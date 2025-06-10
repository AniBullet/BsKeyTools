-- MotionReverse Tool
-- 作者: AniBullet
-- 版本: 1.0.0
-- 描述: MotionReverse脚本管理工具

try(DestroyDialog MotionReverseTool)catch()
rollout MotionReverseTool "MotionReverse 游戏动作逆向学习工具_Bullet.S" width:400 height:550
(
    -- UI控件
    dotNetControl modeSwitch "System.Windows.Forms.Panel" pos:[10,10] width:380 height:30
    dotNetControl scriptList "System.Windows.Forms.ListView" pos:[10,50] width:380 height:350
    dotNetControl descriptionBox "System.Windows.Forms.TextBox" pos:[10,410] width:380 height:40
    dotNetControl statusLabel "System.Windows.Forms.Label" pos:[10,460] width:380 height:20
    
    -- 按钮布局
    button btnRun "运行脚本" pos:[10,490] width:85 height:30
    button btnSaveAs "另存脚本" pos:[105,490] width:85 height:30
    button btnUpdate "检查更新" pos:[200,490] width:85 height:30
    button btnRefresh "刷新列表" pos:[295,490] width:85 height:30
    progressBar updateProgress "更新进度" pos:[10,530] width:380 height:12
    
    -- 全局变量
    local repoOwner = "AniBullet"
    local repoName = "MotionReverse"
    local apiBaseUrl = "https://api.github.com/repos/" + repoOwner + "/" + repoName
    local maxRetries = 3
    local retryDelay = 1000 -- 毫秒
    local scripts = #()
    local tempDir = getDir #temp + "\\MotionReverse\\"
    local localScriptPath = ""
    local configFile = getDir #userScripts + "\\MotionReverse\\config.ini"
    local isLocalMode = false -- 添加本地调试状态变量
    local lastConfigUpdate = 0 -- 添加最后更新时间记录
    
    -- 模式切换按钮
    global btnRemote = undefined
    global btnLocal = undefined
    global btnSetPath = undefined
    global btnHelp = undefined
    
    -- 等待函数
    fn wait milliseconds = 
    (
        local start = timeStamp()
        while (timeStamp() - start) < (milliseconds / 1000.0) do
        (
            sleep 0.1
        )
    )
    
    -- 保存配置
    fn saveConfig = 
    (
        if not doesFileExist (getDir #userScripts + "\\MotionReverse") then
        (
            makeDir (getDir #userScripts + "\\MotionReverse")
        )
        
        local config = createFile configFile
        format "LocalMode=%\n" isLocalMode to:config
        format "LocalPath=%\n" localScriptPath to:config
        close config
    )
    
    -- 加载配置
    fn loadConfig = 
    (
        if doesFileExist configFile then
        (
            try
            (
                local config = openFile configFile
                while not eof config do
                (
                    local line = readLine config
                    local parts = filterString line "="
                    if parts.count == 2 then
                    (
                        case parts[1] of
                        (
                            "LocalMode": isLocalMode = parts[2] as BooleanClass
                            "LocalPath": localScriptPath = parts[2]
                        )
                    )
                )
                close config
            )
            catch
            (
                local errorMsg = getCurrentException()
                messageBox ("读取配置文件时出错: " + errorMsg) title:"错误"
                -- 设置默认值
                isLocalMode = false
                localScriptPath = ""
            )
        )
        else
        (
            -- 如果配置文件不存在，设置默认值
            isLocalMode = false
            localScriptPath = ""
        )
    )
    
    -- 设置本地脚本路径
    fn setLocalPath = 
    (
        local newPath = getSavePath caption:"选择本地脚本目录"
        if newPath != undefined then
        (
            try
            (
                -- 确保路径存在
                if not doesFileExist newPath then
                (
                    messageBox "所选路径不存在！" title:"错误"
                    return false
                )
                
                -- 检查路径是否包含.ms文件
                local files = getFiles (newPath + "\\*.ms")
                if files.count == 0 then
                (
                    messageBox "所选目录中没有找到.ms脚本文件！" title:"错误"
                    return false
                )
                
                localScriptPath = newPath
                saveConfig()
                return true
            )
            catch
            (
                local errorMsg = getCurrentException()
                messageBox ("设置本地路径时出错: " + errorMsg) title:"错误"
                return false
            )
        )
        return false
    )
    
    -- 更新脚本列表
    fn updateScriptList = 
    (
        try
        (
            scriptList.Items.Clear()
            if isLocalMode then
            (
                -- 本地调试
                if localScriptPath != "" and doesFileExist localScriptPath then
                (
                    local files = getFiles (localScriptPath + "\\*.ms")
                    -- 对文件名进行排序
                    fn compareFiles a b = stricmp (getFilenameFile a) (getFilenameFile b)
                    qsort files compareFiles
                    
                    for file in files do
                    (
                        local fileName = getFilenameFile file
                        -- 排除工具本身
                        if fileName != "MotionReverse_Tool" then
                        (
                            -- 确保显示.ms后缀
                            if not matchPattern fileName pattern:"*.ms" then
                            (
                                fileName = fileName + ".ms"
                            )
                            
                            local item = dotNetObject "System.Windows.Forms.ListViewItem" fileName
                            item.SubItems.Add "调试" -- 修改版本列显示为"调试"
                            item.SubItems.Add "" -- 帮助链接
                            scriptList.Items.Add item
                        )
                    )
                    statusLabel.Text = "已加载 " + (scriptList.Items.Count) as string + " 个本地脚本"
                )
                else
                (
                    statusLabel.Text = "请先设置本地脚本路径"
                    messageBox "本地脚本路径无效，请重新设置" title:"提示"
                    isLocalMode = false
                    saveConfig()
                    updateScriptList()
                )
            )
            else
            (
                -- 远程模式
                if scripts.count == 0 then
                (
                    -- 如果脚本列表为空，重新获取配置
                    if getRemoteConfig() then
                    (
                        -- 对脚本列表进行排序
                        fn compareScripts a b = stricmp (toLower a[1]) (toLower b[1])
                        qsort scripts compareScripts
                        
                        for script in scripts do
                        (
                            local item = dotNetObject "System.Windows.Forms.ListViewItem" script[1]
                            item.SubItems.Add script[4] -- 版本
                            item.SubItems.Add script[3] -- 帮助链接
                            scriptList.Items.Add item
                        )
                        statusLabel.Text = "已加载 " + scripts.count as string + " 个远程脚本"
                    )
                    else
                    (
                        statusLabel.Text = "无法获取远程脚本列表"
                    )
                )
                else
                (
                    -- 对脚本列表进行排序
                    fn compareScripts a b = stricmp (toLower a[1]) (toLower b[1])
                    qsort scripts compareScripts
                    
                    for script in scripts do
                    (
                        local item = dotNetObject "System.Windows.Forms.ListViewItem" script[1]
                        item.SubItems.Add script[4] -- 版本
                        item.SubItems.Add script[3] -- 帮助链接
                        scriptList.Items.Add item
                    )
                    statusLabel.Text = "已加载 " + scripts.count as string + " 个远程脚本"
                )
            )
        )
        catch
        (
            local errorMsg = getCurrentException()
            messageBox ("更新脚本列表时出错: " + errorMsg) title:"错误"
            statusLabel.Text = "更新列表失败"
        )
    )
    
    -- 事件处理函数
    fn onRemoteClick = 
    (
        isLocalMode = false
        btnRemote.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 0 120 215
        btnRemote.ForeColor = (dotNetClass "System.Drawing.Color").White
        btnLocal.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 240 240 240
        btnLocal.ForeColor = (dotNetClass "System.Drawing.Color").Black
        saveConfig()
        updateScriptList()
    )
    
    fn onLocalClick = 
    (
        if localScriptPath == "" then
        (
            if setLocalPath() then
            (
                isLocalMode = true
                btnLocal.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 0 120 215
                btnLocal.ForeColor = (dotNetClass "System.Drawing.Color").White
                btnRemote.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 240 240 240
                btnRemote.ForeColor = (dotNetClass "System.Drawing.Color").Black
                saveConfig()
                updateScriptList()
            )
        )
        else
        (
            isLocalMode = true
            btnLocal.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 0 120 215
            btnLocal.ForeColor = (dotNetClass "System.Drawing.Color").White
            btnRemote.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 240 240 240
            btnRemote.ForeColor = (dotNetClass "System.Drawing.Color").Black
            saveConfig()
            updateScriptList()
        )
    )
    
    fn onSetPathClick = 
    (
        if setLocalPath() then
        (
            if isLocalMode then
            (
                updateScriptList()
            )
        )
    )
    
    fn onHelpClick = 
    (
        if scriptList.SelectedItems.Count > 0 then
        (
            local selectedItem = scriptList.SelectedItems.Item[0]
            local helpLink = selectedItem.SubItems.Item[2].Text
            
            if helpLink != "" then
            (
                shellLaunch helpLink ""
            )
            else
            (
                messageBox "该脚本没有帮助文档" title:"提示"
            )
        )
        else
        (
            messageBox "请先选择一个脚本" title:"提示"
        )
    )
    
    -- 从远程获取配置
    fn getRemoteConfig forceRefresh:false = 
    (
        try
        (
            -- 使用raw.githubusercontent.com获取配置文件内容
            local url = "https://raw.githubusercontent.com/" + repoOwner + "/" + repoName + "/main/MotionReverse_Config.ini"
            if forceRefresh then
            (
                url = url + "?t=" + (timestamp() as string)
            )
            
            print ("正在获取配置文件: " + url)
            
            local webClient = dotNetObject "System.Net.WebClient"
            webClient.Headers.Add "User-Agent" "MotionReverse-Tool"
            webClient.Headers.Add "Cache-Control" "no-cache"
            webClient.Encoding = (dotNetClass "System.Text.Encoding").UTF8
            
            -- 清理旧的配置
            scripts = #()
            
            local configContent = webClient.DownloadString url
            print ("获取到的配置内容长度: " + (if configContent != undefined then configContent.count else 0) as string)
            
            if configContent == undefined or configContent == "" then
            (
                messageBox "无法获取配置文件内容" title:"错误"
                return false
            )
            
            -- 记录更新时间
            lastConfigUpdate = timestamp()
            
            -- 打印配置内容的前100个字符用于调试
            print ("配置内容预览: " + (substring configContent 1 100))
            
            -- 解析配置内容
            local lines = filterString configContent "\n"
            print ("配置文件行数: " + lines.count as string)
            
            local inScriptsSection = false
            local lineNumber = 0
            
            for line in lines do
            (
                lineNumber += 1
                line = trimRight (trimLeft line)
                
                -- 跳过空行
                if line == "" then continue
                
                -- 检查是否进入[Scripts]部分
                if line == "[Scripts]" then
                (
                    inScriptsSection = true
                    print "找到[Scripts]部分"
                    continue
                )
                
                -- 检查是否进入[Settings]部分
                if line == "[Settings]" then
                (
                    inScriptsSection = false
                    print "找到[Settings]部分"
                    continue
                )
                
                -- 如果不在[Scripts]部分，跳过
                if not inScriptsSection then continue
                
                -- 跳过注释行
                if line[1] == ";" then continue
                
                -- 解析脚本配置行
                local parts = filterString line "="
                if parts.count == 2 then
                (
                    local scriptName = trimRight (trimLeft parts[1])
                    local scriptInfo = filterString parts[2] "|"
                    if scriptInfo.count == 3 then
                    (
                        -- 确保脚本名称包含.ms后缀
                        if not matchPattern (toLower scriptName) pattern:"*.ms" then
                        (
                            scriptName = scriptName + ".ms"
                        )
                        
                        -- 确保所有值都是字符串类型
                        local description = trimRight (trimLeft scriptInfo[1])
                        local helpLink = trimRight (trimLeft scriptInfo[2])
                        local version = trimRight (trimLeft scriptInfo[3])
                        
                        -- 验证值的有效性
                        if description == "" or helpLink == "" or version == "" then
                        (
                            print ("脚本信息包含空值 - 行号: " + lineNumber as string + ", 内容: " + line)
                            messageBox ("配置文件格式错误：脚本信息包含空值\n行号: " + lineNumber as string + "\n行内容: " + line) title:"错误"
                            return false
                        )
                        
                        append scripts #(
                            scriptName,
                            description,
                            helpLink,
                            version
                        )
                        print ("成功添加脚本: " + scriptName)
                    )
                    else
                    (
                        print ("脚本信息不完整 - 行号: " + lineNumber as string + ", 内容: " + line)
                        messageBox ("配置文件格式错误：脚本信息不完整\n行号: " + lineNumber as string + "\n行内容: " + line) title:"错误"
                        return false
                    )
                )
                else if line != "" and line[1] != ";" and line[1] != "[" then
                (
                    print ("无效的行格式 - 行号: " + lineNumber as string + ", 内容: " + line)
                    messageBox ("配置文件格式错误：无效的行格式\n行号: " + lineNumber as string + "\n行内容: " + line + "\n期望格式: 脚本名称 = 描述|帮助链接|版本号") title:"错误"
                    return false
                )
            )
            
            print ("成功解析 " + scripts.count as string + " 个脚本")
            
            if scripts.count == 0 then
            (
                print "没有找到有效的脚本配置"
                messageBox "配置文件格式错误：没有找到有效的脚本配置" title:"错误"
                return false
            )
            
            true
        )
        catch
        (
            local errorMsg = getCurrentException()
            print ("获取配置文件时发生错误: " + errorMsg)
            messageBox ("获取配置文件时发生错误:\n" + errorMsg + "\n\n请检查网络连接或稍后重试") title:"错误"
            false
        )
    )
    
    -- 获取远程脚本列表
    fn getRemoteScripts retryCount:0 = 
    (
        if retryCount >= maxRetries then
        (
            messageBox "获取远程脚本列表失败，已达到最大重试次数" title:"错误"
            return #()
        )
        
        local url = apiBaseUrl + "/contents/ms"
        local webClient = dotNetObject "System.Net.WebClient"
        webClient.Headers.Add "User-Agent" "MotionReverse-Tool"
        webClient.Headers.Add "Accept" "application/vnd.github.v3+json"
        
        try
        (
            local response = webClient.DownloadString url
            local scriptFiles = #()
            local lines = filterString response "\n"
            local currentName = undefined
            
            for line in lines do
            (
                if matchPattern line pattern:"*\"name\":*" then
                (
                    local nameStart = findString line "\"name\":"
                    if nameStart != undefined then
                    (
                        local nameStr = substring line (nameStart + 8) -1
                        nameStr = substituteString nameStr "\"" ""
                        nameStr = substituteString nameStr "," ""
                        nameStr = trimRight (trimLeft nameStr)
                        -- 只匹配.ms文件，排除.ini文件
                        if matchPattern nameStr pattern:"*.ms" and not matchPattern nameStr pattern:"*.ini" do
                        (
                            currentName = nameStr
                        )
                    )
                )
                else if matchPattern line pattern:"*\"download_url\":*" and currentName != undefined then
                (
                    local urlStart = findString line "\"download_url\":"
                    if urlStart != undefined then
                    (
                        local urlStr = substring line (urlStart + 15) -1
                        urlStr = substituteString urlStr "\"" ""
                        urlStr = substituteString urlStr "," ""
                        urlStr = trimRight (trimLeft urlStr)
                        append scriptFiles #(currentName, urlStr)
                        currentName = undefined
                    )
                )
            )
            scriptFiles
        )
        catch
        (
            local errorMsg = getCurrentException()
            if matchPattern errorMsg pattern:"*429*" then
            (
                messageBox "GitHub API访问受限，正在等待重试..." title:"提示"
                wait retryDelay
                getRemoteScripts retryCount:(retryCount + 1)
            )
            else if matchPattern errorMsg pattern:"*404*" then
            (
                messageBox "仓库ms目录不存在，请检查仓库结构" title:"错误"
                #()
            )
            else
            (
                messageBox ("获取远程脚本列表失败: " + errorMsg + "\n正在重试...") title:"错误"
                wait retryDelay
                getRemoteScripts retryCount:(retryCount + 1)
            )
        )
    )
    
    -- 下载脚本到指定路径
    fn downloadScriptToPath scriptName targetPath retryCount:0 = 
    (
        if retryCount >= maxRetries then
        (
            messageBox ("下载脚本失败，已达到最大重试次数: " + scriptName) title:"错误"
            return undefined
        )
        
        try
        (
            -- 确保脚本名称包含.ms后缀
            if not matchPattern (toLower scriptName) pattern:"*.ms" then
            (
                scriptName = scriptName + ".ms"
            )
            
            -- 构建正确的raw.githubusercontent.com URL
            local url = "https://raw.githubusercontent.com/" + repoOwner + "/" + repoName + "/refs/heads/main/ms/" + scriptName
            
            -- 打印下载链接
            print ("正在下载脚本，URL: " + url)
            
            -- 检查URL是否有效
            if url == undefined or url == "" then
            (
                messageBox "无效的下载URL" title:"错误"
                return undefined
            )
            
            local webClient = dotNetObject "System.Net.WebClient"
            webClient.Headers.Add "User-Agent" "MotionReverse-Tool"
            
            -- 使用目标路径
            local targetFile = targetPath + "\\" + scriptName
            
            -- 强制删除可能存在的文件
            if doesFileExist targetFile then
            (
                try
                (
                    -- 尝试直接删除
                    deleteFile targetFile
                )
                catch
                (
                    -- 如果直接删除失败，尝试使用dotNet方式删除
                    try
                    (
                        local fileInfo = dotNetObject "System.IO.FileInfo" targetFile
                        fileInfo.Delete()
                    )
                    catch
                    (
                        -- 如果还是失败，等待一小段时间后重试
                        wait 100
                        try
                        (
                            deleteFile targetFile
                        )
                        catch
                        (
                            messageBox ("无法删除已存在的文件: " + targetFile + "\n请确保文件未被其他程序占用") title:"错误"
                            return undefined
                        )
                    )
                )
            )
            
            -- 下载文件
            webClient.DownloadFile url targetFile
            
            -- 验证文件是否下载成功
            if doesFileExist targetFile then
            (
                -- 检查文件大小
                local fileSize = getFileSize targetFile
                if fileSize > 0 then
                (
                    targetFile
                )
                else
                (
                    deleteFile targetFile
                    messageBox "下载的文件大小为0" title:"错误"
                    undefined
                )
            )
            else
            (
                messageBox "文件下载失败" title:"错误"
                undefined
            )
        )
        catch
        (
            local errorMsg = getCurrentException()
            if matchPattern errorMsg pattern:"*429*" then
            (
                messageBox "GitHub API访问受限，正在等待重试...\n请稍后再试" title:"提示"
                wait retryDelay
                downloadScriptToPath scriptName targetPath retryCount:(retryCount + 1)
            )
            else if matchPattern errorMsg pattern:"*404*" then
            (
                messageBox ("文件不存在: " + scriptName + "\n请检查脚本名称是否正确\n完整URL: " + url) title:"错误"
                undefined
            )
            else if matchPattern errorMsg pattern:"*401*" or matchPattern errorMsg pattern:"*403*" then
            (
                messageBox "访问被拒绝，请检查网络连接和权限设置" title:"错误"
                undefined
            )
            else
            (
                messageBox ("下载脚本失败: " + errorMsg + "\n完整URL: " + url + "\n正在重试...") title:"错误"
                wait retryDelay
                downloadScriptToPath scriptName targetPath retryCount:(retryCount + 1)
            )
        )
    )
    
    -- 清理临时文件
    fn cleanupTempFiles = 
    (
        if doesFileExist tempDir then
        (
            local files = getFiles (tempDir + "*.ms")
            for file in files do
            (
                deleteFile file
            )
        )
    )
    
    -- 确保临时目录存在
    fn ensureTempDir = 
    (
        if not doesFileExist tempDir then
        (
            makeDir tempDir
        )
    )
    
    -- 运行选中的脚本
    fn runSelectedScript = 
    (
        if scriptList.SelectedItems.Count > 0 then
        (
            local selectedName = scriptList.SelectedItems.Item[0].Text
            -- 移除可能存在的.ms后缀
            if matchPattern (toLower selectedName) pattern:"*.ms" then
            (
                selectedName = substituteString selectedName ".ms" ""
            )
            
            print ("准备运行脚本: " + selectedName)
            
            if isLocalMode then
            (
                -- 本地调试
                if localScriptPath != "" then
                (
                    local scriptFile = localScriptPath + "\\" + selectedName + ".ms"
                    print ("本地脚本路径: " + scriptFile)
                    if doesFileExist scriptFile then
                    (
                        try
                        (
                            fileIn scriptFile
                        )
                        catch
                        (
                            local errorMsg = getCurrentException()
                            messageBox ("运行脚本时出错: " + errorMsg) title:"错误"
                        )
                    )
                    else
                    (
                        messageBox ("脚本文件不存在: " + scriptFile) title:"错误"
                    )
                )
                else
                (
                    messageBox "请先设置本地脚本路径" title:"提示"
                )
            )
            else
            (
                -- 远程模式
                print ("远程模式，准备下载脚本: " + selectedName)
                -- 确保临时目录存在
                ensureTempDir()
                -- 清理临时目录中的旧文件
                cleanupTempFiles()
                -- 等待一小段时间确保文件被完全释放
                wait 100
                -- 下载到临时目录
                local scriptFile = downloadScriptToPath selectedName tempDir
                if scriptFile != undefined then
                (
                    print ("脚本下载成功，路径: " + scriptFile)
                    try
                    (
                        -- 运行脚本
                        fileIn scriptFile
                        -- 等待一小段时间确保脚本执行完成
                        wait 100
                        -- 清理临时文件
                        cleanupTempFiles()
                    )
                    catch
                    (
                        local errorMsg = getCurrentException()
                        messageBox ("运行脚本时出错: " + errorMsg) title:"错误"
                        -- 等待一小段时间后清理
                        wait 100
                        cleanupTempFiles()
                    )
                )
                else
                (
                    messageBox ("无法获取脚本文件: " + selectedName + "\n请检查网络连接或稍后重试") title:"错误"
                )
            )
        )
        else
        (
            messageBox "请先选择一个脚本" title:"提示"
        )
    )
    
    -- 检查更新
    fn checkForUpdates = 
    (
        updateProgress.visible = true
        updateProgress.value = 0
        
        -- 清理临时文件
        cleanupTempFiles()
        
        -- 强制重新获取配置
        if getRemoteConfig forceRefresh:true then
        (
            updateProgress.value = 100
            updateScriptList()
            messageBox "配置已更新！" title:"提示"
        )
        else
        (
            messageBox "更新配置失败！" title:"错误"
        )
        
        updateProgress.visible = false
    )
    
    -- 另存脚本
    fn saveScriptAs = 
    (
        if scriptList.SelectedItems.Count > 0 then
        (
            local selectedName = scriptList.SelectedItems.Item[0].Text
            -- 移除可能存在的.ms后缀
            if matchPattern (toLower selectedName) pattern:"*.ms" then
            (
                selectedName = substituteString selectedName ".ms" ""
            )
            
            -- 选择保存路径
            local savePath = getSavePath caption:"选择保存目录"
            if savePath != undefined then
            (
                try
                (
                    -- 确保路径存在
                    if not doesFileExist savePath then
                    (
                        messageBox "所选路径不存在！" title:"错误"
                        return false
                    )
                    
                    -- 规范化路径格式
                    savePath = substituteString savePath "/" "\\"
                    if matchPattern savePath pattern:"*\\" then
                    (
                        savePath = substring savePath 1 (savePath.count - 1)
                    )
                    
                    -- 检查目录是否可写
                    local canWrite = false
                    local testFile = savePath + "\\MotionReverse_Test.tmp"
                    
                    -- 尝试创建测试文件
                    try
                    (
                        -- 先尝试删除可能存在的测试文件
                        if doesFileExist testFile do deleteFile testFile
                        
                        -- 创建新文件
                        local testStream = createFile testFile
                        if testStream != undefined then
                        (
                            format "test" to:testStream
                            close testStream
                            canWrite = true
                            deleteFile testFile
                        )
                    )
                    catch
                    (
                        local errorMsg = getCurrentException()
                        messageBox ("无法写入所选目录，请检查以下问题：\n1. 目录是否有写入权限\n2. 目录是否被其他程序占用\n3. 磁盘空间是否充足\n\n详细错误：" + errorMsg) title:"错误"
                        return false
                    )
                    
                    if canWrite then
                    (
                        -- 下载脚本到指定路径
                        local result = downloadScriptToPath selectedName savePath
                        if result != undefined then
                        (
                            messageBox ("脚本已保存到: " + result) title:"成功"
                            -- 如果当前是本地模式，刷新列表
                            if isLocalMode then
                            (
                                updateScriptList()
                            )
                            return true
                        )
                    )
                )
                catch
                (
                    local errorMsg = getCurrentException()
                    messageBox ("保存脚本时出错: " + errorMsg) title:"错误"
                )
            )
        )
        else
        (
            messageBox "请先选择一个脚本" title:"提示"
        )
        return false
    )
    
    -- 初始化UI
    fn initUI = 
    (
        -- 初始化模式切换面板
        modeSwitch.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 240 240 240
        
        -- 创建远程模式按钮
        btnRemote = dotNetObject "System.Windows.Forms.Button"
        btnRemote.Text = "远程模式"
        btnRemote.Size = dotNetObject "System.Drawing.Size" 120 20
        btnRemote.Location = dotNetObject "System.Drawing.Point" 50 5
        btnRemote.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat
        btnRemote.Font = dotNetObject "System.Drawing.Font" "Microsoft YaHei" 8.0
        btnRemote.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 0 120 215
        btnRemote.ForeColor = (dotNetClass "System.Drawing.Color").White
        
        -- 创建本地调试按钮
        btnLocal = dotNetObject "System.Windows.Forms.Button"
        btnLocal.Text = "本地调试"
        btnLocal.Size = dotNetObject "System.Drawing.Size" 120 20
        btnLocal.Location = dotNetObject "System.Drawing.Point" 180 5
        btnLocal.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat
        btnLocal.Font = dotNetObject "System.Drawing.Font" "Microsoft YaHei" 8.0
        btnLocal.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 240 240 240
        btnLocal.ForeColor = (dotNetClass "System.Drawing.Color").Black
        
        -- 创建设置路径按钮
        btnSetPath = dotNetObject "System.Windows.Forms.Button"
        btnSetPath.Text = "设置路径"
        btnSetPath.Size = dotNetObject "System.Drawing.Size" 60 20
        btnSetPath.Location = dotNetObject "System.Drawing.Point" 310 5
        btnSetPath.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat
        btnSetPath.Font = dotNetObject "System.Drawing.Font" "Microsoft YaHei" 8.0
        btnSetPath.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 240 240 240
        btnSetPath.ForeColor = (dotNetClass "System.Drawing.Color").Black
        
        -- 创建帮助按钮
        btnHelp = dotNetObject "System.Windows.Forms.Button"
        btnHelp.Text = "帮助"
        btnHelp.Size = dotNetObject "System.Drawing.Size" 40 20
        btnHelp.Location = dotNetObject "System.Drawing.Point" 5 5
        btnHelp.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat
        btnHelp.Font = dotNetObject "System.Drawing.Font" "Microsoft YaHei" 8.0
        btnHelp.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 240 240 240
        btnHelp.ForeColor = (dotNetClass "System.Drawing.Color").Black
        
        -- 添加按钮到面板
        modeSwitch.Controls.Add btnHelp
        modeSwitch.Controls.Add btnRemote
        modeSwitch.Controls.Add btnLocal
        modeSwitch.Controls.Add btnSetPath
        
        -- 设置按钮事件
        dotNet.addEventHandler btnHelp "Click" onHelpClick
        dotNet.addEventHandler btnRemote "Click" onRemoteClick
        dotNet.addEventHandler btnLocal "Click" onLocalClick
        dotNet.addEventHandler btnSetPath "Click" onSetPathClick
        
        -- 初始化ListView
        scriptList.View = (dotNetClass "System.Windows.Forms.View").Details
        scriptList.FullRowSelect = true
        scriptList.GridLines = true
        scriptList.MultiSelect = false
        scriptList.HideSelection = false
        scriptList.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 250 250 250
        scriptList.Columns.Add "脚本名称" 320
        scriptList.Columns.Add "版本" 60
        scriptList.Columns.Add "帮助链接" 0 -- 隐藏帮助链接列
        
        -- 设置描述框属性
        descriptionBox.Multiline = true
        descriptionBox.ReadOnly = true
        descriptionBox.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 250 250 250
        descriptionBox.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
        descriptionBox.Font = dotNetObject "System.Drawing.Font" "Microsoft YaHei" 9.0
        
        -- 设置状态标签属性
        statusLabel.ForeColor = (dotNetClass "System.Drawing.Color").FromArgb 0 120 215
        statusLabel.Font = dotNetObject "System.Drawing.Font" "Microsoft YaHei" 9.0
        
        -- 设置初始模式
        if isLocalMode then
        (
            if localScriptPath == "" then
            (
                isLocalMode = false
                btnRemote.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 0 120 215
                btnRemote.ForeColor = (dotNetClass "System.Drawing.Color").White
            )
            else
            (
                btnLocal.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 0 120 215
                btnLocal.ForeColor = (dotNetClass "System.Drawing.Color").White
            )
        )
        else
        (
            btnRemote.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 0 120 215
            btnRemote.ForeColor = (dotNetClass "System.Drawing.Color").White
        )
    )
    
    -- 事件处理
    on MotionReverseTool open do
    (
        initUI()
        loadConfig()
        -- 确保临时目录存在
        ensureTempDir()
        
        if isLocalMode then
        (
            updateScriptList()
        )
        else
        (
            -- 强制重新获取配置
            if getRemoteConfig forceRefresh:true then
            (
                updateScriptList()
                print "已更新到最新配置"
            )
            else
            (
                messageBox "无法获取远程配置！\n请点击\"检查更新\"按钮重试" title:"错误"
            )
        )
        updateProgress.visible = false
    )
    
    on MotionReverseTool close do
    (
        saveConfig()
        cleanupTempFiles()
    )
    
    on scriptList SelectedIndexChanged args do
    (
        if scriptList.SelectedItems.Count > 0 then
        (
            local scriptName = scriptList.SelectedItems.Item[0].Text
            if isLocalMode then
            (
                descriptionBox.Text = "本地脚本: " + scriptName
            )
            else
            (
                for script in scripts do
                (
                    if (toLower script[1]) == (toLower scriptName) then
                    (
                        descriptionBox.Text = script[2]
                        exit
                    )
                )
            )
        )
    )
    
    on scriptList DoubleClick args do
    (
        runSelectedScript()
    )
    
    on btnRun pressed do
    (
        print "运行按钮被点击"
        runSelectedScript()
    )
    
    on btnUpdate pressed do 
    (
        if not isLocalMode then
        (
            statusLabel.Text = "正在检查更新..."
            -- 添加确认对话框
            local result = queryBox "是否强制刷新配置？\n这将清除所有缓存并重新获取最新配置。" title:"确认更新"
            if result then
            (
                checkForUpdates()
            )
        )
        else
        (
            messageBox "本地调试下无需检查更新" title:"提示"
        )
    )
    
    on btnRefresh pressed do 
    (
        statusLabel.Text = "正在刷新列表..."
        updateScriptList()
    )
    
    on btnSaveAs pressed do
    (
        if not isLocalMode then
        (
            saveScriptAs()
        )
        else
        (
            messageBox "本地调试模式下无需另存脚本" title:"提示"
        )
    )
)

-- 创建工具窗口
createDialog MotionReverseTool 