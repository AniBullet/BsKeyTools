

SwordTrailVersion = "2.5"





fn replaceAllstring str  findstr  replaceStr =
(
	local newStr= copy str
	if findstr.count == 0 do return newStr
	
	count = 0
	while true do
	(
		if keyboard.escPressed do exit
		if count > 1000 do exit
		count += 1	
		
		f = findstring  newStr  findstr
		if f != undefined then
		(
			newStr = replace newStr  f findstr.count  replaceStr
		)
		else exit
	)
	newStr				-- 최종적으로 return
)



fn getScriptStr =
(
"
lengthSegs = ##lengthSegs
widthSegs = ##widthSegs
pObj1 = ##pObj1
pObj2 = ##pObj2
mnode = ##mnode
interp = ##interp
interpSegs = ##intpSegs
dependsOn pObj1 pObj2

fn Linear v0 v1 t =
(
	v0 * (1.0 - t) + v1*t
)

fn getAniFramePos  obj  iFrame =
(
	cpos = animate off
	(
		at time iFrame obj.pos
	)
	cpos
)

fn setMidVerts  mnode  firstVert    firstPos  endPos  =
(
	xStep = 1.0 / widthSegs
	
	for i in 1 to widthSegs-1 do
	(
		mid= firstVert + i
		
		midPos = Linear  firstPos  endPos  (xStep*i)
 		setvert mnode  mid  midPos
	)

)


firstArray = #()
endArray = #()
intpArray = #()

for j in 1 to lengthSegs+1 do
(
	
	first = (widthSegs+1) * (j-1) + 1
	end = (widthSegs+1) * j
	
	first += (widthSegs+1) * (interp*(j-1))
	end += (widthSegs+1) * (interp*(j-1))
	
-- 	format \"%: % %\\n\" j  first  end


	append firstArray first
	append endArray end
	

	for i in 1 to interp do
	(
		intpFirst = first + (widthSegs+1)*i		
		intpEnd = end + (widthSegs+1)*i
		
		append  intpArray [intpFirst, intpEnd]
	)

	-- get Sword Position for Trail
	firstPos = getAniFramePos  pObj1  (slidertime-j+1)
 	setvert mnode  first  firstPos
	endPos = getAniFramePos  pObj2  (slidertime-j+1)
 	setvert mnode  end  endPos


	setMidVerts  mnode  first  firstPos  endPos
)





----------- interpolation --------------------------------

fn CatmullRom t p1 p2 p3 p4 =
(
	t2 = t * t
	t3 = t2 * t
	x = 0.5 * ((2.0*p2.x) + (-p1.x+p3.x)*t + (2.0*p1.x - 5.0*p2.x + 4*p3.x - p4.x)*t2 + (-p1.x + 3.0*p2.x - 3.0*p3.x + p4.x)*t3)
	y = 0.5 * ((2.0*p2.y) + (-p1.y+p3.y)*t + (2.0*p1.y - 5.0*p2.y + 4*p3.y - p4.y)*t2 + (-p1.y + 3.0*p2.y - 3.0*p3.y + p4.y)*t3)
	z = 0.5 * ((2.0*p2.z) + (-p1.z+p3.z)*t + (2.0*p1.z - 5.0*p2.z + 4*p3.z - p4.z)*t2 + (-p1.z + 3.0*p2.z - 3.0*p3.z + p4.z)*t3)
	
	[x, y, z]
)



idx = 0
for i in 1 to firstArray.count-1 do
(
	local p1,p2,p3,p4
	
	if i-1 < 1 then
		p1 = firstArray[i]
	else
		p1 = firstArray[i-1]
	p2 = firstArray[i]
	p3 = firstArray[i+1]
	if i+2 > firstArray.count then
		p4 = firstArray[i+1]
	else
		p4 = firstArray[i+2]
		
	if i-1 < 1 then
		e1 = endArray[i]
	else
		e1 = endArray[i-1]
	e2 = endArray[i]
	e3 = endArray[i+1]
	if i+2 > endArray.count then
		e4 = endArray[i+1]
	else
		e4 = endArray[i+2]
		
	
-- 	format \"% % % %\\n\"  p1 p2 p3 p4
	pp1 = getvert mnode p1
	pp2 = getvert mnode p2
	pp3 = getvert mnode p3
	pp4 = getvert mnode p4
	
	ee1 = getvert mnode e1
	ee2 = getvert mnode e2
	ee3 = getvert mnode e3
	ee4 = getvert mnode e4
	

	val = 0.0
	step = 1.0 / (interp+1)
	for j in 1 to interp do
	(
		val += step
		idx += 1
		
		firstPos = CatmullRom val  pp1 pp2 pp3 pp4
		setvert mnode  intpArray[idx].x  firstPos
		
		endPos = CatmullRom val  ee1 ee2 ee3 ee4
		setvert mnode  intpArray[idx].y  endPos
		
		setMidVerts  mnode  intpArray[idx].x  firstPos  endPos
		
	)
)



update mnode

[0,0,0]
"
)	
	


fn makeTrail  pObj1  pObj2  lengthSegs  widthSegs  interp =
(	
	local interpSegs = 0
	
	interpSegs = lengthSegs * (interp+1)

	
	
	----------- create verts ----------------------
	x = 0
	y = 0
	verts = #()
	for i in 1 to (interpSegs+1) do
	(
		for j in 1 to (widthSegs+1) do
		(
			x = (j-1) * 10
			y = (i-1) * 10
			append verts [x, y, 0] 
		)
		
	)

	-- delete $point*
	-- for i in verts do
	-- 	point pos:i  size:2


	----------- create faces ----------------------
	faces = #()
	x = widthSegs + 1
	y = 0
	z = x + 1
	for i in 1 to widthSegs*interpSegs do
	(
		if mod i widthSegs == 1 and i > 1 do
		(
			x += 1
			y += 1
			z += 1
		)
		
		x += 1
		y += 1
		z += 1
		face1 = [x, y, z]
		append faces  face1
		face2 = [y+1, z, y]
		append faces face2

	-- 	format "faces %  %\n"  face1 face2
	)



	----------- create tvertArray ----------------------


	x = 0
	y = 0
	tvertArray = #()
	xStep = 1.0 / widthSegs
	yStep = 1.0 / interpSegs
	for i in 1 to (interpSegs+1) do
	(
		for j in 1 to (widthSegs+1) do
		(
			x = xStep * (j-1)
			y = yStep * (i-1)
			append tvertArray [x, y, 0]
		)
	)






	----------- built mesh ----------------------

	mnode = mesh vertices:verts  faces:faces  tverts:tvertArray
	mmesh = mnode.mesh

	buildTVFaces mmesh 
	for i = 1 to mmesh.numfaces do (setTVFace mmesh i (getFace mmesh i))
	mnode.name = uniqueName "SwordTrail_node"

		
		
		

	----------- invisible edges ----------------------
	for i in 1 to mnode.faces.count do
	(
		setEdgeVis mnode i 2 off
	)
	update mnode

	completeRedraw()



	----------- make dummy ----------------------
	dummyName = uniqueName "SwordTrail_dummy"
	dumHelper = dummy size:1 name:dummyName
	dumHelper.pos.controller = position_script()
	dumHelper.parent = pObj2






	----------- setup position script controller ----------------------

	scriptStr = getScriptStr()
	scriptStr = replaceAllstring scriptStr   "##lengthSegs"  (lengthSegs as string)
	scriptStr = replaceAllstring scriptStr   "##widthSegs"  (widthSegs as string)
	scriptStr = replaceAllstring scriptStr   "##pObj1"  ("$" + pObj1.name)
	scriptStr = replaceAllstring scriptStr   "##pObj2"  ("$" + pObj2.name)
	scriptStr = replaceAllstring scriptStr   "##mnode"  ("$" + mnode.name)
	scriptStr = replaceAllstring scriptStr   "##interp"  	(interp as string)
	scriptStr = replaceAllstring scriptStr   "##intpSegs"  (interpSegs as string)

	dumHelper.pos.controller.script = scriptStr
	
	
	setUserProp mnode "SwordTrail_dummy" (dumHelper.name as name)
)







---------------------------------  UI  ----------------------------------------------
rollout Trail_roll  "Main"
(
	local pointObj1 = undefined
	local pointObj2 = undefined
	
	fn point_filt obj = classof obj == Point
		
	pickbutton pick_pb1 "Pick Point 1" width:180 filter:point_filt  autoDisplay:true
	pickbutton pick_pb2 "Pick Point 2" width:180 filter:point_filt  autoDisplay:true
	spinner length_spi "LengthSegs "  range:[1,1000,10] pos:[80,70] width:70  type:#integer
	spinner width_spi "WidthSegs "  range:[1,1000,2] pos:[80,100] width:70  type:#integer
	spinner interpolation_spi "Interpolation "  range:[0,100,1] pos:[80,130] width:70  type:#integer
	button create_btn "Create !!"  width:180  offset:[0,20]
	
	on pick_pb1 picked obj  do
	(
		pointObj1 = obj
	)
	on pick_pb2 picked obj do
	(
		pointObj2 = obj
	)

	
	on create_btn pressed do
	(
		if pointObj1 == undefined do return undefined
		if pointObj2 == undefined do return undefined
		
		clearListener()
		makeTrail  pointObj1  pointObj2  length_spi.value  width_spi.value   interpolation_spi.value
	)
)

rollout Etc_roll "Etc"
(
	button delAll_btn "Delete Trails"
	
	on delAll_btn pressed do
	(
		delete $SwordTrail*
	)
	
	on Etc_roll open do
	(
		clearListener()
	)
)







rollout Bake_roll "Bake to Mesh"
(
	spinner start_spi "Start"  range:[-100000,100000,0] type:#integer  pos:[20,20]  width:80
	spinner end_spi "End"  range:[-100000,100000,100]  type:#integer pos:[115,20]  width:80
	button bake_btn "Bake" width:100 offset:[0,10]
	
	fn bakeToAniMesh obj  start end =
	(
		if superclassof obj != GeometryClass do return undefined
		if findstring obj.name "SwordTrail_node" == undefined  do return undefined
		
		smesh = snapshotAsMesh  obj
		uname = uniqueName "SwordTrail_mesh"
		newMesh = mesh mesh:smesh name:uname
		vertNum_obj = getnumverts newMesh

		animateVertex newMesh #all

		animate off
		(
			for t in start to end by 1 do
				at time t
				(
					sliderTime = t

					for i in 1 to vertNum_obj do
					(
						smesh = snapshotAsMesh  obj
						vert = getvert smesh i
						
						vertName = ("Vertex_" + i as string) as name
						vertCon = getPropertyController newMesh vertName
						key = addNewKey  vertCon t
						key.value = vert
						
					)
				)
		)

		gc light:on
		newMesh
	)

	on bake_btn pressed do
	(
		sels = selection as array

		delsObjs = #()
		for o in sels do
		(
			newObj = bakeToAniMesh o  start_spi.value  end_spi.value
			if newObj != undefined do
			(
				dumStr = getUserProp o "SwordTrail_dummy"
				if dumStr != undefined do
				(
					dumStr = (filterString dumStr "#")[1]
					dumObj = getNodeByName dumStr					
-- 							format "% %\n" dumStr dumObj
					append delsObjs dumObj
					append delsObjs o
					
					newObj.material = o.material
				)
			)
		)
		
		delete delsObjs
	)
	
)

try( closeRolloutFloater  SwordTrailFloater )catch()
titleTxt = "SwordTrail  " + SwordTrailVersion
SwordTrailFloater = newRolloutFloater titleTxt 220 400
addRollout Trail_roll  SwordTrailFloater
addRollout Etc_roll  SwordTrailFloater
addRollout Bake_roll  SwordTrailFloater

