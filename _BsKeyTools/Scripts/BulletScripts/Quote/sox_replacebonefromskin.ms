--만든이 : 이상원
try (destroydialog SOX_ReplaceBoneFromSkin) catch()

rollout SOX_ReplaceBoneFromSkin "Replace Bone From Skin v0.17" width:210
(
	pickbutton uiPickBoneOld "旧骨骼" width:91 align:#left across:2
	pickbutton uiPickBoneNew "新骨骼" width:91 align:#right

	pickButton uiPickSkin "选择Skin" width:94 align:#left across:3
	button uiBtnReplace "替换骨骼" align:#right offset:[38,0]
	button uiBtnHelp "?" align:#right
	
	progressBar uiProgress height:8

	
-- 사용법 : fnReplaceBoneFromSkin SkinOBJ BoneA BoneB RemoveOld
-- 스킨 모디파이어가 적용된 SkinOBJ 안에 있는 BoneA에 적용되었던 Weight 값들을 모두 BoneB에 대체 적용한다.
-- 함수가 실행된 뒤에는 SkinOBJ로부터 BoneA가 제거된다.
-- RemoveOld는 true와 false 의 값을 입력한다. true면 BoneA를 스킨 모디파이어로부터 제거하고 false면 제거하지 않고 그대로 둔다.

-- 사용 예 : fnReplaceBoneFromSkin $Cylinder01 $Bone02 $Box01 false 이렇게 하면 스킨이 적용된 실린더에서 Bone02에 적용된 버택스 weight를 모두 Box01로 옮겨간다. 지우는지 여부가 false이므로 실린더의 스킨에는 Bone02가 남아있게 된다.

	function fnFindSkin obj = -- 스킨 모디파이어가 적용되었는지 검사해서 몇 번째 모디파이어에 적용되었는지 숫자를 리턴하는 함수. 못찾으면 0 리턴
	(
		if obj.modifiers.count == 0 do return 0
		
		for o = 1 to obj.modifiers.count do
		(
			if (classof obj.modifiers[o]) == Skin do return o
		)
		
		return 0
	)
	
-- 	modPanel.setCurrentObject $.modifiers[2] -- 이건 모디파이어 선택하기
	
	function fnMakeUniqueArray arr =
	(
		if arr.count == 0 do return false
		
		tArr = #()
		
		for o = 1 to arr.count do
		(
			if (findItem tArr arr[o]) == 0 do append tArr arr[o]
		)
		
		return tArr
	)
	
	function fnReplaceBoneFromSkin skinObj oldBone newBone removeOld = -- 스킨 모디파이어가 적용된 오브젝트의 본을 새로운 본으로 대체한다. 대체된 본에 관련된 버택스는 [modified] 속성이 된다. 정상적으로 대체가 성공하면 true를 리턴, 실패하면 false를 리턴
	(
		if skinObj.mesh.verts.count > 3000 do
		(
			if (queryBox "오브젝트의 버택스 숫자가 너무 많으면 시간이 오래 걸리거나 심지어는 맥스가 다운될 수 있습니다. 모래 시계가 돌아가고 맥스의 응답이 없더라도 대부분의 경우 기다리면 정상적으로 완료되지만 장담할 수 없습니다.\n\n계속 하시겠습니까?") == false do return undefined
		)
		
		-- 이 함수는 모든 버택스가 Normalize 방식으로 작업되었다는 것을 전제로 함.
		
		-- 일단 skinObj에 스킨 모디파이어가 적용되어 있는지, 있다면 몇 번째 모디파이어인지를 알아낸다.
	
		skinModIndex = fnFindSkin skinObj -- 가장 위에 있는 스킨 모디파이어의 번호를 알아낸다. 없으면 skinModIndex는 0
		if skinModIndex == 0 do return false
			
		if oldBone == undefined or newBone == undefined do return false -- 입력된 본이 undefined면 false 리턴
		if oldBone == newBone do return false -- 두 본이 같으면 그냥 false 를 리턴
		
		max modify mode -- open mod panel
		select skinObj -- 다수의 스킨 관련 기능들이 스킨 모디파이어가 선택된 상태에서 실행되어야 한다.
		modPanel.setCurrentObject skinObj.modifiers[skinModIndex] -- 다수의 스킨 관련 기능들이 스킨 모디파이어가 선택된 상태에서 실행되어야 한다.
		
-- 		workingSkin = skinObj.modifiers[skinModIndex] -- 스킨 모디파이어 오브젝트를 workingSkin에 기억시킨다.
		
		boneCount = skinOps.GetNumberBones skinObj.modifiers[skinModIndex]

		boneNameArray = #()
		boneCount = skinOps.GetNumberBones skinObj.modifiers[skinModIndex]
		for o = 1 to boneCount do append boneNameArray (skinOps.GetBoneName skinObj.modifiers[skinModIndex] o 1)
		
		local newBoneIndex
		if (findItem boneNameArray newBone.name) == 0 -- 새 본이 이미 기존에 스킨 모디파이어에 들어있던건지 검사
			then -- 없으면 새로운 본을 추가한다.
			(
				skinOps.addbone skinObj.modifiers[skinModIndex] newBone 1
				boneNameArray = #() -- 새로 추가된 본이 어디에 들어갈지 모르므로 본 이름 배열을 새로 설정한다.
				boneCount = skinOps.GetNumberBones skinObj.modifiers[skinModIndex]
				for o = 1 to boneCount do append boneNameArray (skinOps.GetBoneName skinObj.modifiers[skinModIndex] o 1)
				newBoneIndex = findItem boneNameArray newBone.name
			)
			else newBoneIndex = (findItem boneNameArray newBone.name) -- 있으면 그 인덱스를 알아낸다.
			
		boneNameArray = #()
		boneCount = skinOps.GetNumberBones skinObj.modifiers[skinModIndex]
		for o = 1 to boneCount do append boneNameArray (skinOps.GetBoneName skinObj.modifiers[skinModIndex] o 1)
			
		local oldBoneIndex
		if (findItem boneNameArray oldBone.name) == 0 then return false else oldBoneIndex = (findItem boneNameArray oldBone.name) -- 사라질 본이 스킨 모디파이어의 몇 번째 인덱스에 있는지 알아냄 (oldBoneIndex)
		
		
		
		for o = 1 to skinObj.mesh.verts.count do -- 오브젝트의 모든 버택스마다 하나씩 검사를 한다. o는 버택스 번호
		(
-- 			skinOps.SelectVertices skinObj.modifiers[skinModIndex] o -- 안전한 작동을 위해 현재 버택스를 스킨 모디파이어에서 선택해준다.
-- 			skinOps.unNormalizeVertex skinObj.modifiers[skinModIndex] o true -- 선택된 버택스의 Normalize 옵션을  꺼준다. false 면 노말라이즈 체크 true 면 노말라이즈 체크 해제
			
			tempAffectedBoneCount = skinOps.GetVertexWeightCount skinObj.modifiers[skinModIndex] o -- 현재 버택스에 관련된 본의 갯수 tempAffectedBoneCount
			
			replaceIndexArray = #()
			replaceWeightArray = #()
			tActionTrig = false
			for p = 1 to tempAffectedBoneCount do
			(
				tempIndex = skinOps.GetVertexWeightBoneID skinObj.modifiers[skinModIndex] o p -- 현재 버택스에 적용된 본의 인덱스를 기준으로 스킨 모디파이어의 본 리스트에 몇번째 본인지 본 인덱스를 리턴하는 기능
				if tempIndex == oldBoneIndex -- 현재 버택스에서 대체해야할 본이 사용된 것이 발견되면
					then (append replaceIndexArray newBoneIndex;tActionTrig = true) else (append replaceIndexArray tempIndex) -- 발견되면 새로 추가된 본 인덱스를 배열에 넣고 아니면 원래 본 번호를 배열에 넣는다.
				append replaceWeightArray (skinOps.GetVertexWeight skinObj.modifiers[skinModIndex] o p)
			)
			
			if tActionTrig == true do skinOps.ReplaceVertexWeights skinObj.modifiers[skinModIndex] o replaceIndexArray replaceWeightArray -- 기존의 weight를 완전히 대체한다. SetVertexWeight를 사용하면 0 값을 가진 zero weight가 생기므로 ReplaceVertexWeights를 사용함
-- 			skinOps.unNormalizeVertex skinObj.modifiers[skinModIndex] o false -- 선택된 버택스의 Normalize 옵션을  다시 켜준다.
			
			uiProgress.value = (o as float) / (skinObj.mesh.verts.count as float) * 100.0
		)
		
		if removeOld == true do skinOps.removebone skinObj.modifiers[skinModIndex] oldBoneIndex -- removeOld 옵션이 true면 스킨 모디파이어에서 oldBone을 제거한다.
		return true
	)
	
	function fnExtractBoneFromSkin obj = -- 스킨 오브젝트에 사용된 본을 배열로 리턴한다.
	(
		skinModIndex = fnFindSkin obj -- 가장 위에 있는 스킨 모디파이어의 번호를 알아낸다. 없으면 skinModIndex는 0
		if skinModIndex == 0 do return false

		max modify mode
		select obj
		modPanel.setCurrentObject obj.modifiers[skinModIndex] -- 다수의 스킨 관련 기능들이 스킨 모디파이어가 선택된 상태에서 실행되어야 한다.
		
		tObj = #()
		bCount = skinOps.GetNumberBones obj.modifiers[skinModIndex]
		if bCount != 0 then
		(
			for o = 1 to bCount do append tObj (getNodeByName (skinOps.GetBonename obj.modifiers[skinModIndex] o 1))
		)
		tempArray = deepCopy tObj
		tempArray = fnMakeUniqueArray tempArray
		if tempArray.count != tObj.count then messagebox "중복된 이름의 본이 사용되어서 잠재적으로 문제가 될 수 있습니다"
		
		return tObj
	)

	on SOX_ReplaceBoneFromSkin open do
	(
		
	)
	
	on uiBtnReplace pressed do
	(
		if uiPickSkin.object == undefined or uiPickBoneOld.object == undefined or uiPickBoneNew.object == undefined do
		(
			messagebox "스킨 오브젝트, 제거할 본, 새 본 모두 선택되어 있어야 합니다."
			return ()
		)
		
		if (try (uiPickSkin.object.name) catch (undefined)) == undefined or (try (uiPickBoneOld.object.name) catch (undefined)) == undefined or (try (uiPickBoneNew.object.name) catch (undefined)) == undefined do
		(
			messagebox "삭제된 오브젝트가 선택되었습니다."
			return ()
		)
		
		tObjArr = fnExtractBoneFromSkin uiPickSkin.object -- 스킨 메시에 적용된 본 배열을 리턴받음
		if (findItem tObjArr uiPickBoneOld.object) == 0 do
		(
			messagebox "제거할 본은 스킨 모디파이어에서 사용중인 본이여야 합니다."
			return ()
		)
		
		if (findItem tObjArr uiPickBoneNew.object) != 0 do
		(
			messagebox "새 본은 스킨 모디파이어에서 사용중인 본이면 안됩니다."
			return ()
		)
		
		if (fnReplaceBoneFromSkin uiPickSkin.object uiPickBoneOld.object uiPickBoneNew.object true) == false do messagebox "알 수 없는 문제가 발생했습니다.\n?버튼을 클릭해서 사이트를 방문한 뒤 해당 증세를 보고해주세요."
	)
	
	on uiPickSkin picked var do
	(
		if (fnFindSkin var) == 0 then
		(
			messagebox "스킨 모디파이어가 적용되어 있어야 합니다."
			uiPickSkin.object = undefined
			uiPickSkin.text = "스킨 오브젝트"
		)
		else uiPickSkin.text = "Skin: " + var.name
	)
	
	on uiPickBoneOld picked var do
	(
		uiPickBoneOld.text = "Old: " + var.name
	)
	
	on uiPickBoneNew picked var do
	(
		uiPickBoneNew.text = "New: " + var.name
	)
	
	on uiBtnHelp pressed do
	(
		shellLaunch "http://cafe.naver.com/pinksox/3000" ""
	)

)

createDialog SOX_ReplaceBoneFromSkin style:#(#style_titlebar, #style_toolwindow, #style_sysmenu)

