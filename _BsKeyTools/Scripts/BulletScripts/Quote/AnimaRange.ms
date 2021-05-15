-------------------------------------------------AnimaRange----------------------------------------------
------------------------------------------------------------
--Tool for set scene ranges
--
--scripted by San_oOo 
--http://cargocollective.com/San-oOo
-------------------------------------------------------------

--v 0_9 (19.07.2014) added ctrl+click function for load multiplay range
-- 						fix that animarange_small not closed when large open again
--						id_ranges typed in help
--						added shift+help - launch ini
-- v 1_0 (27.08.2014) fix bug when export objects with instanced transform
--                           variables ex_path renamed to AnimaRange_ex_path
--v 1_1 (30.08.2014) new function - range from selected keys (fn_animarange_selkeys) when ctrl+click on "Get Range" button
--                          tooltips
--                          dialogs closed propperly
--                          text based export path line
--                          slider time = spn_start or spn_end when autoset is checked true
--v 1_2 (07.09.2014) main listbox converted to MultiListBox.
--                          on lbx_ranges selected rewrited to on selectionEnd
--                          multiselection range function adopted to MultiListBox
--                          update function adopted to MultiListBox
--                          export functions adopted to MultiListBox
--                          new button in main rollout - sort by length
--                          fix color on export progress bar (pb)
--v 1_3 (10.09.2014) fixed words in menus
--                          added buttons open dir, scene path in export dialog
--                          added save last load mode option in settings
--					   fn_data_saver was changed (beta) commented lines
--                          browse now will opens text area path
--v 1_4 (17.09.2014) fixed update button bug when none is selected
--                          fixed bug when ctrl+click on get range and no keyframes are selected
--                          fixed bug when start and end bracket buttons wants to set zero length range
--                          added message to delete button
--v 1_5 (20.09.2014) auto reopen dialog with new ranges when dialog was opened and new scene was loaded
--v 1_6 (22.09.2014) new gui
--                           sort gui
--                           fix delete all bug (ctrl+press not work properly)
--                           fix auto reopen function - now load path too
--v 1_7 ()
--v 1_8 (18.05.2015) added example in writer
--v 1_9 (29.07.2015) added condition to select range - if anim playing, then stop,change range, play anim.
--v 1_9_1 (24.01.2016) added catch expressions for the loading ini and the main dialog opening to checking errors

(
--variables
global load_in_small=1
global doubleClick=1
global save_last=true
	
global AnimaRange_ver="v 1_9_1"
global AnimaRange
global AnimaRange_small
global AnimaRange_help
global AnimaRange_Writer
global AnimaRange_ini = getDir #plugcfg + "\AnimaRange.ini"
global id_ranges=-81259732468513268
global id_path=-9125973246851326

global arr_ranges=#()
global writer_text=""
global ch=0
global data_found=false
global full_range
global text_correct=0
global AnimaRange_pos=[mouse.screenpos[1],mouse.screenpos[2]]

global AnimaRange_reloader_message=
"
try(destroyDialog AnimaRange) catch ()
try(destroyDialog AnimaRange_small) catch ()
if load_in_small!=2 then 
(
	createdialog AnimaRange pos:AnimaRange_pos
) else 
(
	createdialog AnimaRange_small pos:AnimaRange_pos
)
"


--variables for export to fbx
global AnimaRange_ex_path
global s=""
global che=0
global anim_arr_exp=#()
global col=#((color 191 0 0), (color 180 20 0), (color 169 41 0), (color 159 62 0), (color 148 82 0), (color 138 103 0), (color 127 124 0), (color 117 144 0), (color 106 165 0), (color 96 186 0))
global bake=true
global separ="_"
global animarange_key_arr=#()
--functions

fn fn_animarange_selkeys = 
(
animarange_key_arr=#()

struct adder
	(
		fn map t = 
			(
				append animarange_key_arr t
				return t
				)
		)

if selection.count!=0 do 
	(
		for i in selection do 
			(
				mapKeys i (adder ()) #selection
				)
		sort animarange_key_arr
		
		if animarange_key_arr.count==0 then 
			(
				selectKeys selection
				for i in selection do 
					(
						mapKeys i (adder ()) #selection
						)
				sort animarange_key_arr
				) 
		if animarange_key_arr.count!=0 do
		(
			if animarange_key_arr[1]!=animarange_key_arr[animarange_key_arr.count] then 
				(
-- 					animationRange = interval animarange_key_arr[1] animarange_key_arr[animarange_key_arr.count]
					return [animarange_key_arr[1],animarange_key_arr[animarange_key_arr.count]]
-- 					messagebox ""
					) else 
					(
-- 						animationRange = interval animarange_key_arr[1] (animarange_key_arr[animarange_key_arr.count]+1)
						return [animarange_key_arr[1], (animarange_key_arr[animarange_key_arr.count]+1)]
						)
			)

		)
	)

fn fn_load_ini = 
	(
		try 
			(
				if doesFileExist (AnimaRange_ini) == false then 
				(
					setIniSetting AnimaRange_ini "Settings" "small" (load_in_small as string)
					setIniSetting AnimaRange_ini "Settings" "save_last" (save_last as string)
					setIniSetting AnimaRange_ini "Settings" "dclck" (doubleClick as string)
					setIniSetting AnimaRange_ini "Settings" "bake" (bake as string)
					setIniSetting AnimaRange_ini "Settings" "separ" (separ as string)
		-- 			print "file created"
					) else 
					(
		-- 				print "file exist"
						doubleClick=getIniSetting AnimaRange_ini "Settings" "dclck" as integer
						save_last=getIniSetting AnimaRange_ini "Settings" "save_last"
						if save_last=="true" then 
							(
								save_last=true
								) else 
								(
									save_last=false
									)
						load_in_small=getIniSetting AnimaRange_ini "Settings" "small" as integer
						bake=getIniSetting AnimaRange_ini "Settings" "bake"
						if bake=="true" then 
							(
								bake=true
								) else 
								(
									bake=false
									)
						separ=getIniSetting AnimaRange_ini "Settings" "separ"
						local temp_dialog_pos=filterstring (getIniSetting animarange_ini "settings" "dialog_pos") "??"
						if temp_dialog_pos!= undefined then 
							(
								global AnimaRange_pos=[(temp_dialog_pos[1] as float), (temp_dialog_pos[2] as float)]
								) else 
								(
									global AnimaRange_pos=[80, 150]
									)
						
						)
				) catch (messagebox ("加载 ini 文件错误\n------------log:-----------\n"+(getCurrentException())))
		)
	
fn fn_text_check txt = 
	(
		ch=0
		local k=1
		if (mod txt.count 3)==0 then 
			(
				for i=1 to (txt.count/3) do 
					(
						if (txt[k+1] as integer)==undefined or (txt[k+2] as integer)==undefined then 
							(
								messagebox "错误！数字不是整数。\n--------------\n像这样输入范围 -\nRun 15 30\nIdle_wait 78 150"
								ch=1
								exit
								) else 
								(
									if (txt[k+1] as integer)>=(txt[k+2] as integer) then 
										(
											messagebox "错误！起始帧不能大于或等于最后一帧"
											ch=1
											exit
											) else 
											(
												k+=3
												)
									)
						)
				) else 
				(
					messagebox "错误！您漏掉了空格或数字。\n--------------\n像这样输入范围 -\nRun 15 30\nIdle_wait 78 150"
					ch=1
					)
		)

fn fn_full_range dialog arr = 
	(
		if arr.count!=0 then
			(
				local numbers_arr=#()
				local k=1
				for i in arr do 
					(
						temp_arr=filterstring i " []"
						append numbers_arr (temp_arr[k+1] as integer)
						append numbers_arr (temp_arr[k+3] as integer)
						)
				sort numbers_arr
				full_range="完整范围 ["+(numbers_arr[1] as string)+" - "+(numbers_arr[numbers_arr.count] as string)+"]"
				) else 
				(
					full_range="完整范围 [0 - 100]"
					)
		try (dialog.bt_full.caption=full_range) catch ()
		)

fn fn_data_finder = 
	(
		if ((getAppData rootnode id_ranges)!=undefined) then 
			(
				data_found=true
-- 				messagebox "welcome to AnimaRange!"
				) else 
				(
-- 					messagebox "you don't have saved AnimaRange data in scene"
					data_found=false
					)
		)
	
fn fn_data_saver arr= 
	(
-- 		fn_data_finder ()
-- 		if data_found==false do 
-- 			(
-- 				setAppData rootnode id_ranges ""
-- 				data_found=true
-- 				)
-- 		setAppData rootnode id_ranges ""
		
		setAppData rootnode id_ranges ""
		data_found=true
		
		if arr.count!=0 then 
			(
				local temp=""
				for i in arr do 
					(
						temp+=i+"\n"
						)
				setAppData rootnode id_ranges temp
				) else 
				(
					deleteAppData rootnode id_ranges
					data_found=false
					)


		)
		
fn fn_data_loader dialog = 
	(
		if data_found==true and (getAppData rootnode id_ranges)!="" do
			(
				local temp_arr=filterstring (getAppData rootnode id_ranges) "
				"
				if 
					(
						for i in temp_arr do 
						(
							local temp_numb=filterstring i " []"
							if temp_numb[1]!=undefined and ((temp_numb[2] as string) as integer)!=undefined and ((temp_numb[4] as string) as integer)!=undefined and ((temp_numb[4] as string) as integer)>((temp_numb[2] as string) as integer) then 
							(
									
							) else 
							(
								exit
							)
						)
						) != undefined then 
						(
							dialog.lbx_ranges.items=temp_arr
-- 								fn_full_range dialog dialog.lbx_ranges.items
						) else 
						(
							messagebox "加载 AnimaRange_data 时出错，请参阅说明并查找错误           "
						)
				) 
		)
		

fn fn_name_test txt = 
	(
		text_correct=1
		local symbols=" []"
		if txt=="" then 
			(
				messagebox "错误！命名为空"
				text_correct=0
				) else 
				(
					for i=1 to txt.count do 
						(
							if 
								(
									for k=1 to symbols.count do 
										(
											if txt[i]==symbols[k] then 
												(
													messagebox "错误！命名不正确"
													text_correct=0
													exit
													)
											)
									) == undefined do 
										(
											exit
											)
							)
					)
		)
		
fn fn_update_button dialog = 
	(
------------------fn_update_button AnimaRange lbx_ranges.items lbx_ranges.selection txt_name.text spn_start.value spn_end.value
		
		local arr=dialog.lbx_ranges.items
		fn_name_test dialog.txt_name.text
		local arr_sel=#()
		for i in dialog.lbx_ranges.selection do 
			(
				append arr_sel i
				)
				
		if arr_sel.count>1 then 
			(
				messagebox "无法更新多个范围\r\n仅能选择一个范围          "
				) else 
				(
					if text_correct==1 and arr.count!=0 and arr_sel.count!=0 do 
						(
							local upd_range=dialog.txt_name.text+" ["+(dialog.spn_start.value as string)+" - "+(dialog.spn_end.value as string)+"]"
							arr[arr_sel[1]]=upd_range
							dialog.lbx_ranges.items=arr
							fn_data_saver arr
							fn_full_range dialog arr
							)
					)
		)
		
fn fn_sort dialog arr state = 
	(
		local temp_arr=#()
		if arr.count!=0 do 
			(
				if state==3 or state==5 then 
					(
						clearListener()
						arr_ranges=#()
						local arr_biggest=#()
						local ctrl=0
						if state==5 do 
							(
								ctrl=1
								)
						for a=1 to arr.count do 
							(
								try 
									(
										arr_biggest=#()
										for i in arr do 
											(
												local temper=filterstring i " []"
												append arr_biggest (abs ((temper[4] as integer)-(temper[2] as integer)))
												)
										
-- 										print ("a="+(a as string))
-- 										print ("arr_biggest="+(arr_biggest as string))
												
										local arr_biggest_sorted=#()
										local param
										if ctrl==0 then 
											(
												param=(amin arr_biggest)
												) else 
												(
													param=(amax arr_biggest)
													)
										local r_param=finditem arr_biggest param
													
-- 										print ("r_param="+(r_param as string))
													
										append arr_ranges arr[r_param]
										deleteItem arr r_param
													
-- 										print "arr_ranges="
-- 										print arr_ranges
-- 										print "----------------------------"
										) catch ()
								)
						) else 
						(
							for i in arr do 
								(
									local temper=filterstring i " []"
									if (temper[state] as integer)==undefined then 
										(
											append temp_arr temper[state]
											) else 
											(
												append temp_arr (temper[state] as integer)
												)
									
									)
							sort temp_arr
							arr_ranges=#()
							for i in temp_arr do 
								(
									for k in arr do 
										(
											local temper=filterstring k " []"
											if (i as string)==temper[state] do 
												(
													appendifunique arr_ranges k
													)
											)
									)
							)

-- 				print arr_ranges
				dialog.lbx_ranges.items=arr_ranges
				dialog.lbx_ranges.selection=0
				fn_data_saver arr_ranges
				)
		)
		
--functions export to fbx
		
	fn fn_check= 
	(
		che=0
		if anim_arr_exp.count==0 then 
			(
				messagebox "请选择动画范围"
				) else 
				(
					if AnimaRange_ex_path==undefined or AnimaRange_ex_path=="" then 
						(
							messagebox "请选择导出路径"
							) else 
							(
								if doesFileExist (getFilenamePath AnimaRange_ex_path)==false then 
									(
										messagebox "路径不存在"
										) else 
										(
											if selection.count==0 then 
												(
													messagebox "请选择要导出的对象"
													) else 
													(
														che=1
														)
											)
								)
					)
		)
		
	fn fn_export range_arr pb separ bake = 
		(
			pb.value=0
			pb_plus=100/range_arr.count
			for i in 1 to range_arr.count do 
				(
					if keyboard.escPressed==true do (exit)
					local str=filterstring range_arr[i] " []"
					local anim_start=str[2] as integer
					local anim_end=str[4] as integer

					if selection.count!=0 do with undo on
						(
							anim_range=anim_end-anim_start
							deselectKeys objects
							selectKeys objects (anim_start-10000000) (anim_start-1)
							selectKeys objects (anim_end+10000000) (anim_end+1)
							deleteKeys objects #selection 
							selectKeys objects anim_start anim_end
							-----------
							local arr_all=objects as array
							for i=1 to arr_all.count do 
								(
									try 
										(
											for a=1 to arr_all.count do 
												(
													if arr_all[a]!=arr_all[i] do 
														(
															if arr_all[i].transform.controller==arr_all[a].transform.controller do 
																(
																	deleteItem arr_all a
																	)
															)
													)
											) catch 
											(
												
												)
									)
							----------
							movekeys arr_all -anim_start #selection
							animationRange = interval 0 anim_range
							)
					-----------export-----------

					if bake.checked==true then 
						(
							FbxExporterSetParam "BakeAnimation" true
							FBXExporterSetParam "BakeFrameStart" animationRange.start
							FBXExporterSetParam "BakeFrameEnd" animationRange.end
							) else 
							(
								FbxExporterSetParam "BakeAnimation" false
								)

					FbxExporterSetParam "Animation" true
-- 					FbxExporterSetParam "FileVersion" "FBX201000"
					AnimaRange_ex_path=(getFilenamePath AnimaRange_ex_path)+(getFilenamefile AnimaRange_ex_path)
					AnimaRange_export_path=(AnimaRange_ex_path + separ.text + str[1] +".fbx")
					exportFile AnimaRange_export_path #noPrompt  selectedOnly:true
					------------------------------
					max undo
					animationRange = interval anim_start anim_end
								
					if i==range_arr.count then 
						(
							pb.value=100
							pb.color=col[col.count]
							messagebox "导出过程完成！！！"
							) else 
							(
								pb.value+=pb_plus
								)
					pb.color=col[((pb.value/10) as integer)]
					)
			)
		
fn fn_animarange_scene_reloaded dialog = 
	(
		fn_data_finder ()
		fn_data_loader AnimaRange
		fn_full_range AnimaRange AnimaRange.lbx_ranges.items
		)
		
		
		
		
-------------------Main Rollaut-----------------
	
try(destroyDialog AnimaRange) catch ()
try(destroyDialog AnimaRange_small) catch ()
rollout AnimaRange ("AnimaRange "+AnimaRange_ver) width:248 height:264
(
	button bt_help "?" pos:[1,1] width:15 height:15 toolTip:"点击 = 帮助
Ctrl+点击 = 打开 INI 配置文件目录
Shift+点击 = 打开 INI 配置文件"
	button bt_small "极简模式" pos:[16,0] width:56 height:16 toolTip:"极简 模式"
-- 	button bt_test "Ping" pos:[16,16] width:56
	
	MultiListBox lbx_ranges "" pos:[8,48] width:232 height:14
	button bt_full "完整范围 [0 - 100]" pos:[8,236] width:232 height:24
	
	button bt_write "写入" pos:[128,24] width:56 height:24 toolTip:"手动输入动画分段"
	checkbutton bt_edit "编辑 >" pos:[184,24] width:56 height:24 toolTip:"打开编辑工具箱"
	
	edittext txt_name "命名:" pos:[248,24] width:192 height:16
	spinner spn_start "" pos:[280,48] width:64 height:16 range:[-1e+007,1e+007,0] type:#integer
	spinner spn_end "" pos:[344,48] width:64 height:16 range:[-1e+007,1e+007,100] type:#integer
	button bt_start_in "[" pos:[248,48] width:32 height:16 toolTip:"从滑块位置获取开始动画范围"
	button bt_end_out "]" pos:[408,48] width:32 height:16 toolTip:"从滑块位置获取结束动画范围"
	
	button bt_get "获取帧栏范围" pos:[248,72] width:192 height:24 toolTip:"从帧栏范围获取参数 "
	button bt_set "帧栏设置" pos:[248,120] width:96 height:16 toolTip:"将帧栏范围设置为此参数"
	checkbutton bt_auto_set "自动设置" pos:[344,120] width:96 height:16 toolTip:"自动将帧栏范围设置为此参数"
-- 	checkbox bt_auto_set "auto" pos:[400,96] width:96 height:16 toolTip:"Automaticly sets scene range to this parametres"
	
	button bt_add "添加" pos:[248,144] width:64 height:56 toolTip:"添加新的范围"
	button bt_upd "更新" pos:[312,144] width:64 height:40 toolTip:"更新所选范围（命名和帧数）"
	checkbutton bt_auto_upd "自动更新" pos:[312,184] width:64 height:16 toolTip:"自动更新所选范围（命名和帧数）"
-- 	checkbox bt_auto_upd "auto" pos:[400,168] width:96 height:16 toolTip:"Auto updates selected range (name and numbers)"
	
-- 	GroupBox grp_sort "Sort ranges by:" pos:[472,168] width:96 height:72
-- 	button bt_sort_name "name" pos:[472,56] width:40 height:16
-- 	button bt_sort_length "length" pos:[472,72] width:40 height:16 toolTip:"click = sort from MIN to MAX
-- ctrl+click = sort from MAX to MIN"
-- 	button bt_sort_start "start frame" pos:[512,56] width:80 height:16
-- 	button bt_sort_end "end frame" pos:[512,72] width:80 height:16
	
	button bt_del "删除" pos:[376,144] width:64 height:56 toolTip:"点击 = 删除所选范围（无法撤消）
Ctrl+点击 = 删除所有范围（无法撤消）"
	checkbutton bt_exporter "导出为FBX" pos:[248,236] width:192 height:24 toolTip:"打开导出为FBX工具箱"


	GroupBox gr_save "保存为:" pos:[8,264] width:432 height:88
	button bt_browse "浏览" pos:[328,315] width:104 height:30 toolTip:"浏览目录"
	edittext lbl_path "" pos:[16,295] width:416 height:16
	button bt_scene_path "场景路径" pos:[248,272] width:184 height:20 toolTip:"使用场景路径"
	button bt_open_dir "打开目录" pos:[248,315] width:80 height:30 toolTip:"打开这个目录"
	
	GroupBox grp7 "设定值:" pos:[8,352] width:432 height:40
	label lbl_file "<文件名>" pos:[16,368] width:56 height:16
	edittext txt_separ "" pos:[72,368] width:24 height:16
	label lbl_an "<动作名>.fbx" pos:[100,368] width:88 height:16
	checkbox ch_bake "烘焙 动画" pos:[344,368] width:80 height:16 checked:true
	progressBar pb "" pos:[200,400] width:240 height:40
	button bt_all "所有" pos:[8,400] width:88 height:40 toolTip:"导出所有动画范围"
	button bt_sel "仅选择" pos:[104,400] width:88 height:40 toolTip:"导出选定的动画范围"
	

	button bt_get_sel_keys "从所选帧中获取" pos:[248,96] width:192 height:24 toolTip:"获取对象选定关键帧的范围"
	button bt_sort "列表排序" pos:[248,206] width:192 height:24	

-- ) createdialog AnimaRange	
	
	on bt_test pressed do 
		(
			fn_animarange_scene_reloaded AnimaRange
			)
	
	on AnimaRange open do 
		(
			try 
				(
					txt_name.text="idle"
					fn_data_finder ()
					fn_data_loader AnimaRange
					fn_full_range AnimaRange AnimaRange.lbx_ranges.items
					
					txt_separ.text=separ
					ch_bake.checked=bake
					pb.value=0
					pb.color=col[10]
					if (getAppData rootnode id_path)!=undefined then 
						(
							lbl_path.text=(getAppData rootnode id_path)
							AnimaRange_ex_path=lbl_path.text
							) else 
							(
								if maxFilePath!="" do 
									(
										s=filterstring maxFileName "."
										lbl_path.text=maxFilePath+s[1]
										AnimaRange_ex_path=lbl_path.text
										setAppData rootnode id_path lbl_path.text
										)
								)
							
					if load_in_small==3 do 
						(
							bt_edit.checked=true
							AnimaRange.width=448
							)
							
					if load_in_small==4 do 
						(
							bt_edit.checked=true
							bt_exporter.checked=true
							AnimaRange.width=448
							AnimaRange.height=448
							)
							
					callbacks.addScript #filePostOpenProcess AnimaRange_reloader_message id:#AnimaRange_reloader
					) catch (messagebox ("打开对话框时出错 \n------------log:-----------\n"+(getCurrentException())))
			)
			
	on AnimaRange close do 
		(
			setIniSetting AnimaRange_ini "settings" "dialog_pos" ((AnimaRange_pos[1] as string)+"??"+(AnimaRange_pos[2] as string))
			setAppData rootnode id_path lbl_path.text
			try 
				(
					destroydialog AnimaRange_writer
					destroydialog AnimaRange_help
					) catch 
					(
						
						)
			if save_last==true do 
				(
					if bt_edit.checked==false then 
						(
							setIniSetting AnimaRange_ini "Settings" "small" "1"
							) else 
							(
								if bt_exporter.checked==false then 
									(
										setIniSetting AnimaRange_ini "Settings" "small" "3"
										) else 
										(
											setIniSetting AnimaRange_ini "Settings" "small" "4"
											)
								)
					)
			callbacks.RemoveScripts #filePostOpenProcess id:#AnimaRange_reloader
			)
			
	on AnimaRange moved p do 
		(
			AnimaRange_pos=[p[1],p[2]]
			)
	
	on bt_help pressed do 
		(
			if keyboard.controlpressed==true then 
							(
								shelllaunch (getDir #plugcfg) ""
								) else 
								(
									if keyboard.shiftpressed==true then 
										(
											shelllaunch (AnimaRange_ini) "" 
											) else 
											(
rollout AnimaRange_help "AnimaRange 帮助和设置" width:440 height:328
(
	GroupBox grp6 "帮助" pos:[8,0] width:224 height:320
	GroupBox grp8 "关于" pos:[240,254] width:192 height:66
	GroupBox grp10 "设置" pos:[240,0] width:192 height:128
	radiobuttons rdo_small "加载方式:" pos:[248,16] width:154 height:46 labels:#("完整", "精简", "完整 (编辑)", "完整 (导出)") columns:2
	checkbox ch_save_last "保存上一个模式 " pos:[248,64] width:104 height:16
	label lbl16 "应用范围通过:" pos:[248,88] width:160 height:16
	radiobuttons rdo_dclck "" pos:[248,104] width:154 height:16 labels:#("单击", "双击") columns:2
	label lblMod "Modified_by_Bullet.S" pos:[248,302] width:120 height:16
	label lbl17 "script by San_oOo" pos:[248,270] width:88 height:16
	HyperLink myEmail "http://cargocollective.com/San-oOo" pos:[248,285] width:176 height:15 color:(color 0 0 255) hovercolor:(color 0 0 190) visitedcolor:(color 190 0 0) address:"http://cargocollective.com/San-oOo"
	label lbl19 "AnimaRange" pos:[88,16] width:64 height:16
	label lbl20 "用于场景中保存和加载动画范围的工具" pos:[16,32] width:209 height:32
	label lbl21 "入门：" pos:[16,64] width:80 height:16
	label lbl22 "按“写入”并输入范围，例如以下示例：" pos:[32,80] width:168 height:32
	label lbl23 "idle 0 50 walk_to_run 60 80 T_pose -10 -5" pos:[32,112] width:96 height:40
	label lbl24 "AnimaRange会将其转换为范围并自动计算整个范围：" pos:[32,160] width:192 height:40
	label lbl25 "idle [0 - 50] walk_to_run [60 - 80] T_pose [-10 - -5] FULL_Range [-10 - 80]" pos:[32,200] width:112 height:56
	label lbl26 "编辑:" pos:[16,265] width:48 height:16
	label lbl27 "您可在“写入”模式或 “编辑 >” 工具箱中编辑范围。" pos:[32,288] width:192 height:30
	GroupBox grp12 "重要:" pos:[240,128] width:192 height:118
	label lbl28 "工具使用 “SetAppData rootnode” 功能将信息保存在场景中" pos:[248,144] width:180 height:32
	label lbl29 "id_ranges=-81259732468513268" pos:[248,184] width:176 height:16
	label lbl30 "id_path=-9125973246851326" pos:[248,200] width:176 height:16
	
-- )createdialog AnimaRange_help
	
	on AnimaRange_help open do 
		(
			fn_load_ini ()
			rdo_small.state=load_in_small
			rdo_dclck.state=doubleClick
			ch_save_last.checked=save_last
			if ch_save_last.checked==true then 
				(
					rdo_small. enabled=false
					) else 
					(
						rdo_small. enabled=true
						)
			)
	
	on rdo_small changed stat do 
		(
			setIniSetting AnimaRange_ini "Settings" "small" (stat as string)
			load_in_small=stat
			)
	
	on ch_save_last changed stat do 
		(
			setIniSetting AnimaRange_ini "Settings" "save_last" (stat as string)
			save_last=stat
			if stat==true then 
				(
					rdo_small. enabled=false
					) else 
					(
						rdo_small. enabled=true
						)
			)
			
	on rdo_dclck changed stat do 
		(
			setIniSetting AnimaRange_ini "Settings" "dclck" (stat as string)
			doubleClick=stat
			)
			
			
) 
createdialog AnimaRange_help
												)
									)
			
			)

	on bt_small pressed do 
		(
			if save_last==true do 
				(
					setIniSetting AnimaRange_ini "Settings" "small" (2 as string)
					load_in_small=2
					)
			createdialog AnimaRange_small pos:animarange_pos
			try(destroydialog AnimaRange)catch()
			callbacks.RemoveScripts #filePostOpenProcess id:#AnimaRange_reloader
			callbacks.addScript #filePostOpenProcess AnimaRange_reloader_message id:#AnimaRange_reloader
			)
			
	on bt_edit changed state do
	(
		if state==true then 
			(
				AnimaRange.width=448
				if bt_exporter.checked==true then 
					(
						AnimaRange.height=448
						) else 
						(
							AnimaRange.height=264
							)
				) else 
				(
					AnimaRange.width=248
					AnimaRange.height=264
					)
		)
		
	on bt_exporter changed state do
	(
		if state==true then 
			(
				AnimaRange.height=448
				) else 
				(
					AnimaRange.height=264
					)
		)
		
	on bt_load pressed do
	(
		fn_data_finder ()
		fn_data_loader AnimaRange
		fn_full_range AnimaRange AnimaRange.lbx_ranges.items
		)
		
	on bt_write pressed do 
		(
			writer_text=""
			for i in lbx_ranges.items do 
				(
					local temp_arr=filterstring i " []"
					writer_text+=temp_arr[1]+" "+temp_arr[2]+" "+temp_arr[4]+"\n"
					)
			rollout AnimaRange_Writer "写入范围" width:304 height:328
				(
					edittext txt_ranges "" pos:[0,8] width:224 height:248
					button bt_done "完成" pos:[5,256] width:219 height:40
					button bt_export "导出 (txt)" pos:[115,296] width:109 height:24
					button bt_import "导入 (txt)" pos:[5,296] width:110 height:24
					label lbl_example "例如:      _______      idle 0 100    run 110 125   hit_1 130 150   hit_2 155 178" pos:[232,8] width:72 height:80
-- 					) createdialog AnimaRange_Writer
					
					on AnimaRange_Writer open do 
						(
							txt_ranges.text=writer_text
							)
							
					on bt_done pressed do 
						(
							local temp_arr=filterstring txt_ranges.text " 
							"
							fn_text_check (temp_arr)
									
							if ch!=1 do 
								(
									arr_ranges=#()
									local k=1
									for i=1 to (temp_arr.count/3) do 
										(
											local ranger=temp_arr[k]+" ["+temp_arr[k+1]+" - "+temp_arr[k+2]+"]"
											append arr_ranges ranger
											k+=3
											)
									fn_full_range AnimaRange arr_ranges
									AnimaRange.lbx_ranges.items=arr_ranges
									AnimaRange.lbx_ranges.selection=1
									fn_data_saver arr_ranges
									destroyDialog AnimaRange_Writer
									)
									
							)
					
					on bt_import pressed do 
						(
							local loadedFile = getOpenFileName caption:"Open text file:" types:"Text file (*.txt)|*.txt|" 
							if loadedFile != undefined and (getFilenameType loadedFile) == ".txt" do 
								(
									local texter=""
									text_in = openFile loadedFile
									while NOT eof text_in do 
									(
										texter+= readLine text_in
										texter+="\n"
										)
									print texter
									txt_ranges.text=texter
									)
							)
							
					on bt_export pressed do 
						(
							local savedFile = (getSaveFileName caption:"Save ranges to txt:" types:"Text file (*.txt)|*.txt|")
							if savedFile != undefined do
								(
									local txtFile = openFile savedFile mode:"w"
									format "%\n" txt_ranges.text to:txtFile
									close txtFile
									ShellLaunch savedFile ""
									)
							)
					
					)
			createdialog AnimaRange_Writer
			)
			
	on lbx_ranges doubleClicked sel do 
		(
			if doubleClick==2 do 
				(
					local temp_arr=filterstring lbx_ranges.items[sel] " []"
					if keyboard.controlpressed == true then 
						(
							local temp_arr_ranges=#()
							append temp_arr_ranges (temp_arr[2] as integer)
							append temp_arr_ranges (temp_arr[4] as integer)
							append temp_arr_ranges ((animationrange.start as string) as integer)
							append temp_arr_ranges ((animationrange.end as string) as integer)
							sort temp_arr_ranges
							animationRange = interval (temp_arr_ranges[1] as time) (temp_arr_ranges[temp_arr_ranges.count] as time)
							slidertime = animationRange.start
							) else 
							(
								animationRange = interval (temp_arr[2] as time) (temp_arr[4] as time)
								slidertime = animationRange.start
								)
					)
			)
			
	on lbx_ranges selectionEnd do 
		(
-- 			messagebox "1"
			local arr_frames=#()
			local temp_arr=#()
			local arr_ranges_names=#()
			for i in lbx_ranges.selection do 
				(
					temp_arr=filterstring lbx_ranges.items[i] " []"
					append arr_ranges_names temp_arr[1]
					append arr_frames (temp_arr[2] as integer)
					append arr_frames (temp_arr[4] as integer)
					)
			sort arr_frames
-- 			print arr_ranges_names
-- 			print "-----------"
			if doubleClick==1 or bt_auto_set.checked==true do 
				(
					local che=0
					if isAnimPlaying()==true do 
						(
-- 							messagebox "2"
							stopAnimation()
							che=1
							)
					animationRange = interval (arr_frames[1] as time) (arr_frames[arr_frames.count] as time)
					slidertime = animationRange.start
					if che==1 do 
						(
							playAnimation immediateReturn:true
							)
					)
			if arr_frames.count>2 then 
				(
					txt_name.text=arr_ranges_names[1]+"-"+arr_ranges_names[arr_ranges_names.count]
					) else 
					(
						txt_name.text=arr_ranges_names[1]
						)
			spn_start.value=arr_frames[1]
			spn_end.value=arr_frames[arr_frames.count]
			)
		
	on bt_full pressed do 
		(
			local temp_arr=filterstring bt_full.caption " []"
			animationRange = interval (temp_arr[2] as time) (temp_arr[4] as time)
			slidertime = animationRange.start
			lbx_ranges.selection=0
			)

	on txt_name entered tex do 
		(
			if bt_auto_upd.checked==true do 
				(
					fn_update_button AnimaRange
					)
			)
			
	on spn_start changed val do 
		(
			if val>=spn_end.value do 
				(
					spn_end.value=val+1
					)
			if bt_auto_set.checked==true do 
				(
					animationRange = interval (spn_start.value as time) (spn_end.value as time)
					sliderTime = spn_start.value
					)
			if bt_auto_upd.checked==true do 
				(
					fn_update_button AnimaRange
					)
			)
			
	on spn_end changed val do 
		(
			if val<=spn_start.value do 
				(
					spn_start.value=val-1
					)
			if bt_auto_set.checked==true do 
				(
					animationRange = interval (spn_start.value as time) (spn_end.value as time)
					sliderTime = spn_end.value
					)
			if bt_auto_upd.checked==true do 
				(
					fn_update_button AnimaRange
					)
			)
			
	on bt_start_in pressed do 
		(
			local val=sliderTime
			spn_start.value=val
			if val>=spn_end.value do 
				(
					spn_end.value=val+1
					)
			if bt_auto_set.checked==true do 
				(
					if spn_start.value!=animationRange.end then 
						(
							animationRange = interval (spn_start.value as time) (animationRange.end)
							) else 
							(
								animationRange = interval (spn_start.value as time) (animationRange.end+1)
								)
					)
			if bt_auto_upd.checked==true do 
				(
					fn_update_button AnimaRange
					)
			)
			
	on bt_end_out pressed do 
		(
			local val=sliderTime
			spn_end.value=val
			if val<=spn_start.value do 
				(
					spn_start.value=val-1
					)
			if bt_auto_set.checked==true do 
				(
					if animationRange.start!=spn_end.value then 
						(
							animationRange = interval (animationRange.start) (spn_end.value as time)
							) else 
							(
								animationRange = interval (animationRange.start-1) (spn_end.value as time)
								)
					)
			if bt_auto_upd.checked==true do 
				(
					fn_update_button AnimaRange
					)
			)
			
	on bt_get pressed do 
		(
			spn_start.value=animationrange.start
			spn_end.value=animationrange.end
			if bt_auto_upd.checked==true do 
				(
					fn_update_button AnimaRange
					)
			)
			
	on bt_get_sel_keys pressed do 
		(
			local a = (fn_animarange_selkeys ())
-- 					print a
			if a!=undefined then 
				(
					spn_start.value=a[1]
					spn_end.value=a[2]
					if bt_auto_set.checked==true do 
						(
							animationRange = interval spn_start.value spn_end.value
							)
					) else 
					(
						messagebox "选择关键帧!      "
						)
			)
			
	on bt_set pressed do 
		(
			animationRange = interval (spn_start.value as time) (spn_end.value as time)
			slidertime = animationRange.start
			)
			
	on bt_add pressed do 
		(
			fn_name_test txt_name.text
			if text_correct==1 do 
				(
					arr_ranges=lbx_ranges.items
					local temp=txt_name.text+" ["+(spn_start.value as string)+" - "+(spn_end.value as string)+"]"
					appendifunique arr_ranges temp
					lbx_ranges.items=arr_ranges
					fn_data_saver arr_ranges
					fn_full_range AnimaRange arr_ranges
					)
			)
			
	on bt_upd pressed do 
		(
			fn_update_button AnimaRange
			)
			
	on bt_sort pressed do 
		(
			rcMenu animarange_sort_menu
			(
				menuItem bt_sort_name "按 命名"
				menuItem bt_sort_length_min "按 长度 (从 最小)"
				menuItem bt_sort_length_max "按 长度 (从 最大)"
				menuItem bt_sort_start "按开始帧"
				menuItem bt_sort_end "按结束帧"
				
				on bt_sort_name picked do 
					(
						fn_sort AnimaRange lbx_ranges.items 1
						)
						
				on bt_sort_length_min picked do 
					(
						fn_sort AnimaRange lbx_ranges.items 3
						)
						
				on bt_sort_length_max picked do 
					(
						fn_sort AnimaRange lbx_ranges.items 5
						)
						
				on bt_sort_start picked do 
					(
						fn_sort AnimaRange lbx_ranges.items 2
						)
						
				on bt_sort_end picked do 
					(
						fn_sort AnimaRange lbx_ranges.items 4
						)

				)
			popUpMenu animarange_sort_menu rollout:animarange
			)
			
	on bt_del pressed do
		(
			if lbx_ranges.items.count!=0 do 
				(
					local kbd_ctrl=0
					if keyboard.controlpressed == true do 
						(
							kbd_ctrl=1
							)
					
					local ranges_sel=0
					for i in lbx_ranges.selection do 
						(
							ranges_sel=i
							)
					
					local messager=""
					if kbd_ctrl==1 then 
						(
							messager="所有范围?"
							) else 
							(
								if ranges_sel!=0 do 
									(
										messager="所选范围?"
										)
								)
					if messager!="" do 
						(
							if querybox ("是否确认删除 "+messager) title:"AnimaRange" == true do 
								(
									arr_ranges=lbx_ranges.items
									local cc=undefined
									if kbd_ctrl==1 then 
										(
											arr_ranges=#()
											) else 
											(
												local arr_delete=#()
												for i in lbx_ranges.selection do 
													(
														if cc==undefined do 
															(
																cc=i
																)
														append arr_delete lbx_ranges.items[i]
														)
												for i=1 to arr_delete.count do 
													(
														deleteItem arr_ranges (finditem arr_ranges arr_delete[i])
														)
												)
									if cc!=undefined do 
										(
											if cc-1==0 then 
												(
													lbx_ranges.selection=1
													) else 
													(
														lbx_ranges.selection=cc-1
														)
											)
									
									lbx_ranges.items=arr_ranges
									fn_data_saver arr_ranges
									fn_full_range AnimaRange arr_ranges
									)
							)
					)
			)
			
	on bt_browse pressed do 
	(
		local pather = ""
		if doesFileExist (getFilenamePath lbl_path.text)==true do 
			(
				pather = getFilenamePath lbl_path.text
				)
		savedFile = getSaveFileName caption:"Save file:" types:"FBX (*.fbx)" filename:pather 
		if savedFile != undefined then lbl_path.text=savedFile as string
		AnimaRange_ex_path=lbl_path.text
		setAppData rootnode id_path lbl_path.text
-- 		print (getFilenameFile savedFile)
		)
		
	on bt_scene_path pressed  do
		(
			if maxFilePath!="" do 
				(
					s=filterstring maxFileName "."
					lbl_path.text=maxFilePath+s[1]
					)
			)
			
	on bt_open_dir pressed  do 
		(
			local a=getFilenamePath lbl_path.text
			if (doesFileExist a)==true do 
				(
					ShellLaunch a ""
					)
			)
		
	on ch_bake changed state do 
	(
		bake=state
		setIniSetting AnimaRange_ini "Settings" "bake" (bake as string)
		)
		
	on txt_separ entered txt do 
	(
		separ=txt
		setIniSetting AnimaRange_ini "Settings" "separ" (separ as string)
		)
			
	on bt_all pressed do 
	(
		anim_arr_exp=lbx_ranges.items

		AnimaRange_ex_path=lbl_path.text
		fn_check ()
		if che==1 do 
			(
				AnimaRange_ex_path=lbl_path.text
				fn_export anim_arr_exp pb txt_separ ch_bake
				)
		)
		
	on bt_sel pressed do 
		(
			anim_arr_exp=#()
			for i in lbx_ranges.selection do 
				(
					append anim_arr_exp lbx_ranges.items[i]
					)

			AnimaRange_ex_path=lbl_path.text
			fn_check ()
			if che==1 do 
				(
					fn_export anim_arr_exp pb txt_separ ch_bake
					)
			)

)

rollout AnimaRange_small ("AnimaRange_small "+AnimaRange_ver) width:248 height:56
(
	button bt_large "完整模式" pos:[8,0] width:56 height:16 tooltip:"完整 模式"
	dropDownList lbx_ranges "" pos:[8,24] width:232 height:21
-- )createdialog AnimaRange_small
	
	on AnimaRange_small open do 
		(
			fn_data_finder ()
			fn_data_loader AnimaRange_small
			fn_full_range AnimaRange_small AnimaRange_small.lbx_ranges.items
			lbx_ranges.items = (append lbx_ranges.items full_range)
			callbacks.addScript #filePostOpenProcess AnimaRange_reloader_message id:#AnimaRange_reloader
			)

	on AnimaRange_small close do 
		(
			setIniSetting AnimaRange_ini "settings" "dialog_pos" ((AnimaRange_pos[1] as string)+"??"+(AnimaRange_pos[2] as string))
			if save_last==true do 
				(
					setIniSetting AnimaRange_ini "Settings" "small" "2"
					)
			callbacks.RemoveScripts #filePostOpenProcess id:#AnimaRange_reloader
			)
			
	on AnimaRange_small moved p do 
		(
			AnimaRange_pos=[p[1],p[2]]
			)
			
	on bt_large pressed do 
		(

			if save_last==true do 
				(
					setIniSetting AnimaRange_ini "Settings" "small" (1 as string)
					load_in_small=1
					)
			createdialog AnimaRange pos:animarange_pos
			try(destroydialog AnimaRange_small)catch()
			callbacks.RemoveScripts #filePostOpenProcess id:#AnimaRange_reloader
			callbacks.addScript #filePostOpenProcess AnimaRange_reloader_message id:#AnimaRange_reloader
			)
			
	on lbx_ranges selected sel do 
		(
			local temp_arr=filterstring lbx_ranges.items[sel] " []"
			animationRange = interval (temp_arr[2] as time) (temp_arr[4] as time)
			slidertime = animationRange.start
			)
			
			
			
	)

fn_load_ini()
if load_in_small!=2 then 
	(
		createdialog AnimaRange pos:AnimaRange_pos
		) else 
		(
			createdialog AnimaRange_small pos:AnimaRange_pos
			)

)