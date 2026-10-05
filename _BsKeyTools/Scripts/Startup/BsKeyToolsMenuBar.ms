Global SIOFile = dotNetClass "System.IO.File"
Global SIODir = dotNetClass "System.IO.Directory"
--杀毒需要获取加载自启脚本设置状态
global stateLoadStartupScripts = (getinisetting (getMAXIniFile()) "MAXScript" "LoadStartupScripts")

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))catch()

fn isRolloutOffScreen tarRol = (
    if fnBsEnsureDialogVisible == undefined do
    (
        format "[BsKeyTools] fnSaveLoadConfig.ms 未加载，无法校验窗口位置\n"
        return false
    )
    fnBsEnsureDialogVisible tarRol
)

fn fnDelFileDir targetDel =  --删除文件
(
	if (SIOFile.Exists targetDel == true) then ---判断是否存在文件
	(
		dotnet.loadAssembly "Microsoft.VisualBasic.dll"
	
		FileIO = dotnetclass "Microsoft.VisualBasic.FileIO.FileSystem"
		UIOption = (dotnetclass "Microsoft.VisualBasic.FileIO.UIOption").OnlyErrorDialogs
		RecycleOption = (dotnetclass "Microsoft.VisualBasic.FileIO.RecycleOption").SendToRecycleBin

		if getFileAttribute targetDel #readOnly == true or \
		getFileAttribute targetDel #hidden == true do --修改只读或者隐藏属性
		(
			setFileAttribute targetDel #readOnly false ; \
			setFileAttribute targetDel #hidden false
		)
		try 
		(
			FileIO.DeleteFile targetDel UIOption RecycleOption
			-- SIOFile.Delete(targetDel)
			(print ("已删除: "+ filenameFromPath targetDel  + " 至回收站"))
		)
		catch 
		(
			messagebox ("删除失败: "+ filenameFromPath targetDel + ". 请尝试手动删除。          ")
			(shellLaunch (getfilenamepath targetDel) "")
		)
	)
)
fn fnDelDir dirDel =
(
	if (SIODir.Exists dirDel) == true do
	(
		dotnet.loadAssembly "Microsoft.VisualBasic.dll"
	
		FileIO = dotnetclass "Microsoft.VisualBasic.FileIO.FileSystem"
		UIOption = (dotnetclass "Microsoft.VisualBasic.FileIO.UIOption").OnlyErrorDialogs
		RecycleOption = (dotnetclass "Microsoft.VisualBasic.FileIO.RecycleOption").SendToRecycleBin

		if getFileAttribute dirDel #readOnly == true or getFileAttribute dirDel #hidden == true do
		(
			setFileAttribute dirDel #readOnly false ; setFileAttribute dirDel #hidden false
		)
		try 
		(
			FileIO.DeleteDirectory dirDel UIOption RecycleOption
			-- SIODir.Delete(dirDel) true
			(print ("已删除: "+ pathConfig.stripPathToLeaf dirDel + " 文件夹至回收站"))
		)
		catch 
		(
			messagebox ("删除失败: "+ pathConfig.stripPathToLeaf dirDel + " 文件夹. 请尝试手动删除.")
			(shellLaunch dirDel "")
		)
	)
)

-- 创建菜单的函数（延迟执行，避免在UI重载期间崩溃）
fn fnCreateBsKeyToolsMenu =
(
    curMaxVersion = ((maxVersion())[1] / 1000)
    if curMaxVersion < 27 then
    (
        local strMenuName = "BsKeyTools"
        local arrToolName = #("BsKeyTools","🎮 BsKeyTools","自动收缩面板","帮助 / Help","自动检测更新","自动启动脚本","+菜单栏按钮-","工具窗口  位置重置")
        
        -- 检查菜单是否已存在，避免重复创建导致崩溃
        if (menuMan.findMenu strMenuName) != undefined then
        (
            -- 菜单已存在，不需要重新创建（避免在UI重载期间操作菜单）
            return undefined
        )
        
        for i in arrToolName do
        (
            while ((menuMan.findMenu i) != undefined) do 
            (
                menuMan.unRegisterMenu (menuMan.findMenu i)
                menuMan.updateMenuBar()
            )
        )
        
        local menuBsTool          = menuMan.createMenu strMenuName
        local separatorBsKeyTools = menuMan.createSeparatorItem()
        local mItemTool           = menuMan.createActionItem "BulletKeyTools" "_[BulletTools]"
        local menuTogglePanel     = menuMan.createMenu "自动收缩面板"
        Local mItemOpenPanel      = menuMan.createActionItem "OpenPanel" "_[BulletTools]"
        Local mItemOpenPanelFull  = menuMan.createActionItem "OpenPanelFull" "_[BulletTools]"
        local mItemClosePanel     = menuMan.createActionItem "ClosePanel" "_[BulletTools]"
        local menuToolsHelp       = menuMan.createMenu "帮助 / Help"
        local mItemBsToolsVideo   = menuMan.createActionItem "UrlBsToolsVideo" "_[BulletTools]"
        local mItemBsToolsDocs    = menuMan.createActionItem "UrlBsToolsDocs" "_[BulletTools]"
        local mItemBsToolsIssues  = menuMan.createActionItem "UrlBsToolsIssues" "_[BulletTools]"
        local menuCheckUpdate     = menuMan.createMenu "自动检测更新"
        local mItemCheckUpdateOn  = menuMan.createActionItem "CheckUpdateOn" "_[BulletTools]"
        local mItemCheckUpdateOff = menuMan.createActionItem "CheckUpdateOff" "_[BulletTools]"
        local mItemUninstall      = menuMan.createActionItem "UninstallBsKeyTools" "_[BulletTools]"
        local mItemUrlBilibili    = menuMan.createActionItem "UrlBilibili" "_[BulletTools]"
        local mItemUrlTwitter     = menuMan.createActionItem "UrlTwitter" "_[BulletTools]"
        local mItemUrlQgroup      = menuMan.createActionItem "UrlQgroup" "_[BulletTools]"
        local mItemBsCleanVirus   = menuMan.createActionItem "BsCleanVirus" "_[BulletTools]"
        local menuAutoStartup     = menuMan.createMenu "自动启动脚本"
        Local mItemStartupOn      = menuMan.createActionItem "BsKeyToolsStartupOn" "_[BulletTools]"
        local mItemStartupOff     = menuMan.createActionItem "BsKeyToolsStartupOff" "_[BulletTools]"
        local menuToolBar         = menuMan.createMenu "+菜单栏按钮-"
        Local mItemToolBarAdd     = menuMan.createActionItem "BsKeyToolsBarAdd" "_[BulletTools]"
        local mItemToolBarRemove  = menuMan.createActionItem "BsKeyToolsBarRemove" "_[BulletTools]"
        local menuPosReset        = menuMan.createMenu "工具窗口  位置重置"
        local mItemMainWindow     = menuMan.createActionItem "BsKeyToolsPosReset" "_[BulletTools]"
        local mItemBsScriptsSet   = menuMan.createActionItem "BsScriptsSetPosReset" "_[BulletTools]"
        local mItemBsResetConfig  = menuMan.createActionItem "BsKeyToolsResetConfig" "_[BulletTools]"

        mainMenuBar        = menuMan.getMainMenuBar()
        subMainMenuItem    = menuMan.createSubMenuItem strMenuName menuBsTool
        subMenuToolsHelp   = menuMan.createSubMenuItem "帮助 / Help" menuToolsHelp
        subMenuTogglePanel = menuMan.createSubMenuItem "自动收缩面板" menuTogglePanel
        subMenuCheckUpdate = menuMan.createSubMenuItem "自动检测更新" menuCheckUpdate
        subMenuAutoStartup = menuMan.createSubMenuItem "自动启动脚本" menuAutoStartup
        subMenuToolBar     = menuMan.createSubMenuItem "+菜单栏按钮-" menuToolBar
        subMenuPosReset    = menuMan.createSubMenuItem "工具窗口  位置重置" menuPosReset

        mainMenuBar.addItem subMainMenuItem -1

        menuBsTool.addItem subMenuToolsHelp -1
        menuToolsHelp.addItem mItemBsToolsVideo -1
        menuToolsHelp.addItem mItemBsToolsDocs -1
        menuToolsHelp.addItem mItemBsToolsIssues -1
        menuToolsHelp.addItem separatorBsKeyTools -1
        menuToolsHelp.addItem mItemUrlBilibili -1
        menuToolsHelp.addItem mItemUrlTwitter -1
        menuToolsHelp.addItem mItemUrlQgroup -1
        menuToolsHelp.addItem separatorBsKeyTools -1
        menuToolsHelp.addItem mItemUninstall -1
        
        menuBsTool.addItem separatorBsKeyTools -1
        menuBsTool.addItem subMenuCheckUpdate -1
        menuCheckUpdate.addItem mItemCheckUpdateOn -1
        menuCheckUpdate.addItem mItemCheckUpdateOff -1
        menuBsTool.addItem subMenuTogglePanel -1
        menuTogglePanel.addItem mItemOpenPanel -1
        menuTogglePanel.addItem mItemOpenPanelFull -1
        menuTogglePanel.addItem mItemClosePanel -1
        menuBsTool.addItem subMenuAutoStartup -1
        menuAutoStartup.addItem mItemStartupOn -1
        menuAutoStartup.addItem mItemStartupOff -1
        menuBsTool.addItem subMenuToolBar -1
        menuToolBar.addItem mItemToolBarAdd -1
        menuToolBar.addItem mItemToolBarRemove -1

        menuBsTool.addItem separatorBsKeyTools -1
        menuBsTool.addItem mItemBsCleanVirus -1
        menuBsTool.addItem subMenuPosReset -1
        menuPosReset.addItem mItemMainWindow -1
        menuPosReset.addItem mItemBsScriptsSet -1
        menuBsTool.addItem separatorBsKeyTools -1
        menuBsTool.addItem mItemBsResetConfig -1
        menuBsTool.addItem separatorBsKeyTools -1
        menuBsTool.addItem mItemTool -1
        
        menuMan.updateMenuBar()

        try
        (
            local menuFile = menuMan.getMenuFile()
            if menuFile != undefined and menuFile != "" then
                menuMan.saveMenuFile menuFile
        )
        catch()
    )
    else
    (
        function callbackBsMenu =
        (
            -- print "BsKeyTools menu loaded"
            local menuMgr = callbacks.notificationParam()

            local mainMenuBar = menuMgr.mainMenuBar

            local newSubMenu = mainMenuBar.CreateSubMenu "E1C75949-7407-46A4-9826-F3BB3495EDA6" "BsKeyTools"

            local separatorId = "B8FBA1AF-67A9-4614-A207-2458C17DBB95"
            newSubMenu.CreateSeparator separatorId
            
            local macroScriptActionTableID = 647394

            subMenu1 = newSubMenu.CreateSubMenu "7A003CFC-9832-44E0-8F4F-06F6217D61DF" "帮助 / Help"
            newSubMenu.CreateSeparator (genGUID())
            subMenu2 = newSubMenu.CreateSubMenu "B39EA47D-6FFE-4B0A-8C28-C5483D99B20B" "自动检测更新"
            subMenu3 = newSubMenu.CreateSubMenu "EA3A4870-04B0-4B13-A387-3D5EEFAEB43F" "自动收缩面板"
            subMenu4 = newSubMenu.CreateSubMenu "0B8CD8AE-237E-4D7F-A6D5-3BB755C23FF2" "自动启动脚本"
            subMenu5 = newSubMenu.CreateSubMenu "80F4114F-189B-4F44-8E90-7A1BBAE3CD8B" "+菜单栏按钮-"
            newSubMenu.CreateSeparator (genGUID())
            subMenu6 = newSubMenu.CreateSubMenu "C31915DC-B962-4A86-98B2-997F1CD61C67" "工具窗口  位置重置"
            newSubMenu.CreateSeparator (genGUID())
            subMenu7 = newSubMenu.CreateSubMenu "F4DF591A-8FAF-4A51-A54B-CFC8E59EFFC4" "重置配置  请先备份"

            subMenu1.CreateAction (genGUID()) macroScriptActionTableID "UrlBsToolsVideo`_[BulletTools]"
            subMenu1.CreateAction (genGUID()) macroScriptActionTableID "UrlBsToolsDocs`_[BulletTools]"
            subMenu1.CreateAction (genGUID()) macroScriptActionTableID "UrlBsToolsIssues`_[BulletTools]"
            subMenu1.CreateSeparator (genGUID())
            subMenu1.CreateAction (genGUID()) macroScriptActionTableID "UrlBilibili`_[BulletTools]"
            subMenu1.CreateAction (genGUID()) macroScriptActionTableID "UrlTwitter`_[BulletTools]"
            subMenu1.CreateAction (genGUID()) macroScriptActionTableID "UrlQgroup`_[BulletTools]"
            subMenu1.CreateSeparator (genGUID())
            subMenu1.CreateAction (genGUID()) macroScriptActionTableID "UninstallBsKeyTools`_[BulletTools]"

            subMenu2.CreateAction (genGUID()) macroScriptActionTableID "CheckUpdateOn`_[BulletTools]"
            subMenu2.CreateAction (genGUID()) macroScriptActionTableID "CheckUpdateOff`_[BulletTools]"

            subMenu3.CreateAction (genGUID()) macroScriptActionTableID "OpenPanel`_[BulletTools]"
            subMenu3.CreateAction (genGUID()) macroScriptActionTableID "OpenPanelFull`_[BulletTools]"
            subMenu3.CreateAction (genGUID()) macroScriptActionTableID "ClosePanel`_[BulletTools]"

            subMenu4.CreateAction (genGUID()) macroScriptActionTableID "BsKeyToolsStartupOn`_[BulletTools]"
            subMenu4.CreateAction (genGUID()) macroScriptActionTableID "BsKeyToolsStartupOff`_[BulletTools]"

            subMenu5.CreateAction (genGUID()) macroScriptActionTableID "BsKeyToolsBarAdd`_[BulletTools]"
            subMenu5.CreateAction (genGUID()) macroScriptActionTableID "BsKeyToolsBarRemove`_[BulletTools]"

            subMenu6.CreateAction (genGUID()) macroScriptActionTableID "BsKeyToolsPosReset`_[BulletTools]"
            subMenu6.CreateAction (genGUID()) macroScriptActionTableID "BsScriptsSetPosReset`_[BulletTools]"

            subMenu7.CreateAction (genGUID()) macroScriptActionTableID "BsKeyToolsResetConfig`_[BulletTools]"

            newSubMenu.CreateSeparator (genGUID())
            newSubMenu.CreateAction (genGUID()) macroScriptActionTableID "BulletKeyTools`_[BulletTools]" title:"🌟 BsKeyTools"
        )
        callbacks.removeScripts id:#menuBsKeyTools
        callbacks.addScript #cuiRegisterMenus callbackBsMenu id:#menuBsKeyTools
    )
)

-- Max >= 27: cuiRegisterMenus 回调（已在 fnCreateBsKeyToolsMenu 内处理）
-- Max < 27: findMenu guard + timer 延迟创建 + saveMenuFile
-- 已知限制: 重启 Max 后首次切换主题可能崩溃（Max 内部 bug），崩溃后再次启动即恢复
if ((maxVersion())[1] / 1000) >= 27 then
(
    fnCreateBsKeyToolsMenu()
)
else if (menuMan.findMenu "BsKeyTools") == undefined then
(
    try(destroydialog _rolBsKeyToolsMenuInit)catch()
    rollout _rolBsKeyToolsMenuInit "" width:1 height:1
    (
        timer tmrInit interval:1000 active:true
        on tmrInit tick do
        (
            tmrInit.active = false
            try(destroydialog _rolBsKeyToolsMenuInit)catch()
            fnCreateBsKeyToolsMenu()
            format "[BsKeyTools] 提示: Max 2025 以下版本重启后首次切换颜色主题可能导致崩溃，崩溃后再次启动即可恢复。\n"
        )
    )
    createDialog _rolBsKeyToolsMenuInit pos:[-10000,-10000] style:#(#style_toolwindow)
)

---通用方法预加载------
global addToolBarButton
fn addToolBarButton macro cat txt remove: false =
(
    local dirIcon = getdir #usericons
    local imgIcon16 = ((getDir #scripts) + "\\BulletScripts\\Icons\\BsBipTools_16i.bmp")
    local imgIcon24 = ((getDir #scripts) + "\\BulletScripts\\Icons\\BsBipTools_24i.bmp")
    local imgIcon16a = ((getDir #scripts) + "\\BulletScripts\\Icons\\BsBipTools_16a.bmp")
    local imgIcon24a = ((getDir #scripts) + "\\BulletScripts\\Icons\\BsBipTools_24a.bmp")
    local tarIcon16 = dirIcon + "\\BsBipTools_16i.bmp"
    local tarIcon24 = dirIcon + "\\BsBipTools_24i.bmp"
    local tarIcon16a = dirIcon + "\\BsBipTools_16a.bmp"
    local tarIcon24a = dirIcon + "\\BsBipTools_24a.bmp"

    if (not (SIOFile.Exists tarIcon16)) then
    (
        SIOFile.Copy imgIcon16 tarIcon16
    )
    else
    (
        SIOFile.Delete tarIcon16
        SIOFile.Copy imgIcon16 tarIcon16
    )

    if (not (SIOFile.Exists tarIcon24)) then
    (
        SIOFile.Copy imgIcon24 tarIcon24
    )
    else
    (
        SIOFile.Delete tarIcon24
        SIOFile.Copy imgIcon24 tarIcon24
    )
    if (not (SIOFile.Exists tarIcon16a)) then
    (
        SIOFile.Copy imgIcon16a tarIcon16a
    )
    else
    (
        SIOFile.Delete tarIcon16a
        SIOFile.Copy imgIcon16a tarIcon16a
    )

    if (not (SIOFile.Exists tarIcon24a)) then
    (
        SIOFile.Copy imgIcon24a tarIcon24a
    )
    else
    (
        SIOFile.Delete tarIcon24a
        SIOFile.Copy imgIcon24a tarIcon24a
    )

    fn insertContent f data: "" find: "" rewrite: false =
    (						
        file = MemStreamMgr.openFile f
        size = file.size()
        MemStreamMgr.close file
                
        stream = openFile f mode:"r+"

        seek stream 0 
        
        if ((sysinfo.GetMaxLanguage())[3]=="CHS")  then 
        (
            mt = "\"主工具栏\""
        )
        else
        (
            mt = "\"Main Toolbar\""
        )
                
        skipToString stream mt
                
        exist = (skipToString stream find) == undefined
        
        previousContent = ""
        
        findPos = filePos stream
        
        if(not exist) do
        (							
            if(rewrite) do 
            (
                pos = findPos - find.count
                seek stream	0
                previousContent += readChars stream (pos)					
            )
            
            pos = findPos - (if(rewrite) then 0 else find.count)
        
            seek stream pos
            
            previousContent += readChars stream (size - pos)
                                    
            if(rewrite) do pos = 0
            
            seek stream pos
                
                        
            format data to: stream
            format previousContent to: stream
        )
        
        close stream
        
        return not exist
    )
    
    try
    (
        f = cui.getConfigFile() 
        
        cui.loadConfig f
        cui.saveConfigAs f
        cui.loadConfig f
        -- <Item typeID="2" type="CTB_MACROBUTTON" width="62" height="0" controlID="0" macroTypeID="3" macroType="MB_TYPE_ACTION" actionTableID="647394" imageID="-1" imageName="" actionID="BulletKeyTools`_[BulletTools]" tip="BsKeyTools" label="BsKeyTools" />
        l = "<Item typeID=\"2\" type=\"CTB_MACROBUTTON\" width=\"0\" height=\"0\" controlID=\"0\" macroTypeID=\"3\" macroType=\"MB_TYPE_ACTION\" actionTableID=\"647394\" imageID=\"-1\" imageName=\"\" actionID=\"" + macro + "`_[" + cat + "]\" tip=\"" + txt + "\" label=\"" + txt + "\" />"
        delBtnLine = "<Item typeID=\"2\" type=\"CTB_MACROBUTTON\" width=\"0\" height=\"0\" controlID=\"0\" macroTypeID=\"3\" macroType=\"MB_TYPE_ACTION\" actionTableID=\"647394\" imageID=\"-1\" imageName=\"\" actionID=\"" + macro + "`_[" + cat + "]\" tip=\"" + txt + "\" label=\"" + txt + "\" />"
        if(remove) then
        (			
            insertContent f find: delBtnLine rewrite: true
        )
        else
        (		
            insertContent f find: "</Items>" data: ("\t\t" + l + "\n")			
        )
                
        cui.loadConfig f
        --cui.setConfigFile f
        cui.saveConfigAs f
        --cui.loadConfig f
            
    ) catch(try(massagebox (getCurrentException()));catch();messagebox "请手动处理Toolbar!             \r\n" title: "错误!")

    -- colorman.reInitIcons() 
    -- 注释原因：此函数在低版本Max(2024及以下)切换颜色主题时会导致崩溃
    -- 因为主题切换时Max会重新加载UI配置，此时调用reInitIcons会触发竞态条件
    -- cui.loadConfig已经会自动更新图标，无需手动调用reInitIcons

    if (not remove) then (messageBox "添加工具栏快捷按钮完成，请注意蓝底白字“S”图标！                                    \r\n" title: "BsKeyTools")
    if (remove) then (messageBox "尝试删除工具栏快捷按钮完成！(添加时也会运行一次)                                      \r\n" title: "BsKeyTools")
)