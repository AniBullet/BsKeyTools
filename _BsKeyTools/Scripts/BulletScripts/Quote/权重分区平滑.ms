rollout skinWeights "skin权重平滑" width:260 height:100
(
	button 'btn1' "一键权重分区" pos:[17,17] width:85 height:32 align:#left
	button 'btn2' "平滑权重" pos:[118,17] width:85 height:32 align:#left
	spinner 'spn1' "" pos:[209,25] width:35 height:16 range:[1,100,1] type:#integer align:#left
	
	progressBar 'pb1' "" pos:[29,57] width:198 height:8 color:(color 0 0 255) align:#left
	GroupBox 'grp1' "绑定专用" pos:[10,3] width:240 height:76 align:#left
	label 'lbl1' "by：一方狂三" pos:[9,81] width:68 height:15 align:#left
	button 'btn3' "使用说明" pos:[177,83] width:70 height:14 align:#left
	
	-- 基于现有权重的纯分区函数
	fn convertToHardWeights obj skinMod =
	(
		local vertCount = obj.numverts
		local boneCount = skinOps.GetNumberBones skinMod
		
		print ("开始处理 " + vertCount as string + " 个顶点的权重转换")
		
		-- 为每个顶点处理权重
		for v = 1 to vertCount do
		(
			-- 更新进度条
			pb1.value = (v as float / vertCount) * 100
			
			-- 获取当前顶点的权重信息
			local vertexWeightCount = skinOps.GetVertexWeightCount skinMod v
			local maxWeight = 0.0
			local dominantBone = 1
			
			-- 找到权重最大的骨骼
			for w = 1 to vertexWeightCount do
			(
				local boneID = skinOps.GetVertexWeightBoneID skinMod v w
				local weight = skinOps.GetVertexWeight skinMod v w
				
				if weight > maxWeight then
				(
					maxWeight = weight
					dominantBone = boneID
				)
			)
			
			-- 将顶点100%分配给权重最大的骨骼
			skinOps.ReplaceVertexWeights skinMod v #(dominantBone) #(1.0)
		)
		
		pb1.value = 100
		return true
	)
	
	on btn1 pressed do
	(
		if selection.count == 0 then
		(
			messagebox "请选中一个以上的物体" beep:false
		)
		else
		(
			local obj = selection[1]
			local skinMod = obj.modifiers[#Skin]
			
			if skinMod == undefined then
			(
				messageBox "当前物体没有皮肤修改器！" title:"错误"
			)
			else
			(
				-- 设置当前修改器
				modPanel.setCurrentObject skinMod
				subobjectLevel = 1
				
				-- 第一步：设置封套大小
				local skin_num = skinOps.GetNumberBones skinMod
				print ("开始设置 " + skin_num as string + " 个骨骼的封套...")
				
				for i = 1 to skin_num do
				(
					-- 获取该骨骼的内部封套半径
					local innerRadius = skinOps.GetInnerRadius skinMod i 1
					innerRadius = innerRadius + 1
					
					-- 选择交叉截面并设置外部封套的半径
					skinOps.SelectCrossSection skinMod 1 1
					skinOps.setOuterRadius skinMod i 1 innerRadius
					
					skinOps.SelectCrossSection skinMod 2 1
					skinOps.setOuterRadius skinMod i 2 innerRadius
				)
				
				print "封套设置完成，开始基于现有权重进行纯分区..."
				
				-- 第二步：基于现有权重进行纯分区
				pb1.value = 0
				local success = convertToHardWeights obj skinMod
				
				if success then
				(
					print "基于现有权重的纯分区完成！"
					redrawViews()
				)
				else
				(
					print "权重分区失败"
				)
			)
		)
	)
	
	on btn2 pressed do
	(
		undo on
		(
			-- 检查选择状态
			if selection.count != 1 then
			(
				messageBox "请选择一个对象！" title:"错误"
				return false
			)
			
			-- 检查是否在Skin修改器模式下
			if classOf (modPanel.getCurrentObject()) != Skin then
			(
				messageBox "请先选择Skin修改器！" title:"错误"
				return false
			)
			
			local obj = selection[1]
			local skinMod = modPanel.getCurrentObject()  -- 直接获取当前的Skin修改器
			
			-- 优化后的平滑权重函数
			fn smoothSkinWeightsOptimized obj skinMod iterations threshold =
			(
				local vertCount = obj.numverts
				local boneCount = skinOps.GetNumberBones skinMod
				
				-- 获取需要处理的顶点（选中的顶点）- 修复：转换为数组
				local vertsToProcess = #()
				for v = 1 to vertCount do
				(
					-- 修复：显式检查返回值是否为真值（非0）
					if (skinOps.IsVertexSelected skinMod v) == 1 then
						append vertsToProcess v
				)
				
				if vertsToProcess.count == 0 then
				(
					-- 如果没有选中顶点，处理所有顶点
					for v = 1 to vertCount do
						append vertsToProcess v
				)
				
				print ("开始平滑处理 " + vertsToProcess.count as string + " 个顶点")
				
				-- 预建立邻接关系表，避免重复计算
				local neighborMap = #()
				neighborMap.count = vertCount + 1
				
				print "建立邻接关系表..."
				pb1.value = 10
				
				for v in vertsToProcess do
				(
					local neighborVerts = #()
					
					-- 根据模型类型获取相邻顶点
					if classof obj == Editable_Poly or classof obj == PolyMeshObject then
					( 
					  local edges = polyop.GetEdgesUsingVert obj v
					  for e in edges do
					  ( 
					    local edgeVerts = polyop.getEdgeVerts obj e
					    for ev in edgeVerts do 
					      if ev != v then appendIfUnique neighborVerts ev
					  ) 
					) 
					else if classof obj == Editable_Mesh then
					( 
					  local faces = meshop.GetFacesUsingVert obj v
					  for f in faces do
					  ( 
					    local faceVerts = getFace obj f  -- getFace返回point3类型
					    if faceVerts.x as integer != v then appendIfUnique neighborVerts (faceVerts.x as integer)
					    if faceVerts.y as integer != v then appendIfUnique neighborVerts (faceVerts.y as integer)
					    if faceVerts.z as integer != v then appendIfUnique neighborVerts (faceVerts.z as integer)
					  ) 
					)
					
					neighborMap[v] = neighborVerts
				)
				
				-- 预读取所有顶点的权重信息，避免重复API调用
				local vertexWeights = #()
				vertexWeights.count = vertCount + 1
				
				print "预读取权重信息..."
				pb1.value = 20
				
				for v in vertsToProcess do
				(
					local weights = #()
					local bones = #()
					
					local weightCount = skinOps.GetVertexWeightCount skinMod v
					for w = 1 to weightCount do
					(
						local boneID = skinOps.GetVertexWeightBoneID skinMod v w
						local weight = skinOps.GetVertexWeight skinMod v w
						if weight > threshold then
						(
							append bones boneID
							append weights weight
						)
					)
					
					vertexWeights[v] = #(bones, weights)
				)
				
				-- 开始平滑迭代
				for iter = 1 to iterations do
				(
					pb1.value = 20 + (iter as float / iterations) * 70
					
					-- 存储新权重，避免在迭代过程中修改数据
					local newWeights = #()
					newWeights.count = vertCount + 1
					
					-- 为每个顶点计算新的权重
					for v in vertsToProcess do
					(
						local neighborVerts = neighborMap[v]
						
						if neighborVerts != undefined and neighborVerts.count > 0 then
						(
							local currentBones = vertexWeights[v][1]
							local currentWeights = vertexWeights[v][2]
							
							-- 收集邻居顶点的权重信息
							local neighborWeightSum = #()
							for i = 1 to boneCount do neighborWeightSum[i] = 0.0
							
							local neighborCount = 0
							for nv in neighborVerts do
							(
								if vertexWeights[nv] != undefined then
								(
									neighborCount += 1
									local nvBones = vertexWeights[nv][1]
									local nvWeights = vertexWeights[nv][2]
									
									for i = 1 to nvBones.count do
									(
										local boneID = nvBones[i]
										local weight = nvWeights[i]
										neighborWeightSum[boneID] += weight
									)
								)
							)
							
							-- 计算平均权重并与当前权重混合
							if neighborCount > 0 then
							(
								local blendRatio = 0.5  -- 混合比例
								local finalWeights = #()
								local finalBones = #()
								
								-- 创建权重映射表
								local weightMap = #()
								for i = 1 to boneCount do weightMap[i] = 0.0
								
								-- 设置当前权重
								for i = 1 to currentBones.count do
								(
									local boneID = currentBones[i]
									weightMap[boneID] = currentWeights[i]
								)
								
								-- 混合权重
								for boneID = 1 to boneCount do
								(
									local currentWeight = weightMap[boneID]
									local neighborAvgWeight = neighborWeightSum[boneID] / neighborCount
									local newWeight = currentWeight * (1.0 - blendRatio) + neighborAvgWeight * blendRatio
									
									if newWeight > threshold then
									(
										append finalBones boneID
										append finalWeights newWeight
									)
								)
								
								-- 归一化权重
								if finalWeights.count > 0 then
								(
									local weightSum = 0.0
									for w in finalWeights do weightSum += w
									
									if weightSum > 0 then
									(
										for i = 1 to finalWeights.count do
											finalWeights[i] /= weightSum
									)
									
									-- 存储新权重
									newWeights[v] = #(finalBones, finalWeights)
								)
							)
						)
					)
					
					-- 批量应用新权重
					for v in vertsToProcess do
					(
						if newWeights[v] != undefined then
						(
							skinOps.ReplaceVertexWeights skinMod v newWeights[v][1] newWeights[v][2]
							vertexWeights[v] = newWeights[v]  -- 更新缓存
						)
					)
				)
				
				pb1.value = 100
				return true
			)
			
			-- 开始平滑处理
			pb1.value = 0
			
			-- 使用spinner控件的值作为迭代次数，0.01作为权重阈值
			local success = smoothSkinWeightsOptimized obj skinMod spn1.value 0.01
			
			-- 只刷新视图，不改变任何选择状态
			redrawViews()
			
			if success then
			(
				print "权重平滑完成！保持在当前骨骼选择状态"
			)
			else
			(
				print "权重平滑失败"
			)
		)
	)
	
	on btn3 pressed do
	(
		helpText = "使用说明：\n\n"
	    helpText += "1.一键分区的时候请在刚刚skin添加完骨骼后直接使用\n"
	    helpText += "2.一键分区是按照初始封套效果进行一定的修改的，所以不要动默认的封套\n"
	    helpText += "3.一键平滑选中点进行平滑效果即刻\n"
		helpText += "使用的时候如果有问题可以加Q群反馈\n"
	    helpText += "Q群:607416824\n" 
	    messageBox helpText title:"帮助信息"  
	)
)

-- 创建对话框
createDialog skinWeights