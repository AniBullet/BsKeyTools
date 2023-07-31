/**************************************************************************************************************************
-- By Bullet.S 自用修改版,功能大集合,完全开源免费仅供学习使用,请勿用于商业用途,否则后果自负    
Reference： SoxBipedAssist_v0.423 & Biped Helper v3.1  
Since 2023.03
**************************************************************************************************************************/

global rolBsBipedTools		-- 롤아웃명을 글로벌 변수로 인식하기 위해 초기에 한 번 사용
global posBsBipedTools
global dragBsBipedTools = false
global arrAllBipedCom
global iniBsBipedTools = execute ("@\"" + (getDir #maxData) + "\\BsBipedToolsConfig.ini\"")  --配置文件路径
global iniBsBTPos
global rolBsAboutPanel
global offsetBsAboutPanel = [0,0]
global stateBsAboutPanel = 0
global dotLinkLabel1
global dotLinkLabel2
global verBsBipedTools = "v1.2"

try(destroydialog rolBsBipedTools) catch()		-- 혹시 열려있는 창이 있으면 강제 종료
try(destroyDialog rolBSLeftHandPivots)catch()
try(destroyDialog rolBSRightHandPivots)catch()
try(destroyDialog rolBSLeftFootPivots)catch()
try(destroyDialog rolBSRightFootPivots)catch()
try(rolBsAboutPanel.close())catch()

fn fnCloseBsAboutForm dotObject evnt =
(
	try(rolBsAboutPanel.close())catch()
)

fn fnOpenAboutPanel =
(
	strHelp = \
"“减少卡顿，便捷K帧”

小圆点：Motion 面板开关，极大减少骨骼选取卡顿
左键禁用，右键启用，未显示请右键慢速点击直到显示

禅模式：切换最大化视窗，聊胜于无
XRay/Box模式：切换XRay/Box显示，很常用

【主功能】
（Checkbutton 原因无法双击，不是不想做~）
左键单击：直接选取   ||   右键单击：选择镜像骨骼
Ctrl + 左击：加选   ||   Alt + 左击：减选
Shift + 左击：选择骨骼及其所有子级
Ctrl + Alt + 左击：骨骼旋转归零
帧相关按钮注意悬停 Tips，比原功能更多，
左击 / 右击 / Ctrl / Shift，都有不同便捷功能。

【辅助功能】
Copy paste Tools，Layer Tools (Biped)，
Loop Key Tools，Others Tools"
    rolBsAboutPanel = dotNetObject "MaxCustomControls.MaxForm"
    dotBtnClose = dotNetObject "System.Windows.Forms.Button"
	fontTitle = dotNetObject "System.Drawing.Font" "comic sans ms" 11 (dotNetClass "System.Drawing.FontStyle").Bold
	fontHelp = dotNetObject "System.Drawing.Font" "comic sans ms" 9 (dotNetClass "System.Drawing.FontStyle").Regular
    -- dotBtnClose
    dotBtnClose.BackColor = (dotNetClass "System.Drawing.Color").Black
    dotBtnClose.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat
    dotBtnClose.ForeColor = (dotNetClass "System.Drawing.Color").AliceBlue
    dotBtnClose.Location = dotNetObject "System.Drawing.Point" 335 400
    dotBtnClose.Name = "dotBtnClose"
    dotBtnClose.Size = dotNetObject "System.Drawing.Size" 60 45
    dotBtnClose.TabIndex = 0
    dotBtnClose.Text = "Close"
    dotBtnClose.UseVisualStyleBackColor = False
	dotBtnClose.font = fontTitle
	-- label
	dotLabel = dotnetobject "System.Windows.Forms.label"
	dotLabel.autosize = true
	dotLabel.ForeColor = (dotNetClass "System.Drawing.Color").black
	dotLabel.text = "BsBipedTools_" + verBsBipedTools
	dotLabel.font = fontTitle
	dotLabel.Location = dotNetObject "System.Drawing.Point" 5 5
	dotHelpLabel = dotnetobject "System.Windows.Forms.label"
	dotHelpLabel.autosize = true
	dotHelpLabel.text = strHelp
	dotHelpLabel.font = fontHelp
	dotHelpLabel.Location = dotNetObject "System.Drawing.Point" 5 40
	-- link1
	dotLinkLabel1 = dotnetobject "System.Windows.Forms.LinkLabel"
	dotLinkLabel1.autosize = true
	dotLinkLabel1.text = "Bullet.S: Help Docs || aniBullet Homepage"
	dotLinkLabel1.font = fontTitle
	dotLinkLabel1.Location = dotNetObject "System.Drawing.Point" 0 50
	dotLinkLabel1.links.add 10 9 "https://anibullet.github.io/"
	dotLinkLabel1.links.add 23 18 "https://www.anibullet.com/"
	dotLinkLabel1.Dock = dotLinkLabel1.Dock.bottom
	dotLinkLabel2 = dotnetobject "System.Windows.Forms.LinkLabel"
	dotLinkLabel2.autosize = true
	dotLinkLabel2.text = "References: SoxBipedAssist || BipedHelper"
	dotLinkLabel2.font = fontTitle
	dotLinkLabel2.Location = dotNetObject "System.Drawing.Point" 0 50
	dotLinkLabel2.links.add 12 14 "http://cafe.naver.com/pinksox/6131"
	dotLinkLabel2.links.add 30 11 "https://sites.google.com/view/lbtools-guide/home/biped-helper"
	dotLinkLabel2.Dock = dotLinkLabel2.Dock.bottom
    -- rolBsAboutPanel
    rolBsAboutPanel.BackColor = (dotNetClass "System.Drawing.Color").LightPink
    rolBsAboutPanel.ClientSize = dotNetObject "System.Drawing.Size" 400 450
    rolBsAboutPanel.Controls.Add(dotBtnClose)
	rolBsAboutPanel.Controls.Add(dotLabel)
	rolBsAboutPanel.Controls.Add(dotHelpLabel)
	rolBsAboutPanel.Controls.Add(dotLinkLabel1)
	rolBsAboutPanel.Controls.Add(dotLinkLabel2)
    rolBsAboutPanel.FormBorderStyle = (dotNetClass "System.Windows.Forms.FormBorderStyle").SizableToolWindow
    rolBsAboutPanel.Name = "rolBsAboutPanel"
    rolBsAboutPanel.Opacity = 0.75
    rolBsAboutPanel.ShowIcon = False
    rolBsAboutPanel.StartPosition = (dotNetClass "System.Windows.Forms.FormStartPosition").Manual
	rolBsAboutPanel.Location = dotNetObject "System.Drawing.Point" (iniBsBTPos[1] as integer - rolBsAboutPanel.width) (iniBsBTPos[2] as integer)
    rolBsAboutPanel.Text = "rolBsAboutPanel"
    rolBsAboutPanel.TransparencyKey = (dotNetClass "System.Drawing.Color").LightPink
    rolBsAboutPanel.FormBorderStyle = (dotNetClass "System.Windows.Forms.FormBorderStyle").None
	rolBsAboutPanel.font = Font
	thePtr = DotNetObject "System.IntPtr" (windows.getMAXHWND())
	theHwnd = DotNetObject "MaxCustomControls.Win32HandleWrapper" thePtr
	rolBsAboutPanel.Show(theHwnd)

    fn fnMouseDown dotObject evnt =
    (
        offsetBsAboutPanel[1] = mouse.screenPos.x - rolBsAboutPanel.left
        offsetBsAboutPanel[2] = mouse.screenPos.y - rolBsAboutPanel.top
        global stateBsAboutPanel=1
    )
    dotnet.addEventHandler rolBsAboutPanel "MouseDown" fnMouseDown

    fn fnMouseMove dotObject evnt =
    (
        if stateBsAboutPanel==1 then
        (
            local FormPos = #()
            local NewPos = #()  
            FormPos[1] = rolBsAboutPanel.left
            FormPos[2] = rolBsAboutPanel.top
                
            NewPos[1] = mouse.screenpos.x - offsetBsAboutPanel[1]
            NewPos[2] = mouse.screenpos.y - offsetBsAboutPanel[2]
            
            rolBsAboutPanel.left = NewPos[1]
            rolBsAboutPanel.top = NewPos[2]
        )
    )
    dotnet.addEventHandler rolBsAboutPanel "MouseMove" fnMouseMove

    fn fnMouseUp dotObject evnt =
    (
        global stateBsAboutPanel=0
    )
    dotnet.addEventHandler rolBsAboutPanel "MouseUp" fnMouseUp

    dotnet.addEventHandler dotBtnClose "MouseDown" fnCloseBsAboutForm

	fn fnSoxBipedAssistLink s e = 
	(
		s.links.item[s.links.IndexOf e.link].Visited = on
		(dotnetclass "System.Diagnostics.Process").Start e.link.LinkData		
	)
	dotnet.addEventHandler dotLinkLabel1 "LinkClicked" fnSoxBipedAssistLink
	dotnet.addEventHandler dotLinkLabel2 "LinkClicked" fnSoxBipedAssistLink
)

fn f_getPivotIndex ctrl =
(
	if ctrl.keys.count > 0 then
	(
		local keyIndex = getKeyIndex ctrl slidertime
		if keyIndex > 0 then
		(
			local key = biped.getKey ctrl keyIndex
			if key.ikSpace > 0 then
			(
				return (biped.getKey ctrl keyIndex).ikPivotIndex
			)
		)
	)
	return 0	
)

fn f_changePivot ctrl index =
(
	if ctrl.keys.count > 0 then
	(
		local keyIndex = getKeyIndex ctrl slidertime
		if keyIndex > 0 then
		(
			local key = biped.getKey ctrl keyIndex
			if key.ikSpace > 0 then
			(
				key.ikPivotIndex = index
				return true
			)
			else
			(
				messagebox "错误：必须是固定帧或滑动帧。                       " title:"选择 Pivots"
			)
		)
		else
		(
			messagebox "错误：当前时间滑块没有帧。                        " title:"选择 Pivots"
		)
	)
	else
	(
		messagebox "错误：找不到帧。\r\n设置一个固定帧或滑动帧。                             " title:"选择 Pivots"
	)
	
	return false
)

rollout rolBSLeftHandPivots "L-Hand" width:90
(
	local lrg = 16
	local sml = 12

	checkbutton chkbtn_pinkyTip "" across:4 width:sml height:sml align:#left offset:[-8,0] tooltip:"pinky tip"
	checkbutton chkbtn_ringTip "" width:sml height:sml offset:[-8,0] tooltip:"ring tip"
	checkbutton chkbtn_middleTip "" width:sml height:sml offset:[-8,0] tooltip:"middle tip"
	checkbutton chkbtn_indexTip "" width:sml height:sml offset:[-8,0] tooltip:"index tip"
	
	checkbutton chkbtn_pinky2 "" width:sml height:sml across:4 align:#left offset:[-8,0] tooltip:"pinky 2"
	checkbutton chkbtn_ring2 "" width:sml height:sml offset:[-8,0] tooltip:"ring 2"
	checkbutton chkbtn_middle2 "" width:sml height:sml offset:[-8,0] tooltip:"middle 2"
	checkbutton chkbtn_index2 "" width:sml height:sml offset:[-8,0] tooltip:"index 2"
	
	checkbutton chkbtn_pinky1 "" width:sml height:sml across:4 align:#left offset:[-8,0] tooltip:"pinky 1"
	checkbutton chkbtn_ring1 "" width:sml height:sml offset:[-8,0] tooltip:"ring 1"
	checkbutton chkbtn_middle1 "" width:sml height:sml offset:[-8,0] tooltip:"middle 1"
	checkbutton chkbtn_index1 "" width:sml height:sml offset:[-8,0] tooltip:"index 1"
	
	checkbutton chkbtn_palmFront "" width:lrg height:lrg across:3 align:#left offset:[-8,0] tooltip:"palm front"
	checkbutton chkbtn_palmMiddle "" width:lrg height:lrg offset:[-9,0] tooltip:"palm middle"
	checkbutton chkbtn_palmBack "" width:lrg height:lrg offset:[-8,0] tooltip:"palm back"
	
	checkbutton chkbtn_wristFront "" width:lrg height:lrg across:3 align:#left offset:[-8,0] tooltip:"wrist front"
	checkbutton chkbtn_wristMiddle "" width:lrg height:lrg offset:[-9,0] tooltip:"wrist middle"
	checkbutton chkbtn_wristBack "" width:lrg height:lrg offset:[-8,0] tooltip:"wrist back"
	
	checkbutton chkbtn_wristCenter "" width:lrg height:lrg align:#left offset:[14,0] tooltip:"wrist center"
	
	checkbutton chkbtn_thumbTip "" width:sml height:sml align:#right offset:[7,-92] tooltip:"thumb tip"
	checkbutton chkbtn_thumb2 "" width:sml height:sml align:#right offset:[7,0] tooltip:"thumb 2"
	checkbutton chkbtn_thumb1 "" width:sml height:sml align:#right offset:[7,0] tooltip:"thumb 1"
	
	fn f_uncheckAll =
	(
		chkbtn_wristCenter.checked = false
		chkbtn_wristFront.checked = false
		chkbtn_wristMiddle.checked = false
		chkbtn_wristBack.checked = false
		chkbtn_palmFront.checked = false
		chkbtn_palmMiddle.checked = false
		chkbtn_palmBack.checked = false
		chkbtn_thumb1.checked = false
		chkbtn_thumb2.checked = false
		chkbtn_thumbTip.checked = false
		chkbtn_index1.checked = false
		chkbtn_index2.checked = false
		chkbtn_indexTip.checked = false
		chkbtn_middle1.checked = false
		chkbtn_middle2.checked = false
		chkbtn_middleTip.checked = false
		chkbtn_ring1.checked = false
		chkbtn_ring2.checked = false
		chkbtn_ringTip.checked = false
		chkbtn_pinky1.checked = false
		chkbtn_pinky2.checked = false
		chkbtn_pinkyTip.checked = false
	)
	
	fn f_updateButton state chkbtn index =
	(
		f_uncheckAll();
		if state then
		(
			if (f_changePivot rolBsBipedTools.m_LHand[1].controller index) then
			(
				chkbtn.checked = true
			)
		)
		else
		(
			if (f_getPivotIndex rolBsBipedTools.m_LHand[1].controller) > 0 then
			(
				chkbtn.checked = true
			)
		)
	)
	
	on rolBSLeftHandPivots open do
	(
		case (f_getPivotIndex rolBsBipedTools.m_LHand[1].controller) of
		(
			1: chkbtn_wristCenter.checked = true
			2: chkbtn_wristFront.checked = true
			3: chkbtn_wristMiddle.checked = true
			4: chkbtn_wristBack.checked = true
			5: chkbtn_palmFront.checked = true
			6: chkbtn_palmMiddle.checked = true
			7: chkbtn_palmBack.checked = true
			8: chkbtn_thumb1.checked = true
			9: chkbtn_thumb2.checked = true
			10: chkbtn_thumbTip.checked = true
			11: chkbtn_index1.checked = true
			12: chkbtn_index2.checked = true
			13: chkbtn_indexTip.checked = true
			14: chkbtn_middle1.checked = true
			15: chkbtn_middle2.checked = true
			16: chkbtn_middleTip.checked = true
			17: chkbtn_ring1.checked = true
			18: chkbtn_ring2.checked = true
			19: chkbtn_ringTip.checked = true
			20: chkbtn_pinky1.checked = true
			21: chkbtn_pinky2.checked = true
			22: chkbtn_pinkyTip.checked = true
			default: f_uncheckAll()
		)
	)
	
	on rolBSLeftHandPivots close do
	(
		
	)
	
	on chkbtn_wristCenter changed state do (f_updateButton state chkbtn_wristCenter 1)
	on chkbtn_wristFront changed state do (f_updateButton state chkbtn_wristFront 2)
	on chkbtn_wristMiddle changed state do (f_updateButton state chkbtn_wristMiddle 3)
	on chkbtn_wristBack changed state do (f_updateButton state chkbtn_wristBack 4)
	on chkbtn_palmFront changed state do (f_updateButton state chkbtn_palmFront 5)
	on chkbtn_palmMiddle changed state do (f_updateButton state chkbtn_palmMiddle 6)
	on chkbtn_palmBack changed state do (f_updateButton state chkbtn_palmBack 7)
	on chkbtn_thumb1 changed state do (f_updateButton state chkbtn_thumb1 8)
	on chkbtn_thumb2 changed state do (f_updateButton state chkbtn_thumb2 9)
	on chkbtn_thumbTip changed state do (f_updateButton state chkbtn_thumbTip 10)
	on chkbtn_index1 changed state do (f_updateButton state chkbtn_index1 11)
	on chkbtn_index2 changed state do (f_updateButton state chkbtn_index2 12)
	on chkbtn_indexTip changed state do (f_updateButton state chkbtn_indexTip 13)
	on chkbtn_middle1 changed state do (f_updateButton state chkbtn_middle1 14)
	on chkbtn_middle2 changed state do (f_updateButton state chkbtn_middle2 15)
	on chkbtn_middleTip changed state do (f_updateButton state chkbtn_middleTip 16)
	on chkbtn_ring1 changed state do (f_updateButton state chkbtn_ring1 17)
	on chkbtn_ring2 changed state do (f_updateButton state chkbtn_ring2 18)
	on chkbtn_ringTip changed state do (f_updateButton state chkbtn_ringTip 19)
	on chkbtn_pinky1 changed state do (f_updateButton state chkbtn_pinky1 20)
	on chkbtn_pinky2 changed state do (f_updateButton state chkbtn_pinky2 21)
	on chkbtn_pinkyTip changed state do (f_updateButton state chkbtn_pinkyTip 22)
) --// end rollout

rollout rolBSRightHandPivots "R-Hand" width:90
(
	local lrg = 16
	local sml = 12
	
	checkbutton chkbtn_indexTip "" across:4 width:sml height:sml align:#right offset:[8,0] tooltip:"index tip"
	checkbutton chkbtn_middleTip "" width:sml height:sml offset:[12,0] tooltip:"middle tip"
	checkbutton chkbtn_ringTip "" width:sml height:sml offset:[12,0] tooltip:"ring tip"
	checkbutton chkbtn_pinkyTip "" width:sml height:sml offset:[12,0] tooltip:"pinky tip"

	checkbutton chkbtn_index2 "" width:sml height:sml across:4 align:#right offset:[8,0] tooltip:"index 2"
	checkbutton chkbtn_middle2 "" width:sml height:sml offset:[12,0] tooltip:"middle 2"
	checkbutton chkbtn_ring2 "" width:sml height:sml offset:[12,0] tooltip:"ring 2"
	checkbutton chkbtn_pinky2 "" width:sml height:sml offset:[12,0] tooltip:"pinky 2"
	
	checkbutton chkbtn_index1 "" width:sml height:sml across:4 align:#right offset:[8,0] tooltip:"index 1"
	checkbutton chkbtn_middle1 "" width:sml height:sml offset:[12,0] tooltip:"middle 1"
	checkbutton chkbtn_ring1 "" width:sml height:sml offset:[12,0] tooltip:"ring 1"
	checkbutton chkbtn_pinky1 "" width:sml height:sml offset:[12,0] tooltip:"pinky 1"

	checkbutton chkbtn_palmFront "" width:lrg height:lrg across:3 align:#right offset:[7,0] tooltip:"palm front"
	checkbutton chkbtn_palmMiddle "" width:lrg height:lrg offset:[11,0] tooltip:"palm middle"
	checkbutton chkbtn_palmBack "" width:lrg height:lrg offset:[12,0] tooltip:"palm back"		

	checkbutton chkbtn_wristFront "" width:lrg height:lrg across:3 align:#right offset:[7,0] tooltip:"wrist front"
	checkbutton chkbtn_wristMiddle "" width:lrg height:lrg offset:[11,0] tooltip:"wrist middle"
	checkbutton chkbtn_wristBack "" width:lrg height:lrg offset:[12,0] tooltip:"wrist back"
	
	checkbutton chkbtn_wristCenter "" width:lrg height:lrg align:#right offset:[-14,0] tooltip:"wrist center"
	
	checkbutton chkbtn_thumbTip "" width:sml height:sml align:#right offset:[-58,-92] tooltip:"thumb tip"
	checkbutton chkbtn_thumb2 "" width:sml height:sml align:#right offset:[-58,0] tooltip:"thumb 2"
	checkbutton chkbtn_thumb1 "" width:sml height:sml align:#right offset:[-58,0] tooltip:"thumb 1"
		
	fn f_uncheckAll =
	(
		chkbtn_wristCenter.checked = false
		chkbtn_wristFront.checked = false
		chkbtn_wristMiddle.checked = false
		chkbtn_wristBack.checked = false
		chkbtn_palmFront.checked = false
		chkbtn_palmMiddle.checked = false
		chkbtn_palmBack.checked = false
		chkbtn_thumb1.checked = false
		chkbtn_thumb2.checked = false
		chkbtn_thumbTip.checked = false
		chkbtn_index1.checked = false
		chkbtn_index2.checked = false
		chkbtn_indexTip.checked = false
		chkbtn_middle1.checked = false
		chkbtn_middle2.checked = false
		chkbtn_middleTip.checked = false
		chkbtn_ring1.checked = false
		chkbtn_ring2.checked = false
		chkbtn_ringTip.checked = false
		chkbtn_pinky1.checked = false
		chkbtn_pinky2.checked = false
		chkbtn_pinkyTip.checked = false
	)
	
	fn f_updateButton state chkbtn index =
	(
		f_uncheckAll();
		if state then
		(
			if (f_changePivot rolBsBipedTools.m_RHand[1].controller index) then
			(
				chkbtn.checked = true
			)
		)
		else
		(
			if (f_getPivotIndex rolBsBipedTools.m_RHand[1].controller) > 0 then
			(
				chkbtn.checked = true
			)
		)
	)

	on rolBSRightHandPivots open do
	(
		case (f_getPivotIndex rolBsBipedTools.m_RHand[1].controller) of
		(
			1: chkbtn_wristCenter.checked = true
			2: chkbtn_wristFront.checked = true
			3: chkbtn_wristMiddle.checked = true
			4: chkbtn_wristBack.checked = true
			5: chkbtn_palmFront.checked = true
			6: chkbtn_palmMiddle.checked = true
			7: chkbtn_palmBack.checked = true
			8: chkbtn_thumb1.checked = true
			9: chkbtn_thumb2.checked = true
			10: chkbtn_thumbTip.checked = true
			11: chkbtn_index1.checked = true
			12: chkbtn_index2.checked = true
			13: chkbtn_indexTip.checked = true
			14: chkbtn_middle1.checked = true
			15: chkbtn_middle2.checked = true
			16: chkbtn_middleTip.checked = true
			17: chkbtn_ring1.checked = true
			18: chkbtn_ring2.checked = true
			19: chkbtn_ringTip.checked = true
			20: chkbtn_pinky1.checked = true
			21: chkbtn_pinky2.checked = true
			22: chkbtn_pinkyTip.checked = true
			default: f_uncheckAll()
		)
	)
	
	on rolBSRightHandPivots close do
	(
		
	)
	
	on chkbtn_wristCenter changed state do (f_updateButton state chkbtn_wristCenter 1)
	on chkbtn_wristFront changed state do (f_updateButton state chkbtn_wristFront 2)
	on chkbtn_wristMiddle changed state do (f_updateButton state chkbtn_wristMiddle 3)
	on chkbtn_wristBack changed state do (f_updateButton state chkbtn_wristBack 4)
	on chkbtn_palmFront changed state do (f_updateButton state chkbtn_palmFront 5)
	on chkbtn_palmMiddle changed state do (f_updateButton state chkbtn_palmMiddle 6)
	on chkbtn_palmBack changed state do (f_updateButton state chkbtn_palmBack 7)
	on chkbtn_thumb1 changed state do (f_updateButton state chkbtn_thumb1 8)
	on chkbtn_thumb2 changed state do (f_updateButton state chkbtn_thumb2 9)
	on chkbtn_thumbTip changed state do (f_updateButton state chkbtn_thumbTip 10)
	on chkbtn_index1 changed state do (f_updateButton state chkbtn_index1 11)
	on chkbtn_index2 changed state do (f_updateButton state chkbtn_index2 12)
	on chkbtn_indexTip changed state do (f_updateButton state chkbtn_indexTip 13)
	on chkbtn_middle1 changed state do (f_updateButton state chkbtn_middle1 14)
	on chkbtn_middle2 changed state do (f_updateButton state chkbtn_middle2 15)
	on chkbtn_middleTip changed state do (f_updateButton state chkbtn_middleTip 16)
	on chkbtn_ring1 changed state do (f_updateButton state chkbtn_ring1 17)
	on chkbtn_ring2 changed state do (f_updateButton state chkbtn_ring2 18)
	on chkbtn_ringTip changed state do (f_updateButton state chkbtn_ringTip 19)
	on chkbtn_pinky1 changed state do (f_updateButton state chkbtn_pinky1 20)
	on chkbtn_pinky2 changed state do (f_updateButton state chkbtn_pinky2 21)
	on chkbtn_pinkyTip changed state do (f_updateButton state chkbtn_pinkyTip 22)
) --// end rollout

rollout rolBSLeftFootPivots "L-Foot" width:90
(
	local lrg = 16

	checkbutton chkbtn_frontLeft "" across:3 width:lrg height:lrg align:#left offset:[0,0] tooltip:"front left"
	checkbutton chkbtn_frontMiddle "" width:lrg height:lrg offset:[0,0] tooltip:"front middle"
	checkbutton chkbtn_frontRight "" width:lrg height:lrg offset:[3,0] tooltip:"front right"
	checkbutton chkbtn_ankle "" width:lrg height:lrg align:#left offset:[13,0] tooltip:"ankle"
	checkbutton chkbtn_backLeft "" across:3 width:lrg height:lrg align:#left offset:[0,0] tooltip:"back left"
	checkbutton chkbtn_backMiddle "" width:lrg height:lrg offset:[0,0] tooltip:"back middle"
	checkbutton chkbtn_backRight "" width:lrg height:lrg offset:[3,0] tooltip:"back right"

	fn f_uncheckAll =
	(
		chkbtn_ankle.checked = false
		chkbtn_backLeft.checked = false
		chkbtn_backMiddle.checked = false
		chkbtn_backRight.checked = false
		chkbtn_frontLeft.checked = false
		chkbtn_frontMiddle.checked = false
		chkbtn_frontRight.checked = false
	)
	
	fn f_updateButton state chkbtn index =
	(
		f_uncheckAll();
		if state then
		(
			if (f_changePivot rolBsBipedTools.m_LFoot[1].controller index) then
			(
				chkbtn.checked = true
			)
		)
		else
		(
			if (f_getPivotIndex rolBsBipedTools.m_LFoot[1].controller) > 0 then
			(
				chkbtn.checked = true
			)
		)
	)

	on rolBSLeftFootPivots open do
	(
		case (f_getPivotIndex rolBsBipedTools.m_LFoot[1].controller) of
		(
			1: chkbtn_ankle.checked = true
			2: chkbtn_backLeft.checked = true
			3: chkbtn_backMiddle.checked = true
			4: chkbtn_backRight.checked = true
			5: chkbtn_frontLeft.checked = true
			6: chkbtn_frontMiddle.checked = true
			7: chkbtn_frontRight.checked = true
			default: f_uncheckAll()
		)
	)
	
	on rolBSLeftFootPivots close do
	(
		
	)
	
	on chkbtn_ankle changed state do (f_updateButton state chkbtn_ankle 1)
	on chkbtn_backLeft changed state do (f_updateButton state chkbtn_backLeft 2)
	on chkbtn_backMiddle changed state do (f_updateButton state chkbtn_backMiddle 3)
	on chkbtn_backRight changed state do (f_updateButton state chkbtn_backRight 4)
	on chkbtn_frontLeft changed state do (f_updateButton state chkbtn_frontLeft 5)
	on chkbtn_frontMiddle changed state do (f_updateButton state chkbtn_frontMiddle 6)
	on chkbtn_frontRight changed state do (f_updateButton state chkbtn_frontRight 7)	
) --// end rollout

rollout rolBSRightFootPivots "R-Foot" width:90
(
	local lrg = 16

	checkbutton chkbtn_frontLeft "" across:3 width:lrg height:lrg align:#left offset:[0,0] tooltip:"front left"
	checkbutton chkbtn_frontMiddle "" width:lrg height:lrg offset:[0,0] tooltip:"front middle"
	checkbutton chkbtn_frontRight "" width:lrg height:lrg offset:[3,0] tooltip:"front right"
	checkbutton chkbtn_ankle "" width:lrg height:lrg align:#left offset:[39,0] tooltip:"ankle"
	checkbutton chkbtn_backLeft "" across:3 width:lrg height:lrg align:#left offset:[0,0] tooltip:"back left"
	checkbutton chkbtn_backMiddle "" width:lrg height:lrg offset:[0,0] tooltip:"back middle"
	checkbutton chkbtn_backRight "" width:lrg height:lrg offset:[3,0] tooltip:"back right"

	fn f_uncheckAll =
	(
		chkbtn_ankle.checked = false
		chkbtn_backLeft.checked = false
		chkbtn_backMiddle.checked = false
		chkbtn_backRight.checked = false
		chkbtn_frontLeft.checked = false
		chkbtn_frontMiddle.checked = false
		chkbtn_frontRight.checked = false
	)
	
	fn f_updateButton state chkbtn index =
	(
		f_uncheckAll();
		if state then
		(
			if (f_changePivot rolBsBipedTools.m_RFoot[1].controller index) then
			(
				chkbtn.checked = true
			)
		)
		else
		(
			if (f_getPivotIndex rolBsBipedTools.m_RFoot[1].controller) > 0 then
			(
				chkbtn.checked = true
			)
		)
	)

	on rolBSRightFootPivots open do
	(
		case (f_getPivotIndex rolBsBipedTools.m_RFoot[1].controller) of
		(
			1: chkbtn_ankle.checked = true
			2: chkbtn_backLeft.checked = true
			3: chkbtn_backMiddle.checked = true
			4: chkbtn_backRight.checked = true
			5: chkbtn_frontLeft.checked = true
			6: chkbtn_frontMiddle.checked = true
			7: chkbtn_frontRight.checked = true
			default: f_uncheckAll()
		)
	)
	
	on rolBSRightFootPivots close do
	(
		
	)
	
	on chkbtn_ankle changed state do (f_updateButton state chkbtn_ankle 1)
	on chkbtn_backLeft changed state do (f_updateButton state chkbtn_backLeft 2)
	on chkbtn_backMiddle changed state do (f_updateButton state chkbtn_backMiddle 3)
	on chkbtn_backRight changed state do (f_updateButton state chkbtn_backRight 4)
	on chkbtn_frontLeft changed state do (f_updateButton state chkbtn_frontLeft 5)
	on chkbtn_frontMiddle changed state do (f_updateButton state chkbtn_frontMiddle 6)
	on chkbtn_frontRight changed state do (f_updateButton state chkbtn_frontRight 7)
) --// end rollout

rollout rolBSFingers "Fingers" width:220 height:160
(
	checkbutton chbRFingers "Right" pos:[32,130] highlightColor:rolBsBipedTools.mcRight checked:true
	checkbutton chbLFingers "Left" pos:[148,130] highlightColor:rolBsBipedTools.mcLeft checked:true
	
	--R Index Finger
	button select_rhand1_btn "RHand"	enabled:true pos:[20,80] width:60 height:40 images:#(Bitmap 60 40 color:(color 5 173 5 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:"选择所有右手手指"
	button select_rfing11_btn "RHand"	enabled:true pos:[(select_rhand1_btn.pos.x)+45,(select_rhand1_btn.pos.y)-22]		width:15 height:22 images:#(Bitmap 15 22 color:(color 135 160 8 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_rfing12_btn "RHand"	enabled:true pos:[(select_rfing11_btn.pos.x)+0,(select_rfing11_btn.pos.y)-21]	width:15 height:20 images:#(Bitmap 15 20 color:(color 135 160 8 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_rfing13_btn "RHand"	enabled:true pos:[(select_rfing12_btn.pos.x)+0,(select_rfing12_btn.pos.y)-18]	width:15 height:17 images:#(Bitmap 15 17 color:(color 135 160 8 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""

	--R Middle Finger
	button select_rfing21_btn "RHand"	enabled:true pos:[(select_rhand1_btn.pos.x)+30,(select_rhand1_btn.pos.y)-23]		width:15 height:23 images:#(Bitmap 15 23 color:(color 135 160 8 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_rfing22_btn "RHand"	enabled:true pos:[(select_rfing21_btn.pos.x)+0,(select_rfing21_btn.pos.y)-23]	width:15 height:23 images:#(Bitmap 15 23 color:(color 135 160 8 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_rfing23_btn "RHand"	enabled:true pos:[(select_rfing22_btn.pos.x)+0,(select_rfing22_btn.pos.y)-20]	width:15 height:20 images:#(Bitmap 15 20 color:(color 135 160 8 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) ttoolTip:""
	
	--R Ring Finger
	button select_rfing31_btn "RHand"	enabled:true pos:[(select_rhand1_btn.pos.x)+15,(select_rhand1_btn.pos.y)-22]		width:15 height:22 images:#(Bitmap 15 22 color:(color 135 160 8 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_rfing32_btn "RHand"	enabled:true pos:[(select_rfing31_btn.pos.x)+0,(select_rfing31_btn.pos.y)-21]	width:15 height:20 images:#(Bitmap 15 20 color:(color 135 160 8 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_rfing33_btn "RHand"	enabled:true pos:[(select_rfing32_btn.pos.x)+0,(select_rfing32_btn.pos.y)-18]	width:15 height:17 images:#(Bitmap 15 17 color:(color 135 160 8 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	
	--R Pinkie Finger
	button select_rfing41_btn "RHand"	enabled:true pos:[(select_rhand1_btn.pos.x)+0,(select_rhand1_btn.pos.y)-20]		width:15 height:20 images:#(Bitmap 15 20 color:(color 135 160 8 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_rfing42_btn "RHand"	enabled:true pos:[(select_rfing41_btn.pos.x)+0,(select_rfing41_btn.pos.y)-18]	width:15 height:17 images:#(Bitmap 15 17 color:(color 135 160 8 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_rfing43_btn "RHand"	enabled:true pos:[(select_rfing42_btn.pos.x)+0,(select_rfing42_btn.pos.y)-16]	width:15 height:16 images:#(Bitmap 15 16 color:(color 135 160 8 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	
	--R Thumb
	button select_rthumb1_btn "RHand"	enabled:true pos:[(select_rhand1_btn.pos.x)+60,(select_rhand1_btn.pos.y)]		width:20 height:30 images:#(Bitmap 20 30 color:(color 224 198 87 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_rthumb2_btn "RHand"	enabled:true pos:[(select_rthumb1_btn.pos.x)+2,(select_rthumb1_btn.pos.y)-20]		width:18 height:19 images:#(Bitmap 18 19 color:(color 224 198 87 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_rthumb3_btn "RHand"	enabled:true pos:[(select_rthumb2_btn.pos.x)+2,(select_rthumb2_btn.pos.y)-18]		width:16 height:18 images:#(Bitmap 16 18 color:(color 224 198 87 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""

	--LEFT HAND
	--L Index Finger
	button select_lhand1_btn "LHand"	enabled:true pos:[140,80] width:60 height:40 images:#(Bitmap 60 40 color:(color 18 18 167 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:"选择所有左手手指"
	button select_lfing11_btn "LHand"	enabled:true pos:[(select_lhand1_btn.pos.x)+0,(select_lhand1_btn.pos.y)-22]		width:15 height:22 images:#(Bitmap 15 22 color:(color 187 9 208 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_lfing12_btn "LHand"	enabled:true pos:[(select_lfing11_btn.pos.x)+0,(select_lfing11_btn.pos.y)-21]	width:15 height:20 images:#(Bitmap 15 20 color:(color 187 9 208 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_lfing13_btn "LHand"	enabled:true pos:[(select_lfing12_btn.pos.x)+0,(select_lfing12_btn.pos.y)-18]	width:15 height:17 images:#(Bitmap 15 17 color:(color 187 9 208 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	
	--L Middle Finger
	button select_lfing21_btn "LHand"	enabled:true pos:[(select_lhand1_btn.pos.x)+15,(select_lhand1_btn.pos.y)-23]		width:15 height:23 images:#(Bitmap 15 23 color:(color 187 9 208 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_lfing22_btn "LHand"	enabled:true pos:[(select_lfing21_btn.pos.x)+0,(select_lfing21_btn.pos.y)-23]	width:15 height:23 images:#(Bitmap 15 23 color:(color 187 9 208 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_lfing23_btn "LHand"	enabled:true pos:[(select_lfing22_btn.pos.x)+0,(select_lfing22_btn.pos.y)-20]	width:15 height:20 images:#(Bitmap 15 20 color:(color 187 9 208 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	
	--L Ring Finger
	button select_lfing31_btn "LHand"	enabled:true pos:[(select_lhand1_btn.pos.x)+30,(select_lhand1_btn.pos.y)-22]		width:15 height:22 images:#(Bitmap 15 22 color:(color 187 9 208 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_lfing32_btn "LHand"	enabled:true pos:[(select_lfing31_btn.pos.x)+0,(select_lfing31_btn.pos.y)-21]	width:15 height:20 images:#(Bitmap 15 20 color:(color 187 9 208 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_lfing33_btn "LHand"	enabled:true pos:[(select_lfing32_btn.pos.x)+0,(select_lfing32_btn.pos.y)-18]	width:15 height:17 images:#(Bitmap 15 17 color:(color 187 9 208 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""

	--L Pinkie Finger
	button select_lfing41_btn "LHand"	enabled:true pos:[(select_lhand1_btn.pos.x)+45,(select_lhand1_btn.pos.y)-20]		width:15 height:20 images:#(Bitmap 15 20 color:(color 187 9 208 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_lfing42_btn "LHand"	enabled:true pos:[(select_lfing41_btn.pos.x)+0,(select_lfing41_btn.pos.y)-18]	width:15 height:17 images:#(Bitmap 15 17 color:(color 187 9 208 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_lfing43_btn "LHand"	enabled:true pos:[(select_lfing42_btn.pos.x)+0,(select_lfing42_btn.pos.y)-16]	width:15 height:16 images:#(Bitmap 15 16 color:(color 187 9 208 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""

	--L Thumb
	button select_lthumb1_btn "LHand"	enabled:true pos:[(select_lhand1_btn.pos.x)-20,(select_lhand1_btn.pos.y)]		width:20 height:30 images:#(Bitmap 20 30 color:(color 119 7 38 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_lthumb2_btn "LHand"	enabled:true pos:[(select_lthumb1_btn.pos.x)+0,(select_lthumb1_btn.pos.y)-20]	width:18 height:19 images:#(Bitmap 18 19 color:(color 119 7 38 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""
	button select_lthumb3_btn "LHand"	enabled:true pos:[(select_lthumb2_btn.pos.x)+0,(select_lthumb2_btn.pos.y)-18]	width:16 height:18 images:#(Bitmap 16 18 color:(color 119 7 38 1)gamma:0.45, undefined, 1, 1, 1, 1, 1) toolTip:""

	fn GetFinger side index =
	(
		if side == "L" then sideFinger = #lfingers 
		else if side == "R" then sideFinger = #rfingers

		selObj = biped.getNode rolBsBipedTools.m_workingBipRoot sideFinger link:index
		if selObj != undefined then
		(
			if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
				return #(selObj)
			)
			else (
				return #()
			)
		)
		else
		(
			return undefined
		)
	)

	on chbLFingers changed state do
	(
		chbLFingers.state = true
	)

	on chbRFingers changed state do
	(
		chbRFingers.state = true
	)

	on select_rhand1_btn pressed do
	(
		rolBsBipedTools.fnSelAllChildrens rolBsBipedTools.m_RHand
		deselect rolBsBipedTools.m_RHand
	)

	on select_rthumb1_btn pressed do (
		m_RThumb1 = (GetFinger "R" 1)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_RThumb1 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_RThumb1) catch (
			m_RThumb1 = (GetFinger "R" 1)
			select m_RThumb1
		)
	)

	on select_rthumb2_btn pressed do (
		m_RThumb2 = (GetFinger "R" 2)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_RThumb2 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_RThumb2) catch (
			m_RThumb2 = (GetFinger "R" 2)
			select m_RThumb2
		)
	)

	on select_rthumb3_btn pressed do (
		m_RThumb3 = (GetFinger "R" 3)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_RThumb3 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_RThumb3) catch (
			m_RThumb3 = (GetFinger "R" 3)
			select m_RThumb3
		)
	)

	on select_rfing11_btn pressed do (
		m_RFing11 = (GetFinger "R" 4)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_RFing11 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_RFing11) catch (
			m_RFing11 = (GetFinger "R" 4)
			select m_RFing11
		)
	)

	on select_rfing12_btn pressed do (
		m_RFing12 = (GetFinger "R" 5)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_RFing12 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_RFing12) catch (
			m_RFing12 = (GetFinger "R" 5)
			select m_RFing12
		)
	)

	on select_rfing13_btn pressed do (
		m_RFing13 = (GetFinger "R" 6)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_RFing13 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_RFing13) catch (
			m_RFing13 = (GetFinger "R" 6)
			select m_RFing13
		)
	)

	on select_rfing21_btn pressed do (
		m_RFing21 = (GetFinger "R" 7)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_RFing21 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_RFing21) catch (
			m_RFing21 = (GetFinger "R" 7)
			select m_RFing21
		)
	)

	on select_rfing22_btn pressed do (
		m_RFing22 = (GetFinger "R" 8)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_RFing22 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_RFing22) catch (
			m_RFing22 = (GetFinger "R" 8)
			select m_RFing22
		)
	)

	on select_rfing23_btn pressed do (
		m_RFing23 = (GetFinger "R" 9)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_RFing23 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_RFing23) catch (
			m_RFing23 = (GetFinger "R" 9)
			select m_RFing23
		)
	)

	on select_rfing31_btn pressed do (
		m_RFing31 = (GetFinger "R" 10)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_RFing31 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_RFing31) catch (
			m_RFing31 = (GetFinger "R" 10)
			select m_RFing31
		)
	)

	on select_rfing32_btn pressed do (
		m_RFing32 = (GetFinger "R" 11)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_RFing32 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_RFing32) catch (
			m_RFing32 = (GetFinger "R" 11)
			select m_RFing32
		)
	)

	on select_rfing33_btn pressed do (
		m_RFing33 = (GetFinger "R" 12)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_RFing33 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_RFing33) catch (
			m_RFing33 = (GetFinger "R" 12)
			select m_RFing33
		)
	)

	on select_rfing41_btn pressed do (
		m_RFing41 = (GetFinger "R" 13)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_RFing41 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_RFing41) catch (
			m_RFing41 = (GetFinger "R" 13)
			select m_RFing41
		)
	)

	on select_rfing42_btn pressed do (
		m_RFing42 = (GetFinger "R" 14)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_RFing42 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_RFing42) catch (
			m_RFing42 = (GetFinger "R" 14)
			select m_RFing42
		)
	)

	on select_rfing43_btn pressed do (
		m_RFing43 = (GetFinger "R" 15)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_RFing43 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_RFing43) catch (
			m_RFing43 = (GetFinger "R" 15)
			select m_RFing43
		)
	)

	on select_Lhand1_btn pressed do
	(
		rolBsBipedTools.fnSelAllChildrens rolBsBipedTools.m_LHand
		deselect rolBsBipedTools.m_LHand
	)

	on select_Lthumb1_btn pressed do (
		m_LThumb1 = (GetFinger "L" 1)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_LThumb1 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_LThumb1) catch (
			m_LThumb1 = (GetFinger "L" 1)
			select m_LThumb1
		)
	)

	on select_Lthumb2_btn pressed do (
		m_LThumb2 = (GetFinger "L" 2)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_LThumb2 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_LThumb2) catch (
			m_LThumb2 = (GetFinger "L" 2)
			select m_LThumb2
		)
	)

	on select_Lthumb3_btn pressed do (
		m_LThumb3 = (GetFinger "L" 3)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_LThumb3 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_LThumb3) catch (
			m_LThumb3 = (GetFinger "L" 3)
			select m_LThumb3
		)
	)

	on select_Lfing11_btn pressed do (
		m_LFing11 = (GetFinger "L" 4)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_LFing11 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_LFing11) catch (
			m_LFing11 = (GetFinger "L" 4)
			select m_LFing11
		)
	)

	on select_Lfing12_btn pressed do (
		m_LFing12 = (GetFinger "L" 5)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_LFing12 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_LFing12) catch (
			m_LFing12 = (GetFinger "L" 5)
			select m_LFing12
		)
	)

	on select_Lfing13_btn pressed do (
		m_LFing13 = (GetFinger "L" 6)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_LFing13 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_LFing13) catch (
			m_LFing13 = (GetFinger "L" 6)
			select m_LFing13
		)
	)

	on select_Lfing21_btn pressed do (
		m_LFing21 = (GetFinger "L" 7)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_LFing21 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_LFing21) catch (
			m_LFing21 = (GetFinger "L" 7)
			select m_LFing21
		)
	)

	on select_Lfing22_btn pressed do (
		m_LFing22 = (GetFinger "L" 8)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_LFing22 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_LFing22) catch (
			m_LFing22 = (GetFinger "L" 8)
			select m_LFing22
		)
	)

	on select_Lfing23_btn pressed do (
		m_LFing23 = (GetFinger "L" 9)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_LFing23 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_LFing23) catch (
			m_LFing23 = (GetFinger "L" 9)
			select m_LFing23
		)
	)

	on select_Lfing31_btn pressed do (
		m_LFing31 = (GetFinger "L" 10)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_LFing31 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_LFing31) catch (
			m_LFing31 = (GetFinger "L" 10)
			select m_LFing31
		)
	)

	on select_Lfing32_btn pressed do (
		m_LFing32 = (GetFinger "L" 11)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_LFing32 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_LFing32) catch (
			m_LFing32 = (GetFinger "L" 11)
			select m_LFing32
		)
	)

	on select_Lfing33_btn pressed do (
		m_LFing33 = (GetFinger "L" 12)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_LFing33 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_LFing33) catch (
			m_LFing33 = (GetFinger "L" 12)
			select m_LFing33
		)
	)

	on select_Lfing41_btn pressed do (
		m_LFing41 = (GetFinger "L" 13)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_LFing41 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_LFing41) catch (
			m_LFing41 = (GetFinger "L" 13)
			select m_LFing41
		)
	)

	on select_Lfing42_btn pressed do (
		m_LFing42 = (GetFinger "L" 14)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_LFing42 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_LFing42) catch (
			m_LFing42 = (GetFinger "L" 14)
			select m_LFing42
		)
	)

	on select_Lfing43_btn pressed do (
		m_LFing43 = (GetFinger "L" 15)
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot) or m_LFing43 == undefined ) do (return ())

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup m_LFing43) catch (
			m_LFing43 = (GetFinger "L" 15)
			select m_LFing43
		)
	)
)

fn fnLoadBsBTConfig =
(
	local oldPrintAllElements  = options.printAllelements
	options.printAllelements = true
	attr = (GetINISetting iniBsBipedTools "BsBipedTools" "BsBTPos") as string  --先提取文件中的记录
	if (attr == "") or (attr == "undefined") then 
	(
		attr = execute "0"
	)
	else 
	(
		attr = execute attr
	)
	options.printAllelements = oldPrintAllElements
	iniBsBTPos = attr
)
fnLoadBsBTConfig()

fn fnSetBsBTConfig =
(
	SetINISetting iniBsBipedTools "BsBipedTools" "BsBTPos" (iniBsBTPos as string)
)

fn fnGetThemeColor =
(
	local curColorThemeFile = colorMan.getFileName()
	local maxuiBgColor = (colorman.getcolor #background) * 255
	
	if (curColorThemeFile != undefined) then
	(
		if (matchpattern curColorThemeFile pattern:"*light*") then
		(
			outThemeColor = "Light"
		)
		else
		(
			case maxuiBgColor of 
			(
				([68,68,68]):
				(
					outThemeColor = "Dark"
				)
				([186,186,186]):
				(
					outThemeColor = "Light"
				)
				default:
				(
					outThemeColor = "Dark"
				)
			)
		)
	)
	else
	(
		case maxuiBgColor of 
		(
			([68,68,68]):
			(
				outThemeColor = "Dark"
			)
			([186,186,186]):
			(
				outThemeColor = "Light"
			)
			default:
			(
				outThemeColor = "Dark"
			)
		)
	)
	return outThemeColor
	----获取当前主题是深色还是浅色,来更改文字颜色 fnGetColorTheme.ms
)

rollout rolBsBipedTools "BsBipedTools" width:180 height:585
(
	local colorTheme = fnGetThemeColor()

	fn fnChangeThemeColor myColor =
	(
		colorTheme = fnGetThemeColor()
		if colorTheme == "Light" then (return myColor) else (return myColor/1.5)
	)

	fn fnBipedComlocalization ctrl =
	(
		if (((sysinfo.GetMaxLanguage())[3]=="CHS") and ((maxVersion())[1] < 20000)) then 
		(
			return ctrl.flip.controller
		)
		else
		(
			return ctrl.turning.controller
		)
	)

	fn fnAddBipedKey =
	(
		for i in selection as array where iskindof i.baseObject Biped_Object do
		(
			if ( classof i.controller == Vertical_Horizontal_Turn ) then
			(
				biped.addNewKey i.controller.vertical.controller slidertime
				biped.addNewKey i.controller.horizontal.controller slidertime
				biped.addNewKey (fnBipedComlocalization i.controller) slidertime
			)
			else 
			(
				try (biped.addNewKey i.controller sliderTime ) catch ()
			)
		)
	)

	fn fnGetAllBipedCom = 
	(
		allBips = #()
		for obj in geometry where not isDeleted obj and classof obj.baseobject == Biped_Object and (classof obj.controller == Vertical_Horizontal_Turn) do
		(
			append allBips obj
		)
		return allBips
	)

	fn fnGetAllSelRootNode = 
	(
		allRootNode = #()
		for obj in selection as array where (classof obj == Biped_object) and ((classof obj.controller == Vertical_Horizontal_Turn) or (classof obj.controller == BipSlave_Control)) do
		(
			if finditem allRootNode obj.controller.rootnode != 0 then 
			(
				Continue
			)
			else 
			(
				appendifUnique allRootNode obj.controller.rootnode
			)
		)
		return allRootNode
	)

	local a_layerNames = #()
	local a_layersActiveState = #()
	local ctrl = undefined
	local numLayers = 0
	local layerIndex = 1
	local postureObjsFile = getDir #plugcfg + "\BsBipedTools_PostureObjs.txt"

	local mc_setKeyColor = fnChangeThemeColor (color 240 180 180)
	local mc_spineColor  = fnChangeThemeColor (color 52 171 187)
	local mcLeft         = fnChangeThemeColor (color 120 120 193)
	local mcRight        = fnChangeThemeColor (color 53 176 53)
	local mcHead         = fnChangeThemeColor (color 160 229 248)
	local mcPevils       = fnChangeThemeColor (color 220 208 148)
	local mcLoopSel      = fnChangeThemeColor (color 200 160 200)
	local mcIK           = fnChangeThemeColor (color 223 225 71)
	local mcFK           = fnChangeThemeColor (color 160 160 160)
	local mcAllBiped     = fnChangeThemeColor (color 200 180 221)
	local mcScanBiped    = fnChangeThemeColor (color 250 200 200)
	local mcMotionPanel  = fnChangeThemeColor (color 223 225 200)
	local mcSelTools     = fnChangeThemeColor (color 20 180 180)
	local mcInPlace      = fnChangeThemeColor (color 192 192 255)

	button uiAbout "?" offset:[-15, -5] height:15 width:20 border:false align:#left across:3
	button btnMini "☐" offset:[45, -5] height:15 width:20 border:false align:#right
	button btnClose "X" offset:[15, -5] height:15 width:20 border:false align:#right
	
	dropdownlist ddlAllBipedCom items:#() selection:1 \
	tooltip:"选择biped骨架" width:70 pos:[10, 20] across:2
	checkButton uiChkBtnScanBiped "All Biped" pos:[85, 20] width:60 checked:true highlightColor:mcScanBiped \
	tooltip:"如果Biped发生变化，请重新扫描。\r\n如果有多个 Biped，请在左边下拉选择。\r\n还可用来选中当前骨架所有Biped骨骼~"
	checkButton uiToggleMotionPanel "M" pos:[150, 20] width:20 checked:true highlightColor:mcMotionPanel \
	tooltip:"左键禁用Motion面板 (大大减少卡顿)\r\n右键恢复 (如未恢复请右击多次)\r\n注意观察按钮颜色 (但颜色重启失效)\r\n(注意:某些Biped功能依赖Motion面板刷新)"
	
	checkButton uiCkbZen "Zen" checked:true width:25 height:23 pos:[10,50] highlightColor:mcMotionPanel \
	tooltip:"禅模式切换（最大化视窗）"
	checkButton uiCkbHideBip "HB" checked:true width:20 height:23 pos:[40,50] highlightColor:mcMotionPanel \
	tooltip:"左键切换隐藏显示Biped骨骼\r\n右键直接隐藏"

	checkButton uiCkbXray "Xray" checked:true width:20 height:23 pos:[120,50] highlightColor:mcMotionPanel \
	tooltip:"左键Xray模式切换\r\n右键直接开启"
	checkButton uiCkbShowBox "Box" checked:true width:25 height:23 pos:[145,50] highlightColor:mcMotionPanel \
	tooltip:"左键Box模式切换\r\n右键直接开启"

	checkBox uiChkSelHiddenObj "Select hidden biped" checked:true pos:[-99, -99]
	
	checkButton uiHead "Head" width: 50 height:33 checked:true highlightColor:mcHead pos:[65, 50]
	checkButton uiNecks "Necks" width: 40 height:23 checked:true highlightColor:mc_spineColor align:#center pos:[70, 85]
	
	checkButton uiRArms "" checked:true highlightColor:mcRight width:25 align:#left pos:[15, 85] across:2
	checkButton uiLArms "" checked:true highlightColor:mcLeft width:25 align:#right pos:[140, 85]
	
	checkButton uiRClavicle "Clavicle" width:55 height:22 checked:true highlightColor:mcRight across:2 pos:[25, 110]
	checkButton uiLClavicle "Clavicle" width:55 height:22 checked:true highlightColor:mcLeft pos:[100, 110]
	
	checkButton uiAllSpine height:58 width:26 checked:true highlightColor:mc_spineColor pos:[60, 135] align:#center
	checkButton uiSpine2 "2" width:30 height:18 checked:true highlightColor:mc_spineColor align:#center pos:[90, 135]
	checkButton uiSpine1 "1" width:30 height:18 checked:true highlightColor:mc_spineColor align:#center pos:[90, 155]
	checkButton uiSpine0 "0" width:30 height:18 checked:true highlightColor:mc_spineColor align:#center pos:[90, 175]
	
	checkButton uiCOM "COM" checked:true width:50 height:30 highlightColor:mcHead pos:[65, 195]
	checkButton uiPelvis "Pelvis" checked:true highlightColor:mcPevils width:60 height:18 pos:[60, 225]
	
	checkButton uiRUpArm "R" width:25  height:30 pos:[20, 135] checked:true highlightColor:mcRight across:2
	checkButton uiLUpArm "L" width:25  height:30 pos:[135, 135] checked:true highlightColor:mcLeft
	checkButton uiRForArm "R" width:25  height:30 pos:[20, 165] checked:true highlightColor:mcRight across:2
	checkButton uiLForArm "L" width:25  height:30 pos:[135, 165] checked:true highlightColor:mcLeft
	checkButton uiRHand "Hand" pos:[10, 195] height:25 checked:true highlightColor:mcRight across:2
	checkButton uiLHand "Hand" pos:[130, 195] height:25 checked:true highlightColor:mcLeft
	
	checkButton uiPropR "Prop" width:35 height:18 checked:true highlightColor:mcSelTools pos:[13, 223]
	checkButton uiPropL "Prop" width:35 height:18 checked:true highlightColor:mcSelTools pos:[133, 223]

	checkButton uiRThigh "R" width:25  height:30 align:#right checked:true highlightColor:mcRight pos:[60, 245] across:2
	checkButton uiLThigh "L" width:25 height:30 align:#left checked:true highlightColor:mcLeft pos:[95, 245]
	checkButton uiRCalf "R" width:25  height:30 checked:true highlightColor:mcRight align:#right  pos:[60, 275] across:2
	checkButton uiLCalf "L" width:25  height:30 checked:true highlightColor:mcLeft align:#left pos:[95, 275]
	checkButton uiRFoot "R Foot" checked:true highlightColor:mcRight align:#right pos:[45, 305] width:40 height:25 across:2
	checkButton uiLFoot "L Foot" checked:true highlightColor:mcLeft align:#left pos:[95, 305] width:40 height:25
	
	checkButton uiRLegs "" checked:true highlightColor:mcRight width:25 align:#left pos:[25, 265] across:2
	checkButton uiLLegs "" checked:true highlightColor:mcLeft width:25 align:#right pos:[130, 265]
	
	checkButton uiRToe "Toe" checked:true highlightColor:mcRight width:30 height:20 align:#left pos:[15, 310] across:2
	checkButton uiLToe "Toe" checked:true highlightColor:mcLeft width:30 height:20 align:#right pos:[135, 310]
	
	checkButton uiAllFoot "" width:50 checked:true highlightColor:mcSelTools align:#center  pos:[65, 335]
	-- checkButton uiAllBip "All Biped" width:100 checked:true highlightColor:mcAllBiped pos:[0, -4] align:#center
	checkButton uiFingers "" width:50 checked:true highlightColor:mcSelTools pos:[10, 335]
	checkButton uiPivot "" width:50 checked:true highlightColor:mcSelTools pos:[120, 335]
	

	groupbox grpKinInfo "" pos:[-10, 358] width:200 height:100
	
	checkbutton uiCbtHorTrack "" pos:[10, 370] width:30 height:25 border:false
	checkbutton uiCbtVerTrack "" pos:[40, 370] width:30 height:25 border:false
	checkbutton uiCbtTurnTrack "" pos:[70, 370] width:30 height:25 border:false
	button uiBtnComLock "" pos:[105, 370] width:30 height:25 border:false 
	checkbutton uiBtnInPlace "" pos:[140,370] width:30 height:25 \
	tooltip:"原地模式去前后位移\r\nIn Place Mode Y\r\n右键真原地模式" \
	border:false highlightColor:mcInPlace

	checkButton uiBtnSetAllKey "" pos:[10, 400] across:4 width:25 height:25 border:false \
	tooltip:"左键选择K帧,\r\n右键Biped全帧." checked:true highlightColor:mcFK
	checkButton uiBtnDeleteKey "" width:25 height:25 tooltip:"左键删除所选Biped当前滑条帧\r\n右键清除Biped所有帧" \
	pos:[37, 400] border:false checked:true highlightColor:mcFK
	checkButton uiBtnLimbPK "" width:25 height:25 tooltip:"Shift + 单击 - 应用于所有帧，\r\nCtrl + 单击 - 应用于选定帧。\r\n（会卡一下因为必须要Motion面板）" \
	pos:[65, 400] border:false checked:true highlightColor:mcFK
	checkButton uiBtnLimbIK "" width:25 height:25 tooltip:"Shift + 单击 - 应用于所有帧，\r\nCtrl + 单击 - 应用于选定帧。\r\n（会卡一下因为必须要Motion面板）" \
	pos:[90, 400] border:false checked:true highlightColor:mcFK
	checkButton uiBtnLimbFK "" width:25 height:25 tooltip:"Shift + 单击 - 应用于所有帧，\r\nCtrl + 单击 - 应用于选定帧。\r\n（会卡一下因为必须要Motion面板）" \
	pos:[115, 400] border:false checked:true highlightColor:mcFK
	checkButton uiBtnTraj "" width:25 height:25
	pos:[145, 400] border:false checked:true highlightColor:mcFK
	
	
	dropdownlist uiDropPlaySpeed pos:[8, 430] items:#("1/4", "1/2", "1", "2", "4") selection:3 tooltip:"播放速度" width:50 
	checkbutton uiPlayBlock "" pos:[60, 430] width:30 height:21 tooltip:"播放Blocking(无过度)" border:true
	button uiBtnFrameTick "" pos:[90, 430] width:30 height:21 tooltip:"整数帧/小数帧切换\r\n便于拖滑条细调动画" border:true
	checkbutton uiFigureMode "" pos:[120,430] width:25 height:21 tooltip:"形体编辑模式\r\nFigure Mode" border:true highlightColor:mcInPlace
	button uiWorkbench "" pos:[145,430] width:27 height:21 tooltip:"Biped曲线编辑\r\nWorkbench" border:true
    
	dotNetControl dotnetTabs "System.Windows.Forms.TabControl" pos:[2,460] height:160 width:45

	--copy paste tools
	checkbutton uiCbtCopy "" pos:[50,465] width:30 height:25 visible:false checked:true highlightColor:mcFK tooltip:"复制Poseture"
	checkbutton uiCbtPaste "" pos:[80,465] width:30 height:25 visible:false checked:true highlightColor:mcFK tooltip:"粘贴Poseture"
	checkbutton uiCbtPasteOpposite "" pos:[110,465] width:30 height:25 visible:false checked:true highlightColor:mcFK tooltip:"镜像粘贴Poseture"
	checkbutton uiCbtSelBones "选择" pos:[140,465] width:35 height:25 visible:false checked:true highlightColor:mcFK tooltip:"选择复制pose的Biped骨骼"
	checkbutton uiCbtMirrorRArm "右→左臂" pos:[50,495] width:60 height:25 visible:false checked:true highlightColor:mcRight
	checkbutton uiCbtMirrorLArm "左→右臂" pos:[115,495] width:60 height:25 visible:false checked:true highlightColor:mcLeft
	checkbutton uiCbtMirrorRLeg "右→左腿" pos:[50,523] width:60 height:25 visible:false checked:true highlightColor:mcRight
	checkbutton uiCbtMirrorLLeg "左→右腿" pos:[115,523] width:60 height:25 visible:false checked:true highlightColor:mcLeft
	checkbutton uiCbtGrabPose "暂存Pose" pos:[50,550] width:60 height:25 visible:false checked:true highlightColor:mcFK
	checkbutton uiCbtLoadPose "加载Pose" pos:[115,550] width:60 height:25 visible:false checked:true highlightColor:mcFK

	--layers tools
	button uiCbtDown "" pos:[50,465] width:20 height:20 visible:false border:false
	button uiCbtUp "" pos:[70,465] width:20 height:20 visible:false border:false
	label uiLblLayerID "0" pos:[95,469] width:20 height:16 visible:false style_sunkenedge:true readonly:true
	label uiLblActive "Active" pos:[123,470] width:40 height:25 visible:false
	checkbox uiChkActive "" pos:[160,465] width:60 height:25 visible:false checked:true
	dropDownList ddlLayers "" pos:[50,489] width:85 visible:false
	checkbutton uiCbtRefreshLayer "刷新" pos:[140,490] width:35 height:20 visible:false checked:true highlightColor:mcScanBiped
	button uiCbtAddLayer "" pos:[52,514] width:30 height:20 visible:false border:false
	button uiCbtDelLayer "" pos:[82,514] width:30 height:20 visible:false border:false
	button uiCbtDownLayer "" pos:[112,514] width:30 height:20 visible:false border:false
	button uiCbtSnapKeys "" pos:[142,514] width:30 height:20 visible:false border:false tooltip:"左键吸附当前帧，右键吸附帧栏所有帧"
	checkbutton uiCbtLeftArm "" pos:[52,537] width:30 height:20 visible:false checked:false highlightColor:mcHead border:false
	checkbutton uiCbtRightArm "" pos:[82,537] width:30 height:20 visible:false checked:false highlightColor:mcHead border:false
	checkbutton uiCbtLeftLeg "" pos:[112,537] width:30 height:20 visible:false checked:false highlightColor:mcHead border:false
	checkbutton uiCbtRightLeg "" pos:[142,537] width:30 height:20 visible:false checked:false highlightColor:mcHead border:false
	button uiCbtUpdate "Update" pos:[50,560] width:65 height:20 visible:false border:false
	checkbox uiChkIKonly "IK Only" pos:[120,560] width:100 height:20 visible:false checked:false highlightColor:mcHead tooltip:"没找到获取状态的api...只能update设置"

	--loopkey tools
	checkButton uiBtnLoopGet "范围" tooltip:"获取当前时间轴\r\nGet current timerange" checked:true width:43 \
	highlightColor:mcAllBiped align:#left pos:[50, 465] height:20 across:3 visible:false
	spinner uiSpnLoopStart tooltip:"Loop Range" type:#integer range:[-9999,9999,0] width:50 align:#left pos:[48, 493] visible:false
	spinner uiSpnLoopEnd tooltip:"Loop Range" type:#integer range:[-9999,9999,30] width:50 align:#left pos:[101, 493] visible:false
	checkButton uiCkbClearUserDef "X" border:true pos:[159, 465] height:70 width:16 checked:true highlightColor:mcAllBiped visible:false \
	tooltip:"清除 骨架保存的循环帧自定义属性值。\r\n（对文件本身无任何影响） "
	checkButton uiBtnGotoMirror "跳转对称帧" checked:true highlightColor:mcAllBiped tooltip:"滑条跳转到镜像帧\r\nGoto symmetry key" \
	align:#left pos:[50, 515] height:20 width:103 across:2 visible:false

	checkButton uiBtnLoopSel "选择帧" height:20 width:57 pos:[95, 465] checked:true highlightColor:mcAllBiped align:#left \
	tooltip:"选择循环内的所有帧\r\nSelect keys in the looping range." visible:false

	--other tools
	checkButton uiBtn0 "0" pos:[50,465] width:30 height:25 tooltip:"曲柄打直 Continuity (TCB)\r\nCtrl/Shift 可批处理\r\nESC可中断" border:true visible:false checked:true highlightColor:mcInPlace
	checkButton uiBtn25 "25" pos:[82,465] width:30 height:25 tooltip:"曲柄默认 Continuity (TCB)\r\nCtrl/Shift 可批处理\r\nESC可中断" border:true visible:false checked:true highlightColor:mcInPlace
	checkButton uiBtnLoadBip "S" pos:[114, 465] width:30 height:25 tooltip:"" border:true visible:false checked:true highlightColor:mcInPlace
	checkButton uiBtnSaveBip "L" pos:[146, 465] width:30 height:25 tooltip:"" border:true visible:false checked:true highlightColor:mcInPlace

	-- label uiLblTitle "BsBipedTools_v1.0" height:16 width:rolBsBipedTools.width pos:[5, 585]
	timer clock "PlayClock" interval:1 active:false -- 가장 빠른 인터벌로

	local arrLoopTools = #("LoopK",#(uiBtnLoopGet,uiSpnLoopStart,uiSpnLoopEnd,uiCkbClearUserDef,uiBtnLoopSel,uiBtnGotoMirror))
	local arrOtherTools = #("Other",#(uiBtn0,uiBtn25,uiBtnLoadBip,uiBtnSaveBip)) 
	local arrLayerTools = #("Layer",#(uiCbtRefreshLayer,uiCbtDown,uiCbtUp,uiLblLayerID,uiLblActive,uiChkActive,uiCbtAddLayer,\
		uiCbtDelLayer,uiCbtDownLayer,uiCbtSnapKeys,uiCbtLeftArm,uiCbtRightArm,uiCbtLeftLeg,uiCbtRightLeg,uiCbtUpdate,uiChkIKonly,ddlLayers))
	local arrCopyTools = #("CopyP",#(uiCbtCopy,uiCbtPaste,uiCbtPasteOpposite,uiCbtSelBones,uiCbtMirrorLArm,uiCbtMirrorRArm,\
		uiCbtMirrorLLeg,uiCbtMirrorRLeg,uiCbtGrabPose,uiCbtLoadPose))
	local arrAllToolsTab = #(arrCopyTools,arrLayerTools,arrLoopTools,arrOtherTools)

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
	)

	-- fn fnDotnetBitmap fName =
	-- (
	-- 	if doesFileExist fName then
	-- 	(
	-- 		local img = (dotnetclass "System.Drawing.Image").fromfile fName 
	-- 		local retBmp = dotnetObject "System.Drawing.Bitmap" (img.Width) (img.height)
	-- 		local g = (dotnetclass "system.drawing.graphics").fromImage retBmp
	-- 		g.drawimage img 0 0 	
	-- 		img.Dispose();
	-- 		retBmp
	-- 	)
	-- 	else return undefined
	-- )

	fn fnInitDotTabs =
	(
		-- imgTab1 = fnDotnetBitmap @"D:\Download\paste (2).png"
		-- imgTab2 = fnDotnetBitmap @"D:\Download\图层 (4).png"
		-- imgTab3 = fnDotnetBitmap @"D:\Download\图层 (4).png"
		-- imgTab4 = fnDotnetBitmap @"D:\Download\图层 (4).png"
		-- -- imgTab1 = dotNetObject "System.Drawing.Bitmap" imgPath
		-- imageList = dotNetObject "System.Windows.Forms.ImageList"

		-- imageList.ImageSize = dotNetObject "System.Drawing.Size" 20 20
		-- imageList.images.add(imgTab1)
		-- imageList.images.add(imgTab2)
		-- imageList.images.add(imgTab3)
		-- imageList.images.add(imgTab4)

		dotnetTabs.sizeMode  = dotnetTabs.sizeMode.Fixed
		dotnetTabs.itemSize  = dotNetObject "System.Drawing.Size" 29 40
		dotnetTabs.dock      = dotnetTabs.dock.Fill
		dotnetTabs.Drawmode  = dotnetTabs.Drawmode.OwnerDrawFixed
		dotnetTabs.alignment = (dotnetclass "system.Windows.Forms.Tabalignment").left

		for aTab = 1 to arrAllToolsTab.count do
		(
			dotnetTabs.TabPages.add arrAllToolsTab[aTab][1]
			-- dotnetTabs.TabPages.item[aTab - 1].ImageIndex = aTab - 1
			-- dotnetTabs.TabPages.item[aTab - 1].text = ""
			-- print  aTab[1]
		)
		-- dotnetTabs.imagelist = imageList
	)

	on dotnetTabs Selected itm do
	(
		arrID = (itm.TabPageIndex + 1)
		if LastSubRollout != arrID do --do not update if the same tab clicked twice
		(
			fnChangeToolsVisble arrID
		) 
	)

	fn fnApplyIcons =
	(
		uiBtnSetAllKey.images      = #("bip_ikkey_i.bmp","bip_ikkey_i.bmp",8,1,1,1,1,true,true)
		uiBtnDeleteKey.images      = #("bip_keyframe_i.bmp","bip_keyframe_i.bmp",46,3,3,3,3,true,true)
		uiBtnLimbPK.images         = #("bip_ikkey_i.bmp","bip_ikkey_i.bmp",8,3,3,3,3,true,true)
		uiBtnLimbIK.images         = #("bip_ikkey_i.bmp","bip_ikkey_i.bmp",8,5,5,5,5,true,true)
		uiBtnLimbFK.images         = #("bip_ikkey_i.bmp","bip_ikkey_i.bmp",8,7,7,7,7,true,true)
		uiPlayBlock.images         = #("bip_mfltrans_i.bmp","bip_mfltrans_i.bmp",26,21,21,21,21,true,true)
		uiToggleMotionPanel.images = #("bip_pivselbig_i.bmp","bip_pivselbig_i.bmp",6,6,6,6,6,true,true)
		uiCkbShowBox.images        = #("UVWUnwrapView_16i.bmp","UVWUnwrapView_16a.bmp",28,9,9,9,9,true,false)
		uiCkbXray.images           = #("bip_modes_i.bmp","bip_modes_i.bmp",8,2,2,2,2,true,true)
		uiCkbHideBip.images        = #("bip_tracksel_i.bmp","bip_tracksel_i.bmp",10,7,7,7,7,true,true)
		uiCkbZen.images            = #("FileLinkActionItems_16i.bmp","FileLinkActionItems_16i.bmp",9,5,5,5,5,true,true)
		uiBtnFrameTick.images      = #("AutoGrid_16i.bmp","AutoGrid_16i.bmp",2,2,2,2,2,true,true)
		uiBtnTraj.images           = #("bip_keyframe_i.bmp","bip_keyframe_i.bmp",46,29,29,29,29,true,true)
		uiRArms.images             = #("AddPreset_16i.bmp","AddPreset_16i.bmp",1,1,1,1,1,true,true)
		uiLArms.images             = #("AddPreset_16i.bmp","AddPreset_16i.bmp",1,1,1,1,1,true,true)
		uiRLegs.images             = #("AddPreset_16i.bmp","AddPreset_16i.bmp",1,1,1,1,1,true,true)
		uiLLegs.images             = #("AddPreset_16i.bmp","AddPreset_16i.bmp",1,1,1,1,1,true,true)
		uiAllFoot.images           = #("bip_modes_i.bmp","bip_modes_i.bmp",8,4,3,4,3,true,true)
		uiBtnInPlace.images        = #("bip_general_i.bmp","bip_general_i.bmp",30,27,27,27,27,true,true)
		uiBtnSaveBip.images        = #("bip_general_i.bmp","bip_general_i.bmp",30,7,7,7,7,true,true)
		uiBtnLoadBip.images        = #("bip_general_i.bmp","bip_general_i.bmp",30,5,5,5,5,true,true)
		uiFigureMode.images        = #("bip_modes_i.bmp","bip_modes_i.bmp",8,1,1,1,1,true,true)
		uiWorkbench.images         = #("bip_workbench_i.bmp","bip_workbench_i.bmp",10,7,7,7,7,true,true)
		uiCbtCopy.images           = #("bip_keyframe_i.bmp","bip_keyframe_i.bmp",46,9,9,9,9,true,true)
		uiCbtPaste.images          = #("bip_keyframe_i.bmp","bip_keyframe_i.bmp",46,17,17,17,17,true,true)
		uiCbtPasteOpposite.images  = #("bip_keyframe_i.bmp","bip_keyframe_i.bmp",46,19,19,19,19,true,true)
		uiCbtUp.images             = #("bip_layer_i.bmp","bip_layer_i.bmp",24,1,1,1,1,true,true)
		uiCbtDown.images           = #("bip_layer_i.bmp","bip_layer_i.bmp",24,3,3,3,3,true,true)
		uiCbtAddLayer.images       = #("bip_layer_i.bmp","bip_layer_i.bmp",24,5,5,5,5,true,true)
		uiCbtDelLayer.images       = #("bip_layer_i.bmp","bip_layer_i.bmp",24,7,7,7,7,true,true)
		uiCbtDownLayer.images      = #("bip_layer_i.bmp","bip_layer_i.bmp",24,13,13,13,13,true,true)
		uiCbtSnapKeys.images       = #("bip_layer_i.bmp","bip_layer_i.bmp",24,15,15,15,15,true,true)
		uiCbtLeftArm.images        = #("bip_layer_i.bmp","bip_layer_i.bmp",24,17,17,17,17,true,true)
		uiCbtRightArm.images       = #("bip_layer_i.bmp","bip_layer_i.bmp",24,19,19,19,19,true,true)
		uiCbtLeftLeg.images        = #("bip_layer_i.bmp","bip_layer_i.bmp",24,21,21,21,21,true,true)
		uiCbtRightLeg.images       = #("bip_layer_i.bmp","bip_layer_i.bmp",24,23,23,23,23,true,true)
		uiFingers.images           = #("curvecontrol_defstat_i.bmp","curvecontrol_defstat_i.bmp",13,5,5,5,5,true,true)
		uiPivot.images             = #("bip_mflshare_i.bmp","bip_mflshare_i.bmp",2,2,2,2,2,true,true)
		uiCbtHorTrack.images       = #("bip_tracksel_i.bmp","bip_tracksel_i.bmp",10,1,1,1,1,true,true)
		uiCbtVerTrack.images       = #("bip_tracksel_i.bmp","bip_tracksel_i.bmp",10,3,3,3,3,true,true)
		uiCbtTurnTrack.images      = #("bip_tracksel_i.bmp","bip_tracksel_i.bmp",10,5,5,5,5,true,true)
		uiBtnComLock.images        = #("LockButtonExt_i.bmp","LockButtonExt_i.bmp",2,1,1,1,1,true,true)
	)

	fn fnDeleteUserProp nodeBipRoot prop = if getUserProp nodeBipRoot prop != undefined do
	(
		buff = (getUserPropBuffer nodeBipRoot) as stringStream 
		newb = stringStream ""
		while not eof buff do
		(
			str = readLine buff
			if str != "" and not matchpattern str pattern:("*" + prop + "*=*") do format "%\n" str to:newb
		)
		setUserPropBuffer nodeBipRoot (replace_LF_with_CRLF (newb as string))
		return ok
	)

    local m_workingBipRoot -- 현재 작업중인 바이패드의 루트 노드
    
	-- 시인성을 위해 예외적으로 m_ 뒤에 대문자 사용
	-- 모든 부위 변수들은 배열
	local m_Head
	local m_RArms
	local m_Necks
	local m_LArms
	local m_RClavicle
	local m_LClavicle
	local m_RUpArm
	local m_AllSpine
	local m_Spine2
	local m_Spine1
	local m_Spine0
	local m_LUpArm
	local m_RForArm
	local m_LForArm
	local m_RHand
	local m_COM
	local m_LHand
	local m_Pelvis
	local m_RThigh
	local m_LThigh
	local m_RCalf
	local m_LCalf
	local m_RFoot
	local m_LFoot
	local m_RToe
	local m_LToe
	local m_RLegs
	local m_AllFoot
	local m_LLegs
	local m_AllBip
	local m_LProp
	local m_RProp
    
    local m_PBKeyTimeArray      -- 블럭킹 애니메이션용 키 타임 배열 로컬 변수 (Frame)
    local m_PBKeyMiliSecArray  -- 블럭킹 애니메이션용 키 타임 배열 로컬 변수 (밀리세컨드)
    local m_PBStartTime     -- 블럭킹 애니메이션 반복 시작시간 비교용 기록
    local m_PBPointer       -- 어디까지 재생중인지 기록하는 포인터
    local m_PBPlaySpeed     -- 재생 속도 가속 감속용, uiDropPlaySpeed 와 연동됨
	
	struct BipType
	(
		limbName,
		linkIndex
    )
    
    function SetPBPlaySpeed = (
        case timeConfiguration.playbackSpeed of (
        1: (m_PBPlaySpeed = 4.0) -- 1/4 속도라서 4배 더 큰 시간 값을 적용해야함
        2: (m_PBPlaySpeed = 2.0)
        3: (m_PBPlaySpeed = 1.0)
        4: (m_PBPlaySpeed = 0.5)
        5: (m_PBPlaySpeed = 0.25) -- 4배 속도라서 0.25배 작은 시간값을 적용해야함
        )
    )

	-- 바이패드 COM인지 검사
	fn IfBipRoot obj = (
		if ((classof obj.baseobject) == Biped_Object and ((classof obj.controller == Vertical_Horizontal_Turn) or (classof obj.controller == BipSlave_Control))) do (
			if (obj.controller.rootNode == obj) do (return true)
		)
		return false
	)

	fn SaveRangeLoop = (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do return ()
		setUserProp m_workingBipRoot "BsBT_RangeLoopStart" uiSpnLoopStart.value
		setUserProp m_workingBipRoot "BsBT_RangeLoopEnd" uiSpnLoopEnd.value
	)

	fn LoadRangeLoop = (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do return ()
		try (
			uiSpnLoopStart.value = getUserProp m_workingBipRoot "BsBT_RangeLoopStart"
			uiSpnLoopEnd.value = getUserProp m_workingBipRoot "BsBT_RangeLoopEnd"
		) catch ()
	)
	
		-- 리턴 스트럭쳐의 멤버 : limbName, linkIndex
	function GetBipedType obj = (
		if ( obj == undefined ) do return undefined
		if ( (classof obj.baseobject) != Biped_Object ) do return (bipType limbName:#nonBiped linkIndex:0)
		
		-- biped.maxNumLinks $ 이 방법으로 바이패드의 최대 링크 수를 알아낼 수 있다. 보통 25이지만 넉넉하게 30
		loopCount = 30
		types = #(
			#larm,
			#rarm,
			#lfingers,
			#rfingers,
			#lleg,
			#rleg,
			#ltoes,
			#rtoes,
			#spine,
			#tail,
			#head,
			#pelvis,
			#vertical,
			#horizontal,
			#turn,
			#footprints,
			#neck,
			#pony1,
			#pony2,
			#prop1,
			#prop2,
			#prop3,
			#lfArmTwist,
			#rfArmTwist,
			#lUparmTwist,
			#rUparmTwist,
			#lThighTwist,
			#rThighTwist,
			#lCalfTwist,
			#rCalfTwist,
			#lHorseTwist,
			#rHorseTwist			
		)
		
		for o in types do (
			for p = 1 to loopCount do (
				if ( try ( obj == biped.getNode obj o link:p ) catch false ) do (
					returnType = (bipType limbName:o linkIndex:p)
					return returnType
				)
			)
		)
		
		-- 맥스 스크립트에서 Xtra 본을 전혀 지원하지 않아서 어쩔 수 없이 바이패드 클래스인데 정체를 알아내지 못한건 모두 Xtra로 정의
		-- https://forums.cgsociety.org/t/biped-xtra-maxscript-commands/1570351/5 숨겨진 바이패드 Xtra 함수들을 좀 살펴봐야할듯.
		return (bipType limbName:#xtra linkIndex:0)
	)
	
	-- 현재 오브젝트가 애니메이션 키 지정이 가능한 바이패드인지를 검사 true 와 false 리턴
	function IfKeyableBip obj =
	(
		if ( classof obj.baseobject != Biped_object ) do return false
		
		tType = GetBipedType obj
		
		returnBool = case tType.limbName of
		(
			#footprints: false
			#lfArmTwist: false
			#rfArmTwist: false
			#lUparmTwist: false
			#rUparmTwist: false
			#lThighTwist: false
			#rThighTwist: false
			#lCalfTwist: false
			#rCalfTwist: false
			#lHorseTwist: false
			#rHorseTwist: false
			default: true
		)
		return returnBool
	)
	
	-- 바이패드 부위들 중 Limb, COM, NoKey, Etc 를 구분하여 리턴 (애니메이션 키 복제 방식이 다름)
	function GetBipKeyType obj = (
		if ( classof obj.baseobject != Biped_object ) do return false
		
		tType = GetBipedType obj

		if tType.limbName == #vertical OR\
			tType.limbName == #horizontal OR\
			tType.limbName == #turn do (
			return "COM"
		)

		if tType.limbName == #larm OR\
			tType.limbName == #rarm OR\
			tType.limbName == #lleg OR\
			tType.limbName == #rleg OR\
			tType.limbName == #ltoes OR\
			tType.limbName == #rtoes do (
				return "Limb"
		)

		if tType.limbName == #lfArmTwist OR\
			tType.limbName == #rfArmTwist OR\
			tType.limbName == #lUparmTwist OR\
			tType.limbName == #rUparmTwist OR\
			tType.limbName == #lThighTwist OR\
			tType.limbName == #rThighTwist OR\
			tType.limbName == #lCalfTwist OR\
			tType.limbName == #rCalfTwist OR\
			tType.limbName == #lHorseTwist OR\
			tType.limbName == #rHorseTwist OR\
			tType.limbName == #footprints do (
				return "NoKey"
		)
		
		return "Etc"
	)

	-- 바이패드 Limb 전용 기능을 위해 Limb 인지 체크하는 함수
	function IfLimb obj = (
		if ( classof obj.baseobject != Biped_object ) do return false
		tType = GetBipedType obj
		if tType.limbName == #larm OR\
			tType.limbName == #rarm OR\
			tType.limbName == #lleg OR\
			tType.limbName == #rleg OR\
			tType.limbName == #ltoes OR\
			tType.limbName == #rtoes do (
				return true
		)
		return false
	)
	
    fn DeselectAllKeys obj = (
		-- 처음엔 복잡한 방법으로 일일이 키 하나씩 루프 돌아가며 선택 해제했는데, 뭉뚱그려서 controller 로 하니 잘 되는듯
		deselectKeys obj.controller
	)
	
	-- 이 함수는 삭제 전 Deselect 는 고려하지 않음. (기존에 Deselect 되어서 진입한 것을 전제로 함)
	fn TrimKeys controller frameStart frameEnd ifBip = (
		local firstKeyTime
		local lastKeyTime
		if (ifBip) then (
			local keyCount = numKeys controller
			if keyCount < 1 do return()
			firstKeyTime = (getKey controller 1).time
			lastKeyTime = (getKey controller keyCount).time
		)
		else (
			firstKeyTime = -99999
			lastKeyTime = 99999
		)

		if (firstKeyTime < frameStart) do (
			-- 보존 구간보다 앞쪽에 키가 있는 경우
			selectKeys controller (interval firstKeyTime (frameStart - 1))
		)
		if (lastKeyTime > frameEnd) do (
			-- 보존 구간보다 뒤쪽에 키가 있는 경우
			selectKeys controller (interval lastKeyTime (frameEnd + 1))
		)

		if (ifBip) then (
			biped.deleteKeys controller #selection
		)
		else (
			deleteKeys controller #selection
		)
	)

    -- obj 의 모든 자식들을 배열로 리턴. 배열 순서는 계층구조 순서대로
	function fnGetAllChildren obj = (
		if ( obj == undefined ) do return undefined
		
		local tAllChildren = #()
		if ( obj.children.count != 0 ) do (
			for o in obj.children do (
				append tAllChildren o
				if ( o.children.count != 0 ) do (
					tAllChildren = tAllChildren +  (fnGetAllChildren o)		-- recursive
				)
			)
		)
		return tAllChildren
	)

	fn fnSelAllChildrens arrObj =
	(
		clearselection()
		for o in arrObj where isvalidnode o do
		(
			selectmore o
			selectmore (fnGetAllChildren o)
		)
	)
	
    fn SetComBtnText state = (
        if state then (
            uiCOM.text = m_workingBipRoot.name
        )
        else (
            uiCOM.text = "COM"
        )
    )

    fn SetButtonState state = (
        uiHead.state = state
        uiRArms.state = state
        uiNecks.state = state
        uiLArms.state = state
        uiRClavicle.state = state
        uiLClavicle.state = state
        uiRUpArm.state = state
		uiAllSpine.state = state
		uiSpine2.state = state
		uiSpine1.state = state
		uiSpine0.state = state
        uiLUpArm.state = state
        uiRForArm.state = state
        uiLForArm.state = state
        uiRHand.state = state
        uiCOM.state = state
        if state == false do uiCOM.text = "COM"
        uiLHand.state = state
        uiPelvis.state = state
        uiRThigh.state = state
        uiLThigh.state = state
        uiRCalf.state = state
        uiLCalf.state = state
        uiRFoot.state = state
		uiLFoot.state = state
		uiRToe.state = state
		uiLToe.state = state
        uiRLegs.state = state
        uiAllFoot.state = state
        uiLLegs.state   = state
		-- uiAllBip.state = state
		uiPlayBlock.state = state
		uiFingers.state   = state
		uiPropR.state      = state
		uiPivot.state     = state
		uiPropL.state     = state
		uiCkbHideBip.state = state
		uiCkbXray.state = state
		uiCkbShowBox.state = state
		uiCkbZen.state = state
		uiCbtMirrorLLeg.state = state
		uiCbtMirrorRLeg.state = state
		uiCbtMirrorLArm.state = state
		uiCbtMirrorRArm.state = state
    )

	-- 씬 내 바이패드 오브젝트를 모두 조사하여 바이패드가 하나만 있으면 그 바이패드를 m_workingBipRoot에 세팅.
	-- 현재 선택된 오브젝트가 바이패드면 그것을 세팅
	-- 선택이 성공하면 true, 실패하면 false 리턴
	function AutoGetBipRoot = 
	(
		if rolBsBipedTools.ddlAllBipedCom.selection != 0 then 
		(
			bipedCom = arrAllBipedCom[rolBsBipedTools.ddlAllBipedCom.selection]
			if not isDeleted bipedCom and isvalidnode bipedCom then 
			(
				if ( try(classof bipedCom.baseobject == Biped_object) catch false ) do (
					try
					(
						m_workingBipRoot = bipedCom.controller.rootnode
						SetComBtnText true
						return true
					)
					catch()
				)
			)
		)
		for o in objects where not isDeleted o and isvalidnode o do (
			try(
				if (classof o.baseobject == Biped_object) do (
					m_workingBipRoot = o.controller.rootnode
					SetComBtnText true
					if not isDeleted m_workingBipRoot then return true
				)
			)catch()
		)
		m_workingBipRoot = undefined -- 씬을 새로 오픈한다거나 하면 삭제된 오브젝트를 기억하고 있을 수 있어서 (undefined 아님) 반드시 undefined 로 초기화해줘야함.
		SetComBtnText false
		SetButtonState false
		return false
	)

	fn fnGetDisplayNames =
	(
		local a_displayNames = deepCopy a_layerNames
		for i = 1 to a_displayNames.count-1 do
		(
			if (biped.getLayerActive ctrl i) then
			(
				a_displayNames[i+1] = a_layerNames[i+1]
			)
			else
			(
				a_displayNames[i+1] = "* " + a_layerNames[i+1]
			)	
		)
		
		a_displayNames
	)

	fn fnSyncBipedPanel =
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do (return ())
		numLayers = biped.numLayers m_workingBipRoot.controller
		layerIndex = biped.getCurrentLayer m_workingBipRoot.controller
	)

	fn fnIsValidBiped =
	(
		if m_workingBipRoot != undefined AND NOT isDeleted m_workingBipRoot then
		(
			return true
		)
		return false
	)
	
	mapped fn fnProcessTCB obj val =
	(
		if fnIsValidBiped() then
		(
			try
			(
				if obj == m_workingBipRoot then
				(
					(biped.getKey obj.controller[1].controller (getkeyindex obj.controller[1].controller slidertime)).continuity = val
					(biped.getKey obj.controller[2].controller (getkeyindex obj.controller[2].controller slidertime)).continuity = val
					(biped.getKey obj.controller[3].controller (getkeyindex obj.controller[3].controller slidertime)).continuity = val
				)
				else
				(
					(biped.getKey obj.controller (getkeyindex obj.controller slidertime)).continuity = val
				)
			)catch()
		)
	)

	fn fnEvaluateTCB val =
	(
		if fnIsValidBiped() then
		(
			if selection.count > 0 do
			(
				if keyboard.shiftPressed OR keyboard.controlPressed then
				(
					slidertime = 0
					for t = animationRange.start to animationRange.end while not keyboard.escPressed do
					(
						at time t (rolBsBipedTools.fnProcessTCB (selection as array) val)
						slidertime += 1
					)
					messagebox "所选物体的 TCB 值批量处理完毕。" title:"BsBipedTools"
				)
				else
				(
					rolBsBipedTools.fnProcessTCB (selection as array) val
				)
			)
		)
	)

	fn fnBSUpdateLayers =
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do (return ())
		if fnIsValidBiped() then
		(
			ctrl = m_workingBipRoot.controller
			if m_LHand[1] != undefined then uiCbtLeftArm.checked = biped.getLimbRetargetState m_LHand[1]
			if m_RHand[1] != undefined then uiCbtRightArm.checked = biped.getLimbRetargetState m_RHand[1]
			if m_LFoot[1] != undefined then uiCbtLeftLeg.checked = biped.getLimbRetargetState m_LFoot[1]
			if m_RFoot[1] != undefined then uiCbtRightLeg.checked = biped.getLimbRetargetState m_RFoot[1]
			a_layerNames = #(("# "+(biped.getLayerName ctrl 0)+" #"))
			numLayers = biped.numLayers ctrl
			if numLayers > 0 then
			(
				layerIndex = biped.getCurrentLayer ctrl
				uiLblLayerID.text = layerIndex as string
				for i = 1 to numLayers do
				(
					append a_layerNames (biped.getLayerName ctrl i)
				)
				if numLayers > 1 then
				(
					uiCbtLeftArm.enabled  = false
					uiCbtRightArm.enabled = false
					uiCbtLeftLeg.enabled  = false
					uiCbtRightLeg.enabled = false
					uiCbtLeftArm.images   = #("bip_layer_i.bmp","bip_layer_i.bmp",24,18,18,18,18,true,true)
					uiCbtRightArm.images  = #("bip_layer_i.bmp","bip_layer_i.bmp",24,20,20,20,20,true,true)
					uiCbtLeftLeg.images   = #("bip_layer_i.bmp","bip_layer_i.bmp",24,22,22,22,22,true,true)
					uiCbtRightLeg.images  = #("bip_layer_i.bmp","bip_layer_i.bmp",24,24,24,24,24,true,true)
				)
				else
				(
					uiCbtLeftArm.enabled  = true
					uiCbtRightArm.enabled = true
					uiCbtLeftLeg.enabled  = true
					uiCbtRightLeg.enabled = true
					uiCbtLeftArm.images   = #("bip_layer_i.bmp","bip_layer_i.bmp",24,17,17,17,17,true,true)
					uiCbtRightArm.images  = #("bip_layer_i.bmp","bip_layer_i.bmp",24,19,19,19,19,true,true)
					uiCbtLeftLeg.images   = #("bip_layer_i.bmp","bip_layer_i.bmp",24,21,21,21,21,true,true)
					uiCbtRightLeg.images  = #("bip_layer_i.bmp","bip_layer_i.bmp",24,23,23,23,23,true,true)
				)
			)
			else
			(
				layerIndex = 0
				uiLblLayerID.text = "0"
				uiChkActive.enabled = false
			)

			if layerIndex > 0 then
			(
				uiChkActive.enabled = true
				uiChkActive.checked = (biped.getLayerActive ctrl layerIndex)
				uiCbtDelLayer.enabled = true
				uiCbtDownLayer.enabled = true
				uiCbtSnapKeys.enabled = true
				uiCbtDelLayer.images  = #("bip_layer_i.bmp","bip_layer_i.bmp",24,7,7,7,7,true,true)
				uiCbtDownLayer.images = #("bip_layer_i.bmp","bip_layer_i.bmp",24,13,13,13,13,true,true)
				uiCbtSnapKeys.images  = #("bip_layer_i.bmp","bip_layer_i.bmp",24,15,15,15,15,true,true)
			)
			else
			(
				uiChkActive.enabled = false
				uiCbtDelLayer.enabled = false
				uiCbtDownLayer.enabled = false
				uiCbtSnapKeys.enabled = false
				uiCbtDelLayer.images  = #("bip_layer_i.bmp","bip_layer_i.bmp",24,8,8,8,8,true,true)
				uiCbtDownLayer.images = #("bip_layer_i.bmp","bip_layer_i.bmp",24,14,14,14,14,true,true)
				uiCbtSnapKeys.images  = #("bip_layer_i.bmp","bip_layer_i.bmp",24,16,16,16,16,true,true)
			)
			
			ddlLayers.items = fnGetDisplayNames()
			ddlLayers.selection = layerIndex + 1
		)
		else
		(
			layerIndex = 0
			numLayers = 0
			uiLblLayerID.text = ""
			ddlLayers.items = #("")
			ddlLayers.selection = 1
			uiChkActive.enabled = false
		)
		
		if layerIndex == numLayers then
		(
			uiCbtUp.enabled = false
			uiCbtUp.images = #("bip_layer_i.bmp","bip_layer_i.bmp",24,2,2,2,2,true,true)
		)
		else 
		(
			uiCbtUp.enabled = true
			uiCbtUp.images = #("bip_layer_i.bmp","bip_layer_i.bmp",24,1,1,1,1,true,true)
		)
		if layerIndex == 0 then
		(
			uiCbtDown.enabled = false
			uiCbtDown.images = #("bip_layer_i.bmp","bip_layer_i.bmp",24,4,4,4,4,true,true)
		)
		else
		(
			uiCbtDown.enabled = true
			uiCbtDown.images = #("bip_layer_i.bmp","bip_layer_i.bmp",24,3,3,3,3,true,true)
		)
		redrawViews()
	)

	fn fnLockComTrack com =
	(
		with redraw off 
		(
			-- max motion mode
			theactionman = actionMan.executeAction
			tableId = 972555510
			-- max select
			theactionman tableId "40185"
			numTrackSel = com.controller.trackSelection
			if numTrackSel != 7 then (com.controller.trackSelection = 7)
			else if numTrackSel == 7 then (com.controller.trackSelection = 0)
			-- max move
		)
	)

	fn fnGetComTrackSelection com =
	(
		case com.controller.trackSelection of
		(
			1:(return [1,0,0])
			2:(return [0,1,0])
			3:(return [0,0,1])
			4:(return [1,1,0])
			5:(return [1,0,1])
			6:(return [0,1,1])
			7:(return [1,1,1])
			default:(return [0,0,0])
		)
	)

	-- fn fnSetComTrackSelection com =
	-- (
	-- 	numTrackSel = 0
	-- 	typeTrackSel = [0,0,0]
	-- 	typeTrackSel[1] = if rolBsBipedTools.uiCbtHorTrack.state then 1 else 0
	-- 	typeTrackSel[2] = if rolBsBipedTools.uiCbtVerTrack.state then 1 else 0
	-- 	typeTrackSel[3] = if rolBsBipedTools.uiCbtTurnTrack.state then 1 else 0
	-- 	case typeTrackSel of 
	-- 	(
	-- 		([1,0,0]):(numTrackSel = 1)
	-- 		([0,1,0]):(numTrackSel = 2)
	-- 		([0,0,1]):(numTrackSel = 3)
	-- 		([1,1,0]):(numTrackSel = 4)
	-- 		([1,0,1]):(numTrackSel = 5)
	-- 		([0,1,1]):(numTrackSel = 6)
	-- 		([1,1,1]):(numTrackSel = 7)
	-- 		default:(numTrackSel = 0)
	-- 	)
	-- 	if numTrackSel >= 5 and numTrackSel <= 7 then (fnLockComTrack com)
	-- 	com.controller.trackSelection = numTrackSel
	-- )

	fn fnRefreshTrackSelection com =
	(
		if fnIsValidBiped() then
		(
			typeTrackSel = rolBsBipedTools.fnGetComTrackSelection com
			if selection.count == 0 then typeTrackSel = [0,0,0]
			rolBsBipedTools.uiCbtHorTrack.state  = if typeTrackSel[1] == 1 then true else false
			rolBsBipedTools.uiCbtVerTrack.state  = if typeTrackSel[2] == 1 then true else false
			rolBsBipedTools.uiCbtTurnTrack.state = if typeTrackSel[3] == 1 then true else false
		)
	)

	-- 배열 빼기
	function ArraySubtract arrFrom arrSub = (
		if arrSub.count == 0 do (return arrFrom)
		
		for o in arrSub do (
			foundNum = findItem arrFrom o
			if foundNum != 0 do (
				deleteItem arrFrom foundNum
			)
		)
		return arrFrom
	)
	
	-- 기존 selection 백업과 이번에 선택할 selArr 을 입력받아 적절하게 선택한다. 부수적으로 모션패널로의 변경도 같이 수행
    -- selBackup 을 사용할지는 미정
    -- selBackup 은 selection as array
	function CompSelect selBackup selArr = (
		-- 단축키 조합이 아무것도 눌러져있지 않으면 빠르게 그냥 선택 후 리턴
		if (keyboard.controlPressed == false) and (keyboard.altPressed == false) and (keyboard.shiftPressed == false) do (
			undo on (
				select selArr
			)
			return()
		)

		if keyboard.shiftPressed do 
		(
			fnSelAllChildrens selArr
			return()
		)

		if keyboard.controlPressed and not keyboard.altPressed do (
			selArr += selBackup
		)
		
		if keyboard.altPressed and not keyboard.controlPressed do (
			selArr = ArraySubtract selBackup selArr
		)
		
		undo on (
			if selArr.count == 0 then (
				clearSelection()
			)
			else (
				--setCommandPanelTaskMode mode:#motion
				select selArr
			)
		)
	)

	-- 바이패드 배열이 정상적인지 체크하여 리턴
	fn IfExistBips bipArr = (
		if (bipArr == undefined) do return false
		if (bipArr.count == 0) do return false
		for obj in bipArr do (
			-- 삭제된 오브젝트에 대해 처리하려고 하면 에러가 나므로 try 처리
			try (
				if (obj == undefined) do return false
				if ((classof obj.baseobject) != Biped_Object) do return false
			) catch (return false)
		)
		return true
	)

	-- 이하 바이패드 부위들을 얻어오는 함수들은 m_workingBipRoot를 대상으로 작동
	fn GetHead = (
		selObj = biped.getNode m_workingBipRoot #head
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetRArms = (
		tArr = #()
		for i = 1 to 4 do (
			selObj = biped.getNode m_workingBipRoot #rarm link:i
			if selObj != undefined do -- 바이패드 스트럭처 설정에 따라 팔이 없는 등 예외가 있을 수 있음
			(
				if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state do (
					append tArr selObj
				)
			)
		)
		return tArr
	)
	fn GetNecks = (
		tArr = #()
		testBool = true
		tIndex = 1
		while testBool do (
			selObj = biped.getNode m_workingBipRoot #neck link:tIndex
			if ( selObj == undefined ) then (
				testBool = false
			)
			else (
				if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state do (
					append tArr selObj
				)
			)
			tIndex += 1
		)
		return tArr
	)
	fn GetLArms = (
		tArr = #()
		for i = 1 to 4 do (
			selObj = biped.getNode m_workingBipRoot #larm link:i
			if selObj != undefined do -- 바이패드 스트럭처 설정에 따라 팔이 없는 등 예외가 있을 수 있음
			(
				if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state do (
					append tArr selObj
				)
			)
		)
		return tArr
	)
	fn GetRClavicle = (
		selObj = biped.getNode m_workingBipRoot #rarm link:1
		if selObj == undefined do -- 바이패드 스트럭처 설정에 따라 팔이 없는 등 예외가 있을 수 있음
		(
			return #()
		)
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetLClavicle = (
		selObj = biped.getNode m_workingBipRoot #larm link:1
		if selObj == undefined do -- 바이패드 스트럭처 설정에 따라 팔이 없는 등 예외가 있을 수 있음
		(
			return #()
		)
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetRUpArm = (
		selObj = biped.getNode m_workingBipRoot #rarm link:2
		if selObj == undefined do -- 바이패드 스트럭처 설정에 따라 팔이 없는 등 예외가 있을 수 있음
		(
			return #()
		)
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetAllSpine = (
		tArr = #()
		testBool = true
		tIndex = 1
		while testBool do (
			selObj = biped.getNode m_workingBipRoot #spine link:tIndex
			if ( selObj == undefined ) then (
				testBool = false
			)
			else (
				if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state do (
					append tArr selObj
				)
			)
			tIndex += 1
		)
		return tArr
	)
	fn GetSpine index = (
		selObj = biped.getNode m_workingBipRoot #spine link:(index + 1)
		if selObj == undefined do return #()
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetLUpArm = (
		selObj = biped.getNode m_workingBipRoot #larm link:2
		if selObj == undefined do -- 바이패드 스트럭처 설정에 따라 팔이 없는 등 예외가 있을 수 있음
		(
			return #()
		)
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetRForArm = (
		selObj = biped.getNode m_workingBipRoot #rarm link:3
		if selObj == undefined do -- 바이패드 스트럭처 설정에 따라 팔이 없는 등 예외가 있을 수 있음
		(
			return #()
		)
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetLForArm = (
		selObj = biped.getNode m_workingBipRoot #larm link:3
		if selObj == undefined do -- 바이패드 스트럭처 설정에 따라 팔이 없는 등 예외가 있을 수 있음
		(
			return #()
		)
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetRHand = (
		selObj = biped.getNode m_workingBipRoot #rarm link:4
		if selObj == undefined do -- 바이패드 스트럭처 설정에 따라 팔이 없는 등 예외가 있을 수 있음
		(
			return #()
		)
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	--fn GetCOM = ()
	fn GetLHand = (
		selObj = biped.getNode m_workingBipRoot #larm link:4
		if selObj == undefined do -- 바이패드 스트럭처 설정에 따라 팔이 없는 등 예외가 있을 수 있음
		(
			return #()
		)
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetPelvis = (
		selObj = biped.getNode m_workingBipRoot #pelvis
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetRThigh = (
		selObj = biped.getNode m_workingBipRoot #rleg link:1
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetLThigh = (
		selObj = biped.getNode m_workingBipRoot #lleg link:1
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetRCalf = (
		selObj = biped.getNode m_workingBipRoot #rleg link:2
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetLCalf = (
		selObj = biped.getNode m_workingBipRoot #lleg link:2
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetRFoot = (
		local footIndex = 4 -- HorseLink가 있는 경우
		if (biped.getNode m_workingBipRoot #rleg link:4) == undefined do (
			footIndex = 3
		)
		selObj = biped.getNode m_workingBipRoot #rleg link:footIndex
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetLFoot = (
		local footIndex = 4 -- HorseLink가 있는 경우
		if (biped.getNode m_workingBipRoot #lleg link:4) == undefined do (
			footIndex = 3
		)
		selObj = biped.getNode m_workingBipRoot #lleg link:footIndex
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetRToe = (
		selObj = biped.getNode m_workingBipRoot #rtoes link:1
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetLToe = (
		selObj = biped.getNode m_workingBipRoot #ltoes link:1
		if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
			return #(selObj)
		)
		else (
			return #()
		)
	)
	fn GetRLegs = (
		tArr = #()
		for i = 1 to 4 do (
			selObj = biped.getNode m_workingBipRoot #rleg link:i
			if selObj != undefined do (		-- HorseLink 가 있기도 하고 없기도 할 수 있음
				if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state do (
					append tArr selObj
				)
			)
		)
		append tArr (biped.getNode m_workingBipRoot #rtoes link:1)
		return tArr
	)
	fn GetAllFoot = (
		tArr = #()
		selObj = GetLFoot()
		if ( selObj[1].isHidden == false ) or uiChkSelHiddenObj.state do ( append tArr selObj[1] )
		selObj = GetRFoot()
		if ( selObj[1].isHidden == false ) or uiChkSelHiddenObj.state do ( append tArr selObj[1] )
		return tArr
	)
	fn GetLLegs = (
		tArr = #()
		for i = 1 to 4 do (
			selObj = biped.getNode m_workingBipRoot #lleg link:i
			if selObj != undefined do (		-- HorseLink 가 있기도 하고 없기도 할 수 있음
				if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state do (
					append tArr selObj
				)
			)
		)
		append tArr (biped.getNode m_workingBipRoot #ltoes link:1)
		return tArr
	)
	fn GetAllBip = (
		local retBips = #()
		for o in objects do (
			if ( classof o.baseobject == Biped_object ) and \
			((classof o.controller == Vertical_Horizontal_Turn) or (classof o.controller == BipSlave_Control)) do
			(
				-- 같은Bip001의 자식이면
				if ( o.controller.rootNode == m_workingBipRoot AND (classof o.controller) != Footsteps) do
				(
					append retBips o
				)
			)
		)
		return retBips
	)

	fn GetLProp =
	(
		selObj = biped.getNode m_workingBipRoot #prop2 link:1
		if selObj != undefined then
		(
			if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
				return #(selObj)
			)
			else (
				return #()
			)
		)
		else
		(
			return #()
		)
	)
	
	fn GetRProp =
	(
		selObj = biped.getNode m_workingBipRoot #prop1 link:1
		if selObj != undefined then
		(
			if ( selObj.isHidden == false ) or uiChkSelHiddenObj.state then (
				return #(selObj)
			)
			else (
				return #()
			)
		)
		else
		(
			return #()
		)
	)

	-- Go to Mirror frame 버튼이 작동하기 위한 조건 검사 후 버튼 enable 세팅
	-- 루핑 구간 프레임이 짝수여야하고 일정 수 이상이여야함
	fn SetGotoMirrorEnable = (
		--uiBtnGotoMirror
		local fCount = uiSpnLoopEnd.value - uiSpnLoopStart.value
		if (fCount < 2) do (
			uiBtnGotoMirror.enabled = false
			return ()
		)

		local fCountHalf = fCount / 2.0
		-- 홀수인지?
		if float (int fCountHalf) != fCountHalf do (
			uiBtnGotoMirror.enabled = false
			return ()
		)
		uiBtnGotoMirror.enabled = true
	)
    
	-- 작업용 바이패드 루트 노드라던가, 선택용 배열 변수 등을 미리 세팅
	function InitLocalVars = (
		try(arrAllBipedCom = rolBsBipedTools.fnGetAllBipedCom())catch()
		-- print arrAllBipedCom
		rolBsBipedTools.ddlAllBipedCom.items = for i in arrAllBipedCom where not isDeleted i and i.name != undefined collect i.name
		for i in (selection as array) where (selection.count != 0 and (isValidNode i) and (iskindof i.baseobject Biped_Object) and \
		((classof i.controller == Vertical_Horizontal_Turn) or (classof i.controller == BipSlave_Control)) ) do 
		(
			selBipedId = finditem arrAllBipedCom i.controller.rootnode
			rolBsBipedTools.ddlAllBipedCom.selection = selBipedId
			exit
		)
		--uiBtnLoopDupe.enabled = false -- 개발중인 기능 봉인
		AutoGetBipRoot()
        if m_workingBipRoot == undefined then (
            SetButtonState false
            return ()
        )
        else (
            SetButtonState true
		)
		uiChkBtnScanBiped.text = "Scanning..."
		
		-- 모든 부위 변수들은 배열
		m_Head = GetHead()
		m_RArms = GetRArms()
		if (m_RArms.count == 0) then (uiRArms.enabled = false; uiRArms.state = false) else (uiRArms.enabled = true; uiRArms.state = true)
		m_Necks = GetNecks()
		m_LArms = GetLArms()
		if (m_LArms.count == 0) then (uiLArms.enabled = false; uiLArms.state = false) else (uiLArms.enabled = true; uiLArms.state = true)
		m_RClavicle = GetRClavicle()
		if (m_RClavicle.count == 0) then (uiRClavicle.enabled = false; uiRClavicle.state = false) else (uiRClavicle.enabled = true; uiRClavicle.state = true)
		m_LClavicle = GetLClavicle()
		if (m_LClavicle.count == 0) then (uiLClavicle.enabled = false; uiLClavicle.state = false) else (uiLClavicle.enabled = true; uiLClavicle.state = true)
		m_RUpArm = GetRUpArm()
		if (m_RUpArm.count == 0) then (uiRUpArm.enabled = false; uiRUpArm.state = false) else (uiRUpArm.enabled = true; uiRUpArm.state = true)
		m_AllSpine = GetAllSpine()
		m_Spine2 = GetSpine 2
		if (m_Spine2.count == 0) then (uiSpine2.enabled = false; uiSpine2.state = false) else (uiSpine2.enabled = true; uiSpine2.state = true)
		m_Spine1 = GetSpine 1
		if (m_Spine1.count == 0) then (uiSpine1.enabled = false; uiSpine1.state = false) else (uiSpine1.enabled = true; uiSpine1.state = true)
		m_Spine0 = GetSpine 0
		if (m_Spine0.count == 0) then (uiSpine0.enabled = false; uiSpine0.state = false) else (uiSpine0.enabled = true; uiSpine0.state = true)
		m_LUpArm = GetLUpArm()
		if (m_LUpArm.count == 0) then (uiLUpArm.enabled = false; uiLUpArm.state = false) else (uiLUpArm.enabled = true; uiLUpArm.state = true)
		m_RForArm = GetRForArm()
		if (m_RForArm.count == 0) then (uiRForArm.enabled = false; uiRForArm.state = false) else (uiRForArm.enabled = true; uiRForArm.state = true)
		m_LForArm = GetLForArm()
		if (m_LForArm.count == 0) then (uiLForArm.enabled = false; uiLForArm.state = false) else (uiLForArm.enabled = true; uiLForArm.state = true)
		m_RHand = GetRHand()
		if (m_RHand.count == 0) then (uiRHand.enabled = false; uiRHand.state = false) else (uiRHand.enabled = true; uiRHand.state = true)
		--m_COM = GetCOM()
		m_LHand = GetLHand()
		if (m_LHand.count == 0) then (uiLHand.enabled = false; uiLHand.state = false) else (uiLHand.enabled = true; uiLHand.state = true)
		m_Pelvis = GetPelvis()
		m_RThigh = GetRThigh()
		m_LThigh = GetLThigh()
		m_RCalf = GetRCalf()
		m_LCalf = GetLCalf()
		m_RFoot = GetRFoot()
		m_LFoot = GetLFoot()
		m_RToe = GetRToe()
		m_LToe = GetLToe()
		m_RLegs = GetRLegs()
		m_AllFoot = GetAllFoot()
		m_LLegs = GetLLegs()
		m_AllBip = GetAllBip()
		m_LProp = GetLProp()
		m_RProp = GetRProp()

		uiChkBtnScanBiped.text = "All Biped"

		LoadRangeLoop()
		-- LoadRangeA()
		-- LoadRangeB()
		-- LoadGoto()
		-- SetGotoBtnText()

		uiDropPlaySpeed.selection = timeConfiguration.playbackSpeed

        SetGotoMirrorEnable ()
        
        uiPlayBlock.state = false
		clock.active = false
		m_PBKeyTimeArray = #()
		m_PBKeyMiliSecArray = #()
        SetPBPlaySpeed()
		if selection.count == 1 then 
		(
			try
			(
				uiFigureMode.state = $.controller.rootnode.controller.figureMode
				uiBtnInPlace.state = false
				if $.controller.rootnode.controller.inPlaceYMode == true then
				(
					uiBtnInPlace.images = #("bip_general_i.bmp","bip_general_i.bmp",30,27,27,27,27,true,true)
					uiBtnInPlace.state = true
				)
				else if $.controller.rootnode.controller.inPlaceMode == true then
				(
					uiBtnInPlace.images = #("bip_general_i.bmp","bip_general_i.bmp",30,23,23,23,23,true,true)
					uiBtnInPlace.state = true
				)
			)
			catch
			(
				uiFigureMode.state = false
				uiBtnInPlace.state = false
			)
		)
		else 
		(
			uiFigureMode.state = false
			uiBtnInPlace.state = false
		)
		fnRefreshTrackSelection m_workingBipRoot
		fnSyncBipedPanel()
		fnBSUpdateLayers()
	)

	-- 보정치 회전값을 입력받고 똑바로 펴주는 기능을 한다. bips는 배열. 보정치 회전값은 Toe 등에서 90도 추가 회전이 필요함
	function Straighten bips offsetRotation = (
		for bip in bips do (
			if (bip != undefined AND (isDeleted bip) == false) do (
				biped.setTransform bip #rotation (offsetRotation * bip.parent.transform.rotation) animButtonState
			)
		)
	)

	-- Straighten 함수와 같은 기능이지만 부모 대신에 다른 프록시 오브젝트를 기준으로 한다.
	-- 바이패드의 Triangle Pelvis 옵션때문에 허벅지 부모가 척추인 경우가 종종 있어서 강제로 Pelvis를 지정
	function StraightenByProxy bips proxy offsetRotation = (
		for bip in bips do (
			if (bip != undefined AND (isDeleted bip) == false) do (
				biped.setTransform bip #rotation (offsetRotation * proxy.transform.rotation) animButtonState
			)
		)
	)

	fn fnMsgMissingBiped =
	(
		messageBox "错误：场景中缺少先前选择的 Biped！已重启工具！                                                " title:"BsBipedTools"
		setIniSetting iniBsBipedTools "BipedPanel" "CurrentBip" "1"
		try (destroydialog rolBsBipedTools) catch()
		if (iniBsBTPos != 0) then 
		(Createdialog rolBsBipedTools pos:iniBsBTPos style:#() fgcolor:(if fnGetThemeColor() == "Light" then (color 28 89 177) else (color 165 222 228)))
		else (Createdialog rolBsBipedTools style:#() fgcolor:(if fnGetThemeColor() == "Light" then (color 28 89 177) else (color 165 222 228)))
	)

	fn fnMirrorPosture a_bipObjs =
	(
		if isValidNode m_workingBipRoot AND NOT isDeleted m_workingBipRoot then
		(
			local bRootCtrl = m_workingBipRoot.controller
			biped.createCopyCollection bRootCtrl "MirrorTemp"
			local colIndex = biped.numCopyCollections bRootCtrl
			local copyCol = biped.getCopyCollection bRootCtrl colIndex
			biped.copyBipPosture bRootCtrl copyCol a_bipObjs #snapAuto
			local mirroreBH_pose = getCopy copyCol #posture 1
			with Animate on
			(
				biped.pasteBipPosture bRootCtrl mirroreBH_pose true #pstdefault false false false false
			)
			biped.deleteCopyCollection bRootCtrl colIndex
		)
	)
	
	fn fnStorePostureObjs a_objs =
	(
		local txtFile = openFile postureObjsFile mode:"w"
		for obj in a_objs do
		(
			format "%\n" obj.name to:txtFile
		)
		close txtFile
	)
	
	fn fnRetrievePostureObjs =
	(
		if doesFileExist postureObjsFile do
		(
			local a_objs = #()
			local txtFile = openFile postureObjsFile mode:"r"
			while NOT eof txtFile do
			(
				append a_objs (getNodeByName (readLine txtFile))
			)
			close txtFile
			a_objs
		)
	)
	
	fn fnFilterBipedParts a_selObjs =
	(
		local a_bipedParts = #()
		
		for obj in a_selObjs do
		(
			if classof obj.baseObject == Biped_Object do
			(
				append a_bipedParts obj
			)
		)
		a_bipedParts
	)

	on uiCbtCopy changed state do
	(
		uiCbtCopy.state = true
		if selection.count > 0 then
		(
			local a_objs = selection as array
			--// Make sure only Biped parts are selected for copying by filtering out non-Biped parts
			a_objs = fnFilterBipedParts a_objs
			if a_objs.count > 0 then
			(
				fnStorePostureObjs a_objs
				if isValidNode m_workingBipRoot AND NOT isDeleted m_workingBipRoot then
				(
					local bRootCtrl = m_workingBipRoot.controller
					biped.createCopyCollection bRootCtrl "CopyPosture"
					local colIndex = biped.numCopyCollections bRootCtrl
					local copyCol = biped.getCopyCollection bRootCtrl colIndex
					biped.copyBipPosture bRootCtrl copyCol a_objs #snapAuto
					biped.saveCopyPasteFile bRootCtrl (getDir #plugcfg + "\BsBipedTools_CopyPosture.cpy")
					biped.deleteCopyCollection bRootCtrl colIndex
				)
			)
			else
			(
				messageBox "错误：没有选择 Biped 对象。                       " title:"BsBipedTools"
			)
		)
		else
		(
			messageBox "错误：请选择一些要复制的 Biped 对象。                            " title:"BsBipedTools"
		)
	)
	
	on uiCbtPaste changed state do
	(
		uiCbtPaste.state = true
		if isValidNode m_workingBipRoot AND NOT isDeleted m_workingBipRoot then
		(
			local postureFile = getDir #plugcfg + "\BsBipedTools_CopyPosture.cpy"
			if doesFileExist postureFile then
			(
				local bRootCtrl = m_workingBipRoot.controller
				biped.loadCopyPasteFile bRootCtrl postureFile
				local colIndex = biped.numCopyCollections bRootCtrl
				local copyCol = biped.getCopyCollection bRootCtrl colIndex
				local copieBH_posture = getCopy copyCol #posture 1
				with Animate on
				(
					biped.pasteBipPosture bRootCtrl copieBH_posture false #pstdefault false false false false
				)
				local colIndex = biped.numCopyCollections bRootCtrl
				biped.deleteCopyCollection bRootCtrl colIndex
			)
			else
			(
				messageBox "错误: 临时 Pose 文件不存在，请先暂存Pose！                              " title:"BsBipedTools"
			)
		)
	)

	on uiCbtPasteOpposite changed state do
	(
		uiCbtPasteOpposite.state = true
		if isValidNode m_workingBipRoot AND NOT isDeleted m_workingBipRoot then
		(
			local postureFile = getDir #plugcfg + "\BsBipedTools_CopyPosture.cpy"
			if doesFileExist postureFile then
			(
				local bRootCtrl = m_workingBipRoot.controller
				biped.loadCopyPasteFile bRootCtrl postureFile
				local colIndex = biped.numCopyCollections bRootCtrl
				local copyCol = biped.getCopyCollection bRootCtrl colIndex
				local copieBH_posture = getCopy copyCol #posture 1
				with Animate on
				(
					biped.pasteBipPosture bRootCtrl copieBH_posture true #pstdefault false false false false
				)
				local colIndex = biped.numCopyCollections bRootCtrl
				biped.deleteCopyCollection bRootCtrl colIndex
			)
			else
			(
				messageBox "错误: 临时 Pose 文件不存在，请先暂存Pose！                              " title:"BsBipedTools"
			)
		)
	)
	
	on uiCbtSelBones changed state do
	(
		uiCbtSelBones.state = true
		local a_objs = fnRetrievePostureObjs()
		if a_objs != undefined do
		(
			try (select a_objs)catch(messageBox "错误：无法选择用于复制姿势的 Biped 部件。                                            " title:"BsBipedTools")
		)
	)
	
	on uiCbtMirrorLArm changed state do
	(
		uiCbtMirrorLArm.state = true
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		-- local arrMirror = makeUniqueArray (m_LArms + m_LHand)
		fnMirrorPosture m_LArms
	)
	
	on uiCbtMirrorRArm changed state do
	(
		uiCbtMirrorRArm.state = true
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		-- local arrMirror = makeUniqueArray (m_RArms + m_RHand)
		fnMirrorPosture m_RArms
	)
	
	on uiCbtMirrorLLeg changed state do
	(
		uiCbtMirrorLLeg.state = true
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		fnMirrorPosture m_LLegs
	)
	
	on uiCbtMirrorRLeg changed state do
	(
		uiCbtMirrorRLeg.state = true
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		fnMirrorPosture m_RLegs
	)

	on uiChkBtnScanBiped changed state do (
		uiChkBtnScanBiped.state = true
		InitLocalVars() -- 작업용 바이패드 루트 노드라던가, 선택용 배열 변수 등을 미리 세팅
		if (m_workingBipRoot != undefined) do (select m_AllBip)
	)

	on uiBtnSetAllKey changed state do with undo on
	(
		uiBtnSetAllKey.state = true
		for i in selection as array where iskindof i.baseObject Biped_Object do
		(
			if ( classof i.controller == Vertical_Horizontal_Turn ) then
			(
				biped.addNewKey i.controller.vertical.controller slidertime
				biped.addNewKey i.controller.horizontal.controller slidertime
				biped.addNewKey (fnBipedComlocalization i.controller) slidertime
			)
			else 
			(
				try (biped.addNewKey i.controller sliderTime ) catch ()
			)
		)
	)
	
	on uiBtnSetAllKey rightclick do (
		uiBtnSetAllKey.state = true
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		if (m_workingBipRoot.transform.controller.figureMode) do (
			messageBox "不能在体形模式中添加关键帧。                              " title:"BsBipedTools"
			return ()
		)

		selBackup = selection as array

		-- 미리 저장한 배열에 문제가 있으면 다시 배열을 초기화
		if (IfExistBips m_AllBip) == false do (
			m_AllBip = GetAllBip()
		)
		if (IfExistBips m_AllBip) == false do return () -- 그래도 문제가 있으면 그냥 리턴
		
		undo on
		(
			for o in m_AllBip do
			(
				if ( o == m_workingBipRoot ) then
				(
					biped.addNewKey o.controller.vertical.controller slidertime
					biped.addNewKey o.controller.horizontal.controller slidertime
					biped.addNewKey (fnBipedComlocalization o.controller) slidertime
				)
				else
				(
					try ( biped.addNewKey o.controller slidertime ) catch ()		-- Footstep 오브젝트때문에 try 처리
				)
			) -- for end
		) -- undo end	
		clearSelection()
		select selBackup
	)

	on uiBtnLimbPK changed state do (
		uiBtnLimbPK.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		setCommandPanelTaskMode mode:#motion -- biped.setSlidingKey 등의 기능은 Motion판넬에서만 정상 작동한다. 다른 곳에서 하면 엉뚱한 자세가 덮어써짐
		local timeBefore = sliderTime
		disableSceneRedraw()
		undo on (
			for obj in selection do (
				if (IfLimb obj) do (
					if (keyboard.shiftPressed OR keyboard.controlPressed) then (
						local keys = obj.controller.keys
						local animRangeBackup = animationRange -- 잠시 바깥에 있는 키들도 수정할 수 있도록 현재의 애니메이션 구간을 기억한다.
						animationRange = Interval keys[1].time keys[keys.count].time
						for i = 1 to keys.count do (
							if keyboard.shiftPressed do (
								-- Shift가 눌려있으면 키 선택과 상관 없이 모두 변경
								sliderTime = keys[i].time -- at time 방식으로 하면 sliderTime의 자세로 키가 생성되는 문제가 있어서 실제 sliderTime을 변경시켜서 진행
								biped.SetPlantedKey obj
							)
							if keyboard.controlPressed do (
								-- Ctrl이 눌려있으면 선택된 키듦만 변경
								if keys[i].selected == true do (
									sliderTime = keys[i].time -- at time 방식으로 하면 sliderTime의 자세로 키가 생성되는 문제가 있어서 실제 sliderTime을 변경시켜서 진행
									biped.SetPlantedKey obj
								)
							)
						)
						animationRange = animRangeBackup -- 다시 원래대로의 애니메이션 구간으로 복구
					)
					else (
						biped.SetPlantedKey obj
					)
				)
			) -- for
		) -- Undo
		setCommandPanelTaskMode mode:#create
		enableSceneRedraw()
		sliderTime = timeBefore
	)

	on uiBtnLimbIK changed state do (
		uiBtnLimbIK.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		setCommandPanelTaskMode mode:#motion -- biped.setSlidingKey 등의 기능은 Motion판넬에서만 정상 작동한다. 다른 곳에서 하면 엉뚱한 자세가 덮어써짐
		local timeBefore = sliderTime
		disableSceneRedraw()
		undo on (
			for obj in selection do (
				if (IfLimb obj) do (
					if (keyboard.shiftPressed OR keyboard.controlPressed) then (
						local keys = obj.controller.keys
						local animRangeBackup = animationRange -- 잠시 바깥에 있는 키들도 수정할 수 있도록 현재의 애니메이션 구간을 기억한다.
						animationRange = Interval keys[1].time keys[keys.count].time
						for i = 1 to keys.count do (
							if keyboard.shiftPressed do (
								-- Shift가 눌려있으면 키 선택과 상관 없이 모두 변경
								sliderTime = keys[i].time -- at time 방식으로 하면 sliderTime의 자세로 키가 생성되는 문제가 있어서 실제 sliderTime을 변경시켜서 진행
								biped.setSlidingKey obj
							)
							if keyboard.controlPressed do (
								-- Ctrl이 눌려있으면 선택된 키듦만 변경
								if keys[i].selected == true do (
									sliderTime = keys[i].time -- at time 방식으로 하면 sliderTime의 자세로 키가 생성되는 문제가 있어서 실제 sliderTime을 변경시켜서 진행
									biped.setSlidingKey obj
								)
							)
						)
						animationRange = animRangeBackup -- 다시 원래대로의 애니메이션 구간으로 복구
					)
					else (
						biped.setSlidingKey obj
					)
				)
			) -- for
		) -- Undo
		setCommandPanelTaskMode mode:#create
		enableSceneRedraw()
		sliderTime = timeBefore
	)

	on uiBtnLimbFK changed state do (
		uiBtnLimbFK.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		setCommandPanelTaskMode mode:#motion -- biped.setSlidingKey 등의 기능은 Motion판넬에서만 정상 작동한다. 다른 곳에서 하면 엉뚱한 자세가 덮어써짐
		local timeBefore = sliderTime
		disableSceneRedraw()
		undo on (
			for obj in selection do (
				if (IfLimb obj) do (
					if (keyboard.shiftPressed OR keyboard.controlPressed) then (
						local keys = obj.controller.keys
						local animRangeBackup = animationRange -- 잠시 바깥에 있는 키들도 수정할 수 있도록 현재의 애니메이션 구간을 기억한다.
						animationRange = Interval keys[1].time keys[keys.count].time
						for i = 1 to keys.count do (
							if keyboard.shiftPressed do (
								-- Shift가 눌려있으면 키 선택과 상관 없이 모두 변경
								sliderTime = keys[i].time -- at time 방식으로 하면 sliderTime의 자세로 키가 생성되는 문제가 있어서 실제 sliderTime을 변경시켜서 진행
								biped.setFreeKey obj
							)
							if keyboard.controlPressed do (
								-- Ctrl이 눌려있으면 선택된 키듦만 변경
								if keys[i].selected == true do (
									sliderTime = keys[i].time -- at time 방식으로 하면 sliderTime의 자세로 키가 생성되는 문제가 있어서 실제 sliderTime을 변경시켜서 진행
									biped.setFreeKey obj
								)
							)
						)
						animationRange = animRangeBackup -- 다시 원래대로의 애니메이션 구간으로 복구
					)
					else (
						biped.setFreeKey obj
					)
				)
			) -- for
		) -- Undo
		setCommandPanelTaskMode mode:#create
		enableSceneRedraw()
		sliderTime = timeBefore
	)

	on uiHead changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiHead.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_Head ((eulerangles 0 0 0) as quat)
			return ()
		)
		
		selBackup = selection as array
		
		try(CompSelect selBackup m_Head) catch (
			m_Head = GetHead()
			select m_Head
		)
	)

	on uiNecks changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiNecks.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_Necks ((eulerangles 0 0 0) as quat)
			return ()
		)
		
		selBackup = selection as array

		try(CompSelect selBackup m_Necks) catch (
			m_Necks = GetNecks()
			select m_Necks
			
		)
	)
	
	on uiRArms changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRArms.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		selBackup = selection as array

		try(CompSelect selBackup m_RArms) catch (
			m_RArms = GetRArms()
			select m_RArms
			
		)
	)

	on uiRArms rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRArms.state = on
		m_LArms = GetLArms()
		select m_LArms
	) 
	
	on uiLArms changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLArms.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		selBackup = selection as array

		try(CompSelect selBackup m_LArms) catch (
			m_LArms = GetLArms()
			select m_LArms
			
		)
	)

	on uiLArms rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLArms.state = on
		m_RArms = GetRArms()
		select m_RArms
	) 
	
	on uiRClavicle changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRClavicle.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			StraightenByProxy m_RClavicle m_AllSpine[m_AllSpine.count] ((eulerangles 0 90 -180) as quat)
			return ()
		)

		selBackup = selection as array

		try(CompSelect selBackup m_RClavicle) catch (
			m_RClavicle = GetRClavicle()
			select m_RClavicle
			
		)
	)

	on uiRClavicle rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRClavicle.state = on
		m_LClavicle = GetLClavicle()
		select m_LClavicle
	) 

	on uiLClavicle changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLClavicle.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			StraightenByProxy m_LClavicle m_AllSpine[m_AllSpine.count] ((eulerangles 0 -90 -180) as quat)
			return ()
		)
		
		selBackup = selection as array

		try(CompSelect selBackup m_LClavicle) catch (
			m_LClavicle = GetLClavicle()
			select m_LClavicle
			
		)
	)

	on uiLClavicle rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLClavicle.state = on
		m_RClavicle = GetRClavicle()
		select m_RClavicle
	)
	
	on uiRUpArm changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRUpArm.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_RUpArm ((eulerangles 0 0 0) as quat)
			return ()
		)
		
		selBackup = selection as array

		try(CompSelect selBackup m_RUpArm) catch (
			m_RUpArm = GetRUpArm()
			select m_RUpArm
			
		)
	)

	on uiRUpArm rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRUpArm.state = on
		m_LUpArm = GetLUpArm()
		select m_LUpArm
	)

	on uiAllSpine changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiAllSpine.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_AllSpine ((eulerangles 0 0 0) as quat)
			return ()
		)
		
		selBackup = selection as array

		try(CompSelect selBackup m_AllSpine) catch (
			m_AllSpine = GetAllSpine()
			select m_AllSpine
			
		)
	)

	on uiSpine2 changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiSpine2.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_Spine2 ((eulerangles 0 0 0) as quat)
			return ()
		)
		
		selBackup = selection as array

		try(CompSelect selBackup m_Spine2) catch (
			m_Spine2 = GetSpine 2
			select m_Spine2
			
		)
	)

	on uiSpine1 changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiSpine1.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_Spine1 ((eulerangles 0 0 0) as quat)
			return ()
		)
		
		selBackup = selection as array

		try(CompSelect selBackup m_Spine1) catch (
			m_Spine1 = GetSpine 1
			select m_Spine1
			
		)
	)

	on uiSpine0 changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiSpine0.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_Spine0 ((eulerangles 0 0 0) as quat)
			return ()
		)
		
		selBackup = selection as array

		try(CompSelect selBackup m_Spine0) catch (
			m_Spine0 = GetSpine 0
			select m_Spine0
			
		)
	)

	on uiLUpArm changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLUpArm.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_LUpArm ((eulerangles 0 0 0) as quat)
			return ()
		)

		selBackup = selection as array

		try(CompSelect selBackup m_LUpArm) catch (
			m_LUpArm = GetLUpArm()
			select m_LUpArm
			
		)
	)

	on uiLUpArm rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLUpArm.state = on
		m_RUpArm = GetRUpArm()
		select m_RUpArm
	)
	
	on uiRForArm changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRForArm.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_RForArm ((eulerangles 0 0 0) as quat)
			return ()
		)
		
		selBackup = selection as array

		try(CompSelect selBackup m_RForArm) catch (
			m_RForArm = GetRForArm()
			select m_RForArm
			
		)
	)

	on uiRForArm rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRForArm.state = on
		m_LForArm = GetLForArm()
		select m_LForArm
	)

	on uiLForArm changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLForArm.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_LForArm ((eulerangles 0 0 0) as quat)
			return ()
		)
		
		selBackup = selection as array

		try(CompSelect selBackup m_LForArm) catch (
			m_LForArm = GetLForArm()
			select m_LForArm
			
		)
	)

	on uiLForArm rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLForArm.state = on
		m_RForArm = GetRForArm()
		select m_RForArm
	)
	
	on uiRHand changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRHand.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_RHand ((eulerangles 90 0 0) as quat)
			return ()
		)

		selBackup = selection as array

		try(CompSelect selBackup m_RHand) catch (
			m_RHand = GetRHand()
			select m_RHand
			
		)
	)

	on uiRHand rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRHand.state = on
		m_LHand = GetLHand()
		select m_LHand
	)

	on uiCOM changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiCOM.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		selBackup = selection as array
        
        -- 새로운 씬을 열면 m_workingBipRoot이 undefined는 아니지만 에러 발생함
        try (
            if ( m_workingBipRoot.isHidden == false ) or uiChkSelHiddenObj.state then (
                CompSelect selBackup #(m_workingBipRoot)
            )
            else (
                clearselection()
            )
        )
        catch (
            if (AutoGetBipRoot() == false) do ( SetButtonState false; return ())
            if ( m_workingBipRoot.isHidden == false ) or uiChkSelHiddenObj.state then (
                CompSelect selBackup #(m_workingBipRoot)
            )
            else (
                clearselection()
            )
        )
		
	)
	
	on uiLHand changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLHand.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_LHand ((eulerangles -90 0 0) as quat)
			return ()
		)
		
		selBackup = selection as array

		try(CompSelect selBackup m_LHand) catch (
			m_LHand = GetLHand()
			select m_LHand
		)
	)

	on uiLHand rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLHand.state = on
		m_RHand = GetRHand()
		select m_RHand
	)
	
	on uiPelvis changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiPelvis.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_Pelvis ((eulerangles -90 -90 0) as quat)
			return ()
		)
		
		selBackup = selection as array

		try(CompSelect selBackup m_Pelvis) catch (
			m_Pelvis = GetPelvis()
			select m_Pelvis
			
		)
	)
	
	on uiRThigh changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRThigh.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			StraightenByProxy m_RThigh m_Pelvis[1] ((eulerangles 0 180 0) as quat)
			return ()
		)
		
		selBackup = selection as array

		try(CompSelect selBackup m_RThigh) catch (
			m_RThigh = GetRThigh()
			select m_RThigh
			
		)
	)

	on uiRThigh rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRThigh.state = on
		m_LThigh = GetLThigh()
		select m_LThigh
	)

	on uiLThigh changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLThigh.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			StraightenByProxy m_LThigh m_Pelvis[1] ((eulerangles 0 -180 0) as quat)
			return ()
		)
		
		selBackup = selection as array
		
		try(CompSelect selBackup m_LThigh) catch (
			m_LThigh = GetLThigh()
			select m_LThigh
			
		)
	)

	on uiLThigh rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLThigh.state = on
		m_RThigh = GetRThigh()
		select m_RThigh
	)
	
	on uiRCalf changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRCalf.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_RCalf ((eulerangles 0 0 0) as quat)
			return ()
		)
		
		selBackup = selection as array

		try(CompSelect selBackup m_RCalf) catch (
			m_RCalf = GetRCalf()
			select m_RCalf
			
		)
	)

	on uiRCalf rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRCalf.state = on
		m_LCalf = GetLCalf()
		select m_LCalf
	)

	on uiLCalf changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLCalf.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_LCalf ((eulerangles 0 0 0) as quat)
			return ()
		)
		
		selBackup = selection as array

		try(CompSelect selBackup m_LCalf) catch (
			m_LCalf = GetLCalf()
			select m_LCalf
			
		)
	)

	on uiLCalf rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLCalf.state = on
		m_RCalf = GetRCalf()
		select m_RCalf
	)
	
	on uiRFoot changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRFoot.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_RFoot ((eulerangles 0 0 0) as quat)
			return ()
		)
		
		selBackup = selection as array

		try(CompSelect selBackup m_RFoot) catch (
			m_RFoot = GetRFoot()
			select m_RFoot
			
		)
	)

	on uiRFoot rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRFoot.state = on
		m_LFoot = GetLFoot()
		select m_LFoot
	)
	
	on uiLFoot changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLFoot.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_LFoot ((eulerangles 0 0 0) as quat)
			return ()
		)
		
		selBackup = selection as array

		try(CompSelect selBackup m_LFoot) catch (
			m_LFoot = GetLFoot()
			select m_LFoot
			
		)
	)

	on uiLFoot rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLFoot.state = on
		m_RFoot = GetRFoot()
		select m_RFoot
	)

	on uiRToe changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRToe.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록

		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_RToe ((eulerangles 0 0 90) as quat)
			return ()
		)

		selBackup = selection as array
		
		try(CompSelect selBackup m_RToe) catch (
			m_RToe = GetRToe()
			select m_RToe
			
		)
	)

	on uiRToe rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRToe.state = on
		m_LToe = GetLToe()
		select m_LToe
	)

	on uiLToe changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLToe.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록

		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_LToe ((eulerangles 0 0 90) as quat)
			return ()
		)

		selBackup = selection as array

		try(CompSelect selBackup m_LToe) catch (
			m_LToe = GetLToe()
			select m_LToe
			
		)
	)

	on uiLToe rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLToe.state = on
		m_RToe = GetRToe()
		select m_RToe
	)
	
	on uiRLegs changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRLegs.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		selBackup = selection as array

		try(CompSelect selBackup m_RLegs) catch (
			m_RLegs = GetRLegs()
			select m_RLegs
			
		)
	)

	on uiRLegs rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiRLegs.state = on
		m_LLegs = GetLLegs()
		select m_LLegs
	)
	
	on uiAllFoot changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiAllFoot.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		selBackup = selection as array

		try(CompSelect selBackup m_AllFoot) catch (
			m_AllFoot = GetAllFoot()
			select m_AllFoot
		)
	)
	
	on uiLLegs changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLLegs.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		selBackup = selection as array

		try(CompSelect selBackup m_LLegs) catch (
			m_LLegs = GetLLegs()
			select m_LLegs
			
		)
	)

	on uiLLegs rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiLLegs.state = on
		m_RLegs = GetRLegs()
		select m_RLegs
	)

	on uiPropL changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiPropL.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록

		selBackup = selection as array

		try(CompSelect selBackup m_LProp) catch (
			m_LProp = GetLProp()
			select m_LProp
		)
	)

	on uiPropL rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiPropL.state = on
		m_RProp = GetRProp()
		select m_RProp
	)

	on uiPropR changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiPropR.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록

		selBackup = selection as array

		try(CompSelect selBackup m_RProp) catch (
			m_RProp = GetRProp()
			select m_RProp
		)
	)

	on uiPropR rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiPropR.state = on
		m_LProp = GetLProp()
		select m_RProp
	)
	
	on uiSpnLoopStart changed var do (
		SaveRangeLoop()
		SetGotoMirrorEnable() -- Go to Mirror frame 버튼 활성/비활성 설정
	)
	on uiSpnLoopEnd changed var do (
		SaveRangeLoop()
		SetGotoMirrorEnable() -- Go to Mirror frame 버튼 활성/비활성 설정
	)

	on uiBtnGotoMirror changed state do (
		uiBtnGotoMirror.state = on
		local now = int sliderTime
		if (now < uiSpnLoopStart.value) OR (now > uiSpnLoopEnd.value) do return ()

		if now == uiSpnLoopEnd.value do (now = uiSpnLoopStart.value) -- 루프 끝 프레임에서 버튼이 눌러졌으면 첫 프레임으로 간주함
		local fCount = uiSpnLoopEnd.value - uiSpnLoopStart.value
		fCount *= 0.5
		local targetFrame = (int sliderTime) + fCount
		if targetFrame == uiSpnLoopEnd.value do (
			sliderTime = uiSpnLoopStart.value
			return ()
		)
		if targetFrame > uiSpnLoopEnd.value then (
			sliderTime = uiSpnLoopStart.value + (targetFrame - uiSpnLoopEnd.value)
			return ()
		)
		else (
			sliderTime = targetFrame
			return ()
		)
	)

	-- IK Blend, Body/Object 등의 키값을 조사해서 Planted, Sliding, Free 셋 중 하나의 타입을 리턴한다.
	fn GetLimbKeyType key = (
		-- ikSpace 0 = Body, 1 = Object
		if key.ikBlend == 1 AND key.ikSpace == 1 AND key.ikJoinedPivot == true do return "Planted"
		if key.ikBlend == 1 AND key.ikSpace == 1 AND key.ikJoinedPivot == false  do return "Sliding"
		return "Free"
	)

	on uiBtnLoopSel changed state do (
		uiBtnLoopSel.state = true

		for obj in selection do (
			DeselectAllKeys obj
			-- 선택시 컨트롤러는 세부 컨트롤러 명시 없어도 대충 잘 선택해줌
			selectKeys obj.controller (interval uiSpnLoopStart.value uiSpnLoopEnd.value)
		)
	)
	
	on uiBtnLoopGet changed state do (
		uiBtnLoopGet.state = true
		undo on (
			uiSpnLoopStart.value = animationRange.start as integer / TicksPerFrame
			uiSpnLoopEnd.value = animationRange.end as integer / TicksPerFrame
			SaveRangeLoop()
		)
	)

	on uiDropPlaySpeed selected sel do (
        timeConfiguration.playbackSpeed = sel
        SetPBPlaySpeed()
    )

    -- 프레임을 틱으로, 틱을 밀리세컨드로 (integer 리턴)
    function FramToMilisecond frame = (
		-- animationRange.start를 빼주지 않으면 0프레임이 아닌 곳에서 시작할 때 딜레이 발생함
		return ((((frame - animationRange.start) as integer) * (10.0 / 48.0) * m_PBPlaySpeed) as integer)
    )

    function AppendKeyTimeArray m_PBKeyMiliSecArray keys = (
        if keys.count == 0 do return()
        for i = 1 to keys.count do (
            if (keys[i].time >= animationRange.start) AND (keys[i].time <= animationRange.end) do (
                appendifUnique m_PBKeyMiliSecArray (FramToMilisecond keys[i].time)
                appendifUnique m_PBKeyTimeArray keys[i].time
            )
        )
        -- 애니메이션 레인지의 시작과 끝은 무조건 포함시킴
        appendifUnique m_PBKeyMiliSecArray (FramToMilisecond animationRange.start)
        appendifUnique m_PBKeyTimeArray animationRange.start
        appendifUnique m_PBKeyMiliSecArray (FramToMilisecond animationRange.end)
        appendifUnique m_PBKeyTimeArray animationRange.end
	)
	
	function StopBlocking = (
        clock.active = false
        uiPlayBlock.state = false
        uiPlayBlock.text = "跳帧播"
	)
    
    function PlayBlocking = (
		m_PBKeyTimeArray = #() -- 블럭킹 애니메이션용 키 타임 배열 로컬 변수 (Frame)
        m_PBKeyMiliSecArray = #() -- 블럭킹 애니메이션용 키 타임 배열 로컬 변수 (밀리세컨드)
        local nowTime = timeStamp()
        for obj in selection do (
            if (classof obj.baseObject) == Biped_Object do (
                if (IfBipRoot obj) then (
					turnCtrlObj = (fnBipedComlocalization obj.transform.controller)
                    AppendKeyTimeArray m_PBKeyMiliSecArray obj.transform.controller.horizontal.controller.keys
                    AppendKeyTimeArray m_PBKeyMiliSecArray obj.transform.controller.vertical.controller.keys
                    AppendKeyTimeArray m_PBKeyMiliSecArray turnCtrlObj.keys
                )
                else (
                    AppendKeyTimeArray m_PBKeyMiliSecArray obj.transform.controller.keys
                )
            )
		)
		if m_PBKeyMiliSecArray.count == 0 do (
			StopBlocking()
			return() -- 일반 오브젝트를 선택하면 배열이 비어있음
		)
		
		if (isAnimPlaying()) do (
			stopAnimation()
		)		
		
        sort m_PBKeyTimeArray
        sort m_PBKeyMiliSecArray
        m_PBPointer = 1
        while (m_PBKeyTimeArray[m_PBPointer] < sliderTime) do (
            m_PBPointer += 1
        )

        m_PBStartTime = timeStamp() - (FramToMilisecond sliderTime)
		sliderTime = m_PBKeyTimeArray[m_PBPointer] -- 일단 슬라이더 타임을 동기화 (안하면 강제로 스톱됨)
		clock.active = true
		uiPlayBlock.text = "Stop"
    )
	
	function ReplayBlocking = (
		m_PBPointer = 1
        m_PBStartTime = timeStamp()
        sliderTime = m_PBKeyTimeArray[m_PBPointer]
	)

	on uiPlayBlock changed state do (
        if (selection.count == 0) do (
            StopBlocking()
            return()
        )
		if state then (
            PlayBlocking()
        )
        else (
            StopBlocking()
        )
    )
    
    -- Play Blocking용 틱 이벤트 처리
    on clock tick do (
        if (m_PBPointer > m_PBKeyMiliSecArray.count) do return()
		local now = timeStamp()
		local pointer
		if (m_PBKeyMiliSecArray.count == m_PBPointer) then (
			ReplayBlocking()
			pointer = 1
		)
		else (
			pointer = m_PBStartTime + m_PBKeyMiliSecArray[m_PBPointer + 1] -- 다음 키프레임과 현재 시간을 비교
		)
        
        -- 현재 시간이 다음 프레임을 넘어서면 포인터 증가, 슬라이더 변경
        if ( now > pointer ) do (
            m_PBPointer += 1
            sliderTime = m_PBKeyTimeArray[m_PBPointer]
        )
        
        -- 포인터가 마지막 프레임을 가리키면 처음으로 되돌리고 시작시간 리셋
        if (m_PBPointer >= m_PBKeyMiliSecArray.count) do (
            ReplayBlocking()
        )

        if keyboard.escPressed do (
            StopBlocking()
		)
		
		-- 외부 요인에 의해 강제로 슬라이더 시간이 변경되면 사용자에 의한 플레이 취소로 간주
		if (sliderTime != m_PBKeyTimeArray[m_PBPointer]) do (
			StopBlocking()
		)
    )

	on uiAbout pressed do (
		-- shellLaunch "http://cafe.naver.com/pinksox/6131" ""
		-- rolBsAboutPanel.Show()
		try(rolBsAboutPanel.close())catch()
		fnOpenAboutPanel()
	)
	
	on rolBsBipedTools open do (
		
		if NOT (doesFileExist postureObjsFile) do
		(
			local txtFile = openFile postureObjsFile mode:"w"
			close txtFile
		)

		fnLoadBsBTConfig()
		fnApplyIcons()
        InitLocalVars() -- 작업용 바이패드 루트 노드라던가, 선택용 배열 변수 등을 미리 세팅
        
		fnInitDotTabs()
		fnChangeToolsVisble (dotnetTabs.SelectedIndex + 1)
		if fnIsValidBiped() then 
		(
			ctrl = m_workingBipRoot.controller
			if m_LHand[1] != undefined then uiCbtLeftArm.checked = biped.getLimbRetargetState m_LHand[1]
			if m_RHand[1] != undefined then uiCbtRightArm.checked = biped.getLimbRetargetState m_RHand[1]
			if m_LFoot[1] != undefined then uiCbtLeftLeg.checked = biped.getLimbRetargetState m_LFoot[1]
			if m_RFoot[1] != undefined then uiCbtRightLeg.checked = biped.getLimbRetargetState m_RFoot[1]
		)

        callbacks.addScript #filePostOpen "rolBsBipedTools.InitLocalVars ()" id:#BsBTCallbackOpen
		callbacks.addScript #systemPostNew "rolBsBipedTools.InitLocalVars ()" id:#BsBTCallbackNew
		callbacks.addScript #systemPostReset "rolBsBipedTools.InitLocalVars ()" id:#BsBTCallbackReset
		callbacks.addScript #selectionSetChanged "rolBsBipedTools.InitLocalVars ()" id:#BsBTSelChange
		
		fnSetBsBTConfig()

	)
	
	on rolBsBipedTools close do (
        callbacks.removeScripts id:#BsBTCallbackOpen
		callbacks.removeScripts id:#BsBTCallbackNew
		callbacks.removeScripts id:#BsBTCallbackReset
		callbacks.removeScripts id:#BsBTSelChange
		fnSetBsBTConfig()
	)

	on rolBsBipedTools mbuttondown pos do 
	(
		try (destroydialog rolBsBipedTools) catch ()
	)
	
	on rolBsBipedTools lbuttondown posMou do
	(
		setSysCur #move
		posBsBipedTools = posMou
		dragBsBipedTools = on
	)
	
	on rolBsBipedTools lbuttonup posMou do
	(
		dragBsBipedTools = off
		iniBsBTPos = (GetDialogPos rolBsBipedTools)
		fnSetBsBTConfig()
	)
	
	on rolBsBipedTools mouseMove pos do
	(
		if dragBsBipedTools == on then
		(
			SetDialogPos rolBsBipedTools (mouse.screenpos - posBsBipedTools)
		)
	)

	on btnClose pressed do 
	(
		try (destroydialog rolBsBipedTools) catch ()
	)

	on btnMini pressed do 
	(
		if rolBsBipedTools.height == 458 then rolBsBipedTools.height = 585
		else rolBsBipedTools.height = 458
	)

	on ddlAllBipedCom selected sel do
	(
		try
		(
			select arrAllBipedCom[sel]
			InitLocalVars()
		)
		catch()
	)

	on uiBtnDeleteKey rightclick do
	(
		uiBtnDeleteKey.state = on 
		allBipedRootNode = fnGetAllSelRootNode()
		-- print allBipedRootNode
		for i in allBipedRootNode where isvalidnode i do 
		(
			if (queryBox ("是否清除 " + i.name + " 骨架的所有帧?                        ") title:"BsBipedTools") do
			(
				biped.clearAllAnimation i.controller
			)
		)
	)

	on uiBtnDeleteKey changed state do
	(
		uiBtnDeleteKey.state = on 
		for b in selection as array where iskindof b.baseObject Biped_Object do
		(
			deselectKeys b.controller
			selectKeys b.controller sliderTime
			if ( classof b.controller == Vertical_Horizontal_Turn ) then
			(
				local arrComSelType = fnGetComTrackSelection b
				ctrlTurn = (fnBipedComlocalization b.controller)
				if arrComSelType[1] == 1 then
				(
					deleteKeys b.controller.horizontal.controller.keys #selection
				)
				if arrComSelType[2] == 1 then
				(
					deleteKeys b.controller.vertical.controller.keys #selection
				)
				if arrComSelType[3] == 1 then
				(
					deleteKeys ctrlTurn.keys #selection
				)
			)
			else
			(
				deleteKeys b.controller.keys #selection
			)
		)
	)

	on uiToggleMotionPanel changed state do
	(
		uiToggleMotionPanel.state = on 
		try
		(
			suspendEditing which:#motion
			uiToggleMotionPanel.highlightColor = green
		)
		catch()
		-- messagebox "已禁用Motion面板,能大大降低选择卡顿,\r\n\r\n如需恢复请右击,禁用了几次右击几次恢复!                         " title:"BsBipedTools"
	)

	on uiToggleMotionPanel rightclick do
	(
		uiToggleMotionPanel.state = on 
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do (return ())
		try
		(
			resumeEditing which:#motion
			uiToggleMotionPanel.highlightColor = mcMotionPanel
		)
		catch()
		-- messagebox "已恢复Motion面板,\r\n\r\n如需禁用请左击!                        " title:"BsBipedTools"
	)

	on uiCkbZen changed state do
	( 
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiCkbZen.state = on
		stateExpertMode = cui.getexpertmode()
		if stateExpertMode then 
		(
			cui.expertModeOff()
		)
		else
		(
			cui.expertModeOn()
		)
	)

	on uiCkbShowBox changed state do
	( 
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiCkbShowBox.state = on
		try(
			for o in m_AllBip where (o.isHidden == false) and (not isDeleted o) do 
			(
				if o.boxmode == off then o.boxmode = on 
				else o.boxmode = off
			)
		)
		catch(messageBox "骨骼可能有变动，请先点击 All Biped 刷新骨骼!         " title:"BsBipedTools")
	)

	on uiCkbShowBox rightclick do
	( 
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiCkbShowBox.state = on
		try(
			for o in m_AllBip where (o.isHidden == false) and (not isDeleted o) do 
			(
				o.boxmode = on
			)
		)
		catch(messageBox "骨骼可能有变动，请先点击 All Biped 刷新骨骼!         " title:"BsBipedTools")
	)

	on uiCkbXray changed state do
	( 
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiCkbXray.state = on
		try(
			for o in m_AllBip where (o.isHidden == false) and (not isDeleted o) do 
			(
				if o.xray == off then o.xray = on 
				else o.xray = off
			)
		)
		catch(messageBox "骨骼可能有变动，请先点击 All Biped 刷新骨骼!         " title:"BsBipedTools")
	)

	on uiCkbXray rightclick do
	( 
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiCkbXray.state = on
		try(
			for o in m_AllBip where (o.isHidden == false) and (not isDeleted o) do 
			(
				o.xray = on
			)
		)
		catch(messageBox "骨骼可能有变动，请先点击 All Biped 刷新骨骼!         " title:"BsBipedTools")
	)
	
	on uiCkbHideBip changed state do
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiCkbHideBip.state = on 
		try(
			for o in m_AllBip where (not isDeleted o) do 
			(
				if o.isHidden == off then o.isHidden = on 
				else o.isHidden = off
			)
			-- m_workingBipRoot.controller.displayFootsteps = false
			hide $*Footsteps
		)
		catch(messageBox "骨骼可能有变动，请先点击 All Biped 刷新骨骼!         " title:"BsBipedTools")
	)

	on uiCkbHideBip rightclick do
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiCkbHideBip.state = on 
		try(
			for o in m_AllBip where (not isDeleted o) do 
			(
				o.isHidden = on
			)
			-- m_workingBipRoot.controller.displayFootsteps = false
			hide $*Footsteps
		)
		catch(messageBox "骨骼可能有变动，请先点击 All Biped 刷新骨骼!         " title:"BsBipedTools")
	)

	on uiBtnFrameTick pressed do 
	(
		if timeDisplayMode != #frameTicks then 
		(
			timeDisplayMode = #frameTicks
		)
		else 
		(
			timeDisplayMode = #frames
		)
		disableSceneRedraw()
		trackbar.visible = false
		trackbar.visible = true
		enableSceneRedraw()
	)

	on uiBtnTraj changed state do 
	(
		uiBtnTraj.state = on 
		try
		(
			allBipedRootNode = fnGetAllSelRootNode()
			for i in allBipedRootNode where isvalidnode i do 
			(
				if i.controller.displaytrajectories then
				(
					i.controller.displaytrajectories = false
				)
				else
				(
					setCommandPanelTaskMode #motion
					i.controller.displaytrajectories = true
				)
			)
		)catch()
	)

	on uiCkbClearUserDef changed state do 
	(
		uiCkbClearUserDef.state = on
		allBipedRootNode = fnGetAllSelRootNode()
		print allBipedRootNode
		for i in allBipedRootNode where isvalidnode i do 
		(
			if (queryBox ("是否清除 " + i.name + " 骨架保存的循环帧自定义属性值?\r\n\r\n（对文件本身无任何影响）                                               ")) do
			(
				try 
				(
					fnDeleteUserProp i "BsBT_RangeLoopStart"
					fnDeleteUserProp i "BsBT_RangeLoopEnd"
				)
				catch()
			)
		)
	)

	on uiWorkbench pressed do 
	(
		BipWorkBench.Open()
	)

	on uiFigureMode changed state do
	(
		arrBipCom = fnGetAllSelRootNode()
		for i in arrBipCom where arrBipCom.count != 0 do
		(
			if biped.getCurrentLayer i.controller == 0 then i.controller.figureMode = state
			else 
			(
				uiFigureMode.state = false
				messageBox "当前不处于 Original Layer，无法打开形体模式！                                " title:"BsBipedTools"
			)
		)
	)

	on uiBtnInPlace changed state do
	(
		uiBtnInPlace.images = #("bip_general_i.bmp","bip_general_i.bmp",30,27,27,27,27,true,true)
		arrBipCom = fnGetAllSelRootNode()
		for i in arrBipCom where isvalidnode i do
		(
			if i.controller.figureMode == false then i.controller.inPlaceYMode  = state
			else 
			(
				uiBtnInPlace.state = false
				messagebox (i.name + "  不能在体形模式中打开原地模式。                              ")  title:"BsBipedTools"
			)
		)
	)
	on uiBtnInPlace rightclick do
	(
		uiBtnInPlace.images = #("bip_general_i.bmp","bip_general_i.bmp",30,23,23,23,23,true,true)
		uiBtnInPlace.state  = not uiBtnInPlace.state
		arrBipCom = fnGetAllSelRootNode()
		for i in arrBipCom where isvalidnode i do
		(
			if i.controller.figureMode == false then i.controller.inPlaceMode  = uiBtnInPlace.state
			else 
			(
				uiBtnInPlace.state = false
				messagebox (i.name + "  不能在体形模式中打开原地模式。                              ")  title:"BsBipedTools"
			)
		)
	)

	on uiCbtDown pressed do
	(
		if fnIsValidBiped() then
		(
			fnSyncBipedPanel()
			layerIndex = layerIndex - 1
			if layerIndex >= 0 then
			(
				biped.setCurrentLayer ctrl layerIndex
				uiCbtUp.enabled = true
				uiCbtUp.images = #("bip_layer_i.bmp","bip_layer_i.bmp",24,1,1,1,1,true,true)
				if layerIndex == 0 then
				(
					uiCbtDown.enabled = false
					uiCbtDown.images = #("bip_layer_i.bmp","bip_layer_i.bmp",24,4,4,4,4,true,true)
				)
			)
			else
			(
				layerIndex = 0
			)
		)	
		fnBSUpdateLayers()
	)

	on uiCbtUp pressed do
	(
		if fnIsValidBiped() then
		(
			fnSyncBipedPanel()
			layerIndex = layerIndex + 1
			if layerIndex <= numLayers then
			(
				biped.setCurrentLayer ctrl layerIndex
				uiCbtDown.enabled = true
				uiCbtDown.images = #("bip_layer_i.bmp","bip_layer_i.bmp",24,3,3,3,3,true,true)
				if layerIndex == numLayers then
				(
					uiCbtUp.enabled = false
					uiCbtUp.images = #("bip_layer_i.bmp","bip_layer_i.bmp",24,2,2,2,2,true,true)
				)
			)
			else
			(
				layerIndex = numLayers
				uiCbtUp.enabled = false
				uiCbtUp.images = #("bip_layer_i.bmp","bip_layer_i.bmp",24,2,2,2,2,true,true)
			)
		)
		fnBSUpdateLayers()
	)

	on uiChkActive changed state do
	(
		if fnIsValidBiped() then
		(
			fnSyncBipedPanel()
			if state then
			(
				biped.setLayerActive ctrl layerIndex true
			)
			else
			(
				biped.setLayerActive ctrl layerIndex false
			)
		)
		fnBSUpdateLayers()
	)

	on ddlLayers selected val do
	(
		if fnIsValidBiped() then
		(
			fnSyncBipedPanel()
			local index = val - 1
			if index <= numLayers then
			(
				biped.setCurrentLayer ctrl index
			)
		)
		fnBSUpdateLayers()
	)

	on uiCbtRefreshLayer changed state do
	(
		uiCbtRefreshLayer.state = true
		if fnIsValidBiped() then
		(
			fnBSUpdateLayers()
		)
	)

	on uiCbtLeftArm changed state do
	(
		if fnIsValidBiped() then 
		(
			if m_LHand[1] != undefined then biped.setLimbRetargetState m_LHand[1] state
		)
	)
	
	on uiCbtRightArm changed state do
	(
		if fnIsValidBiped() then 
		(
			if m_RHand[1] != undefined then biped.setLimbRetargetState m_RHand[1] state
		)
	)
	
	on uiCbtLeftLeg changed state do
	(
		if fnIsValidBiped() then 
		(
			if m_LFoot[1] != undefined then biped.setLimbRetargetState m_LFoot[1] state
		)
	)
	
	on uiCbtRightLeg changed state do
	(
		if fnIsValidBiped() then 
		(
			if m_RFoot[1] != undefined then biped.setLimbRetargetState m_RFoot[1] state
		)
	)
		
	on uiCbtUpdate pressed do
	(
		if fnIsValidBiped() then
		(
			biped.retargetToBaseLayer ctrl uiChkIKonly.state
			redrawViews()
		)
	)

	on uiCbtGrabPose changed state do
	(
		uiCbtGrabPose.state = true
		if isValidNode m_workingBipRoot AND NOT isDeleted m_workingBipRoot then
		(
			local bRootCtrl = m_workingBipRoot.controller
			biped.createCopyCollection bRootCtrl "PoseGrabber"
			local colIndex = biped.numCopyCollections bRootCtrl
			local copyCol = biped.getCopyCollection bRootCtrl colIndex
			biped.copyBipPose bRootCtrl copyCol #snapAuto
			local grabbeBH_pose = getCopy copyCol #pose 1
			biped.saveCopyPasteFile bRootCtrl (getDir #plugcfg + "\BsBipedTools_PoseGrabbed.cpy")
			biped.deleteCopyCollection bRootCtrl colIndex
		)
		else
		(
			fnMsgMissingBiped()			
		)	
	)
	
	on uiCbtLoadPose changed state do
	(
		uiCbtLoadPose.state = true
		if isValidNode m_workingBipRoot AND NOT isDeleted m_workingBipRoot then
		(
			local poseFile = getDir #plugcfg + "\BsBipedTools_PoseGrabbed.cpy"
			if doesFileExist poseFile then
			(
				local bRootCtrl = m_workingBipRoot.controller
				biped.loadCopyPasteFile bRootCtrl poseFile
				local colIndex = biped.numCopyCollections bRootCtrl
				local copyCol = biped.getCopyCollection bRootCtrl colIndex
				local grabbeBH_pose = getCopy copyCol #pose 1
				with Animate on
				(
					--// Requires two paste operations to work properly (Biped oddness)
					biped.pasteBipPose bRootCtrl grabbeBH_pose false #pstdefault true true true false
					biped.pasteBipPose bRootCtrl grabbeBH_pose false #pstdefault true true true false
				)
				local colIndex = biped.numCopyCollections bRootCtrl
				biped.deleteCopyCollection bRootCtrl colIndex
			)
			else
			(
				messageBox "错误: 临时 Pose 文件不存在，请先暂存Pose！                              " title:"BsBipedTools"
			)
		)
		else
		(
			fnMsgMissingBiped()			
		)	
	)

	on uiPivot changed state do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiPivot.state = true

		try(destroyDialog rolBSLeftHandPivots)catch()
		try(destroyDialog rolBSRightHandPivots)catch()
		try(destroyDialog rolBSLeftFootPivots)catch()
		try(destroyDialog rolBSRightFootPivots)catch()

		case of 
		(
			(selection[1] == m_LHand[1]):(Createdialog rolBSLeftHandPivots pos:(mouse.screenPos + [40,-50]) parent:rolBsBipedTools.hwnd fgcolor:(if fnGetThemeColor() == "Light" then (color 28 89 177) else (color 165 222 228)) style:#(#style_titlebar, #style_sysmenu, #style_toolwindow))
			(selection[1] == m_RHand[1]):(Createdialog rolBSRightHandPivots pos:(mouse.screenPos + [40,-50]) parent:rolBsBipedTools.hwnd fgcolor:(if fnGetThemeColor() == "Light" then (color 28 89 177) else (color 165 222 228)) style:#(#style_titlebar, #style_sysmenu, #style_toolwindow))
			(selection[1] == m_LFoot[1]):(Createdialog rolBSLeftFootPivots pos:(mouse.screenPos + [40,-50]) parent:rolBsBipedTools.hwnd fgcolor:(if fnGetThemeColor() == "Light" then (color 28 89 177) else (color 165 222 228)) style:#(#style_titlebar, #style_sysmenu, #style_toolwindow))
			(selection[1] == m_RFoot[1]):(Createdialog rolBSRightFootPivots pos:(mouse.screenPos + [40,-50]) parent:rolBsBipedTools.hwnd fgcolor:(if fnGetThemeColor() == "Light" then (color 28 89 177) else (color 165 222 228)) style:#(#style_titlebar, #style_sysmenu, #style_toolwindow))
			default:(messageBox "请先选择手或脚任意一根骨骼，并且设置滑动帧或固定帧!                            " title:"BsBipedTools")
		)
	)

	on uiFingers changed state do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiFingers.state = true

		try(destroyDialog rolBSFingers)catch()

		Createdialog rolBSFingers pos:(mouse.screenPos - [270,100]) parent:rolBsBipedTools.hwnd fgcolor:(if fnGetThemeColor() == "Light" then (color 28 89 177) else (color 165 222 228)) style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)
	)

	on uiBtnLoadBip changed state do
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiBtnLoadBip.state = true
		biped.loadBipFileDlg m_workingBipRoot.controller
	)

	on uiBtnSaveBip changed state do
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiBtnSaveBip.state = true
		biped.saveBipFileDlg m_workingBipRoot.controller
	)

	on uiCbtAddLayer pressed do
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do (return ())
		fnBSUpdateLayers()
		ctrlCom = m_workingBipRoot.controller
		numCurLayer = biped.getCurrentLayer ctrlCom
		countAllLayers = biped.numLayers ctrlCom
		numNewLayerIndex = numCurLayer + 1
		numNewLayerName = (countAllLayers + 1) as string
		biped.createLayer ctrlCom numNewLayerIndex ("Layer " + numNewLayerName )
		fnBSUpdateLayers()
	)

	on uiCbtDelLayer pressed do
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do (return ())
		fnBSUpdateLayers()
		ctrlCom = m_workingBipRoot.controller
		numCurLayer = biped.getCurrentLayer ctrlCom
		biped.deleteLayer ctrlCom numCurLayer
		fnBSUpdateLayers()
	)

	on uiCbtDownLayer pressed do
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do (return ())
		fnBSUpdateLayers()
		ctrlCom = m_workingBipRoot.controller
		numCurLayer = biped.getCurrentLayer ctrlCom
		biped.collapseAtLayer ctrlCom (numCurLayer - 1)
		fnBSUpdateLayers()
	)

	on uiCbtSnapKeys pressed do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do (return ())
		fnBSUpdateLayers()
		ctrlCom = m_workingBipRoot.controller
		for obj in selection as array where not isDeleted obj and classof obj.baseobject == Biped_Object do 
		(
			if (classof obj.controller == Vertical_Horizontal_Turn) then
			(
				numCurLayer = biped.getCurrentLayer ctrlCom
				biped.setCurrentLayer ctrlCom (numCurLayer - 1)
				tranPos = biped.getTransform obj #pos
				tranRot = biped.getTransform obj #rotation
				biped.setCurrentLayer ctrlCom numCurLayer
				biped.setTransform obj #pos tranPos true
				biped.setTransform obj #rotation tranRot true
			)
			else
			(
				biped.setSnapKey obj
			)
		)
	)

	on uiCbtSnapKeys rightclick do 
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do (return ())
		fnBSUpdateLayers()
		ctrlCom = m_workingBipRoot.controller
		numCurLayer = biped.getCurrentLayer ctrlCom
		for obj in selection as array where not isDeleted obj and classof obj.baseobject == Biped_Object do 
		(
			local arrAllBipedKeys = #()
			biped.setCurrentLayer ctrlCom (numCurLayer - 1)
			if (classof obj.controller == Vertical_Horizontal_Turn) then
			(
				arrKeyVer = for i in obj.controller.vertical.controller.keys collect i.time
				arrKeyHor = for i in obj.controller.horizontal.controller.keys collect i.time
				arrKeyTurn = for i in (fnBipedComlocalization obj.controller).keys collect i.time
				arrAllBipedKeys = arrKeyVer + arrKeyHor + arrKeyTurn
				arrAllBipedKeys = makeUniqueArray arrAllBipedKeys
				sort arrAllBipedKeys
				for t in arrAllBipedKeys where arrAllBipedKeys.count != 0 do 
				(
					-- at time t with animate on 
					slidertime = t
					with animate on
					(
						biped.createCopyCollection obj.controller "tempBipedComKeys"
						copycol= biped.getcopycollection obj.controller (biped.numCopyCollections obj.controller)
						icpmxbipcopy = biped.copybippose obj.controller copycol #snapview
						biped.setCurrentLayer ctrlCom numCurLayer
						biped.pastebippose obj.controller icpmxbipcopy false #pstdefault false true false false
						biped.deleteCopyCollection obj.controller (biped.numCopyCollections obj.controller)
					)
				)
			)
			else 
			(
				arrAllBipedKeys = for i in obj.controller.keys collect i.time
				biped.setCurrentLayer ctrlCom numCurLayer
				for t in arrAllBipedKeys where arrAllBipedKeys.count != 0 do 
				(
					at time t with animate on 
					(
						try (biped.addNewKey obj.controller t) catch ()
					)
				)
			)
		)
	)
	on uiCbtHorTrack changed state do 
	(
		-- fnSetComTrackSelection m_workingBipRoot
		uiCbtHorTrack.state = true
		uiCbtVerTrack.state = uiCbtTurnTrack.state = false
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do (return ())
		m_workingBipRoot.controller.trackSelection = 1
		select m_workingBipRoot
	)
	on uiCbtVerTrack changed state do 
	(
		-- fnSetComTrackSelection m_workingBipRoot
		uiCbtVerTrack.state = true
		uiCbtHorTrack.state = uiCbtTurnTrack.state = false
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do (return ())
		m_workingBipRoot.controller.trackSelection = 2
		select m_workingBipRoot
	)
	on uiCbtTurnTrack changed state do 
	(
		-- fnSetComTrackSelection m_workingBipRoot
		-- if not state then fnLockComTrack m_workingBipRoot
		uiCbtTurnTrack.state = true
		uiCbtVerTrack.state = uiCbtHorTrack.state = false
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do (return ())
		m_workingBipRoot.controller.trackSelection = 3
		select m_workingBipRoot
	)

	on uiBtnComLock pressed do  -- 非状态显示,只是切换按钮,因为没找到API,干脆全锁切换
	(
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do (return ())
		fnLockComTrack m_workingBipRoot
		fnRefreshTrackSelection m_workingBipRoot
	)

	on uiBtn0 changed state do
	(
		uiBtn0.state = true
		fnEvaluateTCB 0.0
	)
	on uiBtn25 changed state do
	(
		uiBtn25.state = true
		fnEvaluateTCB 25.0
	)
)
if (iniBsBTPos != 0) then 
(Createdialog rolBsBipedTools pos:iniBsBTPos style:#() fgcolor:(if fnGetThemeColor() == "Light" then (color 28 89 177) else (color 165 222 228)))
else (Createdialog rolBsBipedTools style:#() fgcolor:(if fnGetThemeColor() == "Light" then (color 28 89 177) else (color 165 222 228)))
clearListener()