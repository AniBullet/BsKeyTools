global rolBsAnimButton 
try(destroyDialog rolBsAnimButton)catch()

Global iniPosAnimButtonTools
global iniAnimButtonSelected = 0
Global BulletConfig = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false)
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false)
stLoadConfigAll.fnLoadConfigBsAnimButton ()

Global switchAnimButtonMouState = false
Global posAnimButtonMouMove     = [0,0]

rcmenu RCmenuConfig
(
    menuItem mAbout "📺 miHoYo_Bullet.S"

    on mAbout picked do 
    (shellLaunch "https://space.bilibili.com/2031113" "")
)

rollout rolBsAnimButton  "BsAnimButton_v1.0"
(
    local LastSubRollout = 1

    dotNetControl dotnetTabCon "System.Windows.Forms.TabControl" height:20 width:285 align:#center pos:[0,0]
    button btnExit "✖" width:20 height:20 pos:[980,0]  border:false
    button btnHelp "？" width:20 height:20 pos:[960,0]  border:false
    label labelTemp "功能待添加..." pos:[350,0]

    
    local arrAnimBtn1 = #()
    local arrAnimBtn2 = #()
    local arrAnimBtn3 = #()
    local arrAnimBtn4 = #()
    
    local arrRolAnimBtn = #(
        #("☘︎模型☘︎",#(arrAnimBtn1)),
        #("☕︎蒙皮☕︎",#(arrAnimBtn2)),
        #("✜动画✜",#(arrAnimBtn3)),
        #("✈︎系统✈︎",#(arrAnimBtn4))
    )

    on btnHelp pressed do 
    (shellLaunch "https://www.notion.so/bullet4869/BsKeyTools-17b5ba7c37ae45f6a69ce90f45fa0657" "")

    on btnExit pressed do 
	(
		try (destroydialog rolBsAnimButton) catch ()
	)

    on dotnetTabCon Selected itm do
    (
        if LastSubRollout != (itm.TabPageIndex+1) do --处理相同tab情况
        (
            
        ) 
    )
    
    on rolBsAnimButton open do
    (
        stLoadConfigAll.fnLoadConfigBsAnimButton ()  ---------------脚本位置等赋值
		stSetConfigAll.fnSetConfigBsAnimButton ()  ----------------保存位置信息到ini文件
        -- dotnetTabCon.Appearance = dotnetTabCon.Appearance.Buttons
        dotnetTabCon.dock     = dotnetTabCon.dock.Fill
        dotnetTabCon.Drawmode = dotnetTabCon.Drawmode.OwnerDrawFixed
        dotnetTabCon.SizeMode = dotnetTabCon.SizeMode.Fixed
        dotnetTabCon.ItemSize = dotNetobject "System.Drawing.Size" 70 20
        
        for aTab in arrRolAnimBtn do
        (
            dotnetTabCon.TabPages.add aTab[1]
        )
        rolBsAnimButton.dotnetTabCon.SelectedIndex = iniAnimButtonSelected
    )

	on rolBsAnimButton close do -- 关闭记忆浮动窗口位置
	(
        iniPosAnimButtonTools   = (GetDialogPos rolBsAnimButton)
        stSetConfigAll.fnSetConfigBsAnimButton ()
	)

	on rolBsAnimButton mbuttondown pos do 
	(
		try (destroydialog rolBsAnimButton) catch ()
	)

	on rolBsAnimButton lbuttondown posMou do
	(
		posAnimButtonMouMove = posMou
		switchAnimButtonMouState = on
	)

	on rolBsAnimButton lbuttonup posMou do
	(
		switchAnimButtonMouState = off
	)

	on rolBsAnimButton rbuttondown pos do 
	(
		popupMenu RCmenuConfig pos:[mouse.screenpos.x + 20,mouse.screenpos.y]
	)

	on rolBsAnimButton mouseMove pos do
	(
		if switchAnimButtonMouState == on then
		(
			SetDialogPos rolBsAnimButton (mouse.screenpos - posAnimButtonMouMove)			
		)
	)
    ------------------------------------------------------------------------------------------------------
)
-- createDialog rolBsAnimButton 1000 100 fgcolor:myFgColor menu:RCmenuConfig
if (iniPosAnimButtonTools != 0) then 
(Createdialog rolBsAnimButton 1000 50 fgcolor:myFgColor pos:iniPosAnimButtonTools style:#())
else (Createdialog rolBsAnimButton 1000 50 fgcolor:myFgColor style:#())