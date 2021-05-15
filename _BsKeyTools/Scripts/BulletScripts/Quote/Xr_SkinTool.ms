fn PPcross p1 p2 = (return p1.x*p2.y - p1.y*p2.x	) ----计算叉积  Cross 
fn PPdot  p1 p2 = (return p1.x*p2.x + p1.y*p2.y) ----计算点积 dot 
fn PPNum_dot  a b = ( return [a.x*b,a.y*b] ) 								-----数乘
fn disVerToLine a b  c =    ---c到直线ab的距离
( 
	return abs( (PPcross (c-a) (c-b))/(distance a b) )	
)
fn PPinter a b c d =     --直线ab和cd的交叉点
(
	s = PPcross (c-a) (d-a)
	ss = s+(PPcross (d-b) (c-b))
	return a+( PPNum_dot (b-a) (s/ss) )	
)
fn angelCmp a b  c = 
(	
	t1 = atan2 (a.y-c.y) (a.x-c.x)
	t2 = atan2 (b.y-c.y) (b.x-c.x)	
	if t1!=t2 then ( return t1<t2 )
	else ( return a.x-c.x<b.x-c.x )
)
fn multi ppp1 ppp2  ppp0 = ----计算叉积  Cross 
(
x1 = ppp1.x - ppp0.x + 0.0
y1 = ppp1.y - ppp0.y + 0.0
x2 = ppp2.x - ppp0.x + 0.0
y2 = ppp2.y - ppp0.y + 0.0	
return (x1*y2-x2*y1)	
)
-- 	multi [1,2] [2,3] [3,4]
fn grahanCmp p1 p2 baseP = 
(
if (PPcross (p1-baseP) (p2-baseP) )==0 then (return (distance p1 baseP)<(distance p2 baseP))
else (return  (PPcross (p1-baseP) (p2-baseP)>0) )	
)

fn GetVectorsAngle v1 v2 =
(theAngle = acos(dot (normalize v1) (normalize v2)))
	
fn yunGetvertsSkinOrPoly  =   ---获取选择的蒙皮或可编辑多边形点儿，输出值是普通数组例：#(293,294,570)
(
	modCheck = modpanel.getcurrentobject() 
	verts = #()
	if (classOf modCheck) == Skin then (for i = 1 to skinops.getnumbervertices modCheck do	(if (skinOps.IsVertexSelected modCheck i) == 1 do (append verts i	)  ))
	if (classOf modCheck) == Editable_Poly then (verts = (polyop.getVertSelection selection[1]) as array)
	return verts
)
fn yunSelvertsSkinOrPoly selVerts =   ---选择蒙皮或可编辑多边形点儿，输入值是普通数组例：#(293,294,570)
(
	modCheck = modpanel.getcurrentobject() 
	if (classOf modCheck) == Skin do (skinOps.SelectVertices modCheck selVerts;modCheck.effect = 0)
	if (classOf modCheck) == Editable_Poly do (selection[1].EditablePoly.SetSelection #Vertex (selVerts as BitArray))
	return (classOf modCheck)
)
	
fn yunSelInBoundingBox = -------------------------判断是否是在模型****粗略--------------------	
(	
	obj = selection
	yunRingSelBitArrat = #()
	yunRingSelInFirstCheck = #()
	yunRingSelInFirstCheck = #()
	for i=1 to (getNumVerts  obj[1]) do
	(
	vert_pos = in coordsys $yunLoopVertexSelFatherHiden (polyop.getVert obj[1] i)	- (in coordsys $yunLoopVertexSelFatherHiden $yunLoopVertexSel.pos)		
	if 	(distance vert_pos [0,0,0]) < $yunLoopVertexSel.radius  and vert_pos[3]> (-$yunLoopVertexSel.height) and vert_pos[3] < $yunLoopVertexSel.height/2 then
	-- if 	vert_pos[1]>vObj.min[1] and vert_pos[1] < vObj.max[1] and vert_pos[2]>vObj.min[2] and vert_pos[2] < vObj.max[2] and vert_pos[3]>vObj.min[3] and vert_pos[3] < vObj.max[3] then
	(append yunRingSelInFirstCheck i)	
	)
	yunSelvertsSkinOrPoly yunRingSelInFirstCheck
	return  yunRingSelInFirstCheck
)
-- 检查数组里某个元素出现的次数	
fn countOccurrences arr n x = 
(	res = 0
	for i=1 to n  do 
	(if x==arr[i] then 
	(res += 1))
	return res	
)
--判断并修复权重点儿
fn yunSkinFixOne vertOne = 
(
	
-- 	vertOne = 1199
	----------------------------------一轮扩选----------------------------------
		sk = modpanel.getcurrentobject() 
		skinOps.SelectVertices sk vertOne
		sk.effect = 0
		skinOps.growSelection sk
	vertsSecond = #()---阔选一圈后的权重点儿
	for i = 1 to skinops.getnumbervertices sk do
	(
		if (skinOps.IsVertexSelected sk i) == 1 then append vertsSecond i
	)
	---------------------------选择点骨骼列表与其他点骨骼列表对比------------------	
	weightCount = skinOps.GetVertexWeightCount sk vertOne
	boneEffect 	= #()  --一圈点儿里所有相关的骨骼
	for vb in vertsSecond do ---所有点循环
	( 
		weightCountAll = skinOps.GetVertexWeightCount sk vb
		for i = 1 to weightCountAll do	(append  boneEffect (skinOps.GetVertexWeightBoneID sk vb i)	)				
	)			
	boneEffectUniquet = makeUniqueArray  boneEffect	
	
	boneEffectOne = #() -- 获取选择点对应的权重骨骼
	for i = 1 to weightCount do
		(append  boneEffectOne (skinOps.GetVertexWeightBoneID sk vertOne i)	)			
	-- 单点里骨骼次数
	boneEffectUniquetNum = #()
	for i in boneEffectOne do
	(append  boneEffectUniquetNum (countOccurrences boneEffect boneEffect.count i))
	boneEffectCheckBone = sort boneEffectUniquetNum
		
-- 判断单点骨骼里是否有只影响   *  3  *  个以下点的骨骼，有怎判断未权重错误
	checkErrorState = false
	for i in boneEffectUniquetNum do
	(if i <= 3 then (checkErrorState = true))		
	
------===============================修复权重if开始============================
if checkErrorState then
(
		-- 九点里所有骨骼次数
		boneEffectUniquetNum_Nine = #()		
		for i in boneEffectUniquet do
		(append  boneEffectUniquetNum_Nine (countOccurrences boneEffect boneEffect.count i)	)
		
		-- 合并的数组，前是骨骼变号，后是骨骼出现次数
		boneEffectCombine_Nine = #()
		boneEffectCheckBone_Nine = #()		
		for i=1 to boneEffectUniquet.count do
			(
			ele = #(boneEffectUniquet[i],boneEffectUniquetNum_Nine[i])
			append  boneEffectCombine_Nine ele	
			append boneEffectCheckBone_Nine	boneEffectUniquetNum_Nine[i]
			)
		boneEffectCheckBone_Nine = sort boneEffectUniquetNum_Nine
			
-------------------修复权重取最多的四个骨骼，把当前骨骼在这四个骨骼上blend----------------			
	-- 冒泡排序
	for i=1 to boneEffectCombine_Nine.count do 
	(
		for j = 1 to boneEffectCombine_Nine.count-i do
		(
			if boneEffectCombine_Nine[j][2]<boneEffectCombine_Nine[j+1][2] then
			(
			vartemp = boneEffectCombine_Nine[j+1]
			boneEffectCombine_Nine[j+1] = boneEffectCombine_Nine[j]
			boneEffectCombine_Nine[j] = vartemp 
	-- 		print vartemp
			)
			
		)	
	)
	-----获取前2多出现的骨骼
	boneChoosen = #()
	for i=1 to 4 do 
	(
		append boneChoosen boneEffectCombine_Nine[i][1]
	)

	boneChoosen = makeUniqueArray boneChoosen
	skinOps.SelectVertices sk #{vertOne}	
	skinOps.SelectBone sk boneChoosen[1] 
	skinOps.setWeight sk 1
	skinOps.RemoveZeroWeights sk
	sk.effect = 0
-- 	先给第一个骨骼1权重在移除所有0权重为下边做准备
	for i in boneChoosen do
		(
		skinOps.SelectBone sk i
		skinOps.setWeight sk 0.5		
		)
		
	choosenWeight = #()----算出平均权重备料
	for b=1 to boneChoosen.count do --每根骨骼
	( 
		append choosenWeight #(#(boneChoosen[b]),#())
		for vb in vertsSecond do  ---每个点
		(		
			weightCountAll = skinOps.GetVertexWeightCount sk  vb
				
			for i = 1 to weightCountAll do  --骨骼列表
			(
				BoneandweightCC = #() --单元素
				if (skinOps.GetVertexWeightBoneID sk vb i)==boneChoosen[b] then 	 --是当前骨骼号	
				(	
					append 	choosenWeight[b][2] (skinOps.GetVertexWeight  sk vb i)						
				)
			)	
		)
	)
  
	for i=1 to choosenWeight.count do
	(
		-- 	求平均权重
		sumVal = 0; for val in choosenWeight[i][2] do ( sumVal += val )
		weightAverage = sumVal/choosenWeight[i][2].count
		skinOps.SelectBone sk choosenWeight[i][1][1]
		skinOps.setWeight sk weightAverage			
	)
)--修复权重if的结尾不能删除
	
return checkErrorState

) ---fn 的结尾
fn getVertexNormal vert = ----法线
(
	sel = selection[1]
	vertFaces = polyOp.getFacesUsingVert sel vert
	tNormal = [0,0,0]; for i in vertFaces do tNormal += polyOp.getFaceNormal sel i
-- 	t01 = tNormal / vertFaces.numberSet
	return normalize (tNormal / vertFaces.numberSet)
)
fn getFourDirVert vert =  ---依次返回右左上下的最近点儿，相对视图
(
		obj = selection[1] --get selected object
		PVAll_left = #()
		PVAll_right= #()
		PVAll_up = #()
		PVAll_down = #()
		combinedArray = #()  --点和度数
	
		polyVertexOne = vert	
		Ori_Pos = polyOp.getVert obj polyVertexOne 	
		normalVec = getVertexNormal polyVertexOne --法向量	
	
		edges_A = polyop.getEdgesUsingVert obj (#(polyVertexOne) as BitArray)
		polyVertexFive = polyop.getVertsUsingEdge obj edges_A
		polyVertexFour = deleteItem  polyVertexFive  polyVertexOne --四点 可能多	
		
		-- 	角度算法	获取相对   垂直于点法线的平面的 单位 角度
		for pt in (polyVertexFour as array) do 
		(
	-- 		视图上方向
			CurrentViewMatrix = inverse(viewport.getTM()) 
			upVec = CurrentViewMatrix.row2					
			PV_Pos = polyOp.getVert obj pt  ---点位置向量		
			PV_Pos = PV_Pos - Ori_Pos  ----计算角度物料	
				
			--法线垂直平面上的投影		
			finalNormal = PV_Pos - normalVec * dot (normalize  PV_Pos) (normalize normalVec) / dot(normalize normalVec) (normalize normalVec)
			
			upVecPP = upVec - normalVec * dot (normalize  upVec) (normalize normalVec) / dot(normalize normalVec) (normalize normalVec)
			upVecPP = normalize (upVecPP)
				
	-----旋转得到z单位向量					
			XVecPP =  upVecPP*cos(-90)+	(cross normalVec upVecPP)*sin(-90)
			XVecPP = normalize(XVecPP)		
	
		ZZZ = (dot finalNormal upVecPP)/length(upVecPP) ----在向量上的投影 
		XXX = (dot finalNormal XVecPP)/length(XVecPP) ----在向量上的投影
		angleCal = atan2 XXX ZZZ	
		append combinedArray #(pt,angleCal)
		)
			
	-- 右边	
		angleGoalR = 90
		currR = combinedArray[1][2]	 --第一个ied度数
		currvertR = combinedArray[1][1]	--第一个的点序号
		for i in combinedArray do
			(
			if 	abs(angleGoalR - i[2])<abs(angleGoalR - currR) then
				(
				currR =i[2]
				currvertR = i[1]			
				)
			)
		append PVAll_right currvertR
	-- 左边		
		angleGoalL = -90
		currL = combinedArray[1][2]	
		currvertL =  combinedArray[1][1]		
		for i in combinedArray do
			(
			if 	abs(angleGoalL - i[2])<abs(angleGoalL - currL) then
				(
				currL =i[2]
				currvertL = i[1]			
				)
			)
		append PVAll_left currvertL
	-- 上边		
		angleGoalUp = 0
		currUp = combinedArray[1][2]	
		currvertUp =  combinedArray[1][1]	
		
		for i in combinedArray do
			(
			if 	abs(angleGoalUp - i[2])<abs(angleGoalUp - currUp) then
				(
				currUp =i[2]
				currvertUp = i[1]		
				)
				
			)
		append PVAll_up currvertUp
-- 下边		
	angleGoalDown = 180  
	currDown = combinedArray[1][2]	
	currvertDown =  combinedArray[1][1]	
	
-- 		i = combinedArray[3]
	for i in combinedArray do
		(
		if angleGoalDown<=-90 and angleGoalDown>=-180 then
		(
		if  abs( i[2] + angleGoalDown)<abs(currDown - angleGoalDown ) then
			(
			currDown =i[2]
			currvertDown = i[1]	
-- 		    print "下边"
-- 			print (angleGoalDown - i[2])
-- 			print currvertDown
			)	
			
		)
		else if 	abs(angleGoalDown - i[2])<abs(angleGoalDown - currDown) then
			(
			currDown =i[2]
			currvertDown = i[1]	
-- 		    print "下边"
-- 			print (angleGoalDown - i[2])
-- 			print currvertDown
			)
		)
	append PVAll_down currvertDown	
-- 		obj.EditablePoly.SetSelection #Vertex (#(polyVertexOne) as BitArray)			
		return #(PVAll_right[1],PVAll_left[1],PVAll_up[1],PVAll_down[1])	
	
)
fn setFourDirVert selDirection =   ---移动选择点儿
(
		
	sk = modpanel.getcurrentobject() 
	if sk as string == "Skin:Skin" then
	(
		-- 蒙皮点模式
		obj = selection[1] --get selected object
		PVselvert = #()
			for i = 1 to skinops.getnumbervertices sk do
			(
				if (skinOps.IsVertexSelected sk i) == 1 then append PVselvert i
			)----获取选择的蒙皮点id
		-- print PVselvert
		selVertexsArray = #{}
		for vert in (PVselvert as array) do
		(
			if selDirection =="right" then (append selVertexsArray (getFourDirVert vert)[1])
			if selDirection =="left" then (append selVertexsArray (getFourDirVert vert)[2])
			if selDirection =="up" then (append selVertexsArray (getFourDirVert vert)[3])
			if selDirection =="down" then (append selVertexsArray (getFourDirVert vert)[4])
			
-- 			append selVertexsArray vert  ---加选用
		)
		skinOps.SelectVertices sk selVertexsArray;	sk.effect = 0
	)	
	
	else if sk as string == "Editable Poly" then
	(
		-- poly模式
		obj = selection[1] --get selected object
		PVselvert = polyop.getVertSelection obj
		selVertexsArray = #{}
		-- 所选点循环

		for vert in (PVselvert as array) do
		(
			if selDirection =="right" then (append selVertexsArray (getFourDirVert vert)[1])
			if selDirection =="left" then (append selVertexsArray (getFourDirVert vert)[2])
			if selDirection =="up" then (append selVertexsArray (getFourDirVert vert)[3])
			if selDirection =="down" then (append selVertexsArray (getFourDirVert vert)[4])			
-- 			append selVertexsArray vert  ---加选用
		)
		
		
		obj.EditablePoly.SetSelection #Vertex selVertexsArray
	)
	else (messageBox "不是Poly或Skin")
)
fn setFourDirVert_add selDirection =   --加选点儿
(
	sk = modpanel.getcurrentobject() 
	if sk as string == "Skin:Skin" then
	(
		-- 蒙皮点模式
		obj = selection[1] --get selected object
		PVselvert = #()
			for i = 1 to skinops.getnumbervertices sk do
			(
				if (skinOps.IsVertexSelected sk i) == 1 then append PVselvert i
			)----获取选择的蒙皮点id
		-- print PVselvert
		selVertexsArray = #{}
		for vert in (PVselvert as array) do
		(
			if selDirection =="right" then (append selVertexsArray (getFourDirVert vert)[1])
			if selDirection =="left" then (append selVertexsArray (getFourDirVert vert)[2])
			if selDirection =="up" then (append selVertexsArray (getFourDirVert vert)[3])
			if selDirection =="down" then (append selVertexsArray (getFourDirVert vert)[4])
			
			append selVertexsArray vert  ---加选用
		)
		skinOps.SelectVertices sk selVertexsArray;	sk.effect = 0
	)	
	
	else if sk as string == "Editable Poly" then
	(
		-- poly模式
		obj = selection[1] --get selected object
		PVselvert = polyop.getVertSelection obj
		selVertexsArray = #{}
		-- 所选点循环

		for vert in (PVselvert as array) do
		(
			if selDirection =="right" then (append selVertexsArray (getFourDirVert vert)[1])
			if selDirection =="left" then (append selVertexsArray (getFourDirVert vert)[2])
			if selDirection =="up" then (append selVertexsArray (getFourDirVert vert)[3])
			if selDirection =="down" then (append selVertexsArray (getFourDirVert vert)[4])
			
			append selVertexsArray vert  ---加选用
		)
		obj.EditablePoly.SetSelection #Vertex selVertexsArray
	)
	else (messageBox "不是Poly或Skin")
)
fn yunSkinOther_selRing =
(	
	obj = selection[1] --get selected object
	-- poly模式
	PVselvert = #{155}
	PVselvert = polyop.getVertSelection obj
	PVAll_left = #()
	PVAll_right= #()
	PVAll_up = #()
	PVAll_down = #()
	combinedArray = #()  --点和度数		
	clearListener()
	seledVertexs = (polyop.getVertSelection obj) as array  -----当前选择的点儿
	polyVertexOne = vert =(seledVertexs[1])	
	Ori_Pos = polyOp.getVert obj polyVertexOne 	
	normalVec = getVertexNormal polyVertexOne --法向量	

	if seledVertexs.count==1 then (nearByert = getFourDirVert polyVertexOne;lastVertexPos = polyOp.getVert obj nearByert[1])
	else (lastVertexPos = polyOp.getVert obj (seledVertexs[seledVertexs.count]))	
		
	if (getNodeByName "yunLoopVertexSel")== undefined then 
	(
		p2plane  = Cylinder smooth:on heightsegs:1 capsegs:1 height:1
		p3plane  = Plane()
			
		p2plane.parent = p3plane
		
		p2plane.name = "yunLoopVertexSel"
		p3plane.isHidden = true	
		p3plane.name = "yunLoopVertexSelFatherHiden"
	-- 		中心重置
		mapped fn center_pivot o =(o.pivot = o.center)  undo on (center_pivot $yunLoopVertexSel)	
		in coordsys parent $yunLoopVertexSel.pos = [0,0,0]
		p2plane.xray = on
	)
	g = Ori_Pos+normalVec*20
	r = Ori_Pos   ----中心在这里
	b = lastVertexPos

	v1 = normalize (g - r)
	v3 = normalize (cross v1 (normalize (b - r)))
	v2 = normalize (cross v3 v1)	
	$yunLoopVertexSelFatherHiden.transform = matrix3 v1 v2 v3 r as matrix3

	$yunLoopVertexSel.radius = yunSkinOtherWin.yunSkinOther_selRing_H.value
	$yunLoopVertexSel.height = yunSkinOtherWin.yunSkinOther_selRing_V.value
	in coordsys parent $yunLoopVertexSel.pos = [yunSkinOtherWin.yunSkinOther_selRing_tx.value,yunSkinOtherWin.yunSkinOther_selRing_ty.value,yunSkinOtherWin.yunSkinOther_selRing_tz.value]
	in coordsys parent $yunLoopVertexSel.rotation = eulerAngles  yunSkinOtherWin.yunSkinOther_selRing_rx.value  yunSkinOtherWin.yunSkinOther_selRing_ry.value  yunSkinOtherWin.yunSkinOther_selRing_rz.value

)	
try(closerolloutfloater  Xr_SkinTools_UI )catch()	


global yunSkinTools_mode 
yunSkinTools_mode  = 1

rollout yunSkinToolWin "蒙皮修复" 
(
	
	groupBox 'grp1' "粗粗修" pos:[1,3] width:195 height:50 align:#left
	button 'yunSkinFix_btn' "粗修" pos:[15,23] width:74 height:25 align:#left	
	button 'yunSkinTool_selfBlend_btn' "自混合权重" pos:[115,23] width:70 height:25 align:#left
	
	groupBox 'grp3' "粗修" pos:[1,62] width:195 height:196 align:#left	
	checkbox 'yunSkinTool_moveVertSMode' "移选择" pos:[10,109] width:60 height:30 align:#left checked:true 
	button 'yunSkinTool_left_btn' "left" pos:[10,152] width:60 height:30 align:#left
	button 'yunSkinTool_deleteZero_btn' "去0权重" pos:[10,206] width:60 height:30 align:#left
	
	
	
	button 'yunSkinTool_up_btn' "up" pos:[73,96] width:55 height:30 align:#left
	button 'yunSkinTool_selMostBone_btn' "选骨" pos:[73,152] width:55 height:30 align:#left  tooltip:"选取对当前点影响最大的骨骼"	
	button 'yunSkinTool_down_btn' "down" pos:[73,206] width:55 height:30 align:#left
	
	checkbox 'yunSkinTool_addVertSMode' "加选择" pos:[133,109] width:60 height:30 align:#left checked:false 
	button 'yunSkinTool_right_btn' "right" pos:[133,152] width:60 height:30 align:#left
	checkbox 'yunSkinTool_copyVertWeightMode' "权重copy" pos:[133,210] width:60 height:30 align:#left checked:false 
	

	on yunSkinTool_deleteZero_btn pressed do
		(
		sk = modpanel.getcurrentobject() 
		skinOps.RemoveZeroWeights sk
		---移除所选点影响0权重骨骼	
		)
	on yunSkinTool_selMostBone_btn pressed do
		(			  
			undo on
			(
				sk = modpanel.getcurrentobject() 
				vertsSel = #()
				for i = 1 to skinops.getnumbervertices sk do
				(
					if (skinOps.IsVertexSelected sk i) == 1 then append vertsSel i
				)----获取选择的蒙皮点id
				boneIds = #()
		-- 		i = vertsSel[1]
				for i in vertsSel  do  
					(
						weightCount = skinOps.GetVertexWeightCount sk  i
						-- 	获取骨骼列表个数
						
						for vb = 1 to weightCount do 
						(
							if (skinOps.GetVertexWeight sk i vb) > 0.5 then
							( append boneIds (skinOps.GetVertexWeightBoneID sk i vb) )
						)
							
					)
					
				boneIdsUnique = makeUniqueArray boneIds
				i = boneIdsUnique[3]
				count = 0
				boneMost = -1			
				for i in 	boneIdsUnique do
				(					
					if (findItem boneIdsUnique i)>count then (count = (findItem boneIdsUnique i); boneMost = i)
				)
				
				if boneMost!=-1 then (skinOps.SelectBone sk boneMost)
				
			)
		)
	
	on yunSkinTool_selfBlend_btn pressed do
		(
			sk = modpanel.getcurrentobject() 
			verts = #()
				for i = 1 to skinops.getnumbervertices sk do
				(
					if (skinOps.IsVertexSelected sk i) == 1 then append verts i
				)----获取选择的蒙皮点id
			boneSel = skinOps.GetSelectedBone sk
				
			undo on 
			(	
			if verts.count ==1 then 
			(
				weightCount = skinOps.GetVertexWeightCount sk  verts[1]
				-- 	获取骨骼列表个数
				for vb = 1 to weightCount do
				(
				boneId = skinOps.GetVertexWeightBoneID sk verts[1] vb
				skinOps.SelectBone sk boneId	
				skinOps.blendSelected sk
				)
				for vb = 1 to weightCount do
				(
				boneId = skinOps.GetVertexWeightBoneID sk verts[1] vb
				skinOps.SelectBone sk boneId	
				skinOps.blendSelected sk
				)
				for vb = 1 to weightCount do
				(
				boneId = skinOps.GetVertexWeightBoneID sk verts[1] vb
				skinOps.SelectBone sk boneId	
				skinOps.blendSelected sk
				)
			)
			else
			(messageBox  "只能选择一个点~~哦~~")
			skinOps.SelectVertices sk verts
			skinOps.SelectBone sk boneSel
			)

		)
	on yunSkinFix_btn pressed do
		(
		-- ---=======================运行部分=========
		sk = modpanel.getcurrentobject() 
		vertsSel = #()
		for i = 1 to skinops.getnumbervertices sk do
		(
			if (skinOps.IsVertexSelected sk i) == 1 then append vertsSel i
		)----获取选择的蒙皮点id
		for i in vertsSel do
		(
		yunSkinFixOne i
		)
		skinOps.SelectVertices sk vertsSel
		sk.effect = 0			
		)
	

	on yunSkinTool_moveVertSMode changed yunSkinTool_moveVertSMode_State do
		(
			if yunSkinTool_moveVertSMode_State == true then				 
			(
				yunSkinTools_mode = 1 --移动选择				
				yunSkinTool_addVertSMode.checked = false
				yunSkinToolWin.yunSkinTool_addVertSMode.checked  =false
				yunSkinTool_copyVertWeightMode.checked = false
			)
		)
	on yunSkinTool_copyVertWeightMode changed yunSkinTool_copyVertWeightMode_State do
		(
			if yunSkinTool_copyVertWeightMode_State == true then				 
			(
				yunSkinTools_mode = 2 --权重copy				
				yunSkinTool_moveVertSMode.checked = false
				yunSkinTool_addVertSMode.checked = false
			)
		)
	on yunSkinTool_addVertSMode changed yunSkinTool_addVertSMode_State do
		(
			if yunSkinTool_addVertSMode_State == true then				 
			(
				yunSkinTools_mode = 3 --加选选择				
				yunSkinTool_moveVertSMode.checked = false
				yunSkinTool_copyVertWeightMode.checked = false
			)
		)

	on yunSkinTool_right_btn pressed  do
		(
			case yunSkinTools_mode of --模式判断  1是移动选择；2是复制蒙皮；3是加选；
			(	
			1: (setFourDirVert "right" 	)	
			2: (

				sk = modpanel.getcurrentobject() 
				verts = #()
					for i = 1 to skinops.getnumbervertices sk do
					(
						if (skinOps.IsVertexSelected sk i) == 1 then append verts i
					)----获取选择的蒙皮点id
				if verts.count == 1 then
				(	
				skinOps.SelectVertices sk #{(getFourDirVert verts[1] )[1]}	  ---方向
				skinOps.copyWeights sk 
				skinOps.copyWeights sk
				skinOps.SelectVertices sk #{verts[1]}
				skinOps.pasteWeights sk
				sk.effect = 0
				)
				else( messageBox "请只选一个点~~儿")

				)
			3: ( setFourDirVert_add "right" 	)
			)
		
		)
			
	on yunSkinTool_left_btn pressed  do
		(
			case yunSkinTools_mode of --模式判断  1是移动选择；2是复制蒙皮；3是加选；
			(	
			1: (setFourDirVert "left" 	)	
			2: 
			(

				sk = modpanel.getcurrentobject() 
				verts = #()
					for i = 1 to skinops.getnumbervertices sk do
					(
						if (skinOps.IsVertexSelected sk i) == 1 then append verts i
					)----获取选择的蒙皮点id
				if verts.count == 1 then
				(	
				skinOps.SelectVertices sk #{(getFourDirVert verts[1] )[2]}	  ---方向
				skinOps.copyWeights sk 
				skinOps.copyWeights sk
				skinOps.SelectVertices sk #{verts[1]}
				skinOps.pasteWeights sk
				sk.effect = 0
				)
				else( messageBox "请只选一个点~~儿")
			)
			
			3: (setFourDirVert_add "left" 	)
			)
			
		)
	on yunSkinTool_up_btn pressed  do
		(
			case yunSkinTools_mode of --模式判断  1是移动选择；2是复制蒙皮；3是加选；
			(	
			1: (setFourDirVert "up" 	)	
			2: 
			(

				sk = modpanel.getcurrentobject() 
				verts = #()
					for i = 1 to skinops.getnumbervertices sk do
					(
						if (skinOps.IsVertexSelected sk i) == 1 then append verts i
					)----获取选择的蒙皮点id
				if verts.count == 1 then
				(	
				skinOps.SelectVertices sk #{(getFourDirVert verts[1] )[3]}	  ---方向
				skinOps.copyWeights sk 
				skinOps.copyWeights sk
				skinOps.SelectVertices sk #{verts[1]}
				skinOps.pasteWeights sk
				sk.effect = 0
				)
				else( messageBox "请只选一个点~~儿")
			)
			3: (setFourDirVert_add "up" 	)
			)			
		
		)
	on yunSkinTool_down_btn pressed  do
		(
			case yunSkinTools_mode of --模式判断  1是移动选择；2是复制蒙皮；3是加选；
			(	
			1: (setFourDirVert "down" 	)	
			2: 
			(

				sk = modpanel.getcurrentobject() 
				verts = #()
					for i = 1 to skinops.getnumbervertices sk do
					(
						if (skinOps.IsVertexSelected sk i) == 1 then append verts i
					)----获取选择的蒙皮点id
				if verts.count == 1 then
				(	
				skinOps.SelectVertices sk #{(getFourDirVert verts[1] )[4]}	  ---方向
				skinOps.copyWeights sk 
				skinOps.copyWeights sk
				skinOps.SelectVertices sk #{verts[1]}
				skinOps.pasteWeights sk
				sk.effect = 0
				)
				else( messageBox "请只选一个点~~儿")
			)
			3: (setFourDirVert_add "down" 	)
			)		
		
		)		
	
		
		
)
rollout yunSkinOtherWin "其他.." 
(
button yunSkinOther_exportBoneList "导出骨骼列表" pos:[10,10] width:80 height:24 tooltip:"导出蒙皮的骨骼列表" 	
button yunSkinOther_importBoneList "导入骨骼列表" pos:[100,10] width:80 height:24 tooltip:"导ri蒙皮的骨骼列表"
	
groupBox yunSkinOther_grp1 "按权重范围选点" pos:[0,45] width:195 height:80 align:#left		
spinner yunSkinOther_minWeight "最小:" pos:[1,71] width:150 height:16 range:[0,1,0.001] scale:0.001 type:#float 
button yunSkinOther_minWeight_btn "±.1" pos:[162,71] width:22 height:16 	
	
spinner yunSkinOther_MaxWeight "最大:" pos:[1,95] width:150 height:16 range:[0,1,1] scale:0.001 type:#float \
button yunSkinOther_maxWeight_btn "±.1" pos:[162,95] width:22 height:16 	
	
-- button yunSkinOther_selWeightRangeVertex "选点" pos:[110,64] width:80 height:45 tooltip:"选"	
	
button yunSkinOther_crowSelVert_small "向上选" pos:[5,130] width:80 height:25 tooltip:"向小扩选选"	
button yunSkinOther_crowSelVert_big "向下选" pos:[110,130] width:80 height:25 tooltip:"向大扩选选"
button yunSkinOther_GrowSelVert_up "向上扩选" pos:[5,165] width:80 height:25 tooltip:"向小扩选选"	
button yunSkinOther_GrowSelVert_down "向下扩选" pos:[110,165] width:80 height:25 tooltip:"向大扩选选"

	
groupBox yunSkinOther_selRing "选环线" pos:[0,200] width:195 height:250 align:#left	
button yunSkinOther_selRing_start "开始环线选择   #点数:" pos:[15,220] width:120 height:25 tooltip:""	
label yunSkinOther_vertsCount "0" pos:[150,228] width:25 height:25
spinner yunSkinOther_selRing_H "横:" pos:[20,256] width:150 height:16 range:[0,99999,15] scale:0.01 type:#worldunits  
spinner yunSkinOther_selRing_V "竖:" pos:[20,280] width:150 height:16 range:[0,99999,2] scale:0.01 type:#worldunits  


spinner yunSkinOther_selRing_tx "tx:" pos:[20,315] width:60 height:16 range:[-9999,9999,0] scale:0.1 type:#worldunits  
spinner yunSkinOther_selRing_ty "ty:" pos:[20,340] width:60 height:16 range:[-9999,9999,0] scale:0.1 type:#worldunits  
spinner yunSkinOther_selRing_tz "tz:" pos:[20,365] width:60 height:16 range:[-9999,9999,0] scale:0.1 type:#worldunits  
		
spinner yunSkinOther_selRing_rx "rx:" pos:[95,315] width:60 height:16 range:[-9999,9999,0] scale:0.1 type:#float 
spinner yunSkinOther_selRing_ry "ry:" pos:[95,340] width:60 height:16 range:[-9999,9999,0] scale:0.1 type:#float 
spinner yunSkinOther_selRing_rz "rz:" pos:[95,365] width:60 height:16 range:[-9999,9999,0] scale:0.1 type:#float 	

button yunSkinOther_selRing_btn_rx "±90" pos:[162,315] width:22 height:16 
button yunSkinOther_selRing_btn_ry "±90" pos:[162,340] width:22 height:16  
button yunSkinOther_selRing_btn_rz "±90" pos:[162,365] width:22 height:16 
button yunSkinOther_selRing_end "结束环线选择" pos:[20,394] width:160 height:25 tooltip:""	

on yunSkinOther_exportBoneList pressed do
	(
		------导出骨骼列表
		sk = modpanel.getcurrentobject() 
		obj = getCurrentSelection()

		delIniSetting "C:\Maxscript_XrTools\Conf\\boneList.ini" ("任意模型")
		boneCount = skinOps.GetNumberBones sk
		--获取受影响的骨骼的个数
		for i = 1 to  boneCount do 
		(
		boneId = skinOps.GetBoneIDByListID sk i		
		boneName = skinOps.GetBoneName  sk boneId 1	
		setINISetting "C:\Maxscript_XrTools\Conf\\boneList.ini" ("任意模型") (i as string) (boneName)
		)	
	)
on yunSkinOther_importBoneList pressed do
	(		
		------导入骨骼列表
		obj = getCurrentSelection()
		hasSkin = false
		for i = 1 to obj[1].modifiers.count do
		(
			if ((classOf obj[1].modifiers[i]) == Skin) then
			( hasSkin = true)	
		)	

		if hasSkin==false then (modPanel.addModToSelection (Skin ()) ui:on	)			
		sk = modpanel.getcurrentobject() 	
		boneCountNew = getINISetting "C:\Maxscript_XrTools\Conf\\boneList.ini" ("任意模型") 
		for i in  boneCountNew do 
		(
		getBone = getINISetting "C:\Maxscript_XrTools\Conf\\boneList.ini" ("任意模型")  (i)
		getBoneObj = getNodeByName 	getBone
		skinOps.addBone sk getBoneObj 1	
		)	
	)   
on yunSkinOther_crowSelVert_small pressed do
	(		
	undo on
	(
		Xr_SkinTools_UI.rollouts[5].yunSkinOther_selRing_start.pressed()	
		sk = modpanel.getcurrentobject() 
		verts = #()
			for i = 1 to skinops.getnumbervertices sk do
			(
				if (skinOps.IsVertexSelected sk i) == 1 then append verts i
			)----获取选择的蒙皮点id	
		skinOps.growSelection sk	
			vertsGrowed = #()
			for i = 1 to skinops.getnumbervertices sk do
			(
				if (skinOps.IsVertexSelected sk i) == 1 then append vertsGrowed i
			)
			
		for j = 1 to verts.count do
			while (index = (findItem vertsGrowed verts[j])) != 0 do
				(deleteItem vertsGrowed index)
		skinOps.SelectVertices sk vertsGrowed
		$.modifiers[#Skin].effect = 0		
		---扩选结束		
			verts = #()
			for i = 1 to skinops.getnumbervertices sk do (if (skinOps.IsVertexSelected sk i) == 1 then append verts i)----获取选择的蒙皮点id		
			vertsUp = #()
			vertsDown = #()
		-- 	i = verts[1]
			for i in verts do
			(
			vert_pos = in coordsys $yunLoopVertexSelFatherHiden (polyop.getVert selection[1] i)	- (in coordsys $yunLoopVertexSelFatherHiden $yunLoopVertexSel.pos)		
			if 	vert_pos[3]> 0  then
			(append vertsUp i)	
			else (append vertsDown i)
			)
			yunSelvertsSkinOrPoly vertsUp	
		-- 	yunSelvertsSkinOrPoly vertsDown	
			if (getNodeByName "yunLoopVertexSelFatherHiden")!=undefined do (delete (getNodeByName "yunLoopVertexSelFatherHiden"))
			if (getNodeByName "yunLoopVertexSel")!=undefined do (delete (getNodeByName "yunLoopVertexSel"))
	)
	)
on yunSkinOther_crowSelVert_big pressed do
	(
	undo on
	(
		Xr_SkinTools_UI.rollouts[5].yunSkinOther_selRing_start.pressed()	
		sk = modpanel.getcurrentobject() 
		verts = #()
			for i = 1 to skinops.getnumbervertices sk do
			(
				if (skinOps.IsVertexSelected sk i) == 1 then append verts i
			)----获取选择的蒙皮点id	
		skinOps.growSelection sk	
			vertsGrowed = #()
			for i = 1 to skinops.getnumbervertices sk do
			(
				if (skinOps.IsVertexSelected sk i) == 1 then append vertsGrowed i
			)
			
		for j = 1 to verts.count do
			while (index = (findItem vertsGrowed verts[j])) != 0 do
				(deleteItem vertsGrowed index)
		skinOps.SelectVertices sk vertsGrowed
		$.modifiers[#Skin].effect = 0		
		---扩选结束		
			verts = #()
			for i = 1 to skinops.getnumbervertices sk do (if (skinOps.IsVertexSelected sk i) == 1 then append verts i)----获取选择的蒙皮点id		
			vertsUp = #()
			vertsDown = #()
		-- 	i = verts[1]
			for i in verts do
			(
			vert_pos = in coordsys $yunLoopVertexSelFatherHiden (polyop.getVert selection[1] i)	- (in coordsys $yunLoopVertexSelFatherHiden $yunLoopVertexSel.pos)		
			if 	vert_pos[3]> 0  then
			(append vertsUp i)	
			else (append vertsDown i)
			)
		-- 	yunSelvertsSkinOrPoly vertsUp	
			yunSelvertsSkinOrPoly vertsDown	
			if (getNodeByName "yunLoopVertexSelFatherHiden")!=undefined do (delete (getNodeByName "yunLoopVertexSelFatherHiden"))
			if (getNodeByName "yunLoopVertexSel")!=undefined do (delete (getNodeByName "yunLoopVertexSel"))
	)
	)
on yunSkinOther_GrowSelVert_up pressed do
	(
	undo on
	(
		Xr_SkinTools_UI.rollouts[5].yunSkinOther_selRing_start.pressed()	
		sk = modpanel.getcurrentobject() 
		vertsBefore = #()
			for i = 1 to skinops.getnumbervertices sk do
			(
				if (skinOps.IsVertexSelected sk i) == 1 then append vertsBefore i
			)----获取选择的蒙皮点id	
		skinOps.growSelection sk	
			vertsGrowed = #()
			for i = 1 to skinops.getnumbervertices sk do
			(
				if (skinOps.IsVertexSelected sk i) == 1 then append vertsGrowed i
			)
			
		for j = 1 to vertsBefore.count do
			while (index = (findItem vertsGrowed vertsBefore[j])) != 0 do
				(deleteItem vertsGrowed index)
		skinOps.SelectVertices sk vertsGrowed
		$.modifiers[#Skin].effect = 0		
		---扩选结束		
			verts = #()
			for i = 1 to skinops.getnumbervertices sk do (if (skinOps.IsVertexSelected sk i) == 1 then append verts i)----获取选择的蒙皮点id		
			vertsUp = #()
			vertsDown = #()
		-- 	i = verts[1]
			for i in verts do
			(
			vert_pos = in coordsys $yunLoopVertexSelFatherHiden (polyop.getVert selection[1] i)	- (in coordsys $yunLoopVertexSelFatherHiden $yunLoopVertexSel.pos)		
			if 	vert_pos[3]> 0  then
			(append vertsUp i)	
			else (append vertsDown i)
			)
			join vertsUp vertsBefore
			yunSelvertsSkinOrPoly vertsUp	
		-- 	yunSelvertsSkinOrPoly vertsDown	
			if (getNodeByName "yunLoopVertexSelFatherHiden")!=undefined do (delete (getNodeByName "yunLoopVertexSelFatherHiden"))
			if (getNodeByName "yunLoopVertexSel")!=undefined do (delete (getNodeByName "yunLoopVertexSel"))		
	)
	)
	
on yunSkinOther_GrowSelVert_down pressed do
	(
		undo on
		(
		Xr_SkinTools_UI.rollouts[5].yunSkinOther_selRing_start.pressed()	
		sk = modpanel.getcurrentobject() 
		vertsBefore = #()
			for i = 1 to skinops.getnumbervertices sk do
			(
				if (skinOps.IsVertexSelected sk i) == 1 then append vertsBefore i
			)----获取选择的蒙皮点id	
		skinOps.growSelection sk	
			vertsGrowed = #()
			for i = 1 to skinops.getnumbervertices sk do
			(
				if (skinOps.IsVertexSelected sk i) == 1 then append vertsGrowed i
			)
			
		for j = 1 to vertsBefore.count do
			while (index = (findItem vertsGrowed vertsBefore[j])) != 0 do
				(deleteItem vertsGrowed index)
		skinOps.SelectVertices sk vertsGrowed
		$.modifiers[#Skin].effect = 0		
		---扩选结束		
			verts = #()
			for i = 1 to skinops.getnumbervertices sk do (if (skinOps.IsVertexSelected sk i) == 1 then append verts i)----获取选择的蒙皮点id		
			vertsUp = #()
			vertsDown = #()
		-- 	i = verts[1]
			for i in verts do
			(
			vert_pos = in coordsys $yunLoopVertexSelFatherHiden (polyop.getVert selection[1] i)	- (in coordsys $yunLoopVertexSelFatherHiden $yunLoopVertexSel.pos)		
			if 	vert_pos[3]> 0  then
			(append vertsUp i)	
			else (append vertsDown i)
			)
			join vertsDown vertsBefore
-- 			yunSelvertsSkinOrPoly vertsUp	
			yunSelvertsSkinOrPoly vertsDown	
			if (getNodeByName "yunLoopVertexSelFatherHiden")!=undefined do (delete (getNodeByName "yunLoopVertexSelFatherHiden"))
			if (getNodeByName "yunLoopVertexSel")!=undefined do (delete (getNodeByName "yunLoopVertexSel"))		
		)
	)
-- 	************
on yunSkinOther_minWeight changed val do 
	(
		weightLimitMin = yunSkinOtherWin.yunSkinOther_minWeight.value
		weightLimitMax = yunSkinOtherWin.yunSkinOther_maxWeight.value	
		-- get the skin
		sk = $.modifiers[#Skin]	  
		boneSel = skinOps.GetSelectedBone sk
		-- skinOps.GetBoneName sk boneSel 1
		verts = #()
			for i = 1 to skinops.getnumbervertices sk do	(append verts i	)
			vertsNew = #()
			boneWeight = #()
			for vb in verts do ---所有点循环
			( 
				weightCountAll = skinOps.GetVertexWeightCount sk vb
				for i = 1 to weightCountAll do				
				(	
					if (skinOps.GetVertexWeightBoneID sk vb i) == boneSel then	
					(
						if (skinOps.GetVertexWeight sk vb i) >= weightLimitMin and (skinOps.GetVertexWeight sk vb i) <= weightLimitMax then
						(
						append  boneWeight (skinOps.GetVertexWeight  sk vb i)	
						append  vertsNew vb
						)
					)
				)				
			)	
		skinOps.SelectVertices sk vertsNew		
		sk.effect = 0
		yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string		
	)	
	
on yunSkinOther_minWeight_btn pressed  do  ---加1
	(
	yunSkinOther_minWeight.value=yunSkinOther_minWeight.value+0.1
	weightLimitMin = yunSkinOtherWin.yunSkinOther_minWeight.value
		weightLimitMax = yunSkinOtherWin.yunSkinOther_maxWeight.value	
		-- get the skin
		sk = $.modifiers[#Skin]	  
		boneSel = skinOps.GetSelectedBone sk
		-- skinOps.GetBoneName sk boneSel 1
		verts = #()
			for i = 1 to skinops.getnumbervertices sk do	(append verts i	)
			vertsNew = #()
			boneWeight = #()
			for vb in verts do ---所有点循环
			( 
				weightCountAll = skinOps.GetVertexWeightCount sk vb
				for i = 1 to weightCountAll do				
				(	
					if (skinOps.GetVertexWeightBoneID sk vb i) == boneSel then	
					(
						if (skinOps.GetVertexWeight sk vb i) >= weightLimitMin and (skinOps.GetVertexWeight sk vb i) <= weightLimitMax then
						(
						append  boneWeight (skinOps.GetVertexWeight  sk vb i)	
						append  vertsNew vb
						)
					)
				)				
			)	
		skinOps.SelectVertices sk vertsNew		
		sk.effect = 0
		yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string
	)
on yunSkinOther_minWeight_btn rightClick  do  ---减1
	(

	yunSkinOther_minWeight.value=yunSkinOther_minWeight.value-0.1
	weightLimitMin = yunSkinOtherWin.yunSkinOther_minWeight.value
		weightLimitMax = yunSkinOtherWin.yunSkinOther_maxWeight.value	
		-- get the skin
		sk = $.modifiers[#Skin]	  
		boneSel = skinOps.GetSelectedBone sk
		-- skinOps.GetBoneName sk boneSel 1
		verts = #()
			for i = 1 to skinops.getnumbervertices sk do	(append verts i	)
			vertsNew = #()
			boneWeight = #()
			for vb in verts do ---所有点循环
			( 
				weightCountAll = skinOps.GetVertexWeightCount sk vb
				for i = 1 to weightCountAll do				
				(	
					if (skinOps.GetVertexWeightBoneID sk vb i) == boneSel then	
					(
						if (skinOps.GetVertexWeight sk vb i) >= weightLimitMin and (skinOps.GetVertexWeight sk vb i) <= weightLimitMax then
						(
						append  boneWeight (skinOps.GetVertexWeight  sk vb i)	
						append  vertsNew vb
						)
					)
				)				
			)	
		skinOps.SelectVertices sk vertsNew		
		sk.effect = 0
		yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string
	)
on yunSkinOther_maxWeight_btn pressed  do  ---加1
	(
	yunSkinOther_maxWeight.value=yunSkinOther_maxWeight.value+0.1
	weightLimitMin = yunSkinOtherWin.yunSkinOther_minWeight.value
		weightLimitMax = yunSkinOtherWin.yunSkinOther_maxWeight.value	
		-- get the skin
		sk = $.modifiers[#Skin]	  
		boneSel = skinOps.GetSelectedBone sk
		-- skinOps.GetBoneName sk boneSel 1
		verts = #()
			for i = 1 to skinops.getnumbervertices sk do	(append verts i	)
			vertsNew = #()
			boneWeight = #()
			for vb in verts do ---所有点循环
			( 
				weightCountAll = skinOps.GetVertexWeightCount sk vb
				for i = 1 to weightCountAll do				
				(	
					if (skinOps.GetVertexWeightBoneID sk vb i) == boneSel then	
					(
						if (skinOps.GetVertexWeight sk vb i) >= weightLimitMin and (skinOps.GetVertexWeight sk vb i) <= weightLimitMax then
						(
						append  boneWeight (skinOps.GetVertexWeight  sk vb i)	
						append  vertsNew vb
						)
					)
				)				
			)	
		skinOps.SelectVertices sk vertsNew		
		sk.effect = 0
		yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string
	)
on yunSkinOther_maxWeight_btn rightClick  do  ---减1
	(
	yunSkinOther_maxWeight.value=yunSkinOther_maxWeight.value-0.1
	weightLimitMin = yunSkinOtherWin.yunSkinOther_minWeight.value
		weightLimitMax = yunSkinOtherWin.yunSkinOther_maxWeight.value	
		-- get the skin
		sk = $.modifiers[#Skin]	  
		boneSel = skinOps.GetSelectedBone sk
		-- skinOps.GetBoneName sk boneSel 1
		verts = #()
			for i = 1 to skinops.getnumbervertices sk do	(append verts i	)
			vertsNew = #()
			boneWeight = #()
			for vb in verts do ---所有点循环
			( 
				weightCountAll = skinOps.GetVertexWeightCount sk vb
				for i = 1 to weightCountAll do				
				(	
					if (skinOps.GetVertexWeightBoneID sk vb i) == boneSel then	
					(
						if (skinOps.GetVertexWeight sk vb i) >= weightLimitMin and (skinOps.GetVertexWeight sk vb i) <= weightLimitMax then
						(
						append  boneWeight (skinOps.GetVertexWeight  sk vb i)	
						append  vertsNew vb
						)
					)
				)				
			)	
		skinOps.SelectVertices sk vertsNew		
		sk.effect = 0
		yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string
	)
-- ***************	
on yunSkinOther_MaxWeight changed val do   
	(
	undo on
	(
		weightLimitMin = yunSkinOtherWin.yunSkinOther_minWeight.value
		weightLimitMax = yunSkinOtherWin.yunSkinOther_maxWeight.value	
		-- get the skin
		sk = $.modifiers[#Skin]	  
		boneSel = skinOps.GetSelectedBone sk
		-- skinOps.GetBoneName sk boneSel 1
		verts = #()
			for i = 1 to skinops.getnumbervertices sk do	(append verts i	)
			vertsNew = #()
			boneWeight = #()
			for vb in verts do ---所有点循环
			( 
				weightCountAll = skinOps.GetVertexWeightCount sk vb
				for i = 1 to weightCountAll do				
				(	
					if (skinOps.GetVertexWeightBoneID sk vb i) == boneSel then	
					(
						if (skinOps.GetVertexWeight sk vb i) >= weightLimitMin and (skinOps.GetVertexWeight sk vb i) <= weightLimitMax then
						(
						append  boneWeight (skinOps.GetVertexWeight  sk vb i)	
						append  vertsNew vb
						)
					)
				)				
			)	
		skinOps.SelectVertices sk vertsNew		
		sk.effect = 0	
		yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string
	)
	)	
	
on yunSkinOther_selRing_start pressed  do ---开始环线选择
	(
	undo on
	(
				if (getNodeByName "yunLoopVertexSelFatherHiden")!=undefined do (delete (getNodeByName "yunLoopVertexSelFatherHiden"))
		if (getNodeByName "yunLoopVertexSel")!=undefined do (delete (getNodeByName "yunLoopVertexSel"))
		objStart = selection[1] --get selected object
		-- poly模式	
		seledVertexs = yunGetvertsSkinOrPoly()  -----当前选择的点儿
		polyVertexOne = vert =(seledVertexs[1])	
		if seledVertexs.count<3 then (messageBox "请最少选择三个点")
		else 
		(
			lastVertexPos = polyOp.getVert objStart (seledVertexs[seledVertexs.count])		
			vertexs_pos = #()	----所有点的位置信息
			for i in seledVertexs do ( append vertexs_pos (polyOp.getVert objStart i))
			pos_sum_x = 0
			for i in vertexs_pos do ( pos_sum_x = pos_sum_x+i[1])
			pos_sum_y = 0
			for i in vertexs_pos do ( pos_sum_y = pos_sum_y+i[2])
			pos_sum_z = 0 	
			for i in vertexs_pos do ( pos_sum_z = pos_sum_z+i[3])	
	-- 		---平均中心点
			pos_average_x = pos_sum_x/vertexs_pos.count
			pos_average_y = pos_sum_y/vertexs_pos.count
			pos_average_z = pos_sum_z/vertexs_pos.count
			midPos = [pos_average_x,pos_average_y,pos_average_z] 			
	
	-- 		叉乘算垂直线
			dotVec = #()	
			for i=1 to vertexs_pos.count-1 do 	(append dotVec (cross  (vertexs_pos[i]-midPos) (vertexs_pos[i+1]-midPos))	)	
			dotVec_normalize = 	 #()
			for i in dotVec do
			(
			if (dot [0,0,1] i)<=90 then(append dotVec_normalize (normalize (i)))
			else (append dotVec_normalize ([0,0,0]-(normalize (i))))
			)

-- 求凸边
point_node = #()
for i in vertexs_pos do ( append point_node (point2  i[1] i[3])  )	
-- 按z轴大小排序
for i= 1  to point_node.count do 
(
	for j = 1 to   point_node.count - i do 
	(
	if  point_node[j][2]>point_node[j+1][2] then 
	( 
	temp = point_node[j+1]
	point_node[j+1] = point_node[j]	
	point_node[j] = temp
	)	
	)	
)
-- 极角排序
base = point_node[1]
deleteItem  point_node 1
for i= 1 to point_node.count do 
(
	for j = 1 to   point_node.count - i do 
	(
	if(angelCmp (point_node[j]) (point_node[j+1]) base)==false then 
	( 
	temp = point_node[j+1]
	point_node[j+1] = point_node[j]	
	point_node[j] = temp
	)	
	)	
)
insertItem base point_node   1
num =#(point_node[1],point_node[2])  ---储存凸边
top = 2
for i = 3 to point_node.count do    ----堆栈排除
(
while  top>1 and  (PPcross  (num[top]-num[top-1])  (point_node[i]-num[top-1])<0)  do 	(top=top-1)
top = top + 1
num[top] = point_node[i]
)
-- 旋转卡壳
PP=#()
PP = num
append PP num[1]
cnt = PP.count-1
ans = #() 
u = 1
r = 1
l = 1
while disVerToLine PP[1] PP[2] PP[u] <= disVerToLine PP[1] PP[2] PP[u+1] do ( u = (mod  u cnt) as integer  + 1 ) 
l = u   ----确定最左点的初始位置，因为最左点必须在最右点的后面，否则初始值为1就会找到错误的点积大于0的点
min_s = 99999999999				

for i = 1 to PP.count-1 do 
(	
	while (disVerToLine PP[i] PP[i+1] PP[u]) <= (disVerToLine PP[i] PP[i+1]  PP[u+1])  do ( u = (mod  u cnt) as integer  + 1 )
	while PPdot (PP[r+1]-PP[r]) (PP[i+1]-PP[i])>=0  do ( r = (mod  r cnt) as integer  + 1 ) 	
	while PPdot (PP[l+1]-PP[l]) (PP[i+1]-PP[i])<=0  do ( l = (mod  l cnt) as integer  + 1 )
	cx = [-(PP[i+1]-PP[i]).y,(PP[i+1]-PP[i]).x]
	res = (disVerToLine PP[i] PP[i+1] PP[u])*(disVerToLine PP[r] (PP[r]+cx) PP[l])
	if res < min_s then (
		min_s = res
		ans[1] = PPinter PP[i]  PP[i+1]                  PP[r]   (PP[r]+cx)
		ans[2] = PPinter PP[r] (PP[r]+cx)                PP[u]   (PP[u]+(PP[i+1]-PP[i]))
		ans[3] = PPinter PP[u] (PP[u]+(PP[i+1]-PP[i]))   PP[l]   (PP[l]+cx)
		ans[4] = PPinter PP[l] (PP[l]+cx) PP[i] PP[i+1]		
	)	
)


-- 角度和长宽
box_angle  = atan2 (ans[2] - ans[3]).y  (ans[2]-ans[3]).x 
box_height = distance ans[2] ans[1]
box_widht  = distance ans[2] ans[3]/2
box_height = box_height*1.15
box_widht = box_widht*1.15
-- 	-- 		---中心点
dotVec_average_x = (ans[2].x+ans[1].x+ans[3].x+ans[4].x)/4
dotVec_average_z = (ans[2].y+ans[1].y+ans[3].y+ans[4].y)/4
middotVec = [dotVec_average_x,pos_average_y,dotVec_average_z] 
			if (getNodeByName "yunLoopVertexSel")== undefined then 
			(
				p2plane  = Cylinder smooth:on heightsegs:1 capsegs:1 height:2 radius:1
				p3plane  = Plane()
					
				p2plane.parent = p3plane			
				p2plane.name = "yunLoopVertexSel"
-- 				p3plane.isHidden = true	
				p3plane.name = "yunLoopVertexSelFatherHiden"
			-- 		中心重置
				mapped fn center_pivot o =(o.pivot = o.center)  undo on (center_pivot p2plane)	
				in coordsys parent $yunLoopVertexSel.pos = [0,0,0]
				p2plane.xray = on	
			)
 			
			in coordsys  world $yunLoopVertexSelFatherHiden.rotation = (eulerAngles 0 0 0)
			in coordsys parent $yunLoopVertexSelFatherHiden.rotation = (eulerAngles 0 box_angle 0 )
			$yunLoopVertexSelFatherHiden.pos = middotVec	----中心在这里	
			
			$yunLoopVertexSel.radius	= box_widht
			$yunLoopVertexSel.height	= 	box_height
			mapped fn center_pivot o =(o.pivot = o.center)  undo on (center_pivot $yunLoopVertexSel)	
			in coordsys parent $yunLoopVertexSel.pos = [0,0,0]	
-- 			角度常上修正						
			in coordsys $yunLoopVertexSelFatherHiden $yunLoopVertexSel.pos = [0,0,10]
			OriParentPos = in coordsys world $yunLoopVertexSelFatherHiden.pos
			comlparePos = in coordsys world $yunLoopVertexSel.pos
			if comlparePos[3] < OriParentPos[3] then   ----统一超上
			(
			beforeRot = in coordsys parent $yunLoopVertexSelFatherHiden.rotation 
			beforepos = in coordsys parent $yunLoopVertexSelFatherHiden.pos 	
			afterRot =quat  -beforeRot.w -beforeRot.z beforeRot.y beforeRot.x
			in coordsys parent $yunLoopVertexSelFatherHiden.rotation  = afterRot
			in coordsys parent $yunLoopVertexSelFatherHiden.pos = beforepos				
			)
			in coordsys $yunLoopVertexSelFatherHiden $yunLoopVertexSel.pos = [0,0,0]			
			yunSkinOther_selRing_H.value = 	 box_widht	
			yunSkinOther_selRing_V.value = 	box_height
			yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string
			yunSkinOther_selRing_tx.value = 0
			yunSkinOther_selRing_ty.value = 0
			yunSkinOther_selRing_tz.value = 0
			yunSkinOther_selRing_rx.value = 0
			yunSkinOther_selRing_ry.value = 0
			yunSkinOther_selRing_rz.value = 0
	
)
	
	)
	)
	
	
	

on yunSkinOther_selRing_H changed val do  
	(	
	$yunLoopVertexSel.radius = yunSkinOtherWin.yunSkinOther_selRing_H.value
	mapped fn center_pivot o =(o.pivot = o.center)  undo on (center_pivot $yunLoopVertexSel)	
	in coordsys parent $yunLoopVertexSel.pos = [yunSkinOther_selRing_tx.value,yunSkinOther_selRing_ty.value,yunSkinOther_selRing_tz.value]
	yunSelInBoundingBox ()
	yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string  
	)
on yunSkinOther_selRing_V changed val do 
	(	
	$yunLoopVertexSel.height = yunSkinOtherWin.yunSkinOther_selRing_V.value
	mapped fn center_pivot o =(o.pivot = o.center)  undo on (center_pivot $yunLoopVertexSel)
	in coordsys parent $yunLoopVertexSel.pos = [yunSkinOther_selRing_tx.value,yunSkinOther_selRing_ty.value,yunSkinOther_selRing_tz.value]
	yunSelInBoundingBox ()
	yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string  
	)
on yunSkinOther_selRing_tx changed val do 
	(
	in coordsys parent $yunLoopVertexSel.pos = [yunSkinOther_selRing_tx.value,yunSkinOther_selRing_ty.value,yunSkinOther_selRing_tz.value]
	yunSelInBoundingBox ()
	yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string 
	)
on yunSkinOther_selRing_ty changed val do 
	(	
	in coordsys parent $yunLoopVertexSel.pos = [yunSkinOther_selRing_tx.value,yunSkinOther_selRing_ty.value,yunSkinOther_selRing_tz.value]
	yunSelInBoundingBox ()
	yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string 
	)
on yunSkinOther_selRing_tz changed val do 
	(	
	in coordsys parent $yunLoopVertexSel.pos = [yunSkinOther_selRing_tx.value,yunSkinOther_selRing_ty.value,yunSkinOther_selRing_tz.value]
	yunSelInBoundingBox ()
	yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string 
	)
on yunSkinOther_selRing_rx changed val do 
	(	
	in coordsys parent $yunLoopVertexSel.rotation = eulerAngles yunSkinOther_selRing_rx.value  yunSkinOther_selRing_ry.value  yunSkinOther_selRing_rz.value
	yunSelInBoundingBox ()
	yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string 
	)
on yunSkinOther_selRing_ry changed val do 
	(
	in coordsys parent $yunLoopVertexSel.rotation = eulerAngles  yunSkinOther_selRing_rx.value  yunSkinOther_selRing_ry.value  yunSkinOther_selRing_rz.value
	yunSelInBoundingBox ()
	yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string 
	)
on yunSkinOther_selRing_rz changed val do 
	(	
	in coordsys parent $yunLoopVertexSel.rotation = eulerAngles  yunSkinOther_selRing_rx.value  yunSkinOther_selRing_ry.value  yunSkinOther_selRing_rz.value
	yunSelInBoundingBox ()
	yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string
	)
on yunSkinOther_selRing_btn_rx pressed  do 
	(
	yunSkinOther_selRing_rx.value=yunSkinOther_selRing_rx.value+90
	in coordsys parent $yunLoopVertexSel.rotation = eulerAngles yunSkinOther_selRing_rx.value  yunSkinOther_selRing_ry.value  yunSkinOther_selRing_rz.value		
	yunSelInBoundingBox ()
	yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string 
	)
on yunSkinOther_selRing_btn_ry pressed  do 
	(
	yunSkinOther_selRing_ry.value=yunSkinOther_selRing_ry.value+90
	in coordsys parent $yunLoopVertexSel.rotation = eulerAngles yunSkinOther_selRing_rx.value  yunSkinOther_selRing_ry.value  yunSkinOther_selRing_rz.value
	yunSelInBoundingBox ()
	yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string 
	)
on yunSkinOther_selRing_btn_rz pressed  do 
	(
	yunSkinOther_selRing_rz.value=yunSkinOther_selRing_rz.value+90
	in coordsys parent $yunLoopVertexSel.rotation = eulerAngles yunSkinOther_selRing_rx.value  yunSkinOther_selRing_ry.value  yunSkinOther_selRing_rz.value
	yunSelInBoundingBox ()
	yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string 
	)
	
on yunSkinOther_selRing_btn_rx rightClick   do 
	(
	yunSkinOther_selRing_rx.value=yunSkinOther_selRing_rx.value-90
	in coordsys parent $yunLoopVertexSel.rotation = eulerAngles yunSkinOther_selRing_rx.value  yunSkinOther_selRing_ry.value  yunSkinOther_selRing_rz.value
	yunSelInBoundingBox ()
	yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string  
	)
on yunSkinOther_selRing_btn_ry rightClick   do 
	(
	yunSkinOther_selRing_ry.value=yunSkinOther_selRing_ry.value-90
	in coordsys parent $yunLoopVertexSel.rotation = eulerAngles yunSkinOther_selRing_rx.value  yunSkinOther_selRing_ry.value  yunSkinOther_selRing_rz.value
	yunSelInBoundingBox ()
	yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string 
	)
on yunSkinOther_selRing_btn_rz rightClick   do 
	(
	yunSkinOther_selRing_rz.value=yunSkinOther_selRing_rz.value-90
	in coordsys parent $yunLoopVertexSel.rotation = eulerAngles yunSkinOther_selRing_rx.value  yunSkinOther_selRing_ry.value  yunSkinOther_selRing_rz.value
	yunSelInBoundingBox ()
	yunSkinOther_vertsCount.text = (yunGetvertsSkinOrPoly()).count  as string  
	)

on yunSkinOther_selRing_end pressed  do 
	(	
	if (getNodeByName "yunLoopVertexSelFatherHiden")!=undefined do (delete (getNodeByName "yunLoopVertexSelFatherHiden"))
	if (getNodeByName "yunLoopVertexSel")!=undefined do (delete (getNodeByName "yunLoopVertexSel"))
	)

)


Xr_SkinTools_UI = newRolloutFloater "蒙皮辅助" 210 550
-- addRollout Xr_WeightTool Xr_SkinTools_UI
-- addRollout Xr_SkinBrush Xr_SkinTools_UI
-- addRollout Xr_SkinCheck Xr_SkinTools_UI
addRollout yunSkinToolWin Xr_SkinTools_UI
addRollout yunSkinOtherWin Xr_SkinTools_UI
-- Xr_WeightTool.open =  false
-- Xr_SkinBrush.open = false
-- Xr_SkinCheck.open = false
yunSkinToolWin.open = false
yunSkinOtherWin.open = true


