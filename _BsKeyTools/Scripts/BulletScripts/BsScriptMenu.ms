global rolBsScriptMenu
global BsScriptMenuConfig = execute ("@\"" + (getDir #maxData) + "\\BsScriptMenuConfig.ini\"")
global iniBsScriptMenuPath = ""
global iniBsScriptMenuName = "BsScriptsMenu"
global lastMenuName = undefined

Global SIOFile = dotNetClass "System.IO.File"			---文件操作
Global SIODir = dotNetClass "System.IO.Directory"		---文件夹操作
Global fnDelFile

global fnLoadBsScriptMenuConfig
global fnSetBsScriptMenuConfig

try(destroydialog rolBsScriptMenu)catch()

fn fnDelFile fileDel =
(
	if (SIOFile.Exists fileDel) == true do
	(
		if getFileAttribute fileDel #readOnly == true or getFileAttribute fileDel #hidden == true do
		(
			setFileAttribute fileDel #readOnly false ; setFileAttribute fileDel #hidden false
		)
		try (SIOFile.Delete(fileDel);(print ("已删除: "+ filenameFromPath fileDel)))
		catch (print ("删除失败: "+ filenameFromPath fileDel + ". 请尝试手动删除.");print "删除失败")
	)
)

fn fnDelDir dirDel =
(
	if (SIODir.Exists dirDel) == true do
	(
		if getFileAttribute dirDel #readOnly == true or getFileAttribute dirDel #hidden == true do
		(
			setFileAttribute dirDel #readOnly false ; setFileAttribute dirDel #hidden false
		)
		try (SIODir.Delete(dirDel) true;(print ("已删除: "+ pathConfig.stripPathToLeaf dirDel + " 文件夹")))
		catch (print ("删除失败: "+ pathConfig.stripPathToLeaf dirDel + " 文件夹. 请尝试手动删除.");print "删除失败")
	)
)

fn fnCopyDirectory sourceDir targetDir = 
(
	local SearchOption = dotNetClass "System.IO.SearchOption";
	local allFiles     = SIODir.GetFiles sourceDir \
										"*.*" \
										SearchOption.AllDirectories;

	for sourceFile in allFiles do
	(
		local targetFile    = targetDir + (substring sourceFile (sourceDir.count + 1) -1);
		local targetFileDir = getFilenamePath targetFile;
		if (not (SIODir.Exists targetFileDir)) do
			SIODir.CreateDirectory targetFileDir;
			fnDelFile targetFile
			SIOFile.Copy sourceFile targetFile;
	)
)

fn fnRemoveMenuByName menuName =
(
    if (menuName != undefined and (menuName as string) != "") then
    (
        local theMenu = menuMan.findMenu menuName
        if (theMenu != undefined) then
        (
            menuMan.unRegisterMenu theMenu
            menuMan.updateMenuBar()
        )
    )
)

fn fnGetBsScriptMenuConfig currentValue nameAttrClass nameAttr defaultValue =  -- 设置初始信息方法（安全读取，不执行字符串）
(
    local rawValue = (GetINISetting BsScriptMenuConfig nameAttrClass nameAttr) as string
    local resolvedValue

    if (rawValue == "" or rawValue == "undefined") then
    (
        resolvedValue = defaultValue
    )
    else
    (
        resolvedValue = rawValue
    )

    case nameAttr of
    (
        -- 数值类型：启动标记
        "BsScriptMenuStartup":
        (
            local intValue
            try (intValue = resolvedValue as integer) catch (intValue = undefined)
            if intValue == undefined do intValue = (defaultValue as integer)
            intValue
        )
        -- 其他均按字符串返回（包含路径与名称）
        default:
        (
            resolvedValue
        )
    )
)
fn fnLoadBsScriptMenuConfig =
(
    iniBsScriptMenuPath    = fnGetBsScriptMenuConfig iniBsScriptMenuPath "BsScriptMenuSet" "BsScriptMenuPath" (with printAllelements on (iniBsScriptMenuPath as string))
    iniBsScriptMenuName    = fnGetBsScriptMenuConfig iniBsScriptMenuName "BsScriptMenuSet" "BsScriptMenuName" (with printAllelements on (iniBsScriptMenuName as string))
)
fn fnSetBsScriptMenuConfig =
(
    -- 兜底：避免写回 undefined 或空值
    if (iniBsScriptMenuName == undefined or (iniBsScriptMenuName as string) == "") do iniBsScriptMenuName = "BsScriptsMenu"
    if (iniBsScriptMenuPath == undefined) do iniBsScriptMenuPath = ""

    SetINISetting BsScriptMenuConfig "BsScriptMenuSet" "BsScriptMenuPath" (with printAllelements on (iniBsScriptMenuPath as string))
    SetINISetting BsScriptMenuConfig "BsScriptMenuSet" "BsScriptMenuName" (with printAllelements on (iniBsScriptMenuName as string))
)

fnLoadBsScriptMenuConfig()

-- 递归创建子菜单和脚本项
fn fnRecursiveMenuHighVersion subMenu subPath =
(
    local scriptActionTableID = 647394
    local files = getFiles (subPath + ("/" + "*.m*"))
    sort files
    local dirArr = GetDirectories (subPath + "/*")
    sort dirArr
    
    -- 添加脚本文件
    for i in files do
    (
        local scriptName = getFilenameFile i
        local macroName = "BsScriptMenu" + (random 1000 9999) as string
        
        -- 创建宏脚本
        local macroStr = "macroscript " + macroName + " category:\"_[BsScriptMenu]\" buttontext:\"" + scriptName + "\" (FileIn @\"" + i + "\")"
        execute macroStr
        
        -- 添加到菜单
        subMenu.CreateAction (genGUID()) scriptActionTableID (macroName + "`_[BsScriptMenu]")
    )
    
    -- 添加分隔符（如果有文件和文件夹）
    if files.count > 0 and dirArr.count > 0 then
    (
        subMenu.CreateSeparator (genGUID())
    )
    
    -- 递归处理子文件夹
    for j = 1 to dirArr.count do
    (
        local subSubPath = substring dirArr[j] 1 (dirArr[j].count-1)
        local subSubMenuName = getFilenameFile subSubPath
        local subSubMenu = subMenu.CreateSubMenu (genGUID()) subSubMenuName
        fnRecursiveMenuHighVersion subSubMenu subSubPath
    )
)

-- 高版本菜单创建函数
fn fnCreateMenuHighVersion =
(
    function callbackBsScriptMenu =
    (
        local menuMgr = callbacks.notificationParam()
        local mainMenuBar = menuMgr.mainMenuBar
        local macroScriptActionTableID = 647394
        
        -- 创建主菜单 - 使用固定GUID
        local newSubMenu = mainMenuBar.CreateSubMenu (genGUID()) iniBsScriptMenuName
        
        -- 开始创建菜单结构
        if (iniBsScriptMenuPath != undefined) and (iniBsScriptMenuPath != "") then
        (
            fnRecursiveMenuHighVersion newSubMenu iniBsScriptMenuPath
        )
        
        -- 添加配置菜单项
        newSubMenu.CreateSeparator (genGUID())
        newSubMenu.CreateAction (genGUID()) macroScriptActionTableID "BsScriptMenuConfig`_[BsScriptMenu]"
        newSubMenu.CreateSeparator (genGUID())
    )
    
    callbacks.removeScripts id:#menuBsScriptMenu
    callbacks.addScript #cuiRegisterMenus callbackBsScriptMenu id:#menuBsScriptMenu
)

-- 低版本菜单创建函数（原有逻辑）
fn fnCreateMenuLowVersion =
(
    local ii = 0 
    
    rolBsScriptMenu.deleting_previousMenu iniBsScriptMenuPath
    if (lastMenuName != undefined and (lastMenuName as string) != "" and lastMenuName != iniBsScriptMenuName) then
    (
        while ((menuMan.findMenu lastMenuName) != undefined) do
        (
            menuMan.unRegisterMenu (menuMan.findMenu lastMenuName)
            menuMan.updateMenuBar()
        )
    )
    while ((menuMan.findMenu iniBsScriptMenuName) != undefined) do 
    (  
        menuMan.unRegisterMenu (menuMan.findMenu iniBsScriptMenuName)
        menuMan.updateMenuBar()
    ) 
    --------------------creating menu
    subMenu = menuMan.createMenu iniBsScriptMenuName 
    subPath = iniBsScriptMenuPath
    if (subPath != undefined) and (subPath != "") then (rolBsScriptMenu.recursive_menu subMenu subPath)
    rolBsScriptMenu.about_Menu subMenu
    -----------------------updating menu 
    mainMenuBar = menuMan.getMainMenuBar() 
    subMenuItem = menuMan.createSubMenuItem iniBsScriptMenuName subMenu 
    subMenuIndex = mainMenuBar.numItems() - 1 
    mainMenuBar.addItem subMenuItem subMenuIndex 
    menuMan.updateMenuBar()
)

-- 统一的菜单刷新函数
fn fnRefreshMenu =
(
    local curMaxVersion = ((maxVersion())[1] / 1000)
    
    if curMaxVersion < 27 then
    (
        -- 低版本使用原有方法
        fnCreateMenuLowVersion()
    )
    else
    (
        -- 高版本使用新方法
        fnCreateMenuHighVersion()
    )
)

rollout rolBsScriptMenu "BsScriptMenuConfig" width:460 height:160
(
	group ""
	(
		Label lblMenuName "自定义菜单命名：" align:#left across:4
		edittext edtMenuName "" align:#center offset:[20,0] width:190
		button btnSetName "确认命名" align:#right offset:[30,0] height:20 width:70 tooltip:"设置菜单名"
		button btnResetName "重置命名" align:#right height:20 width:70 tooltip:"重置菜单名为默认"
		Label lblPath "自定义脚本目录：" align:#left across:3
		edittext edtPath "" align:#center offset:[20,0] width:300
        button btnSetPath "设置" align:#right height:20 width:40  tooltip:"设置脚本目录"
		button btnOpenPath "打开目录" height:30 width:100  tooltip:"打开脚本目录" across:4
		button btnRefreshMenu "更新菜单" height:30 width:100  tooltip:"更新脚本列表"
		button btnReadme "必看说明" height:30 width:100  tooltip:"必看说明" 
        button btnUninstall "卸载" height:30 width:100  tooltip:"卸载工具"
	)

    group ""
	(
		HyperLink hlkAuthor "Bullet.S - S.银色子弹" align:#left width:160 color:(color 0 150 100) hovercolor:(color 0 150 150) visitedcolor:(color 0 150 100) address:"https://space.bilibili.com/2031113" across:3
		HyperLink hlkTips "开源免费，请勿商用" align:#center width:120 color:(color 0 150 100) hovercolor:(color 0 150 150) visitedcolor:(color 0 150 100) address:"https://space.bilibili.com/2031113/lists/560782" 
		Label lblVersion "- 版本：Aptx 1.0 -" width:120 align:#right 
	)

    fn fnUninstallScriptMenu =
    (
        if (queryBox "是否彻底清除 BsScriptMenu？          \r\n( 配置文件默认保留 )" \
		title:"有缘再会" beep:false) then
		(
            -- fnDelDir ((getDir #maxData) + "\\BsScriptMenuConfig.ini")
			local curMaxVersion = ((maxVersion())[1] / 1000)
			if curMaxVersion < 27 then
			(
				if ((menuMan.findMenu iniBsScriptMenuName) != undefined) then 
				(
					menuMan.unRegisterMenu (menuMan.findMenu iniBsScriptMenuName)
					menuMan.updateMenuBar()
				)
			)
			else
			(
				-- 高版本移除菜单回调
				callbacks.removeScripts id:#menuBsScriptMenu
			)

			arrDelMs = #(((getDir #StartupScripts)+ "\\BsScriptMenuStartup.ms"),\
			((getDir #Scripts)+ @"\\BulletScripts\\BsScriptMenu.ms"),\
			((getDir #Scripts)+ @"\\BulletScripts\\BsScriptMenuMacro.ms"))
			for f in arrDelMs do (fnDelFile f)
			try(destroydialog rolBsScriptMenu)catch()
			(messagebox "已清理干净，保留配置文件备用...    \r\n" beep:false title:"卸载成功！")
		)
    )

    local ii = 0 
    -----------------------------------------------------
    
    fn recursive_menu subMenu subPath = 
    ( 
        files=getFiles (subPath + ("/" + "*.m*")); sort files  
        dirArr = GetDirectories (subPath + "/*"); sort dirArr 
        -------------------- creating run-maroscripts and populating menu 
        for i in files do 
        ( 
            ii = ii + 1 
    
            str = "macroscript BsScriptMenu" + (ii as string) + " category:\"_[BsScriptMenu]\" buttontext:\"" + (getFilenameFile i) + "\" (FileIn @\"" + i + "\")" 
            execute str  
    
            testItem = menuMan.createActionItem ("BsScriptMenu" + (ii as string)) "_[BsScriptMenu]" 
            subMenu.addItem testItem -1 
        ) 
        --get dirs 
        if(dirArr.count>0)then 
        ( 
            if(files.count>0)then 
            ( 
                separator = menuMan.createSeparatorItem() 
                subMenu.addItem separator -1 
            ) 
            --creating subMenu 
            for i in dirArr do 
            ( 
                subSubPath = substring i 1 (i.count-1) 
                subSubMenu = menuMan.createMenu (getFilenameFile subSubPath) 
                subSubItem = menuMan.createSubMenuItem "name" subSubMenu 
                subMenu.addItem subSubItem -1 
                recursive_menu subSubMenu subSubPath 
            )
        )
    )
    
    fn about_Menu subMenu =
    (
        separator = menuMan.createSeparatorItem() 
        subMenu.addItem separator -1 
    
        bbs = menuMan.createActionItem ("BsScriptMenuConfig" ) "_[BsScriptMenu]" 
        subMenu.addItem bbs -1  
    
        separator = menuMan.createSeparatorItem() 
        subMenu.addItem separator -1 
    )
    
    ----------------------------------------------------- 
    fn deleting_previousMenu subPath =
    (
        if (subPath != undefined) and (subPath != "") then
        (
            files=getFiles (subPath + ("/" + "*.m*")); sort files 
            if (files.count>0) then
            (
                for i in files do 
                (
                    subMenuName = getFilenameFile i
                    while ((menuMan.findMenu subMenuName) != undefined) do 
                    (
                        menuMan.unRegisterMenu (menuMan.findMenu subMenuName) 
                        menuMan.updateMenuBar() 
                    )
                )
            )
            dirArr2 = GetDirectories (subPath + "/*"); sort dirArr2
            if (dirArr2.count>0) then 
            ( 
                for m in dirArr2 do 
                (
                    subSubPath2 = substring m 1 (m.count-1) 
                    subSubMenuName = getFilenameFile subSubPath2
                    while ((menuMan.findMenu subSubMenuName) != undefined) do 
                    (
                        menuMan.unRegisterMenu (menuMan.findMenu subSubMenuName) 
                        menuMan.updateMenuBar() 
                    )
                    deleting_previousMenu subSubPath2
                )
            )
        )
    )

	on rolBsScriptMenu open do 
	(
        fnLoadBsScriptMenuConfig()
        fnRefreshMenu()
        edtPath.text = iniBsScriptMenuPath
        edtMenuName.text = iniBsScriptMenuName
        if doesDirectoryExist iniBsScriptMenuPath == false then (messagebox "目录不存在，请重新设置！                                   " beep:false title:"BsScriptMenu")
	)
	on rolBsScriptMenu close do
	(
        if (edtPath.text != "") then (
            iniBsScriptMenuPath = edtPath.text
        )
        if (edtMenuName.text != "") then (
            iniBsScriptMenuName = edtMenuName.text
        )
		fnSetBsScriptMenuConfig()
	)
	on btnOpenPath pressed do 
	(
		try(shellLaunch iniBsScriptMenuPath "")catch()
	)
	on btnRefreshMenu pressed do
	(
        local curMaxVersion = ((maxVersion())[1] / 1000)
        if curMaxVersion < 27 then
        (
            if (edtPath.text != "") then (
                iniBsScriptMenuPath = edtPath.text
            )
            if (edtMenuName.text != "") then (
                iniBsScriptMenuName = edtMenuName.text
            )
            fnSetBsScriptMenuConfig()
            fnRefreshMenu()
        )
        else
        (
            (maxops.GetICuiMenuMgr()).LoadConfiguration((maxops.GetICuiMenuMgr()).GetCurrentConfiguration())
        )
        try(destroydialog rolBsScriptMenu)catch()
        messagebox "脚本菜单已实时刷新！                              " beep:false title:"BsScriptMenu"
	)
	on btnReadme pressed do 
	(
		messagebox "注意事项：\n\n1 关于更新列表：\n支持重启MAX更新列表，并保留手动更新！\n\n2 关于作者：\n脚本启发 Igorznag & Jwtoon 和吇鱼，Bullet.S 完全重构~"
	)
    on btnSetPath pressed do
    (
        local dir = getSavePath caption:"请选择目录:" initialDir:(getDir #Scripts)
		if (dir != undefined) then
		(
			edtPath.text = dir
            iniBsScriptMenuPath = dir
            fnSetBsScriptMenuConfig()
            fnRefreshMenu()
		)
    )
    on btnResetName pressed do 
    (
        if (queryBox "是否重置菜单名为默认？( 默认：BsScriptsMenu )                                              " beep:false title:"BsScriptMenu") then
        (
            lastMenuName = iniBsScriptMenuName
            iniBsScriptMenuName = "BsScriptsMenu"
            edtMenuName.text = iniBsScriptMenuName
            fnSetBsScriptMenuConfig()
            fnRefreshMenu()
        )
    )

    on btnSetName pressed do
    (
        if (edtMenuName.text != "") then (
            lastMenuName = iniBsScriptMenuName
            iniBsScriptMenuName = edtMenuName.text
            fnSetBsScriptMenuConfig()
            fnRefreshMenu()
        )
    )

    on btnUninstall pressed do
    (
        fnUninstallScriptMenu()
    )
)
fnRefreshMenu()