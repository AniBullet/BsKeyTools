> 已过时：增量更新/manifest.json 方案已撤销，现行流程见 docs/release-runbook.md

# BsKeyTools 增量自动更新系统设计

- **日期**：2026-05-13
- **目标版本**：2.0 大版本变化
- **状态**：待实现

---

## 背景

当前用户更新流程：插件通过 `fnCheckUpdate.ms` 比对 `version.dat` 版本号，发现差异后提示用户去 GitHub/Gitee 下载完整安装包（exe），体验差、流量浪费。

目标：绝大多数更新（脚本文件改动）无需重下安装包，只下载变化的文件，完成后提示重开 Max 即可。只有结构性大改时才走重装流程。

---

## 核心决策

| 决策点 | 选择 | 原因 |
|--------|------|------|
| 更新触发方式 | 弹窗确认（B） | 保持用户可见，不静默替换文件 |
| 更新器位置 | 内嵌插件（新增独立模块） | 只有 BsKeyTools 一个插件，无需独立更新器 |
| 版本粒度 | 整体版本号 + 文件级 `since` 字段 | 单人维护，低成本，不易漏更新 |
| dlm 更新 | 基本不变，有变动走重装流程 | dlm 版本定型后不改 |
| 脚本更新后重载 | 提示重开 Max | 最稳，不处理热重载边界情况 |
| Gitee 同步 | GitHub Actions 自动镜像 | push main 后自动同步，开发者只管 GitHub |

---

## 整体架构

```
GitHub (开发)                    用户端 (3ds Max)
─────────────────                ─────────────────────────────────
dev 分支开发
    ↓ PR merge
main 分支                        启动 Max
    ↓ GitHub Action              → BulletKeyTools.ms 加载
Gitee 镜像 (用户访问)            → fnCheckUpdate.ms 拉 manifest.json
  ├── _BsKeyTools/manifest.json  → 版本比对
  ├── Scripts/...ms              → 弹窗确认
  └── Scripts/...py                  ↓
                                 fnUpdater.ms 执行
                                  ├── 增量：下载文件 → 提示重开 Max
                                  └── 重装：下载 exe → 失败则开网页
```

---

## 文件变动清单

| 文件 | 变化 |
|------|------|
| `_BsKeyTools/Scripts/BulletScripts/fnCheckUpdate.ms` | 重构，瘦身为「拉 manifest + 版本判断 + 弹窗」 |
| `_BsKeyTools/Scripts/BulletScripts/fnUpdater.ms` | **新增**，负责所有下载和文件操作 |
| `_BsKeyTools/manifest.json` | **新增**，替代 `version.dat` |
| `.github/workflows/sync-gitee.yml` | **新增**，自动镜像到 Gitee |

---

## manifest.json 结构

路径：`_BsKeyTools/manifest.json`，托管在 Gitee，通过 raw 链接访问。

```json
{
  "version": "2.0.0",
  "requireReinstall": false,
  "releaseNote": "更新说明，直接显示在弹窗中",
  "files": [
    { "path": "Scripts/BulletScripts/BsBipedTools.ms",    "since": "2.0.0", "size": 15420 },
    { "path": "Scripts/BulletScripts/BsRetargetTools.ms", "since": "2.0.0", "size": 9800 },
    { "path": "Scripts/BulletScripts/Lang/CHS.lng",       "since": "1.3.5", "size": 3200 }
  ],
  "installer": {
    "url": "https://gitee.com/acebullet/BsKeyTools/releases/download/v2.0.0/BsKeyTools_v2.0.0.exe",
    "fallbackUrl": "https://anibullet.github.io/guide/"
  }
}
```

**字段说明：**

- `version` — 当前最新版本号，与 `BulletKeyTools.ms` 中 `curVerBsKeyTools` 比对
- `requireReinstall` — `true` 时跳过增量更新，直接走重装流程
- `releaseNote` — 更新说明，显示在确认弹窗里
- `files[].since` — 该文件最后改动的版本。客户端判断：`since > 本地版本` 则下载
- `files[].size` — 字节数，下载后校验用，防止 Gitee 限流时下到 HTML 错误页
- `installer.url` — 完整安装包直链（Gitee Release）
- `installer.fallbackUrl` — 下载失败时打开的网页（现有下载引导页）

**每次发版只需修改：**
1. `version` 字段
2. 改过的文件的 `since` 改为新版本号
3. `requireReinstall` 根据情况设 `true`/`false`
4. `releaseNote` 写更新说明

---

## 更新流程

### 增量更新（`requireReinstall: false`）

```
弹窗显示：
  「发现新版本 2.0.0
   <releaseNote 内容>
   是否立即更新？（更新后需重开 Max）」
  [确定]  [取消]  [跳过此版本]

用户点确定：
  for 每个 since > 本地版本 的文件:
    ① 下载到 %TEMP%\BsUpdate\filename.tmp
    ② 验证文件大小 == manifest.size
    ③ 成功 → 覆盖正式路径
    ④ 失败 → 跳过该文件，静默记录，不影响其他文件
  全部完成 → 弹窗「更新完成，请重开 Max 生效」
```

### 重装流程（`requireReinstall: true`）

```
弹窗显示：
  「发现新版本 2.0.0（需重新安装）
   此版本包含较大改动，需要重新运行安装包
   是否立即下载安装？」
  [下载安装]  [取消]

用户点下载：
  ① 尝试 WebClient 下载 installer.url 到 %TEMP%\BsKeyTools_Setup.exe
  ② 成功 → ShellLaunch 启动安装程序
  ③ 失败 → ShellLaunch installer.fallbackUrl（打开浏览器下载页）
```

### 「跳过此版本」行为
将当前远端版本号写入 `BulletConfig.ini`，下次启动不再提示该版本。下一个更新版本照常提示。

---

## fnUpdater.ms 模块边界

```maxscript
-- 对外接口（fnCheckUpdate.ms 调用）

-- 下载所有 since > localVer 的脚本文件
fn fnUpdaterDownloadFiles manifest localVer = ( ... )

-- 下载安装包并启动，失败则打开网页
fn fnUpdaterDownloadInstaller manifest = ( ... )

-- 内部函数（不对外）

-- 下载单个文件到临时目录，返回临时路径或 undefined
fn fnDownloadToTemp url filename = ( ... )

-- 校验文件大小是否匹配
fn fnVerifyFile path expectedSize = ( ... )

-- 将临时文件安全覆盖到目标路径
fn fnSafeCopy src dst = ( ... )
```

**关键实现细节：**
- 所有 URL 通过 `dotNetObject "System.Uri"` 构造，避免中文/特殊字符编码问题
- 下载全程包在 `try/catch` 中，异常静默处理，绝不影响插件正常运行
- TLS 设置复用现有 `spm.SecurityProtocol = Tls12`
- 下载前检查磁盘空间（可选，避免极端情况）

---

## fnCheckUpdate.ms 重构后职责

重构后只做三件事：

1. 通过 `WebClient.DownloadString` 拉取 `manifest.json` 并简单解析
2. 比对 `remoteVersion` vs `curVerBsKeyTools`
3. 弹窗 → 根据用户选择调用 `fnUpdaterDownloadFiles` 或 `fnUpdaterDownloadInstaller`

不再包含任何文件操作逻辑。

---

## GitHub Actions 自动同步到 Gitee

文件路径：`.github/workflows/sync-gitee.yml`

```yaml
name: Sync to Gitee
on:
  push:
    branches: [ main ]

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Mirror to Gitee
        uses: wearerequired/git-mirror-action@master
        env:
          SSH_PRIVATE_KEY: ${{ secrets.GITEE_SSH_PRIVATE_KEY }}
        with:
          source-repo: "git@github.com:AniBullet/BsKeyTools.git"
          destination-repo: "git@gitee.com:acebullet/BsKeyTools.git"
```

**一次性配置步骤：**
1. 本机生成 SSH 密钥对：`ssh-keygen -t ed25519 -C "github-to-gitee"`
2. 公钥 → Gitee「设置 → SSH 公钥」
3. 私钥 → GitHub「Settings → Secrets → Actions → New secret」，名称 `GITEE_SSH_PRIVATE_KEY`

配置后，每次 `git push origin main` 自动触发镜像，`manifest.json` 用户端立即可用。

---

## 分支策略与用户安全

```
main                     ← 生产分支，用户锚点，非发版绝对不改
  │
  └─ feature/xxx         ← 功能开发分支，随意改，不影响任何用户
```

**用户触发更新的唯一开关是 `version.dat`**：
- v1.3.7 用户的旧 `fnCheckUpdate.ms` 只读 `version.dat`
- 只要 main 上 `version.dat` 还是 `"1.3.7"`，所有在线用户零感知
- CI workflow 只在 `push main` 时运行，feature 分支 push 不触发

**v2.0.0 特殊情况**：
- v2.0.0 在 feature 分支上开发，代码改动不影响用户
- 只有 merge 到 main 且 CI 运行后，version.dat 才会变成 "2.0.0"
- 届时需要 Gitee Release 上已有 `BsKeyTools_v2.0.0.exe` 安装包

---

## 发版工作流（完整）

### 日常小版本发版（2.0.0 之后，增量更新生效）

```
1. feature 分支改代码
2. 在 BulletKeyTools.ms 中更新 curVerBsKeyTools（如 "2.0.1"）
3. 在 manifest.json 中写好 releaseNote（发版说明）
   - version / since / requireReinstall 由 CI 自动更新，无需手动改
4. PR merge 到 main
5. GitHub Actions 自动：
   - 运行 update_manifest.py（更新 version、size、since、version.dat）
   - commit 变动 [skip ci]
   - 镜像到 Gitee
6. 用户下次打开 Max 自动收到增量更新提示
```

### v2.0.0 首次发版（一次性全量安装包）

```
1. feature/auto-update-v2 所有功能测试完毕
2. 打包 BsKeyTools_v2.0.0.exe 安装包
3. 上传到 Gitee Release（tag: v2.0.0）
4. 确认下载引导页 https://anibullet.github.io/guide/ 有 v2.0.0 链接
5. PR merge 到 main
6. CI 运行，version.dat 变成 "2.0.0"，镜像到 Gitee
7. v1.3.7 用户下次开 Max → 弹窗「发现新版本 2.0.0」
   → 点「是」→ 打开下载引导页 → 手动下载安装 v2.0.0
8. 装完后，以后所有更新走增量，不再需要装包
```

---

## 兼容性与边界情况

| 场景 | 处理方式 |
|------|---------|
| 无网络 / Gitee 不可达 | 静默跳过，不提示，不影响插件使用 |
| 下载中断 / 文件损坏 | 大小校验失败 → 丢弃临时文件，保留旧版本 |
| Gitee 限流返回 HTML | 大小校验不匹配 → 同上 |
| 文件被 Max 锁定 | `fnSafeCopy` 捕获异常，跳过该文件 |
| 用户跳过某版本 | 写入 ini，下个版本恢复提示 |
| Python 脚本更新 | 同 .ms 文件，加入 files 列表，更新后提示重启 Max |
| 旧版 Max（2019以下）| 无 Python 支持，.py 文件跳过，其余正常更新 |
