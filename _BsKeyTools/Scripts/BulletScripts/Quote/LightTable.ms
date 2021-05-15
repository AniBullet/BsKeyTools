-----------------------LightTable-------------------
-- v 0_0 main functionality
-- v 0_1 script and variables renamed to LightTable
--		  combined create onions code in to one function
--          ckb now delets onions
--          symmetr
-- v 0_2 loop and clip mode main code
-- v 0_3 [loop and clip mode] - auto update 'mode' when dialog change mode state
--			delete onions when open dialog again
-- v 0_4 INI_base
-- v 0_5 INI save array
--          help
-- v 0_6 pressets fixed
--          unskinned objects messagebox fixed
--          copy to after and before fixed duplicated ghosts
-- v 0_7 layermanager
-- v 0_8 2nd open dialog now do not resets array of objects, onions_array_obj at begin not #() (beta)
--          save appdata when scene saved
-- v 0_9 filePreOpenProcess filePostOpenProcess callbacks added
-- v 1_0 fix bug when first opening script and onions_array_obj is undefined
-- v 1_1 beta
-- v 1_2 issue with standard transforms solved. Now all objects supported, without skinning
--		added mirror presset
-- v 1_3 materials on onionskins
--          fn_clean_array to clear onion_obj_arr for deleted nodes
--          deselect when create ghosts issue fixed
-- v 1_4 save ch_alpha in ini
--          fixed issue with load array and converting AppData
--          known issue - undo may crash 3ds max
-- v 1_5 issue with undo crashes 3ds max - i thnik fixed... probably =\ 'do with undo off animate off' added everywhere
-- v 1_6 issue with undo crashes 3ds max - found new bug when autosave - tested again and again
--          issue - 2013 max working right. But early versions have bugs.
--          rewrite fn_onions_create,  fn_onions_val,  fn_onions_all_val - ghosts now using only materials without visibility changing
--          added ch_shaded
--          added before, after checks for fast enable\disable corresponding onions
--          auto ui colors dependend on 3dsmax ui colors
--          user icons on ch_shaded, ch_alpha
-- v 1_7 hide on play option
-- v 1_8 hide on play option now can't change by user
-- v 1_9 changes in fn_load_ini - loading array now not depended on ini (if ini not exist array will loading correctly also)
-- v 2_0 now only material opacity uses
--          xform problem solved!!!! used mesh.objecttransform instead mesh.transform only ^_^
--          ctrl+click 'light selected' to add to existing array
--          group support
--          now you can delete objects with enabled ghosts without errors. Objects ghosts will be hidden
--          intro screen (opened when first installed)
--          version checking and saving in ini
--          fixed issue with pf_source offset
--          text in the help menu corrected and "show splash screen" button was added
-- v 2_1 trying to add keyframe ghosts
-- v 2_2 keyframe ghosts - selection.count=0 not hiding
--		  todo: pressets
-- v 2_3 delete LT data button in help menu
-- v 2_3_1 删除重影移至面板外面，新增渲染可见勾选项
(
global SanLightTable
global SanLightTable_version="2_3_1"
global SanLightTable_help
try 
	(
		for i=1 to 20 do
			(
				local expr_arr="onions_arr_"+(i as string)
				local arr=(execute expr_arr)
				delete arr
				(execute (expr_arr+"=#()"))
				)
		) catch ()
		
global SanLightTable_layer_name="0 (LightTable_ghosts)"
global SanLightTable_layer=LayerManager.getLayerFromName SanLightTable_layer_name
global SanLightTable_layer_0=LayerManager.getLayer 0
global SanLightTable_dialog_pos=[mouse.screenpos[1],mouse.screenpos[2]]
global SanLightTable_ini = getDir #plugcfg + "\LightTable_san_tools.ini"
global SanLightTable_id_obj=-69125528456851322651
global onion_obj_arr--=#()
global temp_onions_arr=#()
global onions_arr_1=#()
global onions_arr_2=#()
global onions_arr_3=#()
global onions_arr_4=#()
global onions_arr_5=#()
global onions_arr_6=#()
global onions_arr_7=#()
global onions_arr_8=#()
global onions_arr_9=#()
global onions_arr_10=#()
global onions_arr_11=#()
global onions_arr_12=#()
global onions_arr_13=#()
global onions_arr_14=#()
global onions_arr_15=#()
global onions_arr_16=#()
global onions_arr_17=#()
global onions_arr_18=#()
global onions_arr_19=#()
global onions_arr_20=#()
global SanLightTable_tbar = maxops.trackbar
------------------------------------------------------
global expr_scal_before="
with undo off (
try (
	timer=oni_time
	if (frame_mode!=1) do 
	(
		target_time=slidertime
		if (frame_mode==2) do
		(
			target_time=(at time target_time SanLightTable_tbar.getnextkeytime())
			target_time=(at time target_time SanLightTable_tbar.getpreviouskeytime())
			)
		for i=1 to abs(oni_time) do 
		(
			target_time=(at time target_time SanLightTable_tbar.getpreviouskeytime())
			)
		if light_mode!=1 and target_time>F do 
		(
			target_time=animationRange.start-1
			)
		)
	
	if light_mode!=1 then 
	(
		frame_mode_ch=0
		if (frame_mode!=1) then 
		(
			unhide oni
			if (target_time<animationRange.start) then 
			(
				if light_mode==2 then 
				(
					target_time=(animationRange.end+1)
					for i=1 to abs(oni_time) do 
					(
						target_time=(at time target_time SanLightTable_tbar.getpreviouskeytime())
						)
					if target_time==animationRange.end do 
					(
						target_time=(at time target_time SanLightTable_tbar.getpreviouskeytime())
						)
					) else 
					(
						hide oni
						)
				)
			if selection.count!=0 then 
			(
				oni.time=currenttime-target_time
				) else 
				(
					frame_mode_ch=1
					)
			) else 
			(
				frame_mode_ch=1
				)
		if frame_mode_ch==1 do 
		(
			if (sliderTime-oni_time)<animationRange.start then 
			(
				if light_mode==2 then 
				(
					timer=-((animationRange.end-animationRange.start)-oni_time)
					oni.time=timer
					) else 
					(
						oni.time=oni_time
						timer=oni_time
						hide oni
						)
				) else 
				(
					if light_mode==2 then 
					(
						oni.time=oni_time
						timer=oni_time
						) else 
						(
							oni.time=oni_time
							timer=oni_time
							unhide oni
							)
					)
			)
		) else 
		(
			if (frame_mode==1) then 
			(
				timer=oni_time
				oni.time=oni_time
				) else 
				(
					unhide oni
					if selection.count!=0 then
					(
						oni.time=currenttime-target_time
						) else 
						(
							oni.time=oni_time
							)
					)
			)
		if hide_on_play==true do 
		(
			if isAnimPlaying()==true then
			(
				hide oni
				) else 
				(
					if light_mode!=3 do 
					(
						if (frame_mode==1) do 
						(
							unhide oni
							)
						)
					)
			)
	xxx
	) catch 
		(
			hide oni
			matrix3 1
			)
)
"
---------------------------------------
global expr_scal_after="
with undo off (
try (
	timer=oni_time
	if (frame_mode!=1) do 
	(
		target_time=slidertime
		for i=1 to abs(oni_time) do 
		(
			target_time=(at time target_time SanLightTable_tbar.getnextkeytime())
			)
		if target_time<currenttime do 
		if light_mode!=1 and target_time<F do 
		(
			target_time=animationRange.end+1
			)
		)
	if light_mode!=1 then --light mode loop or clip
	(
		if (frame_mode!=1) then --keyframes
		(
			unhide oni
			if (target_time>animationRange.end) then --target_time > range
			(
				if light_mode==2 then --loop
				(
					target_time=(animationRange.start-1)
					for i=1 to abs(oni_time) do 
					(
						target_time=(at time target_time SanLightTable_tbar.getnextkeytime())
						)
					if target_time==animationRange.start do 
					(
						target_time=(at time target_time SanLightTable_tbar.getnextkeytime())
						)
					) else -- clip
					(
						hide oni
						)
				)
			if selection.count!=0 then 
			(
				oni.time=currenttime-target_time
				) else 
				(
					frame_mode_ch=1
					)
			) else 
			(
				frame_mode_ch=1
				)
		if frame_mode_ch==1 do --frames mode
		(
			if (sliderTime-oni_time)>animationRange.end then -- target_time > range
			(
				if light_mode==2 then --loop
				(
					timer=((animationRange.end-animationRange.start)+oni_time)
					oni.time=timer
					) else -- clip
					(
						oni.time=oni_time
						timer=oni_time
						hide oni
						)
				) else -- target_time in range
				(
					if light_mode==2 then --loop
					(
						oni.time=oni_time
						timer=oni_time
						) else -- clip
						(
							oni.time=oni_time
							timer=oni_time
							unhide oni
							)
					)
			)
		) else --normal
		(
			if (frame_mode==1) then --frames
			(
				timer=oni_time
				oni.time=oni_time
				) else --keyframes
				(
					unhide oni
					if selection.count!=0 then --find keyframes
					(
						oni.time=currenttime-target_time
						) else 
						(
							oni.time=oni_time
							)
					)
			)
		if hide_on_play==true do
		(
			if isAnimPlaying()==true then --playback on
			(
				hide oni
				) else --playback off
				(
					if light_mode!=3 do 
					(
						if (frame_mode==1) do 
						(
							unhide oni
							)
						)
					)
			)
	xxx
	) catch 
		(
			hide oni
			matrix3 1
			)
)
"
local max_background_col=255*(colorMan.getColor #background)[1]

global pb_col=(color 94 124 162)
global pb_col1=(color 82 75 111)
local pb_col1_coef=2.6
if max_background_col<100.0 do 
	(
		pb_col1_coef=1.7
		)
global pb_col1=(color (max_background_col/pb_col1_coef+10) (max_background_col/pb_col1_coef) (max_background_col/pb_col1_coef+40))
local ch_colors_coef=20
global ch_colors=(color (max_background_col+ch_colors_coef) (max_background_col+ch_colors_coef) (max_background_col+ch_colors_coef))

global check_post_save=0
global check_post_open=0
global SanLightTable_presave_message="
if SanLightTable.ch_onion_enable.checked==true and SanLightTable.open==true do with undo off animate off
(
SanLightTable.ch_onion_enable.changed false
check_post_save=1
		if onion_obj_arr.count!=0 then  
			(
				try 
					(
						local str=\"\"
						for i=1 to onion_obj_arr.count do 
							(
								if i!=onion_obj_arr.count  then 
									(
										str+=(onion_obj_arr[i].name)+\"@!@\"
										) else 
										(
											str+=(onion_obj_arr[i].name)
											)
								)
						setAppData rootnode SanLightTable_id_obj str
						) catch 
						(
							setAppData rootnode SanLightTable_id_obj \"\"
							)
				) else 
				(
					setAppData rootnode SanLightTable_id_obj \"\"
					)
)
"

global SanLightTable_postsave_message="
if check_post_save==1 and SanLightTable.open==true do with undo off animate off
(
	undo off 
		(
			SanLightTable.ch_onion_enable.changed true
			check_post_save=0
			)
	)
"

global SanLightTable_reloader_message="
check_post_open=1
undo off 
	(
		try(destroyDialog SanLightTable) catch ()
		)
"

global SanLightTable_reloader_message_1="
--try(destroyDialog SanLightTable) catch ()
createdialog SanLightTable style: #(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox) pos:SanLightTable_dialog_pos
check_post_open=0
"

fn fn_clean_array = 
	(
		----------clear onion_obj_arr for deleted nodes
		local temp_onion_obj_arr=onion_obj_arr
		onion_obj_arr=#()
		if temp_onion_obj_arr!= undefined do 
			(
				for t in temp_onion_obj_arr do 
					(
						if isValidObj t == true do 
							(
								appendifunique onion_obj_arr t
								)
						)
				)
		)

fn fn_SanLightTable_dialog_pos named_ini = 
	(
		try 
			(
				local dialog_pos=filterstring (getIniSetting named_ini "main_settings" "dialog_pos") "@@"
				SanLightTable_dialog_pos=[(dialog_pos[1] as float),(dialog_pos[2] as float)]
				) catch ()
		)

		
fn fn_onions_create oni_numb= 
	(
		local arrGhostLight = $'ghost_*'
		for o in arrGhostLight do
		(
			o.renderable = SanLightTable.ckbRenderGhost.state
		)
		if SanLightTable.open==true and SanLightTable.ch_onion_enable.checked==true do 
			(
				if (oni_numb>0 and oni_numb<11 and SanLightTable.ch_before.checked==true) or (oni_numb>=11 and oni_numb<=20 and SanLightTable.ch_after.checked==true) do 
					(
						try 
							(
								LayerManager.newLayerFromName SanLightTable_layer_name
								SanLightTable_layer=LayerManager.getLayerFromName SanLightTable_layer_name
								SanLightTable_layer.lock=(not SanLightTable.ckbUnFreeze.state)
								
-- 								SanLightTable_layer.display=4
-- 								SanLightTable_layer.showFrozenInGray=false
								
								local expr_arr="onions_arr_"+(oni_numb as string)
								local expr_val="SanLightTable.pb"+(oni_numb as string)+".value/100.0*SanLightTable.pb_all.value/100.0"
								local arr=(execute expr_arr)
								
								for i in onion_obj_arr do with undo off animate off
									(
										if isValidObj i do 
											(
												local oni = Mesher radius:2 pos:i.transform.pos renderTimeOnly:off --isSelected:off
												oni.pick = i
												oni.backfacecull=true
												oni.renderable=SanLightTable.ckbRenderGhost.state
												oni.showFrozenInGray = false
-- 												oni.visibility = bezier_float()
-- 												oni.visibility.controller.value = execute (expr_val)
-- 						
-- 												oni.displayByLayer=true
												--materials
												oni.material=standard ()
												local m=oni.material
												m.opacity=(execute (expr_val))*100
-- 												if SanLightTable.ch_shaded.checked==true or SanLightTable.ch_alpha.checked==true do 
-- 													(
-- 														local m=oni.material
-- 														m.name=i.material.name+"_Light_table"
-- 														)
												
												if SanLightTable.ch_shaded.checked==true do 
													(
														m.useSelfIllumColor = on
														m.Diffuse = color 0 0 0
														)
														
												if SanLightTable.ch_alpha.checked==true do 
													(
														if i.material!=undefined and (iskindof i.material standard)==true and i.material.opacityMap!=undefined and i.material.opacityMapEnable!=off do  
															(
																m.opacityMap=i.material.opacityMap
																m.opacity=0
																m.opacityMapAmount=(execute (expr_val))*100
																showTextureMap m on
																)
														)
												
												local expr_scal
												
												if oni_numb<=10 then 
													(
														oni.time=oni_numb
														oni.name="ghost_"+i.name+"_t_"+(oni_numb as string)
														oni.wirecolor=SanLightTable.cp_before.color
														if SanLightTable.ch_shaded.checked==true then 
															(
																m.selfIllumColor = SanLightTable.cp_before.color
																) else 
																(
																	m.Diffuse=SanLightTable.cp_before.color
																	)
														expr_scal=expr_scal_before
														) else 
														(
															oni.time=-oni_numb+10
															oni.name="ghost_"+i.name+"_t_"+((-oni_numb+10) as string)
															oni.wirecolor=SanLightTable.cp_after.color
															if SanLightTable.ch_shaded.checked==true then 
																(
																	m.selfIllumColor = SanLightTable.cp_after.color
																	) else 
																	(
																		m.Diffuse=SanLightTable.cp_after.color
																		)
															expr_scal=expr_scal_after
															)
												if (iskindof i PF_Source)==true then 
												(
													local s="matrix3 1"
													expr_scal=substituteString expr_scal "xxx" s
													) else 
													(
														local s="	if (frame_mode==1) then 
		(
			at time (F-timer) target_mesh.objecttransform
			) else 
			(
				at time (target_time) target_mesh.objecttransform
				)"
														expr_scal=substituteString expr_scal "xxx" s
														)
															
												script_transform=oni.Transform.controller=transform_script ()
												script_transform.AddConstant "light_mode" SanLightTable.rdo_mode.state
												script_transform.AddConstant "frame_mode" SanLightTable.rdo_mode_frame.state
												script_transform.AddConstant "hide_on_play" SanLightTable.ch_hide_on_play.checked
												script_transform.AddConstant "oni_time" oni.time
												script_transform.AddNode "oni" oni
												script_transform.AddNode "target_mesh" i
												script_transform.script=expr_scal
															
												appendifunique arr oni
												SanLightTable_layer.addnode oni
												)
										)
								) catch 
								(
									messagebox ("fn_onions_create Error s51f5 \n------------log:-----------\n"+(getCurrentException()))
									)
						)
				)
		)

fn fn_onions_hide numb che= 
	(
		local numb_s
		local ckb=(execute ("SanLightTable.ckb"+(numb as string)))
		local ckb_s
		local expr_arr=("onions_arr_"+(numb as string))
		local expr_arr_s
		local arr=(execute expr_arr)
		if SanLightTable.bt_sym.checked==true do
			(
				if numb <10 do 
					(
						ckb_s=(execute ("SanLightTable.ckb1"+(numb as string)))
						expr_arr_s=("onions_arr_1"+(numb as string))
						numb_s=numb+10
						)
				if numb == 10 do 
					(
						ckb_s=(execute ("SanLightTable.ckb20"))
						expr_arr_s=("onions_arr_20")
						numb_s=20
						)
				if numb >10 do 
					(
						ckb_s=(execute ("SanLightTable.ckb"+((numb-10) as string)))
						expr_arr_s=("onions_arr_"+((numb-10) as string))
						numb_s=(numb-10)
						)
				arr_s=(execute expr_arr_s)
				)
				
		try with undo off animate off
			(
				if che==true then 
					(
						fn_onions_create numb
						if SanLightTable.bt_sym.checked==true do 
							(
								fn_onions_create numb_s
								ckb_s.checked=true
								)
						) else 
						(
							delete arr
							execute (expr_arr+"=#()")
							if SanLightTable.bt_sym.checked==true do 
								(
									delete arr_s
									execute (expr_arr_s+"=#()")
									ckb_s.checked=false
									)
							)
				) catch (messagebox ("Error 6545df \n------------log:-----------\n"+(getCurrentException())))
		)

fn fn_onions_val numb val val_all= 
	(
		local pb=(execute ("SanLightTable.pb"+(numb as string)))
		local pb_s
-- 		local ckb=(execute ("SanLightTable.ckb"+(numb as string)+".checked"))
		local arr=(execute ("onions_arr_"+(numb as string)))
		local arr_s
			
		pb.value=val
		if SanLightTable.bt_sym.checked==true do with undo off animate off
			(
				if numb <10 do 
					(
						pb_s=(execute ("SanLightTable.pb1"+(numb as string)))
						arr_s=(execute ("onions_arr_1"+(numb as string)))
						)
				if numb == 10 do 
					(
						pb_s=(execute ("SanLightTable.pb20"))
						arr_s=(execute ("onions_arr_20"))
						)
				if numb >10 do 
					(
						pb_s=(execute ("SanLightTable.pb"+((numb-10) as string)))
						arr_s=(execute ("onions_arr_"+((numb-10) as string)))
						)
				pb_s.value=val
				)

		try 
			(
				for i=1 to arr.count do with undo off animate off
					(
						local a=val/100.0*val_all/100
						
						if arr[i].material.opacityMap!=undefined then 
							(
								arr[i].material.opacityMapAmount=a*100
								) else 
								(
									arr[i].material.opacity=a*100
									)
								
						if SanLightTable.bt_sym.checked==true do 
							(
								try 
									(
										if arr[i].material.opacityMap!=undefined then  
											(
												arr_s[i].material.opacityMapAmount=a*100
												) else 
												(
													arr_s[i].material.opacity=a*100
													)
										) catch ()
								)
						)
				sliderTime=currenttime
				) catch 
					(
						messagebox ("Error \n------------log:-----------\n"+(getCurrentException()))
						)
		)
		
fn fn_onions_all_val val =
	(
		try 
			(
				for i=1 to 20 do with undo off animate off
					(
						local expr="onions_arr_"+(i as string)
						local expr_val="SanLightTable.pb"+(i as string)+".value"
						local pb_val=execute expr_val
						local arr=(execute expr)
						for s in arr do 
							(
								local a=pb_val/100.0*val/100.0
								
								if s.material.opacityMap!=undefined then 
									(
										s.material.opacityMapAmount=a*100
										) else 
										(
											s.material.opacity=a*100
											)
								)
						)
				sliderTime=currenttime
				) catch ()
				
		)
		
fn fn_load_lt_ini dialog named_ini = 
	(
		if doesFileExist (named_ini) == false then 
		(
			setIniSetting named_ini "main_settings" "version" SanLightTable_version
			setIniSetting named_ini "main_settings" "before_col" "101@203@228"
			setIniSetting named_ini "main_settings" "after_col" "255@144@101"
			setIniSetting named_ini "main_settings" "symmetry" "true"
			setIniSetting named_ini "main_settings" "mode" "1"
			setIniSetting named_ini "main_settings" "mode_frame" "1"
			setIniSetting named_ini "main_settings" "ch_before" "true"
			setIniSetting named_ini "main_settings" "ch_after" "true"
			setIniSetting named_ini "main_settings" "ch_shaded" "false"
			setIniSetting named_ini "main_settings" "ch_alpha" "false"
			setIniSetting named_ini "main_settings" "ch_hide_on_play" "true"

				if (getIniSetting named_ini "main_settings" "ch_before")=="false" then 
					(
						dialog.ch_before.checked=false
						) else 
						(
							dialog.ch_before.checked=true
							)
				if (getIniSetting named_ini "main_settings" "ch_after")=="false" then 
					(
						dialog.ch_after.checked=false
						) else 
						(
							dialog.ch_after.checked=true
							)
				if (getIniSetting named_ini "main_settings" "symmetry")=="false" then 
					(
						dialog.bt_sym.checked=false
						) else 
						(
							dialog.bt_sym.checked=true
							)
				if (getIniSetting named_ini "main_settings" "ch_hide_on_play")=="false" then 
					(
						dialog.ch_hide_on_play.checked=false
						) else 
						(
							dialog.ch_hide_on_play.checked=true
							)
				if (getIniSetting named_ini "main_settings" "ch_shaded")=="true" then 
					(
						dialog.ch_shaded.checked=true
						) else 
						(
							dialog.ch_shaded.checked=false
							)
				if (getIniSetting named_ini "main_settings" "ch_alpha")=="true" then 
					(
						dialog.ch_alpha.checked=true
						) else 
						(
							dialog.ch_alpha.checked=false
							)
				if (hasINISetting named_ini "main_settings" "mode_frame")==true then 
					(
						dialog.rdo_mode_frame.state=(getIniSetting named_ini "main_settings" "mode_frame") as integer
						) else 
						(
							setIniSetting named_ini "main_settings" "mode_frame" "1"
							dialog.rdo_mode_frame.state=(getIniSetting named_ini "main_settings" "mode_frame") as integer
							)
				dialog.rdo_mode.state=(getIniSetting named_ini "main_settings" "mode") as integer
				local temp_col_arr=filterstring (getIniSetting named_ini "main_settings" "before_col") "@"
				dialog.cp_before.color=color (temp_col_arr[1] as float) (temp_col_arr[2] as float) (temp_col_arr[3] as float)
				local temp_col_arr=filterstring (getIniSetting named_ini "main_settings" "after_col") "@"
				dialog.cp_after.color=color (temp_col_arr[1] as float) (temp_col_arr[2] as float) (temp_col_arr[3] as float)
							
				for i=1 to 20 do 
					(
						if (getIniSetting named_ini "onions" ("ckb_"+(i as string)))=="true" then 
							(
								(execute ("SanLightTable.ckb"+(i as string)+".checked=true"))
								) else 
								(
									(execute ("SanLightTable.ckb"+(i as string)+".checked=false"))
									)
						local pb=execute ("SanLightTable.pb"+(i as string))
						pb.value=((getIniSetting named_ini "onions_val" ("pb"+(i as string))) as integer)
						)
				dialog.pb_all.value=(getIniSetting named_ini "onions_val" "pb_all") as integer
				)
-- 		clearListener ()
-- 		print "remembered:-----------"
-- 		print onion_obj_arr
-- 		print "\n"
		if onion_obj_arr==undefined do 
			(
				onion_obj_arr=#()
-- 				print "remembered_undefined_fixed:-----------"
-- 				print onion_obj_arr
-- 				print "\n"
				)
				
				
		------------load nodes from scene
		local obj_str=getAppData rootnode SanLightTable_id_obj
				
-- 		print "AppData:-------------------"
-- 		print obj_str
-- 		print "\n"
				
		if obj_str!=undefined and obj_str!="" do 
			(
				local obj_arr=filterstring obj_str "@!@"
				for i in obj_arr do 
					(
						try 
							(
								appendifunique onion_obj_arr (execute ("$"+i))
								) catch 
									(
-- 										messagebox ("Error converting array \n------------log:-----------\n"+(getCurrentException()))
										)
						)
				)
-- 		print "ConvertedData with $:-------------------"
-- 		print onion_obj_arr
-- 		print "\n"

		----------clear onion_obj_arr for deleted nodes
-- 		local temp_onion_obj_arr=onion_obj_arr
-- 		onion_obj_arr=#()
-- 		if temp_onion_obj_arr!= undefined do 
-- 			(
-- 				for t in temp_onion_obj_arr do 
-- 					(
-- 						if isValidObj t == true do 
-- 							(
-- 								appendifunique onion_obj_arr t
-- 								)
-- 						)
-- 				)
				
		fn_clean_array ()
				
-- 		print "Final array:-------------------"
-- 		print onion_obj_arr
-- 		print "-------------------"
				
		if onion_obj_arr.count!=0 do 
			(
				for oni_numb=1 to 20 do 
					(
						local expr_hide="SanLightTable.ckb"+(oni_numb as string)+".checked"
						if (execute expr_hide)!=false do 
							(
								fn_onions_create oni_numb
								)
						)
				redrawViews()
				)
		)

fn fn_save_lt_ini dialog named_ini = 
	(
		setIniSetting named_ini "main_settings" "version" SanLightTable_version
		setIniSetting named_ini "main_settings" "before_col" ((dialog.cp_before.color.r as string)+"@"+(dialog.cp_before.color.g as string)+"@"+(dialog.cp_before.color.b as string))
		setIniSetting named_ini "main_settings" "after_col" ((dialog.cp_after.color.r as string)+"@"+(dialog.cp_after.color.g as string)+"@"+(dialog.cp_after.color.b as string))
		setIniSetting named_ini "main_settings" "ch_before" (dialog.ch_before.checked as string)
		setIniSetting named_ini "main_settings" "ch_after" (dialog.ch_after.checked as string)
		setIniSetting named_ini "main_settings" "symmetry" (dialog.bt_sym.checked as string)
		setIniSetting named_ini "main_settings" "mode" (dialog.rdo_mode.state as string)
		setIniSetting named_ini "main_settings" "mode_frame" (dialog.rdo_mode_frame.state as string)
		setIniSetting named_ini "main_settings" "enabled" (dialog.ch_onion_enable.checked as string)
-- 		setIniSetting named_ini "main_settings" "ch_hide_on_play" (dialog.ch_hide_on_play.checked as string)
		setIniSetting named_ini "main_settings" "ch_shaded" (dialog.ch_shaded.checked as string)
		setIniSetting named_ini "main_settings" "ch_alpha" (dialog.ch_alpha.checked as string)
		local dialog_pos=(GetDialogPos SanLightTable)
		setIniSetting named_ini "main_settings" "dialog_pos" ((dialog_pos[1] as string)+"@@"+(dialog_pos[2] as string))
		
		for i=1 to 20 do 
			(
				setIniSetting named_ini "onions" ("ckb_"+(i as string)) ((execute ("SanLightTable.ckb"+(i as string)+".checked")) as string)
				setIniSetting named_ini "onions_val" ("pb"+(i as string)) ((execute ("SanLightTable.pb"+(i as string)+".value")) as string)
				)
				
		setIniSetting named_ini "onions_val" "pb_all" (SanLightTable.pb_all.value as string)
				
		undo off 
			(
				if onion_obj_arr!=undefined and onion_obj_arr.count!=0 then 
					(
						try 
							(
								local str=""
								for i=1 to onion_obj_arr.count do 
									(
										if i!=onion_obj_arr.count  then 
											(
												str+=(onion_obj_arr[i].name)+"@!@"
												) else 
												(
													str+=(onion_obj_arr[i].name)
													)
										)
								setAppData rootnode SanLightTable_id_obj str
								) catch 
								(
									setAppData rootnode SanLightTable_id_obj ""
									)
						) else 
						(
							setAppData rootnode SanLightTable_id_obj ""
							)
				)
		)
		
fn fn_lt_quick_clear_arr =
	(
		--delete all onions
		undo off 
			(
				try 
					(
						for i=1 to 20 do 
							(
								local expr_arr="onions_arr_"+(i as string)
								local arr=(execute expr_arr)
								delete arr
								(execute (expr_arr+"=#()"))
								)
						) catch ()
				)
		)
		
fn fn_recreate_onions_with_new_parametres = 
	(
		if SanLightTable.ch_onion_enable.checked==true do 
			(
				fn_lt_quick_clear_arr ()
				fn_clean_array ()
				
				try 
				(
					for i=1 to 20 do 
					(
						local expr_hide="SanLightTable.ckb"+(i as string)+".checked"
						if (execute expr_hide)!=false do 
						(
							fn_onions_create i
						)
					)
				) catch ()
			redrawViews()
			)
			local arrGhostLight = $'ghost_*'
			for o in arrGhostLight do
			(
				o.renderable = SanLightTable.ckbRenderGhost.state
			)
		)
		
fn fn_lock_before = 
	(
		SanLightTable.ckb1.visible=SanLightTable.ch_before.checked
		SanLightTable.ckb2.visible=SanLightTable.ch_before.checked
		SanLightTable.ckb3.visible=SanLightTable.ch_before.checked
		SanLightTable.ckb4.visible=SanLightTable.ch_before.checked
		SanLightTable.ckb5.visible=SanLightTable.ch_before.checked
		SanLightTable.ckb6.visible=SanLightTable.ch_before.checked
		SanLightTable.ckb7.visible=SanLightTable.ch_before.checked
		SanLightTable.ckb8.visible=SanLightTable.ch_before.checked
		SanLightTable.ckb9.visible=SanLightTable.ch_before.checked
		SanLightTable.ckb10.visible=SanLightTable.ch_before.checked
		SanLightTable.pb1.enabled=SanLightTable.ch_before.checked
		SanLightTable.pb2.enabled=SanLightTable.ch_before.checked
		SanLightTable.pb3.enabled=SanLightTable.ch_before.checked
		SanLightTable.pb4.enabled=SanLightTable.ch_before.checked
		SanLightTable.pb5.enabled=SanLightTable.ch_before.checked
		SanLightTable.pb6.enabled=SanLightTable.ch_before.checked
		SanLightTable.pb7.enabled=SanLightTable.ch_before.checked
		SanLightTable.pb8.enabled=SanLightTable.ch_before.checked
		SanLightTable.pb9.enabled=SanLightTable.ch_before.checked
		SanLightTable.pb10.enabled=SanLightTable.ch_before.checked
		)
		
fn fn_lock_after = 
	(
		SanLightTable.ckb11.visible=SanLightTable.ch_after.checked
		SanLightTable.ckb12.visible=SanLightTable.ch_after.checked
		SanLightTable.ckb13.visible=SanLightTable.ch_after.checked
		SanLightTable.ckb14.visible=SanLightTable.ch_after.checked
		SanLightTable.ckb15.visible=SanLightTable.ch_after.checked
		SanLightTable.ckb16.visible=SanLightTable.ch_after.checked
		SanLightTable.ckb17.visible=SanLightTable.ch_after.checked
		SanLightTable.ckb18.visible=SanLightTable.ch_after.checked
		SanLightTable.ckb19.visible=SanLightTable.ch_after.checked
		SanLightTable.ckb20.visible=SanLightTable.ch_after.checked
		SanLightTable.pb11.enabled=SanLightTable.ch_after.checked
		SanLightTable.pb12.enabled=SanLightTable.ch_after.checked
		SanLightTable.pb13.enabled=SanLightTable.ch_after.checked
		SanLightTable.pb14.enabled=SanLightTable.ch_after.checked
		SanLightTable.pb15.enabled=SanLightTable.ch_after.checked
		SanLightTable.pb16.enabled=SanLightTable.ch_after.checked
		SanLightTable.pb17.enabled=SanLightTable.ch_after.checked
		SanLightTable.pb18.enabled=SanLightTable.ch_after.checked
		SanLightTable.pb19.enabled=SanLightTable.ch_after.checked
		SanLightTable.pb20.enabled=SanLightTable.ch_after.checked
		)
		
try (destroydialog SanLightTable) catch ()

rollout SanLightTable ("[运动重影]_LightTable_v "+SanLightTable_version) width:520 height:296
(
	checkbutton ch_onion_enable "启用重影" pos:[192,8] width:136 height:24 checked:true --highlightColor:(color 101 237 108) 

	progressBar pb10 "" pos:[8,64] width:24 height:168 value:0 color:pb_col orient:#vertical
	progressBar pb9 "" pos:[32,64] width:24 height:168 value:2 color:pb_col orient:#vertical
	progressBar pb8 "" pos:[56,64] width:24 height:168 value:4 color:pb_col orient:#vertical
	progressBar pb7 "" pos:[80,64] width:24 height:168 value:7 color:pb_col orient:#vertical
	progressBar pb6 "" pos:[104,64] width:24 height:168 value:11 color:pb_col orient:#vertical
	progressBar pb5 "" pos:[128,64] width:24 height:168 value:16 color:pb_col orient:#vertical
	progressBar pb4 "" pos:[152,64] width:24 height:168 value:22 color:pb_col orient:#vertical
	progressBar pb3 "" pos:[176,64] width:24 height:168 value:35 color:pb_col orient:#vertical
	progressBar pb2 "" pos:[200,64] width:24 height:168 value:53 color:pb_col orient:#vertical
	progressBar pb1 "" pos:[224,64] width:24 height:168 value:85 color:pb_col orient:#vertical
	
	progressBar pb11 "" pos:[272,64] width:24 height:168 value:pb1.value color:pb_col orient:#vertical
	progressBar pb12 "" pos:[296,64] width:24 height:168 value:pb2.value color:pb_col orient:#vertical
	progressBar pb13 "" pos:[320,64] width:24 height:168 value:pb3.value color:pb_col orient:#vertical
	progressBar pb14 "" pos:[344,64] width:24 height:168 value:pb4.value color:pb_col orient:#vertical
	progressBar pb15 "" pos:[368,64] width:24 height:168 value:pb5.value color:pb_col orient:#vertical
	progressBar pb16 "" pos:[392,64] width:24 height:168 value:pb6.value color:pb_col orient:#vertical
	progressBar pb17 "" pos:[416,64] width:24 height:168 value:pb7.value color:pb_col orient:#vertical
	progressBar pb18 "" pos:[440,64] width:24 height:168 value:pb8.value color:pb_col orient:#vertical
	progressBar pb19 "" pos:[464,64] width:24 height:168 value:pb9.value color:pb_col orient:#vertical
	progressBar pb20 "" pos:[488,64] width:24 height:168 value:pb10.value color:pb_col orient:#vertical
	
	progressBar pb_all "" pos:[248,64] width:24 height:168 value:35 color:pb_col1 orient:#vertical
	
	checkbutton bt_sym "对称开关" pos:[440,232] width:72 height:20 checked:true tooltip:"对称编辑开关"--highlightcolor: ch_colors 
	
	colorPicker cp_before "" pos:[72,8] width:40 height:24 color:(color 101 203 228)
	colorPicker cp_after "" pos:[419,8] width:40 height:24 color:(color 255 144 101)
	checkButton ch_before "前" pos:[24,8] width:48 height:24 checked:true highlightcolor: ch_colors
	checkButton ch_after "后" pos:[464,8] width:48 height:24 checked:true highlightcolor: ch_colors
	
	button bt_add "重影高亮" pos:[192,240] width:136 height:24 tooltip: "鼠标左击 = 所选物体显示重影\r\nCtrl+鼠标左击 = 添加所选物体显示重影\r\n鼠标右击 = 选中显示重影的物体"
	button btnCleanGhost "删除重影" pos:[192,264] width:136 height:24

	checkbutton ckb10 "10" pos:[8,40] width:24 height:24
	checkbutton ckb9 "9" pos:[32,40] width:24 height:24
	checkbutton ckb8 "8" pos:[56,40] width:24 height:24
	checkbutton ckb7 "7" pos:[80,40] width:24 height:24 
	checkbutton ckb6 "6" pos:[104,40] width:24 height:24 
	checkbutton ckb5 "5" pos:[128,40] width:24 height:24 
	checkbutton ckb4 "4" pos:[152,40] width:24 height:24 
	checkbutton ckb3 "3" pos:[176,40] width:24 height:24 
	checkbutton ckb2 "2" pos:[200,40] width:24 height:24 --checked:true
	checkbutton ckb1 "1" pos:[224,40] width:24 height:24 checked:true
	button bt_mode "+" pos:[248,40] width:24 height:24 tooltip: "pressets"
	checkbutton ckb11 "1" pos:[272,40] width:24 height:24 checked:true
	checkbutton ckb12 "2" pos:[296,40] width:24 height:24 --checked:true
	checkbutton ckb13 "3" pos:[320,40] width:24 height:24
	checkbutton ckb14 "4" pos:[344,40] width:24 height:24
	checkbutton ckb15 "5" pos:[368,40] width:24 height:24
	checkbutton ckb16 "6" pos:[392,40] width:24 height:24
	checkbutton ckb17 "7" pos:[416,40] width:24 height:24
	checkbutton ckb18 "8" pos:[440,40] width:24 height:24
	checkbutton ckb19 "9" pos:[464,40] width:24 height:24
	checkbutton ckb20 "10" pos:[488,40] width:24 height:24
	
	radioButtons rdo_mode "" pos:[8,240] width:82 height:48 labels:#("正常", "循环", "剪辑范围") columns:1
	radioButtons rdo_mode_frame "" pos:[85,240] width:82 height:48 labels:#("帧", "关键帧 (step)", "关键帧 (spline)") columns:1
	button bt_help "?" pos:[0,1] width:16 height:15 toolTip:"鼠标左击 = 帮助\r\nCtrl+鼠标左击 = 打开 .config 设置文件的目录\r\nShift+鼠标左击 = 打开设置文件\r\nRight+鼠标左击 = “播放时显示重影”开关切换"

	checkbox ckbUnFreeze "解除冻结" pos:[336,240] width:96 height:16 checked:false visible: true
	checkbox ckbRenderGhost "渲染可见" pos:[336,256] width:96 height:16 checked:false visible: true
	checkbox ch_hide_on_play "播放时隐藏" pos:[336,272] width:96 height:16 checked:true visible: true 
	checkButton ch_shaded "平面材质"  pos:[440,252] width:72 height:20 highlightcolor: ch_colors tooltip: "显示平面材质重影" --visible: false 
	checkButton ch_alpha "不透明贴图"  pos:[440,272] width:72 height:20 highlightcolor: ch_colors tooltip: "在重影上使用材质不透明度贴图\r\n仅对Standard材质有效" --visible: false
-- ) 
-- createdialog SanLightTable
	on ckbUnFreeze changed state do 
	(
		SanLightTable_layer.lock = (not state)
	)

	on ckbRenderGhost changed state do
	(
		local arrGhostLight = $'ghost_*'
		for o in arrGhostLight do
		(
			o.renderable = state
		)
	)

	on btnCleanGhost pressed do 
	(
		deleteAppData rootnode SanLightTable_id_obj
		try 
		(
			for i=1 to 20 do 
			(
				local expr="onions_arr_"+(i as string)
				local arr=(execute expr)
				delete arr
				execute (expr+"=#()")
			)
			if SanLightTable_layer.current==true do 
			(
				SanLightTable_layer_0.current=true
			)
			LayerManager.deleteLayerByName "0 (LightTable_ghosts)"
			onion_obj_arr=#()
			redrawViews()
		) catch ()
	)

	on SanLightTable open do with undo off animate off
		(
-- 			if (filterstring (gw.getDriverString()) " ")[1]=="Nitrous" do 
-- 				(
-- 					SanLightTable.ch_onion_enable.visible=false
-- 					)
			fn_load_lt_ini SanLightTable SanLightTable_ini
			callbacks.addScript #filePreSave SanLightTable_presave_message id:#SanLightTable_presave
			callbacks.addScript #filePostSave SanLightTable_postsave_message id:#SanLightTable_postsave
			callbacks.addScript #filePreOpenProcess SanLightTable_reloader_message id:#SanLightTable_reloader
			callbacks.addScript #filePostOpenProcess SanLightTable_reloader_message_1 id:#SanLightTable_reloader_1
			fn_lock_before ()
			fn_lock_after ()
			)
	
	on SanLightTable close do with undo off animate off
	(
		try (destroydialog SanLightTable_help) catch ()
		try 
			(
				for i=1 to 20 do 
					(
						local expr="onions_arr_"+(i as string)
						local arr=(execute expr)
						delete arr
						execute (expr+"=#()")
						)
				if SanLightTable_layer.current==true do 
					(
						SanLightTable_layer_0.current=true
						)
				LayerManager.deleteLayerByName "0 (LightTable_ghosts)"
				) catch ()--messagebox "some of onion objects can not be deleted")
				
		SanLightTable_dialog_pos=GetDialogPos SanLightTable
		fn_save_lt_ini SanLightTable SanLightTable_ini
		callbacks.RemoveScripts #filePreSave id:#SanLightTable_presave
		callbacks.RemoveScripts #filePostSave id:#SanLightTable_postsave
		callbacks.RemoveScripts #filePreOpenProcess id:#SanLightTable_reloader
		if check_post_open==0 do 
			(
				callbacks.RemoveScripts #filePostOpenProcess id:#SanLightTable_reloader_1
				)
		)
		
	on bt_help pressed do 
		(
			if keyboard.controlpressed==true then 
				(
					ShellLaunch "explorer.exe" (GetDir #plugcfg)
					) else 
					(
						if keyboard.shiftpressed==true then 
							(
								ShellLaunch "explorer.exe" SanLightTable_ini
								) else 
								(
									rollout SanLightTable_help ("LightTable v "+SanLightTable_version+" 帮助") width:600
									(
										label lbl_0 "选择任意物体并点击 '重影高亮！'。" align:#left 
										label lbl_1 "现在你可以在选择物体上预览重影 (洋葱皮效果)。" align:#left 
										label lbl_0_1 ""
										label lbl_0_01 "播放动画是重影将自动影藏" align:#left
										label lbl_1_1 "重影将整合在新的层里 \"0 (LightTable_ghosts)\"" align:#left
										label lbl_1_2 "重影不会保存在你的场景和自动保存场景中" align:#left
										label lbl_111 "您通常可以在关闭场景之前收到“保存检查”消息" align:#left
										label lbl_1111 "因为重影会在重新加载或关闭工具时自动删除。" align:#left
										label lbl_1_4_1"为了获得更好的性能，我建议使用Direct3D视口" align:#left
										label lbl_10 ""
										label lbl_2 "按 “+” 按钮更改预设" align:#left 
										label lbl_3 "按“对称开关”按钮以对称方式更改幻影可见性和不透明度" align:#left 
										label lbl_4_1 "" align:#left 
										label lbl_4 "范围模式（取决于动画范围）：" align:#left 
										label lbl_6 "正常-显示所有可见的重影" align:#left 
										label lbl_7 "循环-显示所有循环范围内可见的重影" align:#left 
										label lbl_7_1 "剪辑范围-仅在动画范围内显示重影" align:#left 
										label lbl_9 ""
										label lbl_41 "帧模式：" align:#left 
										label lbl_61 "帧 - 每帧重影; 适用于 polish 阶段" align:#left 
										label lbl_71 "关键帧 (step) - 重影使用当前选定对象的关键帧; 以上一个关键帧为起始; 适用于 Blocking 阶段" align:#left 
										label lbl_7_11 "Key (spline) - 重影使用当前选定对象的关键帧; 以上当前帧为起始; 适用于 Spline 阶段" align:#left 
										label lbl_7_111 "关键帧模式将为存在动画的所选物体显示正确的关键帧" align:#left 
										label lbl_7_1111 "如果没有选择物体，则显示帧模式" align:#left 
										label lbl_91 ""
										label lbl_1_3 "显示选项：" align:#left
										label lbl_1_4 "平面材质-显示不带阴影的重影 " align:#left
										label lbl_1_14 "使用不透明度贴图-如果对象的纹理具有" align:#left
										label lbl_9s "一个Alpha通道（可能会减慢重影的生成）" align:#left
										label lbl_09 ""
										label lbl_51 "注意事项：" align:#left 
										label lbl_5 "所选对象的信息将保存在场景中" align:#left 
										label lbl_8 "脚本使用 “setAppData rootnode” 函数来执行此操作" align:#left
										label lbl_11 "id = -69125528456851322651" align:#left
										button bt_delete_data "从场景中删除LT数据 " align:#left 
										label lbl_author "script by San_oOo" 
										hyperLink myEmail "http://cargocollective.com/San-oOo" color:(color 0 0 255) hovercolor:(color 0 0 190) visitedcolor:(color 190 0 0) align:#center address:"http://cargocollective.com/San-oOo"
										label lblMod "Modified_by_Bullet.S"
										on bt_delete_data pressed do 
											(
												deleteAppData rootnode SanLightTable_id_obj
												try 
													(
														for i=1 to 20 do 
															(
																local expr="onions_arr_"+(i as string)
																local arr=(execute expr)
																delete arr
																execute (expr+"=#()")
																)
														if SanLightTable_layer.current==true do 
															(
																SanLightTable_layer_0.current=true
																)
														LayerManager.deleteLayerByName "0 (LightTable_ghosts)"
														onion_obj_arr=#()
														redrawViews()
														) catch ()--messagebox "some of onion objects can not be deleted")
												)
										
										)
										CreateDialog SanLightTable_help
									)
						)
			)
		
	on bt_help rightclick do 
		(
			SanLightTable.ch_hide_on_play.changed (SanLightTable.ch_hide_on_play.checked=not SanLightTable.ch_hide_on_play.checked)
			if SanLightTable.ch_hide_on_play.checked==true then
				(
					print ("hide when play enabled")
					) else 
					(
						print ("hide when play disabled")
						)
			)
			
	on rdo_mode changed state do with undo off animate off
		(
			try 
				(
					if ch_onion_enable.checked==true and onion_obj_arr.count!=0 do 
						(
							for i=1 to 20 do 
								(
									local ckb=(execute ("SanLightTable.ckb"+(i as string)))
									if ckb.checked==true do 
										(
											local arr=execute ("onions_arr_"+(i as string))
											for s in arr do 
												(
													s.transform.controller.SetConstant "light_mode" state
													unhide s
													)
											)
									)
							redrawViews ()
							)
					) catch ()
			)
		
	on rdo_mode_frame changed state do with undo off animate off
		(
			try 
				(
					if ch_onion_enable.checked==true and onion_obj_arr.count!=0 do 
						(
							for i=1 to 20 do 
								(
									local ckb=(execute ("SanLightTable.ckb"+(i as string)))
									if ckb.checked==true do 
										(
											local arr=execute ("onions_arr_"+(i as string))
											for s in arr do 
												(
													s.transform.controller.SetConstant "frame_mode" state
													if (selection.count!=0) and (selection[1]!=s) then 
													(
														unhide s
														) else 
														(
															hide s
															)
													)
											)
									)
							redrawViews ()
							)
					) catch ()
			)
			
	on ch_hide_on_play changed state do with undo off animate off
		(
			try 
				(
					if ch_onion_enable.checked==true and onion_obj_arr.count!=0 do 
						(
							for i=1 to 20 do 
								(
									local ckb=(execute ("SanLightTable.ckb"+(i as string)))
									if ckb.checked==true do 
										(
											local arr=execute ("onions_arr_"+(i as string))
											for s in arr do 
												(
													s.transform.controller.SetConstant "hide_on_play" state
													unhide s
													)
											)
									)
							redrawViews ()
							)
					) catch (messagebox ("Error \n------------log:-----------\n"+(getCurrentException())))
			)
			
	on bt_mode pressed do 
		(
			rcMenu SanLightTable_frames_menu
			(
				menuItem bt_none "无"
				menuItem bt_all "所有"
				menuItem bt_every_2 "每2"
				menuItem bt_every_3 "每3"
				menuItem bt_default "默认"
-- 				separator sep1
-- 				menuItem bt_after_off "only before"
-- 				menuItem bt_before_off "only after"
				separator sep2
				menuItem bt_copy_to_after "前 -->> 后"
				menuItem bt_copy_to_before "前 <<-- 后"
				menuItem bt_mirror "镜像"
				
				on bt_none picked do with undo off animate off
					(
						fn_lt_quick_clear_arr ()
						fn_clean_array ()
						SanLightTable.ckb1.checked=false
						SanLightTable.ckb2.checked=false
						SanLightTable.ckb3.checked=false
						SanLightTable.ckb4.checked=false
						SanLightTable.ckb5.checked=false
						SanLightTable.ckb6.checked=false
						SanLightTable.ckb7.checked=false
						SanLightTable.ckb8.checked=false
						SanLightTable.ckb9.checked=false
						SanLightTable.ckb10.checked=false
						SanLightTable.ckb11.checked=false
						SanLightTable.ckb12.checked=false
						SanLightTable.ckb13.checked=false
						SanLightTable.ckb14.checked=false
						SanLightTable.ckb15.checked=false
						SanLightTable.ckb16.checked=false
						SanLightTable.ckb17.checked=false
						SanLightTable.ckb18.checked=false
						SanLightTable.ckb19.checked=false
						SanLightTable.ckb20.checked=false
						)
						
				on bt_all picked do with undo off animate off
					(
						fn_lt_quick_clear_arr ()
						fn_clean_array ()
						local sym_ch=0
						if SanLightTable.bt_sym.checked==true do 
							(
								SanLightTable.bt_sym.checked=false
								sym_ch=1
								)
						SanLightTable.ckb1.checked=true
						SanLightTable.ckb2.checked=true
						SanLightTable.ckb3.checked=true
						SanLightTable.ckb4.checked=true
						SanLightTable.ckb5.checked=true
						SanLightTable.ckb6.checked=true
						SanLightTable.ckb7.checked=true
						SanLightTable.ckb8.checked=true
						SanLightTable.ckb9.checked=true
						SanLightTable.ckb10.checked=true
						SanLightTable.ckb11.checked=true
						SanLightTable.ckb12.checked=true
						SanLightTable.ckb13.checked=true
						SanLightTable.ckb14.checked=true
						SanLightTable.ckb15.checked=true
						SanLightTable.ckb16.checked=true
						SanLightTable.ckb17.checked=true
						SanLightTable.ckb18.checked=true
						SanLightTable.ckb19.checked=true
						SanLightTable.ckb20.checked=true
						
						fn_onions_hide 1 SanLightTable.ckb1.checked
						fn_onions_hide 2 SanLightTable.ckb2.checked
						fn_onions_hide 3 SanLightTable.ckb3.checked
						fn_onions_hide 4 SanLightTable.ckb4.checked
						fn_onions_hide 5 SanLightTable.ckb5.checked
						fn_onions_hide 6 SanLightTable.ckb6.checked
						fn_onions_hide 7 SanLightTable.ckb7.checked
						fn_onions_hide 8 SanLightTable.ckb8.checked
						fn_onions_hide 9 SanLightTable.ckb9.checked
						fn_onions_hide 10 SanLightTable.ckb10.checked
						fn_onions_hide 11 SanLightTable.ckb11.checked
						fn_onions_hide 12 SanLightTable.ckb12.checked
						fn_onions_hide 13 SanLightTable.ckb13.checked
						fn_onions_hide 14 SanLightTable.ckb14.checked
						fn_onions_hide 15 SanLightTable.ckb15.checked
						fn_onions_hide 16 SanLightTable.ckb16.checked
						fn_onions_hide 17 SanLightTable.ckb17.checked
						fn_onions_hide 18 SanLightTable.ckb18.checked
						fn_onions_hide 19 SanLightTable.ckb19.checked
						fn_onions_hide 20 SanLightTable.ckb20.checked
						if sym_ch==1 do 
							(
								SanLightTable.bt_sym.checked=true
								)
						)
						
				on bt_every_2 picked do with undo off animate off
					(
						fn_lt_quick_clear_arr ()
						fn_clean_array ()
						local sym_ch=0
						if SanLightTable.bt_sym.checked==true do 
							(
								SanLightTable.bt_sym.checked=false
								sym_ch=1
								)
						SanLightTable.ckb1.checked=false
						SanLightTable.ckb2.checked=true
						SanLightTable.ckb3.checked=false
						SanLightTable.ckb4.checked=true
						SanLightTable.ckb5.checked=false
						SanLightTable.ckb6.checked=true
						SanLightTable.ckb7.checked=false
						SanLightTable.ckb8.checked=true
						SanLightTable.ckb9.checked=false
						SanLightTable.ckb10.checked=true
						SanLightTable.ckb11.checked=false
						SanLightTable.ckb12.checked=true
						SanLightTable.ckb13.checked=false
						SanLightTable.ckb14.checked=true
						SanLightTable.ckb15.checked=false
						SanLightTable.ckb16.checked=true
						SanLightTable.ckb17.checked=false
						SanLightTable.ckb18.checked=true
						SanLightTable.ckb19.checked=false
						SanLightTable.ckb20.checked=true
						fn_onions_hide 1 SanLightTable.ckb1.checked
						fn_onions_hide 2 SanLightTable.ckb2.checked
						fn_onions_hide 3 SanLightTable.ckb3.checked
						fn_onions_hide 4 SanLightTable.ckb4.checked
						fn_onions_hide 5 SanLightTable.ckb5.checked
						fn_onions_hide 6 SanLightTable.ckb6.checked
						fn_onions_hide 7 SanLightTable.ckb7.checked
						fn_onions_hide 8 SanLightTable.ckb8.checked
						fn_onions_hide 9 SanLightTable.ckb9.checked
						fn_onions_hide 10 SanLightTable.ckb10.checked
						fn_onions_hide 11 SanLightTable.ckb11.checked
						fn_onions_hide 12 SanLightTable.ckb12.checked
						fn_onions_hide 13 SanLightTable.ckb13.checked
						fn_onions_hide 14 SanLightTable.ckb14.checked
						fn_onions_hide 15 SanLightTable.ckb15.checked
						fn_onions_hide 16 SanLightTable.ckb16.checked
						fn_onions_hide 17 SanLightTable.ckb17.checked
						fn_onions_hide 18 SanLightTable.ckb18.checked
						fn_onions_hide 19 SanLightTable.ckb19.checked
						fn_onions_hide 20 SanLightTable.ckb20.checked
						if sym_ch==1 do 
							(
								SanLightTable.bt_sym.checked=true
								)
						)
						
				on bt_every_3 picked do with undo off animate off
					(
						fn_lt_quick_clear_arr ()
						fn_clean_array ()
						local sym_ch=0
						if SanLightTable.bt_sym.checked==true do 
							(
								SanLightTable.bt_sym.checked=false
								sym_ch=1
								)
						SanLightTable.ckb1.checked=false
						SanLightTable.ckb2.checked=false
						SanLightTable.ckb3.checked=true
						SanLightTable.ckb4.checked=false
						SanLightTable.ckb5.checked=false
						SanLightTable.ckb6.checked=true
						SanLightTable.ckb7.checked=false
						SanLightTable.ckb8.checked=false
						SanLightTable.ckb9.checked=true
						SanLightTable.ckb10.checked=false
						SanLightTable.ckb11.checked=false
						SanLightTable.ckb12.checked=false
						SanLightTable.ckb13.checked=true
						SanLightTable.ckb14.checked=false
						SanLightTable.ckb15.checked=false
						SanLightTable.ckb16.checked=true
						SanLightTable.ckb17.checked=false
						SanLightTable.ckb18.checked=false
						SanLightTable.ckb19.checked=true
						SanLightTable.ckb20.checked=false
						fn_onions_hide 1 SanLightTable.ckb1.checked
						fn_onions_hide 2 SanLightTable.ckb2.checked
						fn_onions_hide 3 SanLightTable.ckb3.checked
						fn_onions_hide 4 SanLightTable.ckb4.checked
						fn_onions_hide 5 SanLightTable.ckb5.checked
						fn_onions_hide 6 SanLightTable.ckb6.checked
						fn_onions_hide 7 SanLightTable.ckb7.checked
						fn_onions_hide 8 SanLightTable.ckb8.checked
						fn_onions_hide 9 SanLightTable.ckb9.checked
						fn_onions_hide 10 SanLightTable.ckb10.checked
						fn_onions_hide 11 SanLightTable.ckb11.checked
						fn_onions_hide 12 SanLightTable.ckb12.checked
						fn_onions_hide 13 SanLightTable.ckb13.checked
						fn_onions_hide 14 SanLightTable.ckb14.checked
						fn_onions_hide 15 SanLightTable.ckb15.checked
						fn_onions_hide 16 SanLightTable.ckb16.checked
						fn_onions_hide 17 SanLightTable.ckb17.checked
						fn_onions_hide 18 SanLightTable.ckb18.checked
						fn_onions_hide 19 SanLightTable.ckb19.checked
						fn_onions_hide 20 SanLightTable.ckb20.checked
						if sym_ch==1 do 
							(
								SanLightTable.bt_sym.checked=true
								)
						)
						
				on bt_default picked do with undo off animate off
					(
						fn_lt_quick_clear_arr ()
						fn_clean_array ()
						local sym_ch=0
						if SanLightTable.bt_sym.checked==true do 
							(
								SanLightTable.bt_sym.checked=false
								sym_ch=1
								)
						SanLightTable.ckb1.checked=true
						SanLightTable.ckb2.checked=false
						SanLightTable.ckb3.checked=false
						SanLightTable.ckb4.checked=false
						SanLightTable.ckb5.checked=false
						SanLightTable.ckb6.checked=false
						SanLightTable.ckb7.checked=false
						SanLightTable.ckb8.checked=false
						SanLightTable.ckb9.checked=false
						SanLightTable.ckb10.checked=false
						SanLightTable.ckb11.checked=true
						SanLightTable.ckb12.checked=false
						SanLightTable.ckb13.checked=false
						SanLightTable.ckb14.checked=false
						SanLightTable.ckb15.checked=false
						SanLightTable.ckb16.checked=false
						SanLightTable.ckb17.checked=false
						SanLightTable.ckb18.checked=false
						SanLightTable.ckb19.checked=false
						SanLightTable.ckb20.checked=false
						
						SanLightTable.pb1.value=85
						SanLightTable.pb2.value=53
						SanLightTable.pb3.value=35
						SanLightTable.pb4.value=22
						SanLightTable.pb5.value=16
						SanLightTable.pb6.value=11
						SanLightTable.pb7.value=7
						SanLightTable.pb8.value=4
						SanLightTable.pb9.value=2
						SanLightTable.pb10.value=0
						SanLightTable.pb11.value=SanLightTable.pb1.value
						SanLightTable.pb12.value=SanLightTable.pb2.value
						SanLightTable.pb13.value=SanLightTable.pb3.value
						SanLightTable.pb14.value=SanLightTable.pb4.value
						SanLightTable.pb15.value=SanLightTable.pb5.value
						SanLightTable.pb16.value=SanLightTable.pb6.value
						SanLightTable.pb17.value=SanLightTable.pb7.value
						SanLightTable.pb18.value=SanLightTable.pb8.value
						SanLightTable.pb19.value=SanLightTable.pb9.value
						SanLightTable.pb20.value=SanLightTable.pb10.value
						SanLightTable.pb_all.value=35
						
						fn_onions_hide 1 SanLightTable.ckb1.checked
						fn_onions_hide 2 SanLightTable.ckb2.checked
						fn_onions_hide 3 SanLightTable.ckb3.checked
						fn_onions_hide 4 SanLightTable.ckb4.checked
						fn_onions_hide 5 SanLightTable.ckb5.checked
						fn_onions_hide 6 SanLightTable.ckb6.checked
						fn_onions_hide 7 SanLightTable.ckb7.checked
						fn_onions_hide 8 SanLightTable.ckb8.checked
						fn_onions_hide 9 SanLightTable.ckb9.checked
						fn_onions_hide 10 SanLightTable.ckb10.checked
						fn_onions_hide 11 SanLightTable.ckb11.checked
						fn_onions_hide 12 SanLightTable.ckb12.checked
						fn_onions_hide 13 SanLightTable.ckb13.checked
						fn_onions_hide 14 SanLightTable.ckb14.checked
						fn_onions_hide 15 SanLightTable.ckb15.checked
						fn_onions_hide 16 SanLightTable.ckb16.checked
						fn_onions_hide 17 SanLightTable.ckb17.checked
						fn_onions_hide 18 SanLightTable.ckb18.checked
						fn_onions_hide 19 SanLightTable.ckb19.checked
						fn_onions_hide 20 SanLightTable.ckb20.checked
						if sym_ch==1 do 
							(
								SanLightTable.bt_sym.checked=true
								)
						)
						
				on bt_before_off picked do with undo off animate off
					(
-- 						fn_lt_quick_clear_arr ()
						fn_clean_array ()
						local sym_ch=0
						if SanLightTable.bt_sym.checked==true do 
							(
								SanLightTable.bt_sym.checked=false
								sym_ch=1
								)
						SanLightTable.ckb1.checked=false
						SanLightTable.ckb2.checked=false
						SanLightTable.ckb3.checked=false
						SanLightTable.ckb4.checked=false
						SanLightTable.ckb5.checked=false
						SanLightTable.ckb6.checked=false
						SanLightTable.ckb7.checked=false
						SanLightTable.ckb8.checked=false
						SanLightTable.ckb9.checked=false
						SanLightTable.ckb10.checked=false

						fn_onions_hide 1 SanLightTable.ckb1.checked
						fn_onions_hide 2 SanLightTable.ckb2.checked
						fn_onions_hide 3 SanLightTable.ckb3.checked
						fn_onions_hide 4 SanLightTable.ckb4.checked
						fn_onions_hide 5 SanLightTable.ckb5.checked
						fn_onions_hide 6 SanLightTable.ckb6.checked
						fn_onions_hide 7 SanLightTable.ckb7.checked
						fn_onions_hide 8 SanLightTable.ckb8.checked
						fn_onions_hide 9 SanLightTable.ckb9.checked
						fn_onions_hide 10 SanLightTable.ckb10.checked
						if sym_ch==1 do 
							(
								SanLightTable.bt_sym.checked=true
								)
						)
						
				on bt_after_off picked do with undo off animate off
					(
-- 						fn_lt_quick_clear_arr ()
						fn_clean_array ()
						local sym_ch=0
						if SanLightTable.bt_sym.checked==true do 
							(
								SanLightTable.bt_sym.checked=false
								sym_ch=1
								)
						SanLightTable.ckb11.checked=false
						SanLightTable.ckb12.checked=false
						SanLightTable.ckb13.checked=false
						SanLightTable.ckb14.checked=false
						SanLightTable.ckb15.checked=false
						SanLightTable.ckb16.checked=false
						SanLightTable.ckb17.checked=false
						SanLightTable.ckb18.checked=false
						SanLightTable.ckb19.checked=false
						SanLightTable.ckb20.checked=false

						fn_onions_hide 11 SanLightTable.ckb11.checked
						fn_onions_hide 12 SanLightTable.ckb12.checked
						fn_onions_hide 13 SanLightTable.ckb13.checked
						fn_onions_hide 14 SanLightTable.ckb14.checked
						fn_onions_hide 15 SanLightTable.ckb15.checked
						fn_onions_hide 16 SanLightTable.ckb16.checked
						fn_onions_hide 17 SanLightTable.ckb17.checked
						fn_onions_hide 18 SanLightTable.ckb18.checked
						fn_onions_hide 19 SanLightTable.ckb19.checked
						fn_onions_hide 20 SanLightTable.ckb20.checked
						if sym_ch==1 do 
							(
								SanLightTable.bt_sym.checked=true
								)
						)
						
				on bt_copy_to_after picked do with undo off animate off
					(
-- 						fn_lt_quick_clear_arr ()
						fn_clean_array ()
						local sym_ch=0
						if SanLightTable.bt_sym.checked==true do 
							(
								SanLightTable.bt_sym.checked=false
								sym_ch=1
								)
								
						SanLightTable.ckb11.checked=false
						SanLightTable.ckb12.checked=false
						SanLightTable.ckb13.checked=false
						SanLightTable.ckb14.checked=false
						SanLightTable.ckb15.checked=false
						SanLightTable.ckb16.checked=false
						SanLightTable.ckb17.checked=false
						SanLightTable.ckb18.checked=false
						SanLightTable.ckb19.checked=false
						SanLightTable.ckb20.checked=false

						fn_onions_hide 11 SanLightTable.ckb11.checked
						fn_onions_hide 12 SanLightTable.ckb12.checked
						fn_onions_hide 13 SanLightTable.ckb13.checked
						fn_onions_hide 14 SanLightTable.ckb14.checked
						fn_onions_hide 15 SanLightTable.ckb15.checked
						fn_onions_hide 16 SanLightTable.ckb16.checked
						fn_onions_hide 17 SanLightTable.ckb17.checked
						fn_onions_hide 18 SanLightTable.ckb18.checked
						fn_onions_hide 19 SanLightTable.ckb19.checked
						fn_onions_hide 20 SanLightTable.ckb20.checked
								
						SanLightTable.ckb11.checked=SanLightTable.ckb1.checked
						SanLightTable.ckb12.checked=SanLightTable.ckb2.checked
						SanLightTable.ckb13.checked=SanLightTable.ckb3.checked
						SanLightTable.ckb14.checked=SanLightTable.ckb4.checked
						SanLightTable.ckb15.checked=SanLightTable.ckb5.checked
						SanLightTable.ckb16.checked=SanLightTable.ckb6.checked
						SanLightTable.ckb17.checked=SanLightTable.ckb7.checked
						SanLightTable.ckb18.checked=SanLightTable.ckb8.checked
						SanLightTable.ckb19.checked=SanLightTable.ckb9.checked
						SanLightTable.ckb20.checked=SanLightTable.ckb10.checked
						
						SanLightTable.pb11.value=SanLightTable.pb1.value
						SanLightTable.pb12.value=SanLightTable.pb2.value
						SanLightTable.pb13.value=SanLightTable.pb3.value
						SanLightTable.pb14.value=SanLightTable.pb4.value
						SanLightTable.pb15.value=SanLightTable.pb5.value
						SanLightTable.pb16.value=SanLightTable.pb6.value
						SanLightTable.pb17.value=SanLightTable.pb7.value
						SanLightTable.pb18.value=SanLightTable.pb8.value
						SanLightTable.pb19.value=SanLightTable.pb9.value
						SanLightTable.pb20.value=SanLightTable.pb10.value
						
						fn_onions_hide 11 SanLightTable.ckb11.checked
						fn_onions_hide 12 SanLightTable.ckb12.checked
						fn_onions_hide 13 SanLightTable.ckb13.checked
						fn_onions_hide 14 SanLightTable.ckb14.checked
						fn_onions_hide 15 SanLightTable.ckb15.checked
						fn_onions_hide 16 SanLightTable.ckb16.checked
						fn_onions_hide 17 SanLightTable.ckb17.checked
						fn_onions_hide 18 SanLightTable.ckb18.checked
						fn_onions_hide 19 SanLightTable.ckb19.checked
						fn_onions_hide 20 SanLightTable.ckb20.checked
						if sym_ch==1 do 
							(
								SanLightTable.bt_sym.checked=true
								)
						)
						
				on bt_copy_to_before picked do with undo off animate off
					(
-- 						fn_lt_quick_clear_arr ()
						fn_clean_array ()
						local sym_ch=0
						if SanLightTable.bt_sym.checked==true do 
							(
								SanLightTable.bt_sym.checked=false
								sym_ch=1
								)
								
						SanLightTable.ckb1.checked=false
						SanLightTable.ckb2.checked=false
						SanLightTable.ckb3.checked=false
						SanLightTable.ckb4.checked=false
						SanLightTable.ckb5.checked=false
						SanLightTable.ckb6.checked=false
						SanLightTable.ckb7.checked=false
						SanLightTable.ckb8.checked=false
						SanLightTable.ckb9.checked=false
						SanLightTable.ckb10.checked=false

						fn_onions_hide 1 SanLightTable.ckb1.checked
						fn_onions_hide 2 SanLightTable.ckb2.checked
						fn_onions_hide 3 SanLightTable.ckb3.checked
						fn_onions_hide 4 SanLightTable.ckb4.checked
						fn_onions_hide 5 SanLightTable.ckb5.checked
						fn_onions_hide 6 SanLightTable.ckb6.checked
						fn_onions_hide 7 SanLightTable.ckb7.checked
						fn_onions_hide 8 SanLightTable.ckb8.checked
						fn_onions_hide 9 SanLightTable.ckb9.checked
						fn_onions_hide 10 SanLightTable.ckb10.checked
								
						SanLightTable.ckb1.checked=SanLightTable.ckb11.checked
						SanLightTable.ckb2.checked=SanLightTable.ckb12.checked
						SanLightTable.ckb3.checked=SanLightTable.ckb13.checked
						SanLightTable.ckb4.checked=SanLightTable.ckb14.checked
						SanLightTable.ckb5.checked=SanLightTable.ckb15.checked
						SanLightTable.ckb6.checked=SanLightTable.ckb16.checked
						SanLightTable.ckb7.checked=SanLightTable.ckb17.checked
						SanLightTable.ckb8.checked=SanLightTable.ckb18.checked
						SanLightTable.ckb9.checked=SanLightTable.ckb19.checked
						SanLightTable.ckb10.checked=SanLightTable.ckb20.checked
						
						SanLightTable.pb1.value=SanLightTable.pb11.value
						SanLightTable.pb2.value=SanLightTable.pb12.value
						SanLightTable.pb3.value=SanLightTable.pb13.value
						SanLightTable.pb4.value=SanLightTable.pb14.value
						SanLightTable.pb5.value=SanLightTable.pb15.value
						SanLightTable.pb6.value=SanLightTable.pb16.value
						SanLightTable.pb7.value=SanLightTable.pb17.value
						SanLightTable.pb8.value=SanLightTable.pb18.value
						SanLightTable.pb9.value=SanLightTable.pb19.value
						SanLightTable.pb10.value=SanLightTable.pb20.value
						
						fn_onions_hide 1 SanLightTable.ckb1.checked
						fn_onions_hide 2 SanLightTable.ckb2.checked
						fn_onions_hide 3 SanLightTable.ckb3.checked
						fn_onions_hide 4 SanLightTable.ckb4.checked
						fn_onions_hide 5 SanLightTable.ckb5.checked
						fn_onions_hide 6 SanLightTable.ckb6.checked
						fn_onions_hide 7 SanLightTable.ckb7.checked
						fn_onions_hide 8 SanLightTable.ckb8.checked
						fn_onions_hide 9 SanLightTable.ckb9.checked
						fn_onions_hide 10 SanLightTable.ckb10.checked
						if sym_ch==1 do 
							(
								SanLightTable.bt_sym.checked=true
								)
						)
						
				on bt_mirror picked do with undo off animate off
					(
-- 						fn_lt_quick_clear_arr ()
						fn_clean_array ()
						local sym_ch=0
						if SanLightTable.bt_sym.checked==true do 
							(
								SanLightTable.bt_sym.checked=false
								sym_ch=1
								)
						
						--data from after_ckb
						local ckb_11=SanLightTable.ckb11.checked
						local ckb_12=SanLightTable.ckb12.checked
						local ckb_13=SanLightTable.ckb13.checked
						local ckb_14=SanLightTable.ckb14.checked
						local ckb_15=SanLightTable.ckb15.checked
						local ckb_16=SanLightTable.ckb16.checked
						local ckb_17=SanLightTable.ckb17.checked
						local ckb_18=SanLightTable.ckb18.checked
						local ckb_19=SanLightTable.ckb19.checked
						local ckb_20=SanLightTable.ckb20.checked
						--data from after_opacity_values
						local pb_11=SanLightTable.pb11.value
						local pb_12=SanLightTable.pb12.value
						local pb_13=SanLightTable.pb13.value
						local pb_14=SanLightTable.pb14.value
						local pb_15=SanLightTable.pb15.value
						local pb_16=SanLightTable.pb16.value
						local pb_17=SanLightTable.pb17.value
						local pb_18=SanLightTable.pb18.value
						local pb_19=SanLightTable.pb19.value
						local pb_20=SanLightTable.pb20.value
								
						--copy from before
						SanLightTable.ckb11.checked=false
						SanLightTable.ckb12.checked=false
						SanLightTable.ckb13.checked=false
						SanLightTable.ckb14.checked=false
						SanLightTable.ckb15.checked=false
						SanLightTable.ckb16.checked=false
						SanLightTable.ckb17.checked=false
						SanLightTable.ckb18.checked=false
						SanLightTable.ckb19.checked=false
						SanLightTable.ckb20.checked=false

						fn_onions_hide 11 SanLightTable.ckb11.checked
						fn_onions_hide 12 SanLightTable.ckb12.checked
						fn_onions_hide 13 SanLightTable.ckb13.checked
						fn_onions_hide 14 SanLightTable.ckb14.checked
						fn_onions_hide 15 SanLightTable.ckb15.checked
						fn_onions_hide 16 SanLightTable.ckb16.checked
						fn_onions_hide 17 SanLightTable.ckb17.checked
						fn_onions_hide 18 SanLightTable.ckb18.checked
						fn_onions_hide 19 SanLightTable.ckb19.checked
						fn_onions_hide 20 SanLightTable.ckb20.checked
								
						SanLightTable.ckb11.checked=SanLightTable.ckb1.checked
						SanLightTable.ckb12.checked=SanLightTable.ckb2.checked
						SanLightTable.ckb13.checked=SanLightTable.ckb3.checked
						SanLightTable.ckb14.checked=SanLightTable.ckb4.checked
						SanLightTable.ckb15.checked=SanLightTable.ckb5.checked
						SanLightTable.ckb16.checked=SanLightTable.ckb6.checked
						SanLightTable.ckb17.checked=SanLightTable.ckb7.checked
						SanLightTable.ckb18.checked=SanLightTable.ckb8.checked
						SanLightTable.ckb19.checked=SanLightTable.ckb9.checked
						SanLightTable.ckb20.checked=SanLightTable.ckb10.checked
						
						SanLightTable.pb11.value=SanLightTable.pb1.value
						SanLightTable.pb12.value=SanLightTable.pb2.value
						SanLightTable.pb13.value=SanLightTable.pb3.value
						SanLightTable.pb14.value=SanLightTable.pb4.value
						SanLightTable.pb15.value=SanLightTable.pb5.value
						SanLightTable.pb16.value=SanLightTable.pb6.value
						SanLightTable.pb17.value=SanLightTable.pb7.value
						SanLightTable.pb18.value=SanLightTable.pb8.value
						SanLightTable.pb19.value=SanLightTable.pb9.value
						SanLightTable.pb20.value=SanLightTable.pb10.value
						
						fn_onions_hide 11 SanLightTable.ckb11.checked
						fn_onions_hide 12 SanLightTable.ckb12.checked
						fn_onions_hide 13 SanLightTable.ckb13.checked
						fn_onions_hide 14 SanLightTable.ckb14.checked
						fn_onions_hide 15 SanLightTable.ckb15.checked
						fn_onions_hide 16 SanLightTable.ckb16.checked
						fn_onions_hide 17 SanLightTable.ckb17.checked
						fn_onions_hide 18 SanLightTable.ckb18.checked
						fn_onions_hide 19 SanLightTable.ckb19.checked
						fn_onions_hide 20 SanLightTable.ckb20.checked
						
						--copy from saved 'after' data
						SanLightTable.ckb1.checked=false
						SanLightTable.ckb2.checked=false
						SanLightTable.ckb3.checked=false
						SanLightTable.ckb4.checked=false
						SanLightTable.ckb5.checked=false
						SanLightTable.ckb6.checked=false
						SanLightTable.ckb7.checked=false
						SanLightTable.ckb8.checked=false
						SanLightTable.ckb9.checked=false
						SanLightTable.ckb10.checked=false

						fn_onions_hide 1 SanLightTable.ckb1.checked
						fn_onions_hide 2 SanLightTable.ckb2.checked
						fn_onions_hide 3 SanLightTable.ckb3.checked
						fn_onions_hide 4 SanLightTable.ckb4.checked
						fn_onions_hide 5 SanLightTable.ckb5.checked
						fn_onions_hide 6 SanLightTable.ckb6.checked
						fn_onions_hide 7 SanLightTable.ckb7.checked
						fn_onions_hide 8 SanLightTable.ckb8.checked
						fn_onions_hide 9 SanLightTable.ckb9.checked
						fn_onions_hide 10 SanLightTable.ckb10.checked
								
						SanLightTable.ckb1.checked=ckb_11
						SanLightTable.ckb2.checked=ckb_12
						SanLightTable.ckb3.checked=ckb_13
						SanLightTable.ckb4.checked=ckb_14
						SanLightTable.ckb5.checked=ckb_15
						SanLightTable.ckb6.checked=ckb_16
						SanLightTable.ckb7.checked=ckb_17
						SanLightTable.ckb8.checked=ckb_18
						SanLightTable.ckb9.checked=ckb_19
						SanLightTable.ckb10.checked=ckb_20
						
						SanLightTable.pb1.value=pb_11
						SanLightTable.pb2.value=pb_12
						SanLightTable.pb3.value=pb_13
						SanLightTable.pb4.value=pb_14
						SanLightTable.pb5.value=pb_15
						SanLightTable.pb6.value=pb_16
						SanLightTable.pb7.value=pb_17
						SanLightTable.pb8.value=pb_18
						SanLightTable.pb9.value=pb_19
						SanLightTable.pb10.value=pb_20
						
						fn_onions_hide 1 SanLightTable.ckb1.checked
						fn_onions_hide 2 SanLightTable.ckb2.checked
						fn_onions_hide 3 SanLightTable.ckb3.checked
						fn_onions_hide 4 SanLightTable.ckb4.checked
						fn_onions_hide 5 SanLightTable.ckb5.checked
						fn_onions_hide 6 SanLightTable.ckb6.checked
						fn_onions_hide 7 SanLightTable.ckb7.checked
						fn_onions_hide 8 SanLightTable.ckb8.checked
						fn_onions_hide 9 SanLightTable.ckb9.checked
						fn_onions_hide 10 SanLightTable.ckb10.checked
						
						if sym_ch==1 do 
							(
								SanLightTable.bt_sym.checked=true
								)
						)
				)
			popUpMenu SanLightTable_frames_menu rollout:SanLightTable
			)
	
	on cp_before changed col do with undo off animate off
		(
			try 
				(
					for i=1 to 10 do 
						(
							local expr="onions_arr_"+(i as string)
							local arr=(execute expr)
							arr.wirecolor=col
							for oni in arr do 
								(
									if SanLightTable.ch_shaded.checked==true then 
										(
											oni.material.selfIllumColor = col
											) else 
											(
												oni.material.Diffuse= col
												)
									)
							)
					) catch ()
			)
			
	on cp_after changed col do with undo off animate off
		(
			try 
				(
					for i=11 to 20 do 
						(
							local expr="onions_arr_"+(i as string)
							local arr=(execute expr)
							arr.wirecolor=col
							for oni in arr do 
								(
									if SanLightTable.ch_shaded.checked==true then 
										(
											oni.material.selfIllumColor = col
											) else 
											(
												oni.material.Diffuse= col
												)
									)
							)
					) catch ()
			)
	

	on ch_before changed state do with undo off animate off
		(
			fn_lock_before ()
			fn_recreate_onions_with_new_parametres ()
			)
			
	on ch_after changed state do with undo off animate off
		(
			fn_lock_after ()
			fn_recreate_onions_with_new_parametres ()
			)

	on ckb1 changed state do with undo off animate off
		(
			fn_onions_hide 1 state
			redrawViews()
			)
			
	on ckb2 changed state do with undo off animate off
		(
			fn_onions_hide 2 state
			redrawViews()
			)
			
	on ckb3 changed state do with undo off animate off
		(
			fn_onions_hide 3 state
			redrawViews()
			)
			
	on ckb4 changed state do with undo off animate off
		(
			fn_onions_hide 4 state
			redrawViews()
			)
			
	on ckb5 changed state do with undo off animate off
		(
			fn_onions_hide 5 state
			redrawViews()
			)
			
	on ckb6 changed state do with undo off animate off
		(
			fn_onions_hide 6 state
			redrawViews()
			)
			
	on ckb7 changed state do with undo off animate off
		(
			fn_onions_hide 7 state
			redrawViews()
			)
			
	on ckb8 changed state do with undo off animate off
		(
			fn_onions_hide 8 state
			redrawViews()
			)
			
	on ckb9 changed state do with undo off animate off
		(
			fn_onions_hide 9 state
			redrawViews()
			)
			
	on ckb10 changed state do with undo off animate off
		(
			fn_onions_hide 10 state
			redrawViews()
			)
			
	on ckb11 changed state do with undo off animate off
		(
			fn_onions_hide 11 state
			redrawViews()
			)
			
	on ckb12 changed state do with undo off animate off
		(
			fn_onions_hide 12 state
			redrawViews()
			)
			
	on ckb13 changed state do with undo off animate off
		(
			fn_onions_hide 13 state
			redrawViews()
			)
			
	on ckb14 changed state do with undo off animate off
		(
			fn_onions_hide 14 state
			redrawViews()
			)
			
	on ckb15 changed state do with undo off animate off
		(
			fn_onions_hide 15 state
			redrawViews()
			)
			
	on ckb16 changed state do with undo off animate off
		(
			fn_onions_hide 16 state
			redrawViews()
			)
			
	on ckb17 changed state do with undo off animate off
		(
			fn_onions_hide 17 state
			redrawViews()
			)
			
	on ckb18 changed state do with undo off animate off
		(
			fn_onions_hide 18 state
			redrawViews()
			)
			
	on ckb19 changed state do with undo off animate off
		(
			fn_onions_hide 19 state
			redrawViews()
			)
			
	on ckb20 changed state do with undo off animate off
		(
			fn_onions_hide 20 state
			redrawViews()
			)
			
----------------------------------------------------------
		
	on pb1 clicked val do with undo off animate off
	(
		fn_onions_val 1 val pb_all.value
		)
	on pb2 clicked val do with undo off animate off
	(
		fn_onions_val 2 val pb_all.value
		)
	on pb3 clicked val do with undo off animate off
	(
		fn_onions_val 3 val pb_all.value
		)
	on pb4 clicked val do with undo off animate off
	(
		fn_onions_val 4 val pb_all.value
		)
	on pb5 clicked val do with undo off animate off
	(
		fn_onions_val 5 val pb_all.value
		)
	on pb6 clicked val do with undo off animate off
	(
		fn_onions_val 6 val pb_all.value
		)
	on pb7 clicked val do with undo off animate off
	(
		fn_onions_val 7 val pb_all.value
		)
	on pb8 clicked val do with undo off animate off
	(
		fn_onions_val 8 val pb_all.value
		)
	on pb9 clicked val do with undo off animate off
	(
		fn_onions_val 9 val pb_all.value
		)
	on pb10 clicked val do with undo off animate off
	(
		fn_onions_val 10 val pb_all.value
		)
	on pb11 clicked val do with undo off animate off
	(
		fn_onions_val 11 val pb_all.value
		)
	on pb12 clicked val do with undo off animate off
	(
		fn_onions_val 12 val pb_all.value
		)
	on pb13 clicked val do with undo off animate off
	(
		fn_onions_val 13 val pb_all.value
		)
	on pb14 clicked val do with undo off animate off
	(
		fn_onions_val 14 val pb_all.value
		)
	on pb15 clicked val do with undo off animate off
	(
		fn_onions_val 15 val pb_all.value
		)
	on pb16 clicked val do with undo off animate off
	(
		fn_onions_val 16 val pb_all.value
		)
	on pb17 clicked val do with undo off animate off
	(
		fn_onions_val 17 val pb_all.value
		)
	on pb18 clicked val do with undo off animate off
	(
		fn_onions_val 18 val pb_all.value
		)
	on pb19 clicked val do with undo off animate off
	(
		fn_onions_val 19 val pb_all.value
		)
	on pb20 clicked val do with undo off animate off
	(
		fn_onions_val 20 val pb_all.value
		)
	on pb_all clicked val do with undo off animate off
	(
		pb_all.value=val
		fn_onions_all_val val
		)
		
	on bt_add pressed do with undo off animate off
		(
			if selection.count!=0 do 
				(
					local temp_arr=#()
					--check for group
					for g=1 to selection.count do 
						(
							if (isGroupHead selection[g])!=true do 
								(
									appendifunique temp_arr selection[g]
									)
							)
-- 					local temp_arr=selection as array
							
					if keyboard.controlpressed==true do 
						(
							join temp_arr onion_obj_arr
							temp_arr=makeuniquearray temp_arr
							)
							
					if temp_arr.count!=0 do 
						(
							ch_onion_enable.caption="启用重影"
							ch_onion_enable.checked=true
									
							----------clear arrays
							try 
								(
									for i=1 to 20 do 
										(
											local expr="onions_arr_"+(i as string)
											local arr=(execute expr)
											delete arr
											)
									) catch ()
							onions_arr_1=#()
							onions_arr_2=#()
							onions_arr_3=#()
							onions_arr_4=#()
							onions_arr_5=#()
							onions_arr_6=#()
							onions_arr_7=#()
							onions_arr_8=#()
							onions_arr_9=#()
							onions_arr_10=#()
							onions_arr_11=#()
							onions_arr_12=#()
							onions_arr_13=#()
							onions_arr_14=#()
							onions_arr_15=#()
							onions_arr_16=#()
							onions_arr_17=#()
							onions_arr_18=#()
							onions_arr_19=#()
							onions_arr_20=#()
							onion_obj_arr=#()
							------------end clear arrays
							onion_obj_arr=temp_arr
							
							for oni_numb=1 to 20 do 
								(
									local expr_hide="SanLightTable.ckb"+(oni_numb as string)+".checked"
									if (execute expr_hide)!=false do 
										(
											fn_onions_create oni_numb
											)
									)
							redrawViews()
							)
					)
			)
			
	on bt_add rightclick do with undo on
		(
			if onion_obj_arr!=undefined and onion_obj_arr!=#() do 
				(
					deselect objects
					select onion_obj_arr
					)
			)
			
	on ch_onion_enable changed state do with undo off animate off
	(
		if state==false then 
			(
				ch_onion_enable.caption="禁用重影"
				ch_onion_enable.checked=false
				try 
					(
						for i=1 to 20 do 
							(
								local expr_arr="onions_arr_"+(i as string)
								local arr=(execute expr_arr)
								delete arr
								(execute (expr_arr+"=#()"))
								)
						if SanLightTable_layer.current==true do 
							(
								SanLightTable_layer_0.current=true
								)
						LayerManager.deleteLayerByName "0 (LightTable_ghosts)"
						) catch ()--messagebox ("Error 246sd\n------------log:-----------\n"+(getCurrentException())))
				) else 
				(
					fn_clean_array ()
					ch_onion_enable.caption="启用重影"
					ch_onion_enable.checked=true
					try 
						(
							for i=1 to 20 do 
								(
									local expr_hide="SanLightTable.ckb"+(i as string)+".checked"
									if (execute expr_hide)!=false do 
										(
											fn_onions_create i
											)
									)
							) catch (messagebox ("Error \n------------log:-----------\n"+(getCurrentException())))
					)
		redrawViews()
		)
		
	on ch_shaded changed state do with undo off animate off
		(
			fn_recreate_onions_with_new_parametres ()
			)
		
	on ch_alpha changed state do with undo off animate off
		(
			fn_recreate_onions_with_new_parametres ()
			)
)

	fn_SanLightTable_dialog_pos SanLightTable_ini
	clearListener()
	createdialog SanLightTable style: #(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox) pos:SanLightTable_dialog_pos
)