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
--Here is the rollout with all the functions and UI controls
rollout rollCreateChain "Create Chain_v1.32" width:210 height:495
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
  Spline IK Control: Aply the modifier to the spline and adds the Control Objects
  Skin, Verts Only: Aply a skin modifier to the spline, adds the Control Objects as bones and set the vertices weight to their
  respective Control Object. The InVec and OutVec tangents are weighted to their vertex's Control Object.
  Skin, Verts and tangents: Aply a skin modifier to the spline, adds the Control Objects as bones and set the vertices weight to their
  respective helper. Creates Extra Control objects for tangent manipulation (InVec and OutVec), adds them to the skin
  The InVec and OutVec tangents are  weighted to these Extra Control Objects.  
  The Function Receives 5 Arguments, "obj" is the spline, "ControlsArray" are the nodes to attach the spline to, if they're undefined
  (by spline method) then it creates new Control Objects.  "Type" is the type of spline's attachment, "WidthVar" to set the 
  Control objects' size and the "HelperStartEnd" brings the HelperStart and HelperEnd objects to link them to first 
  and the last Control Object respectively.  */
  function fnSplineControl splineNode type tangentsBool widthVar=
  (	 
	local n=(numknots splineNode 1)	  
	--Here is the creation of the Control Objects (the ones that will deform the spline)
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
	checkbox UISquash "挤压 / Squash【引擎不认】" pos:[18,92] height:15 checked:false
	GroupBox grp3 "LookAt" pos:[9,117] width:192 height:57
	radiobuttons UILookAtType "" pos:[21,134] width:107 height:32 labels:#("LookAt Constraint", "Quaternion Aim") columns:1
	button btnHelp1 "帮助" pos:[155,140]
	GroupBox grp2 "Chain Points Settings" pos:[9,177] width:192 height:198
	checkbox UIRotAver "Roll ( X 轴 ) 平均" pos:[18,196] height:15 checked:true
	radiobuttons UIRotAverToControls "平均为:" pos:[40,215] width:127 height:62 labels:#("首尾控制器", "所有控制器", "微调器(属性)") columns:1
	radiobuttons UIRotAverType "平均类型:" pos:[40,282] width:124 height:46 labels:#("方向约束", "欧拉角") default:2 columns:1
	checkbox UIManControllers "单独调整控制器" pos:[18,335] width:136 height:15 checked:true
	checkbox UIIKSolver "IK 控制（ChainKnot 属性）" pos:[18,355] width:143 height:15 
	GroupBox grp4 "Spline Control Settings" pos:[10,380] width:192 height:77
	radiobuttons UISplineControlType "" pos:[19,397] width:101 height:32 labels:#("样条线 IK 控制", "Skin 控制") columns:1
	checkbox UITangents "切线" pos:[19,436] width:136 height:15 checked:true
	button UIOK "Ok" pos:[47,466] width:74 height:21
	button UICancel "Cancel" pos:[127,466] width:74 height:21
	
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
		MessageBox "LookAt Constraint：\r\n\r\n骨骼将分配标准的lookat约束，并将控制点助手作为目标\r\n\r\n\r\n\r\nQuaternion Aim：\r\n\r\n骨骼将有旋转脚本而不是lookat约束，\r\n\r\n优点是脚本控制器有一种通过构建四元数来查找旋转值的查看算法，\r\n\r\n这可以防止不需要的翻转，\r\n\r\n除非骨骼与其父级重叠（x 轴正在寻找相反的方向）。                                                         "
	)
)
dialogCreateChain=createDialog rollCreateChain 
-- )