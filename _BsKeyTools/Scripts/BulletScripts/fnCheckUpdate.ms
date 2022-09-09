-- verURL = "https://gitee.com/acebullet/BsReferenceTools/raw/main/_BsRefTools/EXE/version.dat"
-- dlURL = "https://gitee.com/acebullet/BsReferenceTools/raw/main/_BsRefTools/EXE/_BsRefTools%EF%BC%88%E8%A3%85%E5%AE%8C%E9%87%8D%E5%90%AFMAX,%E8%AF%AF%E6%9D%80%E8%AF%B7%E4%BF%A1%E4%BB%BB%EF%BC%89.exe"
-- dlFile = (getdir #temp) + "\\_BsRefTools（装完重启MAX,误杀请信任）.exe"

global spm = (dotNetclass "System.Net.ServicePointManager")
spm.SecurityProtocol = spm.SecurityProtocol.Tls12

fn fnCheckUpdate currentVer verURL dlURL dlFile isForceUpdate:false = 
(
    local result = undefined

    if internet.CheckConnection url:"https://gitee.com" force:true == true then -- 检查网络是否能连接
    (
        local LaterVersion_installed = true
        local onlineVersion = (dotNetObject "System.Net.WebClient").downloadString verURL

        if (isForceUpdate == false) then
        (
            if (currentVer != onlineVersion) and (not (matchpattern onlineVersion pattern:"*Beta*")) 
            then (LaterVersion_installed = false)
            else (LaterVersion_installed = true)
        )
        else (LaterVersion_installed = false)

        if LaterVersion_installed do (messageBox  ("您已安装最新版本：" + onlineVersion + "\r\n\r\n若本地版本不对应请稍后重试~        ") title:"最新版本" beep:false;result = OK)

        if not LaterVersion_installed AND (queryBox ("远程最新版本为: " + onlineVersion + "\r\n本地当前版本为: " + currentVer + \
            "\r\n\r\n是否立即下载更新并安装脚本?\r\n注意:可在设置中开关自动检测更新!\r\n\r\n(建议只更新正式版,beta仅供测试不保证稳定)\r\n(回退默认安装最新版前一版本)                                      ") title:"是否更新脚本") do 
        (
            local Root = symbolicPaths.getPathValue "$Max"  --max根目录

            if (doesFileExist dlFile) then 
            (
                try(fnDelFileDir dlFile)catch
                (
                    if (queryBox ("可能因为权限无法清除旧版本下载, 若安装失败，\r\n\r\n请点确定跳转目录删除下面文件再更新，否则忽略:\t\t\t\t\t\t\t\t\t\r\n\r\n"+dlFile) \
                    title:"删除旧下载失败" beep:false) do
                    (
                        ShellLaunch (getdir #temp) ""
                    )
                )
            )

            -- try((dotNetObject "System.Net.WebClient").downloadFile dlURL dlFile)
            -- catch( print ((getCurrentException()) + "  " + dlFile);messagebox "下载失败，建议去 GitHub 下载最新版！                                            "title:"BsKeyTools")
            try(ShellLaunch dlURL "";messagebox "请手动下载弹出网页的 BsKeyTools 安装包自行安装！                                                      " title:"BsKeyTools")
            catch(messagebox "下载失败，建议去 GitHub 下载最新版！                                            "title:"BsKeyTools")
            ShellLaunch dlFile ""
            result = OK
        )
    )
    else
    (
        --检查网络是否能连接
        if internet.CheckConnection url:"https://gitee.com" force:true == true then 
        (print "下载服务器当前不可用,请稍后再试                        ";result = undefined)
        else (print "BsKeyTools ：检查更新，无网络连接或链接 Gitee 未响应...                                ";result = undefined)
    )
    result
)

fn fnAutoCheckVersion currentVer verURL dlURL dlFile =
(
    local onlineVersion = (dotNetObject "System.Net.WebClient").downloadString verURL
    if (currentVer != onlineVersion) then 
    (fnCheckUpdate currentVer verURL dlURL dlFile isForceUpdate:true)
)