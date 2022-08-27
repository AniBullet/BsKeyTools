/*Add Spring +  Spring Controller Hierarchy By ---------------------- Hamed Pourkerman --------------------------- */
try(destroydialog SpringChanger) catch()
rollout SpringChanger "Spring Control V0.6 | HPK | " width:295 height:365--240
(
	
	groupbox grpSpEasy "简易弹簧" width:270 height:220
		label 'lbl10' "https://vimeo.com/hamedpk" pos:[16,345] width:270 height:17 align:#left
	label OffsetLbl "偏移"pos:[171,15]
	
	label SpringLbl "开/关 :" 			pos:[20,22]
	Checkbox Spring_CHK ""   			pos:[85,22] type:#boolean checked:true
	
	label SpringValueLbl "弹性值 :"pos:[20,40] 
	spinner SpringValue "" 				pos:[85,40] range:[-1000,1000,100]  type:#Float width:60
	spinner SpringValue_Offset "-->"		pos:[160,40]range:[-1000,1000,0.0]  type:#Float width:55
	
	label MassSpLbl "质量 :" 			pos:[20,60]
	spinner MassSp "" 					pos:[85,60] range:[-1000,1000,300]  type:#Float width:60
	spinner MassSp_Offset "-->" 			pos:[160,60]range:[-1000,1000,0.0]  type:#Float width:55
	
	label DragSpLbl "延迟 : " 			pos:[20,80]
	spinner DragSp "" 					pos:[85,80] range:[-1000,1000,2]  type:#Float width:60
	spinner DragSp_Offset "-->" 			pos:[160,80]range:[-1000,1000,0.0]  type:#Float width:55
	
	label TensionSpLbl "张力 : " 	pos:[20,100]
	spinner TensionSp "" 				pos:[85,100] range:[-1000,1000,1]  type:#Float width:60
	spinner TensionSp_Offset "-->" 			pos:[160,100]range:[-1000,1000,0.0]  type:#Float width:55
	
	label DampeningSpLbl "阻尼 : "	pos:[20,120]
	spinner DampeningSp "" 				pos:[85,120] range:[-1000,1000,0.5]  type:#Float width:60
	spinner DampeningSp_Offset "-->" 		pos:[160,120]range:[-1000,1000,0.0]  type:#Float width:55
	
	button ChangeAll "改变所选对象 "			pos:[17,142]  width:130 height:80 
	button ChangeAllHierarchy "改变整条层级"  pos:[149,142] width:130 height:80
	
	button PresetA "预设 A"				pos:[220,40] width:50 height:47
	button PresetB "预设 B"				pos:[220,90] width:50 height:47
	
	groupbox grp "需要先勾选，添加弹簧" 			width:270 height:117 offset:[0,85]
	
	--label SPControl_Size_LBL "Control Size :"	pos:[20,245] 
	--spinner SPControl_Size_SP "" 				pos:[85,245] range:[0,1000.0,1.0]  type:#Float width:60
	Checkbox AddSpringOnOff_CHK ""  			 pos:[260,245] width:20 type:#boolean checked:false
	editText GroupNameTxt "组名前缀 : " pos:[20,245] width:230 height:15 Text:"SpGroup" enabled:false
	
	label SPControl_Size_LBL "控制器大小 :"	pos:[20,270] enabled:false
	spinner SPControl_Size_SP "" 				pos:[90,270] range:[0,1000.0,5.0]  type:#Float width:50 enabled:false
	label CtrlStepSp_LBL "缩放步长 :"			pos:[155,270] enabled:false
	spinner CtrlStepSp "" 						pos:[220,270] range:[-1000.0,1000.0,0.0001]  type:#Float width:60 enabled:false
	
	button AddToHierarchy "添加到整条层级"		pos:[150,291] width:130 height:50 enabled:false
	button AddSPToSelection "添加到所选择" 		pos:[17,291] width:130 height:50 enabled:false
	
	
	--button AddPosXyz "Add PositionXYZ"  		pos:[155,268] width:120 height:24
	/*=========================================================================================*/
	/*-/*/-----------------------				Return Childs Hierarchy "Children List"				  ----------------------------
	fn makeChildList Obj=()
	---------------------------------------------------------------------------------RECURSIVE----------------------------------------------------------------------------------------------
	fn ReturnChildern ObjOne Types=
	(
		Obj = ObjOne
		Global SpringChildList = #()
		-----------------------------------**************************************************
		-----------------------------------**************************************************
		fn makeChildList Obj Type=
		(
			ChildArray = $.children	
			if Type == "Spring" then
			(
			for i in ChildArray do
				(
					iSpring = 0
					aCtrl = undefined
					try aCtrl = getSubAnimNames i.controller[1].controller catch()
					if aCtrl != undefined do iSpring = findItem aCtrl #spring
					if (iSpring != 0) and (aCtrl != undefined) do
					(
						appendifunique SpringChildList i
						select i
						try makeChildList i "Spring" catch()
					)
				)
			)
			else if type == "All Childrens" do
			(
				for i in ChildArray do
				(
					appendifunique SpringChildList i
					select i
					try makeChildList i "All Childrens" catch()
				)

			)
		)
		-----------------------------------**************************************************
		-----------------------------------**************************************************
		makeChildList ObjOne Types
		select ObjOne
		return SpringChildList
	)
	
	/*=========================================================================================*/
	------------------------------------------------------   		FreezeTransform		 ---------------------------------------------------------------------
	fn FreezeTransform Obj= 	
	( 		
	--suspendEditing()
		Try
			(	
				local CurObj = Obj 	
				if classof CurObj.rotation.controller != Rotation_Layer do
				(
					CurObj.rotation.controller = Euler_Xyz() 		
					CurObj.rotation.controller = Rotation_list() 			
					CurObj.rotation.controller.available.controller = Euler_xyz() 		
					CurObj.rotation.controller.setname 1 "Zero"
					CurObj.rotation.controller.setname 2 "Animation"	
					CurObj.rotation.controller.SetActive 2 		
				)
				if classof CurObj.position.controller != Position_Layer do
				(
					CurObj.position.controller = Bezier_Position() 			
					CurObj.position.controller = position_list() 			
					CurObj.position.controller.available.controller = Position_XYZ() 	
					CurObj.position.controller.setname 1 "Zero"
					CurObj.position.controller.setname 2 "Animation"	
					CurObj.position.controller.SetActive 2 		
					CurObj.Position.controller[2].x_Position = 0
					CurObj.Position.controller[2].y_Position = 0
					CurObj.Position.controller[2].z_Position = 0
				)
			)	
			Catch()
		--resumeEditing()
	)	
	/*=========================================================================================*/
	------------------------------------------------------   Add Selected Object To Children List ---------------------------------------------------------------------
	fn Return_Obj_And_Childern Obj =
	(
		Childs_list = #()
		temparr = ReturnChildern $ "All Childrens"
		append Childs_list Obj                                        -- Put Selected Object In First Index Of Child Array
		for i = 1 to temparr.count do append Childs_list temparr[i] --Fill Child List
		return 	Childs_list
	)
	/*=========================================================================================*/
	-------------------------------------------------------------------MAKE Points For Each Node Of Array--------------------------------------------------------------------------------------------------------------------------------
	fn makepoints arr siz Wcolor = 
		(
			PtArray = #()
			for x in arr do
			(	
				pt = point size:1.0 box:true wirecolor:[0,255,0]
				pt.size = siz
				pt.wirecolor = Wcolor
				pt.transform=x.transform
					pt.Box = on
					pt.cross = off
					pt.centermarker = off
					pt.axistripod = off
				pt.name = x.name + "_Pt_"
				append PtArray pt
			)	
			return PtArray
		)
	/*=========================================================================================*/
	--------------------------------           Make HI IkSolver For Each Node In Children   ---------------------------------------------------------------------
	fn MakeHISolver Obj DisplaySize = 
	(
		HISolverLists = #()
		--Childs_list = #()
		Childs_list = Return_Obj_And_Childern Obj
		
		----ADD HI SOLVER
		for i = 1 to Childs_list.count-1 do 
		(
			HIsolver = iksys.ikchain Childs_list[i] Childs_list[i+1] "IKHISolver"
			HIsolver.name = "HiSolver_0"+ (i as string)+"_"
			HIsolver.transform.controller.goalSize = DisplaySize
			append HISolverLists HIsolver
		)
		return HISolverLists
	)
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	/*=========================================================================================*/
	------------------------------------------------------			Add Circle To Each Nodes of List_Array 		-------------------------------------
	fn Add_Circle_Ctrl List_Array Sizez Wirecolor=
	(
		Temp_List = #()
		index = 1
		for x in List_Array do
		(
			Sizez = Sizez-(index*CtrlStepSp.value)
			steps = 1
			CirA = circle pos:x.pos  wirecolor:Wirecolor
			CirA.radius = Sizez
			CirA.Steps= steps
			CirA.name = x.name + "_CirCtrl_0"+(index as string)
			CirA.render_displayRenderMesh = True
			CirA.thickness = abs(Sizez)*.015
			CirA.sides = 4			
			convertToSplineShape CirA
			if index > 1 do CirA.parent = Temp_List[index-1]
			CirA.Transform = x.Transform
			FreezeTransform CirA
			append Temp_List CirA
			index +=1
		)
			return Temp_List
	) 
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	/*=========================================================================================*/
	------------------------------------------------------		Add Spring Controller	 + Align To Position			-------------------------------------
	fn Add_Spring_Controller List_Array = 
	(
		pt_array=#()
		For i= 1 to List_Array.count Do 
		(
			pt= point size:1.0 centermarker:false axistripod:true cross:false box:true drawontop:false wirecolor:[0,0,255]
			pt.transform = List_Array[i].transform
			if i > 1 do pt.parent = pt_array[i-1]
			append pt_array pt
		)
		For i= 1 to List_Array.count Do 
		(
			List_Array[i].pos.controller.Available.controller = SpringPositionController ()
			List_Array[i].pos.controller.setactive 3
			List_Array[i].pos.controller.delete 2 
			List_Array[i].transform = pt_array[i].transform
			if pt_array[i].parent != undefined then
				pos = in coordsys parent pt_array[i].Position 
			else 
				pos = pt_array[i].Position
			
			List_Array[i].position.controller[#Spring].Position = pos	
			--------------------------------------------------------------------------------------------------------------------------------------------
			List_Array[i].pos.controller.Available.controller = Position_XYZ ()
			List_Array[i].pos.controller.setname 3 "Animation"
			List_Array[i].pos.controller.setactive 3
		)
		for i = 1 to pt_array.count do delete pt_array[i]
		pt_array=#()
	) 
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	/*=========================================================================================*/
	------------------------------------------------------				Add Spring Modifiers					-------------------------------------
	fn AddSpModifier_To_List List_Array =
	(
		ca=attributes Springctrl
		(
			parameters params rollout:SpringA
			(
				Mass type:#float ui:MassSP
				Drags type:#float ui:DragsSp
				Tension type:#float ui:TensionSp
				Damping type:#float ui:DampingSp
				
				chbx type:#boolean ui: Spring_on_off
				SpringValue type:#float ui:SpringValueSP
			)
				
			rollout SpringA "Spring Option Controls For All"
			(
				local range=[-500,500,0]
					
				group "Springs Value Control"
					(
						spinner SpringValueSP "Spring Value" range:[-500,500,0]
						
						On SpringValueSP changed Val Do 
						(
							$.pos.controller.Spring.controller.x_effect = SpringValue	
							$.pos.controller.Spring.controller.y_effect = SpringValue	
							$.pos.controller.Spring.controller.z_effect = SpringValue	
						)
						
						checkbox Spring_on_off "Spring On Or Off" default:true
							on Spring_on_off changed theState do 
							if chbx==true then
								(
									$.pos.controller.weight[2] = 100.0
								)
								else 
								(
									$.pos.controller.weight[2] = 0.0
								)
					)			

		group "Springs Control"
			(
				spinner MassSP "Mass" range:[-500,500,300]
				spinner DragsSp "Drag" range:[-500,500,1]
				spinner TensionSp "Tension" range:[-500,500,0.4]
				spinner DampingSp "Damping" range:[-500,500,0.2]
			
				On MassSP changed val Do ($.pos.controller.Spring.setMass(Mass) )
			
				On DragsSp changed val Do ($.pos.controller.Spring.setDrag(Drags))
					
				On TensionSp changed val Do ($.pos.controller.Spring.setTension(1)(Tension) )
			
				On DampingSp changed val Do ($.pos.controller.Spring.setDampening(1)(Damping))
			
			)			
		group "Reset Transform"
			(
				button reseta "Reset To Default"
			   on reseta pressed do 
				(
				$.Controller.position.controller[3].position = [0,0,0]
				$.Controller.Rotation.controller[2].rotation =(quat 0 0 0 1)
				)
			)
		)
		)
		for x in List_Array do
		(
			Emp = (EmptyModifier ())
			Emp.name = "Spring Controller"	
			addmodifier x Emp
			custAttributes.add x.modifiers[1] ca
		)
	)
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	/*=========================================================================================*/
		on AddToHierarchy pressed do
		( 
			undo on
			(
				suspendEditing()
				Wirecolor = [0,255,255]
				iSpring = 0
				aCtrl = undefined
				if selection.count == 1 then 
				(
					try aCtrl = getSubAnimNames $.controller[1].controller catch()
					if aCtrl != undefined do iSpring = findItem aCtrl #spring
					if (iSpring == 0) or (aCtrl == undefined) then
					(
						Nodes_List = Return_Obj_And_Childern $
/* Add Prefix name Node_list */ if GroupNameTxt.Text != "" do for x in Nodes_List do x.name = GroupNameTxt.Text +"_"+ x.name
						HIikS_List = MakeHISolver $ (SPControl_Size_SP.value*0.1)
/* Add Prefix name HikS_list */ if GroupNameTxt.Text != "" do for x in HIikS_List do x.name = GroupNameTxt.Text +"_"+ x.name
						Ctrl_List = Add_Circle_Ctrl Nodes_List SPControl_Size_SP.value Wirecolor
						Nodes_List[1].parent = Ctrl_List[1]
						for i = 1 to Nodes_List.count-1 do HIikS_List[i].parent = Ctrl_List[i+1]
						Add_Spring_Controller Ctrl_List
						AddSpModifier_To_List Ctrl_List
					) else messagebox "这个物体已经创建了弹簧！                        "
				)
				else
					messagebox "请选择一个父级物体！                       "
				
			resumeEditing()
			)
		--redrawviews()
		)
	/*=========================================================================================*/						
	----------------------------------------------------------- Add Spring To Selection ------------------------------------------------------------------------------------		
			on AddSPToSelection pressed do
			( 
				undo on
				(
					suspendEditing()
					Wirecolor = [0,255,255]
					Nodes_List = selection as array
					----- Link Selection As Hierarchy 
					for i = 1 to Nodes_List.count do 
					(
						FreezeTransform Nodes_List[i]
						if i>1 do Nodes_List[i].parent = Nodes_List[i-1]
						if 	GroupNameTxt.Text != "" do
						(
							Nodes_List[i].name = GroupNameTxt.Text +"_"+ Nodes_List[i].name
						)
					)
					------- End Link
					select Nodes_List[1]
					if selection.count == 1 then 
					(
						Add_Spring_Controller Nodes_List
						AddSpModifier_To_List Nodes_List
					)
					else
						messagebox "请选择一个父级物体！                       "
					resumeEditing()						
				)
			redrawviews()
			resumeEditing()
			--select Nodes_List	
			)
		/*=========================================================================================*/						
			on AddSpringOnOff_CHK changed thestate do 
			(
				if AddSpringOnOff_CHK.checked == true then 
				(
					GroupNameTxt.enabled = true
					SPControl_Size_LBL.enabled = true
					SPControl_Size_SP.enabled = true
					CtrlStepSp_LBL.enabled = true
					CtrlStepSp.enabled = true
					AddToHierarchy.enabled = true
					AddSPToSelection.enabled = true
				)else
				(
					GroupNameTxt.enabled = false
					SPControl_Size_LBL.enabled = false
					SPControl_Size_SP.enabled = false
					CtrlStepSp_LBL.enabled = false
					CtrlStepSp.enabled = false
					AddToHierarchy.enabled = false
					AddSPToSelection.enabled = false
				)
			)
	/*=========================================================================================*/						
			on PresetA pressed do
			(
				SpringValue.Value = 100 ;		SpringValue_Offset.Value = -10
				MassSp.Value = 300 		;		MassSp_Offset.value = 0.0
				DragSp.Value =	1		;		DragSp_Offset.value = -0.1
				TensionSp.Value =	1	;		TensionSp_Offset.value = -0.1
				DampeningSp.Value =	1	;		DampeningSp_Offset.value=-0.1
			)
			on PresetB pressed do
			(
				SpringValue.Value = 10 	;		SpringValue_Offset.Value = 10
				MassSp.Value = 300 		;		MassSp_Offset.value = 0.0
				DragSp.Value =	0.6		;		DragSp_Offset.value = -0.025
				TensionSp.Value =	0.6	;		TensionSp_Offset.value = -0.025
				DampeningSp.Value =	0.6	;		DampeningSp_Offset.value=-0.025
			)
			on ChangeAll pressed do
			(
				 If selection.count == 1 then 
					( 
						try aC = getSubAnimNames $.controller[1].controller catch()
						iSpring = findItem aC #spring
						if Spring_CHK.state == true then try $.pos.controller.weight[iSpring] = 100 catch()
						else try $.pos.controller.weight[iSpring] = 0 catch()
					try(
						$.modifiers[1].Springctrl.chbx = Spring_CHK.state
						$.pos.controller.Spring.setMass(MassSp.Value)
						$.pos.controller.Spring.setDrag(DragSp.value)		
						$.pos.controller.Spring.setTension(1)(TensionSp.value)
						$.pos.controller.Spring.setDampening(1)(DampeningSp.Value)
							
						$.modifiers[1].Springctrl.SpringValue = SpringValue.Value
						$.modifiers[1].Springctrl.Mass = MassSp.Value
						$.modifiers[1].Springctrl.Drags = DragSp.Value
						$.modifiers[1].Springctrl.tension = TensionSp.Value
						$.modifiers[1].Springctrl.Damping = DampeningSp.Value

						$.pos.controller.Spring.controller.x_effect = SpringValue.Value  	
						$.pos.controller.Spring.controller.y_effect = SpringValue.Value
						$.pos.controller.Spring.controller.z_effect = SpringValue.Value
					)catch(messagebox "选择对象有误，请检查是否创建弹簧！                         ")
					)
					else 
					(
						Childs = selection as array
						for i = 1 to Childs.count do
						(
							try aC = getSubAnimNames Childs[i].controller[1].controller catch()
							iSpring = findItem aC #spring
							if Spring_CHK.state == true then try Childs[i].pos.controller.weight[iSpring] = 100 catch()
							else try Childs[i].pos.controller.weight[iSpring] = 0 catch()
						try(
							Childs[i].modifiers[1].Springctrl.chbx = Spring_CHK.state
							Childs[i].pos.controller.Spring.setMass((MassSp.Value + (MassSp_Offset.value*(i-1))))
							Childs[i].pos.controller.Spring.setDrag((DragSp.value + (DragSp_Offset.value*(i-1))))		
							Childs[i].pos.controller.Spring.setTension(1)((TensionSp.value + (TensionSp_Offset.value*(i-1))))
							Childs[i].pos.controller.Spring.setDampening(1)((DampeningSp.Value + (DampeningSp_Offset.value*(i-1))))
							 
							Childs[i].modifiers[1].Springctrl.SpringValue = SpringValue.Value + (SpringValue_Offset.Value*(i-1))
							Childs[i].modifiers[1].Springctrl.Mass = MassSp.Value + (MassSp_Offset.value*(i-1))
							Childs[i].modifiers[1].Springctrl.Drags = DragSp.Value + (DragSp_Offset.value*(i-1))
							Childs[i].modifiers[1].Springctrl.tension = TensionSp.Value + (TensionSp_Offset.value*(i-1))
							Childs[i].modifiers[1].Springctrl.Damping = DampeningSp.Value + (DampeningSp_Offset.value*(i-1))
							
							Childs[i].pos.controller.Spring.controller.x_effect = SpringValue.Value + (SpringValue_Offset.value*(i-1)) 	
							Childs[i].pos.controller.Spring.controller.y_effect = SpringValue.Value + (SpringValue_Offset.value*(i-1))
							Childs[i].pos.controller.Spring.controller.z_effect = SpringValue.Value + (SpringValue_Offset.value*(i-1))
						)catch(messagebox "选择对象有误，请检查是否创建弹簧！                         ")
						)
					)
				---Simulate Spring FrameByFrame To Prevent System Freez Or Hang
				for i = animationRange.start to animationRange.end do
				(
					slidertime = i
				)
			 ) 
			 on ChangeAllHierarchy pressed do
			(
				 If selection.count == 1 then 
					(
						
						Childs_list = ReturnChildern $ "Spring"
						Childs = #()
						append Childs $
						for i = 1 to childs_list.count do append Childs Childs_list[i]
						--print  Childs
						--iSpring=2
						for i = 1 to Childs.count do
						(
							try aC = getSubAnimNames Childs[i].controller[1].controller catch()
							iSpring = findItem aC #spring
							if Spring_CHK.state == true then  try Childs[i].pos.controller.weight[iSpring] = 100 catch()
							else try Childs[i].pos.controller.weight[iSpring] = 0 catch()
							try(
							Childs[i].pos.controller.Spring.setMass((MassSp.Value + (MassSp_Offset.value*(i-1))))
							Childs[i].pos.controller.Spring.setDrag((DragSp.value + (DragSp_Offset.value*(i-1))))		
							Childs[i].pos.controller.Spring.setTension(1)((TensionSp.value + (TensionSp_Offset.value*(i-1))))
							Childs[i].pos.controller.Spring.setDampening(1)((DampeningSp.Value + (DampeningSp_Offset.value*(i-1))))
							
							Childs[i].modifiers[1].Springctrl.chbx = Spring_CHK.state
							Childs[i].modifiers[1].Springctrl.SpringValue = SpringValue.Value + (SpringValue_Offset.Value*(i-1))
							Childs[i].modifiers[1].Springctrl.Mass = MassSp.Value + (MassSp_Offset.value*(i-1))
							Childs[i].modifiers[1].Springctrl.Drags = DragSp.Value + (DragSp_Offset.value*(i-1))
							Childs[i].modifiers[1].Springctrl.tension = TensionSp.Value + (TensionSp_Offset.value*(i-1))
							Childs[i].modifiers[1].Springctrl.Damping = DampeningSp.Value + (DampeningSp_Offset.value*(i-1))
							
							Childs[i].pos.controller.Spring.controller.x_effect = SpringValue.Value + (SpringValue_Offset.value*(i-1)) 	
							Childs[i].pos.controller.Spring.controller.y_effect = SpringValue.Value + (SpringValue_Offset.value*(i-1))
							Childs[i].pos.controller.Spring.controller.z_effect = SpringValue.Value + (SpringValue_Offset.value*(i-1))
							)catch(messagebox "选择对象有误，请检查是否创建弹簧！                         ")
						)
					)
					else 
						(
							messagebox "请选择一个父级物体！                       "
						)
				
				---Simulate Spring FrameByFrame To Prevent System Freez Or Hang
				for i = animationRange.start to animationRange.end do
				(
					slidertime = i
				)
			 )
			)
		
createDialog SpringChanger 
