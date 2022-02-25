(
    macroScript BsKeyToolsPosReset
	category:"_[BulletTools]"
	buttonText:"BsKeyTools 窗口找回"
	toolTip:"BsKeyTools 窗口找回"
	(
		on execute do
		(
            try(fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BulletKeyTools.ms");SetDialogPos rolBsKeyTools [0,0])
            catch(messagebox "打开BsKeyTools失败,\r\n建议重启Max或重新安装...          ")
		)
	)

    fn fnBsAddMenuBar =
    (
        local strMenuName = "🎮 BsKeyTools"
        local arrToolName = #("BsKeyTools","🎮 BsKeyTools","BsKeyTools 窗口找回")
        
        for i in arrToolName do
        (
            if ((menuMan.findMenu i) != undefined) then 
            (
                menuMan.unRegisterMenu (menuMan.findMenu i)
                menuMan.updateMenuBar()
            )
        )
        
        local menuBsTool = menuMan.createMenu strMenuName
        local mItemTool = menuMan.createActionItem "BulletKeyTools" "_[BulletTools]"
        local mItemPosReset = menuMan.createActionItem "BsKeyToolsPosReset" "_[BulletTools]"
        local separatorBsKeyTools = menuMan.createSeparatorItem()
        menuBsTool.addItem mItemPosReset 1
        menuBsTool.addItem separatorBsKeyTools 2
        menuBsTool.addItem mItemTool 3
        
        mainMenuBar = menuMan.getMainMenuBar()
        subMainMenuItem = menuMan.createSubMenuItem strMenuName menuBsTool
        -- subMenuIndex = mainMenuBar.numItems() - 1 
        mainMenuBar.addItem subMainMenuItem -1
        menuMan.updateMenuBar()
    )
    fnBsAddMenuBar()
)