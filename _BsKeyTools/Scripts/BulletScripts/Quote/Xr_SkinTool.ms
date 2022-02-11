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
rollout Xr_WeightTool	"权重工具"
(
	local UpdataSMUI
	local sVerCount = 0
	local sVer = 0
	
	local MS_Poly = undefined
	local MS_VertList = #()
	local axisoffset = 0
	local dist_Threshold = 0.1					--- Change this to change the mirror threshold
	local MS_Class = 0
	
	
	checkbutton Xr_Btn_EditSkin ">>>   编辑封套   <<<" pos:[10,6] width:175 height:24

	button Xr_Btn_Shrink "收缩" pos:[6,36] width:43 height:24
	button Xr_Btn_Grow "扩大" pos:[52,36] width:43 height:24
	button Xr_Btn_Ring "环" pos:[101,36] width:43 height:24
	button Xr_Btn_Loop "循环" pos:[150,36] width:43 height:24
	
	button 'Xr_Btn_WeightsValue0' "0" pos:[6,66] width:20 height:20 
	button 'Xr_Btn_WeightsValue0.1' ".1" pos:[32,66] width:20 height:20
	button 'Xr_Btn_WeightsValue0.25' ".25" pos:[58,66] width:24 height:20
	button 'Xr_Btn_WeightsValue0.5' ".5" pos:[89,66] width:20 height:20
	button 'Xr_Btn_WeightsValue0.75' ".75" pos:[115,66] width:24 height:20
	button 'Xr_Btn_WeightsValue0.9' ".9" pos:[147,66] width:20 height:20
	button 'Xr_Btn_WeightsValue1' "1" pos:[173,66] width:20 height:20
	
	button Xr_Btn_SetWeights ">设置权重<" pos:[6,96] width:66 height:24
	spinner Xr_Btn_SetWeightsValue ""  pos:[75,101] width:55 height:16 range:[0,1,0.5] type:#float scale:0.01
	button Xr_Btn_SetWeightsAdd "+" pos:[139,98] width:25 height:22
	button Xr_Btn_SetWeightsReduce "-" pos:[168,98] width:25 height:22
	
	button Xr_Btn_WeightsCopy "复制" pos:[6,128] width:40 height:24
	button Xr_Btn_WeightsPaste "粘贴" pos:[50,128] width:40 height:24
	button Xr_Btn_WeightsPastePoss "粘贴姿态" pos:[95,128] width:55 height:24
	button Xr_Btn_WeightsBlend "混合" pos:[153,128] width:40 height:24
	
	label Xr_Lbl_vCount "0 选定的顶点" pos:[16,161] width:160
	listbox Xr_Lbx_BoneList "" pos:[6,177] width:185 height:7 selection:1
	label Xr_Lbl_ShowBones "蒙皮骨骼数: ***" pos:[80,279] width:160
	
	button Xr_Btn_SelectVertex "选择顶点" pos:[6, 300] width:88 height:24 tooltip:"选择当前封套或骨骼的所有权重顶点" 
	button Xr_Btn_SelectMirrorVertex "镜像选择顶点" pos:[105, 300] width:85 height:24 tooltip:"镜像选择当前封套或骨骼的所有权重顶点" 
	
	groupBox Xr_GroupBox_1 "" pos:[5,324] width:185 height:105 align:#left	
	
	spinner Xr_Spn_ZeroLimit "移除零限制:" pos:[42,344] width:83 range:[0,1,0.005] scale:0.001 type:#float
	button Xr_Btn_LimitRemove "移除" pos:[128, 340] width:56
	spinner Xr_Spn_MaxBoneCount "骨骼影响:" pos:[42,375] width:83 range:[1,8,4] type:#integer
	button Xr_Btn_BoneRematch "确定" pos:[128, 371] width:56
	
	button Xr_Btn_RemoveUnuseBone "移除未用骨骼" pos:[10,401] width:83 height:23
	
	button Xr_Btn_WeightTransfer "权重转移" pos:[102,401] width:83 height:23
	fn checkSkinModifierWorking = (
		return ((try(classof $.modifiers[#Skin] == Skin)catch(false)) and (getCommandPanelTaskMode() == #modify) and (classof (modPanel.getCurrentObject()) == Skin))
	)
	fn UpdataSMUI =
	(
		if checkSkinModifierWorking() then
		(
			cSBone = skinOps.GetSelectedBone $.modifiers[#Skin]
			nVertex = skinOps.GetNumberVertices $.modifiers[#Skin]
			local fSelVer = 0
			for i = 1 to nVertex do
			(
				if ((skinOps.IsVertexSelected $.modifiers[#Skin] i) == 1) then
				(
					sVerCount += 1
					fSelVer = i
				)
			)
			Xr_Lbl_vCount.text = (sVerCount as String) + " 选定的顶点"
			LSI = 0
			if fSelVer > 0  then
			(
				BInfoList = #()
				nBones = skinOps.GetVertexWeightCount $.modifiers[#Skin] fSelVer
				for BC = 1 to nBones do
				(
					bID = skinOps.GetVertexWeightBoneID $.modifiers[#Skin] fSelVer BC
					bW = skinOps.GetVertexWeight $.modifiers[#Skin] fSelVer BC
					bN = skinOps.GetBoneName $.modifiers[#Skin] bID 0
					append BInfoList ((formattedPrint bW format:"#.4f") + " : " + (bN as String))
					if bID == cSBone then
					(
						LSI = BC
					)
				)
				Xr_Lbx_BoneList.selection = LSI
				Xr_Lbx_BoneList.items = BInfoList
				sVer = fSelVer
			)
			else
			(
				sVer = 0
				Xr_Lbx_BoneList.items = #()
			)
			sVerCount = 0
			Xr_Lbl_ShowBones.text = "蒙皮骨骼数: " + ((skinOps.GetNumberBones $.modifiers[#Skin]) as String)
			
		)
		else
		(
			sVerCount = 0
			Xr_Lbl_vCount.text = "0 选定的顶点"
			Xr_Lbl_ShowBones.text =  "蒙皮骨骼数: ***"
			Xr_Lbx_BoneList.items = #()
		)
	)
	
	fn readObjectVerts obj =
	(
		vertcount = obj.vertices.count
		MS_VertList = #()
		oxlist = #()
		
		if MS_Class == 1 then gv = polyop.getVert
		if MS_Class == 2 then gv = meshop.getVert
		if MS_Class == 3 then gv = polyop.getVert
		for v = 1 to vertcount do
		(
			vpos = gv obj v
			append MS_VertList vpos
			append oxlist vpos.x
		)
		a = amin oxlist							
		b = amax oxlist
		c = ((b-a) / 2)
		axisoffset = (b-c)
		oxlist = #()
	)

	fn mirrorVerts SelVerts =
	(
		enableUpdate = false
		mirrorSel = #()

		minx = miny = minz = 999999
		maxx = maxy = maxz = -999999

		for v=1 to SelVerts.count do
		(
			if MS_VertList[selverts[v]].x < minx then minx = MS_VertList[selverts[v]].x
			if MS_VertList[selverts[v]].y < miny then miny = MS_VertList[selverts[v]].y
			if MS_VertList[selverts[v]].z < minz then minz = MS_VertList[selverts[v]].z

			if MS_VertList[selverts[v]].x > maxx then maxx = MS_VertList[selverts[v]].x
			if MS_VertList[selverts[v]].y > maxy then maxy = MS_VertList[selverts[v]].y
			if MS_VertList[selverts[v]].z > maxz then maxz = MS_VertList[selverts[v]].z
		)
		
		bbx = bby = bbz = 1
	
		minx = minx - bbx 
		miny = miny - bby 
		minz = minz - bbz 

		maxx = maxx + bbx 
		maxy = maxy + bby 
		maxz = maxz + bbz 

		bbArray = #()
		for v=1 to MS_VertList.count do
		(
			if ( ((MS_VertList[v].x) <= (- minx)) AND ((MS_VertList[v].x) >= (- maxx)) AND ((MS_VertList[v].y) >= (miny)) AND ((MS_VertList[v].y) <= (maxy)) AND ((MS_VertList[v].z) >= (minz)) AND ((MS_VertList[v].z) <= (maxz)) ) do
			(
				append bbArray v
			)
		)
		
		for b=1 to SelVerts.count do
		(
			originalpos =  copy (MS_VertList[SelVerts[b]])          
			originalpos.x = ((originalpos.x) - (axisoffset))		
		
			mirrorpos = originalpos
			ax = (mirrorpos.x) 
			ax = (-(ax)) 
			mirrorpos = [(ax + axisoffset), mirrorpos.y, mirrorpos.z]									
			distList = #()
			for v=1 to bbArray.count do
			(
				vPos = MS_VertList[bbArray[v]]
				dist = distance mirrorPos vPos
				append distList dist
				if (dist <= dist_Threshold) then exit
			)
			
			minDist = amin distList
			minVert = findItem distList minDist
			if minVert != 0 then append mirrorSel bbArray[minVert]
		)
		return mirrorSel
	)
	-------------------------------------------权重转移
	fn collectSkinBones sk = 
	(
		a = #()
		for b = 1 to (skinOps.getNumberBones sk) do
		(
			obj =getnodebyname(skinOps.GetBoneName sk b 1)
			append a obj
		)
		a
	)
	fn TransferSkinBone sk source target = 
	(
		verts = #()
		for i = 1 to skinops.getnumbervertices sk do
		(
			if (skinOps.IsVertexSelected sk i) == 1 then append verts i
		)

		for v in verts do
		(
			targetWeight = 0.0
			sourceWeight = 0.0
			weightCount = skinOps.GetVertexWeightCount sk v
			for vb = 1 to weightCount do
			(
				if (skinOps.GetVertexWeightBoneID sk v vb) == target then
				(
					targetWeight = skinOps.GetVertexWeight sk v vb
				)
				if (skinOps.GetVertexWeightBoneID sk v vb) == source then
				(
					sourceWeight = skinOps.GetVertexWeight sk v vb
				)
			)
			
			if sourceWeight > 0 then
			(
				skinOps.SetVertexWeights sk v source 0.0
				skinOps.SetVertexWeights sk v target (sourceWeight + targetWeight)
			)
		)
	)
	fn getTargetPair sk = 
	(
		sel = selectByName title:"将重量转移到？" single:true
		s = findItem (collectSkinBones sk) sel -- no find return 0
	)
	
	on Xr_Btn_WeightTransfer pressed do undo "Transfer" on 
	(
		count = 0
		sk = modpanel.getcurrentobject() 
		if not iskindof sk Skin then
		(
			messagebox "蒙皮修改器必须在“修改器”面板中打开" 
		)
		else
		(
			srcBoneID = skinOps.GetSelectedBone sk
			tagBoneID = getTargetPair sk
			if tagBoneID != 0 then 
			(
				TransferSkinBone sk srcBoneID tagBoneID
			)
		)

	)
	-------------------------------------------权重转移End
	
	on Xr_Btn_EditSkin changed state  do
	(
		try(	
				if Xr_Btn_EditSkin.state == true then
				(
					subobjectLevel = 1
					$.modifiers[#Skin].filter_vertices = on
					)
				else
				(
					subobjectLevel = 0
					$.modifiers[#Skin].filter_vertices = off
					$.modifiers[#Skin].mirrorEnabled = off
					)
			)catch()
		)
		
	on Xr_Btn_Shrink pressed do
	(
		try(skinOps.shrinkSelection $.modifiers[#Skin])catch()
		UpdataSMUI()
		)
		
	on Xr_Btn_Grow pressed do
	(
		try(skinOps.growSelection $.modifiers[#Skin])catch()
		UpdataSMUI()
		)
		
	on Xr_Btn_Ring pressed do
	(
		try(skinOps.ringSelection $.modifiers[#Skin])catch()
		UpdataSMUI()
		)
	
	on Xr_Btn_Loop pressed do
	(
		try(skinOps.loopSelection $.modifiers[#Skin])catch()
		UpdataSMUI()
		)
		
	on Xr_Btn_WeightsValue0 pressed do
	(
		try(skinOps.setWeight $.modifiers[#Skin] 0)catch()
		UpdataSMUI()
		)
	
	on Xr_Btn_WeightsValue0.1 pressed do
	(
		try(skinOps.setWeight $.modifiers[#Skin] 0.1)catch()
		UpdataSMUI()
		)
	
	on Xr_Btn_WeightsValue0.25 pressed do
	(
		try(skinOps.setWeight $.modifiers[#Skin] 0.25)catch()
		UpdataSMUI()
		)
	
	on Xr_Btn_WeightsValue0.5 pressed do
	(
		try(skinOps.setWeight $.modifiers[#Skin] 0.5)catch()
		UpdataSMUI()
		)
	
	on Xr_Btn_WeightsValue0.75 pressed do
	(
		try(skinOps.setWeight $.modifiers[#Skin] 0.75)catch()
		UpdataSMUI()
		)
	
	on Xr_Btn_WeightsValue0.9 pressed do
	(
		try(skinOps.setWeight $.modifiers[#Skin] 0.9)catch()
		UpdataSMUI()
		)
	
	on Xr_Btn_WeightsValue1 pressed do
	(
		try(skinOps.setWeight $.modifiers[#Skin] 1)catch()
		UpdataSMUI()
		)	
		
	on Xr_Btn_SetWeights pressed do
	(
		try(skinOps.setWeight $.modifiers[#Skin] Xr_Btn_SetWeightsValue.value)catch()
		UpdataSMUI()
		)	
		
	on Xr_Btn_SetWeightsValue changed val do
	(
		try(
				Xr_Btn_SetWeightsValue.value =val
				$.modifiers[#Skin].weightTool_weight = val
				)catch()
				UpdataSMUI()
		)
		
	on Xr_Btn_SetWeightsAdd pressed do
	(
		try(skinOps.addWeight $.modifiers[#Skin] 0.05)catch()
		UpdataSMUI()
		)
		
	on Xr_Btn_SetWeightsReduce pressed do
	(
		try(skinOps.addWeight $.modifiers[#Skin] -0.05)catch()
		UpdataSMUI()
		)
		
	on Xr_Btn_WeightsCopy pressed do
	(
		try(skinOps.copyWeights $.modifiers[#Skin])catch()
		UpdataSMUI()
		)
		
	on Xr_Btn_WeightsPaste pressed do
	(
		try(skinOps.pasteWeights $.modifiers[#Skin])catch()
		UpdataSMUI()
		)
		
	on Xr_Btn_WeightsPastePoss pressed do
	(
		try(skinOps.pasteWeightsByPos $.modifiers[#Skin] 0.1)catch()
		UpdataSMUI()
		)
		
	on Xr_Btn_WeightsBlend pressed do
	(
		try(skinOps.blendSelected $.modifiers[#Skin])catch()
		UpdataSMUI()
		)	
		
	on Xr_Lbx_BoneList selected nameIndex do
	(
-- 		unregisterRedrawViewsCallback UpdataSMUI
		if ((try(classof $.modifiers[#Skin] == Skin)catch(false)) and (getCommandPanelTaskMode() == #modify) and nameIndex != 0) then
		(
			bID = skinOps.GetVertexWeightBoneID $.modifiers[#Skin] sVer nameIndex 
			skinOps.SelectBone $.modifiers[#Skin] bID
			)
-- 		registerRedrawViewsCallback UpdataSMUI
-- 		UpdataSMUI()
		
		)
	

	on Xr_Btn_SelectVertex pressed do
	(
		if checkSkinModifierWorking() then
		(
		  skinMod = $.modifiers[#Skin]
		  skinOps.selectVerticesByBone skinMod
		)
		
	)

	on Xr_Btn_SelectMirrorVertex pressed do
	(
		obj = (getCurrentSelection())[1]
		MS_Poly = modpanel.getCurrentObject()
		classxxx = classof MS_Poly
		if classxxx == Editable_Poly then MS_Class = 1
		if classxxx == Editable_Mesh then MS_Class = 2
		if classxxx == Edit_Mesh 	  then MS_Class = 2
		if classxxx == Skin 	  then MS_Class = 3	
			
		if (MS_Class != 0) do
		(
			subobjectlevel = 1
			readObjectVerts obj
			if (MS_Class == 1) then vertSel = polyop.getVertSelection MS_Poly as array 
			if (MS_Class == 2) then 
			(
				if classxxx == Editable_Mesh then vertSel = getVertSelection obj as array
				else vertSel = getVertSelection obj MS_Poly as array 
			)
			if (MS_Class == 3) then 
			(
				selectedVerts=#{}
				vertcount = obj.vertices.count
				theSkin=obj.modifiers[#Skin]		
				for i = 1 to vertcount do --vertnum is number of vertices in skin object
				(		
					theVert = skinOps.IsVertexSelected theSkin i
					if theVert == 1 do append selectedVerts i	
				)
				vertSel=selectedVerts as Array
				selectedVerts=#{}
			)
			mirVerts = mirrorVerts vertSel 
			if (MS_Class == 1) then vertSel = polyOp.setVertSelection MS_Poly mirVerts 
			if (MS_Class == 2) then 
			(
				if classxxx == Editable_Mesh then vertSel = setVertSelection obj mirVerts 
				else vertSel = setVertSelection obj MS_Poly mirVerts 
			)
			if (MS_Class == 3) then 
			(
				mirVerts = mirVerts as Bitarray
				skinOps.SelectVertices theSkin mirVerts	
				theSkin.effect = 0
			)

			forceCompleteRedraw()
		)
	)
	
	on Xr_Btn_LimitRemove pressed do
	(
		if checkSkinModifierWorking() then
		(
			$.modifiers[#Skin].clearZeroLimit = Xr_Spn_ZeroLimit.value
			skinOps.RemoveZeroWeights $.modifiers[#Skin]
		)
	)

	on Xr_Btn_BoneRematch pressed do
	(
		if checkSkinModifierWorking() then
		(
			numVertex = skinOps.GetNumberVertices $.modifiers[#Skin]
			for nV = 1 to numVertex do
			(
				numBones = skinOps.GetVertexWeightCount $.modifiers[#Skin] nV
				BArray = #()
				Warray = #()
				for nB = 1 to numBones do
				(
					append BArray (skinOps.GetVertexWeightBoneID $.modifiers[#Skin] nV nB)
					append Warray (skinOps.GetVertexWeight $.modifiers[#Skin] nV nB)
				)
				for i = 1 to (numBones - 1) do
				(
					for j = 1 to (numBones - 1) do
					(
						if Warray[j] < Warray[j+1] then
						(
							wB = Warray[j]
							Warray[j] = Warray[j+1]
							Warray[j+1] = wB
							bB = BArray[j]
							BArray[j] = BArray[j+1]
							BArray[j+1] = bB
						)
					)
				)
				MaxBoneCount = Xr_Spn_MaxBoneCount.value as integer
				wTotal = 0
				
				for Q = 1 to MaxBoneCount do
				(
					if Warray[Q] != undefined then
					(
						wTotal += Warray[Q]
					)
				)
				for cB = 1 to numBones do
				(
					if cB <= Xr_Spn_MaxBoneCount.value then
					(
						Warray[cB] = Warray[cB] / wTotal
					)
					else
						Warray[cB] = 0
				)
				skinOps.SetVertexWeights $.modifiers[#Skin] nV BArray Warray
			)
		)
	)
	
	on Xr_Btn_RemoveUnuseBone pressed do
	(
		if checkSkinModifierWorking() then
		(
			numBones = skinOps.GetNumberBones $.modifiers[#Skin]
			numVerts = skinOps.GetNumberVertices $.modifiers[#Skin]
			BoneArray = #{1..numBones}
			for n = 1 to BoneArray.count do ( BoneArray[n] = false )
			
			for nV = 1 to numVerts do
			(
				vBoneCount = skinOps.GetVertexWeightCount $.modifiers[#Skin] nV
				for bC = 1 to vBoneCount do
				(
					bID = skinOps.GetVertexWeightBoneID $.modifiers[#Skin] nV bC
					BoneArray[bID] = true
				)
			)
			
			for i = 1 to BoneArray.count do
			(
				bID = BoneArray.count - i + 1
				if BoneArray[bID] == false then
				(
					skinOps.removebone $.modifiers[#Skin] bID
				)
			)
		)
	)
	fn UpdataSMUI_exc=
	(
		if (findItem  mouse.buttonStates 1)	==1 or
		keyboard.altPressed or 
		keyboard.shiftPressed or
		keyboard.controlPressed do (UpdataSMUI())
	)
	
	on Xr_WeightTool open do
	(
		registerRedrawViewsCallback UpdataSMUI_exc
		UpdataSMUI()
		)
		
	on Xr_WeightTool close do
	(
		unregisterRedrawViewsCallback UpdataSMUI_exc
		)
		
)
rollout Xr_SkinBrush "笔刷 " 
(
	button Xr_Btn_Paints ">>>   开启笔刷   <<<"  pos:[10,6] width:175 height:24 toolTip:"按shift键0.5s切换笔刷"
	checkbutton Xr_Btn_Blends "绘制混合权重" pos:[10,37] width:175 height:23
	
	groupBox Xr_GroupBox_2 "" pos:[5,65] width:185 height:125 align:#left	
	
	spinner Xr_WeightIntValue "权重强度:  " pos:[16,80] width:160 height:16 range:[-999,999,1] scale:0.1
	spinner Xr_PaintsSizeValue "尺寸大小:  " pos:[16,100] width:160 height:16 range:[0,999,1] scale:0.1

	checkBox Xr_PaintsMirror "镜像" pos:[25,125] checked:false
	dropdownlist Xr_PaintsMirror_Axle "" pos:[80,123] enabled:false items:#("X","Y","Z") width:50
	
	spinner Xr_PaintsMirror_Offset "镜像偏移:  " pos:[16,148] width:160 height:16 range:[-1e+006,1e+006,0] scale:0.001
	spinner Xr_PaintsMirror_GizmoSize "Gizmo大小:" pos:[16,171]  width:160 height:16 range:[0,1e+006,1] scale:0.001
	
	on Xr_Btn_Paints pressed do
	(
		try(
				if selection.count ==1 then
				(	
					max modify mode
					if subobjectLevel == 0 then
					(
						subobjectLevel = 1
						)
					selection[1].modifiers[#Skin].filter_vertices = on
					selection[1].modifiers[#Skin].showNoEnvelopes = on
					skinOps.paintWeightsButton selection[1].modifiers[#Skin]
					thePainterInterface.maxStr = Xr_WeightIntValue.value
				)
				else(messageBox "请选择蒙皮模型 ")
			)catch()
		)
	
	on Xr_Btn_Blends changed state  do
	(
		try(
				if Xr_Btn_Blends.state == true then
					(
						$.modifiers[#Skin].paintBlendMode = on
						thePainterInterface.maxStr = 2
						Xr_WeightIntValue.value =2
						
						)
				else
						(
							$.modifiers[#Skin].paintBlendMode = off
							
							thePainterInterface.maxStr = 0.01
							Xr_WeightIntValue.value=0.01
							
							)
				)catch()
		)
		
	on Xr_WeightIntValue changed val do
	(
		try(
				Xr_WeightIntValue.value = val 
				thePainterInterface.maxStr = Xr_WeightIntValue.value
				)catch()
		)	
		
	on Xr_PaintsSizeValue changed val do
	(
		try(
				Xr_PaintsSizeValue.value = val 
				thePainterInterface.maxSize  = Xr_PaintsSizeValue.value
				)catch()
		)
	
	on Xr_PaintsMirror changed state do
	(
		if state then
		(
			thePainterInterface.mirrorEnable =true
			Xr_PaintsMirror_Axle.enabled = true
			)
		else
		(
			thePainterInterface.mirrorEnable =false
			Xr_PaintsMirror_Axle.enabled = false
			)
		)
	
	on Xr_PaintsMirror_Axle selected i do
	(
		thePainterInterface.mirrorAxis = i as integer
		)
	
	on Xr_PaintsMirror_Offset changed val do 
	(
		thePainterInterface.mirrorOffset = val
		)

	on Xr_PaintsMirror_GizmoSize changed val do 
	(
		thePainterInterface.mirrorGizmoSize = val
		)
		
)
rollout Xr_SkinCheck "蒙皮检查"
(
	local un_id =#() 					---无权重的骨骼ID
	local Un_BoneName =#() 			--无权重骨骼名字
	local objSkin  					---捡取的蒙皮信息
	local val_num =100   				---权重位数，默认0.001
	local skin_num = 0 				---蒙皮骨骼数
	local Bone_Name =#()
	
	button Xr_Btn_SkinCheck ">>>   检查蒙皮   <<<" pos:[10,6] width:175 height:24
	listbox Xr_Btn_SkinCheckNoWeight "无权重的骨骼：" tooltip:"双击或者右击选择删除"
	button Xr_Btn_Quick_Remove "全部移除" pos:[10,193] width:175 height:24 tooltip:"移除列表中所有无权重骨骼" 
	button 'Xr_Btn_Batch_Remove_0.001' "0.001" pos:[9,220] width:85 height:23 toolTip:"去除0.001位权重"
	button 'Xr_Btn_Batch_Remove_0.01' "0.01" pos:[100,220] width:85 height:23 toolTip:"去除0.001位权重"
	button 'Xr_Btn_Batch_check' "检查规范" pos:[9,248] width:85 height:23 toolTip:"检查是否符合蒙皮规范"
	button 'Xr_Btn_Batch_fix' "修复" pos:[100,248] width:85 height:23 toolTip:"尝试修复"
	progressBar QR_bar  color:blue		---进度条
		on Xr_Btn_Batch_check pressed do
	(
		max modify mode
		poly = selection as array
		-- 没有选择物体
		if poly.count<1 do 
		(
			--选择所有
			allPoly = (for o in geometry where classOf o == PolyMeshObject collect o)
			poly = allPoly
		) 
		---报错信息
		messInfo = ""
		--   for i in poly do (	print(i.name))
		--   o = poly[1]
		for o in poly do
		(
			-- 	select o
			messInfo += "————————————————————\n"
			messInfo +=o.name+":\n"
			modNum = o.modifiers
			if modNum.count ==1 then
			(
				--检查是不是多边形
				if classOf o.baseObject != Editable_poly  do (messInfo+= "不是多边形，请检查！！  \n")
				--检查位移
				if o.pos !=  [0,0,0] do (messInfo+= "模型位置没有归零！！  \n")
				if o.rotation !=  (quat 0.707107 0 0 0.707107) do (messInfo+= "模型旋转没有调成（90，0，0）！！  \n")		
				--检查蒙皮
				modPanel.setCurrentObject  o.modifiers[modNum.count]		
				sk = modpanel.getcurrentobject()
				if classof sk == skin then 
				(
					if sk.always_deform == false do ( messInfo+= "未开总是影响！！  \n")
					if sk.bone_Limit != 4 do (messInfo+= "骨骼影响不是4根！！  \n")			
					if sk.ref_frame !=0 do (messInfo+= "参考帧不在 0f！！   \n")		
				)
				else(messInfo+= "蒙皮修改器未激活！！  \n")		
			)
			else (messInfo+= "有多个修改器，请检查是否未塌陷bonepro！！ \n")
		)
		messageBox messInfo
		select poly			
	)
	
	on Xr_Btn_Batch_fix pressed do
	(
		max modify mode
		--    o = poly[1]
		-- 修复
		poly = selection as array
		for o in poly do
		(
			-- 	select o
			modNum = o.modifiers
			if modNum.count >0 then
			(
				modPanel.setCurrentObject  o.modifiers[modNum.count]
				sk = modpanel.getcurrentobject()
				if classof sk== skin do  
				(
					if sk.ref_frame !=0 do (sk.ref_frame = 0f)		
					if sk.always_deform == false do ( sk.always_deform = true)
					if sk.bone_Limit != 4 do (sk.bone_Limit = 4)
				)		
			)	
		)
		select poly			
	)
	
	fn UnSkinBoneId   =  ---查找无权重骨骼ID
	(
		
		skin_index=#{1.. skin_num} --骨骼蒙皮ID列表
		
		numSkinVerts = #{1..(skinOps.getNumberVertices objSkin)} --获取参与蒙皮的点
		
		global SkinBoneID = #()  --有权重骨骼ID集合
		
		for n=1 to numSkinVerts.count do
		(
			numBoneWeights = skinOps.getVertexWeightCount objSkin n    --每个点有几根骨骼影响
			
            for b=1 to numBoneWeights do
			(
				boneID       = skinOps.getVertexWeightBoneID objSkin n b  --获取第n个点参与的第b个骨骼的ID
				append SkinBoneID boneID
				)

			)
		SkinBoneID=makeUniqueArray SkinBoneID ----去除数组中重复的元素
		SkinBoneID = sort SkinBoneID  ----数组排序
		skin_index = skin_index as array    ----位数组转数组
		
		struct bone_weight  ---绑定骨骼ID和骨骼名
		(
			n_ame,
			index
			)
		
		un_id =#() -- 无权重骨骼ID

		for i =1 to skin_index.count  do    ---skin_index - SkinBoneID
		(
			if (findItem SkinBoneID (skin_index[i])) == 0 do
			(
				tem_bone = bone_weight()
				tem_bone.n_ame = skinOps.GetBoneName objSkin skin_index[i] 1
				tem_bone.index = i
				append un_id tem_bone
			)
		)
	
	)
	
	fn Get_NumberBones = ---检查蒙皮骨骼数
	(
		max modify mode
		objSkin  = $.modifiers[#Skin]
		skinOps.RemoveZeroWeights objSkin
		skin_num = skinOps.GetNumberBones objSkin

		)
	
	fn ChangeBoneName  a_array = ---转换ID骨骼名
	(
		
		Un_BoneName =#()
	
		for i =1 to a_array.count do
		(
			local a_string = a_array[i].n_ame
			append Un_BoneName a_string
			)
		
		)

	fn rounding_off val  = --- 四舍五入
	(
		val = (val*val_num+0.5) as integer
		val = (val as float)/val_num
		)
	
	fn round_off val  = --- 取整
	(
		val = (val*val_num) as integer
		val = (val as float)/val_num
		)
	
	fn ShowBone  =   ---显示
	(
		Xr_Btn_SkinCheckNoWeight.items=Un_BoneName
		)

	fn SkinBoneId  = ---优化权重位数
	(
		
		
		numSkinVerts = #{1..(skinOps.getNumberVertices objSkin)} --获取参与蒙皮的点
		
		local tem_id = #()
		local tem_val = #()
		
		for n=1 to numSkinVerts.count do
		(
			numBoneWeights = skinOps.getVertexWeightCount objSkin n    --每个点有几根骨骼影响
			
            for b=1 to numBoneWeights do
			(
				vertexWeight = skinOps.getVertexWeight objSkin n b --获取第n个点参与的第b个骨骼的ID
				
				tem_id[b]  = skinOps.getVertexWeightBoneID objSkin n b
				
				tem_val[b] = rounding_off vertexWeight 

			)
			
			tem = 1.0
			for b=numBoneWeights to 2 by -1 do
			(
				tem_val[b]=round_off tem_val[b]
				skinOps.SetVertexWeights objSkin n tem_id[b] tem_val[b]
				
				tem = tem - tem_val[b]
			)
			
			skinOps.SetVertexWeights objSkin n tem_id[1] tem

			QR_bar.value = 100-100.*n/numSkinVerts.count
		)
			QR_bar.value = 0
	)	
		
	on Xr_Btn_SkinCheck pressed do
	(
		if selection.count == 1 then	
		(
			Get_NumberBones ()
			UnSkinBoneId ()
			ChangeBoneName un_id
			)
		else
		(
			messageBox "选择单个模型 "
			Un_BoneName =#()
			)
		
		ShowBone()
		skin_num = 0
		)
		
	on Xr_Btn_SkinCheckNoWeight selected nameIndex do  ---选择
	(
		local a_index = (un_id[Xr_Btn_SkinCheckNoWeight.selection]).index  ---获取骨骼ID
		skinOps.SelectBone objSkin a_index     ----选取ID骨骼
		)
		
	on Xr_Btn_SkinCheckNoWeight doubleClicked sel do  ---双击删除
	(
		local a_index = (un_id[Xr_Btn_SkinCheckNoWeight.selection]).index

		skinOps.removebone objSkin a_index
		
		temp = Xr_Btn_SkinCheckNoWeight.items

		deleteItem temp sel

		Xr_Btn_SkinCheckNoWeight.items = temp
		
		Get_NumberBones ()
		
		UnSkinBoneId ()

		ChangeBoneName un_id
		
		ShowBone()
		
		skin_num = 0
		)
	
	on Xr_Btn_SkinCheckNoWeight rightClick sel do  ---右击删除
	(
		local a_index = (un_id[Xr_Btn_SkinCheckNoWeight.selection]).index

		skinOps.removebone objSkin a_index
		
		temp = Xr_Btn_SkinCheckNoWeight.items

		deleteItem temp sel

		Xr_Btn_SkinCheckNoWeight.items = temp
		
		Get_NumberBones ()
		
		UnSkinBoneId ()

		ChangeBoneName un_id
		
		ShowBone()

		skin_num = 0
		)
		
	on Xr_Btn_Quick_Remove pressed do  ---快速移除
	(
		
		max modify mode
		
		for i =un_id.count to 1 by -1 do
		(
			local a_id = un_id[i].index
			modPanel.setCurrentObject objSkin ---选择蒙皮层
			skinOps.removebone objSkin a_id
			QR_bar.value = 100-100.*i/un_id.count
		)
		
		Get_NumberBones () ---检查蒙皮骨骼数
				
		UnSkinBoneId () ---查找无权重骨骼ID

		ChangeBoneName un_id ---转换ID骨骼名
		
		ShowBone() ---显示

		skin_num = 0
		
		QR_bar.value = 0
		)
		
	on Xr_Btn_Batch_Remove_0.001 pressed do  ---去除0.001位
	(
		val_num =100
		if selection.count == 1 then	
		(
			Get_NumberBones ()
			SkinBoneId ()
		)
		else
		(
			messageBox "选择单个模型 "
			)
	)
	
	on Xr_Btn_Batch_Remove_0.01 pressed do ---去除0.01位
	(
		val_num =10
		if selection.count == 1 then	
		(
			Get_NumberBones ()
			SkinBoneId () 
			)
		else
		(
			messageBox "选择单个模型 "
			)
		)
		
)
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
		vcheck = maxversion()
		if vcheck[1]>16000 then
		(
				makeDir @"C:\Maxscript_XrTools\Conf\" all:true
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
		else(messageBox "15以下无法导出   .")
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
	seledVertexs = yunGetvertsSkinOrPoly()  -----当前选择的点儿
	if seledVertexs.count<3 then (messageBox "请最少选择三个点")
	else
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
	)
	
on yunSkinOther_crowSelVert_big pressed do
	(
	undo on
	(
	seledVertexs = yunGetvertsSkinOrPoly()  -----当前选择的点儿
	if seledVertexs.count<3 then (messageBox "请最少选择三个点")
	else
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
	)
on yunSkinOther_GrowSelVert_up pressed do
	(
	undo on
	(
	seledVertexs = yunGetvertsSkinOrPoly()  -----当前选择的点儿
	if seledVertexs.count<3 then (messageBox "请最少选择三个点")
	else
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
	)
	
on yunSkinOther_GrowSelVert_down pressed do
	(
		undo on
		(
		seledVertexs = yunGetvertsSkinOrPoly()  -----当前选择的点儿
	if seledVertexs.count<3 then (messageBox "请最少选择三个点")
	else
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


Xr_SkinTools_UI = newRolloutFloater "Xr_Skin" 210 550
addRollout Xr_WeightTool Xr_SkinTools_UI
addRollout Xr_SkinBrush Xr_SkinTools_UI
addRollout Xr_SkinCheck Xr_SkinTools_UI
addRollout yunSkinToolWin Xr_SkinTools_UI
addRollout yunSkinOtherWin Xr_SkinTools_UI
Xr_WeightTool.open =   true
Xr_SkinBrush.open = false
Xr_SkinCheck.open = false
yunSkinToolWin.open = false
yunSkinOtherWin.open = false


