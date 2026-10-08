/*
* @Description: BsKeyTools 版本检查模块
* @Author: Bullet.S
* @Date: 2026-05-16
* @Version: 1.4.0
*
* 对外接口:
*   fnCheckUpdate versionDatUrl [force:false] -- 手动触发检查（始终显示结果）
*   fnAutoCheckVersion versionDatUrl          -- 启动时自动检查（异步不阻塞，每个 Max 会话一次，仅发现新版本时弹窗）
*
* version.dat 格式（单行）：
*   BsKeyTools 版本，如 "1.4.0"
*/

-- ── TLS 设置（国内 Gitee 需要 TLS 1.2）────────────────────────────────
global spm = (dotNetClass "System.Net.ServicePointManager")
spm.SecurityProtocol = spm.SecurityProtocol.Tls12

-- ── 版本号解析与比较 ──────────────────────────────────────────────────
-- 去掉首尾空白、换行和 UTF-8 BOM（U+FEFF）
fn fnBsTrimVersion str =
(
    local trimChars = " \t\r\n" + (bit.intAsChar 0xFEFF)
    trimRight (trimLeft str trimChars) trimChars
)

-- 解析 "x.y.z" 或 "x.y.z_BetaN"，返回 #(数字段数组, 后缀字符串)，无法解析返回 undefined
-- 数字段必须全为 0-9；"_" 之后为预发布后缀（如 Beta2），不能为空
fn fnBsParseVersion verStr =
(
    if classOf verStr != String then return undefined
    local s = fnBsTrimVersion verStr
    if s == "" then return undefined

    local core   = s
    local suffix = ""
    local usIdx  = findString s "_"
    if usIdx != undefined do
    (
        core   = substring s 1 (usIdx - 1)
        suffix = substring s (usIdx + 1) (s.count - usIdx)
        if suffix == "" do return undefined
    )

    local segs = filterString core "." splitEmptyTokens:true
    if segs.count == 0 then return undefined

    local nums = #()
    local ok   = true
    for seg in segs while ok do
    (
        if seg == "" then ok = false
        else
        (
            for i = 1 to seg.count while ok do
                if (findString "0123456789" seg[i]) == undefined do ok = false
            local v = if ok then (seg as integer) else undefined
            if v == undefined then ok = false else append nums v
        )
    )
    if not ok then return undefined

    #(nums, suffix)
)

-- 比较版本 a 与 b：a>b 返回 1，相等 0，a<b 返回 -1；任一无法解析返回 undefined
-- 缺失的数字段按 0 处理（1.4 == 1.4.0）；数字段相同时带后缀的是预发布版，
-- 低于正式版（1.1.0_Beta < 1.1.0），两个都带后缀则按后缀字符串不区分大小写比较
fn fnBsCompareVersion a b =
(
    local pa = fnBsParseVersion a
    local pb = fnBsParseVersion b
    if pa == undefined or pb == undefined then return undefined

    local na  = pa[1]
    local nb  = pb[1]
    local res = 0
    local n   = amax na.count nb.count
    for i = 1 to n while res == 0 do
    (
        local va = if i <= na.count then na[i] else 0
        local vb = if i <= nb.count then nb[i] else 0
        if va > vb then res = 1
        else if va < vb do res = -1
    )

    if res == 0 do
    (
        local sa = pa[2]
        local sb = pb[2]
        if sa == "" and sb != "" then res = 1
        else if sa != "" and sb == "" then res = -1
        else if sa != "" do
        (
            local c = stricmp sa sb
            res = if c > 0 then 1 else if c < 0 then -1 else 0
        )
    )
    res
)

-- ── version.dat 拉取 ──────────────────────────────────────────────────
-- 取 version.dat 内容的第一行作为 BsKeyTools 版本，内容为空返回 undefined
fn fnBsVersionFromDatContent content =
(
    if classOf content != String then return undefined
    local lines   = filterString content "\r\n"
    local bsktVer = if lines.count >= 1 then (fnBsTrimVersion lines[1]) else ""
    if bsktVer == "" then undefined else bsktVer
)

-- 同步拉取（仅手动检查用，会阻塞 Max 直到返回）；网络失败或内容无效返回 undefined
fn fnFetchVersionDat versionDatUrl =
(
    local wc = dotNetObject "System.Net.WebClient"
    wc.Encoding = (dotNetClass "System.Text.Encoding").UTF8

    local content = undefined
    try (content = wc.DownloadString versionDatUrl)
    catch (format "[BsKeyTools] 拉取 version.dat 失败: %\n" (getCurrentException()))
    wc.Dispose()

    fnBsVersionFromDatContent content
)

-- ── 跳过版本辅助 ──────────────────────────────────────────────────────
fn fnGetSkipVersion key =
(
    GetINISetting BulletConfig "BulletKeyToolsSet" key
)

fn fnSetSkipVersion key ver =
(
    SetINISetting BulletConfig "BulletKeyToolsSet" key ver
)

-- ── 安装包下载源 ──────────────────────────────────────────────────────
-- 按顺序尝试：Gitee Release（国内快，需手动上传附件）→ GitHub Release（CI 自动发布）
fn fnBsktInstallerSources ver =
(
    local exeName = "BsKeyTools_v" + ver + ".exe"
    #(
        #("Gitee",  "https://gitee.com/acebullet/BsKeyTools/releases/download/v" + ver + "/" + exeName),
        #("GitHub", "https://github.com/AniBullet/BsKeyTools/releases/download/v" + ver + "/" + exeName)
    )
)

-- ── 单工具更新弹窗 ────────────────────────────────────────────────────
-- 弹出"发现新版本"对话框，Yes=下载安装包，No=稍后提醒，Cancel=跳过此版本
fn fnPromptUpdate toolName localVer onlineVer installerSources fallbackUrl skipKey =
(
    local bodyText = "发现新版本 " + onlineVer + \
        "\r\n当前版本：" + localVer + \
        "\r\n\r\n[是] 立即下载安装包   [否] 稍后提醒   [取消] 跳过此版本"

    -- 用 Max 自带对话框：以 Max 主窗口为父窗口；无主的 .NET MessageBox 可能被压在 Max 后面，模态卡住界面
    local dr = yesNoCancelBox bodyText title:(toolName + " 发现新版本 " + onlineVer) beep:false

    if dr == #yes then
        fnUpdaterDownloadInstaller installerSources fallbackUrl
    else if dr == #cancel do
    (
        fnSetSkipVersion skipKey onlineVer
        format "[BsKeyTools] 已跳过 % 版本 %\n" toolName onlineVer
    )
)

-- 版本号无法解析时的说明文字（线上内容可能是 HTML 错误页，截断显示）
fn fnBsVersionParseErrorText onlineVer localVer =
(
    local shown = if onlineVer.count > 60 then ((substring onlineVer 1 60) + "...") else onlineVer
    "无法解析版本号：线上 \"" + shown + "\"，本地 \"" + localVer + "\""
)

-- ── 对外接口 ──────────────────────────────────────────────────────────

-- 手动检查更新（菜单项触发）：显示 BsKeyTools 更新结果
-- force:true 时跳过版本比较，强制提示下载（用于"强制更新"菜单项）
fn fnCheckUpdate versionDatUrl force:false =
(
    local onlineBskt = fnFetchVersionDat versionDatUrl
    if onlineBskt == undefined then
    (
        messageBox "获取版本信息失败，请检查网络连接或稍后重试。                    " \
            title:"BsKeyTools 检查更新" beep:false
        return undefined
    )

    local cmp = fnBsCompareVersion onlineBskt curVerBsKeyTools
    if cmp == undefined then
    (
        local errText = fnBsVersionParseErrorText onlineBskt curVerBsKeyTools
        format "[BsKeyTools] 检查更新失败，%\n" errText
        if force then
            messageBox ("无法确认在线版本信息，请前往下载页手动检查。\r\n" + errText + "                    ") \
                title:"BsKeyTools 强制更新" beep:false
        else
            messageBox ("检查更新失败，" + errText + "\r\n请稍后重试或前往下载页手动检查。                    ") \
                title:"BsKeyTools 检查更新" beep:false
        return undefined
    )

    if force or cmp > 0 then
    (
        local back = "https://anibullet.github.io/"
        fnPromptUpdate "BsKeyTools" curVerBsKeyTools onlineBskt (fnBsktInstallerSources onlineBskt) back "SkipVersionBskt"
    )
    else if cmp == 0 then
        messageBox ("当前已是最新版本：BsKeyTools " + curVerBsKeyTools + "                    ") \
            title:"BsKeyTools 检查更新" beep:false
    else
        messageBox ("本地版本高于线上版本，无需更新。\r\n本地：" + curVerBsKeyTools + "\r\n线上：" + onlineBskt + "                    ") \
            title:"BsKeyTools 检查更新" beep:false
    OK
)

-- ── 启动时自动检查（异步）──────────────────────────────────────────────
-- 后台线程只做 WebClient.DownloadFileAsync；完成与否由主线程上的 WinForms Timer 轮询 IsBusy，
-- 所有 MaxScript 都在主线程执行（在后台线程回调 MaxScript 会导致 Max 崩溃）
global bsAutoCheckStarted          -- 本次 Max 会话已发起过自动检查（窗口重开不再检查）
global bsAutoCheckWC
global bsAutoCheckTimer
global bsAutoCheckFile
global bsAutoCheckElapsedMs
global bsAutoCheckTickMs    = 200
global bsAutoCheckTimeoutMs = 15000

-- 只在线上版本更高且未被跳过时弹窗，其余情况只写 Listener
fn fnBsAutoCheckHandleResult onlineBskt =
(
    local cmp = fnBsCompareVersion onlineBskt curVerBsKeyTools
    if cmp == undefined then
    (
        format "[BsKeyTools] 自动检查更新失败，%\n" (fnBsVersionParseErrorText onlineBskt curVerBsKeyTools)
        return undefined
    )

    if cmp > 0 then
    (
        if (fnGetSkipVersion "SkipVersionBskt") != onlineBskt then
        (
            local back = "https://anibullet.github.io/"
            fnPromptUpdate "BsKeyTools" curVerBsKeyTools onlineBskt (fnBsktInstallerSources onlineBskt) back "SkipVersionBskt"
        )
        else
            format "[BsKeyTools] 跳过 BsKeyTools 版本 %\n" onlineBskt
    )
    else if cmp < 0 do
        format "[BsKeyTools] 本地版本 % 高于线上版本 %，不提示更新\n" curVerBsKeyTools onlineBskt
)

fn fnBsAutoCheckCleanup =
(
    if bsAutoCheckTimer != undefined do
    (
        bsAutoCheckTimer.Stop()
        dotNet.removeAllEventHandlers bsAutoCheckTimer
        bsAutoCheckTimer.Dispose()
        bsAutoCheckTimer = undefined
    )
    if bsAutoCheckWC != undefined do
    (
        if bsAutoCheckWC.IsBusy do bsAutoCheckWC.CancelAsync()
        bsAutoCheckWC.Dispose()
        bsAutoCheckWC = undefined
    )
    if bsAutoCheckFile != undefined and (doesFileExist bsAutoCheckFile) do deleteFile bsAutoCheckFile
)

fn fnBsAutoCheckOnTick sender args =
(
    -- 事件回调里的异常不会出现在调用栈上，记录后结束本次检查
    try
    (
        if bsAutoCheckWC == undefined then fnBsAutoCheckCleanup()
        else if bsAutoCheckWC.IsBusy then
        (
            bsAutoCheckElapsedMs += bsAutoCheckTickMs
            if bsAutoCheckElapsedMs >= bsAutoCheckTimeoutMs do
            (
                format "[BsKeyTools] 自动检查更新超时（% 秒），已放弃；可在菜单手动检查更新\n" (bsAutoCheckTimeoutMs / 1000)
                fnBsAutoCheckCleanup()
            )
        )
        else
        (
            local content = undefined
            if (doesFileExist bsAutoCheckFile) and (getFileSize bsAutoCheckFile) > 0 do
            (
                local sioFile = dotNetClass "System.IO.File"
                local utf8    = (dotNetClass "System.Text.Encoding").UTF8
                content = sioFile.ReadAllText bsAutoCheckFile utf8
            )
            fnBsAutoCheckCleanup()

            local onlineBskt = fnBsVersionFromDatContent content
            if onlineBskt == undefined then
                format "[BsKeyTools] 自动检查更新失败：未取到 version.dat（网络错误或内容为空）\n"
            else
                fnBsAutoCheckHandleResult onlineBskt
        )
    )
    catch
    (
        format "[BsKeyTools] 自动检查更新出错: %\n" (getCurrentException())
        try (fnBsAutoCheckCleanup()) catch (format "[BsKeyTools] 清理自动检查失败: %\n" (getCurrentException()))
    )
)

-- 启动时自动检查：立即返回，不阻塞 Max；结果在后台下载完成后于主线程处理
fn fnAutoCheckVersion versionDatUrl =
(
    if bsAutoCheckStarted == true do return undefined
    bsAutoCheckStarted = true

    try
    (
        fnBsAutoCheckCleanup()
        bsAutoCheckFile = (getDir #temp) + "\\BsKeyTools_version.dat"
        if doesFileExist bsAutoCheckFile do deleteFile bsAutoCheckFile
        bsAutoCheckElapsedMs = 0

        bsAutoCheckWC = dotNetObject "System.Net.WebClient"
        bsAutoCheckWC.DownloadFileAsync (dotNetObject "System.Uri" versionDatUrl) bsAutoCheckFile

        bsAutoCheckTimer = dotNetObject "System.Windows.Forms.Timer"
        bsAutoCheckTimer.Interval = bsAutoCheckTickMs
        dotNet.addEventHandler bsAutoCheckTimer "Tick" fnBsAutoCheckOnTick
        dotNet.setLifetimeControl bsAutoCheckTimer #dotnet
        bsAutoCheckTimer.Start()
    )
    catch
    (
        format "[BsKeyTools] 启动自动检查更新失败: %\n" (getCurrentException())
        try (fnBsAutoCheckCleanup()) catch (format "[BsKeyTools] 清理自动检查失败: %\n" (getCurrentException()))
    )
    OK
)
