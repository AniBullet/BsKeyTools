/*
 * @Description: Demo专用工具集
 * @Author: Bullet.S
 * @Date: 2024-04-03 10:58:49
 * @LastEditors: Bullet.S
 * @LastEditTime: 2024-04-15 00:59:54
 * @Email: animator.bullet@foxmail.com
 */


try(destroyDialog rolBsAnimDemoTools )catch()

global rolBsAnimDemoTools
global offsetBsADT = [0,0]
global dragStateBsADT = off

(
	local LastSubRollout = 1
	
	rollout rolBsAnimDemoTools "" width:265 height:300
	(
		local dotColor = dotnetclass "System.Drawing.Color"

		button btnAbout "?" pos:[rolBsAnimDemoTools.width - 40,0] height:16 width:20
		button btnClose "X" pos:[rolBsAnimDemoTools.width - 20,0] height:16 width:20
		label lblTitle "BsAnimDemoTools_v1.0" pos:[5,3]
		dotNetControl tabBsADT "System.Windows.Forms.TabControl" height:30 width:rolBsAnimDemoTools.width pos:[0,20] align:#center

		------------------------------------------------------------------------------------------------------------------------------
		groupbox gpbTrail "GhostTrails" pos:[5,50] width:(rolBsAnimDemoTools.width - 10) height:75
		spinner spnRadian "弧度 " pos:[30,72] width:60 height:20 type:#float range:[-20,20,0] scale:0.1
		checkbutton chkCreateLine "1.创建线" pos:[100,70] width:75 height:20 checked:true
		button btnDeleteLine "删除线" pos:[180,70] width:75 height:20
		button btnHideTrail "隐藏" pos:[15,95] width:35 height:20
		button btnShowTrail "显示" pos:[55,95] width:35 height:20 
		checkbutton chkCreateTrail "2.创建刀光" pos:[100,95] width:75 height:20 checked:true
		button btnDeleteTrail "清除线和刀光" pos:[180,95] width:75 height:20
		------------------------------------------------------------------------------------------------------------------------------

		dotnetcontrol lblTips "Label" text:"2024.4 [ Bullet.S ] ✨        动画师 Demo 简易环境" pos:[0,283] width:rolBsAnimDemoTools.width height:16

		local arrGhostTrails = #("刀光",#())
		local arrDemoScene = #("场景",#()) 
		local arrDemoLight = #("灯光",#())
		local arrDemoMat = #("材质",#())
		local arrAllToolsTab = #(arrGhostTrails,arrDemoScene,arrDemoLight,arrDemoMat)
	
		fn fnInitDotTabs =
		(
			lblTips.font       = dotnetobject "System.Drawing.Font" "Roboto" 8
			lblTips.TextAlign  = (dotnetclass "system.drawing.contentalignment").MiddleCenter
			lblTips.BackColor  = (dotColor.FromArgb	255 250 250)
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
				
				lc = Link_Constraint()
				spline.transform.controller = lc
				lc.key_mode = 0
				lc.addTarget selection[1] 0
				spline.showFrozenInGray = off

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

		on btnHideTrail pressed do
		(
			try(hide $'BsGhostTrails_*')catch()
		)

		on btnShowTrail pressed do
		(
			try(unhide $'BsGhostTrails_*')catch()
		)
	)
	createDialog rolBsAnimDemoTools style:#()
)