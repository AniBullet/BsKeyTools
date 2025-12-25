/**************************************************************************************************************************
-- By Bullet.S 自用修改版,功能大集合,完全开源免费仅供学习使用,请勿用于商业用途,否则后果自负    
Reference： SoxBipedAssist_v0.423 & Biped Helper v3.1  
Since 2023.03

v2.1
1.优化手指弯曲功能（一方狂三）

v2.0
1.修复层功能某些ui遮挡导致按钮不灵的问题

v1.9
1.修复bip层内使用滑动帧导致卡死的bug

v1.8
1.修复手指选择报错
2.添加bend link功能

v1.7
1.头部按钮右键切换颜文字脸表情
2.表情选择自动保存到配置文件
3.添加表情还原按钮

2025.05 v1.6
1.删除biped帧添加回退
2.添加CS缩放(感谢霍霍小猫建议)

2025.03 update v1.5
1.重新改回复制pose的选择被复制biped骨骼功能，去掉清除posture的按钮

2024.04 update v1.4
1. 修复复制pose和加层功能回退导致的闪退
2。稍微拓展手指选择功能
3。IK帧切换面板功能优化，会保持之前面板
**************************************************************************************************************************/

global rolBsBipedTools
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
global verBsBipedTools = "v2.1"

try(destroydialog rolBsBipedTools) catch()
try(destroyDialog rolBSLeftHandPivots)catch()
try(destroyDialog rolBSRightHandPivots)catch()
try(destroyDialog rolBSLeftFootPivots)catch()
try(destroyDialog rolBSRightFootPivots)catch()
try(destroyDialog rolBsBipToolsHelp)catch()

rollout rolBsBipToolsHelp ("BsBipTools" + verBsBipedTools + " 使用指南") width:420 height:480
(
	local strHelpText = ("🎯 BsBipedTools 使用指南" + "\r\n" + \
	"==============================" + "\r\n\r\n" + \
	"⚡ 【特别功能】" + "\r\n" + \
	"• Motion面板开关 (M按钮)：左键禁用减少卡顿，右键恢复" + "\r\n" + \
	"• 禅模式/XRay/Box：快速切换视窗显示模式" + "\r\n" + \
	"• 头部表情：右键点击头部按钮切换颜文字脸，右上角还原" + "\r\n" + \
	"• 手指弯曲：在手指面板中使用Bend控件调节手指弯曲" + "\r\n\r\n" + \
	"🎯 【骨骼选择操作】" + "\r\n" + \
	"• 左键单击：直接选取  |  右键单击：选择镜像骨骼" + "\r\n" + \
	"• Ctrl + 左击：加选  |  Alt + 左击：减选" + "\r\n" + \
	"• Shift + 左击：选择骨骼及其所有子级" + "\r\n" + \
	"• Ctrl + Alt + 左击：骨骼旋转归零" + "\r\n\r\n" + \
	"🛠️ 【辅助工具】" + "\r\n" + \
	"• Copy Paste Tools：姿态复制粘贴和镜像" + "\r\n" + \
	"• Layer Tools：Biped层级管理" + "\r\n" + \
	"• Loop Key Tools：循环关键帧工具" + "\r\n" + \
	"• Others Tools：其他实用功能集合" + "\r\n\r\n" + \
	"💡 【使用提示】" + "\r\n" + \
	"帧相关按钮有丰富的组合键功能，请查看悬停提示" + "\r\n" + \
	"左击 / 右击 / Ctrl / Shift 都有不同便捷功能" + "\r\n\r\n" + \
	"==============================" + "\r\n" + \
	"减少卡顿，便捷K帧 | 作者：Bullet.S" + "\r\n\r\n")

	label lblHelp strHelpText width:400 height:400 pos:[10,10]
	-- 链接区域
	groupBox grpLinks "相关链接" pos:[10,420] width:400 height:50
	label lblAuthor "作者：" pos:[20,440] width:40 height:15
	hyperLink hplHome "Bullet.S" address:"https://www.anibullet.com/" pos:[60,440] width:60 height:15
	hyperLink hplHelpDocs "帮助文档" address:"https://anibullet.github.io/" pos:[130,440] width:60 height:15
	label lblRef "参考：" pos:[200,440] width:40 height:15
	hyperLink hplSox "SoxBipedAssist" address:"http://cafe.naver.com/pinksox/6131" pos:[240,440] width:80 height:15
	hyperLink hplBH "BipedHelper" address:"https://sites.google.com/view/lbtools-guide/home/biped-helper" pos:[330,440] width:70 height:15
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

rollout rolBSFingers "BsBipedTools_Fingers" width:300 height:230
(
	-- ← 新增：手指结构变量
	local rIsKnuckles = false
	local lIsKnuckles = false
	local mc_spreadMaxAngle = 45.0
	-- 新增截断 →

	checkbutton chbTips "暂不支持4节手指" pos:[100,5] height:20 highlightColor:rolBsBipedTools.mcScanBiped checked:true

	checkbutton chbRFingers "R Fingers" pos:[40,160] width:100 highlightColor:rolBsBipedTools.mcRightFinger checked:true
	checkbutton chbLFingers "L Fingers" pos:[160,160] width:100 highlightColor:rolBsBipedTools.mcLeftFinger checked:true
	
	--R Index Finger (整体右移20像素居中)
	checkbutton select_rhand1_btn "R Hand"	enabled:true pos:[40,30] width:80 height:30 highlightColor:rolBsBipedTools.mcRight checked:true toolTip:""
	checkbutton select_rfing11_btn ""	enabled:true pos:[100,85] width:20 height:22 highlightColor:rolBsBipedTools.mcRightFinger checked:true toolTip:""
	checkbutton select_rfing12_btn ""	enabled:true pos:[100,107] width:20 height:20 highlightColor:rolBsBipedTools.mcRightFinger checked:true toolTip:""
	checkbutton select_rfing13_btn ""	enabled:true pos:[100,127] width:20 height:17 highlightColor:rolBsBipedTools.mcRightFinger checked:true toolTip:""

	--R Middle Finger
	checkbutton select_rfing21_btn ""	enabled:true pos:[80,85]	width:20 height:23 highlightColor:rolBsBipedTools.mcRightFinger checked:true toolTip:""
	checkbutton select_rfing22_btn ""	enabled:true pos:[80,108]	width:20 height:23 highlightColor:rolBsBipedTools.mcRightFinger checked:true toolTip:""
	checkbutton select_rfing23_btn ""	enabled:true pos:[80,131]	width:20 height:20 highlightColor:rolBsBipedTools.mcRightFinger checked:true ttoolTip:""
	
	--R Ring Finger
	checkbutton select_rfing31_btn ""	enabled:true pos:[60,85]	width:20 height:22 highlightColor:rolBsBipedTools.mcRightFinger checked:true toolTip:""
	checkbutton select_rfing32_btn ""	enabled:true pos:[60,107]	width:20 height:20 highlightColor:rolBsBipedTools.mcRightFinger checked:true toolTip:""
	checkbutton select_rfing33_btn ""	enabled:true pos:[60,127]	width:20 height:17 highlightColor:rolBsBipedTools.mcRightFinger checked:true toolTip:""
	
	--R Pinkie Finger
	checkbutton select_rfing41_btn ""	enabled:true pos:[40,85]	width:20 height:20 highlightColor:rolBsBipedTools.mcRightFinger checked:true toolTip:""
	checkbutton select_rfing42_btn ""	enabled:true pos:[40,105]	width:20 height:17 highlightColor:rolBsBipedTools.mcRightFinger checked:true toolTip:""
	checkbutton select_rfing43_btn ""	enabled:true pos:[40,122]	width:20 height:16 highlightColor:rolBsBipedTools.mcRightFinger checked:true toolTip:""
	
	--R Thumb
	checkbutton select_rthumb1_btn ""	enabled:true pos:[120,69]	width:20 height:30 highlightColor:rolBsBipedTools.mcRightThumb checked:true toolTip:""
	checkbutton select_rthumb2_btn ""	enabled:true pos:[120,99]	width:18 height:19 highlightColor:rolBsBipedTools.mcRightThumb checked:true toolTip:""
	checkbutton select_rthumb3_btn ""	enabled:true pos:[120,118]	width:16 height:18 highlightColor:rolBsBipedTools.mcRightThumb checked:true toolTip:""

	--LEFT HAND (右移到合适位置)
	--L Index Finger
	checkbutton select_lhand1_btn "L Hand"	enabled:true pos:[180,30]	width:80 height:30 highlightColor:rolBsBipedTools.mcLeft checked:true toolTip:""
	checkbutton select_lfing11_btn ""	enabled:true pos:[180,85]	width:20 height:22 highlightColor:rolBsBipedTools.mcLeftFinger checked:true toolTip:""
	checkbutton select_lfing12_btn ""	enabled:true pos:[180,107]	width:20 height:20 highlightColor:rolBsBipedTools.mcLeftFinger checked:true toolTip:""
	checkbutton select_lfing13_btn ""	enabled:true pos:[180,127]	width:20 height:17 highlightColor:rolBsBipedTools.mcLeftFinger checked:true toolTip:""
	
	--L Middle Finger
	checkbutton select_lfing21_btn ""	enabled:true pos:[200,85]	width:20 height:23 highlightColor:rolBsBipedTools.mcLeftFinger checked:true toolTip:""
	checkbutton select_lfing22_btn ""	enabled:true pos:[200,108]	width:20 height:23 highlightColor:rolBsBipedTools.mcLeftFinger checked:true toolTip:""
	checkbutton select_lfing23_btn ""	enabled:true pos:[200,131]	width:20 height:20 highlightColor:rolBsBipedTools.mcLeftFinger checked:true toolTip:""
	
	--L Ring Finger
	checkbutton select_lfing31_btn ""	enabled:true pos:[220,85]	width:20 height:22 highlightColor:rolBsBipedTools.mcLeftFinger checked:true toolTip:""
	checkbutton select_lfing32_btn ""	enabled:true pos:[220,107]	width:20 height:20 highlightColor:rolBsBipedTools.mcLeftFinger checked:true toolTip:""
	checkbutton select_lfing33_btn ""	enabled:true pos:[220,127]	width:20 height:17 highlightColor:rolBsBipedTools.mcLeftFinger checked:true toolTip:""

	--L Pinkie Finger
	checkbutton select_lfing41_btn ""	enabled:true pos:[240,85]	width:20 height:20 highlightColor:rolBsBipedTools.mcLeftFinger checked:true toolTip:""
	checkbutton select_lfing42_btn ""	enabled:true pos:[240,105]	width:20 height:17 highlightColor:rolBsBipedTools.mcLeftFinger checked:true toolTip:""
	checkbutton select_lfing43_btn ""	enabled:true pos:[240,122]	width:20 height:16 highlightColor:rolBsBipedTools.mcLeftFinger checked:true toolTip:""

	--L Thumb
	checkbutton select_lthumb1_btn ""	enabled:true pos:[160,69]	width:20 height:30 highlightColor:rolBsBipedTools.mcLeftThumb checked:true toolTip:""
	checkbutton select_lthumb2_btn ""	enabled:true pos:[162,99]	width:18 height:19 highlightColor:rolBsBipedTools.mcLeftThumb checked:true toolTip:""
	checkbutton select_lthumb3_btn ""	enabled:true pos:[164,118]	width:16 height:18 highlightColor:rolBsBipedTools.mcLeftThumb checked:true toolTip:""

	checkbutton btnFingerLineR1 "0" enabled:true pos:[120,44] width:20 height:25 checked:true toolTip:"选择单条手指"
	checkbutton btnFingerLineR2 "1" enabled:true pos:[100,60] width:20 height:25 checked:true toolTip:"选择单条手指"
	checkbutton btnFingerLineR3 "2" enabled:true pos:[80,60] width:20 height:25 checked:true toolTip:"选择单条手指"
	checkbutton btnFingerLineR4 "3" enabled:true pos:[60,60] width:20 height:25 checked:true toolTip:"选择单条手指"
	checkbutton btnFingerLineR5 "4" enabled:true pos:[40,60] width:20 height:25 checked:true toolTip:"选择单条手指"
	checkbutton btnFingerLineL1 "0" enabled:true pos:[160,44] width:20 height:25 checked:true toolTip:"选择单条手指"
	checkbutton btnFingerLineL2 "1" enabled:true pos:[180,60] width:20 height:25 checked:true toolTip:"选择单条手指"
	checkbutton btnFingerLineL3 "2" enabled:true pos:[200,60] width:20 height:25 checked:true toolTip:"选择单条手指"
	checkbutton btnFingerLineL4 "3" enabled:true pos:[220,60] width:20 height:25 checked:true toolTip:"选择单条手指"
	checkbutton btnFingerLineL5 "4" enabled:true pos:[240,60] width:20 height:25 checked:true toolTip:"选择单条手指"
		
	-- UI 控件 - 竖直手指张开滑块 (两侧对称布局，加大尺寸)
	slider uiRSpread "" range:[1,-0.3,0] width:25 height:120 pos:[10,35] tooltip:"右手手指张开\n向下拖动张开" orient:#vertical
	slider uiLSpread "" range:[1,-0.3,0] width:25 height:120 pos:[270,35] tooltip:"左手手指张开\n向下拖动张开" orient:#vertical
	
	-- 手指弯曲控件 (底部居中对齐)
	label lblRBend "右手弯曲:" pos:[60,190] width:60 height:15
	spinner uiRBendStart "" width:50 range:[-45,90,0] scale:1 type:#integer pos:[30,205] tooltip:"右手弯曲起始角度"
	spinner uiRBendEnd "" width:50 range:[-45,90,0] scale:1 type:#integer pos:[85,205] tooltip:"右手弯曲结束角度"
	
	label lblLBend "左手弯曲:" pos:[195,190] width:60 height:15
	spinner uiLBendStart "" width:50 range:[-45,90,0] scale:1 type:#integer pos:[165,205] tooltip:"左手弯曲起始角度"
	spinner uiLBendEnd "" width:50 range:[-45,90,0] scale:1 type:#integer pos:[220,205] tooltip:"左手弯曲结束角度"
	

	fn GetFinger side index =
	(
		if side == "L" then sideFinger = #lfingers 
		else if side == "R" then sideFinger = #rfingers

		selObj = biped.getNode rolBsBipedTools.m_workingBipRoot sideFinger link:index
		if selObj != undefined then
		(
			if ( selObj.isHidden == false ) or rolBsBipedTools.uiChkSelHiddenObj.state then (
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

	  -- ← 新增：获取Biped名称
	fn getBipedName =
	( 
	    if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot)) then return ""
	    try
	    ( 
	      local bipName = rolBsBipedTools.m_workingBipRoot.name
	      return bipName
	    ) 
	    catch() 
	    return ""
	) 

	-- ← 新增：获取Biped控制器
	fn getBipedController =
	( 
	    if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot)) then return undefined
	    try
	    ( 
	      if classof rolBsBipedTools.m_workingBipRoot.controller == Vertical_Horizontal_Turn then
	        return rolBsBipedTools.m_workingBipRoot.controller
	    ) 
	    catch() 
	    return undefined
	) 

	 -- 检测是否为Knuckles模式
	fn detectKnucklesMode =
	( 
	    local isKnuckles = false
	    try
	    ( 
	      local bipCtrl = getBipedController() 
	      if bipCtrl != undefined then
	      ( 
	        try
	        ( 
	          isKnuckles = bipCtrl.knuckles
	        ) 
	        catch() 
	      ) 
	    ) 
	    catch() 
	    return isKnuckles
	) 
	
  -- ← 新增：检测手指结构（返回每根手指的节数）
  fn DetectFingerStructure side =
  ( 
    local bipedName = getBipedName() 
    if bipedName == "" then return undefined
    
    local handSide = side
    local fingerInfo = #()  -- 存储每根手指的信息：#(fingerIndex, segmentCount)
    
    -- 检测Finger0-4每根手指
    for fingerIdx = 0 to 4 do
    ( 
      local segmentCount = 0
      local fingerName = "Finger" + fingerIdx as string
      
      -- 检测最多4节（Knuckles模式）
      for segIdx = 0 to 3 do
      ( 
        local boneName = if segIdx == 0 then
          (bipedName + " " + handSide + " " + fingerName)
        else
          (bipedName + " " + handSide + " " + fingerName + segIdx as string)
        
        local bone = getNodeByName boneName
        if bone != undefined and not isDeleted bone then
          segmentCount = segIdx + 1
        else
          exit  -- 遇到不存在的节就停止检测
      ) 
      
      append fingerInfo #(fingerIdx, segmentCount)
    ) 
    
    return fingerInfo
  ) 
  -- 更新按钮启用/禁用状态
  fn UpdateFingerButtonStates =
  ( 
    local bipedName = getBipedName() 
    if bipedName == "" then
    ( 
      -- 没有biped时禁用所有按钮
      local allBtns = #(
        select_rthumb1_btn, select_rthumb2_btn, select_rthumb3_btn,
        select_rfing11_btn, select_rfing12_btn, select_rfing13_btn,
        select_rfing21_btn, select_rfing22_btn, select_rfing23_btn,
        select_rfing31_btn, select_rfing32_btn, select_rfing33_btn,
        select_rfing41_btn, select_rfing42_btn, select_rfing43_btn,
        select_lthumb1_btn, select_lthumb2_btn, select_lthumb3_btn,
        select_lfing11_btn, select_lfing12_btn, select_lfing13_btn,
        select_lfing21_btn, select_lfing22_btn, select_lfing23_btn,
        select_lfing31_btn, select_lfing32_btn, select_lfing33_btn,
        select_lfing41_btn, select_lfing42_btn, select_lfing43_btn,
        btnFingerLineR1, btnFingerLineR2, btnFingerLineR3, btnFingerLineR4, btnFingerLineR5,
        btnFingerLineL1, btnFingerLineL2, btnFingerLineL3, btnFingerLineL4, btnFingerLineL5
      )
      for btn in allBtns do
      ( 
        btn.enabled = false
        btn.highlightColor = (color 128 128 128)
      )
      return()
    )
    
    -- 检测右手手指结构
    local rFingerInfo = DetectFingerStructure "R"
    local rIsKnuckles = detectKnucklesMode()
    
    -- 检测左手手指结构
    local lFingerInfo = DetectFingerStructure "L"
    local lIsKnuckles = detectKnucklesMode()
    
    -- 右手按钮数组：[手指索引][节索引] = 按钮
    local rBtnMap = #(
      #(select_rthumb1_btn, select_rthumb2_btn, select_rthumb3_btn),      -- Finger0
      #(select_rfing11_btn, select_rfing12_btn, select_rfing13_btn),      -- Finger1
      #(select_rfing21_btn, select_rfing22_btn, select_rfing23_btn),      -- Finger2
      #(select_rfing31_btn, select_rfing32_btn, select_rfing33_btn),      -- Finger3
      #(select_rfing41_btn, select_rfing42_btn, select_rfing43_btn)       -- Finger4
    )
    
    -- 左手按钮数组
    local lBtnMap = #(
      #(select_lthumb1_btn, select_lthumb2_btn, select_lthumb3_btn),
      #(select_lfing11_btn, select_lfing12_btn, select_lfing13_btn),
      #(select_lfing21_btn, select_lfing22_btn, select_lfing23_btn),
      #(select_lfing31_btn, select_lfing32_btn, select_lfing33_btn),
      #(select_lfing41_btn, select_lfing42_btn, select_lfing43_btn)
    )
    
    -- 单指选择按钮
    local rLineBtns = #(btnFingerLineR1, btnFingerLineR2, btnFingerLineR3, btnFingerLineR4, btnFingerLineR5)
    local lLineBtns = #(btnFingerLineL1, btnFingerLineL2, btnFingerLineL3, btnFingerLineL4, btnFingerLineL5)
    
    -- 更新右手按钮
    for i = 1 to 5 do
    ( 
      local fingerIdx = i - 1
      local segCount = rFingerInfo[i][2]
      local btns = rBtnMap[i]
      
      -- Knuckles模式：需要跳过第一节（掌骨节）
      local actualSegCount = if rIsKnuckles and fingerIdx != 0 then
        (if segCount > 1 then segCount - 1 else 0)
      else
        segCount
      
      -- 更新3个节按钮
      for j = 1 to 3 do
      ( 
        if j <= actualSegCount then
        ( 
          btns[j].enabled = true
          btns[j].highlightColor = if fingerIdx == 0 then
            rolBsBipedTools.mcRightThumb
          else
            rolBsBipedTools.mcRightFinger
        )
        else
        ( 
          btns[j].enabled = false
          btns[j].highlightColor = (color 128 128 128)
        )
      )
      
      -- 更新单指选择按钮
      if segCount > 0 then
      ( 
        rLineBtns[i].enabled = true
        rLineBtns[i].highlightColor = if fingerIdx == 0 then
          (rolBsBipedTools.mcRightThumb * 0.7)
        else
          (rolBsBipedTools.mcRightFinger * 0.7)
      )
      else
      ( 
        rLineBtns[i].enabled = false
        rLineBtns[i].highlightColor = (color 128 128 128)
      )
    )
    
    -- 更新左手按钮
    for i = 1 to 5 do
    ( 
      local fingerIdx = i - 1
      local segCount = lFingerInfo[i][2]
      local btns = lBtnMap[i]
      
      -- Knuckles模式：需要跳过第一节（掌骨节）
      local actualSegCount = if lIsKnuckles and fingerIdx != 0 then
        (if segCount > 1 then segCount - 1 else 0)
      else
        segCount
      
      -- 更新3个节按钮
      for j = 1 to 3 do
      ( 
        if j <= actualSegCount then
        ( 
          btns[j].enabled = true
          btns[j].highlightColor = if fingerIdx == 0 then
            rolBsBipedTools.mcLeftThumb
          else
            rolBsBipedTools.mcLeftFinger
        )
        else
        ( 
          btns[j].enabled = false
          btns[j].highlightColor = (color 128 128 128)
        )
      )
      
      -- 更新单指选择按钮
      if segCount > 0 then
      ( 
        lLineBtns[i].enabled = true
        lLineBtns[i].highlightColor = if fingerIdx == 0 then
          (rolBsBipedTools.mcLeftThumb * 0.7)
        else
          (rolBsBipedTools.mcLeftFinger * 0.7)
      )
      else
      ( 
        lLineBtns[i].enabled = false
        lLineBtns[i].highlightColor = (color 128 128 128)
      )
    )
  )
  -- 新增截断 →


	-- ← 新增：选择单根手指所有骨骼
	fn SelectWholeFinger side fingerIndex =
	( 
	    local bipedName = getBipedName() 
	    if bipedName == "" then return false
	    
	    local isKnuckles = detectKnucklesMode() 
	    local handSide = side
	    local fingerBones = #() 
	    
	    if fingerIndex == 0 then
	    ( 
	      -- 拇指：Finger0, Finger01, Finger02, (Finger03在Knuckles可能不存在)
	      local f0 = getNodeByName (bipedName + " " + handSide + " Finger0") 
	      local f01 = getNodeByName (bipedName + " " + handSide + " Finger01") 
	      local f02 = getNodeByName (bipedName + " " + handSide + " Finger02") 
	      local f03 = getNodeByName (bipedName + " " + handSide + " Finger03") 
	      if f0 != undefined and not isDeleted f0 then append fingerBones f0
	      if f01 != undefined and not isDeleted f01 then append fingerBones f01
	      if f02 != undefined and not isDeleted f02 then append fingerBones f02
	      if f03 != undefined and not isDeleted f03 then append fingerBones f03
	    ) 
	    else
	    ( 
		    -- Finger1-4
		    local fingerName = "Finger" + fingerIndex as string
		      
		    if isKnuckles then
		    ( 
		        -- Knuckles模式：包含掌骨节(Finger1/2/3/4) + 3指节(Finger11/21/31/41等)
		        local f0 = getNodeByName (bipedName + " " + handSide + " " + fingerName) 
		        local f1 = getNodeByName (bipedName + " " + handSide + " " + fingerName + "1") 
		        local f2 = getNodeByName (bipedName + " " + handSide + " " + fingerName + "2") 
		        local f3 = getNodeByName (bipedName + " " + handSide + " " + fingerName + "3") 
		        if f0 != undefined and not isDeleted f0 then append fingerBones f0
		        if f1 != undefined and not isDeleted f1 then append fingerBones f1
		        if f2 != undefined and not isDeleted f2 then append fingerBones f2
		        if f3 != undefined and not isDeleted f3 then append fingerBones f3
		    ) 
		    else
		    ( 
		        -- 标准模式：Finger1/2/3/4 + Finger11/21等
		        local f0 = getNodeByName (bipedName + " " + handSide + " " + fingerName) 
		        local f1 = getNodeByName (bipedName + " " + handSide + " " + fingerName + "1") 
		        local f2 = getNodeByName (bipedName + " " + handSide + " " + fingerName + "2") 
		        if f0 != undefined and not isDeleted f0 then append fingerBones f0
		        if f1 != undefined and not isDeleted f1 then append fingerBones f1
		        if f2 != undefined and not isDeleted f2 then append fingerBones f2
		    ) 
	    ) 
	    
	    if fingerBones.count > 0 then
	    ( 
	      select fingerBones
	      return true
	    ) 
	    return false
	) 

	-- 选择所有手指（包含拇指Finger0）
	fn SelectAllFingers side =
	( 
	    local bipedName = getBipedName() 
	    if bipedName == "" then return false
	    
	    local isKnuckles = detectKnucklesMode() 
	    local handSide = side
	    local allFingerBones = #() 
	    
	    -- 选择Finger0-4所有骨骼（包含拇指）
	    for fingerIdx = 0 to 4 do
	    ( 
	      local fingerName = "Finger" + fingerIdx as string
	      
	      if isKnuckles then
	      ( 
	        -- Knuckles模式：4节（拇指3节）
	        if fingerIdx == 0 then
	        ( 
	          -- 拇指：Finger0, Finger01, Finger02
	          local f0 = getNodeByName (bipedName + " " + handSide + " " + fingerName) 
	          local f1 = getNodeByName (bipedName + " " + handSide + " " + fingerName + "1") 
	          local f2 = getNodeByName (bipedName + " " + handSide + " " + fingerName + "2") 
	          if f0 != undefined and not isDeleted f0 then append allFingerBones f0
	          if f1 != undefined and not isDeleted f1 then append allFingerBones f1
	          if f2 != undefined and not isDeleted f2 then append allFingerBones f2
	        )
	        else
	        ( 
	          -- 其他手指：包含掌骨节 + 3指节
	          local f0 = getNodeByName (bipedName + " " + handSide + " " + fingerName) 
	          local f1 = getNodeByName (bipedName + " " + handSide + " " + fingerName + "1") 
	          local f2 = getNodeByName (bipedName + " " + handSide + " " + fingerName + "2") 
	          local f3 = getNodeByName (bipedName + " " + handSide + " " + fingerName + "3") 
	          if f0 != undefined and not isDeleted f0 then append allFingerBones f0
	          if f1 != undefined and not isDeleted f1 then append allFingerBones f1
	          if f2 != undefined and not isDeleted f2 then append allFingerBones f2
	          if f3 != undefined and not isDeleted f3 then append allFingerBones f3
	        )
	      ) 
	      else
	      ( 
	        -- 标准模式：3节
	        local f0 = getNodeByName (bipedName + " " + handSide + " " + fingerName) 
	        local f1 = getNodeByName (bipedName + " " + handSide + " " + fingerName + "1") 
	        local f2 = getNodeByName (bipedName + " " + handSide + " " + fingerName + "2") 
	        if f0 != undefined and not isDeleted f0 then append allFingerBones f0
	        if f1 != undefined and not isDeleted f1 then append allFingerBones f1
	        if f2 != undefined and not isDeleted f2 then append allFingerBones f2
	      ) 
	    ) 
	    
	    if allFingerBones.count > 0 then
	    ( 
	      select allFingerBones
	      return true
	    ) 
	    return false
	)
	-- 新增截断 →

	-- ← 新增：智能获取手指骨骼（根据模式自动映射）
	fn GetFingerBone side fingerIdx segmentIdx =
	( 
	    local bipedName = getBipedName() 
	    if bipedName == "" then return undefined
	    
	    local isKnuckles = detectKnucklesMode() 
	    local handSide = side
	    local boneName = ""
	    
	    -- 拇指特殊处理
	    if fingerIdx == 0 then
	    ( 
	      if segmentIdx == 1 then boneName = bipedName + " " + handSide + " Finger0"
	      else if segmentIdx == 2 then boneName = bipedName + " " + handSide + " Finger01"
	      else if segmentIdx == 3 then boneName = bipedName + " " + handSide + " Finger02"
	    ) 
	    else
	    ( 
	      local fingerName = "Finger" + fingerIdx as string
	      
	      if isKnuckles then
	      ( 
	        -- Knuckles模式：跳过掌骨节，直接映射到Finger11/12/13
	        if segmentIdx == 1 then boneName = bipedName + " " + handSide + " " + fingerName + "1"
	        else if segmentIdx == 2 then boneName = bipedName + " " + handSide + " " + fingerName + "2"
	        else if segmentIdx == 3 then boneName = bipedName + " " + handSide + " " + fingerName + "3"
	      ) 
	      else
	      ( 
	        -- 标准模式：先检查是否有根节点Finger1/2/3/4
	        local rootNode = getNodeByName (bipedName + " " + handSide + " " + fingerName)
	        
	        if rootNode != undefined and not isDeleted rootNode then
	        ( 
	          -- 有根节点（3节模式）：Finger1 → Finger11 → Finger12
	          if segmentIdx == 1 then boneName = bipedName + " " + handSide + " " + fingerName
	          else if segmentIdx == 2 then boneName = bipedName + " " + handSide + " " + fingerName + "1"
	          else if segmentIdx == 3 then boneName = bipedName + " " + handSide + " " + fingerName + "2"
	        ) 
	        else
	        ( 
	          -- 无根节点（2节模式）：直接从Finger11开始
	          if segmentIdx == 1 then boneName = bipedName + " " + handSide + " " + fingerName + "1"
	          else if segmentIdx == 2 then boneName = bipedName + " " + handSide + " " + fingerName + "2"
	          else if segmentIdx == 3 then return undefined  -- 第3节不存在
	        ) 
	      ) 
	    ) 
	    
	    if boneName != "" then
	    ( 
	      local bone = getNodeByName boneName
	      if bone != undefined and not isDeleted bone then
	        return bone
	    ) 
	    
	    return undefined
	) 




	on select_lhand1_btn changed state do (
		select_lhand1_btn.state = true
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot)) do ( rolBsBipedTools.SetButtonState false; return ())
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			rolBsBipedTools.Straighten rolBsBipedTools.m_LHand ((eulerangles -90 0 0) as quat)
			return ()
		)
		
		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup rolBsBipedTools.m_LHand) catch (
			rolBsBipedTools.m_LHand = rolBsBipedTools.GetLHand()
			select rolBsBipedTools.m_LHand
		)
	)

	on select_lhand1_btn rightclick do 
	(
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot)) do ( rolBsBipedTools.SetButtonState false; return ())
		rolBsBipedTools.m_RHand = rolBsBipedTools.GetRHand()
		select rolBsBipedTools.m_RHand
	)

	
	on select_rhand1_btn changed state do (
		select_rhand1_btn.state = true
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot)) do ( rolBsBipedTools.SetButtonState false; return ())
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			rolBsBipedTools.Straighten rolBsBipedTools.m_RHand ((eulerangles 90 0 0) as quat)
			return ()
		)

		selBackup = selection as array

		try(rolBsBipedTools.CompSelect selBackup rolBsBipedTools.m_RHand) catch (
			rolBsBipedTools.m_RHand = rolBsBipedTools.GetRHand()
			select rolBsBipedTools.m_RHand
			
		)
	)

	on select_rhand1_btn rightclick do 
	(
		if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot)) do ( rolBsBipedTools.SetButtonState false; return ())
		rolBsBipedTools.m_LHand = rolBsBipedTools.GetLHand()
		select rolBsBipedTools.m_LHand
	)

	on chbTips changed state do
	(
		chbTips.state = true
	)

	on chbRFingers changed state do
	( 
	    chbRFingers.state = true
	    if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot)) do (return ()) 
	    SelectAllFingers "R"
	) 

	-- 右手拇指
	on select_rthumb1_btn changed state do ( 
	    select_rthumb1_btn.state = true
	    local bone = GetFingerBone "R" 0 1
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
	) 

	on select_rthumb2_btn changed state do ( 
	    select_rthumb2_btn.state = true
	    local bone = GetFingerBone "R" 0 2
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
	)

	on select_rthumb3_btn changed state do ( 
	    select_rthumb3_btn.state = true
	    local bone = GetFingerBone "R" 0 3
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
	) 

	-- 右手食指
	on select_rfing11_btn changed state do ( 
	    select_rfing11_btn.state = true
	    local bone = GetFingerBone "R" 1 1
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
	  ) 

	on select_rfing12_btn changed state do ( 
	    select_rfing12_btn.state = true
	    local bone = GetFingerBone "R" 1 2
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
	  ) 

	on select_rfing13_btn changed state do ( 
	    select_rfing13_btn.state = true
	    local bone = GetFingerBone "R" 1 3
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
	  ) 

  	-- 右手中指
	on select_rfing21_btn changed state do ( 
	    select_rfing21_btn.state = true
	    local bone = GetFingerBone "R" 2 1
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
	) 

	  on select_rfing22_btn changed state do ( 
	    select_rfing22_btn.state = true
	    local bone = GetFingerBone "R" 2 2
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
	  ) 

	on select_rfing23_btn changed state do ( 
	    select_rfing23_btn.state = true
	    local bone = GetFingerBone "R" 2 3
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
	) 


 	 -- 右手无名指
 	 on select_rfing31_btn changed state do ( 
	    select_rfing31_btn.state = true
	    local bone = GetFingerBone "R" 3 1
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
 	 ) 

 	 on select_rfing32_btn changed state do ( 
	    select_rfing32_btn.state = true
	    local bone = GetFingerBone "R" 3 2
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
 	 ) 

 	 on select_rfing33_btn changed state do ( 
	    select_rfing33_btn.state = true
	    local bone = GetFingerBone "R" 3 3
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
  	) 

 	 -- 右手小指
 	 on select_rfing41_btn changed state do ( 
	    select_rfing41_btn.state = true
	    local bone = GetFingerBone "R" 4 1
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
  	) 

  	on select_rfing42_btn changed state do ( 
	    select_rfing42_btn.state = true
	    local bone = GetFingerBone "R" 4 2
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
  	) 

 	 on select_rfing43_btn changed state do ( 
	    select_rfing43_btn.state = true
	    local bone = GetFingerBone "R" 4 3
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
  	)


	on chbLFingers changed state do
	( 
	    chbLFingers.state = true
	    if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot)) do (return ()) 
	    SelectAllFingers "L"
	)

	-- 左手拇指
  	on select_lthumb1_btn changed state do ( 
	    select_lthumb1_btn.state = true
	    local bone = GetFingerBone "L" 0 1
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
  	) 

 	 on select_lthumb2_btn changed state do ( 
	    select_lthumb2_btn.state = true
	    local bone = GetFingerBone "L" 0 2
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
  	) 

 	 on select_lthumb3_btn changed state do ( 
	    select_lthumb3_btn.state = true
	    local bone = GetFingerBone "L" 0 3
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
 	 ) 

  	-- 左手食指
  	on select_lfing11_btn changed state do ( 
	    select_lfing11_btn.state = true
	    local bone = GetFingerBone "L" 1 1
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
  	) 

  	on select_lfing12_btn changed state do ( 
	    select_lfing12_btn.state = true
	    local bone = GetFingerBone "L" 1 2
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
  	) 

  	on select_lfing13_btn changed state do ( 
	    select_lfing13_btn.state = true
	    local bone = GetFingerBone "L" 1 3
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
  	) 

  	-- 左手中指
  	on select_lfing21_btn changed state do ( 
	    select_lfing21_btn.state = true
	    local bone = GetFingerBone "L" 2 1
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
  	) 

  	on select_lfing22_btn changed state do ( 
	    select_lfing22_btn.state = true
	    local bone = GetFingerBone "L" 2 2
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
  	) 

  	on select_lfing23_btn changed state do ( 
	    select_lfing23_btn.state = true
	    local bone = GetFingerBone "L" 2 3
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
  	) 

 	 -- 左手无名指
  	on select_lfing31_btn changed state do ( 
	    select_lfing31_btn.state = true
	    local bone = GetFingerBone "L" 3 1
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
  	) 

  	on select_lfing32_btn changed state do ( 
	    select_lfing32_btn.state = true
	    local bone = GetFingerBone "L" 3 2
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
  	) 

  	on select_lfing33_btn changed state do ( 
	    select_lfing33_btn.state = true
	    local bone = GetFingerBone "L" 3 3
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
 	 ) 

  	-- 左手小指
  	on select_lfing41_btn changed state do ( 
	    select_lfing41_btn.state = true
	    local bone = GetFingerBone "L" 4 1
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
  	) 

 	 on select_lfing42_btn changed state do ( 
	    select_lfing42_btn.state = true
	    local bone = GetFingerBone "L" 4 2
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
  	) 

  	on select_lfing43_btn changed state do ( 
	    select_lfing43_btn.state = true
	    local bone = GetFingerBone "L" 4 3
	    if bone == undefined do return()
	    
	    selBackup = selection as array
	    
	    if keyboard.controlPressed and keyboard.altpressed do ( 
	      rolBsBipedTools.Straighten #(bone) ((eulerangles 0 0 0) as quat) 
	      return () 
	    ) 
	    
	    try(rolBsBipedTools.CompSelect selBackup #(bone)) catch (select bone)
  	)

-- 右手单根手指选择按钮
  on btnFingerLineR1 changed state do ( 
    btnFingerLineR1.state = true
    SelectWholeFinger "R" 0
  ) 
  
  on btnFingerLineR2 changed state do ( 
    btnFingerLineR2.state = true
    SelectWholeFinger "R" 1
  ) 
  
  on btnFingerLineR3 changed state do ( 
    btnFingerLineR3.state = true
    SelectWholeFinger "R" 2
  ) 
  
  on btnFingerLineR4 changed state do ( 
    btnFingerLineR4.state = true
    SelectWholeFinger "R" 3
  ) 
  
  on btnFingerLineR5 changed state do ( 
    btnFingerLineR5.state = true
    SelectWholeFinger "R" 4
  ) 

	
  -- 左手单根手指选择按钮
  on btnFingerLineL1 changed state do ( 
    btnFingerLineL1.state = true
    SelectWholeFinger "L" 0
  ) 
  
  on btnFingerLineL2 changed state do ( 
    btnFingerLineL2.state = true
    SelectWholeFinger "L" 1
  ) 
  
  on btnFingerLineL3 changed state do ( 
    btnFingerLineL3.state = true
    SelectWholeFinger "L" 2
  ) 
  
  on btnFingerLineL4 changed state do ( 
    btnFingerLineL4.state = true
    SelectWholeFinger "L" 3
  ) 
  
  on btnFingerLineL5 changed state do ( 
    btnFingerLineL5.state = true
    SelectWholeFinger "L" 4
  )
	
	-- 线性插值函数
	function LerpFloat a b bias = (
		return a + (b - a) * bias
	)

	function MakeClosest quat1 quat2 = -- modifies quat2 and also returns quat2
	(
		local dot = quat1.x*quat2.x + quat1.y*quat2.y + quat1.z*quat2.z+quat1.w*quat2.w
		if (dot < 0.0) do (quat2.x = -quat2.x; quat2.y = -quat2.y;quat2.z = -quat2.z; quat2.w = -quat2.w)
		quat2
	)
	
	-- 手指张开函数 (完全参考BipedAssist实现，6个参数)
	-- 手指张开函数（优化版 - 只对根指节操作）
	function SpreadFingers fingersArr minAngle maxAngle spread bendStart bendEnd isKnucklesMode side =
	( 
	    if fingersArr.count < 1 do return() 
	    if fingersArr.count == 1 then
	    ( 
	      return() 
	    ) 
	    
	    local spreadMultiplier = if side == "L" then -1.0 else 1.0
	    
	    for fingerIndex = 1 to fingersArr.count do
	    ( 
		    if fingersArr[fingerIndex].count > 0 then
		    ( 
		      	local tFingerBias = ((fingerIndex - 1) as float) / ((fingersArr.count - 1) as float) 
		        local tWeightedAngle = LerpFloat bendStart bendEnd tFingerBias
		        local tSpreadMaxAngle = LerpFloat minAngle maxAngle tFingerBias
		        local tSpreadMaxQuat = eulerToQuat (eulerAngles 0 (tSpreadMaxAngle * spreadMultiplier) tWeightedAngle) order:1
		        local tSpreadMinQuat = eulerToQuat (eulerAngles 0 0 tWeightedAngle) order:1
		        MakeClosest tSpreadMinQuat tSpreadMaxQuat
		        local tRot = slerp tSpreadMinQuat tSpreadMaxQuat spread
		        
		        try
		        ( 
		          tRot = tRot * fingersArr[fingerIndex][1].parent.transform.rotation
		          biped.setTransform fingersArr[fingerIndex][1] #rotation tRot false
		        ) 
		        catch() 
		    ) 
	    ) 
	)
		
	-- 手指弯曲函数 (完全参考BipedAssist实现)
	-- 手指弯曲函数（优化版 - 对所有指节操作）
	function BendFingers fingersArr bendStart bendEnd spread isKnucklesMode side = ( 
	    if fingersArr.count < 1 do return() 
	    
	    local spreadMultiplier = if side == "L" then -1.0 else 1.0
	    
	    if fingersArr.count == 1 then
	    ( 
	      local avgAngle = (bendStart + bendEnd) / 2.0
	      
	      if fingersArr[1].count > 0 then
	      ( 
	        try
	        ( 
	          local tRot = eulerToQuat (eulerAngles avgAngle 0 0) order:6
	          tRot = tRot * fingersArr[1][1].parent.transform.rotation
	          biped.setTransform fingersArr[1][1] #rotation tRot false
	          
	          if fingersArr[1].count >= 2 do
	          ( 
	            for i = 2 to fingersArr[1].count do
	            ( 
	              tRot = eulerToQuat (eulerAngles avgAngle 0 0) order:6
	              tRot = tRot * fingersArr[1][i].parent.transform.rotation
	              biped.setTransform fingersArr[1][i] #rotation tRot false
	            ) 
	          ) 
	        ) 
	        catch() 
	      ) 
	      return() 
	    ) 
	    
	    for fingerIndex = 1 to fingersArr.count do
	    ( 
	        if fingersArr[fingerIndex].count > 0 then
	        ( 
		        local tFingerBias = ((fingerIndex - 1) as float) / ((fingersArr.count - 1) as float) 
		        local tWeightedAngle = LerpFloat bendStart bendEnd tFingerBias
		        local tSpreadSliderValue = ((tFingerBias - 0.5) * 2.0) * spread * mc_spreadMaxAngle * spreadMultiplier
		        local tBendY = LerpFloat tSpreadSliderValue 0 ((tWeightedAngle as float) / 90.0) 
		        local tBendX = LerpFloat 0 -tSpreadSliderValue ((tWeightedAngle as float) / 90.0) 
		        
		        try
		        ( 
		          local tRot = eulerToQuat (eulerAngles tWeightedAngle tBendY tBendX) order:6
		          tRot = tRot * fingersArr[fingerIndex][1].parent.transform.rotation
		          biped.setTransform fingersArr[fingerIndex][1] #rotation tRot false
		          
		          if fingersArr[fingerIndex].count >= 2 do
		          ( 
		            for i = 2 to fingersArr[fingerIndex].count do
		            ( 
		              tRot = eulerToQuat (eulerAngles tWeightedAngle 0 0) order:6
		              tRot = tRot * fingersArr[fingerIndex][i].parent.transform.rotation
		              biped.setTransform fingersArr[fingerIndex][i] #rotation tRot false
		            ) 
		          ) 
		        ) 
		        catch() 
		    ) 
	    ) 
	)

	  function GetFingerArray side isKnucklesMode =
	  ( 
	    local fingerArr = #() 
	    local bipedName = getBipedName() 
	    
	    if bipedName == "" or bipedName == undefined then return fingerArr
	    
	    local handSide = side
	    
	    if isKnucklesMode then
	    ( 
	      -- Knuckles模式：跳过掌骨节(Finger1/2/3/4)，从Finger11/21/31/41开始
	      
	      -- Finger1 (食指) - 3节
	      local finger1 = #() 
	      local f1_1 = getNodeByName (bipedName + " " + handSide + " Finger11") 
	      local f1_2 = getNodeByName (bipedName + " " + handSide + " Finger12") 
	      local f1_3 = getNodeByName (bipedName + " " + handSide + " Finger13") 
	      if f1_1 != undefined and not isDeleted f1_1 then append finger1 f1_1
	      if f1_2 != undefined and not isDeleted f1_2 then append finger1 f1_2
	      if f1_3 != undefined and not isDeleted f1_3 then append finger1 f1_3
	      if finger1.count > 0 do append fingerArr finger1
	      
	      -- Finger2 (中指) - 3节
	      local finger2 = #() 
	      local f2_1 = getNodeByName (bipedName + " " + handSide + " Finger21") 
	      local f2_2 = getNodeByName (bipedName + " " + handSide + " Finger22") 
	      local f2_3 = getNodeByName (bipedName + " " + handSide + " Finger23") 
	      if f2_1 != undefined and not isDeleted f2_1 then append finger2 f2_1
	      if f2_2 != undefined and not isDeleted f2_2 then append finger2 f2_2
	      if f2_3 != undefined and not isDeleted f2_3 then append finger2 f2_3
	      if finger2.count > 0 do append fingerArr finger2
	      
	      -- Finger3 (无名指) - 3节
	      local finger3 = #() 
	      local f3_1 = getNodeByName (bipedName + " " + handSide + " Finger31") 
	      local f3_2 = getNodeByName (bipedName + " " + handSide + " Finger32") 
	      local f3_3 = getNodeByName (bipedName + " " + handSide + " Finger33") 
	      if f3_1 != undefined and not isDeleted f3_1 then append finger3 f3_1
	      if f3_2 != undefined and not isDeleted f3_2 then append finger3 f3_2
	      if f3_3 != undefined and not isDeleted f3_3 then append finger3 f3_3
	      if finger3.count > 0 do append fingerArr finger3
	      
	      -- Finger4 (小指) - 3节
	      local finger4 = #() 
	      local f4_1 = getNodeByName (bipedName + " " + handSide + " Finger41") 
	      local f4_2 = getNodeByName (bipedName + " " + handSide + " Finger42") 
	      local f4_3 = getNodeByName (bipedName + " " + handSide + " Finger43") 
	      if f4_1 != undefined and not isDeleted f4_1 then append finger4 f4_1
	      if f4_2 != undefined and not isDeleted f4_2 then append finger4 f4_2
	      if f4_3 != undefined and not isDeleted f4_3 then append finger4 f4_3
	      if finger4.count > 0 do append fingerArr finger4
	      
	    ) 
	    else
	    ( 
	      -- 标准3节模式：Finger1-4各3节（包含Finger1/2/3/4根节），跳过拇指
	      
	      -- Finger1 (食指) - 3节
	      local finger1 = #() 
	      local f1_0 = getNodeByName (bipedName + " " + handSide + " Finger1") 
	      local f1_1 = getNodeByName (bipedName + " " + handSide + " Finger11") 
	      local f1_2 = getNodeByName (bipedName + " " + handSide + " Finger12") 
	      if f1_0 != undefined and not isDeleted f1_0 then append finger1 f1_0
	      if f1_1 != undefined and not isDeleted f1_1 then append finger1 f1_1
	      if f1_2 != undefined and not isDeleted f1_2 then append finger1 f1_2
	      if finger1.count > 0 do append fingerArr finger1
	      
	      -- Finger2 (中指) - 3节
	      local finger2 = #() 
	      local f2_0 = getNodeByName (bipedName + " " + handSide + " Finger2") 
	      local f2_1 = getNodeByName (bipedName + " " + handSide + " Finger21") 
	      local f2_2 = getNodeByName (bipedName + " " + handSide + " Finger22") 
	      if f2_0 != undefined and not isDeleted f2_0 then append finger2 f2_0
	      if f2_1 != undefined and not isDeleted f2_1 then append finger2 f2_1
	      if f2_2 != undefined and not isDeleted f2_2 then append finger2 f2_2
	      if finger2.count > 0 do append fingerArr finger2
	      
	      -- Finger3 (无名指) - 3节
	      local finger3 = #() 
	      local f3_0 = getNodeByName (bipedName + " " + handSide + " Finger3") 
	      local f3_1 = getNodeByName (bipedName + " " + handSide + " Finger31") 
	      local f3_2 = getNodeByName (bipedName + " " + handSide + " Finger32") 
	      if f3_0 != undefined and not isDeleted f3_0 then append finger3 f3_0
	      if f3_1 != undefined and not isDeleted f3_1 then append finger3 f3_1
	      if f3_2 != undefined and not isDeleted f3_2 then append finger3 f3_2
	      if finger3.count > 0 do append fingerArr finger3
	      
	      -- Finger4 (小指) - 3节
	      local finger4 = #() 
	      local f4_0 = getNodeByName (bipedName + " " + handSide + " Finger4") 
	      local f4_1 = getNodeByName (bipedName + " " + handSide + " Finger41") 
	      local f4_2 = getNodeByName (bipedName + " " + handSide + " Finger42") 
	      if f4_0 != undefined and not isDeleted f4_0 then append finger4 f4_0
	      if f4_1 != undefined and not isDeleted f4_1 then append finger4 f4_1
	      if f4_2 != undefined and not isDeleted f4_2 then append finger4 f4_2
	      if finger4.count > 0 do append fingerArr finger4
	      
	    ) 
	    
	    return fingerArr
	  )
	-- 右手张开事件
	on uiRSpread rightClick do (
		uiRSpread.value = 0
		uiRSpread.changed 0
	)
	
	on uiRSpread changed var do ( 
	    if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot)) do return() 
	    rIsKnuckles = detectKnucklesMode()  -- 动态检测
	    local m_RFingers = GetFingerArray "R" rIsKnuckles
	    if m_RFingers.count > 0 then ( 
	      BendFingers m_RFingers uiRBendStart.value uiRBendEnd.value var rIsKnuckles "R"
	      if var != 0 then
	        SpreadFingers m_RFingers (-mc_spreadMaxAngle) mc_spreadMaxAngle var uiRBendStart.value uiRBendEnd.value rIsKnuckles "R"
	    ) 
	) 
	
	-- 左手张开事件
	on uiLSpread rightClick do (
		uiLSpread.value = 0
		uiLSpread.changed 0
	)
	
	on uiLSpread changed var do ( 
	    if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot)) do return() 
	    lIsKnuckles = detectKnucklesMode()  -- 动态检测
	    local m_LFingers = GetFingerArray "L" lIsKnuckles
	    if m_LFingers.count > 0 then ( 
	      BendFingers m_LFingers uiLBendStart.value uiLBendEnd.value var lIsKnuckles "L"
	      if var != 0 then
	        SpreadFingers m_LFingers (-mc_spreadMaxAngle) mc_spreadMaxAngle var uiLBendStart.value uiLBendEnd.value lIsKnuckles "L"
	    ) 
	) 
	
	-- 右手弯曲事件 (食指、中指、无名指)
	on uiRBendEnd changed var do ( 
	    if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot)) do return() 
	    rIsKnuckles = detectKnucklesMode()  -- 动态检测
	    local m_RFingers = GetFingerArray "R" rIsKnuckles
	    if m_RFingers.count > 0 then ( 
	      BendFingers m_RFingers uiRBendStart.value uiRBendEnd.value uiRSpread.value rIsKnuckles "R"
	      if uiRSpread.value != 0 then
	        SpreadFingers m_RFingers (-mc_spreadMaxAngle) mc_spreadMaxAngle uiRSpread.value uiRBendStart.value uiRBendEnd.value rIsKnuckles "R"
	    ) 
	) 

	
	on uiRBendStart changed var do ( 
	    if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot)) do return() 
	    rIsKnuckles = detectKnucklesMode()  -- 动态检测
	    local m_RFingers = GetFingerArray "R" rIsKnuckles
	    if m_RFingers.count > 0 then ( 
	      BendFingers m_RFingers uiRBendStart.value uiRBendEnd.value uiRSpread.value rIsKnuckles "R"
	      if uiRSpread.value != 0 then
	        SpreadFingers m_RFingers (-mc_spreadMaxAngle) mc_spreadMaxAngle uiRSpread.value uiRBendStart.value uiRBendEnd.value rIsKnuckles "R"
	    ) 
	) 
	
	-- 左手弯曲事件 (中指、无名指、小指)
	on uiLBendStart changed var do ( 
	    if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot)) do return() 
	    lIsKnuckles = detectKnucklesMode()  -- 动态检测
	    local m_LFingers = GetFingerArray "L" lIsKnuckles
	    if m_LFingers.count > 0 then ( 
	      BendFingers m_LFingers uiLBendStart.value uiLBendEnd.value uiLSpread.value lIsKnuckles "L"
	      if uiLSpread.value != 0 then
	        SpreadFingers m_LFingers (-mc_spreadMaxAngle) mc_spreadMaxAngle uiLSpread.value uiLBendStart.value uiLBendEnd.value lIsKnuckles "L"
	    ) 
	) 
	
	on uiLBendEnd changed var do ( 
	    if (rolBsBipedTools.m_workingBipRoot == undefined or (isDeleted rolBsBipedTools.m_workingBipRoot)) do return() 
	    lIsKnuckles = detectKnucklesMode()  -- 动态检测
	    local m_LFingers = GetFingerArray "L" lIsKnuckles
	    if m_LFingers.count > 0 then ( 
	      BendFingers m_LFingers uiLBendStart.value uiLBendEnd.value uiLSpread.value lIsKnuckles "L"
	      if uiLSpread.value != 0 then
	        SpreadFingers m_LFingers (-mc_spreadMaxAngle) mc_spreadMaxAngle uiLSpread.value uiLBendStart.value uiLBendEnd.value lIsKnuckles "L"
	    ) 
	)

	on rolBSFingers open do
	( 
	    -- 打开面板时更新按钮状态
	    UpdateFingerButtonStates()
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
	
	-- 颜文字脸数组 (多样化简洁版，无脸框)
	local headFaces = #("｡◕ᴗ◕｡", \
		"^_^", "T_T", "O_O", "o_o", "x_x", "Q_Q", "-_-", ">_<", "<_<", ">_>",
		"v_v", "u_u", "U_U", "o_O", "O_o", "¬_¬", "TωT", "OwO", "UwU", "TwT",
		"owo", "uwu", "ToT", "TAT", "XD", "OvO", "oVo", "TvT", "T^T", "T.T",
		"ಥ_ಥ", "ಥ﹏ಥ", "ಥ‿ಥ", "ಥ益ಥ", "ಥ⌣ಥ", "ಥ‸ಥ", "ಥಥ"
	)
		local currentFaceIndex = 1
	
	-- 保存脸型索引到配置文件
	fn fnSaveHeadFace =
	(
		SetINISetting iniBsBipedTools "BsBipedTools" "HeadFaceIndex" (currentFaceIndex as string)
	)
	
	-- 还原脸型到初始状态
	fn fnResetHeadFace =
	(
		if (queryBox "确定要还原头部表情到初始状态吗？" title:"还原表情确认") then
		(
			currentFaceIndex = 1
			uiHead.text = headFaces[1]
			fnSaveHeadFace()
			messageBox "头部表情已还原到初始状态！" title:"BsBipedTools"
		)
	)

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
	local mcLeftFinger   = fnChangeThemeColor (color 163 61 180)
	local mcRightFinger  = fnChangeThemeColor (color 176 191 46)
	local mcLeftThumb    = fnChangeThemeColor (color 191 46 46)
	local mcRightThumb   = fnChangeThemeColor (color 241 228 157)

	label lblVersion verBsBipedTools height:15 width:30 align:#left pos:[3,0]
	button btnResetFace "◕" offset:[25, -5] height:15 width:15 border:false align:#right pos:[100,0] tooltip:"还原头部表情到初始状态"
	button btnMini "☐" offset:[45, -5] height:15 width:20 border:false align:#right pos:[120,0]
	button uiAbout "?" offset:[-15, -5] height:15 width:20 border:false align:#left pos:[140,0]
	button btnClose "X" offset:[15, -5] height:15 width:20 border:false align:#right pos:[160,0]
	
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
	
	checkButton uiHead "" width: 50 height:33 checked:true highlightColor:mcHead pos:[65, 50]  --表情从Sox工具得到灵感~~
	checkButton uiNecks "Necks" width: 40 height:23 checked:true highlightColor:mc_spineColor align:#center pos:[70, 85]
	
	checkButton uiRArms "" checked:true highlightColor:mcRight width:25 align:#left pos:[15, 85] across:2
	checkButton uiLArms "" checked:true highlightColor:mcLeft width:25 align:#right pos:[140, 85]
	
	checkButton uiRClavicle "Clavicle" width:55 height:18 checked:true highlightColor:mcRight across:2 pos:[25, 110]
	checkButton uiLClavicle "Clavicle" width:55 height:18 checked:true highlightColor:mcLeft pos:[100, 110]
	
	checkButton uiAllSpine height:64 width:26 checked:true highlightColor:mc_spineColor pos:[60, 130] align:#center
	checkButton uiSpine3 "3" width:30 height:16 checked:true highlightColor:mc_spineColor align:#center pos:[90, 130]
	checkButton uiSpine2 "2" width:30 height:16 checked:true highlightColor:mc_spineColor align:#center pos:[90, 146]
	checkButton uiSpine1 "1" width:30 height:16 checked:true highlightColor:mc_spineColor align:#center pos:[90, 162]
	checkButton uiSpine0 "0" width:30 height:16 checked:true highlightColor:mc_spineColor align:#center pos:[90, 178]
	
	checkButton uiCOM "COM" checked:true width:50 height:30 highlightColor:mcHead pos:[65, 195]
	checkButton uiPelvis "Pelvis" checked:true highlightColor:mcPevils width:60 height:18 pos:[60, 225]
	
	checkButton uiRUpArm "R" width:25  height:30 pos:[20, 131] checked:true highlightColor:mcRight across:2
	checkButton uiLUpArm "L" width:25  height:30 pos:[135, 131] checked:true highlightColor:mcLeft
	checkButton uiRForArm "R" width:25  height:30 pos:[20, 161] checked:true highlightColor:mcRight across:2
	checkButton uiLForArm "L" width:25  height:30 pos:[135, 161] checked:true highlightColor:mcLeft
	checkButton uiRHand "Hand" pos:[10, 191] height:25 checked:true highlightColor:mcRight across:2
	checkButton uiLHand "Hand" pos:[130, 191] height:25 checked:true highlightColor:mcLeft
	
	checkButton uiPropR "Prop" width:35 height:18 checked:true highlightColor:mcSelTools pos:[13, 223]
	checkButton uiPropL "Prop" width:35 height:18 checked:true highlightColor:mcSelTools pos:[133, 223]

	checkButton uiRThigh "R" width:30  height:30 align:#right checked:true highlightColor:mcRight pos:[58, 245] across:2
	checkButton uiLThigh "L" width:30 height:30 align:#left checked:true highlightColor:mcLeft pos:[93, 245]
	checkButton uiRCalf "R" width:30  height:30 checked:true highlightColor:mcRight align:#right  pos:[58, 275] across:2
	checkButton uiLCalf "L" width:30  height:30 checked:true highlightColor:mcLeft align:#left pos:[93, 275]
	checkButton uiRFoot "R Foot" checked:true highlightColor:mcRight align:#right pos:[45, 305] width:40 height:25 across:2
	checkButton uiLFoot "L Foot" checked:true highlightColor:mcLeft align:#left pos:[95, 305] width:40 height:25
	
	checkButton uiRLegs "" checked:true highlightColor:mcRight width:25 align:#left pos:[23, 265] across:2
	checkButton uiLLegs "" checked:true highlightColor:mcLeft width:25 align:#right pos:[132, 265]
	
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
	checkbutton uiCbtSelPostureObjs "" pos:[140,465] width:35 height:25 visible:false checked:true highlightColor:mcFK tooltip:"选择复制pose的Biped骨骼"
	checkbutton uiCbtMirrorRArm "右→左臂" pos:[50,495] width:60 height:25 visible:false checked:true highlightColor:mcRight
	checkbutton uiCbtMirrorLArm "左→右臂" pos:[115,495] width:60 height:25 visible:false checked:true highlightColor:mcLeft
	checkbutton uiCbtMirrorRLeg "右→左腿" pos:[50,523] width:60 height:25 visible:false checked:true highlightColor:mcRight
	checkbutton uiCbtMirrorLLeg "左→右腿" pos:[115,523] width:60 height:25 visible:false checked:true highlightColor:mcLeft
	checkbutton uiCbtGrabPose "速存Pose" pos:[50,550] width:60 height:25 visible:false checked:true highlightColor:mcFK
	checkbutton uiCbtLoadPose "加载Pose" pos:[115,550] width:60 height:25 visible:false checked:true highlightColor:mcFK

	--layers tools
	button uiCbtDown "" pos:[50,465] width:20 height:20 visible:false border:false
	button uiCbtUp "" pos:[70,465] width:20 height:20 visible:false border:false
	label uiLblLayerID "0" pos:[95,469] width:20 height:16 visible:false style_sunkenedge:true readonly:true
	label uiLblActive "活动" pos:[130,470] width:25 height:25 visible:false
	checkbox uiChkActive "" pos:[160,465] width:60 height:25 visible:false checked:true
	dropDownList ddlLayers "" pos:[50,489] width:110 visible:false
	checkbutton uiCbtRefreshLayer "R" pos:[160,490] width:15 height:20 visible:false checked:true highlightColor:mcScanBiped tooltip:"刷新"
	button uiCbtAddLayer "" pos:[52,514] width:30 height:20 visible:false border:false
	button uiCbtDelLayer "" pos:[82,514] width:30 height:20 visible:false border:false
	button uiCbtDownLayer "" pos:[112,514] width:30 height:20 visible:false border:false
	button uiCbtSnapKeys "" pos:[142,514] width:30 height:20 visible:false border:false tooltip:"左键吸附当前帧，右键吸附帧栏所有帧"
	checkbutton uiCbtLeftArm "" pos:[52,537] width:30 height:20 visible:false checked:false highlightColor:mcHead border:false
	checkbutton uiCbtRightArm "" pos:[82,537] width:30 height:20 visible:false checked:false highlightColor:mcHead border:false
	checkbutton uiCbtLeftLeg "" pos:[112,537] width:30 height:20 visible:false checked:false highlightColor:mcHead border:false
	checkbutton uiCbtRightLeg "" pos:[142,537] width:30 height:20 visible:false checked:false highlightColor:mcHead border:false
	button uiCbtUpdate "更新" pos:[50,560] width:65 height:20 visible:false --border:false
	checkbox uiChkIKonly "仅IK" pos:[130,560] width:100 height:20 visible:false checked:false highlightColor:mcHead tooltip:"没找到获取状态的api...只能update设置"

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

	-- groupbox grpKeyList "关键帧书签" pos:[50, 535] width:140 height:45
	button btnKey1 "Key" width:30 height:20 pos:[50, 540] border:true
	button btnKey2 "Key" width:30 height:20 pos:[82, 540] border:true
	button btnKey3 "Key" width:30 height:20 pos:[114, 540] border:true
	button btnKey4 "Key" width:30 height:20 pos:[146, 540] border:true
	button btnKey5 "Key" width:30 height:20 pos:[50, 560] border:true
	button btnKey6 "Key" width:30 height:20 pos:[82, 560] border:true
	button btnKey7 "Key" width:30 height:20 pos:[114, 560] border:true
	button btnKey8 "Key" width:30 height:20 pos:[146, 560] border:true


	--other tools
	checkButton uiBtn0 "0" pos:[50,465] width:30 height:25 tooltip:"曲柄打直 Continuity (TCB)\r\nCtrl/Shift 可批处理\r\nESC可中断" border:true visible:false checked:true highlightColor:mcInPlace
	checkButton uiBtn25 "25" pos:[82,465] width:30 height:25 tooltip:"曲柄默认 Continuity (TCB)\r\nCtrl/Shift 可批处理\r\nESC可中断" border:true visible:false checked:true highlightColor:mcInPlace
	checkButton uiBtnLoadBip "S" pos:[114, 465] width:30 height:25 tooltip:"" border:true visible:false checked:true highlightColor:mcInPlace
	checkButton uiBtnSaveBip "L" pos:[146, 465] width:30 height:25 tooltip:"" border:true visible:false checked:true highlightColor:mcInPlace

	-- label uiLblTitle "BsBipedTools_v1.0" height:16 width:rolBsBipedTools.width pos:[5, 585]
	timer clock "PlayClock" interval:1 active:false -- 가장 빠른 인터벌로
--/////////////////////////////////////////////////////////////////////////////////////////////////
    button btnAddScale "添加缩放" pos:[50,495] width:62
    button btnRemoveScale "移除缩放" pos:[114,495] width:62
	checkButton ckbBendLink "弯曲" pos:[50,520] width:30 highlightColor:mcInPlace
	checkButton ckbTwistLink "扭曲" pos:[82,520] width:30 highlightColor:mcInPlace
	checkButton ckbTwistIndiv "自身" pos:[114,520] width:30 highlightColor:mcInPlace
	checkButton ckbSmoothTwist "平滑" pos:[146,520] width:30 highlightColor:mcInPlace
	button btnZeroTwist "归零扭曲" pos:[50,540] width:62
	button btnZeroAllLink "归零所有" pos:[114,540] width:62
	
	local arrLoopTools = #("循环",#(uiBtnLoopGet,uiSpnLoopStart,uiSpnLoopEnd,uiCkbClearUserDef,uiBtnLoopSel,uiBtnGotoMirror,\
		btnKey1,btnKey2,btnKey3,btnKey4,btnKey5,btnKey6,btnKey7,btnKey8))
	local arrOtherTools = #("其他",#(uiBtn0,uiBtn25,uiBtnLoadBip,uiBtnSaveBip,btnAddScale,btnRemoveScale,ckbBendLink,ckbTwistLink,ckbTwistIndiv,\
		ckbSmoothTwist,btnZeroTwist,btnZeroAllLink)) 
	local arrLayerTools = #("层层",#(uiCbtRefreshLayer,uiCbtDown,uiCbtUp,uiLblLayerID,uiLblActive,uiChkActive,uiCbtAddLayer,\
		uiCbtDelLayer,uiCbtDownLayer,uiCbtSnapKeys,uiCbtLeftArm,uiCbtRightArm,uiCbtLeftLeg,uiCbtRightLeg,uiCbtUpdate,uiChkIKonly,ddlLayers))
	local arrCopyTools = #("复制",#(uiCbtCopy,uiCbtPaste,uiCbtPasteOpposite,uiCbtSelPostureObjs,uiCbtMirrorLArm,uiCbtMirrorRArm,\
		uiCbtMirrorLLeg,uiCbtMirrorRLeg,uiCbtGrabPose,uiCbtLoadPose))
	local arrAllToolsTab = #(arrCopyTools,arrLayerTools,arrLoopTools,arrOtherTools)

	local m_goto1; local m_goto2; local m_goto3; local m_goto4; local m_goto5; local m_goto6; local m_goto7; local m_goto8

	
	fn fnRefreshTwistState =
	(
		if selection.count == 1 and classOf selection[1] == Biped_Object then
        (
            bipRoot = selection[1].controller.rootNode
            try (
                local ctrl = bipRoot.controller
                ckbBendLink.state = ctrl.bendLinksMode
                ckbTwistLink.state = ctrl.twistLinksMode
                ckbTwistIndiv.state = ctrl.twistIndMode
                
                -- 检查SmoothTwist状态
                try (
                    ckbSmoothTwist.state = bipRoot.controller.SmoothTwistMode
                ) catch (
                    ckbSmoothTwist.state = false
                )
            )
            catch ()
        )
        else
        (
            ckbBendLink.state = false
            ckbTwistLink.state = false
            ckbTwistIndiv.state = false
            ckbSmoothTwist.state = false
        )
	)

	fn fnSetTwistLink ctrl index =
	(
		case index of
		(
			(1):(ctrl.bendLinksMode = true;ctrl.twistLinksMode = ctrl.twistIndMode = ctrl.SmoothTwistMode = false)
			(2):(ctrl.twistLinksMode = true;ctrl.bendLinksMode = ctrl.twistIndMode = ctrl.SmoothTwistMode = false)
			(3):(ctrl.twistIndMode = true;ctrl.twistLinksMode = ctrl.bendLinksMode = ctrl.SmoothTwistMode = false)
			(4):(ctrl.SmoothTwistMode = true;ctrl.twistLinksMode = ctrl.twistIndMode = ctrl.bendLinksMode = false)
		)
		fnRefreshTwistState()
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
		uiCbtSelPostureObjs.images = #("bip_mflshare_i.bmp","bip_mflshare_i.bmp",2,2,2,2,2,true,true)
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

	function LoadGoto = (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do return ()
		try (
			m_goto1 = getUserProp m_workingBipRoot "BsBT_Goto1"
			if (m_goto1 == "undefined") do (m_goto1 = undefined)
			m_goto2 = getUserProp m_workingBipRoot "BsBT_Goto2"
			if (m_goto2 == "undefined") do (m_goto2 = undefined)
			m_goto3 = getUserProp m_workingBipRoot "BsBT_Goto3"
			if (m_goto3 == "undefined") do (m_goto3 = undefined)
			m_goto4 = getUserProp m_workingBipRoot "BsBT_Goto4"
			if (m_goto4 == "undefined") do (m_goto4 = undefined)
			m_goto5 = getUserProp m_workingBipRoot "BsBT_Goto5"
			if (m_goto5 == "undefined") do (m_goto5 = undefined)
			m_goto6 = getUserProp m_workingBipRoot "BsBT_Goto6"
			if (m_goto6 == "undefined") do (m_goto6 = undefined)
			m_goto7 = getUserProp m_workingBipRoot "BsBT_Goto7"
			if (m_goto7 == "undefined") do (m_goto7 = undefined)
			m_goto8 = getUserProp m_workingBipRoot "BsBT_Goto8"
			if (m_goto8 == "undefined") do (m_goto8 = undefined)
		) catch ()
	)

    function SaveGoto ui val index = (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do return ()
		local pString = "BsBT_Goto" + (index as string)
		try (
			setUserProp m_workingBipRoot pString val
		) catch ()
	)

	function SetGotoBtnTextSub ui val = (
		local tString
		if (val == undefined) then (tString = "Key") else (tString = (val as string))
		ui.text = tString
		ui.tooltip = tString
	)

	function SetGotoBtnText = (
		SetGotoBtnTextSub btnKey1 m_goto1
		SetGotoBtnTextSub btnKey2 m_goto2
		SetGotoBtnTextSub btnKey3 m_goto3
		SetGotoBtnTextSub btnKey4 m_goto4
		SetGotoBtnTextSub btnKey5 m_goto5
		SetGotoBtnTextSub btnKey6 m_goto6
		SetGotoBtnTextSub btnKey7 m_goto7
		SetGotoBtnTextSub btnKey8 m_goto8
	)

	-- m_goto1 등의 변수를 참조 형식으로 &val 매개변수에 전달
	function GotoFrame ui &val index setKey:false = (
		if (setKey) then (
			if (ui.text == "Key") then 
			(
				val = int sliderTime
				SetGotoBtnText()
				SaveGoto ui val index
			)
			else
			(
				if (queryBox "当前已设定跳转帧,是否清除？                   " beep:false) then
				(
					val = undefined
					SetGotoBtnText()
					SaveGoto ui val index
				)
			)
			return ()
		)
		else 
		(
			if (ui.text == "Key") then 
			(
				val = int sliderTime
				SetGotoBtnText()
				SaveGoto ui val index
			)
			else
			(
				if (val != undefined) do (
					try (
						sliderTime = val
					) catch ()
				)
			)
		)
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
			for o in obj.children where not isDeleted o and (classof o.baseobject == Biped_Object or (classof o.controller == Vertical_Horizontal_Turn)) do (
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
		uiSpine3.state = state
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
		m_Spine3 = GetSpine 3
		if (m_Spine3.count == 0) then (uiSpine3.enabled = false; uiSpine3.state = false) else (uiSpine3.enabled = true; uiSpine3.state = true)
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
		LoadGoto()
		SetGotoBtnText()

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
		fnRefreshTwistState()
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
			try
			(
				local bRootCtrl = m_workingBipRoot.controller
				biped.createCopyCollection bRootCtrl "MirrorTemp"
				local colIndex = biped.numCopyCollections bRootCtrl
				local copyCol = biped.getCopyCollection bRootCtrl colIndex
				biped.copyBipPosture bRootCtrl copyCol a_bipObjs #snapAuto
				local mirroreBH_pose = getCopy copyCol #posture 1
				with Animate on
				(
					undo "MirrorPosture" on
					(
						biped.pasteBipPosture bRootCtrl mirroreBH_pose true #pstdefault true true true false
					)
				)
				biped.deleteCopyCollection bRootCtrl colIndex
			)
			catch(messageBox "错误：镜像失败，请重新尝试。                       " title:"BsBipedTools")
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
		try
		(
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
						biped.saveCopyPasteFile bRootCtrl (getDir #plugcfg + "\BsBipedTools_PoseGrabbed.cpy")
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
		catch(messageBox "错误：请重新尝试复制粘贴Pose。                       " title:"BsBipedTools")
	)
	
	on uiCbtPaste changed state do
	(
		uiCbtPaste.state = true
		try
		(
			local postureFile = getDir #plugcfg + "\BsBipedTools_PoseGrabbed.cpy"
			if doesFileExist postureFile then
			(
				if isValidNode m_workingBipRoot AND NOT isDeleted m_workingBipRoot then
				(
					local bRootCtrl = m_workingBipRoot.controller
					biped.loadCopyPasteFile bRootCtrl postureFile
					local colIndex = biped.numCopyCollections bRootCtrl
					local copyCol = biped.getCopyCollection bRootCtrl colIndex
					local copyBH_posture = getCopy copyCol #posture 1
					if copyBH_posture != false then
					(
						with Animate on
						(
							undo "PastePosture" on
							(
								biped.pasteBipPosture bRootCtrl copyBH_posture false #pstdefault true true true false
							)
						)
					)
					else
					(
						messagebox "错误：确保 Copy/Paste Posture 不包含名为"CopyPosture"的集合。                            " title:"BsBipedTools"
					)
					local colIndex = biped.numCopyCollections bRootCtrl
					biped.deleteCopyCollection bRootCtrl colIndex
				)
			)
			else
			(
				messageBox "错误：请先复制一个 Pose。                          " title:"BsBipedTools"
			)
		)
		catch (messageBox "错误：请重新尝试复制粘贴Pose。                       " title:"BsBipedTools")
	)

	on uiCbtPasteOpposite changed state do
	(
		uiCbtPasteOpposite.state = true
		try
		(
			local postureFile = getDir #plugcfg + "\BsBipedTools_PoseGrabbed.cpy"
			if doesFileExist postureFile then
			(
				if isValidNode m_workingBipRoot AND NOT isDeleted m_workingBipRoot then
				(
					local bRootCtrl = m_workingBipRoot.controller
					biped.loadCopyPasteFile bRootCtrl postureFile
					local colIndex = biped.numCopyCollections bRootCtrl
					local copyCol = biped.getCopyCollection bRootCtrl colIndex
					local copyBH_posture = getCopy copyCol #posture 1
					if copyBH_posture != false then
					(
						with Animate on
						(
							undo "PastePosture" on
							(
								biped.pasteBipPosture bRootCtrl copyBH_posture true #pstdefault true true true false
							)
						)
					)
					else
					(
						messagebox "错误：确保 Copy/Paste Posture 不包含名为"CopyPosture"的集合。                            " title:"BsBipedTools"
					)
					local colIndex = biped.numCopyCollections bRootCtrl
					biped.deleteCopyCollection bRootCtrl colIndex
				)
			)
			else
			(
				messageBox "错误：请先复制一个 Pose。                          " title:"BsBipedTools"
			)
		)
		catch (messageBox "错误：请重新尝试复制粘贴Pose。                       " title:"BsBipedTools")
	)
	
	on uiCbtSelPostureObjs changed state do
	(
		uiCbtSelPostureObjs.state = true
		try
			(
				local a_objs = fnRetrievePostureObjs()
				if a_objs != undefined then
				(
					try
					(
						select a_objs
					)catch(messageBox "错误: 无法选择用于复制姿势的Biped骨骼。                                " title:"BsBipedTools")
				)
			)catch()
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
		InitLocalVars() -- 工作用 双足人形 根节点等，选择用数组变量等预设
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

		-- 预存数组有问题则重新初始化数组
		if (IfExistBips m_AllBip) == false do (
			m_AllBip = GetAllBip()
		)
		if (IfExistBips m_AllBip) == false do return () -- 还是有问题则直接返回
		
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
					try ( biped.addNewKey o.controller slidertime ) catch ()		-- Footstep 对象导致 try 处理
				)
			) -- for end
		) -- undo end	
		clearSelection()
		select selBackup
	)

	on uiBtnLimbPK changed state do (
		uiBtnLimbPK.state = on -- 任何状态下按钮状态都保持按下
		if ((rolBsBipedTools.m_workingBipRoot != undefined) and (not (isDeleted rolBsBipedTools.m_workingBipRoot))) then
		(
			layerIndex = biped.getCurrentLayer rolBsBipedTools.m_workingBipRoot.controller
			if layerIndex == 0 then 
			(
				local tempPanel = getCommandPanelTaskMode()
				setCommandPanelTaskMode mode:#motion -- biped.setSlidingKey 等功能只在 Motion 面板正常工作，其他地方会导致错误姿势覆盖
				local timeBefore = sliderTime
				-- disableSceneRedraw()
				undo on (
					for obj in selection do (
						if (IfLimb obj) do (
							if (keyboard.shiftPressed OR keyboard.controlPressed) then (
								local keys = obj.controller.keys
								local animRangeBackup = animationRange -- 暂时可以修改外部的关键帧，记录当前的动画区间
								animationRange = Interval keys[1].time keys[keys.count].time
								for i = 1 to keys.count do (
									if keyboard.shiftPressed do (
										-- Shift 按下则不考虑关键帧选择，全部修改
										sliderTime = keys[i].time -- 使用 at time 方式会导致 sliderTime 的姿势生成关键帧，所以直接改变 sliderTime 进行
										biped.SetPlantedKey obj
									)
									if keyboard.controlPressed do (
										-- Ctrl 按下则只修改选中的关键帧
										if keys[i].selected == true do (
											sliderTime = keys[i].time -- 使用 at time 方式会导致 sliderTime 的姿势生成关键帧，所以直接改变 sliderTime 进行
											biped.SetPlantedKey obj
										)
									)
								)
								animationRange = animRangeBackup -- 恢复原来的动画区间
							)
							else (
								biped.SetPlantedKey obj
							)
						)
					) -- for
				) -- Undo
				if tempPanel != #motion do setCommandPanelTaskMode mode:tempPanel
				-- enableSceneRedraw()
				sliderTime = timeBefore
			)
			else (messagebox "bip 层内无法使用此功能!                                     " beep:false title:"BsBipedTools")
		)
	)

	on uiBtnLimbIK changed state do (
		uiBtnLimbIK.state = on -- 任何状态下按钮状态都保持按下
		if ((rolBsBipedTools.m_workingBipRoot != undefined) and (not (isDeleted rolBsBipedTools.m_workingBipRoot))) then
		(
			layerIndex = biped.getCurrentLayer rolBsBipedTools.m_workingBipRoot.controller
			if layerIndex == 0 then 
			(
				local tempPanel = getCommandPanelTaskMode()
				setCommandPanelTaskMode mode:#motion -- biped.setSlidingKey 等功能只在 Motion 面板正常工作，其他地方会导致错误姿势覆盖
				local timeBefore = sliderTime
				-- disableSceneRedraw()
				undo on (
					for obj in selection do (
						if (IfLimb obj) do (
							if (keyboard.shiftPressed OR keyboard.controlPressed) then (
								local keys = obj.controller.keys
								local animRangeBackup = animationRange -- 暂时可以修改外部的关键帧，记录当前的动画区间
								animationRange = Interval keys[1].time keys[keys.count].time
								for i = 1 to keys.count do (
									if keyboard.shiftPressed do (
										-- Shift 按下则不考虑关键帧选择，全部修改
										sliderTime = keys[i].time -- 使用 at time 方式会导致 sliderTime 的姿势生成关键帧，所以直接改变 sliderTime 进行
										biped.setSlidingKey obj
									)
									if keyboard.controlPressed do (
										-- Ctrl 按下则只修改选中的关键帧
										if keys[i].selected == true do (
											sliderTime = keys[i].time -- 使用 at time 方式会导致 sliderTime 的姿势生成关键帧，所以直接改变 sliderTime 进行
											biped.setSlidingKey obj
										)
									)
								)
								animationRange = animRangeBackup -- 恢复原来的动画区间
							)
							else (
								biped.setSlidingKey obj
							)
						)
					) -- for
				) -- Undo
				if tempPanel != #motion do setCommandPanelTaskMode mode:tempPanel
				-- enableSceneRedraw()
				sliderTime = timeBefore
			)
			else (messagebox "bip 层内无法使用此功能!                                     " beep:false title:"BsBipedTools")
		)
	)

	on uiBtnLimbFK changed state do (
		uiBtnLimbFK.state = on -- 任何状态下按钮状态都保持按下
		if ((rolBsBipedTools.m_workingBipRoot != undefined) and (not (isDeleted rolBsBipedTools.m_workingBipRoot))) then
		(
			layerIndex = biped.getCurrentLayer rolBsBipedTools.m_workingBipRoot.controller
			if layerIndex == 0 then 
			(
				local tempPanel = getCommandPanelTaskMode()
				setCommandPanelTaskMode mode:#motion -- biped.setSlidingKey 等功能只在 Motion 面板正常工作，其他地方会导致错误姿势覆盖
				local timeBefore = sliderTime
				-- disableSceneRedraw()
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
				if tempPanel != #motion do setCommandPanelTaskMode mode:tempPanel
				-- enableSceneRedraw()
				sliderTime = timeBefore
			)
			else (messagebox "bip 层内无法使用此功能!                                     " beep:false title:"BsBipedTools")
		)
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

	on uiHead rightclick do 
	(
		-- 切换颜文字脸
		currentFaceIndex += 1
		if currentFaceIndex > headFaces.count then currentFaceIndex = 1
		uiHead.caption = headFaces[currentFaceIndex]
		uiHead.state = on
		-- 保存到配置文件
		SetINISetting iniBsBipedTools "BsBipedTools" "HeadFaceIndex" (currentFaceIndex as string)
	)

	on btnResetFace pressed do 
	(
		-- 还原脸型到初始状态
		if (queryBox "确定要还原头部表情到初始状态吗？" title:"还原表情确认") then
		(
			currentFaceIndex = 1
			uiHead.caption = headFaces[currentFaceIndex]
			uiHead.state = on
			SetINISetting iniBsBipedTools "BsBipedTools" "HeadFaceIndex" (currentFaceIndex as string)
			messageBox "头部表情已还原到初始状态！" title:"BsBipedTools"
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

	on uiSpine3 changed state do (
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ( SetButtonState false; return ())
		uiSpine3.state = on -- 어떤 상태에서도 버튼 스테이트는 눌려있도록
		
		if keyboard.controlPressed and keyboard.altpressed do (
			-- Shift 를 누르면 똑바로 펴는 기능
			Straighten m_Spine3 ((eulerangles 0 0 0) as quat)
			return ()
		)
		
		selBackup = selection as array

		-- 기존 selection 백업과 이번에 선택할 selArr 을 입력받아 키보드 조합으로 적절하게 선택한다. 부수적으로 모션패널로의 변경도 같이 수행
		try(CompSelect selBackup m_Spine3) catch (
			m_Spine3 = GetSpine 3
			select m_Spine3
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
		try(destroyDialog rolBsBipToolsHelp)catch()
		Createdialog rolBsBipToolsHelp style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)
	)
	
	on rolBsBipedTools open do (
		
		if NOT (doesFileExist postureObjsFile) do
		(
			local txtFile = openFile postureObjsFile mode:"w"
			close txtFile
		)

		fnLoadBsBTConfig()
		-- 加载保存的脸型
		local savedIndex = (GetINISetting iniBsBipedTools "BsBipedTools" "HeadFaceIndex") as integer
		if savedIndex != undefined and savedIndex > 0 and savedIndex <= headFaces.count then
		(
			currentFaceIndex = savedIndex
		)
		else
		(
			currentFaceIndex = 1
		)
		-- 设置表情（在UI创建后）
		uiHead.caption = headFaces[currentFaceIndex]
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
		callbacks.addScript #sceneUndo "rolBsBipedTools.InitLocalVars()" id:#BsBTUpdateLayers
		
		fnSetBsBTConfig()

	)
	
	on rolBsBipedTools close do (
        callbacks.removeScripts id:#BsBTCallbackOpen
		callbacks.removeScripts id:#BsBTCallbackNew
		callbacks.removeScripts id:#BsBTCallbackReset
		callbacks.removeScripts id:#BsBTSelChange
		callbacks.removeScripts id:#BsBTUpdateLayers
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
		undo on (	
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
					fnDeleteUserProp i "BsBT_Goto1"
					fnDeleteUserProp i "BsBT_Goto2"
					fnDeleteUserProp i "BsBT_Goto3"
					fnDeleteUserProp i "BsBT_Goto4"
					fnDeleteUserProp i "BsBT_Goto5"
					fnDeleteUserProp i "BsBT_Goto6"
					fnDeleteUserProp i "BsBT_Goto7"
					fnDeleteUserProp i "BsBT_Goto8"
					btnKey1.text = btnKey2.text = btnKey3.text = btnKey4.text = btnKey5.text = btnKey6.text = btnKey7.text = btnKey8.text = "Key"
					m_goto1 = m_goto2 = m_goto3 = m_goto4 = m_goto5 = m_goto6 = m_goto7 = m_goto8 = undefined
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
			if m_LHand[1] != undefined then (with undo on (biped.setLimbRetargetState m_LHand[1] state))
		)
	)
	
	on uiCbtRightArm changed state do
	(
		if fnIsValidBiped() then 
		(
			if m_RHand[1] != undefined then (with undo on (biped.setLimbRetargetState m_RHand[1] state))
		)
	)
	
	on uiCbtLeftLeg changed state do
	(
		if fnIsValidBiped() then 
		(
			if m_LFoot[1] != undefined then (with undo on (biped.setLimbRetargetState m_LFoot[1] state))
		)
	)
	
	on uiCbtRightLeg changed state do
	(
		if fnIsValidBiped() then 
		(
			if m_RFoot[1] != undefined then (with undo on (biped.setLimbRetargetState m_RFoot[1] state))
		)
	)
		
	on uiCbtUpdate pressed do
	(
		if fnIsValidBiped() then
		(
			with undo on (biped.retargetToBaseLayer ctrl uiChkIKonly.state)
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

		Createdialog rolBSFingers pos:(mouse.screenPos - [310,100]) parent:rolBsBipedTools.hwnd style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)
	)

	on uiBtnLoadBip changed state do
	(
		uiBtnLoadBip.state = true
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ((messageBox "请先确认存在Biped骨骼!                            " title:"BsBipedTools");return ())
		biped.loadBipFileDlg m_workingBipRoot.controller
	)

	on uiBtnSaveBip changed state do
	(
		uiBtnSaveBip.state = true
		if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do ((messageBox "请先确认存在Biped骨骼!                            " title:"BsBipedTools");return ())
		biped.saveBipFileDlg m_workingBipRoot.controller
	)

	on uiCbtAddLayer pressed do
	(
		with undo on
		(
			if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do (return ())
			fnBSUpdateLayers()
			ctrlCom = m_workingBipRoot.controller
			numCurLayer = biped.getCurrentLayer ctrlCom
			countAllLayers = biped.numLayers ctrlCom
			numNewLayerIndex = numCurLayer + 1
			numNewLayerName = (countAllLayers + 1) as string
			biped.createLayer ctrlCom numNewLayerIndex ("Layer " + numNewLayerName )
		)
		fnBSUpdateLayers()
	)

	on uiCbtDelLayer pressed do
	(
		with undo on
		(
			if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do (return ())
			fnBSUpdateLayers()
			ctrlCom = m_workingBipRoot.controller
			numCurLayer = biped.getCurrentLayer ctrlCom
			biped.deleteLayer ctrlCom numCurLayer
		)
		fnBSUpdateLayers()
	)

	on uiCbtDownLayer pressed do
	(
		with undo on
		(
			if (m_workingBipRoot == undefined or (isDeleted m_workingBipRoot)) do (return ())
			fnBSUpdateLayers()
			ctrlCom = m_workingBipRoot.controller
			numCurLayer = biped.getCurrentLayer ctrlCom
			biped.collapseAtLayer ctrlCom (numCurLayer - 1)
		)
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

	on btnKey1 pressed do (GotoFrame btnKey1 &m_goto1 1)
	on btnKey2 pressed do (GotoFrame btnKey2 &m_goto2 2)
	on btnKey3 pressed do (GotoFrame btnKey3 &m_goto3 3)
	on btnKey4 pressed do (GotoFrame btnKey4 &m_goto4 4)
	on btnKey5 pressed do (GotoFrame btnKey5 &m_goto5 5)
	on btnKey6 pressed do (GotoFrame btnKey6 &m_goto6 6)
	on btnKey7 pressed do (GotoFrame btnKey7 &m_goto7 7)
	on btnKey8 pressed do (GotoFrame btnKey8 &m_goto8 8)

	on btnKey1 rightclick do (GotoFrame btnKey1 &m_goto1 1 setKey:true)
	on btnKey2 rightclick do (GotoFrame btnKey2 &m_goto2 2 setKey:true)
	on btnKey3 rightclick do (GotoFrame btnKey3 &m_goto3 3 setKey:true)
	on btnKey4 rightclick do (GotoFrame btnKey4 &m_goto4 4 setKey:true)
	on btnKey5 rightclick do (GotoFrame btnKey5 &m_goto5 5 setKey:true)
	on btnKey6 rightclick do (GotoFrame btnKey6 &m_goto6 6 setKey:true)
	on btnKey7 rightclick do (GotoFrame btnKey7 &m_goto7 7 setKey:true)
	on btnKey8 rightclick do (GotoFrame btnKey8 &m_goto8 8 setKey:true)
	
--///////////////////////////////////////////////////////////	
on btnAddScale pressed do
    (
        if (selection.count != 0) then
        (
            --.transform.controller.Biped_SubAnim.controller.BipScaleList.controller.Available.controller = ScaleXYZ ()
            for i in selection do
            (
                if (classOf i ==Biped_Object) and (i.transform.controller[1].name != "Vertical") do --质心不作缩放
                (
                    undo "bipedscale" on
                    (try
                        (
                        bip_ed = i.transform.controller.rootnode
                        bip_ed.transform.controller.enableSubAnims = true
                        i.transform.controller[1][1][1].controller = ScaleXYZ ()
                        )catch()
                    )
                )
            )
        )
        else
        (
            messagebox "请选择一根或多根 Biped 骨骼!\n\r" beep:true title:"选择有误！"
        )
    )

    on btnRemoveScale pressed do
    (
        if (selection.count != 0) then
        (
            for i in selection do
            (
                if (classOf i ==Biped_Object) and (i.transform.controller[1].name != "Vertical") do --质心不作缩放
                (
                    undo "bipedscale_key" on --删除缩放帧 ，
                    (
                        --deletekeys i.transform.controller[1][1][1].controller.keys #allKeys
                        lstctr = i.transform.controller[1][1]
                        try (lstctr.delete 1)catch()
                    )
                )
            )
        )
        else
        (
            messagebox "请选择一根或多根 Biped 骨骼!\n\r" beep:true title:"选择有误！"
        )
    )

	on ckbBendLink changed state do
	(
		local ctrl = m_workingBipRoot.controller
		if state then 
		(
			fnSetTwistLink ctrl 1
		)
		else ctrl.bendLinksMode = false
	)

	on ckbTwistLink changed state do
	(
		local ctrl = m_workingBipRoot.controller
		if state then 
		(
			fnSetTwistLink ctrl 2
		)
		else ctrl.twistLinksMode = false
	)

	on ckbTwistIndiv changed state do
	(
		local ctrl = m_workingBipRoot.controller
		if state then 
		(
			fnSetTwistLink ctrl 3
		)
		else ctrl.twistIndMode = false
	)

	on ckbSmoothTwist changed state do
	(
		local ctrl = m_workingBipRoot.controller
		if state then 
		(
			fnSetTwistLink ctrl 4
		)
		else ctrl.SmoothTwistMode = false
	)

	on btnZeroTwist pressed do
	(
		if selection.count == 1 and classOf selection[1] == Biped_Object then (with undo on (biped.zeroTwist selection[1]))
		fnRefreshTwistState()
	)
	
	on btnZeroAllLink pressed do
	(
		if selection.count == 1 and classOf selection[1] == Biped_Object then (with undo on (biped.zeroAll selection[1]))
		fnRefreshTwistState()
	)
	
--////////////////////////////////////////////////////////		
	
	
)
if (iniBsBTPos != 0) then 
(Createdialog rolBsBipedTools pos:iniBsBTPos style:#() fgcolor:(if fnGetThemeColor() == "Light" then (color 28 89 177) else (color 165 222 228)))
else (Createdialog rolBsBipedTools style:#() fgcolor:(if fnGetThemeColor() == "Light" then (color 28 89 177) else (color 165 222 228)))
clearListener()