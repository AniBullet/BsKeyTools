(
global roll_mirrormorph
try(destroyDialog roll_mirrormorph)catch()
function getMirrorData = ()
function mirrorMorph = ()
local rightAr=#()
local leftAr=#()
local centerAr=#()
local tempAr=#()
local mySourceObject
local myTargetObject
local un = false
rollout roll_mirrormorph "Mirror Morph"
(
	--pickbutton pcbSourceObject "--source object--" width:140 height:25
	button btnGetData "拾取 Morpher 物体" width:140 height:25
	radiobuttons rdbVert labels:#("所有顶点","所选顶点") align:#left default:2
	group "镜像轴"
	(
		radiobuttons rdbMirrorAxis labels:#("X","Y","Z")
 	)
	spinner spnTreshhold "阈值" range:[0,10000,0.01]
	group "顶点"
	(
		label lblLeft "左" align:#left
		label lblCenter "中" align:#left
		label lblRight "右" align:#left
	)
	--pickbutton pcbTargetObject "--target object--" width:140 height:25 enabled:false
	label lblTargetObject "选择提取的 Target 物体"
	button btnMirror "镜像" width:140 height:25 enabled:false
	button btnSymmetry "对称" width:140 height:25 enabled:false
	label lbl "--------------------------------------------" 
	label lblInfo "从源对象获取数据" offset:[0,-5]
	/*on pcbSourceObject picked obj do
	(
		if obj != undefined do
		(
			lblInfo.text = "calculating..."
			if rdbVert.state == 1 then bAll = true else bAll = false
			pcbSourceObject.text = obj.name
			mySourceObject = obj
			arr = getMirrorData threshold:(spnTreshhold.value) all:bAll
			lblLeft.text = "left :" + arr[1] as string
			lblCenter.text = "center :" + arr[2] as string
			lblRight.text = "right :" + arr[3] as string
			pcbTargetObject.enabled = true
			if arr[2] == 0 then lblInfo.text = "0 vertices in center?"
			else
			lblInfo.text = "done. pick target object"
		)
	)*/
	on btnGetData pressed do
	(
		if $ != undefined then
		(
			if classOf $ == Editable_Poly then
			(
				lblInfo.text = "计算中..."
				if rdbVert.state == 1 then bAll = true else bAll = false
				btnGetData.text = "源数据: " + $.name
				mySourceObject =$
				arr = getMirrorData threshold:(spnTreshhold.value) all:bAll
				lblLeft.text = "左 :" + arr[1] as string
				lblCenter.text = "中 :" + arr[2] as string
				lblRight.text = "右 :" + arr[3] as string
				btnMirror.enabled = true
				btnSymmetry.enabled = true
				if arr[2] == 0 then lblInfo.text = "0 顶点在中间?"
				else
				lblInfo.text = "完成。选择目标对象"
			) else lblInfo.text = "必须选中 editable poly 层"
		) else lblInfo.text = "选择源对象"
		
	)
	on pcbTargetObject picked obj do
	(
		if obj != undefined do
		(
			pcbTargetObject.text = obj.name
			myTargetObject = obj
			btnMirror.enabled = true
		)
	)
	on btnMirror pressed do
	(
		if $ != undefined then
		(
			if classOf $ == Editable_Poly then
			(
				if $ == mySourceObject then
				(
					lblInfo.text = "目标物体与源物体相同"
				)
				else
				(
					if un == true do (max undo;un = false)
					lblInfo.text ="计算中..."
					myTargetObject = $
					mirrorMorph symmetry:false
					lblInfo.text = "完成"
				)
			) else lblInfo.text = "必须选中 editable poly 层"
		) else lblInfo.text = "选择目标物体"
	)--end btnMirror
	on btnSymmetry pressed do
	(
		if $ != undefined then
		(
			if classOf $ == Editable_Poly then
			(
				if $ == mySourceObject then
				(
					lblInfo.text = "目标物体与源物体相同"
				)
				else
				(
					lblInfo.text ="计算中..."
					--check is already pressed
					if un == true do (max undo;mirrorMorph symmetry:false)
					un = true
					
					myTargetObject = $
					mirrorMorph symmetry:true
					lblInfo.text = "完成"
				)
			) else lblInfo.text = "必须选中 editable poly 层"
		) else lblInfo.text = "选择目标物体"
	)--end btnSymmetry
	on roll_mirrormorph help do
	(
		print "help"
	)
)
createDialog roll_mirrormorph 150 style:#(#style_toolwindow,#style_sysmenu)

/*
min -- the modifier context's bounding box min coordinate 	 
max -- the modifier context's bounding box max coordinate 	 
center -- the modifier context's bounding box center coordinate 	 
extent -- the modifier context's bounding box extent or size  
*/
fn getMirrorData threshold:0.01 all:true =
(
	rightAr=#()
	leftAr=#()
	centerAr=#()
	tempAr=#()
	
	baseObj=mySourceObject.baseObject
	vertSel=(polyOp.getVertSelection baseObj)as array
	totalVertNumber = polyop.getNumVerts baseObj
	-- Al vertices
	if all then
	(
		for i = 1 to totalVertNumber do
		(
			in coordsys local
			pos=polyOp.getVert baseObj i
			if roll_mirrormorph.rdbMirrorAxis.state == 1 do posAxis = pos.x
			if roll_mirrormorph.rdbMirrorAxis.state == 2 do posAxis = pos.y
			if roll_mirrormorph.rdbMirrorAxis.state == 3 do posAxis = pos.z
			
			if posAxis < -threshold then 
			(
				append rightAr i
			)
			if posAxis < threshold and posAxis > -threshold then
			(
				append centerAr i
			)
			if posAxis > threshold then 
			(
				append tempAr i
			)
		)
	)
	-- Selected vertices
	else
	(
		for i = 1 to vertSel.count do
		(
			in coordsys local
			pos=polyOp.getVert baseObj vertSel[i]
			if roll_mirrormorph.rdbMirrorAxis.state == 1 do posAxis = pos.x
			if roll_mirrormorph.rdbMirrorAxis.state == 2 do posAxis = pos.y
			if roll_mirrormorph.rdbMirrorAxis.state == 3 do posAxis = pos.z		
			if posAxis < -threshold then 
			(
				append rightAr vertSel[i]
			)
			if posAxis < threshold and posAxis > -threshold then
			(
				append centerAr vertSel[i]
			)
			if posAxis > threshold then 
			(
				append tempAr vertSel[i]
			)
		)
	)
	
	for i in rightAr do
	(
		pos=polyOp.getVert baseObj i
		found=false
		for c = 1 to tempAr.count do
		(
			
			if roll_mirrormorph.rdbMirrorAxis.state == 1 do transformAxis = [-1,1,1]
			if roll_mirrormorph.rdbMirrorAxis.state == 2 do transformAxis = [1,-1,1]
			if roll_mirrormorph.rdbMirrorAxis.state == 3 do transformAxis = [1,1,-1]
			
			cPos=(polyOp.getVert baseObj tempAr[c])*transformAxis
			dist=distance cPos pos
			if dist<threshold then
			(
				append leftAr tempAr[c]
				deleteItem tempAr c
				found=true
				exit
			)
		)
		if found==false then append leftAr undefined
	)
	return #(leftAr.count,centerAr.count,rightAr.count)
)

fn mirrorMorph symmetry:false=
(
	undo on
	(
		if roll_mirrormorph.rdbMirrorAxis.state == 1 do transformAxis = [-1,1,1]
		if roll_mirrormorph.rdbMirrorAxis.state == 2 do transformAxis = [1,-1,1]
		if roll_mirrormorph.rdbMirrorAxis.state == 3 do transformAxis = [1,1,-1]
		--select myTargetObject
		for i = 1 to rightAr.count do
		(
			if leftAr[i]!=undefined do
			(
				Rpos=polyOp.getVert myTargetObject rightAr[i] node:myTargetObject
				if symmetry==false then Lpos=polyOp.getVert myTargetObject leftAr[i] node:myTargetObject
				polyOp.setVert myTargetObject leftAr[i] (((Rpos-myTargetObject.pos)*transformAxis)+myTargetObject.pos) node:myTargetObject
				if symmetry==false then polyOp.setVert myTargetObject rightAr[i] (((Lpos-myTargetObject.pos)*transformAxis)+myTargetObject.pos) node:myTargetObject
			)
		)
		if symmetry==false then
		(
			for i = 1 to centerAr.count do
			(
				Cpos=polyOp.getVert myTargetObject centerAr[i] node:myTargetObject
				polyOp.setVert myTargetObject centerAr[i] (((Cpos-myTargetObject.pos)*transformAxis)+myTargetObject.pos) node:myTargetObject
			)
		)else
		(
			if roll_mirrormorph.rdbMirrorAxis.state == 1 do centerAxis = [0,1,1]
			if roll_mirrormorph.rdbMirrorAxis.state == 2 do centerAxis = [1,0,1]
			if roll_mirrormorph.rdbMirrorAxis.state == 3 do centerAxis = [1,1,0]
			
			for i = 1 to centerAr.count do
			(
				Cpos=polyOp.getVert myTargetObject centerAr[i] node:myTargetObject
				polyOp.setVert myTargetObject centerAr[i] (((Cpos-myTargetObject.pos)*centerAxis)+myTargetObject.pos) node:myTargetObject
			)
		)
	)
)
)









