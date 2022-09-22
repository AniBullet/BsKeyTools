try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))catch()
(
    local strMenuName = "BsKeyTools"
    local arrToolName = #("BsKeyTools","🎮 BsKeyTools","自动收缩面板","帮助 / Help","自动检测更新","自动启动脚本","+菜单栏按钮-")
    
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
    local mItemPosReset       = menuMan.createActionItem "BsKeyToolsPosReset" "_[BulletTools]"
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


    menuBsTool.addItem separatorBsKeyTools -1
    menuBsTool.addItem mItemBsCleanVirus -1
    menuBsTool.addItem mItemPosReset -1
    menuBsTool.addItem separatorBsKeyTools -1
    menuBsTool.addItem mItemTool -1
    menuTogglePanel.addItem mItemOpenPanel -1
    menuTogglePanel.addItem mItemOpenPanelFull -1
    menuTogglePanel.addItem mItemClosePanel -1
    menuToolsHelp.addItem mItemBsToolsVideo -1
    menuToolsHelp.addItem mItemBsToolsDocs -1
    menuToolsHelp.addItem mItemBsToolsIssues -1
    menuToolsHelp.addItem separatorBsKeyTools -1
    menuToolsHelp.addItem mItemUrlBilibili -1
    menuToolsHelp.addItem mItemUrlTwitter -1
    menuToolsHelp.addItem mItemUrlQgroup -1
    menuToolsHelp.addItem separatorBsKeyTools -1
    menuToolsHelp.addItem mItemUninstall -1
    menuCheckUpdate.addItem mItemCheckUpdateOn -1
    menuCheckUpdate.addItem mItemCheckUpdateOff -1
    menuAutoStartup.addItem mItemStartupOn -1
    menuAutoStartup.addItem mItemStartupOff -1
    menuToolBar.addItem mItemToolBarAdd -1
    menuToolBar.addItem mItemToolBarRemove -1
    
    mainMenuBar        = menuMan.getMainMenuBar()
    subMainMenuItem    = menuMan.createSubMenuItem strMenuName menuBsTool
    subMenuToolsHelp   = menuMan.createSubMenuItem "帮助 / Help" menuToolsHelp
    subMenuTogglePanel = menuMan.createSubMenuItem "自动收缩面板" menuTogglePanel
    subMenuCheckUpdate = menuMan.createSubMenuItem "自动检测更新" menuCheckUpdate
    subMenuAutoStartup = menuMan.createSubMenuItem "自动启动脚本" menuAutoStartup
    subMenuToolBar     = menuMan.createSubMenuItem "+菜单栏按钮-" menuToolBar

    mainMenuBar.addItem subMainMenuItem -1
    menuBsTool.addItem subMenuToolsHelp 1
    menuBsTool.addItem separatorBsKeyTools 2
    menuBsTool.addItem subMenuCheckUpdate 3
    menuBsTool.addItem subMenuTogglePanel 4
    menuBsTool.addItem subMenuAutoStartup 5
    -- menuBsTool.addItem separatorBsKeyTools 6
    menuBsTool.addItem subMenuToolBar 6

    menuMan.updateMenuBar()
)