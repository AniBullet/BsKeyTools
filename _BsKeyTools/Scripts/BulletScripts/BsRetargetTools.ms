-- BipedRigCreator_v3.3.2_Enhanced
-- by: Bullet.S
-- 2022.05

try (destroyDialog biped_align_test) catch()
try (destroyDialog choose_item_rollout) catch()

global biped_align_test

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
	#("*Spine","*Waist"),				--3
	#("*Spine1","*Stomach"),			--4
	#("*Spine2","*Chest"),			--5
	#("*Neck"),				--6
	#("*Neck1","*Neck?Middle"),			--7
	#("*Head"),				--8
	#("*HeadNub","*Head?nub"),			--9
	
	#("*L?Thigh","*Thigh?L"),			--10
	#("*L?Calf","*L?Shin","*Calf?L"),				--11
	#("*L?Foot","*Foot?L"),				--12
	#("*L?Toe0","*L?Toe","*Toe?L"),			--13
	#("*L?Toe0Nub","*L?Toe?nub","*L?Toe0?Nub"),		--14
	
	#("*R?Thigh","*Thigh?R"),			--15
	#("*R?Calf","*R?Shin","*Calf?R"),				--16
	#("*R?Foot","*Foot?R"),			--17
	#("*R?Toe0","*R?Toe","*Toe?R"),			--18
	#("*R?Toe0Nub","*R?Toe?nub","*R?Toe0?Nub"),		--19
	
	#("*L?Clavicle","*L?Shoulder","*Clavicle?L"),		--20
	#("*L?UpperArm","*UpperArm?L"),		--21
	#("*L?Forearm","*Forearm?L"),		--22
	#("*L?Hand","*Hand?L"),			--23
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
	
	#("*R?Clavicle","*R?Shoulder","*Clavicle?R"),		--44
	#("*R?UpperArm","*UpperArm?R"),		--45
	#("*R?Forearm","*Forearm?R"),		--46
	#("*R?Hand","*Hand?R"),			--47
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


global bipedRootName = "Bip001";

global okForceRedraw = true;

global mappingCheckState = false

global arrExportRetargetAnim = #()

global arrAllBipedNode = #()
global arrAllBipedName = #()

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
			result = getNodeByName biped_align_test.characterBones.items[index]
		)
		else
		(
			result = getNodeByName biped_align_test.characterBones_B.items[index-35]
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
			return getNodeByName ("RetargetHelper_" + bipedRootName)
		)
		else 
		(
			return getNodeByName ("RetargetHelper_" + bipedRootName + (substituteString boneNames[index] "[可选]" ""))
		)
	)
)	

rcmenu menuQuickCreateNode
(
	menuItem quickMakeParent "快速创建父级骨骼"
    menuItem quickDuplicate "快速创建子级 Nub"
    menuItem quickDuplicateFoot "快速创建 Foot Nub"
    menuItem quickCenterRoot "快速创建新的 Hips"
	menuItem tips "根据 Bone 骨骼大腿的位置，" enabled:false
    menuItem tips2 "创建符合 Biped 骨骼位置的质心。" enabled:false

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
	on quickDuplicateFoot picked do
	(
		for i in selection as array where $ != undefined do
		(
			local vec = i.pos - i.parent.pos;
			local pos = i.pos + (normalize vec) * (length vec);
			pos.z = i.pos.z;
			
			in i nB = bone pos:pos;
			nB.name = i.name + " nub";
			-- select nB
		)
	)
	on quickCenterRoot picked do
	(
		try
		(
			local leftLeg = GetSkeletalNode 10 false
			local rightLeg = GetSkeletalNode 15 false
			
			local root = GetSkeletalNode 1 false
			local hip = GetSkeletalNode 2 false
			
			local rootDummy = point name:("NewHip_" + root.name)
			local dummyPelvis = point name:("NewPelvis_" + hip.name)

			rootDummy.constantscreensize = true
			-- rootDummy.box = true

			dummyPelvis.constantscreensize = true
			-- dummyPelvis.box = true
			
			rootDummy.transform = hip.transform
			rootDummy.pos = 0.5 * (leftLeg.pos + rightLeg.pos)
			dummyPelvis.transform = rootDummy.transform

			local pC = Position_Constraint()
			pC.appendTarget root 100
			rootDummy.Position.controller = pC
			pC.relative = true
			
			local oC = Orientation_Constraint()
			oC.appendTarget root 100
			rootDummy.Rotation.controller = oC
			oC.relative = true

			-- rootDummy.parent = root.parent
			dummyPelvis.parent = rootDummy
			
			tempItems = biped_align_test.characterBones.items
			tempItems[1] = rootDummy.name
			tempItems[2] = dummyPelvis.name
			biped_align_test.characterBones.items = tempItems

			-- if root.parent != undefined then
			-- (
			-- 	boneRootMotionTarget = root.parent
			-- 	boneRootMotion = dummy name:("Root_" + boneRootMotionTarget.name)
			-- 	boneRootMotion.transform = boneRootMotionTarget.transform
			-- 	-- rootDummy.parent = boneRootMotion
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
			-- hip.parent = rootDummy

			-- print leftLeg
			-- print rightLeg
			-- print root
			-- print hip
		)
		catch
		(
            messagebox "请先添加骨骼映射！                 "
		)
	)
)

-- The rollout used for this script.
rollout biped_align_test "BsRetargetTools_v1.9 (BipedRigCreator_Enhanced)"
(
	-- Contains the names of the first 35 biped bones for reference
	listbox bipedBones "Bip 节点名 1 - 35" align:#left across:4 height:35 width:113 items:#("Biped Root", "Biped Pelvis", "Biped Spine 0", "Biped Spine 1")
	-- visible:false
    -- Contains the names of the first 35 bones used from the original rig
	listbox characterBones "Bone 骨骼名 1 - 35" align:#left height:35 width:113 items:#("~undefined~")
	
	-- Contains the names of the reamining biped bones for reference
	listbox bipedBones_B "Bip 节点名 36 - 67" align:#left height:35 width:113 items:#("Biped Root", "Biped Pelvis", "Biped Spine 0", "Biped Spine 1")
	-- Contains the names of the remaining original rig's bones.
	listbox characterBones_B "Bone 骨骼名 36 - 67" align:#left height:35 width:113 items:#("~undefined~")

    local btnWidth   = 120

    groupbox grpRetargetList "1. Check  mapping" pos:[15,485] width:130 height:125

    button loadDialogue "加载" pos:[20,535] width:(btnWidth/2) height:25
    button saveDialogue "保存" pos:[80,535] width:(btnWidth/2) height:25
    button btnAutoMapping "自动检索匹配" pos:[20,505] width:btnWidth height:30 tooltip:"根据通用的身体骨骼名称，自动检索匹配。"
    -- button testWizard "快速映射助手" pos:[20,555] width:btnWidth tooltip:"根据层级关系帮助选择对应骨骼。"
	button validateButton "验证映射列表" pos:[20,560] width:btnWidth height:40 tooltip:"验证匹配是否完整。"
    
    --button setupRotation "Setup Rotations"
    -- groupbox grpHelper "Helpers" pos:[255,485] width:100 height:125
    -- button createHelpersBtn "创建 Helpers" pos:[260,505] width:btnWidth
    -- button destroyHelpersBtn "清除 Helpers" pos:[260,555] width:btnWidth
    -- button setupHelpersBtn "设置 Helpers" pos:[260,530] width:btnWidth
    -- checkBox hideHelpers "隐藏 Helpers" checked:true tooltip:"隐藏 Helpers" pos:[260,585] width:btnWidth
    
    groupbox grpBiped "2. Rig Retarget Tools" pos:[155,485] width:310 height:125
    -- button buildHelperBiped "创建 Biped" pos:[370,505] width:btnWidth
    -- button buildHelperRig "创建辅助骨骼" pos:[370,530] width:btnWidth
	button btnQuickTools "[可选]快速创建节点" pos:[160,505] width:(btnWidth + 20) height:25
    button alignBipedToHelper "🍖 创建和对齐 Biped" pos:[160,530] width:(btnWidth + 20) height:40
    button reAlignFingers "🤞🏼 重新对齐手指骨骼" pos:[160,570] width:(btnWidth + 20) height:30
    -- button btnExportTPose "[可选]导出 Biped Figure Pose" pos:[305,505] width:(btnWidth + 35) height:25
	checkbox chkRenameBiped "👇 Biped 保持 Bone 原名" checked:false pos:[306,505] width:(btnWidth + 35) height:20
	button btnReplaceToBiped "[可选] Skin 替换为 Biped" pos:[305,530] width:(btnWidth + 35) height:25
    checkbutton ckbExportFBXTools "🎮 动画批量重定向工具" pos:[305,555] width:(btnWidth + 35) height:45
    
    -- checkBox toggleBipedMode "形体模式开关" checked:true tooltip:"打开和关闭 Biped 体形模式" pos:[370,580] width:btnWidth
    
    -- checkBox togglePositionConstraints "使用位置约束" checked:false tooltip:"如果打开，位置约束将应用于 Rig 的 Hips。" \
    -- pos:[370,583] width:btnWidth
        
    -- button constrainButton "对齐后创建约束" pos:[370,605] width:btnWidth
    
    -- groupbox grpQuickNub "Quick Nub / Hips" pos:[155,485] width:150 height:125
    -- button quickMakeParent "快速创建父级骨骼" pos:[160,505] width:(btnWidth + 20)
    -- button quickDuplicate "快速创建子级 Nub" pos:[160,530] width:(btnWidth + 20)
    -- button quickDuplicateFoot "快速创建 Foot Nub" pos:[160,555] width:(btnWidth + 20)
    -- button quickCenterRoot "快速创建新的 Hips" tooltip:"根据 Bone 骨骼大腿的位置创建符合 Biped 骨骼位置的质心。" \
    -- pos:[160,580] width:(btnWidth + 20)
    
    -- button recordFrame "记录 Biped 单帧" pos:[15,615] width:btnWidth border:false
    -- spinner animationRate "帧数间隔" range:[1,100,2] type:#integer pos:[170,618] width:(btnWidth - 40)
    -- button recordAnimation "记录整个 Biped 动画" pos:[240,615] width:(btnWidth + 25) border:false

    groupbox grpExportTools "Anim Retarget Tools" pos:[15,5] width:450 height:475 visible:false
	
	button btnRefreshFolder ">>  按默认规则刷新路径和文件  <<" \
	height:30 width:235 pos:[225,25] tooltip:"刷新当前文件目录\r\n并按默认规则寻找文件\r\n映射文件为当前打开文件\r\n新 Skin 文件为同目录 Skin.max" visible:false

	listBox ltbFilesList "" selection:0 \
	height:34 width:200 pos:[20,25] visible:false

	button btnLoadAnimPath "选择动画目录" tooltip:"选择原始动画目录" \
	height:22 width:115 pos:[225,65] visible:false
	button btnRefreshAnimFiles "刷新" \
	height:22 width:60 pos:[340,65] visible:false
	button btnOpenCurrentPath "打开" tooltip:"打开当前文件夹" \
	height:22 width:60 pos:[400,65] border:true visible:false
	editText edtAnimFbxPath "" text:"" labelOnTop:true \
	height:22 fieldWidth:235 pos:[225,90] readOnly:true visible:false
	
	button btnOutputPath "选择导出目录" pos:[225,125] width:160 visible:false \
	tooltip:"导出的重定向动画 FBX 保存目录，\r\n新 Skin 动画目录在：\r\n此目录的 *\NewFbx 目录下。"
	button btnOpedOutputPath "打开" pos:[385,125] width:75 visible:false \
	tooltip:"打开重定向文件导出目录"
	editText edtOutputPath "" text:"" labelOnTop:true \
	height:22 fieldWidth:235 pos:[225,150] readOnly:true visible:false
    
	button btnSelectMappingFile "选择映射文件" pos:[225,185] width:160 visible:false \
	tooltip:"选择以 Bone 骨架生成的 Biped 映射文件"
	button btnOpenMappingFile "打开" pos:[385,185] width:75 visible:false \
	tooltip:"打开映射文件"
    editText edtMappingFile "" text:"" labelOnTop:true \
	height:22 fieldWidth:235 pos:[225,210] readOnly:true visible:false
	
	button btnSelectSkinFile "选择新 Skin 文件" pos:[225,245] width:160 visible:false \
	tooltip:"选择新的 Skin 文件"
	button btnOpenSkinFile "打开" pos:[385,245] width:75 visible:false \
	tooltip:"打开新 Skin 文件"
    editText edtSkinFile "" text:"" labelOnTop:true \
	height:22 fieldWidth:235 pos:[225,270] readOnly:true visible:false

    button btnRetargetSelected ">>>   重定向列表选中动画   <<<" pos:[225,310] width:235 height:35 visible:false \
	tooltip:"重定向列表选中的动画并且打开\r\n会保存一份 .max 和 .FBX 文件"
    button btnRetargettAll ">>>   重定向列表所有动画   <<<" pos:[225,345] width:235 height:35 visible:false \
	tooltip:"重定向列表选中的动画\r\n会保存一份 .max 和 .FBX 文件\r\n可能比较慢..."
	checkbox chkRecoverExport "不覆盖导出，用于崩溃后继续重导" checked:false pos:[240,385] width:200 height:20 visible:false

	label lblCount "已重定向动画 FBX 数：0 个\r\n\r\n待处理原始动画 FBX 数：0 个" \
	pos:[235,425] width:225 height:40 visible:false

    progressbar pgbBar "" pos:[15,618] width:450 height:10 color:white
	
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
			lblCount.text = ("已重定向动画 FBX 数：0 个")
			lblCount.text += ("\r\n\r\n待处理原始动画 FBX 数：" + ltbFilesList.items.count as string + " 个")
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

	fn fnFixBoneSize tempBone =
	(
		case units.MetricType of
		(
			#Millimeters:(tempBone.width = 40;tempBone.height = 40)
			#Centimeters:(tempBone.width = 4;tempBone.height = 4)
			#Meters:(tempBone.width = 0.04;tempBone.height = 0.04)
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
            local strTargetBiped = (bipedRootName + " " + (substituteString biped_align_test.bipedBones.items[index] "[可选]" ""))
			idTargetBiped = finditem arrAllBipedName strTargetBiped
			targetBiped = arrAllBipedNode[idTargetBiped]
            targetBiped.boxmode = true
			return targetBiped
		)
		else
		(
            local strTargetBiped = (bipedRootName + " " + biped_align_test.bipedBones_B.items[index-35])
			idTargetBiped = finditem arrAllBipedName strTargetBiped
			targetBiped = arrAllBipedNode[idTargetBiped]
			targetBiped.boxmode = true
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
			tarFileExportPath  = edtOutputPath.text + "\\" + (getfilenamefile sourFileImportPath) + ".FBX"
			tempBip = edtOutputPath.text + "\\" + (getfilenamefile sourFileImportPath) + ".bip"
			skinFile   = edtSkinFile.text
			tarNewAnim = (edtOutputPath.text + (getfilenamefile sourFileImportPath) + ".FBX")
			if (not (SIODir.Exists edtOutputPath.text)) do (SIODir.CreateDirectory edtOutputPath.text)
			
			-- print ("开始重定向动画：" +  (getfilenamefile arrExportRetargetAnim[index]) + ".FBX")
			if chkRecoverExport.state then 
			(
				if doesFileExist (substituteString tarNewAnim ".FBX" ".max") then (return "Exist")
			)
			resetMaxFile #noPrompt
			-- framerate = 60
			loadMaxFile mappingFilePath useFileUnits:true quiet:true
			importFile sourFileImportPath #noPrompt using:FBXIMP

			-- DialogMonitorOps.Enabled = true
			-- DialogMonitorOps.RegisterNotification fnConfirmImportFBX id:#importFBX
			-- DialogMonitorOps.unRegisterNotification id:#importFBX
			-- DialogMonitorOps.Enabled = false

			select $'RetargetHelper_*'
			arrExport = (selection as array)
			for i in arrExport where isValidNode i do
			(
				(i.name = substituteString i.name "RetargetHelper_" "")
			)
			
			FBXExporterSetParam "Animation" true
			FBXExporterSetParam "BakeAnimation" true
			FBXExporterSetParam "BakeResampleAnimation" false
			FBXExporterSetParam "SplitAnimationIntoTakes" "-c"
			FBXExporterSetParam "BakeFrameStart" animationRange.start
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
			exportFile tarFileExportPath #noPrompt selectedOnly:true using:FBXEXP

			-- print ("正在导入新 Skin 动画：" + tarNewAnim)
			resetMaxFile #noPrompt
			-- framerate = 60
			loadMaxFile skinFile useFileUnits:true quiet:true
			(GetBipedNode 1).transform.controller.figureMode = false

			FbxImporterSetParam "Mode" #exmerge
			FbxImporterSetParam "Animation" true
			FbxImporterSetParam "FillTimeline" true
			FbxImporterSetParam "BakeAnimationLayers" false
			FbxImporterSetParam "PointCache" false

			if (getnodebyname "Root") != undefined then
			(
				local dummyRootMotionTemp = point name:"RootTemp"
				in coordsys gimbal dummyRootMotionTemp.rotation = (eulerAngles 90 0 0)
				(GetBipedNode 1).parent = dummyRootMotionTemp
				dummyRootMotionTemp.constantscreensize = true
			)

			importFile tarNewAnim #noPrompt using:FBXIMP

			if (getnodebyname "Root") != undefined then 
			(
				local rootBone            = (GetBipedNode 1)
				local dummyRootMotion     = (getnodebyname "Root")
				local dummyRootMotionTemp = (getnodebyname "RootTemp")

				-- 每一帧的Pos与Rot
				local bipPosList = #()
				local bipRotList = #()

				-- 第一次遍历，记录原始的bip在世界空间的位置与旋转信息
				for t = (animationRange.start) to (animationRange.end) do
				(
					at time t
					(
						append bipPosList (in coordsys world Biped.getTransform rootBone #pos)
						append bipRotList (in coordsys world Biped.getTransform rootBone #rotation)
					)
				)

				-- 第二次遍历，动画 Root 匹配 RootLeader
				for t = (animationRange.start) to (animationRange.end) do
				(
					at time t with animate on (dummyRootMotionTemp.transform = dummyRootMotion.transform)  
				)

				-- 第三次遍历，创建新的Bip层，还原bip的位置以及旋转信息
				biped.createLayer rootBone.controller 1 "layerRootMotionOffset"
				biped.setcurrentlayer rootBone.controller 1
				local f = 1
				for t = (animationRange.start) to (animationRange.end) do
				(
					slidertime = t
					with animate on
					(
						-- Pos
						local bipPos = bipPosList[f]
						in coordsys world Biped.setTransform rootBone #pos bipPos true
						-- Rot
						local bipRot = bipRotList[f]
						in coordsys world Biped.setTransform rootBone #rotation bipRot true

						f += 1
						-- biped.addNewKey rootBone.transform.controller.vertical.controller t
					)
				)
				dummyRootMotion.children.parent = dummyRootMotionTemp
				delete dummyRootMotion
				dummyRootMotionTemp.name = "Root"
				biped.collapseAtLayer rootBone.controller 0
			)
			saveMaxFile (substituteString tarNewAnim ".FBX" ".max") quiet:true
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
			
			newBone = BoneSys.createBone parentPos midPos axisA
			newBone.parent    = initialBone
			newBone.name      = ("RetargetHelper_" + (GetBipedNode parentIndex).name);
			newBone.boxmode   = true
			newBone.wirecolor = black
			fnFixBoneSize newBone
			
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
			
			newBone = BoneSys.createBone parentPos midPos axisA
			newBone.parent    = initialBone
			newBone.name      = ("RetargetHelper_" + (GetBipedNode parentIndex).name);
			newBone.boxmode   = true
			newBone.wirecolor = green
			fnFixBoneSize newBone
			
			return newBone;
		)
		
		if (isHand == true) then
		(
			local mid = [0,0,0]
			if (parentIndex == 23) then
			(
				local fIndex = GetSkeletalNode 28 false
				local fMiddle = GetSkeletalNode 32 false
				local fRing = GetSkeletalNode 36 false
				local fPinky = GetSkeletalNode 40 false;
				
				mid = (fIndex.pos + fMiddle.pos + fRing.pos + fPinky.pos) * 0.25;
			)
			else
			(
				local fIndex = GetSkeletalNode 52 false
				local fMiddle = GetSkeletalNode 56 false
				local fRing = GetSkeletalNode 60 false
				local fPinky = GetSkeletalNode 64 false;
				
				mid = (fIndex.pos + fMiddle.pos + fRing.pos + fPinky.pos) * 0.25;
			)
			
			local diff = mid - foundParent.pos
			local cro = cross (normalize diff) axis
			axis = normalize cro
			print axis
				
			if initialBone != undefined then
			(
				newBone = BoneSys.createBone foundParent.pos mid axis
				newBone.parent    = initialBone
				newBone.boxmode   = true
				newBone.wirecolor = green
				fnFixBoneSize newBone
			)
			else
			(
				newBone = BoneSys.createBone foundParent.pos mid axis
				newBone.boxmode   = true
				newBone.wirecolor = green
				fnFixBoneSize newBone
			)
			
			newBone.name = ("RetargetHelper_" + (GetBipedNode parentIndex).name);
			
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
					fnFixBoneSize newBone
				)
				else
				(
					newBone = BoneSys.createBone foundParent.pos foundChild.pos axis
					newBone.boxmode   = true
					newBone.wirecolor = green
					fnFixBoneSize newBone
				)
				
				newBone.name = ("RetargetHelper_" + (GetBipedNode parentIndex).name)
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
					fnFixBoneSize newBone
					newBone.ishidden = true
				)
				else
				(
					return undefined;
				)
				
				newBone.name = ("RetargetHelper_" + (GetBipedNode parentIndex).name)
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
			
			(getNodeByName ("RetargetHelper_" + (GetBipedNode itemIndex).name)).Rotation.controller = oC;
			oC.relative = true;
		)
		else
		(
			local oC = Orientation_Constraint();
			oC.appendTarget (GetBipedNode itemIndex) 100;
			
			(getNodeByName ("RetargetHelper_" + (GetBipedNode itemIndex).name)).Rotation.controller = oC;
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
			
			(getNodeByName ("RetargetHelper_" + (GetBipedNode itemIndex).name)).Position.controller = oC;
			oC.relative = true;
		)
		else
		(
			local oC = Position_Constraint();
			oC.appendTarget (GetBipedNode itemIndex) 100;
			
			(getNodeByName ("RetargetHelper_" + (GetBipedNode itemIndex).name)).Position.controller = oC;
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

        f = getSaveFileName caption:"Save Skeleton" initialDir:tempdir filename:".list" types:"Mapping List (*.list)|*.list|"
        
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

        local tempdir = (if (maxFilePath != "") and (doesDirectoryExist maxFilePath) then maxFilePath else (@"C:\Users\" + (filterString  (getdir #userscripts) @"\")[3] + @"\Desktop\"))

		f = getOpenFileName caption:"Open A Test File:" filename:tempdir types:"Mapping List (*.list)|*.list|"
		
		if f != undefined then
		(
			fS = openFile f mode:"r"
			i = 1
			
			while (eof fS) == false do
			(
				newValue = readLine fS;
				print newValue
				
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
		print (nameIndex)
		if $ != undefined and (selection as array).count == 1 then
		(
			local temp_array = characterBones.items;
			temp_array[nameIndex] = $.name
			characterBones.items = temp_array;
		)
		else (messagebox "只能填入一个有效骨骼节点!                                              ")
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
	
	on bipedBones doubleClicked nameIndex do
	(
		local temp_array = characterBones.items;
		temp_array[nameIndex] = "~undefined~";
		characterBones.items = temp_array;
	)
	
	on characterBones doubleClicked nameIndex do
	(
		local temp_array = characterBones.items;
		temp_array[nameIndex] = "~undefined~";
		characterBones.items = temp_array;
	)
	
-- ALTA
	
	on bipedBones_B selected nameIndex do
	(
		print (nameIndex)
		if $ != undefined then
		(
			local temp_array = characterBones_B.items;
			temp_array[nameIndex] = $.name
			characterBones_B.items = temp_array;
		)
	)
	
	on characterBones_B selected nameIndex do
	(
		print (nameIndex)
		if $ != undefined then
		(
			local temp_array = characterBones_B.items;
			temp_array[nameIndex] = $.name
			characterBones_B.items = temp_array;
		)
	)
	
	on bipedBones_B doubleClicked nameIndex do
	(
		local temp_array = characterBones_B.items;
		temp_array[nameIndex] = "~undefined~";
		characterBones_B.items = temp_array;
	)
	
	on characterBones_B doubleClicked nameIndex do
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
		if boneFBXRoot == (GetSkeletalNode 1 false).parent then 
		(
			for c in boneFBXRoot.children do
			(
				fnCopyChildSubBone c
			)
		)
		else 
		(
			if (finditem biped_align_test.characterBones.items boneFBXRoot.name == 0) and \
			(finditem biped_align_test.characterBones_B.items boneFBXRoot.name == 0) then 
			(
				case of
				(
					(boneFBXRoot.parent == (GetSkeletalNode 1 false).parent):
					(
						helperRoot = (getnodebyname "RetargetHelper_Root")
					)
					((finditem biped_align_test.characterBones.items boneFBXRoot.parent.name) != 0):
					(
						helperRoot = (GetSkeletalNode (finditem biped_align_test.characterBones.items boneFBXRoot.parent.name) true)
					)
					((finditem biped_align_test.characterBones_B.items boneFBXRoot.parent.name) != 0):
					(
						helperRoot = (GetSkeletalNode ((finditem biped_align_test.characterBones_B.items boneFBXRoot.parent.name) + 35) true)
					)
					default:
					(helperRoot = (getnodebyname ("RetargetHelper_" + boneFBXRoot.parent.name)))
				) 
				tempCopyBone = (copy boneFBXRoot)
				tempCopyBone.name = boneFBXRoot.name
				strTempName = tempCopyBone.name
				tempCopyBone.name = "RetargetHelper_" + strTempName
				tempCopyBone.parent = helperRoot
				lc = Link_Constraint();
				tempCopyBone.transform.controller = lc
				lc.key_mode = 0
				lc.addTarget boneFBXRoot 0
				tempCopyBone.transform = boneFBXRoot.transform
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
		if boneFBXRoot.parent != undefined then 
		(
			fnCopyChildSubBone boneFBXRoot.parent
		)
		else (fnCopyChildSubBone boneFBXRoot)
	)
	
    on alignBipedToHelper pressed do
	(
		if mappingCheckState then
		(
			pgbBar.value = 0
			max Create mode
			---断开质心防止旋转出问题，后面连上
			rootMotionBone = (GetSkeletalNode 1 false).parent
			(GetSkeletalNode 1 false).parent = undefined

			-- 创建 Helper
			if isValidNode headNub == false then headNub = point name:"_Helper_Head Nub" wirecolor:(color 0 255 0)
	
			if isValidNode fingerNubs[1][1] == false then fingerNubs[1][1] = point name: "_Helper_Finger L Thumb 1 Nub" boxsize:[1,1,1] wirecolor:(color 255 0 0)
			if isValidNode fingerNubs[1][2] == false then fingerNubs[1][2] = point name: "_Helper_Finger L Index 2 Nub" boxsize:[1,1,1] wirecolor:(color 255 64 0)
			if isValidNode fingerNubs[1][3] == false  then fingerNubs[1][3] = point  name: "_Helper_Finger L Mid 3 Nub" boxsize:[1,1,1] wirecolor:(color 255 128 0)
			if isValidNode fingerNubs[1][4] == false  then fingerNubs[1][4] = point  name: "_Helper_Finger L Ring 4 Nub" boxsize:[1,1,1] wirecolor:(color 255 192 0)
			if isValidNode fingerNubs[1][5] == false  then fingerNubs[1][5] = point  name: "_Helper_Finger L Pinky 5 Nub" boxsize:[1,1,1] wirecolor:(color 255 255 0)
			
			if isValidNode fingerNubs[2][1] == false  then fingerNubs[2][1] = point  name: "_Helper_Finger R Thumb 1 Nub" boxsize:[1,1,1] wirecolor:(color 0 0 255)
			if isValidNode fingerNubs[2][2] == false  then fingerNubs[2][2] = point  name: "_Helper_Finger R Index 2 Nub" boxsize:[1,1,1] wirecolor:(color 0 64 255)
			if isValidNode fingerNubs[2][3] == false  then fingerNubs[2][3] = point  name: "_Helper_Finger R Mid 3 Nub" boxsize:[1,1,1] wirecolor:(color 0 128 255)
			if isValidNode fingerNubs[2][4] == false  then fingerNubs[2][4] = point  name: "_Helper_Finger R Ring 4 Nub" boxsize:[1,1,1] wirecolor:(color 0 192 255)
			if isValidNode fingerNubs[2][5] == false  then fingerNubs[2][5] = point  name: "_Helper_Finger R Pinky 5 Nub" boxsize:[1,1,1] wirecolor:(color 0 255 255)
			
			if isValidNode toeNubs[1] == false  then toeNubs[1] = point  name: "_Helper_Toe L Nub" boxsize:[1,1,1] wirecolor:(color 255 64 128)	
			if isValidNode toeNubs[2] == false  then toeNubs[2] = point  name: "_Helper_Toe R Nub" boxsize:[1,1,1] wirecolor:(color 64 128 255)
	
			if isValidNode footHelpers[1] == false  then footHelpers[1] = point  name: "_Helper_Foot Helper L" boxsize:[2,4,2] wirecolor:(color 255 128 255)
			if isValidNode footHelpers[2] == false  then footHelpers[2] = point  name: "_Helper_Foot Helper R" boxsize:[2,4,2] wirecolor:(color 128 255 255)
	
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
				for j in i where isvalidnode j do j.constantscreensize = true
			)
			headNub.constantscreensize = true

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
			)
			catch
			(
				messagebox "创建 Biped 时出错，可能有骨骼映射缺失。                               "
			)
	
			pgbBar.value = 5
	
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
			rootBone.constantscreensize = true
			-- rootBone.box = true
			rootBone.name = ("RetargetHelper_" + (GetBipedNode 1).name)
			rootBone.transform = (GetBipedNode 1).transform
			bipedRetargetRM = undefined
			boneRetargetRM = undefined
			if rootMotionBone != undefined then
			(
				boneRetargetRM = point name:"RetargetHelper_Root"
				boneRetargetRM.constantscreensize = true
				-- boneRetargetRM.box = true
				boneRetargetRM.transform = rootMotionBone.transform
				in coordsys gimbal boneRetargetRM.rotation = (eulerAngles 90 0 0)
				local pC = Position_Constraint()
				pC.appendTarget rootMotionBone 100
				boneRetargetRM.Position.controller = pC
				pC.relative = true
				
				local oC = Orientation_Constraint()
				oC.appendTarget rootMotionBone 100
				boneRetargetRM.Rotation.controller = oC
				oC.relative = true

				bipedRetargetRM = point name:"Root"
				bipedRetargetRM.transform = boneRetargetRM.transform
				in coordsys gimbal bipedRetargetRM.rotation = (eulerAngles 90 0 0)
				bipedRetargetRM.wirecolor = red
				bipedRetargetRM.constantscreensize = true
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
			lHandBone = CreateFauxBone newBone 23 32 [0,0,-1]-- isHand:true
			
			newBone = CreateFauxBone topSpine 44 45 [0,1,0]
			newBone = CreateFauxBone newBone 45 46 [0,1,0]
			newBone = CreateFauxBone newBone 46 47 [0,1,0]
			rHandBone = CreateFauxBone newBone 47 56 [0,0,-1]-- isHand:true
			
			pgbBar.value = 10
			-- Create the fingers
			fn QuickFingers sI startingBone isThumbs =
			(
				local axis = [0,0,-1]
				--if isThumbs == true then
				--(
				--	axis = [0,1,0]
				--)
				local tBone = CreateFauxBone startingBone sI (sI+1) 		axis
				tBone = CreateFauxBone tBone (sI+1) (sI+2) 					axis
				tBone = CreateFauxBone tBone (sI+2) (sI+3)					axis
				tBone = CreateFauxBone tBone (sI+3) 0 							axis
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
			--对齐 Biped
			fnAlignBipedToHelper()
			pgbBar.value = 55
			(GetBipedNode 1).transform.controller.figureMode = false
			fnAlignBipedToHelper()
			pgbBar.value = 90
			biped.createCopyCollection (GetBipedNode 1).controller "tempRetargetBipedPose"
			copycol= biped.getcopycollection (GetBipedNode 1).controller 1
			icpmxbipcopy = biped.copybippose (GetBipedNode 1).controller copycol #snapview
			-- strBipedPoseCollection = (biped.copyPosture (GetBipedNode 1).controller #pose true true true)
			(GetBipedNode 1).transform.controller.figureMode = true
			biped.pastebippose (GetBipedNode 1).controller icpmxbipcopy false #pstdefault true true true false
			-- biped.pastePosture (GetBipedNode 1).controller #pose false strBipedPoseCollection
			fnAlignBipedFingersToHelper ()
			-- (GetBipedNode 1).transform.controller.figureMode = false
			-- toggleBipedMode.state = false
			biped.deleteCopyCollection (GetBipedNode 1).controller (biped.numCopyCollections (GetBipedNode 1).controller)
	
			pgbBar.value = 95
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

			(GetSkeletalNode 1 false).parent = rootMotionBone
			(GetBipedNode 1).parent = bipedRetargetRM
			rootBone.parent = boneRetargetRM

			fnCopySubBones()
			pgbBar.value = 100

			messageBox "重定向 Biped 创建成功！\r\n\r\n如肩膀匹配不高，\r\n\r\n建议微调两边肩膀手臂和手，\r\n\r\n再点击重新对齐手指骨骼。                         "
		)
		else (messageBox "请先验证并检查映射列表是否完整！                                       ")
	)

    on reAlignFingers pressed do
    (
		if mappingCheckState then
		(
			try(fnAlignBipedFingersToHelper ())
			catch(messageBox "重新对齐手指成功！                            ")
		)
		else (messageBox "请先验证并检查映射列表是否完整！                                       ")
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

    on ckbExportFBXTools changed state do
    (
        bipedBones.visible       = (not state)
        characterBones.visible   = (not state)
        bipedBones_B.visible     = (not state)
        characterBones_B.visible = (not state)

        edtAnimFbxPath.visible       = state
        btnLoadAnimPath.visible      = state
		btnRefreshAnimFiles.visible  = state
        btnOpenCurrentPath.visible   = state
        btnRefreshFolder.visible     = state
        ltbFilesList.visible         = state
        grpExportTools.visible       = state
        btnOutputPath.visible        = state
        edtOutputPath.visible        = state
        edtMappingFile.visible       = state
        btnOpedOutputPath.visible    = state
        btnSelectMappingFile.visible = state
        btnOpenMappingFile.visible   = state
        btnRetargetSelected.visible  = state
        btnRetargettAll.visible      = state
        btnSelectSkinFile.visible    = state
        edtSkinFile.visible          = state
        btnOpenSkinFile.visible      = state
        lblCount.visible             = state
		chkRecoverExport.visible     = state
        -- if state then (fnRefreshDir maxFilePath)
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
					lblCount.text = ("已重定向动画 FBX 数：1 个")
					lblCount.text += ("\r\n\r\n待批处理原始动画 FBX 数：0 个")
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
					for i = 1 to arrExportRetargetAnim.count where (doesFileExist arrExportRetargetAnim[i]) do 
					(
						fnExportReTargrtedAnim arrExportRetargetAnim i
						lblCount.text = ("已重定向动画 FBX 数：" + (i as string) + " 个")
						lblCount.text += ("\r\n\r\n待批处理原始动画 FBX 数：" + (arrExportRetargetAnim.count - i) as string + " 个")
						pgbBar.value = 100.*i/arrExportRetargetAnim.count
					)
					resetMaxFile #noPrompt
					messageBox ("已重定向所有动画，一共 " + (arrExportRetargetAnim.count as string) + " 个,\r\n\r\n在导出目录有相应 .max 和 .FBX 文件                                                ")
				)
			)
		)
	)

	on biped_align_test open do (mappingCheckState = false;pgbBar.value = 0;pgbBar.color = white)

	on btnQuickTools pressed do ( popupmenu menuQuickCreateNode )

	fn getSkin node = if isvalidnode node do
	(
		local sk
		for m in node.modifiers while sk == undefined where iskindof m Skin do sk = m
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
			tarBiped.name = tarBone.name
			tarBone.name = "ReTempNode_" + tarBone.name
			for i in tarBone.children where i != undefined do (i.parent = tarBiped)
			tempParent = tarBone.parent
			tarBiped.parent = tempParent

			if matchpattern tarBiped.name pattern:"NewHip_*" then 
			(
				tarHipBone = getnodebyname (substituteString tarBiped.name "NewHip_" "")
				tarHipBone.children.parent = tarBiped
				tarBiped.parent = tarHipBone.parent
				tarHipBone.parent = tarBiped
			)

			if matchpattern tarBiped.name pattern:"NewPelvis_*" then 
			(
				tarPelvisBone = getnodebyname (substituteString tarBiped.name "NewPelvis_" "")
				tarPelvisBone.children.parent = tarBiped
				tarBiped.parent = tarPelvisBone.parent
				tarPelvisBone.parent = tarBiped
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

			local boneRootMotion = (GetSkeletalNode 1 false).parent

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
			)

			

			fnRenameBiped characterBones.items isB:false
			fnRenameBiped characterBones_B.items isB:true
			
			for g = 1 to arrTarSkinMesh.count do 
			(
				-- print g.name
				local meshSkin = (getSkin arrTarSkinMesh[g])
				meshSkin.always_deform = off
				select arrTarSkinMesh[g]
				modpanel.setcurrentobject meshSkin
				xchangeSkin arrTarSkinMesh[g]
				fnLoadEnvelope meshSkin ((getdir #temp) + "\\" + arrTarSkinMesh[g].name + "_TempSkin.env")
				fnDelFileDir ((getdir #temp) + "\\" + arrTarSkinMesh[g].name + "_TempSkin.env")
				meshSkin.always_deform = on
				pgbBar.value = 30 + (70.*g/(arrTarSkinMesh.count))
			)

			select $'ReTempNode_*'
			selectmore $'RetargetHelper_*'
			delete $

			for g = 1 to arrTarSkinMesh.count do 
			(
				local meshSkin = (getSkin arrTarSkinMesh[g])
				meshSkin.always_deform = off
				meshSkin.always_deform = on
			)

			-- if boneRootMotion != undefined then (if ((getnodebyname "Root" != undefined) and (boneRootMotion.name != "Root")) then (delete $'Root'))

			if (chkRenameBiped.state == false) then 
			(
				(GetBipedNode 1).controller.rootname = bipedRootName
				if boneRootMotion != undefined and (getnodebyname "Root") != undefined then 
				(
					boneRootMotion.children.parent = (getnodebyname "Root")
					delete boneRootMotion
				)
			)

			messagebox "Biped 已替换，且原 Bone 和多余 Helper 已被删除。                                              "
		)
		else (messageBox "请先验证并检查映射列表是否完整！                                       ")
	)
)

createDialog biped_align_test 480 635 style:#(#style_titlebar, #style_minimizebox, #style_sysmenu, #style_resizing) lockHeight:true lockWidth:true



biped_align_test.bipedBones.items = #(
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

biped_align_test.bipedBones_B.items = #(
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

for  i=2 to biped_align_test.bipedBones.items.count do
(
	biped_align_test.characterBones.items = append biped_align_test.characterBones.items "~undefined~"
)

for  i=2 to biped_align_test.bipedBones_B.items.count do
(
	biped_align_test.characterBones_B.items = append biped_align_test.characterBones_B.items "~undefined~"
)