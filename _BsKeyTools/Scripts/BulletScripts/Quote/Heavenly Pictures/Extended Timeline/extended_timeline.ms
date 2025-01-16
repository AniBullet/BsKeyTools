--( CLOSE IF RUN
	try (destroydialog hpxtl_menupanel) catch ()
	try (destroydialog hpxtl_rollout_settings) catch ()
	try (destroydialog hpxtl_rollout_changelog) catch ()
	try (destroydialog hpxtl_rollout_about) catch ()
	try (cui.UnRegisterDialogBar hpxtl_rollout) catch ()
	try (destroydialog hpxtl_rollout) catch ()
	try (animationRange = interval hpxtl_animation_start hpxtl_animation_end) catch ()
	try (callbacks.removeScripts #filePostOpenProcess id:#hpxtlchanimrange) catch ()
	try (callbacks.removeScripts #filePreSave id:#hpxtloriganimrange) catch ()
	try (callbacks.removeScripts #filePostSave id:#hpxtlrestanimrange) catch ()
--)

--( VARIABLES
	hpxtl_scriptpath = getfilenamepath (getSourceFileName())
	hpxtl_animation_start = int(animationRange.start)
	hpxtl_animation_end = int(animationRange.end)
	hpxtl_animation_zoom_start = int(animationRange.start)
	hpxtl_animation_zoom_end = int(animationRange.end)
	hpxtl_bitmap_alpha
	hpxtl_bitmap_slider1
	hpxtl_bitmap_slider2
	hpxtl_bitmap_range
	hpxtl_bitmap_range_center
	hpxtl_bitmap_trackbar
	hpxtl_bitmap_trackbar_side
	hpxtl_bitmap_settings
	hpxtl_bitmap_preset_active
	hpxtl_bitmap_preset_inactive
	hpxtl_bitmap_preset_invalid
	hpxtl_bitmap_keyframes
	hpxtl_data_slider1_pos
	hpxtl_data_slider2_pos
	hpxtl_data_mouse_pos
	hpxtl_data_slider_width
	hpxtl_data_settings_width
	hpxtl_buttons_width
	hpxtl_data_trackbar_side_width
	hpxtl_data_range_center_width
	hpxtl_data_keyframes_width
	hpxtl_control_slider1
	hpxtl_control_slider2
	hpxtl_control_range
	hpxtl_control_range_center
	hpxtl_control_trackbar
	hpxtl_control_trackbar_side_right
	hpxtl_control_settings
	hpxtl_control_preset_1
	hpxtl_control_preset_2
	hpxtl_control_preset_3
	hpxtl_control_preset_4
	hpxtl_control_preset_5
	hpxtl_control_keyframes
	hpxtl_control_settings
	hpxtl_menupanel
	hpxtl_controls_general = #()
	hpxtl_controls_control = #()
	hpxtl_controls_skin = #()
	hpxtl_controls_version = #()
	hpxtl_scroll
	hpxtl_scroll_normal
	hpxtl_scroll_less
	hpxtl_scroll_more
	hpxtl_skin_background_end
	hpxtl_available_skins = #()
	hpxtl_skin
	hpxtl_skin_number
	hpxtl_skin_creator
	hpxtl_inifile
	hpxtl_middle_button = false
	hpxtl_middle_button_pos
	hpxtl_middle_button_width
	hpxtl_slider1_stored_pos = int(animationRange.start)
	hpxtl_slider2_stored_pos = int(animationRange.end)
	hpxtl_last_timestamp = 0
	hpxtl_fps = 25
	hpxtl_zoom_pivot
	hpxtl_data_preset_width
	hpxtl_number_of_presets
	hpxtl_presets
	hpxtl_presets_width
	hpxtl_preset_old_image
	hpxtl_inner_spinners
	hpxtl_control_tooltip
	hpxtl_interval_array_start = #()
	hpxtl_interval_array_end = #()
	hpxtl_interval_start
	hpxtl_interval_end
	function hpxtl_add_skin = ()
	function hpxtl_resize_interface = ()
	function hpxtl_read_presets = ()
	function hpxtl_change_animation_range = ()
	rollout hpxtl_rollout "" ( )
--)
--( INI
	hpxtl_inifile = hpxtl_scriptpath + "extended_timeline_Mod.ini"
	hpxtl_scroll_normal = getinisetting hpxtl_inifile "control" "scroll_normal" as integer
	hpxtl_scroll_more = getinisetting hpxtl_inifile "control" "scroll_more" as integer
	hpxtl_scroll_less = getinisetting hpxtl_inifile "control" "scroll_less" as integer
	hpxtl_scroll = hpxtl_scroll_normal
--)		

--( FUNCTIONS
	--( SETTINGS FUNCTION
		function hpxtl_settings_click = (
			if (hpxtl_menupanel.isdisplayed == false) then (
				hpxtl_rollout_pos = getdialogpos hpxtl_rollout
				createdialog hpxtl_menupanel 75 100 (hpxtl_rollout_pos[1] + hpxtl_rollout.width - 74) (hpxtl_rollout_pos[2] - 102) style:#(#style_sysmenu)
			) else (
				destroydialog hpxtl_menupanel
			)
		)
	--)
	--( EXIT
		function hpxtl_exit = (
			try (destroydialog hpxtl_menupanel) catch ()
			try (destroydialog hpxtl_rollout_settings) catch ()
			try (destroydialog hpxtl_rollout_changelog) catch ()
			try (destroydialog hpxtl_rollout_about) catch ()
			cui.UnRegisterDialogBar hpxtl_rollout
			destroydialog hpxtl_rollout
			animationRange = interval hpxtl_animation_start hpxtl_animation_end
			callbacks.removeScripts #filePostOpenProcess id:#hpxtlchanimrange
			callbacks.removeScripts #filePostOpenProcess id:#hpxtlreadpresetsopen
			callbacks.removeScripts #systemPostNew id:#hpxtlreadpresetsnew
			callbacks.removeScripts #systemPostReset id:#hpxtlreadpresetsreset
		)
	--)
	--( UPDATE
		function hpxtl_update_script = (
			if dragAndDrop.isEnabled() == false then (
				draganddrop.globalenabledraganddrop true
			)
			dragAndDrop.DownloadUrlToDisk "http://www.heavenlypictures.hu/maxscript/extendedtimeline/download_update.php?id=8765231225" ((getdir #temp)+"\\extendedtimeline_updater.mzp") 0
			if (doesfileexist ((getdir #temp)+"\\extendedtimeline_updater.mzp")) == true then (
				dragAndDrop.dropPackage 0 [0,0] ((getdir #temp)+"\\extendedtimeline_updater.mzp")
			) else (
				messagebox "Can't download the new version! Please download the latest version from www.heavenlypictures.hu" title:"Extended Timeline"
			)
		)
	--)
	--( SLIDER 1 FUNCTIONS
		function hpxtl_setrange_1 = (
			hpxtl_animation_zoom_start = int((hpxtl_rollout.hpxtl_control_lastframe.value - hpxtl_rollout.hpxtl_control_firstframe.value) * ((hpxtl_control_slider1.location.x - 1.0) / (hpxtl_rollout.hpxtl_form.width - (hpxtl_data_slider_width * 2)))) + hpxtl_rollout.hpxtl_control_firstframe.value
			if (hpxtl_animation_zoom_start > (hpxtl_animation_zoom_end - 1)) then hpxtl_animation_zoom_start = hpxtl_animation_zoom_end - 1
			animationRange = interval hpxtl_animation_zoom_start hpxtl_animation_zoom_end
			hpxtl_rollout.hpxtl_control_zoom_firstframe.value = hpxtl_animation_zoom_start
			setAppData rootNode 98068471 (hpxtl_animation_zoom_start as string)
		)
		function hpxtl_slider1_mousemove = (
			if (timestamp() > (hpxtl_last_timestamp + hpxtl_fps)) then (
				hpxtl_newpos = hpxtl_data_slider1_pos + (mouse.pos.x - hpxtl_data_mouse_pos)
				case of (
					(hpxtl_newpos < 1): hpxtl_newpos = 1
					(hpxtl_newpos > (hpxtl_control_slider2.location.x - hpxtl_data_slider_width)): hpxtl_newpos = hpxtl_control_slider2.location.x - hpxtl_data_slider_width
				)
				if (hpxtl_newpos != hpxtl_control_slider1.location.x) then (
					hpxtl_control_slider1.location.x = hpxtl_newpos
					hpxtl_control_range.width = hpxtl_control_slider2.location.x - (hpxtl_newpos + hpxtl_data_slider_width)
					hpxtl_control_range.location.x = hpxtl_newpos + hpxtl_data_slider_width
					hpxtl_control_range_center.location.x = hpxtl_control_range.location.x + (int(hpxtl_control_range.width / 2)) - 3
					hpxtl_setrange_1()
				)
			hpxtl_last_timestamp = timestamp()
			)
		)
		function hpxtl_slider1_mouseup arg = (
			dotNet.removeEventHandler hpxtl_control_slider1 "mousemove" hpxtl_slider1_mousemove
			dotNet.removeEventHandler hpxtl_control_slider1 "mouseup" hpxtl_slider1_mouseup
		)
		function hpxtl_slider1_mousedown arg = (
			if (arg.button == arg.button.left) then (
				hpxtl_data_slider1_pos = hpxtl_control_slider1.location.x
				hpxtl_data_mouse_pos = mouse.pos.x
				dotNet.addEventHandler hpxtl_control_slider1 "mouseup" hpxtl_slider1_mouseup
				dotNet.addEventHandler hpxtl_control_slider1 "mousemove" hpxtl_slider1_mousemove
			)
			hpxtl_last_timestamp = timestamp()
		)
	--)
	--( SLIDER 2 FUNCTIONS
		function hpxtl_setrange_2 = (
			hpxtl_animation_zoom_end = int((hpxtl_rollout.hpxtl_control_lastframe.value - hpxtl_rollout.hpxtl_control_firstframe.value) * ((hpxtl_control_slider2.location.x - hpxtl_data_slider_width + 1.0) / (hpxtl_rollout.hpxtl_form.width - (hpxtl_data_slider_width * 2)))) + hpxtl_rollout.hpxtl_control_firstframe.value
			if (hpxtl_animation_zoom_end < (hpxtl_animation_zoom_start + 1)) then hpxtl_animation_zoom_end = hpxtl_animation_zoom_start + 1
			animationRange = interval hpxtl_animation_zoom_start hpxtl_animation_zoom_end
			hpxtl_rollout.hpxtl_control_zoom_lastframe.value = hpxtl_animation_zoom_end
			setAppData rootNode 98068472 (hpxtl_animation_zoom_end as string)
		)
		function hpxtl_slider2_mousemove = (
			if (timestamp() > (hpxtl_last_timestamp + hpxtl_fps)) then (
				hpxtl_newpos = hpxtl_data_slider2_pos + (mouse.pos.x - hpxtl_data_mouse_pos)
				case of (
					(hpxtl_newpos < (hpxtl_control_slider1.location.x + hpxtl_data_slider_width)): hpxtl_newpos = hpxtl_control_slider1.location.x + hpxtl_data_slider_width
					(hpxtl_newpos > (hpxtl_rollout.hpxtl_form.width - hpxtl_data_slider_width - 1)): hpxtl_newpos = hpxtl_rollout.hpxtl_form.width - hpxtl_data_slider_width - 1
				)
				if (hpxtl_newpos != hpxtl_control_slider2.location.x) then (
					hpxtl_control_slider2.location.x = hpxtl_newpos
					hpxtl_control_range.width = hpxtl_newpos - (hpxtl_control_slider1.location.x + hpxtl_data_slider_width)
					hpxtl_control_range_center.location.x = hpxtl_control_range.location.x + (int(hpxtl_control_range.width / 2)) - 3
					hpxtl_setrange_2()
				)
				hpxtl_last_timestamp = timestamp()
			)
		)
		function hpxtl_slider2_mouseup arg = (
			dotNet.removeEventHandler hpxtl_control_slider2 "mousemove" hpxtl_slider2_mousemove
			dotNet.removeEventHandler hpxtl_control_slider2 "mouseup" hpxtl_slider2_mouseup
		)
		function hpxtl_slider2_mousedown arg = (
			if (arg.button == arg.button.left) then (
				hpxtl_data_slider2_pos = hpxtl_control_slider2.location.x
				hpxtl_data_mouse_pos = mouse.pos.x
				dotNet.addEventHandler hpxtl_control_slider2 "mouseup" hpxtl_slider2_mouseup
				dotNet.addEventHandler hpxtl_control_slider2 "mousemove" hpxtl_slider2_mousemove
			)
			hpxtl_last_timestamp = timestamp()
		)
	--)
	--( RANGE FUNCTIONS
		function hpxtl_setrange_3 = (
			hpxtl_animation_zoom_start = int((hpxtl_rollout.hpxtl_control_lastframe.value - hpxtl_rollout.hpxtl_control_firstframe.value) * ((hpxtl_control_slider1.location.x - 1.0) / (hpxtl_rollout.hpxtl_form.width - (hpxtl_data_slider_width * 2)))) + hpxtl_rollout.hpxtl_control_firstframe.value
			hpxtl_animation_zoom_end = int((hpxtl_rollout.hpxtl_control_lastframe.value - hpxtl_rollout.hpxtl_control_firstframe.value) * ((hpxtl_control_slider2.location.x - hpxtl_data_slider_width + 1.0) / (hpxtl_rollout.hpxtl_form.width - (hpxtl_data_slider_width * 2)))) + hpxtl_rollout.hpxtl_control_firstframe.value
			if (hpxtl_animation_zoom_end < (hpxtl_animation_zoom_start + 1)) then hpxtl_animation_zoom_end = hpxtl_animation_zoom_start + 1
			animationRange = interval hpxtl_animation_zoom_start hpxtl_animation_zoom_end
			hpxtl_rollout.hpxtl_control_zoom_firstframe.value = hpxtl_animation_zoom_start
			hpxtl_rollout.hpxtl_control_zoom_lastframe.value = hpxtl_animation_zoom_end
			setAppData rootNode 98068471 (hpxtl_animation_zoom_start as string)
			setAppData rootNode 98068472 (hpxtl_animation_zoom_end as string)
		)
		function hpxtl_range_zoom hpxtl_slider1_newpos hpxtl_slider2_newpos hpxtl_local_zoom_pivot = (
			case of (
				(hpxtl_slider1_newpos < 1): hpxtl_slider1_newpos = 1
				(hpxtl_slider1_newpos > (hpxtl_local_zoom_pivot - hpxtl_data_slider_width)): hpxtl_slider1_newpos = hpxtl_local_zoom_pivot - hpxtl_data_slider_width
			)
			case of (
				(hpxtl_slider2_newpos > (hpxtl_rollout.hpxtl_form.width - hpxtl_data_slider_width - 1)): hpxtl_slider2_newpos = hpxtl_rollout.hpxtl_form.width - hpxtl_data_slider_width - 1
				(hpxtl_slider2_newpos < hpxtl_local_zoom_pivot): hpxtl_slider2_newpos = hpxtl_local_zoom_pivot
			)
			if ((hpxtl_control_slider1.location.x != hpxtl_slider1_newpos) or (hpxtl_control_slider2.location.x != hpxtl_slider2_newpos)) then (
				hpxtl_control_range.width = hpxtl_slider2_newpos - (hpxtl_slider1_newpos + hpxtl_data_slider_width)
				hpxtl_control_range.location.x = hpxtl_slider1_newpos + hpxtl_data_slider_width
				hpxtl_control_range_center.location.x = hpxtl_control_range.location.x + (int(hpxtl_control_range.width / 2)) - 3
				hpxtl_control_slider1.location.x = hpxtl_slider1_newpos
				hpxtl_control_slider2.location.x = hpxtl_slider2_newpos
				hpxtl_setrange_3()
			)
		)
		function hpxtl_range_mousemove = (
			if (timestamp() > (hpxtl_last_timestamp + hpxtl_fps)) then (
				if (hpxtl_middle_button == true) then (
					hpxtl_zoomfactor_1 = int(hpxtl_middle_button_pos * (hpxtl_scroll * (hpxtl_data_mouse_pos - mouse.pos.x) / 20.0 / 100.0))
					hpxtl_zoomfactor_2 = int((hpxtl_middle_button_width - hpxtl_middle_button_pos) * (hpxtl_scroll * (hpxtl_data_mouse_pos - mouse.pos.x) / 20.0 / 100.0))
					if (((hpxtl_data_slider1_pos + hpxtl_zoomfactor_1) != hpxtl_control_slider1.location.x) or ((hpxtl_data_slider2_pos - hpxtl_zoomfactor_2) != hpxtl_control_slider2.location.x)) then (
						hpxtl_range_zoom (hpxtl_data_slider1_pos + hpxtl_zoomfactor_1) (hpxtl_data_slider2_pos - hpxtl_zoomfactor_2) hpxtl_zoom_pivot
					)
				) else (
					hpxtl_newpos = hpxtl_data_slider1_pos + (mouse.pos.x - hpxtl_data_mouse_pos)
					hpxtl_newpos2 = hpxtl_data_slider1_pos + (hpxtl_data_slider_width * 2) + hpxtl_control_range.width + (mouse.pos.x - hpxtl_data_mouse_pos)
					if (hpxtl_newpos < 1) then (
						hpxtl_newpos = 1
					)
					if (hpxtl_newpos2 > (hpxtl_rollout.hpxtl_form.width - 1)) then (
						hpxtl_newpos = hpxtl_rollout.hpxtl_form.width - (1 + (hpxtl_data_slider_width * 2) + hpxtl_control_range.width)
					)
					if (hpxtl_control_slider1.location.x != hpxtl_newpos) then (
						hpxtl_newpos2 = 1 + (hpxtl_data_slider_width * 2) + hpxtl_control_range.width
						hpxtl_control_slider1.location.x = hpxtl_newpos
						hpxtl_control_slider2.location.x = hpxtl_newpos + hpxtl_data_slider_width + hpxtl_control_range.width
						hpxtl_control_range.location.x = hpxtl_newpos + hpxtl_data_slider_width
						hpxtl_control_range_center.location.x = hpxtl_control_range.location.x + (int(hpxtl_control_range.width / 2)) - 3
						hpxtl_setrange_3()
					)
				)
				hpxtl_last_timestamp = timestamp()
			)
		)
		function hpxtl_range_doubleclick arg = (
			if (arg.button == arg.button.left) then (
				if ((hpxtl_animation_start == int(animationRange.start)) and (hpxtl_animation_end == int(animationRange.end))) then (
					hpxtl_range_zoom hpxtl_slider1_stored_pos hpxtl_slider2_stored_pos ((hpxtl_slider2_stored_pos - hpxtl_slider1_stored_pos - 7) / 2 + hpxtl_slider1_stored_pos + 7)
					setAppData rootNode 98068471 (hpxtl_animation_zoom_start as string)
					setAppData rootNode 98068472 (hpxtl_animation_zoom_end as string)
				) else (
					hpxtl_slider1_stored_pos = hpxtl_control_slider1.location.x
					hpxtl_slider2_stored_pos = hpxtl_control_slider2.location.x
					hpxtl_control_slider1.location.x = 1
					hpxtl_control_slider2.location.x = hpxtl_rollout.hpxtl_form.width - (1 + hpxtl_data_slider_width)
					hpxtl_control_range.location.x = 1 + hpxtl_data_slider_width
					hpxtl_control_range.width = hpxtl_rollout.hpxtl_form.width - (hpxtl_data_slider_width * 2) - 2
					hpxtl_control_range_center.location.x = hpxtl_control_range.location.x + (int(hpxtl_control_range.width / 2)) - 3
					hpxtl_animation_zoom_start = hpxtl_animation_start
					hpxtl_animation_zoom_end = hpxtl_animation_end
					animationRange = interval hpxtl_animation_start hpxtl_animation_end
					hpxtl_rollout.hpxtl_control_zoom_firstframe.value = hpxtl_animation_zoom_start
					hpxtl_rollout.hpxtl_control_zoom_lastframe.value = hpxtl_animation_zoom_end
					setAppData rootNode 98068471 (hpxtl_animation_zoom_start as string)
					setAppData rootNode 98068472 (hpxtl_animation_zoom_end as string)
				)
			)
		)
		function hpxtl_range_mousewheel sender arg = (
			if (sender == hpxtl_control_range_center) then (
				hpxtl_zoomfactor_1 = int(hpxtl_control_range.width * (hpxtl_scroll / 200.0))
				hpxtl_zoomfactor_2 = int(hpxtl_control_range.width * (hpxtl_scroll / 200.0))
				hpxtl_zoom_pivot = (hpxtl_control_range.width / 2) + hpxtl_control_range.location.x
			) else (
				hpxtl_zoomfactor_1 = int(arg.x * (hpxtl_scroll / 100.0))
				hpxtl_zoomfactor_2 = int((hpxtl_control_range.width - arg.x) * (hpxtl_scroll / 100.0))
				hpxtl_zoom_pivot = arg.x + hpxtl_control_range.location.x
			)
			if arg.delta > 0 then (
				hpxtl_range_zoom (hpxtl_control_slider1.location.x + hpxtl_zoomfactor_1) (hpxtl_control_slider2.location.x - hpxtl_zoomfactor_2) hpxtl_zoom_pivot
			) else (
				hpxtl_range_zoom (hpxtl_control_slider1.location.x - hpxtl_zoomfactor_1) (hpxtl_control_slider2.location.x + hpxtl_zoomfactor_2) hpxtl_zoom_pivot
			)
		)
		function hpxtl_range_mouseup arg = (
			if (arg.button == arg.button.middle) then (
				hpxtl_middle_button = false
				dotNet.removeEventHandler hpxtl_control_range "mousemove" hpxtl_range_mousemove
				dotNet.removeEventHandler hpxtl_control_range "mouseup" hpxtl_range_mouseup
			)
			if (arg.button == arg.button.left) then (
				dotNet.removeEventHandler hpxtl_control_range "mousemove" hpxtl_range_mousemove
				dotNet.removeEventHandler hpxtl_control_range "mouseup" hpxtl_range_mouseup
				hpxtl_middle_button = false
			)
		)
		function hpxtl_range_mousedown arg = (
			if (arg.button == arg.button.middle) then (
				hpxtl_middle_button = true
				hpxtl_middle_button_pos = arg.x
				hpxtl_zoom_pivot = hpxtl_control_range.location.x + arg.x
				hpxtl_middle_button_width = hpxtl_control_range.width
				dotNet.addEventHandler hpxtl_control_range "mouseup" hpxtl_range_mouseup
			)
			if (arg.button == arg.button.left) then (
				hpxtl_data_slider1_pos = hpxtl_control_slider1.location.x
				hpxtl_data_slider2_pos = hpxtl_control_slider2.location.x
				hpxtl_data_mouse_pos = mouse.pos.x
				dotNet.addEventHandler hpxtl_control_range "mouseup" hpxtl_range_mouseup
				dotNet.addEventHandler hpxtl_control_range "mousemove" hpxtl_range_mousemove
			)
			hpxtl_last_timestamp = timestamp()
		)
		function hpxtl_range_keyup = (
			hpxtl_scroll = hpxtl_scroll_normal
		)
		function hpxtl_range_keydown arg = (
			if (arg.shift == true) then (
				hpxtl_scroll = hpxtl_scroll_less
			) else (
				if (arg.control == true) then (
					hpxtl_scroll = hpxtl_scroll_more
				)
			)
		)
		function hpxtl_range_mouseleave = (
			dotNet.removeEventHandler hpxtl_control_range "mousemove" hpxtl_range_mousemove
			dotNet.removeEventHandler hpxtl_control_range "mousewheel" hpxtl_range_mousewheel
			dotNet.removeEventHandler hpxtl_control_range "mousedown" hpxtl_range_mousedown
			dotNet.removeEventHandler hpxtl_control_range "doubleclick" hpxtl_range_doubleclick
			dotNet.removeEventHandler hpxtl_control_range "keydown" hpxtl_range_keydown
			dotNet.removeEventHandler hpxtl_control_range "keyup" hpxtl_range_keyup
			dotNet.removeEventHandler hpxtl_control_range "mouseup" hpxtl_range_mouseup
			dotNet.removeEventHandler hpxtl_control_range "mouseleave" hpxtl_range_mouseleave
			hpxtl_scroll = hpxtl_scroll_normal
		)
		function hpxtl_range_mouseenter = (
			dotNet.addEventHandler hpxtl_control_range "mousedown" hpxtl_range_mousedown
			dotNet.addEventHandler hpxtl_control_range "mousewheel" hpxtl_range_mousewheel
			dotNet.addEventHandler hpxtl_control_range "mouseleave" hpxtl_range_mouseleave
			dotNet.addEventHandler hpxtl_control_range "doubleclick" hpxtl_range_doubleclick
			dotNet.addEventHandler hpxtl_control_range "keydown" hpxtl_range_keydown
			dotNet.addEventHandler hpxtl_control_range "keyup" hpxtl_range_keyup
			hpxtl_control_range.focus()
			hpxtl_last_timestamp = timestamp()
		)
	--)
	--( RANGE REVERSE FUNCTIONS
		function hpxtl_setrange_reverse = (
			hpxtl_newpos = int((hpxtl_rollout.hpxtl_form.width - (hpxtl_data_slider_width * 2)) * ((hpxtl_animation_zoom_start - hpxtl_animation_start) / (hpxtl_animation_end - hpxtl_animation_start + 0.0))) + 1
			hpxtl_newpos2 = int((hpxtl_rollout.hpxtl_form.width - (hpxtl_data_slider_width * 2)) * ((hpxtl_animation_zoom_end - hpxtl_animation_start) / (hpxtl_animation_end - hpxtl_animation_start + 0.0))) + (hpxtl_data_slider_width - 1)
			if (hpxtl_newpos2 < (hpxtl_newpos + hpxtl_data_slider_width)) then (
				hpxtl_newpos2 = hpxtl_newpos + hpxtl_data_slider_width
			)
			if (hpxtl_newpos < 1) then (
				hpxtl_newpos = 1
				if (hpxtl_newpos2 < (hpxtl_newpos + hpxtl_data_slider_width)) then (
					hpxtl_newpos2 = hpxtl_newpos + hpxtl_data_slider_width
				)
			)
			if (hpxtl_newpos2 > (hpxtl_rollout.hpxtl_form.width - 1)) then (
				hpxtl_newpos2 = hpxtl_rollout.hpxtl_form.width - hpxtl_data_slider_width
				if (hpxtl_newpos2 < (hpxtl_newpos + hpxtl_data_slider_width)) then (
					hpxtl_newpos = hpxtl_newpos2 - hpxtl_data_slider_width
				)
			)
			hpxtl_control_slider1.location.x = hpxtl_newpos
			hpxtl_control_slider2.location.x = hpxtl_newpos2
			hpxtl_control_range.width = hpxtl_newpos2 - hpxtl_newpos - hpxtl_data_slider_width
			hpxtl_control_range.location.x = hpxtl_newpos + hpxtl_data_slider_width
			hpxtl_control_range_center.location.x = hpxtl_control_range.location.x + (int(hpxtl_control_range.width / 2)) - 3
		)
	--)
	--( RANGE CENTER FUNCTIONS
		function hpxtl_range_center_mouseup arg = (
			if (arg.button == arg.button.middle) then (
				dotNet.removeEventHandler hpxtl_control_range_center "mousemove" hpxtl_range_mousemove
				dotNet.removeEventHandler hpxtl_control_range_center "mouseup" hpxtl_range_center_mouseup
				hpxtl_middle_button = false
			)
			if (arg.button == arg.button.left) then (
				hpxtl_middle_button = false
				dotNet.removeEventHandler hpxtl_control_range_center "mousemove" hpxtl_range_mousemove
				dotNet.removeEventHandler hpxtl_control_range_center "mouseup" hpxtl_range_center_mouseup
			)
		)
		function hpxtl_range_center_mousedown arg = (
			if (arg.button == arg.button.middle) then (
				hpxtl_middle_button = true
				hpxtl_middle_button_pos = hpxtl_control_range.width / 2
				hpxtl_zoom_pivot = hpxtl_control_range.location.x + (hpxtl_control_range.width / 2)
				hpxtl_middle_button_width = hpxtl_control_range.width
				dotNet.addEventHandler hpxtl_control_range_center "mouseup" hpxtl_range_center_mouseup
			)
			if (arg.button == arg.button.left) then (
				hpxtl_data_slider1_pos = hpxtl_control_slider1.location.x
				hpxtl_data_slider2_pos = hpxtl_control_slider2.location.x
				hpxtl_data_mouse_pos = mouse.pos.x
				dotNet.addEventHandler hpxtl_control_range_center "mouseup" hpxtl_range_center_mouseup
				dotNet.addEventHandler hpxtl_control_range_center "mousemove" hpxtl_range_mousemove
			)
			hpxtl_last_timestamp = timestamp()
		)
		function hpxtl_range_center_mouseleave = (
			dotNet.removeEventHandler hpxtl_control_range_center "mousemove" hpxtl_range_mousemove
			dotNet.removeEventHandler hpxtl_control_range_center "mousewheel" hpxtl_range_mousewheel
			dotNet.removeEventHandler hpxtl_control_range_center "mousedown" hpxtl_range_center_mousedown
			dotNet.removeEventHandler hpxtl_control_range_center "doubleclick" hpxtl_range_doubleclick
			dotNet.removeEventHandler hpxtl_control_range_center "keydown" hpxtl_range_keydown
			dotNet.removeEventHandler hpxtl_control_range_center "keyup" hpxtl_range_keyup
			dotNet.removeEventHandler hpxtl_control_range_center "mouseup" hpxtl_range_center_mouseup
			dotNet.removeEventHandler hpxtl_control_range_center "mouseleave" hpxtl_range_center_mouseleave
		)
		function hpxtl_range_center_mouseenter = (
			dotNet.addEventHandler hpxtl_control_range_center "mousedown" hpxtl_range_center_mousedown
			dotNet.addEventHandler hpxtl_control_range_center "mousewheel" hpxtl_range_mousewheel
			dotNet.addEventHandler hpxtl_control_range_center "mouseleave" hpxtl_range_center_mouseleave
			dotNet.addEventHandler hpxtl_control_range_center "doubleclick" hpxtl_range_doubleclick
			dotNet.addEventHandler hpxtl_control_range_center "keydown" hpxtl_range_keydown
			dotNet.addEventHandler hpxtl_control_range_center "keyup" hpxtl_range_keyup
			hpxtl_control_range_center.focus()
		)
	--)
	--( TRACKBAR FUNCTIONS
		function hpxtl_trackbar_mousedown arg = (
			hpxtl_newpos = arg.x - (int(hpxtl_control_range.width / 2) + hpxtl_data_slider_width)
			hpxtl_newpos2 = arg.x + (int(hpxtl_control_range.width / 2))
			if (hpxtl_newpos < 1) then (
				hpxtl_newpos = 1
			)
			if (hpxtl_newpos2 > (hpxtl_rollout.hpxtl_form.width - 1)) then (
				hpxtl_newpos = hpxtl_rollout.hpxtl_form.width - (1 + (hpxtl_data_slider_width * 2) + hpxtl_control_range.width)
			)
			hpxtl_newpos2 = 1 + (hpxtl_data_slider_width * 2) + hpxtl_control_range.width
			hpxtl_control_slider1.location.x = hpxtl_newpos
			hpxtl_control_slider2.location.x = hpxtl_newpos + hpxtl_data_slider_width + hpxtl_control_range.width
			hpxtl_control_range.location.x = hpxtl_newpos + hpxtl_data_slider_width
			hpxtl_control_range_center.location.x = hpxtl_control_range.location.x + (int(hpxtl_control_range.width / 2)) - 3
			hpxtl_setrange_3()
		)
	--)
	--( PRESET FUNCTIONS
		function hpxtl_preset_click sender arg = (
			if (arg.button == arg.button.right) then (
				sender.image = hpxtl_bitmap_preset_active
				setAppData rootNode (("9806845" + sender.name + "1") as integer) (hpxtl_animation_zoom_start as string)
				setAppData rootNode (("9806845" + sender.name + "2") as integer) (hpxtl_animation_zoom_end as string)
				sender.cursor = hpxtl_hand
				hpxtl_control_tooltip.SetToolTip sender ((hpxtl_animation_zoom_start as string) + " - " + (hpxtl_animation_zoom_end as string))
			)
			if (arg.button == arg.button.left) then (
				try (hpxtl_slider1_saved_pos = getAppData rootNode (("9806845" + sender.name + "1") as integer)) catch ()
				try (hpxtl_slider2_saved_pos = getAppData rootNode (("9806845" + sender.name + "2") as integer)) catch ()
				if ((hpxtl_slider1_saved_pos != undefined) and (hpxtl_slider2_saved_pos != undefined)) then (
					if (hpxtl_slider1_saved_pos as integer < hpxtl_animation_start) or (hpxtl_slider2_saved_pos as integer > hpxtl_animation_end) then (
						messagebox ("Couldn't load the preset!\r\nThe time range of the preset (" + hpxtl_slider1_saved_pos + " - " + hpxtl_slider2_saved_pos + ")\r\nis out of the full time range (" + hpxtl_animation_start as string + " - " + hpxtl_animation_end as string + ")!") title:"Extended Timeline"
					) else (
						hpxtl_animation_zoom_start = hpxtl_slider1_saved_pos as integer
						hpxtl_animation_zoom_end = hpxtl_slider2_saved_pos as integer
						animationRange = interval hpxtl_animation_zoom_start hpxtl_animation_zoom_end
						hpxtl_rollout.hpxtl_control_zoom_firstframe.value = hpxtl_animation_zoom_start
						hpxtl_rollout.hpxtl_control_zoom_lastframe.value = hpxtl_animation_zoom_end
						setAppData rootNode 98068471 (hpxtl_animation_zoom_start as string)
						setAppData rootNode 98068472 (hpxtl_animation_zoom_end as string)
						hpxtl_setrange_reverse()
					)
				)
			)
			if (arg.button == arg.button.middle) then (
				sender.image = hpxtl_bitmap_preset_inactive
				deleteAppData rootNode (("9806845" + sender.name + "1") as integer)
				deleteAppData rootNode (("9806845" + sender.name + "2") as integer)
				sender.cursor = hpxtl_default
				hpxtl_control_tooltip.SetToolTip sender ""
			)
		)
	--)
	--( SETTINGS TAB FUNCTIONS
		function hpxtl_deactivate_general = (
			for i in hpxtl_controls_general do (
				i.pos.x += 600
			)
		)
		function hpxtl_activate_general = (
			for i in hpxtl_controls_general do (
				i.pos.x -= 600
			)
		)
		function hpxtl_deactivate_control = (
			for i in hpxtl_controls_control do (
				i.pos.x += 600
			)
		)
		function hpxtl_activate_control = (
			for i in hpxtl_controls_control do (
				i.pos.x -= 600
			)
		)
		function hpxtl_deactivate_skin = (
			for i in hpxtl_controls_skin do (
				i.pos.x += 600
			)
		)
		function hpxtl_activate_skin = (
			for i in hpxtl_controls_skin do (
				i.pos.x -= 600
			)
		)
	--)
	--( KEYFRAME FUNCTIONS
		function hpxtl_keyframes_click = (
			if ($ != undefined)  then (
				hpxtl_interval_start = undefined
				hpxtl_interval_end = undefined
				hpxtl_interval_array_start = #()
				hpxtl_interval_array_end = #()
				for i in selection do (
					hpxtl_interval = getTimeRange i.controller #children #selonly
					if abs hpxtl_interval.start != 2147483648 then (
						append hpxtl_interval_array_start hpxtl_interval.start
					) else (
						for j=1 to i.controller.keys.count do (
							if (iskeyselected i.controller j) then (
								append hpxtl_interval_array_start (getkeytime i.controller j)
							)
						)
					)
					if abs hpxtl_interval.end != 2147483648 then (
						append hpxtl_interval_array_end hpxtl_interval.end
					) else (
						for j=1 to i.controller.keys.count do (
							if (iskeyselected i.controller j) then (
								append hpxtl_interval_array_end (getkeytime i.controller j)
							)
						)
					)
				)
				hpxtl_interval_start = amin hpxtl_interval_array_start
				hpxtl_interval_end = amax hpxtl_interval_array_end
				if (hpxtl_interval_start != undefined and hpxtl_interval_end != undefined) then (
					if (hpxtl_interval_start >= hpxtl_animation_start and hpxtl_interval_end <= hpxtl_animation_end) then (
						hpxtl_animation_zoom_start = (hpxtl_interval_start as integer)/TicksPerFrame
						hpxtl_animation_zoom_end = (hpxtl_interval_end as integer)/TicksPerFrame
						if (hpxtl_animation_zoom_start == hpxtl_animation_zoom_end) then (
							if (hpxtl_animation_zoom_end < hpxtl_animation_end) then (
								hpxtl_animation_zoom_end = hpxtl_animation_zoom_start + 1
							) else (
								hpxtl_animation_zoom_start = hpxtl_animation_zoom_end - 1
							)
						)
						hpxtl_rollout.hpxtl_control_zoom_firstframe.value = hpxtl_animation_zoom_start
						hpxtl_rollout.hpxtl_control_zoom_lastframe.value = hpxtl_animation_zoom_end
						animationRange = interval hpxtl_animation_zoom_start hpxtl_animation_zoom_end
						hpxtl_setrange_reverse()
					)
				) else (
					messagebox "No keys are selected" title:"Extended Timeline"
				)
			)
		)
	--)
	--( PRESET VALIDATION
		function hpxtl_preset_validation = (
			for i = 1 to 5 do (
				try (hpxtl_slider1_saved_pos = getAppData rootNode (("9806845" + (i as string) + "1") as integer)) catch ()
				try (hpxtl_slider2_saved_pos = getAppData rootNode (("9806845" + (i as string) + "2") as integer)) catch ()
				if ((hpxtl_slider1_saved_pos != undefined) and (hpxtl_slider2_saved_pos != undefined)) then (
					if (hpxtl_slider1_saved_pos as integer < hpxtl_animation_start) or (hpxtl_slider2_saved_pos as integer > hpxtl_animation_end) then (
						execute("hpxtl_control_preset_" + (i as string) + ".image = hpxtl_bitmap_preset_invalid")
					) else (
						execute("hpxtl_control_preset_" + (i as string) + ".image = hpxtl_bitmap_preset_active")
					)
				)
			)
		)
	--)
--)

--( CURSORS
	hpxtl_cursor = dotNetClass "System.Windows.Forms.Cursors"
	hpxtl_default = hpxtl_cursor.default
	hpxtl_hand = hpxtl_cursor.hand
	hpxtl_sizewe = hpxtl_cursor.sizewe
--)
--( USERINTERFACE COLORS
	hpxtl_max_backgroundcolor = colorman.getColor #background
	hpxtl_colorclass = dotnetclass "System.Drawing.Color"
	hpxt_max_backgroundcolor_r = int(hpxtl_max_backgroundcolor[1] * 255)
	hpxt_max_backgroundcolor_g = int(hpxtl_max_backgroundcolor[2] * 255)
	hpxt_max_backgroundcolor_b = int(hpxtl_max_backgroundcolor[3] * 255)
	hpxtl_backgroundcolor = hpxtl_colorclass.fromargb 255 hpxt_max_backgroundcolor_r hpxt_max_backgroundcolor_g hpxt_max_backgroundcolor_b
	hpxtl_bitmap_logo_temp = dotNetObject "System.Drawing.Bitmap" (hpxtl_scriptpath + "/logo.png")
	hpxtl_bitmap_logo = hpxtl_bitmap_logo_temp.clone (dotNetObject "System.Drawing.Rectangle" 0 0 300 50) (hpxtl_bitmap_logo_temp.pixelformat)
	hpxtl_bitmap_donate = hpxtl_bitmap_logo_temp.clone (dotNetObject "System.Drawing.Rectangle" 220 23 74 21) (hpxtl_bitmap_logo_temp.pixelformat)
	hpxtl_bitmap_logo_temp.dispose()
--)

--( CREATE DOT NET USER INTERFACE
	--( SETTING BUTTON
		hpxtl_control_settings = dotNetObject "System.Windows.Forms.PictureBox"
		hpxtl_control_settings.height = 21
		hpxtl_control_settings.location.y = 0
		hpxtl_control_settings.cursor = hpxtl_hand
	--)
	--( TRACKBAR
		hpxtl_control_trackbar = dotNetObject "System.Windows.Forms.PictureBox"
		hpxtl_control_trackbar.height = 21
		hpxtl_control_trackbar.location.x = 2
		hpxtl_control_trackbar.location.y = 1
	--)
	--( SLIDER LEFT
		hpxtl_control_slider1 = dotNetObject "System.Windows.Forms.PictureBox"
		hpxtl_control_slider1.height = 21
		hpxtl_control_slider1.location.x = 1
		hpxtl_control_slider1.location.y = 1
		hpxtl_control_slider1.cursor = hpxtl_sizewe
	--)
	--( SLIDER RIGHT
		hpxtl_control_slider2 = dotNetObject "System.Windows.Forms.PictureBox"
		hpxtl_control_slider2.height = 21
		hpxtl_control_slider2.location.y = 1
		hpxtl_control_slider2.cursor = hpxtl_sizewe
	--)
	--( RANGE
		hpxtl_control_range = dotNetObject "System.Windows.Forms.PictureBox"
		hpxtl_control_range.height = 21
		hpxtl_control_range.location.y = 1
		hpxtl_control_range.cursor = hpxtl_hand
	--)
	--( RANGE CENTER
		hpxtl_control_range_center = dotNetObject "System.Windows.Forms.PictureBox"
		hpxtl_control_range_center.height = 21
		hpxtl_control_range_center.location.y = 1
		hpxtl_control_range_center.cursor = hpxtl_hand
	--)
	--( TRACKBAR SIDE RIGHT
		hpxtl_control_trackbar_side_right = dotNetObject "System.Windows.Forms.PictureBox"
		hpxtl_control_trackbar_side_right.height = 21
		hpxtl_control_trackbar_side_right.location.y = 1
	--)
	--( PRESETS
		hpxtl_control_preset_1 = dotNetObject "System.Windows.Forms.PictureBox"
		hpxtl_control_preset_1.height = 21
		hpxtl_control_preset_1.location.y = 0
		hpxtl_control_preset_1.name = "1"
		hpxtl_control_preset_2 = dotNetObject "System.Windows.Forms.PictureBox"
		hpxtl_control_preset_2.height = 21
		hpxtl_control_preset_2.location.y = 0
		hpxtl_control_preset_2.name = "2"
		hpxtl_control_preset_3 = dotNetObject "System.Windows.Forms.PictureBox"
		hpxtl_control_preset_3.height = 21
		hpxtl_control_preset_3.location.y = 0
		hpxtl_control_preset_3.name = "3"
		hpxtl_control_preset_4 = dotNetObject "System.Windows.Forms.PictureBox"
		hpxtl_control_preset_4.height = 21
		hpxtl_control_preset_4.location.y = 0
		hpxtl_control_preset_4.name = "4"
		hpxtl_control_preset_5 = dotNetObject "System.Windows.Forms.PictureBox"
		hpxtl_control_preset_5.height = 21
		hpxtl_control_preset_5.location.y = 0
		hpxtl_control_preset_5.name = "5"
	--)
	--( TOOLTIPS
		hpxtl_control_tooltip = dotNetObject "System.Windows.Forms.ToolTip"
	--)
	--( KEYFRAMES BUTTON
		hpxtl_control_keyframes = dotNetObject "System.Windows.Forms.PictureBox"
		hpxtl_control_keyframes.height = 21
		hpxtl_control_keyframes.location.y = 0
		hpxtl_control_keyframes.location.x = 3
		hpxtl_control_keyframes.cursor = hpxtl_hand
	--)
	--( ADD EVENT HANDLERS TO DOTNET OBJECTS
		dotNet.addEventHandler hpxtl_control_slider1 "mousedown" hpxtl_slider1_mousedown
		dotNet.addEventHandler hpxtl_control_slider2 "mousedown" hpxtl_slider2_mousedown
		dotNet.addEventHandler hpxtl_control_range "mouseenter" hpxtl_range_mouseenter
		dotNet.addEventHandler hpxtl_control_range_center "mouseenter" hpxtl_range_center_mouseenter
		dotNet.addEventHandler hpxtl_control_trackbar "mousedown" hpxtl_trackbar_mousedown
		dotNet.addEventHandler hpxtl_control_preset_1 "click" hpxtl_preset_click
		dotNet.addEventHandler hpxtl_control_preset_2 "click" hpxtl_preset_click
		dotNet.addEventHandler hpxtl_control_preset_3 "click" hpxtl_preset_click
		dotNet.addEventHandler hpxtl_control_preset_4 "click" hpxtl_preset_click
		dotNet.addEventHandler hpxtl_control_preset_5 "click" hpxtl_preset_click
		dotNet.addEventHandler hpxtl_control_keyframes "click" hpxtl_keyframes_click
		dotNet.addEventHandler hpxtl_control_settings "click" hpxtl_settings_click
	--)
--)

--( BUILD MAXSCRIPT ROLLOUTS
	--(UPDATE QUERY
		rollout hpxtl_update_query "Extended Time" width:400 height:65 (
			label hpxtl_label "New version is available for Extended Timeline. Do you want to update it now?" pos:[12,5]
			button hpxtl_button_yes "Yes" width:100 height:25 pos:[90,30]
			button hpxtl_button_no "No" width:100 height:25 pos:[210,30]
			on hpxtl_button_no pressed do (
				destroydialog hpxtl_update_query
			)
			on hpxtl_button_yes pressed do (
				destroydialog hpxtl_update_query
				hpxtl_exit()
				hpxtl_update_script()
			)
		)
	--)
	--(ABOUT
		rollout hpxtl_rollout_about "Extended Timeline" width:300 height:200 (
			label hpxtl_about_label1 "Extended Timeline v1.6.1 for Autodesk 3ds Max" pos:[37,15]
			label hpxtl_about_label2 "Created by Heavenly Pictures" pos:[77,35]
			label hpxtl_about_label3 "All rights reserved" pos:[107,55]
			label hpxtl_about_label4 "Website: www.heavenlypictures.hu" pos:[60,95]
			label hpxtl_about_label5 "Info and error reporting: info@heavenlypictures.hu" pos:[25,115]
			dotnetcontrol hpxtl_about_donate "PictureBox" image:hpxtl_bitmap_donate width:74 height:21 pos:[220,173]
			dotnetcontrol hpxtl_logo "PictureBox" image:hpxtl_bitmap_logo width:300 height:50 pos:[0,150]
			on hpxtl_about_donate click do (
				hpxtl_donate_link = dotnetclass "System.Diagnostics.Process"
				hpxtl_donate_link.start ("www.heavenlypictures.hu/maxscript/extendedtimeline/donate.php")
			)
		)
	--)
	--(CHANGELOG ROLLOUT
		rollout hpxtl_rollout_changelog "Extended Timeline Changelog" width:430 height:225 (
			label hpxtl_changelog_label1 "1.0 (2012. jul 12) :" pos:[5,5]
			label hpxtl_changelog_label1b "First release" pos:[110,5]
			label hpxtl_changelog_label2 "1.1 (2012. jul 18) :" pos:[5,25]
			label hpxtl_changelog_label2b "Small bug fixes, double click again to restore last zoomed position" pos:[110,25]
			label hpxtl_changelog_label3 "Zoom without mouse wheel (see manual)" pos:[110,40]
			label hpxtl_changelog_label4 "1.2 (2012. aug 1) :" pos:[5,60]
			label hpxtl_changelog_label4b "Available to store presets, and save them with the scene" pos:[110,60]
			label hpxtl_changelog_label5 "1.3 (2012. aug 2) :" pos:[5,80]
			label hpxtl_changelog_label5b "Bug fixes" pos:[110,80]
			label hpxtl_changelog_label6 "1.4 (2012. aug 3) :" pos:[5,100]
			label hpxtl_changelog_label6b "Bug fixes" pos:[110,100]
			label hpxtl_changelog_label7 "1.5 (2013. feb 20) :" pos:[5,120]
			label hpxtl_changelog_label7b "Bug fixes, Presets are stored as frames instead of percent" pos:[110,120]
			label hpxtl_changelog_label8 "Inner spinners to set zoom range" pos:[110,135]
			label hpxtl_changelog_label9 "Tooltips for preset buttons" pos:[110,150]
			label hpxtl_changelog_label10 "1.6 (2013. mar 19) :" pos:[5,170]
			label hpxtl_changelog_label10b "Available to Zoom to selected keyframes" pos:[110,170]
			label hpxtl_changelog_label11 "1.6.1 (2013. apr 7) :" pos:[5,190]
			label hpxtl_changelog_label11b "Error in new scene fixed, callback events error fixed," pos:[110,190]
			label hpxtl_changelog_label12 "zoom to keyframes works with biped objects" pos:[110,205]
		)
	--)
	--( SETTINGS ROLLOUT
		rollout hpxtl_rollout_settings "Extended Timeline Settings" width:300 height:250 (
			checkbutton hpxtl_settings_general "General" width:100 height:25 pos:[0,0]
			checkbutton hpxtl_settings_control "Control" width:100 height:25 pos:[100,0]
			checkbutton hpxtl_settings_skin "Skin" width:100 height:25 pos:[200,0]
			dotnetcontrol hpxtl_donate "PictureBox" image:hpxtl_bitmap_donate width:74 height:21 pos:[220,223]
			dotnetcontrol hpxtl_logo "PictureBox" image:hpxtl_bitmap_logo width:300 height:50 pos:[0,200]
			--( TAB CHANGE EVENTS
				--( GENERAL
					on hpxtl_settings_general changed state do (
						if (state == true) then (
							hpxtl_activate_general()
							if (hpxtl_settings_control.state == true) then (
								hpxtl_settings_control.state = false
								hpxtl_deactivate_control()
							)
							if (hpxtl_settings_skin.state == true) then (
								hpxtl_settings_skin.state = false
								hpxtl_deactivate_skin()
							)
						) else (
							hpxtl_settings_general.state = true
						)
					)
				--)
				--( CONTROL
					on hpxtl_settings_control changed state do (
						if (state == true) then (
							hpxtl_activate_control()
							if (hpxtl_settings_general.state == true) then (
								hpxtl_settings_general.state = false
								hpxtl_deactivate_general()
							)
							if (hpxtl_settings_skin.state == true) then (
								hpxtl_settings_skin.state = false
								hpxtl_deactivate_skin()
							)
						) else (
							hpxtl_settings_control.state = true
						)
					)
				--)
				--( SKIN
					on hpxtl_settings_skin changed state do (
						if (state == true) then (
							hpxtl_activate_skin()
							if (hpxtl_settings_general.state == true) then (
								hpxtl_settings_general.state = false
								hpxtl_deactivate_general()
							)
							if (hpxtl_settings_control.state == true) then (
								hpxtl_settings_control.state = false
								hpxtl_deactivate_control()
							)
						) else (
							hpxtl_settings_skin.state = true
						)
					)
				--)
			--)
			--( GENERAL TAB
				groupbox hpxtl_settings_groupbox1 "" pos:[608,30] width:284 height:50
					label hpxtl_settings_general_label1 "Extended Timeline v1.6.1 for Autodesk 3ds Max" pos:[645,40]
					checkbox hpxtl_settings_general_autorun "Run at Max startup" pos:[615,60]
				groupbox hpxtl_settings_groupbox2 "" pos:[608,82] width:284 height:113
					label hpxtl_settings_general_label2 "Current version: 1.6.1 (19 Mar 2013)" pos:[675,92]
					checkbox hpxtl_settings_general_autoupdate "Check for updates on startup" pos:[615,112]
					button hpxtl_settings_general_update "Check for updates now" width:132 height:25 pos:[615,132]
					button hpxtl_settings_general_changelog "View changelog" width:132 height:25 pos:[752,132]
					label hpxtl_settings_general_label3 "To get updates, please be sure that your firewall allows" pos:[615,162]
					label hpxtl_settings_general_label4 "this script to access the internet!" pos:[670,178]
				--(GENERAL EVENTS
					on hpxtl_settings_general_autorun changed state do (
						local startupMS = (getDir #Scripts) + "\\BulletScripts\\StartupMS\\EXTimelineStartup.ms"
						local startupPath = (getDir #StartupScripts)+ "\\EXTimelineStartup.ms"
						if state == true then (
							-- hpxtl_autorun_file = fopen ((getdir #userstartupscripts)+"\\EXTimelineStartup.ms") "wt"
							-- writestring hpxtl_autorun_file ("filein \""+(getdir #Scripts)+"\\BulletScripts\\Quote\\Heavenly Pictures\\Extended Timeline\\extended_timeline.ms\"")
							-- fclose hpxtl_autorun_file
							if (not (SIOFile.Exists startupPath)) do
							(
								try 
								(
									FileIO.Copyfile startupMS startupPath UIOption
									-- SIOFile.Copy startupBsKeyTools startupPath
									messagebox ("已打开 Extended Timeline 自启！                  ")  title:"自启设置"
									-- setFileAttribute startupPath #readOnly true
								)
								catch()
							)
							setinisetting hpxtl_inifile "General" "autorun" (state as string)
						) else (
							-- if (doesfileexist ((getdir #startupscripts)+"\\BulletScripts\\StartupMS\\EXTimelineStartup.ms") == true) then (
							-- 	deletefile ((getdir #startupscripts)+"\\BulletScripts\\StartupMS\\EXTimelineStartup.ms")
								fnDelFileDir startupPath
								setinisetting hpxtl_inifile "General" "autorun" (state as string)
							-- )
						)
					)
					on hpxtl_settings_general_autoupdate changed state do (
						setinisetting hpxtl_inifile "General" "autoupdate" (state as string)
					)
					on hpxtl_settings_general_changelog pressed do (
						createdialog hpxtl_rollout_changelog style:#(#style_toolwindow,#style_sysmenu)
					)
					on hpxtl_settings_general_update pressed do (
						try (
							hpxtl_webrequest = ((dotnetclass "net.httpwebrequest").create("http://www.heavenlypictures.hu/maxscript/extendedtimeline/version.php")).getresponse()
							if (hpxtl_webrequest.statuscode == hpxtl_webrequest.statuscode.ok) then (
								hpxtl_response = (dotnetobject "IO.streamreader" (hpxtl_webrequest.getresponsestream())).readtoend()
								if ((hpxtl_response as float) > (getinisetting hpxtl_inifile "general" "version" as float)) then (
									hpxtl_querybox_response = querybox "New version is available for Extended Timeline. Do you want to update it now?" title:"Extended Timeline"
									if (hpxtl_querybox_response == true) then (
										hpxtl_exit()
										hpxtl_update_script()
									)
								) else (
									messagebox "You already have the latest version" title:"Extended Timeline"
								)
							) else (
								messagebox "Can't connect to heavenlypictures.hu" title:"Extended Timeline"
							)
						) catch (
							messagebox "Can't connect to heavenlypictures.hu" title:"Extended Timeline"
						)
					)
				--)
			--)
			--( CONTROL TAB
				groupbox hpxtl_settings_groupbox3 "" pos:[608,30] width:284 height:70
					label hpxtl_settings_control_label1 "Normal Zoom (Mouse Wheel)" pos:[615,40]
					label hpxtl_settings_control_label2 "Less Zoom (Mouse Wheel + SHIFT)" pos:[615,60]
					label hpxtl_settings_control_label3 "More Zoom (Mouse Wheel + CTRL)" pos:[615,80]
					label hpxtl_settings_control_label4 "%" pos:[875,40]
					label hpxtl_settings_control_label5 "%" pos:[875,60]
					label hpxtl_settings_control_label6 "%" pos:[875,80]
					spinner hpxtl_settings_control_scroll "" range:[5,90,hpxtl_scroll_normal] type:#integer width:50 height:20 pos:[820,40]
					spinner hpxtl_settings_control_less "" range:[5,90,hpxtl_scroll_less] type:#integer width:50 height:20 pos:[820,60]
					spinner hpxtl_settings_control_more "" range:[5,90,hpxtl_scroll_more] type:#integer width:50 height:20 pos:[820,80]
				groupbox hpxtl_settings_groupbox4 "" pos:[608,105] width:284 height:30
					checkbox hpxtl_settings_control_checkbox_1 "Presets" pos:[615,115]
					label hpxtl_settings_control_label7 "Number of presets" pos:[740,116]
					spinner hpxtl_settings_control_nofpresets "" range:[1,5,3] type:#integer width:50 height:20 pos:[836,115]
				groupbox hpxtl_settings_groupbox5 "" pos:[608,135] width:284 height:30
					checkbox hpxtl_settings_control_innerspinners "Zoom spinners" pos:[615,145]
					checkbox hpxtl_settings_control_keyframes "Zoom to keyframes" pos:[775,145]
				groupbox hpxtl_settings_groupbox6 "" pos:[608,165] width:284 height:30
					checkbox hpxtl_settings_control_tooltips "Preset tooltips" pos:[615,175]
				--( CONTROL EVENTS
					on hpxtl_settings_control_scroll changed val do (
						setinisetting hpxtl_inifile "control" "scroll_normal" (val as string)
						hpxtl_scroll_normal = val
						hpxtl_scroll = val
					)
					on hpxtl_settings_control_less changed val do (
						setinisetting hpxtl_inifile "control" "scroll_less" (val as string)
						hpxtl_scroll_less = val
					)
					on hpxtl_settings_control_more changed val do (
						setinisetting hpxtl_inifile "control" "scroll_more" (val as string)
						hpxtl_scroll_more = val
					)
					on hpxtl_settings_control_checkbox_1 changed state do (
						setinisetting hpxtl_inifile "control" "presets" (state as string)
						if (state == true) then (
							hpxtl_presets_width = (hpxtl_data_preset_width * (getinisetting hpxtl_inifile "control" "nofpresets" as integer))+(3 * ((getinisetting hpxtl_inifile "control" "nofpresets" as integer)-1))
							hpxtl_rollout.hpxtl_presets.width = hpxtl_presets_width
							hpxtl_resize_interface()
							hpxtl_settings_control_nofpresets.enabled = true
						) else (
							hpxtl_presets_width = 0
							hpxtl_rollout.hpxtl_presets.width = hpxtl_presets_width
							hpxtl_resize_interface()
							hpxtl_settings_control_nofpresets.enabled = false
						)
					)
					on hpxtl_settings_control_nofpresets changed val do (
						setinisetting hpxtl_inifile "control" "nofpresets" (val as string)
						hpxtl_number_of_presets = getinisetting hpxtl_inifile "control" "nofpresets" as integer
						hpxtl_presets_width = (hpxtl_data_preset_width * hpxtl_number_of_presets)+(3 * (hpxtl_number_of_presets-1))
						hpxtl_rollout.hpxtl_presets.width = hpxtl_presets_width
						hpxtl_resize_interface()
					)
					on hpxtl_settings_control_innerspinners changed state do (
						setinisetting hpxtl_inifile "control" "innerspinners" (state as string)
						if (state == true) then (
							hpxtl_inner_spinners = 120
						) else (
							hpxtl_inner_spinners = 0
						)
						hpxtl_resize_interface()
					)
					on hpxtl_settings_control_tooltips changed state do (
						setinisetting hpxtl_inifile "control" "tooltips" (state as string)
						hpxtl_control_tooltip.active = state
					)
					on hpxtl_settings_control_keyframes changed state do (
						setinisetting hpxtl_inifile "control" "keyframes" (state as string)
						if (state == true) then (
							hpxtl_buttons_width = hpxtl_data_settings_width + 6 + hpxtl_data_keyframes_width
						) else (
							hpxtl_buttons_width = hpxtl_data_settings_width + 3
						)
						hpxtl_resize_interface()
					)
				--)
			--)
			--( SKIN TAB
				groupbox hpxtl_skin_groupbox1 "" pos:[702,26] width:192 height:167
				listbox hpxtl_skin_listbox "" items:#("Default","Default Blue") height:50 width:90 pos:[607,32]
				label hpxtl_skin_label1 "Skin name: " align:#left pos:[711,40]
				label hpxtl_skin_label2 "Created by: " align:#left pos:[711,60]
				label hpxtl_skin_label3 "Supported alpha: " align:#left pos:[711,80]
				--( SKIN EVENTS
					on hpxtl_skin_listbox selected arg do (
						if (hpxtl_add_skin(hpxtl_available_skins[arg]) == true) then (
							hpxtl_resize_interface()
							hpxtl_skin = hpxtl_skin_listbox.selected
							hpxtl_skin_number = arg
							hpxtl_skin_label1.text = "Skin name: " + hpxtl_skin
							hpxtl_skin_label2.text = "Created by: " + hpxtl_skin_creator
							hpxtl_skin_label3.text = "Supported alpha: " + hpxtl_bitmap_alpha
							setinisetting hpxtl_inifile "Skin" "name" hpxtl_skin_listbox.selected as string
						) else (
							hpxtl_skin_listbox.selection = hpxtl_skin_number
						)
					)
				--)
			--)
			--( DONATE
				on hpxtl_donate click do (
					hpxtl_donate_link = dotnetclass "System.Diagnostics.Process"
					hpxtl_donate_link.start ("www.heavenlypictures.hu/maxscript/extendedtimeline/donate.php")
				)
			--)
		)
	--)
	--( MENUPANEL ROLLOUT
		rollout hpxtl_menupanel "" width:75 height:100 (
			button hpxtl_menu_settings "Settings" width:75 height:25 pos:[0,0] border:true
			button hpxtl_menu_help "Help" width:75 height:25 pos:[0,25] border:true
			button hpxtl_menu_about "About" width:75 height:25 pos:[0,50] border:true
			button hpxtl_menu_exit "Exit" width:75 height:25 pos:[0,75] border:true
			--( EVENTS
				on hpxtl_menu_about pressed do (
					destroydialog hpxtl_menupanel
					createdialog hpxtl_rollout_about style:#(#style_toolwindow,#style_sysmenu)
					hpxtl_rollout_about.hpxtl_about_donate.cursor = hpxtl_hand
				)
				on hpxtl_menu_exit pressed do (
					hpxtl_exit()
				)
				on hpxtl_menu_settings pressed do (
					try (destroydialog hpxtl_rollout_settings) catch ()
					destroydialog hpxtl_menupanel
					createdialog hpxtl_rollout_settings style:#(#style_toolwindow,#style_sysmenu)
					hpxtl_controls_general = #(hpxtl_rollout_settings.hpxtl_settings_general_label4, hpxtl_rollout_settings.hpxtl_settings_general_label3, hpxtl_rollout_settings.hpxtl_settings_general_changelog, hpxtl_rollout_settings.hpxtl_settings_groupbox1, hpxtl_rollout_settings.hpxtl_settings_groupbox2, hpxtl_rollout_settings.hpxtl_settings_general_label1, hpxtl_rollout_settings.hpxtl_settings_general_autorun, hpxtl_rollout_settings.hpxtl_settings_general_label2, hpxtl_rollout_settings.hpxtl_settings_general_autoupdate, hpxtl_rollout_settings.hpxtl_settings_general_update)
					hpxtl_controls_control = #(hpxtl_rollout_settings.hpxtl_settings_control_keyframes, hpxtl_rollout_settings.hpxtl_settings_groupbox6, hpxtl_rollout_settings.hpxtl_settings_control_tooltips, hpxtl_rollout_settings.hpxtl_settings_groupbox5, hpxtl_rollout_settings.hpxtl_settings_control_innerspinners, hpxtl_rollout_settings.hpxtl_settings_control_nofpresets, hpxtl_rollout_settings.hpxtl_settings_control_label7, hpxtl_rollout_settings.hpxtl_settings_control_checkbox_1, hpxtl_rollout_settings.hpxtl_settings_groupbox4, hpxtl_rollout_settings.hpxtl_settings_control_label6, hpxtl_rollout_settings.hpxtl_settings_control_label5, hpxtl_rollout_settings.hpxtl_settings_control_label4, hpxtl_rollout_settings.hpxtl_settings_control_label3, hpxtl_rollout_settings.hpxtl_settings_control_label2, hpxtl_rollout_settings.hpxtl_settings_control_label1, hpxtl_rollout_settings.hpxtl_settings_control_scroll, hpxtl_rollout_settings.hpxtl_settings_control_less, hpxtl_rollout_settings.hpxtl_settings_control_more, hpxtl_rollout_settings.hpxtl_settings_groupbox3)
					hpxtl_controls_skin = #(hpxtl_rollout_settings.hpxtl_skin_label3, hpxtl_rollout_settings.hpxtl_skin_label2, hpxtl_rollout_settings.hpxtl_skin_label1, hpxtl_rollout_settings.hpxtl_skin_groupbox1, hpxtl_rollout_settings.hpxtl_skin_listbox)
					hpxtl_rollout_settings.hpxtl_settings_general.checked = true
					hpxtl_rollout_settings.hpxtl_skin_listbox.height = 161
					hpxtl_activate_general()
					hpxtl_rollout_settings.hpxtl_skin_listbox.items = hpxtl_available_skins
					hpxtl_rollout_settings.hpxtl_skin_listbox.selection = hpxtl_skin_number
					hpxtl_rollout_settings.hpxtl_skin_label1.text = "Skin name: " + hpxtl_skin
					hpxtl_rollout_settings.hpxtl_skin_label2.text = "Created by: " + hpxtl_skin_creator
					hpxtl_rollout_settings.hpxtl_skin_label3.text = "Supported alpha: " + hpxtl_bitmap_alpha
					hpxtl_rollout_settings.hpxtl_donate.cursor = hpxtl_hand
					hpxtl_rollout_settings.hpxtl_settings_general_autorun.state = getinisetting hpxtl_inifile "General" "autorun" as booleanclass
					hpxtl_rollout_settings.hpxtl_settings_general_autoupdate.state = getinisetting hpxtl_inifile "General" "autoupdate" as booleanclass
					hpxtl_rollout_settings.hpxtl_settings_control_nofpresets.value = getinisetting hpxtl_inifile "control" "nofpresets" as integer
					hpxtl_rollout_settings.hpxtl_settings_control_checkbox_1.state = getinisetting hpxtl_inifile "control" "presets" as booleanclass
					hpxtl_rollout_settings.hpxtl_settings_control_innerspinners.state = getinisetting hpxtl_inifile "control" "innerspinners" as booleanclass
					hpxtl_rollout_settings.hpxtl_settings_control_tooltips.state = getinisetting hpxtl_inifile "control" "tooltips" as booleanclass
					hpxtl_rollout_settings.hpxtl_settings_control_nofpresets.enabled = getinisetting hpxtl_inifile "control" "presets" as booleanclass
					hpxtl_rollout_settings.hpxtl_settings_control_keyframes.state = getinisetting hpxtl_inifile "control" "keyframes" as booleanclass
				)
				on hpxtl_menu_help pressed do (
					destroydialog hpxtl_menupanel
					shellLaunch (hpxtl_scriptpath + "manual.pdf") ""
				)
			--)
		)
	--)
	--( MAIN ROLLOUT
		rollout hpxtl_rollout "Extended Timeline" width:1000 height:25 (
			spinner hpxtl_control_firstframe "" align:#left pos:[0,5] width:50 height:20 type:#integer range:[-100000,100000,hpxtl_animation_start]
			spinner hpxtl_control_lastframe "" align:#left pos:[0,5] width:50 height:20 type:#integer range:[-100000,100000,hpxtl_animation_end]
			spinner hpxtl_control_zoom_firstframe "" align:#left pos:[98,5] width:50 height:20 type:#integer range:[hpxtl_animation_start,(hpxtl_animation_end - 1),hpxtl_animation_zoom_start]
			spinner hpxtl_control_zoom_lastframe "" align:#left pos:[0,5] width:50 height:20 type:#integer range:[(hpxtl_animation_start + 1),hpxtl_animation_end,hpxtl_animation_zoom_end]
			dotnetcontrol hpxtl_form "System.Windows.Forms.ContainerControl" width:500 height:25 pos:[120,1]
			dotnetcontrol hpxtl_presets "System.Windows.Forms.ContainerControl" width:0 height:21 pos:[1,2]
			dotnetcontrol hpxtl_buttons "System.Windows.Forms.ContainerControl" width:24 height:21 pos:[1,2]
			--( EVENTS
				on hpxtl_control_firstframe changed arg do (
					hpxtl_animation_start = arg
					if (arg >= hpxtl_animation_end) then (
						hpxtl_animation_end = arg + 1
						hpxtl_control_lastframe.value = hpxtl_animation_end
						hpxtl_animation_zoom_end = hpxtl_animation_end
					)
					hpxtl_rollout.hpxtl_control_zoom_firstframe.range = [hpxtl_animation_start,hpxtl_animation_end - 1,hpxtl_animation_zoom_start]
					hpxtl_rollout.hpxtl_control_zoom_lastframe.range = [hpxtl_animation_start + 1,hpxtl_animation_end,hpxtl_animation_zoom_end]
					if (hpxtl_animation_zoom_start < hpxtl_animation_start) then (
						hpxtl_animation_zoom_start = hpxtl_animation_start
						if (hpxtl_animation_zoom_end <= hpxtl_animation_zoom_start) then (
							hpxtl_animation_zoom_end = hpxtl_animation_zoom_start + 1
						)
						hpxtl_rollout.hpxtl_control_zoom_firstframe.range = [hpxtl_animation_start,hpxtl_animation_end - 1,hpxtl_animation_zoom_start]
						hpxtl_rollout.hpxtl_control_zoom_lastframe.range = [hpxtl_animation_start + 1,hpxtl_animation_end,hpxtl_animation_zoom_end]
						animationRange = interval hpxtl_animation_zoom_start hpxtl_animation_zoom_end
						hpxtl_rollout.hpxtl_control_zoom_firstframe.value = hpxtl_animation_zoom_start
						hpxtl_rollout.hpxtl_control_zoom_lastframe.value = hpxtl_animation_zoom_end
						setAppData rootNode 98068471 (hpxtl_animation_zoom_start as string)
						setAppData rootNode 98068472 (hpxtl_animation_zoom_end as string)
					)
					hpxtl_setrange_reverse()
					setAppData rootNode 98068461 (arg as string)
					hpxtl_preset_validation()
				)
				on hpxtl_control_lastframe changed arg do (
					hpxtl_animation_end = arg
					if (arg <= hpxtl_animation_start) then (
						hpxtl_animation_start = arg - 1
						hpxtl_control_firstframe.value = hpxtl_animation_start
						hpxtl_animation_zoom_start = hpxtl_animation_start
					)
					hpxtl_rollout.hpxtl_control_zoom_firstframe.range = [hpxtl_animation_start,hpxtl_animation_end - 1,hpxtl_animation_zoom_start]
					hpxtl_rollout.hpxtl_control_zoom_lastframe.range = [hpxtl_animation_start + 1,hpxtl_animation_end,hpxtl_animation_zoom_end]
					if (hpxtl_animation_zoom_end > hpxtl_animation_end) then (
						hpxtl_animation_zoom_end = hpxtl_animation_end
						if (hpxtl_animation_zoom_start >= hpxtl_animation_zoom_end) then (
							hpxtl_animation_zoom_start = hpxtl_animation_zoom_end - 1
						)
						hpxtl_rollout.hpxtl_control_zoom_firstframe.range = [hpxtl_animation_start,hpxtl_animation_end - 1,hpxtl_animation_zoom_start]
						hpxtl_rollout.hpxtl_control_zoom_lastframe.range = [hpxtl_animation_start + 1,hpxtl_animation_end,hpxtl_animation_zoom_end]
						animationRange = interval hpxtl_animation_zoom_start hpxtl_animation_zoom_end
						hpxtl_rollout.hpxtl_control_zoom_firstframe.value = hpxtl_animation_zoom_start
						hpxtl_rollout.hpxtl_control_zoom_lastframe.value = hpxtl_animation_zoom_end
						setAppData rootNode 98068471 (hpxtl_animation_zoom_start as string)
						setAppData rootNode 98068472 (hpxtl_animation_zoom_end as string)
					)
					hpxtl_setrange_reverse()
					setAppData rootNode 98068462 (arg as string)
					hpxtl_preset_validation()
				)
				on hpxtl_control_zoom_firstframe changed arg do (
					hpxtl_animation_zoom_start = arg
					setAppData rootNode 98068471 (hpxtl_animation_zoom_start as string)
					if (hpxtl_animation_zoom_start >= hpxtl_animation_zoom_end) then (
						hpxtl_animation_zoom_end = hpxtl_animation_zoom_start + 1
						hpxtl_control_zoom_lastframe.value = hpxtl_animation_zoom_end
						setAppData rootNode 98068472 (hpxtl_animation_zoom_end as string)
					)
					animationRange = interval hpxtl_animation_zoom_start hpxtl_animation_zoom_end
					hpxtl_setrange_reverse()
				)
				on hpxtl_control_zoom_lastframe changed arg do (
					hpxtl_animation_zoom_end = arg
					setAppData rootNode 98068472 (hpxtl_animation_zoom_end as string)
					if (hpxtl_animation_zoom_end <= hpxtl_animation_zoom_start) then (
						hpxtl_animation_zoom_start = hpxtl_animation_zoom_end - 1
						hpxtl_control_zoom_firstframe.value = hpxtl_animation_zoom_start
						setAppData rootNode 98068471 (hpxtl_animation_zoom_start as string)
					)
					animationRange = interval hpxtl_animation_zoom_start hpxtl_animation_zoom_end
					hpxtl_setrange_reverse()
				)
				on hpxtl_rollout resized arg do (
					hpxtl_resize_interface()
				)
				local hpxtl_dorefresh = true
				on hpxtl_form Paint args do (
					if hpxtl_dorefresh == true then (
						hpxtl_dorefresh = false
						hpxtl_form.refresh()
						hpxtl_presets.refresh()
						hpxtl_buttons.refresh()
						hpxtl_dorefresh = true
					)
				)
			--)
		)
	--)
--)

--( SKINS
	hpxtl_available_skins = getfiles (hpxtl_scriptpath + "skin\\*.xtls")
	for i=1 to hpxtl_available_skins.count do (
		hpxtl_available_skins[i] = getFilenameFile hpxtl_available_skins[i]
	)
	hpxtl_skin = getinisetting hpxtl_inifile "skin" "name" as string
	hpxtl_skin_number = finditem hpxtl_available_skins hpxtl_skin
--)

--( INTERFACE FUNCTIONS
	--( LOAD SKIN ELEMENTS
		function hpxtl_load_skin skinname = (
			msZip.fileinpackage (hpxtl_scriptpath + "skin\\" + skinname + ".xtls") &hpxtl_skinpath_temp
			try (
			--( GENERAL SKIN SETTINGS
					hpxtl_skin_ini = hpxtl_skinpath_temp + "\\skin.ini"
					hpxtl_skin_image = getinisetting hpxtl_skin_ini "default" "image" as string
					hpxtl_skin_creator = getinisetting hpxtl_skin_ini "default" "creator" as string
					hpxtl_data_slider_width = getinisetting hpxtl_skin_ini "slider1" "width" as integer
					if (hpxtl_data_slider_width > 20) then hpxtl_data_slider_width = 20
					hpxtl_data_settings_width = getinisetting hpxtl_skin_ini "settings" "width" as integer
					hpxtl_data_keyframes_width = getinisetting hpxtl_skin_ini "keyframes" "width" as integer
					if (hpxtl_data_settings_width > 40) then hpxtl_data_settings_width = 40
					hpxtl_data_trackbar_side_width = getinisetting hpxtl_skin_ini "background_end" "width" as integer
					hpxtl_data_range_center_width = getinisetting hpxtl_skin_ini "rangebarcenter" "width" as integer
					hpxtl_data_preset_width = getinisetting hpxtl_skin_ini "preset_active" "width" as integer
			--)
			--( USERINTERFACE IMAGES
					hpxtl_bitmap = dotNetObject "System.Drawing.Bitmap" (hpxtl_skinpath_temp + "\\" + hpxtl_skin_image)
					hpxtl_pixelformat = hpxtl_bitmap.pixelformat
					if (hpxtl_bitmap.isalphapixelformat hpxtl_pixelformat) then (
						hpxtl_bitmap_alpha = "Yes"
					) else (
						hpxtl_bitmap_alpha = "No"
					)
					hpxtl_rect_slider1 = dotNetObject "System.Drawing.Rectangle" (getinisetting hpxtl_skin_ini "slider1" "posx" as integer) (getinisetting hpxtl_skin_ini "slider1" "posy" as integer) (getinisetting hpxtl_skin_ini "slider1" "width" as integer) (getinisetting hpxtl_skin_ini "slider1" "height" as integer)
					hpxtl_rect_slider2 = dotNetObject "System.Drawing.Rectangle" (getinisetting hpxtl_skin_ini "slider2" "posx" as integer) (getinisetting hpxtl_skin_ini "slider2" "posy" as integer) (getinisetting hpxtl_skin_ini "slider2" "width" as integer) (getinisetting hpxtl_skin_ini "slider2" "height" as integer)
					hpxtl_rect_range = dotNetObject "System.Drawing.Rectangle" (getinisetting hpxtl_skin_ini "rangebar" "posx" as integer) (getinisetting hpxtl_skin_ini "rangebar" "posy" as integer) (getinisetting hpxtl_skin_ini "rangebar" "width" as integer) (getinisetting hpxtl_skin_ini "rangebar" "height" as integer)
					hpxtl_rect_range_center = dotNetObject "System.Drawing.Rectangle" (getinisetting hpxtl_skin_ini "rangebarcenter" "posx" as integer) (getinisetting hpxtl_skin_ini "rangebarcenter" "posy" as integer) (getinisetting hpxtl_skin_ini "rangebarcenter" "width" as integer) (getinisetting hpxtl_skin_ini "rangebarcenter" "height" as integer)
					hpxtl_rect_trackbar = dotNetObject "System.Drawing.Rectangle" (getinisetting hpxtl_skin_ini "background" "posx" as integer) (getinisetting hpxtl_skin_ini "background" "posy" as integer) (getinisetting hpxtl_skin_ini "background" "width" as integer) (getinisetting hpxtl_skin_ini "background" "height" as integer)
					hpxtl_rect_settings = dotNetObject "System.Drawing.Rectangle" (getinisetting hpxtl_skin_ini "settings" "posx" as integer) (getinisetting hpxtl_skin_ini "settings" "posy" as integer) (getinisetting hpxtl_skin_ini "settings" "width" as integer) (getinisetting hpxtl_skin_ini "settings" "height" as integer)
					hpxtl_rect_preset_active = dotNetObject "System.Drawing.Rectangle" (getinisetting hpxtl_skin_ini "preset_active" "posx" as integer) (getinisetting hpxtl_skin_ini "preset_active" "posy" as integer) (getinisetting hpxtl_skin_ini "preset_active" "width" as integer) (getinisetting hpxtl_skin_ini "preset_active" "height" as integer)
					hpxtl_rect_preset_inactive = dotNetObject "System.Drawing.Rectangle" (getinisetting hpxtl_skin_ini "preset_inactive" "posx" as integer) (getinisetting hpxtl_skin_ini "preset_inactive" "posy" as integer) (getinisetting hpxtl_skin_ini "preset_active" "width" as integer) (getinisetting hpxtl_skin_ini "preset_active" "height" as integer)
					hpxtl_rect_preset_invalid = dotNetObject "System.Drawing.Rectangle" (getinisetting hpxtl_skin_ini "preset_invalid" "posx" as integer) (getinisetting hpxtl_skin_ini "preset_invalid" "posy" as integer) (getinisetting hpxtl_skin_ini "preset_active" "width" as integer) (getinisetting hpxtl_skin_ini "preset_active" "height" as integer)
					hpxtl_rect_keyframes = dotNetObject "System.Drawing.Rectangle" (getinisetting hpxtl_skin_ini "keyframes" "posx" as integer) (getinisetting hpxtl_skin_ini "keyframes" "posy" as integer) (getinisetting hpxtl_skin_ini "keyframes" "width" as integer) (getinisetting hpxtl_skin_ini "keyframes" "height" as integer)
					hpxtl_bitmap_slider1 = hpxtl_bitmap.clone hpxtl_rect_slider1 hpxtl_pixelformat
					hpxtl_bitmap_slider2 = hpxtl_bitmap.clone hpxtl_rect_slider2 hpxtl_pixelformat
					hpxtl_bitmap_range = hpxtl_bitmap.clone hpxtl_rect_range hpxtl_pixelformat
					hpxtl_bitmap_range_center = hpxtl_bitmap.clone hpxtl_rect_range_center hpxtl_pixelformat
					hpxtl_bitmap_trackbar = hpxtl_bitmap.clone hpxtl_rect_trackbar hpxtl_pixelformat
					hpxtl_bitmap_settings = hpxtl_bitmap.clone hpxtl_rect_settings hpxtl_pixelformat
					hpxtl_bitmap_preset_active = hpxtl_bitmap.clone hpxtl_rect_preset_active hpxtl_pixelformat
					hpxtl_bitmap_preset_inactive = hpxtl_bitmap.clone hpxtl_rect_preset_inactive hpxtl_pixelformat
					hpxtl_bitmap_preset_invalid = hpxtl_bitmap.clone hpxtl_rect_preset_invalid hpxtl_pixelformat
					hpxtl_bitmap_keyframes = hpxtl_bitmap.clone hpxtl_rect_keyframes hpxtl_pixelformat
					hpxtl_skin_background_end = getinisetting hpxtl_skin_ini "background_end" "available" as booleanclass
					if (hpxtl_skin_background_end == true) then (
						hpxtl_rect_trackbar_side = dotNetObject "System.Drawing.Rectangle" (getinisetting hpxtl_skin_ini "background_end" "posx" as integer) (getinisetting hpxtl_skin_ini "background_end" "posy" as integer) (getinisetting hpxtl_skin_ini "background_end" "width" as integer) (getinisetting hpxtl_skin_ini "background_end" "height" as integer)
						hpxtl_bitmap_trackbar_side = hpxtl_bitmap.clone hpxtl_rect_trackbar_side hpxtl_pixelformat
					)
					hpxtl_bitmap.dispose()
					return true
			--)
			) catch (
				messagebox "This is not a valid skin!" title:"Extended Timeline"
				return false
			)
		)
	--)
	--( BUILD INTERFACE (AFTER ROLLOUT CREATED)
		function hpxtl_build_interface = (
			hpxtl_rollout.hpxtl_form.backcolor = hpxtl_backgroundcolor
			hpxtl_rollout.hpxtl_form.controls.add hpxtl_control_slider1
			hpxtl_rollout.hpxtl_form.controls.add hpxtl_control_slider2
			hpxtl_rollout.hpxtl_form.controls.add hpxtl_control_range_center
			hpxtl_rollout.hpxtl_form.controls.add hpxtl_control_range
			hpxtl_rollout.hpxtl_form.controls.add hpxtl_control_trackbar
			hpxtl_rollout.hpxtl_presets.backcolor = hpxtl_backgroundcolor
			hpxtl_rollout.hpxtl_buttons.backcolor = hpxtl_backgroundcolor
			hpxtl_rollout.hpxtl_presets.controls.add hpxtl_control_preset_1
			hpxtl_rollout.hpxtl_presets.controls.add hpxtl_control_preset_2
			hpxtl_rollout.hpxtl_presets.controls.add hpxtl_control_preset_3
			hpxtl_rollout.hpxtl_presets.controls.add hpxtl_control_preset_4
			hpxtl_rollout.hpxtl_presets.controls.add hpxtl_control_preset_5
			hpxtl_rollout.hpxtl_buttons.controls.add hpxtl_control_settings
			hpxtl_rollout.hpxtl_buttons.controls.add hpxtl_control_keyframes
			hpxtl_control_tooltip.active = getinisetting hpxtl_inifile "Control" "tooltips" as booleanclass
		)
	--)
	--( RESIZE INTERFACE
		function hpxtl_resize_interface = (
			hpxtl_rollout_pos = getdialogpos hpxtl_rollout
			hpxtl_rollout.hpxtl_presets.pos.x = hpxtl_rollout.width - hpxtl_buttons_width - hpxtl_presets_width - 4
			if (hpxtl_inner_spinners == 120) then (
				hpxtl_rollout.hpxtl_control_zoom_lastframe.pos.x = hpxtl_rollout.width - (18 + hpxtl_buttons_width + (hpxtl_inner_spinners / 2)) - hpxtl_presets_width
				hpxtl_rollout.hpxtl_control_zoom_firstframe.pos.x = 98
			) else (
				hpxtl_rollout.hpxtl_control_zoom_lastframe.pos.x = -100
				hpxtl_rollout.hpxtl_control_zoom_firstframe.pos.x = -100
			)
			hpxtl_rollout.hpxtl_control_lastframe.pos.x = hpxtl_rollout.width - (20 + hpxtl_buttons_width) - hpxtl_presets_width
			hpxtl_rollout.hpxtl_form.width = hpxtl_rollout.width - (120 + hpxtl_inner_spinners + hpxtl_buttons_width + hpxtl_presets_width)
			hpxtl_rollout.hpxtl_form.height = 23
			hpxtl_rollout.hpxtl_form.pos.x = 58 + (hpxtl_inner_spinners / 2)
			hpxtl_rollout.hpxtl_form.pos.y = 1
			hpxtl_rollout.hpxtl_buttons.pos.x = hpxtl_rollout.width - (hpxtl_buttons_width + 4)
			hpxtl_rollout.hpxtl_buttons.width = hpxtl_buttons_width
			hpxtl_control_settings.location.x = hpxtl_buttons_width - hpxtl_data_settings_width
			hpxtl_control_slider1.location.x = 1
			hpxtl_control_slider2.location.x = hpxtl_rollout.hpxtl_form.width - hpxtl_data_slider_width - 1
			hpxtl_control_range.location.x = hpxtl_data_slider_width + 1
			hpxtl_control_range.width = hpxtl_rollout.hpxtl_form.width - (hpxtl_data_slider_width * 2) - 2
			hpxtl_control_range_center.location.x = hpxtl_control_range.location.x + (int(hpxtl_control_range.width / 2)) - 3
			hpxtl_control_trackbar.width = hpxtl_rollout.hpxtl_form.width - 4
			if (hpxtl_skin_background_end == true) then (
				hpxtl_control_trackbar_side_right.location.x = hpxtl_rollout.hpxtl_form.width - (1 + hpxtl_data_trackbar_side_width)
			)
			animationRange = interval hpxtl_animation_start hpxtl_animation_end
			hpxtl_rollout.hpxtl_control_zoom_firstframe.value = hpxtl_animation_zoom_start
			hpxtl_rollout.hpxtl_control_zoom_lastframe.value = hpxtl_animation_zoom_end
		)
	--)
	--( ADD SKIN
		function hpxtl_add_skin skinname = (
			if (hpxtl_load_skin(skinname) == true) then (
				--( ADD IMAGES
					hpxtl_control_slider1.image = hpxtl_bitmap_slider1
					hpxtl_control_slider2.image = hpxtl_bitmap_slider2
					hpxtl_control_range.backgroundimage = hpxtl_bitmap_range
					hpxtl_control_range_center.image = hpxtl_bitmap_range_center
					hpxtl_control_trackbar.backgroundimage = hpxtl_bitmap_trackbar
					hpxtl_control_trackbar_side_right.image = hpxtl_bitmap_trackbar_side
					hpxtl_control_settings.image = hpxtl_bitmap_settings
					hpxtl_control_keyframes.image = hpxtl_bitmap_keyframes
					hpxtl_read_presets()
				--)
				--( SET OBJECT SIZE
					hpxtl_control_slider1.width = hpxtl_data_slider_width
					hpxtl_control_slider2.width = hpxtl_data_slider_width
					hpxtl_control_range_center.width = hpxtl_data_range_center_width
					hpxtl_control_settings.width = hpxtl_data_settings_width
					hpxtl_control_keyframes.width = hpxtl_data_keyframes_width
					hpxtl_control_trackbar_side_right.width = hpxtl_data_trackbar_side_width
					if (getinisetting hpxtl_inifile "control" "innerspinners" as booleanclass) == true then (
						hpxtl_inner_spinners = 120
					) else (
						hpxtl_inner_spinners = 0
					)
					if (getinisetting hpxtl_inifile "control" "keyframes" as booleanclass) == true then (
						hpxtl_buttons_width = hpxtl_data_settings_width + 6 + hpxtl_data_keyframes_width
					) else (
						hpxtl_buttons_width = hpxtl_data_settings_width + 3
					)
					if (getinisetting hpxtl_inifile "control" "presets" as booleanclass) == true then (
						hpxtl_number_of_presets = getinisetting hpxtl_inifile "control" "nofpresets" as integer
						hpxtl_presets_width = (hpxtl_data_preset_width * hpxtl_number_of_presets)+(3 * (hpxtl_number_of_presets-1))
						hpxtl_rollout.hpxtl_presets.width = hpxtl_presets_width
						hpxtl_control_preset_1.location.x = 0
						hpxtl_control_preset_2.location.x = hpxtl_data_preset_width + 3
						hpxtl_control_preset_3.location.x = (hpxtl_data_preset_width * 2) + 6
						hpxtl_control_preset_4.location.x = (hpxtl_data_preset_width * 3) + 9
						hpxtl_control_preset_5.location.x = (hpxtl_data_preset_width * 4) + 12
						hpxtl_control_preset_1.width = hpxtl_data_preset_width
						hpxtl_control_preset_2.width = hpxtl_data_preset_width
						hpxtl_control_preset_3.width = hpxtl_data_preset_width
						hpxtl_control_preset_4.width = hpxtl_data_preset_width
						hpxtl_control_preset_5.width = hpxtl_data_preset_width
					) else (
						hpxtl_presets_width = 0
						hpxtl_rollout.hpxtl_presets.width = 0
						hpxtl_control_preset_1.location.x = 0
						hpxtl_control_preset_2.location.x = hpxtl_data_preset_width + 3
						hpxtl_control_preset_3.location.x = (hpxtl_data_preset_width * 2) + 6
						hpxtl_control_preset_4.location.x = (hpxtl_data_preset_width * 3) + 9
						hpxtl_control_preset_5.location.x = (hpxtl_data_preset_width * 4) + 12
						hpxtl_control_preset_1.width = hpxtl_data_preset_width
						hpxtl_control_preset_2.width = hpxtl_data_preset_width
						hpxtl_control_preset_3.width = hpxtl_data_preset_width
						hpxtl_control_preset_4.width = hpxtl_data_preset_width
						hpxtl_control_preset_5.width = hpxtl_data_preset_width
					)
				--)
				--( ADD ELEMENTS
					try (hpxtl_rollout.hpxtl_form.controls.remove hpxtl_control_trackbar_side_right) catch ()
					if (hpxtl_skin_background_end == true) then (
						hpxtl_rollout.hpxtl_form.controls.add hpxtl_control_trackbar_side_right
					)
				--)
				hpxtl_resize_interface()
				return true
			) else (
				return false
			)
		)
	--)
--)

--( CREATE DIALOG 
	createdialog hpxtl_rollout style:#(#style_border)
	hpxtl_build_interface()
	hpxtl_add_skin(hpxtl_skin)
	cui.RegisterDialogBar hpxtl_rollout minSize:[300,30] style:#(#cui_dock_bottom, #cui_max_sized)
	cui.DockDialogBar hpxtl_rollout #cui_dock_bottom
	--( FIX ROLLOUT HEIGHT
		if (hpxtl_rollout.height < 25) then (
			hpxtl_old_height = hpxtl_rollout.height
			cui.UnRegisterDialogBar hpxtl_rollout
			cui.RegisterDialogBar hpxtl_rollout minSize:[300,(25 + (25 - hpxtl_old_height))] style:#(#cui_dock_bottom, #cui_max_sized)
			cui.DockDialogBar hpxtl_rollout #cui_dock_bottom
		)
	--)
	hpxtl_change_animation_range()
--)

--( ANIMATION RANGE CALLBACK
	--( AFTER FILE OPEN
		function hpxtl_read_presets = (
			for i=1 to 5 do (
				try (hpxtl_slider1_saved_pos = getAppData rootNode (("9806845" + (i as string) + "1") as integer)) catch ()
				try (hpxtl_slider2_saved_pos = getAppData rootNode (("9806845" + (i as string) + "2") as integer)) catch ()
				if ((hpxtl_slider1_saved_pos != undefined) and (hpxtl_slider2_saved_pos != undefined)) then (
					if (hpxtl_slider1_saved_pos as integer < hpxtl_animation_start) or (hpxtl_slider2_saved_pos as integer > hpxtl_animation_end) then (
						execute("hpxtl_control_preset_" + (i as string) + ".image = hpxtl_bitmap_preset_invalid")
					) else (
						execute ("hpxtl_control_preset_" + (i as string) + ".image = hpxtl_bitmap_preset_active")
					)
					execute ("hpxtl_control_preset_" + (i as string) + ".cursor = hpxtl_hand")
					execute ("hpxtl_control_tooltip.SetToolTip hpxtl_control_preset_" + (i as string) + " \"" + (hpxtl_slider1_saved_pos as string) + " - " + (hpxtl_slider2_saved_pos as string) + "\"")
				) else (
					execute ("hpxtl_control_preset_" + (i as string) + ".image = hpxtl_bitmap_preset_inactive")
					execute ("hpxtl_control_preset_" + (i as string) + ".cursor = hpxtl_default")
				)
			)
		)
		function hpxtl_change_animation_range = (
			try (hpxtl_animation_start = (getAppData rootNode 98068461) as integer) catch (hpxtl_animation_start = int(animationRange.start))
			try (hpxtl_animation_end = (getAppData rootNode 98068462) as integer) catch (hpxtl_animation_end = int(animationRange.end))
			try (hpxtl_animation_zoom_start = (getAppData rootNode 98068471) as integer) catch (hpxtl_animation_zoom_start = hpxtl_animation_start)
			try (hpxtl_animation_zoom_end = (getAppData rootNode 98068472) as integer) catch (hpxtl_animation_zoom_end = hpxtl_animation_end)
			hpxtl_rollout.hpxtl_control_firstframe.value = hpxtl_animation_start
			hpxtl_rollout.hpxtl_control_lastframe.value = hpxtl_animation_end
			hpxtl_slider1_stored_pos = hpxtl_animation_start
			hpxtl_slider2_stored_pos = hpxtl_animation_end
			hpxtl_setrange_reverse()
			animationRange = interval hpxtl_animation_zoom_start hpxtl_animation_zoom_end
			hpxtl_rollout.hpxtl_control_zoom_firstframe.value = hpxtl_animation_zoom_start
			hpxtl_rollout.hpxtl_control_zoom_lastframe.value = hpxtl_animation_zoom_end
			hpxtl_rollout.hpxtl_control_zoom_firstframe.range = [hpxtl_animation_start,hpxtl_animation_end,hpxtl_animation_zoom_start]
			hpxtl_rollout.hpxtl_control_zoom_lastframe.range = [hpxtl_animation_start,hpxtl_animation_end,hpxtl_animation_zoom_end]
		)
		hpxtl_read_presets()
		callbacks.addScript #filePostOpenProcess "hpxtl_change_animation_range()" id:#hpxtlchanimrange
		callbacks.addScript #filePostOpenProcess "hpxtl_read_presets()" id:#hpxtlreadpresetsopen
		callbacks.addScript #systemPostNew "hpxtl_read_presets()" id:#hpxtlreadpresetsnew
		callbacks.addScript #systemPostReset "hpxtl_read_presets()" id:#hpxtlreadpresetsreset
	--)
--)
		
--(CHECK FOR UPDATES ON STARTUP
	if ((getinisetting hpxtl_inifile "general" "autoupdate" as booleanclass) == true) then (
		try (
			hpxtl_webrequest = (dotnetclass "net.httpwebrequest").create("http://www.heavenlypictures.hu/maxscript/extendedtimeline/version.php")
			hpxtl_webrequest.timeout = 3000
			hpxtl_webresponse = hpxtl_webrequest.getresponse()
			if (hpxtl_webresponse.statuscode == hpxtl_webresponse.statuscode.ok) then (
				hpxtl_response = (dotnetobject "IO.streamreader" (hpxtl_webresponse.getresponsestream())).readtoend()
				if ((hpxtl_response as float) > (getinisetting hpxtl_inifile "general" "version" as float)) then (
					createdialog hpxtl_update_query style:#(#style_toolwindow)
				)
			) else (
				hpxtl_querybox_response = querybox "Can't connect to heavenlypictures.hu to check for updates! Do you want to turn off the auto-update function?" title:"Extended Timeline"
				if (hpxtl_querybox_response == true) then (
					setinisetting hpxtl_inifile "general" "autoupdate" "false"
				)
			)
		) catch (
			hpxtl_querybox_response = querybox "Can't connect to heavenlypictures.hu to check for updates! Do you want to turn off the auto-update function?" title:"Extended Timeline"
			if (hpxtl_querybox_response == true) then (
				setinisetting hpxtl_inifile "general" "autoupdate" "false"
			)
		)
	)
--)