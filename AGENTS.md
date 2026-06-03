---
description: Repository-wide agent rules
alwaysApply: true
---

# Repository Agent Rules

This file is the canonical agent instruction file for this repository.

Mirror paths:

- `CLAUDE.md`
- `.cursor/rules/agents.mdc`

On this Windows workspace these mirror paths should be NTFS hardlinks to this file. Edit `AGENTS.md` as the source of truth, then run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/check-agent-rules.ps1
```

## Communication

- 始终中文回复。
- 回复自然简短，先给结论，再给必要证据。
- 不确定就明确说“我的判断是...”或“需要验证”。
- 用户要求计划时，先列计划，不直接动代码。

## Git / Workspace

- 修改前先看当前分支和 `git status --short --branch`。
- 不切分支，除非用户明确要求。
- 不回滚、不覆盖用户或其他 agent 的改动。
- 如果同一分支有并行 agent，只碰自己认领的文件。
- `dev` 分支不要混入临时工作区改动；需要确认时用只读 git 命令检查。

## Editing

- 只碰任务必须碰的文件。
- 手工编辑文件用 `apply_patch`。
- 不做大规模格式化、换行、重命名，除非任务需要。
- 文本文件默认 UTF-8；本仓库脚本和文档保持 CRLF。
- Windows 下不要用破坏性命令；递归删除/移动前必须确认目标路径。

## Error Handling

- 遇到问题不能只绕过、吞错或让流程“看起来能跑”；必须暴露关键错误、说明已知/未知状态，并尽量定位根因。
- 可以减少成功弹窗或 UI 噪音，但文件缺失、格式不兼容、Root/Biped 缺失、异常路径、核心步骤失败必须提示或记录。
- `quiet` / `silent` / fallback 逻辑只能压制非关键信息；不得掩盖真实失败，也不得把未验证状态汇报成已成功。

## MaxScript

- MaxScript 函数必须在第一次使用之前定义。
- 新增 helper 后，要检查是否被更早的函数或 rollout handler 调用。
- 避免隐式全局临时变量；能局部化就用 `local`。
- 不轻易改 Biped 创建顺序、对齐数学、约束算法、FBX 导入导出参数。
- **函数定义顺序**：MaxScript（尤其在 rollout 内）必须先定义后使用。如果函数 A 调用函数 B，B 必须在 A 之前定义。`global` 前向声明在 rollout 内部不能解决此问题，唯一可靠方式是调整定义顺序。
- BsRetargetTools 改动后至少运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/check-bs-retarget-script.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools/check-bs-retarget-lists.ps1
```

## IDE / MXSPyCOM（在 Max 里执行当前脚本）

本仓库提供通过 **MXSPyCOM** 把当前打开的 `.ms` 送进已启动的 3ds Max 执行，便于快速冒烟（例如改完脚本后验证能否 `fileIn`/语法是否报错）。任务定义在 `.vscode/` 下，适用于支持 **VS Code 兼容任务** 的编辑器（如 Cursor、VS Code、VSCodium 等）。

**人工使用：**

1. 启动 3ds Max，并保证 MXSPyCOM 已按其一贯方式连上。
2. 在 IDE 中打开要测的 `.ms` 文件。
3. `Ctrl+Shift+B` 在本仓库绑定的是默认 **构建** 任务，不会执行 Max 脚本；请用命令面板里的 **`Tasks: Run Task`**（或等价的「运行任务」），选 **`Execute Script in 3ds Max`**。若你在用户 `keybindings.json` 里把该任务绑到了快捷键（如 Ctrl+E），可直接按键。
4. 任务 **`Execute Script in 3ds Max`** 固定为：`powershell … -File .vscode/run_maxscript.ps1`，由脚本查找 **MXSPyCOM.exe** 并执行 `-s`，**不依赖**把工作区里的 `bskeytools.mxspycomPath` 填进 `command`（避免空路径时只剩 `-s` 报错）。可选在用户设置填写 `bskeytools.mxspycomPath`，任务会通过环境变量 `BSKEYTOOLS_MXSPYCOM_PATH` 传给脚本优先使用。  
5. **`${file}` 是当前焦点文件**：必须把焦点放在目标 **`.ms`** 编辑器里再按快捷键（不要停在 `tasks.json`）。

**给 AI 的约定：**

- 在讨论 MaxScript 修改时，可**建议**用户在 IDE 里运行 **`Execute Script in 3ds Max`**（`run_maxscript.ps1`，焦点在 `.ms`；可选 `bskeytools.mxspycomPath`）（需已打开 Max + MXSPyCOM），或在本机终端执行同一脚本，作为**快速验证加载/基础执行**的手段。
- **不能**用该方式代替 `docs/BsRetargetTools-validation-checklist.md` 中的手验；静态检查、`run_maxscript` 与 PowerShell 脚本检查都是辅助，**不**等同于完整插件流程验收。

## BsRetargetTools Scope

BsRetarget 优化相关文件：

- `_BsKeyTools/Scripts/BulletScripts/BsRetargetTools.ms`
- `docs/BsRetargetTools-list-format.md`
- `docs/BsRetargetTools-validation-checklist.md`
- `docs/BsRetargetTools-optimization-summary.md`
- `tools/check-bs-retarget-lists.ps1`
- `tools/check-bs-retarget-script.ps1`

CI/Release 相关文件（与 BsRetarget 任务无关，勿混淆）：

- `.github/workflows/release.yml` -- GitHub Release 自动构建发布
- `.github/workflows/sync-gitee.yml` -- Gitee 镜像同步
- `scripts/update_manifest.py` -- version.dat / NSIS 版本号更新
- `_BsKeyTools/Scripts/BulletScripts/fnCheckUpdate.ms` -- 插件内版本检查（仅 BsKeyTools）
- `_BsKeyTools/Scripts/BulletScripts/fnUpdater.ms` -- 下载安装包

## Validation

- 不能用静态检查冒充 3ds Max 验收。
- 能本地验证的就跑命令并读结果。
- MaxScript 语法和真实插件流程最终必须按 `docs/BsRetargetTools-validation-checklist.md` 在 3ds Max 内手验。
