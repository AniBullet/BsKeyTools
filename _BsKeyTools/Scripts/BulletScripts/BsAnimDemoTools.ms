/*
 * @Description: Demo专用工具集
 * @Author: Bullet.S
 * @Date: 2024-04-03 10:58:49
 * @LastEditors: Bullet.S
 * @LastEditTime: 2024-04-03 20:31:08
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

		button btnClose "X" pos:[rolBsAnimDemoTools.width - 20,0] height:16 width:20
		label lblTitle "BsAnimDemoTools_v1.0" pos:[5,3]
		dotNetControl tabBsADT "System.Windows.Forms.TabControl" height:30 width:rolBsAnimDemoTools.width pos:[0,20] align:#center

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
	)

	createDialog rolBsAnimDemoTools style:#()
)