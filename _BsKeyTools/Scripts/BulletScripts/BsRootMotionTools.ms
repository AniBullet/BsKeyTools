--만든이 : 이상원
global RMC_DataCA
-- 다음 attribID 번호는 플러그인을 구분하는 중요한 번호인데, 제작 초반에 중요한 실수를 했었고 지금은 수정됨.
-- (문제 기록용) 코드 구조 편하게 만든다고 attributes 외부에서 global 변수로 RMC_ID = #(0x7b72aada, 0x1462108b) 이런 식으로 만들고 커스텀 어트리뷰트에서 변수를 사용했더니 다음에 씬을 로딩할 때에는 global 변수를 인식할 수 없어서 씬 컨버터가 계속 missing DLL 관련 오류로 체크하고 제거하려고 함.
-- attribID 관련 문서: https://help.autodesk.com/view/MAXDEV/2022/ENU/?guid=GUID-9F96FB7D-EB51-41FA-976D-C39DEED69CE4
-- 요약 결론, 조금 귀찮더라도 attribID는 코드 내에서 직접 숫자로 사용해야함.
RMC_DataCA= attributes RMC_Data attribID:#(0x7b72aada, 0x1462108b) (
	parameters main rollout:RMCRollout (
		--오브젝트 지정을 #node 타입으로 하면 루트 본과 circular dependency 관계가 되어서 expression 컨트롤러의 변수 지정이 불가함.
		--그래서 #node 타입 대신에 #integer 타입으로 지정하고 inode.handle 방식으로 오브젝트를 기억시킴.
		--다음 #node 타입은 기록용으로 남겨둠.
		--PelvisObj type:#node subAnim:false	--subAnim을 true로 하면 선택된 오브젝트의 애니메이션을 커스텀 어트리뷰트에서도 다룰 수 있게 된다. false로 하면 커브 에디터 트랙에서 보이지 않고 숨겨진다.
		PelvisObjHandle type:#integer subAnim:false
		RootObjHandle type:#integer subAnim:false

		-- 커브 에디터 트랙에서 대문자료 표시되기 위해 파라미터 변수는 대문자로 시작하게 함.
		ManualX type:#float ui:spnManualX default:0
		ManualY type:#float ui:spnManualY default:0
		ManualZ type:#float ui:spnManualZ default:0
		TrackX type:#float ui:sliderTrackX default:0
		TrackX_Offset type:#float ui:spnTrackX_Offset default:0
		TrackY type:#float ui:sliderTrackY default:0
		TrackY_Offset type:#float ui:spnTrackY_Offset default:0
		TrackZ type:#float ui:sliderTrackZ default:0
		TrackZ_Offset type:#float ui:spnTrackZ_Offset default:0
		ManualYaw type:#float ui:spnManualYaw default:0
		TrackYaw type:#float ui:sliderTrackYaw default:0
		TrackYaw_Offset type:#float ui:spnTrackYaw_Offset default:90
	)

	-- 롤아웃의 ui 변수는 파라미터명과 동일하게 하지 말아야 이벤트에서 변수를 사용할 때 오류가 발생하지 않음.
	rollout RMCRollout ("Root Motion Controller 0.93") (
		local animStateBackup	-- OnButtonDown, OnButtonUp 함수에서 Auto Key 상태를 강제로 비활성하기 전 이전 상태를 기록하기 위한 로컬 변수

		pickbutton pickAnimPelvisObj "Pick Animated Pelvis" width:140 tooltip:"애니메이션된 pelvis를 선택합니다. 바이패드의 경우 Bip001을 선택해주세요.\nSelect the animated pelvis. For the Bipad, select Bip001."
		label labelPelvisObj "Pelvis: " align:#left offset:[0, -6]
		pickbutton pickRootObj "Pick Root" width:140 tooltip:"루트로 사용할 오브젝트를 선택해주세요.\nSelect an object to use as the root."
		label labelRootObj "Root: " align:#left offset:[0, -6]
		button btnLinkController "Link Controller" width:140 tooltip:"Root에 컨트롤러를 적용하고 Pelvis와 연결합니다.\nApply the controller to Root and connect it with Pelvis."
		
		group "Position Control" (
			spinner spnManualX "ManualX" type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100
			spinner spnManualY "ManualY" type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100
			spinner spnManualZ "ManualZ" type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100
			label labelTrackX "TrackX" align:#left width:50 offset:[0, 10] across:2
			slider sliderTrackX "" type:#float range:[0.0, 1.0, 0.0] width:100 align:#left offset:[-20, -4]
			spinner spnTrackX_Offset "TrackX_Offset" type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:136
			label labelTrackY "TrackY" align:#left width:50 offset:[0, 10] across:2
			slider sliderTrackY "" type:#float range:[0.0, 1.0, 0.0] width:100 align:#left offset:[-20, -4]
			spinner spnTrackY_Offset "TrackY_Offset" type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:136
			label labelTrackZ "TrackZ" align:#left width:50 offset:[0, 10] across:2
			slider sliderTrackZ "" type:#float range:[0.0, 1.0, 0.0] width:100 align:#left offset:[-20, -4]
			spinner spnTrackZ_Offset "TrackZ_Offset" type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:136
			button btnGetPelvisPosZ "Get Pelvis PosZ" align:#center width:140 tooltip:"지면으로부터 골반의 높이 값을 자동으로 가져와 TrackZ_Offset에 적용합니다.\nAutomatically gets the height value of the pelvis from the ground and applies it to TrackZ_Offset."
		)
		
		group "Rotation Control" (
			spinner spnManualYaw "ManualYaw" type:#float range:[-99999.0, 99999.0, 0.0] align:#left width:100
			label labelTrackYaw "TrackYaw" align:#left width:50 offset:[0, 10] across:2
			slider sliderTrackYaw "" type:#float range:[0.0, 1.0, 0.0] width:90 align:#left offset:[-10, -4]
			spinner spnTrackYaw_Offset "TrackYaw_Offset" type:#float range:[-99999.0, 99999.0, 90.0] align:#left width:118 tooltip:"Default = 90"
		)

		label labelAbout "cafe.naver.com/pinksox/9011"
		
		function Initialize = (
			local pelvisObj = maxOps.getNodeByHandle PelvisObjHandle
			if (pelvisObj != undefined) do (
				labelPelvisObj.text = "Pelvis: " + pelvisObj.name
			)
			local rootObj = maxOps.getNodeByHandle RootObjHandle
			if (rootObj != undefined) do (
				labelRootObj.text = "Root: " + rootObj.name
			)
			-- 파라미터에 컨트롤러가 지정되어있지 않으면 컨트롤러 적용
			if (ManualX.controller == undefined) do (ManualX.controller = bezier_float ())
			if (ManualY.controller == undefined) do (ManualY.controller = bezier_float ())
			if (ManualZ.controller == undefined) do (ManualZ.controller = bezier_float ())
			if (TrackX.controller == undefined) do (TrackX.controller = bezier_float ())
			if (TrackX_Offset.controller == undefined) do (TrackX_Offset.controller = bezier_float ())
			if (TrackY.controller == undefined) do (TrackY.controller = bezier_float ())
			if (TrackY_Offset.controller == undefined) do (TrackY_Offset.controller = bezier_float ())
			if (TrackZ.controller == undefined) do (TrackZ.controller = bezier_float ())
			if (TrackZ_Offset.controller == undefined) do (TrackZ_Offset.controller = bezier_float ())
			if (ManualYaw.controller == undefined) do (ManualYaw.controller = bezier_float ())
			if (TrackYaw.controller == undefined) do (TrackYaw.controller = bezier_float ())
			if (TrackYaw_Offset.controller == undefined) do (TrackYaw_Offset.controller = bezier_float ())
		)

		on pickAnimPelvisObj picked obj do (
			if obj == undefined do return()
			PelvisObjHandle = obj.inode.handle
			labelPelvisObj.text = "Pelvis: " + obj.name
		)

		on pickRootObj picked obj do (
			if obj == undefined do return()
			RootObjHandle = obj.inode.handle
			labelRootObj.text = "Root: " + obj.name
		)
		
		on btnLinkController pressed do (
			-- 대상 오브젝트가 하나라도 지정되지 않으면 그냥 리턴
			local pelvisObj = maxOps.getNodeByHandle PelvisObjHandle
			if pelvisObj == undefined do return()
			local rootObj = maxOps.getNodeByHandle RootObjHandle
			if rootObj == undefined do return()
			local myRMC_Data = selection[1].baseObject.RMC_Data	-- Root Motion Controller 롤아웃 데이터

			-- 포지션 컨트롤러 지정
			rootObj.pos.controller = Position_XYZ ()
			-- 이 부분의 컨트롤러를 로컬 변수화 하여 가독성을 단순화하려고 했으나 변수에서 AddScalarTarget은 작동하지 않음.
			rootObj.pos.controller.X_Position.controller = Float_Expression ()
			rootObj.pos.controller.Y_Position.controller = Float_Expression ()
			rootObj.pos.controller.Z_Position.controller = Float_Expression ()
			rootObj.pos.controller.X_Position.controller.AddScalarTarget "ManualX" myRMC_Data.ManualX.controller
			rootObj.pos.controller.Y_Position.controller.AddScalarTarget "ManualY" myRMC_Data.ManualY.controller
			rootObj.pos.controller.Z_Position.controller.AddScalarTarget "ManualZ" myRMC_Data.ManualZ.controller
			rootObj.pos.controller.X_Position.controller.AddVectorNode "PelvisPos" pelvisObj
			rootObj.pos.controller.Y_Position.controller.AddVectorNode "PelvisPos" pelvisObj
			rootObj.pos.controller.Z_Position.controller.AddVectorNode "PelvisPos" pelvisObj
			rootObj.pos.controller.X_Position.controller.AddScalarTarget "TrackX" myRMC_Data.TrackX.controller
			rootObj.pos.controller.X_Position.controller.AddScalarTarget "TrackX_Offset" myRMC_Data.TrackX_Offset.controller
			rootObj.pos.controller.Y_Position.controller.AddScalarTarget "TrackY" myRMC_Data.TrackY.controller
			rootObj.pos.controller.Y_Position.controller.AddScalarTarget "TrackY_Offset" myRMC_Data.TrackY_Offset.controller
			rootObj.pos.controller.Z_Position.controller.AddScalarTarget "TrackZ" myRMC_Data.TrackZ.controller
			rootObj.pos.controller.Z_Position.controller.AddScalarTarget "TrackZ_Offset" myRMC_Data.TrackZ_Offset.controller
			rootObj.pos.controller.X_Position.controller.SetExpression "(TrackX_Offset + PelvisPos.x)*TrackX + ManualX*(1-TrackX)"
			rootObj.pos.controller.Y_Position.controller.SetExpression "(TrackY_Offset + PelvisPos.y)*TrackY + ManualY*(1-TrackY)"
			rootObj.pos.controller.Z_Position.controller.SetExpression "(TrackZ_Offset + PelvisPos.z)*TrackZ + ManualZ*(1-TrackZ)"
			
			-- 로테이션 컨트롤러 지정
			rootObj.rotation.controller
			rootObj.rotation.controller = Euler_XYZ ()
			rootObj.rotation.controller.X_Rotation.controller = Float_Expression ()	-- 미 사용 로테이션도 강제로 0으로 초기화
			rootObj.rotation.controller.X_Rotation.controller.SetExpression "0"
			rootObj.rotation.controller.Y_Rotation.controller = Float_Expression ()	-- 미 사용 로테이션도 강제로 0으로 초기화
			rootObj.rotation.controller.Y_Rotation.controller.SetExpression "0"
			rootObj.rotation.controller.Z_Rotation.controller = float_script ()			-- Z 로테이션은 Bip001의 회전을 얻어오기위해 스크립트 컨트롤러 지정
			rootObj.rotation.controller.Z_Rotation.controller.AddTarget "ManualYaw" myRMC_Data.ManualYaw.controller
			rootObj.rotation.controller.Z_Rotation.controller.AddTarget "TrackYaw" myRMC_Data.TrackYaw.controller
			rootObj.rotation.controller.Z_Rotation.controller.AddTarget "TrackYaw_Offset" myRMC_Data.TrackYaw_Offset.controller
			rootObj.rotation.controller.Z_Rotation.controller.AddNode "PelvisObj" pelvisObj
			rootObj.rotation.controller.Z_Rotation.controller.SetExpression "local pelvisYaw = degToRad (PelvisObj.transform.rotation as EulerAngles).z
local track = (pelvisYaw + degToRad (TrackYaw_Offset)) * TrackYaw
local manual = degToRad(ManualYaw) * (1-TrackYaw)
return (track + manual)"
		)

		on btnGetPelvisPosZ pressed do (
			local pelvisObj = maxOps.getNodeByHandle PelvisObjHandle
			if pelvisObj == undefined do return()
			TrackZ_Offset = -pelvisObj.transform.pos.z	-- 마이너스 처리
		)

		-- 오브젝트가 선택될 때마다 롤아웃이 오픈되고 이벤트가 실행된다.
		on RMCRollout open do (
			Initialize()
		)

		-- 플레이 도중 슬라이더나 스피너 변화가 있을 때 애니메이션 키가 생성되지 않도록 막는 함수
		function OnButtonDown = (
			animStateBackup = animButtonState
			if isAnimPlaying() do (
				animButtonState = false		-- 슬라이더나 스피너 변화 중에는 강제로 애니메이션 Off
			)
		)

		function OnButtonUp = (
			animButtonState = animStateBackup
		)

		on spnManualX buttondown do (OnButtonDown())
		on spnManualX buttonup do (OnButtonUp())
		on spnManualY buttondown do (OnButtonDown())
		on spnManualY buttonup do (OnButtonUp())
		on spnManualZ buttondown do (OnButtonDown())
		on spnManualZ buttonup do (OnButtonUp())
		on sliderTrackX buttondown do (OnButtonDown())
		on sliderTrackX buttonup do (OnButtonUp())
		on spnTrackX_Offset buttondown do (OnButtonDown())
		on spnTrackX_Offset buttonup do (OnButtonUp())
		on sliderTrackY buttondown do (OnButtonDown())
		on sliderTrackY buttonup do (OnButtonUp())
		on spnTrackY_Offset buttondown do (OnButtonDown())
		on spnTrackY_Offset buttonup do (OnButtonUp())
		on sliderTrackZ buttondown do (OnButtonDown())
		on sliderTrackZ buttonup do (OnButtonUp())
		on spnTrackZ_Offset buttondown do (OnButtonDown())
		on spnTrackZ_Offset buttonup do (OnButtonUp())
		on spnManualYaw buttondown do (OnButtonDown())
		on spnManualYaw buttonup do (OnButtonUp())
		on sliderTrackYaw buttondown do (OnButtonDown())
		on sliderTrackYaw buttonup do (OnButtonUp())
		on spnTrackYaw_Offset buttondown do (OnButtonDown())
		on spnTrackYaw_Offset buttonup do (OnButtonUp())
   )
)

global RootMotionTools		-- 롤아웃명을 글로벌 변수로 인식하기 위해 초기에 한 번 사용
try (destroydialog RootMotionTools) catch()		-- 혹시 열려있는 창이 있으면 강제 종료

rollout RootMotionTools ("Root Motion Tools 0.93") width:200
(
	local STRING_PICK_CONTROLLER = "Pick Controller"
	
	pickbutton uiPickController STRING_PICK_CONTROLLER width:166 tooltip:"컨트롤러 오브젝트를 지정\n(우클릭: 등록된 오브젝트를 선택합니다)\nPick the controller object\n(Right-click: Select the registered object)"
	button uiAddRMC "Add RMC" width:80 tooltip:"Add Root Motion Controller"across:2
	button uiRemoveRMC "Remove RMC" width:80 tooltip:"Remove Root Motion Controller"
	group "Other Tools" (
		button uiRemoveAnyCustomAttribute "Remove Any Custom Attribute" width:166 tooltip:"위험한 기능이니 주의해주세요.\n종류와 상관 없이 커스텀 어트리뷰트 하나를 삭제.\nThis is a dangerous feature, so be careful.\nRemove one custom attribute of any type."
	)
	button uiBtnHelp "About"

	/*
	button uiTest "Test"
	on uiTest pressed do (
	)
	*/
	
	-- 커스텀 어트리뷰트의 attribID가 같은지 조사. attribID를 직접 비교하면 무조건 false여서 attribID 내 숫자를 비교하는 함수.
	function CompareAttribID idA idB = (
		if (idA[1] == idB[1] AND idA[2] == idB[2]) then (return true) else (return false)
	)

	-- 오브젝트에 루트 모션 컨트롤러 어트리뷰트 인덱스를 리턴. 없으면 0 리턴
	function GetRootMotionControllerAttrIndex obj = (
		local attrCount = custAttributes.count obj
		for i = 1 to attrCount do (
			local tID = (custAttributes.getDef obj i).attribID
			if (CompareAttribID tID #(0x7b72aada, 0x1462108b)) do (return i)
		)
		return 0		
	)

	-- 씬을 뒤져서 루트 모션 컨트롤러 먼저 발견되는 것을 리턴
	function FindRootMotionController = (
		for obj in objects do (
			if (GetRootMotionControllerAttrIndex obj) != 0 do (return obj)
		)
		return undefined	-- 없으면 undefined 리턴
	)

	-- 초기화 함수
	function Initialize = (
		-- 씬 전체를 뒤져서 컨트롤러 오브젝트가 있는지 검사. 찾는 기준은 RMC_DataCA 커스텀 어트리뷰트가 있는지.
		local controllerObj = FindRootMotionController()
		if (controllerObj == undefined) then (	--있으면 컨트롤러 픽버튼에 등록.
			uiPickController.object = undefined
			uiPickController.text = STRING_PICK_CONTROLLER	
		)
		else (	--없으면 픽버튼 초기화
			uiPickController.object = controllerObj
			uiPickController.text = controllerObj.name
		)
	)
	
	on uiPickController picked obj do (
		if obj == undefined then (
			uiPickController.text = STRING_PICK_CONTROLLER
		)
		else (
			uiPickController.text = obj.name
			select obj
		)
	)

	-- 픽버튼 우클릭하면 해당 오브젝트 선택
	on uiPickController rightclick do (
		local controllerObj = uiPickController.object
		if (controllerObj != undefined AND	-- 비어있지 앖고
			(not (isdeleted controllerObj))	-- 삭제되지 않았다면
		) do (select controllerObj)			-- 오브젝트 선택
	)
	
	on uiAddRMC pressed do (
		local controllerObj = uiPickController.object
		if (controllerObj == undefined OR (isdeleted controllerObj)) do (
			messagebox "컨트롤러 오브젝트를 선택해주세요"
			return()
		)

		select controllerObj
		-- 기존에 RMC_DataCA가 있는지 조사해서 없으면 추가
		local attrIndex = GetRootMotionControllerAttrIndex controllerObj
		if attrIndex != 0 then (
			messagebox "이미 Root Motion Controller가 존재합니다.\nThe Root Motion Controller already exists."
		)
		else (
			custAttributes.add controllerObj RMC_DataCA
		)
	)

	on uiRemoveRMC pressed do (
		local controllerObj = uiPickController.object
		if (controllerObj == undefined OR (isdeleted controllerObj)) do (
			messagebox "컨트롤러 오브젝트를 선택해주세요"
			return()
		)

		select controllerObj
		local attrIndex = GetRootMotionControllerAttrIndex controllerObj
		if attrIndex != 0 do (
			custAttributes.delete controllerObj attrIndex	-- 삭제시 커스텀 어트리뷰트의 애니메이션 키도 삭제된다.
		)
	)

	on uiRemoveAnyCustomAttribute pressed do (
		local controllerObj = uiPickController.object
		if (controllerObj == undefined OR (isdeleted controllerObj)) do (
			messagebox "컨트롤러 오브젝트를 선택해주세요"
			return()
		)

		select controllerObj
		custAttributes.delete controllerObj 1	-- 삭제시 커스텀 어트리뷰트의 애니메이션 키도 삭제된다.
	)
	
	on RootMotionTools open do (
        callbacks.addScript #filePostOpen "RootMotionTools.Initialize ()" id:#RootMotionToolsOpen
		callbacks.addScript #systemPostNew "RootMotionTools.Initialize ()" id:#RootMotionToolsNew
		callbacks.addScript #systemPostReset "RootMotionTools.Initialize ()" id:#RootMotionToolsReset
		--callbacks.addScript #sceneUndo "RootMotionTools.UnDoCallBack ()" id:#RootMotionToolsUnDo

		Initialize()
	)
	
	on RootMotionTools close do (
		callbacks.removeScripts id:#RootMotionToolsOpen
		callbacks.removeScripts id:#RootMotionToolsNew
		callbacks.removeScripts id:#RootMotionToolsReset
		--callbacks.removeScripts id:#RootMotionToolsUnDo
	)

	on uiBtnHelp pressed do (
		shellLaunch "https://cafe.naver.com/pinksox/9011" ""
	)
)
createDialog RootMotionTools style:#(#style_titlebar, #style_toolwindow, #style_sysmenu) lockWidth:true