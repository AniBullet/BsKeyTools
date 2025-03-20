/*
 * @Description: 
 * @Author: Bullet.S
 * @Date: 2022-11-17 13:05:32
 * @LastEditors: Bullet.S
 * @LastEditTime: 2025-03-20 16:43:07
 * @Email: animator.bullet@foxmail.com
 */
-- BipedRigCreator_v3.3.2_Enhanced
-- by: Bullet.S
-- 2022.05

try (destroyDialog rolBsRetarget) catch()
try (destroyDialog choose_item_rollout) catch()

global rolBsRetarget

global boneNames = #(
	
	"Bip001", 				--1
	"Pelvis", 				--2
	"Spine", 				--3
	"Spine1",			--4
	"[可选]Spine2",			--5
	"Neck",				--6
	"[可选]Neck1",	--7 (NO LONGER USING)
	"Head",				--8
	"HeadNub",			--9
	
	"L Thigh",			--10
	"L Calf",				--11
	"L Foot",				--12
	"L Toe0",			--13
	"L Toe0Nub",		--14
	
	"R Thigh",			--15
	"R Calf",				--16
	"R Foot",			--17
	"R Toe0",			--18
	"R Toe0Nub",		--19
	
	"L Clavicle", 		--20
	"L UpperArm",		--21
	"L Forearm",		--22
	"L Hand",			--23
	"L Finger0",			--24
	"L Finger01",		--25
	"L Finger02",		--26
	"L Finger0Nub",	--27
	"L Finger1",			--28
	"L Finger11",		--29
	"L Finger12",		--30
	"L Finger1Nub",	--31
	"L Finger2",			--32
	"L Finger21",		--33
	"L Finger22",		--34
	"L Finger2Nub",    --35
	
	"L Finger3",			--36
	"L Finger31",		--37
	"L Finger32",		--38
	"L Finger3Nub",	--39
	"L Finger4",			--40
	"L Finger41",		--41
	"L Finger42",		--42
	"L Finger4Nub",	--43
	
	"R Clavicle",		--44
	"R UpperArm",		--45
	"R Forearm",		--46
	"R Hand",			--47
	"R Finger0",		--48
	"R Finger01",		--49
	"R Finger02",		--50
	"R Finger0Nub",	--51
	"R Finger1",		--52
	"R Finger11",		--53
	"R Finger12",		--54
	"R Finger1Nub",	--55
	"R Finger2",		--56
	"R Finger21",		--57
	"R Finger22",		--58
	"R Finger2Nub",	--59
	"R Finger3",		--60
	"R Finger31",		--61
	"R Finger32",		--62
	"R Finger3Nub",	--63
	"R Finger4",		--64
	"R Finger41",		--65
	"R Finger42",		--66
	"R Finger4Nub"		--67	
)

global pattBipedNames = #(
	#("Bip00?","*Hip","*Hips"),				--1
	#("*Pelvis"),				--2
	#("*Spine","*Waist","*Spine*Lower"),				--3
	#("*Spine1","*Stomach","*Spine*Middle"),			--4
	#("*Spine2","*Chest","*Spine*Upper"),			--5
	#("*Neck","*Neck*Lower"),				--6
	#("*Neck1","*Neck?Middle"),			--7
	#("*Head","*Neck*Upper"),				--8
	#("*HeadNub","*Head?nub"),			--9
	
	#("*L?Thigh","*Thigh?L","*Left*Thigh"),			--10
	#("*L?Calf","*L?Shin","*Calf?L","*Left*Knee"),				--11
	#("*L?Foot","*Foot?L","*Left*Ankle"),				--12
	#("*L?Toe0","*L?Toe","*Toe?L","*Left*Toes"),			--13
	#("*L?Toe0Nub","*L?Toe?nub","*L?Toe0?Nub"),		--14
	
	#("*R?Thigh","*Thigh?R","*Right*Thigh"),			--15
	#("*R?Calf","*R?Shin","*Calf?R","*Right*Knee"),				--16
	#("*R?Foot","*Foot?R","*Right*Ankle"),			--17
	#("*R?Toe0","*R?Toe","*Toe?R","*Right*Toes"),			--18
	#("*R?Toe0Nub","*R?Toe?nub","*R?Toe0?Nub"),		--19
	
	#("*L?Clavicle","*L?Shoulder","*Clavicle?L","*Left*Shoulder 1"),		--20
	#("*L?UpperArm","*UpperArm?L","*Left*Shoulder 2"),		--21
	#("*L?Forearm","*Forearm?L","*Left*Elbow"),		--22
	#("*L?Hand","*Hand?L","*Left*Wrist"),			--23
	#("*L?Finger0","*L?Thumb1"),			--24
	#("*L?Finger01","*L?Thumb2"),		--25
	#("*L?Finger02","*L?Thumb3"),		--26
	#("*L?Finger0Nub","*L?Thumb3?nub","*L?Finger02?nub"),	--27
	#("*L?Finger1","*L?IndexF1"),			--28
	#("*L?Finger11","*L?IndexF2"),		--29
	#("*L?Finger12","*L?IndexF3"),		--30
	#("*L?Finger1Nub","*L?IndexF3?nub","*L?Finger12?nub","*L?IndexF3?ss"),	--31
	#("*L?Finger2","*L?MiddleF1"),			--32
	#("*L?Finger21","*L?MiddleF2"),		--33
	#("*L?Finger22","*L?MiddleF3"),		--34
	#("*L?Finger2Nub","*L?MiddleF3?nub","*L?Finger22?Nub","*L?MiddleF3?ss"),--35
	
	#("*L?Finger3","*L?RingF1"),			--36
	#("*L?Finger31","*L?RingF2"),		--37
	#("*L?Finger32","*L?RingF3"),		--38
	#("*L?Finger3Nub","*L?RingF3?nub","*L?Finger32?Nub","*L?RingF3?ss"),	--39
	#("*L?Finger4","*L?PinkyF1"),			--40
	#("*L?Finger41","*L?PinkyF2"),		--41
	#("*L?Finger42","*L?PinkyF3"),		--42
	#("*L?Finger4Nub","*L?PinkyF3?nub","*L?Finger42?Nub","*L?PinkyF3?ss"),	--43
	
	#("*R?Clavicle","*R?Shoulder","*Clavicle?R","*Right*Shoulder 1"),		--44
	#("*R?UpperArm","*UpperArm?R","*Right*Shoulder 2"),		--45
	#("*R?Forearm","*Forearm?R","*Right*Elbow"),		--46
	#("*R?Hand","*Hand?R","*Right*Wrist"),			--47
	#("*R?Finger0","*R?Thumb1"),		--48
	#("*R?Finger01","*R?Thumb2"),		--49
	#("*R?Finger02","*R?Thumb3"),		--50
	#("*R?Finger0Nub","*R?Thumb3?nub","*R?Finger02?Nub","*R?Thumb3?ss"),	--51
	#("*R?Finger1","*R?IndexF1"),		--52
	#("*R?Finger11","*R?IndexF2"),		--53
	#("*R?Finger12","*R?IndexF3"),		--54
	#("*R?Finger1Nub","*R?IndexF3?nub","*R?Finger12?Nub","*R?IndexF3?ss"),	--55
	#("*R?Finger2","*R?MiddleF1"),		--56
	#("*R?Finger21","*R?MiddleF2"),		--57
	#("*R?Finger22","*R?MiddleF3"),		--58
	#("*R?Finger2Nub","*R?MiddleF3?nub","*R?Finger22?Nub","*R?MiddleF3?ss"),	--59
	#("*R?Finger3","*R?RingF1"),		--60
	#("*R?Finger31","*R?RingF2"),		--61
	#("*R?Finger32","*R?RingF3"),		--62
	#("*R?Finger3Nub","*R?RingF3?nub","*R?Finger32?Nub","*R?RingF3?ss"),	--63
	#("*R?Finger4","*R?PinkyF1"),		--64
	#("*R?Finger41","*R?PinkyF2"),		--65
	#("*R?Finger42","*R?PinkyF3"),		--66
	#("*R?Finger4Nub","*R?PinkyF3?nub","*R?Finger42?Nub","*R?PinkyF3?ss")		--67	
)

global myFgColor
global myClickColor
global myCheckedColor
global dotColor = dotnetclass "System.Drawing.Color"

(
	local curColorThemeFile = colorMan.getFileName()
	local maxuiBgColor      = (colorman.getcolor #background) * 255
	
	if (curColorThemeFile != undefined) then
	(
		if (matchpattern curColorThemeFile pattern:"*light*") then
		(
			myFgColor    = (color 28 89 177)
			myClickColor = (color 0 139 139)
			myCheckedColor = (color 152 227 213)
		)
		else
		(
			case maxuiBgColor of 
			(
				([68,68,68]):
				(
					myFgColor    = (color 165 222 228)
					myClickColor = (color 0 92 175)
					myCheckedColor = (color 30 136 168)
				)
				([186,186,186]):
				(
					myFgColor    = (color 28 89 177)
					myClickColor = (color 0 139 139)
					myCheckedColor = (color 152 227 213)
				)
				default:
				(
					myFgColor    = (color 165 222 228)
					myClickColor = (color 0 92 175)
					myCheckedColor = (color 30 136 168)
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
				myFgColor    = (color 165 222 228)
				myClickColor = (color 0 92 175)
				myCheckedColor = (color 30 136 168)
			)
			([186,186,186]):
			(
				myFgColor    = (color 28 89 177)
				myClickColor = (color 0 139 139)
				myCheckedColor = (color 152 227 213)
			)
			default:
			(
				myFgColor    = (color 165 222 228)
				myClickColor = (color 0 92 175)
				myCheckedColor = (color 30 136 168)
			)
		)
	)
	----获取当前主题是深色还是浅色,来更改文字颜色 fnGetColorTheme.ms

	BsDotFont       = dotnetobject "System.Drawing.Font" "Roboto" 8
	BsDotBackColor  = dotColor.FromArgb maxuiBgColor[1] maxuiBgColor[2] maxuiBgColor[3]
	BsDotForeColor  = dotColor.FromArgb myFgColor.r myFgColor.g myFgColor.b
	BsDotCheckColor = dotColor.FromArgb myCheckedColor.r myCheckedColor.g myCheckedColor.b
)

global bipedRootName = "Bip001";

global okForceRedraw = true;

global mappingCheckState = false

global arrExportRetargetAnim = #()

global arrAllBipedNode = #()
global arrAllBipedName = #()

global hasExtraHips = false
global fixNierFramerate = false
-- global pickedRootMotion = undefined
global isScale100 = false

-- wizardIndex = 1
-- wizardArray = #()

-- creates all of the dummies
headNub = undefined;--point name:"_Helper_Head Nub" wirecolor:(color 0 255 0)
fingerNubs = #(#(undefined, undefined, undefined, undefined), #(undefined, undefined, undefined, undefined, undefined))

--fingerNubs[1][1] = point name: "_Helper_Finger L Thumb 1 Nub" boxsize:[1,1,1] wirecolor:(color 255 0 0)
--fingerNubs[1][2] = point name: "_Helper_Finger L Index 2 Nub" boxsize:[1,1,1] wirecolor:(color 255 64 0)
--fingerNubs[1][3] = point  name: "_Helper_Finger L Mid 3 Nub" boxsize:[1,1,1] wirecolor:(color 255 128 0)
--fingerNubs[1][4] = point  name: "_Helper_Finger L Ring 4 Nub" boxsize:[1,1,1] wirecolor:(color 255 192 0)
--fingerNubs[1][5] = point  name: "_Helper_Finger L Pinky 5 Nub" boxsize:[1,1,1] wirecolor:(color 255 255 0)
	
--fingerNubs[2][1] = point  name: "_Helper_Finger R Thumb 1 Nub" boxsize:[1,1,1] wirecolor:(color 0 0 255)
--fingerNubs[2][2] = point  name: "_Helper_Finger R Index 2 Nub" boxsize:[1,1,1] wirecolor:(color 0 64 255)
--fingerNubs[2][3] = point  name: "_Helper_Finger R Mid 3 Nub" boxsize:[1,1,1] wirecolor:(color 0 128 255)
--fingerNubs[2][4] = point  name: "_Helper_Finger R Ring 4 Nub" boxsize:[1,1,1] wirecolor:(color 0 192 255)
--fingerNubs[2][5] = point  name: "_Helper_Finger R Pinky 5 Nub" boxsize:[1,1,1] wirecolor:(color 0 255 255)
	
toeNubs = #(undefined, undefined);
--toeNubs[1] = point  name: "_Helper_Toe L Nub" boxsize:[1,1,1] wirecolor:(color 255 64 128)
--toeNubs[2] = point  name: "_Helper_Toe R Nub" boxsize:[1,1,1] wirecolor:(color 64 128 255)

footHelpers = #(undefined, undefined)	
--footHelpers[1] = point  name: "_Helper_Foot Helper L" boxsize:[2,4,2] wirecolor:(color 255 128 255)
--footHelpers[2] = point  name: "_Helper_Foot Helper R" boxsize:[2,4,2] wirecolor:(color 128 255 255)

global GetSkeletalNode
fn GetSkeletalNode index isFaux findCorrect:true = 
(
	if isFaux == false then
	(
		local result = undefined
		if (index < 35 or index == 35) then
		(
			result = getNodeByName rolBsRetarget.characterBones.items[index]
		)
		else
		(
			result = getNodeByName rolBsRetarget.characterBones_B.items[index-35]
		)
		
		if result == undefined and findCorrect == true then
		(
			case index of
			(
				-- head
				9:  
				(
					result = headNub
				)
				
				-- toe nubs
				14:
				(
					result = toeNubs[1]
				)
				19:
				(
					result = toeNubs[2]
				)
				
				-- Finger nubs
				27:
				(
					result = fingerNubs[1][1]
				)
				31:
				(
					result = fingerNubs[1][2]
				)
				35:
				(
					result = fingerNubs[1][3]
				)
				39:
				(
					result = fingerNubs[1][4]
				)
				43:
				(
					result = fingerNubs[1][5]
				)
				51:
				(
					result = fingerNubs[2][1]
				)
				55:
				(
					result = fingerNubs[2][2]
				)
				59:
				(
					result = fingerNubs[2][3]
				)
				63:
				(
					result = fingerNubs[2][4]
				)
				67:
				(
					result = fingerNubs[2][5]
				)
			)
		)
		
		return result;
	)
	else
	(
		if (index == 1) then
		(
			return getNodeByName ("RTHelper_" + bipedRootName)
		)
		else 
		(
			return getNodeByName ("RTHelper_" + bipedRootName + (substituteString boneNames[index] "[可选]" ""))
		)
	)
)	

rcmenu menuQuickCreateNode
(
	menuItem quickMakeParent "快速创建父级骨骼"
    menuItem quickDuplicate "快速创建子级骨骼"
	menuItem quickDuplicateFingers "快速创建 Hand Nub"
    menuItem quickDuplicateFoot "快速创建 Foot Nub"
	menuItem quickDuplicateHead "快速创建 Head Nub"
    menuItem quickCenterRoot "快速创建新的 Hips"
	menuItem tips "根据 Bone 骨骼大腿的位置，" enabled:false
    menuItem tips2 "创建符合 Biped 骨骼位置的质心。" enabled:false

	fn fnDuplicateNub arrID isFoot:false isHead:false =
	(
		for i in arrID do 
		(
			parentNub = (GetSkeletalNode i false)
			nubNode = (GetSkeletalNode (i + 1) false)
			if isvalidnode parentNub and parentNub != undefined and nubNode == undefined then
			(
				local vec = parentNub.pos - parentNub.parent.pos
				if isHead then vec = vec * 3
				local pos = parentNub.pos + (normalize vec) * (length vec)
				if isFoot then pos.z = parentNub.pos.z
				in parentNub nB = bone pos:pos
				nB.name = parentNub.name + " nub"
				if i > 35 then 
				(
					tempItems = rolBsRetarget.characterBones_B.items
					tempItems[i - 35 + 1] = nB.name
					rolBsRetarget.characterBones_B.items = tempItems
				)
				else 
				(
					tempItems = rolBsRetarget.characterBones.items
					tempItems[i+ 1] = nB.name
					rolBsRetarget.characterBones.items = tempItems
				)
			)
			else (messageBox "请先验证并检查映射列表是否完整！                                       " title:"BsRetargetTools")
		)
	)

	on quickMakeParent picked do
	(
		if $ != undefined then
		(
			nB = bone pos:$.pos
			nB.name = $.name
			$.name = nB.name + " DEP"
			nB.parent = $.parent
			$.parent = nB
		)
	)
	on quickDuplicate picked do
	(
		for i in selection as array where $ != undefined do
		(
			local vec = i.pos - i.parent.pos;
			local pos = i.pos + (normalize vec) * (length vec);
			in i nB = bone pos:pos;
			nB.name = i.name + " nub";
			-- select nB
		)
	)

	on quickDuplicateHead picked do 
	(
		arrHeadID = #(8)
		fnDuplicateNub arrHeadID isHead:true
	)

	on quickDuplicateFingers picked do 
	(
		arrFingersID = #(26,30,34,38,42,50,54,58,62,66)
		fnDuplicateNub arrFingersID
	)

	on quickDuplicateFoot picked do
	(
		arrFootID = #(13,18)
		fnDuplicateNub arrFootID isFoot:true
	)
	on quickCenterRoot picked do
	(
		try
		(
			local leftLeg = GetSkeletalNode 10 false
			local rightLeg = GetSkeletalNode 15 false
			
			local root = GetSkeletalNode 1 false
			local hip = GetSkeletalNode 2 false
			
			local dummyRoot = point name:("NewHip_" + root.name)
			local dummyPelvis = point name:("NewPelvis_" + hip.name)

			dummyRoot.constantscreensize = false
			dummyRoot.size = 0.01

			dummyPelvis.constantscreensize = false
			dummyPelvis.size = 0.01
			
			dummyRoot.transform = root.transform
			dummyRoot.pos = 0.5 * (leftLeg.pos + rightLeg.pos)
			dummyPelvis.transform = dummyRoot.transform

			-- local pC = Position_Constraint()
			-- pC.appendTarget root 100
			-- dummyRoot.Position.controller = pC
			-- pC.relative = true
			
			-- local oC = Orientation_Constraint()
			-- oC.appendTarget root 100
			-- dummyRoot.Rotation.controller = oC
			-- oC.relative = true

			dummyRoot.parent = root
			dummyPelvis.parent = hip
			
			tempItems = rolBsRetarget.characterBones.items
			tempItems[1] = dummyRoot.name
			tempItems[2] = dummyPelvis.name
			rolBsRetarget.characterBones.items = tempItems

			-- if root.parent != undefined then
			-- (
			-- 	boneRootMotionTarget = root.parent
			-- 	boneRootMotion = dummy name:("Root_" + boneRootMotionTarget.name)
			-- 	boneRootMotion.transform = boneRootMotionTarget.transform
			-- 	-- dummyRoot.parent = boneRootMotion
			-- 	local pC = Position_Constraint()
			-- 	pC.appendTarget boneRootMotionTarget 100
			-- 	boneRootMotion.Position.controller = pC
			-- 	pC.relative = true
				
			-- 	local oC = Orientation_Constraint()
			-- 	oC.appendTarget boneRootMotionTarget 100
			-- 	boneRootMotion.Rotation.controller = oC
			-- 	oC.relative = true
			-- )

			messagebox "已根据大腿重新创建符合 Biped 的质心和盆骨，并且更新了映射列表！                                                          "
			-- hip.parent = dummyRoot

			-- print leftLeg
			-- print rightLeg
			-- print root
			-- print hip
			hasExtraHips = true
		)
		catch
		(
            messagebox "请先添加骨骼映射！                 "
		)
	)
)

rcmenu menuBsRetarget
(
	menuItem mItemNier "修复 Nier 60帧率"
	menuItem mItemScale100 "Scale 100"

	on menuBsRetarget open do
	(
		mItemNier.checked = fixNierFramerate
		mItemScale100.checked = isScale100
	)
	
	on mItemNier picked do
	(
		mItemNier.checked = not mItemNier.checked
		fixNierFramerate = mItemNier.checked
	)

	on mItemScale100 picked do
	(
		mItemScale100.checked = not mItemScale100.checked
		isScale100 = mItemScale100.checked
	)
)

-- The rollout used for this script.
rollout rolBsRetarget "BsRetargetTools_v3.1 （ FBX 转 BIP + 动画重定向 ）"
(
	local LastSubRollout = 1

	dotnetcontrol lblTitle "Label" text:"选择骨骼，左键填入列表，右键重置，除【可选】以外，暂时需要映射列表完整，按1234顺序执行即可" pos:[0,5] width:rolBsRetarget.width height:16
	dotNetControl tabBsADT "System.Windows.Forms.TabControl" height:30 width:rolBsRetarget.width pos:[0,25] align:#center
	-- Contains the names of the first 35 biped bones for reference
	listbox bipedBones "Bip 节点 1 - 35" pos:[10,60] across:4 height:42 width:114 items:#("Biped Root", "Biped Pelvis", "Biped Spine 0", "Biped Spine 1")
	-- visible:false
    -- Contains the names of the first 35 bones used from the original rig
	listbox characterBones "Bone 骨骼 1 - 35" pos:[130,60]height:42 width:114 items:#("~undefined~")
	
	-- Contains the names of the reamining biped bones for reference
	listbox bipedBones_B "Bip 节点 36 - 67" pos:[250,60] height:42 width:114 items:#("Biped Root", "Biped Pelvis", "Biped Spine 0", "Biped Spine 1")
	-- Contains the names of the remaining original rig's bones.
	listbox characterBones_B "Bone 骨骼 36 - 67" pos:[370,60] height:42 width:114 items:#("~undefined~")
	
	local switchFBXTools = false
    local btnWidth   = 145
	local arrSaveVer = (for i = 0 to 3 collect ("20" + (((maxversion())[1]/1000)-2-i) as string))

    groupbox grpRetargetList "【必须】检查映射" pos:[490,60] width:(btnWidth + 10) height:210

	-- label lblTips "" pos:[260,450] width:200 height:30
	-- pickbutton pkbRootMption "0. 指定原 RootMotion" pos:[20,505] height:30 width:(btnWidth) message:"指定原始 FBX 的 RootMotion" autoDisplay:true tooltip:"右键清除选择"
    button loadDialogue "加载列表" pos:[495,140] width:(btnWidth/2) height:25
    button saveDialogue "保存列表" pos:[570,140] width:(btnWidth/2) height:25
    button btnAutoMapping "1. 自动按命名匹配" pos:[495,100] width:btnWidth height:35 tooltip:"根据通用的身体骨骼名称，自动检索匹配。"
	button btnQuickTools "快速创建所需节点" pos:[495,170] width:btnWidth height:35 tooltip:"快速创建 nub 骨骼或符合 Biped 的质心。"
	button validateButton "2. 验证映射列表完整" pos:[495,210] width:btnWidth height:50 tooltip:"必须验证匹配是否完整。"
    
    groupbox grpBiped "【可选】视情况设置" pos:[490,280] width:(btnWidth + 10) height:250
	spinner spnObjSize "Helper Size" pos:[500,81] range:[0.01,1000,5] align:#left offset:[2,0] fieldwidth:35 scale:0.01
	button btnResetSize "应用" pos:[605,80] width:35 height:18 tooltip:"重置选中辅助骨骼大小"

	label lblThumbAxis "(左) 拇指 z轴" pos:[500,352] width:70 height:25
	dropdownList ddlThumbAxis "" pos:[590,350] width:50 height:25 items:#("X","Y","Z","-X","-Y","-Z") selection:2
	label lblHandAxis "(左) 四指 z轴" pos:[500,377] width:70 height:25
	dropdownList ddlHandAxis "" pos:[590,375] width:50 height:25 items:#("X","Y","Z","-X","-Y","-Z") selection:6
	label lblThumbAxis2 "(右) 拇指 z轴" pos:[500,402] width:70 height:25
	dropdownList ddlThumbAxis2 "" pos:[590,400] width:50 height:25 items:#("X","Y","Z","-X","-Y","-Z") selection:2
	label lblHandAxis2 "(右) 四指 z轴" pos:[500,427] width:70 height:25
	dropdownList ddlHandAxis2 "" pos:[590,425] width:50 height:25 items:#("X","Y","Z","-X","-Y","-Z") selection:6
	button reAlignFingers "🤞🏼 重新对齐手指 🤞🏼" pos:[495,450] width:(btnWidth) height:25
	-- checkbox chkRenameBiped "Biped 保持 Bone 原名" checked:false pos:[164,535] width:(btnWidth + 20) height:20
	-- radiobuttons rdoUpAxis " 映射 RootMotion 轴向" pos:[155,500] width:154 height:46 labels:#("Y-Up (U3D)", "Z-Up (UE)") columns:2 default:2
	label lblUpAxis "引擎 RootMotion 选择" pos:[500,300] width:120 height:25
	dropdownList ddlUpAxis "" pos:[495,320] width:145 height:25 items:#("Y-Up (U3D) -  Unity","Z-Up (UE)   -  Unreal") selection:2
	checkbox chkCopySubs "↓ 映射飘带骨骼动画 ↓" pos:[500,535] height:20 width:(btnWidth + 25) checked:false
    button alignBipedToHelper "3. 创建重定向映射文件" pos:[495,560] width:(btnWidth) height:30
    
    -- button btnExportTPose "[可选]导出 Biped Figure Pose" pos:[305,505] width:(btnWidth + 35) height:25
	
	button btnReplaceToBiped "4. FBX 转 Biped ( Skin )" pos:[495,595] width:(btnWidth) height:30
    -- checkbutton ckbExportFBXTools "🎮 动画批量重定向工具" pos:[305,555] width:(btnWidth + 35) height:45
	checkbox chkRealign "重置轴向 (解算飘带) ↓" pos:[500,477] height:20 width:(btnWidth - 15) checked:false
	button btnConvertToBone "[慎用] Helper 转 Bone" pos:[495,500] height:25 width:(btnWidth) tooltip:"需要选中"
	
	button btnRefreshFolder ">>  按默认规则刷新路径和文件  <<" \
	height:40 width:225 pos:[240,65] tooltip:"刷新当前文件目录\r\n并按默认规则寻找文件\r\n映射文件为当前打开文件\r\n新 Skin 文件为同目录 Skin.max" visible:false
	edittext edtAllTips text:"打开映射文件\r\n\r\n按规则刷新路径\r\n\r\n会找同目录下的 \r\n\r\nSkin.max（转的蒙皮文件）\r\n\r\nAniFBX（原fbx动画目录）\r\n\r\nReOutput（新导出目录）
\r\n\r\n\r\n\r\n映射文件为\r\n\r\n前面fbx转biped\r\n\r\n的中间文件\r\n\r\nskin文件为\r\n\r\n最后转的文件\r\n\r\n注意分别保存\r\n\r\n注意检查映射文件\r\n\r\n的手指轴向（Y内Z右）\r\n\r\n\r\n\r\n\r\n清零Root曲线不用点\r\n\r\n暂时没多大用\r\n\r\n是测试用小工具" pos:[475,65] height:530 width:165 readOnly:true visible:false

	listBox ltbFilesList "" selection:0 \
	height:40 width:215 pos:[15,65] visible:false

	button btnLoadAnimPath "选择动画目录" tooltip:"选择原始动画目录" \
	height:22 width:105 pos:[240,115] visible:false
	button btnRefreshAnimFiles "刷新" \
	height:22 width:60 pos:[345,115] visible:false
	button btnOpenCurrentPath "打开" tooltip:"打开当前文件夹" \
	height:22 width:60 pos:[405,115] border:true visible:false
	editText edtAnimFbxPath "" text:"" labelOnTop:true \
	height:22 fieldWidth:225 pos:[240,145] readOnly:true visible:false
	
	button btnOutputPath "选择导出目录" pos:[240,175] width:165 visible:false \
	tooltip:"导出的重定向动画 FBX 保存目录，\r\n新 Skin 动画目录在：\r\n此目录的 *\NewFbx 目录下。"
	button btnOpedOutputPath "打开" pos:[405,175] width:60 visible:false \
	tooltip:"打开重定向文件导出目录"
	editText edtOutputPath "" text:"" labelOnTop:true \
	height:22 fieldWidth:225 pos:[240,200] readOnly:true visible:false
    
	button btnSelectMappingFile "选择映射文件" pos:[240,230] width:165 visible:false \
	tooltip:"选择以 Bone 骨架生成的 Biped 映射文件"
	button btnOpenMappingFile "打开" pos:[405,230] width:60 visible:false \
	tooltip:"打开映射文件"
    editText edtMappingFile "" text:"" labelOnTop:true \
	height:22 fieldWidth:225 pos:[240,260] readOnly:true visible:false
	
	button btnSelectSkinFile "选择新 Skin 文件" pos:[240,295] width:165 visible:false \
	tooltip:"选择新的 Skin 文件"
	button btnOpenSkinFile "打开" pos:[405,295] width:60 visible:false \
	tooltip:"打开新 Skin 文件"
    editText edtSkinFile "" text:"" labelOnTop:true \
	height:22 fieldWidth:225 pos:[240,325] readOnly:true visible:false

	checkbox chkRecoverExport "不覆盖导出，用于崩溃后继续重导" checked:false pos:[250,355] width:225 height:20 visible:false
    button btnRetargetSelected ">>>   重定向列表选中动画   <<<" pos:[240,430] width:225 height:30 visible:false \
	tooltip:"重定向列表选中的动画并且打开\r\n会保存一份 .max 和 .FBX 文件"
    button btnRetargettAll ">>>   重定向列表所有动画   <<<" pos:[240,470] width:225 height:30 visible:false \
	tooltip:"重定向列表选中的动画\r\n会保存一份 .max 和 .FBX 文件\r\n可能比较慢..."
	checkbox chkXAxis "X" pos:[245,513] width:30 height:30 visible:false
	checkbox chkYAxis "Y" pos:[275,513] width:30 height:30 visible:false
	checkbox chkZAxis "Z" pos:[305,513] width:30 height:30 visible:false
	button btnBatchAll "清零 Root 位移曲线" pos:[340,515] width:125 height:25 visible:false border:false tooltip:"自用"
	button btnSpecial "[自用] 后处理集合" pos:[240,385] width:110 height:25 visible:false border:true
	label lblVerTips "保存版本:" pos:[355,390] width:60 height:25 visible:false
	dropdownList ddlSaveVersion "" pos:[410,387] width:55 items:arrSaveVer visible:false
	button btnCount "待处理原始动画 FBX 数：0 个" pos:[15,600] width:215 height:30 visible:false border:true tooltip:"打开原始动画 FBX 文件夹"

    progressbar pgbBar "" pos:[10,635] width:590 height:16 color:white
	label lblBarValue "" pos:[610,635] width:60

	local arrFBXtoBIPED   = #(">> 【 FBX 转 Biped 】 <<",#(bipedBones,characterBones,bipedBones_B,characterBones_B,grpRetargetList,loadDialogue,saveDialogue,\
											btnAutoMapping,btnQuickTools,validateButton,grpBiped,spnObjSize,btnResetSize,lblThumbAxis,ddlThumbAxis,\
											lblHandAxis,ddlHandAxis,lblThumbAxis2,ddlThumbAxis2,ddlHandAxis2,lblHandAxis2,reAlignFingers,lblUpAxis,ddlUpAxis,chkCopySubs,alignBipedToHelper,\
											btnReplaceToBiped,chkRealign,btnConvertToBone))
	local arrAnimRetarget = #(">> 【 动画重定向 】<<",#(btnRefreshFolder,ltbFilesList,btnLoadAnimPath,btnRefreshAnimFiles,btnOpenCurrentPath,edtAnimFbxPath,btnOutputPath,\
											btnOpedOutputPath,edtOutputPath,btnSelectMappingFile,btnOpenMappingFile,edtMappingFile,btnSelectSkinFile,btnOpenSkinFile,\
											edtSkinFile,chkRecoverExport,btnRetargetSelected,btnRetargettAll,chkXAxis,chkYAxis,chkZAxis,btnBatchAll,\
											btnSpecial,lblVerTips,ddlSaveVersion,btnCount,edtAllTips))
	local arrAllToolsTab  = #(arrFBXtoBIPED,arrAnimRetarget)

	fn fnInitDotTabs =
	(
		lblTitle.font      = dotnetobject "System.Drawing.Font" "Roboto" 8
		lblTitle.TextAlign = (dotnetclass "system.drawing.contentalignment").MiddleCenter
		lblTitle.BackColor = (dotColor.FromArgb	200 200 200)
		lblTitle.ForeColor = (dotColor.FromArgb 139 0 0)
		tabBsADT.sizeMode  = (dotnetclass "System.Windows.Forms.TabSizeMode").Fixed
		tabBsADT.itemSize  = dotNetObject "System.Drawing.Size" (rolBsRetarget.width/arrAllToolsTab.count - arrAllToolsTab.count) 30
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

    fn getFilesequenceFile f &base &digits = 
	(
		f = getFilenameFile f
		base = trimRight f "0123456789"
		digits = subString f (base.count + 1) -1
	)

	fn fnPseudoNaturalSort a b =  --文件名排序新方法--https://forums.cgsociety.org/t/sorting-filenames/1219205/4
	(
		a = a as string
		b = b as string
		getFilesequenceFile a &aBase &aDigits
		-- hackhackhack.  This pads a number with zeros to 6 digits without using a loop.
		-- things will fail if there's more digits.. 6 'seems' safe.
		aDigits = subString ((1000000 + (aDigits as integer)) as string) 2 -1
		getFilesequenceFile b &bBase &bDigits
		bDigits = subString ((1000000 + (bDigits as integer)) as string) 2 -1
		a = aBase + aDigits
		b = bBase + bDigits
	
		case of (
		(a == b): 0
		(a < b): -1
		(a > b): 1
		)
	)

    fn getFilesRecursive root pattern =
	(
		dir_array = GetDirectories (root+"/*")
		for d in dir_array do 
		(
			-- print d
			if (d != edtOutputPath.text) then join dir_array (GetDirectories (d+"/*"))
		)
		my_files = #()
		for f in dir_array do 
		(
			if (getfilenamepath f != edtOutputPath.text) then join my_files (getFiles (f + pattern))
		)
		join my_files (getFiles (root + "/" + pattern))
		my_files
	)

    fn fnRefreshDir dir =
    (
        if (dir != undefined) and (dir != "") then 
        (
			dir += "\\"
            edtAnimFbxPath.text = (substituteString dir "\\\\" "\\")
            arrFBX = (getFilesRecursive dir "\\*.FBX")
			qsort arrFBX fnPseudoNaturalSort
			ltbFilesList.items = for i in arrFBX collect ((getfilenamefile i) + ".FBX")
			-- btnCount.text = ("已重定向动画 FBX 数：0 个")
			btnCount.text = ("待处理原始动画 FBX 数：" + ltbFilesList.items.count as string + " 个")
			arrExportRetargetAnim = arrFBX
        )
    )

	fn fnIsIgnoreBone index =
	(
		if characterBones.items[index] == "~undefined~" then (return true) else (return false)
	)

	-- fn fnConfirmImportFBX =
	-- (
	-- 	hwnd = dialogMonitorOps.getWindowHandle()
	-- 	hwndText = uiAccessor.getWindowText hwnd
	-- 	print hwndText
	-- 	if (matchpattern hwndText pattern:"*FBX Import*") then
	-- 	(
	-- 		UIAccessor.PressButtonByName hwnd "OK"
	-- 	)
	-- 	true
	-- )

	-- fn fnConfirmExportFBX =
	-- (
	-- 	hwnd = dialogMonitorOps.getWindowHandle()
	-- 	hwndText = uiAccessor.getWindowText hwnd
	-- 	print hwndText
	-- 	if (matchpattern hwndText pattern:"*FBX Export*") then
	-- 	(
	-- 		UIAccessor.PressButtonByName hwnd "OK"
	-- 	)
	-- 	true
	-- )

	mapped fn fnSelectChildrens objSel =
	(
		selectmore objSel.children
		for i in objSel.children do (fnSelectChildrens i)
	)

	fn fnJudgeSizeType tempObj size =
	(
		case classof tempObj of
		(
			(BoneGeometry):(tempObj.width = size;tempObj.height = size)
			(Dummy):(tempObj.boxsize = [size,size,size])
			(point):(tempObj.size = size)
		)
	)

	fn fnFixSize tempHelpers =
	(
		case units.MetricType of
		(
			#Millimeters:(fnJudgeSizeType tempHelpers 40)
			#Centimeters:(fnJudgeSizeType tempHelpers 4)
			#Meters:(fnJudgeSizeType tempHelpers 0.04)
		)
	)

	fn fnGetRootNode = 
	(
		for i in objects where classof i == Biped_Object do (return i.controller.rootnode)
	)

	global GetBipedNode
	fn GetBipedNode index =
	(
		if (index == 1) then
		(
			targetBiped = fnGetRootNode()
			if targetBiped != ok then 
			(
				clearselection()
				select targetBiped
				fnSelectChildrens targetBiped
				arrAllBipedNode = (selection as array)
				arrAllBipedName = for i in arrAllBipedNode collect i.name
				return targetBiped
			)
		)
		else if (index <= 35) then
		(
            local strTargetBiped = (bipedRootName + " " + (substituteString rolBsRetarget.bipedBones.items[index] "[可选]" ""))
			idTargetBiped = finditem arrAllBipedName strTargetBiped
			if idTargetBiped != 0 then 
			(
				targetBiped = arrAllBipedNode[idTargetBiped]
            	targetBiped.boxmode = true
			)
			return targetBiped
		)
		else
		(
            local strTargetBiped = (bipedRootName + " " + rolBsRetarget.bipedBones_B.items[index-35])
			idTargetBiped = finditem arrAllBipedName strTargetBiped
			if idTargetBiped != 0 then 
			(
				targetBiped = arrAllBipedNode[idTargetBiped]
				targetBiped.boxmode = true
			)
			return targetBiped
		)
	)

	fn fnExportReTargrtedAnim arrExportRetargetAnim index =
	(
		if (index != 0) and (doesFileExist arrExportRetargetAnim[index]) then
		(
			local SIOFile = dotNetClass "System.IO.File"			---文件操作
			local SIODir = dotNetClass "System.IO.Directory"		---文件夹操作

			FbxImporterSetParam "Mode" #exmerge
			FbxImporterSetParam "Animation" true
			FbxImporterSetParam "FillTimeline" true
			FbxImporterSetParam "BakeAnimationLayers" false
			FbxImporterSetParam "PointCache" false

			mappingFilePath    = edtMappingFile.text
			sourFileImportPath = arrExportRetargetAnim[index]
			tarFileExportPath  = edtOutputPath.text + "\FBX\\" + (getfilenamefile sourFileImportPath) + ".FBX"
			tempBip = edtOutputPath.text + "\BIP\\" + (getfilenamefile sourFileImportPath) + ".bip"
			tarMaxFile = edtOutputPath.text + "\MAX\\" + (getfilenamefile sourFileImportPath) + ".max"
			skinFile   = edtSkinFile.text
			tarNewAnim = (edtOutputPath.text + "\FBX\\" + (getfilenamefile sourFileImportPath) + ".FBX")
			if (not (SIODir.Exists edtOutputPath.text)) do (SIODir.CreateDirectory edtOutputPath.text)
			if (not (SIODir.Exists (edtOutputPath.text + "\FBX\\"))) do (SIODir.CreateDirectory (edtOutputPath.text + "\FBX\\"))
			if (not (SIODir.Exists (edtOutputPath.text + "\BIP\\"))) do (SIODir.CreateDirectory (edtOutputPath.text + "\BIP\\"))
			if (not (SIODir.Exists (edtOutputPath.text + "\MAX\\"))) do (SIODir.CreateDirectory (edtOutputPath.text + "\MAX\\"))
			-- print ("开始重定向动画：" +  (getfilenamefile arrExportRetargetAnim[index]) + ".FBX")
			if chkRecoverExport.state then 
			(
				if (doesFileExist tarMaxFile) and (doesFileExist tarNewAnim) then (return "Exist")
			)
			resetMaxFile #noPrompt

			loadMaxFile mappingFilePath useFileUnits:true quiet:true
			if fixNierFramerate then framerate = 30
			importFile sourFileImportPath #noPrompt using:FBXIMP

			-- DialogMonitorOps.Enabled = true
			-- DialogMonitorOps.RegisterNotification fnConfirmImportFBX id:#importFBX
			-- DialogMonitorOps.unRegisterNotification id:#importFBX
			-- DialogMonitorOps.Enabled = false

			if fixNierFramerate then 
			(
				framerate = 60
				frameStart = animationrange.start
				frameEnd = animationrange.end
				scaleTime objects frameStart frameEnd 0.5
				animationrange = interval frameStart (frameEnd/2)
				rescaleWorldUnits 100
				--修复Nier动画帧数,缩放等等
				startFrame = animationrange.start
				endFrame = animationrange.end
				for i in objects where isValidNode i do
				(
					deselectKeys i
					selectkeys i startFrame startFrame
					deleteKeys i #selection
					selectkeys i (startFrame + 1) endFrame
					moveKeys i -1 #selection
				)
				animationrange = interval startFrame (endFrame - 1)
			)

			if isScale100 then (rescaleWorldUnits 100)

			select $'RTHelper_*'
			if (selection as array).count == 0 then (select $'RetargetHelper_*';preStr = "Old")
			arrExport = (selection as array)
			for i in arrExport where isValidNode i do
			(
				if preStr == "Old" then (i.name = substituteString i.name "RetargetHelper_" "")
				else (i.name = substituteString i.name "RTHelper_" "")
			)
			
			FBXExporterSetParam "Animation" true
			FBXExporterSetParam "BakeAnimation" true
			FBXExporterSetParam "BakeResampleAnimation" false
			FBXExporterSetParam "SplitAnimationIntoTakes" "-c"
			FBXExporterSetParam "BakeFrameStart" animationRange.start
			-- if fixNierFramerate then (FBXExporterSetParam "BakeFrameStart" 1)
			FBXExporterSetParam "BakeFrameEnd" animationRange.end
			FBXExporterSetParam "Cameras" false
			FBXExporterSetParam "Lights" false
			FBXExporterSetParam "EmbedTextures" false

			FBXExporterSetParam "AxisConversionMethod" "None"
			FBXExporterSetParam "UpAxis" "Y"

			FBXExporterSetParam "ShowWarnings" true
			FBXExporterSetParam "GenerateLog" false

			FBXExporterSetParam "ASCII" false
			FBXExporterSetParam "FileVersion" "FBX201200"

			select arrExport
			completeredraw()
			exportFile tarFileExportPath #noPrompt selectedOnly:true using:FBXEXP

			-- print ("正在导入新 Skin 动画：" + tarNewAnim)
			resetMaxFile #noPrompt
			
			loadMaxFile skinFile useFileUnits:true quiet:true
			if fixNierFramerate then framerate = 60
			(GetBipedNode 1).transform.controller.figureMode = false

			FbxImporterSetParam "Mode" #exmerge
			FbxImporterSetParam "Animation" true
			FbxImporterSetParam "FillTimeline" true
			FbxImporterSetParam "BakeAnimationLayers" false
			FbxImporterSetParam "PointCache" false

			-- if (getnodebyname "Root") != undefined then
			-- (
			-- 	local dummyRootMotionTemp = point name:"RootTemp" wirecolor:red
			-- 	-- in coordsys gimbal dummyRootMotionTemp.rotation = (eulerAngles 90 0 0)
			-- 	if rolBsRetarget.ddlUpAxis.selection == 1 then (in coordsys gimbal dummyRootMotionTemp.rotation = (eulerAngles 90 0 0))
			-- 	else (in coordsys gimbal dummyRootMotionTemp.rotation = (eulerAngles 0 0 0))
			-- 	(GetBipedNode 1).parent = dummyRootMotionTemp
			-- 	dummyRootMotionTemp.constantscreensize = false
			-- )
			(GetBipedNode 1).parent = undefined
			importFile tarNewAnim #noPrompt using:FBXIMP
			DeleteFile tarNewAnim

			if (getnodebyname "Root") != undefined then 
			(
				local rootBone            = (GetBipedNode 1)
				local dummyRootMotion     = (getnodebyname "Root")
				-- local dummyRootMotionTemp = (getnodebyname "RootTemp")

				-- 每一帧的Pos与Rot
				local bipPosList = #()
				local bipRotList = #()

				-- 第一次遍历，记录原始的bip在世界空间的位置与旋转信息
				-- for t = (animationRange.start) to (animationRange.end) do
				-- (
				-- 	at time t
				-- 	(
				-- 		append bipPosList (in coordsys world Biped.getTransform rootBone #pos)
				-- 		append bipRotList (in coordsys world Biped.getTransform rootBone #rotation)
				-- 	)
				-- )

				-- 第二次遍历，动画 Root 匹配 RootLeader
				for t = (animationRange.start) to (animationRange.end) do
				(
					at time t with animate on 
					(
						append bipPosList (in coordsys world Biped.getTransform rootBone #pos)
						append bipRotList (in coordsys world Biped.getTransform rootBone #rotation)
						-- dummyRootMotionTemp.transform = dummyRootMotion.transform
					)  
				)
				rootBone.parent = dummyRootMotion
				-- 第三次遍历，创建新的Bip层，还原bip的位置以及旋转信息
				biped.createLayer rootBone.controller 1 "layerRootMotionOffset"
				biped.setcurrentlayer rootBone.controller 1
				local f = 1
				for t = (animationRange.start) to (animationRange.end) do
				(
					at time t with animate on
					(
						-- Pos
						bipPos = bipPosList[f]
						in coordsys world Biped.setTransform rootBone #pos bipPos true
						-- Rot
						rootRot = dummyRootMotion.controller.rotation
						bipRot = bipRotList[f]
						localRot = bipRot * (inverse rootRot)
						Biped.setTransform rootBone #rotation localRot true

						f += 1
					)
				)
				-- dummyRootMotion.children.parent = dummyRootMotionTemp
				-- delete dummyRootMotionTemp
				-- dummyRootMotionTemp.name = "Root"
				biped.createLayer rootBone.controller 2 "layerRootMotionReverse"
				biped.setcurrentlayer rootBone.controller 2
				at time (animationRange.start) with animate on Biped.setTransform rootBone #rotation bipRotList[1] true
				biped.collapseAtLayer rootBone.controller 1
				biped.collapseAtLayer rootBone.controller 0
				-- dummyRootMotionTemp.size = 0.4
			)

			-- (GetBipedNode 1).transform.controller.figureMode = true
			-- (GetBipedNode 1).controller.trianglePelvis = false
			-- (GetBipedNode 1).controller.triangleNeck = true
			-- (GetBipedNode 1).transform.controller.figureMode = false

			saveMaxFile tarMaxFile saveAsVersion:((rolBsRetarget.ddlSaveVersion.selected) as integer) clearNeedSaveFlag:true quiet:true
			arrExport = (for i in objects where classof i == Biped_Object or classof i == Dummy or classof i == BoneGeometry collect i)
			select arrExport
			exportFile tarFileExportPath #noPrompt selectedOnly:true using:FBXEXP
			biped.saveBipFile (getnodebyname "Bip001").controller tempBip
			-- print ("已保存新 Skin 动画：" + (substituteString tarNewAnim ".FBX" ".max"))
		)
	)

--------------------------------------------------------------------------------------------------------------------------	

	global GetBonePos
	fn GetBonePos itemIndex =
	(
		return (GetSkeletalNode itemIndex false).pos;
	)

	global GetBoneRot
	fn GetBoneRot itemIndex =
	(
		return (GetSkeletalNode itemIndex false).rotation;
	)

	global CreateFauxBone
	fn CreateFauxBone initialBone parentIndex childIndex axis isFoot:false isToes:false isHand:false=
	(
		foundParent = GetSkeletalNode parentIndex false
		
		foundChild = undefined 
		if (childIndex > 0) then
		(
			foundChild = GetSkeletalNode childIndex false
		)
		
		print (foundParent)
		print (foundChild)
		
		if (isFoot == true) then
		(
			local parentPos = foundParent.pos;
			local childPos = foundChild.pos;
			local midPos = [parentPos.x, parentPos.y, childPos.z]
			
			local diffA = midPos - parentPos;
			local croA = cross (normalize diffA) axis
			local axisA = normalize croA
			
			newBone           = BoneSys.createBone parentPos midPos axisA
			newBone.parent    = initialBone
			newBone.name      = ("RTHelper_" + (GetBipedNode parentIndex).name);
			newBone.boxmode   = true
			newBone.wirecolor = black
			fnFixSize newBone
			-- newBone.width     = 0.01
			-- newBone.height    = 0.01
			
			return newBone;
		)
		
		if (isToes == true) then
		(
			local parentPos = foundParent.pos;
			local childPos = foundChild.pos;
			local midPos = [childPos.x, childPos.y, parentPos.z]
			
			local diffA = midPos - parentPos;
			local croA = cross (normalize diffA) axis
			local axisA = normalize croA
			
			newBone           = BoneSys.createBone parentPos midPos axisA
			newBone.parent    = initialBone
			newBone.name      = ("RTHelper_" + (GetBipedNode parentIndex).name);
			newBone.boxmode   = true
			newBone.wirecolor = green
			fnFixSize newBone
			-- newBone.width     = 0.01
			-- newBone.height    = 0.01
			
			return newBone;
		)
		
		if (isHand == true) then
		(
			local mid = [0,0,0]
			if (parentIndex == 23) then
			(
				-- local fIndex = GetSkeletalNode 28 false
				local fMiddle = GetSkeletalNode 32 false
				local fRing = GetSkeletalNode 36 false
				-- local fPinky = GetSkeletalNode 40 false;
				
				mid = (fMiddle.pos + fRing.pos) * 0.5;
			)
			else if (parentIndex == 47) then
			(
				-- local fIndex = GetSkeletalNode 52 false
				local fMiddle = GetSkeletalNode 56 false
				local fRing = GetSkeletalNode 60 false
				-- local fPinky = GetSkeletalNode 64 false;
				
				mid = (fMiddle.pos + fRing.pos) * 0.5;
			)
			else 
			(
				if (foundChild != undefined) then
				(
					mid = foundChild.pos
				)
				else 
				(
					local diff = foundParent.pos - initialBone.pos
					
					if initialBone != undefined then
					(
						mid = (foundParent.pos + (normalize diff) * 4)
					)
					else
					(
						return undefined;
					)
				)
			)
			
			-- local diff = mid - foundParent.pos
			-- local cro = cross (normalize diff) axis
			-- axis = normalize cro
			-- print axis
			local axis2
			local axisThumb2

			case rolBsRetarget.ddlHandAxis.selected of 
			(
				("X"):(axis = foundParent.transform.row1)
				("Y"):(axis = foundParent.transform.row2)
				("Z"):(axis = foundParent.transform.row3)
				("-X"):(axis = -foundParent.transform.row1)
				("-Y"):(axis = -foundParent.transform.row2)
				("-Z"):(axis = -foundParent.transform.row3;axisThumb = foundParent.transform.row2)
				default:(axis = -foundParent.transform.row3;axisThumb = foundParent.transform.row2)
			)

			case rolBsRetarget.ddlThumbAxis.selected of 
			(
				("X"):(axisThumb = foundParent.transform.row1)
				("Y"):(axisThumb = foundParent.transform.row2)
				("Z"):(axisThumb = foundParent.transform.row3)
				("-X"):(axisThumb = -foundParent.transform.row1)
				("-Y"):(axisThumb = -foundParent.transform.row2)
				("-Z"):(axisThumb = -foundParent.transform.row3)
				default:(axisThumb = -foundParent.transform.row3)
			)

			case rolBsRetarget.ddlHandAxis2.selected of
			(
				("X"):(axis2 = foundParent.transform.row1)
				("Y"):(axis2 = foundParent.transform.row2)
				("Z"):(axis2 = foundParent.transform.row3)
				("-X"):(axis2 = -foundParent.transform.row1)
				("-Y"):(axis2 = -foundParent.transform.row2)
				("-Z"):(axis2 = -foundParent.transform.row3;axisThumb2 = foundParent.transform.row2)
				default:(axis2 = -foundParent.transform.row3;axisThumb2 = foundParent.transform.row2)
			)

			case rolBsRetarget.ddlThumbAxis2.selected of 
			(
				("X"):(axisThumb2 = foundParent.transform.row1)
				("Y"):(axisThumb2 = foundParent.transform.row2)
				("Z"):(axisThumb2 = foundParent.transform.row3)
				("-X"):(axisThumb2 = -foundParent.transform.row1)
				("-Y"):(axisThumb2 = -foundParent.transform.row2)
				("-Z"):(axisThumb2 = -foundParent.transform.row3)
				default:(axisThumb2 = -foundParent.transform.row3)
			)

			arrThumbIndex = #(24,25,26,27)
			arrThumbIndex2 = #(48,49,50,51)

			if parentIndex > 47 then (axis = axis2;axisThumb = axisThumb2)
			if finditem arrThumbIndex parentIndex != 0 then (axis = axisThumb)
			if finditem arrThumbIndex2 parentIndex != 0 then (axis = axisThumb2)

			if initialBone != undefined then
			(
				newBone = BoneSys.createBone foundParent.pos mid axis
				newBone.parent    = initialBone
				newBone.boxmode   = true
				newBone.wirecolor = green
				fnFixSize newBone
			)
			else
			(
				newBone = BoneSys.createBone foundParent.pos mid axis
				newBone.boxmode   = true
				newBone.wirecolor = green
				fnFixSize newBone
			)

			newBone.name   = ("RTHelper_" + (GetBipedNode parentIndex).name);
			-- newBone.width  = 0.01
			-- newBone.height = 0.01
			
			return newBone;
		)
		
		if (foundParent != undefined) then
		(
			if (foundChild != undefined) then
			(
				local diff = foundChild.pos - foundParent.pos
				local cro = cross (normalize diff) axis
				axis = normalize cro
				print axis
				
				if initialBone != undefined then
				(
					newBone = BoneSys.createBone foundParent.pos foundChild.pos axis
					newBone.parent    = initialBone
					newBone.boxmode   = true
					newBone.wirecolor = green
					fnFixSize newBone
				)
				else
				(
					newBone = BoneSys.createBone foundParent.pos foundChild.pos axis
					newBone.boxmode   = true
					newBone.wirecolor = green
					fnFixSize newBone
				)
				
				newBone.name   = ("RTHelper_" + (GetBipedNode parentIndex).name)
				-- newBone.width  = 0.01
				-- newBone.height = 0.01
			)
			else
			(
				local diff = foundParent.pos - initialBone.pos
				local cro = cross diff axis
				axis = normalize cro
				print axis
				
				if initialBone != undefined then
				(
					newBone=BoneSys.createBone foundParent.pos (foundParent.pos + (normalize diff) * 4) axis
					newBone.parent    = initialBone
					newBone.boxmode   = true
					newBone.wirecolor = green
					fnFixSize newBone
					newBone.ishidden = true
				)
				else
				(
					return undefined;
				)
				
				newBone.name   = ("RTHelper_" + (GetBipedNode parentIndex).name)
				-- newBone.width  = 0.01
				-- newBone.height = 0.01
			)
		)		
		
		return newBone;
	)

	fn AdjustBipedScale index0 spine:false isToe:false isHand:false = 
	(
		local index1 = index0 + 1;
		if (((index0 == 6) and (fnIsIgnoreBone 7)) or ((index0 == 4) and (fnIsIgnoreBone 5))) then
		(
			index1 = index0 + 2;
		)
		
		affectedBiped = GetBipedNode index0;
		if affectedBiped == undefined then
		(
			messagebox ("Biped Node -- " + index0 + " is missing. -- Not Found");
			return 0;
		)
		
		pos0 = GetBonePos index0
		pos1 = GetBonePos index1
		if isHand == true then
		(
			-- Gives the middle finger.
			pos1 = GetBonePos (index0+9)
		)
		diff = (pos1 - pos0);
		nS = length diff;
		
		
		if isToe == true then
		(
			biped.setTransform affectedBiped #scale [nS, nS * 0.1, nS] false
		)
		else if spine == false or isHand == true then
		(
			biped.setTransform affectedBiped #scale [nS,nS,nS] false
		)
		else
		(
			print (diff.z);
			biped.setTransform affectedBiped #scale [abs diff.z,abs diff.z,abs diff.z] false
		)
	)
	
	global CreateOrientationConstraint
	fn CreateOrientationConstraint itemIndex fauxToBiped =
	(
		if fauxToBiped == false then
		(		
			/*local oC = Orientation_Constraint();
			oC.appendTarget (GetSkeletalNode itemIndex true) 100;
			
			(GetSkeletalNode itemIndex false).Rotation.controller = oC;
			oC.relative = true;*/
			


			local oC = Orientation_Constraint();
			oC.appendTarget (GetSkeletalNode itemIndex false) 100;
			
			(getNodeByName ("RTHelper_" + (GetBipedNode itemIndex).name)).Rotation.controller = oC;
			oC.relative = true;
		)
		else
		(
			local oC = Orientation_Constraint();
			oC.appendTarget (GetBipedNode itemIndex) 100;
			
			(getNodeByName ("RTHelper_" + (GetBipedNode itemIndex).name)).Rotation.controller = oC;
			oC.relative = true;
		)
	)
	
	global CreatePositionConstraint
	fn CreatePositionConstraint itemIndex fauxToBiped =
	(
		if fauxToBiped == false then
		(		
			/*local oC = Orientation_Constraint();
			oC.appendTarget (GetSkeletalNode itemIndex true) 100;
			
			(GetSkeletalNode itemIndex false).Rotation.controller = oC;
			oC.relative = true;*/
			
			local oC = Position_Constraint();
			oC.appendTarget (GetSkeletalNode itemIndex false) 100;
			
			(getNodeByName ("RTHelper_" + (GetBipedNode itemIndex).name)).Position.controller = oC;
			oC.relative = true;
		)
		else
		(
			local oC = Position_Constraint();
			oC.appendTarget (GetBipedNode itemIndex) 100;
			
			(getNodeByName ("RTHelper_" + (GetBipedNode itemIndex).name)).Position.controller = oC;
			oC.relative = true;
		)
	)
	
	fn AlignOldAndNewBones itemIndex prealign:false = 
	(
		if prealign == true then
		(
			biped.setTransform (GetBipedNode itemIndex) #pos (GetSkeletalNode itemIndex true).pos false
		)
		
		charBone = GetSkeletalNode itemIndex true
		bipedBone = GetBipedNode itemIndex
		
		if (charBone == undefined or bipedBone == undefined) then
		(
			messagebox (format "Character or Biped Bone % not found" itemIndex)
		)
		else
		(
			charBone.transform = bipedBone.transform
			select charBone
		)
	)
	
	global FixLimb
	fn FixLimb index = 
	(
		local limbToRotate = (GetBipedNode index)
		if (limbToRotate != undefined) then
		(
			select (GetBipedNode index)
				
			local min = 0
			local minLength = 900000
				
			for i = 1 to 72 do
			(
				in coordsys local rotate $ (angleaxis 5 [1,0,0])
					
				pos = biped.getTransform (GetBipedNode index) #pos
				diff = (GetSkeletalNode index true).transform.position - pos
				
				if (length diff < minLength) then
				(
					minLength = length diff
					min = i
				)
			)
			in coordsys local rotate $ (angleaxis (5 * min) [1,0,0])
		)
	)
	
	global AlignBipToFaux
	fn AlignBipToFaux v prealign:false = 
	(
		print v;
		
		inFigureMode = (GetBipedNode 1).transform.controller.figureMode
			
		case v of
		(
			1:  
			(
				ll = (GetSkeletalNode 10 true)
				rr = (GetSkeletalNode 15 true)
				pp = (ll.pos + rr.pos) * 0.5
				
				biped.setTransform (GetBipedNode 1) #pos pp false
				if okForceRedraw == true then forceCompleteRedraw();
					
				biped.setTransform (GetBipedNode 1) #rotation (GetSkeletalNode 1 true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
			2:
			(
				/*biped.setTransform (GetBipedNode 1) #pos (GetSkeletalNode 2 true).transform.position false
				if okForceRedraw == true then forceCompleteRedraw();
					
				biped.setTransform (GetBipedNode 1) #rotation (GetSkeletalNode 2 true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();*/
			)
			-- 1st Spine
			3:
			(
				if (inFigureMode) then
				(
					biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
					if okForceRedraw == true then forceCompleteRedraw();
				)
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
			-- Neck
			6:
			(
				if (inFigureMode) then
				(
					biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
					if okForceRedraw == true then forceCompleteRedraw();
				)
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
			-- Head
			8:
			(
				if (inFigureMode) then
				(
					biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
					if okForceRedraw == true then forceCompleteRedraw();
				)
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
			-- left shoulder
			20:
			(
				if (inFigureMode) then
				(
					biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
					if okForceRedraw == true then forceCompleteRedraw();
				)
				
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
			-- right shoulder
			44:
			(
				if (inFigureMode) then
				(
					biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
					if okForceRedraw == true then forceCompleteRedraw();
				)
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				
				if okForceRedraw == true then forceCompleteRedraw();
			)
			
			-- left hand
			23:
			(
				biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
				if okForceRedraw == true then forceCompleteRedraw();
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
				
				biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
				if okForceRedraw == true then forceCompleteRedraw();
				
				FixLimb 22
			)
			
			-- right hand
			47:
			(
				biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
				if okForceRedraw == true then forceCompleteRedraw();
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
				
				biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
				if okForceRedraw == true then forceCompleteRedraw();
				
				FixLimb 46
			)
			-- left foot
			12:
			(
				biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
				if okForceRedraw == true then forceCompleteRedraw();
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
				
				--in coordsys local rotate (GetBipedNode v) footAdjuster.value [0,0,1]
				
				biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
				if okForceRedraw == true then forceCompleteRedraw();
				
				FixLimb 11
			)
			-- right foot
			17:
			(
				biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
				if okForceRedraw == true then forceCompleteRedraw();
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
				
				--in coordsys local rotate (GetBipedNode v) footAdjuster.value [0,0,1]
				
				biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
				if okForceRedraw == true then forceCompleteRedraw();
				
				FixLimb 16
			)
			-- left thumb
			24:
			(
				if (inFigureMode) then
				(
					biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
					if okForceRedraw == true then forceCompleteRedraw();
				)
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
			-- left index
			28:
			(
				if (inFigureMode) then
				(
					biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
					if okForceRedraw == true then forceCompleteRedraw();
				)
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
			-- left middle
			32:
			(
				if (inFigureMode) then
				(
					biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
					if okForceRedraw == true then forceCompleteRedraw();
				)
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
			
			-- left ring
			36:
			(
				if (inFigureMode) then
				(
					biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
					if okForceRedraw == true then forceCompleteRedraw();
				)
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
			
			-- left pinky
			40:
			(
				if (inFigureMode) then
				(
					biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
					if okForceRedraw == true then forceCompleteRedraw();
				)
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
			
			-- right thumb
			48:
			(
				if (inFigureMode) then
				(
					biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
					if okForceRedraw == true then forceCompleteRedraw();
				)
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
			-- right index
			52:
			(
				if (inFigureMode) then
				(
					biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
					if okForceRedraw == true then forceCompleteRedraw();
				)
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
			-- right  middle
			56:
			(
				if (inFigureMode) then
				(
					biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
					if okForceRedraw == true then forceCompleteRedraw();
				)
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
			
			-- right  ring
			60:
			(
				if (inFigureMode) then
				(
					biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
					if okForceRedraw == true then forceCompleteRedraw();
				)
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
			
			-- left toe
			13:
			(
				if (inFigureMode) then
				(
					biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
					if okForceRedraw == true then forceCompleteRedraw();
				)
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
			
			-- right  toe
			18:
			(
				if (inFigureMode) then
				(
					biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
					if okForceRedraw == true then forceCompleteRedraw();
				)
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
			
			-- right  pinky
			64:
			(
				if (inFigureMode) then
				(
					biped.setTransform (GetBipedNode v) #pos (GetSkeletalNode v true).transform.position false
					if okForceRedraw == true then forceCompleteRedraw();
				)
					
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
			
			default:
			(
				biped.setTransform (GetBipedNode v) #rotation (GetSkeletalNode v true).transform.rotation false
				if okForceRedraw == true then forceCompleteRedraw();
			)
		)
	)

    fn fnAlignBipedFingersToHelper = 
    (
        if (GetBipedNode 1) != undefined then
        (
			max Create mode

            oldFigureMode = ((GetBipedNode 1).transform.controller.figureMode)

			if oldFigureMode == true then
			(
				for i = 24 to 43 do
				(
					AlignBipToFaux i
				)
				
				for i = 48 to 67 do
				(
					AlignBipToFaux i
				)
			)
            else (messageBox "请先打开 Biped 形体模式粘贴 Pose，否则 当前 Pose 会丢失！                                                    ")
        )
        else (messageBox "没有找到 Biped 骨骼！                                ")
    )

    fn fnAlignBipedToHelper =
    (
        try
		(
			for i = 1 to 67 where (not (fnIsIgnoreBone i)) do
			(
				-- if (i != 7) then
				-- (
					/*if (i == 2) then 
					(
						(GetSkeletalNode 2 true).transform = (GetSkeletalNode 2 false).transform;			
						(GetSkeletalNode 2 true).position = 0.5 * ((GetSkeletalNode 10 false).position + (GetSkeletalNode 15 false).position)
					)
					else
					(
						(GetSkeletalNode i true).transform = (GetSkeletalNode i false).transform;
					)
					
					local fauxNode = (GetSkeletalNode i true)
					
					for j = 1 to fauxBoneRotations[i].count do
					(
						in coordsys local rotate fauxNode fauxBoneRotations[i][j][1] fauxBoneRotations[i][j][2];
					)*/
					
					-- We ignore aligning to the legs and arms
					if (i != 10 and i != 11 and i != 15 and i != 16 and i != 21 and i != 22 and i != 45 and i != 46) then
					(
						AlignBipToFaux i
					)
				-- )
			)
		)
		catch
		(
			messagebox "Error when realigning.  Most likely a missing bone."
			return undefined
		)
		
		FixLimb 22
		biped.setTransform (GetBipedNode 23) #rotation (GetSkeletalNode 23 true).transform.rotation false
		
		FixLimb 46
		biped.setTransform (GetBipedNode 47) #rotation (GetSkeletalNode 47 true).transform.rotation false
		
		FixLimb 11
		FixLimb 16	
		
        AlignBipToFaux 23
        AlignBipToFaux 47
    )
	
	
	on alignHelperBiped pressed do
	(
		
		-- We align the neck and head bones
		AlignOldAndNewBones 3 prealign:true
		AlignOldAndNewBones 4
		AlignOldAndNewBones 5
		AlignOldAndNewBones 6 prealign:true
		if (not (fnIsIgnoreBone 7)) then (AlignOldAndNewBones 7)
		
		-- We then align the head bone
		AlignOldAndNewBones 8 prealign:true
		
		AlignOldAndNewBones 10
		AlignOldAndNewBones 11
		AlignOldAndNewBones 12
		
		AlignOldAndNewBones 13 prealign:true
		
		AlignOldAndNewBones 15
		AlignOldAndNewBones 16
		AlignOldAndNewBones 17
		AlignOldAndNewBones 18 prealign:true
		
		AlignOldAndNewBones 15
		AlignOldAndNewBones 16
		AlignOldAndNewBones 17
		AlignOldAndNewBones 18 prealign:true
		
		-- LEFT ARM
		AlignOldAndNewBones 20 prealign:true
		AlignOldAndNewBones 21
		AlignOldAndNewBones 22
		AlignOldAndNewBones 23
		
		-- LEFT FINGERS
		AlignOldAndNewBones 24 prealign:true
		AlignOldAndNewBones 25
		AlignOldAndNewBones 26
		
		AlignOldAndNewBones 28 prealign:true
		AlignOldAndNewBones 29
		AlignOldAndNewBones 30
		
		AlignOldAndNewBones 32 prealign:true
		AlignOldAndNewBones 33
		AlignOldAndNewBones 34
		
		AlignOldAndNewBones 36 prealign:true
		AlignOldAndNewBones 37
		AlignOldAndNewBones 38
		
		AlignOldAndNewBones 40 prealign:true
		AlignOldAndNewBones 41
		AlignOldAndNewBones 42
		
		-- RIGHT ARM
		AlignOldAndNewBones 44 prealign:true
		AlignOldAndNewBones 45
		AlignOldAndNewBones 46
		AlignOldAndNewBones 47
		
		-- RIGHT FINGERS
		AlignOldAndNewBones 48 prealign:true
		AlignOldAndNewBones 49
		AlignOldAndNewBones 50
		
		AlignOldAndNewBones 52 prealign:true
		AlignOldAndNewBones 53
		AlignOldAndNewBones 54
		
		AlignOldAndNewBones 56 prealign:true
		AlignOldAndNewBones 57
		AlignOldAndNewBones 58
		
		AlignOldAndNewBones 60 prealign:true
		AlignOldAndNewBones 61
		AlignOldAndNewBones 62
		
		AlignOldAndNewBones 64 prealign:true
		AlignOldAndNewBones 65
		AlignOldAndNewBones 66
	)
	
	on resetPosition pressed do
	(
		if (originalTransformArray.count != characterBones.items.count) then
		(
			for i = 1 to characterBones.items.count do
			(
				originalTransformArray = append originalTransformArray (GetBoneRot i)
			)
		)
		else
		(
		
			for i = 1 to originalTransformArray.count do
			(
				(getNodeByName (characterBones.items[i])).rotation = originalTransformArray[i]
			)
		)
	)
	
	-- on constrainButton pressed do
	-- (
	-- 	try
	-- 	(
	-- 		-- Creates a dummy
	-- 		newRoot = bone pos:[0,0,0]
	-- 		bipedNode = GetBipedNode 1
	-- 		newRoot.transform = bipedNode.transform
	-- 		newRoot.name = "NEW_CHARACTER_ROOT"
			
	-- 		for i = 3 to characterBones.items.count do
	-- 		(
	-- 			if (i != 7) then
	-- 			(
	-- 				CreateOrientationConstraint i true
	-- 			)
	-- 		)
			
	-- 		for i = 1 to characterBones_B.items.count do
	-- 		(
	-- 			CreateOrientationConstraint (i + 35) true
	-- 		)
			
	-- 		-- Uses a link constraint for the hips instead of putting it under a new parent.
	-- 		lc = Link_Constraint();
	-- 		(GetSkeletalNode 1 false).transform.controller = lc --assign the constraint to the transform controller of the teapot
	-- 		lc.key_mode = 0 --set the key mode to 0 (it is the default anyway)
	-- 		lc.addTarget newRoot 0
			
	-- 		--(GetSkeletalNode 1 false)
	-- 		-- Sets the new root
	-- 		--(GetSkeletalNode 1 false).parent = newRoot
			
	-- 		oC = Orientation_Constraint();
	-- 		oC.appendTarget (GetBipedNode 1) 500;
			
	-- 		newRoot.Rotation.controller = oC;
	-- 		oC.relative = true;
			
	-- 		-- Adds position constraints
	-- 		pC = Position_Constraint();
	-- 		pC.appendTarget (GetBipedNode 1) 500;
			
	-- 		newRoot.Position.controller = pC;
	-- 		pC.relative = true;
			
	-- 		-- Does the position constraitns for the legs, spine, etc.
	-- 		-- if togglePositionConstraints.checked then
	-- 		-- (
				
	-- 		-- 	CreatePositionConstraint 3 true
	-- 		-- 	CreatePositionConstraint 10 true
	-- 		-- 	CreatePositionConstraint 15 true
	-- 		-- )
	-- 	)
	-- 	catch
	-- 	(
	-- 		messagebox "Error when setting up constraint.  Bones, biped, and/or helper rig most likely missing."
	-- 	)
	-- )
	
	on saveDialogue pressed do
	(
        local tempdir = (if (maxFilePath != "") and (doesDirectoryExist maxFilePath) then \
        maxFilePath else (@"C:\Users\" + (filterString  (getdir #userscripts) @"\")[3] + @"\Desktop\"))

        f = getSaveFileName caption:"Save Skeleton" initialDir:tempdir filename:"mapping.list" types:"Mapping List (*.list)|*.list|"
        
        if f != undefined then
        (
            if doesFileExist f then
            (
                out_file = openfile (f) mode:"w"
            )
            else
            (
                out_file = createfile (f)
            )
            
            for i = 1 to characterBones.items.count do
            (
                format "%\n" characterBones.items[i] to:out_file
            )
            
            for i = 1 to characterBones_B.items.count do
            (
                format "%\n" characterBones_B.items[i] to:out_file
            )
            
            close out_file
            
            messagebox "保存成功！                       "
        )
	)
	
	on loadDialogue pressed do
	(
        pgbBar.value = 0
		lblBarValue.text = (pgbBar.value as string) + " %"
        local tempdir = (if (maxFilePath != "") and (doesDirectoryExist maxFilePath) then maxFilePath else (@"C:\Users\" + (filterString  (getdir #userscripts) @"\")[3] + @"\Desktop\"))

		f = getOpenFileName caption:"Open A Test File:" filename:tempdir types:"Mapping List (*.list)|*.list|"
		
		if f != undefined then
		(
			fS = openFile f mode:"r"
			i = 1
			
			while (eof fS) == false do
			(
				newValue = readLine fS;
				-- print newValue
				
				if (i <= 35) then
				(
					local temp_array = characterBones.items;
					temp_array[i] = newValue;
					characterBones.items = temp_array;
				)
				else if (i <= 67) then
				(
					local temp_array = characterBones_B.items;
					temp_array[i-35] = newValue;
					characterBones_B.items = temp_array;
				)
				i += 1;
			)
			
			close fS
			
			messagebox "加载成功！                       "
		)
	)
	
	-- on toggleBipedMode changed theState do
	-- (
	-- 	local bip = (GetBipedNode 1);
	-- 	if bip != undefined then
	-- 	(
	-- 		bip.transform.controller.figureMode = theState
	-- 	)
	-- )
	
	on bipedBones selected nameIndex do
	(
		-- print (nameIndex)
		-- if $ != undefined and (selection as array).count == 1 then
		-- (
		-- 	local temp_array = characterBones.items;
		-- 	temp_array[nameIndex] = $.name
		-- 	characterBones.items = temp_array;
		-- )
		-- else (messagebox "只能填入一个有效骨骼节点!                                              ")
		try(select (GetSkeletalNode nameIndex false))catch()
	)
	
	on characterBones selected nameIndex do
	(
		print (nameIndex)
		if $ != undefined and (selection as array).count == 1 then
		(
			local temp_array = characterBones.items;
			temp_array[nameIndex] = $.name
			characterBones.items = temp_array;
		)
		else (messagebox "只能填入一个有效骨骼节点!                                              ")
	)
	
	on bipedBones rightclick nameIndex do
	(
		local temp_array = characterBones.items;
		temp_array[nameIndex] = "~undefined~";
		characterBones.items = temp_array;
	)
	
	on characterBones rightclick nameIndex do
	(
		local temp_array = characterBones.items;
		temp_array[nameIndex] = "~undefined~";
		characterBones.items = temp_array;
	)
	
-- ALTA
	
	on bipedBones_B selected nameIndex do
	(
		-- print (nameIndex)
		-- if $ != undefined and (selection as array).count == 1 then
		-- (
		-- 	local temp_array = characterBones_B.items;
		-- 	temp_array[nameIndex] = $.name
		-- 	characterBones_B.items = temp_array;
		-- )
		-- else (messagebox "只能填入一个有效骨骼节点!                                              ")
		try(select (GetSkeletalNode (nameIndex + 35) false))catch()
	)
	
	on characterBones_B selected nameIndex do
	(
		print (nameIndex)
		if $ != undefined and (selection as array).count == 1 then
		(
			local temp_array = characterBones_B.items;
			temp_array[nameIndex] = $.name
			characterBones_B.items = temp_array;
		)
		else (messagebox "只能填入一个有效骨骼节点!                                              ")
	)
	
	on bipedBones_B rightclick nameIndex do
	(
		local temp_array = characterBones_B.items;
		temp_array[nameIndex] = "~undefined~";
		characterBones_B.items = temp_array;
	)
	
	on characterBones_B rightclick nameIndex do
	(
		local temp_array = characterBones_B.items;
		temp_array[nameIndex] = "~undefined~";
		characterBones_B.items = temp_array;
	)
	
	------------------------------------------
	
	-- on quickDuplicate pressed do
	-- (
	-- 	if $ != undefined then
	-- 	(
	-- 		local vec = $.pos - $.parent.pos;
	-- 		local pos = $.pos + (normalize vec) * (length vec);
	-- 		in $ nB = bone pos:pos;
	-- 		nB.name = $.name + " nub";
	-- 		select nB
	-- 	)
	-- )
	
	on validateButton pressed do
	(
		mappingCheckState = true
		for i = 1 to characterBones.items.count do
		(
			local checkedNode = GetSkeletalNode i false
			if (checkedNode == undefined) then
			(
				if (i != 5) and (i != 7) then
				(
					messagebox ("缺失 " + (i as string) + ":  " + bipedBones.items[i] + "                  ");
					mappingCheckState = false
					exit
				)
			)
		)
		
		for i = 1 to characterBones_B.items.count do
		(
			local checkedNode = GetSkeletalNode (i+35) false
			if (checkedNode == undefined) then
			(
				messagebox ("缺失 " + (i as string) + ":  " + bipedBones_B.items[i] + "                   ");
				mappingCheckState = false
				exit
			)
		)
		
		if (mappingCheckState) then
		(
			messagebox ("骨骼映射完整，请继续！                 ");
		)
		else
		(
			messagebox ("存在未指定的映射骨骼！\r\n\r\n修改请选中骨骼，点击上面列表对应节点！                ");
		)
	)
	
	global SetupNormalChildFN
	fn SetupNormalChildFN nubItem nubIndex isToe = 
	(
		try
		(
			print ("Setting up " + (nubItem.name) + " at " + (nubIndex as string))
			
			local skeletalItem = GetSkeletalNode nubIndex false findCorrect:false;
			if skeletalItem == undefined then
			(
				skeletalItem = GetSkeletalNode (nubIndex-1) false findCorrect:false;
				if skeletalItem == undefined then
				(
					print ("Skeletal item at " + ((nubIndex-1) as string) + " is missing.")
				)
				else
				(
					print "Nub parent found"
					
					local vec =  skeletalItem.pos - skeletalItem.parent.pos;
					local pos = skeletalItem.pos + (normalize vec) * (length vec);
					if isToe == true then
					(
						pos.z = skeletalItem.pos.z;
					)
					nubItem.pos = pos;
					
					if nubIndex <= 35 then
					(
						local temp_array = characterBones.items;
						temp_array[nubIndex] = nubItem.name
						characterBones.items = temp_array;
					)
					else
					(
						local temp_array = characterBones_B.items;
						temp_array[nubIndex-35] = nubItem.name
						characterBones_B.items = temp_array;
					)
				)
			)
			else
			(
				print "Nub found"
				nubItem.transform = skeletalItem.transform
			)
		)
		catch
		(
			format "*** % ***\n" (getCurrentException())
		)
	)

	fn fnCopyChildSubBone boneFBXRoot =
	(
		hips = (GetSkeletalNode 1 false)
		tempRM = (if matchpattern hips.name pattern:"NewHip_*" then hips.parent.parent else hips.parent)
		if boneFBXRoot == tempRM then 
		(
			for c in boneFBXRoot.children do
			(
				fnCopyChildSubBone c
			)
		)
		else 
		(
			if (finditem rolBsRetarget.characterBones.items boneFBXRoot.name == 0) and \
			(finditem rolBsRetarget.characterBones_B.items boneFBXRoot.name == 0) then 
			(
				case of
				(
					((finditem rolBsRetarget.characterBones.items ("NewHip_" + boneFBXRoot.name)) != 0):
					(
						helperRoot = GetSkeletalNode 1 true
					)
					((finditem rolBsRetarget.characterBones.items ("NewPelvis_" + boneFBXRoot.name)) != 0):
					(
						helperRoot = GetSkeletalNode 2 true
					)
					(boneFBXRoot.parent == tempRM):
					(
						helperRoot = (getnodebyname "RTHelper_Root")
					)
					((finditem rolBsRetarget.characterBones.items boneFBXRoot.parent.name) != 0):
					(
						helperRoot = (GetSkeletalNode (finditem rolBsRetarget.characterBones.items boneFBXRoot.parent.name) true)
					)
					((finditem rolBsRetarget.characterBones_B.items boneFBXRoot.parent.name) != 0):
					(
						helperRoot = (GetSkeletalNode ((finditem rolBsRetarget.characterBones_B.items boneFBXRoot.parent.name) + 35) true)
					)
					default:
					(helperRoot = (getnodebyname ("RTHelper_" + boneFBXRoot.parent.name)))
				) 
				tempCopyBone = (copy boneFBXRoot)
				tempCopyBone.name = boneFBXRoot.name
				strTempName = tempCopyBone.name
				tempCopyBone.name = "RTHelper_" + strTempName
				tempCopyBone.parent = helperRoot
				lc = Link_Constraint();
				tempCopyBone.transform.controller = lc
				lc.key_mode = 0
				lc.addTarget boneFBXRoot 0
				tempCopyBone.transform = boneFBXRoot.transform
				fnFixSize tempCopyBone
			)
			if boneFBXRoot.children != 0 then 
			(
				for c in boneFBXRoot.children do
				(
					fnCopyChildSubBone c
				)
			)
		)
	)

	fn fnCopySubBones =
	(
		boneFBXRoot = (GetSkeletalNode 1 false)
		boneAllRoot = (if matchpattern boneFBXRoot.name pattern:"NewHip_*" then boneFBXRoot.parent.parent else boneFBXRoot.parent)
		if boneAllRoot != undefined then 
		(
			fnCopyChildSubBone boneAllRoot
		)
		else (fnCopyChildSubBone boneFBXRoot)
	)

	fn fnCleanRootCurve x:false y:false z:false =
	(
		local boneHips = (rolBsRetarget.GetBipedNode 1)
		if boneHips == undefined then
		(
			messagebox "没有找到 Biped 质心骨骼！                          "
			return undefined
		)
		local boneRoot = boneHips.parent
		if boneRoot == undefined then
		(
			messagebox "没有找到 Root 骨骼！                          "
			return undefined
		)
		local hipsPosList = #()

		
		for t = (animationRange.start) to (animationRange.end) do
		(
			at time t with animate on 
			(
				append hipsPosList (in coordsys world Biped.getTransform boneHips #pos)
			)  
		)
		biped.createLayer boneHips.controller 1 "layerRootMotionClean"
		biped.setcurrentlayer boneHips.controller 1

		for t = (animationRange.start) to (animationRange.end) do
		(
			slidertime = t
			with animate on
			(
				if x then
				(
					boneRoot.controller.position.x = 0
				)
				if y then
				(
					boneRoot.controller.position.y = 0
				)
				if z then
				(
					boneRoot.controller.position.z = 0
				)
			)
		)

		local f = 1
		for t = (animationRange.start) to (animationRange.end) do
		(
			slidertime = t
			with animate on
			(
				-- Pos
				local hipsPos = hipsPosList[f]
				in coordsys world Biped.setTransform boneHips #pos hipsPos true
				f += 1
			)
		)
		biped.collapseAtLayer boneHips.controller 0
	)

	on tabBsADT Selected itm do
	(
		arrID = (itm.TabPageIndex + 1)
		if LastSubRollout != arrID do --避免点击重复
		(
			fnChangeToolsVisble arrID
		) 
	)

	on spnObjSize changed val do
	(
		for b in selection where classof b == BoneGeometry or classof b == dummy or classof b == point do
		(
			fnJudgeSizeType b val
		)
	)

	on btnResetSize pressed do 
	(
		spnObjSize.value = 5
		for b in selection where classof b == BoneGeometry or classof b == dummy or classof b == point do
		(
			fnJudgeSizeType b 5
		)
	)
	
    on alignBipedToHelper pressed do
	(
		if mappingCheckState then
		(
			pgbBar.value = 0
			lblBarValue.text = (pgbBar.value as string) + " %"
			max Create mode
			---断开质心防止旋转出问题，后面连上
			hips = (GetSkeletalNode 1 false)
			rootMotionBone = (if matchpattern hips.name pattern:"NewHip_*" then hips.parent.parent else hips.parent)
			tempHips = hips.parent
			hips.parent = undefined

			-- 创建 Helper
			if isValidNode headNub == false then headNub = point name:"_Helper_Head Nub" wirecolor:(color 0 255 0)
	
			if isValidNode fingerNubs[1][1] == false then fingerNubs[1][1] = point name: "_Helper_Finger L Thumb 1 Nub" boxsize:[1,1,1] wirecolor:(color 255 0 0) size:0.01
			if isValidNode fingerNubs[1][2] == false then fingerNubs[1][2] = point name: "_Helper_Finger L Index 2 Nub" boxsize:[1,1,1] wirecolor:(color 255 64 0) size:0.01
			if isValidNode fingerNubs[1][3] == false  then fingerNubs[1][3] = point  name: "_Helper_Finger L Mid 3 Nub" boxsize:[1,1,1] wirecolor:(color 255 128 0) size:0.01
			if isValidNode fingerNubs[1][4] == false  then fingerNubs[1][4] = point  name: "_Helper_Finger L Ring 4 Nub" boxsize:[1,1,1] wirecolor:(color 255 192 0) size:0.01
			if isValidNode fingerNubs[1][5] == false  then fingerNubs[1][5] = point  name: "_Helper_Finger L Pinky 5 Nub" boxsize:[1,1,1] wirecolor:(color 255 255 0) size:0.01
			
			if isValidNode fingerNubs[2][1] == false  then fingerNubs[2][1] = point  name: "_Helper_Finger R Thumb 1 Nub" boxsize:[1,1,1] wirecolor:(color 0 0 255) size:0.01
			if isValidNode fingerNubs[2][2] == false  then fingerNubs[2][2] = point  name: "_Helper_Finger R Index 2 Nub" boxsize:[1,1,1] wirecolor:(color 0 64 255) size:0.01
			if isValidNode fingerNubs[2][3] == false  then fingerNubs[2][3] = point  name: "_Helper_Finger R Mid 3 Nub" boxsize:[1,1,1] wirecolor:(color 0 128 255) size:0.01
			if isValidNode fingerNubs[2][4] == false  then fingerNubs[2][4] = point  name: "_Helper_Finger R Ring 4 Nub" boxsize:[1,1,1] wirecolor:(color 0 192 255) size:0.01
			if isValidNode fingerNubs[2][5] == false  then fingerNubs[2][5] = point  name: "_Helper_Finger R Pinky 5 Nub" boxsize:[1,1,1] wirecolor:(color 0 255 255) size:0.01
			
			if isValidNode toeNubs[1] == false  then toeNubs[1] = point  name: "_Helper_Toe L Nub" boxsize:[1,1,1] wirecolor:(color 255 64 128)	size:0.01
			if isValidNode toeNubs[2] == false  then toeNubs[2] = point  name: "_Helper_Toe R Nub" boxsize:[1,1,1] wirecolor:(color 64 128 255) size:0.01
	
			if isValidNode footHelpers[1] == false  then footHelpers[1] = point  name: "_Helper_Foot Helper L" boxsize:[2,4,2] wirecolor:(color 255 128 255) size:0.01
			if isValidNode footHelpers[2] == false  then footHelpers[2] = point  name: "_Helper_Foot Helper R" boxsize:[2,4,2] wirecolor:(color 128 255 255) size:0.01
	
			--设置 Helper
			SetupNormalChildFN headNub 9 false;
			
			SetupNormalChildFN fingerNubs[1][1] 27 false;
			SetupNormalChildFN fingerNubs[1][2] 31 false;
			SetupNormalChildFN fingerNubs[1][3] 35 false;
			SetupNormalChildFN fingerNubs[1][4] 39 false;
			SetupNormalChildFN fingerNubs[1][5] 43 false;
			
			SetupNormalChildFN fingerNubs[2][1] 51 false;
			SetupNormalChildFN fingerNubs[2][2] 55 false;
			SetupNormalChildFN fingerNubs[2][3] 59 false;
			SetupNormalChildFN fingerNubs[2][4] 63 false;
			SetupNormalChildFN fingerNubs[2][5] 67 false;
			
			-- Sets up the toes?
			
			SetupNormalChildFN toeNubs[1] 14 true;
			SetupNormalChildFN toeNubs[2] 19 true;
			
			SetupNormalChildFN footHelpers[1] 12 false;
			SetupNormalChildFN footHelpers[2] 17 false;
	
			tempArr = (fingerNubs + toeNubs + footHelpers)
			for i in tempArr do 
			(
				for j in i where isvalidnode j do j.constantscreensize = false
			)
			headNub.constantscreensize = false

			--创建 Biped
			try
			(
				--print (getNodeByName (prefix + characterBones.items[9]).transform.pos.z)
				--print 
				headPos = GetBonePos 9
				rootPos = 0.5 * ((GetBonePos 10) + (GetBonePos 15))
				legLen = length ((GetBonePos 10) - (GetBonePos 15))
				ang = -90
				print (height)
				print (ang)
				
				numNeckLink = if (not (fnIsIgnoreBone 7)) then 2 else 1
				numSpineLink = if (not (fnIsIgnoreBone 5)) then 3 else 2

				newBiped = biped.createNew headPos.z ang [0,0,headPos.z] neckLinks:numNeckLink spineLinks:numSpineLink fingers:5 fingerLinks:3 toes:1 toeLinks:1 trianglePelvis:false triangleNeck:true
				newBiped.transform.controller.figureMode = true;
				newBiped.controller.rootname = bipedRootName
				(GetBipedNode 1).controller.bodytype = 3
				bipedRootName = newBiped.name;

				rotate (GetBipedNode 45) (angleaxis 85 [0,1,0])
				rotate (GetBipedNode 21) (angleaxis -85 [0,1,0])
				
				-- STEP 1:  Move and scale the hips
				biped.setTransform newBiped.transform.controller.rootNode #pos rootPos false
				biped.setTransform (GetBipedNode 2) #scale [legLen, legLen, legLen] false
				
				-- Step 2:  Move the spine and scale from the first spine to the head
				neckPos = GetBonePos 6
				waistPos = GetBonePos 3
				biped.setTransform (GetBipedNode 3) #pos [neckPos.x, neckPos.y, waistPos.z] false
				AdjustBipedScale 3
				--RotateBone 3 (getNodeByName(n + " Spine")) 0
					
				AdjustBipedScale 4
				--RotateBone 4 (getNodeByName(n + " Spine1")) 0
					
				if (not (fnIsIgnoreBone 5)) then (AdjustBipedScale 5)
				--RotateBone 5 (getNodeByName(n + " Spine2")) 0
				
				AdjustBipedScale 6
				--RotateBone 6 (getNodeByName(n + " Neck")) 0
					
				if (not (fnIsIgnoreBone 7)) then (AdjustBipedScale 7)
				--RotateBone 7 (getNodeByName(n + " Neck1")) 0
					
				AdjustBipedScale 8
				--RotateBone 8 (getNodeByName(n + " Head")) 0		
				
				biped.setTransform (GetBipedNode 6) #pos neckPos false
				--biped.setTransform (GetBipedNode 8) #pos (GetBonePos 8) false
				
				-- Step 3:  Scale the legs
				-- LEFT
				AdjustBipedScale 10
				AdjustBipedScale 11
				
				-- RIGHT
				AdjustBipedScale 15
				AdjustBipedScale 16
				
				-- STEP 4:  Scale the Feet
				-- LEFT FOOT SCALE:  0.8 is (1 - biped attachment)
				footVector = (GetBonePos 12) - (GetBonePos 13)
				footVector2 = (GetBonePos 14) - (GetBonePos 12)
				biped.setTransform (GetBipedNode 12) #scale [abs footVector2.z, abs footVector.y / 0.8, abs (footVector.y + footVector.z) * 0.5] false		
				AdjustBipedScale 13 isToe:true
	
				-- RIGHT FOOT SCALE			
				footVector = (GetBonePos 17) - (GetBonePos 18)
				footVector2 = (GetBonePos 19) - (GetBonePos 17)
				biped.setTransform (GetBipedNode 17) #scale [abs footVector2.z, abs footVector.y / 0.8, abs (footVector.y + footVector.z) * 0.5] false		
				AdjustBipedScale 18 isToe:true
					
				-- Step 5:  Scale the arms and fingers.
				-- LEFT ARM
				--biped.setTransform (getNodeByName(n + " L Clavicle")) #pos (GetBonePos 20) false
				AdjustBipedScale 20
				AdjustBipedScale 21
				AdjustBipedScale 22
				AdjustBipedScale 23 isHand:true
				
				-- RIGHT ARM
				--biped.setTransform (getNodeByName(n + " R Clavicle")) #pos (GetBonePos 44) false
				AdjustBipedScale 44
				AdjustBipedScale 45
				AdjustBipedScale 46
				AdjustBipedScale 47 isHand:true
					
				-- -- LEFT FINGERS
				AdjustBipedScale 24
				AdjustBipedScale 25
				AdjustBipedScale 26
				
				AdjustBipedScale 28
				AdjustBipedScale 29
				AdjustBipedScale 30
					
				AdjustBipedScale 32
				AdjustBipedScale 33
				AdjustBipedScale 34
					
				AdjustBipedScale 36
				AdjustBipedScale 37
				AdjustBipedScale 38
					
				AdjustBipedScale 40
				AdjustBipedScale 41
				AdjustBipedScale 42
					
				-- -- RIGHT FINGERS
				AdjustBipedScale 48
				AdjustBipedScale 49
				AdjustBipedScale 50
				
				AdjustBipedScale 52
				AdjustBipedScale 53
				AdjustBipedScale 54
					
				AdjustBipedScale 56
				AdjustBipedScale 57
				AdjustBipedScale 58
					
				AdjustBipedScale 60
				AdjustBipedScale 61
				AdjustBipedScale 62
					
				AdjustBipedScale 64
				AdjustBipedScale 65
				AdjustBipedScale 66

				newBiped.controller.trianglePelvis = true
				newBiped.controller.trianglePelvis = false
				newBiped.controller.triangleNeck = false
				newBiped.controller.triangleNeck = true
			)
			catch
			(
				messagebox "创建 Biped 时出错，可能有骨骼映射缺失。                               "
			)

			pgbBar.value = 5
			lblBarValue.text = (pgbBar.value as string) + " %"
			--创建对齐辅助骨骼
			local bipOne = (GetBipedNode 1)
			if bipOne == undefined then
			(
				messagebox "没有找到 Biped 骨骼！                          "
				return undefined
			)
			
			-- Creates the faux bones
			-- Creates just a simple root bone
			rootBone = point pos:(GetBipedNode 1).transform.position -- rotation:(GetBonePos 1).transform.rotation
			rootBone.constantscreensize = false
			-- rootBone.box = true
			rootBone.name      = ("RTHelper_" + (GetBipedNode 1).name)
			rootBone.size      = 0.01
			rootBone.transform = (GetBipedNode 1).transform
			bipedRetargetRM    = undefined
			boneRetargetRM     = undefined
			if rootMotionBone != undefined then
			(
				boneRetargetRM = point name:"RTHelper_Root"
				-- boneRetargetRM.size               = 0.01
				boneRetargetRM.constantscreensize = false
				-- boneRetargetRM.box = true
				boneRetargetRM.transform = rootMotionBone.transform
				if rolBsRetarget.ddlUpAxis.selection == 1 then (in coordsys gimbal boneRetargetRM.rotation = (eulerAngles 90 0 0))
				else (in coordsys gimbal boneRetargetRM.rotation = (eulerAngles 0 0 0))
				local pC = Position_Constraint()
				pC.appendTarget rootMotionBone 100
				boneRetargetRM.Position.controller = pC
				pC.relative = true
				
				local oC = Orientation_Constraint()
				oC.appendTarget rootMotionBone 100
				boneRetargetRM.Rotation.controller = oC
				oC.relative = true

				bipedRetargetRM = point name:"Root"
				-- bipedRetargetRM.size = 0.01
				bipedRetargetRM.transform = boneRetargetRM.transform
				if rolBsRetarget.ddlUpAxis.selection == 1 then (in coordsys gimbal bipedRetargetRM.rotation = (eulerAngles 90 0 0))
				else (in coordsys gimbal bipedRetargetRM.rotation = (eulerAngles 0 0 0))
				bipedRetargetRM.wirecolor = red
				bipedRetargetRM.constantscreensize = false
				bipedRetargetRM.axistripod = on
				-- fnFixSize bipedRetargetRM
			)
			
			--newBone = CreateFauxBone rootBundefined 1 2
			-- Creates the spine
			pelvisBone = CreateFauxBone rootBone  2 3 [0,-1,0]
			newBone = CreateFauxBone pelvisBone 3 4 [0,-1,0]
			if (not (fnIsIgnoreBone 5)) then 
			(
				newBone = CreateFauxBone newBone 4 5 [0,-1,0]
				topSpine = CreateFauxBone newBone 5 6 [0,-1,0]
			)
			else (topSpine = CreateFauxBone newBone 4 6 [0,-1,0])
			if (not (fnIsIgnoreBone 7)) then 
			(
				newBone = CreateFauxBone topSpine 6 7 [0,-1,0]
				newBone = CreateFauxBone newBone 7 8 [0,-1,0]
			)
			else (newBone = CreateFauxBone topSpine 6 8 [0,-1,0])
			newBone = CreateFauxBone newBone 8 9 [0,-1,0]
			newBone = CreateFauxBone newBone 9 0 [0,-1,0]
			
			-- Creates the legs
			newBone = CreateFauxBone pelvisBone 10 11 [0,-1,0]
			newBone = CreateFauxBone newBone 11 12 [0,-1,0]
			newBone = CreateFauxBone newBone 12 13 [0,-1,0] isFoot:true
			newBone = CreateFauxBone newBone 13 14 [0,0,1] isToes:true
			newBone = CreateFauxBone newBone 14 0 [0,0,1]
			
			-- Creates the legs
			newBone = CreateFauxBone pelvisBone 15 16 [0,-1,0]
			newBone = CreateFauxBone newBone 16 17 [0,-1,0]
			newBone = CreateFauxBone newBone 17 18 [0,-1,0] isFoot:true
			newBone = CreateFauxBone newBone 18 19 [0,0,1] isToes:true
			newBone = CreateFauxBone newBone 19 0 [0,0,1]
			
			
			-- Create the arms
			newBone = CreateFauxBone topSpine 20 21 [0,1,0]
			newBone = CreateFauxBone newBone 21 22 [0,1,0]
			newBone = CreateFauxBone newBone 22 23 [0,1,0]
			lHandBone = CreateFauxBone newBone 23 32 [0,0,-1] isHand:true
			
			newBone = CreateFauxBone topSpine 44 45 [0,1,0]
			newBone = CreateFauxBone newBone 45 46 [0,1,0]
			newBone = CreateFauxBone newBone 46 47 [0,1,0]
			rHandBone = CreateFauxBone newBone 47 56 [0,0,-1] isHand:true
			
			pgbBar.value = 10
			lblBarValue.text = (pgbBar.value as string) + " %"
			-- Create the fingers
			fn QuickFingers sI startingBone isThumbs =
			(
				local axis = [0,0,-1]
				--if isThumbs == true then
				--(
				--	axis = [0,1,0]
				--)
				local tBone = CreateFauxBone startingBone sI (sI+1) axis isHand:true
				tBone = CreateFauxBone tBone (sI+1) (sI+2) 	axis isHand:true
				tBone = CreateFauxBone tBone (sI+2) (sI+3) axis isHand:true
				tBone = CreateFauxBone tBone (sI+3) 0 axis isHand:true
			)
			
			QuickFingers 24 lHandBone true
			QuickFingers 28 lHandBone false
			QuickFingers 32 lHandBone false
			QuickFingers 36 lHandBone false
			QuickFingers 40 lHandBone false
			
			QuickFingers 48 rHandBone true
			QuickFingers 52 rHandBone false
			QuickFingers 56 rHandBone false
			QuickFingers 60 rHandBone false
			QuickFingers 64 rHandBone false
			
			-- Creates orientation constraints for the original rig to the faux rig.
			for i = 1 to characterBones.items.count do
			(
				case i of 
				(
					5:
					(
						if (fnIsIgnoreBone 5) then (print "ignore")
						else (CreateOrientationConstraint 5 false)
					)
					7:
					(
						if (fnIsIgnoreBone 7) then (print "ignore")
						else (CreateOrientationConstraint 7 false)
					)
					9:(print "ignore nub")
					14:(print "ignore nub")
					19:(print "ignore nub")
					27:(print "ignore nub")
					31:(print "ignore nub")
					35:(print "ignore nub")
					-- 39:(print "ignore")
					-- 43:(print "ignore")
					-- 51:(print "ignore")
					-- 55:(print "ignore")
					-- 59:(print "ignore")
					-- 63:(print "ignore")
					-- 67:(print "ignore")
					default:(CreateOrientationConstraint i false)
				)
			)
			
			for i = 1 to characterBones_B.items.count do
			(
				case (i+35) of 
				(
					-- 7:(print "ignore")
					-- 9:(print "ignore")
					-- 14:(print "ignore")
					-- 19:(print "ignore")
					-- 27:(print "ignore")
					-- 31:(print "ignore")
					-- 35:(print "ignore")
					39:(print "ignore nub")
					43:(print "ignore nub")
					51:(print "ignore nub")
					55:(print "ignore nub")
					59:(print "ignore nub")
					63:(print "ignore nub")
					67:(print "ignore nub")
					default:(CreateOrientationConstraint (i+35) false)
				)
			)
			
			CreatePositionConstraint 1 false
			CreatePositionConstraint 2 false
	
			pgbBar.value = 25
			lblBarValue.text = (pgbBar.value as string) + " %"
			--对齐 Biped
			fnAlignBipedToHelper()
			pgbBar.value = 55
			lblBarValue.text = (pgbBar.value as string) + " %"
			(GetBipedNode 1).transform.controller.figureMode = false
			fnAlignBipedToHelper()
			pgbBar.value = 70
			lblBarValue.text = (pgbBar.value as string) + " %"
			biped.createCopyCollection (GetBipedNode 1).controller "tempRetargetBipedPose"
			copycol= biped.getcopycollection (GetBipedNode 1).controller 1
			icpmxbipcopy = biped.copybippose (GetBipedNode 1).controller copycol #snapview
			-- strBipedPoseCollection = (biped.copyPosture (GetBipedNode 1).controller #pose true true true)
			(GetBipedNode 1).transform.controller.figureMode = true
			biped.pastebippose (GetBipedNode 1).controller icpmxbipcopy false #pstdefault true true true false
			-- biped.pastePosture (GetBipedNode 1).controller #pose false strBipedPoseCollection
			-- AlignBipToFaux 21
			-- AlignBipToFaux 23
			-- AlignBipToFaux 45
			-- AlignBipToFaux 47
			fnAlignBipedFingersToHelper ()
			-- (GetBipedNode 1).transform.controller.figureMode = false
			-- toggleBipedMode.state = false
			biped.deleteCopyCollection (GetBipedNode 1).controller (biped.numCopyCollections (GetBipedNode 1).controller)
			AlignBipToFaux 10
			AlignBipToFaux 15
			-- (GetBipedNode 21).transform.rotation = (GetSkeletalNode 21 true).rotation
			-- (GetBipedNode 23).transform.rotation = (GetSkeletalNode 23 true).rotation
			-- (GetBipedNode 45).transform.rotation = (GetSkeletalNode 45 true).rotation
			-- (GetBipedNode 47).transform.rotation = (GetSkeletalNode 47 true).rotation
			pgbBar.value = 90
			lblBarValue.text = (pgbBar.value as string) + " %"
			-- 清除 Helper
			if isValidNode headNub then
			(
				delete headNub;
				headNub = undefined;
			)
			
			for i = 1 to 5 do
			(
				if isValidNode fingerNubs[1][i] then
				(
					delete fingerNubs[1][i]
					fingerNubs[1][i] = undefined
				)
				
				if isValidNode fingerNubs[2][i] then
				(
					delete fingerNubs[2][i]
					fingerNubs[2][i] = undefined
				)
			)
			
			if isValidNode toeNubs[1] then
			(
				delete toeNubs[1]
				toeNubs[1] = undefined;
			)
			
			if isValidNode toeNubs[2] then
			(
				delete toeNubs[2]
				toeNubs[2] = undefined;
			)
			
			if isValidNode footHelpers[1] then
			(
				delete footHelpers[1]
				footHelpers[1] = undefined;
			)
			
			if isValidNode footHelpers[2] then
			(
				delete footHelpers[2]
				footHelpers[2] = undefined;
			)

			hips.parent = tempHips
			(GetBipedNode 1).parent = bipedRetargetRM
			rootBone.parent = boneRetargetRM

			if chkCopySubs.state then fnCopySubBones()
			else 
			(
				if matchpattern (GetSkeletalNode 1 false).name pattern:"NewHip_*" and matchpattern (GetSkeletalNode 2 false).name pattern:"NewPelvis_*" then 
				(
					tarHipBone = getnodebyname (substituteString (GetSkeletalNode 1 false).name "NewHip_" "")
					tempHipBone = (copy tarHipBone)
					tempHipBone.name = tarHipBone.name
					strTempName = tempHipBone.name
					tempHipBone.name = "RTHelper_" + strTempName
					tempHipBone.parent = (GetSkeletalNode 1 true)
					lc = Link_Constraint();
					tempHipBone.transform.controller = lc
					lc.key_mode = 0
					lc.addTarget tarHipBone 0
					tempHipBone.transform = tarHipBone.transform

					tarPelvisBone = getnodebyname (substituteString (GetSkeletalNode 2 false).name "NewPelvis_" "")
					tempPelvisBone = (copy tarPelvisBone)
					tempPelvisBone.name = tarPelvisBone.name
					strTempName = tempPelvisBone.name
					tempPelvisBone.name = "RTHelper_" + strTempName
					tempPelvisBone.parent = (GetSkeletalNode 2 true)
					lc = Link_Constraint();
					tempPelvisBone.transform.controller = lc
					lc.key_mode = 0
					lc.addTarget tarPelvisBone 0
					tempPelvisBone.transform = tarPelvisBone.transform
				)
			)
			pgbBar.value = 100
			lblBarValue.text = (pgbBar.value as string) + " %"
			messageBox "重定向 Biped 创建成功！\r\n\r\n如肩膀匹配不高，\r\n\r\n建议微调两边肩膀手臂和手，\r\n\r\n再点击重新对齐手指骨骼。                         "
		)
		else (messageBox "请先验证并检查映射列表是否完整！                                       " title:"BsRetargetTools")
	)

    on reAlignFingers pressed do
    (
		if mappingCheckState then
		(
			try(fnAlignBipedFingersToHelper ())
			catch(messageBox "重新对齐手指成功！                            ")
		)
		else (messageBox "请先验证并检查映射列表是否完整！                                       " title:"BsRetargetTools")
    )

    -- on btnExportTPose pressed do
	-- (
    --     if (GetBipedNode 1) != undefined then
    --     (
    --         oldFigureMode = ((GetBipedNode 1).transform.controller.figureMode)
    --         (GetBipedNode 1).transform.controller.figureMode = true
    --         biped.saveBipFileDlg (GetBipedNode 1).controller
    --         (GetBipedNode 1).transform.controller.figureMode = oldFigureMode
    --     )
    --     else (messageBox "没有找到 Biped 骨骼！                                ")
	-- )

    -- on ckbExportFBXTools changed state do
    -- (
    --     bipedBones.visible       = (not state)
    --     characterBones.visible   = (not state)
    --     bipedBones_B.visible     = (not state)
    --     characterBones_B.visible = (not state)

    --     edtAnimFbxPath.visible       = state
    --     btnLoadAnimPath.visible      = state
    --     btnRefreshAnimFiles.visible  = state
    --     btnOpenCurrentPath.visible   = state
    --     btnRefreshFolder.visible     = state
    --     ltbFilesList.visible         = state
    --     btnOutputPath.visible        = state
    --     edtOutputPath.visible        = state
    --     edtMappingFile.visible       = state
    --     btnOpedOutputPath.visible    = state
    --     btnSelectMappingFile.visible = state
    --     btnOpenMappingFile.visible   = state
    --     btnRetargetSelected.visible  = state
    --     btnRetargettAll.visible      = state
    --     btnSelectSkinFile.visible    = state
    --     edtSkinFile.visible          = state
    --     btnOpenSkinFile.visible      = state
    --     btnCount.visible             = state
    --     chkRecoverExport.visible     = state
    --     btnSpecial.visible           = state
    --     btnTemp.visible              = state
    --     -- if state then (fnRefreshDir maxFilePath)
    -- )

	on btnCount pressed do 
	(
		if (doesDirectoryExist edtAnimFbxPath.text) then
		(
			shellLaunch edtAnimFbxPath.text ""
		)
		else (messageBox "刷新动画列表，目录不存在！                             " title:"BsRetargetTools")
	)

	on btnSpecial pressed do 
	(
		popupMenu menuBsRetarget pos:(mouse.screenpos + [15,0])
	)

    on btnOpenCurrentPath pressed do
    (
        if (doesDirectoryExist edtAnimFbxPath.text) then
		(
			shellLaunch edtAnimFbxPath.text ""
		)
		else (messageBox "目录不存在！                        ")
    )

	on btnOpedOutputPath pressed do
    (
        if (doesDirectoryExist edtOutputPath.text) then
		(
			shellLaunch edtOutputPath.text ""
		)
		else (messageBox "目录不存在！                        ")
    )

	on btnOpenMappingFile pressed do
    (
		if (doesFileExist edtMappingFile.text) then
		(
			if CheckForSave() then (loadMaxFile edtMappingFile.text useFileUnits:true)
		)
		else (messageBox "没有找到映射文件！                            ")
    )

	on btnOpenSkinFile pressed do
    (
		if (doesFileExist edtSkinFile.text) then
		(
			if CheckForSave() then (loadMaxFile edtSkinFile.text useFileUnits:true)
		)
		else (messageBox "没有找到 Skin 文件！                          ")
    )

    on btnLoadAnimPath pressed do
    (
        local dirOpened = getSavePath caption:"请选择动画 FBX 文件路径:" initialDir:(maxFilePath + "AniFBX\\")

        fnRefreshDir dirOpened
    )

	on btnRefreshAnimFiles pressed do
	(
		fnRefreshDir edtAnimFbxPath.text
	)

	on btnOutputPath pressed do
    (
        local dirOpened = getSavePath caption:"请选择导出重定向 FBX 路径:" initialDir:edtAnimFbxPath.text

        if (dirOpened != undefined) then (edtOutputPath.text = dirOpened + "\\")
    )

	on btnSelectMappingFile pressed do
    (
        local pathFile = getOpenFileName caption:"请选择映射文件" types:"MAX(*.max)|*.max|"

		if (pathFile != undefined) then (edtMappingFile.text = pathFile)
    )

	on btnSelectSkinFile pressed do
    (
        local pathFile = getOpenFileName caption:"请选择新 Skin 文件" types:"MAX(*.max)|*.max|"

		if (pathFile != undefined) then (edtSkinFile.text = pathFile)
    )

    on btnRefreshFolder pressed do
    (
		edtOutputPath.text = (maxFilePath + "ReOutput\\")
		edtMappingFile.text = (maxFilePath + maxfilename)
		edtSkinFile.text = (maxFilePath + "Skin.max")
		fnRefreshDir (maxFilePath + "AniFBX\\")
    )

	on btnAutoMapping pressed do
	(
		for i in (objects as array) do
		(
			local tarNodeName = i.name
			for j in pattBipedNames do
			(
				for k in j do 
				(
					if (matchpattern tarNodeName pattern:k ignoreCase:true) then
					(
						tarBonesIndex = (finditem pattBipedNames j)
						-- print (tarBonesIndex as string)
						-- print (tarNodeName)
						if (tarBonesIndex <= 35) then
						(
							characterBones.items[tarBonesIndex] = tarNodeName
							temp_array = characterBones.items
							temp_array[tarBonesIndex] = tarNodeName
							characterBones.items = temp_array
						)
						else
						(
							characterBones_B.items[tarBonesIndex - 35] = tarNodeName
							temp_array2 = characterBones_B.items
							temp_array2[tarBonesIndex - 35] = tarNodeName
							characterBones_B.items = temp_array2
						)
					)
				)
			)
		)
		messagebox "根据骨骼名自动匹配完成，建议检查一遍，\r\n\r\n修改请选中骨骼，点击上面列表对应节点！                                   " beep:false
	)

	on btnRetargetSelected pressed do
	(
		if edtAnimFbxPath.text != edtOutputPath.text then
		(
			if (doesFileExist edtSkinFile.text) then
			(
				if CheckForSave() then 
				(
					fnExportReTargrtedAnim arrExportRetargetAnim ltbFilesList.selection
					-- btnCount.text = ("已重定向动画 FBX 数：1 个")
					btnCount.text = ("待批处理原始动画 FBX 数：0 个")
				)
			)
			else (print "Skin 文件不存在!                             ")
		)
		else (messageBox "导出路径不能和原动画 FBX 路径相同！                                                  ")
	)

	on btnRetargettAll pressed do 
	(
		-- escapeEnable = true

		if edtAnimFbxPath.text != edtOutputPath.text then
		(
			if (doesFileExist edtSkinFile.text) then
			(
				if CheckForSave() then 
				(
					pgbBar.color = blue
					pgbBar.value = 0
					lblBarValue.text = (pgbBar.value as string) + " %"
					for i = 1 to arrExportRetargetAnim.count where (doesFileExist arrExportRetargetAnim[i]) do 
					(
						fnExportReTargrtedAnim arrExportRetargetAnim i
						-- btnCount.text = ("已重定向动画 FBX 数：" + (i as string) + " 个")
						btnCount.text = ("待批处理原始动画 FBX 数：" + (arrExportRetargetAnim.count - i) as string + " 个")
						pgbBar.value = 100.*i/arrExportRetargetAnim.count
						lblBarValue.text = (pgbBar.value as string) + " %"
					)
					resetMaxFile #noPrompt
					messageBox ("已重定向所有动画，一共 " + (arrExportRetargetAnim.count as string) + " 个,\r\n\r\n在导出目录有相应 .max .bip 和 .FBX 文件                                                ")
				)
			)
		)
	)

	on btnBatchAll pressed do
	(
		-- if CheckForSave() then 
		-- (
			local dirOpened = maxFilePath
			local curFile = maxFilePath + maxfilename
			local pathOutPut = (dirOpened + "\\FixRoot_" + maxfilename)
			-- resetMaxFile #noPrompt
			-- loadMaxFile curFile useFileUnits:true quiet:true
			fnCleanRootCurve x:chkXAxis.state y:chkYAxis.state z:chkZAxis.state
			saveMaxFile pathOutPut saveAsVersion:((rolBsRetarget.ddlSaveVersion.selected) as integer) clearNeedSaveFlag:true quiet:true
		-- )
	)

	on rolBsRetarget open do 
	(
		local dotColor        = dotnetclass "System.Drawing.Color"
		local maxuiBgColor    = (colorman.getcolor #background) * 255
		local BsDotFont       = dotnetobject "System.Drawing.Font" "Roboto" 8

		fnInitDotTabs()
		fnChangeToolsVisble (tabBsADT.SelectedIndex + 1)

		mappingCheckState = false
		pgbBar.value = 0
		pgbBar.color = white
		lblBarValue.text = (pgbBar.value as string) + " %"
	)

	on btnQuickTools pressed do ( popupmenu menuQuickCreateNode )

	fn getSkin tempNode = if isvalidnode tempNode do
	(
		local sk
		for m in tempNode.modifiers while sk == undefined where iskindof m Skin do sk = m
		sk
	)

	fn collectSkinBones sk = 
	(
		a = for b in (refs.dependson sk) where isvalidnode b collect b
	)

	fn xchangeSkinBone sk source target = 
	(
		local result = off

		if sk == modpanel.getcurrentobject() and iskindof sk Skin do
					(
			bones = collectSkinBones sk
			if (sid = finditem bones source) > 0 do
					(
				-- if finditem bones target == 0 do
				-- (
				-- 	skinops.addbone sk target 1
				-- 	bones = collectSkinBones sk
				-- 	sid = finditem bones source
				-- )
				-- if (tid = finditem bones target) > 0 do
				-- (
					-- verts = #{1..skinops.getnumbervertices sk}
					-- skinops.selectvertices sk verts
					-- skinops.bakeselectedverts sk

					-- for v in verts do
					-- (
					-- 	bb = #()
					-- 	ww = #()
					-- 	for k=1 to skinops.getvertexweightcount sk v do
					-- 	(
					-- 		append bb (skinops.getvertexweightboneid sk v k)
					-- 		append ww (skinops.getvertexweight sk v k)
					-- 	)
					-- 	if (k = finditem bb sid) > 0 do 
					-- 	(
					-- 		bb[k] = tid
					-- 		skinops.replacevertexweights sk v tid 1.0
					-- 		skinops.setvertexweights sk v bb ww

					-- 		result = on
					-- 	)
					-- )
					skinops.removebone sk sid 
				-- )
				skinops.addbone sk target 0
				)
			)
		result
	)
	fn getTargetPair node = 
	(
		getnodebyname (substituteString node.name "ReTempNode_" "") 
	)
	fn xchangeSkin node = if (sk = getSkin node) == undefined then 0 else
	(
		select node
		max modify mode
		modpanel.setcurrentobject sk
		-- verts = #{1..skinops.getnumbervertices sk}
		-- skinops.selectvertices sk verts
		-- skinops.bakeselectedverts sk

		-- sk.always_deform = off
		-- sk.always_deform = on

		count = 0
		bones = collectSkinBones sk
		for source in bones where (target = getTargetPair source) != undefined do
		(
			if (act = xchangeSkinBone sk source target) do count += 1 
		)
		count
	)

	fn setUICheckboxState hwnd state =
	(
	/*******************************************************************************
		<DOC> toggle an UI checkbox's checked state via UI messages/notifications
		Arguments:
			<int> hwnd:			HWND of the control
			<int> state: 		checked state.  1 = check, 0 = uncheck
			<skin modifier> curObj:		The selected skin modifier (must be in modify panel)
		Return:
			<ok>  should check/uncheck the checkbox and have its change effected
	*******************************************************************************/
		local BN_CLICKED = 0 -- clicky message ID
		local BM_SETCHECK = 241 -- checkbutton toggle message ID
		local WM_COMMAND = 273 -- windows command message

		local parent = UIAccessor.getParentWindow hwnd
		local id = UIAccessor.getWindowResourceID hwnd
		windows.sendMessage hwnd BM_SETCHECK state 0
		windows.sendMessage parent WM_COMMAND ((bit.shift BN_CLICKED 16) + id) hwnd
		OK
	)


	fn confirmLoadEnvelopes removeIncomingPrefix:0 removeCurrentPrefix:0 =
	(
	/*******************************************************************************
		<DOC> Manipulate the Load Envelopes dialog via the UI Accessor.
		Arguments:
			<int> removeIncomingPrefix:		Corresponds to the "Remove Incoming Prefix" checkbox.  0 is false, 1 is true
			<int> removeCurrentPrefix:		Corresponds to the "Remove Current Prefix" checkbox.  0 is false, 1 is true
		Return:
			<bool> true (needed for DialogMonitorOps)
	*******************************************************************************/
		--local BM_SETCHECK = 241
		local hwnd = dialogMonitorOps.getWindowHandle()
		if (uiAccessor.getWindowText hwnd == "Load Envelopes") then
		(
			local children = windows.getChildrenHWND hwnd
			for child in children do
			(
				if (child[5] == "Remove Incoming Prefix") then
				(
					setUICheckboxState child[1] 0
				)
				else if (child[5] == "Remove Current Prefix") then
				(
					setUICheckboxState child[1] 0
				)
			)
			
			UIAccessor.PressButtonByName hwnd "Match by Name"
			UIAccessor.PressButtonByName hwnd "Match by Name"
			UIAccessor.PressButtonByName hwnd "Match by Name"
			forceCompleteRedraw()
			UIAccessor.PressButtonByName hwnd "OK"
			--UIAccessor.PressDefaultButton()
		)
		true
	)

	fn confTT = (confirmLoadEnvelopes removeIncomingPrefix:1 removeCurrentPrefix:1)
	fn confTF = (confirmLoadEnvelopes removeIncomingPrefix:1 removeCurrentPrefix:0)
	fn confFT = (confirmLoadEnvelopes removeIncomingPrefix:0 removeCurrentPrefix:1)
	fn confFF = (confirmLoadEnvelopes removeIncomingPrefix:0 removeCurrentPrefix:0)

	fn fnLoadEnvelope theSkin envFile removeIncomingPrefix:false removeCurrentPrefix:false =
	(
	/*******************************************************************************
		<DOC> Load an .env file.  There is no function for silently loading an .env, so this
		is a UI Accessor workaround.
		Arguments:
			<skin modifier> theSkin:		The selected skin modifier (must be in modify panel)
			<string>	envFile:					Filename of the .env file.
		Return:
			<ok>
	*******************************************************************************/
		--determine which confirmLoadEnvelopes to use
		local confirmFn = case of
		(
			(removeIncomingPrefix and removeCurrentPrefix):confTT
			(removeIncomingPrefix and not removeCurrentPrefix):confTF
			(not removeIncomingPrefix and removeCurrentPrefix):confFT
			(not removeIncomingPrefix and not removeCurrentPrefix):confFF
		)
		
		DialogMonitorOps.Enabled = true	--DialogMonitorOps.Enabled = false
		DialogMonitorOps.RegisterNotification confirmFn id:#pressSkinOK
		skinOps.LoadEnvelope theSkin envFile
		DialogMonitorOps.unRegisterNotification id:#pressSkinOK
		DialogMonitorOps.Enabled = false
		ok
	)

	fn fnRefreshSkinDeform = 
	(
		-- tm = timeStamp()
		local arrTarSkinMesh = #()
		for g in objects as array where (classof g == Editable_mesh) or (classof g == PolyMeshObject) do
		(
			if (getSkin g) != undefined then append arrTarSkinMesh g
		)

		for m in arrTarSkinMesh do
		(
			m.skin.always_deform = off
			m.skin.always_deform = on
		)
		-- format "RefreshSkinDeform Cost % ms\n" (timeStamp()-tm)
	)

	fn fnConvertToBone sourceObjs =
	(
		local tempBone = BoneSys.createBone [0,0,0] [0,rolBsRetarget.spnObjSize.value,0] [0,0,1]
		tempBone.width = tempBone.height =  rolBsRetarget.spnObjSize.value
		disableSceneRedraw()
		(
			local newBone = copy tempBone
			newBone.width         = tempBone.width
			newBone.height        = tempBone.height
			newBone.transform     = sourceObjs.transform
			newBone.name          = sourceObjs.name
			if sourceObjs.children.count > 0 then
				newBone.length = distance sourceObjs sourceObjs.children[1]
			else
				newBone.length =  rolBsRetarget.spnObjSize.value
			sourceObjs.baseobject    = newBone
			sourceObjs.showLinks     = false
			sourceObjs.showLinksOnly = false
			sourceObjs.boneEnable	= true
			delete newBone
		)
		delete tempBone
		enableSceneRedraw()
	)

	fn fnRenameBiped arrItems isB:false =
	(
		for i = 1 to arrItems.count where arrItems[i] != "~undefined~" do
		(
			if isB == false then 
			(
				tarBone = GetSkeletalNode i false
				-- if i == 1 then (tarBiped = getnodebyname "Bip001")
				-- else (tarBiped = getnodebyname (bipedRootName + (substituteString bipedBones.items[i] "[可选]" "")))
				tarBiped = (GetBipedNode i)
			)
			else 
			(
				tarBone = GetSkeletalNode (i + 35) false
				tarBiped = (GetBipedNode (i + 35))
			)

			if matchpattern tarBone.name pattern:"NewHip_*" then 
			(
				tarHipBone = getnodebyname (substituteString tarBone.name "NewHip_" "")
				tarBone = tarHipBone
				tarBone.parent = tarBiped
				for i in tarBone.children where i != undefined and (finditem rolBsRetarget.characterBones.items i.name == 0) and \
					(finditem rolBsRetarget.characterBones_B.items i.name == 0) do (i.parent = tarBone)
			)

			else if matchpattern tarBone.name pattern:"NewPelvis_*" then 
			(
				tarPelvisBone = getnodebyname (substituteString tarBone.name "NewPelvis_" "")
				tarBone = tarPelvisBone
				tarBone.parent = tarBiped
				for i in tarBone.children where i != undefined and (finditem rolBsRetarget.characterBones.items i.name == 0) and \
					(finditem rolBsRetarget.characterBones_B.items i.name == 0) do (i.parent = tarBone)
			)
			else
			(
				if tarBiped.parent != undefined then
				(
					if tarBone.name != tarBiped.parent.name do
					(
						tarBiped.name = tarBone.name
						tarBone.name = "ReTempNode_" + tarBone.name
						
						for i in tarBone.children where i != undefined and (finditem rolBsRetarget.characterBones.items i.name == 0) and \
						(finditem rolBsRetarget.characterBones_B.items i.name == 0) do (i.parent = tarBiped)
					)
				)
			)
		)
	)

	local SIOFile = dotNetClass "System.IO.File"
	local SIODir = dotNetClass "System.IO.Directory"

	-------------------右键面板空白处设置---------------------------------------------------------
	fn fnDelFileDir targetDel =  --删除文件
	(
		if (SIOFile.Exists targetDel == true) then ---判断是否存在文件
		(
			dotnet.loadAssembly "Microsoft.VisualBasic.dll"
		
			FileIO = dotnetclass "Microsoft.VisualBasic.FileIO.FileSystem"
			UIOption = (dotnetclass "Microsoft.VisualBasic.FileIO.UIOption").OnlyErrorDialogs
			RecycleOption = (dotnetclass "Microsoft.VisualBasic.FileIO.RecycleOption").SendToRecycleBin
	
			if getFileAttribute targetDel #readOnly == true or \
			getFileAttribute targetDel #hidden == true do --修改只读或者隐藏属性
			(
				setFileAttribute targetDel #readOnly false ; \
				setFileAttribute targetDel #hidden false
			)
			try 
			(
				FileIO.DeleteFile targetDel UIOption RecycleOption
				-- SIOFile.Delete(targetDel)
				(print ("已删除: "+ filenameFromPath targetDel  + " 至回收站"))
			)
			catch 
			(
				messagebox ("删除失败: "+ filenameFromPath targetDel + ". 请尝试手动删除。          ")
				(shellLaunch (getfilenamepath targetDel) "")
			)
		)
	)

	on btnReplaceToBiped pressed do
	(
		-- escapeEnable = true
		if mappingCheckState then
		(
			pgbBar.color = green
			pgbBar.value = 0
			lblBarValue.text = (pgbBar.value as string) + " %"
			hips = (GetSkeletalNode 1 false)
			boneRootMotion = (if matchpattern hips.name pattern:"NewHip_*" then hips.parent.parent else hips.parent)
			bipRootMotion = (GetBipedNode 1).parent
			(GetBipedNode 1).transform.controller.figureMode = false

			arrTarSkinMesh = #()
			for g in objects as array where (classof g == Editable_mesh) or (classof g == PolyMeshObject) do
			(
				if (getSkin g) != undefined then append arrTarSkinMesh g
			)

			for o = 1 to arrTarSkinMesh.count do
			(
				local meshSkin = (getSkin arrTarSkinMesh[o])
				select arrTarSkinMesh[o]
				max modify mode
				modpanel.setcurrentobject meshSkin
				skinOps.saveEnvelope meshSkin ((getdir #temp) + "\\" + arrTarSkinMesh[o].name + "_TempSkin.env")
				pgbBar.value = 30.*o/(arrTarSkinMesh.count)
				lblBarValue.text = (pgbBar.value as string) + " %"
			)

			fnRenameBiped characterBones.items isB:false
			fnRenameBiped characterBones_B.items isB:true
			-- delete hips
			-- bipRoot = getnodebyname (substituteString rolBsRetarget.characterBones.items[1] "NewHip_" "")
			-- bipPelvis = getnodebyname (substituteString rolBsRetarget.characterBones.items[2]"NewPelvis_" "")
			-- bipSpine = getnodebyname (substituteString rolBsRetarget.characterBones.items[3]"NewSpine_" "")
			-- bipRoot = (GetBipedNode 1)
			-- bipPelvis = (GetBipedNode 2)
			-- bipSpine = (GetBipedNode 3)
			-- biproot.transform.controller.figureMode = true
			-- biproot.controller.trianglePelvis = true
			-- biproot.controller.trianglePelvis = false
			-- biproot.controller.triangleNeck = false
			-- biproot.controller.triangleNeck = true
			-- biproot.transform.controller.figureMode = false
			-- if bipSpine != bipPelvis then bipSpine.parent = bipPelvis
			-- else (GetBipedNode 4).parent = (GetBipedNode 3)

			for g = 1 to arrTarSkinMesh.count do 
			(
				-- print g.name
				local meshSkin = (getSkin arrTarSkinMesh[g])
				-- meshSkin.always_deform = off
				select arrTarSkinMesh[g]
				modpanel.setcurrentobject meshSkin
				xchangeSkin arrTarSkinMesh[g]
				fnLoadEnvelope meshSkin ((getdir #temp) + "\\" + arrTarSkinMesh[g].name + "_TempSkin.env")
				fnDelFileDir ((getdir #temp) + "\\" + arrTarSkinMesh[g].name + "_TempSkin.env")
				-- meshSkin.always_deform = on
				-- meshSkin.always_deform = off
				-- meshSkin.always_deform = on
				pgbBar.value = 30 + (70.*g/(arrTarSkinMesh.count))
				lblBarValue.text = (pgbBar.value as string) + " %"
			)

			-- if (chkRenameBiped.state == false) then 
			-- (
				(GetBipedNode 1).controller.rootname = bipedRootName
				if boneRootMotion != undefined and bipRootMotion != undefined then 
				(
					boneRootMotion.children.parent = bipRootMotion
					delete boneRootMotion
				)
			-- )
			-- else(if bipRootMotion != undefined then (delete bipRootMotion))
			
			clearselection()
			select $'ReTempNode_*'
			selectmore $'RTHelper_*'
			selectmore $'NewHip_*'
			selectmore $'NewPelvis_*'
			selectmore $'NewSpine_*'
			-- delete $
			for i in selection as array where isvalidnode i do delete i

			messagebox "Biped 已替换，且原 Bone 和多余 Helper 已被删除。\r\n\r\n【可能存在冗余节点未删除】，请检查骨骼链外的节点，自行清理~                                              " title:"BsRetargetTools"
		)
		else (messageBox "请先验证并检查映射列表是否完整！                                       " title:"BsRetargetTools")
	)

	-- on pkbRootMption picked obj do 
	-- (
	-- 	pickedRootMotion = obj 
	-- 	messagebox ("RootMotion 已指定为: " + obj.name + "                     ") title:"BsRetargetTools" beep:false
	-- )

	-- on pkbRootMption rightclick do 
	-- (
	-- 	pkbRootMption.object = undefined
	-- )

	on btnConvertToBone pressed do with undo on
	(
		if (queryBox "因轴向原因转换可能会导致骨骼错乱，\r\n\r\n建议只选需要解算的飘带转换，\r\n\r\n注意备份文件！                                                     " \
		title:"BsRetargetTools Tips" beep:false) then
		(
			arrConvertBones = (selection as array)
			if arrConvertBones.count != 0 then 
			(
				-- tm = timeStamp()
				for i in arrConvertBones where superclassof i == helper do 
				(
					fnConvertToBone i
				)
				for i in arrConvertBones where (classof i.controller != Vertical_Horizontal_Turn) and (i.parent != undefined) do 
				(
					if (chkRealign.state) and i.children.count == 1 then
					(
						i.realignBoneToChild()
					)
				)
				-- format "ConvertToBone Cost % s\n" ((timeStamp()-tm)*0.001)
				if chkRealign.state then fnRefreshSkinDeform()
			)
		)
	)
)

createDialog rolBsRetarget 650 660 style:#(#style_titlebar, #style_sysmenu, #style_toolwindow) lockHeight:true lockWidth:true fgcolor:myFgColor



rolBsRetarget.bipedBones.items = #(
	"Bip001", 				--1
	"Pelvis", 				--2
	"Spine", 				--3
	"Spine1",			--4
	"[可选]Spine2",			--5
	"Neck",				--6
	"[可选]Neck1",	--7 (NO LONGER USING)
	"Head",				--8
	"HeadNub",			--9
	
	"L Thigh",			--10
	"L Calf",				--11
	"L Foot",				--12
	"L Toe0",			--13
	"L Toe0Nub",		--14
	
	"R Thigh",			--15
	"R Calf",				--16
	"R Foot",			--17
	"R Toe0",			--18
	"R Toe0Nub",		--19
	
	"L Clavicle", 		--20
	"L UpperArm",		--21
	"L Forearm",		--22
	"L Hand",			--23
	"L Finger0",			--24
	"L Finger01",		--25
	"L Finger02",		--26
	"L Finger0Nub",	--27
	"L Finger1",			--28
	"L Finger11",		--29
	"L Finger12",		--30
	"L Finger1Nub",	--31
	"L Finger2",			--32
	"L Finger21",		--33
	"L Finger22",		--34
	"L Finger2Nub"	    --35
)

rolBsRetarget.bipedBones_B.items = #(
	"L Finger3",			--36
	"L Finger31",		--37
	"L Finger32",		--38
	"L Finger3Nub",	--39
	"L Finger4",			--40
	"L Finger41",		--41
	"L Finger42",		--42
	"L Finger4Nub",	--43
	
	"R Clavicle",		--44
	"R UpperArm",		--45
	"R Forearm",		--46
	"R Hand",			--47
	"R Finger0",		--48
	"R Finger01",		--49
	"R Finger02",		--50
	"R Finger0Nub",	--51
	"R Finger1",		--52
	"R Finger11",		--53
	"R Finger12",		--54
	"R Finger1Nub",	--55
	"R Finger2",		--56
	"R Finger21",		--57
	"R Finger22",		--58
	"R Finger2Nub",	--59
	"R Finger3",		--60
	"R Finger31",		--61
	"R Finger32",		--62
	"R Finger3Nub",	--63
	"R Finger4",		--64
	"R Finger41",		--65
	"R Finger42",		--66
	"R Finger4Nub"		--67	
)

for  i=2 to rolBsRetarget.bipedBones.items.count do
(
	rolBsRetarget.characterBones.items = append rolBsRetarget.characterBones.items "~undefined~"
)

for  i=2 to rolBsRetarget.bipedBones_B.items.count do
(
	rolBsRetarget.characterBones_B.items = append rolBsRetarget.characterBones_B.items "~undefined~"
)