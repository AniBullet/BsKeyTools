-------------------------------------------------Anim meshes to bones----------------------------------------------
------------------------------------------------------------
--Tool for create one skinned mesh with animated bones from any animated meshes
--
--scripted by San_oOo 
--http://cargocollective.com/San_oOo
-------------------------------------------------------------
--updates:
-- v 1_7 bone size fixed to objects size
-- v 1_8 rewrite preview function to interactive
--         spn_maxlines renamed to spn_x
--         spn_liner renamed to spn_y
--         add checkbox and function of autostep elements in sides of box
--         script in progress...
-- v 1_9 new gui
-- v 2_0 create algoritm depends on preview meshes
-- v 2_1 manual check intersections
--          new gui
-- v 2_2 new gui
--          reset to default function 
-- v 2_3 new gui
--          delete spn_x and spn_y
--          delete auto_step button
--          preview now always cubic
--          delete unused variables
--          delete reset to default function 
--          preview position now centered.Thank you AnjiMo for this idea
-- v 2_4 in create function 'arr' was renamed to 'preview' becouse they are equal
--          in create function 'end_ar' was renamed to 'bone_arr'
--          saving hierarchy
-- v 2_5 skin_pose frame
-- v 2_5_1 added auto calculated distance to preview (while function)
--              added restore material function
-- v 2_6 added collision mover
-------------------------------------------------------------

(--variables
global tester
global preview=#() --created array for preview, then processed for new mesh
global selec=#() --original selected array
global anibon_step=0
global offset = 0
global offset2 = 0
global poser = #()
global liner=0
global maxline=0
global offset3=0
global anibon
global anibon_ver = "v 2_6"
global anibon_prev_color=color 141 200 123
global anibon_prev_color_intersect=color 193 62 62
global anibon_fin_color=color 255 162 0
global anibon_bone_color=color 114 116 153
global anibon_key_arr
global anibon_mesh_time=0f
global anibon_skinpose_time=-10f
global anibon_material=undefined
	
--functions	
	
fn fn_anibon_selkeys = 
(
anibon_key_arr=#()

struct adder
	(
		fn map t = 
			(
				append anibon_key_arr t
				return t
				)
		)

if selection.count!=0 do 
	(
		selectKeys selection
		for i in selection do 
			(
				mapKeys i (adder ()) #selection
				)
		sort anibon_key_arr
		
		if anibon_key_arr.count!=0 do
		(
			if anibon_key_arr[1]!=anibon_key_arr[anibon_key_arr.count] then 
				(
					return [anibon_key_arr[1],anibon_key_arr[anibon_key_arr.count]]
					) else 
					(
						return [anibon_key_arr[1], (anibon_key_arr[anibon_key_arr.count]+1)]
						)
			)
		)
	)
	
fn fn_back_to_original = 
	(
		for i=1 to preview.count do 
			(
				preview[i].transform=poser[i]
				)
		)
	
fn fn_check_create dialog = 
	(
		for i in preview do 
			(
				for s in preview do 
					(
						if s!=i do 
						(
							if (intersects i s)==true then 
								(
									i.wirecolor=anibon_prev_color_intersect
									s.wirecolor=anibon_prev_color_intersect
									exit
									) else 
									(
										i.wirecolor=anibon_prev_color
										)
							)
						)
				)
		local che=0
		for i in preview do   
			(
				if i. wirecolor==anibon_prev_color_intersect then 
					(
						che=0
						exit
						) else 
						(
							che=1
							)
				)
		if che==0 then 
			(
				dialog.bt_create.caption="模型有交错！"
				dialog.bt_create.enabled=false
				) else 
				(
					dialog.bt_create.caption="创建"
					dialog.bt_create.enabled=true
					)
		return che
		)
	
fn fn_step_calc dialog =
	(
		if selec!=undefined do 
			(
				try 
					(
						a=pow selec.count (1.0/3.0)
						anibon_step=(ceil a) as integer
						) catch ()
				)
		)
	
fn fn_create_copymeshes = 
	(
		if selection.count!=0 do 
			(
				selec=#()
				for i in selection where (superClassOf i == GeometryClass) do 
					(
						append selec i
						)
				anibon_material=selec[1].material
				preview=#()
				poser=#()
				for i in selec do 
					(
						append poser i.transform
						local prev_mesh= copy i
						prev_mesh.parent=undefined
						prev_mesh.wirecolor = anibon_prev_color
						prev_mesh.material = none
						setTransformLockFlags prev_mesh #{7,8,9}
						append preview prev_mesh
						)
				clearSelection ()
				hide selec
				)
		)
	
fn fn_move_copymeshes dialog = 
	(
		if preview!=#() do 
			(
				offset = 0
				offset2 = 0
				liner=0
				maxline=0
				offset3=0
				for i in preview do 
					(
						if liner==anibon_step do 
							(
								offset2+=dialog.spn_offset.value
								offset=0
								liner=0
								maxline+=1
								)
						if maxline==anibon_step do 
							(
								liner=0
								offset=0
								offset2=0
								offset3+=dialog.spn_offset.value
								maxline=0
								)
						local centro=(((anibon_step-1)*dialog.spn_offset.value)/2)
						if selec.count<=2 then 
							(
								i.pos = [0, offset-centro, offset3]
								) else 
								(
									i.pos = [offset2-centro, offset-centro, offset3]
									)
						offset+=dialog.spn_offset.value
						liner+=1
						)
				)
				

		)
		
fn fn_delete_copymeshes =
	(
		try 
			(
				if preview!=#() do 
					(
						for i in preview do 
							(
								if isValidObj i do 
									(
										delete i
										)
								)
						preview=#()
						unhide selec
						select selec
						)
				) catch ()
		)
		
fn fn_anibon_on dialog = 
	(
		dialog.txt_name.enabled=true
		dialog.spn_offset.enabled=true
		dialog.bt_check_intersect.enabled=true
		dialog.bt_back_to_original.enabled=true
		dialog.ch_delete_original.enabled=true
		dialog.ch_skin_original.enabled=true
-- 		dialog.bt_collision_mover.enabled=true
		
		if dialog.ch_skin_original. checked == true then 
			(
				dialog.bt_back_to_original.enabled=false
				dialog.bt_check_intersect.enabled=false
				dialog.spn_offset.enabled = false 
				dialog.ch_skin_frame.enabled = false 
				) else 
				(
					dialog.bt_back_to_original.enabled=true
					dialog.bt_check_intersect.enabled=true
					dialog.spn_offset.enabled = true 
					dialog.ch_skin_frame.enabled = true 
					)
		dialog.bt_create.enabled=true
		)
		
fn fn_anibon_off dialog = 
	(
		dialog.txt_name.enabled=false
		dialog.spn_offset.enabled=false
		dialog.bt_check_intersect.enabled=false
		dialog.bt_back_to_original.enabled=false
		dialog.ch_delete_original.enabled=false
		dialog.ch_skin_original.enabled=false
		dialog.bt_create.enabled=false
		dialog.ch_skin_frame.enabled=false
-- 		dialog.bt_collision_mover.enabled=false
		)
		
fn fn_collision_mover = 
	(
		while (fn_check_create anibon)==0 do 
			(
				for i in preview do 
					(
						for s in preview do 
							(
								if s!=i do 
								(
									while (intersects i s)==true do 
										(
											start=i
											end=s
											if end.pos==start.pos do 
												(
													end.pos+=0.001
													)
											vec=end.pos-start.pos
											bone_length=length vec

											while (intersects start end) do 
											(
												bone_length+=1.0
												vec=end.pos-start.pos
												vec_l=length vec
												
-- 												if end.name=="column_frag_Detached_024" or start.name=="column_frag_Detached_024" do 
-- 													(
-- 														print (start.name+"="+(start.pos as string))
-- 														print (end.name+"="+(end.pos as string))
-- 														print "------------"
-- 														)
												
												end.pos=vec*(bone_length/vec_l)+start.pos

												)

											)
									)
								)
						)
				)
		)
		
--rollout
	
try (destroyDialog anibon) catch ()
rollout anibon "模型一键加骨骼[破碎适用]" width:265 height:150
(
	checkbutton ckb_preview "先点击预览 Skin Pose" pos:[8,8] width:170 height:40 toolTip:"选择物体并点击此按钮"
	button bt_help "?" pos:[245,8] width:16 height:40 toolTip:"帮助"
	edittext txt_name "命名前缀:" pos:[8,55] width:150 height:16
	spinner spn_offset "距离:" pos:[180,55] width:80 height:16 range:[1,1e+006,0] type:#float
	button bt_check_intersect "检查穿插" pos:[178,8] width:67 height:20 toolTip:"移动物体位置后，请点击检查交错"
	button bt_back_to_original "原始位置" pos:[178,28] width:67 height:20 toolTip:"Reset pose (go to original pose)"
	
	GroupBox grp1 "" pos:[5,70] width:255 height:60
	checkbox ch_delete_original "删除原始物体" pos:[10,80] width:128 height:16
	checkbox ch_skin_original "Skin pose 像原始物体一样" pos:[10,96] width:152 height:16
	checkbox ch_skin_frame "创建 Skin pose" pos:[30,112] width:136 height:16
	button bt_create "创建" pos:[170,85] width:85 height:40
	label lblAuthor "Author:San_oOo" pos:[10,135] width:100 height:40
	label lblMod "Modified_by_Bullet.S" pos:[150,135] width:184 height:40
-- )createdialog anibon
	
	on anibon open do 
		(
			txt_name.text = "Fracture"
			spn_offset.value = 30
			ch_delete_original. checked=true
-- 			ch_skin_frame. checked=true
			
			fn_anibon_off anibon
			)
			
	on anibon close do 
		(
			if ckb_preview.checked==true do 
				(
					fn_delete_copymeshes ()
					)
			)
	
	on bt_help pressed  do 
		(
-- 			anibon.ckb_preview.changed (anibon.ckb_preview.checked = true)
			messagebox ("		Anim-meshes to bones "+anibon_ver+"
-------------------------------------------------------------------------------------------

用于从任何动画mesh创建带有Bone蒙皮mesh的工具，例如破碎的碎块


快速教程：

选择Mesh，单击预览，设置距离并点击“创建”


怎么运行的：

该工具将在物体的位置创建骨骼

并存储他的动画。然后将创建一个带蒙皮的网格

同时，创建骨骼添加进蒙皮。

为了正确蒙皮，工具需要重新定位网格。

您也可以手动重新放置对象，然后单击“检查穿插”

元素的边界框不应相交！

如果物体有交点-物体会将其颜色更改为红色。

增加“网格元素距离”以正确创建Skin。

如果预览不是交互式的，请重新加载脚本
				
scripted by San_oOo
http://cargocollective.com/San-oOo

Modified_by_Bullet.S
") title:"Help" beep:false
)

			
	on ckb_preview changed state do 
		(
			if state==true then 
				(
					if selection.count!=0 then 
						(
							try 
								(
									anibon_mesh_time=(((fn_anibon_selkeys ())[1]) as time)
									) catch 
									(
										anibon_mesh_time=animationRange.start
										)
							anibon_skinpose_time=anibon_mesh_time-15f
							fn_anibon_on anibon
							max create mode
							if anibon_mesh_time<animationRange.start do 
								(
									animationRange = interval (anibon_mesh_time) (animationRange.end)
									)
							sliderTime = animationRange.start
							deselectKeys selection
							enablesceneredraw()
							fn_create_copymeshes ()
							if ch_skin_original.checked==true do 
								(
									freeze preview
									)
							
							fn_step_calc anibon
							fn_move_copymeshes anibon
							if (fn_check_create anibon)==0 then 
								(
									while (fn_check_create anibon)==0 do 
										(
											spn_offset.value+=1
											fn_move_copymeshes anibon
											)
									) else 
									(
										if selec.count!=1 do 
											(
												while (fn_check_create anibon)==1 do 
													(
														spn_offset.value-=1
														fn_move_copymeshes anibon
														)
												spn_offset.value+=1
												fn_move_copymeshes anibon
												fn_check_create anibon	
												)
										)
							
							) else 
							(
								messagebox "请选择物体!        "
								ckb_preview.checked=false
								)
					) else 
					(
						if querybox "所有 transform 变换将会丢失，继续？" title:"Anim meshes to bones" == true then 
							(
								fn_delete_copymeshes ()
								fn_anibon_off anibon
								) else 
								(
									ckb_preview. checked=true
									)
						)
			)
			
	on spn_offset changed val do 
		(
			fn_move_copymeshes anibon
-- 			fn_check_create anibon
			fn_collision_mover ()
			redrawViews ()
			)
			
	on bt_back_to_original pressed do with undo on
		(
			fn_back_to_original ()
			fn_check_create anibon
			)
			
	on bt_check_intersect pressed do 
		(
-- 			fn_check_create anibon
			fn_collision_mover ()
			)
			
	on ch_skin_original changed che do 
		(
			if che==true then 
				(
					
					bt_back_to_original.enabled=false
					bt_check_intersect.enabled=false
					spn_offset.enabled = false 
					ch_skin_frame.enabled = false 
					freeze preview
					) else 
					(
						unfreeze preview
						bt_back_to_original.enabled=true
						bt_check_intersect.enabled=true
						spn_offset.enabled = true 
						ch_skin_frame.enabled = true
						)
			)
			
	on bt_create pressed  do with undo on
		(
			fn_collision_mover ()
			if (fn_check_create anibon)==0 then 
				(
					messagebox "模型有交错!\n点击“检查穿插”, 如果你手动移动过物体"
					) else 
					(
						if (querybox "这个操作无法回退，建议先另存！！！继续？          " title:"Anim meshes to bones") ==true do 
							(
								try 
									(
										---------reset script
										ckb_preview.checked=false
										fn_anibon_off anibon
										
										--------prepare scene
										max modify mode
										if anibon_mesh_time<animationRange.start do 
											(
												animationRange = interval (anibon_mesh_time) (animationRange.end)
												)
										sliderTime = animationRange.start
										
										--------create fracture mesh (fr)
										local fr=box lengthsegs:1 widthsegs:1 heightsegs:1 mapcoords:on realWorldMapSize:off
										fr.name=uniquename (txt_name.text+"_mesh")
										convertToPoly fr
										fr.EditablePoly.SetSelection #Face #{1..6}
										fr.EditablePoly.delete #Face
										fr. wirecolor=anibon_fin_color
											
										--------create bones
										local bone_arr=#()
										for i in 1 to preview.count do
											(
												clearSelection()
												select preview[i]
												parentBone  = selection[1]
												parentTrans = parentBone.transform
												parentPos   = parentTrans.translation

												in coordsys (matrix3 [1,0,0] [0,1,0] [0,0,1] parentBone.pos) 
												(
													newBone_length=(length (parentBone.maximum-parentBone.minimum))*0.3
													newBone_width=(length (parentBone.maximum-parentBone.minimum))*0.3
													)

												newBone=BoneSys.createBone parentPos (parentPos+newBone_length) parentBone.dir

												newBone.name=uniquename (txt_name.text +"_bone_")
												newBone.wirecolor=anibon_bone_color
												newBone.transform = parentTrans
												newBone.taper = 90
												
												newBone.width=newBone_width
												newBone.height=newBone.width
												newBone.frontfin = off
												newBone.backfin = off
												newBone.sidefins = off
												
												newBone.boneEnable=false
												newBone.parent = preview[i].parent
												newBone.pos.controller = copy preview[i].pos.controller
												newBone.rotation.controller = copy preview[i].rotation.controller
												newBone.scale.controller = copy preview[i].scale.controller
												
												------create copy of element and skining to created bone
												fr.EditablePoly.attach (copy preview[i]) fr
												addModifier preview[i] (skin())
												skinOps.addBone preview[i].modifiers[#Skin] newBone 0
												append bone_arr newBone
												)
												
										---------Create skin_wrap with all elements
										select fr
										addModifier fr (Skin_Wrap())
										for i in 1 to preview.count do
											(
												append fr.modifiers[#Skin_Wrap].meshList preview[i]
												)
										fr.modifiers[#Skin_Wrap].engine = 0
										fr.modifiers[#Skin_Wrap].weightAllVerts = on
										-----------Skin_wrap converts to skin
										fr.modifiers[#Skin_Wrap].meshDeformOps.convertToSkin off
										fr.modifiers[1].always_deform=false
										fr.modifiers[1].always_deform=true
										deleteModifier fr 2
										---------restore material
										fr.material=anibon_material
										
										--------save new poses for skin pose
										local poser_skin=#()
										for i in bone_arr do 
											(
												append poser_skin i.transform
												)
										
										--------restore original pose
										for i=1 to bone_arr.count do 
											(
												bone_arr[i].transform=poser[i]
												)
										delete preview
										
										---------restore original hierarchy
										for i=1 to bone_arr.count do 
											(
												if selec[i].parent!=undefined do 
													(
														local parent_id=finditem selec selec[i].parent
														if parent_id!=0 then 
															(
																bone_arr[i].parent=bone_arr[parent_id]
																) else 
																(
																	bone_arr[i].parent=selec[i].parent
																	)
														)
												)
												
												
										---------restore skin pose (if checked)
										if ch_skin_original.checked != true do 
											(
												if ch_skin_frame.checked == true do 
													(
														with animate on 
															(
																animationRange = interval (anibon_skinpose_time) (animationRange.end)
																for i=1 to bone_arr.count do 
																	(
																		addNewKey bone_arr[i] (anibon_skinpose_time+5f)
																		)
																sliderTime = anibon_skinpose_time
																for i=1 to bone_arr.count do 
																	(
																		bone_arr[i].transform=poser_skin[i]
																		)
																animationRange = interval (anibon_mesh_time) (animationRange.end)
																)
														fr.modifiers[#Skin].ref_frame = anibon_skinpose_time
														messagebox ("Skin pose 保存在第 "+(((anibon_skinpose_time as integer)/TicksPerFrame) as string)+" 帧") beep: false
														)
												)
												
										-----------check delete original objects (if checked)
										if ch_delete_original.checked ==true do 
											(
												delete selec
												)
												
										----------skin like original mesh (if checked)
										if ch_skin_original.checked ==true do 
											(
												fr_targ=copy fr
												convertToPoly fr_targ
												addModifier fr (morpher()) before:2
												WM3_MC_BuildFromNode fr.morpher 1 fr_targ
												WM3_MC_SetValue fr.morpher 1 100.0
												maxOps.CollapseNodeTo fr 2 off
												delete fr_targ
												fr.modifiers[1].always_deform=false
												fr.modifiers[1].always_deform=true
												)
										) catch 
										(
											messagebox ("Error \n------------log:-----------\n"+(getCurrentException()))
											)
								)
						)
			)

)
createdialog anibon

)