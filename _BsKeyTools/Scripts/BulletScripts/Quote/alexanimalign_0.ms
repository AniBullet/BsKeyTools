-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------      Keyframe Animated Align      -----------------------------------------------------------------------------
/* Created by Alex Velez; Updated on Sep 24, 2009 
Updated on Dec 12, 2008
Updated on June 11 2010 - Full Rebuild to make it stable under max 2010
Cleaned up the alignment code, added them as functions for further updates
Jim Jaggers advanced align was my inspiration
I added the ability to animate align 2 objects based on their keyframes instead of an even increment. 
I added the ability to animate align pos, rot, and scale seperately.
I will eventually clean this code and add transform mapping incase pivot points do not match.
Added the ability to align to a biped and align biped to other objects
I added the ablitiy to bake all keys and step that increment I also added the ability to enter a time range
By default the time range looks at the animationrange.
I added the ability to undo the maxscript
I updated how keyframes are handled when you align to a key frame. I made the process cleaner and it fixed a rotation bug
any questions or comments please email alexvelez@email.com*/
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- macroScript alexAnimAlign
-- category:"Alex Tools"
-- tooltip:"Animated Align by Keyframe"
-- buttontext:"K.F. Align"
-- (

struct av_kfAlign
--define struct to hold my global values
(
	keyAlign = #(),
	tObj,
	sObj
)

--Init my structure
av_kf = av_kfAlign()

--check if rollout exists
try(destroydialog alignRoll)catch()

--define my rollout
rollout alignRoll "帧对齐"
(
	--define ui --
	local startDef = animationrange.start 
	local endDef = animationrange.end
	GroupBox grp1 "需要对齐" pos:[5,5] width:145 height:54
	GroupBox grp2 "目标物体" pos:[5,60] width:145 height:56
	pickbutton objOne "点击指定" pos:[20,20] width:115 height:31
	pickbutton Obj2 "点击指定" pos:[20,81] width:115 height:31
	button bakeBtn "烘焙" pos:[20,311] width:115 height:30
	checkbox chkPos "Pos" pos:[10,135] width:40 height:20 checked:false
	checkbox chkRot "Rot" pos:[55,135] width:40 height:20 checked:false
	checkbox chkSca "Scale" pos:[100,135] width:50 height:20 checked:false
	GroupBox grp3 "Transforms" pos:[5,120] width:145 height:41
	button doBtn "执行！" pos:[5,165] width:145 height:25
	GroupBox grp4 "增量对齐" pos:[5,201] width:145 height:147
	spinner startSpn "起始帧" pos:[20,219] width:110 height:16 range:[-999999,999999,0] type:#integer
	spinner endSpn "结束帧" pos:[20,245] width:110 height:16 range:[-999999,999999,30] type:#integer
	spinner stepSpn "间隔帧" pos:[20,270] width:110 height:16 range:[1,60,1] type:#integer
	progressBar pb1 "ProgressBar" pos:[7,356] width:140 height:8 color:(color 63 181 47)
	checkbox timeCk "时间轴帧数" pos:[35,291] width:107 height:16
	
	--Define Functions--
	
	fn rotControl rotObj kfArray =
	/*This function finds the keys on the rotation controller*/
	(
		local rotKeyControl = #()
		If classof rotObj.rotation.controller == Rotation_List then
		(
			For i =1 to rotObj.rotation.controller.count do -- iterates through each pos controller to find keys
			(
				If numkeys rotObj.rotation.controller[i].rotation.controller > 1 then -- this line finds if a particular controller has keys 
				(	
					append rotKeyControl  (rotObj.rotation.controller[i].rotation.controller) --adds controller to an array
				)
			)
		)
		Else
		(
			rotKeyControl[1] = rotObj.rotation.controller --if its a regular transform controller it assigns that to the variable
		)
		If 	rotKeyControl.count >= 1 then
		(
			for i = 1 to rotKeyControl.count do
			(
				local keyNum = numKeys rotKeyControl[i]
				for j = 1 to keyNum do
				(
					append kfArray (getKeyTime rotKeyControl[i] j)
				)
			)
		)
		Else
		(
			local rotkeyNum = numKeys rotKeyControl[1]
			for t = 1 to rotkeyNum do
			(
				append kfArray (getKeyTime rotKeyControl[1] t)
			)
		)
	)
	
	fn posControl posObj kfArray =
	/*This function finds the keys on the rotation controller*/
	(
		local posKeyControl = #()
		If classof posObj.position.controller == Rotation_List then
		(
			For i =1 to posObj.position.controller.count do -- iterates through each pos controller to find keys
			(
				If numkeys posObj.position.controller[i].position.controller > 1 then -- this line finds if a particular controller has keys 
				(	
					append posKeyControl  (posObj.position.controller[i].position.controller) --adds controller to an array
				)
			)
		)
		Else
		(
			posKeyControl[1] = posObj.position.controller --if its a regular transform controller it assigns that to the variable
		)
		If posKeyControl.count >= 1 then
		(
			for i = 1 to posKeyControl.count do
			(
				local keyNum = numKeys posKeyControl[i]
				for j = 1 to keyNum do
				(
					append kfArray (getKeyTime posKeyControl[i] j)
				)
			)
		)
		Else
		(
			local poskeyNum = numKeys posKeyControl[1]
			for t = 1 to poskeyNum do
			(
				append kfArray (getKeyTime posKeyControl[1] t)
			)
		)
	)
	
	fn bipControl bipOb kfArray= 
	/*This function finds the biped key and addes them to the array*/
	(
		bKey = numkeys bipOb.controller
		for j = 1 to bKey do 
		(
			append kfArray (getKeyTime bipOb.controller j)
		)
	)
	
	/*-------------------------------------------------- Main Body ------------------------------------------------------------*/
	on objOne picked obj do --object to be aligned
	(
		av_kf.sobj = obj
		objOne.text = obj.name
	)
	
	on Obj2 picked obj do -- pick object and populate an array with the keyframes to align
	(
		av_kf.Tobj = obj
		Obj2.text = obj.name
		If IsKindOf av_kf.Tobj.baseobject Biped_Object then
		(
			bipControl(av_kf.tObj)(av_kf.keyAlign)
		)
		Else
		(
			posControl(av_kf.tObj) (av_kf.keyAlign)
			rotControl(av_kf.tObj) (av_kf.keyAlign)
		)
	)
	
	on doBtn pressed do
	(
		sort av_kf.keyAlign
		--print av_kf.keyAlign
		undo on 
		(
			for i = 1 to av_kf.keyAlign.count do --iterates through the keyframes
			(	
				animButtonState = true --turns animate on
				slidertime = av_kf.keyAlign[i] --moves the timeslider to the proper keyframe
				--print keyArray[i]
				pb1.value = 100.*i/av_kf.keyAlign.count --progress bar
				if IsKindOf av_kf.Tobj.baseobject Biped_Object then
				(
					If chkSca.checked == true do --allows for scale alignment to  biped
					(
						av_kf.sobj.Scale = av_kf.tobj.transform.scale
					)				
					If chkRot.checked == true do --allows for rot alignment to biped
					(
						av_kf.sobj.rotation = av_kf.Tobj.transform.rotation
					)
					If chkPos.checked == true do --allows for pos alignment to biped
					(
						av_kf.sobj.position = av_kf.Tobj.transform.position
					)
				)
				Else
				(
					if IsKindOf av_kf.sobj.baseobject Biped_Object then
					(
						If chkPos.checked == true do
						(	
							biped.setTransform av_kf.sobj #pos av_kf.tobj.transform.position true
						)
						If chkRot.checked == true do
						(
							biped.setTransform av_kf.sobj #rotation av_kf.tobj.transform.rotation true
						)
					)
					Else
					(
						If chkSca.checked == true do --allows for scale alignment
						(
							av_kf.sobj.Scale = av_kf.tobj.Scale
						)
						If chkRot.checked == true do --allows for rot alignment
						(
							av_kf.sobj.rotation = av_kf.tobj.rotation
						)
						If chkPos.checked == true do --allows for pos alignment
						(
							av_kf.sobj.position = av_kf.tobj.position
						)
					)
				)
			)
		)
		pb1.value = 0
		gc light:true
	)

	on timeCk changed state do 
	(
		if state then 
		(
			startSpn.value = animationrange.start
			endSpn.value = animationrange.end
		)
	)

	on bakeBtn pressed do
	(
		undo on
		(
			if timeCk.checked == true do 
			(
				startSpn.value = animationrange.start
				endSpn.value = animationrange.end
			)
			If startSpn.value > endSpn.value then --checks to make sure animation ranges are valid
			(
				Messagebox "开始帧大于结束帧，请检查！             "
			)
			Else
			(
				disableSceneRedraw() -- disables scene redraw for speed
				for t = startSpn.value to endSpn.value by stepSpn.value do
				(
				pb1.value = 100.*t/endSpn.value				
				animButtonState = true --turns animate on
				slidertime = t --moves the timeslider to the proper keyframe
				if IsKindOf av_kf.Tobj.baseobject Biped_Object then
				(
					If chkSca.checked == true do --allows for scale alignment to  biped
					(
						av_kf.sobj.Scale = av_kf.tobj.transform.scale
					)
					If chkRot.checked == true do --allows for rot alignment to biped
					(
						av_kf.sobj.rotation = av_kf.tobj.transform.rotation
					)
					If chkPos.checked == true do --allows for pos alignment to biped
					(
						av_kf.sobj.position = av_kf.tobj.transform.position
					)
				)
				Else
				(
					if IsKindOf av_kf.sobj.baseobject Biped_Object then --allows biped to be baked but tracks seperated
					(
						If chkPos.checked == true do
						(	
							biped.setTransform av_kf.sobj #pos av_kf.tobj.transform.position true
						)
						If chkRot.checked == true do
						(
							biped.setTransform av_kf.sobj #rotation av_kf.tobj.transform.rotation true
						)
					)
					Else
					(
						If chkSca.checked == true do --allows for scale alignment
						(
							av_kf.sobj.Scale = av_kf.tobj.Scale
						)
						If chkRot.checked == true do --allows for rot alignment
						(
							av_kf.sobj.rotation = av_kf.tobj.rotation
						)
						If chkPos.checked == true do --allows for pos alignment
						(
							av_kf.sobj.position = av_kf.tobj.position
						)
					)
				)
				)
				pb1.value = 0 --resets progressbar 
				enableSceneRedraw() -- enables scene redraw
			)
		)
		gc light:true
	)
	
)
CreateDialog alignRoll 155 372
-- )