

-- messagebox "Thank you for using this script.\n This Script is a Demo Version"
(
	  
	
global P_WT_Rollout

local OBJ__
local pre_ring
local Edit_Curve_Dialog
local Lock_Weights	
local skin_
local open__

--for dialog
local _mode
local minus
local bone_
local distance__
local Select_Bone_buttonlist
local save_vertices
local controlMap
local memory_skin_vert = #()

--for GW
local skin_vert_arr
local skin_vert_screen_arr
local lastpoint_xy = [0,0,0]
local viewpoint_xy = [0,0,0]
local Same = #All
local colorArray

local closestPointOnLine2D
 GW_displayObjectNames
 GW_display_Gradient
local get_verts_screen_position	
local draw_feature2
local Gradient_Multi_Bones

local Bones_list = #()
local Gradient_arr = #()

local Multi_bones = #()
local vertexSkinInfo_for_Lock = #()
local saved_Vertices_for_Lock = #()

-- 兼容性函数：获取选中的顶点（支持低版本3ds Max）
-- 全局变量用于缓存是否支持原生方法
global _skinOps_hasGetSelectedVertices = undefined

fn getSelectedVertices_compat skinMod =
(
	-- 首次调用时检测是否支持原生方法
	if _skinOps_hasGetSelectedVertices == undefined do
	(
		try
		(
			local testResult = skinOps.getSelectedVertices skinMod
			_skinOps_hasGetSelectedVertices = true
		)
		catch
		(
			_skinOps_hasGetSelectedVertices = false
		)
	)
	
	-- 根据检测结果选择方法
	if _skinOps_hasGetSelectedVertices == true then
	(
		return skinOps.getSelectedVertices skinMod
	)
	else
	(
		-- 低版本兼容：遍历所有顶点检查是否选中
		local result = #()
		local numVerts = skinOps.GetNumberVertices skinMod
		for i = 1 to numVerts do
		(
			-- isVertexSelected 可能返回 0/1 而不是 true/false
			local isSelected = skinOps.isVertexSelected skinMod i
			if isSelected != 0 and isSelected != false do
			(
				append result i
			)
		)
		return result
	)
)

try (destroydialog P_WT_Rollout) catch()	

		
fn closestPointOnLine2D a b c ver2:false  = 
(
    c = [c.x, c.y, 0] 
    AB = b - a
    AC = c - a
    
    if ver2 do
    (
        dot_product = dot AB AC
        AB_length = length AB
        t = dot_product / (AB_length * AB_length)
        return (t * 100)  
    )
	
    if _mode == #circle do
    (   
        ab_length = length AB
        ac_length = length AC
        if (ac_length > ab_length) do return 0
        return (1 - (ac_length / ab_length))
    )
    
    dot_product = dot AB AC
    AB_length = length AB
    distance_ = abs(dot_product) / AB_length
    x_perp = a.x + (b.x - a.x) * dot_product / (AB_length * AB_length)
    y_perp = a.y + (b.y - a.y) * dot_product / (AB_length * AB_length)
    [x_perp, y_perp]  
)
function select_bones mode_:false=
(
	tool objPick
	(
		local selectedObjects, objectPositions, currentObjectIndex
		local before_viewport
		local bonesArray, boneName, node
		local mode__=mode_
		local lastpoint_xyz
		
		fn getSkinBones  =
		(
			bonesArray = #()
			for i=1 to (skinOps.GetNumberBones ($selection[1].modifiers[#Skin])) do 
			(
				boneName = skinOps.GetBoneName ($selection[1].modifiers[#Skin]) i 1
				node = getNodeByName boneName
				append bonesArray node
			)
			return bonesArray
		)
		
		fn gwDrawText o =
		(
			gw.setTransform (matrix3 1)
			gw.wText [o.center.x, o.center.y, o.center.z] o.name size:10 color:(color 255 255 255)
		)

		
		fn cbDrawBBox =
		(
			gwDrawText selectedObjects[currentObjectIndex] 
			gw.enlargeUpdateRect #whole
		)
		
		fn MouseTransform =
		(
			local ray = mapScreenToWorldRay mouse.pos
			local transformMatrix= matrixFromNormal ray.dir
			transformMatrix.pos = ray.pos
			transformMatrix
		)
		
		fn Select_Object =
		(
			transformMatrix = MouseTransform ()
			
			arrDist = for p in objectPositions collect (p * inverse transformMatrix)
			arrDist = for p in arrDist collect length (p * [1,1,0])
			currentObjectIndex = finditem arrDist (amin arrDist)
			for i=1 to (skinOps.GetNumberBones skin_) do
			(
				if (skinOps.GetBoneName skin_ i 1) == selectedObjects[currentObjectIndex].name do (skinOps.SelectBone skin_ i; exit)
			)
			
			redrawviews()
		)
		

		on freeMove do
		(
			lastpoint_xyz=[viewPoint.x+30, viewPoint.y+30, 0]
			Select_Object ()
		)
		
		on mousePoint arg do if arg == 2 do
		(
			#stop
		)
		
		on start do
		(
			lastpoint_xyz = [0, 0, 0]
			before_viewport = #(viewport.GetRenderLevel(), viewport.GetShowEdgeFaces(), subobjectlevel, displayColor.shaded)
			if mode__ do
			(
				viewport.SetRenderLevel #flat
				viewport.SetShowEdgeFaces false
				subobjectlevel = 1
			)
			selectedObjects = getSkinBones ()
			objectPositions = for o in selectedObjects collect o.center
			Select_Object ()
			registerRedrawViewsCallback cbDrawBBox
			redrawviews()
		)
		
		on stop do
		(
			try
			(
				if mode__ do
				(
					viewport.SetRenderLevel before_viewport[1]
					viewport.SetShowEdgeFaces before_viewport[2]
					subobjectlevel = before_viewport[3]
					displayColor.shaded = before_viewport[4]
				)
				unregisterRedrawViewsCallback cbDrawBBox
				lastpoint_xyz = undefined
			)
			catch()
			redrawviews()
		)
	)
	
	if ((skinOps.GetNumberBones (selection[1].modifiers[skin]))!=0) do
	(
		stopTool objPick
		startTool objPick
	)

)
fn getVertexSkinInfo selection_:undefined =
(
    local vertexSkinInfo = #()
    local targetVertices = if selection_ == undefined then getSelectedVertices_compat skin_ else selection_

    for vertIndex in targetVertices do
    (
        local boneIDs = #()
        local weights = #()
        local weightCount = skinOps.GetVertexWeightCount skin_ vertIndex

        for weightIndex = 1 to weightCount do
        (
            append boneIDs (skinOps.GetVertexWeightBoneID skin_ vertIndex weightIndex)
            append weights (skinOps.GetVertexWeight skin_ vertIndex weightIndex)
        )

        append vertexSkinInfo #(vertIndex, boneIDs, weights)
    )
    vertexSkinInfo
)


-- 兼容性函数：在数组中按顶点ID查找数据（替代 Dictionary）
fn findVertexDataById dataArray vertId =
(
	for item in dataArray do
	(
		if item[1] == vertId do return item
	)
	return undefined
)

-- 兼容性函数：Hammer 平滑权重（支持低版本3ds Max）
fn skinHammer_compat skinMod vertArray =
(
	-- 尝试使用带数组参数的新版本 Hammer（3ds Max 2016+）
	try
	(
		skinOps.Hammer skinMod vertArray
	)
	catch
	(
		-- 低版本兼容：先选择顶点，再调用 Hammer
		skinOps.SelectVertices skinMod vertArray
		-- 尝试无参数的 Hammer
		try ( skinOps.Hammer skinMod ) catch()
	)
)

-- 兼容性函数：bakeSelectedVerts（支持低版本3ds Max）
fn bakeSelectedVerts_compat skinMod =
(
	try
	(
		skinOps.bakeSelectedVerts skinMod
	)
	catch
	(
		-- 低版本可能不支持此函数，忽略错误
	)
)

-- 兼容性函数：blendSelected（支持低版本3ds Max）
fn blendSelected_compat skinMod =
(
	try
	(
		skinOps.blendSelected skinMod
	)
	catch
	(
		-- 低版本可能不支持此函数，忽略错误
	)
)

-- 兼容性函数：removeUnusedBones（支持低版本3ds Max）
fn removeUnusedBones_compat skinMod =
(
	try
	(
		skinOps.removeUnusedBones skinMod
	)
	catch
	(
		messageBox "此功能在当前版本的 3ds Max 中不受支持。"
	)
)

fn blendVertexSkinWeights vertexSkinInfo percentage current_value_ selection_only:false =
(
    local selection_ = if selection_only then getSelectedVertices_compat skin_ else undefined
	local Percentage__=(1 - percentage / 100)
	local Percentage_=(percentage / 100)
	
	for vertData in vertexSkinInfo do
	(
		if selection_only then
		(
			local found = findItem selection_ vertData[1]
			if found == 0 do continue
		)

		-- 使用兼容性函数查找数据
		local current_info_ = findVertexDataById current_value_ vertData[1]

		if current_info_ != undefined then
		(
			local all_bone_indices = #()
			local all_weights = #()

			-- current_info_에서 데이터 처리
			for j = 1 to current_info_[2].count do
			(
				append all_bone_indices current_info_[2][j]
				local vert_weight = current_info_[3][j]
				local blended_weight = vert_weight * Percentage__
				append all_weights blended_weight
			)

			-- vertData에서 데이터 처리
			for j = 1 to vertData[2].count do
			(
				local bone_idx = vertData[2][j]
				local idx = findItem all_bone_indices bone_idx
				if idx == 0 then
				(
					append all_bone_indices bone_idx
					local blended_weight = vertData[3][j] * Percentage_
					append all_weights blended_weight
				)
				else
				(
					all_weights[idx] += vertData[3][j] * Percentage_
				)
			)

			-- 최종 결과 적용
			skinOps.ReplaceVertexWeights skin_ vertData[1] all_bone_indices all_weights
		)
	)
)



function get_verts_screen_position=
(
	gw.setTransform(Matrix3 1)
	for i in skin_vert_arr do
	(
		viewPosW = gw.wTransPoint $.verts[i[1]].pos
		append skin_vert_screen_arr [viewPosW[1],viewPosW[2]]
	)
)
fn GW_display_Gradient =
(
    gw.settransform(viewport.gettm())
    gw.setColor #line white
    gw.wPolyline #(viewpoint_xy, lastpoint_xy) true
    gw.wMarker viewpoint_xy #circle color: white
    gw.wMarker lastpoint_xy #circle color: white

    local directionVec = normalize (lastpoint_xy - viewpoint_xy)
    local perpDirectionVec = [directionVec.y, -directionVec.x, directionVec.z]
    local lineLength = length (lastpoint_xy - viewpoint_xy)
    local moveDistance = 10
    local scaleFactor = lineLength / 100.0

    for i = 1 to Gradient_arr.count do
    (
        local gradient = Gradient_arr[i]
        local startPercent = gradient[1] / 100.0
        local endPercent = gradient[2] / 100.0
        local startPoint = viewpoint_xy + (lastpoint_xy - viewpoint_xy) * startPercent
        local endPoint = viewpoint_xy + (lastpoint_xy - viewpoint_xy) * endPercent
        local offset = perpDirectionVec * moveDistance * ((mod i 2) + 0.3)
        startPoint += offset
        endPoint += offset

        local offsetVec1 = directionVec * (moveDistance + (if Same == #All then Gradient_arr[1][3] else gradient[3]) * scaleFactor)
        local offsetVec2 = if Same == false then directionVec * (moveDistance + gradient[4] * scaleFactor) else offsetVec1

        local adjustedStartPoint = startPoint - offsetVec1
        local adjustedEndPoint = endPoint + offsetVec2

        gw.wMarker startPoint #circle color: colorArray[i]
        gw.wMarker endPoint #circle color: colorArray[i]
        gw.wMarker adjustedStartPoint #point color: colorArray[i]
        gw.wMarker adjustedEndPoint #point color: colorArray[i]
        gw.wPolyline #(adjustedEndPoint, adjustedStartPoint) true
        gw.wPolyline #(startPoint, endPoint) true

        local offsetMovement = perpDirectionVec * moveDistance * 0.1
        gw.wPolyline #(startPoint + offsetMovement, endPoint + offsetMovement) true
    )



    -- 화면 업데이트
    gw.enlargeUpdateRect #whole
    gw.updatescreen()
)
fn GW_displayObjectNames=
(
	completeredraw()
	gw.settransform(viewport.gettm())
	gw.setColor #line white
	gw.wPolyline #( viewpoint_xy,  lastpoint_xy) true
	gw.enlargeUpdateRect #whole
	gw.updatescreen()
)

fn findSetsForTar tar =
(
    local result = #()  
    local sum = 0.0
    
    for i = 1 to Gradient_arr.count do
    (
        local gradient_ = Gradient_arr[i]
        local startPoint = gradient_[1]
        local endPoint = gradient_[2]
        local gradientDistance = if Same == #All then Gradient_arr[1][3] else gradient_[3]
        local gradientDistance2 = if Same == false then gradient_[4] else gradientDistance

        local value = 0.0
        if tar >= startPoint and tar <= endPoint then
		(
            value = 1.0 * gradient_[5]
		)
        else if tar < startPoint and tar >= startPoint - gradientDistance then
		(
            local overshoot = startPoint - tar
            local percentage = overshoot / gradientDistance
            value = (1.0 - percentage) * gradient_[5]
		)
        else if tar > endPoint and tar <= endPoint + gradientDistance2 then
		(
            local overshoot = tar - endPoint
            local percentage = overshoot / gradientDistance2
            value = (1.0 - percentage) * gradient_[5]
		)
        else
		(
            value = 0
		)

        append result value
        sum += value
    )

    if sum != 0 then
    (
        for i = 1 to result.count do
        (
            result[i] = result[i] / sum
        )
    )

    return result
)
fn change_value=
(
	for i=1 to skin_vert_arr.count do 
	(
		tar_ = closestPointOnLine2D viewpoint_xy lastpoint_xy skin_vert_screen_arr[i] ver2:true
		Affect_Sets=findSetsForTar tar_
		skinOps.SetVertexWeights skin_ skin_vert_arr[i][1] Bones_list Affect_Sets
	)	
	completeredraw()
    gw.updatescreen()
)
function draw_feature2 =
(
    viewpoint_xy = [0, 0, 0]
    lastpoint_xy = [0, 0, 0]
    open__ = false

    tool AssignSkinVertexWeightTool2
    (
        on mousePoint clickno do 
        (
            if clickno > 1 then 
            (
                unregisterRedrawViewsCallback GW_displayObjectNames
                return #stop
            )
            viewpoint_xy = [viewPoint.x, viewPoint.y, 0]
            get_verts_screen_position()
        )

        on mouseMove clickno do
        (
            completeredraw()
            gw.updatescreen()
            lastpoint_xy = [viewPoint.x, viewPoint.y, 0]
        )

        on stop do
        (
			
            CreateDialog Gradient_Multi_Bones
            unregisterRedrawViewsCallback GW_displayObjectNames
        )
    )

    registerRedrawViewsCallback GW_displayObjectNames

    if (selection[1] != undefined) and (selection[1].modifiers[Skin] != undefined) then
    (
        skin_ = selection[1].modifiers[Skin]
        skin_vert_arr = #()
        skin_vert_screen_arr = #()

        for i = 1 to (skinOps.GetNumberVertices skin_) do
        (
            if skinOps.isVertexSelected skin_ i then 
            (
                append skin_vert_arr #(i)
            )
        )

        memory_skin_vert = getVertexSkinInfo()
        startTool AssignSkinVertexWeightTool2 prompt:"绘制线条"
    )
    else 
    (
        unregisterRedrawViewsCallback GW_displayObjectNames
    )
)
fn calculatePointA point1 point2 =
(
	midPoint = (point1 + point2) / 2.0
	directionVector = point2 - point1
	pointA = midPoint + directionVector * 0.25
	pointA
)
fn Dialog_modal text1 text2=
(
	theObj = dotNetObject "MaxCustomControls.RenameInstanceDialog" text2
	theobj.text =text1
	DialogResult = theObj.Showmodal()

	return theobj.InstanceName 
)
fn makeFiveCharacters inputString =
(
    case inputString.count of
    (
        0: inputString += "00000"
        1: inputString += "0000"
        2: inputString += "000"
        3: inputString += "00"
        4: inputString += "0"
		default: inputString = substring inputString 1 5
    )
    return inputString
)




fn updateLockedVertexWeightsWithNewData lock_arr new_arr =
(
    for vertData_new in new_arr do 
    (
        -- 使用兼容性函数查找数据（替代 Dictionary）
        local vertData_lock_copy = findVertexDataById lock_arr vertData_new[1]
        
        if vertData_lock_copy != undefined do
        (
            vertData_lock_copy = deepCopy vertData_lock_copy

            -- 기존 가중치 합계 계산
            local lock_weights_sum = 0.0
            for w in vertData_lock_copy[3] do  lock_weights_sum += w

            -- 남은 가중치 비율 계산
            local anothers_weights_sum = 1.0 - lock_weights_sum
            local anothers_bones = #()
            local anothers_weights = #()

            -- 중복되지 않는 뼈 찾기
            for j = 1 to vertData_new[2].count do
            (
                if findItem vertData_lock_copy[2] vertData_new[2][j] == 0 do
                (
                    append anothers_bones vertData_new[2][j]
                    append anothers_weights vertData_new[3][j]
                )
            )

            -- 나머지 가중치 정규화
            local sum = 0.0
            for w in anothers_weights do sum += w

            local new_anothers_weights = #()
            if sum == 0 then 
            (
                local uniform_weight = anothers_weights_sum / anothers_bones.count
                for i = 1 to anothers_bones.count do append new_anothers_weights uniform_weight
            )
            else
            (
                for w in anothers_weights do append new_anothers_weights (w / sum * anothers_weights_sum)
            )

            -- 새로운 뼈와 가중치 병합
            join vertData_lock_copy[2] anothers_bones
            join vertData_lock_copy[3] new_anothers_weights

            -- 스킨 가중치 업데이트
            skinOps.ReplaceVertexWeights skin_ vertData_lock_copy[1] vertData_lock_copy[2] vertData_lock_copy[3]
        )
    )
)
fn getVertexSkinInfoAndBone targetBone=
(
	saved_Vertices_for_Lock=#()
    local vertexSkinInfo = #()
	local targetVertices = getSelectedVertices_compat skin_
    for vertIndex in targetVertices do
    (
        local boneIDs=#()
		local weights=#()
        local weightCount = skinOps.GetVertexWeightCount skin_ vertIndex
		for ii in targetBone do 
		(
				local chacked_=false
			for weightIndex = 1 to weightCount do
			(
				if (skinOps.GetVertexWeightBoneID skin_ vertIndex weightIndex) == (ii as integer) do 
				(
					append boneIDs (skinOps.GetVertexWeightBoneID skin_ vertIndex weightIndex)
					append weights (skinOps.GetVertexWeight skin_ vertIndex weightIndex)
					append saved_Vertices_for_Lock vertIndex
					chacked_=true
				)
			)
				if chacked_==false do 
				(
					append boneIDs (ii as integer)
					append weights 0.0
					append saved_Vertices_for_Lock vertIndex
				)
			
		)
		
		append vertexSkinInfo #(vertIndex, boneIDs, weights)
    )
    vertexSkinInfo
)
fn periodicFunction =
(
	vertexSkinInfo_now=getVertexSkinInfo selection_:saved_Vertices_for_Lock
	updateLockedVertexWeightsWithNewData vertexSkinInfo_for_Lock vertexSkinInfo_now
)






rollout Select_Bone_from_List "选择骨骼" width:256 height:208
(
	Multilistbox 'lbx1' "" pos:[8,8] width:240 height:11 align:#left
	button 'b_Accept' "确定" pos:[48,170] width:64 height:32 align:#left
	button 'b_Cancel' "取消" pos:[144,170] width:64 height:32 align:#left
	
	on Select_Bone_from_List open do 
	(
		arr=#()
		for i=1 to (skinOps.GetNumberBones skin_) do 
		(
			append arr ((i as string )+" : "+(skinOps.GetBoneName skin_ i 1))
		)
		lbx1.items=arr
	)
	
	on b_Accept pressed do 
	(
		arr=#()
		arr2=#()
		lbx1Items = lbx1.items
		for ii in lbx1.selection do
		(
			append arr (((FilterString (lbx1.items[ii]) " : ")[1]) as integer)
			append arr2 lbx1.items[ii]
		)
		Multi_bones=arr
		DestroyDialog Select_Bone_from_List
		Lock_Weights.lbx1.items=arr2
	)
	
	on b_Cancel pressed do 
	(
		DestroyDialog Select_Bone_from_List
	)
)


rollout Lock_Weights "锁定权重" width:240 height:208
(
	
	local rdo_value=1
	
	Timer 'SecTme' "Tme" pos:[168,600] width:24 height:24 interval:1000 active:false align:#left
	checkbutton 'b_LockBtn' "锁定!!" pos:[8,8] width:104 height:80 align:#left
	label 'lbl1' "关闭此窗口将解除锁定" pos:[0,190] width:240 height:16 align:#left
	checkbutton 'btn5' "使用多骨骼" pos:[136,312] width:104 height:40 align:#left
	button 'Manual_Update' "手动更新" pos:[120,72] width:88 height:16 align:#left
	radiobuttons 'rdo1' "" pos:[120,8] width:131 height:64 labels:#("不自动更新", "间隔 1.5秒", "间隔 0.7秒", "间隔 0.1秒") default:2 align:#left
	
	
	button 'btn_add' "添加" pos:[56,160] width:48 height:24 align:#left
	button 'btn_Delete' "删除" pos:[104,160] width:48 height:24 align:#left
	button 'btn_fromlist' "从列表" pos:[8,160] width:48 height:24 align:#left
	listbox 'lbx1' "" pos:[8,112] width:144 height:3 align:#left
	label 'lbl2' "- 骨骼列表 -" pos:[24,96] width:64 height:16 align:#left
	button 'btn_affectedVertices' "选择受影响顶点" pos:[160,120] width:72 height:56 align:#left
	
	on Lock_Weights close do 
	(
		Multi_bones=#()
	)
	
	on btn_delete pressed do 
	(
		if lbx1.selected==undefined do return false
		a = finditem Multi_bones (((FilterString lbx1.selected " : ")[1]) as integer)
		if a > 0 do deleteItem Multi_bones a
			
		local arr=lbx1.items
		deleteitem arr lbx1.selection
		lbx1.items=arr
		
		print Multi_bones
	)
	
	on btn_add pressed do 
	(
		select_bones()
		appendIfUnique Multi_bones (skinOps.GetSelectedBone skin_)
		sort Multi_bones
		arr=#()
		for i in Multi_bones do 
		(
			append arr (""+i as string+" : "+(skinOps.GetBoneName skin_ i 1))
		)
		lbx1.items=arr
	)
	
	on btn_fromlist pressed do
	(
		aa= GetDialogPos Lock_Weights
		CreateDialog Select_Bone_from_List 256 208 aa.x aa.y modal:true 
	)
	on SecTme tick do
	(
		periodicFunction()
	)
	on b_LockBtn changed arg do
	(
		if arg==true then
		(
			if Multi_bones.count==0 or ((getSelectedVertices_compat skin_).count==0) then 
			(
				b_LockBtn.state=false
				messagebox "骨骼或顶点尚未选择。"
			)
			else
			(
				vertexSkinInfo_for_Lock=getVertexSkinInfoAndBone Multi_bones
				if rdo1.state!=1 do (SecTme.active = true)
			)
		)
		else 
		(
			SecTme.active = false
			if Multi_bones.count==0  then 
			(
				b_LockBtn.text="Lock!!"
			)
		)
	)
	on Manual_Update pressed do
	(
		 periodicFunction()
	)
	on rdo1 changed arg do
	(
		rdo_value = arg
		if arg >= 2 and arg <= 4 then
		(
			SecTme.interval = case arg of
			(
				2: 1500
				3: 700
				4: 100
			)
			if b_LockBtn.state == true do SecTme.active = true
		)
		else SecTme.active = false
	)
	on btn_affectedVertices pressed do 
	(
		b=skinOps.GetSelectedBone skin_
		arr=#()
		for i in Multi_bones do 
		(
			skinOps.SelectBone skin_ i
			skinOps.selectVerticesByBone skin_
			join arr (getSelectedVertices_compat skin_)
		)
		skinOps.SelectVertices skin_ arr
		skinOps.SelectBone skin_ b
	)
)


rollout Load_Weights "加载权重" width:224 height:80
(
    slider 'sld1' "" pos:[8,48] width:216 height:25 align:#left
    button 'btn2' "加载100%" pos:[168,8] width:48 height:40 align:#left
    button 'btn3' "选择已保存选集" pos:[120,8] width:48 height:40 align:#left
    checkbox 'chk6' "仅当前选择" pos:[8,8] width:104 height:24 align:#left
    label 'lbl83' "的顶点" pos:[36,32] width:64 height:16 align:#left
    
    local target_ = undefined
	local current_value_

    on Load_Weights open do 
    (
        if save_vertices[1].count != 0 and save_vertices[1][save_vertices[1].count] == #select do 
        (
            target_ = 1
            deleteItem save_vertices[1] save_vertices[1].count
        )
        if save_vertices[2].count != 0 and save_vertices[2][save_vertices[2].count] == #select do 
        (
            target_ = 2
            deleteItem save_vertices[2] save_vertices[2].count
        )
    )
    
    on sld1 changed arg do
    (
		if chk6.checked==true then
			blendVertexSkinWeights save_vertices[target_ + 2] arg current_value_ selection_only:true
		else 
			blendVertexSkinWeights save_vertices[target_ + 2] arg current_value_ 
    )

    on sld1 buttondown do
    (
        bakeSelectedVerts_compat skin_
        current_value_ = getVertexSkinInfo selection_: save_vertices[target_]
    )

    on sld1 buttonup do
    (
        sld1.value = 0
    )

    on btn2 pressed do
    (
        bakeSelectedVerts_compat skin_
        current_value_ = getVertexSkinInfo selection_: save_vertices[target_]
		if chk6.checked==true then
			blendVertexSkinWeights save_vertices[target_ + 2] 100 current_value_ selection_only:true
		else 
			blendVertexSkinWeights save_vertices[target_ + 2] 100 current_value_ 
       -- blendVertexSkinWeights save_vertices[target_ + 2] 100 current_value_
    )

    on btn3 pressed do
    (
        skinOps.SelectVertices skin_ save_vertices[target_]
    )
)



rollout Gradient_Multi_Bones "多骨骼渐变" width:416 height:144
(
	
	button 'b_RestoreView' "还原视图和帧" pos:[136,8] width:64 height:48 align:#left
	button 'b_Cancel' "重置并关闭" pos:[288,24] width:56 height:32 align:#left
	button 'b_Apply' "应用" pos:[344,8] width:64 height:48 align:#left				
	checkbox 'b_Same_G_ALL' "" pos:[24,40] width:24 height:16 enabled:false checked:true align:#left
	button 'b_ResetLine' "重绘线条" pos:[56,8] width:80 height:24 align:#left       
	button 'b_ResetValue' "重置数值" pos:[56,32] width:80 height:24 align:#left
	label 'lbl31' "相同" pos:[16,8] width:32 height:16 align:#left				
	label 'lbl32' "渐变" pos:[8,24] width:48 height:16 align:#left
	button 'btn_MoreBones' "更多骨骼" pos:[232,24] width:56 height:32 align:#left
	

	button 'Select_Bone_1' "- 空骨骼 - " pos:[8,64] width:128 height:16 align:#left
	button 'Select_Bone_2' "- 空骨骼 - " pos:[144,64] width:128 height:16 enabled:false align:#left
	button 'Select_Bone_3' "- 空骨骼 - " pos:[280,64] width:128 height:16 enabled:false align:#left
	button 'Select_Bone_4' "- 空骨骼 - " pos:[8,144] width:128 height:16 enabled:false align:#left
	button 'Select_Bone_5' "- 空骨骼 - " pos:[144,144] width:128 height:16 enabled:false align:#left
	button 'Select_Bone_6' "- 空骨骼 - " pos:[280,144] width:128 height:16 enabled:false align:#left
	button 'Select_Bone_7' "- 空骨骼 - " pos:[8,224] width:128 height:16 enabled:false align:#left
	button 'Select_Bone_8' "- 空骨骼 - " pos:[144,224] width:128 height:16 enabled:false align:#left
	button 'Select_Bone_9' "- 空骨骼 - " pos:[280,224] width:128 height:16 enabled:false align:#left

    -- 첫 번째 그룹 (Bone 1)
	spinner 'spn_bone1_1' "" pos:[8,88] width:56 height:16 enabled:false range:[0,100,0] align:#left
	spinner 'spn_bone1_2' "" pos:[80,88] width:56 height:16 enabled:false range:[0,100,100] align:#left
	label 'lbl_bone1_to' "至" pos:[68,88] width:10 height:16 align:#left
	label 'lbl_bone1_gradient' "渐变范围" pos:[16,104] width:80 height:16 align:#left
	spinner 'spn_bone1_value' "" pos:[96,120] width:40 height:16 enabled:false range:[0,1,1] scale:0.01 align:#left
	label 'lbl_bone1_value' "权重" pos:[104,104] width:32 height:16 align:#left
	
	-- 두 번째 그룹 (Bone 2)
	spinner 'spn_bone2_1' "" pos:[144,88] width:56 height:16 enabled:false range:[0,100,0] align:#left
	spinner 'spn_bone2_2' "" pos:[216,88] width:56 height:16 enabled:false range:[0,100,0] align:#left
	label 'lbl_bone2_to' "至" pos:[204,88] width:10 height:16 align:#left
	label 'lbl_bone2_gradient' "渐变范围" pos:[152,104] width:80 height:16 align:#left
	spinner 'spn_bone2_value' "" pos:[232,120] width:40 height:16 enabled:false range:[0,1,1] scale:0.01 align:#left
	label 'lbl_bone2_value' "权重" pos:[240,104] width:32 height:16 align:#left

	-- 세 번째 그룹 (Bone 3)
	spinner 'spn_bone3_1' "" pos:[280,88] width:56 height:16 enabled:false range:[0,100,0] align:#left
	spinner 'spn_bone3_2' "" pos:[352,88] width:56 height:16 enabled:false range:[0,100,0] align:#left
	label 'lbl_bone3_to' "至" pos:[340,88] width:10 height:16 align:#left
	label 'lbl_bone3_gradient' "渐变范围" pos:[288,104] width:80 height:16 align:#left
	spinner 'spn_bone3_value' "" pos:[368,120] width:40 height:16 enabled:false range:[0,1,1] scale:0.01 align:#left
	label 'lbl_bone3_value' "权重" pos:[376,104] width:32 height:16 align:#left
	
		-- 네 번째 그룹 (Bone 4)
	spinner 'spn_bone4_1' "" pos:[8,164] width:56 height:16 enabled:false range:[0,100,0] align:#left
	spinner 'spn_bone4_2' "" pos:[80,164] width:56 height:16 enabled:false range:[0,100,0] align:#left
	label 'lbl_bone4_to' "至" pos:[68,164] width:10 height:16 align:#left
	label 'lbl_bone4_gradient' "渐变范围" pos:[16,184] width:80 height:16 align:#left
	spinner 'spn_bone4_value' "" pos:[96,200] width:40 height:16 enabled:false range:[0,1,1] scale:0.01 align:#left
	label 'lbl_bone4_value' "权重" pos:[104,184] width:32 height:16 align:#left

	-- 다섯 번째 그룹 (Bone 5)
	spinner 'spn_bone5_1' "" pos:[144,164] width:56 height:16 enabled:false range:[0,100,0] align:#left
	spinner 'spn_bone5_2' "" pos:[216,164] width:56 height:16 enabled:false range:[0,100,0] align:#left
	label 'lbl_bone5_to' "至" pos:[204,164] width:10 height:16 align:#left
	label 'lbl_bone5_gradient' "渐变范围" pos:[152,184] width:80 height:16 align:#left
	spinner 'spn_bone5_value' "" pos:[232,200] width:40 height:16 enabled:false range:[0,1,1] scale:0.01 align:#left
	label 'lbl_bone5_value' "权重" pos:[240,184] width:32 height:16 align:#left

	-- 여섯 번째 그룹 (Bone 6)
	spinner 'spn_bone6_1' "" pos:[280,164] width:56 height:16 enabled:false range:[0,100,0] align:#left
	spinner 'spn_bone6_2' "" pos:[352,164] width:56 height:16 enabled:false range:[0,100,0] align:#left
	label 'lbl_bone6_to' "至" pos:[340,164] width:10 height:16 align:#left
	label 'lbl_bone6_gradient' "渐变范围" pos:[288,184] width:80 height:16 align:#left
	spinner 'spn_bone6_value' "" pos:[368,200] width:40 height:16 enabled:false range:[0,1,1] scale:0.01 align:#left
	label 'lbl_bone6_value' "权重" pos:[376,184] width:32 height:16 align:#left

	-- 일곱 번째 그룹 (Bone 7)
	spinner 'spn_bone7_1' "" pos:[8,244] width:56 height:16 enabled:false range:[0,100,0] align:#left
	spinner 'spn_bone7_2' "" pos:[80,244] width:56 height:16 enabled:false range:[0,100,0] align:#left
	label 'lbl_bone7_to' "至" pos:[68,244] width:10 height:16 align:#left
	label 'lbl_bone7_gradient' "渐变范围" pos:[16,264] width:80 height:16 align:#left
	spinner 'spn_bone7_value' "" pos:[96,280] width:40 height:16 enabled:false range:[0,1,1] scale:0.01 align:#left
	label 'lbl_bone7_value' "权重" pos:[104,264] width:32 height:16 align:#left

	-- 여덟 번째 그룹 (Bone 8)
	spinner 'spn_bone8_1' "" pos:[144,244] width:56 height:16 enabled:false range:[0,100,0] align:#left
	spinner 'spn_bone8_2' "" pos:[216,244] width:56 height:16 enabled:false range:[0,100,0] align:#left
	label 'lbl_bone8_to' "至" pos:[204,244] width:10 height:16 align:#left
	label 'lbl_bone8_gradient' "渐变范围" pos:[152,264] width:80 height:16 align:#left
	spinner 'spn_bone8_value' "" pos:[232,280] width:40 height:16 enabled:false range:[0,1,1] scale:0.01 align:#left
	label 'lbl_bone8_value' "权重" pos:[240,264] width:32 height:16 align:#left

	-- 아홉 번째 그룹 (Bone 9)
	spinner 'spn_bone9_1' "" pos:[280,244] width:56 height:16 enabled:false range:[0,100,0] align:#left
	spinner 'spn_bone9_2' "" pos:[352,244] width:56 height:16 enabled:false range:[0,100,0] align:#left
	label 'lbl_bone9_to' "至" pos:[340,244] width:10 height:16 align:#left
	label 'lbl_bone9_gradient' "渐变范围" pos:[288,264] width:80 height:16 align:#left
	spinner 'spn_bone9_value' "" pos:[368,280] width:40 height:16 enabled:false range:[0,1,1] scale:0.01 align:#left
	label 'lbl_bone9_value' "权重" pos:[376,264] width:32 height:16 align:#left

	
	
	spinner 'spn_bone1_3' "" pos:[8,120] width:40 height:16 enabled:false range:[0,100,10] align:#left
	spinner 'spn_bone1_4' "" pos:[48,120] width:40 height:16 enabled:false range:[0,100,10] align:#left
	spinner 'spn_bone2_3' "" pos:[144,120] width:40 height:16 enabled:false range:[0,100,10] align:#left
	spinner 'spn_bone2_4' "" pos:[184,120] width:40 height:16 enabled:false range:[0,100,10] align:#left
	spinner 'spn_bone3_3' "" pos:[280,120] width:40 height:16 enabled:false range:[0,100,10] align:#left
	spinner 'spn_bone3_4' "" pos:[324,120] width:40 height:16 enabled:false range:[0,100,10] align:#left
	spinner 'spn_bone4_3' "" pos:[8,200] width:40 height:16 enabled:false range:[0,100,10] align:#left
	spinner 'spn_bone4_4' "" pos:[48,200] width:40 height:16 enabled:false range:[0,100,10] align:#left
	spinner 'spn_bone5_3' "" pos:[144,200] width:40 height:16 enabled:false range:[0,100,10] align:#left
	spinner 'spn_bone5_4' "" pos:[184,200] width:40 height:16 enabled:false range:[0,100,10] align:#left
	spinner 'spn_bone6_3' "" pos:[280,200] width:40 height:16 enabled:false range:[0,100,10] align:#left
	spinner 'spn_bone6_4' "" pos:[324,200] width:40 height:16 enabled:false range:[0,100,10] align:#left
	spinner 'spn_bone7_3' "" pos:[8,280] width:40 height:16 enabled:false range:[0,100,10] align:#left
	spinner 'spn_bone7_4' "" pos:[48,280] width:40 height:16 enabled:false range:[0,100,10] align:#left
	spinner 'spn_bone8_3' "" pos:[144,280] width:40 height:16 enabled:false range:[0,100,10] align:#left
	spinner 'spn_bone8_4' "" pos:[184,280] width:40 height:16 enabled:false range:[0,100,10] align:#left
	spinner 'spn_bone9_3' "" pos:[280,280] width:40 height:16 enabled:false range:[0,100,10] align:#left
	spinner 'spn_bone9_4' "" pos:[324,280] width:40 height:16 enabled:false range:[0,100,10] align:#left
	
	local Save_View_Frame=undefined
	
	fn reset_value__=
	(
			if gradient_arr.count==0 do (return false)
		local new_gradient_arr = #()
		local sections = gradient_arr.count -- 원소 갯수
		local step = 100 / sections -- 각 구간의 크기
		local start_value=0
		
		for i = 1 to sections do
		(
			local end_value = start_value + step
			if i == sections do
				end_value = 100  
			append new_gradient_arr #(start_value, end_value, 10.0,10.0,1.0)
			
			controlMap[2][i].value=start_value			
			controlMap[3][i].value=end_value
			controlMap[4][i].value=10
			controlMap[5][i].value=10
			controlMap[6][i].value=1.0
			
			start_value = end_value
		)
		gradient_arr=new_gradient_arr
		change_value()
	)
				
	fn Plus_Bone number_ =
	(
		Bones_list[number_] = skinOps.GetSelectedBone skin_
		
		controlMap[1][number_].text=(skinOps.GetBoneName skin_ Bones_list[number_] 1)
		--controlMap[1][number_].enabled=false
		if number_<9 do  controlMap[1][number_+1].enabled=true
			
		if number_==1 do 
		(
			controlMap[4][number_].enabled = true
		)
		if Gradient_Multi_Bones.b_Same_G_ALL.checked==false do 
		(
			controlMap[4][number_].enabled = true
			controlMap[5][number_].enabled = true
		)
			controlMap[2][number_].enabled = true
			controlMap[3][number_].enabled = true
			controlMap[6][number_].enabled = true
		
		skinOps.SelectBone skin_ (skinOps.GetSelectedBone skin_)
		skinOps.SetWeight skin_ 1.0
		skinOps.addWeight skin_ 1.0
		append gradient_arr #(0,0,0,0,1)
		reset_value__()
	)

	

	
	on Gradient_Multi_Bones open do
	(
		controlMap = #(
			#(
				Gradient_Multi_Bones.Select_Bone_1, 
				Gradient_Multi_Bones.Select_Bone_2, 
				Gradient_Multi_Bones.Select_Bone_3, 
				Gradient_Multi_Bones.Select_Bone_4, 
				Gradient_Multi_Bones.Select_Bone_5, 
				Gradient_Multi_Bones.Select_Bone_6, 
				Gradient_Multi_Bones.Select_Bone_7, 
				Gradient_Multi_Bones.Select_Bone_8, 
				Gradient_Multi_Bones.Select_Bone_9
			),
			#(
				Gradient_Multi_Bones.spn_bone1_1, 
				Gradient_Multi_Bones.spn_bone2_1, 
				Gradient_Multi_Bones.spn_bone3_1, 
				Gradient_Multi_Bones.spn_bone4_1, 
				Gradient_Multi_Bones.spn_bone5_1, 
				Gradient_Multi_Bones.spn_bone6_1, 
				Gradient_Multi_Bones.spn_bone7_1, 
				Gradient_Multi_Bones.spn_bone8_1, 
				Gradient_Multi_Bones.spn_bone9_1
			),
			#(
				Gradient_Multi_Bones.spn_bone1_2, 
				Gradient_Multi_Bones.spn_bone2_2, 
				Gradient_Multi_Bones.spn_bone3_2, 
				Gradient_Multi_Bones.spn_bone4_2, 
				Gradient_Multi_Bones.spn_bone5_2, 
				Gradient_Multi_Bones.spn_bone6_2, 
				Gradient_Multi_Bones.spn_bone7_2, 
				Gradient_Multi_Bones.spn_bone8_2, 
				Gradient_Multi_Bones.spn_bone9_2
			),
			#(
				Gradient_Multi_Bones.spn_bone1_3, 
				Gradient_Multi_Bones.spn_bone2_3, 
				Gradient_Multi_Bones.spn_bone3_3, 
				Gradient_Multi_Bones.spn_bone4_3, 
				Gradient_Multi_Bones.spn_bone5_3, 
				Gradient_Multi_Bones.spn_bone6_3, 
				Gradient_Multi_Bones.spn_bone7_3, 
				Gradient_Multi_Bones.spn_bone8_3, 
				Gradient_Multi_Bones.spn_bone9_3
			),
			#(
				Gradient_Multi_Bones.spn_bone1_4, 
				Gradient_Multi_Bones.spn_bone2_4, 
				Gradient_Multi_Bones.spn_bone3_4, 
				Gradient_Multi_Bones.spn_bone4_4, 
				Gradient_Multi_Bones.spn_bone5_4, 
				Gradient_Multi_Bones.spn_bone6_4, 
				Gradient_Multi_Bones.spn_bone7_4, 
				Gradient_Multi_Bones.spn_bone8_4, 
				Gradient_Multi_Bones.spn_bone9_4
			),
			#(
				Gradient_Multi_Bones.spn_bone1_value, 
				Gradient_Multi_Bones.spn_bone2_value, 
				Gradient_Multi_Bones.spn_bone3_value, 
				Gradient_Multi_Bones.spn_bone4_value, 
				Gradient_Multi_Bones.spn_bone5_value, 
				Gradient_Multi_Bones.spn_bone6_value, 
				Gradient_Multi_Bones.spn_bone7_value, 
				Gradient_Multi_Bones.spn_bone8_value, 
				Gradient_Multi_Bones.spn_bone9_value
			)
		)
	
		Save_View_Frame= #(viewport.getTM() , currentTime)
		registerRedrawViewsCallback GW_display_Gradient
			 Same=#All
			 Bones_list=#()
			 Gradient_arr=#()
			 colorArray = #(
			[255, 0, 0], 
			[0, 255, 0], 
			[255, 165, 0],
			[255, 0, 255], 
			[0, 0, 255], 
			[255, 255, 0], 
			[0, 255, 255], 
			[128, 0, 0], 
			[0, 128, 0], 
			[0, 0, 128]
			)
	)
	on Gradient_Multi_Bones close do
	(
		Gradient_arr=undefined
		unregisterRedrawViewsCallback GW_display_Gradient
	)
	on b_RestoreView pressed do
	(
		viewport.setTM Save_View_Frame[1]
		sliderTime = Save_View_Frame[2]
	)
	on b_Cancel pressed do
	(
		current_value_=getVertexSkinInfo()
		blendVertexSkinWeights memory_skin_vert 100 memory_skin_vert
		DestroyDialog Gradient_Multi_Bones
	)
	on b_Apply pressed do
	(
		DestroyDialog Gradient_Multi_Bones
	)
	on b_Same_G_ALL changed arg do
	(
		if arg == true do
		(
			Same = #All
			spn_bone1_4.enabled = false
			spn_bone1_4.value = 0
			Gradient_arr[1][4] = 0
			
			for i = 2 to Gradient_arr.count do
			(
				controlMap[4][i].enabled = false
				controlMap[5][i].enabled = false
				controlMap[4][i].value = 0
				controlMap[5][i].value = 0
				Gradient_arr[i][3] = Gradient_arr[1][3]
				Gradient_arr[i][4] = Gradient_arr[1][3]
			)
			
			change_value()
			return true
		)
		
		Same = false
		Gradient_arr[1][4] = Gradient_arr[1][3]
		spn_bone1_4.value = Gradient_arr[1][3]
		spn_bone1_4.enabled = true
		
		for i = 2 to Gradient_arr.count do
		(
			controlMap[4][i].enabled = true
			controlMap[5][i].enabled = true
			controlMap[4][i].value = Gradient_arr[1][3]
			controlMap[5][i].value = Gradient_arr[1][3]
			Gradient_arr[i][3] = Gradient_arr[1][3]
			Gradient_arr[i][4] = Gradient_arr[1][3]
		)
		
		change_value()
		return false
	)

	on b_ResetLine pressed do
	(
		draw_feature2()
		change_value()
	)
	on b_ResetValue pressed do
	(
		reset_value__()
	)
	on btn_MoreBones pressed do
	(
		height_=Gradient_Multi_Bones.height
		if height_==144 then
		(
			Gradient_Multi_Bones.height=222
		)
		else if height_==222 then
		(
			Gradient_Multi_Bones.height=300
		)
		else 
		(
			Gradient_Multi_Bones.height=144
		)
	)
	on Select_Bone_1 pressed do
	(
		if Select_Bone_1.text == "- Empty Bone - " then
		(
			select_bones()
			b_Same_G_ALL.enabled=true
			b_Same_G_ALL.checked=true
			spn_bone1_value.enabled=true
			Plus_Bone 1
		)
		else 
		(
			skinOps.SelectBone skin_ 	Select_Bone_1.text
		)
		
	)
	on Select_Bone_2 pressed do
	(
		if Select_Bone_2.text == "- Empty Bone - " then
		(
			select_bones()
			Plus_Bone 2
		)
		else 
		(
			skinOps.SelectBone skin_ Select_Bone_2.text
		)
	)
	on Select_Bone_3 pressed do
	(
		if Select_Bone_3.text == "- Empty Bone - " then
		(
			select_bones()
			Plus_Bone 3
		)
		else 
		(
			skinOps.SelectBone skin_ Select_Bone_3.text
		)
	)
	on Select_Bone_4 pressed do
	(
		if Select_Bone_4.text == "- Empty Bone - " then
		(
			select_bones()
			Plus_Bone 4
		)
		else 
		(
			skinOps.SelectBone skin_ Select_Bone_4.text
		)
	)
	on Select_Bone_5 pressed do
	(
		if Select_Bone_5.text == "- Empty Bone - " then
		(
			select_bones()
			Plus_Bone 5
		)
		else 
		(
			skinOps.SelectBone skin_ Select_Bone_5.text
		)
	)
	on Select_Bone_6 pressed do
	(
		if Select_Bone_6.text == "- Empty Bone - " then
		(
			select_bones()
			Plus_Bone 6
		)
		else 
		(
			skinOps.SelectBone skin_ Select_Bone_6.text
		)
	)
	on Select_Bone_7 pressed do
	(
		if Select_Bone_7.text == "- Empty Bone - " then
		(
			select_bones()
			Plus_Bone 7
		)
		else 
		(
			skinOps.SelectBone skin_ Select_Bone_7.text
		)
	)
	on Select_Bone_8 pressed do
	(
		if Select_Bone_8.text == "- Empty Bone - " then
		(
			select_bones()
			Plus_Bone 8
		)
		else 
		(
			skinOps.SelectBone skin_ Select_Bone_8.text
		)
	)
	on Select_Bone_9 pressed do
	(
		if Select_Bone_9.text == "- Empty Bone - " then
		(
			select_bones()
			Plus_Bone 9
		)
		else 
		(
			skinOps.SelectBone skin_ Select_Bone_9.text
		)
	)

	on spn_bone1_1 changed val do
	(
		Gradient_arr[1][1] = val
		change_value()
	)
	on spn_bone1_2 changed val do
	(
		Gradient_arr[1][2] = val
		change_value()
	)
	on spn_bone1_value changed val do
	(
		Gradient_arr[1][5] = val
		change_value()
	)
	on spn_bone2_1 changed val do
	(
		Gradient_arr[2][1] = val
		change_value()
	)
	on spn_bone2_2 changed val do
	(
		Gradient_arr[2][2] = val
		change_value()
	)
	on spn_bone2_value changed val do
	(
		Gradient_arr[2][5] = val
		change_value()
	)
	on spn_bone3_1 changed val do
	(
		Gradient_arr[3][1] = val
		change_value()
	)
	on spn_bone3_2 changed val do
	(
		Gradient_arr[3][2] = val
		change_value()
	)
	on spn_bone3_value changed val do
	(
		Gradient_arr[3][5] = val
		change_value()
	)
	on spn_bone4_1 changed val do
	(
		Gradient_arr[4][1] = val
		change_value()
	)
	on spn_bone4_2 changed val do
	(
		Gradient_arr[4][2] = val
		change_value()
	)
	on spn_bone4_value changed val do
	(
		Gradient_arr[4][5] = val
		change_value()
	)
	on spn_bone5_1 changed val do
	(
		Gradient_arr[5][1] = val
		change_value()
	)
	on spn_bone5_2 changed val do
	(
		Gradient_arr[5][2] = val
		change_value()
	)
	on spn_bone5_value changed val do
	(
		Gradient_arr[5][5] = val
		change_value()
	)
	on spn_bone6_1 changed val do
	(
		Gradient_arr[6][1] = val
		change_value()
	)
	on spn_bone6_2 changed val do
	(
		Gradient_arr[6][2] = val
		change_value()
	)
	on spn_bone6_value changed val do
	(
		Gradient_arr[6][5] = val
		change_value()
	)
	on spn_bone7_1 changed val do
	(
		Gradient_arr[7][1] = val
		change_value()
	)
	on spn_bone7_2 changed val do
	(
		Gradient_arr[7][2] = val
		change_value()
	)
	on spn_bone7_value changed val do
	(
		Gradient_arr[7][5] = val
		change_value()
	)
	on spn_bone8_1 changed val do
	(
		Gradient_arr[8][1] = val
		change_value()
	)
	on spn_bone8_2 changed val do
	(
		Gradient_arr[8][2] = val
		change_value()
	)
	on spn_bone8_value changed val do
	(
		Gradient_arr[8][5] = val
		change_value()
	)
	on spn_bone9_1 changed val do
	(
		Gradient_arr[9][1] = val
		change_value()
	)
	on spn_bone9_2 changed val do
	(
		Gradient_arr[9][2] = val
		change_value()
	)
	on spn_bone9_value changed val do
	(
		Gradient_arr[9][5] = val
		change_value()
	)
	on spn_bone1_3 changed val do
	(
		Gradient_arr[1][3] = val
		change_value()
	)
	on spn_bone1_4 changed val do
	(
		Gradient_arr[1][4] = val
		change_value()
	)
	on spn_bone2_3 changed val do
	(
		Gradient_arr[2][3] = val
		change_value()
	)
	on spn_bone2_4 changed val do
	(
		Gradient_arr[2][4] = val
		change_value()
	)
	on spn_bone3_3 changed val do
	(
		Gradient_arr[3][3] = val
		change_value()
	)
	on spn_bone3_4 changed val do
	(
		Gradient_arr[3][4] = val
		change_value()
	)
	on spn_bone4_3 changed val do
	(
		Gradient_arr[4][3] = val
		change_value()
	)
	on spn_bone4_4 changed val do
	(
		Gradient_arr[4][4] = val
		change_value()
	)
	on spn_bone5_3 changed val do
	(
		Gradient_arr[5][3] = val
		change_value()
	)
	on spn_bone5_4 changed val do
	(
		Gradient_arr[5][4] = val
		change_value()
	)
	on spn_bone6_3 changed val do
	(
		Gradient_arr[6][3] = val
		change_value()
	)
	on spn_bone6_4 changed val do
	(
		Gradient_arr[6][4] = val
		change_value()
	)
	on spn_bone7_3 changed val do
	(
		Gradient_arr[7][3] = val
		change_value()
	)
	on spn_bone7_4 changed val do
	(
		Gradient_arr[7][4] = val
		change_value()
	)
	on spn_bone8_3 changed val do
	(
		Gradient_arr[8][3] = val
		change_value()
	)
	on spn_bone8_4 changed val do
	(
		Gradient_arr[8][4] = val
		change_value()
	)
	on spn_bone9_3 changed val do
	(
		Gradient_arr[9][3] = val
		change_value()
	)
	on spn_bone9_4 changed val do
	(
		Gradient_arr[9][4] = val
		change_value()
	)
)

	


rollout Attach_Skin_Dialog "附加蒙皮对象" width:152 height:72
(
	local mode=1
	local skinobj, bone_list
	Button 'btn1' "选择蒙皮对象\n然后按此按钮" pos:[16,9] width:120 height:48 align:#left
	on btn1 pressed do
	(
			max modify mode
			if $selection.count<=1 do (Messagebox "请仅选择蒙皮对象"; DestroyDialog Attach_Skin_Dialog; return 0)
			for i in $selection do 
			(
			if i.modifiers[#Skin]==undefined do (Messagebox "请仅选择蒙皮对象"; DestroyDialog Attach_Skin_Dialog; return 0)	
			)
			sele=selection as array
			new_sele=#()
			for i in sele do
			(
				ii=copy i
				select ii
				append new_sele ii
			)
			
			converttopoly new_sele[1]
			
			for i=2 to new_sele.count do
			(
				polyop.attach new_sele[1] new_sele[i]
			)
			
			ddd=new_sele[1]
			select ddd
			addmodifier ddd (Skin_Wrap())
			ddd.modifiers[#Skin_Wrap].meshlist=sele
			ddd.modifiers[#Skin_Wrap].falloff = 10
			ddd.modifiers[#Skin_Wrap].threshold = 0.01
			ddd.modifiers[#Skin_Wrap].weightAllVerts = on
			ddd.modifiers[#Skin_Wrap].engine = 0
			select ddd
			
		messagebox "点击转换为蒙皮" 
		DestroyDialog Attach_Skin_Dialog
	)
)


rollout Advanced_Feature "高级功能" width:344 height:416
(
	dotNetControl 'edtDescription' "System.Windows.Forms.Textbox" pos:[16,152] width:312 height:112 align:#left
	GroupBox 'grp1' "从最近顶点复制权重" pos:[8,8] width:328 height:264 align:#left
	
	button 'btn3' "从选择加载" pos:[16,104] width:104 height:32 align:#left
	button 'btn5' "从选择加载" pos:[152,104] width:104 height:32 align:#left
	label 'lbl5' "-->" pos:[128,56] width:16 height:16 align:#left
	button 'btn14' "执行" pos:[264,56] width:64 height:40 align:#left
	label 'lbl23' "已选择 0 个顶点" pos:[24,56] width:88 height:32 align:#left
	GroupBox 'grp7' "参考源" pos:[16,32] width:104 height:64 align:#left
	GroupBox 'grp8' "目标" pos:[152,32] width:104 height:64 align:#left
	
	label 'lbl24' "已选择 0 个顶点" pos:[160,56] width:88 height:32 align:#left
	GroupBox 'grp71' "从其他对象逐一复制权重" pos:[8,280] width:328 height:128 align:#left
	button 'btn7' "执行" pos:[120,304] width:32 height:96 align:#left	
	
	
	pickbutton 'btn12' "拾取\n参考对象" pos:[16,304] width:96 height:96 align:#left
	dotNetControl 'edtDescription2' "System.Windows.Forms.Textbox" pos:[160,304] width:168 height:96 align:#left
	
	
	
	
	local Ref_v=#()
	local Tar_v=#()
	local Tar_v_OBJ, Ref_v_OBJ
	local a_list=#()
	local selectedVertices	
	local vert_arr, vert_arr2
	local mode_=1
	local theTimer,counter
	local From_Memory, To_Memory		
	local a,b
	local From_Obj=undefined
	local OBJ__ = undefined
	
	tool vertex_copy_paste
	( 
		fn getMouseBaseTm =
				(
					r = mapscreentoworldray mouse.pos
					tm = matrixfromnormal r.dir
					tm.pos = r.pos
					tm
				)
				
		fn getClosestVertexIndex  arr=
		(
			tm = getMouseBaseTm()
			arrDist = for pos in arr collect (length ((pos * inverse tm) * [1,1,0]))
			closestVertexIndex = finditem arrDist (amin arrDist)
			return #(closestVertexIndex,arr[closestVertexIndex])
		)

		on start do
			(	

				vert_arr=#()
				for i = 1 to (polyop.getNumVerts From_Obj) do
				(
						vertPos = polyop.getVert From_Obj i
						append vert_arr vertPos
					)

				vert_arr2=#()
				for i = 1 to (polyop.getNumVerts OBJ__) do
				(
						vertPos = polyop.getVert OBJ__ i
						append vert_arr2 vertPos
					)
					
					
			a=Tape length:1 pos:[0,0,0]  target:(Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [18.4012,-88.269,0]))
			b=a.Target
			
			)	
			
		on freeMove do 
		(
			if (mode_==1) then
				(
					From_Memory = #((getClosestVertexIndex vert_arr)[1])
					a.pos=((getClosestVertexIndex vert_arr)[2])
					b.pos=((getClosestVertexIndex vert_arr)[2])
				)
			else
				(
				)
		)
		
		on mouseMove arg  do 
		(
			if (mode_==1) then
				(
					From_Memory = #((getClosestVertexIndex vert_arr)[1])
					a.pos=((getClosestVertexIndex vert_arr)[2])
					b.pos=((getClosestVertexIndex vert_arr)[2])
				)
			else
				(
					To_Memory = #((getClosestVertexIndex vert_arr2)[1])
					b.pos=((getClosestVertexIndex vert_arr2)[2])
				)
		)
			
		on mousePoint arg do
		(
			if arg!=1 do 
			(
				if (mode_==1) then
				(
					From_Memory = #((getClosestVertexIndex vert_arr)[1])
					mode_=2
					print "COPY!!"
				)
				else
				(
					
					
					suspendEditing which:#modify
					mode_=1
					disableSceneRedraw()
					print "PASTE!!"
					max modify mode
					bb= skinOps.GetSelectedBone  obj__.modifiers[skin]
					if From_Obj!=OBJ__  or true then 
					(
					select From_Obj
						modPanel.setCurrentObject From_Obj.modifiers[#Skin]
						
					skinMod = From_Obj.modifiers[skin]
						vertIndex=From_Memory[1]
							weightCount = skinOps.GetVertexWeightCount skinMod vertIndex
							boneArr = #()
							weightsArr = #()
							for weightIndex = 1 to weightCount do
							(
								boneID = skinOps.GetVertexWeightBoneID skinMod vertIndex weightIndex
								boneName = skinOps.GetBoneName skinMod boneID 1
								weight = skinOps.GetVertexWeight skinMod vertIndex weightIndex
								append boneArr boneName
								append weightsArr weight
							)
							vertexInfo2 = #(boneArr, weightsArr)
					Tar_v_OBJ=OBJ__
					select Tar_v_OBJ
					skinOps.SelectVertices OBJ__.modifiers[#Skin] To_Memory
					modPanel.setCurrentObject Tar_v_OBJ.modifiers[skin] 
					gg_s=skinOps.GetBoneNodes Tar_v_OBJ.modifiers[skin]	
					gg = for obj in gg_s collect obj.name
					all_bones = #()
					for vi in a_list do
					(	
							for j in vi.boneArr do
							(
								appendIfUnique all_bones j
							)
					)
					empty_bones=""
					for bone__ in all_bones do
					(
						if (findItem gg bone__ == false) do
						(
							empty_bones += bone__ +"\n"
						)
					)
					if empty_bones!="" do 
					(
						empty_bones+="这些骨骼缺失。"
						messagebox empty_bones
						return false
					)
					
			selectedObject=Tar_v_OBJ
			current_selected_vert=getSelectedVertices_compat selectedObject.modifiers[skin]
				
			for i in current_selected_vert do 
			(
				bones_=skinOps.GetNumberBones selectedObject.modifiers[skin]
					bones_arr=#()
					
					for iii in vertexInfo2[1] do 
					(
						for ii=1 to bones_ do 
						(
							if (skinops.GetBoneName selectedObject.modifiers[skin] ii 0)==iii do 
							(
								append bones_arr ii
							)
						)
					)
					for ii=1 to bones_ do 
					(
						check_=false
						for iii in vertexInfo2[1] do 
						(
							if (skinops.GetBoneName selectedObject.modifiers[skin] ii 0)==iii do 
							(
								check_=true
							)
						)
						if check_==false do 
						(
							--skinops.SetVertexWeights selectedObject.modifiers[skin] i ii 0
						)
					)
						skinOps.ReplaceVertexWeights selectedObject.modifiers[skin] i bones_arr vertexInfo2[2]
						--skinops.SetVertexWeights selectedObject.modifiers[skin] i bones_arr closestVertexInfo.weightsArr
					
									vert_arr=#()
				for i = 1 to (polyop.getNumVerts From_Obj) do
				(
						vertPos = polyop.getVert From_Obj i
						append vert_arr vertPos
					)

				vert_arr2=#()
				for i = 1 to (polyop.getNumVerts OBJ__) do
				(
						vertPos = polyop.getVert OBJ__ i
						append vert_arr2 vertPos
					)
			)
						
						
						
					)
					
			enableSceneRedraw()
			redrawViews()
			resumeEditing which:#modify
			bakeSelectedVerts_compat OBJ__.modifiers[#Skin]
			subObjectLevel=1
			skinOps.SelectBone obj__.modifiers[#Skin] bb
			)
		)
	)
		on mouseAbort arg do 
		(
			delete a
				
			enableSceneRedraw()
			redrawViews()
			resumeEditing which:#modify
		)
	)


	
	struct VertexInfo
	(
		vertIndex,  -- 버텍스 인덱스
		boneArr,    -- 각 버텍스에 대한 본 이름 배열
		weightsArr  -- 각 버텍스에 대한 가중치 배열
	)
	fn findNearestVertex refVertPositions tarVertPositions targetVertexIndex =
(
    closestDist = undefined 
    closestVertex = undefined 

    -- targetVertex의 위치를 tarVertPositions 배열에서 가져옴
    targetPos = tarVertPositions[targetVertexIndex]

    -- refVertPositions에서 가장 가까운 레퍼런스를 찾기
    for i = 1 to refVertPositions.count do
    (
        dist = distance refVertPositions[i] targetPos

        if closestDist == undefined or dist < closestDist do
        (
            closestDist = dist
            closestVertex = i  -- refVertPositions 배열에서의 인덱스를 저장
        )
    )
    -- 가장 가까운 레퍼런스의 인덱스를 반환
    return closestVertex
)

	on Advanced_Feature open do
	(
		edtDescription.text="应用时，从邻近顶点复制权重到选中的顶点。\n适用于薄布料的均匀权重分布。\n"+
		" ([目标] 组的权重值会改变，[参考源] 组不变)\n(目标中注册的顶点会自动从参考源中排除)\n"+
		" (作为参考的 [距离] 基于当前帧屏幕上可见的距离)\n(可在不同对象之间操作)"
		
		edtDescription.ReadOnly = true
		edtDescription.Multiline = true
		edtDescription.WordWrap = true
		edtDescription.BackColor = (dotNetClass "System.Drawing.Color").Black
		edtDescription.ForeColor = (dotNetClass "System.Drawing.Color").White
		edtDescription.ScrollBars = (dotNetClass "System.Windows.Forms.ScrollBars").None
		
		edtDescription2.text="将参考对象的一个顶点权重复制到当前选中对象的一个顶点。\n通过连续点击逐个复制顶点。"
		
		edtDescription2.ReadOnly = true
		edtDescription2.Multiline = true
		edtDescription2.WordWrap = true
		edtDescription2.BackColor = (dotNetClass "System.Drawing.Color").Black
		edtDescription2.ForeColor = (dotNetClass "System.Drawing.Color").White
		edtDescription2.ScrollBars = (dotNetClass "System.Windows.Forms.ScrollBars").None
	)
	on btn3 pressed do
	(
		Ref_v_OBJ=selection[1]
		Ref_v=getSelectedVertices_compat skin_ 
		lbl23.text=(Ref_v.count as string) +" vertices selected"
		selectedVertices = Ref_v
	)
	on btn5 pressed do
	(
		Tar_v_OBJ=selection[1]
		Tar_v=getSelectedVertices_compat skin_ 
		lbl24.text=(Tar_v.count as string) +" vertices selected"
	)
	on btn14 pressed do
	(
		if (Tar_v_OBJ!=undefined) and (Tar_v_OBJ!=selection[1]) do (select Tar_v_OBJ;)
		Other_mode=false
		if (Ref_v==#()) or (Tar_v==#()) do (messageBox "请选择参考源和目标顶点"; return false)
		if (Ref_v_OBJ!=Tar_v_OBJ) do (
			if (queryBox ("在不同对象之间复制权重时，操作方式与默认不同。"+
			" 此过程可能较慢\n是否继续？")==true) then (Other_mode=true) else(return false)
			)
			
		MOD_poly=false
		if (classof Ref_v_OBJ.baseobject) == Editable_Poly do MOD_poly=1
		for i=Ref_v_OBJ.modifiers.count to 1 by -1 do 
		(
			if classof (Ref_v_OBJ.modifiers[i])==skin do MOD_skin=Ref_v_OBJ.modifiers[i]
			if classof (Ref_v_OBJ.modifiers[i])==Edit_Poly do MOD_poly=Ref_v_OBJ.modifiers[i]
		)
		
		if MOD_poly==false then (messagebox "此功能仅在 Edit Poly 或 Editable Poly 激活时可用。")
		
		MOD_poly=false
		if (classof Tar_v_OBJ.baseobject) == Editable_Poly do MOD_poly=1
		for i=Tar_v_OBJ.modifiers.count to 1 by -1 do 
		(
			if classof (Tar_v_OBJ.modifiers[i])==skin do MOD_skin=Tar_v_OBJ.modifiers[i]
			if classof (Tar_v_OBJ.modifiers[i])==Edit_Poly do MOD_poly=Tar_v_OBJ.modifiers[i]
		)
		
		if MOD_poly==false then (messagebox "此功能仅在 Edit Poly 或 Editable Poly 激活时可用。")
		
			bakeSelectedVerts_compat Tar_v_OBJ.modifiers[skin]
		max modify mode
		OBJ__=Tar_v_OBJ
		
		if Other_mode==true do 
		(
		suspendEditing which:#modify
			select Ref_v_OBJ
			modPanel.setCurrentObject Ref_v_OBJ.modifiers[skin] 
			a_list=#()
			skinMod = Ref_v_OBJ.modifiers[skin]
				for vertIndex in selectedVertices do
				(
					weightCount = skinOps.GetVertexWeightCount skinMod vertIndex
					boneArr = #()
					weightsArr = #()
					for weightIndex = 1 to weightCount do
					(
						boneID = skinOps.GetVertexWeightBoneID skinMod vertIndex weightIndex
						boneName = skinOps.GetBoneName skinMod boneID 1
						weight = skinOps.GetVertexWeight skinMod vertIndex weightIndex
						append boneArr boneName
						append weightsArr weight
					)
					vertexInfo2 = VertexInfo (polyop.getvert Ref_v_OBJ vertIndex) boneArr weightsArr
					append a_list vertexInfo2
				)
			selectedObject = Tar_v_OBJ
				
			select Tar_v_OBJ
			modPanel.setCurrentObject Tar_v_OBJ.modifiers[skin] 
			gg_s=skinOps.GetBoneNodes Tar_v_OBJ.modifiers[skin]	
			gg = for obj in gg_s collect obj.name
			all_bones = #()
			for vi in a_list do
			(	
					for j in vi.boneArr do
					(
						appendIfUnique all_bones j
					)
			)
			empty_bones=""
			for bone__ in all_bones do
			(
				if (findItem gg bone__ == false) do
				(
					empty_bones += bone__ +"\n"
				)
			)
			if empty_bones!="" do 
			(
				empty_bones+="These bones are missing."
				messagebox empty_bones
				resumeEditing which:#modify
				return false
			)
				
			bakeSelectedVerts_compat selectedObject.modifiers[skin]
			--skinOps.SetWeight selectedObject.modifiers[skin] 1
			current_selected_vert=getSelectedVertices_compat selectedObject.modifiers[skin]
			local total_vert_count = current_selected_vert.count
			local ten_percent_increment = total_vert_count / 10
			local start_time = timestamp() 
			local processed_vert_count =0
			for i in current_selected_vert do 
				(
					local minDistance=999999
					local closestVertexInfo
					
					for vertexInfo in a_list do
					(
						currentVertexCoord =  vertexInfo.vertIndex
						distance_ = distance currentVertexCoord (polyop.getvert selectedObject i)
						
						if distance_ < minDistance do
						(
							minDistance = distance_
							closestVertexInfo = vertexInfo
						)
					)
				
				for j=1 to 2 do 
				(	
					bones_=skinOps.GetNumberBones selectedObject.modifiers[skin]
					bones_arr=#()
					
					for iii in closestVertexInfo.boneArr do 
					(
						for ii=1 to bones_ do 
						(
							if (skinops.GetBoneName selectedObject.modifiers[skin] ii 0)==iii do 
							(
								append bones_arr ii
							)
						)
					)
					for ii=1 to bones_ do 
					(
						check_=false
						for iii in closestVertexInfo.boneArr do 
						(
							if (skinops.GetBoneName selectedObject.modifiers[skin] ii 0)==iii do 
							(
								check_=true
							)
						)
						if check_==false do 
						(
							--skinops.SetVertexWeights selectedObject.modifiers[skin] i ii 0
						)
					)
						skinOps.ReplaceVertexWeights selectedObject.modifiers[skin] i bones_arr closestVertexInfo.weightsArr
						--skinops.SetVertexWeights selectedObject.modifiers[skin] i bones_arr closestVertexInfo.weightsArr
				)
				processed_vert_count +=1
				progress_percentage=0
				if processed_vert_count >= ten_percent_increment then
				(
					progress_percentage = processed_vert_count * 100 / total_vert_count
					print ("进度: " + progress_percentage as string + "%")
					ten_percent_increment += total_vert_count / 10
				)
	
				if start_time != undefined do
				(
					local current_time = timestamp()
					local elapsed_time = current_time - start_time
					if elapsed_time >= 1000 then -- 변경된 부분: 2초 이상인 경우에만 계산
					(
						if (progress_percentage==0) do (progress_percentage = processed_vert_count * 100 / total_vert_count)
						local remaining_percentage = 100 - progress_percentage
						local remaining_time = (elapsed_time / progress_percentage) * remaining_percentage
						local remaining_seconds = remaining_time / 1000
						if remaining_seconds > 13 then -- 当剩余时间超过13秒时才显示 queryBox
						(
							start_time = undefined
							local a = queryBox ("预计剩余时间为 " + remaining_seconds as string + " 秒。是否继续？")
							if a == false do 
							(
								max undo
								return false
							)
						)
					)
				)
			)
			resumeEditing which:#modify
				subObjectLevel=1
				messagebox "操作成功"
			
			bakeSelectedVerts_compat Tar_v_OBJ.modifiers[skin]
			return false
		)
		undo on (
    -- Ref_v와 Tar_v에 대해 getvert를 미리 계산한 배열을 만들어 두고 재사용
    refVertPositions = for refVertex in Ref_v collect polyop.getvert OBJ__ refVertex
    tarVertPositions = for targetVertex in Tar_v collect polyop.getvert OBJ__ targetVertex

        -- Ref_v가 적을 경우: 각 Tar_v의 요소에 대해 가장 가까운 Ref_v를 찾음
        for targetVertexIndex = 1 to Tar_v.count do
        (
            if (findItem Ref_v Tar_v[targetVertexIndex] == 0) then
            (
                closestRefVertex = findNearestVertex refVertPositions tarVertPositions targetVertexIndex
                skinOps.SelectVertices skin_ Ref_v[closestRefVertex]
                skinOps.copyWeights skin_
                skinOps.SelectVertices skin_ Tar_v[targetVertexIndex]
                skinOps.pasteWeights skin_
            )
        )
)


				messagebox "操作成功"
	)
	on btn7 pressed do
	(
		test=modpanel.getCurrentObject () as string
		if (test=="Skin:Skin" ) then
		(
			--subobjectLevel = 1
			From_Obj=btn12.object
			OBJ__=selection[1]
			startTool vertex_copy_paste
		)
	)
	on btn12 picked arg do
	(
		btn12.text="蒙皮参考对象\r\n"+arg.name
	)
	on btn12 pressed do
	(
		Ref_v_OBJ=selection[1]
		Ref_v=getSelectedVertices_compat Ref_v_OBJ.modifiers[skin] 
		lbl23.text=(Ref_v.count as string) +" vertices selected"
		a_list=#()
		skinMod = Ref_v_OBJ.modifiers[skin]
			selectedVertices = getSelectedVertices_compat skinMod
			for vertIndex in selectedVertices do
			(
				weightCount = skinOps.GetVertexWeightCount skinMod vertIndex
				boneArr = #()
				weightsArr = #()
				for weightIndex = 1 to weightCount do
				(
					boneID = skinOps.GetVertexWeightBoneID skinMod vertIndex weightIndex
					boneName = skinOps.GetBoneName skinMod boneID 1
					weight = skinOps.GetVertexWeight skinMod vertIndex weightIndex
					append boneArr boneName
					append weightsArr weight
				)
				vertexInfo2 = VertexInfo (polyop.getvert Ref_v_OBJ vertIndex) boneArr weightsArr
				append a_list vertexInfo2
			)
	)
)

rcmenu Savemenu
(
	menuItem m1 "保存到 A (空)" enabled:true
	menuItem m2 "保存到 B (空)" enabled:true
   
   on Savemenu open do 
   (	   
	   aa= save_vertices[1]
	   bb= save_vertices[2]
	   if aa!=undefined and aa.count>0 do  m1.text="覆盖到 A (" +(save_vertices[1].count as string)+" 个顶点已保存)"
	   if bb!=undefined and bb.count>0 do  m2.text="覆盖到 B (" +(save_vertices[2].count as string)+" 个顶点已保存)"
   )
	   
	on m1 picked do
		(
			save_vertices[1]=getSelectedVertices_compat skin_
			save_vertices[3]=getVertexSkinInfo()
		)
	on m2 picked do
		(
			save_vertices[2]=getSelectedVertices_compat skin_
			save_vertices[4]=getVertexSkinInfo()			
		)

)
rcmenu Loadmenu
(
	menuItem m1 "选择 A : " enabled:true
	menuItem m2 "选择 B : " enabled:true
	menuItem m3 "并集 (A+B)" enabled:true
	menuItem m4 "交集 (A*B)" enabled:true
	menuItem m5 "差集 (A-B)" enabled:true
	menuItem m6 "差集 (B-A)" enabled:true
	menuItem m7 "---------- : " enabled:true
	menuItem m8 "加载 A 权重 : " enabled:true
	menuItem m9 "加载 B 权重 : " enabled:true
   
   on Loadmenu open do 
   (
	   m1.text="选择 A : "+(save_vertices[1].count as string)+" 个顶点"
	   m2.text="选择 B : "+(save_vertices[2].count as string)+" 个顶点"
	   m8.text="加载 A 权重 : "+(save_vertices[1].count as string)+" 个顶点"
	   m9.text="加载 B 权重 : "+(save_vertices[2].count as string)+" 个顶点"
   )
   
	on m1 picked do
		(skinOps.SelectVertices skin_ save_vertices[1])
	on m2 picked do
		(skinOps.SelectVertices skin_ save_vertices[2])
    on m3 picked do 
    (
        local union_set = makeUniqueArray(save_vertices[1] + save_vertices[2])
        skinOps.SelectVertices skin_ union_set
    )
    on m4 picked do 
    (
        local intersection_set = for v in save_vertices[1] where (findItem save_vertices[2] v != 0) collect v
        skinOps.SelectVertices skin_ intersection_set
    )
    on m5 picked do
    (
        local difference_set = for v in save_vertices[1] where (findItem save_vertices[2] v == 0) collect v
        skinOps.SelectVertices skin_ difference_set
    )
    on m6 picked do 
    (
        local difference_set = for v in save_vertices[2] where (findItem save_vertices[1] v == 0) collect v
        skinOps.SelectVertices skin_ difference_set
    )
	on m8 picked do
		(
			append save_vertices[1] #select 

			aa=GetDialogPos P_WT_Rollout
			mode___=0
			if aa.x<800 do mode___=224+184 
			CreateDialog Load_Weights 224 80 (aa.x-224+mode___) aa.y
			)
	on m9 picked do
		(
			append save_vertices[2] #select 
			
			aa=GetDialogPos P_WT_Rollout
			mode___=0
			if aa.x<800 do mode___=224+184 
			CreateDialog Load_Weights 224 80 (aa.x-224+mode___) aa.y
			)
)

rcmenu MyRCmenu
(
	menuItem m1 "--" enabled:false
	menuItem m2 "--" enabled:false
	menuItem m3 "--" enabled:false
	menuItem m4 "--" enabled:false
	menuItem m5 "--" enabled:false
	menuItem m6 "--" enabled:false
	menuItem m7 "--" enabled:false
	menuItem m8 "--" enabled:false
	menuItem m9 "--" enabled:false
	menuItem m10 "--" enabled:false
   
   on MyRCmenu open do 
   (
	   m1.text="--"
	   m2.text="--"
	   m3.text="--"
	   m4.text="--"
	   m5.text="--"
	   m6.text="--"
	   m7.text="--"
	   m8.text="--"
	   m9.text="--"
	   m10.text="--"
		ab=skinOps.GetBoneNode skin_ (skinOps.GetSelectedBone skin_)
		ab_children=#()
		for i in (skinOps.GetBoneNodes skin_) do 
		(
			for ii in ab.children do 
			(
				if i.name==ii.name do 
				(
					appendIfUnique ab_children i
				)
			)
		)
		
		local reversedArray = #()

		for i = ab_children.count to 1 by -1 do
		(
			append reversedArray ab_children[i]
		)
		ab_children=reversedArray
		
	   try(
	   m1.text=ab_children[1].name; m1.enabled=true
	   m2.text=ab_children[2].name; m2.enabled=true
	   m3.text=ab_children[3].name; m3.enabled=true
	   m4.text=ab_children[4].name; m4.enabled=true
	   m5.text=ab_children[5].name; m5.enabled=true
	   m6.text=ab_children[6].name; m6.enabled=true
	   m7.text=ab_children[7].name; m7.enabled=true
	   m8.text=ab_children[8].name; m8.enabled=true
	   m9.text=ab_children[9].name; m9.enabled=true
	   m10.text=ab_children[10].name; m10.enabled=true
	   )catch()
   )
	on m1 picked do
		(skinOps.SelectBone skin_ m1.text)
	on m2 picked do
		(skinOps.SelectBone skin_ m2.text)
	on m3 picked do
		(skinOps.SelectBone skin_ m3.text)
	on m4 picked do
		(skinOps.SelectBone skin_ m4.text)
	on m5 picked do
		(skinOps.SelectBone skin_ m5.text)
	on m6 picked do
		(skinOps.SelectBone skin_ m6.text)
	on m7 picked do
		(skinOps.SelectBone skin_ m7.text)
	on m8 picked do
		(skinOps.SelectBone skin_ m8.text)
	on m9 picked do
		(skinOps.SelectBone skin_ m9.text)
	on m10 picked do
		(skinOps.SelectBone skin_ m10.text)
)


rollout Edit_Curve_Dialog "编辑曲线" width:216 height:88
(
	button 'btn3' "重置" pos:[152,8] width:56 height:24 align:#left
	button 'btn4' "关闭" pos:[152,40] width:56 height:40 align:#left
	spinner 'spn2' "" pos:[48,8] width:96 height:16 range:[0,100,1] scale:0.01 align:#left
	spinner 'spn3' "" pos:[48,24] width:96 height:16 range:[0.001,10,0.001] scale:0.01 align:#left
	spinner 'spn4' "" pos:[48,40] width:96 height:16 range:[0.001,10,0.001] scale:0.01 align:#left
	label 'lbl1' "数值" pos:[8,8] width:32 height:16 align:#left
	label 'lbl2' "收缩" pos:[8,24] width:32 height:16 align:#left
	label 'lbl3' "膨胀" pos:[8,40] width:32 height:16 align:#left
	dropdownList 'ddl1' "" pos:[37,60] width:108 height:22 align:#left items:#("线性 / 增加","线性 / 减少","圆形 / 增加","圆形 / 减少")
	label 'lbl28' "模式" pos:[8,64] width:32 height:16 align:#left

	

	fn changedvalue=
		(
			for i = 1 to skin_vert_arr.count do (
			tar_ = closestPointOnLine2D viewpoint_xy lastpoint_xy skin_vert_screen_arr[i]

			a__ = distance tar_ viewpoint_xy
			b__ = distance tar_ lastpoint_xy

			weight = 1.0 - a__ / distance__
				
					
				
			a=spn2.value
			b=spn3.value
			x=weight
			x=(1 - exp(b * x)) / (1 - exp(b))
			b=spn4.value
			curve_value=(1 - exp(-b * x)) / (1 - exp(-b))
				curve_value=curve_value*a
				if curve_value<=0 do curve_value=0
				if minus then
				(
					newWeight = skin_vert_arr[i][2] - curve_value
					if newWeight < 0 do newWeight = 0
					skinOps.setVertexWeights skin_ skin_vert_arr[i][1] bone_ newWeight
				)
				else
					skinOps.setVertexWeights skin_ skin_vert_arr[i][1] bone_ (curve_value + skin_vert_arr[i][2])
		)
		)
	
		fn changedvalue_circle =
		(
			--bakeSelectedVerts_compat skin_
			for i = 1 to skin_vert_arr.count do
			(
				tar_ = closestPointOnLine2D viewpoint_xy lastpoint_xy skin_vert_screen_arr[i]
				a = spn2.value
				b = spn3.value
				x = tar_
				x = (1 - exp(b * x)) / (1 - exp(b))
				b = spn4.value
				curve_value = (1 - exp(-b * x)) / (1 - exp(-b))
				curve_value = curve_value * a
				
				-- 만약 minus가 true일 경우, 기존 가중치에서 curve_value를 빼기
				if minus then
				(
					newWeight = skin_vert_arr[i][2] - curve_value
					if newWeight < 0 do newWeight = 0
					skinOps.setVertexWeights skin_ skin_vert_arr[i][1] bone_ newWeight
				)
				else
				(
					skinOps.setVertexWeights skin_ skin_vert_arr[i][1] bone_ (curve_value + skin_vert_arr[i][2])
				)
			)
		)
	on Edit_Curve_Dialog open do 
	(
		n=1
		if minus==true do (n+=1)
		if _mode==#circle do (n+=2)
		ddl1.selection=n
	)
		
	on Edit_Curve_Dialog close do
	(
		   _mode = undefined
			minus=undefined
		if (skinOps.isWeightToolOpen skin_)==false and open__==true do (skinOps.WeightTool skin_)
	
	)
	on btn3 pressed do
	(
		spn2.value=1
		spn3.value=0.001
		spn4.value=0.001
		if _mode==#circle then (changedvalue_circle())
		else (changedvalue())
	)
	on btn4 pressed do
	(
		DestroyDialog Edit_Curve_Dialog
		
	)
	on spn2 changed arg do
	(
		if _mode==#circle then (changedvalue_circle())
		else (changedvalue())
	)
	on spn3 changed arg do
	(
		if _mode==#circle then (changedvalue_circle())
		else (changedvalue())
	)
	on spn4 changed arg do
	(
		if _mode==#circle then (changedvalue_circle())
		else (changedvalue())
	)
	on ddl1 selected  arg do 
	(
		if arg==1 then 
		(
			_mode=#line
			minus=false
			changedvalue()
		)
		else if arg==2 then 
		(
			_mode=#line
			minus=true
			changedvalue()
		)
		else if arg==3 then 
		(
			_mode=#circle
			minus=false
			changedvalue_circle()
		)
		else if arg==4 then 
		(
			_mode=#circle
			minus=true
			changedvalue_circle()
		)
	)
)
rollout P_WT_Rollout "P_SkinWeightTool 2.0.1" width:184 height:776
(
	local SelectedVertex
	local SelectedBone
	local SelectedVertexWC=1
	local arr, arr2, arr3
	local last_vert_weight
	local sld_before_arg
	local objectsExceptBones = #()
	
	
	fn check_editpoly=
	(
		if skinOps.GetSelectedBone skin_==0 do return false
		if (classof OBJ__.baseobject) == Editable_Poly do return true
		
		MOD_poly=false
		MOD_skin=false
		
		for i=1 to OBJ__.modifiers.count do 
		(
			if classof (OBJ__.modifiers[i])==skin do MOD_skin=i
			if (classof (OBJ__.modifiers[i])==Edit_Poly) do MOD_poly=i
		)
		
		if MOD_poly==false or (MOD_poly<MOD_skin)do( (messagebox "此功能仅在 Skin 修改器位于 Edit Poly 或 Editable Poly 之上时可用"); return false)
		return true
	)
	
	fn compareNestedArrays arr1 arr2 =
	(
		if (arr1 as string)==(arr2 as string) do return true
		return false
		/*
		if arr1.count != arr2.count then return false

		for i = 1 to arr1.count do
		(
			if isKindOf arr1[i] Array and not compareNestedArrays arr1[i] arr2[i] or
			   not isKindOf arr1[i] Array and arr1[i] != arr2[i] do return false
		)
		return true*/
	)
		
	fn mergeUniqueArrays arr1 arr2 =
	(
		f = false
		for i in arr1 do for ii in arr2 where i == ii do (f = true; exit)
		if f do
		(
			arr = #()
			for i in arr1 do appendIfUnique arr i
			for i in arr2 do appendIfUnique arr i
			return arr
		)
		false
	)


	fn splitIntersection arr =
	(
		for aa=1 to 20 do 
		(
			arr2=arr
			for i = 1 to arr.count do 
			(
				for ii = i + 1 to arr.count do
				(
					a = (mergeUniqueArrays arr[i] arr[ii])
					if a != false do (arr[i] = a; arr[ii] = #();)
				)
			)
			arr=  for subArr in arr where subArr.count != 0 collect subArr
			if ((arr as string)==(arr2 as string)) == true do (return arr)
		)
	)

	
	
	function draw_feature mode__:#line minus_:false=
	(
	bakeSelectedVerts_compat skin_
	open__=false
	_mode=mode__
	minus=minus_

	bone_=skinOps.GetSelectedBone skin_
	skin_vert_arr=#()
	skin_vert_screen_arr=#()
	lastpoint_xy=[0,0,0]
	viewpoint_xy=[0,0,0]
	distance__=0
		
	 tool AssignSkinVertexWeightTool1
					(
						
						on mousePoint clickno do (                 
													
										if clickno > 1 then 
											(    unregisterRedrawViewsCallback GW_displayObjectNames; 
												
												
												return  #stop  )   
							viewpoint_xy=[viewPoint.x,viewPoint.y,0]
							get_verts_screen_position()
							
						)
						on mouseAbort clickno do (
							unregisterRedrawViewsCallback GW_displayObjectNames;  
							
							return  #stop  
						)
					   on mouseMove clickno do 
						(
							if AltKey ==true then (minus=true) else (minus=false)
						   if _mode==#Circle then
						   (
									lastpoint_xy = [viewPoint.x, viewPoint.y, 0]
									distance__ = distance viewpoint_xy lastpoint_xy
									for i = 1 to skin_vert_arr.count do
									(
										tar_ = closestPointOnLine2D viewpoint_xy lastpoint_xy skin_vert_screen_arr[i]
										
										if minus==false then (skinOps.setVertexWeights skin_ skin_vert_arr[i][1] bone_ (tar_+skin_vert_arr[i][2]))
										else (skinOps.setVertexWeights skin_ skin_vert_arr[i][1] bone_ (skin_vert_arr[i][2]-tar_))
									)
							)
						   else 
							(
								lastpoint_xy = [viewPoint.x, viewPoint.y, 0]
								distance__ = distance viewpoint_xy lastpoint_xy

								for i = 1 to skin_vert_arr.count do (
								tar_ = closestPointOnLine2D viewpoint_xy lastpoint_xy skin_vert_screen_arr[i]

								a__ = distance tar_ viewpoint_xy
								b__ = distance tar_ lastpoint_xy

								weight = 1.0 - a__ / distance__
								if weight<0 do weight=0
								if minus==false then (skinOps.setVertexWeights skin_ skin_vert_arr[i][1] bone_ (weight+skin_vert_arr[i][2]))
								else (skinOps.setVertexWeights skin_ skin_vert_arr[i][1] bone_ (skin_vert_arr[i][2] - weight))
								)
							)
						)
							on stop do
							(
								CreateDialog Edit_Curve_Dialog  216 88 (mouse.screenpos.x-170) (mouse.screenpos.y-10)
							)
					)


			skin_vert_arr=#()
			skin_vert_screen_arr=#()
				for i=1 to (skinOps.GetNumberVertices skin_) do
				(
					a=skinOps.isVertexSelected skin_  i
					if a==true do (
						vv=0
								for ii=1 to (skinOps.GetVertexWeightCount skin_ i) do 
								(
									if 	((skinOps.GetVertexWeightBoneID skin_ i ii)==bone_) do 
									(
										vv=(skinOps.GetVertexWeight skin_ i ii )
									)
								)
						append skin_vert_arr [i,vv]
						)
				)
				if skin_vert_arr.count==0 do (messageBox "请选择顶点！"; return false)
				if (skinOps.isWeightToolOpen skin_)==true do (open__=true; skinOps.closeWeightTool skin_)
				get_verts_screen_position()
				unregisterRedrawViewsCallback GW_displayObjectNames;  
				registerRedrawViewsCallback GW_displayObjectNames  
										
				startTool AssignSkinVertexWeightTool1 prompt:"设置顶点权重"
							
	)
	
	
	
	fn hide_fn type vertices unselect:false=
	(
		if skinOps.GetSelectedBone skin_==0 do return false
		
		MOD_poly=false
		MOD_skin=false
		
		for i=1 to OBJ__.modifiers.count do 
		(
			if classof (OBJ__.modifiers[i])==skin do MOD_skin=i
			if (classof (OBJ__.modifiers[i])==Edit_Poly) do MOD_poly=i
		)
		if MOD_poly==false or (MOD_poly<MOD_skin) then
		( 
			if (classof OBJ__.baseobject) == Editable_Poly then MOD_poly=1
			else ((messagebox "此功能仅在 Skin 修改器位于 Edit Poly 或 Editable Poly 之上时可用"); return false)
		) 
		else (MOD_poly=OBJ__.modifiers[MOD_poly];MOD_skin=OBJ__.modifiers[MOD_skin];)
				
		if type==#unhide and MOD_poly!=1 do (MOD_poly.ButtonOp #UnhideAllFace; MOD_poly.ButtonOp #UnhideAllVertex; return true)
		if type==#unhide and MOD_poly==1 do (OBJ__.baseobject.unhideAll #Face; OBJ__.baseobject.unhideAll #Vertex; return true)
		
		if MOD_poly==1 and type==#face do  
			(
				if unselect==true do 
				(
					numVerts=polyOp.getNumVerts OBJ__.baseobject
					allVerts = #{1..numVerts}
					vertices = allVerts - (vertices as BitArray)
				)
				polyop.setHiddenFaces OBJ__.baseobject (polyop.getFacesUsingVert OBJ__.baseobject vertices); return true
			)
		if MOD_poly==1 and type==#vertices do  
			(
				if unselect==true do 
				(
					numVerts=polyOp.getNumVerts OBJ__.baseobject
					allVerts = #{1..numVerts}
					vertices = allVerts - (vertices as BitArray)
				)
				(polyop.setHiddenVerts OBJ__.baseobject vertices); return true
			)
		
		modPanel.setCurrentObject MOD_poly
		subobjectLevel = 1
		if type==#vertices do  ((MOD_poly.SetSelection #Vertex #{}); MOD_poly.Select #Vertex (vertices as BitArray); if unselect==true do (max select invert); MOD_poly.ButtonOp #HideVertex)
		if type==#face do ((MOD_poly.SetSelection #Vertex #{}); MOD_poly.Select #Vertex (vertices as BitArray);
											MOD_poly.ConvertSelection #Vertex #Face; subobjectLevel = 4; if unselect==true do (max select invert);MOD_poly.ButtonOp #HideFace)
		subobjectLevel = 0
		modPanel.setCurrentObject MOD_skin
		subobjectLevel =	1
	)
	
	function find_next_ring direction:true=
	(
			if (check_editpoly ()==false) do return false
			try(
				M = skin_
					
				arr=getSelectedVertices_compat M 
				arrj=getSelectedVertices_compat M 
					
				skinOps.growSelection M
				arr2=getSelectedVertices_compat M 

				arr3=#()
				for val in arr do
				(
					if findItem arr2 val == 0 do
					(
						append arr3 val
					)
				)

				for val in arr2 do
				(
					if findItem arr val == 0 do
					(
						append arr3 val
					)
				)

				skinOps.SelectVertices M arr3

				Varr=#()
				for i in arr3 do 
				(
					skinOps.SelectVertices M i
					skinOps.growSelection M
					arr4=getSelectedVertices_compat M
					
					b_arr=#()
					for val in arr4 do
					(
						if findItem arr3 val != 0 do
						(
							append b_arr val
						)
					)
					append Varr (b_arr)
				)
				result=splitIntersection Varr
				
				arr3_island1=result[1]
				arr3_island2=result[2]
				a=direction
					if pre_ring==undefined then
					(
						if a==true then
							(skinOps.SelectVertices M arr3_island1; pre_ring=#(arrj,false))
						else 
							(skinOps.SelectVertices M arr3_island2; pre_ring=#(arrj,true))
					)
					else
					(
						resultA= ((sort pre_ring[1] as string)==(sort arr3_island1 as string))
						resultB= ((sort pre_ring[1] as string)==(sort arr3_island2 as string))
							if a==pre_ring[2] and (resultA==true or resultB==true) then 
							(
								skinOps.SelectVertices M pre_ring[1];  pre_ring=#(arrj,not a)
							)
							else
							(
								resultA= ((sort pre_ring[1] as string)==(sort arr3_island1 as string))
								if resultA==true then 
									(
										(skinOps.SelectVertices M arr3_island2; pre_ring=#(arrj,not a))
									)
								else
									(
										(skinOps.SelectVertices M arr3_island1; pre_ring=#(arrj,not a))
									)
							)
					)
				)catch()
	)
	
	function select_element=
	(
		for i=1 to 20 do 
			(
				A = ((getSelectedVertices_compat skin_))
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				B = ((getSelectedVertices_compat skin_) as array)
				if A.count==B.count do (exit)
			)
	)
	button 'b_grow' "+" pos:[48,96] width:40 height:32 toolTip:"右键: 选择元素" align:#left
	button 'b_shrink' "-" pos:[8,96] width:40 height:32 toolTip:"右键: 取消全选" align:#left 
 
 
 
 
	button 'b_Loop' "循环" pos:[136,96] width:40 height:32 toolTip:"右键: 选择元素" align:#left 
 
 
 
 
	button 'b_next' "◀" pos:[96,64] width:40 height:32 toolTip:"下一环" align:#left 
 
 
 
 
	button 'b_previous' "▶" pos:[136,64] width:40 height:32 toolTip:"上一环" align:#left 
 
 
 
 
	button 'b_Ring' "环形" pos:[96,96] width:40 height:32 toolTip:"右键: 选择元素" align:#left 
 
 
 
 
	button 'b_Load' "元素" pos:[48,64] width:40 height:32 toolTip:"加载顶点选集" iconName:":/CommandPanel/Motion/BipedRollout/MotionFlow/LoadFile" align:#left

	button 'b_parent' "父级" pos:[64,24] width:40 height:32 toolTip:"选择父骨骼" align:#left 
 
 
 
	button 'b_child' "子级" pos:[104,24] width:40 height:32 toolTip:"选择子骨骼" align:#left 
 
 
 
	button 'b_mirror' "镜像" pos:[144,24] width:32 height:32 toolTip:"选择镜像骨骼" iconName:":/CommandPanel/Motion/BipedRollout/Mirror" iconSize:[20,20] align:#left 
 
 
 
	button 'b_save' "保存" pos:[8,64] width:40 height:32 toolTip:"保存顶点选集" iconName:":/CommandPanel/Motion/BipedRollout/MotionMixer/BatchSave" align:#left
	button 'b_selectBones' "选骨骼" pos:[8,24] width:56 height:32 toolTip:"选择骨骼\n右键: 选择模式" iconName:":/MainUI/SelectInvert" align:#left
	
	
	button 'b_DrawLine' "绘制渐变" pos:[16,416] width:72 height:32 toolTip:"右键: 圆形模式\nAlt键: 减少" align:#left
	button 'b_DrawMulti' "多线渐变" pos:[96,416] width:72 height:32 align:#left
	button 'b_Hammer' "平滑" pos:[16,448] width:72 height:32 toolTip:"右键: 平滑 x 5" align:#left  
	button 'b_Average' "平均化" pos:[96,448] width:56 height:32 align:#left
	button 'b_LockWeights' "锁定权重" pos:[96,480] width:72 height:32 align:#left
	button 'b_Advanced' "高级功能" pos:[16,480] width:72 height:32 align:#left
	
	listbox 'lbx_1' "" pos:[16,296] width:152 height:8 align:#left
	button 'b_0' "0" pos:[8,136] width:24 height:24 align:#left
	button 'b_1' ".1" pos:[32,136] width:24 height:24 align:#left
	button 'b_25' ".25" pos:[56,136] width:24 height:24 align:#left
	button 'b_5' ".5" pos:[80,136] width:24 height:24 align:#left
	button 'b_75' ".75" pos:[104,136] width:24 height:24 align:#left
	button 'b_9' ".9" pos:[128,136] width:24 height:24 align:#left
	button 'b_100' "1" pos:[152,136] width:24 height:24 align:#left
	button 'b_Set_Weight' "设置权重" pos:[8,160] width:48 height:32 align:#left
	button 'b_Scale_Weight' "缩放权重" pos:[8,192] width:48 height:32 align:#left
	button 'b_Copy' "复制" pos:[8,264] width:40 height:24 align:#left
	button 'b_Paste' "粘贴" pos:[48,264] width:40 height:24 align:#left
	button 'b_PastePos' "按位粘贴" pos:[88,264] width:48 height:24 align:#left
	button 'b_Blend' "混合" pos:[136,264] width:40 height:24 align:#left
	spinner 'spn_weight' "" pos:[60,164] width:48 height:16 range:[0,0.5,1] type:#float scale:0.05 align:#left
	spinner 'spn_scale' "" pos:[60,196] width:48 height:16 range:[0.001,0.95,5] type:#float scale:0.05 align:#left
	button 'b_Plus' "+" pos:[112,160] width:32 height:32 align:#left
	button 'b_Minus' "-" pos:[144,160] width:32 height:32 align:#left
	button 'b_plus2' "+" pos:[112,192] width:32 height:32 align:#left
	button 'b_minus2' "-" pos:[144,192] width:32 height:32 align:#left
	slider 'sld1' "" pos:[8,224] width:178 height:25 range:[-1,1,0] align:#left

	Timer 'SecTme' "Tme" pos:[168,600] width:24 height:24 interval:100 align:#left 
 
 
 

	button 'b_vertex' "顶点" pos:[16,608] width:32 height:32 iconName:"Common\\Vertex" iconSize:[20,20] align:#left
	button 'b_face' "面" pos:[56,608] width:32 height:32 iconName:"Common\\Face" iconSize:[20,20] align:#left
	button 'b_element' "元素" pos:[96,608] width:32 height:32 iconName:"Common/Element" iconSize:[20,20] align:#left
	button 'b_unhide' "显示" pos:[136,608] width:32 height:32 iconName:":/EditUVW/UnhideAll" iconSize:[20,20] align:#left
	button 'b_objcolor' "对象颜色" pos:[16,568] width:72 height:32 align:#left
	button 'b_mtlcolor' "材质颜色" pos:[96,568] width:72 height:32 align:#left
	button 'b_CustomSet' "截面 关" pos:[96,536] width:72 height:24 toolTip:"关闭截面显示\n右键: + 封套不可点击" align:#left
	button 'b_CustomSetOn' "截面 开" pos:[16,536] width:72 height:24 enabled:true toolTip:"开启截面显示" align:#left
 
	button 'bones_list_Add' "+" pos:[8,696] width:40 height:24 align:#left
	button 'bones_list_remove' "-" pos:[48,696] width:40 height:24 align:#left
	button 'bones_Change' "替换" pos:[8,728] width:46 height:40 align:#left
	button 'bones_pick_Add' "+" pos:[96,696] width:40 height:24 align:#left
	button 'bones_pick_remove' "-" pos:[136,696] width:40 height:24 align:#left
	label 'lb_List' "列表" pos:[44,680] width:32 height:16 align:#left
	label 'lb_Pick' "拾取" pos:[120,680] width:32 height:16 align:#left
	button 'b_Removezero' "移除零权骨" pos:[110,728] width:66 height:40 align:#left
	button 'b_skinattach' "蒙皮合并" pos:[54,728] width:56 height:40 align:#left
 
 
	label 'lbl3' "---------- 选择 + 权重 ----------" pos:[8,8] width:184 height:16 align:#left
	label 'lbl5' "---------- 显示 ----------" pos:[32,520] width:128 height:16 align:#left
	label 'lbl7' "---------- 骨骼 ----------" pos:[32,664] width:120 height:16 align:#left
	label 'lbl55' "隐藏选择 (右键:隐藏未选)" pos:[8,640] width:168 height:16 align:#left
	--button 'b_Hide_BonesTab' "O" pos:[152,672] width:16 height:16 align:#left

	
	button 'btn146' "◀" pos:[152,448] width:16 height:16 align:#left
	button 'btn147' "▶" pos:[152,464] width:16 height:16 align:#left
	
	local pre_ring

	fn All_Button_able mode=
	(
		if mode==false then 
		(
			if b_grow.enabled==false do return true
		    for ctrl in P_WT_Rollout.controls do
			(
					ctrl.enabled = false 
			)
			b_objcolor.enabled=true
			b_mtlcolor.enabled=true
		)
		else if b_grow.enabled==false then 
		(
		    for ctrl in P_WT_Rollout.controls do
			(
					ctrl.enabled = true 
			)
		)
	)
	
	
	on P_WT_Rollout open do
	(
		try(
		OBJ=selection[1].modifiers[Skin]
		OBJ__=selection[1]
		spn_weight.value=skin_.weightTool_weight
		spn_scale.value=skin_.weightTool_scale
		save_vertices=#(#(),#(),#())
			)
		catch()
		SelectedVertex=#()
		SelectedBone=undefined
		SelectedBone_LOCAL=undefined
		arr=#()
		sld_before_arg=0
	)
	on P_WT_Rollout close do
	(
		P_WT_Rollout=undefined
		save_vertices=undefined
		 skin_vert_arr=undefined
		 lastpoint_xy=undefined
		 viewpoint_xy=undefined
		 GW_display_Gradient=undefined
		 Bones_list=undefined
		 Gradient_arr=undefined
		 colorArray = undefined
		 skin_vert_screen_arr=undefined
		 memory_skin_vert=undefined
		Multi_bones=undefined
		vertexSkinInfo_for_Lock = undefined
		saved_Vertices_for_Lock=undefined
		
		try (DestroyDialog Edit_Curve_Dialog)catch()
		Edit_Curve_Dialog=undefined
		try (DestroyDialog Lock_Weights)catch()
		Lock_Weights=undefined
	)
	on P_WT_Rollout resized pt do
	(
	    P_WT_Rollout.width = 184
	)
	on b_grow pressed do
	(
		undo on 
		(skinOps.growSelection skin_)
	)
	on b_grow rightClick do
	(
		undo on 
		(select_element())
	)
	on b_shrink pressed do
	(
		undo on 
		(skinOps.shrinkSelection skin_)
	)
	on b_shrink rightClick do
	(
		undo on 
		(actionMan.executeAction 0 "40043" )
	)
	on b_Loop pressed do
	(
		undo on 
		(skinOps.loopSelection skin_)
	)
	on b_Loop rightClick do
	(
		undo on 
		(select_element())
	)
	on b_next pressed do
	(
		undo on
		(
			find_next_ring()
		)
	)
	on b_previous pressed do
	(
		undo on
		(
			find_next_ring direction:false
		)
	)
	on b_Ring pressed do
	(
		undo on 
		(skinOps.ringSelection skin_)
	)
	on b_Ring rightClick do
	(
		undo on 
		(select_element())
	)
	on b_Load rightClick do
	(
		if (save_vertices.count!=0) do 
			(
			undo on 
				(
					skinOps.SelectVertices skin_ save_vertices[3]
				)
			)
	)
	on b_Load pressed do
	(
		 PopupMenu Loadmenu 
	)
	on b_parent pressed do
	(
		if skinOps.GetSelectedBone skin_==0 do return false
		skinOps.selectParent skin_
	)
	on b_child pressed do
	(
		if skinOps.GetSelectedBone skin_==0 do return false
		a=skinOps.GetBoneNode skin_ (skinOps.GetSelectedBone skin_)
		a_children=#()
		for i in (skinOps.GetBoneNodes skin_) do 
		(
			for ii in a.children do 
			(
				if i.name==ii.name do 
				(
					appendIfUnique a_children i
				)
			)
		)
		if a_children.count>1 do 
		(
		   PopupMenu MyRcmenu 
	   )
	   if a_children.count==1 do skinOps.SelectBone skin_ (a_children[1].name)
	)
	on b_mirror pressed do
	(
		if skinOps.GetSelectedBone skin_==0 do return false
		rf=skin_.ref_frame
		currentFrame = sliderTime
		disableSceneRedraw()
		sliderTime = rf
		arr=skinOps.GetBoneNodes skin_
		now_name=skinops.GetBoneName skin_ (skinOps.GetSelectedBone skin_) 1
		matching_nodes=undefined
			
			p1=#("Left","L_","_L"," L ","L)","L]","L-")
			p2=#("Right","R_","_R"," R ","R)","R]","R-")
			
		for i = 1 to p1.count do
		(
			if findString now_name p1[i] != undefined do
			(
				a=substituteString now_name p1[i] p2[i]
				matching_nodes = for node in arr where node.name == a collect node
			)
			if findString now_name p2[i] != undefined do
			(
				a=substituteString now_name p2[i] p1[i]
				matching_nodes = for node in arr where node.name == a collect node
			)
		)
		if matching_nodes!=undefined do 
			(
				sliderTime=currentFrame
				enableSceneRedraw()
				CompleteRedraw()
				skinOps.selectBoneByNode skin_ matching_nodes[1]; 
				return true
			)
		arr = skinOps.GetBoneNodes skin_
		now_ = skinOps.GetBoneNode skin_ (skinOps.GetSelectedBone skin_)
		
		closestBone=undefined
		closestDistance = 9999999
		for i in arr do
		(
			myCoord = i.boundingBox.center
			target = [(selection[1].pos.x) -  myCoord.x, myCoord.y, myCoord.z] 
			
			local distance_ = distance now_.boundingBox.center target
			if distance_ < closestDistance then
			(
				closestDistance = distance_
				closestBone = i
			)
		)
		if closestBone != undefined then skinOps.selectBoneByNode skin_ closestBone
		sliderTime=currentFrame
		enableSceneRedraw()
		CompleteRedraw()
	)
	on b_save rightClick do
	(
		save_vertices[3]=getSelectedVertices_compat skin_
	)
	on b_save pressed do
	(
		 PopupMenu Savemenu 
	)
	on b_selectBones pressed do
	(
		select_bones()
	)
	on b_selectBones rightClick do
	(
		select_bones mode_:true
	)
	on b_DrawLine pressed do
	(
			draw_feature()
	)
	on b_DrawLine rightClick do
	(
			draw_feature mode__:#Circle
	)
	on b_DrawMulti pressed do
	(
		unregisterRedrawViewsCallback GW_displayObjectNames  
		try(DestroyDialog Gradient_Multi_Bones)catch()
		draw_feature2()
	)
	on b_Hammer pressed do
	(
		bakeSelectedVerts_compat skin_
		(
			if selection.count == 1 do
			(
				skinvertarr=#()
				undo on
				(
					skinvertarr=getSelectedVertices_compat skin_
					skinHammer_compat skin_ skinvertarr
				)
			)
		)
	)
	on b_Hammer rightClick do
	(
		bakeSelectedVerts_compat skin_
		(
			if selection.count == 1 do
			(
				skinvertarr=#()
				undo on
				(
					for ii=1 to 5 do 
					(
						skinvertarr=getSelectedVertices_compat skin_
						skinHammer_compat skin_ skinvertarr
					)
				)
			)
		)
	)
	on b_Average pressed do
	(
		Mvert_arr=getSelectedVertices_compat skin_
	
		arr=#()
		for i in Mvert_arr do 
		(	a=skinOps.GetVertexWeightCount skin_ i
			for ii=1 to a do 
			(	append arr #((skinOps.GetVertexWeightBoneID skin_ i ii),(skinOps.GetVertexWeight skin_ i ii)))
		)
	
		index_=#()
		for ii in arr do 
		(		check_=false
				for iii=1 to index_.count do 
				(	if index_[iii][1]==ii[1] do check_=iii	)
				if check_==false do
				(	append index_ ii	)
				if check_!=false do 
				(	index_[check_][2]=index_[check_][2]+ii[2]	)
		)
		for i in index_ do 
		(	i[2]=(i[2]/Mvert_arr.count) )
		newarr1 = #()
		newarr2 = #()
	
		for subArr in index_ do
		(	if subArr[2]!=0 do 
			(
			append newarr1 subArr[1]
	
			append newarr2 subArr[2]
			)
		)
		bakeSelectedVerts_compat skin_
	
		for i in Mvert_arr do 
		(
			skinOps.SetVertexWeights skin_ i newarr1 newarr2
		)
	)
	on lbx_1 selected arg do
	(
		if arg==0 do return false
		skinOps.SelectBone skin_ arr[lbx_1.selection]
		SelectedBone = (skinOps.GetSelectedBone skin_)
	)
	on b_0 pressed do
	(
		skinOps.setWeight skin_ 0
	)
	on b_1 pressed do
	(
		skinOps.setWeight skin_ 0.1
	)
	on b_25 pressed do
	(
		skinOps.setWeight skin_ 0.25
	)
	on b_5 pressed do
	(
		skinOps.setWeight skin_ 0.5
	)
	on b_75 pressed do
	(
		skinOps.setWeight skin_ 0.75
	)
	on b_9 pressed do
	(
		skinOps.setWeight skin_ 0.9
	)
	on b_100 pressed do
	(
		skinOps.setWeight skin_ 1
	)
	on b_Set_Weight pressed do
	(
		skinOps.setWeight skin_ (skin_.weightTool_weight )
	)
	on b_Scale_Weight pressed do
	(
		skinOps.scaleWeight skin_ (skin_.weightTool_scale )
	)
	on b_Copy pressed do
	(
		skinOps.copyWeights skin_
	)
	on b_Paste pressed do
	(
		skinOps.pasteWeights skin_
	)
	on b_PastePos pressed do
	(
		skinOps.pasteWeightsByPos skin_ (skin_.weightTool_tolerance)
	)
	on b_PastePos rightClick do
	(
		val=Dialog_modal  ("Set Paste-Pos Tolerance") ((skin_.weightTool_tolerance) as string)
		try(val=val as float) catch()
		if (isKindOf val float)==true do (skin_.weightTool_tolerance=val)
	)
	on b_Blend pressed do
	(
		blendSelected_compat skin_
	)
	on b_Plus pressed do
	(
		skinOps.addWeight skin_ 0.05
	)
	on b_Minus pressed do
	(
		skinOps.addWeight skin_ -0.05
	)
	on b_plus2 pressed do
	(
		skinOps.scaleWeight skin_ 1.05
	)
	on b_minus2 pressed do
	(
		skinOps.scaleWeight skin_ 0.95
	)
	on sld1 changed arg do
	(  
			undo off
		(
		val=(arg-sld_before_arg)*0.7
		skinOps.AddWeight skin_ val
		sld_before_arg=arg
		)
	)
	on sld1 buttondown do
	(
		bakeSelectedVerts_compat skin_
	)
	on sld1 buttonup do
	(
		sld1.value=0
		sld_before_arg=0
		setFocus P_WT_Rollout
	)
	on sld1 rightClick do
	(
		a=(GetDialogPos P_WT_Rollout)+[192/2,385]
		
		local pos = dotNetObject "System.Drawing.Point" (a.x+3) (a.y-110)
		(dotNetClass "System.Windows.Forms.Cursor").Position = pos
	)
	on SecTme tick do
	(
		mod_=modpanel.getCurrentObject()
		if  classof(mod_)!=skin then (All_Button_able false; return false)
		else (All_Button_able true)
		if selection[1]!=OBJ__ do (OBJ__=selection[1]; skin_=mod_;)
			
		local newVertices = ((getSelectedVertices_compat skin_) as array)
		local newBone = (skinOps.GetSelectedBone skin_)
		local check_bone_change=false
		local arraysEqual = true
			
		if newBone!=SelectedBone do 
			(
				SelectedBone=newBone
				check_bone_change=true
			)
			
		
		if SelectedVertex.count != newVertices.count then
		(
			arraysEqual = false
			check_bone_change=true
		)
		else
		(
			check_vertex=true
			for i = 1 to SelectedVertex.count do
			(
				if SelectedVertex[i] != newVertices[i] do
				(
					arraysEqual = false
					check_bone_change=true
					exit
				)
			)
			
			if (arraysEqual) and (newVertices.count !=0)  do
			(
				WC_=skinOps.GetVertexWeightCount skin_ newVertices[1]
				if (WC_)!=SelectedVertexWC  then 
				(
					SelectedVertexWC=WC_
					arraysEqual = false
				)
				
				else
				(
					tar=1
					for i=1 to (WC_) do 
					(
						if (skinOps.GetVertexWeight skin_ newVertices[1] i)!=0 do (tar=i; exit)
					)
					try (vert_weight=(skinOps.GetVertexWeight skin_ (newVertices[1]) tar)) catch(vert_weight=#(0))
					if vert_weight!=last_vert_weight do
					(
						last_vert_weight=vert_weight
						arraysEqual = false
					)
				)
			)
		)
		
		
		
		if (not arraysEqual) do
		(
			SelectedVertex = newVertices 
			a= getSelectedVertices_compat skin_
			arr=#()
			if a.count==0 then arr=#()
			else
			(
				for i=1 to (skinOps.GetVertexWeightCount skin_ a[1]) do 
				(
					appendIfUnique arr (skinOps.GetVertexWeightBoneID skin_ a[1] i)
				)
			)
			newArr = #()
			for i = 1 to arr.count do
			(
				local weight = "0.000"
				local vall = skinOps.GetVertexWeight skin_ SelectedVertex[1] i
				if vall >= 0.005 do
				(
					weight = makeFiveCharacters (vall as string)
				)
				local boneName = skinOps.GetBoneName skin_ arr[i] 1
				append newArr (weight + " : " + boneName)
			)
			lbx_1.items =newArr
		)
		
		if check_bone_change do 
		(
			lbx_1.selection=0
			for i=1 to arr.count do (if arr[i]==newBone do ( lbx_1.selection=i; exit))
		)
	)
	on b_vertex pressed do
	(
		undo on 
		(
		hide_fn #vertices (getSelectedVertices_compat skin_)
		enableSceneRedraw()
		skinOps.SelectVertices skin_ #{}
		)
	)
	on b_vertex rightClick do
	(
		undo on 
		(
		v=(getSelectedVertices_compat skin_)
		hide_fn #vertices v unselect:true
		skinOps.SelectVertices skin_ v
		enableSceneRedraw()
		redrawViews()
		)
	)
	on b_face pressed do
	(
		undo on 
		(
		hide_fn #face (getSelectedVertices_compat skin_)
		enableSceneRedraw()
		skinOps.SelectVertices skin_ #{}
		)
	)
	on b_face rightClick do
	(
		undo on 
		(
		v=(getSelectedVertices_compat skin_)
		skinOps.growSelection skin_
		hide_fn #face (getSelectedVertices_compat skin_) unselect:true
		skinOps.SelectVertices skin_ v
		enableSceneRedraw()
		redrawViews()
		)
	)
	on b_element pressed do
	(
		undo on 
		(
			for i=1 to 20 do 
			(
				A = ((getSelectedVertices_compat skin_))
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				B = ((getSelectedVertices_compat skin_) as array)
				if A.count==B.count do (exit)
			)
			hide_fn #face (getSelectedVertices_compat skin_)
			enableSceneRedraw()
			skinOps.SelectVertices skin_ #{}
		)
	)
	on b_element rightClick do
	(
		undo on 
		(
			old = ((getSelectedVertices_compat skin_) as array)
			for i=1 to 20 do 
			(
				A = ((getSelectedVertices_compat skin_) as array)
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				skinOps.growSelection skin_
				B = ((getSelectedVertices_compat skin_) as array)
				if A.count==B.count do (exit)
			)
			hide_fn #face (getSelectedVertices_compat skin_) unselect:true
			enableSceneRedraw()
			skinOps.SelectVertices skin_ old
		)
	)
	on b_unhide pressed do
	(
		undo on 
		(
		hide_fn #unhide 1
		enableSceneRedraw()
		)
	)
	on b_unhide rightClick do
	(
		undo on 
		(
		hide_fn #unhide 1
		enableSceneRedraw()
		)
	)
	on b_objcolor pressed do
	(
		displayColor.shaded = #object
	)
	on b_mtlcolor pressed do
	(
		displayColor.shaded = #material
	)
	on b_CustomSet pressed do
	(
		skin_.showNoEnvelopes = on
		skin_.filter_cross_sections = off
		skin_.filter_envelopes = on
	)
	on b_CustomSet rightClick do
	(
		skin_.showNoEnvelopes = on
		skin_.filter_cross_sections = off
		skin_.filter_envelopes = off
	)
	on b_CustomSetOn pressed do
	(
		skin_.showNoEnvelopes = off
		skin_.filter_cross_sections = on
		skin_.filter_envelopes = on
	)
	on b_CustomSetOn rightClick do
	(
		skin_.showNoEnvelopes = off
		skin_.filter_cross_sections = on
		skin_.filter_envelopes = on
	)
	on bones_list_Add pressed do
	(
		objectsExceptBones = for obj2 in objects where findItem (skinOps.GetBoneNodes skin_) obj2 == -1 and obj2 != skin_ collect obj2
		fn shape_filt obj3 = findItem objectsExceptBones obj3 != -1
		theShapes = selectByName title:"添加骨骼" filter:shape_filt single:false
		if theShapes==undefined do return false
		for i=1 to (theShapes.count) do 
		(
			skinOps.addbone  skin_ theShapes[i] -1
		)
	)
	on bones_list_remove pressed do
	(
		macros.run "Skin Modifier" "multiRemove"
	)
	on bones_Change pressed do
	(
		if skinOps.GetSelectedBone skin_==0 do return false
		now_bone=(skinOps.GetBoneName skin_ (skinOps.GetSelectedBone skin_) 1)
		messagebox "此功能不支持撤销，请谨慎使用。"
		text___="["+now_bone+"]     (当前选中的骨骼)\n"+
		"   ↓ ↓ ↓ ↓ ↓ ↓ ↓ \n[接下来选择的另一骨骼] \n\n(替换骨骼可以是已注册的骨骼或未注册的骨骼)\n\n"+
		"是否继续？"
		if (queryBox text___)==false do return false
		
		fn shape_filt obj3 = (obj3 != OBJ__ and obj3 != (skinOps.GetBoneNode skin_ (skinOps.GetSelectedBone skin_)))
		To_Object = selectByName title:"替换为 : " filter:shape_filt single:true showHidden:true
		if To_Object!=undefined do 
			(
				next_bone=To_Object.name
				final_text="删除骨骼 ["+now_bone+"] 并将其权重转移到骨骼 ["+next_bone+"]。\n是否继续？"
				if (queryBox final_text)==false do return false
				undo on (skinOps.replaceBone skin_ (skinOps.GetSelectedBone skin_) To_Object)
			)
	)
	on bones_pick_Add pressed do
	(
		rollout Add_Bone "添加骨骼(拾取)" width:152 height:72
		(
			local bone_list
			Button 'btn1' "选择骨骼\n然后按此按钮" pos:[16,9] width:120 height:48 align:#left
			on btn1 pressed do
			(
					destroydialog Add_Bone
			)
			on Add_Bone close do 
			(
				OBJ__.xray = off
				unfreeze OBJ__
				bone_list=selection as array
				select OBJ__
				max modify mode
				subObjectLevel= 1
				if bone_list.count==0 do (destroydialog Add_Bone; 
					return 0)
				for i in bone_list do
					(
					skinOps.addbone (skin_) i -1
					)
			)
		)
		OBJ__.xray = on
		freeze OBJ__
		deselect OBJ__
		macros.run "Selection" "SmartSelect"
		createdialog Add_Bone
	)
	on bones_pick_remove pressed do
	(	
		arr=(skinOps.GetBoneNodes skin_)
		if arr.count==0 do return false
			max create mode
		arr2=#()
		arr3=#()
		for obj3 in arr do
		(
			isHidden2 = obj3.isHidden;     isFrozen2 = obj3.isFrozen
			append arr2 #(obj3, isHidden2, isFrozen2)
			append arr3 #(obj3.layer, obj3.layer.ishidden)
		)
		if (IsolateSelection.IsolateSelectionModeActive()==true) do
		(IsolateSelection.ExitIsolateSelectionMode())
		select arr
		IsolateSelection.EnterIsolateSelectionMode()
		for i in arr do 
		(
			i.isHidden=false; i.isFrozen=false
		)
		select arr
		IsolateSelection.ExitIsolateSelectionMode()
		IsolateSelection.EnterIsolateSelectionMode()
		deselect $
		
		rollout Remove_Bone "移除骨骼(拾取)" width:208 height:112
		(
			button 'btn1' "选择要移除的所有骨骼，\n然后按此按钮。" pos:[16,16] width:176 height:80 align:#left
			
			on btn1 pressed do 
			(
				old_select = for skin_ in selection collect skin_
				
				if selection.count!=0 do deselect $
				for i=1 to arr2.count  do
				(
					arr2[i][1].ishidden=arr2[i][2]
					arr2[i][1].isfrozen=arr2[i][3]
				)
				for i in arr3 do 
				(
					i[1].ishidden=i[2]
				)
				IsolateSelection.ExitIsolateSelectionMode()
				select OBJ__
				max modify mode
				subObjectLevel= 1
				if old_select.count!=0 do 
				(
					for ii=1 to old_select.count do 
					(
						for i=1 to (skinOps.GetNumberBones skin_ ) do 
						(
							if (skinOps.GetBoneName skin_ i 1) == old_select[ii].name do 
								(
									try(skinOps.removebone skin_ i)catch(print "fail")
									exit
								)
						)
					)
				)
				DestroyDialog Remove_Bone
			)
			on Remove_Bone close do 
			(
				if selection.count!=0 do deselect $
				for i=1 to arr2.count  do
				(
					arr2[i][1].ishidden=arr2[i][2]
					arr2[i][1].isfrozen=arr2[i][3]
				)
				for i in arr3 do 
				(
					i[1].ishidden=i[2]
				)
				IsolateSelection.ExitIsolateSelectionMode()
				select OBJ__
				max modify mode
				subObjectLevel= 1
			)
		)
		macros.run "Selection" "SmartSelect"
		CreateDialog Remove_Bone
	)
	on b_Removezero pressed do
	(
		messagebox "此功能不支持撤销，请谨慎使用。"
		if (queryBox "是否继续移除所有未分配给任何顶点权重值的骨骼？")==true do 
			(removeUnusedBones_compat skin_)
	)
	on b_skinattach pressed do
	(
		CreateDialog Attach_Skin_Dialog
		max create mode
	)
	on b_Advanced pressed do
	(
		aa=GetDialogPos P_WT_Rollout
		mode___=0
		if aa.x<800 do mode___=344+184 
		CreateDialog Advanced_Feature 344 416 (aa.x-344+mode___) aa.y
	)
	on lbl5 pressed do
	(
	)
	on lbl7 pressed do
	(
	)
	on b_LockWeights pressed do 
	(
		aa=GetDialogPos P_WT_Rollout
		mode___=0
		if aa.x<800 do mode___=240+184
		CreateDialog Lock_Weights 240 208 (aa.x-240+mode___) aa.y
	)
	on btn146 pressed do
	(
		undo on
		(
			find_next_ring()
		)
	)
	on btn147 pressed do
	(
		undo on
		(
			find_next_ring direction:false
		)
	)
)

if selection.count!=0 and (selection[1].modifiers[Skin]!=undefined ) then 
	(skin_=selection[1].modifiers[Skin])
CreateDialog P_WT_Rollout   style:#(#style_resizing,#style_titlebar, #style_border, #style_sysmenu)

)

