-- 试验功能可以加入快速创建方块武器，刀剑，锤，长枪，手枪等~~
-- 集成 RefBones 工具，WireColorPro 工具等

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
		label lblTitle "BsBoxMan_v1.1" pos:[5,3]
		dotNetControl tabBoxMan "System.Windows.Forms.TabControl" height:30 width:260 pos:[8,25] align:#center
		
		groupBox gpbBox "" pos:[5,55] width:250 height:110
		
		checkbutton chkCreateBodyBox ">> 根据所选物体 渲染框 创建 Body Box <<" pos:[10,70] height:25 width:240 border:false checked:true 
		radiobuttons rdoColor labels:#("随机颜色", "统一单色") columns:2 align:#center pos:[20,105]
		colorpicker rtcp "" width:70 height:20 color:[38,130,118] pos:[170,103]
		checkbox ckbFreeze "Box 是否冻结" pos:[20,135] width:100 height:20 color:[152, 227, 213] checked:true
		button btnClearBox "一键清除 Body Box" pos:[120,135] width:130 height:20 border:true
			
		groupBox gbpLWH "" pos:[5,170] width:250 height:180
		
		checkbutton ckbSync "等比调节" pos:[175,310] height:30 width:75 tooltip:"同时调节长宽高" border:false checked:true 
		checkbutton ckbReset "重置大小" pos:[110,310] height:30 width:60 tooltip:"重置长宽高" border:false checked:true 
		radiobuttons rdoReduce labels:#("放大", "缩小") columns:2 pos:[15,318] height:30 width:50 border:true Selection:1
		slider sldLenthValue ""  pos:[50,185] align:#center range:[1,20,1] \
		type:#integer width:170 ticks:50
		slider sldWidthValue ""  pos:[50,225] align:#center range:[1,20,1] \
		type:#integer width:170 ticks:50 
		slider sldHeightValue ""  pos:[50,265] align:#center range:[1,20,1] \
		type:#integer width:170 ticks:50
		label lblLenth "X：" pos:[15,195] width:30
		label lblWidth "Y：" pos:[15,235] width:30
		label lblHeight "Z：" pos:[15,275] width:30
		label lblLenthValue "x " pos:[215,195] width:30
		label lblWidthValue "x " pos:[215,235] width:30
		label lblHeightValue "x " pos:[215,275] width:30
		
		groupBox gpbDisplayUnit "Display Unit" pos:[5,355] width:105 height:50
		dropdownlist ddlMetric "" align:#left selection:2 height:15 width:95 pos:[10,375] \
		items:#("Millimeters","Centimeters","Meters","Kilometers")

		groupBox gpbSystemUnit "System Unit" pos:[115,355] width:105 height:50
		dropdownlist ddlSystemUnit "" align:#left selection:5 height:15 width:95 pos:[120,375] \
		items:#("Inches","Feet","Miles","Millimeters","Centimeters","Meters","Kilometers")

		button btnGetUnit "刷新" tooltip:"获取当前 Unit (单位) 状态" pos:[225,361] width:30 height:44

		dotnetcontrol lblTips "Label" text:"2023.2 [ Bullet.S ] ✨        创建专属练习方块人" pos:[0,413] width:260 height:16

--------------------------------------------------------------------------------------------------------------------------------------------

		local IDKEYWORD = "RefBone"		-- Ref Bone 임을 알아보는 유저디파인 정보용 키워드 디파인
		local IDKEYWORDHANDLE = "RefBoneHandle"		-- Ref Bone 임을 알아보는 유저디파인 정보용 키워드 디파인
		local IDKEYWORDTARGETHANDLE = "RefBoneTargetHandle"		-- Ref 본 의 타겟에 Ref 본의 핸들 번호를 기록
		local NAMEPREFIX = "Ref_"
		
		checkbutton chkProcess "生成参考骨骼" width:100 pos:[10,70] visible:false border:false checked:true 
		button uiBtnSelect "选中" width:50 visible:false pos:[120,70]
		button uiBtnClearAll "清除参考" width:70 visible:false pos:[180,70]
		spinner uiSpnBoneWidth "骨骼缩放比 %" pos:[50, 105] tooltip:"选择并调整创建的骨骼的大小。" range:[1, 500, 100] type:#integer width:100  visible:false
		colorPicker uiColorWireColor "颜色：" color:yellow pos:[165, 102] toolTip:"选择并更改颜色。"  visible:false height:20

		--checkbox <name> [<caption>] [checked:<boolean>] [triState:<integer>][tooltip:<string>
		checkbox uiChkOptPos "Position" checked:true  visible:false pos:[15,135]
		checkbox uiChkOptRot "Rotation" checked:true visible:false pos:[100,135]
		checkbox uiChkOptScale "Scale" checked:true visible:false pos:[185,135]
		
		checkbox uiChkOptInheritScale "继承缩放" pos:[15,160] checked:false toolTip:"默认：关闭\r\n\r\n除非有特殊情况，否则建议不继承"  visible:false
		checkbox uiChkKeepParent "保持父子层级关系" pos:[100,160] checked:false  visible:false
		
		/*
		Set Scalable Biped 버튼은 척추와 쇄골의 위치를 보정해주는 서브애님까지 추가하는 작업이 필요해서 만들다 말고 홀드 --> 서브애님 위치 보정을 해보려 헀는데, 단순 스케일에서 어긋나는 포지션이 규칙이 없다. (스케일을 키를 걸어놓고 보면 확실함)
		button uiBtnSetScalableBiped "Set Scalable Biped" tooltip:"Scale이 가능한 바이패드로 변경하고 Scale을 조정하는 헬퍼를 추가합니다."
		*/
		
		-- 더미 생성하는 스크립트 --
		spinner uiDummySize "Point 大小：" pos:[150, 203] tooltip:"创建辅助点的大小" range:[0.001, 100, 0.1] type:#float align:#right width:95 visible:false
		checkbutton uiBtnDummy "生成辅助 Point" pos:[10, 200] width:90 visible:false border:false checked:true 
		button uiBtnHelp "RefBones 关于，原作者" visible:false width:240 pos:[10, 240]

-----------------------------------------------------------------------------------------------------------------------------------------

		groupBox gpbType "" pos:[5,55] width:250 height:145 visible:false

		radiobuttons radObject "类型" pos:[20,70] labels:#( "几何体", "形状", "所有组", "所有物体", "选择物体" )  visible:false
		radiobuttons radColor "配色" pos:[130,70] columns:2 labels:#( "粉彩", "灰白", "毒彩" , "黏土" , "淡彩", "深沉" , "荧彩", "随机")  visible:false
		checkButton chkIsInstance "相关实例" pos:[20,170] height:20 width:80 tooltip:"启用后，相关实例\r\n(如复制出的Instance)\r\n也会保持一致的颜色。" height:  30 align:#left  visible:false
		checkbutton btnRandom ">> 随机颜色 <<" pos:[120,160] height:30 width:125 visible:false border:false checked:true 

		groupBox gpbGradient "渐变" pos:[5,210] width:170 height:45 visible:false
		colorpicker cpGradient1 pos:[15,230] color:  [58, 122, 205] width:70 height:15 align:#left  visible:false
		colorpicker cpGradient2 pos:[95,230] color:  [139, 49, 165] width:70 height:15 align:#right visible:false

		groupBox gpbRealTime "实时" pos:[185,210] width:70 height:45 visible:false
		colorpicker cp "" pos:[195,230] width:50 height:15 color:  [119, 95, 192] align:#center visible:false

		groupBox gpbMaterial "材质" pos:[5,260] width:250 height:60 visible:false
		radiobuttons radMaterial pos:[15,280] labels:#( "标准", "物理" ) columns:1 visible:false
		button btnConverter "转换" pos:[70,280] width:50 height:30 tooltip:"Convert WireColor to Material" width:70 height:30 visible:false

		radiobuttons radErase pos:[140,280] labels:#( "选择", "所有" )  columns:1 visible:false 
		Button btnErase "清除" pos:[195,280] width:50 height:30 tooltip:"Assign to objects" width:70 height:30 visible:false
		hyperLink author "markulie" pos:[15,390] address:"https://markulie.github.io" color:(color 255 255 255) hovercolor:(color 255 0 0) visitedcolor:(color 255 255 255) visible:false
-----------------------------------------------------------------------------------------------------------------------------------------

		edittext edtValue "\"卡通色\""  pos:[10,332] width:85 usePercentageWidth:true  visible:false \
		percentageWidth:44.0 labelOnTop:false text:"100" bold:false readOnly:false --自发光数值
		button btnSet "应用自发光"  pos:[180,330] width:75 height:20 tooltip:"调节选中，否则全部。\r\n需要先有材质!\r\n且非一致色彩模式!"  visible:false
		button btnSet0 "0"  pos:[105,330] width:25 height:20 tooltip:"调节选中，否则全部。"  visible:false
		button btnSet100 "100"  pos:[140,330] width:30 height:20 tooltip:"调节选中，否则全部。"  visible:false
		slider sldValue ""  pos:[15,350] align:#center range:[0,100,0]  visible:false \
		type:#integer tooltip:"调节选中，否则全部。" width:250

		HyperLink lnkLink "Adapter: Bullet.S" color:(color 255 255 255) hovercolor:(color 255 0 0) visitedcolor:(color 255 255 255) visible:false \
		address:"https://space.bilibili.com/2031113/channel/collectiondetail?sid=560782" pos:[165,390]

---------------------------------------------------------------------------------------------------------------------------------------------------------

		local arrCreateBox = #("方块包裹",#(lblLenth,lblWidth,lblHeight,ckbReset,gpbBox,gbpLWH,\
			chkCreateBodyBox,rdoColor,rtcp,ckbFreeze,btnClearBox,ckbSync,rdoReduce,sldLenthValue,sldWidthValue,\
			sldHeightValue,gpbDisplayUnit,gpbSystemUnit,btnGetUnit,ddlSystemUnit,ddlMetric,lblLenthValue,lblWidthValue,lblHeightValue))
		local arrRefBones = #("参考骨骼",#(uiChkKeepParent,uiBtnClearAll,chkProcess,uiBtnSelect,uiSpnBoneWidth,uiColorWireColor,uiChkOptPos,\
			uiChkOptRot,uiChkOptScale,uiChkOptInheritScale,uiDummySize,uiBtnDummy,uiBtnHelp))
		local arrEquipTools = #("⚔️ 装备",#())
		local arrColorTools = #("🎨 调色",#(gpbRealTime,gpbType,radObject,radColor,chkIsInstance,btnRandom,gpbGradient,cpGradient1,cpGradient2,\
			cp,gpbMaterial,radMaterial,btnConverter,radErase,btnErase,author,edtValue,btnSet,btnSet0,btnSet100,sldValue,lnkLink))
		local arrAllToolsTab = #(arrCreateBox,arrRefBones,arrEquipTools,arrColorTools)

		fn fnRefreshSliderValue =
		(
			rolBsBoxMan.lblLenthValue.text = "x " + (rolBsBoxMan.sldLenthValue.value as string)
			rolBsBoxMan.lblWidthValue.text = "x " + (rolBsBoxMan.sldWidthValue.value as string)
			rolBsBoxMan.lblHeightValue.text = "x " + (rolBsBoxMan.sldHeightValue.value as string)
		)
		
		function GetAlignBB obj = (		-- 월드 좌표상에서 자유롭게 회전되어있는 오브젝트의 바운딩 박스 포지션을 월드 중점으로 위치와 회전을 리셋하여 point 값 두 개를 리턴한다. 주로 길이를 재기 위한 용도
			bb = nodeGetBoundingBox obj obj.transform		-- 로컬 바운딩 박스 포지션 값 두 개가 배열로 bb에 저장됨 bb[1], bb[2]
			
			if ((classof obj.baseobject) == Point) do
			(	-- 포인트헬퍼는 점으로만 존재해서 바운딩박스를 강제로 넣엊줘야한다.
				bb[1].x -= obj.baseobject.size * 0.5
				bb[1].y -= obj.baseobject.size * 0.5
				bb[2].x += obj.baseobject.size * 0.5
				bb[2].y += obj.baseobject.size * 0.5
			)
			return bb
		)
		
		function GetWidthX obj = (		-- 선택된 오브젝트의 로컬 바운딩 박스 기준으로 x축 방향의 두께를 알아낸다. (길이가 아닌 두께 --> 본의 두께 값에 사용하기 위함)
			bb = GetAlignBB obj		-- 월드 중점으로 회전과 위치가 리셋된 바운딩 박스 생성
			return (((abs (bb[2].y - bb[1].y)) + (abs (bb[2].z - bb[1].z))) / 2.0)		-- z축 두께와 y축 두께의 평균값을 구한다.
		)
		
		function CheckWorkingBone obj = (		-- 어떤 작업을 할지 검사. "IGNORE", "CREATE", "MODIFY" 이렇게 세 가지 string을 리턴한다.
			if (getUserProp obj "RefBone") == true do (return "MODIFY")
			
			tFlag = false		-- 임시 플래그 생성
			
			-------------------- 검사 시작
			if (classof obj.baseobject == Biped_Object) do (tFlag = true)		-- 바이패드인 경우, 모디파이어가 적용된 바이패드나 본에는 baseobject 처리해줘야함
			if (obj.BoneEnable == true) do (tFlag = true)		-- 본인 경우
			if (classof obj.baseobject == Point) do (tFlag = true)
			if (classof obj.baseobject == Dummy) do (tFlag = true)
			
			if ((getUserProp obj IDKEYWORD) == true) do (tFlag = false)		-- 최종적으로 RefBone 이면 무조건 false 처리
			-------------------- 검사 끝
			
			if tFlag == true then (return "CREATE") else (return "IGNORE")
		)

		-- children이 Array로 바로 변환이 안돼서 만든 함수. 배열을 리턴
		function ChildrenToArray childrenArray = (
			local returnArray = #()
			for o in childrenArray do (
				append returnArray o
			)
			return returnArray
		)
		
		function FindLookAtPos obj = (		-- 바이패드의 목처럼 자식이 여럿 있는 본은 머리를 바라보면서 RefBone 이 생성되어야 한다. 이런 경우 똑똑하게 바라볼 본을 찾아주는 함수. 바라볼 위치를 리턴한다.
		-- 작동 방식은, 부모 본 위치에서 자식본 위치의 거리를 모두 알아내서, 부모본으로부터 x축으로 이동시켰더니 거리가 오히려 멀어지면 바라보는 본이 아니라는 방식으로 검출
		-- 검사중인 obj 가 일반 본일 경우 .length 값을 활용한다.
		-- 자식이 없는 바이패드 오브젝트나 일반 오브젝트의 BoneOn 인 경우에는 바운딩 박스 정보를 길이로 활용한다.
			
			tMatrix = obj.transform		-- 스케일이 리셋된 기준으로 tLength 계산을 해야함
			tMatrix.scale = [1, 1, 1]
			tMatrix.rotation = obj.transform.rotation
			tMatrix.position = obj.transform.position
			
			tLength = 1.0		-- 계산할 길이 변수 셋팅. 디폴트값은 1.0
			
			if obj.children.count == 0 then (		-- 자식이 하나도 없는 경우 본의 length 값을 이용하거나 로컬 바운딩 박스 중심으로부터 양의 x축 길이를 이용한다.
				tLength = case (classof obj.baseobject) of
				(
				BoneGeometry: obj.baseobject.length * obj.transform.scale.x
				Biped_Object: (biped.getTransform obj #scale).x
				default: (GetAlignBB obj)[2].x
				)
				/*
				if ((classof obj.baseobject) == BoneGeometry) then (
					tLength = obj.baseobject.length * obj.transform.scale.x
				)
				else (
					tLength = (GetAlignBB obj)[2].x
				)
				*/
			)
			else		-- 자식이 하나 이상인 경우
			(
				local targetNode
				local beforeDist = -1.0
				local childrenObjs = #() -- 자식들이 여럿일 때 바이패드가 하나라도 있으면 바이패드만 대상으로 자식을 다시 선별하기 위한 배열
				
				for o in obj.children do
				(
					if (classof o.baseobject) == Biped_Object do
					(
						append childrenObjs o -- 바이패드로 판명되면 배열에 추가
					)

				)
				
				if childrenObjs.count == 0 do
				(
					-- 바이패드가 하나도 발견되지 않으면 childrenObjs에 원래 자식들을 다시 적용
					childrenObjs = ChildrenToArray obj.children
				)

				for o in childrenObjs do
				(
					vDist = distance obj.transform.pos o.transform.pos		-- 기준 오브젝트로부터 자식 오브젝트의 거리를 측정
					if vDist > 0.001 do		-- 같은 위치에 있는 본은 처리 대상에서 제외한다. 제외 결과 자식이 하나도 없을 수 있는데 이때는 tLength 는 기본값인 1.0이 된다.
					(
						xPos = ((transMatrix [vDist, 0, 0]) * tMatrix).pos		-- 자식오브젝트 거리만큼 기준 오브젝트의 x축으로 이동한 위치
						endDist = distance xPos o.transform.pos		-- 이동한 위치로부터 자식 오브젝트까지의 거리 (이 거리가 짧을 수록 실제 목표 자식임. x축에 정렬되어있을 수록 이 거리가 짧다. x축에 벗어나면 이 거리가 커진다.)
						
						if beforeDist == -1.0 OR endDist <= beforeDist do		-- 현재 o의 endDist 가 이전보다 더 짧으면 o를 타겟 노드로 지정 후 beforeDist 업데이트
						(
							targetNode = o
							beforeDist = endDist
							tLength = (cos ((90 - acos ((endDist * 0.5) / vDist)) * 2)) * vDist		-- 타겟이 x축 중심에서 어긋나있을 경우에는 삼각함수로 계산해야함
						)
					)
				)
			)
			
			return ((transMatrix [tLength, 0, 0]) * tMatrix).pos		-- obj로부터 tLength 만큼 이동한 트랜스폼의 pos 리턴
		)
		
		function CreateBone pStart pEnd vUp vSize = (		-- 시작점, 끝점, 업벡터, 두께 입력받고 본 생성. 나머지 모든 본 지오메트리 변수들은 디폴트로 강제 셋팅
			tBone = BoneSys.createBone pStart pEnd vUp
			tBone.width = vSize
			tBone.height = vSize
			tBone.taper = 90.0
			-- tBone.length 이것은 자동 결정됨
			tBone.sidefins = false
			tBone.sidefinssize = vSize * 0.5
			tBone.sidefinsstarttaper 
			tBone.sidefinsendtaper 
			tBone.frontfin = false
			tBone.frontfinsize = vSize * 0.5
			tBone.frontfinstarttaper 
			tBone.frontfinendtaper 
			tBone.backfin = false
			tBone.backfinsize = vSize * 0.5
			tBone.backfinstarttaper = 10.0
			tBone.backfinendtaper = 10.0
			tBone.genmap = false
			
			tBone.boneScaleType=#none
			tBone.boneAutoAlign=false
			
			return tBone
		)
		
		function SetRefBoneAttr targetObj newObj = (		-- Ref Bone 속성과 컬러를 적용한다
			newObj.WireColor = uiColorWireColor.color
			setUserProp newObj IDKEYWORD "true"
			setUserProp newObj IDKEYWORDHANDLE targetObj.inode.handle
			setUserProp targetObj IDKEYWORDTARGETHANDLE newObj.inode.handle
			newObj.name = NAMEPREFIX + targetObj.name
		)
		
		function SetRefController targetObj newObj = (		-- 타겟 오브젝트를 따라하도록 스크립트 컨트롤러로 변경. 변경 당시 본의 상대적인 transform 유지는 보류.
			-- 일단 컨트롤러 리셋
			newObj.pos.controller = Position_XYZ ()
			newObj.rotation.controller = Euler_XYZ ()
			newObj.scale.controller = bezier_scale ()

			newObj.scale = targetObj.transform.scale
			newObj.rotation = targetObj.transform.rotation
			newObj.pos = targetObj.transform.pos
			
			if (uiChkOptPos.state == true) do (
				newObj.pos.controller = Position_Constraint ()
				newObj.pos.controller.appendTarget targetObj 50.0
			)

			if (uiChkOptRot.state == true) do (
				newObj.rotation.controller = Orientation_Constraint ()
				newObj.rotation.controller.appendTarget targetObj 50.0
			)

			if (uiChkOptScale.state == true) do (
				newObj.scale.controller = scale_script ()
				newObj.scale.controller.AddNode "TG" targetObj
				newObj.scale.controller.SetExpression "tScale = try (TG.transform.scale * TG.inode.stretchTM.scale) catch ([1, 1, 1])
	if abs (tScale.x - 1.0) < 0.00001 do (tScale.x = 1.0)
	if abs (tScale.y - 1.0) < 0.00001 do (tScale.y = 1.0)
	if abs (tScale.z - 1.0) < 0.00001 do (tScale.z = 1.0)
	tScale"
			)

			-- Scale 상속
			if ( uiChkOptInheritScale.state == false ) then (
				setInheritanceFlags newObj #{1, 2, 3, 4, 5, 6}		-- scale 상속 관련 문제를 막기 위해 inherit 를 꺼줌
			)
			else (
				setInheritanceFlags newObj #{1, 2, 3, 4, 5, 6, 7, 8, 9}		-- scale 을 강제로 상속하려면 켜줌
			)
		)

		-- 레프본이 참조하는 원본 (바이패드 등)을 리턴한다.
		function GetRefOrigin ref = (
			local handle = getUserProp ref IDKEYWORDHANDLE
			return (maxOps.getNodeByHandle handle)
		)

		-- 원본이 참조하는 Ref본을 리턴한다. 원본에 Ref본 기록이 없거나 찾을 수 없으면 undefined 리턴.
		function GetRef origin = (
			local refBone
			try (refBone = maxOps.getNodeByHandle (getUserProp origin IDKEYWORDTARGETHANDLE)) catch (
				refBone = undefined
			)

			return refBone
		)
		
		function CheckIfExist obj = (		-- 현재 처리하려고 하는 오브젝트에 이미 Ref Bone 이 생성되어있는지를 조사. Ref Bone 툴로 생성된 본에는 무조건 IDKEYWORDHANDLE = "RefBoneHandle" 의 유저 프로퍼티로 원본 본의 핸들 번호가 있기때문에 이를 조사함)
			if obj == undefined do return undefined		-- 부모의 Ref Bone 을 찾는 과정에서 undefined 가 obj 로 입력될 수 있어서 방어코드
			
			local rNode
			rNode = GetRef obj -- 일단 현재 오브젝트에 Ref본 기록이 있는지 찾아본다.
			if (rNode != undefined) do (return rNode) -- 기록이 있으면 그 오브젝트를 리턴

			-- 기록이 없으면 전체 오브젝트 안에서 다 찾아본다.
			for o in objects do (
				if (obj.inode.handle == getUserProp o IDKEYWORDHANDLE) do (rNode = o)
			)
			return rNode		-- Ref Bone 을 리턴한다. 못찾으면 undefined 리턴
		)
		
		function AutoParent targetObj newObj = (		-- 새로 생성된 Ref Bone 의 부모를 자동 지정하도록 하는 함수
			if targetObj.parent == undefined do return ()		-- 타겟 오브젝트의 부모가 없으면 그냥 리턴해야함

			tObj = CheckIfExist targetObj.parent		-- 타겟 오브젝트 부모의 Ref Bone 을 찾는다.
			if tObj != undefined do (newObj.parent = tObj)		-- 타겟 부모의 Ref Bone을 찾았으면 새로 생긴 Ref Bone의 부모로 링크
		)
		
		-- obj 의 모든 자식들을 배열로 리턴. 배열 순서는 계층구조 순서대로
		function GetAllChildren obj = (
			if ( obj == undefined ) do return undefined
			
			local tAllChildren = #()
			if ( obj.children.count != 0 ) do (
				for o in obj.children do (
					append tAllChildren o
					if ( o.children.count != 0 ) do (
						tAllChildren = tAllChildren +  (GetAllChildren o)		-- recursive
					)
				)
			)
			
			return tAllChildren
		)
		
		-- 선택이 바이패드라면, 소속된 모든 바이패드를 리턴.
		function GetAllBiped obj = (
			if ( obj == undefined ) do return undefined
			if ( classof obj.baseobject != Biped_Object ) do return undefined
			
			local bipedRoot = obj.controller.rootNode
			
			local allChildren = GetAllChildren bipedRoot
			
			local allBiped = #()
			for o in allChildren do
			(
				if classof o.baseobject == Biped_Object do
				(
					append allBiped o
				)
			)
			return allBiped
		)

----------------------------------------------------------------------------------------------------------------

		fn fnInitDotTabs =
		(
			lblTips.font       = dotnetobject "System.Drawing.Font" "Roboto" 8
			lblTips.TextAlign  = (dotnetclass "system.drawing.contentalignment").MiddleCenter
			lblTips.BackColor  = (dotColor.FromArgb	255 250 250)
			lblTips.ForeColor  = (dotColor.FromArgb 60 0 160)
			tabBoxMan.sizeMode  = (dotnetclass "System.Windows.Forms.TabSizeMode").Fixed
			tabBoxMan.itemSize  = dotNetObject "System.Drawing.Size" 60 30
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
			LayerManager.newLayerFromName "001_Ref_Boxes"
			tmpLayer = LayerManager.getLayerFromName "001_Ref_Boxes"

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

				tmplayer.addnode b
			)
		)

		fn fnCapitalizeFirstLetter str = 
		(
			if str != "" and str != undefined then
			(
				local firstLetter = substring str 1 1
				local remainingLetters = substring str 2 (str.count - 1)
				return (toupper firstLetter) + remainingLetters
			)
		)

		fn fnRefreshUnite =
		(
			strMertic = (fnCapitalizeFirstLetter (units.metricType as string))
			strSysType = (fnCapitalizeFirstLetter (units.systemType as string))
			idMetric = (finditem rolBsBoxMan.ddlMetric.items strMertic)
			idSysType = (finditem rolBsBoxMan.ddlSystemUnit.items strSysType)
			if idMetric != undefined and idSysType != undefined then
			(
				rolBsBoxMan.ddlMetric.Selection = idMetric
				rolBsBoxMan.ddlSystemUnit.Selection = idSysType
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
			fnRefreshUnite()
			fnRefreshSliderValue()

			callbacks.addScript #filePostOpen "rolBsBoxMan.fnRefreshUnite ()" id:#BsBoxManCallbackOpen
			callbacks.addScript #systemPostNew "rolBsBoxMan.fnRefreshUnite ()" id:#BsBoxManCallbackNew
			callbacks.addScript #systemPostReset "rolBsBoxMan.fnRefreshUnite ()" id:#BsBoxManCallbackReset
			callbacks.addScript #selectionSetChanged "rolBsBoxMan.fnRefreshUnite ()" id:#BsBoxManSelChange
		)

		on btnClose pressed do 
		(
			try (destroydialog rolBsBoxMan) catch ()

			callbacks.removeScripts id:#BsBoxManCallbackOpen
			callbacks.removeScripts id:#BsBoxManCallbackNew
			callbacks.removeScripts id:#BsBoxManCallbackReset
			callbacks.removeScripts id:#BsBoxManSelChange
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

		on chkCreateBodyBox changed state do
		(
			chkCreateBodyBox.state = true
			fnCreateBoxBody()
		)

		on btnClearBox pressed do 
		(
			try(delete $'*_BsBoxManBox';messagebox "清除BsBox成功!                      " title:"BsBoxMan")
			catch(messagebox "错误：清除BsBox失败!                      " title:"BsBoxMan")
		)

		on ddlMetric selected id do
		(
			units.displayType= #Metric
			units.metricType= (ddlMetric.items[id] as name)
		)

		on ddlSystemUnit selected id do
		(
			units.SystemType= (ddlSystemUnit.items[id] as name)
		)

		on btnGetUnit pressed do 
		(
			fnRefreshUnite()
		)

		on chkProcess changed state do (
			chkProcess.state = true
			if selection.count == 0 do return ()		-- 선택된 오브젝트가 없으면 그냥 리턴
			
			undo on (
				
				LayerManager.newLayerFromName "001_Ref_Bones"   -- 레이어 생성.
				tmpLayer = LayerManager.getLayerFromName "001_Ref_Bones"  --생성한 레이어 가져오기.
						-- Undo 가 가능하도록
				local tTarget = #()		-- 부모 링크 작업을 위해서는 모든 Ref Bone 이 생겨난 뒤에 for 문을 한 번 더 돌려야하므로 작업 대상을 기억시키는 배열이 필요함
				local tNew = #()			-- 부모 링크 작업을 위해서는 모든 Ref Bone 이 생겨난 뒤에 for 문을 한 번 더 돌려야하므로 작업 대상을 기억시키는 배열이 필요함
				for o in selection do (
					checkStr = CheckWorkingBone o
					case of (
						(checkStr == "CREATE"):(
							-- 바이패드를 선택한 채 Process를 눌렀음. Ref본을 생성하거나 기존 Ref본을 수정함.
							local tReply = #yes		-- 유저의 대답을 기억하는 로컬 변수
							local foundRefBone = CheckIfExist o
							
							local tBone
							if foundRefBone != undefined then (
								tBone = foundRefBone
							)
							else (
								tBone = CreateBone o.transform.pos (FindLookAtPos o) o.dir ((GetWidthX o) * (uiSpnBoneWidth.value * 0.01))
							)
							
							SetRefBoneAttr o tBone		-- RefBone 속성 지정
							SetRefController o tBone		-- 컨트롤러 변경
							if ((classof o.baseobject) != Point AND (classof o.baseobject) != Dummy) do
							(
								o.boxMode = on
							)
							append tTarget o
							append tNew tBone
						)
						(checkStr == "MODIFY"):(
							-- Ref본을 선택한 채 Process를 눌렀음. Ref본을 수정하기만 함'
							-- 이 경우 o가 Ref본
							local tOrigin = GetRefOrigin o
	
							SetRefBoneAttr tOrigin o		-- RefBone 속성 지정
							SetRefController tOrigin o		-- 컨트롤러 변경
	
							if ((classof tOrigin.baseobject) != Point AND (classof tOrigin.baseobject) != Dummy) do (
								tOrigin.boxMode = on
							)
							append tTarget tOrigin
							append tNew o
						)
						default:()
					)
				) -- for end
				if tTarget.count != 0 do (		-- CheckWorkingBone 체크에 의해 tTarget 개수가 0일 가능성이 있음.
					--for o = 1 to tTarget.count do (AutoParent tTarget[o] tNew[o])
				)
				
				select tNew

				for i in selection do tmplayer.addnode i
			)
		)
		
		on uiBtnSelect pressed do (
			tSel = #()
			for o in objects do (
				if ((getUserProp o IDKEYWORD) == true) do (append tSel o)
			)
			select tSel
		)
		
		on uiSpnBoneWidth changed var do (
			if selection.count == 0 do return ()
			tObj = #()
			for o in selection do (
				if (getUserProp o IDKEYWORD) == true do (append tObj o)		-- 선택 오브젝트들 안에서 Ref Bone 만 골라낸다
			)
			if tObj.count == 0 do return ()
			
			for o in tObj do (
				tNode = maxOps.getNodeByHandle (getUserProp o IDKEYWORDHANDLE)		-- 핸들 번호로 타겟 본을 역으로 알아낸다. 못찾으면 tNode 는 undefined
				tScale = 1.0 / ((tNode.transform.scale.y + tNode.transform.scale.z) * 0.5)
				if tNode != undefined do (
					tValue = (GetWidthX tNode) * (uiSpnBoneWidth.value * 0.01 * tScale)
					o.width = tValue
					o.height = tValue
				)
			)			
		)
		
		on uiColorWireColor changed var do (
			for o in selection do (
				if ((getUserProp o IDKEYWORD) == true) do (o.wirecolor = var)
			)
		)
		
		-- 스케일시 1번 척추와 쇄골의 위치가 엉뚱한 곳에 있게된다. 이것을 보정해주는 Position 서브애님 컨트롤러를 추가해야함.
		-- on uiBtnSetScalableBiped pressed do
		-- (
		-- 	if selection[1] == undefined do return()
		-- 	if (classof selection[1].baseobject != Biped_Object) do return()
			
		
		-- 	local allBiped = GetAllBiped selection[1]
		-- 	local rootBiped = selection[1].controller.rootNode
		-- 	local pelvis = biped.getNode selection[1] #Pelvis link:1
			
		-- 	local newPoint = Point isSelected:off Box:on Centermarker:off axistripod:off cross:off size:((GetWidthX pelvis) * 2.2) wirecolor:green
		-- 	newPoint.transform = rootBiped.transform
		-- 	newPoint.parent = rootBiped
			
		-- 	-- 혹시 모를 오류를 방지하기 위해 figure모드는 꺼준다.
		-- 	rootBiped.controller.figureMode = false
			
		-- 	--paramWire.connect $.transform.controller[#Scale] $'Bip001 L Forearm'.transform.controller.Biped_SubAnim.controller.BipScaleList.controller[#Bezier_Scale] "Scale"
	
		-- 	for o in allBiped do
		-- 	(
		-- 		if ( classof o.controller == BipSlave_Control) do
		-- 		(
		-- 			o.controller.Biped_SubAnim.controller.BipScaleList.Available.controller = bezier_scale()
		-- 			o.controller.Biped_SubAnim.controller.BipScaleList.active = o.controller.Biped_SubAnim.controller.BipScaleList.count
					
		-- 			paramWire.connect newPoint.transform.controller[#Scale] o.transform.controller.Biped_SubAnim.controller.BipScaleList.controller[o.controller.Biped_SubAnim.controller.BipScaleList.count] "Scale"
		-- 		)
		-- 	)
		-- 	select newPoint
		-- )
	
		--찌노님 제작--
		on uiBtnDummy changed state do ( 
			uiBtnDummy.state = true
			LayerManager.newLayerFromName "001_Ref_Dummy"   -- 레이어 생성.
			tmpLayer = LayerManager.getLayerFromName "001_Ref_Dummy"  --생성한 레이어 가져오기.
			sel = selection as array
	
			for s in sel do
			(
				--create point
				--tmpDummySize = uiDummySize.value * 1  -- 
				pt = point centerMaker:False axisTripod:False cross:True box:True size:uiDummySize.value
				pt.wirecolor = color 250 160 0
				--rename point
				pt.name = "RefPoint_" + s.name
				--match transform to selected object
				pt.transform = s.transform
				--assign rotation controller
				pt.rotation.controller = orientation_constraint()
				pt.position.controller = position_constraint()
				--append target
				pt.rotation.controller.appendTarget s 100
				pt.position.controller.appendTarget s 100
				
				tmplayer.addnode pt --새성한 포인트 레이어에 넣기.
				
			)
			
		)
		
		on uiBtnHelp pressed do (
			shellLaunch "http://cafe.naver.com/pinksox/5035" ""
		)
		
		on uiDummySize changed val do
		(
			for b in selection where classof b == BoneGeometry or classof b == dummy or classof b == point do
			(
				case classof b of
				(
					(BoneGeometry):(b.width = val;b.height = val)
					(Dummy):(b.boxsize = [val,val,val])
					(point):(b.size = val)
				)
			)
		)

		on uiBtnClearAll pressed do
		(
			delLayerA    = LayerManager.getLayerFromName "001_Ref_Bones"
			delLayerB	 = LayerManager.getLayerFromName "001_Ref_Dummy"
			
			if delLayerA != undefined then with undo on
			(
				delLayerObj = #()
				layerRTA = delLayerA.nodes &delLayerObj
				delLayerA.lock = off
				tDel = #()
				for o in delLayerObj do (
					if ((getUserProp o IDKEYWORD) == true) do (delete o)
				)
				LayerManager.deleteLayerByName "001_Ref_Bones"
				delLayerObj = #()

				messageBox "清理 RefBones 成功！				" title:"BsBoxMan"
			)

			if delLayerB != undefined then with undo on
			(
				delLayerObj = #()
				layerRTB = delLayerB.nodes &delLayerObj
				delLayerB.lock = off
				for j in delLayerObj where (delLayerObj.count != 0) do 
				(
					if ((matchpattern j.name pattern:"RefPoint_*") == true) do 
					delete j
				)
				LayerManager.deleteLayerByName "001_Ref_Dummy"
				delLayerObj = #()

				messageBox "清理 RefPoints 成功！				" title:"BsBoxMan"
			)
		)

		fn getRandomColor =  
		(  
			local randomColor = blue  
			if radColor.state == 1 then  
			(  
				randomColor.hue = random 0 255  
				randomColor.saturation = 120  
				randomColor.value = random 150 240  
			)  
			else if radColor.state == 2 then       
			(  
				randomColor = white * random 0.2 0.8  
			)  
			else if radColor.state == 3 then  
			(  
				randomColor.hue = random 0 255  
				randomColor.saturation = 255  
			)
			else if radColor.state == 4 then  
			(  	
				local r = random 5 30	
				randomColor = color (r*6) (r*2) r
			)
			else if radColor.state == 5 then       
			(  
				randomColor.hue = random 0 255  
				randomColor.saturation = 30  
				-- randomColor.value = 180
			)
			else if radColor.state == 6 then  
			(  
				randomColor.hue = random 0 255 
				randomColor.saturation = 90  
				randomColor.value = 90 
			)  
			else if radColor.state == 7 then  
			(  	
				randomColor.hue = random 40 140  
				randomColor.saturation = 255  
				randomColor.value = 255
			)
			else if radColor.state == 8 then  
			(  
				randomColor = random black white  
			)
			return randomColor  
		)  

		on btnRandom changed state do  
		(  
			btnRandom.state = true
			with undo on
			(	
				if radObject.state == 1 then  
				(  
					for i in geometry do  
					(  
						InstanceMgr.GetInstances i &instArray  
						if chkIsInstance.checked then  
						(  
							instArray.wirecolor = getRandomColor()   
						)  
						else  
						(  
							i.wirecolor = getRandomColor()   
						)  
					)  
				) 
				else if radObject.state == 2 then  
				(  
					for i in shapes do  
					(  
						InstanceMgr.GetInstances i &instArray  
						if chkIsInstance.checked then  
						(  
							instArray.wirecolor = getRandomColor()   
						)  
						else  
						(  
							i.wirecolor = getRandomColor()   
						)  
					)  
				)
				else if radObject.state == 3 then  
				(  
					allGroups = for obj in objects where isGroupHead obj collect obj  
					if allGroups.count == 0 then  
					(  
						messageBox "There are no groups in the scene."  
					)  
					else  
					(  
						fn changeInstancesRandom group =  
						(  
							local randomColor = getRandomColor()   
							for i in group do  
							(  
								InstanceMgr.GetInstances i &instArray  
								instArray.wirecolor = randomColor	
							)
						) 
						fn changeWireColorRandom group =  
						(  
							local randomColor = getRandomColor()   
							for i in group do  
							(
								i.wirecolor = randomColor  
							)
						)
						
						if chkIsInstance.checked then
						(
							for group in allGroups do  
							(  
								changeInstancesRandom group  
							)
						)
						for group in allGroups do  
						(  
							changeWireColorRandom group  
						)						
					)  
				) 
				else if radObject.state == 4 then  
				(  
					for i in objects do  
					(  
						InstanceMgr.GetInstances i &instArray  
						if chkIsInstance.checked then  
						(  
							instArray.wirecolor = getRandomColor()   
						)  
						else  
						(  
							i.wirecolor = getRandomColor()   
						)  
					)  
				)  				
				else if radObject.state == 5 then  
				(  
					if selection.count < 1 then messagebox "Please select at least one object"  
					else  
					(  
						for i in selection do  
						(  
							InstanceMgr.GetInstances i &instArray  
							if chkIsInstance.checked then  
							(  
								instArray.wirecolor = getRandomColor()   
							)  
							else  
							(  
								i.wirecolor = getRandomColor()   
							)  
						)  
					)  
				) 
			)
			redrawviews()   
		)  
		fn FnGradient =  
		(  
			local domain = if selection.count == 0 then objects else selection  
			local cnt = domain.count  
			if cnt >= 2 then  
			(  
				local col1 = cpGradient1.color  
				local col2 = cpGradient2.color  
				local step = ( col2 - col1 ) / ( cnt - 1 )  
				for i = 1 to cnt do domain[i].wireColor = col1 + ( i - 1 ) * step  
			)  
			redrawviews()   
		)  

		on cpGradient1 changed val do FnGradient()   
		on cpGradient2 changed val do FnGradient()   

		on cp changed newColor do  
		(  
			if selection.count > 0 then  
			(  
				for obj in selection do  
				(  
					selection.wirecolor = newColor  
				)  
			)  
			else  
			(  
				for obj in geometry do  
				(  
					geometry.wirecolor = newColor  
				)  
			)  
		)  
		
		fn FnMatS objs =  
		(  
			for i in objs do  
			(  
				if superClassOf i == geometryClass then  
				(  
					newColor = i.wireColor  
					i.material = standardMaterial showInViewport:true name:  ( "WireColor Pro - " + i.name )  
					i.material.diffuse = newColor  
				)  
			)  
			redrawviews()   
		)  

		fn FnMatP objs =  
		(  
			for i in objs do  
			(  
				if superClassOf i == geometryClass then  
				(  
					newColor = i.wireColor  
					i.material = physicalMaterial showInViewport:true name:  ( "WireColor Pro - " + i.name )  
					i.material.Base_Color = newColor  
				)  
			)  
			redrawviews()   
		)  

		on btnConverter pressed do  
		(  
			if selection.count < 1 then  
			(  
				messagebox "Please select at least one object"  
			)  
			else  
			(  
				if radMaterial.state == 1 then  
				(  
					FnMatS selection  
				)  
				else if radMaterial.state == 2 then  
				(  
					FnMatP selection  
				)  
			)  
		)  
		on btnErase pressed do  
		(  
			if radErase.state == 1 then  
			(  
				if selection.count < 1 then  
				(  
					messagebox "Please select at least one object"  
				)  
				else  
				(  
					$.material = undefined  
				)  
			)  
			else  
			(  
				if geometry.count < 1 then  
				(  
					messagebox "You have no geometry objects"  
				)  
				else  
				(  
					geometry.material = undefined  
				)  
			)  
		)  

		-- End  
		
		local selfValue = 100
		local arrSelObj = #()
	
	
		fn jugdeSel =
		(
			if (selection.count == 0) then
			(
				arrSelObj = #()
				for i in objects do (append arrSelObj i)
			)
			else
			(
				arrSelObj = #()
				for i in selection do (append arrSelObj i)
			)
		)
	
		fn fnSetSelfIllumAmount arrSelObj val = 
		(
			for i in arrSelObj do
			(
				if (classof i.mat == Multimaterial) do  
				(
					for s = 1 to i.mat.materialList.count do  i.mat.materialList[s].selfIllumAmount = val
				)
				if (classof i.mat == Standardmaterial) do 
				(
					i.mat.selfIllumAmount = val
				)
			)
		)
	
		on edtValue entered val do
		(
			jugdeSel ()
			if ((val != ".") and (val as integer != undefined) and (val != "") and (val as integer <= 100) and (val as integer >= 0)) then
			(
				sldValue.value = (val as integer)
			)
		)
	
		on sldValue changed val do (jugdeSel ();fnSetSelfIllumAmount arrSelObj val;edtValue.text = val as string)
	
		on btnSet pressed do 
		(
			jugdeSel ()
			if ((edtValue.text != ".") and (edtValue.text as integer != undefined) and (edtValue.text != "") and (edtValue.text as integer <= 100) and (edtValue.text as integer >= 0)) then
			(
				fnSetSelfIllumAmount arrSelObj (edtValue.text as integer)
				sldValue.value = (edtValue.text as integer)
			)
			else messagebox "-------------------------\r\n请输入0-100的整数数值\r\n"
		)
		on btnSet0 pressed do (jugdeSel ();fnSetSelfIllumAmount arrSelObj 0;sldValue.value = 0;edtValue.text = "0")
	
		on btnSet100 pressed do (jugdeSel ();fnSetSelfIllumAmount arrSelObj 100;sldValue.value = 100;edtValue.text = "100")

		on rdoReduce changed state do
		(
			try(
				if rdoReduce.state == 2 then 
				(
					$.scale.x = (1.0/sldLenthValue.value)
					$.scale.y = (1.0/sldWidthValue.value)
					$.scale.z = (1.0/sldHeightValue.value)
				)
				else
				(
					$.scale.x = sldLenthValue.value
					$.scale.y = sldWidthValue.value
					$.scale.z = sldHeightValue.value
				)
			)catch()
		)

		on sldLenthValue changed val do 
		(
			fnRefreshSliderValue()
			try(if rdoReduce.state == 2 then $.scale.x = (1.0/val) else $.scale.x = val)catch()
		)

		on sldWidthValue changed val do 
		(
			fnRefreshSliderValue()
			try(if rdoReduce.state == 2 then $.scale.y = (1.0/val) else $.scale.y = val)catch()
		)

		on sldHeightValue changed val do 
		(
			fnRefreshSliderValue()
			try(if rdoReduce.state == 2 then $.scale.z = (1.0/val) else $.scale.z = val)catch()
		)

		on ckbReset changed state do 
		(
			--可以记录之前长宽高在自定义属性里面
			ckbReset.state = true
			try 
			(
				$.scale = [1,1,1]
				sldLenthValue.value = 1
				sldWidthValue.value = 1
				sldHeightValue.value = 1
			)
			catch(messagebox "仅支持创建的 Boxes！请勿选择其他类型！                 " title:"BsBoxMan")
			fnRefreshSliderValue()
		)

		on lblTips mouseup arg do
		(
			shellLaunch "https://space.bilibili.com/2031113/channel/collectiondetail?sid=560782" ""
		)
	)
	createDialog rolBsBoxMan style:#()
)