/*
 * @Description: 
 * @Author: Bullet.S
 * @Date: 2022-11-17 13:05:32
 * @LastEditors: Bullet.S
 * @LastEditTime: 2026-05-15 22:20:15
 * @Email: animator.bullet@foxmail.com
 */
-- BipedRigCreator_v3.3.2_Enhanced
-- by: Bullet.S
-- 2022.05

try (destroyDialog rolBsRetarget) catch()
-- try (destroyDialog choose_item_rollout) catch() -- REMOVED: choose_item_rollout does not exist
try (destroyDialog rolHelpDialog) catch()

global rolBsRetarget
global rolHelpDialog

-- ====== SECTION 1: DATA TABLES & STRUCTS ======

global boneNames = #(
	-- ========== 脊椎 / 头 ==========
	"Bip001",                --[1]  质心
	"Pelvis",                --[2]  骨盆
	"Spine",                 --[3]  脊椎
	"Spine1",                --[4]  脊椎1
	"[可选]Spine2",          --[5]  脊椎2
	"[可选]Spine3",          --[6]  脊椎3
	"[可选]Spine4",          --[7]  脊椎4
	"Neck",                  --[8]  颈
	"[可选]Neck1",           --[9]  颈1
	"Head",                  --[10] 头
	"HeadNub",               --[11] 头末端
	-- ========== 左腿 (12-16) ==========
	"L Thigh",               --[12] 左大腿
	"L Calf",                --[13] 左小腿
	"L Foot",                --[14] 左脚
	"L Toe0",                --[15] 左脚趾
	"L Toe0Nub",             --[16] 左脚趾末端
	-- ========== 右腿 (17-21) ==========
	"R Thigh",               --[17] 右大腿
	"R Calf",                --[18] 右小腿
	"R Foot",                --[19] 右脚
	"R Toe0",                --[20] 右脚趾
	"R Toe0Nub",             --[21] 右脚趾末端
	-- ========== 左臂 (22-25) ==========
	"L Clavicle",            --[22] 左锁骨
	"L UpperArm",            --[23] 左上臂
	"L Forearm",             --[24] 左前臂
	"L Hand",                --[25] 左手
	-- ========== 左手指 (26-37) | characterBones 列表末尾 ==========
	"[可选]L Finger0",       --[26] 左拇指0
	"[可选]L Finger01",      --[27] 左拇指1
	"[可选]L Finger02",      --[28] 左拇指2
	"[可选]L Finger0Nub",    --[29] 左拇指末端
	"[可选]L Finger1",       --[30] 左食指0
	"[可选]L Finger11",      --[31] 左食指1
	"[可选]L Finger12",      --[32] 左食指2
	"[可选]L Finger1Nub",    --[33] 左食指末端
	"[可选]L Finger2",       --[34] 左中指0
	"[可选]L Finger21",      --[35] 左中指1
	"[可选]L Finger22",      --[36] 左中指2
	"[可选]L Finger2Nub",    --[37] 左中指末端
	-- ========== 左手指续 (38-45) | characterBones_B 列表开头 ==========
	"[可选]L Finger3",       --[38] 左无名指0
	"[可选]L Finger31",      --[39] 左无名指1
	"[可选]L Finger32",      --[40] 左无名指2
	"[可选]L Finger3Nub",    --[41] 左无名指末端
	"[可选]L Finger4",       --[42] 左小指0
	"[可选]L Finger41",      --[43] 左小指1
	"[可选]L Finger42",      --[44] 左小指2
	"[可选]L Finger4Nub",    --[45] 左小指末端
	-- ========== 右臂 (46-49) ==========
	"R Clavicle",            --[46] 右锁骨
	"R UpperArm",            --[47] 右上臂
	"R Forearm",             --[48] 右前臂
	"R Hand",                --[49] 右手
	-- ========== 右手指 (50-69) ==========
	"[可选]R Finger0",       --[50] 右拇指0
	"[可选]R Finger01",      --[51] 右拇指1
	"[可选]R Finger02",      --[52] 右拇指2
	"[可选]R Finger0Nub",    --[53] 右拇指末端
	"[可选]R Finger1",       --[54] 右食指0
	"[可选]R Finger11",      --[55] 右食指1
	"[可选]R Finger12",      --[56] 右食指2
	"[可选]R Finger1Nub",    --[57] 右食指末端
	"[可选]R Finger2",       --[58] 右中指0
	"[可选]R Finger21",      --[59] 右中指1
	"[可选]R Finger22",      --[60] 右中指2
	"[可选]R Finger2Nub",    --[61] 右中指末端
	"[可选]R Finger3",       --[62] 右无名指0
	"[可选]R Finger31",      --[63] 右无名指1
	"[可选]R Finger32",      --[64] 右无名指2
	"[可选]R Finger3Nub",    --[65] 右无名指末端
	"[可选]R Finger4",       --[66] 右小指0
	"[可选]R Finger41",      --[67] 右小指1
	"[可选]R Finger42",      --[68] 右小指2
	"[可选]R Finger4Nub"     --[69] 右小指末端
)

struct BsBoneSlot (name, group, isOptional, nubType, mirrorIdx)

global kBoneSlots = #(
	-- ========== 脊椎/头 (1-11) ==========
	BsBoneSlot name:"Bip001"         group:#spine    isOptional:false nubType:#none      mirrorIdx:0,   --[1]
	BsBoneSlot name:"Pelvis"         group:#spine    isOptional:false nubType:#none      mirrorIdx:0,   --[2]
	BsBoneSlot name:"Spine"          group:#spine    isOptional:false nubType:#none      mirrorIdx:0,   --[3]
	BsBoneSlot name:"Spine1"         group:#spine    isOptional:false nubType:#none      mirrorIdx:0,   --[4]
	BsBoneSlot name:"Spine2"         group:#spine    isOptional:true  nubType:#none      mirrorIdx:0,   --[5]
	BsBoneSlot name:"Spine3"         group:#spine    isOptional:true  nubType:#none      mirrorIdx:0,   --[6]
	BsBoneSlot name:"Spine4"         group:#spine    isOptional:true  nubType:#none      mirrorIdx:0,   --[7]
	BsBoneSlot name:"Neck"           group:#spine    isOptional:false nubType:#none      mirrorIdx:0,   --[8]
	BsBoneSlot name:"Neck1"          group:#spine    isOptional:true  nubType:#none      mirrorIdx:0,   --[9]
	BsBoneSlot name:"Head"           group:#spine    isOptional:false nubType:#none      mirrorIdx:0,   --[10]
	BsBoneSlot name:"HeadNub"        group:#spine    isOptional:false nubType:#headNub   mirrorIdx:0,   --[11]
	-- ========== 左腿 (12-16) ==========
	BsBoneSlot name:"L Thigh"        group:#lLeg     isOptional:false nubType:#none      mirrorIdx:17,  --[12]
	BsBoneSlot name:"L Calf"         group:#lLeg     isOptional:false nubType:#none      mirrorIdx:18,  --[13]
	BsBoneSlot name:"L Foot"         group:#lLeg     isOptional:false nubType:#none      mirrorIdx:19,  --[14]
	BsBoneSlot name:"L Toe0"         group:#lLeg     isOptional:false nubType:#none      mirrorIdx:20,  --[15]
	BsBoneSlot name:"L Toe0Nub"      group:#lLeg     isOptional:false nubType:#toeNub    mirrorIdx:21,  --[16]
	-- ========== 右腿 (17-21) ==========
	BsBoneSlot name:"R Thigh"        group:#rLeg     isOptional:false nubType:#none      mirrorIdx:12,  --[17]
	BsBoneSlot name:"R Calf"         group:#rLeg     isOptional:false nubType:#none      mirrorIdx:13,  --[18]
	BsBoneSlot name:"R Foot"         group:#rLeg     isOptional:false nubType:#none      mirrorIdx:14,  --[19]
	BsBoneSlot name:"R Toe0"         group:#rLeg     isOptional:false nubType:#none      mirrorIdx:15,  --[20]
	BsBoneSlot name:"R Toe0Nub"      group:#rLeg     isOptional:false nubType:#toeNub    mirrorIdx:16,  --[21]
	-- ========== 左臂 (22-25) ==========
	BsBoneSlot name:"L Clavicle"     group:#lArm     isOptional:false nubType:#none      mirrorIdx:46,  --[22]
	BsBoneSlot name:"L UpperArm"     group:#lArm     isOptional:false nubType:#none      mirrorIdx:47,  --[23]
	BsBoneSlot name:"L Forearm"      group:#lArm     isOptional:false nubType:#none      mirrorIdx:48,  --[24]
	BsBoneSlot name:"L Hand"         group:#lArm     isOptional:false nubType:#none      mirrorIdx:49,  --[25]
	-- ========== 左手指 (26-45): 5指×4段 ==========
	BsBoneSlot name:"L Finger0"      group:#lFinger  isOptional:true  nubType:#none      mirrorIdx:50,  --[26]
	BsBoneSlot name:"L Finger01"     group:#lFinger  isOptional:true  nubType:#none      mirrorIdx:51,  --[27]
	BsBoneSlot name:"L Finger02"     group:#lFinger  isOptional:true  nubType:#none      mirrorIdx:52,  --[28]
	BsBoneSlot name:"L Finger0Nub"   group:#lFinger  isOptional:true  nubType:#fingerNub mirrorIdx:53,  --[29]
	BsBoneSlot name:"L Finger1"      group:#lFinger  isOptional:true  nubType:#none      mirrorIdx:54,  --[30]
	BsBoneSlot name:"L Finger11"     group:#lFinger  isOptional:true  nubType:#none      mirrorIdx:55,  --[31]
	BsBoneSlot name:"L Finger12"     group:#lFinger  isOptional:true  nubType:#none      mirrorIdx:56,  --[32]
	BsBoneSlot name:"L Finger1Nub"   group:#lFinger  isOptional:true  nubType:#fingerNub mirrorIdx:57,  --[33]
	BsBoneSlot name:"L Finger2"      group:#lFinger  isOptional:true  nubType:#none      mirrorIdx:58,  --[34]
	BsBoneSlot name:"L Finger21"     group:#lFinger  isOptional:true  nubType:#none      mirrorIdx:59,  --[35]
	BsBoneSlot name:"L Finger22"     group:#lFinger  isOptional:true  nubType:#none      mirrorIdx:60,  --[36]
	BsBoneSlot name:"L Finger2Nub"   group:#lFinger  isOptional:true  nubType:#fingerNub mirrorIdx:61,  --[37]
	BsBoneSlot name:"L Finger3"      group:#lFinger  isOptional:true  nubType:#none      mirrorIdx:62,  --[38]
	BsBoneSlot name:"L Finger31"     group:#lFinger  isOptional:true  nubType:#none      mirrorIdx:63,  --[39]
	BsBoneSlot name:"L Finger32"     group:#lFinger  isOptional:true  nubType:#none      mirrorIdx:64,  --[40]
	BsBoneSlot name:"L Finger3Nub"   group:#lFinger  isOptional:true  nubType:#fingerNub mirrorIdx:65,  --[41]
	BsBoneSlot name:"L Finger4"      group:#lFinger  isOptional:true  nubType:#none      mirrorIdx:66,  --[42]
	BsBoneSlot name:"L Finger41"     group:#lFinger  isOptional:true  nubType:#none      mirrorIdx:67,  --[43]
	BsBoneSlot name:"L Finger42"     group:#lFinger  isOptional:true  nubType:#none      mirrorIdx:68,  --[44]
	BsBoneSlot name:"L Finger4Nub"   group:#lFinger  isOptional:true  nubType:#fingerNub mirrorIdx:69,  --[45]
	-- ========== 右臂 (46-49) ==========
	BsBoneSlot name:"R Clavicle"     group:#rArm     isOptional:false nubType:#none      mirrorIdx:22,  --[46]
	BsBoneSlot name:"R UpperArm"     group:#rArm     isOptional:false nubType:#none      mirrorIdx:23,  --[47]
	BsBoneSlot name:"R Forearm"      group:#rArm     isOptional:false nubType:#none      mirrorIdx:24,  --[48]
	BsBoneSlot name:"R Hand"         group:#rArm     isOptional:false nubType:#none      mirrorIdx:25,  --[49]
	-- ========== 右手指 (50-69): 5指×4段 ==========
	BsBoneSlot name:"R Finger0"      group:#rFinger  isOptional:true  nubType:#none      mirrorIdx:26,  --[50]
	BsBoneSlot name:"R Finger01"     group:#rFinger  isOptional:true  nubType:#none      mirrorIdx:27,  --[51]
	BsBoneSlot name:"R Finger02"     group:#rFinger  isOptional:true  nubType:#none      mirrorIdx:28,  --[52]
	BsBoneSlot name:"R Finger0Nub"   group:#rFinger  isOptional:true  nubType:#fingerNub mirrorIdx:29,  --[53]
	BsBoneSlot name:"R Finger1"      group:#rFinger  isOptional:true  nubType:#none      mirrorIdx:30,  --[54]
	BsBoneSlot name:"R Finger11"     group:#rFinger  isOptional:true  nubType:#none      mirrorIdx:31,  --[55]
	BsBoneSlot name:"R Finger12"     group:#rFinger  isOptional:true  nubType:#none      mirrorIdx:32,  --[56]
	BsBoneSlot name:"R Finger1Nub"   group:#rFinger  isOptional:true  nubType:#fingerNub mirrorIdx:33,  --[57]
	BsBoneSlot name:"R Finger2"      group:#rFinger  isOptional:true  nubType:#none      mirrorIdx:34,  --[58]
	BsBoneSlot name:"R Finger21"     group:#rFinger  isOptional:true  nubType:#none      mirrorIdx:35,  --[59]
	BsBoneSlot name:"R Finger22"     group:#rFinger  isOptional:true  nubType:#none      mirrorIdx:36,  --[60]
	BsBoneSlot name:"R Finger2Nub"   group:#rFinger  isOptional:true  nubType:#fingerNub mirrorIdx:37,  --[61]
	BsBoneSlot name:"R Finger3"      group:#rFinger  isOptional:true  nubType:#none      mirrorIdx:38,  --[62]
	BsBoneSlot name:"R Finger31"     group:#rFinger  isOptional:true  nubType:#none      mirrorIdx:39,  --[63]
	BsBoneSlot name:"R Finger32"     group:#rFinger  isOptional:true  nubType:#none      mirrorIdx:40,  --[64]
	BsBoneSlot name:"R Finger3Nub"   group:#rFinger  isOptional:true  nubType:#fingerNub mirrorIdx:41,  --[65]
	BsBoneSlot name:"R Finger4"      group:#rFinger  isOptional:true  nubType:#none      mirrorIdx:42,  --[66]
	BsBoneSlot name:"R Finger41"     group:#rFinger  isOptional:true  nubType:#none      mirrorIdx:43,  --[67]
	BsBoneSlot name:"R Finger42"     group:#rFinger  isOptional:true  nubType:#none      mirrorIdx:44,  --[68]
	BsBoneSlot name:"R Finger4Nub"   group:#rFinger  isOptional:true  nubType:#fingerNub mirrorIdx:45   --[69]
)

global pattBipedNames = #(
	#("Bip00?","*Hip","*Hips"),				--1
	#("*Pelvis"),				--2
	#("*Spine","*Waist","*Spine*Lower"),				--3
	#("*Spine1","*Stomach","*Spine*Middle"),			--4
	#("*Spine2","*Chest","*Spine*Upper"),
	#("*Spine3"),
	#("*Spine4"),			--5
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
global bsRootBoneName = "Root"
global bsRootBone

struct BsRetargetOptions
(
	okForceRedraw          = true,
	mappingCheckState      = false,
	hasExtraHips           = false,
	fixNierFramerate       = false,
	isScale100             = false,
	isEulerFilter          = false,
	isReloadBip            = false,
	isHalfAnimSpeed        = false,
	isRemoveRootKeepAnim   = false
)
global gOpts = BsRetargetOptions()

struct BsMappingState
(
	hasRequiredBones = false,
	missingRequired = #(),
	missingOptional = #(),
	hasRoot = false,
	rootNode = undefined,
	duplicateMappings = #(),
	missingSceneNodes = #(),
	canAutoCreateNubs = false,
	canCreateMapping = false,
	canReplaceToBiped = false,
	warnings = #(),
	nextAction = ""
)

global arrExportRetargetAnim = #()
global arrAllBipedNode = #()
global arrAllBipedName = #()

-- 常用提示文本常量
global kMsgTitle           = "BsRetargetTools"
global kMsgCheckMapping    = "请先验证并检查映射列表是否完整！"
global kMsgNoRootBone      = "未找到骨架质心骨骼！请先验证映射列表。"

-- wizardIndex = 1
-- wizardArray = #()

-- creates all of the dummies
headNub = undefined;--point name:"_Helper_Head Nub" wirecolor:(color 0 255 0)
fingerNubs = #(#(undefined, undefined, undefined, undefined, undefined), #(undefined, undefined, undefined, undefined, undefined))

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

-- ===================== P2: 模糊匹配 + 自动映射工具函数 =====================

-- Levenshtein 编辑距离（大小写不敏感）
fn fnLevenshtein s t =
(
	local sLen = s.count
	local tLen = t.count
	if sLen == 0 then return tLen
	if tLen == 0 then return sLen
	local sLow = toLower s
	local tLow = toLower t
	local prev = for k = 0 to tLen collect k
	local curr = for k = 0 to tLen collect 0
	for i = 1 to sLen do
	(
		curr[1] = i
		for j = 1 to tLen do
		(
			local cost = if sLow[i] == tLow[j] then 0 else 1
			curr[j+1] = amin #(prev[j+1]+1, curr[j]+1, prev[j]+cost)
		)
		local tmp = prev; prev = curr; curr = tmp
	)
	prev[tLen+1]
)

-- ====== SECTION 2: UTILITY FUNCTIONS ======

-- 标准化骨骼名：去掉常见前缀/命名空间/分隔符，便于模糊比较
fn fnNormalizeBoneName boneName =
(
	local n = toLower boneName
	-- 去掉常见命名空间前缀
	local prefixes = #("mixamorig:", "character:", "bip001_", "bip01_", "bip_",
	                    "deformationbones:", "skeleton:", "root:")
	for p in prefixes do
	(
		if (findString n p) == 1 then n = substring n (p.count + 1) -1
	)
	-- 去掉分隔符
	n = substituteString n "_" ""
	n = substituteString n "-" ""
	n = substituteString n " " ""
	n = substituteString n "." ""
	n
)

-- 左右骨骼镜像：将名称中的左右标识互换
fn fnMirrorBoneName boneName =
(
	local result = boneName
	-- 精确替换 L/R 标记（按优先级：长 → 短）
	local swapPairs = #(
		#("Left", "Right"), #("left", "right"), #("LEFT", "RIGHT"),
		#("_L_", "_R_"), #("_l_", "_r_"),
		#(".L.", ".R."), #(".l.", ".r."),
		#(" L ", " R "), #(" l ", " r "),
		#("_L", "_R"), #("_l", "_r"),
		#(".L", ".R"), #(".l", ".r"),
		#(" L", " R"), #(" l", " r")
	)
	local swapped = false
	for pair in swapPairs where not swapped do
	(
		if (findString result pair[1]) != undefined then
		(
			result = substituteString result pair[1] pair[2]
			swapped = true
		)
		else if (findString result pair[2]) != undefined then
		(
			result = substituteString result pair[2] pair[1]
			swapped = true
		)
	)
	result
)

-- 左右槽位映射表：kBoneSlots 索引的 L→R 对应关系
-- 左腿 10-14 ↔ 右腿 15-19 (offset +5)
-- 左右镜像对照表（从 kBoneSlots.mirrorIdx 自动生成）
global kLeftRightMap = #()
(
	for i = 1 to kBoneSlots.count where kBoneSlots[i].mirrorIdx > 0 and kBoneSlots[i].mirrorIdx > i do
		append kLeftRightMap #(i, kBoneSlots[i].mirrorIdx)
)

-- 自动识别场景中的骨架类型，返回预设名或 undefined
fn fnDetectSkeletonPreset =
(
	local sceneNameSet = for o in objects collect (toLower o.name)
	-- Mixamo
	if (findItem sceneNameSet "mixamorig:hips") > 0 then return "Mixamo-Standard"
	-- CC4
	if (findItem sceneNameSet "cc_base_hip") > 0 then return "CC4-Standard"
	-- Daz Genesis 8
	if ((findItem sceneNameSet "genesis8female") > 0 or (findItem sceneNameSet "genesis8male") > 0 or \
		((findItem sceneNameSet "hip") > 0 and (findItem sceneNameSet "abdomenlower") > 0)) then return "Daz-Genesis8"
	-- UE Mannequin
	if ((findItem sceneNameSet "pelvis") > 0 and (findItem sceneNameSet "spine_01") > 0) then return "00.Unreal-UE5"
	-- MMD
	if ((findItem sceneNameSet "center") > 0 and (findItem sceneNameSet "upper body") > 0) then return "MMD-Standard"
	return undefined
)

-- 对尚未匹配的槽位，用 Levenshtein 做模糊匹配
-- items: 当前映射数组，sceneNames: 场景骨骼名列表
-- 返回更新后的 items 数组和匹配计数
fn fnFuzzyFillUnmatched items sceneNames threshold:0.55 =
(
	local matchCount = 0
	local usedNames = #()
	-- 收集已占用的名称
	for v in items where v != "~undefined~" do appendIfUnique usedNames v

	for slotIdx = 1 to items.count do
	(
		if items[slotIdx] != "~undefined~" then continue
		local patterns = if slotIdx <= pattBipedNames.count then pattBipedNames[slotIdx] else #()
		if patterns.count == 0 then continue

		-- 从第一个 pattern 提取参考关键字（去掉通配符）
		local canonical = substituteString (substituteString patterns[1] "*" "") "?" ""
		local normCanon = fnNormalizeBoneName canonical

		local bestName = undefined
		local bestScore = 0.0

		for sn in sceneNames where (findItem usedNames sn) == 0 do
		(
			local normSN = fnNormalizeBoneName sn
			local dist = fnLevenshtein normCanon normSN
			local maxLen = amax #(normCanon.count, normSN.count)
			if maxLen == 0 then continue
			local score = 1.0 - (dist as float / maxLen as float)
			if score > bestScore and score >= threshold then
			(
				bestScore = score
				bestName = sn
			)
		)
		if bestName != undefined then
		(
			items[slotIdx] = bestName
			appendIfUnique usedNames bestName
			matchCount += 1
		)
	)
	#(items, matchCount)
)

-- ===================== End P2 工具函数 =====================

global GetSkeletalNode
fn GetSkeletalNode index isFaux findCorrect:true =
(
	if isFaux == false then
	(
		local result = undefined
		if (index < 37 or index == 37) then
		(
			if index >= 1 and index <= rolBsRetarget.characterBones.items.count then result = getNodeByName rolBsRetarget.characterBones.items[index]
		)
		else
		(
			if (index - 37) >= 1 and (index - 37) <= rolBsRetarget.characterBones_B.items.count then result = getNodeByName rolBsRetarget.characterBones_B.items[index-37]
		)
		
		if result == undefined and findCorrect == true then
		(
			case index of
			(
				-- head
				11:  
				(
					result = headNub
				)
				
				-- toe nubs
				16:
				(
					result = toeNubs[1]
				)
				21:
				(
					result = toeNubs[2]
				)
				
				-- Finger nubs
				29:
				(
					result = fingerNubs[1][1]
				)
				33:
				(
					result = fingerNubs[1][2]
				)
				37:
				(
					result = fingerNubs[1][3]
				)
				41:
				(
					result = fingerNubs[1][4]
				)
				45:
				(
					result = fingerNubs[1][5]
				)
				53:
				(
					result = fingerNubs[2][1]
				)
				57:
				(
					result = fingerNubs[2][2]
				)
				61:
				(
					result = fingerNubs[2][3]
				)
				65:
				(
					result = fingerNubs[2][4]
				)
				69:
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
			return getNodeByName ("RTHelper_" + bipedRootName + (if index >= 1 and index <= kBoneSlots.count then kBoneSlots[index].name else ""))
		)
	)
)	

-- ====== SECTION 3: CONTEXT MENUS (rcmenu) ======

rcmenu menuQuickCreateNode
(
	menuItem mItemFixSkinRotation "修复SkinMesh旋转"
	menuItem fixOldList "修复旧映射列表 List"
	menuItem quickMakeParent "快速创建父级骨骼"
    menuItem quickDuplicate "快速创建子级骨骼"
	menuItem quickDuplicateFingers "快速创建 Hand Nub"
    menuItem quickDuplicateFoot "快速创建 Foot Nub"
	menuItem quickDuplicateHead "快速创建 Head Nub"
    menuItem quickCenterRoot "快速创建新的 Hips"
	menuItem tips "说明：根据 Bone 骨骼大腿的位置，" enabled:false
    menuItem tips2 "说明：创建符合 Biped 骨骼位置的质心。" enabled:false

	fn fnDuplicateNub arrID isFoot:false isHead:false =
	(
	for i in arrID do 
	(
		parentNub = (GetSkeletalNode i false)
		nubNode = (GetSkeletalNode (i + 1) false)
		if isvalidnode parentNub and parentNub != undefined and parentNub.parent != undefined and nubNode == undefined then
		(
			local vec = parentNub.pos - parentNub.parent.pos
			if isHead then vec = vec * 3
			local pos = parentNub.pos + (normalize vec) * (length vec)
			if isHead then pos.y = parentNub.pos.y
			if isFoot then pos.z = parentNub.pos.z
			in parentNub nB = bone pos:pos
			nB.name = parentNub.name + " nub"
			if i > 37 then 
			(
				tempItems = rolBsRetarget.characterBones_B.items
				tempItems[i - 37 + 1] = nB.name
				rolBsRetarget.characterBones_B.items = tempItems
			)
			else 
			(
				tempItems = rolBsRetarget.characterBones.items
				tempItems[i+ 1] = nB.name
				rolBsRetarget.characterBones.items = tempItems
			)
			)
			-- else (messageBox kMsgCheckMapping title:kMsgTitle)
		)
	)

	fn fnFixOldMappingList =
	(
		local arrListItemA = rolBsRetarget.characterBones.items
		local arrListItemB = rolBsRetarget.characterBones_B.items

		
		for i = arrListItemB.count to 1 by -1 do 
		(
			arrListItemB[i+2] = arrListItemB[i]
		)

		n = 2
		for i = arrListItemA.count to 1 by -1 do 
		(
			if i >= (arrListItemA.count - 1) then 
			(
				arrListItemB[n] = arrListItemA[i]
				n--
			)
			else if i >= 6 then 
			(
				arrListItemA[i+2] = arrListItemA[i]
			)
		)
		arrListItemA[6] = "~undefined~"
		arrListItemA[7] = "~undefined~"

		deleteitem arrListItemB arrListItemB.count 
		deleteitem arrListItemB arrListItemB.count

		rolBsRetarget.characterBones.items = arrListItemA
		rolBsRetarget.characterBones_B.items = arrListItemB
	)

	fn fnQuickTempRoot =
	(
	try
	(
		local leftLeg = GetSkeletalNode 12 false
		local rightLeg = GetSkeletalNode 17 false

		local hip = GetSkeletalNode 1 false
		local pelvis = GetSkeletalNode 2 false

		if hip == undefined or pelvis == undefined then
		(
			messagebox "未找到质心或盆骨骨骼！请先验证映射列表。" title:kMsgTitle
			return undefined
		)

		if leftLeg == undefined or rightLeg == undefined then
		(
			messagebox "未找到左腿或右腿骨骼！请先验证映射列表。" title:kMsgTitle
			return undefined
		)
		
		local dummyHip = point name:("NewHip_" + hip.name)
		local dummyPelvis = point name:("NewPelvis_" + pelvis.name)

			dummyHip.constantscreensize = false
			dummyHip.size = 0.01

			dummyPelvis.constantscreensize = false
			dummyPelvis.size = 0.01
			
			dummyHip.transform = hip.transform
			dummyHip.pos = 0.5 * (leftLeg.pos + rightLeg.pos)
			dummyPelvis.transform = dummyHip.transform

			dummyHip.parent = hip
			dummyPelvis.parent = pelvis
			
			tempItems = rolBsRetarget.characterBones.items
			tempItems[1] = dummyHip.name
			tempItems[2] = dummyPelvis.name
			rolBsRetarget.characterBones.items = tempItems

			messagebox "已根据大腿重新创建符合 Biped 的质心和盆骨，并且更新了映射列表！                                                          "

			gOpts.hasExtraHips = true
		)
		catch
		(
            messagebox "请先添加骨骼映射！                 "
		)
	)

	fn fnFixSkinRotation =
	(
		local meshes = selection as array
		local tempDir = getDir #temp
		local processedCount = 0
		local failedCount = 0

		for obj in meshes where classof obj == Editable_mesh or classof obj == Editable_Poly do
		(
			local skinMod = undefined
			local skinModIndex = 0
			local boneArray = #()
			local upperMods = #()
			local skinEnvelopeFile = tempDir + "\\" + obj.name + "_skin.env"

			-- 查找 Skin 修改器位置
			for m = 1 to obj.modifiers.count do
			(
				if classof obj.modifiers[m] == Skin then
				(
					skinMod = obj.modifiers[m]
					skinModIndex = m
					exit
				)
			)

			if skinMod != undefined then
			(
				-- 保存 Skin 权重到临时文件(回滚点)
				skinOps.SaveEnvelope skinMod skinEnvelopeFile

				-- 保存骨骼列表
				for b = 1 to skinOps.GetNumberBones skinMod do
				(
					local boneName = skinOps.GetBoneName skinMod b 0
					local boneNode = getNodeByName boneName
					if boneNode != undefined then
						append boneArray boneNode
				)

				try
				(
					-- 创建当前变形状态的快照
					local snapshotMesh = snapshot obj
					snapshotMesh.name = obj.name + "_temp_snapshot"

					local vertCount = snapshotMesh.numverts
					local vertArray = #()
					for v = 1 to vertCount do (append vertArray (getVert snapshotMesh v))
					delete snapshotMesh

					-- 临时移除 Skin 及其上面的所有修改器
					for m = 1 to skinModIndex do
					(
						append upperMods obj.modifiers[1]
						deleteModifier obj 1
					)

					-- 将快照的顶点位置应用到模型
					for v = 1 to obj.numverts do (setVert obj v vertArray[v])
					update obj

					-- 两次 Reset XForm 和塌陷
					addModifier obj (XForm())
					maxOps.CollapseNode obj off
					addModifier obj (XForm())
					maxOps.CollapseNode obj off

					-- 重新添加 Skin 修改器
					local newSkinMod = Skin()
					addModifier obj newSkinMod
					for bone in boneArray do (skinOps.addBone newSkinMod bone 0)

					-- 加载权重
					rolBsRetarget.fnLoadEnvelope newSkinMod skinEnvelopeFile

					-- 恢复 Skin 上面的修改器
					for i = (upperMods.count - 1) to 1 by -1 do
					(
						if classof upperMods[i] != Skin then
						(
							try (addModifier obj (copy upperMods[i])) catch ()
						)
					)

					-- 刷新蒙皮影响
					newSkinMod.enabled = false
					newSkinMod.enabled = true

					processedCount += 1
				)
				catch
				(
					-- 回滚: 尝试恢复 Skin 权重
					format "[BsRetarget] fnFixSkinRotation failed on '%': %\n" obj.name (getCurrentException())
					try
					(
						local sk = undefined
						for m in obj.modifiers where classof m == Skin do (sk = m; exit)
						if sk != undefined and doesFileExist skinEnvelopeFile then
							rolBsRetarget.fnLoadEnvelope sk skinEnvelopeFile
					) catch ()
					failedCount += 1
				)

				-- 清理临时文件
				if doesFileExist skinEnvelopeFile do deleteFile skinEnvelopeFile
			)
		)

		local msg = "已完成 " + processedCount as string + " 个对象的 Skin 旋转修复！"
		if failedCount > 0 do msg += "\n" + failedCount as string + " 个对象处理失败，已尝试回滚。"
		messagebox msg title:kMsgTitle
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
		arrHeadID = #(10)
		fnDuplicateNub arrHeadID isHead:true
	)

	on quickDuplicateFingers picked do 
	(
		arrFingersID = #(28,32,36,40,44,52,56,60,64,68)
		fnDuplicateNub arrFingersID
	)

	on quickDuplicateFoot picked do
	(
		arrFootID = #(15,20)
		fnDuplicateNub arrFootID isFoot:true
	)
	on quickCenterRoot picked do
	(
		fnQuickTempRoot()
	)

	on fixOldList picked do 
	(
		if (queryBox "确认修复旧映射列表？会改变映射 list，请慎重考虑！                                                               " \
		title:(kMsgTitle + " Tips") beep:false) then (fnFixOldMappingList())
	)

	on mItemFixSkinRotation picked do
	(
		if queryBox "需要先旋转骨骼，使模型正面朝前，再执行此操作，\r\n\r\n确认继续请点是。请注意备份文件！                   " title:(kMsgTitle + " Tips") then
		(
			fnFixSkinRotation()
		)
	)
)

rcmenu menuBsRetarget
(
	menuItem mItemEulerFilter "Euler欧拉过滤"
	menuItem mItemHalfAnimSpeed "1/2动画速率"
	menuItem mItemNier "修复 Nier 帧率和缩放"
	menuItem mItemScale100 "仅 Scale 100"
	menuItem mItemReloadBip "重新加载 Biped"
	menuItem mItemRemoveRootKeepAnim "移除 Root 保留动画"

	on menuBsRetarget open do
	(
		mItemNier.checked              = gOpts.fixNierFramerate
		mItemScale100.checked          = gOpts.isScale100
		mItemReloadBip.checked         = gOpts.isReloadBip
		mItemHalfAnimSpeed.checked     = gOpts.isHalfAnimSpeed
		mItemRemoveRootKeepAnim.checked = gOpts.isRemoveRootKeepAnim
	)

	-- 通用菜单切换：翻转 checked 并返回新状态
	fn fnMenuToggle mItem = (mItem.checked = not mItem.checked; mItem.checked)

	on mItemEulerFilter        picked do (gOpts.isEulerFilter        = fnMenuToggle mItemEulerFilter)
	on mItemNier               picked do (gOpts.fixNierFramerate     = fnMenuToggle mItemNier)
	on mItemScale100           picked do (gOpts.isScale100           = fnMenuToggle mItemScale100)
	on mItemReloadBip          picked do (gOpts.isReloadBip          = fnMenuToggle mItemReloadBip)
	on mItemHalfAnimSpeed      picked do (gOpts.isHalfAnimSpeed      = fnMenuToggle mItemHalfAnimSpeed)
	on mItemRemoveRootKeepAnim picked do (gOpts.isRemoveRootKeepAnim = fnMenuToggle mItemRemoveRootKeepAnim)
)

-- ====== SECTION 4: MAIN ROLLOUT UI ======

rollout rolBsRetarget "BsRetargetTools_v5.3 （ FBX 转 BIP + 动画重定向 ）"
(
	local LastSubRollout = 1
	local winW = 655  -- 窗口宽度
	local margin = 8 -- 边距
	local listW = 117 -- 列表宽度
	local rightPanelX = 485 -- 右侧面板起始X
	local rightPanelW = 162 -- 右侧面板宽度
	local btnWidth = 150    -- 按钮宽度
	local listH = 37        -- 列表高度(行数)

	-- ========== 顶部标题区域 ==========
	dotnetcontrol lblTitle "Label" text:"选择Bone，左键填入列表，右键重置，除【可选】外需映射完整，按【1234】顺序执行" pos:[10,3] width:(rightPanelX + 115) height:18
	button btnHelp "?" pos:[(winW - 38),1] width:32 height:20 tooltip:"点击查看使用帮助"
	
	-- ========== Tab 控件 ==========
	dotNetControl tabBsADT "System.Windows.Forms.TabControl" height:30 width:winW pos:[0,23] align:#center
	
	-- ========== Tab1: 预设和Root区域 ==========
	dotnetcontrol lblPreset "Label" text:"[重要] 映射列表和手指轴向配置预设【List】:" pos:[margin,55] width:290 height:17
	dropdownList ddlPreset "" pos:[305,55] width:125 height:20 items:#() selection:1
	button btnApplyList "应用" pos:[435,55] width:38 height:20 tooltip:"右键可打开预设存放文件夹"
	
	dotnetcontrol lblRoot "Label" text:"[必要] 指认原 Bone 骨骼内的根节点【Root】:" pos:[margin,77] width:290 height:17
	listbox lbxRoot "" pos:[305,77] height:1 width:168 items:#("~undefined~") selection:0
	
	-- ========== Tab1: 四个映射列表 ==========
	listbox bipedBones "Bip 节点 1-37" pos:[margin,100] height:listH width:listW selection:0 items:#("Biped Root", "Biped Pelvis", "Biped Spine 0", "Biped Spine 1")
	listbox characterBones "Bone 骨骼 1-37" pos:[margin+listW+2,100] height:listH width:listW items:#("~undefined~") selection:0
	listbox bipedBones_B "Bip 节点 38-69" pos:[margin+listW*2+4,100] height:listH width:listW selection:0 items:#("Biped Root", "Biped Pelvis", "Biped Spine 0", "Biped Spine 1")
	listbox characterBones_B "Bone 骨骼 38-69" pos:[margin+listW*3+6,100] height:listH width:listW items:#("~undefined~") selection:0
	
	local switchFBXTools = false
	local arrSaveVer = (for i = 0 to 3 collect ("20" + (((maxversion())[1]/1000)-2-i) as string))

	-- ========== 右侧面板: 便捷工具区 ==========
	groupbox grpRetargetList "便捷工具" pos:[rightPanelX,53] width:rightPanelW height:75
	spinner spnObjSize "Size:" pos:[rightPanelX+8,72] range:[0.01,1000,5] align:#left fieldwidth:45 scale:0.01 tooltip:"设置辅助骨骼显示大小"
	button btnResetSize "重置大小" pos:[rightPanelX+95,70] width:60 height:20 tooltip:"重置选中辅助骨骼大小"
	button btnQuickTools "快速便捷小工具" pos:[rightPanelX+5,95] width:(btnWidth) height:28 tooltip:"快速创建 nub 骨骼或符合 Biped 的质心"
	
	-- ========== 右侧面板: 轴向设置区 ==========
	groupbox grpBiped "【可选】轴向设置" pos:[rightPanelX,132] width:rightPanelW height:175
	label lblUpAxis "引擎:" pos:[rightPanelX+8,150] width:35 height:16
	dropdownList ddlUpAxis "" pos:[rightPanelX+42,148] width:112 height:20 items:#("Y-Up (Unity)","Z-Up (Unreal)") selection:2
	button btnHandAxisTips "手指轴向说明" pos:[rightPanelX+5,172] width:(btnWidth) height:22 tooltip:"点击查看手指轴向设置说明"
	
	-- 轴向设置：左右并排布局
	label lblLeftHand "左手" pos:[rightPanelX+58,196] width:40 height:14
	label lblRightHand "右手" pos:[rightPanelX+108,196] width:40 height:14
	
	label lblThumbAxis "拇指:" pos:[rightPanelX+10,214] width:40 height:16
	dropdownList ddlThumbAxis "" pos:[rightPanelX+50,211] width:50 height:20 items:#("X","Y","Z","-X","-Y","-Z") selection:3
	dropdownList ddlThumbAxis2 "" pos:[rightPanelX+103,211] width:50 height:20 items:#("X","Y","Z","-X","-Y","-Z") selection:3
	
	label lblHandAxis "四指:" pos:[rightPanelX+10,237] width:40 height:16
	dropdownList ddlHandAxis "" pos:[rightPanelX+50,234] width:50 height:20 items:#("X","Y","Z","-X","-Y","-Z") selection:3
	dropdownList ddlHandAxis2 "" pos:[rightPanelX+103,234] width:50 height:20 items:#("X","Y","Z","-X","-Y","-Z") selection:3
	
	label lblPalmAxis "手掌:" pos:[rightPanelX+10,260] width:40 height:16
	dropdownList ddlPalmAxis "" pos:[rightPanelX+50,257] width:50 height:20 items:#("X","Y","Z","-X","-Y","-Z") selection:3
	dropdownList ddlPalmAxis2 "" pos:[rightPanelX+103,257] width:50 height:20 items:#("X","Y","Z","-X","-Y","-Z") selection:3
	
	-- 隐藏的占位标签（保持兼容性）
	label lblThumbAxis2 "" pos:[9999,9999] width:0 height:0
	label lblHandAxis2 "" pos:[9999,9999] width:0 height:0
	label lblPalmAxis2 "" pos:[9999,9999] width:0 height:0
	
	button reAlignFingers "重新对齐手指" pos:[rightPanelX+5,282] width:(btnWidth) height:20 tooltip:"重新对齐手指骨骼方向"
	
	-- ========== 右侧面板: 慎用区域 ==========
	groupbox grpBoneTips "【慎用】高级选项" pos:[rightPanelX,312] width:rightPanelW height:110
	checkbox chkRealign "重置 Bone 轴向" pos:[rightPanelX+8,332] height:16 width:(btnWidth-10) checked:false tooltip:"勾选后会重置 Bone 轴向（慎用，影响蒙皮）"
	button btnConvertToBone "Helper 转 Bone" pos:[rightPanelX+5,352] height:22 width:(btnWidth) tooltip:"需要选中 Helper 对象"
	checkbox chkCopySubs "重定向飘带动画" pos:[rightPanelX+8,378] height:16 width:(btnWidth-10) checked:false tooltip:"同时复制飘带/裙摆等非Biped骨骼动画"
	checkbox chkFbxMixBip "FBX 套接 Biped" pos:[rightPanelX+8,398] height:16 width:(btnWidth-10) checked:false tooltip:"慎用！保留原骨骼套接Biped，Skin无法重定向"
	
	-- ========== 右侧面板: 底部操作按钮 ==========
	groupbox grpRightBtns "操作" pos:[rightPanelX,427] width:rightPanelW height:220
	button btnAutoMapping "1.自动匹配" pos:[rightPanelX+5,445] width:(btnWidth) height:26 tooltip:"根据通用骨骼名称自动匹配"
	button loadDialogue "加载列表" pos:[rightPanelX+5,474] width:72 height:20 tooltip:"加载映射列表文件"
	button saveDialogue "保存列表" pos:[rightPanelX+80,474] width:72 height:20 tooltip:"保存映射列表文件"
	button btnMirrorSync "左右同步" pos:[rightPanelX+5,496] width:72 height:20 tooltip:"将左侧映射镜像到右侧（或反向）"
	button btnUndo "撤销" pos:[rightPanelX+80,496] width:72 height:20 tooltip:"撤销上一次映射操作"
	button btnPickBone "视口拾取" pos:[rightPanelX+5,518] width:(btnWidth) height:20 tooltip:"点击开启/关闭视口拾取模式\n在视口点选骨骼自动填入空槽位\n右键按钮=跳过当前槽 | Esc=退出"
	dotNetControl lblStatusBar "Label" pos:[rightPanelX+5,540] width:(btnWidth) height:14
	timer tmrPickMode "" interval:150 active:false
	button validateButton "2.验证映射" pos:[rightPanelX+5,557] width:(btnWidth) height:26 tooltip:"验证映射列表是否完整"
	button alignBipedToHelper "3.创建映射文件" pos:[rightPanelX+5,586] width:(btnWidth) height:26 tooltip:"创建重定向映射中间文件"
	button btnReplaceToBiped "4.FBX转Biped" pos:[rightPanelX+5,615] width:(btnWidth) height:30 tooltip:"将 FBX 骨骼转换为 Biped"

	-- ========== Tab2: 动画重定向界面 (初始隐藏) ==========
	listBox ltbFilesList "" selection:0 height:40 width:225 pos:[margin,55] visible:false

	button btnRefreshFolder ">>  刷新路径和文件  <<" \
	height:28 width:213 pos:[245,55] tooltip:"刷新当前文件目录\n并按默认规则寻找文件" visible:false
	
	button btnLoadAnimPath "选择动画目录" tooltip:"选择原始动画目录" \
	height:20 width:105 pos:[245,88] visible:false
	button btnRefreshAnimFiles "刷新" height:20 width:50 pos:[354,88] visible:false
	button btnOpenCurrentPath "打开" tooltip:"打开当前文件夹" \
	height:20 width:50 pos:[408,88] border:true visible:false
	editText edtAnimFbxPath "" text:"" labelOnTop:true \
	height:18 fieldWidth:213 pos:[245,112] readOnly:true visible:false
	
	button btnOutputPath "选择导出目录" pos:[245,136] width:155 height:20 visible:false \
	tooltip:"导出的重定向动画 FBX 保存目录"
	button btnOpedOutputPath "打开" pos:[408,136] width:50 height:20 visible:false \
	tooltip:"打开重定向文件导出目录"
	editText edtOutputPath "" text:"" labelOnTop:true \
	height:18 fieldWidth:213 pos:[245,160] readOnly:true visible:false
	
	button btnSelectMappingFile "选择映射文件" pos:[245,184] width:155 height:20 visible:false \
	tooltip:"选择以 Bone 骨架生成的 Biped 映射文件"
	button btnOpenMappingFile "打开" pos:[408,184] width:50 height:20 visible:false \
	tooltip:"打开映射文件"
	editText edtMappingFile "" text:"" labelOnTop:true \
	height:18 fieldWidth:213 pos:[245,208] readOnly:true visible:false
	
	button btnSelectSkinFile "选择新Skin文件" pos:[245,232] width:155 height:20 visible:false \
	tooltip:"选择新的 Skin 文件"
	button btnOpenSkinFile "打开" pos:[408,232] width:50 height:20 visible:false \
	tooltip:"打开新 Skin 文件"
	editText edtSkinFile "" text:"" labelOnTop:true \
	height:18 fieldWidth:213 pos:[245,256] readOnly:true visible:false

	checkbox chkRecoverExport "不覆盖导出(崩溃后继续)" checked:false pos:[250,282] width:200 height:16 visible:false
	button btnSpecial "[自用]后处理" pos:[245,303] width:95 height:22 visible:false border:true
	label lblVerTips "版本:" pos:[348,307] width:32 height:16 visible:false
	dropdownList ddlSaveVersion "" pos:[382,304] width:55 items:arrSaveVer visible:false
	
	button btnRetargetSelected ">>>  重定向选中动画  <<<" pos:[245,332] width:213 height:28 visible:false \
	tooltip:"重定向列表选中的动画\n会保存 .max 和 .FBX 文件"
	button btnRetargettAll ">>>  重定向所有动画  <<<" pos:[245,365] width:213 height:28 visible:false \
	tooltip:"重定向列表所有动画\n可能比较慢..."

	checkbox chkXAxis "X" pos:[250,400] width:32 height:18 visible:false
	checkbox chkYAxis "Y" pos:[285,400] width:32 height:18 visible:false
	checkbox chkZAxis "Z" pos:[320,400] width:32 height:18 visible:false
	button btnBatchAll "清零Root位移" pos:[358,398] width:100 height:20 visible:false border:false tooltip:"清零Root位移曲线"
	
	button btnCount "待处理: 0 个" pos:[margin,585] width:225 height:26 visible:false border:true tooltip:"打开原始动画 FBX 文件夹"

	-- Tab2 右侧操作区
	-- groupbox grpTab2Right "设置和说明" pos:[rightPanelX-15,55] width:(rightPanelW+15) height:550 visible:false
	edittext edtAllTips text:"【说明】\n映射文件=FBX转Biped中间文件\nSkin文件=最终蒙皮文件\n\n目录结构:\n - Skin.max\n - AniFBX/\n - ReOutput/\n\n【操作流程】\n1. 打开映射文件\n2. 刷新路径\n3. 选择动画目录\n4. 选择导出目录\n5. 选择映射文件\n6. 选择Skin文件\n7. 批量重定向" \
	pos:[rightPanelX-25,55] height:520 width:(rightPanelW+20) readOnly:true visible:false

	-- ========== 进度条区域 ==========
	progressbar pgbBar "" pos:[margin,652] width:(winW-55) height:16 color:white
	label lblBarValue "0 %" pos:[(winW-40),653] width:38

	-- Tab1 控件列表: FBX 转 Biped
	local arrFBXtoBIPED = #(">> 【 FBX 转 Biped 】 <<",#(
		lblPreset,ddlPreset,btnApplyList,lblRoot,lbxRoot,
		bipedBones,characterBones,bipedBones_B,characterBones_B,
		grpRetargetList,spnObjSize,btnResetSize,btnQuickTools,
		grpBiped,lblUpAxis,ddlUpAxis,btnHandAxisTips,
		lblLeftHand,lblRightHand,
		lblThumbAxis,ddlThumbAxis,ddlThumbAxis2,
		lblHandAxis,ddlHandAxis,ddlHandAxis2,
		lblPalmAxis,ddlPalmAxis,ddlPalmAxis2,
		lblThumbAxis2,lblHandAxis2,lblPalmAxis2,
		reAlignFingers,
		grpBoneTips,chkRealign,btnConvertToBone,chkCopySubs,chkFbxMixBip,
		grpRightBtns,btnAutoMapping,loadDialogue,saveDialogue,btnMirrorSync,btnUndo,btnPickBone,lblStatusBar,validateButton,alignBipedToHelper,btnReplaceToBiped
	))
	-- Tab2 控件列表: 动画重定向
	local arrAnimRetarget = #(">> 【 动画重定向 】<<",#(
		btnRefreshFolder,ltbFilesList,
		btnLoadAnimPath,btnRefreshAnimFiles,btnOpenCurrentPath,edtAnimFbxPath,
		btnOutputPath,btnOpedOutputPath,edtOutputPath,
		btnSelectMappingFile,btnOpenMappingFile,edtMappingFile,
		btnSelectSkinFile,btnOpenSkinFile,edtSkinFile,
		chkRecoverExport,btnSpecial,lblVerTips,ddlSaveVersion,
		btnRetargetSelected,btnRetargettAll,
		chkXAxis,chkYAxis,chkZAxis,btnBatchAll,btnCount,
		edtAllTips
	))
	local arrAllToolsTab = #(arrFBXtoBIPED,arrAnimRetarget)

	local pathMappingListPreset = ((getDir #scripts) + "\\BulletScripts\\Res\\BsMappingList\\")
	local arrMappingListFile = #()
	local fileMappingList

	fn fnRefreshMappingFile =
	(
		local arrMappingFile = #()
		local arrMappingFileName = #()
		if ((pathMappingListPreset != "") and (doesDirectoryExist pathMappingListPreset)) then
		(
			arrMappingFile =  (getfiles (pathMappingListPreset + "*.list"))
			arrMappingFileName = for i in arrMappingFile collect (getFilenameFile i)
		)
		ddlPreset.items = arrMappingFileName
		return arrMappingFile
	)

	-- ====== SECTION 5: CORE LOGIC FUNCTIONS ======

	fn fnShowBlockedAction actionName reason =
	(
		messagebox (actionName + "\r\n\r\n原因：" + reason) title:kMsgTitle
	)

	fn fnIsOptionalNodeIndex id =
	(
		if id >= 1 and id <= kBoneSlots.count then kBoneSlots[id].isOptional
		else false
	)

	fn fnEnsureMappingListLengths =
	(
		local arrA = characterBones.items
		local arrB = characterBones_B.items
		while arrA.count < 37 do append arrA "~undefined~"
		while arrB.count < 32 do append arrB "~undefined~"
		if arrA.count > 37 do arrA = for i = 1 to 37 collect arrA[i]
		if arrB.count > 32 do arrB = for i = 1 to 32 collect arrB[i]
		characterBones.items = arrA
		characterBones_B.items = arrB
	)

	fn fnSetListItem index value =
	(
		fnEnsureMappingListLengths()
		if index >= 1 and index <= 37 then
		(
			local arr = characterBones.items
			arr[index] = value
			characterBones.items = arr
		)
		else if index >= 38 and index <= 69 then
		(
			local arr = characterBones_B.items
			arr[index - 37] = value
			characterBones_B.items = arr
		)
	)

	fn fnGetListItem index =
	(
		fnEnsureMappingListLengths()
		if index >= 1 and index <= 37 then characterBones.items[index]
		else if index >= 38 and index <= 69 then characterBones_B.items[index - 37]
		else "~undefined~"
	)

	fn fnLoadMappingList f quiet:false =
	(
		if f == undefined or not (doesFileExist f) then
		(
			fnShowBlockedAction "当前不能加载 List。" "文件不存在。"
			return false
		)

		local fS = openFile f mode:"r"
		if fS == undefined then
		(
			fnShowBlockedAction "当前不能加载 List。" "文件无法打开。"
			return false
		)

		local arrA = for slotIndex = 1 to 37 collect "~undefined~"
		local arrB = for slotIndex = 1 to 32 collect "~undefined~"
		lbxRoot.items = #("~undefined~")
		lbxRoot.selection = 0

		-- 读取首行判断版本
		local fileVersion = 1
		local firstLine = readLine fS
		if firstLine == "v2" then
			fileVersion = 2
		else
		(
			-- Legacy: firstLine 是第一个骨骼名，需回退重读
			close fS
			fS = openFile f mode:"r"
		)

		local i = 1
		local lineCount = 0

		while (eof fS) == false do
		(
			local newValue = readLine fS
			lineCount += 1

			if (i <= 37) then
				arrA[i] = newValue
			else if (i <= 69) then
				arrB[i - 37] = newValue
			else if (i == 70) then (lbxRoot.items = #(newValue))
			else if (i == 71) then (try(ddlThumbAxis.selection = (newValue as integer))catch())
			else if (i == 72) then (try(ddlHandAxis.selection = (newValue as integer))catch())
			else if (i == 73) then (try(ddlThumbAxis2.selection = (newValue as integer))catch())
			else if (i == 74) then (try(ddlHandAxis2.selection = (newValue as integer))catch())
			else if (i == 75) then (try(ddlPalmAxis.selection = (newValue as integer))catch())
			else if (i == 76) then (try(ddlPalmAxis2.selection = (newValue as integer))catch())

			i += 1
		)

		close fS
		characterBones.items = arrA
		characterBones_B.items = arrB
		if lineCount < 69 then
		(
			if (queryBox "List文件是老版本,是否 \"修复旧映射列表\" ,注意重新保存列表！                                                                     " \
			title:(kMsgTitle + " Tips") beep:false) then (menuQuickCreateNode.fnFixOldMappingList())
		)
		else if lineCount < 76 then
		(
			messagebox "List文件是老版本,注意另存一份新版,包括手和手指轴向设置！(当前不影响使用)                                                                     "
		)
		else if not quiet then (messagebox "加载成功！                       ")
		true
	)

	-- ========== Mapping State / Root Resolution / Action Guards ==========
	fn fnBuildAllMappingItems =
	(
		fnEnsureMappingListLengths()
		characterBones.items + characterBones_B.items
	)

	fn fnGetCurrentRootName =
	(
		if lbxRoot.items.count > 0 then lbxRoot.items[1] else "~undefined~"
	)

	fn fnSetRootNode rootNode =
	(
		if rootNode != undefined and isValidNode rootNode then
		(
			bsRootBone = rootNode
			lbxRoot.items = #(rootNode.name)
			lbxRoot.selection = 0
			true
		)
		else false
	)

	fn fnResolveRootBone allItems =
	(
		local rootName = fnGetCurrentRootName()
		if rootName != "~undefined~" do
		(
			local listedRoot = getNodeByName rootName
			if listedRoot != undefined and isValidNode listedRoot do return listedRoot
		)

		if allItems != undefined and allItems.count >= 1 and allItems[1] != "~undefined~" do
		(
			local comNode = getNodeByName allItems[1]
			if comNode != undefined and isValidNode comNode and comNode.parent != undefined do return comNode.parent
		)

		local rootCandidates = #("Root", "root", "ROOT", "Armature", "Skeleton", "Bip001", "Bip01", "Hips", "Character")
		for candidateName in rootCandidates do
		(
			local candidate = getNodeByName candidateName
			if candidate != undefined and isValidNode candidate do return candidate
		)

		undefined
	)

	fn fnResolveAndSetRoot =
	(
		local rootNode = fnResolveRootBone (fnBuildAllMappingItems())
		if rootNode != undefined then fnSetRootNode rootNode
		else false
	)

	fn fnBuildMappingState =
	(
		local allItems = fnBuildAllMappingItems()
		local state = BsMappingState()
		local usedNames = #()

		for i = 1 to allItems.count do
		(
			local item = allItems[i]
			if item == "~undefined~" then
			(
				if fnIsOptionalNodeIndex i then append state.missingOptional i
				else append state.missingRequired i
			)
			else
			(
				local foundNode = getNodeByName item
				if foundNode == undefined then append state.missingSceneNodes #(i, item)
				if findItem usedNames item > 0 then append state.duplicateMappings #(i, item)
				else append usedNames item
			)
		)

		state.rootNode = fnResolveRootBone allItems
		state.hasRoot = (state.rootNode != undefined and isValidNode state.rootNode)
		state.hasRequiredBones = (state.missingRequired.count == 0 and state.missingSceneNodes.count == 0)
		state.canAutoCreateNubs = true
		state.canCreateMapping = (state.hasRequiredBones and state.hasRoot)
		state.canReplaceToBiped = state.canCreateMapping

		if not state.hasRoot then state.nextAction = "请先指定或自动识别 Root。"
		else if state.missingRequired.count > 0 then state.nextAction = "请补齐必需骨骼映射。"
		else if state.missingSceneNodes.count > 0 then state.nextAction = "映射列表中有场景不存在的节点。"
		else state.nextAction = "可以继续下一步。"

		state
	)

	fn fnShowBlockedByState actionName state =
	(
		local reason = if state != undefined and state.nextAction != "" then state.nextAction else "当前状态不安全。"
		fnShowBlockedAction actionName reason
	)

	fn fnValidateRetargetInputs requireSelection:false =
	(
		if edtAnimFbxPath.text == edtOutputPath.text then
		(
			fnShowBlockedAction "当前不能批量重定向。" "导出路径不能和原动画 FBX 路径相同。"
			return false
		)
		if not (doesFileExist edtSkinFile.text) then
		(
			fnShowBlockedAction "当前不能批量重定向。" "Skin 文件不存在。"
			return false
		)
		if arrExportRetargetAnim.count == 0 then
		(
			fnShowBlockedAction "当前不能批量重定向。" "动画列表为空，请先刷新动画目录。"
			return false
		)
		if requireSelection and ltbFilesList.selection == 0 then
		(
			fnShowBlockedAction "当前不能批量重定向。" "请先在动画列表中选择一个文件。"
			return false
		)
		true
	)

	-- 映射撤销栈
	local mappingUndoStack = #()
	local pickModeActive = false
	local pickModeSlot = 0
	local pickModeCount = 0
	local pickModeGuard = false
	local kUndoMax = 20

	fn fnPushMappingUndo =
	(
		local state = #(
			deepCopy characterBones.items,
			deepCopy characterBones_B.items,
			deepCopy lbxRoot.items
		)
		append mappingUndoStack state
		if mappingUndoStack.count > kUndoMax then deleteItem mappingUndoStack 1
	)

	fn fnPopMappingUndo =
	(
		if mappingUndoStack.count == 0 then
		(
			messagebox "没有可撤销的操作。" title:kMsgTitle beep:false
			return false
		)
		local state = mappingUndoStack[mappingUndoStack.count]
		deleteItem mappingUndoStack mappingUndoStack.count
		characterBones.items = state[1]
		characterBones_B.items = state[2]
		lbxRoot.items = state[3]
		true
	)

	-- 映射状态栏更新
	fn fnUpdateStatusBar =
	(
		local filled = 0; local reqMissing = 0; local optMissing = 0
		local allItems = fnBuildAllMappingItems()
		for i = 1 to allItems.count do
		(
			local val = allItems[i]
			if val != "~undefined~" then filled += 1
			else if fnIsOptionalNodeIndex i then optMissing += 1
			else reqMissing += 1
		)
		local rootNode = fnResolveRootBone allItems
		local hasRoot = (rootNode != undefined and isValidNode rootNode)
		local rootOK = if hasRoot then "Root:OK" else "Root:?"
		local nextAction = case of
		(
			(not hasRoot): "请先指定或自动识别 Root。"
			(reqMissing > 0): "请补齐必需骨骼映射。"
			default: "可以继续下一步。"
		)
		lblStatusBar.Text = ("已映射:" + filled as string + "  必需缺失:" + reqMissing as string +
							   "  可选缺失:" + optMissing as string + "  " + rootOK + "  |  " + nextAction)
		local dotColor = dotNetClass "System.Drawing.Color"
		lblStatusBar.ForeColor = case of
		(
			(not hasRoot):          (dotColor.FromArgb 220 120 20)
			(reqMissing > 0):       (dotColor.FromArgb 200 40 40)
			(optMissing > 0):       (dotColor.FromArgb 180 160 20)
			default:                (dotColor.FromArgb 40 160 60)
		)
	)

	fn fnLoadMappingListAndRefresh f pushUndo:false quiet:false =
	(
		if pushUndo do fnPushMappingUndo()
		if fnLoadMappingList f quiet:quiet then
		(
			fnResolveAndSetRoot()
			fnUpdateStatusBar()
			true
		)
		else false
	)

	-- ========== 视口拾取模式 ==========
	fn fnPickModeNextEmpty startFrom skipOptional:true =
	(
		for i = startFrom to 69 do
			if (fnGetListItem i) == "~undefined~" and (not skipOptional or not (fnIsOptionalNodeIndex i)) then return i
		0
	)

	fn fnPickModeHighlightSlot slot =
	(
		if slot >= 1 and slot <= 37 then
		(
			characterBones.selection = slot
			characterBones_B.selection = 0
			bipedBones.selection = slot
			bipedBones_B.selection = 0
		)
		else if slot >= 38 and slot <= 69 then
		(
			characterBones.selection = 0
			characterBones_B.selection = slot - 37
			bipedBones.selection = 0
			bipedBones_B.selection = slot - 37
		)
	)

	fn fnPickModeUpdateStatus =
	(
		if not pickModeActive then return undefined
		local slotName = if pickModeSlot >= 1 and pickModeSlot <= kBoneSlots.count then kBoneSlots[pickModeSlot].name else ("Slot " + pickModeSlot as string)
		btnPickBone.text = "[拾取中] " + pickModeCount as string + "个"
		lblStatusBar.Text = (">> " + slotName + "  |  点选骨骼填入 / 右键跳过 / Esc退出")
		lblStatusBar.ForeColor = ((dotNetClass "System.Drawing.Color").FromArgb 30 90 180)
	)

	fn fnPickModeExit =
	(
		pickModeActive = false
		pickModeGuard = false
		tmrPickMode.active = false
		callbacks.removeScripts id:#bsPickMode
		btnPickBone.text = "视口拾取"
		fnUpdateStatusBar()
	)

	fn fnPickModeAdvance =
	(
		local nextSlot = fnPickModeNextEmpty (pickModeSlot + 1)
		if nextSlot == 0 then
		(
			local msg = "所有槽位已填满！共填入 " + pickModeCount as string + " 个骨骼"
			fnPickModeExit()
			messagebox msg title:kMsgTitle beep:false
			return undefined
		)
		pickModeSlot = nextSlot
		fnPickModeHighlightSlot nextSlot
		fnPickModeUpdateStatus()
	)

	fn fnPickModeSelect =
	(
		if not pickModeActive or pickModeGuard then return undefined
		pickModeGuard = true
		local sel = selection as array
		if sel.count == 1 then
		(
			fnPushMappingUndo()
			fnSetListItem pickModeSlot sel[1].name
			pickModeCount += 1
			fnPickModeAdvance()
		)
		pickModeGuard = false
	)

	fn fnPickModeEnter =
	(
		local startSlot = 0
		if bipedBones.selection > 0 then startSlot = bipedBones.selection
		else if bipedBones_B.selection > 0 then startSlot = bipedBones_B.selection + 37
		else if characterBones.selection > 0 then startSlot = characterBones.selection
		else if characterBones_B.selection > 0 then startSlot = characterBones_B.selection + 37

		if startSlot > 0 and (fnGetListItem startSlot) != "~undefined~" then
			startSlot = fnPickModeNextEmpty startSlot
		else if startSlot == 0 then
			startSlot = fnPickModeNextEmpty 1

		if startSlot == 0 then
		(
			messagebox "所有槽位已填满！" title:kMsgTitle beep:false
			return undefined
		)

		pickModeActive = true
		pickModeSlot = startSlot
		pickModeCount = 0
		fnPickModeHighlightSlot startSlot
		fnPickModeUpdateStatus()
		callbacks.addScript #selectionSetChanged "if rolBsRetarget != undefined do rolBsRetarget.fnPickModeSelect()" id:#bsPickMode
		tmrPickMode.active = true
	)

	fn fnInitDotTabs =
	(
		-- 设置标签字体和样式
		local dotFont = dotnetobject "System.Drawing.Font" "Microsoft YaHei UI" 8.5
		lblTitle.font = lblPreset.font = lblRoot.font = lblStatusBar.font = dotFont
		lblStatusBar.BackColor = (dotNetClass "System.Drawing.Color").Transparent
		lblTitle.TextAlign = lblPreset.TextAlign = lblRoot.TextAlign = (dotnetclass "system.drawing.contentalignment").MiddleLeft
		
		-- 设置标签颜色
		local tipsBgColor = (dotColor.FromArgb 220 230 240)
		local tipsFgColor = (dotColor.FromArgb 50 80 120)
		lblTitle.BackColor = tipsBgColor
		lblTitle.ForeColor = tipsFgColor
		lblPreset.BackColor = lblRoot.BackColor = (dotColor.FromArgb 245 245 245)
		lblPreset.ForeColor = lblRoot.ForeColor = (dotColor.FromArgb 80 80 80)
		
		-- 设置 Tab 控件
		tabBsADT.SizeMode = (dotnetclass "System.Windows.Forms.TabSizeMode").Fixed
		tabBsADT.ItemSize = dotNetObject "System.Drawing.Size" (winW/arrAllToolsTab.count - arrAllToolsTab.count) 30
		tabBsADT.Dock = (dotNetClass "System.Windows.Forms.DockStyle").Fill
		tabBsADT.DrawMode = (dotNetClass "System.Windows.Forms.TabDrawMode").OwnerDrawFixed

		-- 添加 Tab 页
		for aTab = 1 to arrAllToolsTab.count do
		(
			tabBsADT.TabPages.add arrAllToolsTab[aTab][1]
		)
	)

	fn fnChangeToolsVisble id =
	(
		-- 切换 Tab 页显示
		for i = 1 to arrAllToolsTab.count do 
		(
			if i == id then
			(
				for j in arrAllToolsTab[i][2] do j.visible = true
			)
			else 
			(
				for j in arrAllToolsTab[i][2] do j.visible = false
			)
		)

		-- Tab1 时显示预设和Root标签
		if id == 1 then 
		(
			lblPreset.pos = [margin,55]
			lblRoot.pos = [margin,77]
		)
		else 
		(
			lblPreset.pos = lblRoot.pos = [9999,9999]
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
		(fnGetListItem index) == "~undefined~"
	)


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
		return undefined
	)

	global _bipedCacheDirty = true
	fn fnInvalidateBipedCache = (_bipedCacheDirty = true)

	global GetBipedNode
	fn GetBipedNode index =
	(
		-- 缓存脏、为空、或引用已删除对象时重建
		if _bipedCacheDirty or arrAllBipedNode.count == 0 or (not isValidNode arrAllBipedNode[1]) then
		(
			local rootBip = fnGetRootNode()
			if rootBip != undefined then
			(
				clearselection()
				select rootBip
				fnSelectChildrens rootBip
				arrAllBipedNode = (selection as array)
				arrAllBipedName = for i in arrAllBipedNode collect i.name
				_bipedCacheDirty = false
			)
		)

		if (index == 1) then
		(
			return fnGetRootNode()
		)
		else if (index <= 37) then
		(
			local targetBiped = undefined
			local idTargetBiped = 0
			if index >= 1 and index <= rolBsRetarget.bipedBones.items.count then
			(
	            local strTargetBiped = (bipedRootName + " " + (substituteString rolBsRetarget.bipedBones.items[index] "[可选]" ""))
				idTargetBiped = finditem arrAllBipedName strTargetBiped
				if idTargetBiped != 0 then
				(
					targetBiped = arrAllBipedNode[idTargetBiped]
	            	targetBiped.boxmode = true
				)
			)
			return targetBiped
		)
		else
		(
			local targetBiped = undefined
			local idTargetBiped = 0
			local idxB = index - 37
			if idxB >= 1 and idxB <= rolBsRetarget.bipedBones_B.items.count then
			(
	            local strTargetBiped =(bipedRootName + " " + (substituteString rolBsRetarget.bipedBones_B.items[idxB] "[可选]" ""))
				idTargetBiped = finditem arrAllBipedName strTargetBiped
				if idTargetBiped != 0 then
				(
					targetBiped = arrAllBipedNode[idTargetBiped]
					targetBiped.boxmode = true
				)
			)
			return targetBiped
		)
	)

	fn fnGetExistingBipedRoot =
	(
		local bipRoot = undefined
		try (bipRoot = GetBipedNode 1) catch (bipRoot = undefined)
		if bipRoot != undefined and isValidNode bipRoot then bipRoot
		else undefined
	)

	fn fnHalfAnimSpeed = 
	(
		endFrame = animationrange.end * 2
		for i in objects do scaletime i.controller animationrange.start animationrange.end 2
		animationrange = interval animationrange.start endFrame
		true
	)

	-- [Shared] 移除 Root 骨骼但保留 Biped 动画(世界空间烘焙)
	fn fnRemoveRootKeepAnim =
	(
		if gOpts.isRemoveRootKeepAnim and (getnodebyname "Root") != undefined then
		(
			local rootNode = getnodebyname "Root"
			local bipRoot = fnGetExistingBipedRoot()
			if bipRoot == undefined or not (isValidNode bipRoot) then
			(
				format "[BsRetarget] Skip RemoveRootKeepAnim: Biped root missing.\n"
				return false
			)

			local bipWorldPosList = #()
			local bipWorldRotList = #()

			for t = animationRange.start to animationRange.end do
			(
				at time t
				(
					append bipWorldPosList (in coordsys world Biped.getTransform bipRoot #pos)
					append bipWorldRotList (in coordsys world Biped.getTransform bipRoot #rotation)
				)
			)

			bipRoot.parent = undefined

			biped.createLayer bipRoot.controller 1 "layerRemoveRoot"
			biped.setcurrentlayer bipRoot.controller 1

			local f = 1
			for t = animationRange.start to animationRange.end do
			(
				slidertime = t
				with animate on
				(
					in coordsys world Biped.setTransform bipRoot #pos bipWorldPosList[f] true
					in coordsys world Biped.setTransform bipRoot #rotation bipWorldRotList[f] true
					f += 1
				)
			)

			biped.collapseAtLayer bipRoot.controller 0
			delete rootNode
			true
		)
		else false
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
			tarFileDebug  = edtOutputPath.text + "\FBX\\" + (getfilenamefile sourFileImportPath) + "_Debug.FBX"
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
			if gOpts.fixNierFramerate then framerate = 30
			importFile sourFileImportPath #noPrompt using:FBXIMP

			-- DialogMonitorOps.Enabled = true
			-- DialogMonitorOps.RegisterNotification fnConfirmImportFBX id:#importFBX
			-- DialogMonitorOps.unRegisterNotification id:#importFBX
			-- DialogMonitorOps.Enabled = false

			if gOpts.fixNierFramerate then 
			(
				framerate = 60
				-- frameStart = animationrange.start
				-- frameEnd = animationrange.end
				-- scaleTime objects frameStart frameEnd 0.5
				-- animationrange = interval frameStart (frameEnd/2)
				rescaleWorldUnits 100
				--修复Nier动画帧数,缩放等等
				-- startFrame = animationrange.start
				-- endFrame = animationrange.end
				-- for i in objects where isValidNode i do
				-- (
				-- 	deselectKeys i
				-- 	selectkeys i startFrame startFrame
				-- 	deleteKeys i #selection
				-- 	selectkeys i (startFrame + 1) endFrame
				-- 	moveKeys i -1 #selection
				-- )
				-- animationrange = interval startFrame (endFrame - 1)
			)

			if gOpts.isScale100 then (rescaleWorldUnits 100)

			select $'RTHelper_*'
			if (selection as array).count == 0 then (select $'RetargetHelper_*';preStr = "Old")
			arrExport = (selection as array)
			for i in arrExport where isValidNode i do
			(
				if preStr == "Old" then (i.name = substituteString i.name "RetargetHelper_" "")
				else (i.name = substituteString i.name "RTHelper_" "")
			)
			
			if gOpts.isHalfAnimSpeed do 
			(
				fnHalfAnimSpeed()
			)
			
			FBXExporterSetParam "Animation" true
			FBXExporterSetParam "BakeAnimation" true
			FBXExporterSetParam "BakeResampleAnimation" false
			FBXExporterSetParam "SplitAnimationIntoTakes" "-c"
			FBXExporterSetParam "BakeFrameStart" animationRange.start
			-- if gOpts.fixNierFramerate then (FBXExporterSetParam "BakeFrameStart" 1)
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

			if gOpts.isEulerFilter then 
			(
				for i in selection where classof i == BoneGeometry or classof i == dummy or classof i == point do
				(
					if classof i.rotation.controller == Euler_XYZ then
					(
						i.rotation.controller = tcb_rotation ()
						i.rotation.controller = Euler_XYZ ()
					)
				)
			)

			completeredraw()
			try (exportFile tarNewAnim #noPrompt selectedOnly:true using:FBXEXP)
			catch (format "[BsRetarget] FBX export failed: %\n" (getCurrentException()))
			-- exportFile tarFileDebug #noPrompt selectedOnly:true using:FBXEXP

			-- print ("正在导入新 Skin 动画：" + tarNewAnim)
			resetMaxFile #noPrompt
			
			loadMaxFile skinFile useFileUnits:true quiet:true
			if gOpts.fixNierFramerate then framerate = 60
			local bipRoot = fnGetExistingBipedRoot()
			if bipRoot == undefined then
			(
				format "[BsRetarget] Export skipped: no Biped in skin file %\n" skinFile
				return false
			)
			try (bipRoot.transform.controller.figureMode = false) catch (print "[BsRetarget] figureMode already off or cannot switch")

			FbxImporterSetParam "Mode" #exmerge
			FbxImporterSetParam "Animation" true
			FbxImporterSetParam "FillTimeline" true
			FbxImporterSetParam "BakeAnimationLayers" false
			FbxImporterSetParam "PointCache" false

			bipRoot.parent = undefined
			try (importFile tarNewAnim #noPrompt using:FBXIMP)
			catch (format "[BsRetarget] FBX import failed: %\n" (getCurrentException()))
			DeleteFile tarNewAnim

			if (getnodebyname "Root") != undefined then 
			(
				local rootBone            = bipRoot
				local dummyRootMotion     = (getnodebyname "Root")
				local bipPosList = #()
				local bipRotList = #()

				-- 遍历：动画 Root 匹配 RootLeader
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
					slidertime = t
					with animate on
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
				f = 1
				for t = (animationRange.start) to (animationRange.end) do
				(
					slidertime = t
					with animate on
					(
						-- Pos
						bipPos = bipPosList[f]
						in coordsys world Biped.setTransform rootBone #pos bipPos true
						-- Rot
						bipRot = bipRotList[f]
						in coordsys world Biped.setTransform rootBone #rotation bipRot true
						f += 1
					)
				)
				biped.collapseAtLayer rootBone.controller 1
				biped.collapseAtLayer rootBone.controller 0
			)

			-- 移除 Root 保留动画
			fnRemoveRootKeepAnim()

			saveMaxFile tarMaxFile saveAsVersion:((rolBsRetarget.ddlSaveVersion.selected) as integer) clearNeedSaveFlag:true quiet:true
			arrExport = (for i in objects where classof i == Biped_Object or classof i == Dummy or classof i == BoneGeometry collect i)
			select arrExport
			try (exportFile tarNewAnim #noPrompt selectedOnly:true using:FBXEXP)
			catch (format "[BsRetarget] FBX export failed: %\n" (getCurrentException()))
			biped.saveBipFile bipRoot.controller tempBip
			-- print ("已保存新 Skin 动画：" + (substituteString tarNewAnim ".FBX" ".max"))
			true
		)
	)

	fn fnLoadBipAnim arrBipAnim index = 
	(
		if (index != 0) and (doesFileExist arrBipAnim[index]) then
		(
			local SIOFile = dotNetClass "System.IO.File"			---文件操作
			local SIODir = dotNetClass "System.IO.Directory"		---文件夹操作

			sourFileImportPath = arrBipAnim[index]
			fileName = (getfilenamefile sourFileImportPath)
			loadBip = edtOutputPath.text + "\BIP\\" + fileName + ".bip"
			tempRootAnim = edtOutputPath.text + "\FBX_ReloadBip\\" + fileName + ".xaf"
			loadRootAnimFile = edtOutputPath.text + "\MAX\\" + fileName + ".max"
			tarMaxFile = edtOutputPath.text + "\MAX_ReloadBip\\" + fileName + ".max"
			skinFile   = edtSkinFile.text
			tarNewAnim = (edtOutputPath.text + "\FBX_ReloadBip\\" + fileName + ".FBX")
			if (not (SIODir.Exists edtOutputPath.text)) do (SIODir.CreateDirectory edtOutputPath.text)
			if (not (SIODir.Exists (edtOutputPath.text + "\FBX_ReloadBip\\"))) do (SIODir.CreateDirectory (edtOutputPath.text + "\FBX_ReloadBip\\"))
			if (not (SIODir.Exists (edtOutputPath.text + "\MAX_ReloadBip\\"))) do (SIODir.CreateDirectory (edtOutputPath.text + "\MAX_ReloadBip\\"))

			if chkRecoverExport.state then 
			(
				if (doesFileExist tarMaxFile) and (doesFileExist tarNewAnim) then (return "Exist")
			)
			resetMaxFile #noPrompt
			
			loadMaxFile loadRootAnimFile useFileUnits:true quiet:true
			zeroFrame = animationrange.start
			endFrame = animationrange.end
			-- print endframe
			LoadSaveAnimation.saveAnimation tempRootAnim $'Root' #("") #("")

			resetMaxFile #noPrompt
			loadMaxFile skinFile useFileUnits:true quiet:true
			if gOpts.fixNierFramerate then framerate = 60
			local bipRoot = fnGetExistingBipedRoot()
			if bipRoot == undefined then
			(
				format "[BsRetarget] Reload skipped: no Biped in skin file %\n" skinFile
				return false
			)
			try (bipRoot.transform.controller.figureMode = false) catch (print "[BsRetarget] figureMode already off or cannot switch")
			-- (GetBipedNode 1).parent = undefined  --质心已经没动画了,不用断开父子级
			slidertime = zeroFrame
			LoadSaveAnimation.loadAnimation tempRootAnim $'Root' relative:false insert:false
			biped.loadBipFile bipRoot.controller loadBip #noRedraw 
			
			DeleteFile tempRootAnim

			-- fnTransferRootAnim()

			animationrange = (interval zeroFrame endFrame)

			-- 移除 Root 保留动画
			fnRemoveRootKeepAnim()

			saveMaxFile tarMaxFile saveAsVersion:((rolBsRetarget.ddlSaveVersion.selected) as integer) clearNeedSaveFlag:true quiet:true
			arrExport = (for i in objects where classof i == Biped_Object or classof i == Dummy or classof i == BoneGeometry collect i)
			select arrExport
			try (exportFile tarNewAnim #noPrompt selectedOnly:true using:FBXEXP)
			catch (format "[BsRetarget] FBX export failed: %\n" (getCurrentException()))
			true
		)
	)

--------------------------------------------------------------------------------------------------------------------------	

	global GetBonePos
	fn GetBonePos itemIndex =
	(
		return (GetSkeletalNode itemIndex false).pos
	)

	global GetBoneRot
	fn GetBoneRot itemIndex =
	(
		return (GetSkeletalNode itemIndex false).rotation
	)

	-- 将下拉框轴向选择解析为变换矩阵的对应行向量
	fn fnResolveAxis ddlWidget xformNode =
	(
		local tm = xformNode.transform
		case ddlWidget.selected of
		(
			("X"):  tm.row1
			("Y"):  tm.row2
			("Z"):  tm.row3
			("-X"): -tm.row1
			("-Y"): -tm.row2
			("-Z"): -tm.row3
			default: -tm.row3
		)
	)

	global CreateFauxBone
	fn CreateFauxBone initialBone parentIndex childIndex axis isFoot:false isToes:false isHand:false=
	(
		if (not (fnIsIgnoreBone parentIndex)) then 
		(
			foundParent = GetSkeletalNode parentIndex false
		
			foundChild = undefined 
			if (childIndex > 0) then
			(
				foundChild = GetSkeletalNode childIndex false
			)
			

			
			if (isFoot == true) then
			(
				local parentPos = foundParent.pos;
				local childPos = foundChild.pos;
				local midPos = [parentPos.x, parentPos.y, childPos.z]

				local diffA = midPos - parentPos;
				local toeHoriz = normalize [childPos.x - parentPos.x, childPos.y - parentPos.y, 0]
				local axisA = normalize (cross (normalize diffA) toeHoriz)
				
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
				if (parentIndex == 25) and not (fnIsIgnoreBone 34) and not (fnIsIgnoreBone 38) then
				(
					-- local fIndex = GetSkeletalNode 28 false
					local fMiddle = GetSkeletalNode 34 false
					local fRing = GetSkeletalNode 38 false
					-- local fPinky = GetSkeletalNode 40 false;
					
					mid = (fMiddle.pos + fRing.pos) * 0.5;
				)
				else if (parentIndex == 49) and not (fnIsIgnoreBone 58) and not (fnIsIgnoreBone 62) then
				(
					-- local fIndex = GetSkeletalNode 52 false
					local fMiddle = GetSkeletalNode 58 false
					local fRing = GetSkeletalNode 62 false
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
				axis      = fnResolveAxis rolBsRetarget.ddlHandAxis   foundParent
				axisThumb = fnResolveAxis rolBsRetarget.ddlThumbAxis  foundParent
				local axis2      = fnResolveAxis rolBsRetarget.ddlHandAxis2  foundParent
				local axisThumb2 = fnResolveAxis rolBsRetarget.ddlThumbAxis2 foundParent
				local axisPalm   = fnResolveAxis rolBsRetarget.ddlPalmAxis   foundParent
				local axisPalm2  = fnResolveAxis rolBsRetarget.ddlPalmAxis2  foundParent
	
				arrThumbIndex = #(26,27,28,29)
				arrThumbIndex2 = #(50,51,52,53)
				arrPalmIndex = #(25)
				arrPalmIndex2 = #(49)
	
				if parentIndex >= 49 then (axis = axis2;axisThumb = axisThumb2;axisPalm = axisPalm2)
				if finditem arrThumbIndex parentIndex != 0 then (axis = axisThumb)
				if finditem arrThumbIndex2 parentIndex != 0 then (axis = axisThumb2)
				if finditem arrPalmIndex parentIndex != 0 then (axis = axisPalm)
				if finditem arrPalmIndex2 parentIndex != 0 then (axis = axisPalm2)
	
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
				-- print parentIndex
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
			return newBone	
		)
	)

	fn AdjustBipedScale index0 spine:false isToe:false isHand:false = 
	(
		try
		(		
			local index1 = index0 + 1;
			if fnIsIgnoreBone index0 then (return true)
			
			affectedBiped = GetBipedNode index0;
			if affectedBiped == undefined then
			(
				messagebox ("Biped Node -- " + (index0 as string) + " is missing. -- Not Found");
				return 0;
			)
			
			pos0 = GetBonePos index0
			pos1 = GetBonePos index1
			if isHand == true then
			(
				-- Gives the middle finger.
				if not (fnIsIgnoreBone (index0+9)) then 
				(
					pos1 = (GetBonePos (index0+9))
				)
				else pos1 = (GetBonePos index1)
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
				biped.setTransform affectedBiped #scale [abs diff.z,abs diff.z,abs diff.z] false
			)
		)
		catch(format "[BsRetarget] AdjustBipedScale error at index: %\n" index0)
	)
	
	global CreateOrientationConstraint
	fn CreateOrientationConstraint itemIndex fauxToBiped =
	(
		if (not (fnIsIgnoreBone itemIndex)) then 
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
		else () --ignore
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
		if (not (fnIsIgnoreBone itemIndex)) then 
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
	)
	
	global FixLimb
	fn FixLimb index =
	(
		local limbNode = (GetBipedNode index)
		if limbNode == undefined then return undefined
		local skelTarget = (GetSkeletalNode index true)
		if skelTarget == undefined then return undefined

		select limbNode
		local bestStep = 0
		local minDist = 900000

		for i = 1 to 72 do
		(
			in coordsys local rotate limbNode (angleaxis 5 [1,0,0])
			local pos = biped.getTransform limbNode #pos
			local diff = skelTarget.transform.position - pos
			if (length diff < minDist) then
			(
				minDist = length diff
				bestStep = i
			)
		)
		-- 72×5=360度 → 回到原位，再转 bestStep×5 度
		in coordsys local rotate limbNode (angleaxis (5 * bestStep) [1,0,0])
	)
	
	-- 数据表: #(索引, 类型, FixLimb目标)
	-- 类型: #posrot_figmode=figure模式下pos+rot, #posrot_ik=pos+rot+pos+FixLimb, #root=特殊根节点, #skip=跳过
	global alignPosRotFigModeSet = #{3,8,10,15,20,22,26,30,34,38,42,46,50,54,58,62,66}
	global alignIKMap = #(#(14,11), #(19,16), #(25,22), #(49,46))  -- #(节点index, fixLimb目标)

	global AlignBipToFaux
	fn AlignBipToFaux v prealign:false =
	(
		if not (fnIsIgnoreBone v) then
		(
			local bipRoot = fnGetExistingBipedRoot()
			if bipRoot == undefined then return undefined

			local inFigureMode = bipRoot.transform.controller.figureMode
			local bipNode = GetBipedNode v
			local fauxNode = GetSkeletalNode v true

			if v == 1 then
			(
				-- 根节点: 用左右腿中点
				local ll = (GetSkeletalNode 12 true)
				local rr = (GetSkeletalNode 17 true)
				local pp = (ll.pos + rr.pos) * 0.5
				biped.setTransform bipNode #pos pp false
				biped.setTransform bipNode #rotation fauxNode.transform.rotation false
			)
			else if v == 2 then
			(
				-- Pelvis: 跳过(由根节点驱动)
			)
			else
			(
				-- 检查是否为 IK 末端(手/脚): pos+rot+pos+FixLimb
				local ikTarget = 0
				for pair in alignIKMap where pair[1] == v do (ikTarget = pair[2])

				if ikTarget > 0 then
				(
					biped.setTransform bipNode #pos fauxNode.transform.position false
					biped.setTransform bipNode #rotation fauxNode.transform.rotation false
					biped.setTransform bipNode #pos fauxNode.transform.position false
					FixLimb ikTarget
				)
				-- figure 模式下 pos+rot 的节点(脊椎/颈/头/肩/手指/脚趾)
				else if alignPosRotFigModeSet[v] then
				(
					if inFigureMode do
						biped.setTransform bipNode #pos fauxNode.transform.position false
					biped.setTransform bipNode #rotation fauxNode.transform.rotation false
				)
				-- 其他节点: 仅 rotation
				else
				(
					try (biped.setTransform bipNode #rotation fauxNode.transform.rotation false)
					catch (format "[BsRetarget] AlignBipToFaux error at ID: %\n" v)
				)
			)

			-- 批量重绘: 仅在整批调用末尾由调用方执行一次
			if gOpts.okForceRedraw == true do forceCompleteRedraw()
		)
	)

    fn fnAlignBipedFingersToHelper = 
    (
		local bipRoot = fnGetExistingBipedRoot()
        if bipRoot != undefined then
        (
			max Create mode

            oldFigureMode = (bipRoot.transform.controller.figureMode)

			if oldFigureMode == true then
			(
				for i = 26 to 45 do
				(
					AlignBipToFaux i
				)
				
				for i = 50 to 69 do
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
		fnInvalidateBipedCache()
		if (fnGetExistingBipedRoot()) == undefined then
		(
			format "[BsRetarget] Align skipped: Biped root missing.\n"
			return undefined
		)
		local savedRedraw = gOpts.okForceRedraw
		gOpts.okForceRedraw = false
        try
		(
			for i = 1 to 69 where (not (fnIsIgnoreBone i)) do
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
					if (i != 12 and i != 13 and i != 17 and i != 18 and i != 23 and i != 24 and i != 47 and i != 48) then
					(
						AlignBipToFaux i
					)
				-- )
			)
		)
		catch
		(
			format "[BsRetarget] Error when realigning. Most likely a missing bone.\n"
			return undefined
		)
		
		FixLimb 24
		biped.setTransform (GetBipedNode 25) #rotation (GetSkeletalNode 25 true).transform.rotation false
		
		FixLimb 48
		biped.setTransform (GetBipedNode 49) #rotation (GetSkeletalNode 49 true).transform.rotation false
		
		FixLimb 13
		FixLimb 18	
		
        AlignBipToFaux 25
        AlignBipToFaux 49

		gOpts.okForceRedraw = savedRedraw
		if savedRedraw do forceCompleteRedraw()
    )
	
	
	on alignHelperBiped pressed do
	(
		if not gOpts.mappingCheckState then
		(
			fnShowBlockedAction "当前不能对齐 Biped。" "请先验证映射列表。"
			return undefined
		)
		if (fnGetExistingBipedRoot()) == undefined then
		(
			fnShowBlockedAction "当前不能对齐 Biped。" "场景中没有可用的 Biped。"
			return undefined
		)
		
		-- We align the neck and head bones
		AlignOldAndNewBones 3 prealign:true
		AlignOldAndNewBones 4
		AlignOldAndNewBones 5
		AlignOldAndNewBones 6
		AlignOldAndNewBones 7
		AlignOldAndNewBones 8 prealign:true
		AlignOldAndNewBones 9
		
		-- We then align the head bone
		AlignOldAndNewBones 10 prealign:true
		
		AlignOldAndNewBones 12
		AlignOldAndNewBones 13
		AlignOldAndNewBones 14
		
		AlignOldAndNewBones 15 prealign:true
		
		AlignOldAndNewBones 17
		AlignOldAndNewBones 18
		AlignOldAndNewBones 19
		AlignOldAndNewBones 20 prealign:true
		
		AlignOldAndNewBones 17
		AlignOldAndNewBones 18
		AlignOldAndNewBones 19
		AlignOldAndNewBones 20 prealign:true
		
		-- LEFT ARM
		AlignOldAndNewBones 22 prealign:true
		AlignOldAndNewBones 23
		AlignOldAndNewBones 24
		AlignOldAndNewBones 25
		
		-- LEFT FINGERS
		AlignOldAndNewBones 26 prealign:true
		AlignOldAndNewBones 27
		AlignOldAndNewBones 28
		
		AlignOldAndNewBones 30 prealign:true
		AlignOldAndNewBones 31
		AlignOldAndNewBones 32
		
		AlignOldAndNewBones 34 prealign:true
		AlignOldAndNewBones 35
		AlignOldAndNewBones 36
		
		AlignOldAndNewBones 38 prealign:true
		AlignOldAndNewBones 39
		AlignOldAndNewBones 40
		
		AlignOldAndNewBones 42 prealign:true
		AlignOldAndNewBones 43
		AlignOldAndNewBones 44
		
		-- RIGHT ARM
		AlignOldAndNewBones 46 prealign:true
		AlignOldAndNewBones 47
		AlignOldAndNewBones 48
		AlignOldAndNewBones 49
		
		-- RIGHT FINGERS
		AlignOldAndNewBones 50 prealign:true
		AlignOldAndNewBones 51
		AlignOldAndNewBones 52
		
		AlignOldAndNewBones 54 prealign:true
		AlignOldAndNewBones 55
		AlignOldAndNewBones 56
		
		AlignOldAndNewBones 58 prealign:true
		AlignOldAndNewBones 59
		AlignOldAndNewBones 60
		
		AlignOldAndNewBones 62 prealign:true
		AlignOldAndNewBones 63
		AlignOldAndNewBones 64
		
		AlignOldAndNewBones 66 prealign:true
		AlignOldAndNewBones 67
		AlignOldAndNewBones 68
	)

	-- ====== SECTION 6: EVENT HANDLERS ======

	on saveDialogue pressed do
	(
		fnEnsureMappingListLengths()
		local defaultName = "mapping"
		local detected = fnDetectSkeletonPreset()
		if detected != undefined then
			defaultName = detected
		else if characterBones.items[1] != "~undefined~" then
		(
			defaultName = substituteString characterBones.items[1] ":" "_"
			defaultName = substituteString defaultName " " "_"
		)

        local tempdir = (if (maxFilePath != "") and (doesDirectoryExist maxFilePath) then \
        maxFilePath else (@"C:\Users\" + (filterString  (getdir #userscripts) @"\")[3] + @"\Desktop\"))

        f = getSaveFileName caption:"Save Skeleton Mapping:" initialDir:tempdir filename:(defaultName + ".list") types:"Mapping List (*.list)|*.list|"
        
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

			if out_file == undefined then
			(
				fnShowBlockedAction "当前不能保存 List。" "文件无法写入。"
				return undefined
			)

            fnEnsureMappingListLengths()

	            format "v2\n" to:out_file
            for i = 1 to characterBones.items.count do
            (
                format "%\n" characterBones.items[i] to:out_file
            )
            
            for i = 1 to characterBones_B.items.count do
            (
                format "%\n" characterBones_B.items[i] to:out_file
            )

			format "%\n" (if lbxRoot.items.count > 0 then lbxRoot.items[1] else "~undefined~") to:out_file
			format "%\n" ddlThumbAxis.selection to:out_file
			format "%\n" ddlHandAxis.selection to:out_file
			format "%\n" ddlThumbAxis2.selection to:out_file
			format "%\n" ddlHandAxis2.selection to:out_file
			format "%\n" ddlPalmAxis.selection to:out_file
			format "%\n" ddlPalmAxis2.selection to:out_file
            
            close out_file

            fnRefreshMappingFile()
            messagebox ("保存成功！\n" + (filenameFromPath f)) title:kMsgTitle beep:false
        )
	)
	
	on loadDialogue pressed do
	(
		pgbBar.value = 0
		lblBarValue.text = (pgbBar.value as string) + " %"
        local tempdir = (if (maxFilePath != "") and (doesDirectoryExist maxFilePath) then maxFilePath else (@"C:\Users\" + (filterString  (getdir #userscripts) @"\")[3] + @"\Desktop\"))

		f = getOpenFileName caption:"Load Skeleton Mapping:" initialDir:tempdir types:"Mapping List (*.list)|*.list|"
		
		if f != undefined then
		(
			fnLoadMappingListAndRefresh f pushUndo:true
		)
	)

	on btnMirrorSync pressed do
	(
		fnPushMappingUndo()
		local sceneNames = for o in objects collect o.name
		local syncCount = 0
		for pair in kLeftRightMap do
		(
			local lVal = fnGetListItem pair[1]
			local rVal = fnGetListItem pair[2]
			if lVal != "~undefined~" and rVal == "~undefined~" then
			(
				local mir = fnMirrorBoneName lVal
				if mir != lVal and (findItem sceneNames mir) > 0 then
				(
					fnSetListItem pair[2] mir
					syncCount += 1
				)
			)
			else if rVal != "~undefined~" and lVal == "~undefined~" then
			(
				local mir = fnMirrorBoneName rVal
				if mir != rVal and (findItem sceneNames mir) > 0 then
				(
					fnSetListItem pair[1] mir
					syncCount += 1
				)
			)
		)
		fnUpdateStatusBar()
		messagebox ("镜像同步完成！填充了 " + syncCount as string + " 个槽位。") title:kMsgTitle beep:false
	)

	on btnUndo pressed do (fnPopMappingUndo(); fnUpdateStatusBar())

	on btnPickBone pressed do
	(
		if pickModeActive then fnPickModeExit()
		else fnPickModeEnter()
	)

	on btnPickBone rightclick do
	(
		if pickModeActive then fnPickModeAdvance()
	)

	on tmrPickMode tick do
	(
		if not pickModeActive then tmrPickMode.active = false
		else if keyboard.escPressed then fnPickModeExit()
	)

	on lbxRoot selected nameIndex do
	(
		if $ != undefined and (selection as array).count == 1 then
		(
			bsRootBone = selection[1]
			lbxRoot.items = #(bsRootBone.name)
			lbxRoot.selection = 0
		)
		else (messagebox "只能填入一个有效骨骼节点!                                              ")
	)
	
	on lbxRoot rightclick nameIndex do
	(
		bsRootBone = undefined
		lbxRoot.items = #("~undefined~")
		lbxRoot.selection = 0
	)

	on bipedBones selected nameIndex do
	(
		if pickModeActive then
		(
			pickModeSlot = nameIndex
			fnPickModeHighlightSlot nameIndex
			fnPickModeUpdateStatus()
		)
		else try(select (GetSkeletalNode nameIndex false))catch()
	)

	on characterBones selected nameIndex do
	(
		if not pickModeActive then
		(
			if $ != undefined and (selection as array).count == 1 then
			(
				fnPushMappingUndo()
				fnSetListItem nameIndex $.name
				fnUpdateStatusBar()
			)
			else (messagebox "只能填入一个有效骨骼节点!                                              ")
		)
	)

	on bipedBones rightclick nameIndex do
	(
		fnSetListItem nameIndex "~undefined~"
	)

	on characterBones rightclick nameIndex do
	(
		fnPushMappingUndo()
		fnSetListItem nameIndex "~undefined~"
		fnUpdateStatusBar()
	)
	
-- ALTA
	
	on bipedBones_B selected nameIndex do
	(
		if pickModeActive then
		(
			pickModeSlot = nameIndex + 37
			fnPickModeHighlightSlot (nameIndex + 37)
			fnPickModeUpdateStatus()
		)
		else try(select (GetSkeletalNode (nameIndex + 37) false))catch()
	)

	on characterBones_B selected nameIndex do
	(
		if not pickModeActive then
		(
			if $ != undefined and (selection as array).count == 1 then
			(
				fnPushMappingUndo()
				fnSetListItem (nameIndex + 37) $.name
				fnUpdateStatusBar()
			)
			else (messagebox "只能填入一个有效骨骼节点!                                              ")
		)
	)

	on bipedBones_B rightclick nameIndex do
	(
		fnSetListItem (nameIndex + 37) "~undefined~"
	)

	on characterBones_B rightclick nameIndex do
	(
		fnPushMappingUndo()
		fnSetListItem (nameIndex + 37) "~undefined~"
		fnUpdateStatusBar()
	)
	
	------------------------------------------
	
	
	on validateButton pressed do
	(
		fnResolveAndSetRoot()
		gOpts.mappingCheckState = true
		local missingHeadNub = false
		local missingFootNubs = false  
		local missingFingers = #()
		local otherMissing = #()
		local autoCreated = false  -- 标志变量，记录是否进行了自动创建
		local stateMessageShown = false

		for i = 1 to characterBones.items.count do
		(
			local checkedNode = GetSkeletalNode i false
			if (checkedNode == undefined) then
			(
				if not (fnIsOptionalNodeIndex i) then
				(
					-- 检查是否是特定的 Nub 骨骼 (根据用户提供的正确索引)
					case i of
					(
						11: missingHeadNub = true  -- HeadNub
						16: missingFootNubs = true -- L Toe0Nub
						21: missingFootNubs = true -- R Toe0Nub 
						default:
						(
							-- 只有非 nub 的必需骨骼才加入 otherMissing
							append otherMissing i
						)
					)
				)
				else
				(
					-- 检查是否是所有可选的手指骨骼，不仅仅是nub
					case i of
					(
						24: append missingFingers i -- L Finger0
						25: append missingFingers i -- L Finger01
						26: append missingFingers i -- L Finger02
						27: append missingFingers i -- L Finger0Nub
						28: append missingFingers i -- L Finger1
						29: append missingFingers i -- L Finger11
						30: append missingFingers i -- L Finger12
						31: append missingFingers i -- L Finger1Nub
						32: append missingFingers i -- L Finger2
						33: append missingFingers i -- L Finger21
						34: append missingFingers i -- L Finger22
						35: append missingFingers i -- L Finger2Nub
						36: append missingFingers i -- L Finger3
						37: append missingFingers i -- L Finger31
						38: append missingFingers i -- L Finger32
						39: append missingFingers i -- L Finger3Nub
						40: append missingFingers i -- L Finger4
						41: append missingFingers i -- L Finger41
						42: append missingFingers i -- L Finger42
						43: append missingFingers i -- L Finger4Nub
						default: ()
					)
				)
			)
		)
		
		for i = 1 to characterBones_B.items.count do
		(
			local checkedNode = GetSkeletalNode (i+37) false
			if (checkedNode == undefined) then
			(
				if not (fnIsOptionalNodeIndex (i+37)) then
				(
					append otherMissing (i+37)
				)
				else
				(
					-- 检查是否是右手所有可选手指骨骼
					local realIndex = i + 37
					case realIndex of
					(
						48: append missingFingers realIndex -- R Finger0
						49: append missingFingers realIndex -- R Finger01
						50: append missingFingers realIndex -- R Finger02
						51: append missingFingers realIndex -- R Finger0Nub
						52: append missingFingers realIndex -- R Finger1
						53: append missingFingers realIndex -- R Finger11
						54: append missingFingers realIndex -- R Finger12
						55: append missingFingers realIndex -- R Finger1Nub
						56: append missingFingers realIndex -- R Finger2
						57: append missingFingers realIndex -- R Finger21
						58: append missingFingers realIndex -- R Finger22
						59: append missingFingers realIndex -- R Finger2Nub
						60: append missingFingers realIndex -- R Finger3
						61: append missingFingers realIndex -- R Finger31
						62: append missingFingers realIndex -- R Finger32
						63: append missingFingers realIndex -- R Finger3Nub
						64: append missingFingers realIndex -- R Finger4
						65: append missingFingers realIndex -- R Finger41
						66: append missingFingers realIndex -- R Finger42
						67: append missingFingers realIndex -- R Finger4Nub
						default: ()
					)
				)
			)
		)
		
		-- 处理其他缺失的必需骨骼 - 直接报错，不进行自动创建
		if otherMissing.count > 0 then
		(
			local missingName = ""
			for idx in otherMissing do 
			(
				missingName += (idx as string) + ":  " + boneNames[idx] + "\n"
			)
			messagebox ("缺失必需骨骼：\n\n" + missingName + "\n请手动映射这些骨骼！")
			gOpts.mappingCheckState = false
		)
		
		-- 一次性处理所有可自动创建的内容
		local needsAutoCreation = missingHeadNub or missingFootNubs or missingFingers.count > 0
		local hasRequiredNubs = missingHeadNub or missingFootNubs  -- 区分必需的nub和可选的手指
		
		if needsAutoCreation and not autoCreated then
		(
			-- 构建询问消息
			local message = "检测到以下缺失的骨骼，是否自动创建？\n\n"
			local creationList = #()
			
			if missingHeadNub then
			(
				message += "• Head Nub\n"
				append creationList "head"
			)
			
			if missingFootNubs then
			(
				message += "• Foot Nub (脚趾末端)\n"
				append creationList "foot"
			)
			
			if missingFingers.count > 0 then
			(
				message += "• [可选] " + (missingFingers.count as string) + " 个手指骨骼\n"
				append creationList "fingers"
			)
			
			message += "\n一次性创建所有缺失骨骼(占位用)？                               "
			
			if (queryBox message title:"自动创建缺失骨骼" beep:false) then
			(
				local successCount = 0
				local errorMessages = #()
				
				-- 创建 Head Nub
				if missingHeadNub then
				(
					try
					(
						menuQuickCreateNode.fnDuplicateNub #(10) isHead:true
						local headNubNode = GetSkeletalNode 11 false
						if headNubNode != undefined then
						(
							successCount += 1
						)
						else
						(
							append errorMessages "Head Nub 创建失败"
						)
					)
					catch
					(
						append errorMessages "Head Nub 创建出错"
					)
				)
				
				-- 创建 Foot Nub
				if missingFootNubs then
				(
					try
					(
						menuQuickCreateNode.fnDuplicateNub #(15,20) isFoot:true
						local lFootNub = GetSkeletalNode 16 false
						local rFootNub = GetSkeletalNode 21 false
						if lFootNub != undefined or rFootNub != undefined then
						(
							successCount += 1
						)
						else
						(
							append errorMessages "Foot Nub 创建失败"
						)
					)
					catch
					(
						append errorMessages "Foot Nub 创建出错"
					)
				)
				
				-- 创建手指骨骼
				if missingFingers.count > 0 then
				(
					try
					(
						-- 使用 quickDuplicateFingers 功能创建手指nub
						local arrFingersID = #(28,32,36,40,44,52,56,60,64,68)
						menuQuickCreateNode.fnDuplicateNub arrFingersID
						
						-- 检查是否成功创建了一些手指 Nub
						local createdCount = 0
						local fingerNubIndices = #(29,33,37,41,45,53,57,61,65,69)
						for nubIdx in fingerNubIndices do
						(
							local createdNode = GetSkeletalNode nubIdx false
							if createdNode != undefined then createdCount += 1
						)
						
						if createdCount > 0 then
						(
							successCount += 1
						)
						else
						(
							append errorMessages "手指 Nub 创建失败"
						)
					)
					catch
					(
						append errorMessages "手指 Nub 创建出错"
					)
				)
				
				-- 显示创建结果
				if successCount > 0 then
				(
					local resultMessage = "自动创建完成！"
					if errorMessages.count > 0 then
					(
						resultMessage += "\n\n部分创建失败：\n"
						for errMsg in errorMessages do
						(
							resultMessage += "• " + errMsg + "\n"
						)
					)
					resultMessage += "\n请重新验证映射列表！"
					messagebox resultMessage title:"创建完成"
				)
				else
				(
					local errorMessage = "所有自动创建都失败了：\n\n"
					for errMsg in errorMessages do
					(
						errorMessage += "• " + errMsg + "\n"
					)
					errorMessage += "\n请手动创建或检查骨骼结构！"
					messagebox errorMessage title:"创建失败"
				)
				
				autoCreated = true
			)
			else
			(
				-- 用户选择"否"时，只有缺失必需nub才算验证失败
				if hasRequiredNubs then
				(
					gOpts.mappingCheckState = false
				)
				-- 如果只缺失可选手指，不影响验证状态，让流程继续
			)
		)
		
		local curState = fnBuildMappingState()
		if not curState.hasRoot then
		(
			gOpts.mappingCheckState = false
			messagebox ("Root 未指定或场景中不存在。\r\n\r\n请选中原骨架根节点并点击 Root 列表，或重新自动匹配。") title:kMsgTitle
			stateMessageShown = true
		)
		else if curState.missingSceneNodes.count > 0 then
		(
			gOpts.mappingCheckState = false
			messagebox ("映射列表中有场景不存在的节点。\r\n\r\n请检查已加载的 List 是否匹配当前骨架。") title:kMsgTitle
			stateMessageShown = true
		)
		else if gOpts.mappingCheckState then
		(
			fnSetRootNode curState.rootNode
		)
		fnUpdateStatusBar()
		
		-- 如果进行了自动创建，提示重新验证
		if autoCreated then
		(
			-- 已经在上面显示了详细的创建结果，这里不需要额外提示
		)
		else if (gOpts.mappingCheckState) then
		(
			messagebox ("骨骼映射完整，请继续！                 ");
		)
		else if not stateMessageShown then
		(
			messagebox ("存在未指定的映射骨骼！\r\n\r\n修改请选中骨骼，点击上面列表对应节点！                ");
		)
	)
	
	global SetupNormalChildFN
	fn SetupNormalChildFN nubItem nubIndex isToe = 
	(
		try
		(
			format "[BsRetarget] Setting up % at %\n" nubItem.name nubIndex
			
			local skeletalItem = GetSkeletalNode nubIndex false findCorrect:false;
			if skeletalItem == undefined then
			(
				skeletalItem = GetSkeletalNode (nubIndex-1) false findCorrect:false;
				if skeletalItem == undefined then
				(
					format "[BsRetarget] Skeletal item at % is missing.\n" (nubIndex-1)
				)
				else
				(
					format "[BsRetarget] Nub parent found\n"
					
					local vec =  skeletalItem.pos - skeletalItem.parent.pos;
					local pos = skeletalItem.pos + (normalize vec) * (length vec);
					if isToe == true then
					(
						pos.z = skeletalItem.pos.z;
					)
					nubItem.pos = pos;
					
					fnSetListItem nubIndex nubItem.name
				)
			)
			else
			(
				format "[BsRetarget] Nub found\n"
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
	if hips == undefined then
	(
		return undefined
	)
	-- 安全获取 rootMotion，处理 NewHip_* 模式
	if matchpattern hips.name pattern:"NewHip_*" then
	(
		if hips.parent != undefined and hips.parent.parent != undefined then
			tempRM = hips.parent.parent
		else if hips.parent != undefined then
			tempRM = hips.parent
		else
			tempRM = hips
	)
	else
	(
		if hips.parent != undefined then
			tempRM = hips.parent
		else
			tempRM = hips
	)
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
						helperRoot = (GetSkeletalNode ((finditem rolBsRetarget.characterBones_B.items boneFBXRoot.parent.name) + 37) true)
					)
					default:
					(helperRoot = (getnodebyname ("RTHelper_" + boneFBXRoot.parent.name)))
				) 
				tempCopyBone = (copy boneFBXRoot)
				tempCopyBone.name = boneFBXRoot.name
				strTempName = tempCopyBone.name
				tempCopyBone.transform = boneFBXRoot.transform
				tempCopyBone.name = "RTHelper_" + strTempName
				tempCopyBone.parent = helperRoot
				-- lc = Link_Constraint();
				local pC = Position_Constraint()
				local oC = Orientation_Constraint()

				tempCopyBone.Position.controller = pC
				tempCopyBone.Rotation.controller = oC
				
				pC.appendTarget boneFBXRoot 100
				oC.appendTarget boneFBXRoot 100
				pC.relative = true
				oC.relative = true

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
	if boneFBXRoot == undefined then
	(
		return undefined
	)
	-- 安全获取 boneAllRoot，处理 NewHip_* 模式
	if matchpattern boneFBXRoot.name pattern:"NewHip_*" then
	(
		if boneFBXRoot.parent != undefined and boneFBXRoot.parent.parent != undefined then
			boneAllRoot = boneFBXRoot.parent.parent
		else if boneFBXRoot.parent != undefined then
			boneAllRoot = boneFBXRoot.parent
		else
			boneAllRoot = boneFBXRoot
	)
	else
	(
		if boneFBXRoot.parent != undefined then
			boneAllRoot = boneFBXRoot.parent
		else
			boneAllRoot = boneFBXRoot
	)
	if boneAllRoot != undefined then 
	(
		fnCopyChildSubBone boneAllRoot
	)
	else (fnCopyChildSubBone boneFBXRoot)
)

	fn fnCleanRootCurve x:false y:false z:false =
	(
		local boneHips = fnGetExistingBipedRoot()
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

	on tabBsADT SelectedIndexChanged arg do
	(
		local arrID = (tabBsADT.SelectedIndex + 1)
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
		local curState = fnBuildMappingState()
		if not curState.canCreateMapping then
		(
			gOpts.mappingCheckState = false
			fnUpdateStatusBar()
			fnShowBlockedByState "当前不能创建映射文件。" curState
			return undefined
		)
		fnSetRootNode curState.rootNode
		gOpts.mappingCheckState = true
		if gOpts.mappingCheckState then
		(
		pgbBar.value = 0
		lblBarValue.text = (pgbBar.value as string) + " %"
		max Create mode
		---断开质心防止旋转出问题，后面连上
		hips = (GetSkeletalNode 1 false)
		if hips == undefined then
		(
			messagebox kMsgNoRootBone title:kMsgTitle
			return undefined
		)
		-- rootMotionBone = (if matchpattern hips.name pattern:"NewHip_*" then hips.parent.parent else hips.parent)
		bsRootBone = curState.rootNode
		rootMotionBone = bsRootBone
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
			SetupNormalChildFN headNub 11 false;
			
			SetupNormalChildFN fingerNubs[1][1] 29 false;
			SetupNormalChildFN fingerNubs[1][2] 33 false;
			SetupNormalChildFN fingerNubs[1][3] 37 false;
			SetupNormalChildFN fingerNubs[1][4] 41 false;
			SetupNormalChildFN fingerNubs[1][5] 45 false;
			
			SetupNormalChildFN fingerNubs[2][1] 53 false;
			SetupNormalChildFN fingerNubs[2][2] 57 false;
			SetupNormalChildFN fingerNubs[2][3] 61 false;
			SetupNormalChildFN fingerNubs[2][4] 65 false;
			SetupNormalChildFN fingerNubs[2][5] 69 false;
			
			-- Sets up the toes?
			
			SetupNormalChildFN toeNubs[1] 16 true;
			SetupNormalChildFN toeNubs[2] 21 true;
			
			SetupNormalChildFN footHelpers[1] 14 false;
			SetupNormalChildFN footHelpers[2] 19 false;
	
			local tempArr = (fingerNubs + toeNubs + footHelpers)
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
				local headPos = GetBonePos 11
				local rootPos = 0.5 * ((GetBonePos 12) + (GetBonePos 17))
				local legLen = length ((GetBonePos 12) - (GetBonePos 17))
				local ang = -90

				local numNeckLink = if (not (fnIsIgnoreBone 9)) then 2 else 1
				local numSpineLink = 2
				if (not (fnIsIgnoreBone 5) and not (fnIsIgnoreBone 6) and not (fnIsIgnoreBone 7)) then numSpineLink = 5 
				else if (not (fnIsIgnoreBone 5) and not (fnIsIgnoreBone 6) and (fnIsIgnoreBone 7)) then numSpineLink = 4
				else if (not (fnIsIgnoreBone 5) and (fnIsIgnoreBone 6) and (fnIsIgnoreBone 7)) then numSpineLink = 3
				else if ((fnIsIgnoreBone 5) and (fnIsIgnoreBone 6) and (fnIsIgnoreBone 7)) then numSpineLink = 2

				local numFinger = 5
				for i in #(26,30,34,38,42) do 
				(
					if (fnIsIgnoreBone i) then (numFinger = numFinger - 1)
					-- print ("i:" + (i as string) + "  numFinger:" + (numFinger as string))
				)
				local newBiped = biped.createNew headPos.z ang [0,0,headPos.z] neckLinks:numNeckLink spineLinks:numSpineLink fingers:numFinger fingerLinks:3 toes:1 toeLinks:1 trianglePelvis:false triangleNeck:true
				fnInvalidateBipedCache()
				newBiped.transform.controller.figureMode = true;
				newBiped.controller.rootname = bipedRootName
				(GetBipedNode 1).controller.bodytype = 3
				bipedRootName = newBiped.name;

				rotate (GetBipedNode 47) (angleaxis 85 [0,1,0])
				rotate (GetBipedNode 23) (angleaxis -85 [0,1,0])
				
				-- STEP 1:  Move and scale the hips
				biped.setTransform newBiped.transform.controller.rootNode #pos rootPos false
				biped.setTransform (GetBipedNode 2) #scale [legLen, legLen, legLen] false
				
				-- Step 2:  Move the spine and scale from the first spine to the head
				local neckPos = GetBonePos 8
				local waistPos = GetBonePos 3
				biped.setTransform (GetBipedNode 3) #pos [neckPos.x, neckPos.y, waistPos.z] false
				AdjustBipedScale 3
				--RotateBone 3 (getNodeByName(n + " Spine")) 0
					
				AdjustBipedScale 4
				--RotateBone 4 (getNodeByName(n + " Spine1")) 0
					
				AdjustBipedScale 5
				AdjustBipedScale 6
				AdjustBipedScale 7
				--RotateBone 5 (getNodeByName(n + " Spine2")) 0
				
				AdjustBipedScale 8
				--RotateBone 6 (getNodeByName(n + " Neck")) 0
					
				AdjustBipedScale 9
				--RotateBone 7 (getNodeByName(n + " Neck1")) 0
					
				AdjustBipedScale 10
				--RotateBone 8 (getNodeByName(n + " Head")) 0		
				
				biped.setTransform (GetBipedNode 8) #pos neckPos false
				--biped.setTransform (GetBipedNode 8) #pos (GetBonePos 8) false
				
				-- Step 3:  Scale the legs
				-- LEFT
				AdjustBipedScale 12
				AdjustBipedScale 13
				
				-- RIGHT
				AdjustBipedScale 17
				AdjustBipedScale 18
				
				-- STEP 4:  Scale the Feet
				-- LEFT FOOT SCALE:  0.8 is (1 - biped attachment)
				local footVector = (GetBonePos 14) - (GetBonePos 15)
				local footVector2 = (GetBonePos 16) - (GetBonePos 14)
				biped.setTransform (GetBipedNode 14) #scale [abs footVector2.z, abs footVector.y / 0.8, abs (footVector.y + footVector.z) * 0.5] false		
				AdjustBipedScale 15 isToe:true
	
				-- RIGHT FOOT SCALE			
				footVector = (GetBonePos 19) - (GetBonePos 20)
				footVector2 = (GetBonePos 21) - (GetBonePos 19)
				biped.setTransform (GetBipedNode 19) #scale [abs footVector2.z, abs footVector.y / 0.8, abs (footVector.y + footVector.z) * 0.5] false		
				AdjustBipedScale 20 isToe:true
					
				-- Step 5:  Scale the arms and fingers.
				-- LEFT ARM
				--biped.setTransform (getNodeByName(n + " L Clavicle")) #pos (GetBonePos 20) false
				AdjustBipedScale 22
				AdjustBipedScale 23
				AdjustBipedScale 24
				AdjustBipedScale 25 isHand:true
				
				-- RIGHT ARM
				--biped.setTransform (getNodeByName(n + " R Clavicle")) #pos (GetBonePos 44) false
				AdjustBipedScale 46
				AdjustBipedScale 47
				AdjustBipedScale 48
				AdjustBipedScale 49 isHand:true
					
				-- -- LEFT FINGERS
				AdjustBipedScale 26
				AdjustBipedScale 27
				AdjustBipedScale 28
				
				AdjustBipedScale 30
				AdjustBipedScale 31
				AdjustBipedScale 32
					
				AdjustBipedScale 34
				AdjustBipedScale 35
				AdjustBipedScale 36
					
				AdjustBipedScale 38
				AdjustBipedScale 39
				AdjustBipedScale 40
					
				AdjustBipedScale 42
				AdjustBipedScale 43
				AdjustBipedScale 44
					
				-- -- RIGHT FINGERS
				AdjustBipedScale 50
				AdjustBipedScale 51
				AdjustBipedScale 52
				
				AdjustBipedScale 54
				AdjustBipedScale 55
				AdjustBipedScale 56
					
				AdjustBipedScale 58
				AdjustBipedScale 59
				AdjustBipedScale 60
					
				AdjustBipedScale 62
				AdjustBipedScale 63
				AdjustBipedScale 64
					
				AdjustBipedScale 66
				AdjustBipedScale 67
				AdjustBipedScale 68

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
			local createdBipRoot = (GetBipedNode 1)
			if createdBipRoot == undefined then
			(
				messagebox "没有找到 Biped 骨骼！                          "
				return undefined
			)
			
			-- Creates the faux bones
			-- Creates just a simple root bone
			local rootBone = point pos:createdBipRoot.transform.position -- rotation:(GetBonePos 1).transform.rotation
			rootBone.constantscreensize = false
			-- rootBone.box = true
			rootBone.name      = ("RTHelper_" + createdBipRoot.name)
			rootBone.size      = 0.01
			rootBone.transform = createdBipRoot.transform
			local bipedRetargetRM    = undefined
			local boneRetargetRM     = undefined
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
			local pelvisBone = CreateFauxBone rootBone  2 3 [0,-1,0]
			local newBone = CreateFauxBone pelvisBone 3 4 [0,-1,0]
			local topSpine = undefined
			if (not (fnIsIgnoreBone 7)) then 
			(
				newBone = CreateFauxBone newBone 4 5 [0,-1,0]
				newBone = CreateFauxBone newBone 5 6 [0,-1,0]
				newBone = CreateFauxBone newBone 6 7 [0,-1,0]
				topSpine = CreateFauxBone newBone 7 8 [0,-1,0]
			)
			else if (not (fnIsIgnoreBone 6)) then 
			(
				newBone = CreateFauxBone newBone 4 5 [0,-1,0]
				newBone = CreateFauxBone newBone 5 6 [0,-1,0]
				topSpine = CreateFauxBone newBone 6 8 [0,-1,0]
			)
			else if (not (fnIsIgnoreBone 5)) then 
			(
				newBone = CreateFauxBone newBone 4 5 [0,-1,0]
				topSpine = CreateFauxBone newBone 5 8 [0,-1,0]
			)
			else (topSpine = CreateFauxBone newBone 4 8 [0,-1,0])
			if (not (fnIsIgnoreBone 9)) then 
			(
				newBone = CreateFauxBone topSpine 8 9 [0,-1,0]
				newBone = CreateFauxBone newBone 9 10 [0,-1,0]
			)
			else (newBone = CreateFauxBone topSpine 8 10 [0,-1,0])
			newBone = CreateFauxBone newBone 10 11 [0,-1,0]
			newBone = CreateFauxBone newBone 11 0 [0,-1,0]
			
			-- Creates the legs
			local lThighBone = GetSkeletalNode 12 false
			local lCalfBone = GetSkeletalNode 13 false
			local lThighAxis = [0,-1,0]
			local lCalfAxis = [0,-1,0]
			if lThighBone != undefined then (lThighAxis = normalize lThighBone.transform.row2; if lThighAxis.y > 0 then lThighAxis = -lThighAxis)
			if lCalfBone != undefined then (lCalfAxis = normalize lCalfBone.transform.row2; if lCalfAxis.y > 0 then lCalfAxis = -lCalfAxis)
			newBone = CreateFauxBone pelvisBone 12 13 lThighAxis
			newBone = CreateFauxBone newBone 13 14 lCalfAxis
			newBone = CreateFauxBone newBone 14 15 [0,-1,0] isFoot:true
			newBone = CreateFauxBone newBone 15 16 [0,0,1] isToes:true
			newBone = CreateFauxBone newBone 16 0 [0,0,1]

			-- Creates the legs
			local rThighBone = GetSkeletalNode 17 false
			local rCalfBone = GetSkeletalNode 18 false
			local rThighAxis = [0,-1,0]
			local rCalfAxis = [0,-1,0]
			if rThighBone != undefined then (rThighAxis = normalize rThighBone.transform.row2; if rThighAxis.y > 0 then rThighAxis = -rThighAxis)
			if rCalfBone != undefined then (rCalfAxis = normalize rCalfBone.transform.row2; if rCalfAxis.y > 0 then rCalfAxis = -rCalfAxis)
			newBone = CreateFauxBone pelvisBone 17 18 rThighAxis
			newBone = CreateFauxBone newBone 18 19 rCalfAxis
			newBone = CreateFauxBone newBone 19 20 [0,-1,0] isFoot:true
			newBone = CreateFauxBone newBone 20 21 [0,0,1] isToes:true
			newBone = CreateFauxBone newBone 21 0 [0,0,1]
			
			
			-- Create the arms
			newBone = CreateFauxBone topSpine 22 23 [0,1,0]
			newBone = CreateFauxBone newBone 23 24 [0,1,0]
			newBone = CreateFauxBone newBone 24 25 [0,1,0]
			local lHandBone = undefined
			if (not (fnIsIgnoreBone 34)) then 
			(
				lHandBone = CreateFauxBone newBone 25 34 [0,0,-1] isHand:true
			)
			else (lHandBone = CreateFauxBone newBone 25 0 [0,0,-1] isHand:true)
			newBone = CreateFauxBone topSpine 46 47 [0,1,0]
			newBone = CreateFauxBone newBone 47 48 [0,1,0]
			newBone = CreateFauxBone newBone 48 49 [0,1,0]
			local rHandBone = undefined
			if (not (fnIsIgnoreBone 58)) then 
			(
				rHandBone = CreateFauxBone newBone 49 58 [0,0,-1] isHand:true
			)
			else (rHandBone = CreateFauxBone newBone 49 0 [0,0,-1] isHand:true)
			pgbBar.value = 10
			lblBarValue.text = (pgbBar.value as string) + " %"
			-- Create the fingers
			fn QuickFingers sI startingBone isThumbs =
			(
				if (not (fnIsIgnoreBone sI)) then 
				(
					try
					(
						local axis = [0,0,-1]
						local tBone = CreateFauxBone startingBone sI (sI+1) axis isHand:true
						tBone = CreateFauxBone tBone (sI+1) (sI+2) 	axis isHand:true
						tBone = CreateFauxBone tBone (sI+2) (sI+3) axis isHand:true
						tBone = CreateFauxBone tBone (sI+3) 0 axis isHand:true
					)
					catch()
				)
			)
			
			if (not (fnIsIgnoreBone 26)) then QuickFingers 26 lHandBone true
			if (not (fnIsIgnoreBone 30)) then QuickFingers 30 lHandBone false
			if (not (fnIsIgnoreBone 34)) then QuickFingers 34 lHandBone false
			if (not (fnIsIgnoreBone 38)) then QuickFingers 38 lHandBone false
			if (not (fnIsIgnoreBone 42)) then QuickFingers 42 lHandBone false
			
			if (not (fnIsIgnoreBone 50)) then QuickFingers 50  rHandBone true
			if (not (fnIsIgnoreBone 54)) then QuickFingers 54 rHandBone false
			if (not (fnIsIgnoreBone 58)) then QuickFingers 58 rHandBone false
			if (not (fnIsIgnoreBone 62)) then QuickFingers 62 rHandBone false
			if (not (fnIsIgnoreBone 66)) then QuickFingers 66 rHandBone false
			
		-- 检测 Root 和 Pelvis 是否映射同一骨骼
		local _sameRootPelvis = false
		(
			local _sn1 = GetSkeletalNode 1 false
			local _sn2 = GetSkeletalNode 2 false
			if _sn1 != undefined and _sn2 != undefined and _sn1.name == _sn2.name then _sameRootPelvis = true
		)
		-- Creates orientation constraints for the original rig to the faux rig.
		for i = 1 to characterBones.items.count do
		(
			case i of 
			(
				2:(if not _sameRootPelvis then CreateOrientationConstraint 2 false)
				11:() --nub
				16:() --nub
				21:() --nub
					23:
					(
						local lC = LookAt_Constraint();
						lC.appendTarget (GetSkeletalNode 24 false) 100;
						
						(getNodeByName ("RTHelper_" + (GetBipedNode 23).name)).Rotation.controller = lC;
						lC.relative = true;
					)
					29:() --nub
					33:() --nub
					37:() --nub
					-- 39:(()--ignore)
					-- 43:(()--ignore)
					-- 51:(()--ignore)
					-- 55:(()--ignore)
					-- 59:(()--ignore)
					-- 63:(()--ignore)
					-- 67:(()--ignore)
					default:(CreateOrientationConstraint i false)
				)
			)
			
			for i = 1 to characterBones_B.items.count do
			(
				case (i+37) of 
				(
					-- 7:(()--ignore)
					-- 9:(()--ignore)
					-- 14:(()--ignore)
					-- 19:(()--ignore)
					-- 27:(()--ignore)
					-- 31:(()--ignore)
					-- 35:(()--ignore)
					41:() --nub
					45:() --nub
					47:
					(
						local lC = LookAt_Constraint();
						lC.appendTarget (GetSkeletalNode 48 false) 100;
						
						(getNodeByName ("RTHelper_" + (GetBipedNode 47).name)).Rotation.controller = lC;
						lC.relative = true;
					)
					53:() --nub
					57:() --nub
					61:() --nub
					65:() --nub
					69:() --nub
					default:(CreateOrientationConstraint (i+37) false)
				)
			)
			
		CreatePositionConstraint 1 false
		if not _sameRootPelvis then CreatePositionConstraint 2 false

			CreatePositionConstraint 22 false
			CreatePositionConstraint 46 false
			
			CreatePositionConstraint 24 false
			CreatePositionConstraint 25 false

			CreatePositionConstraint 48 false
			CreatePositionConstraint 49 false
	
			pgbBar.value = 25
			lblBarValue.text = (pgbBar.value as string) + " %"
			--对齐 Biped
			fnAlignBipedToHelper()
			pgbBar.value = 55
			lblBarValue.text = (pgbBar.value as string) + " %"
			createdBipRoot.transform.controller.figureMode = false
			fnAlignBipedToHelper()
			pgbBar.value = 70
			lblBarValue.text = (pgbBar.value as string) + " %"
			biped.createCopyCollection createdBipRoot.controller "tempRetargetBipedPose"
			local copycol = biped.getcopycollection createdBipRoot.controller 1
			local icpmxbipcopy = biped.copybippose createdBipRoot.controller copycol #snapview
			-- strBipedPoseCollection = (biped.copyPosture (GetBipedNode 1).controller #pose true true true)
			createdBipRoot.transform.controller.figureMode = true
			biped.pastebippose createdBipRoot.controller icpmxbipcopy false #pstdefault true true true false
			-- biped.pastePosture (GetBipedNode 1).controller #pose false strBipedPoseCollection
			-- AlignBipToFaux 21
			-- AlignBipToFaux 23
			-- AlignBipToFaux 45
			-- AlignBipToFaux 47
			fnAlignBipedFingersToHelper ()
			-- (GetBipedNode 1).transform.controller.figureMode = false
			biped.deleteCopyCollection createdBipRoot.controller (biped.numCopyCollections createdBipRoot.controller)
			AlignBipToFaux 12
			AlignBipToFaux 17
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

			hips.parent = rootMotionBone
			createdBipRoot.parent = bipedRetargetRM
			rootBone.parent = boneRetargetRM

		if chkCopySubs.state then fnCopySubBones()
		else 
		(
			local skelNode1 = (GetSkeletalNode 1 false)
			local skelNode2 = (GetSkeletalNode 2 false)
			if skelNode1 != undefined and skelNode2 != undefined and \
			   matchpattern skelNode1.name pattern:"NewHip_*" and matchpattern skelNode2.name pattern:"NewPelvis_*" then 
			(
			tarHipBone = getnodebyname (substituteString skelNode1.name "NewHip_" "")
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

			tarPelvisBone = getnodebyname (substituteString skelNode2.name "NewPelvis_" "")
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
		else (messageBox kMsgCheckMapping title:kMsgTitle)
	)

    on reAlignFingers pressed do
    (
		if gOpts.mappingCheckState then
		(
			try(fnAlignBipedFingersToHelper ())
			catch(messageBox "重新对齐手指成功！                            ")
		)
		else (messageBox kMsgCheckMapping title:kMsgTitle)
    )


	on btnCount pressed do 
	(
		if (doesDirectoryExist edtAnimFbxPath.text) then
		(
			shellLaunch edtAnimFbxPath.text ""
		)
		else (messageBox "刷新动画列表，目录不存在！                             " title:kMsgTitle)
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

	fn fnTryApplyDetectedPreset =
	(
		local detected = fnDetectSkeletonPreset()
		if detected == undefined then return false

		local presetDir = ((getDir #scripts) + "\\BulletScripts\\Res\\BsMappingList\\")
		local presetPath = presetDir + detected + ".list"
		if not (doesFileExist presetPath) then return false

		if queryBox ("检测到骨架类型: " + detected + "\n是否应用预设？") title:kMsgTitle beep:false then
		(
			fnLoadMappingListAndRefresh presetPath
		)
		else false
	)

	on btnAutoMapping pressed do
	(
		fnPushMappingUndo()
		-- 空映射时先尝试预设自动识别
		local allEmpty = true
		for item in characterBones.items where item != "~undefined~" do (allEmpty = false; exit)
		if allEmpty then for item in characterBones_B.items where item != "~undefined~" do (allEmpty = false; exit)

		if allEmpty then
		(
			if (fnTryApplyDetectedPreset()) do return undefined
		)

		-- 合并两个列表为统一的69项数组进行处理
		local allItems = characterBones.items + characterBones_B.items
		-- 确保长度匹配 kBoneSlots（69项）
		while allItems.count < kBoneSlots.count do append allItems "~undefined~"

		local sceneObjs = objects as array
		local sceneNames = for o in sceneObjs collect o.name
		local usedNames = #()
		local pattMatchCount = 0

		-- ===== 第一轮：通配符模式匹配（快速精确）=====
		for obj in sceneObjs do
		(
			local tarNodeName = obj.name
			for j in pattBipedNames do
			(
				for k in j do
				(
					if (matchPattern tarNodeName pattern:k ignoreCase:true) then
					(
						local idx = findItem pattBipedNames j
						if idx > 0 and idx <= allItems.count and allItems[idx] == "~undefined~" then
						(
							if (findItem usedNames tarNodeName) == 0 then
							(
								allItems[idx] = tarNodeName
								appendIfUnique usedNames tarNodeName
								pattMatchCount += 1
							)
						)
					)
				)
			)
		)

		-- ===== 第二轮：左右镜像自动填充 =====
		local mirrorCount = 0
		for pair in kLeftRightMap do
		(
			local lIdx = pair[1]
			local rIdx = pair[2]
			if allItems[lIdx] != "~undefined~" and allItems[rIdx] == "~undefined~" then
			(
				local mirrorName = fnMirrorBoneName allItems[lIdx]
				if mirrorName != allItems[lIdx] and (findItem sceneNames mirrorName) != 0 \
				   and (findItem usedNames mirrorName) == 0 then
				(
					allItems[rIdx] = mirrorName
					appendIfUnique usedNames mirrorName
					mirrorCount += 1
				)
			)
			else if allItems[rIdx] != "~undefined~" and allItems[lIdx] == "~undefined~" then
			(
				local mirrorName = fnMirrorBoneName allItems[rIdx]
				if mirrorName != allItems[rIdx] and (findItem sceneNames mirrorName) != 0 \
				   and (findItem usedNames mirrorName) == 0 then
				(
					allItems[lIdx] = mirrorName
					appendIfUnique usedNames mirrorName
					mirrorCount += 1
				)
			)
		)

		-- ===== 第三轮：模糊匹配补充未匹配槽位 =====
		local fuzzyResult = fnFuzzyFillUnmatched allItems sceneNames threshold:0.55
		allItems = fuzzyResult[1]
		local fuzzyCount = fuzzyResult[2]

		-- ===== 第四轮：拓扑兜底匹配（父子链推断）=====
		-- 对仍未匹配的槽位，查找已匹配父槽位在场景中的子节点
		local parentMap = #(
			0,   --[1]  Bip001 无父
			1,   --[2]  Pelvis → Bip001
			2,   --[3]  Spine → Pelvis
			3,   --[4]  Spine1 → Spine
			4,   --[5]  Spine2 → Spine1
			5,   --[6]  Spine3 → Spine2
			6,   --[7]  Spine4 → Spine3
			4,   --[8]  Neck → Spine1 (或最高 Spine)
			8,   --[9]  Neck1 → Neck
			8,   --[10] Head → Neck (fallback)
			10,  --[11] HeadNub → Head
			2,   --[12] L Thigh → Pelvis
			12,  --[13] L Calf → L Thigh
			13,  --[14] L Foot → L Calf
			14,  --[15] L Toe0 → L Foot
			15,  --[16] L Toe0Nub → L Toe0
			2,   --[17] R Thigh → Pelvis
			17,  --[18] R Calf → R Thigh
			18,  --[19] R Foot → R Calf
			19,  --[20] R Toe0 → R Foot
			20,  --[21] R Toe0Nub → R Toe0
			4,   --[22] L Clavicle → Spine1
			22,  --[23] L UpperArm → L Clavicle
			23,  --[24] L Forearm → L UpperArm
			24,  --[25] L Hand → L Forearm
			25,  --[26] L Finger0 → L Hand
			26,  --[27] L Finger01 → L Finger0
			27,  --[28] L Finger02 → L Finger01
			28,  --[29] L Finger0Nub → L Finger02
			25,  --[30] L Finger1 → L Hand
			30,  --[31] L Finger11 → L Finger1
			31,  --[32] L Finger12 → L Finger11
			32,  --[33] L Finger1Nub → L Finger12
			25,  --[34] L Finger2 → L Hand
			34,  --[35] L Finger21 → L Finger2
			35,  --[36] L Finger22 → L Finger21
			36,  --[37] L Finger2Nub → L Finger22
			25,  --[38] L Finger3 → L Hand
			38,  --[39] L Finger31 → L Finger3
			39,  --[40] L Finger32 → L Finger31
			40,  --[41] L Finger3Nub → L Finger32
			25,  --[42] L Finger4 → L Hand
			42,  --[43] L Finger41 → L Finger4
			43,  --[44] L Finger42 → L Finger41
			44,  --[45] L Finger4Nub → L Finger42
			4,   --[46] R Clavicle → Spine1
			46,  --[47] R UpperArm → R Clavicle
			47,  --[48] R Forearm → R UpperArm
			48,  --[49] R Hand → R Forearm
			49,  --[50] R Finger0 → R Hand
			50,  --[51] R Finger01 → R Finger0
			51,  --[52] R Finger02 → R Finger01
			52,  --[53] R Finger0Nub → R Finger02
			49,  --[54] R Finger1 → R Hand
			54,  --[55] R Finger11 → R Finger1
			55,  --[56] R Finger12 → R Finger11
			56,  --[57] R Finger1Nub → R Finger12
			49,  --[58] R Finger2 → R Hand
			58,  --[59] R Finger21 → R Finger2
			59,  --[60] R Finger22 → R Finger21
			60,  --[61] R Finger2Nub → R Finger22
			49,  --[62] R Finger3 → R Hand
			62,  --[63] R Finger31 → R Finger3
			63,  --[64] R Finger32 → R Finger31
			64,  --[65] R Finger3Nub → R Finger32
			49,  --[66] R Finger4 → R Hand
			66,  --[67] R Finger41 → R Finger4
			67,  --[68] R Finger42 → R Finger41
			68   --[69] R Finger4Nub → R Finger42
		)

		-- 收集已占用的名称
		local topoUsedNames = #()
		for v in allItems where v != "~undefined~" do appendIfUnique topoUsedNames v

		local topoCount = 0
		for i = 1 to allItems.count where allItems[i] == "~undefined~" do
		(
			local pIdx = if i <= parentMap.count then parentMap[i] else 0
			if pIdx > 0 and allItems[pIdx] != "~undefined~" then
			(
				local parentNode = getNodeByName allItems[pIdx]
				if parentNode != undefined then
				(
					-- 从 kBoneSlots 获取期望骨骼名（无[可选]前缀）
					local expectName = if i <= kBoneSlots.count then kBoneSlots[i].name else ""
					if expectName == "" then continue
					local normExpect = fnNormalizeBoneName expectName

					local bestChild = undefined
					local bestScore = 0.0

					for child in parentNode.children where (findItem topoUsedNames child.name) == 0 do
					(
						local normChild = fnNormalizeBoneName child.name
						local dist = fnLevenshtein normChild normExpect
						local maxL = amax #(normChild.count, normExpect.count)
						local score = if maxL > 0 then (1.0 - dist as float / maxL as float) else 0.0
						if score > bestScore and score >= 0.4 then
						(
							bestScore = score
							bestChild = child.name
						)
					)
					if bestChild != undefined then
					(
						allItems[i] = bestChild
						appendIfUnique topoUsedNames bestChild
						topoCount += 1
					)
				)
			)
		)

		-- 写回两个列表
		local arrA = for i = 1 to 37 collect allItems[i]
		local arrB = for i = 38 to 69 collect allItems[i]
		characterBones.items = arrA
		characterBones_B.items = arrB

		-- ===== 自动识别 Root 节点 =====
		local rootAutoSet = fnResolveAndSetRoot()

		-- 统计未匹配数和必要项
		local unmatchedRequired = 0
		local unmatchedOptional = 0
		for i = 1 to allItems.count do
		(
			if allItems[i] == "~undefined~" then
			(
				if fnIsOptionalNodeIndex i then unmatchedOptional += 1
				else unmatchedRequired += 1
			)
		)
		local totalMatched = pattMatchCount + mirrorCount + fuzzyCount + topoCount
		local summary = "自动匹配完成！\r\n\r\n"
		summary += "  通配符匹配: " + pattMatchCount as string + " 个\r\n"
		if mirrorCount > 0 then summary += "  左右镜像: " + mirrorCount as string + " 个\r\n"
		if fuzzyCount > 0 then summary += "  模糊匹配: " + fuzzyCount as string + " 个\r\n"
		if topoCount > 0 then summary += "  拓扑推断: " + topoCount as string + " 个\r\n"
		if rootAutoSet then summary += "  Root 自动识别: " + (if lbxRoot.items.count > 0 then lbxRoot.items[1] else "~undefined~") + "\r\n"
		summary += "\r\n  合计: " + totalMatched as string + " / " + allItems.count as string + "\r\n"
		if unmatchedRequired > 0 then
			summary += "\r\n  [!] 必要骨骼缺失: " + unmatchedRequired as string + " 个，请手动指定！"
		else if unmatchedOptional > 0 then
			summary += "\r\n  可选骨骼未映射: " + unmatchedOptional as string + " 个（可忽略）"
		else
			summary += "\r\n  所有骨骼已映射完毕！"

		messagebox summary title:kMsgTitle beep:false
		fnUpdateStatusBar()
	)

	on btnRetargetSelected pressed do
	(
		if fnValidateRetargetInputs requireSelection:true then
		(
			local stateSilent = silentMode()
			setSilentMode true
			try
			(
				if CheckForSave() then
				(
					if not gOpts.isReloadBip then (fnExportReTargrtedAnim arrExportRetargetAnim ltbFilesList.selection)
					else (fnLoadBipAnim arrExportRetargetAnim ltbFilesList.selection)
					btnCount.text = ("待批处理原始动画 FBX 数：0 个")
				)
			)
			catch
			(
				format "[BsRetarget] btnRetargetSelected error: %\n" (getCurrentException())
			)
			setSilentMode stateSilent
		)
	)

	on btnRetargettAll pressed do
	(
		if fnValidateRetargetInputs() then
		(
			if CheckForSave() then
			(
				local stateSilent = silentMode()
				setSilentMode true
				pgbBar.color = blue
				pgbBar.value = 0
				lblBarValue.text = (pgbBar.value as string) + " %"
				try
				(
					for i = 1 to arrExportRetargetAnim.count where (doesFileExist arrExportRetargetAnim[i]) do
					(
						if not gOpts.isReloadBip then (fnExportReTargrtedAnim arrExportRetargetAnim i)
						else (fnLoadBipAnim arrExportRetargetAnim i)
						btnCount.text = ("待批处理原始动画 FBX 数：" + (arrExportRetargetAnim.count - i) as string + " 个")
						pgbBar.value = 100.*i/arrExportRetargetAnim.count
						lblBarValue.text = (pgbBar.value as string) + " %"
					)
					resetMaxFile #noPrompt
					messageBox ("已重定向所有动画，一共 " + (arrExportRetargetAnim.count as string) + " 个,\r\n\r\n在导出目录有相应 .max .bip 和 .FBX 文件") title:kMsgTitle
				)
				catch
				(
					format "[BsRetarget] btnRetargettAll error: %\n" (getCurrentException())
					messageBox ("批量重定向中断: " + (getCurrentException()) as string) title:kMsgTitle
				)
				setSilentMode stateSilent
				pgbBar.value = 0
				lblBarValue.text = "0 %"
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

	-- ====== SECTION 7: DIALOG INIT & HELP ======

	on rolBsRetarget open do
	(
		local dotColor        = dotnetclass "System.Drawing.Color"
		local maxuiBgColor    = (colorman.getcolor #background) * 255
		local BsDotFont       = dotnetobject "System.Drawing.Font" "Roboto" 8

		fnInitDotTabs()
		fnChangeToolsVisble (tabBsADT.SelectedIndex + 1)

		gOpts.mappingCheckState = false
		pgbBar.value = 0
		pgbBar.color = white
		lblBarValue.text = (pgbBar.value as string) + " %"

		arrMappingListFile = fnRefreshMappingFile()
		fnUpdateStatusBar()
	)

	on rolBsRetarget close do
	(
		if pickModeActive then fnPickModeExit()
		callbacks.removeScripts id:#bsPickMode
	)

	on ddlPreset selected id do
	(
		if id < 1 then return undefined
		if id > arrMappingListFile.count do arrMappingListFile = fnRefreshMappingFile()
		fileMappingList = if id <= arrMappingListFile.count then arrMappingListFile[id] else undefined
		if fileMappingList != undefined then
		(
			fnLoadMappingListAndRefresh fileMappingList quiet:true
		)
	)

	on btnApplyList pressed do 
	(
		arrMappingListFile = fnRefreshMappingFile()
		if arrMappingListFile.count != 0 then fileMappingList = arrMappingListFile[ddlPreset.selection]
		if fileMappingList != undefined then
		(
			fnLoadMappingListAndRefresh fileMappingList
		)
	)

	on btnApplyList rightClick do 
	(
		if doesDirectoryExist pathMappingListPreset then
		(
			shelllaunch pathMappingListPreset ""
		)
		else 
		(
			messagebox "映射列表预设文件夹不存在，已创建！                                       "
			makedir pathMappingListPreset
			shelllaunch pathMappingListPreset ""
		)
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
		local skinBones = for b in (refs.dependson sk) where isvalidnode b collect b
		skinBones
	)

	fn xchangeSkinBone sk source target = 
	(
		local result = off

		if sk == modpanel.getcurrentobject() and iskindof sk Skin do
		(
			local bones = collectSkinBones sk
			local sid = finditem bones source
			if sid > 0 do
			(
				skinops.removebone sk sid
				skinops.addbone sk target 0
			)
		)
		result
	)
	fn getTargetPair node = 
	(
		getnodebyname (substituteString node.name "OldBone_" "") 
	)
	fn xchangeSkin node =
	(
		local sk = getSkin node
		if sk == undefined then return 0

		select node
		max modify mode
		modpanel.setcurrentobject sk

		local count = 0
		local bones = collectSkinBones sk
		for source in bones do
		(
			local target = getTargetPair source
			if target != undefined do
			(
				local act = xchangeSkinBone sk source target
				if act do count += 1
			)
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

	fn fnLoadEnvelope theSkin envFile removeIncomingPrefix:false removeCurrentPrefix:false =
	(
	/*******************************************************************************
		Load an .env file via UI Accessor workaround (no silent API exists).
	*******************************************************************************/
		local confirmFn = confirmLoadEnvelopes

		DialogMonitorOps.Enabled = true
		DialogMonitorOps.RegisterNotification confirmFn id:#pressSkinOK
		try
		(
			skinOps.LoadEnvelope theSkin envFile
		)
		catch
		(
			format "[BsRetarget] fnLoadEnvelope failed: %\n" (getCurrentException())
		)
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
		try
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
		catch
		(
			format "[BsRetarget] fnConvertToBone failed: %\n" (getCurrentException())
		)
		delete tempBone
		enableSceneRedraw()
	)

	fn fnRenameBiped arrItems isB:false =
	(
		-- 在重命名之前检测 Root 和 Pelvis 是否映射同一骨骼
		local _sameRootPelvis = false
		if not isB then
		(
			local _sn1 = GetSkeletalNode 1 false
			local _sn2 = GetSkeletalNode 2 false
			if _sn1 != undefined and _sn2 != undefined and _sn1.name == _sn2.name then _sameRootPelvis = true
		)
		for i = 1 to arrItems.count where arrItems[i] != "~undefined~" do
		(
			if isB == false then 
			(
				tarBone = GetSkeletalNode i false
				tarBiped = (GetBipedNode i)
			)
			else 
			(
				tarBone = GetSkeletalNode (i + 37) false
				tarBiped = (GetBipedNode (i + 37))
			)

		if chkFbxMixBip.state then 
		(
			local skelNode1 = (GetSkeletalNode 1 false)
			local skelNode2 = (GetSkeletalNode 2 false)
			if not (i == 2 and skelNode1 != undefined and skelNode2 != undefined and skelNode1.name == skelNode2.name) then
			(
				local pC = Position_Constraint()
				pC.appendTarget tarBiped 100
				tarBone.Position.controller = pC
				pC.relative = true
				
				local oC = Orientation_Constraint()
				oC.appendTarget tarBiped 100
				tarBone.Rotation.controller = oC
				oC.relative = true
					tarBiped.name = "BipCtrl_" + tarBiped.name
				)
			)
		else
		(
			-- Root 和 Pelvis 同源时，Pelvis 跟随 Bip001，不独立处理
			if i == 2 and _sameRootPelvis then continue
			if matchpattern tarBone.name pattern:"NewHip_*" then 
			(
				tarHipBone = getnodebyname (substituteString tarBone.name "NewHip_" "")
				if tarHipBone != undefined then
				(
					tarBone = tarHipBone
					tarBone.parent = tarBiped
					for i in tarBone.children where i != undefined and (finditem rolBsRetarget.characterBones.items i.name == 0) and \
						(finditem rolBsRetarget.characterBones_B.items i.name == 0) do (i.parent = tarBone)
				)
				else
					format "[BsRetarget] NewHip 原骨骼未找到: %\n" tarBone.name
			)
	
			else if matchpattern tarBone.name pattern:"NewPelvis_*" then 
			(
				tarPelvisBone = getnodebyname (substituteString tarBone.name "NewPelvis_" "")
				if tarPelvisBone != undefined then
				(
					tarBone = tarPelvisBone
					tarBone.parent = tarBiped
					for i in tarBone.children where i != undefined and (finditem rolBsRetarget.characterBones.items i.name == 0) and \
						(finditem rolBsRetarget.characterBones_B.items i.name == 0) do (i.parent = tarBone)
				)
				else
					format "[BsRetarget] NewPelvis 原骨骼未找到: %\n" tarBone.name
			)
				else
				(
					if tarBiped.parent != undefined and tarBone != undefined then
					(
						if tarBone.name != tarBiped.parent.name do
						(
							tarBiped.name = tarBone.name
							tarBone.name = "OldBone_" + tarBone.name
							
							for i in tarBone.children where i != undefined and (finditem rolBsRetarget.characterBones.items i.name == 0) and \
							(finditem rolBsRetarget.characterBones_B.items i.name == 0) do 
							(
								tempLoc = point()
								tempLoc.transform = i.transform
								i.parent = tarBiped
								i.transform = tempLoc.transform
								delete tempLoc
							)
						)
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
		
			local FileIO = dotnetclass "Microsoft.VisualBasic.FileIO.FileSystem"
			local UIOption = (dotnetclass "Microsoft.VisualBasic.FileIO.UIOption").OnlyErrorDialogs
			local RecycleOption = (dotnetclass "Microsoft.VisualBasic.FileIO.RecycleOption").SendToRecycleBin
	
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
				(format "[BsRetarget] Deleted to recycle bin: %\n" (filenameFromPath targetDel))
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
		local curState = fnBuildMappingState()
		if not curState.canCreateMapping then
		(
			gOpts.mappingCheckState = false
			fnUpdateStatusBar()
			fnShowBlockedByState "当前不能转换为 Biped。" curState
			return undefined
		)
		fnSetRootNode curState.rootNode
		local bipRoot = fnGetExistingBipedRoot()
		if bipRoot == undefined then
		(
			gOpts.mappingCheckState = false
			fnUpdateStatusBar()
			fnShowBlockedAction "当前不能转换为 Biped。" "场景中没有可用的 Biped，请先创建映射文件。"
			return undefined
		)
		if gOpts.mappingCheckState then
		(
			pgbBar.color = green
			pgbBar.value = 0
			lblBarValue.text = (pgbBar.value as string) + " %"
			local hips = (GetSkeletalNode 1 false)
			if hips == undefined then
			(
				messagebox kMsgNoRootBone title:kMsgTitle
				return undefined
			)
			local boneRootMotion = undefined
			-- 处理 NewHip_* 模式时需要检查 parent.parent 是否存在
			if matchpattern hips.name pattern:"NewHip_*" then
			(
				if hips.parent != undefined and hips.parent.parent != undefined then
					boneRootMotion = hips.parent.parent
				else if hips.parent != undefined then
					boneRootMotion = hips.parent
				else
					boneRootMotion = hips
			)
			else
			(
				if hips.parent != undefined then
					boneRootMotion = hips.parent
				else
					boneRootMotion = hips
			)
			local bipRootMotion = bipRoot.parent
			if bipRootMotion == undefined then
			(
				fnShowBlockedAction "当前不能转换为 Biped。" "Biped RootMotion 不存在，请重新创建映射文件。"
				return undefined
			)
			bipRoot.transform.controller.figureMode = false

			local arrTarSkinMesh = #()
			if not chkFbxMixBip.state then
			(
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

			if not chkFbxMixBip.state then
			(
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
			)

			if not chkFbxMixBip.state then
			(
				bipRoot.controller.rootname = bipedRootName
				if boneRootMotion != undefined and bipRootMotion != undefined then 
				(
					boneRootMotion.children.parent = bipRootMotion
					delete boneRootMotion
				)
			)
			else
			(
				local pC = Position_Constraint()
				pC.appendTarget bipRootMotion 100
				boneRootMotion.Position.controller = pC
				pC.relative = true
				
				local oC = Orientation_Constraint()
				oC.appendTarget bipRootMotion 100
				boneRootMotion.Rotation.controller = oC
				oC.relative = true
			)
			
			clearselection()
			select $'RTHelper_*'
			selectmore $'NewHip_*'
			selectmore $'NewPelvis_*'
			selectmore $'NewSpine_*'
			if not chkFbxMixBip.state then selectmore $'OldBone_*'
			-- delete $
			for i in selection as array where isvalidnode i do delete i
			pgbBar.value = 100
			lblBarValue.text = (pgbBar.value as string) + " %"
			messagebox "Biped 已替换，且原 Bone 和多余 Helper 已被删除。\r\n\r\n【可能存在冗余节点未删除】，请检查骨骼链外的节点，自行清理~                                              " title:kMsgTitle
		)
		else (messageBox kMsgCheckMapping title:kMsgTitle)
	)

	-- on pkbRootMption picked obj do 
	-- (
	-- 	pickedRootMotion = obj 
	-- 	messagebox ("RootMotion 已指定为: " + obj.name + "                     ") title:kMsgTitle beep:false
	-- )

	-- on pkbRootMption rightclick do 
	-- (
	-- 	pkbRootMption.object = undefined
	-- )

	on btnConvertToBone pressed do with undo on
	(
		if (queryBox "注意备份文件！\r\n\r\n注意备份文件！\r\n\r\n注意备份文件！                                                     " \
		title:(kMsgTitle + " Tips") beep:false) then
		(
			arrConvertBones = (selection as array)
			if arrConvertBones.count != 0 then 
			(
				-- tm = timeStamp()
				for i in arrConvertBones where superclassof i == helper do 
				(
					fnConvertToBone i
				)
				if (chkRealign.state) then
				(
					if (queryBox "会重置蒙皮影响！会重置蒙皮影响！\r\n\r\n请确认使用的是蒙皮姿势 (SkinPose)                                                     " \
					title:(kMsgTitle + " Tips") beep:false) then
					(
						for i in arrConvertBones where (classof i.controller != Vertical_Horizontal_Turn) and (i.parent != undefined) do 
						(
							i.realignBoneToChild()
						)
					)
					fnRefreshSkinDeform()
				)
				-- format "ConvertToBone Cost % s\n" ((timeStamp()-tm)*0.001)
			)
		)
	)

	-- 帮助按钮事件
	on btnHelp pressed do
	(
		createDialog rolHelpDialog modal:true
	)

	on btnHandAxisTips pressed do
	(
		messageBox "💡 手指轴向设置指南 💡\n\n📋 操作步骤：\n1. 选择 Bone 手掌和手指骨骼\n2. 切换视图坐标为位移Local模式\n3. 观察坐标轴方向显示\n\n🎯 轴向判断：\n• 靠向身体背后的轴向 → 下拉列表选择对应轴\n• APose姿势：靠向身体两外侧的轴向\n• 通常为 Y轴 或 Z轴（根据模型而定）\n\n⚠️ 重要提醒：\n手指轴向设置影响重定向质量，\n请仔细观察Local坐标轴再进行选择！\n\n——————————————------------------——\nBullet.S  |  BsRetargetTools                                      " \
			title:"手指轴向提示" beep:false
	)

	on chkFbxMixBip changed state do 
	(
		if state do (messageBox "慎用，勾选后生成的 Skin 无法重定向动画！！！                                                " title:"警告")
	)
)

createDialog rolBsRetarget 655 680 style:#(#style_sysmenu, #style_toolwindow) fgcolor:myFgColor



rolBsRetarget.bipedBones.items = #(
	"Bip001", 				--1
	"Pelvis", 				--2
	"Spine", 				--3
	"Spine1",			--4
	"[可选]Spine2",			--5
	"[可选]Spine3",
	"[可选]Spine4",
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
	"[可选]L Finger0",			--24
	"[可选]L Finger01",		--25
	"[可选]L Finger02",		--26
	"[可选]L Finger0Nub",	--27
	"[可选]L Finger1",			--28
	"[可选]L Finger11",		--29
	"[可选]L Finger12",		--30
	"[可选]L Finger1Nub",	--31
	"[可选]L Finger2",			--32
	"[可选]L Finger21",		--33
	"[可选]L Finger22",		--34
	"[可选]L Finger2Nub"	    --35
)

rolBsRetarget.bipedBones_B.items = #(
	"[可选]L Finger3",			--36
	"[可选]L Finger31",		--37
	"[可选]L Finger32",		--38
	"[可选]L Finger3Nub",	--39
	"[可选]L Finger4",			--40
	"[可选]L Finger41",		--41
	"[可选]L Finger42",		--42
	"[可选]L Finger4Nub",	--43
	
	"R Clavicle",		--44
	"R UpperArm",		--45
	"R Forearm",		--46
	"R Hand",			--47
	"[可选]R Finger0",		--48
	"[可选]R Finger01",		--49
	"[可选]R Finger02",		--50
	"[可选]R Finger0Nub",	--51
	"[可选]R Finger1",		--52
	"[可选]R Finger11",		--53
	"[可选]R Finger12",		--54
	"[可选]R Finger1Nub",	--55
	"[可选]R Finger2",		--56
	"[可选]R Finger21",		--57
	"[可选]R Finger22",		--58
	"[可选]R Finger2Nub",	--59
	"[可选]R Finger3",		--60
	"[可选]R Finger31",		--61
	"[可选]R Finger32",		--62
	"[可选]R Finger3Nub",	--63
	"[可选]R Finger4",		--64
	"[可选]R Finger41",		--65
	"[可选]R Finger42",		--66
	"[可选]R Finger4Nub"		--67	
)

rolBsRetarget.characterBones.items = for i = 1 to rolBsRetarget.bipedBones.items.count collect "~undefined~"
rolBsRetarget.characterBones_B.items = for i = 1 to rolBsRetarget.bipedBones_B.items.count collect "~undefined~"

-- 帮助子面板（可折叠）
rollout rolHelp_Wf "Tab1: FBX 转 Biped 工作流程" height:168
(
	local m = 8; local w = 484; local h = 16; local s = 18
	label lbl0 "准备: 导入 FBX 骨骼模型到 3ds Max 场景" pos:[m,2] width:w height:h
	label lbl1 "1. 映射骨骼：选中场景 Bone，左键点击列表填入对应位置" pos:[m,2+s] width:w height:h
	label lbl1b "      或点击【自动匹配】(支持 Mixamo/CC4/UE5/Daz/MMD)" pos:[m,2+s+14] width:w height:h
	label lbl2 "2. 设置 Root：选中根骨骼，点击 Root 列表填入" pos:[m,2+s*2+14] width:w height:h
	label lbl3 "3. 设置轴向：选择引擎和手指轴向" pos:[m,2+s*3+14] width:w height:h
	label lbl4 "4. 点击【2.验证映射】确认列表完整" pos:[m,2+s*4+14] width:w height:h
	label lbl5 "5. 点击【3.创建映射文件】生成 Helper 中间文件" pos:[m,2+s*5+14] width:w height:h
	label lbl6 "6. 点击【4.FBX转Biped】完成骨架替换" pos:[m,2+s*6+14] width:w height:h
	label lbl7 "7. 验证结果，保存 .max 映射文件" pos:[m,2+s*7+14] width:w height:h
)

rollout rolHelp_Rt "Tab2: 动画重定向工作流程" height:112
(
	local m = 8; local w = 484; local h = 16; local s = 18
	label lbl1 "1. 打开 Tab1 生成的 Mapping.max 映射文件" pos:[m,2] width:w height:h
	label lbl2 "2. 切换到【动画重定向】页签" pos:[m,2+s] width:w height:h
	label lbl3 "3. 选择：动画FBX目录 / 导出目录 / 映射文件 / Skin文件" pos:[m,2+s*2] width:w height:h
	label lbl4 "4. 点击【重定向选中动画】或【重定向所有动画】" pos:[m,2+s*3] width:w height:h
	label lbl5 "5. 在 ReOutput 文件夹查看生成的 FBX/MAX/BIP" pos:[m,2+s*4] width:w height:h
	label lbl6 "目录结构建议: Skin.max + AniFBX/ + ReOutput/" pos:[m,2+s*5] width:w height:h
)

rollout rolHelp_Feat "功能说明" height:112
(
	local m = 8; local w = 484; local h = 16; local s = 18
	label lbl1 "• 自动匹配：通配符+模糊匹配+拓扑推断，支持预设自动识别" pos:[m,2] width:w height:h
	label lbl2 "• 左右同步：从已填的左/右侧自动推导对侧映射" pos:[m,2+s] width:w height:h
	label lbl3 "• 撤销：支持最近 20 步映射操作回退" pos:[m,2+s*2] width:w height:h
	label lbl4 "• 视口拾取：开关式拾取，视口点选骨骼自动按序填入空槽位" pos:[m,2+s*3] width:w height:h
	label lbl5 "• 状态栏：实时显示已映射/必需缺失/可选缺失/Root（带色码）" pos:[m,2+s*4] width:w height:h
	label lbl6 "• 预设系统：.list 文件存储完整映射+轴向配置" pos:[m,2+s*5] width:w height:h
)

rollout rolHelp_Ops "操作方式" height:94
(
	local m = 8; local w = 484; local h = 16; local s = 18
	label lbl1 "• 左键点击 Bone 列表：将选中场景骨骼填入该槽位" pos:[m,2] width:w height:h
	label lbl2 "• 右键点击 Bone 列表：清空该槽位" pos:[m,2+s] width:w height:h
	label lbl3 "• 左键点击 Bip 列表：选中场景中对应骨骼" pos:[m,2+s*2] width:w height:h
	label lbl4 "• 视口拾取：点击按钮开启/关闭，右键按钮跳过，Esc退出" pos:[m,2+s*3] width:w height:h
	label lbl5 "• 右键【应用】按钮：打开预设文件夹" pos:[m,2+s*4] width:w height:h
)

rollout rolHelp_Faq "常见问题" height:40
(
	local m = 8; local w = 484; local h = 16; local s = 18
	label lbl1 "• 手指轴向：观察 Local 坐标，选择靠向身体背后的轴" pos:[m,2] width:w height:h
	label lbl2 "• Nub 缺失：用【快速便捷小工具】自动创建" pos:[m,2+s] width:w height:h
)

-- 帮助主窗口（折叠面板 + 底部固定信息）
rollout rolHelpDialog "BsRetargetTools v5.2 使用帮助" width:520 height:600
(
	local helpW = 520

	label lblHelpTitle "BsRetargetTools v5.2 完整使用指南" pos:[10,6] width:500 height:20 style_sunkenedge:true
	subRollout subHelp "" pos:[0,30] width:520 height:520

	hyperLink hlHome "Bullet.S | www.anibullet.com" pos:[10,556] width:190 height:16 \
		address:"https://www.anibullet.com/" color:(color 30 90 180) hovercolor:(color 0 120 220)
	hyperLink hlVideo "Bilibili 教程" pos:[(helpW-120),556] width:100 height:16 \
		address:"https://space.bilibili.com/2031113/lists/560782?type=season" color:(color 30 90 180) hovercolor:(color 0 120 220)
	button btnClose "关闭" pos:[(helpW/2-50),575] width:100 height:22

	on rolHelpDialog open do
	(
		addSubRollout subHelp rolHelp_Wf rolledUp:false
		addSubRollout subHelp rolHelp_Rt rolledUp:true
		addSubRollout subHelp rolHelp_Feat rolledUp:true
		addSubRollout subHelp rolHelp_Ops rolledUp:true
		addSubRollout subHelp rolHelp_Faq rolledUp:true
	)
	on btnClose pressed do (destroyDialog rolHelpDialog)
)
