	-- if (PTH_helper == undefined) do
	-- (
		plugin Helper PTH_helper name:"PTH_helper"  replaceui: false classId:#(8872500, 12324302) extends:Point 
		( 
			local parentID
			local parentHandleID
			local trg
			local vlen
			local lvlen
			local hind
			local sc = 1.0
			local ltvec = 1.0
			local pvlen = 1.0
			local ctrl
			local show_vel
			local type
			local hscale=1.0
			local lx=1
			local ly=1
			local lz=1
			local position2 = [0,0,0]
			local sanity=0
			local ktime =0
			local timehash=0
			local ch=0
			local stime = 0
			local etime = 0
			local tlen = 0
			local ktype = #custom			
			
			local	setBoxSize = (fn setBoxSize obj s = (obj.point_helper.size=s)) 
			
			-- local	setColor = (fn setColor obj c = (obj.wirecolor=c)) 
			
			on create do
			(	
				this.point_helper.size=1
				this.point_helper.centermarker = false
				this.point_helper.axistripod =false 
				this.point_helper.cross = false
				this.point_helper.box = true
				this.point_helper.constantscreensize = true
				this.point_helper.drawontop =true
			)
		)
	-- )
-- macroScript ProTrajectoryHandles category:"JDBgraphics"  
(
 	try(	destroydialog PTH ) catch ()
	
	unregisterRedrawViewsCallback vph_drawlines
	callbacks.removeScripts id:#PTH_cleanup
	callbacks.removeScripts id:#PTH_fixselection

	try(pth_fix.stop()) catch()
	 
	global pth_fix  
	global pth_delayedRebuild
		
	global PTH = "";	
	global pth_version=1600
	global pth_sync=true
	global pth_mode=1
	global pth_is_resetting=false
	global pth_ignore_event=false
	global pth_ignore_event2=false
	global pth_ignore_parent=false
	global pth_selonly=false
	global pth_orderSelection
	global pth_alignOpposite = 0	
	global pth_chk_vel=false
	global pth_usewire=false
	global pth_handles=#()
	global pth_createHelperStructure = 0
	global pth_getCtrl = 0
	global debug = 0
	global pth_rebuild
	global pth_viewAxis = 0
	global pth_addToLayer = 0

	global pth_resetAll = 0
	global pth_outTanToPos = 0
	global pth_inTanToPos = 0
	global pth_PosToTan = 0
	global pth_getMatrix = 0
	global pth_getLinkMatrix = 0
	global pth_rotateObj = 0
	global pth_sanityCheck = 0
	global pth_sanityCheckHdl = 0
	global pth_moveMain = 0
	global pth_moveHandle = 0
	global pth_getTrajectoryDistance = 0
	global pth_strToPos = 0
	global pth_ParentTransform = 0
	global pth_AutoUpdHelperStructure = 0
	global pth_isSelected = 0
	global pth_checkDirect = 0
	global pth_alignOpposite = 0
	global pth_updateHelperStructure = 0
	global pth_updateHandlePos = 0
	global trg=0
	global DeleteHandle = 0
 
	global getSetting= 0
	global setSetting= 0
	global deleteSettings= 0
	global updateTHCheck = 0
	global isLicenced = 0
	global totalts= 0
	global totalte= 0
	global totaltl= 0
	global getKeyTypeHdl= 0
	global updateAutoHandlePos= 0
	global PTHmanageLinks()
	global setKeyType= 0
	global PTHmanageCtrl()

	global updateAllAuto= 0
	global goddevit = false 			
	global checkKeyTypes = 0

	global pth_fixit= 0
	global pth_fixit_count =0 
		
	global pth_delreb= 0
	global pth_dr_count	= 0
	global is_deleting=false	
	global getTrgList= 0
	
	global inertia_updateTrajectory= 0
 	global PTH= 0
	global inertia_drawlines= 0
 	global inertia_getApprox= 0
	global inertia_getSubs= 0
	global inertia_inverted= 0
	global interia_scankey = 0

	global pth_showpath=#()

	global PTHINI = (getdir #userScripts+@"\PTH.ini")
	-- global PTH_DEFAULTINI = (getdir #userScripts+@"\PTH_default.ini")
	
	if not doesfileexist PTHINI then 
	(
		setINISetting  PTHINI "presets" "ps1_name" "Max default"
		setINISetting  PTHINI "presets" "ps1_curve" "10"
		setINISetting  PTHINI "presets" "ps1_bias" "0"
		setINISetting  PTHINI "presets" "ps1_relax" "0.0"
		
		setINISetting  PTHINI "presets" "ps2_name" "iSlide"
		setINISetting  PTHINI "presets" "ps2_curve" "10.0"
		setINISetting  PTHINI "presets" "ps2_bias" "8.5"
		setINISetting  PTHINI "presets" "ps2_relax" "0"

		setINISetting  PTHINI "presets" "ps3_name" "Warp"
		setINISetting  PTHINI "presets" "ps3_curve" "18.7"
		setINISetting  PTHINI "presets" "ps3_bias" "8.8"
		setINISetting  PTHINI "presets" "ps3_relax" "0.0"

		setINISetting  PTHINI "presets" "ps4_name" "Constant"
		setINISetting  PTHINI "presets" "ps4_curve" "10"
		setINISetting  PTHINI "presets" "ps4_bias" "0"
		setINISetting  PTHINI "presets" "ps4_relax" "20.0"

		setINISetting  PTHINI "presets" "ps5_name" "Linear"
		setINISetting  PTHINI "presets" "ps5_curve" "0"
		setINISetting  PTHINI "presets" "ps5_bias" "0"
		setINISetting  PTHINI "presets" "ps5_relax" "0.0"

		setINISetting  PTHINI "presets" "ps6_name" "TickTock"
		setINISetting  PTHINI "presets" "ps6_curve" "11"
		setINISetting  PTHINI "presets" "ps6_bias" "-7"
		setINISetting  PTHINI "presets" "ps6_relax" "0.0"
	)
	-- if not doesfileexist PTH_DEFAULTINI then (createFile PTH_DEFAULTINI;close PTH_DEFAULTINI)


	pth_fix = dotnetobject "System.Timers.Timer"
	pth_delayedRebuild = dotnetobject "System.Timers.Timer"
	
	fn pth_fixit s e =
	(
	 
		if (theHold.holding()==false) do
		(
			pth_fixit_count -= 1
			if (pth_fixit_count< 1) do
			(
				redrawviews()
				setNeedsRedraw()
			)
			pth_fix.stop()
		)
	)		
		
	pth_fix.Interval = 10  
	dotnet.addEventHandler pth_fix "Elapsed" pth_fixit
	
	fn pth_delreb s e =
	(
		if (theHold.holding()==false) do
		(
			pth_dr_count -= 1
			if (pth_dr_count< 1) do
			(
			 	setNeedsRedraw()
			)
		)
		 
	)		
	
	pth_delayedRebuild.Interval = 10  
	dotnet.addEventHandler pth_delayedRebuild  "Elapsed" pth_delreb
	
	fn setKeyType nodes stype  trg  =
	(
		
		buildlist=#()
		sel=#(#(),#())
		
		for obj in nodes do
		(
			if (classof obj == PTH_helper ) do
			(
				appendifunique  buildlist obj.trg	

				type=obj.type
				
				objt=findItem buildlist obj.trg
				
				if (sel[ (objt ) ]==undefined) do (sel[objt]=#())
				sel[objt][ sel[objt].count+1 ] = #(obj.parentID, type) 
				
				if (type==0) do
				(
					if (trg==0 or trg==-1) do
					(
						obj.ctrl.X_position.controller.keys[obj.parentID].inTangentType = stype
						obj.ctrl.Y_position.controller.keys[obj.parentID].inTangentType = stype
						obj.ctrl.Z_position.controller.keys[obj.parentID].inTangentType = stype
					)
					
					if (trg==0 or trg==1) do
					(
						obj.ctrl.X_position.controller.keys[obj.parentID].outTangentType = stype
						obj.ctrl.Y_position.controller.keys[obj.parentID].outTangentType = stype
						obj.ctrl.Z_position.controller.keys[obj.parentID].outTangentType = stype
					)
			 
				)
				
				
				if (type==-1 AND (trg==0 or trg==-1) ) do
				(
					obj.ctrl.X_position.controller.keys[obj.parentID].inTangentType = stype
					obj.ctrl.Y_position.controller.keys[obj.parentID].inTangentType = stype
					obj.ctrl.Z_position.controller.keys[obj.parentID].inTangentType = stype
				)
				
				if (type==1 AND (trg==0 or trg==1)) do
				(
					obj.ctrl.X_position.controller.keys[obj.parentID].outTangentType = stype
					obj.ctrl.Y_position.controller.keys[obj.parentID].outTangentType = stype
					obj.ctrl.Z_position.controller.keys[obj.parentID].outTangentType = stype
				)
			)
		)
			 
		for obj in buildlist do
		(
			pth_resetAll obj true false 
		)
		
		for obj in buildlist do
		(
			for selh  in  sel[ (findItem buildlist obj  ) ] do
			(
				for h in pth_handles do
				(
					if (superclassof h == StructDef   ) then
					(    
						if (h.h_in!=undefined) do
						(				
							if (h.h_in.type==selh[2] AND h.h_in.parentID== selh[1] and h.h_in.trg==obj  ) do
							(
								selectmore h.h_in
							)
						)

				 		if (h.h_out!=undefined) do
						(				
							if (h.h_out.type==selh[2] AND h.h_out.parentID== selh[1] and h.h_out.trg==obj ) do
							(
								selectmore h.h_out
							)
						)
						 
					) else
					(
						if (h!=undefined) do
						(
							if (h.type==selh[2] AND h.parentID== selh[1]  and h.trg==obj) do
							(
								selectmore h
						 	)
						)
					)
				)
			)
		)
		redrawviews()
	)
		

	fn PTHmanageCtrl =
	(
		   obj=(callbacks.notificationParam() )
	)
	

	
	fn PTHmanageLinks =
	(
		   obj=(callbacks.notificationParam() )
			
			if (classof obj != PTH_helper) then
			(
				 
			 	pth_resetAll obj false false
			)					
			
	)
	
	callbacks.removeScripts id:#PTH_ctrl
	callbacks.removeScripts id:#PTH_linkage
	callbacks.addScript #nodeLinked "PTHmanageLinks()" id:#PTH_linkage
	callbacks.addScript #nodeUnLinked "PTHmanageLinks()" id:#PTH_linkage
	
	fn PTHcleanup =
	(
		try(
			pth_fix.stop()
			pth_fix.dispose()
		) catch()
		
		callbacks.removeScripts id:#PTH_linkage
		unregisterRedrawViewsCallback vph_drawlines
		pth_resetAll true false false
		try( destroydialog PTH ) catch()
	)
		
	callbacks.removeScripts id:#PTH_cleanup
	callbacks.removeScripts id:#PTH_fixselection
--	callbacks.addScript #filePreSaveProcess "PTHcleanup()" id:#PTH_cleanup
 	callbacks.addScript #systemPreReset "PTHcleanup()" id:#PTH_cleanup
 	callbacks.addScript #systemPostReset "PTHcleanup()" id:#PTH_cleanup
	callbacks.addScript #systemPostNew "PTHcleanup()" id:#PTH_cleanup
	callbacks.addScript #systemPreNew "PTHcleanup()" id:#PTH_cleanup
	

	fn pth_orderSelection=
	(
		callbacks.removeScripts id:#PTH_fixselection
		
		a1=#()
		a2=#()
		
		for obj in selection do
		(
			if (classof obj == PTH_helper) then
			(
				append a2 obj
			) else
			(
				append a1 obj	
			)
		)
		select (a1+a2)
		callbacks.addScript #selectionSetChanged "pth_orderSelection()" id:#PTH_fixselection
		
	)
	
	callbacks.addScript #selectionSetChanged "pth_orderSelection()" id:#PTH_fixselection

	struct handle   
	(
	  trg, key, h_main, h_in, h_out, pth_ignore_event
	)
	
	fn isLicenced = (
		true
	)
	
	fn updateTHCheck forced =
	(
		frc=forced

		if (getSetting "options" "auto_update_check" == "1") do
		(
			 
			lastCheckTicks =   getINISetting  (getdir #userScripts+@"\PTH.ini") "system" "last_update_check" as Integer64
			if (lastCheckTicks==0L OR lastCheckTicks==undefined) do 
			(
				lastCheckTicks = 0L;
				setINISetting  (getdir #userScripts+@"\PTH.ini") "system" "last_update_check" (0L as string)
			)
			nowTicks = (dotNetClass "System.DateTime").Now.Ticks;
			lastCheckSpan = dotNetObject "System.TimeSpan" (nowTicks - lastCheckTicks);

			if  ((lastCheckSpan.totalDays as integer) > 6 OR frc==true OR  lastCheckTicks==0L) do
			(
				 
				setINISetting  (getdir #userScripts+@"\PTH.ini") "system" "last_update_check" (nowTicks as string)

				rollout httpSock "httpSock" width:0 height:0
				(
					activeXControl port "Microsoft.XMLHTTP" setupEvents:false releaseOnClose:false
				);
				createDialog httpSock pos:[-100,-100] style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)
				destroyDialog httpSock;
		 
				httpSock.port.open "GET" ("http://www.jdbgraphics.nl/updates/check.php?product=pth&version=" + pth_version as string) false;
				httpSock.port.setrequestheader "If-Modified-Since" "Sat, 1 Jan 1900 00:00:00 GMT";
				httpSock.port.send();

				res=httpSock.port.responsetext
				
				if (res=="1") then
				(
					v=((pth_version/100)/10.0) as string 
				
					r=querybox ("Update for ProTrajectoryHandles is available! Go to download page?")
					if (r==true) do
					(
						shellLaunch "	https://jdbgraphics.nl/script/protrajectoryhandles/" ""
					)
				) else
				(
					if (frc==true) do
					(
						messagebox ("您正在使用最新版本!                        ")
					)
				)
			)
		)
	)
	
	rollout PTHs "PTH Settings" width:272 height:112
	(
		button 'btn_Save' "关闭" pos:[200,72] width:64 height:24 align:#left
		GroupBox 'grp5' "更新" pos:[8,10] width:256 height:54 align:#left
		button 'btn_check' "立即检查" pos:[192,29] width:64 height:24 align:#left
		button 'btn_rst' "重置为默认 UI" pos:[8,72] width:112 height:24 align:#left
		checkbox 'chk_autocheck' "每周自动检查更新" pos:[16,34] width:152 height:16 align:#left  
  
		on btn_rst pressed do
		(
				deleteSettings();
				destroydialog PTH
				createdialog PTH style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)
				destroydialog PTHs
		)
  
		on btn_Save pressed do
		(
			try( destroydialog PTHs ) catch () )

		on btn_check pressed do
		(
			updateTHCheck true
			 
			
			)
		on chk_autocheck changed state do
		(
				if ( (getSetting "options" "auto_update_check") == "1" ) then
				(
					setSetting "options" "auto_update_check" "0"
				)  else
				(
					setSetting "options" "auto_update_check" "1"
					updateTHCheck true
				)  
			)
	)
	
	rollout PTH ("PTH v"+ (pth_version /1000.0) as string) width:136 height:896
	(
		radiobuttons 'rdo_ttype' "" pos:[16,611] width:120 height:32 labels:#("Default", "Wire", "Velocity", "None") columns:2 align:#left
		checkbox 'chk_link' "Link/Align 曲柄" pos:[16,184] width:104 height:16 checked:true align:#left tooltip:"是否同时调节曲柄两端"
		radiobuttons 'rdo_mode' "" pos:[16,147] width:76 height:32 labels:#("强度 | Strength", "时间 | Time Scale") columns:1 align:#left
		GroupBox 'grp1' "曲柄" pos:[8,128] width:120 height:264 align:#left
		button 'btn_align' "匹配对面曲柄" pos:[16,208] width:104 height:24 align:#left tooltip:"把另外一段曲柄匹配当前所选端"
		button 'btn_remall' "所有" pos:[80,64] width:40 height:24 align:#left
		GroupBox 'grp2' "轨迹" pos:[8,592] width:120 height:232 align:#left
		GroupBox 'grp3' "ProTrajectory" pos:[8,8] width:120 height:112 align:#left
		button 'btn_Build' "（重新）生成" pos:[16,32] width:104 height:24 align:#left
		checkbox 'chk_pth_selonly' "仅选择帧" pos:[16,96] width:108 height:16 align:#left
		button 'btn_rem' "移除" pos:[16,64] width:64 height:24 align:#left
		label 'lbl4' "  Jonathan de Blok www.jdbgraphics.nl" pos:[24,856] width:96 height:32 align:#left
		button 'btn_setup' "设置" pos:[8,832] width:56 height:16 align:#left		
		button 'btn_help' "帮助" pos:[72,832] width:56 height:16 align:#left	
		checkbox 'chk_lt' "使用更多刷新" pos:[16,664] width:96 height:16 align:#left 
		button 'btn_smt' "Smooth" pos:[40,320] width:56 height:16 align:#left
		button 'btn_lin' "Linear" pos:[40,256] width:56 height:16 align:#left
		button 'btn_stp' "Step" pos:[40,304] width:56 height:16 align:#left
		button 'btn_fst' "Fast" pos:[40,272] width:56 height:16 align:#left
		button 'btn_slw' "Slow" pos:[40,288] width:56 height:16 align:#left
		button 'btn_auto' "Auto" pos:[40,336] width:56 height:16 align:#left
		button 'btn_cst' "Custom" pos:[40,240] width:56 height:16 align:#left
		button 'btn_cst_in' ">" pos:[16,240] width:16 height:16 align:#left
		button 'btn_cst_out' ">" pos:[104,240] width:16 height:16 align:#left
		button 'btn_lin_in' ">" pos:[16,256] width:16 height:16 align:#left
		button 'btn_fst_in' ">" pos:[16,272] width:16 height:16 align:#left
		button 'btn_slw_in' ">" pos:[16,288] width:16 height:16 align:#left
		button 'btn_stp_in' ">" pos:[16,304] width:16 height:16 align:#left
		button 'btn_smt_in' ">" pos:[16,320] width:16 height:16 align:#left
		button 'btn_auto_in' ">" pos:[16,336] width:16 height:16 align:#left
		button 'btn_lin_out' ">" pos:[104,256] width:16 height:16 align:#left
		button 'btn_fst_out' ">" pos:[104,272] width:16 height:16 align:#left
		button 'btn_slw_out' ">" pos:[104,288] width:16 height:16 align:#left
		button 'btn_stp_out' ">" pos:[104,304] width:16 height:16 align:#left
		button 'btn_smt_out' ">" pos:[104,320] width:16 height:16 align:#left
		button 'btn_auto_out' ">" pos:[104,336] width:16 height:16 align:#left
		colorPicker 'cp_slow' "" pos:[14,688] width:25 height:16 color:(color 0 0 255) align:#left
		button 'btn_approx' "获取约值" pos:[16,520] width:104 height:24 align:#left
		colorPicker 'cp_fast' "" pos:[14,711] width:25 height:16 color:(color 255 0 0) align:#left
		spinner 'spn_mult' "@" pos:[40,688] width:82 height:16 range:[0,100000,0] align:#left
		spinner 'spn_fast' "@" pos:[40,712] width:82 height:16 range:[0,100000,10] align:#left
		button 'btn_tv' "曲线 | TrackView" pos:[16,360] width:104 height:24 align:#left
		checkbox 'chk_X' "X" pos:[16,752] width:24 height:16 align:#left
		checkbox 'chk_Y' "Y" pos:[57,752] width:24 height:16 align:#left
		checkbox 'chk_Z' "Z" pos:[93,752] width:24 height:16 align:#left
		label 'lbl4b' "显示方向:" pos:[18,736] width:96 height:16 align:#left
		spinner 'spn_ol' "长度 " pos:[17,776] width:110 height:16 range:[-100000,100000,10] align:#left
		spinner 'spn_oe' "每隔 " pos:[17,800] width:110 height:16 range:[1,100000,1] type:#integer scale:1 align:#left
		checkbox 'chk_hp' "播放时隐藏" pos:[16,648] width:104 height:16 checked:true align:#left
		---
		spinner 'spn_bias' "" pos:[56,448] width:64 height:16 range:[-10,10,0] align:#left
		spinner 'spn_curve' "" pos:[56,424] width:64 height:16 range:[0,100,10] align:#left
		spinner 'spn_rlx' "" pos:[56,472] width:64 height:16 range:[-100000,100000,0] align:#left
		label 'clbl1' "偏移:" pos:[16,448] width:40 height:16 align:#left
		GroupBox 'cgrp1' "Bezier辅助" pos:[8,400] width:120 height:184 align:#left
		label 'clbl2' "曲线:" pos:[16,424] width:40 height:16 align:#left
		label 'clbl3' "张力:" pos:[16,472] width:32 height:16 align:#left
		button 'btn_apply' "更新" pos:[70,496] width:50 height:16 enabled:false align:#left
		checkbox 'chk_live' "自动" pos:[16,496] width:45 height:16 checked:true align:#left
		dropdownList 'ddl1' "" pos:[16,552] width:104 height:21 align:#left
		
		on PTH open do
		(
			 try( spn_mult.value= readValue(StringStream (getSetting  "ui" "gradient_slow" )) ) catch ()
			 try(	spn_fast.value= readValue(StringStream (getSetting  "ui" "gradient_fast" )) ) catch ()
			 try(	cp_slow.color=readValue(StringStream (getSetting  "ui" "gradient_col_slow" )) 	) catch ()
			 try(	cp_fast.color=readValue(StringStream (getSetting  "ui" "gradient_col_fast" )) 	) catch ()
			 try(	chk_live.state= readValue(StringStream (getSetting  "ui" "liveupdate" )) 	) catch ()
			 try(	chk_lt.state= 	 readValue(StringStream (getSetting  "ui" "large_ticks"  )) ) catch ()
			 try(	chk_X.state  = readValue(StringStream (getSetting  "ui" "orientation_x"   )) ) catch ()
			 try(	chk_Y.state  = readValue(StringStream (getSetting  "ui" "orientation_z"  ))  ) catch ()
			 try(	chk_Z.state  = readValue(StringStream (	getSetting  "ui" "orientation_y"  ))  ) catch ()
			 try(	spn_oe.value  = readValue(StringStream (getSetting  "ui" "orientation_nth"  ))  ) catch ()
			 try(	spn_ol.value  =  readValue(StringStream (	getSetting  "ui" "orientation_length"  ))  ) catch ()
			 try(	rdo_ttype.state=readValue(StringStream (	getSetting  "ui" "trajectory_type"  ))    ) catch ()
			try(	rdo_mode.state= pth_mode = readValue(StringStream (	getSetting  "ui" "scale_mode"  ))    ) catch ()
			try(	chk_link.state= pth_sync = readValue(StringStream (getSetting  "ui" "link_handles"  )) ) catch () 
			try(	chk_hp.state= 	 readValue(StringStream (getSetting  "ui" "hide_on_playback"  )) ) catch () 			 
			try(	chk_pth_selonly.state= pth_selonly = readValue(StringStream (getSetting  "ui" "selected_key_only"  )) ) catch () 			 
				
			if (chk_live.state==true) then
			(
				btn_apply.caption="自动"
				btn_apply.enabled = false
			) else
			(
				btn_apply.caption="更新"
				btn_apply.enabled = true
			)

			i=1;
			
			pth.ddl1.items=#("- 预设 -")
			while ( getSetting  "presets" ("ps"+(i as string)+"_name") !=""  AND i<100)   do
			(
				append pth.ddl1.items  (getSetting  "presets" ("ps"+(i as string)+"_name"))
				i=i+1
			)
			
			pth.ddl1.items = pth.ddl1.items

			pth.btn_align.enabled = not pth.chk_link.state
			
		)
		on PTH close do
		(
				pth_resetAll true false false
				unregisterRedrawViewsCallback vph_drawlines
				callbacks.removeScripts id:#PTH_cleanup
				callbacks.removeScripts id:#PTH_fixselection

				delLayerObj = #()

				delLayer    = LayerManager.getLayerFromName "ProTrajectory Handles"
				
				if delLayer != undefined then
				(
					layerRT = delLayer.layerAsRefTarg
					delLayerObj = refs.dependents layerRT
					delLayer.lock = off
					for i in delLayerObj where ((delLayerObj.count != 0) and (classof i == PTH_helper)) do delete i
					LayerManager.deleteLayerByName "ProTrajectory Handles"
					delLayerObj = #()
				)
		)
		on rdo_ttype changed stat do
		(
			
			for obj in pth_showpath do
			(
				setTrajectoryOn obj false
			)
			
			pth_showpath=#()
			
			for obj in selection do
			(
				
				if (classof obj == PTH_helper) then
				(
					appendifunique  pth_showpath obj.trg
									
				) else
				(
					appendifunique  pth_showpath obj
				)
			)
		 
			for obj in pth_showpath do
			(
				if (stat!=1 ) then
				(						
					setTrajectoryOn obj false
				) else
				(
					setTrajectoryOn obj true
				)
				
				if  (stat==4 ) do
				(
					pth_showpath=#()
					setTrajectoryOn obj false
				)	
			
			)
		 
			redrawViews()
			redrawViews()
			setNeedsRedraw()
			
			setSetting  "ui" "trajectory_type" stat
		)
		on chk_link changed state do
		(
				setSetting  "ui" "link_handles" state
				pth_sync=state
				pth.btn_align.enabled = not pth.chk_link.state
		)
		on rdo_mode changed stat do
		(
				setSetting  "ui" "scale_mode" stat
				pth_mode= stat  
		)
		on btn_align pressed do
		(
			for obj in selection do
			(
				if (classof obj == PTH_helper) then
				(
					if (obj.type!=0) do
					(
						pth_alignOpposite obj
						pth_rebuild()
					)
				)
			)
		)
		on btn_remall pressed do
		(
			pth_resetAll true false false

			delLayerObj = #()

			delLayer    = LayerManager.getLayerFromName "ProTrajectory Handles"
			
			if delLayer != undefined then
			(
				layerRT = delLayer.layerAsRefTarg
				delLayerObj = refs.dependents layerRT
				delLayer.lock = off
				for i in delLayerObj where ((delLayerObj.count != 0) and (classof i == PTH_helper)) do delete i
				LayerManager.deleteLayerByName "ProTrajectory Handles"
				delLayerObj = #()
			)
		)
		on btn_Build pressed do
		(
			
				pth_rebuild()
			 
				redrawviews()
			)
		on chk_pth_selonly changed state do
		(
		 
				pth_selonly = state
			 	setSetting  "ui" "selected_key_only" state
		)
		on btn_rem pressed do
		(
			
			
			buildlist=#()
			
			for obj in selection do
			(
				
				if (classof obj == PTH_helper) then
				(
					appendifunique  buildlist obj.trg
									
				) else
				(
					appendifunique  buildlist obj
				)
			
			)
			
			
			for obj in buildlist do
			(
			 
				pth_resetAll obj false false
			)
			
			delLayerObj = #()

			delLayer    = LayerManager.getLayerFromName "ProTrajectory Handles"
			
			if delLayer != undefined then
			(
				layerRT = delLayer.layerAsRefTarg
				delLayerObj = refs.dependents layerRT
				delLayer.lock = off
				for i in delLayerObj where ((delLayerObj.count != 0) and (classof i == PTH_helper)) do delete i
				LayerManager.deleteLayerByName "ProTrajectory Handles"
				delLayerObj = #()
			)
		)
		on btn_setup pressed do
		(
				wup=false
				createdialog PTHs style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)
			
			if ( getSetting "options" "auto_update_check" == "1" ) do ( PTHs.chk_autocheck.checked=true)
		
			
		)
		on btn_help pressed do
		(
			 	shellLaunch "https://jdbgraphics.nl/script/protrajectoryhandles/" "" 
		
		
			
		)
		on chk_lt changed state do
		(
			setSetting  "ui" "large_ticks" state
			redrawViews()
			setNeedsRedraw()
		)
		on btn_smt pressed do
		(
		setKeyType selection  #smooth  0 
			)
		on btn_lin pressed do
		(
			setKeyType selection  #linear  0 
			)
		on btn_stp pressed do
		(
			setKeyType selection  #step  0 
			)
		on btn_fst pressed do
		(
			setKeyType selection  #fast  0 
			)
		on btn_slw pressed do
		(
			setKeyType selection  #slow  0 
			)
		on btn_auto pressed do
		(
			setKeyType selection  #auto  0 
			)
		on btn_cst pressed do
		(
			setKeyType selection  #custom  0 
			)
		on btn_cst_in pressed do
		(
			setKeyType selection  #custom -1 
		)
		on btn_cst_out pressed do
		(
			setKeyType selection  #custom 1
			)
		on btn_lin_in pressed do
		(
			setKeyType selection  #linear -1 
			)
		on btn_fst_in pressed do
		(
			setKeyType selection  #fast -1 
			)
		on btn_slw_in pressed do
		(
			setKeyType selection  #slow -1 
			)
		on btn_stp_in pressed do
		(
			setKeyType selection  #step -1 
			)
		on btn_smt_in pressed do
		(
			setKeyType selection  #smooth -1 
			)
		on btn_auto_in pressed do
		(
			setKeyType selection  #auto -1 
			)
		on btn_lin_out pressed do
		(
		setKeyType selection  #linear 1
			)
		on btn_fst_out pressed do
		(
		setKeyType selection  #fast 1
			)
		on btn_slw_out pressed do
		(
		setKeyType selection  #slow 1
			)
		on btn_stp_out pressed do
		(
		setKeyType selection  #step 1
			)
		on btn_smt_out pressed do
		(
		setKeyType selection  #smooth 1
			)
		on btn_auto_out pressed do
		(
		setKeyType selection  #auto 1
			)
		on cp_slow changed col do
		(
			setSetting  "ui" "gradient_col_slow" col
			
			redrawViews()
			)
		on btn_approx pressed do
		(
		
			
			r=inertia_getApprox()
			if (r!=false) do
			(
				spn_bias.value=r[1]
				spn_curve.value=r[2]
				spn_rlx.value=r[3]
			)
			
			)
		on cp_fast changed col do
		(
				setSetting  "ui" "gradient_col_fast" col
			redrawViews()
			)
		on spn_mult changed val do
		(
			setSetting  "ui" "gradient_slow" val
		
			
			if (val>= pth.spn_fast.value) do ( pth.spn_fast.value=val+0.2  )
			redrawViews()
					
		)
		on spn_fast changed val do
		(
					setSetting  "ui" "gradient_fast" val
			if (val<= pth.spn_mult.value) do ( pth.spn_mult.value=val-0.2  )
			redrawViews()
					
		)
		on btn_tv pressed do
		( 
			
			buildlist=  selection
			if (buildlist.count >0 ) then
			(
				
				if (trackviews.exists "PTH") then
				(	
					trackviews.open "PTH"  
				) else
				(
					trackviews.open "PTH"  
					actionMan.executeAction 1 "2110"
					trackviews.current.ui.loadLayout "Function Curve Layout"
					trackviews.current.clearFilter #all
					trackviews.current.setFilter #default 
				)
								 
				trackviews.current.manualNavigation = false
				trackviews.current.expandTracks()
				trackviews.current.interactiveUpdate = true
				trackviews.current.selectTrack buildlist[1]  true
				 
				 for obj in buildlist do
				 (
					trackviews.current.selectTrack  obj  false
					trackviews.current.selectTrack  obj.pos.controller.X_Position.controller  false
					trackviews.current.selectTrack  obj.pos.controller.Y_Position.controller  false
					trackviews.current.selectTrack  obj.pos.controller.Z_Position.controller  false
					trackviews.current.selectTrack  obj.rotation.controller.Xrotation.controller  false
					trackviews.current.selectTrack  obj.rotation.controller.Yrotation.controller  false
					trackviews.current.selectTrack  obj.rotation.controller.Zrotation.controller  false
				 )
				 
				trackviews.current.setfilter #selectedTracks
				trackviews.current.manualNavigation = true
			) 
			else
			(
				messagebox "选择不能为空!                   "
			)
			
		)
		
		on chk_X changed state do
		(	setSetting  "ui" "orientation_x" state
			redrawViews()  
			)
		on chk_Y changed state do
		(	redrawViews()  
		setSetting  "ui" "orientation_y" state
			)
		on chk_Z changed state do
		(
			setSetting  "ui" "orientation_z" state
			redrawViews()  
			)
		on spn_ol changed val do
		(setSetting  "ui" "orientation_length" val
			redrawViews()  
			)
		on spn_oe changed val do
		(	setSetting  "ui" "orientation_nth" val
			redrawViews()  
			)
		on chk_hp changed state do
		(
					setSetting  "ui" "hide_on_playback" state
			redrawViews()
			setNeedsRedraw()
		)
		on spn_bias changed val do
		(
			if (chk_live.state==true) do
			(
				inertia_updateTrajectory()
			)
		
		)
		on spn_curve changed val do
		(
				if (chk_live.state==true) do
			(
				inertia_updateTrajectory()
			)
			)
		on spn_rlx changed val do
		(
			if (chk_live.state==true) do
			(
				inertia_updateTrajectory()
			)
			)
		on btn_apply pressed do
		(
				inertia_updateTrajectory()
			)
		on chk_live changed state do
		(
		 
			btn_apply.enabled = true
			btn_apply.caption="更新"
			if (state==true) do
			(
				btn_apply.caption="自动"
				btn_apply.enabled = false
				)
				
					setSetting  "ui" "liveupdate" state
			
			)
		on ddl1 selected sel do
		(
			if (ddl1.selection!=1) do
			(
				spn_curve.value = (getSetting  "presets" ("ps"+((ddl1.selection-1) as string)+"_curve")) as float
				spn_bias.value = (getSetting  "presets" ("ps"+((ddl1.selection-1) as string)+"_bias")) as float
				spn_rlx.value = (getSetting  "presets" ("ps"+((ddl1.selection-1) as string)+"_relax")) as float
				
				ddl1.selection = 1
				
				if (chk_live.state==true) do
				(
					inertia_updateTrajectory()
				)
			
			)
		)
	)
	
	-- fn getDefSetting cat var =
	-- (
	-- 	data=getINISetting  (getdir #userScripts+@"\PTH_default.ini") cat var
	-- 	data
	-- )
	
	
	fn getSetting cat var = (
		data=getINISetting  (getdir #userScripts+@"\PTH.ini") cat var
		data
	)
	
	fn setSetting cat var val= (
		setINISetting  (getdir #userScripts+@"\PTH.ini") cat var (val as string)
	)
	
	fn deleteSettings = (
			
		delIniSetting  (getdir #userScripts+@"\PTH.ini") "ui"  
	)
	
	
	fn DeleteHandle index type =
	(
		
		if (superclassof pth_handles[index] == StructDef   ) then
		(    
			if (type ==1 ) do
			(
				pth_handles[index].h_out=undefined
			)
			
			if (type ==-1 ) do
			(
				pth_handles[index].h_in=undefined
			)
		 
			if (type == 0 ) do
			(
				pth_handles[index].h_main=undefined
			)
		)
		
		if ( classof pth_handles[index] == PTH_helper   ) then 
		(
		   key=pth_handles[index].parentID
		   trg=pth_handles[index].trg
			
			for i =  1 to pth_handles.count do
			(
				if (superclassof pth_handles[i]== StructDef   ) then
				( 
					dump=false
					if (pth_handles[i].h_in != undefined) do
					(
						if (pth_handles[i].h_in.parentHandleID==index ) do ( delete pth_handles[i].h_in; dump=true  ) 
					)
					
					if (pth_handles[i].h_out != undefined) do
					(
						if (pth_handles[i].h_out.parentHandleID==index ) do ( delete pth_handles[i].h_out; dump=true  ) 
					) 

					if (pth_handles[i].h_main.trg==trg AND pth_handles[i].h_main.parentID==key   ) do (  pth_handles[i].h_main=undefined; dump=true  ) 

					if (dump==true) do
					(
						pth_handles[i]=undefined
					)
				)
			)
				 
			pth_handles[index]=undefined	
		)
	)
	
	global _user32 =
	(
		source = "using System;\n"
		source += "using System.Runtime.InteropServices;\n"
		source += "class User32\n"
		source += "{\n"
		source += " [DllImport(\"user32.dll\")]\n"
		source += " public static extern IntPtr GetActiveWindow();\n"
		source += "}\n"

		try 
		(
			csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
			compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
	
			compilerParams.GenerateInMemory = on
			compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
			compilerResults.CompiledAssembly.CreateInstance "User32"
		)
		catch
		(
			local CSharpCompilationHelper = dotnetclass "CSharpUtilities.CSharpCompilationHelper"
			CSharpCompilationHelper.compile source #()
			dotnetclass "User32"
		)
	)

	fn debug str=
	(
	 --   print str	
	)
	
	fn pth_rebuild =
	(
		buildlist=#()
		for obj in selection do
		(
			if (classof obj == PTH_helper) then
			(
				appendifunique  buildlist obj.trg						
			) else
			(
				appendifunique  buildlist obj
			)
		)
		 
	 
		
		for obj in buildlist do
		(
			pth_resetAll obj true false
		)
	)
	
	fn getTrgList sel =
	(
		sel = sel as array
		buildlist=#()
		hp= helpers as array
			
		for n in sel do
		(
			if (classof n == PTH_helper)
			do(
				if (n.trg != undefined  ) do
				(
					appendifunique buildlist n.trg
				)		
			)
				
					
			for obj in hp do
			(
				if (classof obj == PTH_helper) do ( 
					if (obj.trg == n) do
					(
						appendifunique buildlist n
					)		
				) 
			)
		)
		buildlist
	)


	fn pth_viewAxis =
	(
		local coordSysTM = Inverse(getViewTM())
		local viewDir = -coordSysTM.row3
			
		t=[viewDir.x, viewDir.y,viewDir.z]
		return  t
	)

	fn pth_addToLayer obj =
	(
		if (LayerManager.getLayerFromName "ProTrajectory Handles"==undefined) do
		(
			 LayerManager.newLayerFromName "ProTrajectory Handles"	
		)

		PTlayer = LayerManager.getLayerFromName "ProTrajectory Handles"
		PTlayer.addnode obj
	)

	fn pth_getCtrl obj =
	(	
		if (classof obj != Biped_Object) then
		(
			ctrl=obj.position.controller

			if (classof ctrl==position_xyz) do
			(
				return ctrl
			)

			if (classof ctrl==Position_List) do
			(
				i=ctrl.getActive() 
				
				try(
					if (classof  ctrl[i].x_position.controller == Bezier_Float AND classof  ctrl[i].y_position.controller == Bezier_Float AND classof  ctrl[i].z_position.controller == Bezier_Float) do
					(
						return ctrl[i]
					)
				) catch ()
			)
			
			messageBox ("在节点上找不到可用的控制器："+ obj.name+"\r\n\r\n应该是带有 3 个 “Bezier_Float” 子控制器的 “Position_XYZ”。                                                           ")
			return false
		)
		else (messageBox ("暂时不支持 Biped 物体："+ obj.name+"\r\n\r\n已中断，请重试！                                                 ");return false)
	)

	fn pth_resetAll trg rebuild delayed=
	(
	 

		with undo off
		(
		
		delayed= false
		
		if (delayed==true) then
		(						
			return false
			--fix this
			pth_dr_count =3
			pth_delayedRebuild.stop()
			pth_delayedRebuild.start()
			return false
		)
	 
		global pth_ignore_event=false
		global pth_ignore_event2=false
		global pth_ignore_parent=false
	
	 
		if (trg == true) then
		(
			 
			deleteAllChangeHandlers id:#vphmain
			deleteAllChangeHandlers id:#vph
			
			buildlist=#()
			
			hp= helpers as array
			for obj in hp do
			(
				if (classof obj == PTH_helper) do
				( 
					if (obj.trg != undefined) do
					(
						appendifunique buildlist obj.trg
						try( setTrajectoryOn obj.trg false ) catch ()
					)		
					
					if (obj!=undefined) do
					(
						try( delete obj ) catch ()
					)
				) 
			)

			pth_handles=#()
			
			
			if (rebuild==true) then
			(				
					for trg in buildlist do
					(
					 
						setTrajectoryOn trg (pth.rdo_ttype.state==1)
						pth_createHelperStructure trg  (pth_getCtrl trg) 		
					)
			)
			
		 
		) else
		(
			-- cleat all helpers belonging to target
			hc=pth_handles.count-1
			os = 0

			for i = 0 to (hc) do
			(
				j=hc - i   + 1
				hdl=pth_handles[j]
				
				if (hdl!=undefined) do
				(
					 
				  oke=true
					try (
					if (superclassof hdl == PTH_helper ) do ( oke=true)
						
					) catch (
						oke=false
						 
					)
				 
					if (oke==true )
					then
					(							
					
						if (superclassof hdl ==  helper   ) then
						(   			
							if (hdl.trg==trg or isdeleted trg) do
							(
								 if ( hdl.ch!=0) do
								 (
									--	deleteChangeHandler hdl.ch
								 )
								 is_deleting = true
								delete hdl
								 is_deleting = false
								 pth_handles[j]=undefined
							)
						)
					
						try(  if (isdeleted hdl == true ) do ( hdl=undefined; ) ) catch ()
					 
						if (superclassof hdl == StructDef   ) then
						(  
							if ( pth_handles[j]!=undefined) do
							(
								 is_deleting = true
									try (if (hdl.trg==trg) do (   pth_handles[j]=undefined )) catch ()
									try (if (hdl.trg==trg) do ( delete hdl.h_in;  pth_handles[j]=undefined )) catch ()
									try (if (hdl.trg==trg) do ( delete hdl.h_out;  pth_handles[j]=undefined  )) catch ()
								 is_deleting = false
							)
						)
					)  
					else
					(
						pth_handles[j]=undefined	
					)
				)
			)
			 ----------------------------------------
					
			hp= helpers as array
			for obj in hp do
			(
		 --		if (classof obj == PTH_helper and obj.trg==trg) do ( print obj; delete obj; ) 
			)
				
			if (rebuild==true) then
			(	
				 
				setTrajectoryOn trg (pth.rdo_ttype.state==1)
				pth_createHelperStructure trg  (pth_getCtrl trg) 
			)
			else
			(
				if (trg!=undefined) do
				(
					try(setTrajectoryOn trg false ) catch()
				)
			)
		)
			
		global pth_ignore_event=false
		global pth_ignore_event2=false
		global pth_ignore_parent=false	

		redrawViews() 	
		)
	)

	fn pth_outTanToPos ctrl  key hscale  =
	(

			tx = tan(ctrl.X_position.controller.keys[key].outTangent * hscale)  
			ty = tan(ctrl.Y_position.controller.keys[key].outTangent * hscale)  
			tz = tan(ctrl.Z_position.controller.keys[key].outTangent * hscale)  
			px = asin ( tx / sqrt(1+tx*tx) ) 
			py = asin ( ty / sqrt(1+ty*ty) ) 
			pz = asin ( tz / sqrt(1+tz*tz) ) 
	 
			[px,py,pz]
	)

	fn pth_inTanToPos ctrl  key hscale =
	(
			tx = tan(ctrl.X_position.controller.keys[key].inTangent * hscale)
			ty = tan(ctrl.Y_position.controller.keys[key].inTangent * hscale)
			tz = tan(ctrl.Z_position.controller.keys[key].inTangent * hscale)
			px = asin ( tx / sqrt(1+tx*tx) ) 
			py = asin ( ty / sqrt(1+ty*ty) ) 
			pz = asin ( tz / sqrt(1+tz*tz) ) 
			[px,py,pz]  
	)


	fn pth_PosToTan pos hdist =
	(
			x=atan( sin((pos.x) / hdist) ) 
			y=atan( sin((pos.y) / hdist) ) 
			z=atan( sin((pos.z) / hdist) )
			
			[x,y,z]	 
	)

	fn pth_getMatrix trg =
	(
		if (trg.parent!=undefined) then
		(
			mx=trg.parent.transform as matrix3
		) else
		(
			mx=matrix3 1
		)
		
		mx
	)
		
		
	fn pth_getLinkMatrix obj sp kp hp =
	(
			
		va=pth_viewAxis()
		ova=va
		if (abs(va.x) > abs(va.y) and abs(va.x)> abs(va.z) ) do (va=[ (va.x/abs(va.x))*1.0 , 0.0 , 0.0] )
		if (abs(va.y) > abs(va.z) and abs(va.y)> abs(va.x) ) do (va=[ 0.0, (va.y/abs(va.y))*1.0 , 0.0 ] )
		if (abs(va.z) > abs(va.x) and abs(va.z)> abs(va.y) ) do (va=[ 0.0, 0.0, (va.z/abs(va.z))*1.0 ] )
		
			
		if (  floor  (abs((va.x-ova.x + va.y-ova.y + va.z- ova.z)*10000)  )!=0   ) do
		(
			in coordsys world ( xc =	sp - hp )
			if (xc.x!=0) do (xc.x=xc.x/abs(xc.x))
			if (xc.y!=0) do (xc.y=xc.y/abs(xc.y))
			if (xc.z!=0) do (xc.z=xc.z/abs(xc.z))
		)
 
		pva=[1-abs(va.x), 1-abs(va.y), 1-abs(va.z) ]
		dc=(va.x+va.y+va.z)*-1
		
		in coordsys world
		(			 
			a =  acos  (dot  (normalize((sp*pva)  - (kp*pva ) )) (normalize((obj.position*pva) - (kp*pva)))  )    
			bz=normalize  (cross  (normalize((sp*pva)  - (kp*pva )))  (normalize ((obj.position*pva) - (kp*pva))))  
			az=  AngleAxis a (va*bz*dc)
		)
		
		az as matrix3
	)
	 
	fn pth_rotateObj obj rx ry rz =
	(
		obj.transform = scaleMatrix obj.transform.scale * transMatrix obj.transform.pos
		rotate obj (angleaxis rx [1,0,0])
		rotate obj (angleaxis ry [0,1,0])
		rotate obj (angleaxis rz [0,0,1])
	)

	fn pth_sanityCheck ctrl =
	(
		sanity=true
		
		for i=1 to (ctrl.Z_position.controller.keys.count ) do
		( 
			key_x=ctrl.X_position.controller.keys[i]
			key_y=ctrl.Y_position.controller.keys[i]
			key_z=ctrl.Z_position.controller.keys[i]

			if ( key_x!=undefined and key_y!=undefined and key_z!=undefined ) then
			(
				key_xc=ctrl.X_position.controller.keys[i].time
				key_yc=ctrl.Y_position.controller.keys[i].time
				key_zc=ctrl.Z_position.controller.keys[i].time
				if (key_xc != key_yc or key_yc != key_zc or key_xc != key_zc) do (sanity = false;  )
		
			) else
			(
				sanity = false	
			)
		)
		
		sanity
	)

	fn pth_sanityCheckHdl hdl =
	(
		ctrl=hdl.ctrl
		
		sanity=pth_sanityCheck ctrl
		
		if (sanity==true) do
		(
			if (hdl.sanity != ctrl.X_position.controller.keys.count or  hdl.sanity != ctrl.Y_position.controller.keys.count or hdl.sanity != ctrl.Z_position.controller.keys.count) do
			(
			 sanity= false	
			)
		)
		
		sanity
	)

	fn pth_moveMain hdl =
	(	 
		
		pth_fixit_count =3
		pth_fix.stop()
		pth_fix.start()
		
		if (animButtonState==true) do
		(
			animButtonState = false
		)
		
		if (pth_ignore_event==false ) do
		(
			pth_ignore_event=true;
			hdl.scale= [1,1,1]
					
			if (pth_isSelected hdl  >0) do
			(
				at time hdl.ctrl.X_position.controller.keys[hdl.parentID].time
				(					
					in coordsys  (pth_getMatrix hdl.trg)
					(
						 
						hdl.ctrl.X_position.controller.keys[hdl.parentID].value+=   hdl.position.x  - hdl.trg.position.x
						hdl.ctrl.Y_position.controller.keys[hdl.parentID].value+=   hdl.position.y - hdl.trg.position.y 
						hdl.ctrl.Z_position.controller.keys[hdl.parentID].value+=   hdl.position.z - hdl.trg.position.z  
					)
				)
				
				pth_ignore_event=false;
				if ((  pth_handles[hdl.hind].h_in!=undefined)  ) do
				(	 
					  pth_moveHandle   pth_handles[hdl.hind] -1
				)
			
				if ((pth_handles[hdl.hind].h_out!=undefined)  ) do
				(	 
					pth_moveHandle   pth_handles[hdl.hind] 1
				)
				
				pth_ignore_event=true;
				obj=hdl
				 
				deleteKeys obj.position.controller.X_position.controller #allKeys	
				deleteKeys obj.position.controller.Y_position.controller #allKeys	
				deleteKeys obj.position.controller.Z_position.controller #allKeys
			)
				
		   pth_ignore_event=false;	
		)
	)

	fn pth_moveHandle hdl type=
	(  
		debug "move handel"
		try
		(
			with animate off
			(
				if (superclassof hdl == StructDef) then
				(
					if (hdl.h_out!=undefined) do
					(
						obj=hdl.h_out
						deleteKeys obj.position.controller.X_position.controller #allKeys	
						deleteKeys obj.position.controller.Y_position.controller #allKeys	
						deleteKeys obj.position.controller.Z_position.controller #allKeys	
						deleteKeys obj.scale.controller #allKeys
						deleteKeys obj.rotation.controller #allKeys
					)
					
					if (hdl.h_in!=undefined) do
					(
						obj=hdl.h_in
						deleteKeys obj.position.controller.X_position.controller #allKeys	
						deleteKeys obj.position.controller.Y_position.controller #allKeys	
						deleteKeys obj.position.controller.Z_position.controller #allKeys
						deleteKeys obj.scale.controller #allKeys
						deleteKeys obj.rotation.controller #allKeys
					)		

					if (hdl.h_main!=undefined) do
					(
						obj=hdl.h_main
						deleteKeys obj.position.controller.X_position.controller #allKeys	
						deleteKeys obj.position.controller.Y_position.controller #allKeys	
						deleteKeys obj.position.controller.Z_position.controller #allKeys
						deleteKeys obj.scale.controller #allKeys
						deleteKeys obj.rotation.controller #allKeys
					)	
				
				) else
				(
						deleteKeys hdl.position.controller.X_position.controller #allKeys	
						deleteKeys hdl.position.controller.Y_position.controller #allKeys
						deleteKeys hdl.position.controller.Z_position.controller #allKeys
						deleteKeys hdl.scale.controller #allKeys
						deleteKeys hdl.rotation.controller #allKeys
				)
				
				if (pth_ignore_parent == false) do
				(

					delta = 1
					direct=pth_checkDirect()
					
					if (type==-1  ) then
					(			
						obj=hdl.h_in
						delta= (  1-(obj.scale.x - obj.pvlen))  
						 
						if (pth_mode == 1) do
						(					
								obj.hscale *=delta	 
						)
						
						if (pth_mode == 2) do
						(
							obj.sc  *= delta
							if (obj.sc<0.003)  do ( obj.sc=0.003)
						)
						
						obj.pvlen =obj.scale.x						
						obj.scale= [1,1,1]
					)
				
				
					if (type==1  ) then
					(			
					
						obj=hdl.h_out		
						delta= (  1-(obj.scale.x - obj.pvlen))  
						 
						if (pth_mode == 1) do
						(					
							obj.hscale *=delta	 
						)
						
						if (pth_mode == 2) do
						(
							obj.sc  *= delta
							if (obj.sc<0.003)  do ( obj.sc=0.003)
						)
						obj.pvlen =obj.scale.x						
						obj.scale= [1,1,1]
						
					)	
				
					if ( pth_ignore_event == false) do
					(
						pth_ignore_event=true;

						if (type!=0  ) do
						(
							trg=hdl.trg
						 
							i=hdl.key
							obj=hdl.h_main
							key_x=obj.ctrl.X_position.controller.keys[i]
							key_y=obj.ctrl.Y_position.controller.keys[i]
							key_z=obj.ctrl.Z_position.controller.keys[i]
							
							kpos = [key_x.value, key_y.value, key_z.value]
							pkey_x=obj.ctrl.X_position.controller.keys[i+type]
							pkey_y=obj.ctrl.Y_position.controller.keys[i+type]
							pkey_z=obj.ctrl.Z_position.controller.keys[i+type]
						   
							keytime= obj.ctrl.X_position.controller.keys[i].time
							 
							if (type==-1   ) then
							(			
				
								obj=hdl.h_in
								vlen=obj.vlen
								hscale= obj.hscale 
								sca=  obj.sc
								
								if ((pth_isSelected obj) != 0 and pth_mode == 2)
								then
								(
									l= obj.ltvec 
									obj.ctrl.x_position.controller.keys[i].inTangentLength = l.x * sca
									obj.ctrl.y_position.controller.keys[i].inTangentLength = l.y * sca
									obj.ctrl.z_position.controller.keys[i].inTangentLength = l.z * sca
									
									if (pth_sync == true and hdl.h_out!=undefined) do
									(	
										l= hdl.h_out.ltvec 						
										obj.ctrl.x_position.controller.keys[i].outTangentLength  =   l.x * hdl.h_out.sc
										obj.ctrl.y_position.controller.keys[i].outTangentLength  =   l.y * hdl.h_out.sc
										obj.ctrl.z_position.controller.keys[i].outTangentLength  =   l.z * hdl.h_out.sc
									)
								)
					
								ltvec=(length  [key_x.inTangentLength, key_y.inTangentLength, key_z.inTangentLength ]  )  

								at time keytime
								(
									in coordsys  (pth_getMatrix trg)
									(
										if (distance obj.position   trg.position == 0 ) then (   obj.setBoxSize obj 15 ) else ( obj.setBoxSize obj 6)
										obj.position2= (pth_inTanToPos obj.ctrl i  (hscale)   ) * ( ltvec *  vlen  ) + trg.position
										it=((pth_PosToTan ((obj.position - trg.position)  ) ( ((vlen ) / 3)   ) )   / ( hscale ))  / sca
										obj.ctrl.x_position.controller.keys[i].inTangent = it.x 
										obj.ctrl.y_position.controller.keys[i].inTangent =  it.y 
										obj.ctrl.z_position.controller.keys[i].inTangent =  it.z 
									)
								)
						
						
								if (pth_sync==true AND hdl.h_out!=undefined AND pth_isSelected hdl.h_out == 0 AND pth_isSelected hdl.h_main == 0 AND pth_isSelected hdl.h_in != 0 AND direct == true ) do
								(
									at time keytime 
									(
										sp=obj.position2 
										in coordsys world ( kp= trg.position )
									)
				 
									in coordsys world
									(					
										l1=distance hdl.h_out.position   kp 	
										l2=distance hdl.h_in.position  kp		 	
										hdl.h_out.position= kp + ((kp - hdl.h_in.position )	/ (l2/l1))
									)
									
									at time keytime
									(
										in coordsys (pth_getMatrix trg)
										(			
											it=((pth_PosToTan ((hdl.h_out.position-trg.position)  ) ( ((hdl.h_out.vlen ) / 3)   ) )   / ( hdl.h_out.hscale ))  / hdl.h_out.sc							
											obj.ctrl.x_position.controller.keys[i].outTangent = it.x 
											obj.ctrl.y_position.controller.keys[i].outTangent = it.y 
											obj.ctrl.z_position.controller.keys[i].outTangent = it.z
										)
									)
								)		 
							) 
				
			 
							if (type==1  ) then
							(			
							
								obj=hdl.h_out
								vlen=obj.vlen
								hscale= obj.hscale 
								sca=  hdl.h_out.sc
								
								if ((pth_isSelected hdl.h_out) != 0 and pth_mode == 2)
								then
								(
									l= hdl.h_out.ltvec 
									obj.ctrl.x_position.controller.keys[i].outTangentLength = l.x * sca
									obj.ctrl.y_position.controller.keys[i].outTangentLength = l.y * sca
									obj.ctrl.z_position.controller.keys[i].outTangentLength = l.z * sca
									
									if (pth_sync == true and hdl.h_in!=undefined ) do
									(				
										l= hdl.h_in.ltvec 							
										obj.ctrl.x_position.controller.keys[i].inTangentLength  =  l.x * hdl.h_in.sc 
										obj.ctrl.y_position.controller.keys[i].inTangentLength  =   l.y * hdl.h_in.sc 
										obj.ctrl.z_position.controller.keys[i].inTangentLength  =  l.z * hdl.h_in.sc 
									)
								)
								
								ltvec=(length  [key_x.inTangentLength, key_y.inTangentLength, key_z.inTangentLength ]  )  


								at time keytime
								(
									in coordsys  (pth_getMatrix trg)
									(
										
										if (distance obj.position   trg.position == 0 ) then (   obj.setBoxSize obj 25 ) else ( obj.setBoxSize obj 6)
										
										obj.position2= (pth_outTanToPos obj.ctrl i  (hscale)   ) * ( ltvec *  vlen  ) + trg.position
										it=((pth_PosToTan ((obj.position-trg.position)  ) ( ((vlen ) / 3)   ) )   / ( hscale ))  / sca
										
										obj.ctrl.x_position.controller.keys[i].outTangent = it.x 
										obj.ctrl.y_position.controller.keys[i].outTangent =  it.y 
										obj.ctrl.z_position.controller.keys[i].outTangent =  it.z 
									)
								)
						
							
								if (pth_sync==true AND hdl.h_in!=undefined AND pth_isSelected hdl.h_in == 0 AND pth_isSelected hdl.h_main == 0 AND pth_isSelected hdl.h_out != 0 AND direct == true ) do
								(
								
									at time keytime 
									(
										sp=obj.position2 * (pth_getMatrix trg)
										in coordsys world ( kp= trg.position )
									)
				 
									in coordsys world
									(					
									 
										l1=distance hdl.h_in.position   kp 	
										l2=distance hdl.h_out.position  kp		 	
										hdl.h_in.position= kp + ((kp - hdl.h_out.position )	/ (l2/l1))
									)
									
									at time keytime
									(
										in coordsys (pth_getMatrix trg)
										(					
											it=((pth_PosToTan ((hdl.h_in.position-trg.position)  ) ( ((hdl.h_in.vlen ) / 3)   ) )   / ( hdl.h_in.hscale ))  / hdl.h_in.sc							
											obj.ctrl.x_position.controller.keys[i].inTangent = it.x 
											obj.ctrl.y_position.controller.keys[i].inTangent = it.y 
											obj.ctrl.z_position.controller.keys[i].inTangent = it.z
										
										)
									)
								)		 
							) 
						)
						pth_ignore_event=false;
					)
				)
			)
		) catch ()
	)

	
	fn updateAllAuto direct updateType=
	(
		try(
			for h in pth_handles do
			(
				if (superclassof h == StructDef   ) then
				(    
					htype=getKeyTypeHdl h.h_main.ctrl h.key true
					
				 	if (h.h_in!=undefined) do
					(				
						if (updateType==true) do
						(
							h.h_in.ktype=htype[1]
						)
						if (htype[1]==#auto) do
						(
						 	updateAutoHandlePos h 1  
						)
					)

					if (h.h_out!=undefined) do
					(
						if (updateType==true) do
						(
							h.h_out.ktype=htype[2]
						)
						
						if (htype[2]==#auto) do
						(
						 	updateAutoHandlePos h -1  
 						)
					)
					 
				)
			)
			
		) catch
		(
		 --	Runtime error: Attempt to access deleted scene object <<
		)
	)
	
	fn pth_getTrajectoryDistance obj t1 t2=
	(
		
		if (t1>t2) do (swap t1 t2)
		d=0.0
		d2=0
		for i = t1  to t2  do 
		(
			in coordsys world
			(
			posA = at time (i) obj.pos
			posB = at time (i+1f) obj.pos
			d += distance posA posB
			)
		)	
		
		d			
	)

	fn pth_strToPos str =
	(
		p = (readvalue (stringstream (filterString   (str as string) " @ ")[2]))
		p
	)
		
	fn pth_ParentTransform inode= 
	(
			pth_ignore_parent=true
			pth_updateHelperStructure inode true false
			pth_ignore_parent=false
	)

	fn pth_AutoUpdHelperStructure  inode=
	(
		debug "pth_AutoUpdHelperStructure"
		pth_updateHelperStructure inode false false
	)
	 
	fn pth_isSelected n = 
	(
		r=findItem  (selection as array) n
		r
	)

	fn pth_checkDirect =
	(
		tv = trackviews.current

		if (tv!=undefined) do (
			if (tv.ui.hwnd == _user32.GetActiveWindow()) do (return false)
		)
		
		return true
	)

	fn pth_alignOpposite hdl =
	(
		buildlist=#()
		for obj in selection do
		(
			if (classof obj == PTH_helper) then
			(
				if (hdl.type==1) do
				(
				
					 pth_handles[hdl.parent.hind].h_main.ctrl.X_position.controller.keys[pth_handles[hdl.parent.hind].h_main.parentID].inTangent = 	-1 * pth_handles[hdl.parent.hind].h_main.ctrl.X_position.controller.keys[pth_handles[hdl.parent.hind].h_main.parentID].outTangent
					 pth_handles[hdl.parent.hind].h_main.ctrl.Y_position.controller.keys[pth_handles[hdl.parent.hind].h_main.parentID].inTangent = 	-1 * pth_handles[hdl.parent.hind].h_main.ctrl.Y_position.controller.keys[pth_handles[hdl.parent.hind].h_main.parentID].outTangent
					 pth_handles[hdl.parent.hind].h_main.ctrl.Z_position.controller.keys[pth_handles[hdl.parent.hind].h_main.parentID].inTangent = 	-1 * pth_handles[hdl.parent.hind].h_main.ctrl.Z_position.controller.keys[pth_handles[hdl.parent.hind].h_main.parentID].outTangent
					pth_updateHandlePos  pth_handles[obj.parent.hind]  -1
					
				)
				
				if (hdl.type==-1) do
				(
				
					 pth_handles[hdl.parent.hind].h_main.ctrl.X_position.controller.keys[pth_handles[hdl.parent.hind].h_main.parentID].outTangent = 	-1 * pth_handles[hdl.parent.hind].h_main.ctrl.X_position.controller.keys[pth_handles[hdl.parent.hind].h_main.parentID].inTangent
					 pth_handles[hdl.parent.hind].h_main.ctrl.Y_position.controller.keys[pth_handles[hdl.parent.hind].h_main.parentID].outTangent = 	-1 * pth_handles[hdl.parent.hind].h_main.ctrl.Y_position.controller.keys[pth_handles[hdl.parent.hind].h_main.parentID].inTangent
					 pth_handles[hdl.parent.hind].h_main.ctrl.Z_position.controller.keys[pth_handles[hdl.parent.hind].h_main.parentID].outTangent = 	-1 * pth_handles[hdl.parent.hind].h_main.ctrl.Z_position.controller.keys[pth_handles[hdl.parent.hind].h_main.parentID].inTangent
					pth_updateHandlePos  pth_handles[obj.parent.hind]  1
					
				)
				
				appendifunique  buildlist obj.trg						
			) else
			(
				appendifunique  buildlist obj
			)
		)
	 
		for obj in buildlist do
		(
			pth_resetAll obj true false
		)

		redrawviews()
		redrawviews()
	)

	fn getKeyTypeHdl ctrl i dontfix = 
	(
		out= #()
		if (ctrl!=undefined) do
		(
			
			try
			(
				key_x=ctrl.X_position.controller.keys[i].inTangentType 
				key_y=ctrl.Y_position.controller.keys[i].inTangentType 
				key_z=ctrl.Z_position.controller.keys[i].inTangentType 
			
				if ( (key_x != key_y or key_x != key_y or key_x != key_z) and dontfix==false  ) do
				(
					ctrl.X_position.controller.keys[i].inTangentType= #custom
					ctrl.Y_position.controller.keys[i].inTangentType= #custom
					ctrl.Z_position.controller.keys[i].inTangentType= #custom
					key_x=#custom
				)

				if (i==1) do (  key_x=#none) 
				out[1]=key_x

				key_x=	 ctrl.X_position.controller.keys[i].outTangentType 
				key_y=	 ctrl.Y_position.controller.keys[i].outTangentType 
				key_z=	 ctrl.Z_position.controller.keys[i].outTangentType 
			
				if ( (key_x != key_y or key_x != key_y or key_x != key_z)  and dontfix==false ) do
				(
					 ctrl.X_position.controller.keys[i].outTangentType= #custom
					 ctrl.Y_position.controller.keys[i].outTangentType= #custom
					 ctrl.Z_position.controller.keys[i].outTangentType= #custom
					key_x=#custom
				)
				
				if (i==ctrl.X_position.controller.keys.count ) do (  key_x=#none) 
				out[2]=key_x
				
			) catch ()
		)
		out
	)
	
	fn pth_updateHelperStructure inode byParent autohandles=
	(
		with animate off 
		(
 			debug "pth_updateHelperStructure"
			hdl=0
			
			for h in pth_handles do
			(
				if (superclassof h == StructDef   ) then
				(    
					if (h.h_main.trg.inode.handle==inode) do
					(
						hdl=h.h_main
					)
				)
			)
			
			if (hdl==0) do  ( return false)
		 
			ctrl=hdl.ctrl
			timehash=0
			
			try
			(
				for i=1 to (ctrl.X_position.controller.keys.count ) do
				( 
					timehash += ctrl.X_position.controller.keys[i].time
					timehash += ctrl.Y_position.controller.keys[i].time
					timehash += ctrl.Z_position.controller.keys[i].time
				)
			) catch
			(
				pth_resetAll hdl.trg false	false
				return false
			)
			
			if ( hdl.sanity != ctrl.X_position.controller.keys.count + ctrl.Y_position.controller.keys.count + ctrl.Z_position.controller.keys.count  or (timehash !=hdl.timehash and pth_checkDirect()== true)  ) do
			(
				pth_resetAll  hdl.trg false false
				return false 
			)
			
			if (   (timehash !=hdl.timehash and pth_checkDirect()== false)  ) do
			(
				hdl.timehash  = timehash
			)
	 
			direct=pth_checkDirect()
			if (direct==false) do ( clearselection() )
			
			if ( pth_ignore_event == false) do
			(
				reb=false
				pth_ignore_event=true;
				
				for hdl in pth_handles do
				(	
					if (hdl!=undefined) do
					(
						if (superclassof hdl == StructDef   ) then
						(
							if (   direct==false or byparent == true or autohandles==true) do
							(
							
								k=getKeyTypeHdl  hdl.h_main.ctrl hdl.h_main.parentID true 
							 
								if (hdl.h_in !=undefined) then									(
										if (k[1] != hdl.h_in.ktype  ) do ( reb=true ;   )
								) else
								(
									if ( k[1]==#custom or k[1]==#auto) do
									(	
										reb=true	
									)
								)
							
								if ((hdl.h_in!=undefined and hdl.h_in.trg.inode.handle==inode)  ) do
								(	 
									if ( (autohandles==true and hdl.h_in.ktype==#auto and  pth_isSelected hdl.h_in  == 0 ) or  autohandles==false) do
									(
										pth_updateHandlePos  hdl -1
									)
								)
								
								if (hdl.h_out !=undefined) then
								(
										if (k[2] != hdl.h_out.ktype ) do ( reb=true;  )
								) else
								(
									if (k[2]==#custom or k[2]==#auto) do
									(			
										reb=true	
									)
								)
								if ((hdl.h_out!=undefined and hdl.h_out.trg.inode.handle==inode)   ) then
								(	
									if ( (autohandles==true and hdl.h_out.ktype==#auto and  pth_isSelected hdl.h_out == 0 ) or  autohandles==false) do
									(
										pth_updateHandlePos  hdl 1
									)
								)  
							)	 
						)
						else
						(
							if ( pth_isSelected hdl  == 0 or direct==false   ) do
							(	 
						 
								if (autohandles==false) do
								(
									at time hdl.ctrl.X_position.controller.keys[hdl.parentID].time
									 (
										in coordsys world
										(	
											tp=(readvalue (stringstream (filterString   (hdl.trg as string) " @ ")[2])) 
											hdl.position.x =tp.x
											hdl.position.y =tp.y
											hdl.position.z =tp.z
										)
									)
								) 
							)
						)
						
						pth_ignore_event=false
					)
				) -- end main loop
			)
		
			if (reb==true) do
			(
				pth_resetAll hdl.trg false false
			)
			
			setNeedsRedraw()
		)
	)
	 
	
	fn updateAutoHandlePos hdl type   =
	(
		-- reverse in/outs etc here
		with animate off
		(
			debug "Autopth_updateHandlePos"
		
			i=hdl.key
		 
			obj=hdl.h_main
			key_x=	 obj.ctrl.X_position.controller.keys[i]
			key_y=	 obj.ctrl.Y_position.controller.keys[i]
			key_z=	 obj.ctrl.Z_position.controller.keys[i]
			 
			
			keytime =  obj.ctrl.X_position.controller.keys[i].time
			
				
			if (type==1 and hdl.h_in!=undefined and  hdl.h_out!=undefined) do
			(	
				obj=hdl.h_in
				vlen=obj.vlen
				ltvec=length  [key_x.inTangentLength, key_y.inTangentLength, key_z.inTangentLength ]  / 3
				obj.ltvec = ltvec
				hdist=  (ltvec  ) * vlen 
				
				 at time keytime
				(
					in coordsys  ( pth_getMatrix hdl.trg)
					(
						pos=pth_inTanToPos obj.ctrl i 1 
						len2 = (length pos)  	
						
						if (len2 == 0) do (  len2 =0.1   )
						
						hscale=1 / len2 
						
						limit=1
						if 	(abs(key_x.outTangent * hscale) > 89.9 ) do ( limit *= 89.9 / abs(key_x.outTangent * hscale)    )
						if 	(abs(key_y.outTangent * hscale * limit) > 89.9) do ( limit *= 89.9 / abs(key_y.outTangent * hscale * limit)    )
						if 	(abs(key_z.outTangent * hscale * limit) > 89.9 ) do ( limit *= 89.9 / abs(key_z.outTangent * hscale * limit)    )
						
						pos=(pth_outTanToPos obj.ctrl i (hscale * limit )   )  * -1
						len = (length pos)   
						
						if (len == 0) then ( hdist=( 0.3 ) * vlen ; len = 0.001 ; limit=1;  obj.setBoxSize obj 15 ) else ( obj.setBoxSize obj 6)
						
						l=len / (vlen/ 3 ) 

						obj.hscale=(( 1 /  len2) / len)   *    limit  
						obj.position    =  (( pos  / l ) ) + hdl.trg.position
						obj.ltvec = [ key_x.inTangentLength ,  key_y.inTangentLength , key_z.inTangentLength ]  
						obj.sc=1.0
						obj.pvlen=1.0
						
					)
				)
			)	
		
			if (type==-1 and hdl.h_in!=undefined and  hdl.h_out!=undefined) do
			(	
				obj=hdl.h_out
				vlen=obj.vlen
				ltvec=length  [key_x.outTangentLength, key_y.outTangentLength, key_z.outTangentLength ]  / 3
				hdist=  (ltvec  ) * vlen 
				obj.ltvec = ltvec
				
				at time keytime
				(
					in coordsys  ( pth_getMatrix hdl.trg)
					(
						pos=pth_outTanToPos obj.ctrl i 1 
						len2 = (length pos)  	
						
						if (len2 == 0) do (  len2 =0.1   )
						
						hscale=1 / len2 
						
						limit=1
						if 	(abs(key_x.inTangent * hscale) > 89.9 ) do ( limit *= 89.9 / abs(key_x.inTangent * hscale)    )
						if 	(abs(key_y.inTangent * hscale * limit) > 89.9) do ( limit *= 89.9 / abs(key_y.inTangent * hscale * limit)    )
						if 	(abs(key_z.inTangent * hscale * limit) > 89.9 ) do ( limit *= 89.9 / abs(key_z.inTangent * hscale * limit)    )
						
						pos=(pth_inTanToPos obj.ctrl i (hscale * limit )   )  * -1
						len = (length pos)   
						
						if (len == 0) then ( hdist=( 0.3 ) * vlen ; len = 0.001 ; limit=1;  obj.setBoxSize obj 15 ) else ( obj.setBoxSize obj 6)
						
						l=len / (vlen/ 3 ) 

						obj.hscale=(( 1 /  len2) / len)   *    limit  
						obj.position    =  (( pos  / l ) ) + hdl.trg.position
						obj.ltvec = [ key_x.outTangentLength ,  key_y.outTangentLength , key_z.outTangentLength ]  
						obj.sc=1.0
						obj.pvlen=1.0

					)
				)
			)	
		)
		setNeedsRedraw()
	) 
 
	fn pth_updateHandlePos hdl  type =
	(
		with animate off
		(
			debug "pth_updateHandlePos"
		
			i=hdl.key
		 
			obj=hdl.h_main
			key_x=	 obj.ctrl.X_position.controller.keys[i]
			key_y=	 obj.ctrl.Y_position.controller.keys[i]
			key_z=	 obj.ctrl.Z_position.controller.keys[i]
			keytime =  obj.ctrl.X_position.controller.keys[i].time
				
			if (type==-1 and hdl.h_in!=undefined) do
			(	
				obj=hdl.h_in
				vlen=obj.vlen
				ltvec=length  [key_x.inTangentLength, key_y.inTangentLength, key_z.inTangentLength ]  / 3
				hdist=  (ltvec  ) * vlen 
				obj.ltvec = ltvec
				
				at time keytime
				(
					in coordsys  ( pth_getMatrix hdl.trg)
					(
						pos=pth_inTanToPos obj.ctrl i 1 
						len2 = (length pos)  	
						
						if (len2 == 0) do (  len2 =0.1   )
						hscale=1 / len2 
						
						limit=1
						if 	(abs(key_x.inTangent * hscale) > 89.9 ) do ( limit *= 89.9 / abs(key_x.inTangent * hscale)    )
						if 	(abs(key_y.inTangent * hscale * limit) > 89.9) do ( limit *= 89.9 / abs(key_y.inTangent * hscale * limit)    )
						if 	(abs(key_z.inTangent * hscale * limit) > 89.9 ) do ( limit *= 89.9 / abs(key_z.inTangent * hscale * limit)    )
						
						pos=(pth_inTanToPos obj.ctrl i (hscale * limit )   )  
						len = (length pos)   
						
						if (len == 0) then ( hdist=( 0.3 ) * vlen ; len = 0.001 ; limit=1;  obj.setBoxSize obj 15 ) else ( obj.setBoxSize obj 6)
						
						l=len / (vlen/ 3 ) 
						 obj.hscale=(( 1 /  len2) / len)   *    limit  
						obj.position    =  (( pos  / l ) ) + hdl.trg.position
						obj.ltvec = [ key_x.inTangentLength ,  key_y.inTangentLength , key_z.inTangentLength ]  
						obj.sc=1.0
						obj.pvlen=1.0
						
					)
				)
			)	
				
			if (type==1 and hdl.h_out!=undefined) do
			(	
				 obj=hdl.h_out
				 vlen=obj.vlen

			
				ltvec=length  [key_x.outTangentLength, key_y.outTangentLength, key_z.outTangentLength ]  / 3
				hdist=  (ltvec  ) * vlen 
				obj.ltvec = ltvec
				
				 at time keytime 
				 (
					in coordsys  ( pth_getMatrix hdl.trg)
					(
						pos=pth_outTanToPos obj.ctrl i 1 
						len2 = (length pos)  	
						
						if (len2 == 0) do (  len2 =0.1   )
						hscale=1 / len2 
						
						limit=1
						if 	(abs(key_x.outTangent * hscale) > 89.9 ) do ( limit *= 89.9 / abs(key_x.outTangent * hscale)    )
						if 	(abs(key_y.outTangent * hscale * limit) > 89.9) do ( limit *= 89.9 / abs(key_y.outTangent * hscale * limit)    )
						if 	(abs(key_z.outTangent * hscale * limit) > 89.9 ) do ( limit *= 89.9 / abs(key_z.outTangent * hscale * limit)    )
						
						pos=(pth_outTanToPos obj.ctrl i (hscale * limit )   )  
						len = (length pos)   
						
						if (len == 0) then ( hdist=( 0.3 ) * vlen ; len = 0.001 ; limit=1 ;  obj.setBoxSize obj 25 ) else ( obj.setBoxSize obj 6)
						l=len / (vlen/ 3 ) 
						obj.hscale=(( 1 /  len2) / len)   *    limit  
						obj.position    =  (( pos  / l ) ) + hdl.trg.position
						obj.ltvec = [ key_x.outTangentLength ,  key_y.outTangentLength , key_z.outTangentLength ]  
						obj.sc=1.0
						obj.pvlen=1.0
					)
				)
			)	
		)
	) 

	fn pth_createHelperStructure t ctrl =
	(
		debug "pth_createHelperStructure"	
		trg = t 
		execute ("when transform trg changes handleAt: #redrawViews id:#vph do  ( updateAllAuto false true;   ); ") 
		 
		if (classof ctrl != position_XYZ and classof ctrl !=SubAnim ) do (return false)
 
		with animate off 
		(
			if (pth_sanityCheck ctrl == false) then
			(
				r=querybox "The XYZ-controller has keyframes that does not have keys for all 3 X,Y and Z tracks. Add automatically?"

				if (r==false) then
				 (
					return false 
				 ) else
				 (
					for i=1 to (ctrl.X_position.controller.keys.count ) do
					( 
						ctime= ctrl.X_position.controller.keys[i].time
						try ( if  (ctrl.Y_position.controller.keys[i].time !=ctime) do ( addNewKey ctrl ctime )) catch (addNewKey ctrl ctime)
						try ( if  (ctrl.Z_position.controller.keys[i].time !=ctime) do ( addNewKey ctrl ctime )) catch (addNewKey ctrl ctime)
					)
					
					for i=1 to (ctrl.Y_position.controller.keys.count ) do
					( 
						ctime= ctrl.Y_position.controller.keys[i].time
						try ( if  (ctrl.X_position.controller.keys[i].time !=ctime) do ( addNewKey ctrl ctime )) catch ( addNewKey ctrl ctime)
						try ( if  (ctrl.Z_position.controller.keys[i].time !=ctime) do ( addNewKey ctrl ctime )) catch ( addNewKey ctrl ctime)
					)
					
					for i=1 to (ctrl.Z_position.controller.keys.count ) do
					( 
						ctime= ctrl.Z_position.controller.keys[i].time
						try ( if  (ctrl.Y_position.controller.keys[i].time !=ctime) do ( addNewKey ctrl ctime )) catch ( addNewKey ctrl ctime)
						try ( if  (ctrl.X_position.controller.keys[i].time !=ctime) do ( addNewKey ctrl ctime )) catch ( addNewKey ctrl ctime)
					)
				 )
			 )
			 
			timehash=0
			 
			for i=1 to (ctrl.X_position.controller.keys.count ) do
			( 
				timehash += ctrl.X_position.controller.keys[i].time
				timehash += ctrl.Y_position.controller.keys[i].time
				timehash += ctrl.Z_position.controller.keys[i].time
			)
		
			totalts=0
			totalte=0
			totall=0
		
			for h in pth_handles do
			(
				if (superclassof h == StructDef   ) then
				(    
					if (h.h_main.trg.inode.handle==inode) do
					(
						deleteChangeHandler  h.h_main.ch
					)
				)
			)
 
			global pth_ignore_event=false
			global pth_ignore_event2=false
			global pth_ignore_parent=false
		
		
			cnt=ctrl.keys.count 
			if (	isLicenced() == false and cnt>4) do (cnt=4; messagebox ("Demo verison will only create handles for the first 4 keys"))
 
			for i=1 to (cnt ) do
			( 
				if ( pth_selonly==false or  ((isKeySelected  ctrl.X_position.controller i ) or  (isKeySelected  ctrl.Y_position.controller i) or (isKeySelected  ctrl.Z_position.controller i) )  ) do
				(
					key_x=ctrl.X_position.controller.keys[i]
					key_y=ctrl.Y_position.controller.keys[i]
					key_z=ctrl.Z_position.controller.keys[i]

					if ( true ) do
					(
					
						keytime=ctrl.X_position.controller.keys[i].time
						if (totalts > keytime) do ( totalts = keytime )
						if (totalte < keytime) do ( totalte = keytime )
						key_x.freeHandle = false
						key_y.freeHandle = false
						key_z.freeHandle = false
						
						first=true
						last=true
						if (i>1) do
						(
							if (ctrl.X_position.controller.keys[i-1] != undefined) do
							(
								first=false
								pkey_x=ctrl.X_position.controller.keys[i-1]
								pkey_y=ctrl.Y_position.controller.keys[i-1]
								pkey_z=ctrl.Z_position.controller.keys[i-1]
							)
						)
				
						if (ctrl.X_position.controller.keys[i+1] != undefined  ) do
						(
							last=false
							nkey_x=ctrl.X_position.controller.keys[i+1]
							nkey_y=ctrl.Y_position.controller.keys[i+1]
							nkey_z=ctrl.Z_position.controller.keys[i+1]
						)
						
						htype=getKeyTypeHdl ctrl i false
						a=PTH_helper()
						a.setBoxSize a 8
						a.parentID=i
						a.parentHandleID = -1
						a.wirecolor=color 255 128 0
						a.type=0
						a.name="PT_"+t.name+"_key"+i as string+"_main"
						a.ctrl=ctrl
						a.sanity = ctrl.X_position.controller.keys.count + ctrl.Y_position.controller.keys.count + ctrl.Z_position.controller.keys.count
						a.ktime=ctrl.X_position.controller.keys[i].time
						a.timehash=timehash
						pth_addToLayer a 
						 
						at time keytime
						(			
							in coordsys world
							(		
								a.rotation = (quat 0 0 0 1)
							)
							
							in coordsys  trg 
							(		
								a.position=[0,0,0]
							)
						)
							 
						a.vlen=0
						a.trg=trg
						a.type=0
				 
						index=pth_handles.count+1
						curpar=index
							
						append pth_handles a
						execute ("when pth_handles["+index as string+"]  deleted id:#vph do ( DeleteHandle  "+index as string+" 0 )")
						execute ("when transform pth_handles["+index as string+"] changes id:#vph do  (  if (  theHold.Holding() ) then ( pth_moveMain pth_handles["+index as string+"]) else ( goddevit=true	 	))")
				 
						a_out = undefined
						a_in=undefined
						
						if (first==false and (htype[1]==#custom or htype[1]==#auto ) ) do
						(
							a_in=PTH_helper()
							a_in.setBoxSize a 6
							a_in.parentID=i
							a_in.parentHandleID = index
							a_in.wirecolor=color 80  255 80
							a_in.name="PT_"+t.name+"_key"+i as string+"_in"
							a_in.type= -1
							a_in.parent=a
							a_in.ctrl=ctrl
							vlen= (pth_getTrajectoryDistance trg key_x.time pkey_x.time)  
							a_in.vlen=vlen
							a_in.sanity =  ctrl.X_position.controller.keys.count + ctrl.Y_position.controller.keys.count + ctrl.Z_position.controller.keys.count
							a_in.ktime=ctrl.X_position.controller.keys[i].time
							ltvec=length  [key_x.inTangentLength, key_y.inTangentLength, key_z.inTangentLength ]  / 3
							hdist=  (ltvec  ) * vlen 
							a_in.ltvec = ltvec
							a_in.timehash=timehash
							a_in.trg=trg
							a_in.ktype=htype[1]
							pth_addToLayer a_in
							
							 at time keytime 
							 (
								in coordsys  ( pth_getMatrix trg)
								(
									--get initial value for hscale
									pos=pth_inTanToPos a_in.ctrl i 1 
									len2 = (length pos)  
									if (len2 < 0.01 ) do (  len2 =1 )				
									hscale=1 / len2 

									--Set hscale so the  (hscale	* tangent) keeps between -90 and 90
									limit=1
									if 	(abs(key_x.inTangent * hscale) > 89.9 ) do ( limit *= 89.9 / abs(key_x.inTangent * hscale)    )
									if 	(abs(key_y.inTangent * hscale * limit) > 89.9) do ( limit *= 89.9 / abs(key_y.inTangent * hscale * limit)    )
									if 	(abs(key_z.inTangent * hscale * limit) > 89.9 ) do ( limit *= 89.9 / abs(key_z.inTangent * hscale * limit)    )
						 
									--
									pos=(pth_inTanToPos a_in.ctrl i (hscale * limit )   )  
									len = (length pos)  
									
									--assume some fallback  for 0 tangents, sharps corners. 
									a_in.hscale=(( 1 /  len2) / len)   *    limit
										
										
									if (len < 0.01 ) do
									(
										hdist=( 0.3 ) * vlen ; len =1 ; limit=1 ; 	a_in.hscale=1; 	a_in.setBoxSize a_in 15
										ctrl.X_position.controller.keys[i].inTangentType = #custom
										ctrl.X_position.controller.keys[i].inTangentType = #custom
										ctrl.X_position.controller.keys[i].inTangentType = #custom
										a_in.ktype=#custom
									)
									--
									l=len / (vlen/ 3 ) 
									a_in.position    =  ( pos  / l ) + trg.position
									a_in.ltvec = [ key_x.inTangentLength ,  key_y.inTangentLength , key_z.inTangentLength ]
								)
							)
						)
						
						if (last==false  and (htype[2]==#custom or htype[2]==#auto) ) do
						(
							a_out=PTH_helper()
							a_out.setBoxSize a 6
							a_out.parentID=i
							a_out.parentHandleID = index
							a_out.wirecolor=color 80 80 255
							a_out.name="PT_"+t.name+"_key"+i as string+"_out"
							a_out.type= 1
							a_out.parent=a
							a_out.ctrl=ctrl
							vlen= (pth_getTrajectoryDistance trg key_x.time nkey_x.time)  
							a_out.vlen=vlen
							a_out.ktype=htype[2]
							totall += vlen
							
							a_out.sanity = ctrl.X_position.controller.keys.count + ctrl.Y_position.controller.keys.count + ctrl.Z_position.controller.keys.count
							a_out.ktime=ctrl.X_position.controller.keys[i].time
							a_out.timehash=timehash
							pth_addToLayer a_out
							a_out.trg=trg

							
							ltvec=length  [key_x.outTangentLength, key_y.outTangentLength, key_z.outTangentLength ]  / 3
							hdist=  (ltvec  ) * vlen 
							a_out.ltvec = ltvec
							 at time keytime 
							 (
								in coordsys  ( pth_getMatrix trg)
								(
									--get initial value for hscale
									pos=pth_outTanToPos a_out.ctrl i 1 
									len2 = (length pos)  
									if (len2 < 0.01) do (  len2 =1 )		
									hscale=1 / len2 

									--Set hscale so the  (hscale	* tangent) keeps between -90 and 90
									limit=1
									if 	(abs(key_x.outTangent * hscale) > 89.9 ) do ( limit *= 89.9 / abs(key_x.outTangent * hscale)    )
									if 	(abs(key_y.outTangent * hscale * limit) > 89.9) do ( limit *= 89.9 / abs(key_y.outTangent * hscale * limit)    )
									if 	(abs(key_z.outTangent * hscale * limit) > 89.9 ) do ( limit *= 89.9 / abs(key_z.outTangent * hscale * limit)    )
					
									pos=(pth_outTanToPos a_out.ctrl i (hscale * limit )   )  
									len = (length pos)  
									--assume some fallback  for 0 tangents, sharps corners. 
									a_out.hscale=(( 1 /  len2) / len)   *    limit
									
									if (len < 0.01) do
									(
										hdist=( 0.3 ) * vlen ; len =1 ; limit=1 ; 	a_out.hscale=1;	a_out.setBoxSize a_out 25
										ctrl.X_position.controller.keys[i].outTangentType = #custom
										ctrl.X_position.controller.keys[i].outTangentType = #custom
										ctrl.X_position.controller.keys[i].outTangentType = #custom
										a_out.ktype=#custom
									)
									
									--
									l=len / (vlen/ 3 ) 
									a_out.position    =  ( pos  / l ) + trg.position
									a_out.ltvec = [ key_x.outTangentLength ,  key_y.outTangentLength , key_z.outTangentLength ]
								)
							)
						)
						
						index=pth_handles.count+1	
						pth_handles[curpar].hind=index
						
						h=handle trg i a a_in a_out false
						append pth_handles h
					
						if (last==false  and (htype[2]==#custom or htype[2]==#auto    ) ) do
						(
							execute ("when pth_handles["+index as string+"].h_out deleted id:#vph do ( DeleteHandle  "+index as string+" 1 )")
							execute ("when transform pth_handles["+index as string+"].h_out changes id:#vph do  ( if (  theHold.Holding() and pth_isSelected pth_handles["+index as string+"].h_out  >0 ) then ( pth_moveHandle pth_handles["+index as string+"] 1) else (    )); ")
							execute ("when transform pth_handles["+index as string+"].h_out changes handleAt: #redrawViews id:#vph do  ( if (  not theHold.Holding() ) do(  pth_handles["+index as string+"].h_out.pvlen = 1;   )  ); ")
						)

						if (first==false  and (htype[1]==#custom or htype[1]==#auto )) do
						(
							execute ("when pth_handles["+index as string+"].h_in deleted id:#vph do ( DeleteHandle "+index as string+" -1 )")
							execute ("when transform pth_handles["+index as string+"].h_in changes id:#vph do  ( if (  theHold.Holding() and pth_isSelected pth_handles["+index as string+"].h_in  >0  ) then ( pth_moveHandle pth_handles["+index as string+"] -1) else (   ));")		
							 execute ("when transform pth_handles["+index as string+"].h_in changes handleAt: #redrawViews id:#vph do  ( if (  not theHold.Holding() ) do( pth_handles["+index as string+"].h_in.pvlen = 1;  	 )  ); ") 
						)	
					)
				)
			)			
	 
			cc=0
			execute (" cc = when parameters trg changes id:#vphmain  do  ( pth_AutoUpdHelperStructure "+ (trg.inode.handle  as string)+ " )" )
			execute (" when trg deleted id:#vphmain  do  ( pth_resetAll trg false false)" )
			
			if (trg.parent!=undefined) do
			(
				execute ("when transform trg.parent changes id:#vphmain   do  ( pth_ParentTransform "+ (trg.inode.handle as string )+ " )")
			)
		 
			for h in pth_handles do
			(
				if (superclassof h == StructDef   ) then
				(    
					if (h.h_main.trg==t) do
					(
						 h.h_main.ch=cc
						 h.h_main.stime=totalts
						 h.h_main.etime=totalte
						 h.h_main.tlen=totall
					)
				)
			)
		)
	)

	fn inertia_getApprox  =
	(
		p1=0.0;
		p2=0.0;
		p3=0.0;
		cnt=0;
		cnt_rlx=0;
		
		warn=true
		
		sel=selection 
		for trg in sel do
		(
			out=inertia_getSubs trg  Bezier_Float	"" #()
			
			for item in out do
			(
				ctrl=item[1]
				if (ctrl.keys.count>0) do (warn=false)
				
				selcount=0
				for keyA = 1 to (ctrl.keys.count ) do
				(
					if (isKeySelected ctrl keyA) do ( selcount += 1 )
				)
				
				curcount=1
				
				for keyA = 1 to (ctrl.keys.count ) do
				(
					if ((isKeySelected ctrl keyA    and (curcount <= selcount OR selcount == 1 )) ) do
					(  
						keyB = keyA + 1;
						if (keyA==1 AND ctrl.keys[keyB]!=undefined) do
						(
							dx=(ctrl.keys[keyA].value - ctrl.keys[keyB].value) * 2
							b_in=ctrl.keys[keyB].inTangentLength
						)
						
						if (keyA==ctrl.keys.count AND keyA > 1 ) do
						(
							dx=(ctrl.keys[keyA-1].value - ctrl.keys[keyA].value) * 2
							b_in=ctrl.keys[keyA].inTangentLength
						)
						
						if (keyA==ctrl.keys.count AND keyA == 1 ) do
						(
							dx=(  ctrl.keys[keyA].value) * 2
							b_in=ctrl.keys[keyA].inTangentLength
						)
						
						if (keyA!=ctrl.keys.count AND keyA!=1) do
						(
							b_in=ctrl.keys[keyB].inTangentLength
							dx=ctrl.keys[keyA-1].value - ctrl.keys[keyB].value
						)
						
						type=#single
						if  ( selcount > 1) do
						(
							if (curcount ==1 ) do ( type=#first )
							if (curcount == selcount) do ( type=#last )
							if (type==#single) do ( type=#mid )
						)
						
						if (type!=#single) then
						(
							t=inertia_inverted ctrl.keys[keyA].outTangentLength   b_in  ctrl.keys[keyA].inTangent (dx    ) type
						) else
						(
							t=inertia_inverted ctrl.keys[keyA].outTangentLength  ctrl.keys[keyA].inTangentLength ctrl.keys[keyA].inTangent ( dx ) type
						)
						 
						p1 +=t[1] 
						p2 +=t[2] 
						p3 +=t[3] 
						
						if (dx!=0)  do
						(
							cnt_rlx += 1	
						)
		
						cnt += 1
						curcount += 1
					)
				)
			)
		)

		if (warn) do (	messagebox ("时间轴中没有选择要操作的帧！                        "))
		if (cnt==0) do (  return false)
		p1  = (p1 / cnt) * 10
		p2  = ((p2 / cnt)  * 10) - 1
 
		if (cnt_rlx==0) do (cnt_rlx=1)
		return #(p1, p2, (p3/cnt_rlx))
	)		
	
	fn inertia_inverted a b c d type=
	(
		p1=0
		p2=0
		p3=0
		if  ((a + b) != 0) do
		(
			 p1 = 1  - a / ( 0.33333 *  (( a + b ) / 0.66666))
			 p2 =   ((   b + a ) / 0.66666)  
		)

		if (d != 0  AND  (a+b) != 0 ) do
		(
			p3= c / (d / (20000 * (( a + b ) / 0.66666) ))   
		)
		 
		return #(p1, p2, (p3   ))
	 )
  
	fn makeTangents ctrl keyA params type =
	(
		
	 	if (type==#single ) do
		(
		--	params[3] *= 0.666666
		)
		
		keyB = keyA + 1;
		
		if (keyA==1) do
		(
			dx=(ctrl.keys[keyA].value - ctrl.keys[keyB].value) * 2
		)
		
		if (keyA==ctrl.keys.count) do
		(
			dx=(ctrl.keys[keyA-1].value - ctrl.keys[keyA].value) * 2
		)
		
		if (keyA!=ctrl.keys.count AND keyA!=1) do
		(
			dx=ctrl.keys[keyA-1].value - ctrl.keys[keyB].value
		)
	 
		la=(0.33333 * (params[2])) * (1 - params[1])    
		lb=(0.33333 * (params[2])) * (1+ params[1])    
 
		if (type!=#last OR keyA==ctrl.keys.count) do
		(
			ctrl.keys[keyA].outTangentLength=la
		)
		
		if (type==#single  OR keyA==1 ) do
		(
				ctrl.keys[keyA].inTangentLength=lb
		)
			
		if (keyB<=ctrl.keys.count  ) then
		(
		 	if (type!=#last) do
			(
				ctrl.keys[keyB].inTangentLength=lb
			)
			
			ita=( dx * (params[3] / 20000)  ) / params[2]
			ctrl.keys[keyA].inTangent = ita    
			ctrl.keys[keyA].outTangent = -1 * ita 
	 
		)
		else
		(
			ctrl.keys[keyA].inTangentLength=lb  
			ita=( dx * (params[3] / 20000)  ) / params[2]
			ctrl.keys[keyA].inTangent = ita    
		)
	)

	fn inertia_getSubs item ctype p out =
	(
		for i = 1 to item.numSubs do
		(
			inertia_getSubs item[i]  ctype (p+"/"+(item[i].name as string)) out 
			if (classof item[i].controller == ctype AND numSelKeys item[i].controller > 0	) do
			(
				append out #(item[i].controller, p+"/"+item[i].name  )
			)	
		)
		
		return out
	)

	fn inertia_updateTrajectory = 
	(
		showpop=false
		sel=selection 
		warn = true
		print "X"
		for trg in sel do
		(
			print "T"
			out=inertia_getSubs trg  Bezier_Float	"" #()
			
			for item in out do
			(
				ctrl=item[1]
			 
				selcount=0
				
				if (ctrl.keys.count > 0 ) do ( warn=false)
				for i = 1 to (ctrl.keys.count ) do
				(
					print "u"
					if (isKeySelected ctrl i   ) do ( selcount += 1; )
				)
				print "!"
				curcount=1
				for i = 1 to (ctrl.keys.count ) do
				(
					
 					if (isKeySelected ctrl i   ) do
					(  
						params=#( PTH.spn_bias.value /10  , (PTH.spn_curve.value + 1 ) /10 , PTH.spn_rlx.value )
						
						type=#single
						if  ( selcount > 1) do
						(
							if (curcount ==1 ) do ( type=#first )
							if (curcount == selcount) do ( type=#last )
							if (type==#single) do ( type=#mid )
						 )
					 
						if (ctrl.keys.count > 1 ) do
						(
							makeTangents ctrl i params type
						)
						curcount += 1
					)
				)
			)
		)
		
		if (warn) do (	messagebox ("没有选中帧!                           "))
		
		tmp=selection as array
		try(
			if (PTH.open) do
			(
				pth_resetAll true false false
				select tmp
				delLayerObj = #()

				delLayer    = LayerManager.getLayerFromName "ProTrajectory Handles"
				
				if delLayer != undefined then
				(
					layerRT = delLayer.layerAsRefTarg
					delLayerObj = refs.dependents layerRT
					delLayer.lock = off
					for i in delLayerObj where ((delLayerObj.count != 0) and (classof i == PTH_helper)) do delete i
					LayerManager.deleteLayerByName "ProTrajectory Handles"
					delLayerObj = #()
				)
			)
		) catch
		()
			
		redrawviews();
	)
	
	unregisterRedrawViewsCallback vph_drawlines
	fn vph_drawlines =
	(
 
		tmp_ttype=pth.rdo_ttype.state;
		
		if (isAnimPlaying() == false or pth.chk_hp.state == false) then
		(
			gw.setTransform (Matrix3 1)
				
			if (tmp_ttype==3) then
			(		
				gw.setColor #line black
			) else
			(
				gw.setColor #line yellow
			)
				
			try
			(
				trglist=#()

				totalts=0
				totalte=0

				totallen=0
				
				local stime = 0
				local etime = 1
				local tlen = 0

				if (pth_handles.count==0) do
				(
					local stime = animationrange.start
					local etime = animationrange.end
					local tlen = etime-stime
				)
				for hdl in pth_handles do
				(
		 
					if (superclassof hdl == StructDef and hideByCategory.helpers == false) then
					(
						if ( hdl.h_out!=undefined and hdl.h_out.isHidden==false) do
						(
							totallen += hdl.h_out.vlen		
							
							if (tmp_ttype!=3) do
							(
								if (hdl.h_out.ktype== #custom) then (	gw.setColor #line yellow ) else (	gw.setColor #line gray )
							)	
							gw.Polyline #([hdl.h_out.position.x,hdl.h_out.position.y,hdl.h_out.position.z] ,  [hdl.h_main.position.x,hdl.h_main.position.y,hdl.h_main.position.z]) false 
						)
						
						if ( hdl.h_in!=undefined and hdl.h_in.isHidden==false) do
						(
							if (tmp_ttype!=3) do
							(
							if (hdl.h_in.ktype== #custom) then (	gw.setColor #line yellow ) else (	gw.setColor #line gray )
							)
							gw.Polyline #([hdl.h_in.position.x,hdl.h_in.position.y,hdl.h_in.position.z] ,  [hdl.h_main.position.x,hdl.h_main.position.y,hdl.h_main.position.z]) false 
						)
						
						
						if (hdl.h_main!=undefined) do
						(
							 appendifunique pth_showpath  hdl.h_main.trg
							 if (stime > hdl.h_main.stime ) do (stime = hdl.h_main.stime  )
							 if (etime < hdl.h_main.etime ) do (etime = hdl.h_main.etime  )
						)
					)  
				)
	
				for  obj in pth_showpath do
				(
					if ((tmp_ttype!=1  AND tmp_ttype!=4  ) or pth.chk_lt.state==true) then
					(
						d=0.0
						for i = stime to etime  do 
						(
							in coordsys world
							(
								posA = at time (i) obj.pos
								posB = at time (i+1f) obj.pos
							)
							
							f=totallen / (etime-stime)
							r= (distance posA posB)  
						
							ss=pth.spn_mult.value  
							fs=pth.spn_fast.value  
								 
							if (r<ss) do (r=ss)
							rc=(r-ss)/(fs-ss)
							if (rc>1) do (rc=1.0)

							if (tmp_ttype== 3) then
							(
								s= pth.cp_slow.color
								f= pth.cp_fast.color
							) else
							(
								s= obj.wirecolor
								f=  obj.wirecolor
							)
							
							c=(s*(1-rc)+f*rc)
							
							gw.setColor #line c
						
							in coordsys world
							(
								posA = at time (i) obj.pos
								posB = at time (i+1f) obj.pos
							)
							
							if (tmp_ttype!= 1) then
							(
								gw.Polyline #(posA ,  posB) false 
							)
							
							mt=#point
							
							if (pth.chk_lt.state==true) then
							(
								mt=#smallDiamond
							)
							
							if (tmp_ttype!= 3) then
							(
								gw.Marker posA mt   color:[255,255,255]
							)
							else
							(
								gw.Marker posA mt  color:c
							)
						) 
					)   
		 
					if (pth.chk_X.state == true OR pth.chk_Y.state == true OR pth.chk_Z.state == true ) do
					(
						in coordsys world
						(
							for i = stime to etime  do (
								
								if (mod (i as integer / ticksperframe) pth.spn_oe.value) != 0 do continue;
									
								pos = at time (i) obj.pos;
								mat= at time(i)  inverse (obj.rotation as matrix3);
								
								l=pth.spn_ol.value 
								
								posX= [l,0,0]* mat   + pos
								posY= [0,l,0]* mat   + pos
								posZ= [0,0,l]* mat   + pos
								
								if (pth.chk_X.state == true) do
								(
								gw.setColor #line red			
								gw.Polyline #(pos ,  posX) false 
								)
								
								if (pth.chk_Y.state == true) do
								(
								gw.setColor #line green
								gw.Polyline #(pos ,  posY) false 
								)
								if (pth.chk_Z.state == true) do
								(
								gw.setColor #line blue
								gw.Polyline #(pos ,  posZ) false 
								)
							)
						)
					)
				)
				
			) catch
			(
				--format "*** % ***\n" (getCurrentException())
			)	
			gw.enlargeUpdateRect #whole
			gw.updateScreen()
	 	)  
 	)

	registerRedrawViewsCallback vph_drawlines
	pth_resetAll true false false	
	createdialog PTH style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)
	redrawViews()  
	updateTHCheck false
)

 