/*
* @Description: BsKeyTools 安装包下载模块
* @Author: Bullet.S
* @Date: 2026-05-16
* @Version: 1.4.0
*
* 对外接口（由 fnCheckUpdate.ms 调用）:
*   fnUpdaterDownloadInstaller installerSources fallbackUrl
*     installerSources: #(#("Gitee", url), #("GitHub", url), ...) 按顺序尝试；也可传单个 url 字符串
*/

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

fn fnUpdaterRemoveFile filePath =
(
    if doesFileExist filePath do
    (
        if not (deleteFile filePath) do
            format "[BsUpdater] 无法删除临时文件（可能被占用）: %\n" filePath
    )
)

-- 从单个地址下载到 exePath；成功返回 true，失败把原因写入 Listener 并删除残留文件
-- WebClient 会自动跟随重定向（GitHub Release 会跳转到 githubusercontent 的存储地址）
fn fnUpdaterTryDownload sourceName url exePath =
(
    format "[BsUpdater] 尝试从 % 下载: %\n" sourceName url
    fnUpdaterRemoveFile exePath

    local ok = false
    local wc = dotNetObject "System.Net.WebClient"
    try
    (
        wc.DownloadFile (dotNetObject "System.Uri" url) exePath
        ok = true
    )
    catch
    (
        format "[BsUpdater] % 下载失败: %\n" sourceName (getCurrentException())
    )
    wc.Dispose()

    if ok do
    (
        if not (doesFileExist exePath) then
        (
            ok = false
            format "[BsUpdater] % 下载结束但文件不存在: %\n" sourceName exePath
        )
        else
        (
            local fileSize = (dotNetObject "System.IO.FileInfo" exePath).Length as integer
            -- 大于 500KB 才视为有效 exe（排除 HTML 错误页）
            if fileSize <= 512000 do
            (
                ok = false
                format "[BsUpdater] % 下载文件太小（% 字节），可能是错误页\n" sourceName fileSize
            )
        )
    )

    if not ok do fnUpdaterRemoveFile exePath
    ok
)

-- 按顺序尝试各下载源，任一成功即启动安装程序
-- 注意：DownloadFile 为同步调用，下载期间 Max 界面暂时无响应，属正常现象
-- 全部失败则弹提示并打开 fallbackUrl
fn fnUpdaterDownloadInstaller installerSources fallbackUrl =
(
    local sources = #()
    if classOf installerSources == String then
    (
        if installerSources != "" do append sources #("下载地址", installerSources)
    )
    else if classOf installerSources == Array do sources = installerSources

    local dlOk        = false
    local exePath     = ""
    local triedNames  = ""

    if sources.count > 0 do fnUpdaterEnsureTls12()

    for src in sources while not dlOk do
    (
        local srcName = src[1]
        local url     = src[2]
        if url == undefined or url == "" then
            format "[BsUpdater] 跳过空下载地址: %\n" srcName
        else
        (
            -- 从 URL 末尾提取文件名，避免 BsKeyTools 与 BsCleanVirus 下载路径冲突
            local urlParts = filterString url "/"
            local exeName  = if urlParts.count > 0 then urlParts[urlParts.count] else "BsKeyTools_Setup.exe"
            exePath = (getDir #temp) + "\\" + exeName

            triedNames += (if triedNames == "" then "" else "、") + srcName
            dlOk = fnUpdaterTryDownload srcName url exePath
        )
    )

    if dlOk then
    (
        format "[BsUpdater] 启动安装程序: %\n" exePath
        ShellLaunch exePath ""
    )
    else
    (
        local url = if (fallbackUrl != undefined and fallbackUrl != "") \
            then fallbackUrl \
            else "https://anibullet.github.io/"
        local triedText = if triedNames == "" then "没有可用的下载地址" else ("已尝试 " + triedNames + "，均失败")
        format "[BsUpdater] 安装包下载失败（%），打开备用下载页: %\n" triedText url
        messageBox ("安装包下载失败（" + triedText + "），已为你打开备用下载页。\r\n请在浏览器中手动下载安装。") \
            title:"BsKeyTools 更新" beep:false
        ShellLaunch url ""
    )
)
