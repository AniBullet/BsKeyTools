/*
* @Description: BsKeyTools 安装包下载模块
* @Author: Bullet.S
* @Date: 2026-05-16
* @Version: 1.4.0
*
* 对外接口（由 fnCheckUpdate.ms 调用）:
*   fnUpdaterDownloadInstaller installerSources fallbackUrl
*     installerSources: #(#("Gitee", url), #("GitHub", url), ...) 按顺序尝试；也可传单个 url 字符串
*
* 异步下载：立即返回，弹出进度窗口（可取消）。WebRequest.GetResponseAsync 取响应，
* 再用 Stream.CopyToAsync 写入自己打开的 FileStream；主线程上的 WinForms Timer 轮询
* Task 状态和 FileStream.Position。不传回调、不注册事件：回调会在后台线程
* 执行 MaxScript，导致 Max 崩溃（BeginGetResponse 也因此不可用，MaxScript 传不了空回调）。
* 不用 WebClient.DownloadFileAsync：在 Max 里 CancelAsync 不生效，取消后仍在后台下完。
*/

global bsDlState                 -- undefined = 空闲；否则为当前 BsDlSession
global rolBsUpdaterProgress
global bsDlTickMs    = 250
global bsDlConnectMs = 30000     -- 这么久拿不到响应就放弃当前源
global bsDlStallMs   = 30000     -- 连续这么久没有新数据就放弃当前源
global bsDlMinBytes  = 512000    -- 小于这个大小视为错误页而不是安装包

struct BsDlSession
(
    sources = #(),
    index = 0,
    fallbackUrl = "",
    timer = undefined,
    phase = #idle,               -- #connect：等响应；#copy：写文件
    req = undefined,
    respTask = undefined,
    resp = undefined,
    netStream = undefined,
    fileStream = undefined,
    copyTask = undefined,
    total = 0,
    srcName = "",
    exeName = "",
    exePath = "",
    lastBytes = 0,
    stallMs = 0,
    srcElapsedMs = 0,
    failures = #()
)

-- github.com 需要 TLS 1.2；在现有协议上追加，不覆盖其他已启用的协议
fn fnUpdaterEnsureTls12 =
(
    try
    (
        local spmCls   = dotNetClass "System.Net.ServicePointManager"
        local protoCls = dotNetClass "System.Net.SecurityProtocolType"
        spmCls.SecurityProtocol = dotNet.combineEnums spmCls.SecurityProtocol protoCls.Tls12
    )
    catch
    (
        format "[BsUpdater] 启用 TLS 1.2 失败，GitHub 下载可能失败: %\n" (getCurrentException())
    )
)

-- 删除失败（文件仍被占用）时交给清理定时器每秒重试，最多 30 次，仍失败写 Listener
global bsDlPendingDelete = if bsDlPendingDelete == undefined then #() else bsDlPendingDelete
global bsDlCleanupTimer
global bsDlCleanupTries = 0

fn fnBsDlOnCleanupTick sender args =
(
    bsDlCleanupTries += 1
    local remaining = #()
    for p in bsDlPendingDelete do
        if (doesFileExist p) and not (deleteFile p) do append remaining p
    bsDlPendingDelete = remaining
    if remaining.count == 0 or bsDlCleanupTries >= 30 do
    (
        for p in remaining do format "[BsUpdater] 临时文件 30 秒内仍无法删除（可能被占用），请手动删除: %\n" p
        bsDlPendingDelete = #()
        sender.Stop()
        dotNet.removeAllEventHandlers sender
        sender.Dispose()
        bsDlCleanupTimer = undefined
    )
)

fn fnBsDlDeleteFile filePath =
(
    if filePath == "" or not (doesFileExist filePath) then return undefined
    if deleteFile filePath then return undefined
    appendIfUnique bsDlPendingDelete filePath
    bsDlCleanupTries = 0
    if bsDlCleanupTimer == undefined do
    (
        bsDlCleanupTimer = dotNetObject "System.Windows.Forms.Timer"
        bsDlCleanupTimer.Interval = 1000
        dotNet.addEventHandler bsDlCleanupTimer "Tick" fnBsDlOnCleanupTick
        dotNet.setLifetimeControl bsDlCleanupTimer #dotnet
        bsDlCleanupTimer.Start()
    )
)

fn fnBsDlMB bytes = formattedPrint (bytes / 1048576.0) format:".1f"

-- dotNet 异常（含 AggregateException）取最内层的说明文字
fn fnBsDlExceptionText ex =
(
    if ex == undefined then return "未知错误"
    local e = ex
    while e.InnerException != undefined do e = e.InnerException
    e.Message
)

fn fnBsDlSetUI srcText statusText pct =
(
    if rolBsUpdaterProgress != undefined and rolBsUpdaterProgress.open do
    (
        if srcText != undefined do rolBsUpdaterProgress.lblSource.text = srcText
        if statusText != undefined do rolBsUpdaterProgress.lblStatus.text = statusText
        if pct != undefined do rolBsUpdaterProgress.pbDl.value = amax 0 (amin 100 pct)
    )
)

-- 中止请求并关闭所有流；后台未完成的 CopyToAsync 随之失败，结果不再读取
fn fnBsDlStopTransfer s =
(
    if s.req != undefined do
    (
        try (s.req.Abort()) catch (format "[BsUpdater] 中止请求失败: %\n" (getCurrentException()))
        s.req = undefined
    )
    for obj in #(s.fileStream, s.netStream, s.resp) where obj != undefined do
        try (obj.Dispose()) catch (format "[BsUpdater] 关闭下载流失败: %\n" (getCurrentException()))
    s.fileStream = undefined
    s.netStream  = undefined
    s.resp       = undefined
    s.respTask   = undefined
    s.copyTask   = undefined
    s.phase      = #idle
)

-- 结束会话：先清空 bsDlState 再关窗口，避免窗口 close 事件再触发取消
fn fnBsDlEndSession s =
(
    bsDlState = undefined
    if s.timer != undefined do
    (
        s.timer.Stop()
        dotNet.removeAllEventHandlers s.timer
        s.timer.Dispose()
        s.timer = undefined
    )
    fnBsDlStopTransfer s
    if rolBsUpdaterProgress != undefined and rolBsUpdaterProgress.open do destroyDialog rolBsUpdaterProgress
)

fn fnBsDlAllFailed s =
(
    local url = if (s.fallbackUrl != undefined and s.fallbackUrl != "") then s.fallbackUrl else "https://anibullet.github.io/"
    local detail = if s.failures.count == 0 then "没有可用的下载地址" else ""
    for f in s.failures do detail += (if detail == "" then "" else "\r\n") + f
    format "[BsUpdater] 安装包下载失败，打开备用下载页: %\n%\n" url detail
    messageBox ("安装包下载失败，已为你打开备用下载页，请在浏览器中手动下载安装。\r\n\r\n" + detail) \
        title:"BsKeyTools 更新" beep:false
    ShellLaunch url ""
)

-- 开始下一个可用的下载源；没有了就结束会话并提示失败
fn fnBsDlStartNext s =
(
    local started = false
    while not started and s.index < s.sources.count do
    (
        s.index += 1
        local src = s.sources[s.index]
        local url = src[2]
        if url == undefined or url == "" then
            append s.failures (src[1] + "：下载地址为空")
        else
        (
            -- 每个源单独的文件名，避免与上一个源未释放的文件冲突
            local urlParts = filterString url "/"
            s.exeName      = if urlParts.count > 0 then urlParts[urlParts.count] else "BsKeyTools_Setup.exe"
            s.srcName      = src[1]
            s.exePath      = (getDir #temp) + "\\" + (getFilenameFile s.exeName) + "_" + s.srcName + (getFilenameType s.exeName)
            s.total        = 0
            s.lastBytes    = 0
            s.stallMs      = 0
            s.srcElapsedMs = 0
            fnBsDlDeleteFile s.exePath

            format "[BsUpdater] 尝试从 % 下载: %\n" s.srcName url
            try
            (
                s.req = (dotNetClass "System.Net.WebRequest").Create url
                s.respTask = s.req.GetResponseAsync()
                s.phase = #connect
                started = true
                fnBsDlSetUI ("正在从 " + s.srcName + " 下载 " + s.exeName) "正在连接..." 0
            )
            catch
            (
                local err = getCurrentException()
                format "[BsUpdater] % 无法开始下载: %\n" s.srcName err
                append s.failures (s.srcName + "：无法开始下载（" + err + "）")
                fnBsDlStopTransfer s
            )
        )
    )
    if not started do
    (
        fnBsDlEndSession s
        fnBsDlAllFailed s
    )
)

fn fnBsDlFailCurrent s reason =
(
    format "[BsUpdater] % 下载失败: %\n" s.srcName reason
    append s.failures (s.srcName + "：" + reason)
    fnBsDlStopTransfer s
    fnBsDlDeleteFile s.exePath
    fnBsDlStartNext s
)

fn fnBsDlCancel =
(
    local s = bsDlState
    if s == undefined then return undefined
    format "[BsUpdater] 已取消下载\n"
    fnBsDlEndSession s
    fnBsDlDeleteFile s.exePath
)

-- 响应已到：打开文件并开始异步复制。HTTP 4xx/5xx 会让 respTask 以 WebException 失败
fn fnBsDlBeginCopy s =
(
    local task = s.respTask
    if task.IsFaulted or task.IsCanceled do
    (
        local reason = if task.IsFaulted then (fnBsDlExceptionText task.Exception) else "已取消"
        fnBsDlFailCurrent s ("连接失败（" + reason + "）")
        return undefined
    )
    local resp = task.Result
    s.resp  = resp
    s.total = resp.ContentLength
    if s.total < 0 do s.total = 0

    local fileMode   = (dotNetClass "System.IO.FileMode").Create
    local fileAccess = (dotNetClass "System.IO.FileAccess").Write
    s.fileStream = dotNetObject "System.IO.FileStream" s.exePath fileMode fileAccess
    s.netStream  = resp.GetResponseStream()
    s.copyTask   = s.netStream.CopyToAsync s.fileStream 81920
    s.phase      = #copy
)

fn fnBsDlOnCopyDone s =
(
    local task = s.copyTask
    if task.IsFaulted or task.IsCanceled do
    (
        local reason = if task.IsFaulted then (fnBsDlExceptionText task.Exception) else "已取消"
        fnBsDlFailCurrent s ("传输中断（" + reason + "）")
        return undefined
    )

    s.fileStream.Flush()
    local bytes = s.fileStream.Length
    fnBsDlStopTransfer s

    if bytes <= bsDlMinBytes then
        fnBsDlFailCurrent s ("文件太小（" + (bytes as string) + " 字节），可能是错误页")
    else if s.total > 0 and bytes != s.total then
        fnBsDlFailCurrent s ("下载不完整（" + (fnBsDlMB bytes) + " / " + (fnBsDlMB s.total) + " MB）")
    else
    (
        local exePath = s.exePath
        fnBsDlSetUI undefined "下载完成，正在启动安装程序..." 100
        fnBsDlEndSession s
        format "[BsUpdater] 下载完成（% MB），启动安装程序: %\n" (fnBsDlMB bytes) exePath
        ShellLaunch exePath ""
    )
)

fn fnBsDlUpdateProgress s =
(
    local bytes = s.fileStream.Position
    if bytes > s.lastBytes then (s.lastBytes = bytes; s.stallMs = 0)
    else s.stallMs += bsDlTickMs

    local secs  = s.srcElapsedMs / 1000.0
    local speed = if secs > 0 then (bytes / secs) else 0
    local pct   = 0
    local status = ""
    if s.total > 0 then
    (
        pct = (bytes * 100.0 / s.total) as integer
        local remain = if speed > 0 then (((s.total - bytes) / speed) as integer) else 0
        status = (fnBsDlMB bytes) + " / " + (fnBsDlMB s.total) + " MB    " + (fnBsDlMB speed) + " MB/s    剩余约 " + (remain as string) + " 秒"
    )
    else
        status = (fnBsDlMB bytes) + " MB    " + (fnBsDlMB speed) + " MB/s"
    fnBsDlSetUI undefined status pct

    if s.stallMs >= bsDlStallMs do
        fnBsDlFailCurrent s (((bsDlStallMs / 1000) as string) + " 秒没有收到数据（已下载 " + (fnBsDlMB bytes) + " MB）")
)

fn fnBsDlOnTick sender args =
(
    local s = bsDlState
    if s == undefined then
    (
        sender.Stop()
        return undefined
    )
    -- 事件回调里的异常不会出现在调用栈上，记录并结束下载，提示用户
    try
    (
        s.srcElapsedMs += bsDlTickMs
        case s.phase of
        (
            #connect:
            (
                if s.respTask.IsCompleted then fnBsDlBeginCopy s
                else
                (
                    fnBsDlSetUI undefined ("正在连接... " + ((s.srcElapsedMs / 1000) as string) + " 秒") 0
                    if s.srcElapsedMs >= bsDlConnectMs do
                        fnBsDlFailCurrent s (((bsDlConnectMs / 1000) as string) + " 秒内连接不上服务器")
                )
            )
            #copy:
            (
                if s.copyTask.IsCompleted then fnBsDlOnCopyDone s
                else fnBsDlUpdateProgress s
            )
        )
    )
    catch
    (
        local err = getCurrentException()
        format "[BsUpdater] 下载过程出错: %\n" err
        local path = s.exePath
        try (fnBsDlEndSession s) catch (format "[BsUpdater] 结束下载失败: %\n" (getCurrentException()))
        fnBsDlDeleteFile path
        messageBox ("下载更新时出错：\r\n" + err + "\r\n\r\n可在设置菜单里重新检查更新，或前往下载页手动下载。") \
            title:"BsKeyTools 更新" beep:false
    )
)

rollout rolBsUpdaterProgress "BsKeyTools 下载更新" width:380 height:96
(
    label lblSource "" align:#left width:360
    progressBar pbDl value:0 width:360 height:14 color:(color 80 160 240)
    label lblStatus "" align:#left width:360
    button btnCancel "取消下载" width:90 align:#right

    on btnCancel pressed do fnBsDlCancel()
    on rolBsUpdaterProgress close do (if bsDlState != undefined do fnBsDlCancel())
)

-- 按顺序尝试各下载源，任一成功即启动安装程序；全部失败则提示并打开 fallbackUrl
fn fnUpdaterDownloadInstaller installerSources fallbackUrl =
(
    if bsDlState != undefined do
    (
        if rolBsUpdaterProgress != undefined and rolBsUpdaterProgress.open then
            setFocus rolBsUpdaterProgress
        else
            messageBox "正在下载更新，请稍候。" title:"BsKeyTools 更新" beep:false
        return undefined
    )

    local sources = #()
    if classOf installerSources == String then
    (
        if installerSources != "" do append sources #("下载地址", installerSources)
    )
    else if classOf installerSources == Array do sources = installerSources

    fnUpdaterEnsureTls12()
    local s = BsDlSession sources:sources fallbackUrl:fallbackUrl
    bsDlState = s

    createDialog rolBsUpdaterProgress
    s.timer = dotNetObject "System.Windows.Forms.Timer"
    s.timer.Interval = bsDlTickMs
    dotNet.addEventHandler s.timer "Tick" fnBsDlOnTick
    dotNet.setLifetimeControl s.timer #dotnet
    s.timer.Start()

    fnBsDlStartNext s
    OK
)
