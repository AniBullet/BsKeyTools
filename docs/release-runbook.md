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

产物（已在 `.gitignore`，不提交，见第 8 节）：
- `_BsKeyTools/_BsKeyTools.exe`（`Setup_BsKeyTools.nsi` 的 `OutFile`）
- `_BsKeyTools/BsCleanVirus_Standalone.exe`（`Setup_BsCleanVirus.nsi` 的 `OutFile`）

方式：
- `_BsKeyTools/build.bat`：依次编译两个 `.nsi`。只查找 PATH、`C:\Program Files (x86)\NSIS`、`C:\Program Files\NSIS`，**不读注册表**。
- IDE 任务（`.vscode/tasks.json`）：`NSIS: Build Current File`（默认构建，`Ctrl+Shift+B`）、`NSIS: Build BsKeyTools`、`NSIS: Build BsCleanVirus`，都调用 `.vscode/build_nsi.ps1`。该脚本额外查 `HKLM:\SOFTWARE\NSIS` 注册表，找不到会尝试 winget/choco 自动安装。

本机 NSIS 在 `D:\NSIS`，不在 PATH。`build.bat` 会报"找不到 makensis.exe"，解决办法：
- 直接调用：`cd _BsKeyTools; D:\NSIS\makensis.exe Setup_BsKeyTools.nsi`
- 或临时加 PATH：`$env:Path = "D:\NSIS;$env:Path"` 后再跑 `build.bat`
- 或用 IDE 任务 / `build_nsi.ps1`（能通过注册表找到 `D:\NSIS`）

测试打包：
1. 打包后把产物复制到 `D:\_Scripts\GitHub\BsKeyTools_TestBuild` 发给测试的人。
2. 本地若手改了 `.nsi` 版本宏，按需还原或随版本提交。

## 4. 发布步骤 Checklist

1. 在 `dev` 上完成功能并通过各自的验证（BsRetarget 见 `docs/BsRetargetTools-validation-checklist.md`）。
2. 改 `curVerBsKeyTools`（必要时改 `curVerBsCleanVirus`），然后**必须**运行 `python scripts/update_manifest.py`，把 `version.dat` 和两个 `.nsi` 一起提交到 `dev`。
   - `main` 受规则集保护（必须走 PR，仅管理员可绕过），CI 的 `github-actions[bot]` 推不上去，所以 `version.dat` 只能随发版提交进入 `main`。`check-version` 会校验 `version.dat == curVerBsKeyTools`，不一致直接失败、不发版。
   - 代价：`version.dat` 进入 `main` 到 GitHub Release 建好之间（约 5–10 分钟）检查更新的用户会下载失败、落到备用页。尽量在用户少的时段发版。
   - 同时写好 `docs/release-notes/v<ver>.md`（写法见 `docs/release-notes/README.md`，要言简意赅、写给用户看）。缺失或为空 `check-version` 直接失败、不发版。
3. 本地打包冒烟：安装到 3ds Max 实测（安装包不提交，正式包由 CI 构建）。
4. 确认目标 tag `v<ver>` 在远端不存在（存在则 CI 会跳过发版）。
5. 合并 `dev` → `main` 并 push。不切分支的做法：在 `dev` 上 `git merge origin/main`（带上 `main` 独有的提交），`git push origin dev`，再 `git push origin dev:main`（快进；管理员推送时会提示 "Bypassed rule violations"，属正常）。
   - **`Build and Release` 跑完之前不要再推 `main`**：tag 还没建，再推会触发第二次发版。
6. 盯 GitHub Actions：`Build and Release` 全绿，随后 `Sync to Gitee` 的 `mirror` 和 `gitee-release` 两个 job 都成功（`gitee-release` 上传附件较慢，v1.4.0 时约 50 分钟）。
7. 检查 GitHub Release `v<ver>` 有两个 exe，资产大小正常（BsKeyTools 约 48 MB）。
8. 检查 Gitee Release `v<ver>` 已自动创建且有两个 exe（见第 6 节）。`gitee-release` 失败时修好原因后补发：`gh workflow run sync-gitee.yml -R AniBullet/BsKeyTools --ref main -f tag=v<ver>`。
9. 验证下载链接：`https://gitee.com/acebullet/BsKeyTools/releases/download/v<ver>/BsKeyTools_v<ver>.exe` 返回 200 且大小正确。
10. 确认 Gitee raw `main` 的 `version.dat` 已是新版本；在旧版插件里点"检查更新"实测。
11. `main` 与 `dev` 应保持同一提交；若发版期间 `main` 有额外提交，合回 `dev`。

## 5. CI 做了什么（`.github/workflows/release.yml`）

触发：push 到 `main`。

1. `check-version`（ubuntu）：从两个 `.ms` 正则读版本；`TAG=v<BsKeyTools 版本>`；`git rev-parse "$TAG"` 已存在则 `should_release=false`，后续 job 全部跳过。要发版时校验 `version.dat`（去掉换行/BOM/空格）等于 BsKeyTools 版本，且 `docs/release-notes/v<ver>.md` 存在且非空，否则 `::error::` 失败。
2. `build-bskeytools`（windows）：checkout `main` → `RELEASE_VERSION=<ver> python scripts/update_manifest.py` → `choco install nsis` → `makensis Setup_BsKeyTools.nsi` → 改名 `BsKeyTools_v<ver>.exe` → 上传 artifact。
3. `build-bscleanvirus`（windows）：同上，产出 `BsCleanVirus_v<cvver>.exe`。
4. `release`（ubuntu）：
   - 下载两个 artifact；
   - `gh release create v<ver> --target main`，标题 `BsKeyTools v<ver>`，正文 = 安装包说明（两个 exe 各装什么，CI 自动生成）+ `docs/release-notes/v<ver>.md`，附两个 exe。v1.4.0、v1.4.1 发布时正文还是写死的一行版本号，v1.4.1 的说明是事后用 `gh release edit --notes-file` 补的。
   - 不再回推 `main`（2026-10 起）。v1.4.1 发版时旧的 "Update version.dat and commit to main" 步骤被 `main` 规则集拒绝（`GH013: Changes must be made through a pull request`），已删除。

`.github/workflows/sync-gitee.yml`（Gitee 镜像拉取的唯一入口，`60ee9fc` 起）：
- 触发：`workflow_run`，`Build and Release` 在 `main` 上结束后（不论成功失败）；以及 `workflow_dispatch` 手动触发。不再由 push `main` 直接触发，`release.yml` 里也不再调 Gitee API。这样每次 push 只拉一次。
- 新触发方式只有合入 `main` 后才生效（`workflow_run` / `workflow_dispatch` 以默认分支上的工作流文件为准）。
- `concurrency: sync-gitee`，不取消进行中的运行。
- 流程：读 GitHub `main` HEAD；Gitee `main` 已相同则直接成功跳过；否则 `POST remote_mirror/pull`（`secrets.GITEE_TOKEN`），非 2xx 失败；之后每 30 秒查一次 Gitee `main`，最多 10 分钟，等于目标 SHA 或当前 GitHub `main` HEAD 即成功；超时报 `::error::`（提示去 Gitee 仓库镜像管理更换 GitHub 令牌）并 exit 1。

- `gitee-release` job（`needs: mirror`，超时 90 分钟）：tag 取 `workflow_dispatch` 输入 `tag`，留空取 GitHub 最新 Release。Gitee Release 已有 GitHub Release 的全部 exe → 直接成功；否则确认 Gitee 已有该 tag（没有就失败，避免 Release 指到 Gitee 旧 `main`）→ `gh release download` 两个 exe → 不存在则用 GitHub Release 的标题和正文创建 Gitee Release → 只上传缺的附件（`attach_files`，非 201 即失败）。失败只让 `Sync to Gitee` 标红，GitHub Release 不受影响。

CI **不会**：提交安装包、回推 `main`。

## 6. Gitee 同步与 Gitee Release

已确认（2026-10-06 查询 Gitee/GitHub API + `gh run`）：
- Gitee 只有 **1 个** Release：`v1.4.0`，`created_at 2026-05-26T14:09:19+08:00`，作者 `acebullet`，正文 `BsKeyTools v1.4.0 | BsCleanVirus v2.2`，附件 `BsKeyTools_v1.4.0.exe`（48108122 字节，下载链接返回 200）、`BsCleanVirus_v2.2.exe`。
- 它是 GitHub Actions run `26435428759`（commit `2970c33`）里当时存在的 `Create Gitee Release and upload installers` 步骤创建的：该步骤 06:09:17Z 开始，Gitee Release 06:09:19Z 创建，GitHub Release 06:09:17Z 发布。
- 随后 `7994363`（Gitee 仓库超配额）删除了 Gitee 同步/Release，`f85eed4` 只恢复代码同步，`741f6b9` 改为 mirror pull API。从那以后到 2026-10 CI 都没有创建 Gitee Release 的代码。
- 已实测：Gitee pull mirror **不同步 Release**，只同步分支和 tag。v1.4.1 发布后 Gitee 有 tag `v1.4.1`，`releases/tags/v1.4.1` 返回 `null`。
- 2026-10 起 `sync-gitee.yml` 的 `gitee-release` job 恢复自动发 Gitee Release（第 5 节），v1.4.1 用 `workflow_dispatch` 补发。

需要验证：
- Release 附件是否计入 Gitee 仓库配额。我的判断是当初超配额主要来自 `git push --force --tags` 镜像推送，v1.4.0 的附件上传本身是成功的；如果以后 `attach_files` 报配额/容量错误，就要改成不传附件、只建 Release 页（插件下载会回退到 GitHub）。

影响：Gitee Release 缺附件时，插件从 Gitee 下载 `.../releases/download/v<ver>/BsKeyTools_v<ver>.exe` 会 404，随后自动改从 GitHub Release 下载（见第 7 节）；国内访问 GitHub 慢或不通的用户才会落到备用页 `https://anibullet.github.io/`。

### 镜像同步与校验

Gitee 镜像依赖 Gitee 仓库 → 管理 → 仓库镜像管理 里配置的 GitHub classic 私人令牌（repo 权限）；GitHub Secret `GITEE_TOKEN` 只用于调用 Gitee `remote_mirror/pull` API。API 返回 204 不代表拉取成功；令牌过期时 Gitee `main` 会停在旧提交。镜像不同步 Release。

- 校验：`Sync to Gitee` 会轮询比对 Gitee 与 GitHub 的 `main` HEAD（见第 5 节），超时标红即说明没拉到。手动核对用 `https://gitee.com/api/v5/repos/acebullet/BsKeyTools/branches/main` 与 `https://api.github.com/repos/AniBullet/BsKeyTools/branches/main` 的 `commit.sha`。
- 手动补同步：`gh workflow run sync-gitee.yml -R AniBullet/BsKeyTools --ref main`，或在 Actions 页面对 `Sync to Gitee` 点 Run workflow。
- Gitee 拉取间隔需 ≥5 分钟，太频繁会被拒；连续 5 次失败 Gitee 会停用该镜像，需在同一页面（仓库镜像管理）重新启用。
- 恢复令牌：在 https://github.com/settings/tokens/new?scopes=repo&description=Gitee_Mirror 新建令牌，到镜像管理替换并点"更新"（间隔 ≥5 分钟），然后手动触发 `Sync to Gitee` 或对比上面两个 API 的 `main` HEAD。

## 7. 插件内更新链路

文件：`_BsKeyTools/Scripts/BulletScripts/fnCheckUpdate.ms`、`fnUpdater.ms`（由 `BulletKeyTools.ms` `FileIn` 加载）。

- `fnFetchVersionDat`（只给手动检查用）：同步 `WebClient.DownloadString` 拉 `version.dat`，期间 Max 无响应；`fnBsVersionFromDatContent` 取第一行并去掉首尾空白/换行/BOM；失败返回 `undefined`（Listener 打印异常）。
- 版本比较用 `fnBsCompareVersion online local`（返回 1/0/-1，无法解析返回 `undefined`）：
  - 按 `.` 分段逐段按整数比较，缺失段按 0（`1.4` == `1.4.0`，`1.4.1` > `1.4.0`，`1.10` > `1.9`）。
  - `_` 之后视为预发布后缀（历史上用过 `1.1.0_Beta`、`0.9.9.9_Beta2`）：数字段相同时带后缀的低于正式版，都带后缀按后缀字符串不区分大小写比较。
  - 数字段含非数字字符、出现空段（如 `1..4`）或后缀为空，视为无法解析。
- `fnAutoCheckVersion`（`rolBsKeyTools` 的 `open` 里调用，设置里开了自动检测才会调）：**异步**，每个 Max 会话只发起一次（全局 `bsAutoCheckStarted`；插件窗口每次打开都会 `fileIn` 重跑 `open`）。
  - `WebClient.DownloadFileAsync` 下到 `#temp\BsKeyTools_version.dat`，主线程上的 `System.Windows.Forms.Timer` 每 200 ms 查一次 `IsBusy`；MaxScript 只在主线程执行，不注册 WebClient 完成事件（在后台线程回调 MaxScript 会崩 Max）。
  - 15 秒没完成就 `CancelAsync` 并在 Listener 打印超时；下载失败/内容为空在 Listener 打印一行；结果处理同前：线上更高且未被跳过（INI `BulletKeyToolsSet` / `SkipVersionBskt`）才弹窗，相等静默，本地更高或无法解析只写 Listener。
  - 1.4.1 及以前是同步下载：Gitee 慢或 TLS 握手卡住时 Max 启动/打开插件会卡住，最长到 WebClient 默认 100 秒超时。
- `fnCheckUpdate`（菜单"检查更新"）：拉取失败弹"获取版本信息失败"；线上更高弹更新提示；相等弹"当前已是最新版本"；本地更高弹"本地版本高于线上版本"；无法解析弹错误并在 Listener 记录。`force:true`（强制更新）跳过大小比较直接提示，但线上版本无法解析时同样报错不提示下载。
- 弹窗用 Max 的 `yesNoCancelBox`（以 Max 主窗口为父窗口）：是=下载安装包，否=稍后，取消=写入跳过版本。不要换回无主的 .NET `MessageBox`：异步检查结果可能在用户操作时弹出，被压在 Max 后面会模态卡住界面。
- 下载源（`fnBsktInstallerSources`）按顺序尝试：
  1. Gitee Release：`https://gitee.com/acebullet/BsKeyTools/releases/download/v<ver>/BsKeyTools_v<ver>.exe`（国内快，`Sync to Gitee` 的 `gitee-release` 自动上传，见第 5、6 节）。
  2. GitHub Release：`https://github.com/AniBullet/BsKeyTools/releases/download/v<ver>/BsKeyTools_v<ver>.exe`（`release.yml` 自动发布；会重定向到 `release-assets.githubusercontent.com`，`HttpWebRequest` 默认自动跟随）。
- `fnUpdaterDownloadInstaller`：
  - 下载前在现有 `ServicePointManager.SecurityProtocol` 上追加 TLS 1.2（失败写 Listener）。`fnCheckUpdate.ms` 加载时也会把协议设为 TLS 1.2。
  - 异步下载：立即返回并弹出"BsKeyTools 下载更新"进度窗口（来源、进度条、已下载/总大小、速度、剩余秒数、"取消下载"按钮；关窗口等同取消），Max 不卡。
  - 实现：`WebRequest.GetResponseAsync()` 取响应，再 `Stream.CopyToAsync` 写入自己打开的 `FileStream`；主线程 `System.Windows.Forms.Timer` 每 250 ms 轮询 Task 状态和 `FileStream.Position`。取消 = `req.Abort()` + 关闭流。
  - 不要换回 `WebClient.DownloadFileAsync`：在 Max 里 `CancelAsync` 不生效，取消后文件仍在后台下完（实测）。也不能用 `BeginGetResponse`：MaxScript 传 `undefined` 回调匹配不到重载，传真回调又会在后台线程执行 MaxScript。
  - 每个源下载到 `#temp\BsKeyTools_v<ver>_<源名>.exe`，尝试前删除旧文件；删不掉（仍被占用）时交给清理定时器每秒重试，30 秒后仍失败写 Listener。Listener 打印源名称和 URL。
  - 当前源失败即切下一个源，原因写 Listener 并汇总到最终失败弹窗：HTTP 错误（如 `(404) Not Found`）、30 秒连不上、30 秒无新数据、文件 ≤ 512000 字节（疑为错误页）、大小与 `Content-Length` 不一致。
  - 任一源成功即 `ShellLaunch` 安装包；全部失败弹"安装包下载失败"（附各源失败原因）并打开 `https://anibullet.github.io/`。下载进行中再次点更新只会聚焦已有进度窗口。
  - 1.4.1 及以前是同步下载：期间 Max 完全无响应、无进度、不能取消。
- 菜单"更新记录"打开 `https://github.com/AniBullet/BsKeyTools/releases`（v1.4.1 之后的版本；v1.4.1 及以前打开手工维护的 Notion 页）。更新说明只维护 `docs/release-notes/` 一处。
- 安装包自身 `.onInit` 也会检查 `version.dat`，`VersionCompare` 远端更新时提示并打开 `https://github.com/AniBullet/BsKeyTools/releases/latest`。

## 8. 仓库里的 exe 文件

跟踪的 exe 只有运行时工具，随安装包分发，不要删、不要加进 `.gitignore`：
- `_BsKeyTools/AnimRef/Contents/converter/ffmpeg.exe`、`gifsicle.exe`
- `_BsKeyTools/Scripts/BulletScripts/Res/fbxreview.exe`

安装包 `_BsKeyTools/_BsKeyTools.exe`、`_BsKeyTools/BsCleanVirus_Standalone.exe` 2026-10 起**不再跟踪**（已加 `.gitignore`），只通过 Release 分发。原因与依据：
- 它们共被提交约 130 次，每次约 46 MB，是仓库体积（本地 pack 约 378 MB）的主要来源，也是 Gitee 超配额的主因；仓库里那份还停在 1.4.0，容易被当成最新版。
- 从 raw `main` 下载它的只有 0.9.9.1–0.9.9.4（2022-09～10）。0.9.9.5～v1.3.7 的"更新"打开引导页 `https://anibullet.github.io/guide/`，引导页链接 `releases/latest` 和网盘；v1.4.0 起从 Release 下载。所以删掉只影响这四个 2022 年的版本（下载 404，需从引导页手动装）。
- 历史里的旧版本仍占体积；要真正瘦身只能改写历史并强推，代价远大于收益，不做。

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
- 忘了写 `docs/release-notes/v<ver>.md` → `check-version` 报"缺少更新说明"失败。补提交后再推即可。已发布的说明写错了直接 `gh release edit` 改，不用重发。
- 发版运行中又推 `main` → 可能并发两次发版。等 `Build and Release` 结束再推。
- 工作流文件的改动（尤其 `workflow_run` / `workflow_dispatch` 触发）要合入 `main` 后才生效；在 `dev` 上改完不能直接验证。
- `RELEASE_VERSION` 与 `curVerBsKeyTools` 不一致 → `update_manifest.py` 报错，构建失败。
- Gitee Release 没建成或缺附件（`gitee-release` 失败）→ 插件自动改从 GitHub Release 下载；GitHub 也不通的用户才落到备用页。修好后 `gh workflow run sync-gitee.yml --ref main -f tag=v<ver>` 补发，已有的附件不会重复上传。
- GitHub runner 访问 Gitee API 偶发 TLS 握手超时（`curl: (28) SSL connection timeout`，v1.4.1 首次补发时卡 5 分钟后失败）。第二次补发时读请求连续 4 次超时、第 5 次才成功，创建 Release 的 POST 也超时。现在读请求 `curl --retry`；创建（5 次）和上传（3 次）失败后先回读 Gitee，确认没生效再重试，避免重复；网络失败与"tag 不存在"分开报错。仍失败就重跑，只补缺的部分。
- v1.4.1 曾漏发 Gitee Release：以为 CI 一直会发，实际 `7994363` 删了那一步；仓库镜像不同步 Release。发版后务必按第 4 节第 8 步核对 Gitee。
- `version.dat` 早于安装包进入 `main` → 用户提前收到更新提示（Gitee、GitHub 都没有安装包时直接落到备用页）。现行流程下这是发版时约 5–10 分钟的固有窗口，见第 4 节第 2 步。
- `version.dat` 内容不是合法版本号（如 Gitee 返回 HTML 页、写错格式）→ 插件报"无法解析版本号"，不会提示更新。首尾空白/换行/BOM 会被去掉，不影响比较；`update_manifest.py` 写的是无 BOM UTF-8 + LF。
- 线上 `version.dat` 低于本地版本（如本地测试包先于发版）→ 不提示更新，手动检查显示"本地版本高于线上版本"。
- 本地 `build.bat` 找不到 `D:\NSIS` → 见第 3 节。
- 不要再把安装包提交进仓库（即使 `git add -f`）：会重新撑大仓库和 Gitee 配额。
- Gitee 同步失败（镜像令牌过期、镜像被停用等）只会让 `Sync to Gitee` 标红，不影响已创建的 GitHub Release；按第 6 节恢复后手动触发 `Sync to Gitee`。
