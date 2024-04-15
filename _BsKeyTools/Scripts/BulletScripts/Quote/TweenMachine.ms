/*
 * @Description: 根据 Michael Smith 的 TWEEN MACHINE 修改自用
 * @Author: Bullet.S
 * @Date: 2024-04-13 13:20:58
 * @LastEditors: Bullet.S
 * @LastEditTime: 2024-04-15 10:42:34
 * @Email: animator.bullet@foxmail.com
 */

--****************************************************************************************
--*	TWEEN MACHINE for 3DSMax
--* -------------
--* version 1.00
--*
--*	AUTHOR
--*		Michael Smith � 01/2012
--*		email: maxscripts@TheMichaelSmith.com  
--*		website: www.TheMichaelSmith.com
--* 
--* Last update: 2012-01-09
--*----------------------------------------------------------------------------------------
--*
--* WARNING
--* 	This script comes with no warranty!!!
--*		I'm just an animator who likes dabbling in Maxscript.
--*		This script was created in 3DSMax 2009.
--*		No support for Biped IK keys...so tweening the biped will make the feet act as if
--*		they are not "locked in place".  I may fix that later if it bugs me enough.
--*		This script does NOT work with CAT (as far as I know).
--*		This script does NOT work with Animation Layers (again...as far as I know).
--* 	Tried this script and couldn't find any problems with it, I can't be held responsible
--* 	in any way for any kind of loss or damage, whether direct or indirect, due  to the
--* 	use of this script. (lemme know what happened though, I don't want anyone losing 
--*		work, and if I can fix something to prevent it from happening to others, I will)
--*
--* ----------------------------------------------------------------------------------------
--*
--* DESCRIPTION
--*		Adds an inbetween key at the current time for all selected objects.
--*		Creates a new key inbetween the previous and next keys, using a
--*		slider to adjust the "bias" or weight that each key has over the
--*		new key.  Requested/inspired by what Justin Barret made for Maya.
--*		www.justinanimator.com/mel-tweenMachine.php
--*		:)
--*
--*		Thanks to Erik Eidukas for showing me his unfinished Tween Helper script which
--*		I stole ideas from ;) and for answering some of my advanced maxscipt questions
--*		when I was stumped.
--*		www.eee3d.com
--*
--*		Special thanks goes to Nathan Heazlett for answering all my silly questions as I
--*		was getting started on the maxscript learning experience.  
--*		www.nathanheazlett.com
--*
--* VERSIONS:
--* 	1.00 	- This is it.  Only one so far.
--*
--******************************************************************************************/

try(destroyDialog rolBsTweenMachine)catch()

global rolBsTweenMachine
global offsetBsTM = [0,0]
global dragStateBsTM = off

fn sortSelObjs objArray =
(
	-- First find all the root hierarchy objects for selected.
	--Puts them in a rootObjArray
	rootObjArray = #()
	for obj in objArray do
	(
		rootobj = obj
		while rootobj.parent != undefined do rootobj = rootobj.parent
		if (finditem rootObjArray rootobj) == 0 then append rootObjArray rootObj
	)
	--Find children of ALL objects in sorted order.
	--Starts with the rootObjArray and then selects all the children
	--in hierarchical order.
	allObjArray = rootObjArray

	for obj in allObjArray do
	(
		if obj.children != undefined do
		(
			for d in obj.children do
			(
				append allObjArray d
			)
		)
	)
	--create array of just the SELECTED objects in a sorted order.
	-- sortedSelObjs = #()
	-- for obj in allObjArray do
	-- (
	-- 	if obj.isSelected then append sortedSelObjs obj
	-- )
	-- sortedSelObjs
	allObjArray
)


--function that moves selected objects to inbetween position between the previous and 
--next key position, using "sliderValue" to adjust the "bias" or weight that each key 
--position has over the new position.
------------------------------------------------------------------------------------------
fn TweenMachine sliderValue objArray =
(
	--first check to see if auto key or set key button is highlighted.  If not Warning Message.
	--I didn't want anyone accidentally moving objects and changing keys they did not want changed.
	if maxOps.setKeyMode or animButtonState then with undo on
	(
		-- sortedSelObjs = sortSelObjs objArray
		curTime = sliderTime
		k1 = 0f
		k2 =1000000f
		timeArray = #()
		
		for obj in objArray where (objArray.count != 0 and (not matchpattern obj.name pattern:"Bip*Nub")) do
		(
			--check objects properties to see if they have animated keys.  Returns keys as array.
			fn getPropKeys objProps =
			(
				propTimeArray = #()
				propNum = 1
				while objProps[propNum]!= undefined do
				(
					--if isController $.modifiers[modNum][propNum].isAnimated then  --didn't work on morpher
					if isController objProps[propNum].controller then
					(
						--if the controller type is a Position, Rotation and Scale controller (ie. for a subobject gizmo) then
						--get the key values for each of the three (pos, rot and scale).
						if  classof objProps[propNum].controller == prs then
						(
							for i = 1 to 3 do
							(
								for k in objProps[propNum].controller[i].controller.keys do
								(
									if (finditem propTimeArray k.time) == 0 then append propTimeArray k.time
								)
							)
						)
						--if not a PRS controller I ASSUME it's a bezier or a position controller and get those keys
						--I also ASSUME that ASSUMING will come back to bite me in the butt.
						for k in objProps[propNum].controller.keys do
						(
							if (finditem propTimeArray k.time) == 0 then append propTimeArray k.time
						)
					)
					propNum +=1
				)
				propTimeArray
			)

			--checks the objects for animated custom attributes keys. Returns keys as array.
			fn getCAKeys objCAs =
			(
				cATimeArray = #()
				cAcount = custAttributes.count objCAs
				if cAcount > 0 then
				(
					for c = 1 to cACount do
					(
						cANum = 1
						while objCAs.custAttributes[c][cANum] != undefined do
						(
							if objCAs.custAttributes[c][cANum].isAnimated then
							(
								for k in objCAs.custAttributes[c][cANum].controller.keys do
								(
									if (finditem cATimeArray k.time) == 0 then append cATimeArray k.time
								)
							)
							cANum +=1
						)
					)
				)
				cATimeArray
			)

			--calcultates rotational inbetween value and returns a matrix3 value as the result
			fn calcRotTween r1 r2 sliderValue=
			(
				fn dotQuat q q_prev =
				( 
				   (q.w * q_prev.w + q.x * q_prev.x + q.y * q_prev.y + q.z * q_prev.z) < 0 
				)
				if (dotQuat r1 r2) do r1 *=-1

				tweenRot = slerp (normalize r1) (normalize r2) sliderValue
				tweenRot = tweenRot as matrix3
				tweenRot
			)

			--calcultates inbetween value at slider percentage
			fn calcTween v1 v2 sliderValue=
			(
				tweenValue = v1 + (v2-v1)*sliderValue
				tweenValue
			)
			
			--create an array of the baseObject and it's modifiers
			objModArray = #(obj.baseObject)
			if obj.modifiers.count > 0 then
			(
				for i = 1 to obj.modifiers.count do
				(
					append objModArray obj.modifiers[i]
				)
			)

			for objMod in objModArray do
			(
				for pk in (getPropKeys objMod) do
				if (finditem timeArray pk) == 0 then append timeArray pk
				for cak in (getCAKeys objMod) do
				if (finditem timeArray cak) == 0 then append timeArray cak
			)

			if classof obj.baseObject == Biped_Object then
			(
				bipCtrller = obj.controller
				--check if it's the biped COM node
				if classOf bipCtrller == Vertical_Horizontal_Turn then
				(
					for h = 1 to 3 do
					(
						for bipkey in bipCtrller[h].controller.keys do
						(
							if (finditem timeArray bipkey.time) == 0 then append timeArray bipkey.time
						)
					)
					
				)
				else 
				(
					for bipkey in bipCtrller.keys do
					(
						if (finditem timeArray bipkey.time) == 0 then append timeArray bipkey.time
					)
				)
			)
			else
			(
				--check for position rotation and scale keys on the object.  If the objects using a list controller only get
				--the key times of the active controller.
				--I ASSUME position rotation scale controllers OR list controllers.
				for q = 1 to 3 do
				(
					ListCtrller = #(Position_List, Rotation_List, Scale_List)
					PRScntrller = obj.transform.controller[q].controller
					if classOf PRScntrller != ListCtrller[q] then 
					(
						for prskey in PRScntrller.keys do
						(
							if (finditem timeArray prskey.time) == 0 then append timeArray prskey.time
						)
					)
					else 
					(
						for prskey in PRScntrller[PRScntrller.active].controller.keys do
						(
							if (finditem timeArray prskey.time) == 0 then append timeArray prskey.time
						)		
					)
					
				)
			)
			sort timeArray

			--Find the previous and next keyframe time based on the current time slider value
			for k in timeArray do
			(
				if k < curTime then k1 = k
				if k > curTime and k < k2 then k2 = k
			)

			--Set the default in and out tangent type for bezier controllers based on the previous and
			--next keyframe tangent types of the X_rotation of the rotation controller.  
			--The BezierDefaultParams command is available in 3ds Max 2008 and higher. Previously available in the free [AVG] Avguard Extensions.
			oldInTangentType = BezierDefaultParams.inTangentType
			oldOutTangentType = BezierDefaultParams.outTangentType
			try
			(
				rotCtrller = obj.transform.controller[2].controller
				if classOf rotCtrller != Rotation_List then (rotC = rotCtrller)else(rotC = rotCtrller[rotCtrller.active].controller)
				if classOf rotC == Euler_XYZ then
				(
					numK = 0
					for rotkey in rotC.keys do
					(
						objTangType = oldInTangentType
						numK +=1
						if rotkey.time == k1 then	(objTangType = rotC[1].keys[numK].outTangentType)
						if rotkey.time == k2 then (objTangType = rotC[1].keys[numK].inTangentType)
					
						--for some reason BezierDefaultParams.(in and out)TangentType doesn't support the label "#auto" so I
						--had to change that label to "#flat"
						if objTangType == #auto then keyType = #flat
							else keyType = objTangType
						
						if rotkey.time == k1 then	(BezierDefaultParams.inTangentType = keyType)
						if rotkey.time == k2 then (BezierDefaultParams.outTangentType = keyType)
					)
				)
			)
			catch()

			--calculate the inbetween values for all the properties and CAs on the object and it's modifiers
			for objMod in objModArray do
			(
				cAcount = custAttributes.count objMod
				if cACount > 0 then
				(
					for c = 1 to cACount do
					(
						cANum = 1
						while objMod.custAttributes[c][cANum] != undefined do
						(
							try
							(
								v1 = at time k1 objMod.custAttributes[c][cANum].controller.value
								v2 = at time k2 objMod.custAttributes[c][cANum].controller.value
								objMod.custAttributes[c][cANum].controller.value = calcTween v1 v2 sliderValue
								
							)
							catch ()
							cANum +=1
						)
					)
				)
				propNum = 1
				while objMod[propNum] != undefined do
				(
					--Morpher modifier needed it's own special case
					if classOf objMod == Morpher then
					(
						for m = 1 to 100 do
						(
							if objMod[m].controller != undefined then
							(
								v1 = at time k1 objMod[m].controller.value
								v2 = at time k2 objMod[m].controller.value
								objMod[m].controller.value = calcTween v1 v2 sliderValue
							)
						)
					)
					else
					(
						if objMod[propNum].isAnimated then  --didn't work on morpher
						(
							--if the controller type is a Position, Rotation and Scale controller (ie. for a subobject gizmo) then
							--get the key values for each of the three
							if  classof objMod[propNum].controller == prs then
							(
								for i = 1 to 3 do
								(
									v1 = at time k1 objMod[propNum].controller[i].value
									v2 = at time k2 objMod[propNum].controller[i].value
									if i == 2 then objMod[propNum].controller[i].value =calcRotTween v1 v2 sliderValue
									else
									objMod[propNum].controller[i].value =calcTween v1 v2 sliderValue
								)
							)
							try
							(
								v1 = at time k1 objMod[propNum].controller.value
								v2 = at time k2 objMod[propNum].controller.value
								objMod[propNum].controller.value = calcTween v1 v2 sliderValue
							)
							catch()
						)
					)
					propNum +=1
				)
				
			)
			
			--calculate the inbetween values for the position, rotation and scale of the two matirices
			TM1 = at time k1 obj.transform
			TM2 = at time k2 obj.transform
			if obj.parent != undefined then
			(
				TM1 *= at time k1 inverse obj.parent.transform
				TM2 *= at time k2 inverse obj.parent.transform
			)
			tweenTM = TM1
			
			tweenPos = calcTween TM1.translationPart TM2.translationPart sliderValue
			tweenRot = calcRotTween TM1.rotationPart TM2.rotationPart sliderValue
			--apparently the transform scalePart property does NOT keep negative values of scale....so
			--I need to use the scale controller value to check for negative values cause some people
			--(like me) don't listen to other tech people and include negative scales in thier rigs.
			if classof obj.baseObject == Biped_Object then
			(tweenScale = calcTween TM1.scalePart TM2.scalePart sliderValue)
			else 
			(tweenScale = calcTween (at time k1 obj.scale.controller.value) (at time k2 obj.scale.controller.value) sliderValue)
			
			tweenTM.row1 = tweenRot.row1
			tweenTM.row2 = tweenRot.row2
			tweenTM.row3 = tweenRot.row3
			
			tweenTM.row4 = tweenPos
			
			tweenTM.row1 *= tweenScale.x
			tweenTM.row2 *= tweenScale.y
			tweenTM.row3 *= tweenScale.z

			if obj.parent != undefined then
			(
				obj.transform = tweenTM * obj.parent.transform
			)
			else
			(
				obj.transform = tweenTM 
			)
			
			--Set default controller types back to what they were.
			BezierDefaultParams.inTangentType = oldInTangentType 
			BezierDefaultParams.outTangentType = oldOutTangentType
		)
	)
	else
	(
		messageBox "必须打开 AutoKey 或者 SetKey，否则可能造成其他帧 Pose 混乱~                        " title:"BsTweenMachine - 请注意..."
	)
)




--Create the Tween Machine UI.
--slider value is determined with it.
------------------------------------------------------------------------------------------

rollout rolBsTweenMachine "" width:335 height:185
(
	local theMessageError ="出错，请重试，或联系作者~                  "
	
	groupbox gpbOutline "" pos:[5,15] width:325 height:145

	label lblTitle "TweenMachineMod_v2.0" pos:[5,3]
	button btnAbout "?" pos:[rolBsTweenMachine.width - 40,0] height:16 width:20
	button btnClose "X" pos:[rolBsTweenMachine.width - 20,0] height:16 width:20 
	spinner tweenSp "Key % " range:[0.0,100.0,50.0] width:75 height:20 pos:[40,58]
	button less "-10" width:45 pos:[15,30] height:20
	button more "+10" width:45 pos:[70,30] height:20
	radiobuttons rdoType "" pos:[210,30] offsets:#([0,0],[-5,0]) columns:2 labels:#("选中","全Biped") default:1
	button btnFrameTick "整小数帧" pos:[132.5,30] width:65 height:20 checked:true
	button btnStepPlay	"|◀▶| 切换" pos:[132.5,55] width:65 height:20
	checkbutton chkAutoKey	"自动帧-AutoKey(N)" pos:[210,55] width:110 height:20 checked:animButtonState
	
	checkbutton prev "前 Pose" pos:[10,85] width:50 height:30 border:true checked:true
	button onefourth "25.0" pos:[65,90] width:30 height:20 border:true
	button onethird "33.3" pos:[100,90] width:30 height:20 border:true
	checkbutton tween "中间 Pose" pos:[135,85] width:60 height:30 border:true checked:true
	button twothird "66.6" pos:[200,90] width:30 height:20 border:true
	button threefourth "75.0" pos:[235,90] width:30 height:20 border:true
	checkbutton next "后 Pose" pos:[270,85] width:50 height:30 border:true checked:true
	slider tweenSl range:[0.0,100.0,50.0] pos:[15,125] width:315 ticks:10

	hyperlink website "TheMichaelSmith" tooltip:"" pos:[20,165]
	hoverColor:red address:"http://www.themichaelsmith.com/p/tutorials.html" 

	hyperLink hplHome "Bullet.S" address:"https://www.anibullet.com/" hoverColor:green pos:[270,165]

	on rolBsTweenMachine open do
	(

	)

	on btnClose pressed do 
	(
		try (destroydialog rolBsTweenMachine) catch ()
	)

	on rolBsTweenMachine mbuttondown pos do 
	(
		try (destroydialog rolBsTweenMachine) catch ()
	)
	
	on rolBsTweenMachine lbuttondown posMou do
	(
		setSysCur #move
		offsetBsTM = posMou
		dragStateBsTM = on
	)
	
	on rolBsTweenMachine lbuttonup posMou do
	(
		dragStateBsTM = off
	)
	
	on rolBsTweenMachine mouseMove pos do
	(
		if dragStateBsTM == on then
		(
			SetDialogPos rolBsTweenMachine (mouse.screenpos - offsetBsTM)
		)
	)

	--Event Handlers
	on tweenSl changed arg do
	(
		tweenSp.value = arg
	)
	
	on tweenSp changed arg do
	(
		tweenSl.value = arg
	)
	
	on tweenSp entered do
	(
		sliderValue = tweenSP.value/100
		try
		(	
			if rdoType.state !=	2 then tarObjs = (selection as array)
			else tarObjs = (for obj in objects where (classof obj.baseObject == Biped_Object) collect obj)
			TweenMachine sliderValue tarObjs
		)
		catch 
		(	
			messageBox theMessageError title:"BsTweenMachine - ERROR"
		)
	)
	
	on tweenSl buttonUp do
	(
		sliderValue = tweenSP.value/100
		try
		(	
			if rdoType.state !=	2 then tarObjs = (selection as array)
			else tarObjs = (for obj in objects where (classof obj.baseObject == Biped_Object) collect obj)
			TweenMachine sliderValue tarObjs
		)
		catch 
		(	
			messageBox theMessageError title:"BsTweenMachine - ERROR"
		)
	)
	
	on tweenSp buttonUp do
	(
		sliderValue = tweenSl.value/100
		try
		(	
			if rdoType.state !=	2 then tarObjs = (selection as array)
			else tarObjs = (for obj in objects where (classof obj.baseObject == Biped_Object) collect obj)
			TweenMachine sliderValue tarObjs
		)
		catch 
		(	
			messageBox theMessageError title:"BsTweenMachine - ERROR"
		)
	)
	
	on less pressed do
	(
		if tweenSp.value < 10 then tweenSp.value = 0.0 else tweenSp.value -= 10.0
		if tweenSl.value < 10 then tweenSl.value = 0.0 else tweenSl.value -= 10.0
		sliderValue = tweenSP.value/100	
		try
		(	
			if rdoType.state !=	2 then tarObjs = (selection as array)
			else tarObjs = (for obj in objects where (classof obj.baseObject == Biped_Object) collect obj)
			TweenMachine sliderValue tarObjs
		)
		catch 
		(	
			messageBox theMessageError title:"BsTweenMachine - ERROR"
		)
	)
	
	on more pressed do
	(
		if tweenSp.value > 90 then tweenSp.value = 100.0 else tweenSp.value += 10.0
		if tweenSl.value > 90 then tweenSl.value = 100.0 else tweenSl.value += 10.0
		sliderValue = tweenSP.value/100	
		try
		(	
			if rdoType.state !=	2 then tarObjs = (selection as array)
			else tarObjs = (for obj in objects where (classof obj.baseObject == Biped_Object) collect obj)
			TweenMachine sliderValue tarObjs
		)
		catch 
		(	
			messageBox theMessageError title:"BsTweenMachine - ERROR"
		)
	)
	
	on prev changed state do
	(
		prev.state = true
		tweenSp.value = 0.0
		tweenSl.value = 0.0
		sliderValue = tweenSP.value/100
		try
		(	
			if rdoType.state !=	2 then tarObjs = (selection as array)
			else tarObjs = (for obj in objects where (classof obj.baseObject == Biped_Object) collect obj)
			TweenMachine sliderValue tarObjs
		)
		catch 
		(	
			messageBox theMessageError title:"BsTweenMachine - ERROR"
		)
	)
	
	on onefourth pressed do
	(
		tweenSp.value = 25.0
		tweenSl.value = 25.0
		sliderValue = tweenSP.value/100
		try
		(	
			if rdoType.state !=	2 then tarObjs = (selection as array)
			else tarObjs = (for obj in objects where (classof obj.baseObject == Biped_Object) collect obj)
			TweenMachine sliderValue tarObjs
		)
		catch 
		(	
			messageBox theMessageError title:"BsTweenMachine - ERROR"
		)
	)
	
	on onethird pressed do
	(
		tweenSp.value = 33.3
		tweenSl.value = 33.3
		sliderValue = tweenSP.value/100
		try
		(	
			if rdoType.state !=	2 then tarObjs = (selection as array)
			else tarObjs = (for obj in objects where (classof obj.baseObject == Biped_Object) collect obj)
			TweenMachine sliderValue tarObjs
		)
		catch 
		(	
			messageBox theMessageError title:"BsTweenMachine - ERROR"
		)
	)
	
	on twothird pressed do
	(
		tweenSp.value = 66.6
		tweenSl.value = 66.6
		sliderValue = tweenSP.value/100
		try
		(	
			if rdoType.state !=	2 then tarObjs = (selection as array)
			else tarObjs = (for obj in objects where (classof obj.baseObject == Biped_Object) collect obj)
			TweenMachine sliderValue tarObjs
		)
		catch 
		(	
			messageBox theMessageError title:"BsTweenMachine - ERROR"
		)
	)
	
	on threefourth pressed do
	(
		tweenSp.value = 75.0
		tweenSl.value = 75.0
		sliderValue = tweenSP.value/100
		try
		(	
			if rdoType.state !=	2 then tarObjs = (selection as array)
			else tarObjs = (for obj in objects where (classof obj.baseObject == Biped_Object) collect obj)
			TweenMachine sliderValue tarObjs
		)
		catch 
		(	
			messageBox theMessageError title:"BsTweenMachine - ERROR"
		)
	)
	
	on tween changed state do
	(
		tween.state = true
		tweenSp.value = 50.0
		tweenSl.value = 50.0
		sliderValue = tweenSP.value/100
		try
		(	
			if rdoType.state !=	2 then tarObjs = (selection as array)
			else tarObjs = (for obj in objects where (classof obj.baseObject == Biped_Object) collect obj)
			TweenMachine sliderValue tarObjs
		)
		catch 
		(	
			messageBox theMessageError title:"BsTweenMachine - ERROR"
		)
	)
	
	on next changed state do
	(
		next.state = true
		tweenSp.value = 100.0
		tweenSl.value = 100.0
		sliderValue = tweenSP.value/100
		--try
		--(	
			if rdoType.state !=	2 then tarObjs = (selection as array)
			else tarObjs = (for obj in objects where (classof obj.baseObject == Biped_Object) collect obj)
			TweenMachine sliderValue tarObjs
		--)
		--catch 
		--(	
		--	messageBox theMessageError title:"BsTweenMachine - ERROR"
		--)
	)

	on chkAutoKey changed state do 
	(
		animButtonState = state
	)

	on btnStepPlay pressed do
	(
		max key mode
	)

	on btnFrameTick pressed do 
	(
		if timeDisplayMode != #frameTicks then 
		(
			timeDisplayMode = #frameTicks
		)
		else 
		(
			timeDisplayMode = #frames
		)
		disableSceneRedraw()
		trackbar.visible = false
		trackbar.visible = true
		enableSceneRedraw()
	)

	on btnAbout pressed do 
	(
		shellLaunch "https://space.bilibili.com/2031113/channel/collectiondetail?sid=560782" ""
	)
)
CreateDialog rolBsTweenMachine style: #()


