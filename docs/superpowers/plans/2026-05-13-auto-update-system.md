> 已过时：增量更新/manifest.json 方案已撤销，现行流程见 docs/release-runbook.md

# BsKeyTools 增量自动更新系统 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 BsKeyTools 的更新流程从「下载完整安装包」升级为「按需差量下载脚本文件」，同时实现安装包全自动构建发布。

**Architecture:** 新增 `fnUpdater.ms` 负责所有文件下载逻辑；重构 `fnCheckUpdate.ms` 专职版本比对与弹窗；`manifest.json` 托管在 Gitee，记录各文件版本与大小；GitHub Actions 在 push tag 后自动构建安装包，同时发布到 GitHub Release 和 Gitee Release，并镜像代码到 Gitee。

**Tech Stack:** MAXScript, dotNet (System.Net.WebClient / System.IO.File / System.Text.RegularExpressions), GitHub Actions, Gitee raw 文件托管, Gitee/GitHub Release

---

## 当前状态（2026-05-16）

| 任务 | 状态 |
|------|------|
| manifest.json | ✅ 已完成 |
| fnUpdater.ms | ✅ 已完成，已在 Max 2026 验证 |
| fnCheckUpdate.ms 重写 | ✅ 已完成，已在 Max 2026 验证 |
| BulletKeyTools.ms 接入 | ✅ 已完成 |
| .gitattributes（LF 统一）| ✅ 已完成 |
| scripts/update_manifest.py | ✅ 已完成 |
| sync-gitee.yml（push main 自动镜像）| ✅ 已完成 |
| release.yml（tag 触发全自动发版）| ✅ 已完成 |
| GitHub Secrets 配置 | ✅ 已完成（`GITEE_SSH_PRIVATE_KEY` + `GITEE_TOKEN`）|
| Max 端到端测试 | ✅ 通过（弹窗、下载、失败降级均正常）|
| **merge 到 main + 正式发版** | ⏳ 等其他功能完成后一起发 |

**当前所在分支：** `feature/auto-update-v2`  
**计划版本：** `v1.4.0`（不跳 2.0，循序渐进）

---

## 分支与发版安全原则

```
main               ← 生产分支，用户锚点，非发版绝对不改
  └─ feature/xxx   ← 功能开发，随意改，不影响任何用户
```

**用户触发更新的唯一开关是 `version.dat`**：只要 main 上 version.dat 还是旧版本，所有在线用户零感知。CI workflow 只在 push main / push tag 时运行，feature 分支不触发。

---

## 文件结构总览

| 文件 | 状态 | 职责 |
|------|------|------|
| `_BsKeyTools/manifest.json` | ✅ 新增 | 远端版本清单，Gitee raw 访问 |
| `_BsKeyTools/Scripts/BulletScripts/fnUpdater.ms` | ✅ 新增 | 版本比较、下载、校验、覆盖、pycache 清理 |
| `_BsKeyTools/Scripts/BulletScripts/fnCheckUpdate.ms` | ✅ 重写 | manifest 拉取解析、弹窗、调用 fnUpdater |
| `_BsKeyTools/Scripts/BulletScripts/BulletKeyTools.ms` | ✅ 修改 | 版本 1.4.0、manifestUrl、加载 fnUpdater |
| `scripts/update_manifest.py` | ✅ 新增 | CI 自动维护 manifest（size/since/version.dat）|
| `.github/workflows/sync-gitee.yml` | ✅ 新增 | push main → 更新 manifest → 镜像 Gitee |
| `.github/workflows/release.yml` | ✅ 新增 | push tag → 构建 exe → 发 GitHub+Gitee Release |
| `.gitattributes` | ✅ 新增 | 强制 LF，防止 size 校验误差 |

**NSIS 无需改动**：`File /r "Scripts\*.*"` 已递归包含 fnUpdater.ms。manifest.json 从 Gitee 远端拉取，不需安装到用户本地。NSIS 版本号由 `update_manifest.py` 在 CI 中自动更新。

---

## 已知 MAXScript 兼容问题（已修复）

| 问题 | 原因 | 修复 |
|------|------|------|
| `min` 函数 undefined | MAXScript 无两参数 `min(a,b)` | 改为 `if a < b then a else b` |

---

## 发版流程（v1.4.0 及以后所有版本）

### 你需要做的全部工作

```
1. 改代码（在 feature 分支）
2. 更新 BulletKeyTools.ms 中的版本号（curVerBsKeyTools）
3. 更新 manifest.json 中的 releaseNote（写更新说明给用户看）
   ← size / since / version.dat / NSIS 版本号 全部由 CI 自动更新，无需手动改
4. PR → merge 到 main
5. git tag v1.4.0 && git push origin v1.4.0
```

### CI 自动完成的全部工作

```
push main 触发 sync-gitee.yml：
  ① update_manifest.py 更新 manifest size / since / version.dat
  ② commit 回 main [skip ci]
  ③ 镜像代码到 Gitee

push tag v1.4.0 触发 release.yml：
  ① update_manifest.py 更新 manifest
  ② makensis 构建 BsKeyTools_v1.4.0.exe
  ③ 发布 GitHub Release + 上传 exe
  ④ 发布 Gitee Release + 上传 exe（国内主下载源）
  ⑤ commit manifest 回 main [skip ci]
  ⑥ 镜像代码到 Gitee
```

### 下载地址策略

| 字段 | 地址 | 说明 |
|------|------|------|
| `installer.url` | `gitee.com/.../releases/download/v{ver}/...exe` | 主下载，国内速度快 |
| `fallbackUrl` | `github.com/.../releases/download/v{ver}/...exe` | 备用，Gitee 挂了时 |

### GitHub Secrets 配置（一次性，已完成）

| Secret 名称 | 用途 |
|-------------|------|
| `GITEE_SSH_PRIVATE_KEY` | 代码镜像到 Gitee（SSH push）|
| `GITEE_TOKEN` | Gitee API 创建 Release + 上传文件 |

> ⚠️ 安全提示：token 只存在 GitHub Secrets 中，不出现在代码、文档或任何明文记录里。

---

## 用户侧更新体验

### v1.3.7 → v1.4.0（一次性全量安装）

```
用户开 Max → 旧 fnCheckUpdate.ms 读 version.dat → 发现 1.4.0 > 1.3.7
→ 弹窗「发现新版本 1.4.0」→ 点是 → 尝试下载 Gitee Release exe
→ 成功：静默安装  失败：打开 GitHub Release 页面
→ 装完后以后所有更新走增量，不再需要装包
```

### v1.4.0 以后（增量更新）

```
用户开 Max → 新 fnCheckUpdate.ms 拉 manifest.json → 版本比对
→ 有更新：弹窗显示 releaseNote + 三按钮（立即/稍后/跳过）
→ 点立即：只下载 since > 本地版本 的文件 → 提示重开 Max
→ 点跳过：写入 ini，该版本不再提示
```

---

## 待完成（发版前 checklist）

- [ ] 完成 v1.4.0 其他功能开发
- [ ] 确认 `manifest.json` 的 `releaseNote` 写好
- [ ] 确认 `BulletKeyTools.ms` 第 29 行 `curVerBsKeyTools = "1.4.0"`
- [ ] PR merge `feature/auto-update-v2` → `main`
- [ ] 等 `sync-gitee.yml` 跑完（约 1-2 分钟）
- [ ] `git tag v1.4.0 && git push origin v1.4.0`
- [ ] 确认 GitHub Actions `release.yml` 全绿
- [ ] 确认 GitHub Release 有 exe
- [ ] 确认 Gitee Release 有 exe
- [ ] 在 Max 中最终验收（将 curVerBsKeyTools 临时改回 1.3.7 触发更新流程）
