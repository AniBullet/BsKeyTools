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
		-- button centimeterButton "Centimeters" pos:[120,365] width:80 height:28 toolTip:"Set Units to Decimal Feet"
		-- button kilometerButton "Kilometers" pos:[120,395] width:80 height:28 toolTip:"Set Units to Decimal Feet"
		-- button millimeterButton "Millimeters" pos:[20,365] width:80 height:28 toolTip:"Set Units to Decimal Feet"
		-- button meterButton "Meters" pos:[20,395] width:80 height:28 toolTip:"Set Units to Decimal Feet"
		dropdownlist ddlMetric "" align:#left selection:1 height:15 width:95 pos:[10,375] \
		items:#("Millimeters","Centimeters","Meters","Kilometers")

		groupBox gpbSystemUnit "System Unit" pos:[115,355] width:105 height:50
		dropdownlist ddlSystemUnit "" align:#left selection:1 height:15 width:95 pos:[120,375] \
		items:#("Inches","Feet","Miles","Millimeters","Centimeters","Meters","Kilometers")

		button btnGetUnit "刷新" tooltip:"获取当前 Unit (单位) 状态" pos:[225,361] width:30 height:44

		dotnetcontrol lblTips "Label" text:"2023.2 [ Bullet.S ] ✨        创建专属练习方块人" pos:[0,413] width:260 height:16

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
				b.name = i.name + "_box"
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
			-- if LastSubRollout != (itm.TabPageIndex + 1) do --do not update if the same tab clicked twice
			-- (
			-- 	for subroll in arrTabRollout[LastSubRollout][2] do
			-- 		removeSubRollout subRolUI subroll
			-- 	for subroll in arrTabRollout[LastSubRollout = itm.TabPageIndex+1][2] do	
			-- 		addSubRollout subRolUI subroll
			-- ) 
		)
		
		on rolBsBoxMan open do
		(
			lblTips.font       = dotnetobject "System.Drawing.Font" "Roboto" 8
			lblTips.TextAlign = (dotnetclass "system.drawing.contentalignment").MiddleCenter
			tabBoxMan.sizeMode = (dotnetclass "System.Windows.Forms.TabSizeMode").Fixed
			tabBoxMan.itemSize = dotNetObject "System.Drawing.Size" 85 30
			tabBoxMan.dock     = tabBoxMan.dock.Fill
			tabBoxMan.Drawmode = tabBoxMan.Drawmode.OwnerDrawFixed
			arrTabRollout = #("创建 Body Box","调整 Box 颜色","实验功能")
			for aTab in arrTabRollout do
			(
				tabBoxMan.TabPages.add aTab
			)
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

		-- on centimeterButton pressed do
		-- (
		-- 	units.displayType= #Metric
		-- 	units.metricType= #Centimeters
		-- )
		-- on kilometerButton pressed do
		-- (
		-- 	units.displayType= #Metric
		-- 	units.metricType= #Kilometers
		-- )
		-- on millimeterButton pressed do
		-- (
		-- 	units.displayType= #Metric
		-- 	units.metricType= #Millimeters
		-- )
		-- on meterButton pressed do
		-- (
		-- 	units.displayType= #Metric
		-- 	units.metricType= #Meters
		-- )
	)

	createDialog rolBsBoxMan style:#()
)