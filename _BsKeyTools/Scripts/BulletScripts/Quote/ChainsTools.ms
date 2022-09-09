/*
CHAIN TOOLS

Version 1.3
Author: Felix Joleanes
web:    www.joleanes.com
email:  felix@joleanes.com

Tool useful to create a chain of bones attached to a spline, using position and lookat constraints
from the bones to helpers which have path constraints with the spline as target, offset values can be aplied.
It can create an extra chain with a spline ik solver to control stretching.
The spline can also be constrainted to helper objects usin the Spline IK Control or the skin Modifier.

Usage: Select a spline to create a chain, and press "Create by Spline, or select a group of objects
to create a chain and press "Create by objects" (the selection order is used to create the chain)
*/

-- macroScript chainTools
-- 	category:"Custom tools"
-- 	icon:#("Max_Edit_Modifiers", 11)
	
-- (
try(destroyDialog rollCreateChain)catch()
--Here is the rollout with all the functions and UI controls  495
rollout rollCreateChain "Create Chain_v1.32" width:210 height:515
(
  /*Function fnCreateChain:
  Creates the bones of the chain, its helpers, controllers and constraints.
  it receives 10 arguments. The first argument (obj) is the spline to constraint the bones and helpers to.
  nBones, the number of bones to create in the chain. WidthVar, taperVar, and SquashBool are the Bone's
  settings. The RotationAverage defines if the Helper points are gonna be constrainted to extra helpers and how,
  the IKSolverBool controls if it needs to create an extra chain with a Spline IK solver to avoid stretching.
  (Helper_Start, Helper_End) to control the chain orientation gradually. The ManCtrlsBool defines if 
  the helper points will have extra position-rotation controllers for manual adjustments. And the OffsetRange
  is the helpers' offset in respect to the spline. */
function fnCreateChain splineNode ControlsArray nBones widthVar taperVar SquashBool LookAtType \
								RotationAverage ManCtrlsBool IKSolverBool=
(
	 --some variables
	local BoneArray=#()
	local SplineChainDef
	local rotScriptCtrl
	local lengthVar=curveLength splineNode
	local HelperArray=#()
	local RootHelper=point centerMarker:false axisTripod:false cross:false box:true size:(widthVar*5) wirecolor:blue name:"Helper_Chain_Root"
	RootHelper.transform=ControlsArray[1].transform
	ControlsArray.parent=RootHelper
	local prevBoneVar=RootHelper
	
	 --First loop, it creates each bone and defines its settings, it creates also its respective
	 --helper and the controller to attach the bone to the helper (position constraint)
	for i=1 to nBones+1 do
	(
		BoneVar=bonesys.createBone [(lengthVar*(i-1)/nBones),0,0] [(lengthVar*i/nBones),0,0] [0,0,1]
		BoneVar.name="Bone_Chain_"+(i as string)
		BoneVar.parent=prevBoneVar
		BoneVar.taper=taperVar
		BoneVar.width=widthVar
		BoneVar.height=boneVar.width
		BoneVar.boxmode = true
		HelperVar=point centerMarker:false axisTripod:false cross:false box:true size:(widthVar*1.5) wirecolor:blue name:("Helper_ChainPoint_"+(i as string))
		HelperVar.position=BoneVar.position
		--HelperVar.rotation=RootHelper.rotation
		BoneVar.position.controller=position_constraint()
		BoneVar.position.controller.appendTarget HelperVar 100
		prevBoneVar=BoneVar
		append BoneArray BoneVar
		append HelperArray HelperVar
	)
	--Here are some special settings for the End Bone
	BoneArray[nBones+1].taper=100
	BoneArray[nBones+1].width=BoneArray[nBones+1].width/2
	BoneArray[nBones+1].height=BoneArray[nBones+1].width
	BoneArray[nBones+1].length=BoneArray[nBones+1].width
	--If squash option active:
	if SquashBool then BoneArray.boneScaleType=#squash
		
	if (RotationAverage[3]==3) or IKSolverBool then
	(
		local defString="Attributes SplineChain\n(\n\tparameters SCParams rollout:SCRoll\n\t("
		local defParamString=""
		local defRollString=""
		if (RotationAverage[3]==3) then
		(
			defParamString+="\n\t\tRoll type:#float default:0 ui:UIRoll"
			defRollString+="\n\t\tspinner UIRoll \"Roll:\" range:[-999999999,999999999,0]"
		)
		if IKSolverBool then
		(
			defParamString+="\n\t\tStretch type:#float default:0 ui:UIStretch"
			defRollString+="\n\t\tspinner UIStretch \"Stretch Percent:\" range:[0,100,0] scale:0.5"
		)
		defString+=defParamString+"\n\t)"
		defString+="\n\trollout SCRoll \"Spline Chain Control\"\n\t("
		defString+=defRollString+"\n\t)\n)"
		
		local CtrlModifier=EmptyModifier()
		CtrlModifier.name="Control"
		custAttributes.add CtrlModifier (execute(defString))
		addModifier RootHelper CtrlModifier
		addModifier ControlsArray CtrlModifier
	)
		
	--Remove Helper's inheritance 
	if ((LookAtType==2) or (RotationAverage[1] and RotationAverage[2]==1 and RotationAverage[3]!=3)) then
			setInheritanceFlags HelperArray #{7,8,9}
	
	--This loop assigns the path_constraint to the helper objects
	for i=1 to HelperArray.count do
	(
		HelperArray[i].position.controller=path_constraint()
		HelperArray[i].position.controller.appendTarget splineNode 100
		deletekeys HelperArray[i].position.controller.percent.controller
		--the helper's percent over the spline depends on its position over the chain
		HelperArray[i].position.controller.percent=100*(i-1)/nBones as float
	)
	
	if IKSolverBool or ManCtrlsBool then
		for i=1 to (nBones+1) do
			HelperArray[i].position.controller=position_list()
	
	HelperArray.parent=RootHelper
	
	/*If the IKSolver option is active It creates an extra chain of	helper objects with a spline ik 
	solver to the same spline, also creates the position constraints of the previosly created objects with
	these new helpers as targets and creates an expression_controller to control the weight of the position 
	constraint. This expression controller has a variable "value" that will need to be assigned by the user 
	to a spinner or a slider, it has to be done only once because all the weight controllers are instanced.*/
	if IKSolverBool then
	(
		local FirstHelperIK, LastHelperIK
		prevHelperIK=undefined
		WeightController=float_script()
		RootHelper.modifiers[1].SplineChain.Stretch.controller=bezier_float()
		WeightController.addTarget "Value" RootHelper.modifiers[1].SplineChain.Stretch.controller
		WeightController.script= "1-(Value/100)"
		for i=1 to HelperArray.count do
		(
			HelperIKSolver=point centerMarker:false axisTripod:false cross:true box:false size:(widthVar*0.5) wirecolor:blue name:("Helper_IKSolverPoint_"+(i as string))
			HelperIKSolver.parent=prevHelperIK
			HelperIKSolver.position=[lengthVar*(i-1)/nBones,0,0]
			HelperArray[i].position.controller[2].controller=position_constraint()
			HelperArray[i].position.controller[2].controller.appendTarget HelperIKSolver 100
			HelperArray[i].position.controller.weights[2].controller=WeightController
			if i==1 then FirstHelperIK=HelperIKSolver
			if i==HelperArray.count then LastHelperIK=HelperIKSolver
			prevHelperIK=HelperIKSolver
		)
		SplineIK=IKSys.IKChain FirstHelperIK LastHelperIK "SplineIKSolver"
		SplineIK.controller.pickShape=splineNode
		SplineIK.controller.goalSize=widthVar
		FirstHelperik.position.controller=path_constraint()
		FirstHelperik.position.controller.appendTarget splineNode 100
	)
	--if the manipulation controllers option is active then create an extra position_xyz controller for manual adjustments
	if ManCtrlsBool then
	(
		for i=1 to HelperArray.count do
		(
			HelperArray[i].position.controller.available.controller=position_xyz()
			HelperArray[i].position.controller.active=HelperArray[i].position.controller.count
		)
	)
	
	--if Look At Type equals LookAt Constraint, constraints each bone to the next level helper object
	--and use the current level helper as upNode
	if LookAtType==1 then	
	(
		--If the Average Constraint option is active then constraints the helpers to an average defined by the user
		--(by First and Last Control Objects, All Control Objects or Spinner)
		if RotationAverage[1] then
		(
			case RotationAverage[3] of
			(
				--if "Average To" equals First and Last controls
				1:
				(
					 --If "Average Type" equals Orientation Constraint
					if RotationAverage[2]==1 then
					(
						for i=1 to nBones do
						(
							HelperArray[i].rotation.controller=orientation_constraint()
							--The weights in the orientation constraint depends on the helper's position in the chain
							HelperArray[i].rotation.controller.appendTarget ControlsArray[1] (100*(nBones-i)/(nBones-1) as float)
							HelperArray[i].rotation.controller.appendTarget ControlsArray[ControlsArray.count] (100*(i-1)/(nBones-1) as float)
						)
					)
					--If Average Type equals Euler Angles Average
					else
					(
						for i=1 to nBones do
						(
							HelperArray[i].rotation.controller=rotation_script()
							HelperArray[i].rotation.controller.addObject "rotA" ControlsArray[1].rotation.controller
							HelperArray[i].rotation.controller.addObject "rotB" ControlsArray[ControlsArray.count].rotation.controller
							HelperArray[i].rotation.controller.script="rotX= (rotA.x_rotation*"+(((nBones-i)/(nBones-1) as float) as string)+"+rotB.x_rotation*"+(((i-1)/(nBones-1) as float)as string)+")\n"+
																				"rotY= (rotA.y_rotation*"+(((nBones-i)/(nBones-1) as float) as string)+"+rotB.y_rotation*"+(((i-1)/(nBones-1) as float)as string)+")\n"+
																				"rotZ= (rotA.z_rotation*"+(((nBones-i)/(nBones-1) as float) as string)+"+rotB.z_rotation*"+(((i-1)/(nBones-1) as float)as string)+")\n"+
																				"eulerangles rotX rotY rotZ"
						)
					)
				)
				--if "Average to" equals All controls
				2:
				(
					--If "Average Type" equals Orientation Constraint
					if RotationAverage[2]==1 then
					(
						 --Loops throught the Control Objects and constraint the bones between them (the weight is a static value in respect percent by number of controls 
						 --instead dynamic distance calculation)
						m =(ControlsArray.count-1)
						l=nBones/m as float
						for j=1 to m do
						(
							for i=(ceil ((j-1)*l+1)) to (ceil (j*l)) do
							(
								HelperArray[i].parent=RootHelper
								HelperArray[i].rotation.controller=orientation_constraint()
								--The weights in the orientation constraint depends on the helper's position in the chain
								HelperArray[i].rotation.controller.appendTarget ControlsArray[j] (100*(j-(i-1)/l as float))
								HelperArray[i].rotation.controller.appendTarget ControlsArray[(j+1)] (100*((i-1)-(j-1)*l)/l as float)
							)
						)
					)
					--If Average Type equals Euler Angles Average
					else
					(
						m =(ControlsArray.count-1)
						l=nBones/m as float
						for j=1 to m do
						(
							for i=(ceil ((j-1)*l+1)) to (ceil (j*l)) do
							(
								HelperArray[i].parent=RootHelper
								HelperArray[i].rotation.controller=rotation_script()
								HelperArray[i].rotation.controller.addObject "rotA" ControlsArray[j].rotation.controller
								HelperArray[i].rotation.controller.addObject "rotB" ControlsArray[j+1].rotation.controller
								HelperArray[i].rotation.controller.script="rotX= (rotA.x_rotation*"+((j-(i-1)/l as float) as string)+"+rotB.x_rotation*"+((((i-1)-(j-1)*l)/l as float) as string)+")\n"+
																				"rotY= (rotA.y_rotation*"+((j-(i-1)/l as float)as string)+"+rotB.y_rotation*"+((((i-1)-(j-1)*l)/l as float) as string)+")\n"+
																				"rotZ= (rotA.z_rotation*"+((j-(i-1)/l as float) as string)+"+rotB.z_rotation*"+((((i-1)-(j-1)*l)/l as float) as string)+")\n"+
																				"eulerangles rotX rotY rotZ"
							)
						)
					)
				)
				-- if "Average to" equals Spinner
				3:
				(
					RootHelper.modifiers[1].SplineChain.Roll.controller=bezier_float()
					for i=1 to nBones do
					(
						HelperArray[i].rotation.x_rotation.controller=float_script()
						HelperArray[i].rotation.x_rotation.controller.addTarget "rollValue" RootHelper.modifiers[1].SplineChain.Roll.controller
						HelperArray[i].rotation.x_rotation.controller.script="degtorad rollValue*"+(((i-1)/(nBones-1) as float) as string)
					)
				)
			)
		)
		--if the manipulation controllers option is active then create an extra euler_xyz controller for manual adjustments
		if ManCtrlsBool and RotationAverage[1] then
		(
			for i=1 to HelperArray.count do
			(
				HelperArray[i].rotation.controller=rotation_list()
				HelperArray[i].rotation.controller[2].controller=euler_xyz()
				HelperArray[i].rotation.controller.active=2
			)
		)
		for i=1 to nBones do
		(
			boneArray[i].rotation.controller=lookAt_constraint()
			boneArray[i].rotation.controller.appendTarget helperArray[(i+1)] 100
			boneArray[i].rotation.controller.lookat_vector_length=0
			boneArray[i].rotation.controller.pickupnode=helperArray[i]
			boneArray[i].rotation.controller.upnode_world=false
		)
	)
	--if Look At Type Equals Quaternion Aim,constraints each bone to the current level helper
	--the helper will do all the job with the quaternion script controller
	else
	(
		setTransformLockFlags HelperArray #{5,6,7,8,9}
		local quatScriptCtrl
		local scriptString="posThis=posThisCtrl.value*inverse nodeParent.transform\n"+
								"posTarget=posTargetCtrl.value*inverse nodeParent.transform\n"+
								"vector=posTarget-posThis\n"+
								"axis=normalize (cross vector [1,0,0])\n"+
								"angle=acos (normalize vector).x\n"
		if ManCtrlsBool then
		(
			for i=1 to HelperArray.count do
			(
				HelperArray[i].rotation.controller=rotation_list()
				HelperArray[i].rotation.controller[2].controller=euler_xyz()
				HelperArray[i].rotation.controller.active=2
			)
			quatScriptCtrl=rotation_script()
			helperArray[1].rotation.controller[1].controller=quatScriptCtrl
			quatScriptCtrl.addNode "nodeParent" RootHelper
			quatScriptCtrl.addObject "posTargetCtrl" helperArray[2].position.controller
			quatScriptCtrl.addObject "posThisCtrl" helperArray[1].position.controller
			quatScriptCtrl.script=scriptString+"(quat angle axis)*nodeParent.transform.rotation"
			scriptString+="(quat rotX [1,0,0])*(quat angle axis)*nodeParent.transform.rotation"
			for i=2 to nBones do
			(
				quatScriptCtrl=rotation_script()
				helperArray[i].rotation.controller[1].controller=quatScriptCtrl
				quatScriptCtrl.addNode "nodeParent" helperArray[i-1]
				quatScriptCtrl.addObject "posTargetCtrl" helperArray[i+1].position.controller
				quatScriptCtrl.addObject "posThisCtrl" helperArray[i].position.controller
				quatScriptCtrl.addTarget "rotX" helperArray[i-1].rotation.controller[2].x_rotation.controller
				quatScriptCtrl.script=scriptString
			)
		)
		else
		(
			scriptString+="(quat angle axis)*nodeParent.transform.rotation"
			local prevHelper=RootHelper
			for i=1 to nBones do
			(
				quatScriptCtrl=rotation_script()
				helperArray[i].rotation.controller=quatScriptCtrl
				quatScriptCtrl.addNode "nodeParent" prevHelper
				quatScriptCtrl.addObject "posTargetCtrl" helperArray[i+1].position.controller
				quatScriptCtrl.addObject "posThisCtrl" helperArray[i].position.controller
				quatScriptCtrl.script=scriptString
				prevHelper=helperArray[i]
			)
		)
		--If the Average Constraint option is active then constraints the helpers to an average defined by the user
		--(by First and Last Control Objects, All Control Objects or Spinner)
		if RotationAverage[1] then
		(
			if not ManCtrlsBool then
				for i=1 to HelperArray.count do
					HelperArray[i].rotation.controller=rotation_list()
				
			case RotationAverage[3] of
			(
				--if "Average To" equals First and Last controls
				1:
				(
					 --If "Average Type" equals Orientation Constraint
					if RotationAverage[2]==1 then
					(
						rotScriptCtrl=rotation_script()
						rotScriptCtrl.addNode "nodeA" RootHelper
						rotScriptCtrl.addNode "nodeB" controlsArray[1]
						rotScriptCtrl.script="rot=quatToEuler (nodeB.transform*inverse nodeA.transform).rotation order:7\n"+
												   "quat (rot.x+rot.z) [-1,0,0]"
						HelperArray[1].rotation.controller.available.controller=rotScriptCtrl
						rotScriptCtrl=copy rotScriptCtrl
						rotScriptCtrl.setNode "nodeA" controlsArray[1]
						rotScriptCtrl.setNode "nodeB" controlsArray[controlsArray.count]
						for i=2 to nBones do
						(
							HelperArray[i].rotation.controller.available.controller=rotScriptCtrl
							HelperArray[i].rotation.controller.weight[HelperArray[i].rotation.controller.count]=100.0/(nBones-1)
						)
					)
					--If Average Type equals Euler Angles Average
					else
					(
						rotScriptCtrl=rotation_script()
						rotScriptCtrl.addTarget "rotXA" controlsArray[1].rotation.controller.x_rotation.controller
						rotScriptCtrl.script="quat rotXA [-1,0,0]"
						HelperArray[1].rotation.controller.available.controller=rotScriptCtrl
						rotScriptCtrl=copy rotScriptCtrl
						rotScriptCtrl.addTarget "rotXB" controlsArray[controlsArray.count].rotation.controller.x_rotation.controller
						rotScriptCtrl.script="quat ((rotXB-rotXA)*"+((1.0/(nBones-1)) as string)+") [-1,0,0]"		
						for i=2 to nBones do
							HelperArray[i].rotation.controller.available.controller=rotScriptCtrl
					)
				)
				--if "Average to" equals All controls
				2:
				(
					--If "Average Type" equals Orientation Constraint
					if RotationAverage[2]==1 then
					(
						 --Loops throught the Control Objects and constraint the bones between them (the weight is a static value in respect percent by number of controls 
						 --instead dynamic distance calculation)
						m =(ControlsArray.count-1)
						l=nBones/m as float
						rotScriptCtrl=rotation_script()
						rotScriptCtrl.addNode "nodeA" RootHelper
						rotScriptCtrl.addNode "nodeB" controlsArray[1]
						rotScriptCtrl.script="rot=quatToEuler (nodeB.transform*inverse nodeA.transform).rotation order:7\n"+
												   "quat (rot.x+rot.z) [-1,0,0]"
						HelperArray[1].rotation.controller.available.controller=rotScriptCtrl
						for j=1 to m do
						(
							difIter=((j-1)*l+1)
							minIter=(ceil difIter) 
							difIter=minIter-difIter
							maxIter=(ceil (j*l))
							if j!=1 then
							(
								HelperArray[minIter].rotation.controller.available.controller=rotScriptCtrl
								HelperArray[minIter].rotation.controller.weight[HelperArray[minIter].rotation.controller.count]=100.0*(1-difIter)/l
							)
							rotScriptCtrl=copy rotScriptCtrl
							rotScriptCtrl.setNode "nodeA" controlsArray[j]
							rotScriptCtrl.setNode "nodeB" controlsArray[j+1]
							if difIter!=0 then
							(
								HelperArray[minIter].rotation.controller.available.controller=rotScriptCtrl
								HelperArray[minIter].rotation.controller.weight[HelperArray[minIter].rotation.controller.count]=100.0*difIter/l
							)
							minIter+=1
							for i=minIter to maxIter do
							(
								HelperArray[i].rotation.controller.available.controller=rotScriptCtrl
								HelperArray[i].rotation.controller.weight[HelperArray[i].rotation.controller.count]=100.0/l
							)
						)
					)
					--If Average Type equals Euler Angles Average
					else
					(
						 --Loops throught the Control Objects and constraint the bones between them (the weight is a static value in respect percent by number of controls 
						 --instead dynamic distance calculation)
						m =(ControlsArray.count-1)
						l=nBones/m as float
						for j=1 to m do
						(
							difIter=((j-1)*l+1)
							minIter=(ceil difIter) 
							difIter=minIter-difIter
							rotScriptCtrl=rotation_script()
							rotScriptCtrl.addTarget "rotXA" controlsArray[j].rotation.controller.x_rotation.controller
							local scriptString="quat"
							if j!=1 then
							(
								rotScriptCtrl.addTarget "rotXB" controlsArray[j-1].rotation.controller.x_rotation.controller
								scriptString+=" ((rotXA-rotXB)*"+((1.0*(1-difIter)/l) as string)
								if difIter !=0 then
								(
									rotScriptCtrl.addTarget "rotXC" controlsArray[j+1].rotation.controller.x_rotation.controller
									scriptString+="+(rotXC-rotXA)*"+((1.0*difIter/l) as string)
								)
								scriptString+=")"
							)
							else
								scriptString+=" rotXA"
							scriptString+=" [-1,0,0]" 
							rotScriptCtrl.script=scriptString
							HelperArray[minIter].rotation.controller.available.controller=rotScriptCtrl
							
							rotScriptCtrl=rotation_script()
							rotScriptCtrl.addTarget "rotXA" controlsArray[j].rotation.controller.x_rotation.controller
							rotScriptCtrl.addTarget "rotXB" controlsArray[j+1].rotation.controller.x_rotation.controller
							rotScriptCtrl.script="quat ((rotXB-rotXA)*"+((1.0/l) as string)+") [-1,0,0]"
							for i=minIter+1 to (ceil (j*l)) do
								HelperArray[i].rotation.controller.available.controller=rotScriptCtrl
						)
					)
				)
				-- if "Average to" equals Spinner
				3:
				(
					RootHelper.modifiers[1].SplineChain.Roll.controller=bezier_float()
					for i=1 to nBones do
					(
						local rotCtrl=euler_xyz()
						HelperArray[i].rotation.controller.available.controller=rotCtrl
						rotCtrl.x_rotation.controller=float_script()
						rotCtrl.x_rotation.controller.addTarget "rollValue" RootHelper.modifiers[1].SplineChain.Roll.controller
						rotCtrl.x_rotation.controller.script="degtorad rollValue*"+(((i-1)/(nBones-1) as float) as string)
					)
				)
			)
		)

		for i=1 to nBones do
		(
			boneArray[i].rotation.controller=orientation_constraint()
			boneArray[i].rotation.controller.appendTarget helperArray[i] 100
		)
	)
  )
  /*Function fnSplineControl:
  Creates the spline's attachment to Control objects. It can create three types of attachment: 
  创建这条线的控制器，它有三和类型
  Spline IK Control: Aply the modifier to the spline and adds the Control Objects
  ik控制点：给线添加修改器（splineIKControl）和控制物体
  Skin, Verts Only: Aply a skin modifier to the spline, adds the Control Objects as bones and set the vertices weight to their
  蒙皮，仅点：给线添加skin修改器，把控制器添加到骷髅列表并设置点的权重到对应的控制器上。
  respective Control Object. The InVec and OutVec tangents are weighted to their vertex's Control Object.
  左右权柄被点的控制物影响。
  Skin, Verts and tangents: Aply a skin modifier to the spline, adds the Control Objects as bones and set the vertices weight to their
  蒙皮，点加权柄：给线加skin修改器，把控制器添加到骷髅列表并设置点的权重对应的虚拟体上。
  respective helper. Creates Extra Control objects for tangent manipulation (InVec and OutVec), adds them to the skin
  为权重权柄（左右权柄）创建额外的控制物体，并添加到skin上
  The InVec and OutVec tangents are  weighted to these Extra Control Objects.  
  左右权柄受附加的控制物影响。
  The Function Receives 5 Arguments, "obj" is the spline, "ControlsArray" are the nodes to attach the spline to, if they're undefined
  此函数需要5个输入：obj是线；controlsArry上吸附到线上的节点，如果没有定义（线方式）则创建新的控㓡物；
  (by spline method) then it creates new Control Objects.  "Type" is the type of spline's attachment, "WidthVar" to set the 
  type线的吸附模式；widthVar设置控制
  Control objects' size and the "HelperStartEnd" brings the HelperStart and HelperEnd objects to link them to first 
  物的大小；helperStartEnd  创建首尾虚拟体并将它们分别链接给首尾控制器
  and the last Control Object respectively.  */
  function fnSplineControl splineNode type tangentsBool widthVar=
  (	 
	local n=(numknots splineNode 1)	  
	--Here is the creation of the Control Objects (the ones that will deform the spline)
	----ik控制器在这里创建
	local controlsArray=#()
	for i=1 to n do
	(
		controlVar=point centerMarker:false axisTripod:false cross:false box:true size:(widthVar*3) \
						wirecolor:red name:("Control_ChainKnot_"+(i as string))
		local controlRow1=pathTangent splineNode 1 ((i-1)/(n-1) as float)
		local controlRow3=normalize (cross controlRow1 [0,1,0])
		local controlRow2=normalize (cross controlRow3 controlRow1)
		local controlRow4=getknotpoint splineNode 1 i
		controlVar.transform=matrix3 controlRow1 controlRow2 controlRow3 controlRow4
		append controlsArray controlVar
	)
	
	--it's a need to select the spline and activate the modify panel, oterwise the script 
	--will crash when adding the control Objects in the skin modifier.
	select splineNode
	setCommandPanelTaskMode mode: #modify
	
	--Creates the Attachment, according to the type.
    if type==1 then --Spline IK Control
	(
		if tangentsBool then --With tangents
		(
			for i=1 to n do
			(
				setknotType splineNode 1 i #beziercorner
				local knotPos=(getKnotPoint splineNode 1 i)
				setInVec splineNode 1 i (((getInVec splineNode 1 i)-knotPos)*(inverse controlsArray[i].transform.rotation)+knotPos)
				setOutVec splineNode 1 i (((getOutVec splineNode 1 i)-knotPos)*(inverse controlsArray[i].transform.rotation)+knotPos)
			)
			updateshape splineNode
		)
		else	--Without tangents
			for i=1 to n do
				setknotType splineNode 1 i #smooth
			
		addmodifier splineNode (Spline_IK_Control ()) 
		splineNode.modifiers[1].noLinking()
		splineNode.modifiers[1].helper_list=controlsArray
	)
	else --Skin
	(
		if tangentsBool then --With tangents
		(
			for i=1 to n do
			  setknotType splineNode 1 i #beziercorner 
			addmodifier splineNode (skin())		
			for i=1 to n do
			(
				--First Creates The InVec Control Object, adds it to the skin and sets the respective weight,
				--then the Vertex Control Object, and finally the OutVec Control Object
				if i>1 then
				(
					controlVarInVec=copy controlsArray[i]
					controlVarInVec.size=widthVar
					controlVarInVec.wirecolor=red
					controlVarInVec.name="Control_ChainInVec_"+(i as string)
					controlVarInVec.parent=controlsArray[i]
					controlVarInVec.position=getInVec splineNode 1 i
					skinops.addbone splineNode.modifiers[1] controlVarInVec 0
					classof splineNode 
					skinops.setVertexWeights splineNode.modifiers[1] (i*3-2) (i*3-3) 1
				)
				skinops.addbone splineNode.modifiers[1] controlsArray[i] 0
				classof splineNode
				skinops.setVertexWeights splineNode.modifiers[1] (i*3-1) (i*3-2) 1		
				if i==1 then
					skinops.setVertexWeights splineNode.modifiers[1] (i*3-2) (i*3-2) 1		
				if i<n then
				(
					controlVarOutVec=copy controlsArray[i]
					controlVarOutVec.wirecolor=red
					controlVarOutVec.size=widthVar
					controlVarOutVec.name="Control_ChainOutVec_"+(i as string)
					controlVarOutVec.parent=controlsArray[i]
					controlVarOutVec.position=getOutVec splineNode 1 i
					skinops.addbone splineNode.modifiers[1] controlVarOutVec 0
					classof splineNode
					skinops.setVertexWeights splineNode.modifiers[1] (i*3) (i*3-1) 1
				)						  
				else
					skinops.setVertexWeights splineNode.modifiers[1] (i*3) (i*3-2) 1
			)
		)
		else --Without tangents
		(
			for i=1 to n do
			  setknotType splineNode 1 i #smooth
			addmodifier splineNode (skin())
			for i=1 to n do
			(
				skinops.addbone splineNode.modifiers[1] controlsArray[i] 0
				classof splineNode --this line is a need to update the skin, and to don't get a crash with the next line (setVertexWeights)
				--set the vertex and its tangent points weights
				skinops.setVertexWeights splineNode.modifiers[1] (i*3) i 1
				skinops.setVertexWeights splineNode.modifiers[1] (i*3-1) i 1
				skinops.setVertexWeights splineNode.modifiers[1] (i*3-2) i 1
		  )
	    )
	)
	return controlsArray
  )
  --The rollout UI controls
	GroupBox grp1 "Bones Settings" pos:[9,10] width:192 height:103
	spinner UIBones "骨骼 / Bones: " pos:[67,29] width:125 height:16 range:[1,1e+008,6] type:#integer
	spinner UIWidth "宽度 / Width: " pos:[69,50] width:123 height:16 range:[0,1e+008,5] type:#float
	spinner UITaper "锥度 / Taper: " pos:[69,71] width:123 height:16 range:[0,1e+008,0] type:#float
	checkbox UISquash "挤压[引擎不认]" pos:[15,92] height:15 checked:false
	-->>>新增引擎支持挤压拉伸
	checkbox UISquash_new "->[引擎认]" pos:[120,92] height:15 checked:false tooltip: "打开挤压才能打开此项，开启后会生成一套新的引擎支持的骨骼在名为“yun_scale_bones”的层里"
	GroupBox grp3 "LookAt" pos:[9,117] width:192 height:57
	radiobuttons UILookAtType "" pos:[21,134] width:107 height:32 labels:#("LookAt Constraint", "Quaternion Aim") columns:1
	button btnHelp1 "帮助" pos:[155,140]
	GroupBox grp2 "Chain Points Settings" pos:[9,177] width:192 height:198
	checkbox UIRotAver "Roll ( X 轴 ) 旋转" pos:[18,196] height:15 checked:true
	radiobuttons UIRotAverToControls "平均为:" pos:[40,215] width:127 height:62 labels:#("首尾控制器", "所有控制器", "微调器[ChainKnot 属性]") columns:1
	radiobuttons UIRotAverType "平均类型:" pos:[40,282] width:124 height:46 labels:#("方向约束", "欧拉角") default:2 columns:1
	checkbox UIManControllers "单独调整控制器" pos:[18,335] width:136 height:15 checked:true
	checkbox UIIKSolver "IK 控制[ChainKnot 属性]" pos:[18,355] width:143 height:15 
	GroupBox grp4 "Spline Control Settings" pos:[10,380] width:192 height:100
	radiobuttons UISplineControlType "" pos:[19,397] width:101 height:32 labels:#("样条线 IK 控制", "Skin 控制") columns:1
	checkbox UITangents "切线" pos:[19,436] width:136 height:15 checked:true
	-->>>新增严路径伸缩
	checkbox UISplineLenth "路径伸缩" pos:[19,456] width:80 height:15 checked:false tooltip: "可以使骨骼沿着路径伸缩"
	
	-->>>新增fkik切换系统
	checkbox UISuperIkFk "FKIK切换(实验)" pos:[90,456] width:110 height:15 checked:false tooltip: "可创建一套fkik的切换系统（实验中，待优化）"
  
	button UIOK "Ok" pos:[47,486] width:74 height:21
	button UICancel "Cancel" pos:[127,486] width:74 height:21
	
	--Finally the execution of the functions when the magic buttons are pressed

	on UIRotAver changed val do
	(
		if val then 
		(
			UIRotAverToControls.enabled=true
			if UIRotAverToControls.state!=3 then
				UIRotAverType.enabled=true
		) 
		else
		(
			UIRotAverType.enabled=false
			UIRotAverToControls.enabled=false
		)
	)
	on UIRotAverToControls changed val do
	(
		if val==3 then
			UIRotAverType.enabled=false
		else
			UIRotAverType.enabled=true
	)
	on UISquash_new changed theState do
	(
		if theState do (UISquash.checked = true)		
	)
	on UISquash changed theState do
	(
		if not theState do (UISquash_new.checked = false)		
	)
	
	on UIOK pressed do
	(
	 undo on
	 (
	   shapeBool=false
	   SelArray=selection as array
	   for splineNode in SelArray where (superclassof splineNode==shape) do
	   (
		   shapebool=true
		   if (numknots splineNode 1)>1 then
		   (
			   local ControlsArray=fnSplineControl splineNode UISplineControlType.state UITangents.checked UIWidth.value
			   fnCreateChain splineNode ControlsArray UIBones.value UIWidth.value UITaper.value \
				   UISquash.checked UILookAtType.state #(UIRotAver.checked,UIRotAverType.state,UIRotAverToControls.state) \
				   UIManControllers.checked UIIKSolver.checked
		   )
	   )
	   select SelArray
	   
	   -->>>添加的新功能
	   -->>>链条工具引擎缩放支持
	   if UISquash_new.checked  then
	   (
		   
			select $Bone_Chain_*
			$.isHidden = false
			--clone the selected objects
			maxOps.cloneNodes (selection as array) cloneType:#copy newNodes:&nnl #nodialog

			try (delete $Bone_Chain_scale_*) catch ()
			--Loop through the array of object it returns
			for i = 1 to nnl.count do
			(
				--rename the objects to a unique name
				nnl[i].name = uniqueName "Bone_Chain_scale_" numDigits:1
				
			)

			$.isHidden = true


			select  $Bone_Chain_scale_* 			
			
			$.boneScaleType=#scale
			for i=1  to  selection.count do
			(
				p = getNodeByName ("Bone_Chain_scale_" + (i as string))
				scaleExp =  scale_script ()
				p.scale.controller = scaleExp

				p_s = 	getNodeByName ("Bone_Chain_" + (i as string))
				scaleExp.Addnode  "scalePP"  p_s
					
				scaleExp.script = 	"[scalePP.stretchTM[1][1],scalePP.stretchTM[2][2],scalePP.stretchTM[3][3]]"	
					
			)

			---创建骨骼的层
			yun_bone_Layer = LayerManager.getLayerFromName "yun_scale_bones"
			if yun_bone_Layer == undefined then 
			(
				yun_bone_Layer = layerManager.newLayerFromName "yun_scale_bones"
				yun_bone_Layer.on = true
			)

-- 			$.parent = world
			for i in selection do ( yun_bone_Layer.addnode i)
		
		)
	   -->>>聊条工具曲线长度控制
		if UISplineLenth.checked  then
	   (
			--添加自定义属性
			obj = $Helper_Chain_Root
-- 			addmodifier obj (EmptyModifier())
			--Bone Attributes
			line_lenth = attributes line_lenth
			attribid:#(0x7c853e24, 0x7b78b8d4)

			version:1
			(
				parameters line_lenth rollout: Params
				(
					lenth type:#float UI:Param1 defult:100.0
			-- 		Param2 type:#float UI:Param2 defult:0.0
			-- 		Param3 type:#float UI:Param3 defult:0.0
					
				)
				
				Rollout Params "custom Attributes"
				(
					spinner Param1 "长度:" width:160 Height:16 Align:#Center Offset:[0,0] Type:#float Range:[0,100,100]
			-- 		spinner Param2 "Param2:" width:160 Height:16 Align:#Center Offset:[0,0] Type:#float
			-- 		spinner Param3 "Param2:" width:160 Height:16 Align:#Center Offset:[0,0] Type:#float
					
				)
			)

			-- Apply attribute class to an object
			add_attribute = custattributes.add obj line_lenth
			$Helper_Chain_Root.baseObject.line_lenth[1].value = 100

			-- $.position.controller.Path_Constraint.controller.Percent

			----获取所有的ikherlper点
			h_chain =   $Helper_ChainPoint* as array
			h_chain_percent = #()
			--原本的百分比数据
			if h_chain.count>2 then
			(
			-- 	i = $Helper_ChainPoint_6
				for i in h_chain do 
				(
					try (
						
						p = i.position.controller.Path_Constraint.controller.Percent/100	
						append h_chain_percent p
						---添加表达式
			-- 			print i.name
						i.position.controller.Path_Constraint.controller.Percent.controller	 = float_script ()
						CT = i.position.controller.Path_Constraint.controller.Percent.controller		
						CT.AddTarget  "mainP"  $Helper_Chain_Root.baseObject.line_lenth[1]
						----要注意百分比转换
						CT.script =  ( p as string) +"* (mainP/100) "		
					
					) catch()
				)
			)  
		   
	   )
	   -->>>创建fkik切换
-- 	   rollCreateChain.UISuperIkFk.checked
	   if UISuperIkFk.checked  then
		( 
			----创建骨骼链	
			function reconstructBones ori prefix  collor =
			(
			--排序	

			sort_bones_n = sort(for i in ori collect i.name)	
			sort_bones = #()
			sort_bones = for o in sort_bones_n  collect (getNodeByName o)	
			n = sort_bones.count	
				
			for i=1 to n do 
			(	
				if i != n then 
				( 
					makeBone = boneSys.createBone sort_bones[i].pos sort_bones[i+1].pos [1,0,0]		
				)	
				---创建末端
				else
				( 
					arrSel = sort_bones[n]
					parentBone  = arrSel
					parentTrans = parentBone.transform
					parentPos   = parentTrans.translation

					
					dir = sort_bones[n].pos - sort_bones[n-1].pos 
					dir = normalize dir		
					makeBone = BoneSys.createBone sort_bones[n].pos  (sort_bones[n].pos+10*dir) parentBone.dir
					
			-- 		makeBone = BoneSys.createBone parentPos [parentPos.x+6,parentPos.y,parentPos.z ] parentBone.dir
			-- 		makeBone.transform = parentTrans
					makeBone.taper     = 90	


					if iskindof arrSel BoneGeometry==true do 
					(
						in coordSys Local move makeBone [parentBone.length,0,0]			
						makeBone.parent    = parentBone
						
						makeBone.width     = parentBone.width
						makeBone.height    = parentBone.height
						makeBone.length    = (parentBone.width+parentBone.height)/2
						makeBone.wirecolor = parentBone.wirecolor
					)
					---轴向调整
					in coordSys Local rotate makeBone	(angleaxis 90 [1,0,0])			
					append arrBoneEndAll makeBone		
					
				)
				
				---命名和层级整理
				makeBone.name =prefix + "_"+(i as string)
				makeBone.wirecolor = collor
				if i > 1 then
				(
					try (p = getNodeByName (prefix + "_"+(i-1) as string) ) catch()
					if p!=undefined then ( makeBone.parent =  p  )
				)
				--box显示
				makeBone.boxmode = on

				
			)

			) 
			with undo on 
			(
			-- ikfk切换器
				IKFK_switch = $Helper_Chain_Root

			------------------------------------------------------------------------
			----创建FK
			clearSelection()	
			select $Control_ChainKnot_*		
			IK_ready =  selection as array

			---锁定ik旋转
			-- for i in IK_ready do ( i.rotation.controller = rotation_script () )


			fk_radius = 15	
			---显示层整理
			yun_line_Layer = LayerManager.getLayerFromName "FK控制器"
			if yun_line_Layer == undefined then 
			(
				yun_line_Layer = layerManager.newLayerFromName "FK控制器"
				yun_line_Layer.on = true
			)


			try (delete $FK_ctl*) catch()
			select $Control_ChainKnot_*		
			IK_ready =  selection as array

			ori =IK_ready	
			prefix ="FK_ctl"
			collor = yellow

			---创建骨骼
			reconstructBones ori prefix collor
			$FK_ctl_1.parent =   IKFK_switch

			---objA被objB位置约束
			fn yunPosconstraint objA objB = 
			(
				objA.pos.controller = position_list ()	
				posPP =Position_Constraint() 
				objA.pos.controller.Available.controller=posPP
				posPP.appendTarget objB 100
				posPP.relative=true	
			)
			fn yunRotconstraint objA objB = 
			(
				objA.rotation.controller = rotation_list  ()	
				rotPP =Orientation_Constraint() 
				objA.rotation.controller.Available.controller=rotPP
				rotPP.appendTarget objB 100
				rotPP.relative=true	
			)
				

			---添加ik的约束唯一控制层
			for i=1 to IK_ready.count do
			(
				objA = IK_ready[i]	
				fk_ctrl_P =  "FK_ctl_"+(i as string)
				objB = getNodeByName fk_ctrl_P
				yunPosconstraint objA objB
				yunRotconstraint objA objB
			)
	


			-- ikfk 切换器自定义属性添加
			 
			CWCode_A = attributes Custom_Attributes 
			version:0
			( 
				Parameters main rollout:params
				(
					'FK / IK' Type:#integer UI:'FK / IK' Default:0 
				)  
				   
				Rollout Params "Custom Attributes"   
				( 
					slider 'FK / IK' "FK / IK:" Width:50 Height:25 Align:#Center Offset:[0,0] Type:#integer Range:[0,1,0] Orient:#Horizontal Ticks:0
					
					on 'FK / IK' changed var do 
					(
						ctrlList = execute InfoStr
						---显隐控制
						for i = 1 to ctrlList.count do
						(	
							if	 var != 1 then
							(		
							ctrlList[i][1].isHidden = false
							ctrlList[i][2].isHidden = true
							)
							else			
							(		
							ctrlList[i][1].isHidden = true
							ctrlList[i][2].isHidden = false
							)
						)
					)
				)
				
				
			)
			custAttributes.add IKFK_switch CWCode_A   

			-- <AttributeDef:FK / IK Tools> 
			CWCode_B =  attributes "FK / IK Tools" attribID:#(0xe493761, 0x7662f616)
			(
			-- 	这一行的InfoStr很关键
				parameters main rollout:FKIKTool
				(
					InfoStr type:#string default:""
				)
				rollout FKIKTool "FK / IK Tools"
				(
					

					timer fkik_goodSee "fkik_goodSee" interval:500 --tick once a second

					group "Pose" (
						button btnPoseIK2FK "IK >> FK" width:120
						button btnPoseFK2IK "FK >> IK" width:120
					)
					group "Animation" (
						button btnAnimIK2FK ">> FK" width:120
						button btnAnimFK2IK ">> IK" width:120
						radioButtons rdoRangeType "" labels:#("Time Line","Range") default:1 columns:2
						label lbStart "Start :"　across:2 enabled:false
						spinner spnStart "" align:#left width:60 range:[-9999,9999,0] type:#integer enabled:false
						label lbEnd "End :"　across:2 enabled:false
						spinner spnEnd "" align:#left width:60 range:[-9999,9999,0] type:#integer enabled:false
						button btnFitTimeLine "Fit Time Line" align:#right enabled:false
					)
					
			-- 		timer 控制ikfk的显示状态
					on fkik_goodSee tick do
					  (
						ctrlList = execute InfoStr
						
						if $.baseObject.Custom_Attributes.FK___IK==1 then
						(
						   
							FKIKTool.btnPoseIK2FK.text = "o(^▽^)o >> FK"
							FKIKTool.btnPoseFK2IK.text = "(T⌓T) >> IK"
							
							FKIKTool.btnPoseIK2FK.enabled = true
							FKIKTool.btnPoseFK2IK.enabled = false
							---显隐控制_IK
							for i = 1 to ctrlList.count do
							(					
								ctrlList[i][1].isHidden = true
								ctrlList[i][2].isHidden = false			
							)
						)
						else
						(
						   
							FKIKTool.btnPoseIK2FK.text = "(T⌓T)>> FK"
							FKIKTool.btnPoseFK2IK.text = "o(^▽^)o >> IK"
							FKIKTool.btnPoseIK2FK.enabled = false
							FKIKTool.btnPoseFK2IK.enabled = true
							---显隐控制_FK
							for i = 1 to ctrlList.count do
							(					
								ctrlList[i][1].isHidden = false
								ctrlList[i][2].isHidden = 	true		
							)
						)
					  ) 
					----ik吸附到fk
					on btnPoseFK2IK pressed do (
						------严查
						ctrlList = execute InfoStr
						undo "" on
						(
							$.FK___IK = 1
							redrawViews()
							for ctrls in ctrlList do (
								ctrls[2].transform = ctrls[1].transform
							)

							---显隐控制
							for i = 1 to ctrlList.count do(ctrlList[i][1].isHidden = true ;ctrlList[i][2].isHidden = false)
						)
					)
					--- fk吸附到ik
					on btnPoseIK2FK pressed do (
						ctrlList = execute InfoStr
						undo "" on
						(
							for i = 1 to ctrlList.count - 1 do(
								vPos = ctrlList[i][2].transform.position
								xAxis = normalize (ctrlList[i+1][2].transform.position - vPos)
								yAxis = normalize (cross [0,0,1] xAxis)
								zAxis = normalize (cross xAxis yAxis)

								ctrlList[i][1].transform = (matrix3 xAxis yAxis zAxis vPos)
							)

							---显隐控制
							for i = 1 to ctrlList.count do(ctrlList[i][1].isHidden = false;ctrlList[i][2].isHidden = true)
							ctrlList[ctrlList.count][1].transform = ctrlList[ctrlList.count][2].transform

							$.FK___IK = 0
							redrawViews()
						)
					)
					---动画的ikfk切换
					on btnAnimFK2IK pressed do (
						ctrlList = execute InfoStr

						tNow = (currentTime as string) as integer
						tStart = (animationRange.start as string) as integer
						tEnd = (animationRange.end as string) as integer
						
						if rdoRangeType.state == 2 then (
							tStart = spnStart.value
							tEnd = spnEnd.value
						)

						oriAnmState = animButtonState

						undo "" on
						(
							TMInfoList = #()
							for t = tStart to tEnd do (
								sliderTime = t
								TMInfo = #()
								for ctrls in ctrlList do (
									append TMInfo ctrls[2].transform 
								)
								append TMInfoList TMInfo
							)

							animate on
							(
								at Time (tStart - 1)
								(
									$.FK___IK = $.FK___IK
								)
								at Time (tEnd + 1)
								(
									$.FK___IK = $.FK___IK
								)
							)

							selectKeys $.FK___IK.controller tStart tEnd
							deleteKeys $.FK___IK.controller #selection

							animate on
							(
								at Time tStart
								(
									$.FK___IK = 1
								)
								at Time tEnd
								(
									$.FK___IK = 1
								)
							)

							redrawViews()
							animate on
							(
								for t = tStart to tEnd do (
									idxT = (t - tStart) + 1
									at Time t 
									(
										for i = 1 to ctrlList.count do
										(
											ctrlList[i][2].transform = TMInfoList[idxT][i]
										)
									)
								)
							)--end animate
							sliderTime = tNow
						)-- end undo
					)
					---动画的ikfk切换
					on btnAnimIK2FK pressed do (
						ctrlList = execute InfoStr

						tNow = (currentTime as string) as integer
						tStart = (animationRange.start as string) as integer
						tEnd = (animationRange.end as string) as integer
						
						if rdoRangeType.state == 2 then (
							tStart = spnStart.value
							tEnd = spnEnd.value
						)

						oriAnmState = animButtonState

						undo "" on
						(
							TMInfoList = #()
							for t = tStart to tEnd do (
								sliderTime = t
								TMInfo = #()
								for i = 1 to (ctrlList.count - 1) do (
									vPos = ctrlList[i][2].transform.position
									xAxis = normalize (ctrlList[i+1][2].transform.position - vPos)
									yAxis = normalize (cross [0,0,1] xAxis)
									zAxis = normalize (cross xAxis yAxis)

									mtx = (matrix3 xAxis yAxis zAxis vPos)
									append TMInfo mtx
								)

								append TMInfo ctrlList[ctrlList.count][2].transform
								append TMInfoList TMInfo
							)

							animate on
							(
								at Time (tStart - 1)
								(
									$.FK___IK = $.FK___IK
								)
								at Time (tEnd + 1)
								(
									$.FK___IK = $.FK___IK
								)
							)

							selectKeys $.FK___IK.controller tStart tEnd
							deleteKeys $.FK___IK.controller #selection

							animate on
							(
								at Time tStart
								(
									$.FK___IK = 0
								)
								at Time tEnd
								(
									$.FK___IK = 0
								)
							)

							redrawViews()

							animate on
							(
								for t = tStart to tEnd do (
									idxT = (t - tStart) + 1
									at Time t 
									(
										for i = 1 to ctrlList.count do
										(
											ctrlList[i][1].transform = TMInfoList[idxT][i]
										)
									)
								)
							)--end animate
							sliderTime = tNow
						)-- end undo
					)
					---动画的ikfk切换的配置块儿
					on rdoRangeType changed val do (
						case val of (
							1:(
								lbStart.enabled = false
								lbEnd.enabled = false
								spnStart.enabled = false
								spnEnd.enabled = false
								btnFitTimeLine.enabled = false
							)
							2:(
								lbStart.enabled = true
								lbEnd.enabled = true
								spnStart.enabled = true
								spnEnd.enabled = true
								btnFitTimeLine.enabled = true
							)
						)
						if FKIKTimeRangeType == undefined then (
							global FKIKTimeRangeType
						)
						FKIKTimeRangeType = val
					)
					---动画的ikfk切换的配置块儿的 小弟
					on spnStart changed val do (
						if spnEnd.value < val then (
							spnEnd.value = val
						)

						if startTime == undefined then (
							global startTime
						)
						startTime = val
					)
					---动画的ikfk切换的配置块儿的 小弟
					on spnEnd changed val do (
						if spnStart.value > val then (
							spnStart.value = val
						)

						if endTime == undefined then (
							global endTime
						)
						endTime = val
					)
					---动画的ikfk切换的配置块儿的 小弟
					on btnFitTimeLine pressed do (
						spnStart.value = (animationRange.start as string) as integer
						spnEnd.value = (animationRange.end as string) as integer
					)
					-- 打开时固定执行
					on FKIKTool open do(
						if startTime == undefined then (
							global startTime
							startTime = (animationRange.start as string) as integer
						)
						if endTime == undefined then (
							global endTime
							endTime = (animationRange.end as string) as integer
						)
						
						spnStart.value = startTime
						spnEnd.value = endTime

						if FKIKTimeRangeType != undefined then (
							rdoRangeType.state = FKIKTimeRangeType
							case FKIKTimeRangeType of (
								1:(
									lbStart.enabled = false
									lbEnd.enabled = false
									spnStart.enabled = false
									spnEnd.enabled = false
									btnFitTimeLine.enabled = false
								)
								2:(
									lbStart.enabled = true
									lbEnd.enabled = true
									spnStart.enabled = true
									spnEnd.enabled = true
									btnFitTimeLine.enabled = true
								)
							)
						)
					)
				)
			)

			custAttributes.add IKFK_switch CWCode_B

			---获取命令的字符串
			finalCtr_str = ""
			for i=1 to IK_ready.count do
			(
				fk_ctrl_P =  "FK_ctl_"+(i as string)
				objB = getNodeByName fk_ctrl_P
				IK_ready[i].name
				objB.name
				if i==1 then 	( str = "#($"+objB.name+",$"+IK_ready[i].name+")"  )
				else (str = ",#($"+objB.name+",$"+IK_ready[i].name+")")
				append finalCtr_str str	
			)
			finalCtr_str = "#("+finalCtr_str+")"
			---将字符串赋值给属性
			IKFK_switch.baseObject.FK___IK_Tools.InfoStr = finalCtr_str


			-- ik约束权重的连线参数
			-- 0是fk，1是ik
			IKFK_switch.baseObject.Custom_Attributes.FK___IK = 1
			for i=1 to IK_ready.count do
			(
			paramWire.connect IKFK_switch.baseObject.Custom_Attributes[#FK___IK] IK_ready[i].pos.controller[4][#Weight__Position_Constraint] "1-FK___IK"

			paramWire.connect IKFK_switch.baseObject.Custom_Attributes[#FK___IK] IK_ready[i].rotation.controller[4][#Weight__Orientation_Constraint] "1-FK___IK"
-- 			paramWire.connect $.baseObject.Custom_Attributes[#FK___IK] $Control_ChainKnot_2.rotation.controller.Orientation_Constraint.controller[#Orientation_Weight_0] "1-FK___IK"
				
			)

			/* 
			---添加ikfk显示隐藏表达式
			exp_IK = "if SW > 0.5 and SelfObj.isHidden == true then unhide SelfObj
			else if SW <= 0.5 and SelfObj.isHidden == false then hide SelfObj
			[1, 1, 1]"
			exp_FK = "if SW > 0.5 and SelfObj.isHidden == false then hide SelfObj
			else if SW <= 0.5 and SelfObj.isHidden == true then unhide SelfObj
			[1, 1, 1]"


			for i=1 to IK_ready.count do
			(
				IK_ready[i].scale.controller = scale_script ()
				IK_ready[i].scale.controller.AddTarget  "SW"  IKFK_switch.baseObject.Custom_Attributes[1]
				IK_ready[i].scale.controller.AddNode    "SelfObj"  IK_ready[i]
				IK_ready[i].scale.controller.script =exp_IK	
				fk_ctrl_P =  "FK_ctl_"+(i as string)
				objB = getNodeByName fk_ctrl_P	
				objB.scale.controller = scale_script ()
				objB.scale.controller.AddTarget  "SW"  IKFK_switch.baseObject.Custom_Attributes[1]
				objB.scale.controller.AddNode    "SelfObj"  objB
				objB.scale.controller.script =exp_FK
			)
			IKFK_switch.baseObject.Custom_Attributes.FK___IK = 0 */



			)  ---end undo


		)----end of 创建fkik 

	   
	   if not shapeBool then MessageBox "Select a Spline object"
	 )
	 --destroyDialog rollCreateChain
	 
	 
	 
	 
	 
	)
	on UICancel pressed do
	(
		destroyDialog rollCreateChain
	)

	on btnHelp1 pressed do
	(
		MessageBox "LookAt Constraint：\r\n\r\n骨骼将分配标准的 lookat 约束，并将控制点虚拟体作为目标\r\n\r\n\r\n\r\nQuaternion Aim：\r\n\r\n骨骼将有旋转脚本而不是 lookat 约束，\r\n\r\n优点是脚本控制器有一种通过构建四元数来查找旋转值的查看算法，\r\n\r\n这可以防止不需要的翻转，\r\n\r\n除非骨骼与其父级重叠（x 轴正在寻找相反的方向）。                                                         "
	)
) 
dialogCreateChain=createDialog rollCreateChain 
-- )