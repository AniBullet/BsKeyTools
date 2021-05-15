(
	--variables skiner
	global arr_obj = #()
	global arr_obj_names = #()
	global arr_bones = #()
	global bone_only = false
	global as_one = false
	global arr_existbone = #()
	--functions
	
	--rollouts
	try(destroyDialog skiner)catch()
	rollout skiner "Add Skin" width:152 height:344
	(
		button bt_help "help" pos:[0,0] width:32 height:16
		listbox lbx_obj "Objects to Skin:" pos:[8,24] width:145 height:8
		button bt_add "Add" pos:[8,152] width:96 height:20
		button bt_clear "Clear" pos:[104,152] width:49 height:20
		button bt_create "Create Skin" pos:[160,10] width:155 height:40
		button bt_add_bone "Add Bones to Skin" pos:[160,55] width:155 height:32
		checkbox ch_bone "Use only bone objects" pos:[165,95] width:155 height:16 enabled:true
		checkbox ch_one "Skin as one obj" pos:[165,115] width:155 height:16 enabled:true
		button bt_pick_bone "Start pick mode" pos:[160,140] width:155 height:32
	-- )createdialog skiner
		on skiner open do 
			(
				ch_bone.checked = true
				bone_only = ch_bone.checked
				ch_one.checked = true
				as_one = ch_one.checked
				)
	
		on bt_help pressed do 
			(
				messagebox " 		Skin By Selection Bones
	--------------------------------------------------------
	Tool for fast adding skin modifer and attach selected bones to all objects in list
	quick start:
	- select objects that you want apply skin and push 'add' button
	- select bones that needed adding in skin and push 'Create skin'
	-- select bones that needed adding in already created skin and push 'add bones to skin'
		push CTRL and click on 'add bones to skin' to add selected bones again. Then you get
	second envelop for one bone
	-- select object with skin and push 'Start pick mode' for add bones to skin by clickin on them
	
	other:
	- right click on item in list to delete it from list
	- double click on item in list to select object in scene
	- With 'Use only bone objects' you can select all objects in scene, but skin add only bone objects
	- If 'Skin as one object' is disable, then skin modifer will apply on objects in list separatly
	"
				)
	
		on bt_add pressed do 
			(
				for i in selection do 
					(
						if iskindof i GeometryClass==true or iskindof i Shape==true then
							(
								for i in selection do 
									(
										appendifunique arr_obj i
										)
								for i=1 to arr_obj.count do 
									(
										appendifunique arr_obj_names arr_obj[i].name
										)
								lbx_obj.items = arr_obj_names
								) else 
								(
									messagebox (i.name + "not geometry or shape class")
									exit
									)
						)
				)
		
		on bt_clear pressed do 
			(
				arr_obj = #()
				arr_obj_names = #()
				lbx_obj.items = arr_obj_names
				)
	
		on lbx_obj rightClick obj do 
			(
				for i=1 to arr_obj.count do 
					(
						if arr_obj[i].name == lbx_obj.items[obj] do 
							(
								deleteitem arr_obj i
								exit
								)
						)
				for i=1 to arr_obj_names.count do 
					(
						if arr_obj_names[i] == lbx_obj.items[obj] do 
							(
								deleteitem arr_obj_names i
								exit
								)
						)
				lbx_obj.items = arr_obj_names
				)
				
		on lbx_obj doubleClicked obj do 
			(
				select arr_obj[obj]
				)
		
		on bt_create pressed do with undo on
			(
				max modify mode
				arr_bones = #()
				if bone_only==true then 
					(
						for i in selection do 
							(
								if iskindof i BoneGeometry == true or iskindof i Biped_Object == true or iskindof i CATBone == true or iskindof i HubObject == true do 
									(
										append arr_bones i
										)
								)
						) else 
						(
							arr_bones = selection as array
							)
				
				if as_one==true then 
					(
						select arr_obj
						addModifier selection (skin())
						select selection
						for a=1 to arr_bones.count do 
							(
								skinOps.addBone selection[1].modifiers[#Skin] arr_bones[a] 0
								)
						select arr_obj
						subobjectLevel=1
						) else 
						(
							for i=1 to arr_obj.count do 
								(
									addModifier arr_obj[i] (skin())
									select arr_obj[i]
									for a=1 to arr_bones.count do 
										(
											skinOps.addBone arr_obj[i].modifiers[#Skin] arr_bones[a] 0
											)
									)
							select arr_obj
							)
	
				)
	
		on ch_bone changed che do 
			(
				bone_only = che
				)
	
		on ch_one changed che do 
			(
				as_one = che
				)
	
		on bt_add_bone pressed do with undo on
			(
				arr_bones = #()
				arr_existbone = #()
				if bone_only==true then 
					(
						for i in selection do 
							(
								if iskindof i BoneGeometry == true or iskindof i Biped_Object == true or iskindof i CATBone == true or iskindof i HubObject == true do 
									(
										append arr_bones i
										)
								)
						) else 
						(
							arr_bones = selection as array
							)
				
				for i=1 to arr_obj.count do 
					(
						select arr_obj[i]
						local ch=0
						for i in $.modifiers do 
							(
								if classof i==skin do ch=1
								)
						if ch==1 do 
							(
								max modify mode
								modPanel.setCurrentObject $.skin
								for a=1 to arr_bones.count do 
									(
										ch2=0
										for s=1 to (skinOps.GetNumberBones arr_obj[i].skin) do 
											(
												if (skinOps.GetBoneName arr_obj[i].skin s 1)==arr_bones[a].name then 
													(
	-- 													messagebox (arr_bones[a].name + " is already added in skin")
														append arr_existbone arr_bones[a]
														ch2=0
														exit
														) else 
														(
															ch2=1
															)
												)
										if (skinOps.GetNumberBones arr_obj[i].skin)==0 do ch2=1
												
										if keyboard.controlPressed == true do (ch2=1)
										if ch2==1 do 
											(
												skinOps.addBone arr_obj[i].skin arr_bones[a] 1
												)
										)
								if arr_existbone.count!=0 do 
									(
										local message = ""
										for i=1 to arr_existbone.count do 
											(
												message+=arr_existbone[i].name
												if i != arr_existbone.count do 
													(
														message+=", "
														)
												)
										if keyboard.controlPressed != true do messagebox (message+" not added, already in skin")
										)
								select arr_obj
								if selection.count==1 do modPanel.setCurrentObject $.skin
								)
						)
	
				)
				
		on bt_pick_bone pressed do with undo on 
			(
				if selection.count !=1 then 
					(
						messagebox "Select only one object with skin modifier"
						) else 
						(
							ch=0
							for i in $.modifiers do 
								(
									if classof i==skin do ch=1
									)
							if ch==1 do 
								(
									max modify mode
									modPanel.setCurrentObject $.skin
									skinOps.addBoneFromViewStart $.modifiers[#Skin]
									)
							)
				)
		)
	-- createdialog skiner
	
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	global ch=0
	global SkinEditor
	
	fn fn_skin_tools_reint =
		(
			if (selection.count > 0 and modPanel.getCurrentObject() == selection[1].modifiers[#skin]) and subobjectLevel == 1 and skinOps.GetNumberBones selection[1].modifiers[#Skin] > 0 then 
				(
					
					SkinEditor.ch_vert.enabled=true
					SkinEditor.bt_excl.enabled=true
					SkinEditor.bt_incl.enabled=true
					SkinEditor.bt_reset_vert.enabled=true
					SkinEditor.bt_reset_bone.enabled=true
	
					SkinEditor.bt_env_copy.enabled=true
					SkinEditor.bt_env_paste.enabled=true
					SkinEditor.bt_prev.enabled=true
					SkinEditor.bt_next.enabled=true
	
					SkinEditor.spn_abs_effect.enabled=true
					SkinEditor.bt_weight_tool.enabled=true
					SkinEditor.bt_0.enabled=true
					SkinEditor.bt_01.enabled=true
					SkinEditor.bt_025.enabled=true
					SkinEditor.bt_05.enabled=true
					SkinEditor.bt_075.enabled=true
					SkinEditor.bt_09.enabled=true
					SkinEditor.bt_1.enabled=true
					SkinEditor.ch_noenv.enabled=true
					SkinEditor.spn_limit.enabled=true
					
					SkinEditor.grp_parametres.enabled=true
					SkinEditor.grp_reset.enabled=true
					SkinEditor.grp_vert.enabled=true
					SkinEditor.grp_env.enabled=true
					SkinEditor.ch_always_deform.enabled=true
					
					SkinEditor.ch_vert.state=selection[1].skin.filter_vertices
					SkinEditor.ch_sel_element.state=selection[1].skin.selectElement
					SkinEditor.ch_backface.state=selection[1].skin.backFaceCull
					SkinEditor.ch_noenv.state=selection[1].skin.showNoEnvelopes
					SkinEditor.spn_limit.value=selection[1].skin.bone_Limit
					SkinEditor.ch_always_deform.state=selection[1].skin.always_deform
					if SkinEditor.ch_vert.state == true then 
						(
							SkinEditor.ch_sel_element.enabled=true
							SkinEditor.ch_backface.enabled=true
							SkinEditor.bt_shrink.enabled=true
							SkinEditor.bt_grow.enabled=true
							SkinEditor.bt_ring.enabled=true
							SkinEditor.bt_loop.enabled=true
							) else 
							(
								SkinEditor.ch_sel_element.enabled=false
								SkinEditor.ch_backface.enabled=false
								SkinEditor.bt_shrink.enabled=false
								SkinEditor.bt_grow.enabled=false
								SkinEditor.bt_ring.enabled=false
								SkinEditor.bt_loop.enabled=false
								)
					) else 
					(
						SkinEditor.ch_vert.enabled=false
						SkinEditor.bt_shrink.enabled=false
						SkinEditor.bt_grow.enabled=false
						SkinEditor.bt_ring.enabled=false
						SkinEditor.bt_loop.enabled=false
						SkinEditor.ch_sel_element.enabled=false
						SkinEditor.ch_backface.enabled=false
						
						SkinEditor.bt_excl.enabled=false
						SkinEditor.bt_incl.enabled=false
						SkinEditor.bt_reset_vert.enabled=false
						SkinEditor.bt_reset_bone.enabled=false
	
						SkinEditor.bt_env_copy.enabled=false
						SkinEditor.bt_env_paste.enabled=false
						SkinEditor.bt_prev.enabled=false
						SkinEditor.bt_next.enabled=false
	
						SkinEditor.spn_abs_effect.enabled=false
						SkinEditor.bt_weight_tool.enabled=false
						SkinEditor.bt_0.enabled=false
						SkinEditor.bt_01.enabled=false
						SkinEditor.bt_025.enabled=false
						SkinEditor.bt_05.enabled=false
						SkinEditor.bt_075.enabled=false
						SkinEditor.bt_09.enabled=false
						SkinEditor.bt_1.enabled=false
						SkinEditor.ch_noenv.enabled=false
						SkinEditor.spn_limit.enabled=false
						
						SkinEditor.grp_parametres.enabled=false
						SkinEditor.grp_reset.enabled=false
						SkinEditor.grp_vert.enabled=false
						SkinEditor.grp_env.enabled=false
						SkinEditor.ch_always_deform.enabled=false
						)
			)
		
	fn check_skin = 
		(
			ch=0
			if selection.count!=0 do 
				(
					for i in selection[1].modifiers do 
						(
							if classof i==skin do ch=1
							)
					if ch==1 do 
						(
							max modify mode
							if (classof (modPanel.getCurrentObject()))!=skin do 
								(
									modPanel.setCurrentObject selection[1].skin
									)
							if subobjectLevel!=1 do 
								(
									subobjectLevel=1
									)
							)
					)
			)
	
			
	try(destroyDialog SkinEditor)catch()
	rollout SkinEditor "Edit skin" width:176 height:464
	(
		GroupBox grp_parametres "Parametres" pos:[8,8] width:150 height:140
		checkbox ch_vert "Vertices" pos:[24,30] width:72 height:16
		button bt_shrink "Shrink" pos:[24,54] width:56 height:24
		button bt_grow "Grow" pos:[80,54] width:56 height:24
		button bt_ring "Ring" pos:[24,78] width:56 height:24
		button bt_loop "Loop" pos:[80,78] width:56 height:24
		checkbox ch_sel_element "Select Element" pos:[24,108] width:96 height:16
		checkbox ch_backface "Backface Cull Vertices" pos:[24,125] width:128 height:16
		button bt_excl "Exclude" pos:[165,80] width:75 height:50
		button bt_incl "Include" pos:[240,80] width:75 height:50
		button bt_reset_vert "Vertex" pos:[235,155] width:40 height:20
		GroupBox grp_reset "Reset selected" pos:[230,140] width:88 height:40
		button bt_reset_bone "Bone" pos:[275,155] width:40 height:20
		GroupBox grp_vert "Selected Vertex:" pos:[160,8] width:160 height:130
		button bt_env_copy "Copy" pos:[16,170] width:40 height:24
		button bt_env_paste "Paste" pos:[56,170] width:40 height:24 tooltip:"click=paste\nctrl+click=paste to all"
		button bt_prev "<" pos:[104,170] width:24 height:24 toolTip:"select previous envelope"
		button bt_next ">" pos:[128,170] width:24 height:24 toolTip:"select next envelope"
		GroupBox grp_env "Envelope:" pos:[8,150] width:150 height:72
		spinner spn_abs_effect "Abs. Effect: " pos:[194,60] width:120 height:16 range:[0,1,0] type:#float
		button bt_weight_tool "Weight Tool" pos:[162,145] width:64 height:35
		button bt_0 "0" pos:[165,25] width:18 height:24
		button bt_01 ".1" pos:[183,25] width:21 height:24
		button bt_025 ".25" pos:[204,25] width:24 height:24
		button bt_05 ".5" pos:[228,25] width:24 height:24
		button bt_075 ".75" pos:[252,25] width:24 height:24
		button bt_09 ".9" pos:[276,25] width:20 height:24
		button bt_1 "1" pos:[296,25] width:20 height:24
		checkbox ch_noenv "Show No Envelope" pos:[24,200] width:120 height:16
		spinner spn_limit "Bone Affect Limit: " pos:[215,185] width:100 height:16 type:#integer
		checkbox ch_always_deform "Always Deform" pos:[165,205] width:104 height:16
	-- )createdialog SkinEditor
		
		on SkinEditor close do 
			(
				unRegisterRedrawViewsCallback fn_skin_tools_reint
				) 
		
		on SkinEditor open do 
			(
				SkinEditor.ch_vert.enabled=false
				SkinEditor.bt_shrink.enabled=false
				SkinEditor.bt_grow.enabled=false
				SkinEditor.bt_ring.enabled=false
				SkinEditor.bt_loop.enabled=false
				SkinEditor.ch_sel_element.enabled=false
				SkinEditor.ch_backface.enabled=false
				
				SkinEditor.bt_excl.enabled=false
				SkinEditor.bt_incl.enabled=false
				SkinEditor.bt_reset_vert.enabled=false
				SkinEditor.bt_reset_bone.enabled=false
	
				SkinEditor.bt_env_copy.enabled=false
				SkinEditor.bt_env_paste.enabled=false
				SkinEditor.bt_prev.enabled=false
				SkinEditor.bt_next.enabled=false
	
				SkinEditor.spn_abs_effect.enabled=false
				SkinEditor.bt_weight_tool.enabled=false
				SkinEditor.bt_0.enabled=false
				SkinEditor.bt_01.enabled=false
				SkinEditor.bt_025.enabled=false
				SkinEditor.bt_05.enabled=false
				SkinEditor.bt_075.enabled=false
				SkinEditor.bt_09.enabled=false
				SkinEditor.bt_1.enabled=false
				SkinEditor.ch_noenv.enabled=false
				SkinEditor.spn_limit.enabled=false
				
				SkinEditor.grp_parametres.enabled=false
				SkinEditor.grp_reset.enabled=false
				SkinEditor.grp_vert.enabled=false
				SkinEditor.grp_env.enabled=false
				ch_always_deform.enabled=false
				registerRedrawViewsCallback fn_skin_tools_reint
				check_skin ()
				if ch==1 do 
					(
						fn_skin_tools_reint ()
						)
				)
		
		on ch_vert changed state do
			(
				check_skin ()
				if ch==1 do 
					(
						selection[1].skin.filter_vertices=state
						if ch_vert.state == true then 
							(
								ch_sel_element.enabled=true
								ch_backface.enabled=true
								bt_shrink.enabled=true
								bt_grow.enabled=true
								bt_ring.enabled=true
								bt_loop.enabled=true
								) else 
								(
									ch_sel_element.enabled=false
									ch_backface.enabled=false
									bt_shrink.enabled=false
									bt_grow.enabled=false
									bt_ring.enabled=false
									bt_loop.enabled=false
									)
						)
				)
		on bt_shrink pressed  do
			(
				check_skin ()
				if ch==1 do 
					(
						skinOps.shrinkSelection selection[1].skin
						)
				)
		on bt_grow pressed  do
			(
				check_skin ()
				if ch==1 do 
					(
						skinOps.growSelection selection[1].skin
						)
				)
		on bt_ring pressed  do
			(
				check_skin ()
				if ch==1 do 
					(
						skinOps.ringSelection selection[1].skin
						)
				)
		on bt_loop pressed  do
			(
				check_skin ()
				if ch==1 do 
					(
						skinOps.loopSelection selection[1].skin
						)
				)
		on ch_sel_element changed state do
			(
				check_skin ()
				if ch==1 do 
					(
						selection[1].skin.selectElement=state
						)
				)
		on ch_backface changed state do
			(
				check_skin ()
				if ch==1 do 
					(
						selection[1].skin.backFaceCull=state
						)
				)
		on bt_excl pressed  do
			(
				check_skin ()
				if ch==1 do 
					(
						skinOps.ButtonExclude selection[1].skin
						skinOps.selectNextBone selection[1].skin
						skinOps.selectPreviousBone selection[1].skin
						)
				)
		on bt_incl pressed  do
			(
				check_skin ()
				if ch==1 do 
					(
						skinOps.ButtonInclude selection[1].skin
						)
				)
		on bt_reset_vert pressed  do
			(
				check_skin ()
				if ch==1 do 
					(
						skinOps.resetSelectedVerts selection[1].skin
						)
				)
		on bt_reset_bone pressed  do
			(
				check_skin ()
				if ch==1 do 
					(
						skinOps.resetSelectedBone selection[1].skin
						)
				)
		on bt_env_copy pressed  do
			(
				check_skin ()
				if ch==1 do 
					(
						skinOps.copySelectedBone selection[1].skin
						)
				)
		on bt_env_paste pressed  do
			(
				check_skin ()
				if ch==1 do 
					(
						if keyboard.controlpressed!=true then 
							(
								skinOps.pasteToSelectedBone selection[1].skin
								) else 
								(
									macros.run "Skin Modifier" "PasteToAllBones"
									)
						)
				)
				
		on ch_noenv changed state do
			(
				check_skin ()
				if ch==1 do 
					(
						selection[1].skin.showNoEnvelopes=state
						)
				)
				
		on bt_prev pressed  do
			(
				check_skin ()
				if ch==1 do 
					(
						skinOps.selectPreviousBone selection[1].skin
						)
				)
				
		on bt_next pressed  do
			(
				check_skin ()
				if ch==1 do 
					(
						skinOps.selectNextBone selection[1].skin
						)
				)
	
		on bt_0 pressed do
			(
				check_skin ()
				if ch==1 do 
					(
						val=0
						skinOps.setWeight selection[1].skin val
						spn_abs_effect.value=val
						)
				)
				
		on bt_01 pressed do
			(
				check_skin ()
				if ch==1 do 
					(
						val=0.1
						skinOps.setWeight selection[1].skin val
						spn_abs_effect.value=val
						)
				)
				
		on bt_025 pressed do
			(
				check_skin ()
				if ch==1 do 
					(
						val=0.25
						skinOps.setWeight selection[1].skin val
						spn_abs_effect.value=val
						)
				)
				
		on bt_05 pressed do
			(
				check_skin ()
				if ch==1 do 
					(
						val=0.5
						skinOps.setWeight selection[1].skin val
						spn_abs_effect.value=val
						)
				)
				
		on bt_075 pressed do
			(
				check_skin ()
				if ch==1 do 
					(
						val=0.75
						skinOps.setWeight selection[1].skin val
						spn_abs_effect.value=val
						)
				)
				
		on bt_09 pressed do
			(
				check_skin ()
				if ch==1 do 
					(
						val=0.9
						skinOps.setWeight selection[1].skin val
						spn_abs_effect.value=val
						)
				)
				
		on bt_1 pressed do
			(
				check_skin ()
				if ch==1 do 
					(
						val=1
						skinOps.setWeight selection[1].skin val
						spn_abs_effect.value=val
						)
				)
				
				
				
				
				
				
				
				
				
				
				
		on spn_abs_effect changed val do
			(
				check_skin ()
				if ch==1 do 
					(
						skinOps.setWeight selection[1].skin val
						)
				)
				
		on bt_weight_tool pressed  do
			(
				check_skin ()
				if ch==1 do 
					(
						skinOps.weightTool selection[1].skin
						)
				)
				
		on spn_limit changed val do
			(
				check_skin ()
				if ch==1 do 
					(
						selection[1].skin.bone_Limit=val
						)
				)
				
		on ch_always_deform changed val do
			(
				check_skin ()
				if ch==1 do 
					(
						selection[1].skin.always_deform=val
						)
				)
	)
	-- createdialog SkinEditor pos:[1500,136]
	
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	rollout SkinUtilits "Utilities" width:176 height:104
	(
		button bt_sel_skin_bones "Select skin bones" width:155 height:32 pos:[5,5]
		button bt_sel_affected_verts "Select affected vertices" width:155 height:32 pos:[160,5]
	-- ) createdialog SkinUtilits
	-- 	
		on bt_sel_skin_bones pressed do 
			(
				check_skin ()
				if ch==1 do 
					(
						max modify mode
						arr_sel=#()
						for i=1 to (skinOps.GetNumberBones selection[1].skin) do 
							(
								try 
									(
										execute ("appendifunique arr_sel $"+(skinOps.GetBoneName selection[1].skin i 0))
										) catch 
										(
											if querybox "objects with '(' or ')' in name can not be selected\ndo you want to rename all objects like this:\n'bone(mirrored) = bone_mirrored'" title:"error" ==true then 
												(
													for i in objects do 
														(
															for s=1 to i.name.count do 
																(
																	if i.name[s]=="(" do 
																		(
																			i.name=replace i.name s 1 "_"
																			)
																	if i.name[s]==")" do 
																		(
																			i.name=replace i.name s 1 ""
																			)
																	)
															)
													) else 
													(
														select selection[1]
														exit
														)
											) 
								)
						select arr_sel
						)
				)
				
		on bt_sel_affected_verts pressed do 
			(
				check_skin ()
				if ch==1 do 
					(
						try 
							(
								max modify mode
								local arr_sel=#()
								local bone_id=skinOps.GetSelectedBone selection[1].modifiers[#Skin]
								for i=1 to (getNumVerts selection[1]) do 
									(
										local vertex_bone_count = skinOps.GetVertexWeightCount selection[1].modifiers[#skin] i
										for b=1 to vertex_bone_count do 
											(
												if (skinops.GetVertexWeightBoneID selection[1].modifiers[#skin] i b)==bone_id do 
													(
														if (skinops.GetVertexWeight selection[1].modifiers[#skin] i b)!=0.0 do 
															(
																append arr_sel i
																)
														)
												)
										)
								skinOps.SelectVertices $.modifiers[#Skin] arr_sel
								format "% vertices selected\n" arr_sel.count
								) catch 
								(
									messagebox ("Error sk546 \n------------log:-----------\n"+(getCurrentException()))
									)
						)
				)
	)
	-- createdialog SkinUtilits
	
	
	
	
	global floater_skin_tools
	try(closeRolloutFloater floater_skin_tools)catch()
	floater_skin_tools=newRolloutFloater "Skin Tools[待完善]" 335 525 1490 136
	check_skin ()
	if ch==1 then 
	(
		addRollout skiner floater_skin_tools rolledUp:true
		addRollout SkinEditor floater_skin_tools rolledUp:false 
		addRollout SkinUtilits floater_skin_tools rolledUp:false
	) else 
	(
		addRollout skiner floater_skin_tools rolledUp:false
		addRollout SkinEditor floater_skin_tools rolledUp:false
		addRollout SkinUtilits floater_skin_tools rolledUp:false
	)
)