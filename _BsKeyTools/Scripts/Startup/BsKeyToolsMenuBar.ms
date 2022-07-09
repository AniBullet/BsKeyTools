try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))catch()
(
    local strMenuName = "🎮 BsKeyTools"
    local arrToolName = #("BsKeyTools","🎮 BsKeyTools","窗口位置重置")
    
    for i in arrToolName do
    (
        if ((menuMan.findMenu i) != undefined) then 
        (
            menuMan.unRegisterMenu (menuMan.findMenu i)
            menuMan.updateMenuBar()
        )
    )
    
    local menuBsTool = menuMan.createMenu strMenuName
    local separatorBsKeyTools = menuMan.createSeparatorItem()
    local mItemTool = menuMan.createActionItem "BulletKeyTools" "_[BulletTools]"
    local mItemPosReset = menuMan.createActionItem "BsKeyToolsPosReset" "_[BulletTools]"
    local menuTogglePanel = menuMan.createMenu "自动收缩面板"
    Local mItemOpenTogglePanel = menuMan.createActionItem "OpenBsTogglePanel" "_[BulletTools]"
    local mItemCloseTogglePanel = menuMan.createActionItem "CloseBsTogglePanel" "_[BulletTools]"
    local menuToolsHelp = menuMan.createMenu "帮助 / Help"
    local mItemBsToolsDocs = menuMan.createActionItem "UrlBsToolsDocs" "_[BulletTools]"
    local mItemBsToolsIssues = menuMan.createActionItem "UrlBsToolsIssues" "_[BulletTools]"
    local menuCheckUpdate = menuMan.createMenu "自动检测更新"
    local mItemCheckUpdateOn = menuMan.createActionItem "CheckUpdateOn" "_[BulletTools]"
    local mItemCheckUpdateOff = menuMan.createActionItem "CheckUpdateOff" "_[BulletTools]"
    local mItemUninstall = menuMan.createActionItem "UninstallBsKeyTools" "_[BulletTools]"
    local mItemUrlBilibili = menuMan.createActionItem "UrlBilibili" "_[BulletTools]"
    local mItemUrlTwitter = menuMan.createActionItem "UrlTwitter" "_[BulletTools]"
    local mItemUrlQgroup = menuMan.createActionItem "UrlQgroup" "_[BulletTools]"

    menuBsTool.addItem separatorBsKeyTools -1
    menuBsTool.addItem mItemPosReset -1
    menuBsTool.addItem separatorBsKeyTools -1
    menuBsTool.addItem mItemTool -1
    menuTogglePanel.addItem mItemOpenTogglePanel -1
    menuTogglePanel.addItem mItemCloseTogglePanel -1
    menuToolsHelp.addItem mItemBsToolsDocs -1
    menuToolsHelp.addItem mItemBsToolsIssues -1
    menuToolsHelp.addItem mItemUninstall -1
    menuToolsHelp.addItem separatorBsKeyTools -1
    menuToolsHelp.addItem mItemUrlBilibili -1
    menuToolsHelp.addItem mItemUrlTwitter -1
    menuToolsHelp.addItem mItemUrlQgroup -1
    menuCheckUpdate.addItem mItemCheckUpdateOn -1
    menuCheckUpdate.addItem mItemCheckUpdateOff -1
    
    mainMenuBar = menuMan.getMainMenuBar()
    subMainMenuItem = menuMan.createSubMenuItem strMenuName menuBsTool
    subMenuTogglePanel = menuMan.createSubMenuItem "自动收缩面板" menuTogglePanel
    subMenuToolsHelp = menuMan.createSubMenuItem "帮助 / Help" menuToolsHelp
    subMenuCheckUpdate = menuMan.createSubMenuItem "自动检测更新" menuCheckUpdate
    mainMenuBar.addItem subMainMenuItem -1
    menuBsTool.addItem subMenuToolsHelp 1
    menuBsTool.addItem separatorBsKeyTools 2
    menuBsTool.addItem subMenuCheckUpdate 3
    menuBsTool.addItem subMenuTogglePanel 4

    menuMan.updateMenuBar()
)