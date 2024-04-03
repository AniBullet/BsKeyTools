-- 试验功能可以加入快速创建方块武器，刀剑，锤，长枪，手枪等~~

try(destroyDialog rolBsBoxMan )catch()

global rolBsBoxMan
global offsetBsBoxMan = [0,0]
global dragStateBsBoxMan = off

(
	local LastSubRollout = 1
	
	rollout rolBsBoxMan "" width:260 height:430
	(
		local dotColor = dotnetclass "System.Drawing.Color"

		button btnClose "X" pos:[rolBsBoxMan.width - 20,0] height:16 width:20
		label lblTitle "BsBoxMan_v1.0" pos:[5,3]
		dotNetControl tabBoxMan "System.Windows.Forms.TabControl" height:30 width:260 pos:[0,20] align:#center
		group ""
		(
			button btnCreateBodyBox "根据所选物体 渲染框 创建 Body Box" pos:[10,70] height:25 width:240
			radiobuttons rdoColor labels:#("随机颜色", "统一单色") columns:2 align:#center pos:[20,105]
			colorpicker rtcp "" width:70 height:20 color:[38,130,118] pos:[170,103]
			checkbox ckbFreeze "Box 是否冻结" pos:[20,135] width:100 height:20 color:[152, 227, 213] checked:true
			button btnClearBox "一键清除 Body Box" pos:[120,135] width:130 height:20 border:false
		)
		group ""
		(
			checkbutton ckbSync "同调" pos:[210,185] height:90 width:40 tooltip:"同时调节长宽高"
			checkbutton ckbCopy "获取" pos:[210,280] height:30 width:40 tooltip:"获取选择单个物体长宽高"
			checkbutton ckbPaste "应用" pos:[210,310] height:30 width:40 tooltip:"应用长宽高至选择的所有物体"
			slider sldLenthValue "Box 长："  pos:[15,180] align:#center range:[-100,100,10] \
			type:#integer tooltip:"调节选中" width:200 ticks:50
			slider sldWidthValue "Box 宽："  pos:[15,235] align:#center range:[-100,100,10] \
			type:#integer tooltip:"调节选中" width:200 ticks:50
			slider sldHeightValue "Box 高："  pos:[15,295] align:#center range:[-100,100,10] \
			type:#integer tooltip:"调节选中" width:200 ticks:50
		)
		
		groupBox gpbDisplayUnit "Display Unit" pos:[5,355] width:105 height:50
		dropdownlist ddlMetric "" align:#left selection:1 height:15 width:95 pos:[10,375] \
		items:#("Millimeters","Centimeters","Meters","Kilometers")

		groupBox gpbSystemUnit "System Unit" pos:[115,355] width:105 height:50
		dropdownlist ddlSystemUnit "" align:#left selection:1 height:15 width:95 pos:[120,375] \
		items:#("Inches","Feet","Miles","Millimeters","Centimeters","Meters","Kilometers")

		button btnGetUnit "刷新" tooltip:"获取当前 Unit (单位) 状态" pos:[225,361] width:30 height:44

		dotnetcontrol lblTips "Label" text:"2023.2 [ Bullet.S ] ✨        创建专属练习方块人" pos:[0,413] width:260 height:16

		local arrCreateBox = #("创建 Body Box",#(btnCreateBodyBox,rdoColor,rtcp,ckbFreeze,btnClearBox,ckbSync,\
			ckbCopy,ckbPaste,sldLenthValue,sldWidthValue,sldHeightValue,gpbDisplayUnit,gpbSystemUnit,btnGetUnit,\
			ddlSystemUnit,ddlMetric))
		local arrBoxColor = #("调整 Box 颜色",#()) 
		local arrTestFunc = #("实验功能",#())
		local arrAllToolsTab = #(arrCreateBox,arrBoxColor,arrTestFunc)

		fn fnInitDotTabs =
		(
			lblTips.font       = dotnetobject "System.Drawing.Font" "Roboto" 8
			lblTips.TextAlign  = (dotnetclass "system.drawing.contentalignment").MiddleCenter
			lblTips.BackColor  = (dotColor.FromArgb	255 250 250)
			lblTips.ForeColor  = (dotColor.FromArgb 60 0 160)
			tabBoxMan.sizeMode  = (dotnetclass "System.Windows.Forms.TabSizeMode").Fixed
			tabBoxMan.itemSize  = dotNetObject "System.Drawing.Size" 85 30
			tabBoxMan.dock      = tabBoxMan.dock.Fill
			tabBoxMan.Drawmode  = tabBoxMan.Drawmode.OwnerDrawFixed
	
			for aTab = 1 to arrAllToolsTab.count do
			(
				tabBoxMan.TabPages.add arrAllToolsTab[aTab][1]
			)
		)

		fn fnChangeToolsVisble id =
		(
			for i = 1 to arrAllToolsTab.count do 
			(
				if i == id then
				(
					for j in arrAllToolsTab[i][2] do j.visible = true
				)
				else (for j in arrAllToolsTab[i][2] do j.visible = false)
			)
			LastSubRollout = id
		)

		fn fnCreateBoxBody =
		(
			for i in selection do with undo off 
			(
				c = snapshot i
				c.transform = matrix3 1
				bb = c.max - c.min
				b = box width:bb[1] length:bb[2] height:bb[3]
				CenterPivot b
				delete c
				b.transform = i.transform
				b.pos = i.center
			-- 	b.pivot = i.pivot
				b.name = i.name + "_BsBoxManBox"
				lc = Link_Constraint()
				b.transform.controller = lc
				lc.key_mode = 0
				lc.addTarget i 0
				-- freeze b
				b.showFrozenInGray = off
			)
		)

		on tabBoxMan Selected itm do
		(
			arrID = (itm.TabPageIndex + 1)
			if LastSubRollout != arrID do --避免点击重复
			(
				fnChangeToolsVisble arrID
			) 
		)
		
		on rolBsBoxMan open do
		(
			fnInitDotTabs()
			fnChangeToolsVisble (tabBoxMan.SelectedIndex + 1)
		)

		on btnClose pressed do 
		(
			try (destroydialog rolBsBoxMan) catch ()
		)

		on rolBsBoxMan mbuttondown pos do 
		(
			try (destroydialog rolBsBoxMan) catch ()
		)
		
		on rolBsBoxMan lbuttondown posMou do
		(
			setSysCur #move
			offsetBsBoxMan = posMou
			dragStateBsBoxMan = on
		)
		
		on rolBsBoxMan lbuttonup posMou do
		(
			dragStateBsBoxMan = off
		)
		
		on rolBsBoxMan mouseMove pos do
		(
			if dragStateBsBoxMan == on then
			(
				SetDialogPos rolBsBoxMan (mouse.screenpos - offsetBsBoxMan)
			)
		)

		on btnCreateBodyBox pressed do
		(
			fnCreateBoxBody()
		)

		on btnClearBox pressed do 
		(
			try(delete $'*_BsBoxManBox';messagebox "清除BsBox成功!                      " title:"BsBoxMan")
			catch(messagebox "错误：清除BsBox失败!                      " title:"BsBoxMan")
		)
	)

	createDialog rolBsBoxMan style:#()
)