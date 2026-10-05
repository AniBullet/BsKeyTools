# BsKeyTools 发版 Runbook

> 现行流程（2026-10 核对）。旧的 manifest.json 增量更新方案已撤销，`docs/superpowers/` 下 2026-05-13 的 spec/plan 仅作历史参考。

## 1. 概述与分支策略

- `dev`：日常开发、PR 目标分支（见 `.github/workflows/greetings.yml`、`CONTRIBUTING.md`）。
- `main`：发版分支。`dev` 合入 `main` 并 push 后，`.github/workflows/release.yml` 自动判断是否发版。
- `_BsKeyTools/version.dat`（`main` 上的那份）决定用户是否收到更新提示：
  - 插件读取 `https://gitee.com/acebullet/BsKeyTools/raw/main/_BsKeyTools/version.dat`（`BulletKeyTools.ms` 的 `verUrlBsKeyTools`）。
  - 安装包启动时依次读取 Gitee raw / jsDelivr / GitHub raw 的 `main` 分支 `version.dat`（`Setup_BsKeyTools.nsi` 的 `CheckForUpdates`）。
- 因此 **`version.dat` 一旦在 `main` 上变化并同步到 Gitee，用户就会被提示升级**，必须保证对应安装包已经可下载。

## 2. 版本号位置

| 位置 | 说明 | 谁改 |
|---|---|---|
| `_BsKeyTools/Scripts/BulletScripts/BulletKeyTools.ms` 的 `global curVerBsKeyTools = "x.y.z"` | BsKeyTools 主版本，**唯一源头** | 手改 |
| `_BsKeyTools/Scripts/BulletScripts/BsCleanVirus.ms` 的 `global curVerBsCleanVirus = "x.y"` | BsCleanVirus 版本 | 手改（需要时） |
| `_BsKeyTools/version.dat` | 单行 BsKeyTools 版本 | 发版前在 `dev` 本地跑 `scripts/update_manifest.py` 并随发版提交（CI 只校验，不回写） |
| `_BsKeyTools/Setup_BsKeyTools.nsi` 的 `!define PRODUCT_VERSION_NUM` | 安装包版本，`PRODUCT_VERSION` 由它派生 `_v<ver>` | `update_manifest.py`（本地打包前可手改或跑脚本） |
| `_BsKeyTools/Setup_BsCleanVirus.nsi` 的 `!define PRODUCT_VERSION "_v<ver>"` | BsCleanVirus 安装包版本 | `update_manifest.py` |
| Git tag `v<BsKeyTools 版本>` | 发版标记，CI 创建 | CI（`gh release create`） |
| Release 资产 `BsKeyTools_v<ver>.exe` / `BsCleanVirus_v<cvver>.exe` | 由 CI 改名生成 | CI |

`scripts/update_manifest.py` 行为：
- 用正则从两个 `.ms` 读取版本；读不到直接抛错。
- 若设置了环境变量 `RELEASE_VERSION`，必须等于 `curVerBsKeyTools`，否则抛错。
- 写 `version.dat`（UTF-8、LF、单行）并更新两个 `.nsi` 的版本宏。

注意：`fnCheckUpdate.ms` / `fnUpdater.ms` 文件头的 `@Version` 只是注释，不参与任何逻辑。

## 3. 本地打包

产物（均覆盖 Git 跟踪的文件）：
- `_BsKeyTools/_BsKeyTools.exe`（`Setup_BsKeyTools.nsi` 的 `OutFile`）
- `_BsKeyTools/BsCleanVirus_Standalone.exe`（`Setup_BsCleanVirus.nsi` 的 `OutFile`）

方式：
- `_BsKeyTools/build.bat`：依次编译两个 `.nsi`。只查找 PATH、`C:\Program Files (x86)\NSIS`、`C:\Program Files\NSIS`，**不读注册表**。
- IDE 任务（`.vscode/tasks.json`）：`NSIS: Build Current File`（默认构建，`Ctrl+Shift+B`）、`NSIS: Build BsKeyTools`、`NSIS: Build BsCleanVirus`，都调用 `.vscode/build_nsi.ps1`。该脚本额外查 `HKLM:\SOFTWARE\NSIS` 注册表，找不到会尝试 winget/choco 自动安装。

本机 NSIS 在 `D:\NSIS`，不在 PATH。`build.bat` 会报"找不到 makensis.exe"，解决办法：
- 直接调用：`cd _BsKeyTools; D:\NSIS\makensis.exe Setup_BsKeyTools.nsi`
- 或临时加 PATH：`$env:Path = "D:\NSIS;$env:Path"` 后再跑 `build.bat`
- 或用 IDE 任务 / `build_nsi.ps1`（能通过注册表找到 `D:\NSIS`）

测试打包（不打算提交 exe 时）：
1. 打包后把产物复制到 `D:\_Scripts\GitHub\BsKeyTools_TestBuild`。
2. `git restore _BsKeyTools/_BsKeyTools.exe _BsKeyTools/BsCleanVirus_Standalone.exe` 还原跟踪的 exe。
3. 本地若手改了 `.nsi` 版本宏，按需还原或随版本提交。

## 4. 发布步骤 Checklist

1. 在 `dev` 上完成功能并通过各自的验证（BsRetarget 见 `docs/BsRetargetTools-validation-checklist.md`）。
2. 改 `curVerBsKeyTools`（必要时改 `curVerBsCleanVirus`），然后**必须**运行 `python scripts/update_manifest.py`，把 `version.dat` 和两个 `.nsi` 一起提交到 `dev`。
   - `main` 受规则集保护（必须走 PR，仅管理员可绕过），CI 的 `github-actions[bot]` 推不上去，所以 `version.dat` 只能随发版提交进入 `main`。`check-version` 会校验 `version.dat == curVerBsKeyTools`，不一致直接失败、不发版。
   - 代价：`version.dat` 进入 `main` 到 GitHub Release 建好之间（约 5–10 分钟）检查更新的用户会下载失败、落到备用页。尽量在用户少的时段发版。
3. 本地打包冒烟：安装到 3ds Max 实测；如要提交跟踪的 `_BsKeyTools.exe`，确认是新版本产物。
4. 确认目标 tag `v<ver>` 在远端不存在（存在则 CI 会跳过发版）。
5. 合并 `dev` → `main` 并 push。不切分支的做法：在 `dev` 上 `git merge origin/main`（带上 `main` 独有的提交），`git push origin dev`，再 `git push origin dev:main`（快进；管理员推送时会提示 "Bypassed rule violations"，属正常）。
   - **`Build and Release` 跑完之前不要再推 `main`**：tag 还没建，再推会触发第二次发版。
6. 盯 GitHub Actions：`Build and Release` 全绿，随后 `Sync to Gitee` 成功。
7. 检查 GitHub Release `v<ver>` 有两个 exe，资产大小正常（BsKeyTools 约 48 MB）。
8. **手动处理 Gitee Release**（推荐，见第 6 节；不建时插件会改从 GitHub Release 下载）：在 Gitee 创建 `v<ver>` Release 并上传 `BsKeyTools_v<ver>.exe`（建议同时上传 BsCleanVirus）。
9. 验证下载链接：`https://gitee.com/acebullet/BsKeyTools/releases/download/v<ver>/BsKeyTools_v<ver>.exe` 返回 200 且大小正确。
10. 确认 Gitee raw `main` 的 `version.dat` 已是新版本；在旧版插件里点"检查更新"实测。
11. `main` 与 `dev` 应保持同一提交；若发版期间 `main` 有额外提交，合回 `dev`。

## 5. CI 做了什么（`.github/workflows/release.yml`）

触发：push 到 `main`。

1. `check-version`（ubuntu）：从两个 `.ms` 正则读版本；`TAG=v<BsKeyTools 版本>`；`git rev-parse "$TAG"` 已存在则 `should_release=false`，后续 job 全部跳过。要发版时校验 `version.dat`（去掉换行/BOM/空格）等于 BsKeyTools 版本，否则 `::error::` 失败。
2. `build-bskeytools`（windows）：checkout `main` → `RELEASE_VERSION=<ver> python scripts/update_manifest.py` → `choco install nsis` → `makensis Setup_BsKeyTools.nsi` → 改名 `BsKeyTools_v<ver>.exe` → 上传 artifact。
3. `build-bscleanvirus`（windows）：同上，产出 `BsCleanVirus_v<cvver>.exe`。
4. `release`（ubuntu）：
   - 下载两个 artifact；
   - `gh release create v<ver> --target main`，标题 `BsKeyTools v<ver>`，正文 `BsKeyTools v<ver> | BsCleanVirus v<cvver>`，附两个 exe。
   - 不再回推 `main`（2026-10 起）。v1.4.1 发版时旧的 "Update version.dat and commit to main" 步骤被 `main` 规则集拒绝（`GH013: Changes must be made through a pull request`），已删除。

`.github/workflows/sync-gitee.yml`（Gitee 镜像拉取的唯一入口，`60ee9fc` 起）：
- 触发：`workflow_run`，`Build and Release` 在 `main` 上结束后（不论成功失败）；以及 `workflow_dispatch` 手动触发。不再由 push `main` 直接触发，`release.yml` 里也不再调 Gitee API。这样每次 push 只拉一次。
- 新触发方式只有合入 `main` 后才生效（`workflow_run` / `workflow_dispatch` 以默认分支上的工作流文件为准）。
- `concurrency: sync-gitee`，不取消进行中的运行。
- 流程：读 GitHub `main` HEAD；Gitee `main` 已相同则直接成功跳过；否则 `POST remote_mirror/pull`（`secrets.GITEE_TOKEN`），非 2xx 失败；之后每 30 秒查一次 Gitee `main`，最多 10 分钟，等于目标 SHA 或当前 GitHub `main` HEAD 即成功；超时报 `::error::`（提示去 Gitee 仓库镜像管理更换 GitHub 令牌）并 exit 1。

CI **不会**：创建 Gitee Release、上传 Gitee 附件、提交 `_BsKeyTools.exe`。

## 6. Gitee 同步与 Gitee Release

已确认（2026-10-06 查询 Gitee/GitHub API + `gh run`）：
- Gitee 只有 **1 个** Release：`v1.4.0`，`created_at 2026-05-26T14:09:19+08:00`，作者 `acebullet`，正文 `BsKeyTools v1.4.0 | BsCleanVirus v2.2`，附件 `BsKeyTools_v1.4.0.exe`（48108122 字节，下载链接返回 200）、`BsCleanVirus_v2.2.exe`。
- 它是 GitHub Actions run `26435428759`（commit `2970c33`）里当时存在的 `Create Gitee Release and upload installers` 步骤创建的：该步骤 06:09:17Z 开始，Gitee Release 06:09:19Z 创建，GitHub Release 06:09:17Z 发布。
- 随后 `7994363`（Gitee 仓库超配额）删除了 Gitee 同步/Release，`f85eed4` 只恢复代码同步，`741f6b9` 改为 mirror pull API。**现在的 CI 没有任何创建 Gitee Release 的代码**，仓库里也没有 `.workflow/`（Gitee Go）或其他 Gitee Release 脚本。
- Gitee 上有 `1.3.1`…`v1.3.7` 等 tag（随代码同步），但都没有 Release。

需要验证：
- Gitee 仓库镜像（pull mirror）是否会同步 GitHub Release。我的判断是不会（镜像只同步分支/tag/提交，现有证据中没有任何非 CI 创建的 Gitee Release）；v1.4.0 之后还没发过版，无法用实际数据证伪。下次发版后用 `https://gitee.com/api/v5/repos/acebullet/BsKeyTools/releases/tags/v<ver>` 确认。

影响：若不手动建 Gitee Release，插件从 Gitee 下载 `.../releases/download/v<ver>/BsKeyTools_v<ver>.exe` 会 404，随后自动改从 GitHub Release 下载（见第 7 节）；国内访问 GitHub 慢或不通的用户才会落到备用页 `https://anibullet.github.io/`。所以手动建 Gitee Release 仍然推荐，但不再是发版的硬性前提。

### 镜像同步与校验

Gitee 镜像依赖 Gitee 仓库 → 管理 → 仓库镜像管理 里配置的 GitHub classic 私人令牌（repo 权限）；GitHub Secret `GITEE_TOKEN` 只用于调用 Gitee `remote_mirror/pull` API。API 返回 204 不代表拉取成功；令牌过期时 Gitee `main` 会停在旧提交。镜像不同步 Release。

- 校验：`Sync to Gitee` 会轮询比对 Gitee 与 GitHub 的 `main` HEAD（见第 5 节），超时标红即说明没拉到。手动核对用 `https://gitee.com/api/v5/repos/acebullet/BsKeyTools/branches/main` 与 `https://api.github.com/repos/AniBullet/BsKeyTools/branches/main` 的 `commit.sha`。
- 手动补同步：`gh workflow run sync-gitee.yml -R AniBullet/BsKeyTools --ref main`，或在 Actions 页面对 `Sync to Gitee` 点 Run workflow。
- Gitee 拉取间隔需 ≥5 分钟，太频繁会被拒；连续 5 次失败 Gitee 会停用该镜像，需在同一页面（仓库镜像管理）重新启用。
- 恢复令牌：在 https://github.com/settings/tokens/new?scopes=repo&description=Gitee_Mirror 新建令牌，到镜像管理替换并点"更新"（间隔 ≥5 分钟），然后手动触发 `Sync to Gitee` 或对比上面两个 API 的 `main` HEAD。

## 7. 插件内更新链路

文件：`_BsKeyTools/Scripts/BulletScripts/fnCheckUpdate.ms`、`fnUpdater.ms`（由 `BulletKeyTools.ms` `FileIn` 加载）。

- `fnFetchVersionDat`：`WebClient.DownloadString` 拉 `version.dat`，取第一行并去掉首尾空白/换行/BOM；失败返回 `undefined`（Listener 打印异常）。
- 版本比较用 `fnBsCompareVersion online local`（返回 1/0/-1，无法解析返回 `undefined`）：
  - 按 `.` 分段逐段按整数比较，缺失段按 0（`1.4` == `1.4.0`，`1.4.1` > `1.4.0`，`1.10` > `1.9`）。
  - `_` 之后视为预发布后缀（历史上用过 `1.1.0_Beta`、`0.9.9.9_Beta2`）：数字段相同时带后缀的低于正式版，都带后缀按后缀字符串不区分大小写比较。
  - 数字段含非数字字符、出现空段（如 `1..4`）或后缀为空，视为无法解析。
- `fnAutoCheckVersion`（启动时）：线上更高且未被跳过（INI `BulletKeyToolsSet` / `SkipVersionBskt`）才弹窗；相等静默；本地更高只在 Listener 打印一行；无法解析在 Listener 打印错误；拉取失败静默返回。
- `fnCheckUpdate`（菜单"检查更新"）：拉取失败弹"获取版本信息失败"；线上更高弹更新提示；相等弹"当前已是最新版本"；本地更高弹"本地版本高于线上版本"；无法解析弹错误并在 Listener 记录。`force:true`（强制更新）跳过大小比较直接提示，但线上版本无法解析时同样报错不提示下载。
- 弹窗：是=下载安装包，否=稍后，取消=写入跳过版本。
- 下载源（`fnBsktInstallerSources`）按顺序尝试：
  1. Gitee Release：`https://gitee.com/acebullet/BsKeyTools/releases/download/v<ver>/BsKeyTools_v<ver>.exe`（国内快，需手动上传附件，见第 6 节）。
  2. GitHub Release：`https://github.com/AniBullet/BsKeyTools/releases/download/v<ver>/BsKeyTools_v<ver>.exe`（`release.yml` 自动发布；会重定向到 `release-assets.githubusercontent.com`，`WebClient` 自动跟随）。
- `fnUpdaterDownloadInstaller`：
  - 下载前在现有 `ServicePointManager.SecurityProtocol` 上追加 TLS 1.2（失败写 Listener）。`fnCheckUpdate.ms` 加载时也会把协议设为 TLS 1.2。
  - 每个源下载到 `#temp\BsKeyTools_v<ver>.exe`，尝试前删除旧文件；Listener 打印源名称和 URL。
  - 失败原因写 Listener：`WebClient` 异常（如 `(404) Not Found`）或文件 ≤ 512000 字节（疑为错误页）；失败后删除残留文件再试下一个源。
  - 任一源成功即 `ShellLaunch` 安装包；全部失败弹"安装包下载失败（已尝试 Gitee、GitHub，均失败）"并打开 `https://anibullet.github.io/`。
  - 同步下载，期间 Max 界面无响应；Gitee 404 通常很快返回，主要耗时在 GitHub 下载。
- 安装包自身 `.onInit` 也会检查 `version.dat`，`VersionCompare` 远端更新时提示并打开 `https://github.com/AniBullet/BsKeyTools/releases/latest`。

## 8. 仓库里的 exe 文件

`git ls-files "*.exe"`：
- `_BsKeyTools/_BsKeyTools.exe`：完整安装包。早期插件（2022-09 `c89080b` 起的 0.9.9.x 系列）从 `https://gitee.com/acebullet/BsKeyTools/raw/main/_BsKeyTools/_BsKeyTools.exe` 下载更新，引导页/网盘压缩包说明也让用户运行它。要保持 `main` 上是可用的新版安装包。
- `_BsKeyTools/BsCleanVirus_Standalone.exe`：独立杀毒安装包。
- `_BsKeyTools/AnimRef/Contents/converter/ffmpeg.exe`、`gifsicle.exe`、`_BsKeyTools/Scripts/BulletScripts/Res/fbxreview.exe`：运行时工具，随安装包分发。

不要把这些 exe 加进 `.gitignore`，也不要随手提交测试产物。

## 9. BsScriptHub 远程脚本索引

- `_BsKeyTools/Scripts/BsScriptHub/**` 变更 push 到 `main` 或 `dev` 时，`.github/workflows/update-index.yml` 运行 `generate_index.py`。
  - `dev`：索引有变化就由 bot 提交并推送（`dev` 规则集是 disabled）。
  - `main`：受规则集保护，bot 推不上去（v1.4.1 发版时报 `GH013` 失败过）。现在只检查，索引过期给 `::warning::` 不提交；索引应在 `dev` 上先更新好再合入。
- 安装包不打包该目录（`Setup_BsKeyTools.nsi`：`File /r /x "BsScriptHub" "Scripts\*.*"`），客户端 `BsScriptHub.py` 运行时从 GitHub raw（`main`/`dev` 可切换）读取。
- 所以 BsScriptHub 脚本更新**不需要发版**。

## 10. 常见坑

- tag 已存在 → CI 静默跳过发版。重发同一版本需先删远端 tag 和 GitHub Release。
- `main` 规则集（2025-12 建，`pull_request` + 禁删 + 禁强推，仅仓库管理员 bypass）→ 任何 workflow 用 `GITHUB_TOKEN` 往 `main` 推都会 `GH013` 失败。新增 workflow 不要设计成回推 `main`。
- 忘了跑 `update_manifest.py` → `check-version` 报 `version.dat ... 不一致` 并失败，不会发版。补提交 `version.dat` 后再推即可（tag 未建，会正常发版）。
- 发版运行中又推 `main` → 可能并发两次发版。等 `Build and Release` 结束再推。
- 工作流文件的改动（尤其 `workflow_run` / `workflow_dispatch` 触发）要合入 `main` 后才生效；在 `dev` 上改完不能直接验证。
- `RELEASE_VERSION` 与 `curVerBsKeyTools` 不一致 → `update_manifest.py` 报错，构建失败。
- 改了版本但没建 Gitee Release → 插件自动改从 GitHub Release 下载；GitHub 也不通的用户才落到备用页。
- `version.dat` 早于安装包进入 `main` → 用户提前收到更新提示（Gitee、GitHub 都没有安装包时直接落到备用页）。现行流程下这是发版时约 5–10 分钟的固有窗口，见第 4 节第 2 步。
- `version.dat` 内容不是合法版本号（如 Gitee 返回 HTML 页、写错格式）→ 插件报"无法解析版本号"，不会提示更新。首尾空白/换行/BOM 会被去掉，不影响比较；`update_manifest.py` 写的是无 BOM UTF-8 + LF。
- 线上 `version.dat` 低于本地版本（如本地测试包先于发版）→ 不提示更新，手动检查显示"本地版本高于线上版本"。
- 本地 `build.bat` 找不到 `D:\NSIS` → 见第 3 节。
- 本地打包会改动跟踪的 exe，提交前 `git status` 确认。
- Gitee 同步失败（镜像令牌过期、镜像被停用等）只会让 `Sync to Gitee` 标红，不影响已创建的 GitHub Release；按第 6 节恢复后手动触发 `Sync to Gitee`。
