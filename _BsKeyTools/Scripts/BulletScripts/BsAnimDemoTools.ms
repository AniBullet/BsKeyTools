/*
 * @Description: Demo专用工具集
 * @Author: Bullet.S
 * @Date: 2024-04-03 10:58:49
 * @LastEditors: Bullet.S
 * @LastEditTime: 2025-01-07 22:00:05
 * @Email: animator.bullet@foxmail.com
 */
--E8C18FB749BA820E0525422425AFBED057AD5AEB7FE98E2F17C688B869B454

try(destroyDialog rolBsAnimDemoTools )catch()

global rolBsAnimDemoTools
global offsetBsADT = [0,0]
global dragStateBsADT = off

(
	local LastSubRollout = 1
	
	rollout rolBsAnimDemoTools "" width:265 height:300
	(
		local dotColor = dotnetclass "System.Drawing.Color"
		button btnRegister "免费注册刀光" pos:[rolBsAnimDemoTools.width - 120,0] width:80 height:16 border:false
		button btnAbout "?" pos:[rolBsAnimDemoTools.width - 40,0] height:16 width:20
		button btnClose "X" pos:[rolBsAnimDemoTools.width - 20,0] height:16 width:20
		label lblTitle "BsAnimDemo_v1.0" pos:[5,3]
		dotNetControl tabBsADT "System.Windows.Forms.TabControl" height:30 width:rolBsAnimDemoTools.width pos:[0,20] align:#center
		------------------------------------------------------------------------------------------------------------------------------
		groupbox gpbTrail "" pos:[5,50] width:(rolBsAnimDemoTools.width - 10) height:70
		spinner spnRadian "弧度 " pos:[30,65] width:60 height:20 type:#float range:[-20,20,0] scale:0.1
		checkbutton chkCreateLine "1.创建线" pos:[100,65] width:75 height:20 checked:true
		checkbutton chkCreateTrail "2.创建刀光" pos:[180,65] width:75 height:20 checked:true
		button btnSelectTrail "选中" pos:[10,90] width:60 height:24
		button btnHideTrail "隐藏" pos:[75,90] width:55 height:24
		button btnShowTrail "显示" pos:[135,90] width:55 height:24
		button btnDeleteTrail "清除" pos:[195,90] width:60 height:24
		-------------------------------------------------------------------------------------------------------------------------------------
		groupbox gpbPreset "" pos:[5,120] width:(rolBsAnimDemoTools.width - 10) height:65
		radiobuttons rdoTrailType "类型:" labels:#("移动","固定") columns:2 pos:[15,135] offsets:#([40,-16],[0,-16])
		spinner spnFrameToLag "帧延迟" pos:[185,136] width:65 height:20 type:#integer range:[0,1000,3]
		checkbox ckbSetRange "指定帧范围" pos:[15,158] width:80 height:20 checked:false enabled:false
		spinner spnStartFrame "起始" pos:[120,160] width:55 height:20 type:#integer range:[0,999999,animationrange.start] enabled:false
		spinner spnEndFrame "结束" pos:[195,160] width:55 height:20 type:#integer range:[0,999999,animationrange.end] enabled:false
		----------------------------------------------------------------------------------------------------------------------------------------
		groupbox gpbMesh "" pos:[5,185] width:(rolBsAnimDemoTools.width - 10) height:65
		spinner spnSegments "每帧段数" pos:[40,200] width:90 height:20 type:#float range:[0.0001,1000,10.0]
		spinner spnSplineSteps "线 段数" pos:[175,200] width:75 height:20 type:#integer range:[0,1000,6]
		spinner spnURepeat "U 重复" pos:[40,224] width:55 height:20 type:#float range:[0.0001,1000,1.0]
		checkbox ckbFlipNormals "翻转法线" pos:[110,223] width:70 height:20 checked:false
		checkbox ckbGenerateMapping "生成映射" pos:[185,223] width:70 height:20 checked:true
		-----------------------------------------------------------------------------------------------------------------------------------------
		button btnMaterial "材质窗口" pos:[5,256] width:65 height:20
		-- button btnTransparency "透明" pos:[75,256] width:40 height:20
		dropdownlist ddlDefaultTex "" pos:[75,255] width:105 height:20 items:#("默认刀光")
		button btnSelectTex "赋予材质" pos:[185,256] width:75 height:20
		-------------------------------------------------------------------------------------------------------------------------------------------
		dotnetcontrol lblTips "Label" text:"2024.4 [ Bullet.S ] ✨        动画师 Demo 简易环境" pos:[0,283] width:rolBsAnimDemoTools.width height:16

		local arrGhostTrails = #("刀光",#(gpbTrail,spnRadian,chkCreateLine,chkCreateTrail,btnSelectTrail,btnHideTrail, \
										btnShowTrail,btnDeleteTrail,gpbPreset,rdoTrailType,spnFrameToLag,ckbSetRange, \
										spnStartFrame,spnEndFrame,gpbMesh,spnSegments,spnSplineSteps,spnURepeat, \
										ckbFlipNormals,ckbGenerateMapping,btnMaterial,ddlDefaultTex,btnSelectTex))
		local arrDemoScene = #("场景",#()) 
		local arrDemoLight = #("灯光",#())
		local arrDemoMat = #("材质",#())
		local arrAllToolsTab = #(arrGhostTrails,arrDemoScene,arrDemoLight,arrDemoMat)
	
		fn fnInitDotTabs =
		(
			lblTips.font       = dotnetobject "System.Drawing.Font" "Roboto" 8
			lblTips.TextAlign  = (dotnetclass "system.drawing.contentalignment").MiddleCenter
			lblTips.BackColor  = (dotColor.FromArgb	200 200 200)
			lblTips.ForeColor  = (dotColor.FromArgb 139 0 0)
			tabBsADT.sizeMode  = (dotnetclass "System.Windows.Forms.TabSizeMode").Fixed
			tabBsADT.itemSize  = dotNetObject "System.Drawing.Size" 65 30
			tabBsADT.dock      = tabBsADT.dock.Fill
			tabBsADT.Drawmode  = tabBsADT.Drawmode.OwnerDrawFixed
	
			for aTab = 1 to arrAllToolsTab.count do
			(
				tabBsADT.TabPages.add arrAllToolsTab[aTab][1]
			)
		)

		fn fnRefreshInitValue = 
		(
			try
			(
				rdoTrailType.state       = $.modifiers[#GhostTrails].movingorstill + 1
				spnFrameToLag.value      = $.modifiers[#GhostTrails].old_frames
				spnStartFrame.value      = $.modifiers[#GhostTrails].startFrame/80
				spnEndFrame.value        = $.modifiers[#GhostTrails].endFrame/80
				spnSegments.value        = $.modifiers[#GhostTrails].segmentsperframe
				spnSplineSteps.value     = $.modifiers[#GhostTrails].splineSteps
				spnURepeat.value         = $.modifiers[#GhostTrails].pb_urepeat
				ckbFlipNormals.state     = $.modifiers[#GhostTrails].flipNormals
				ckbGenerateMapping.state = $.modifiers[#GhostTrails].generateMap
			)catch()
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

		fn fnMakeSpline pos1 pos2 sinkF:0 = 
		(
			local dir = normalize (pos2-pos1)
			local dist = (distance pos1 pos2)/2.0
			local pos = pos1 + dir * dist
			pos.z -= (dist*sinkF)
			local new_spline = splineShape ()
				addNewSpline new_spline
					addKnot new_spline 1 #smooth #curve pos1
						addKnot new_spline 1 #smooth #curve pos
					addKnot new_spline 1 #smooth #curve pos2
				updateshape new_spline
			return new_spline
		)

		on btnRegister pressed do
		(
			if (queryBox ("是否复制注册码到剪切板？                        ") title:"BsAnimMemoTools") do
			(
				getclipboardText()
				setclipboardText "E8C18FB749BA820E0525422425AFBED057AD5AEB7FE98E2F17C688B869B454"
				messageBox "复制成功,选中刀光点击注册粘贴即可(下面可创建)。                                   " title:"BsAnimMemoTools"
			)
		)

		on btnAbout pressed do 
		(
			shellLaunch "https://space.bilibili.com/2031113/channel/collectiondetail?sid=560782" ""
		)

		on tabBsADT Selected itm do
		(
			arrID = (itm.TabPageIndex + 1)
			if LastSubRollout != arrID do --避免点击重复
			(
				fnChangeToolsVisble arrID
			) 
		)
		
		on rolBsAnimDemoTools open do
		(
			fnInitDotTabs()
			fnChangeToolsVisble (tabBsADT.SelectedIndex + 1)
			fnRefreshInitValue()
		)

		on btnClose pressed do 
		(
			try (destroydialog rolBsAnimDemoTools) catch ()
		)

		on rolBsAnimDemoTools mbuttondown pos do 
		(
			try (destroydialog rolBsAnimDemoTools) catch ()
		)
		
		on rolBsAnimDemoTools lbuttondown posMou do
		(
			setSysCur #move
			offsetBsADT = posMou
			dragStateBsADT = on
		)
		
		on rolBsAnimDemoTools lbuttonup posMou do
		(
			dragStateBsADT = off
		)
		
		on rolBsAnimDemoTools mouseMove pos do
		(
			if dragStateBsADT == on then
			(
				SetDialogPos rolBsAnimDemoTools (mouse.screenpos - offsetBsADT)
			)
		)

		on chkCreateLine changed state do
		(
			chkCreateLine.state = true
			if selection.count == 2 then
			(
				local p1 = selection[1].pos
				local p2 = selection[2].pos
				local spline = fnMakeSpline p1 p2 sinkF:spnRadian.value
				local newName = "BsGhostTrails_" + spline.name
				spline.name = newName
				CenterPivot spline
				lc = Link_Constraint()
				spline.transform.controller = lc
				lc.key_mode = 0
				lc.addTarget selection[1] 0
				spline.showFrozenInGray = off
				spline.isfrozen = on

				select spline
			) 
			else 
			(
				messagebox "请先选择两个物体 (需要两点位置) ...             " title:"BsAnimDemoTools"
			)
		)
		
		on chkCreateTrail changed state do
		(
			chkCreateTrail.state = true
			if selection.count == 0 do (messagebox "请先创建并选择线...             " title:"BsAnimDemoTools")
			for i in selection where selection.count != 0 do 
			(
				if validModifier i GhostTrails then 
				(
					modPanel.addModToSelection (GhostTrails ()) ui:on
				)
			)
		)

		on btnDeleteTrail pressed do
		(
			undo "deleteGhostTrails" on
			(
				try(delete $'BsGhostTrails_*';messagebox "清除 GhostTrails 刀光相关物体成功!                      " title:"BsAnimDemoTools")catch()
			)
		)

		on btnSelectTrail pressed do
		(
			try(select $'BsGhostTrails_*';max modify mode)catch()
		)

		on btnHideTrail pressed do
		(
			try(hide $'BsGhostTrails_*')catch()
		)

		on btnShowTrail pressed do
		(
			try(unhide $'BsGhostTrails_*')catch()
		)

		on spnFrameToLag changed val do
		(
			try
			(
				$.modifiers[#GhostTrails].old_frames = val
			)catch()
		)

		on spnStartFrame changed val do
		(
			try
			(
				$.modifiers[#GhostTrails].startFrame = val*80
			)catch()
		)

		on spnEndFrame changed val do
		(
			try
			(
				$.modifiers[#GhostTrails].endFrame = val*80
			)catch()
		)

		on spnSegments changed val do
		(
			try
			(
				$.modifiers[#GhostTrails].segmentsperframe = val
			)catch()
		)

		on spnSplineSteps changed val do
		(
			try
			(
				$.modifiers[#GhostTrails].splineSteps = val
			)catch()
		)

		on spnURepeat changed val do
		(
			try
			(
				$.modifiers[#GhostTrails].pb_urepeat = val
			)catch()
		)

		on ckbFlipNormals changed state do
		(
			try
			(
				$.modifiers[#GhostTrails].flipNormals = state
			)catch()
		)

		on ckbGenerateMapping changed state do
		(
			try
			(
				$.modifiers[#GhostTrails].generateMap = state
			)catch()
		)

		on rdoTrailType changed id do
		(
			if id == 2 then
			(
				try
				(
					$.modifiers[#GhostTrails].movingorstill = 1
					spnFrameToLag.enabled = off
					ckbSetRange.enabled   = on
				)catch()
			)
			else
			(
				try
				(
					$.modifiers[#GhostTrails].movingorstill = 0
					spnFrameToLag.enabled = on
					ckbSetRange.enabled   = off
					spnStartFrame.enabled = off
					spnEndFrame.enabled   = off
				)catch()
			)
		)

		on ckbSetRange changed state do
		(
			if state then
			(
				spnStartFrame.enabled = on
				spnEndFrame.enabled   = on
			)
			else
			(
				spnStartFrame.enabled = off
				spnEndFrame.enabled   = off
			)
		)

		on btnMaterial pressed do
		(
			max mtledit
		)
	)
	createDialog rolBsAnimDemoTools style:#()
)