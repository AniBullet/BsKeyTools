--转自CGJOY:https://www.cgjoy.com/forum.php?mod=viewthread&tid=150585
--原作者未知,Bullet.S精简修改,版权归原作者,请勿商用!后果自负!

if doesFileExist ((getDir #maxData) + "\\cstool.ini") == false then
	(
		f = createFile ((getdir #maxData) + "\\cstool.ini");close f
	)
	
	if ottool!=undefind then CloseRolloutfloater ottool
	if cstoolroll!=undefined then destroydialog cstoolroll
	if pathdlg!=undefined then destroydialog pathdlg
	if pathdata!=undifined then destroydialog pathdata
	if setpara!=undefined then destroydialog setpara
	if mergebip!=undefined then destroydialog mergebip
	if bipexp!=undefind then destroydialog bipexp
	
	
	global msfilename="*.ms";
	global mspath="f:\\scripts\\批处理\\"
	global scriptfile1 = ""
	global scriptfile2 = "f:\\scripts\\批处理\\加三帧.ms"
	global scriptfile3 = "f:\\scripts\\批处理\\女拷贝pos.ms"
	global scriptfile4 = ""
	global exppath="d:\an_exp"
	
	
	global image_cs_sp4=openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\image_cs_sp4.bmp")
	global image_cs_sp3=openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\image_cs_sp3.bmp")
	global image_cs_sp2=openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\image_cs_sp2.bmp")
	global image_cs_sp1=openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\image_cs_sp1.bmp")
	global image_cs_lost=openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\image_cs_lost.bmp")
	
	global image_select    = openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\select.bmp")
	global image_leftFootA = openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\leftfootA.bmp")
	global image_leftFootB = openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\leftfootB.bmp")
	global image_leftFootC = openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\leftfootC.bmp")
	global image_leftFootD = openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\leftfootD.bmp")
	
	
	global image_leftFootA2 = openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\leftfootA2.bmp")
	global image_leftFootB2 = openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\leftfootB2.bmp")
	global image_leftFootC2 = openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\leftfootC2.bmp")
	global image_leftFootD2 = openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\leftfootD2.bmp")
	
	if selhanddlg!=undefind then destroydialog selhanddlg
	
	global image_finger5=openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\finger5.bmp")
	global image_finger4=openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\finger4.bmp")
	global image_finger3=openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\finger3.bmp")
	global image_finger2=openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\finger2.bmp")
	global image_greenhand=openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\greenhand.bmp")
	global image_bluehand=openbitmap(getdir #maxroot+"UI_ln\\ICONS\\cstoolIcons\\bluehand.bmp")
	
	global hbtn,hoffset,hbtncode
	global pic_greenhand =bitmap 24 24
	
	global nowhandlx=1
	
	
	global back = bitmap 117 240
	
	global tmp1  = bitmap 117 240
	global tmp2  = bitmap 117 240
	global tmp3  = bitmap 117 240
	global tmp4  = bitmap 117 240
	global tmplost  = bitmap 117 240
	global splinenum=99;
	global havebip=0;
	global showtrajflag=0
	global autotimelimit=3   --自动保存的时间配置
	global bipnumlimit=30       --自动保存的BIP数量限制
	global spflag=0;
	global clk  = bitmap 16  16
	global timescan=1;
	global autotime=0;
	global laststart=0;
	global lastend=100;
	
	global hiderollyflag=0;
	global showrollyflag=0;
	global hidedlg=false
	global maxmenuflag=0;
	
	global fullscreenflag=0;
	global boxmodeflag=0;
	global bipfileitems
	global pathItems=#("","","","","","","","","","","","","","","","","","","","")
	back = image_cs_sp1
	copy back tmp1
	
	back = image_cs_sp2
	copy back tmp2
	
	back = image_cs_sp4
	copy back tmp4
	
	back = image_cs_sp3
	copy back tmp3
	
	back =image_cs_lost
	copy back tmplost
	
	
	
	--back = bitmap 117 240
	
	
	clk=image_select
	global speedmode=1
	global anflag;
	global atime;
	global delpath=getdir #maxroot +"DelBip\\"
	
	global paraflag=0
	global pathdlgflag=0
	
	global bipfilename="*.bip";
	global showbip=0
	global box_state=0
	global pivotmode=0
	
	global dialog_x=500
	global dialog_y=10
	global mystarttime=0
	global myendtime=242
	global myrangetime=50
	global mymovetime=10
	global myaddtime=10
	global filepath=getdir #maxroot
		
	global last_dialog_x
	global last_dialog_y
	
	global initcs;
	global bspeed = 1;
	
	global antime=0;
	global antimemode=0;
	
	global newchar
	
	global second;
	global lastsecond;
	
	
	copy image_greenhand pic_greenhand 
	
	global handname=#()
	global hsz=#(0,0,0,0,0,0)
	fn gethandname lx=
	(
	 
	 handname=#()
	 bip=bipname[24].controller
	 if lx==1 then
	 (
	 for i=1 to bip.fingers do
	 (
	  p=biped.getNode bip #Rfingers link:(bip.fingerLinks*(i-1)+1)
	  append handname p 
	
	 )
	 append handname bipname[9]
	 )
	 else
	 (
	  for i=1 to bip.fingers do
	  (
	 
	  p=biped.getNode bip #Lfingers link:(bip.fingerLinks*(i-1)+1)
	  append handname p
	 )
	 append handname bipname[10]
	 )
	
	)
	
	
	
	global hbtn=#()
	global hoffset=#()
	
	  
	fn sethandbtn fingernum=
	(
	hbtn=#()
	hoffset=#()
	if fingernum==5 then
	   (
		hbtn[1]=rect 15 69 20 20
		hbtn[2]=rect 23 36 20 20
		hbtn[3]=rect 45 29 20 20
		hbtn[4]=rect 67 30 20 20
		hbtn[5]=rect 87 39 20 20
		hbtn[6]=rect 51 70 26 26
		hbtn[7]=rect 0  91 24 24
		hbtn[8]=rect 91 91 24 24
		
		
		hoffset[1]=point2 1 1
		hoffset[2]=point2 2 2
		hoffset[3]=point2 1 1
		hoffset[4]=point2 2 1
		hoffset[5]=point2 2 2
		hoffset[6]=point2 5 4
		
	 
	   )
	   
	if fingernum==4 then
	   (
		hbtn[1]=rect 15 69 20 20
		hbtn[2]=rect 26 38 20 20
		hbtn[3]=rect 51 30 20 20
		hbtn[4]=rect 78 35 20 20
		hbtn[5]=rect 51 72 26 26
		hbtn[6]=rect 0  91 24 24
		hbtn[7]=rect 91 91 24 24
		
		hoffset[1]=point2 1 1
		hoffset[2]=point2 1 1
		hoffset[3]=point2 1 1
		hoffset[4]=point2 2 1
		hoffset[5]=point2 5 4
	
	   )
	   
	   if fingernum==3 then
	   (
		hbtn[1]=rect 15 69 20 20
		hbtn[2]=rect 27 35 20 20
		hbtn[3]=rect 48 29 43 24
		hbtn[4]=rect 52 72 26 26
		hbtn[5]=rect 0  91 24 24
		hbtn[6]=rect 91 91 24 24	
		
		hoffset[1]=point2 1 1
		hoffset[2]=point2 1 2
		hoffset[3]=point2 12 3
		hoffset[4]=point2 4 4 
	
	
	   ) 
	  if fingernum==2 then
	   (
		hbtn[1]=rect 15 69 20 20
		hbtn[2]=rect 42 29 43 24
		hbtn[3]=rect 51 70 26 26
		hbtn[4]=rect 0  91 24 24
		hbtn[5]=rect 91 91 24 24
		
		hoffset[1]=point2 1 0
		hoffset[2]=point2 12 3
		hoffset[3]=point2 5 4 
	
	   )
	   
	)
	
	
	global hback=bitmap 115 115
	global temphback=bitmap 115 115
	global fingernum
	global fingerslink
	
	
	
	
	fn showsel bcode =
	(
	 for i=0 to 15 do 
	 for j=0 to 15 do
	 (
	  aa=getpixels clk [j,i] 1
	  ix=hbtn[bcode].x+hoffset[bcode].x;
	  iy=hbtn[bcode].y+hoffset[bcode].y
	  if aa[1].r<5 and aa[1].r<5 and aa[1].b<5 then () else  setpixels hback[ix+j,iy+i] aa
	  )
		selhanddlg.handdlg.bitmap=hback
	)
	
	fn selandshowhand  =
	(
	 copy temphback hback 
	 s=#()
	 for i=1 to 6 do
	 if hsz[i]==1 then
	  (
	   showsel i
	   append s handname[i]
	  )
	  select s
	)
	
	
	fn showhand lx=
	(
		if fingernum==5 then
		copy image_finger5 hback
	
		if fingernum==4 then
		copy image_finger4 hback
	
		if fingernum==3 then
		copy image_finger3 hback
	
		if fingernum==2 then
		copy image_finger2 hback
	
		copy hback temphback
		
		if lx==1 then
	 for i=0 to 24 do 
	 (
	  aa=getpixels image_greenhand [0,i] 24
	  setpixels temphback[0,91+i] aa
	  setpixels hback[0,91+i] aa
	  ) 
	  else
	  for i=0 to 24 do 
	 (
	  aa=getpixels image_bluehand [0,i] 24
	  setpixels temphback[91,91+i] aa
		setpixels hback[91,91+i] aa
	  )
	  
	   gethandname lx
	   selandshowhand()
	)
	
	fn readhandbutton x y=
	(
	hbtncode=0;hbtndown=0;
	 for i=1 to hbtn.count do
	   (sx=hbtn[i].x;sy=hbtn[i].y;
		ex=hbtn[i].w+hbtn[i].x;
		ey=hbtn[i].h+hbtn[i].y;
		 if x>sx and y>sy and x<ex and y<ey then (hbtncode=i;hbtndown=1)
		 )
	)
	
	fn selectallchild  =
	  (
	   toolMode.coordsys #local
		 with redraw off
				(
					temparray =#()
					--select obj		
					
					for i = 1 to 6  do
					(
						for j = 1 to $selection.count do  (append temparray ($selection[j]))
						max select child
					)			
					for i = 1 to temparray.count do (selectmore temparray[i])
				)
	   
	  )
	  
	
	
	fn mirror_sel =
	
	
	try
	(
		with redraw off
		(
			-- create blank arrays
			global biped_array = #()
			global non_biped_array = #()
			global opposite_biped_array =#()
			global rootbone
		
			-- Functions
			-- Function to find the biped's root and split the selected objects into arrays based on 
			--  whether or not they are biped objects
			fn get_biped =
			(
				temparray = #()
				tempvar
				for i in (selection as array) do
				(
					if classOf i == Biped_Object then
					(	
						append biped_array i
						tempvar = i
					)
					else
					(
						append non_biped_array i
					)
				)
				RootBone = tempvar.controller.rootnode
				/*for i = 1 to 30 do
				(
					append temparray $.name
					tempparent = $.parent
					try(select tempparent)catch()
				)			
				RootBone = $*/
			)
			
			-- A hacky function to mirror any biped_array with the opposing objects
			fn mirror_biped_selection biped_bone =
			(
				case of
				(
					(biped_bone == (biped.getNode RootBone #rarm link:1)): (append opposite_biped_array (biped.getNode RootBone #larm link:1))
					(biped_bone == (biped.getNode RootBone #larm link:1)): (append opposite_biped_array (biped.getNode RootBone #rarm link:1))
					(biped_bone == (biped.getNode RootBone #rarm link:2)): (append opposite_biped_array (biped.getNode RootBone #larm link:2))
					(biped_bone == (biped.getNode RootBone #larm link:2)): (append opposite_biped_array (biped.getNode RootBone #rarm link:2))
					(biped_bone == (biped.getNode RootBone #rarm link:3)): (append opposite_biped_array (biped.getNode RootBone #larm link:3))
					(biped_bone == (biped.getNode RootBone #larm link:3)): (append opposite_biped_array (biped.getNode RootBone #rarm link:3))
					(biped_bone == (biped.getNode RootBone #rarm link:4)): (append opposite_biped_array (biped.getNode RootBone #larm link:4))
					(biped_bone == (biped.getNode RootBone #larm link:4)): (append opposite_biped_array (biped.getNode RootBone #rarm link:4))
	
					(biped_bone == (biped.getNode RootBone #rfingers link:1)): (append opposite_biped_array (biped.getNode RootBone #lfingers link:1))
					(biped_bone == (biped.getNode RootBone #lfingers link:1)): (append opposite_biped_array (biped.getNode RootBone #rfingers link:1))
					(biped_bone == (biped.getNode RootBone #rfingers link:2)): (append opposite_biped_array (biped.getNode RootBone #lfingers link:2))
					(biped_bone == (biped.getNode RootBone #lfingers link:2)): (append opposite_biped_array (biped.getNode RootBone #rfingers link:2))
					(biped_bone == (biped.getNode RootBone #rfingers link:3)): (append opposite_biped_array (biped.getNode RootBone #lfingers link:3))
					(biped_bone == (biped.getNode RootBone #lfingers link:3)): (append opposite_biped_array (biped.getNode RootBone #rfingers link:3))
					(biped_bone == (biped.getNode RootBone #rfingers link:4)): (append opposite_biped_array (biped.getNode RootBone #lfingers link:4))
					(biped_bone == (biped.getNode RootBone #lfingers link:4)): (append opposite_biped_array (biped.getNode RootBone #rfingers link:4))
					(biped_bone == (biped.getNode RootBone #rfingers link:5)): (append opposite_biped_array (biped.getNode RootBone #lfingers link:5))
					(biped_bone == (biped.getNode RootBone #lfingers link:5)): (append opposite_biped_array (biped.getNode RootBone #rfingers link:5))
					(biped_bone == (biped.getNode RootBone #rfingers link:6)): (append opposite_biped_array (biped.getNode RootBone #lfingers link:6))
					(biped_bone == (biped.getNode RootBone #lfingers link:6)): (append opposite_biped_array (biped.getNode RootBone #rfingers link:6))
					(biped_bone == (biped.getNode RootBone #rfingers link:7)): (append opposite_biped_array (biped.getNode RootBone #lfingers link:7))
					(biped_bone == (biped.getNode RootBone #lfingers link:7)): (append opposite_biped_array (biped.getNode RootBone #rfingers link:7))
					(biped_bone == (biped.getNode RootBone #rfingers link:8)): (append opposite_biped_array (biped.getNode RootBone #lfingers link:8))
					(biped_bone == (biped.getNode RootBone #lfingers link:8)): (append opposite_biped_array (biped.getNode RootBone #rfingers link:8))
					(biped_bone == (biped.getNode RootBone #rfingers link:9)): (append opposite_biped_array (biped.getNode RootBone #lfingers link:9))
					(biped_bone == (biped.getNode RootBone #lfingers link:9)): (append opposite_biped_array (biped.getNode RootBone #rfingers link:9))
					(biped_bone == (biped.getNode RootBone #rfingers link:10)): (append opposite_biped_array (biped.getNode RootBone #lfingers link:10))
					(biped_bone == (biped.getNode RootBone #lfingers link:10)): (append opposite_biped_array (biped.getNode RootBone #rfingers link:10))
					(biped_bone == (biped.getNode RootBone #rfingers link:11)): (append opposite_biped_array (biped.getNode RootBone #lfingers link:11))
					(biped_bone == (biped.getNode RootBone #lfingers link:11)): (append opposite_biped_array (biped.getNode RootBone #rfingers link:11))
					(biped_bone == (biped.getNode RootBone #rfingers link:12)): (append opposite_biped_array (biped.getNode RootBone #lfingers link:12))
					(biped_bone == (biped.getNode RootBone #lfingers link:12)): (append opposite_biped_array (biped.getNode RootBone #rfingers link:12))
					(biped_bone == (biped.getNode RootBone #rfingers link:13)): (append opposite_biped_array (biped.getNode RootBone #lfingers link:13))
					(biped_bone == (biped.getNode RootBone #lfingers link:13)): (append opposite_biped_array (biped.getNode RootBone #rfingers link:13))
					(biped_bone == (biped.getNode RootBone #rfingers link:14)): (append opposite_biped_array (biped.getNode RootBone #lfingers link:14))
					(biped_bone == (biped.getNode RootBone #lfingers link:14)): (append opposite_biped_array (biped.getNode RootBone #rfingers link:14))
					(biped_bone == (biped.getNode RootBone #rfingers link:15)): (append opposite_biped_array (biped.getNode RootBone #lfingers link:15))
					(biped_bone == (biped.getNode RootBone #lfingers link:15)): (append opposite_biped_array (biped.getNode RootBone #rfingers link:15))
	
					(biped_bone == (biped.getNode RootBone #rleg link:1)): (append opposite_biped_array (biped.getNode RootBone #lleg link:1))
					(biped_bone == (biped.getNode RootBone #lleg link:1)): (append opposite_biped_array (biped.getNode RootBone #rleg link:1))
					(biped_bone == (biped.getNode RootBone #rleg link:2)): (append opposite_biped_array (biped.getNode RootBone #lleg link:2))
					(biped_bone == (biped.getNode RootBone #lleg link:2)): (append opposite_biped_array (biped.getNode RootBone #rleg link:2))
					(biped_bone == (biped.getNode RootBone #rleg link:3)): (append opposite_biped_array (biped.getNode RootBone #lleg link:3))
					(biped_bone == (biped.getNode RootBone #lleg link:3)): (append opposite_biped_array (biped.getNode RootBone #rleg link:3))
					(biped_bone == (biped.getNode RootBone #rleg link:4)): (append opposite_biped_array (biped.getNode RootBone #lleg link:4))
					(biped_bone == (biped.getNode RootBone #lleg link:4)): (append opposite_biped_array (biped.getNode RootBone #rleg link:4))
	
					(biped_bone == (biped.getNode RootBone #rtoes link:1)): (append opposite_biped_array (biped.getNode RootBone #ltoes link:1))
					(biped_bone == (biped.getNode RootBone #ltoes link:1)): (append opposite_biped_array (biped.getNode RootBone #rtoes link:1))
					(biped_bone == (biped.getNode RootBone #rtoes link:2)): (append opposite_biped_array (biped.getNode RootBone #ltoes link:2))
					(biped_bone == (biped.getNode RootBone #ltoes link:2)): (append opposite_biped_array (biped.getNode RootBone #rtoes link:2))
					(biped_bone == (biped.getNode RootBone #rtoes link:3)): (append opposite_biped_array (biped.getNode RootBone #ltoes link:3))
					(biped_bone == (biped.getNode RootBone #ltoes link:3)): (append opposite_biped_array (biped.getNode RootBone #rtoes link:3))
					(biped_bone == (biped.getNode RootBone #rtoes link:4)): (append opposite_biped_array (biped.getNode RootBone #ltoes link:4))
					(biped_bone == (biped.getNode RootBone #ltoes link:4)): (append opposite_biped_array (biped.getNode RootBone #rtoes link:4))
					(biped_bone == (biped.getNode RootBone #rtoes link:5)): (append opposite_biped_array (biped.getNode RootBone #ltoes link:5))
					(biped_bone == (biped.getNode RootBone #ltoes link:5)): (append opposite_biped_array (biped.getNode RootBone #rtoes link:5))
					(biped_bone == (biped.getNode RootBone #rtoes link:6)): (append opposite_biped_array (biped.getNode RootBone #ltoes link:6))
					(biped_bone == (biped.getNode RootBone #ltoes link:6)): (append opposite_biped_array (biped.getNode RootBone #rtoes link:6))
					(biped_bone == (biped.getNode RootBone #rtoes link:7)): (append opposite_biped_array (biped.getNode RootBone #ltoes link:7))
					(biped_bone == (biped.getNode RootBone #ltoes link:7)): (append opposite_biped_array (biped.getNode RootBone #rtoes link:7))
					(biped_bone == (biped.getNode RootBone #rtoes link:8)): (append opposite_biped_array (biped.getNode RootBone #ltoes link:8))
					(biped_bone == (biped.getNode RootBone #ltoes link:8)): (append opposite_biped_array (biped.getNode RootBone #rtoes link:8))
					(biped_bone == (biped.getNode RootBone #rtoes link:9)): (append opposite_biped_array (biped.getNode RootBone #ltoes link:9))
					(biped_bone == (biped.getNode RootBone #ltoes link:9)): (append opposite_biped_array (biped.getNode RootBone #rtoes link:9))
					(biped_bone == (biped.getNode RootBone #rtoes link:10)): (append opposite_biped_array (biped.getNode RootBone #ltoes link:10))
					(biped_bone == (biped.getNode RootBone #ltoes link:10)): (append opposite_biped_array (biped.getNode RootBone #rtoes link:10))
					(biped_bone == (biped.getNode RootBone #rtoes link:11)): (append opposite_biped_array (biped.getNode RootBone #ltoes link:11))
					(biped_bone == (biped.getNode RootBone #ltoes link:11)): (append opposite_biped_array (biped.getNode RootBone #rtoes link:11))
					(biped_bone == (biped.getNode RootBone #rtoes link:12)): (append opposite_biped_array (biped.getNode RootBone #ltoes link:12))
					(biped_bone == (biped.getNode RootBone #ltoes link:12)): (append opposite_biped_array (biped.getNode RootBone #rtoes link:12))
					(biped_bone == (biped.getNode RootBone #rtoes link:13)): (append opposite_biped_array (biped.getNode RootBone #ltoes link:13))
					(biped_bone == (biped.getNode RootBone #ltoes link:13)): (append opposite_biped_array (biped.getNode RootBone #rtoes link:13))
					(biped_bone == (biped.getNode RootBone #rtoes link:14)): (append opposite_biped_array (biped.getNode RootBone #ltoes link:14))
					(biped_bone == (biped.getNode RootBone #ltoes link:14)): (append opposite_biped_array (biped.getNode RootBone #rtoes link:14))
					(biped_bone == (biped.getNode RootBone #rtoes link:15)): (append opposite_biped_array (biped.getNode RootBone #ltoes link:15))
					(biped_bone == (biped.getNode RootBone #ltoes link:15)): (append opposite_biped_array (biped.getNode RootBone #rtoes link:15))
	
					(biped_bone == (biped.getNode RootBone #spine link:1)): (append opposite_biped_array (biped.getNode RootBone #spine link:1))
					(biped_bone == (biped.getNode RootBone #spine link:2)): (append opposite_biped_array (biped.getNode RootBone #spine link:2))
					(biped_bone == (biped.getNode RootBone #spine link:3)): (append opposite_biped_array (biped.getNode RootBone #spine link:3))
					(biped_bone == (biped.getNode RootBone #spine link:4)): (append opposite_biped_array (biped.getNode RootBone #spine link:4))
					(biped_bone == (biped.getNode RootBone #spine link:5)): (append opposite_biped_array (biped.getNode RootBone #spine link:5))
	
					(biped_bone == (biped.getNode RootBone #tail link:1)): (append opposite_biped_array (biped.getNode RootBone #tail link:1))
					(biped_bone == (biped.getNode RootBone #tail link:2)): (append opposite_biped_array (biped.getNode RootBone #tail link:2))
					(biped_bone == (biped.getNode RootBone #tail link:3)): (append opposite_biped_array (biped.getNode RootBone #tail link:3))
					(biped_bone == (biped.getNode RootBone #tail link:4)): (append opposite_biped_array (biped.getNode RootBone #tail link:4))
					(biped_bone == (biped.getNode RootBone #tail link:5)): (append opposite_biped_array (biped.getNode RootBone #tail link:5))
	
					(biped_bone == (biped.getNode RootBone #head link:1)): (append opposite_biped_array (biped.getNode RootBone #head link:1))
	
					(biped_bone == (biped.getNode RootBone #pelvis link:1)): (append opposite_biped_array (biped.getNode RootBone #pelvis link:1))
	
					(biped_bone == (biped.getNode RootBone #neck link:1)): (append opposite_biped_array (biped.getNode RootBone #neck link:1))
					(biped_bone == (biped.getNode RootBone #neck link:2)): (append opposite_biped_array (biped.getNode RootBone #neck link:2))
					(biped_bone == (biped.getNode RootBone #neck link:3)): (append opposite_biped_array (biped.getNode RootBone #neck link:3))
					(biped_bone == (biped.getNode RootBone #neck link:4)): (append opposite_biped_array (biped.getNode RootBone #neck link:4))
					(biped_bone == (biped.getNode RootBone #neck link:5)): (append opposite_biped_array (biped.getNode RootBone #neck link:5))
	
					(biped_bone == (biped.getNode RootBone #pony1 link:1)): (append opposite_biped_array (biped.getNode RootBone #pony1 link:1))
					(biped_bone == (biped.getNode RootBone #pony2 link:1)): (append opposite_biped_array (biped.getNode RootBone #pony2 link:1))
					(biped_bone == (biped.getNode RootBone #pony1 link:2)): (append opposite_biped_array (biped.getNode RootBone #pony1 link:2))
					(biped_bone == (biped.getNode RootBone #pony2 link:2)): (append opposite_biped_array (biped.getNode RootBone #pony2 link:2))
					(biped_bone == (biped.getNode RootBone #pony1 link:3)): (append opposite_biped_array (biped.getNode RootBone #pony1 link:3))
					(biped_bone == (biped.getNode RootBone #pony2 link:3)): (append opposite_biped_array (biped.getNode RootBone #pony2 link:3))
					(biped_bone == (biped.getNode RootBone #pony1 link:4)): (append opposite_biped_array (biped.getNode RootBone #pony1 link:4))
					(biped_bone == (biped.getNode RootBone #pony2 link:4)): (append opposite_biped_array (biped.getNode RootBone #pony2 link:4))
					(biped_bone == (biped.getNode RootBone #pony1 link:5)): (append opposite_biped_array (biped.getNode RootBone #pony1 link:5))
					(biped_bone == (biped.getNode RootBone #pony2 link:5)): (append opposite_biped_array (biped.getNode RootBone #pony2 link:5))
					
					(biped_bone == (biped.getNode RootBone #prop1 link:1)): (append opposite_biped_array (biped.getNode RootBone #prop1 link:1))
					(biped_bone == (biped.getNode RootBone #prop2 link:1)): (append opposite_biped_array (biped.getNode RootBone #prop2 link:1))
					(biped_bone == (biped.getNode RootBone #prop3 link:1)): (append opposite_biped_array (biped.getNode RootBone #prop3 link:1))
					
				)	
			)
			get_biped()				
	--				deselect $
			
			-- creates an array of all opposing biped bones
			for i = 1 to biped_array.count do
			(
				mirror_biped_selection(biped_array[i])	
			)
			
			-- adds the original non biped bones to the opposing array
			for i = 1 to non_biped_array.count do
			(
				append opposite_biped_array non_biped_array[i]
			)
			select opposite_biped_array
		)-- end redraw
	)
	catch(format"Could not mirror selection\n")
	
	
	
	rollout selhanddlg "手部细调" width:117 height:118
	(
		bitmap handdlg "Bitmap" pos:[1,1] width:115 height:115
	
		on selhanddlg open do
		(
		bip=bipname[24].controller
		fingernum=bip.fingers
		fingerlink=bip.fingerLinks 
		
		if fingernum==5 then
		copy image_finger5 hback
		
		if fingernum==4 then
		copy image_finger4 hback
		
		if fingernum==3 then
		copy image_finger3 hback
		
		if fingernum==2 then
		copy image_finger2 hback
		sethandbtn fingernum
		showhand     nowhandlx
		gethandname nowhandlx
		copy hback temphback
		handdlg .bitmap= hback
		)
		
	------------------------------------------------------------------	
		on selhanddlg lbuttondown pos do
		(
		print ("x="+pos.x as string )
		print ("y="+pos.y as string )
		readhandbutton (pos.x) (pos.y-1)
		  
		if hbtncode>fingernum+1 then
		(
		if nowhandlx!=(hbtncode-fingernum-1)	then
		(
		 mirror_sel()
		 tempsel=#()
		for o in (selection as array) do append tempsel o
		 showhand    (hbtncode-fingernum-1)
		 gethandname (hbtncode-fingernum-1)
		 select tempsel
		 nowhandlx=(hbtncode-fingernum-1)
		 handdlg .bitmap= hback
		 
		 )
		)
		else
		if hbtncode!=0  then 
		if  keyboard.controlpressed == true then
		  (  
			hsz[hbtncode]=1-hsz[hbtncode];
		  selandshowhand ()
		  handdlg.bitmap=hback
		)	
		else
		  (  
		  hsz=#(0,0,0,0,0,0)
			hsz[hbtncode]=1;
		  selandshowhand ()
		  handdlg.bitmap=hback
		)
		)
	------------------------------------------------------------------------
		on selhanddlg rbuttondown pos do
		(
		print ("x="+pos.x as string )
		print ("y="+pos.y as string )
		readhandbutton (pos.x) (pos.y-1)
		if hbtncode!=0 and hbtncode<=fingernum then 
		  (  
		  hsz=#(0,0,0,0,0,0)
		 for i=2 to fingernum do
			hsz[i]=1;
		  selandshowhand ()
		  selectallchild()
		  handdlg.bitmap=hback
		)
		)
		
		on selhanddlg lbuttondblclk pos  do
		(
		print ("x="+pos.x as string )
		print ("y="+pos.y as string )
		readhandbutton (pos.x) (pos.y-1)
		
		if hbtncode!=0 and hbtncode<=fingernum  then 
		 ( 
		  selectallchild()
		  
		  handdlg.bitmap=hback
		)
		else 
		if hbtncode==fingernum+1 then
		( 
		for i=1 to fingernum+1 do (hsz[i]=1;showsel i)
		 
		select handname[fingernum+1]
		selectallchild()
		)
		)
	)
	
	
	
	fn rebuildchar str=
	(
	newchar=""
	for i=1 to str.count do
	(
	x=substring str i 1
	if x!="
	"
	then  newchar=newchar+x
	)
	
	)
	
	
	fn getAllBips =
	(
		allBips = #()
		for obj in geometry do
		(
			if classof obj.controller == Vertical_Horizontal_Turn then 
			(
				append allBips obj
			)
		)
		return allBips
	)
	
	-- function to return all biped bones in the current scene
	
	fn getAllBipBones =
	(
		allBips = #()
		for obj in geometry do
		(
			if classof obj == Biped_Object then 
			(
				append allBips obj
			)
		)
		return allBips
	)
	
	
	fn getBipRootNode obj1 =
	(
		if classof obj1 == Biped_Object then
		(
			obj_root = obj1.controller.rootnode
			return obj_root
		)
		else
		(
			return obj1
		)
	)
	
	
	
	
	
	
	function savedate  =
		(
		   f=createFile("$maxData\\cstool.ini")
			format "%\t%\n" dialog_x dialog_y to:f
			format "%\t%\t%\t%\t%\n" mystarttime myendtime myrangetime mymovetime myaddtime to:f
		   format "%\n" bspeed to:f
		   format "%\n" filepath  to: f
		   format "%\n" autotimelimit to:f
		   format "%\n" bipnumlimit  to:f
		   close f
		)
		
	
	function savePathData  =
		(
		   f=createFile("$UI_ln\\bipPath.ini")
		   for i=1 to 20 do
			format "%\n" pathItems[i] to:f
		   close f
		)
		
		
	function loaddate  =
	   (
		f = openfile ("$maxData\\cstool.ini")
	
		if f != undefined then 
		   try
			  (
		   dialog_x=readvalue f;dialog_y=readvalue f;
		   mystarttime =readvalue f; myendtime =readvalue f; myrangetime =readvalue f; mymovetime =readvalue f;myaddtime =readvalue f;    
		   bspeed=readvalue f;
		   filepath=readLine f
		   autotimelimit=readvalue f
		   bipnumlimit =readvalue f
		   format "%\t%\n" dialog_x dialog_y 
		   format "%\t%\t%\t%\t%\n" mystarttime myendtime myrangetime mymovetime myaddtime 
		   format "%\n" bspeed 
		   format "%\n" filepath  
		   format "%\n" autotimelimit
		   format "%\n" bipnumlimit  
		   close f 
		  ) 	catch()
		  else 
		  try( 
	
		   f=createFile("$maxData\\cstool.ini")
			format "%\t%\t%\n" dialog_x dialog_y to:f
			format "%\t%\t%\t%\t%\n" mystarttime myendtime myrangetime mymovetime myaddtime to:f
		   format "%\n" bspeed to:f
		   format "%\n" filepath  to: f
		   format "%\n" autotimelimit to:f
		   format "%\n" bipnumlimit  to:f
		   close f
		  
		  )catch() 
	   )
		
	function loadPathData  =
	   (
		f = openfile ("$UI_ln\\bipPath.ini")
	
		if f != undefined then 
		   try
			  (
		   for i=1 to 20 do  pathItems[i]=readline f 
			for i=1 to 20 do  format "%\n" pathItems[i]
		   close f 
		  ) 	catch()
		  else  
		  try( 
		   f=createFile("$UI_ln\\bipPath.ini")
		   for i=1 to 20 do
			format "%\n" pathItems[i] to:f
		   close f
		  )catch()
	   )
	   
	loaddate()
	if dialog_y<=0 then dialog_y=1
	loadPathData()
	
	
	
	global mode=1
	global footmode=1
	global bipname=#()
	global sz=#(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	
	struct rect(x,y,w,h)
	global btncode=888
	global btn=#()
	btn[ 1] = rect 44   0 30 30
	btn[ 2] = rect 54  31 16 27
	btn[ 3] = rect 24  33 21 21
	btn[ 4] = rect 72  33 21 21
	btn[ 5] = rect 15  62 21 21
	btn[ 6] = rect 82  62 21 21
	btn[ 7] = rect  9  92 21 21
	btn[ 8] = rect 88  92 21 21
	btn[ 9] = rect  2 120 21 21
	btn[10] = rect 94 120 21 21
	btn[11] = rect 29 144 21 21
	btn[12] = rect 67 144 21 21
	btn[13] = rect 23 182 21 21
	btn[14] = rect 73 182 21 21
	btn[15] = rect 23 216 21 21
	btn[16] = rect 73 216 21 21
	btn[17] = rect  0 216 21 21
	btn[18] = rect 96 216 21 21
	btn[19] = rect 48  59 30 13
	btn[20] = rect 48  73 30 13
	btn[21] = rect 48  88 30 13
	btn[22] = rect 48 102 30 13
	btn[23] = rect 34 114 12 15
	btn[24] = rect 48 116 21 21
	btn[25] = rect 34  60 11 53
	btn[26] = rect  0   0 25 25
	btn[27] = rect 89   0 25 25
	btn[28] = rect  0 151 25 25
	btn[29] = rect 92 151 25 25
	btn[30] = rect 46 196 25 25
	btn[31] = rect 3   33 20 20
	btn[32] = rect 95  33 20 20
	
	
	offset=#()
	offset[1]=point2   7   7
	offset[2]=point2  -3   4
	offset[3]=point2   2   2
	offset[4]=point2   2   2
	offset[5]=point2   2   1
	offset[6]=point2   2   1
	offset[7]=point2   2   1
	offset[8]=point2   2   1
	offset[9]=point2   2   0
	offset[10]=point2  2   0
	offset[11]=point2  2  -1
	offset[12]=point2  3  -1
	offset[13]=point2  3  -2
	offset[14]=point2  3  -2
	offset[15]=point2  2  -3
	offset[16]=point2  3  -3
	offset[17]=point2  3  -2
	offset[18]=point2  3  -2
	offset[19]=point2  2  -3
	offset[20]=point2  3  -3
	offset[21]=point2  2  -4
	offset[22]=point2  2  -4
	offset[23]=point2 -2   0
	offset[24]=point2  2   0
	
	 allbipsName =#()
	 allbips = getallbips()
	 for i = 1 to allbips.count do (append allbipsName allbips[i].name)
	
	leftx=58;lefty=313
	rightx=0;righty=313
	global opf=0;
	
	if ottool != undefind then CloseRolloutfloater ottool
	
	
	sdlx=0;
	jzlx=0;
	
	
	
	
	
	
	
	rollout mergebip "MIX工具" width:294 height:157
	(
		button btn14 "..." pos:[12,34] width:27 height:25
		button btn15 "按文件名顺序进行MIX合并" pos:[12,67] width:270 height:46 enabled:true toolTip:""
		editText edt2 "" pos:[41,36] width:237 height:23
		groupBox grp1 "MIX文件夹下所有的文件" pos:[6,9] width:284 height:121
	
	
	on mergebip open do
	(
	edt2.text=filepath 
	)
	
	on btn14 pressed do
	(
	  loadfilepath = getSavePath caption:"选择读取文件路径:"  initialDir:filepath
	if loadfilepath!=undefined then edt2.text=loadfilepath 
	)
	
	on btn15 pressed do
	(
	
	loadfilepath=edt2.text
	-- bip = biped.createNew 100 -90 [0,0,0] arms:true neckLinks:2 spineLinks:4 legLinks:4 \
	-- tailLinks:1 ponyTail1Links:1 ponyTail2Links:1 fingers:5 fingerLinks:2 toes:4 toeLinks:2 ankleAttach:0.3 trianglePelvis:True  
	 
	
	if $sangum070816_Bip01==undefind then
	      mergeMAXFile "$UI_ln\\ICONS\\cstoolIcons\\newbip.max"  #select
	
	bip=$sangum070816_Bip01.controller
	
	themixer.addMixerToDisplay $sangum070816_Bip01.transform.controller
	
	mymixer = $sangum070816_Bip01.transform.controller.mixer
	
	if mymixer.numTrackgroups<1 then appendTrackgroup  mymixer
	
	mx1=getTrackgroup mymixer 1
	 
	mx2=getTrack mx1 1
	
	theFiles = getFiles (loadfilepath+"\\*.bip") 
	
	--对文件名进行排序--------------------------------------------
			for  i=1 to theFiles.count  do
			     for j=1 to theFiles.count do
				 (
				   if theFiles[i]< theFiles[j] then ( temp= theFiles[i]; theFiles[i]=theFiles[j];theFiles[j]=temp;)
				 ) 
	---------------------------------------------------------------
	
	bip.figureMode= false
	        bip.mixerMode=true
			for f in theFiles do
				if f.count>18 then
				(
				  bipname=substring f (f.count-17) 18
				   if bipname!="cstools_mixall.bip" then  mx3=appendClip mx2 f  false 1f 
				   )
				   else
				   mx3=appendClip mx2 f  false 1f 
	
		   mixdown mymixer true true 6 true 166.15
		   copyMixdownToBiped  mymixer
		   bip.mixerMode=false
		   bipfile=loadfilepath+"\\"+"cstools_mixall.bip"
		   biped.saveBipfile bip bipfile
		   select  $sangum070816*
	        actionMan.executeAction 0 "40020"  -- Edit: Delete Objects
	   )
	)
	
	rollout aboutme "about" width:200 height:241
	(	GroupBox grp5 "" pos:[3,4] width:182 height:96
		label lbl1 "这个脚本利用业余时间历时好几个月才完成。希望你能喜欢。" pos:[10,15] width:162 height:77
		label lbl2 "VER：0.75" pos:[5,108] width:117 height:22
		label lbl3 "作者：郑善俊" pos:[5,134] width:117 height:22
		label lbl4 "希望能和大家多交流。我的QQ：30020524" pos:[7,162] width:153 height:56
	)
	
	rollout ot00 "BIP满整数帧切换" width:200 height:65
	(
		button btn18 "BIP满整数帧切换" pos:[9,19] width:167 height:30
		GroupBox grp5 "" pos:[3,7] width:182 height:47
		
		on btn18 pressed do
		(
		bip=bipname[24].Controller
		tempfile=getdir #maxroot+"temp.bip"
		s1=integer(animationrange.start)
		s2=integer(animationrange.end)
		biped.saveBipFileSegment bip  tempfile s1 s2 #keyPerFrame
	
		animationRange = Interval 0 1
		bip.figureMode= false
		biped.loadBipfile bip tempfile
		)
	)
	
	rollout ot01 "滑动帧范围锁定" width:200 height:145
	(
		spinner spn1 "" pos:[4,30] width:58 height:16 range:[0,9999,0] type:#integer
		spinner spn2 "" pos:[65,30] width:56 height:16 range:[0,9999,0] type:#integer
		button starttime_btn "开始帧" pos:[6,51] width:51 height:28
		button endtime_btn "结束帧" pos:[66,50] width:50 height:29
		button current_btn "默认帧" pos:[134,26] width:49 height:25
		button ok_btn "开始锁定" pos:[90,85] width:92 height:42
		GroupBox grp1 "滑动帧范围锁定" pos:[2,8] width:184 height:128
		radiobuttons rdo1 "" pos:[5,84] width:93 height:48 enabled:true labels:#("当前选择的", "双手", "双脚") default:1 columns:1
		
		on ot01 open do
		(
		 sdlx=1;
		)
		
		on starttime_btn pressed do	 spn1.value=currentTime
		on endtime_btn pressed do
		(
		if currentTime>spn1.value then spn2.value=currentTime
		 )
		 
		on current_btn pressed do 
		(
		spn1.value=animationrange.start;
		spn2.value=animationrange.end;
		)
		
		on rdo1 changed sel do
		(
		sdlx=sel;
		)
		
		on ok_btn pressed do
		(	
		if sdlx==1 then 
		try(
		   for i=spn1.value to spn2.value do
		   (
			slidertime=i;
			biped.setSlidingKey $
			)
			)catch()
		if sdlx==2 then 
		   for i=spn1.value to spn2.value do
		   (
			slidertime=i;
			biped.setSlidingKey bipname[9];
			biped.setSlidingKey bipname[10];
			)	
		if sdlx==3 then 
		   for i=spn1.value to spn2.value do
		   (
			slidertime=i;
			biped.setSlidingKey bipname[15];
			biped.setSlidingKey bipname[16];
			)
		)
	)
	
	/*
	if zbdlg!=undefined then destroydialog zbdlg
	rollout zbdlg "Untitled" width:188 height:74
	(
		editText edt1 "" pos:[73,18] width:42 height:16
		editText edt2 "" pos:[123,18] width:42 height:16
		editText edt3 "" pos:[72,45] width:42 height:16
		editText edt4 "" pos:[124,45] width:42 height:16
		label lbl5 "窗口位置" pos:[8,18] width:65 height:16
		label lbl6 "鼠标位置" pos:[7,45] width:65 height:16
	)
	
	
	createdialog zbdlg  
	*/
	
	global posobj,CShand
	rollout followobj "跟随" width:200 height:207
	(
		spinner spn1 "" pos:[8,27] width:47 height:16 range:[0,9999,0] type:#integer
		spinner spn2 "" pos:[69,27] width:46 height:16 range:[0,9999,0] type:#integer
		button starttime_btn "开始帧" pos:[10,47] width:51 height:21
		button endtime_btn "结束帧" pos:[62,47] width:50 height:22
		button current_btn "默认帧" pos:[127,26] width:49 height:19
		button ok_btn "开始跟随" pos:[11,100] width:174 height:28
		GroupBox grp1 "跟随物体" pos:[5,6] width:189 height:128
		spinner spn3 "间距:" pos:[127,51] width:61 height:16 range:[0,9999,1] type:#integer
		pickbutton btn33 "拾取跟随物" pos:[103,72] width:81 height:23
		pickbutton btn79 "拾取手部" pos:[14,72] width:81 height:23
		
		
		on starttime_btn pressed do	spn1.value=currentTime
		
		on endtime_btn pressed do	if currentTime>spn1.value then spn2.value=currentTime
		
		on current_btn pressed do
		(
		spn1.value=animationrange.start;
		spn2.value=animationrange.end;
		)
		
		on ok_btn pressed do
		undo on
		(
		slidertime=spn1.value
		--创建参考物体
		select CShand
		slidertime=spn1.value
		biped.setFreeKey $
		handpos=biped.getTransform  CShand #pos 
		Point pos:handpos name:"handpoint"
		 --将参考物体角度设置为和手部一致	
		
		rp=biped.getTransform CShand #ROTATION
		rp=quatToEuler rp
		in coordsys local rotate $handpoint rp
		 max motion mode
		--链给身体
		$handpoint.parent=posobj
		for tt=spn1.value to spn2.value by spn3.value do
		(
		slidertime=tt
		biped.setTransform  CShand #pos $handpoint.pos true
		rt= $handpoint.rotation
	
		biped.setTransform $  #rotation  (quat 0 0 0 0)  true
		in coordsys local rotate $ rt
		 
		 biped.setSelectedkey $.controller
	
		)
		delete $handpoint
		)
		
		on btn33 picked obj do
		(
			btn33.caption=obj.name
			posobj=obj
		)	
		
		on btn79 picked obj do
		(
			btn79.caption=obj.name
			CShand=obj
		)
		
	 
	)	
		
		
	
	rollout ot02 "物体精减关键帧" width:200 height:145
	(
		spinner spn1 "" pos:[4,30] width:58 height:16 range:[0,9999,0] type:#integer
		spinner spn2 "" pos:[65,30] width:56 height:16 range:[0,9999,0] type:#integer
		button starttime_btn "开始帧" pos:[6,51] width:51 height:28
		button endtime_btn "结束帧" pos:[66,50] width:50 height:29
		button current_btn "默认帧" pos:[134,26] width:49 height:25
		button ok_btn "开始减帧" pos:[90,85] width:92 height:42
		GroupBox grp1 "滑动帧范围锁定" pos:[2,8] width:184 height:128
		radiobuttons rdo1 "" pos:[5,84] width:93 height:32 enabled:true labels:#("当前选择的", "整副骨架的") default:1 columns:1
		spinner skip "跳帧" pos:[135,61] width:49 height:16 range:[0,20,0] type:#integer
		
		on ot02 open do
		(
		 jzlx=1;
		 skip.value=2;
		)
			
		on starttime_btn pressed do
			spn1.value=currentTime
			
		on endtime_btn pressed do
		(
		if currentTime>spn1.value then spn2.value=currentTime 	
		 )
		on current_btn pressed do
		(
		spn1.value=animationrange.start;
		spn2.value=animationrange.end;
		)
		on ok_btn pressed do
		(
			 b1 =  spn1.value;
			fend= spn2.value;	
				step =skip.value;  
				
		if jzlx==1 then 
		undo on
		  (
		bip = bipname[24].transform.controller
		if sz[24]==1 then
		(
		vertCont = bip.vertical.controller
		horzCont = bip.horizontal.controller
		turnCont = bip.turning.controller
		for btime =1  to integer (fend / step) do
		 if (b1 + step)<=fend then
			(	
			b2 = b1 + step
			biped.addNewKey vertCont b2
			biped.addNewKey horzCont b2
			biped.addNewKey turnCont b2
			if b2 <= fend then  deleteTime bipname[24].transform.controller b1 b2 #noslide
			b1 += step
			)
		)
	
		 selobj=#()
		if sz[1]==1 or sz[2]==1 then append selobj bipname[1]
		if sz[3]==1 or sz[5]==1 or sz[7]==1 or sz[9]==1 then append selobj bipname[9]   
		if sz[4]==1 or sz[6]==1 or sz[8]==1 or sz[10]==1 then append selobj bipname[10]
		if sz[11]==1 or sz[13]==1 or sz[15]==1 or sz[17]==1 then append selobj bipname[11]
		if sz[12]==1 or sz[14]==1 or sz[16]==1 or sz[18]==1 then append selobj bipname[12]
		if sz[19]==1 or sz[20]==1 or sz[21]==1 or sz[22]==1 then append selobj bipname[22]
		if sz[23]==1  then append selobj bipname[23]	
		
		
		for btime =1  to integer (fend / step) do
		   if (b1 + step)<=fend then
			(	
				b2 = b1 + step
				for m in selobj do
					  biped.addNewKey m.transform.controller b2
				if b2 <= fend then
					(
						for i in  selobj do 
								 deleteTime i.transform.controller b1 b2 #noslide
					)
				b1 += step
			)
	
	
	
		   )
	
		if jzlx==2 then 
		undo on
		   (
	
	
		bip = bipname[24].transform.controller
		vertCont = bip.vertical.controller
		horzCont = bip.horizontal.controller
		turnCont = bip.turning.controller
	
		for btime =1  to integer (fend / step) do
		 if (b1 + step)<=fend then
			(	
				b2 = b1 + step
			biped.addNewKey vertCont b2
			biped.addNewKey horzCont b2
			biped.addNewKey turnCont b2
				for m in #(bipname[23],
										bipname[22],
										bipname[1],
										bipname[10],
										bipname[9],
										bipname[11],
										bipname[12])
						 do biped.addNewKey m.transform.controller b2
				if b2 <= fend then
					(
						for i in #(bipname[24],bipname[23],
										bipname[22],
										bipname[1],
										bipname[10],
										bipname[9],
										bipname[11],
										bipname[12])
								 do deleteTime i.transform.controller b1 b2 #noslide
					)
				b1 += step
			)
	
	
		   )	
		)
		on rdo1 changed sel do
		(
		jzlx=sel;
		)
	)
	
	
	
	
	rollout ot05 "插入删除BIP帧" width:200 height:145
	(
		spinner spn1 "" pos:[28,25] width:58 height:16 range:[0,9999,0] type:#integer
		spinner spn2 "" pos:[115,25] width:56 height:16 range:[0,9999,0] type:#integer
		button starttime_btn "开始帧" pos:[30,46] width:51 height:22
		button endtime_btn "结束帧" pos:[116,45] width:50 height:23
		button ins_btn "插入指定范围空白帧" pos:[11,106] width:174 height:29
		GroupBox grp1 "帧范围处理" pos:[7,3] width:184 height:139
		button del_btn "删除指定范围关键帧" pos:[13,73] width:174 height:27	 
		 
		
	 
	fn insertframe n1 n2=
	(
	  bip = bipname[24].controller
	  --插入关键帧	
	   insertTime bip n1 (n2-n1)   --只插入重心的关键帧
	  for i in 
	   #(
	   bipname[23],
	   bipname[22],
	   bipname[ 1],
	   bipname[10],
	   bipname[ 9],
	   bipname[11],
	   bipname[12]
	   )
		  do
		 insertTime i.transform.controller n1 (n2-n1)
	 
	)
	
	fn deleteframe n1 n2=
	( 
	  bip = bipname[24].controller
	  for obj in 
	   #(
	   bipname[24],
	   bipname[23],
	   bipname[22],
	   bipname[ 1],
	   bipname[10],
	   bipname[ 9],
	   bipname[11],
	   bipname[12]
	   )
		do 
		(
		-- if n1<0 then n1=0
		 deleteTime obj.transform.controller n1 n2 #incLeft 
		 )
	 
	)
	
	   on ot05 open do
	   spn2.value=2
		 
			
		on starttime_btn pressed do	 spn1.value=currentTime
		on endtime_btn pressed do
		(
		if currentTime>spn1.value then spn2.value=currentTime
		 )
		 
		on ins_btn pressed do
		(
		 if spn1.value>spn2.value then 
		  (
		  temp=spn1.value
		  spn1.value=spn2.value
		  spn2.value=temp
		  )
		   undo on insertframe spn1.value spn2.value
		)	
		
		on del_btn pressed do
		(
		 if spn1.value>spn2.value then 
		  (
		  temp=spn1.value
		  spn1.value=spn2.value
		  spn2.value=temp
		  )
		  undo on deleteframe spn1.value spn2.value
		)
	 
	)
	
	
	
	
	
	rollout turnBIPframe "反转关键帧" width:200 height:145
	(
		spinner spn1 "" pos:[8,27] width:58 height:16 range:[0,9999,0] type:#integer
		spinner spn2 "" pos:[69,27] width:56 height:16 range:[0,9999,0] type:#integer
		button starttime_btn "开始帧" pos:[12,48] width:51 height:28
		button endtime_btn "结束帧" pos:[73,47] width:50 height:29
		button current_btn "默认帧" pos:[134,26] width:49 height:25
		button ok_btn "开始反转" pos:[117,81] width:69 height:48
		GroupBox grp1 "反转动作关键帧" pos:[5,6] width:184 height:128
		spinner spn6 "新开始帧" pos:[28,84] width:85 height:16 range:[0,9999,0] type:#integer
		button btn25 "新开始帧" pos:[36,105] width:74 height:22
		
		 
		
	
		
		on ot01 open do
		(
		 sdlx=1;
		)
		on starttime_btn pressed do
		  spn1.value=currentTime
			
		on endtime_btn pressed do
		(
		if currentTime>spn1.value then spn2.value=currentTime
		 )
		 
		on current_btn pressed do
		(
		spn1.value=animationrange.start;
		spn2.value=animationrange.end;
		)
		
		on ok_btn pressed do
		(	
		  --设定帧数
		  turntime=spn2.value-spn1.value
		  if turntime+spn6.value>animationrange.end then animationRange = Interval animationrange.start (turntime+spn6.value)
	
	
	
	
	bip = bipname[24].transform.controller
	startframe=spn1.value;
	endframe=spn2.value;
	newendframe=spn6.value;
	select bipname[24]
	
	
	frame=spn6.value;
	for t=startframe to endframe do
	(
	biped.deleteAllCopyCollections bip
	biped.createcopyCollection bip "zsj"
	
	slidertime =endframe-(t-startframe)
	biped.copyPosture bip #pose  true true true
	
	
	slidertime=frame;
	frame +=1;
	
	
	posename=biped.getCopyName bip #pose 1
	animButtonState=true
	biped.pastePosture bip #pose false posename
	
	animButtonState=false
		
	)
		
		)
		on btn25 pressed do
			spn6.value=currentTime
	)
	
	
			global sdlx=0;
		
			rollout xhb "修滑步用工具" width:200 height:145
			(
				spinner spn1 "" pos:[4,30] width:58 height:16 range:[0,9999,0] type:#integer
				spinner spn2 "" pos:[65,30] width:56 height:16 range:[0,9999,0] type:#integer
				button starttime_btn "开始帧" pos:[6,51] width:51 height:28
				button endtime_btn "结束帧" pos:[66,50] width:50 height:29
				button current_btn "默认帧" pos:[132,20] width:49 height:25
				button ok_btn "开始锁定" pos:[90,85] width:92 height:42
				GroupBox grp1 "锁定" pos:[2,8] width:184 height:128
				radiobuttons rdo1 "" pos:[5,84] width:93 height:48 enabled:true labels:#("当前选择的", "双手", "双脚") default:1 columns:1
					
			   fn BipedPivot PivotNumber =
			(
				if havebip==1 then
				(
				foot=$ ;clearselection();
				max motion mode;select foot;TheKeyIndex = getKeyIndex ($.controller) currentTime;max create mode;
				if TheKeyIndex != 0 then
				(
					TheKey = biped.getKey foot.controller TheKeyIndex;
					TheKey.ikPivotIndex = PivotNumber
				)
				)
			)	
			
			
				on xhb open do
				(
				 sdlx=1;
				)
				
				on starttime_btn pressed do
					spn1.value=currentTime
					
				on endtime_btn pressed do
				(
				if currentTime>spn1.value then spn2.value=currentTime 	
				 )
				 
				on current_btn pressed do
				(
				spn1.value=animationrange.start;
				spn2.value=animationrange.end;
				)
				
				on ok_btn pressed do
				undo on
				(
				
				if sdlx==1  then 
				--if  $==bipname[15] or $==bipname[16]  then 
				(	
				   try (slidertime=(spn1.value-2))catch()
				   try(biped.setSlidingKey $;)catch()	  
				   
					try ( deleteTime $.transform.controller (spn1.value-2) spn1.value #noslide)catch() 
					
					slidertime=spn1.value;
				   try(biped.setSlidingKey $)catch()
				   for i=(spn1.value+1) to spn2.value do
				   (
				   if keyboard.controlpressed==true then 
				   (
				   Messagebox("中断")
				  -- goto MMMXXX:
				   )
					slidertime=i;
					
					BipedPivot 8;--这个设置锁定位置可以自己改
					try(biped.setPlantedKey $)catch()
					)
				 
	
				  try ( deleteTime $.transform.controller spn2.value (spn2.value+2) #noslide)catch()
	
				  try (slidertime=(spn2.value+2))catch()
				   try(biped.setSlidingKey $;)catch()	 
				  
				)
	-- MMMXXX:
					
				)
				
				on rdo1 changed sel do
				(
				sdlx=sel;
				)
			)
	
	
	
	
	
	global expfile;	
	 fn appendtext string = (  
				 format "%" string to:expfile
				)	
	
	rollout rendlg "Untitled" width:482 height:40
	(
		edittext renfile "" pos:[5,3] width:412 height:22
		button btn_okren "确定" pos:[424,2] width:58 height:24
		
		on rendlg open do
		try(
		renfile.text=bipfileitems[pathdlg.bipfilelist.selection]
		)catch()
		
		on btn_okren pressed do
		try(
		 
		 -- bipfileitems[pathdlg.bipfilelist.selection]=renfile.text
		-- newtext=renfile.text
		  renameFile  (filepath+"\\"+bipfileitems[pathdlg.bipfilelist.selection])  (filepath+"\\"+rendlg.renfile.text)
		  rendlg.renfile.text
		  bipfilename=renfile.text
		  pathdlg.openpathdlg()
		  
		  destroydialog rendlg
		)catch()
	
	)
	
	rollout pathdata "BIP路径选择" width:354 height:300
	(
		listbox pathlist pos:[7,3] width:340 height:20 selection:1
		button btn2 "修改路径文件" pos:[7,285] width:334 height:22
		
		on pathdata open do
		(
		 loadPathData();
		 pathlist.items=pathItems;
		)
		
		on pathlist doubleClicked sel do
		(
		 filepath=pathItems[sel]
		 pathdlg.pathtext.text=filepath
		 pathdlg.openpathdlg()
		)
			
		on pathdata close do
		(
		 spflag=0;
		)
		
		on btn2 pressed do
		(
		 ShellLaunch "$UI_ln\\bipPath.ini" ""
		)
		
	)
	
				
	rollout bipexp "BIP导出工具" width:220 height:380
	(
		button btn21 "..." pos:[193,124] width:20 height:20
		button btn22 "..." pos:[193,152] width:20 height:20	
		button btn23 "..." pos:[193,178] width:20 height:20
		button btn24 "..." pos:[193,203] width:20 height:20	
		button btn3 "导出到" pos:[3,239] width:48 height:28
		button btn4 "导出当前文件" pos:[5,345] width:100 height:30
		button btn5 "导出整个目录" pos:[111,345] width:100 height:30
		edittext label3 "" pos:[51,243] width:163 height:20
		edittext edt21 "" pos:[2,123] width:190 height:20
		edittext edt22 "" pos:[2,151] width:190 height:20
		edittext edt23 "" pos:[2,177] width:190 height:20
		edittext edt24 "" pos:[2,202] width:190 height:20
		checkbox chk1 "执行脚本序列" pos:[6,99] width:169 height:14 checked:true
		GroupBox grp12 "" pos:[4,113] width:213 height:117
		label lbl22 "当前路径:" pos:[3,7] width:208 height:14
		label lbl24 "" pos:[5,27] width:203 height:30 enabled:true
		label lbl25 "当前文件名:" pos:[4,66] width:208 height:15
		label lbl26 "" pos:[82,66] width:129 height:16
		label lbl59 "注意:导出前请激活POSE及重心三方向" pos:[7,277] width:202 height:16
		button btn30 "修改并存储整个目录BIP" pos:[7,305] width:203 height:30
	
		
		
		
		on bipexp open do
		try
		(
		lbl24.caption=filepath
		lbl26.caption=bipfilename
		edt21.text=scriptfile1
		edt22.text=scriptfile2
		edt23.text=scriptfile3
		edt24.text=scriptfile4
		label3.text=exppath
		)
		catch()
		
		on btn21 pressed do
		(
			pathfilename=mspath+msfilename;
			s1 = getOpenFileName caption:"打开ms文件" filename:pathfilename types:"ms file(*.ms)|All files(*.*)|*.*"
			
			if s1!=undefind then (scriptfile1=s1;edt21.text = scriptfile1)
		)
		on btn21 rightClick do
			(scriptfile1 = "";edt21.text="";)
		on btn22 pressed do
		(
			pathfilename=mspath+msfilename;
			s2 = getOpenFileName caption:"打开ms文件" filename:pathfilename types:"ms file(*.ms)|All files(*.*)|*.*"
			if s2!=undefind then (scriptfile2=s2;edt22.text = scriptfile2)
		)
		on btn22 rightClick do
			(scriptfile2 = "";edt22.text="";)
		on btn23 pressed do
		(
			pathfilename=mspath+msfilename;
			s3 = getOpenFileName caption:"打开ms文件" filename:pathfilename types:"ms file(*.ms)|All files(*.*)|*.*"
			if s3!=undefind then (scriptfile3=s3;edt23.text = scriptfile3)
	edt23.text = scriptfile3 
		)
		on btn23 rightClick do
			(scriptfile3 = "";edt23.text="";)
		on btn24 pressed do
		(
			pathfilename=mspath+msfilename;
			s4 = getOpenFileName caption:"打开ms文件" filename:pathfilename types:"ms file(*.ms)|All files(*.*)|*.*"
			if s4!=undefind then (scriptfile4=s4;edt24.text = scriptfile4)
		)
		on btn24 rightClick do
			(scriptfile4 = "";edt24.text="";)
		on btn3 pressed do
		(	
				 local exppath;
				 exppath = getSavePath caption:"选择保存文件路径:"  initialDir:"C:\\"
				 if exppath != undefined then 
				try(
					 
					label3.text = exppath;
					savefilepath=exppath;
					savedate()
				)catch()
				
				
		)
		
		on btn4 pressed do  --单个文件导出
		(
			 loadfilepath=filepath
			 savefilepath=getdir #maxroot+"\\exptemp";
			 try(makedir savefilepath)catch()
			 
			 if chk1.checked==true then
			 (
			 --for f in getFiles (savefilepath+"\\*.*") do deleteFile f
	
		
		
			bip=bipname[24].controller
			theFiles = getFiles (loadfilepath+"\\"+bipfilename) 
			for f in theFiles do
				(
					bip=bipname[24].controller
					zz=#()
					zz=filterString f  "\\"
					filename=replace zz[zz.count] (zz[zz.count].count-3) 4 "" 			
					animationRange = Interval 0 1
					 bip.figureMode= false
					 biped.loadBipfile bip f	
					
	 
					---------------------------------------------------------------------中间是批处理脚本载入的地方--------
					try ( fileIn scriptfile1 ) catch ()
					try ( fileIn scriptfile2 ) catch ()
					try ( fileIn scriptfile3 ) catch ()
					try ( fileIn scriptfile4 ) catch ()
					try ( fileIn scriptfile5 ) catch ()
					-------------------------------------------------------------------------------------------------------
		
				
					 bipfile=savefilepath+"\\"+filename+".bip"
					 biped.saveBipfile bip bipfile
				  )
				--closerolloutfloater wando_bacthtool
	
		
		
		--将处理好的BIP导出去
			loadfilepath=savefilepath   --刚刚经过处理的BIP将作为导出读取的路径
			)
			
			exppath=label3.text	
			dirtemp=filterString exppath "\\"
			pathtemp=dirtemp[1]
			for i=1 to dirtemp.count-1 do 
			(
			pathtemp += "\\" + dirtemp[i+1]
			try( makedir pathtemp) catch()		
			)
			
			  try(	
			 $'Bip01 LThighTwist'.parent =$'Bip01 Pelvis'
			 $'Bip01 RThighTwist'.parent =$'Bip01 Pelvis'		
	)catch() 
			bip=bipname[24].controller
	
			theFiles = getFiles (loadfilepath+"\\"+bipfilename) 
			
			for f in theFiles do
			(   
				zz=#()
				zz=filterString f  "\\"
				filename=replace zz[zz.count] (zz[zz.count].count-3) 4 "" 
				animationRange = Interval 0 1
				bip.figureMode= false
				biped.loadBipfile bip f
	 
				
				exfile=exppath+"\\"+filename+".1_many"
				exportFile exfile true true true true #noPrompt
			)
			ShellLaunch exppath "导出"
			destroydialog bipexp
		
		)
		
		
		on btn5 pressed do  --整个目录里的文件导出
		(
			 loadfilepath=filepath
			 
			 
			 savefilepath=getdir #maxroot+"\\exptemp";
			 
			 try(makedir savefilepath)catch()
			 
			if chk1.checked==true then
			 (
			 for f in getFiles (savefilepath+"\\*.*") do deleteFile f
			 
			txtfile=savefilepath+"\\expert.txt"
			 expfile=createFile txtfile
			 appendtext "\nBIP文件读取路径： ";	 appendtext loadfilepath
			 appendtext "\n\n---------------------------------------------------\n\n"
			 appendtext "BIP文件初始帧数:\n\n" ;
		
		
			bip=bipname[24].controller
			theFiles = getFiles (loadfilepath+"\\*.bip") 
			for f in theFiles do
				(
					bip=bipname[24].controller
					zz=#()
					zz=filterString f  "\\"
					filename=replace zz[zz.count] (zz[zz.count].count-3) 4 "" 			
					animationRange = Interval 0 1
					 bip.figureMode= false
					 biped.loadBipfile bip f	
					
				appendtext (filename+".bip") ;
				space="";for i=1 to 20-filename.count do space=space+" ";appendtext (space+"time:0 至 ")	
				  appendtext (integer(animationrange.end));
				appendtext "帧\n\n"
				
				
					---------------------------------------------------------------------中间是批处理脚本载入的地方--------
					try ( fileIn scriptfile1 ) catch ()
					try ( fileIn scriptfile2 ) catch ()
					try ( fileIn scriptfile3 ) catch ()
					try ( fileIn scriptfile4 ) catch ()
					try ( fileIn scriptfile5 ) catch ()
					-------------------------------------------------------------------------------------------------------
		
				
					 bipfile=savefilepath+"\\"+filename+".bip"
					 biped.saveBipfile bip bipfile
				  )
				--closerolloutfloater wando_bacthtool
			close expfile
	
		
		--将处理好的BIP导出去
			loadfilepath=savefilepath   --刚刚经过处理的BIP将作为导出读取的路径
			)
			 
			 
			 $'Bip01 LThighTwist'.parent =$'Bip01 Pelvis'
			 $'Bip01 RThighTwist'.parent =$'Bip01 Pelvis'		 
			 
			bip=bipname[24].controller
			exppath=label3.text
			dirtemp=filterString exppath "\\"
			pathtemp=dirtemp[1]
			for i=1 to dirtemp.count-1 do 
			(
			pathtemp += "\\" + dirtemp[i+1]
			try( makedir pathtemp) catch()		
			)
	
			theFiles = getFiles (loadfilepath+"\\*.bip") 
			
			for f in theFiles do
			(   
				zz=#()
				zz=filterString f  "\\"
				filename=replace zz[zz.count] (zz[zz.count].count-3) 4 "" 
				animationRange = Interval 0 1
				bip.figureMode= false
				biped.loadBipfile bip f
				
				--appendtext (filename+".bip") ;
				--space="";for i=1 to 20-filename.count do space=space+" ";appendtext (space+"time: 0 至 ")	
				  --appendtext animationrange.end;appendtext "\n\n"
				--flush expfile
				
				exfile=exppath+"\\"+filename+".1_many"
				exportFile exfile true true true true #noPrompt
			)
		 ShellLaunch exppath "导出"
		 destroydialog bipexp
		 close expfile
		 
		)
		
		
		on btn30 pressed do   
		(
			 loadfilepath=filepath;
			  savefilepath=filepath;
			 bip=bipname[24].controller
			 
			if chk1.checked==true then
			 (
	--		 for f in getFiles (savefilepath+"\\*.*") do deleteFile f	
		 
			  txtfile=savefilepath+"\\expert.txt"
			   expfile=createFile txtfile
			  appendtext "\nBIP文件读取路径： "; appendtext loadfilepath
			  appendtext "\n\n---------------------------------------------------\n\n"
			  appendtext "BIP文件初始帧数:\n\n";
		
			  
			 theFiles = getFiles (loadfilepath+"\\*.bip") 
			 for f in theFiles do
				(
					bip=bipname[24].controller
					zz=#()
					zz=filterString f  "\\"
					filename=replace zz[zz.count] (zz[zz.count].count-3) 4 "" 			
					animationRange = Interval 0 1
					 bip.figureMode= false
					 biped.loadBipfile bip f	
				appendtext (filename+".bip") ;
				space="";for i=1 to 20-filename.count do space=space+" ";appendtext (space+"time:0 至 ")	
				  appendtext (integer(animationrange.end));
				appendtext "帧\n\n"
				
				
					---------------------------------------------------------------------中间是批处理脚本载入的地方--------
					try ( fileIn scriptfile1 ) catch ()
					try ( fileIn scriptfile2 ) catch ()
					try ( fileIn scriptfile3 ) catch ()
					try ( fileIn scriptfile4 ) catch ()
					try ( fileIn scriptfile5 ) catch ()
					-------------------------------------------------------------------------------------------------------
		
				
					 bipfile=loadfilepath+"\\"+filename+".bip"
					 biped.saveBipfile bip bipfile
				  )
				 
			close expfile
			
	
		)
		
		)
		
		
		on chk1 changed state do
		(
			if state==true then
			(
			edt21.enabled=true
			edt22.enabled=true
			edt23.enabled=true
			edt24.enabled=true
			)
			
			else
			(
			edt21.enabled=false
			edt22.enabled=false
			edt23.enabled=false
			edt24.enabled=false
	
			)
		)
	)
	
	
	
	
	
	
	rollout pathdlg "BIP工具" width:223 height:460
	(
		edittext pathtext "" pos:[20,3] width:160 height:21
		listbox bipfilelist "" pos:[4,33] width:213 height:28
		button btn_save "保存" pos:[5,468] width:38 height:22   --images:#("$UI_ln\\Icons\\cstoolIcons\\bip2_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip2_a.bmp", 10, 3, 3, 4, 4)
		button btn_copy "拷贝" pos:[45,468] width:38 height:22 --images:#("$UI_ln\\Icons\\cstoolIcons\\bip_copypaste_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip_copypaste_a.bmp", 22, 1, 1, 2, 2)
		button btn_ren "改名" pos:[84,468] width:38 height:22
		button btn_del "删除" pos:[123,468] width:30 height:22 images:#("$UI_ln\\Icons\\cstoolIcons\\del.bmp", "$UI_ln\\Icons\\cstoolIcons\\whitecolor.bmp", 1, 1, 1, 1, 1)
		button btn_look "查帧" pos:[183,432] width:35 height:22 --images:#("$UI_ln\\Icons\\cstoolIcons\\bip_copypaste_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip_copypaste_a.bmp", 22, 21, 21, 22,22)
		checkbutton btn_shuang "双" pos:[197,468] width:22 height:22 toolTip:"必须要有两套以上骨架且重心名为男和女时才能激活"
		button btn_R "刷新" pos:[184,3] width:38 height:22
		button btn_dir "..." pos:[2,3] width:20 height:22
		label lbl1 ":: " pos:[3,410] width:60 height:17
		label lbl_bip "Label" pos:[8,410] width:206 height:17
		button btn_ConvertBVH "转BVH" pos:[156,468] width:40 height:22
		button btn_sp " " pos:[2,25] width:220 height:8 enabled:true images:#("$UI_ln\\Icons\\cstoolIcons\\redline.bmp", "$UI_ln\\Icons\\cstoolIcons\\whitecolor.bmp", 1, 1, 1, 1, 1)
		GroupBox grp1 "" pos:[2,422] width:219 height:36
		GroupBox grp2 "" pos:[2,458] width:219 height:36
		button btn37 "BIP导出" pos:[4,432] width:175 height:22
		
		fn openpathdlg=
		(
		if filepath!=undefined then 
			(
			pathtext.text=filepath
			theFiles = getFiles (filepath+"\\*.bip") 
			bipfileitems=#()
			for f in theFiles do
				(
					zz=#()
					zz=filterString f  "\\"
					filename=replace zz[zz.count] (zz[zz.count].count-3) 4 ""
					   append bipfileitems (filename+".bip")
					) 		
		   
		   
			
			for  i=1 to bipfileitems.count  do
				 for j=1 to bipfileitems.count do
				 (
				   if bipfileitems[i]< bipfileitems[j] then ( temp= bipfileitems[i]; bipfileitems[i]=bipfileitems[j];bipfileitems[j]=temp;)
				 ) 
			
			
			bipfilelist.items=bipfileitems
			bipfilelist.selection=1;
					for i =1 to bipfileitems.count do 
			 if bipfileitems[i]==bipfilename then  pathdlg.bipfilelist.selection=i
			 
		if  bipfilename!="*.bip" then lbl_bip.caption=bipfilename; else lbl_bip.caption="无在编辑中的BIP文件"
		)
		)
		
		
		 on btn37 pressed do
		 (
		  if bipexp!=undefind then destroydialog bipexp
		  wz=getdialogpos  pathdlg
		   createdialog bipexp  220 380 wz.x (wz.y+60)
		 )
		 
		 
		 on pathdlg close do
		 (
		 pathdlgflag=0;
		 )
		 
		 
		 on btn_convertBvh pressed do
		 (
	if $sangum070816_Bip01!=undefind then
	(
			select  $sangum070816*
			 actionMan.executeAction 0 "40020"  -- Edit: Delete Objects
	)
	
	 if $sangum070816_Bip01==undefind then
		  (
			mergeMAXFile "$UI_ln\\ICONS\\cstoolIcons\\newbip.max"  
			loadfilepath=pathtext.text
		 rollout  explain "Untitled" width:350 height:27
		  (
		  label lbl1 "正在转换BVH.请稍候...." pos:[13,4] width:320 height:21
		  )		
		   bipx=$sangum070816_Bip01.controller
		   bipx.figureMode= false
		   theFiles = getFiles (loadfilepath+"\\*.bvh") 
			createdialog explain 350 27
			fnum=0;
			
		   for f in theFiles do
		   (
			
			zz=#()
			zz=filterString f  "\\"
			filename=replace zz[zz.count] (zz[zz.count].count-3) 4 "" 
			--print ("filename="+filename)
			fnum=fnum+1;
			explain.lbl1.caption="正在转换第"+fnum as string +"个文件:  "+filename+".bvh"+"     共"+theFiles.count as string+"个文件  [按CTRL暂停]"
			  
			  
			 -- if  keyboard.controlpressed == true then goto 
			  savefile= loadfilepath+"\\"+filename+".bip"
			  m=getFileSize savefile
			  qstr=filename+".bip"+"已存在,是否替换?"
	
	
	
			 if m==0 then
			  (
			   biped.loadMocapFile bipx f #noRedraw
				biped.saveBipfile bipx savefile	
				)	
			   else
			  if querybox qstr title:"覆盖文件选项" then
			  (
			   biped.loadMocapFile bipx f #noRedraw
				biped.saveBipfile bipx savefile	
				)		
			)
			 
			   
			select  $sangum070816*
			 actionMan.executeAction 0 "40020"  -- Edit: Delete Objects
			-- biped.loadBipfile bip  (getdir #maxroot+"temp.bip")
			 destroydialog explain  
			
		)	 
			 
			pospathdlg=getdialogpos pathdlg
		   
		   destroydialog  pathdlg
		   
		  createdialog pathdlg 223 500 pospathdlg.x pospathdlg.y
	
		 )
		 
		on btn_sp pressed do
		(
		--loadPathData();
		 spflag=1-spflag;
		 if spflag==1 then
		 (
		if pathdata!=undefind then destroydialog pathdata
	
		pdpos=getdialogpos pathdlg
		if pdpos.x>200 then 
		createdialog pathdata  354 310 (pdpos.x-354)  pdpos.y
		else
		createdialog pathdata  354 310 (pdpos.x+223)  pdpos.y
		 )
		 else
		 (
		 if pathdata!=undefind then destroydialog pathdata
		  )
		
		)
	 
		on btn_shuang  changed va  do
	   (
		--判断有没有"男"
		sflag=0;
		for bnx in allbipsName do if (bnx=="男" or bnx=="女") then sflag=sflag+1;
	   if sflag!=2 then
		  btn_shuang.checked=false 
	   )
	 
		
		on btn_dir pressed do
		(
		 local tpath
		   tpath = getSavePath caption:"选择读取文件路径:"  initialDir:pathtext.text
		   if tpath != undefined then 
					try(pathtext.text =tpath; filepath=tpath ) catch()
		)
	 
		 on btn_dir rightclick do
		(
		 ShellLaunch pathtext.text ""
		)
		on pathdlg open do
		(
			 openpathdlg()
		)
		
	 
		on bipfilelist doubleClicked sel do
		(
		 global  readlovers=false
		 if btn_shuang.checked==true then
		 (
		 --找到另一个BIP但是并不选择它
		 --如果双击的是11或12打头的文件.则判断有无与之相对应的文件.若有则
		 --用男的打开11.女的打开12
	
	fn readloversdance  bs1 bs2 =
	(
	 tempsel=pathdlg.bipfilelist.selection
	  bn  = bipfileitems[pathdlg.bipfilelist.selection]
	  
	
	--找到相对应的编号
	bhqz=substring bn 1 bs1.count
	bhhw=substring bn (bs1.count+1) (6-bs1.count)
	ppbh=""
	if bhqz==bs1 then ppbh=bs2+bhhw
	else
	if bhqz==bs2 then ppbh=bs1+bhhw
	
	print ppbh
	
	--判断此编号是否存在
	bhindex=0
	if ppbh!="" then 
	for bipbh=1 to  bipfileitems.count do
	  (
	   newbhqz=substring bipfileitems[bipbh] 1 6
	   if newbhqz==ppbh then bhindex=bipbh
	   )
	   
	
	print bhindex
	   
	--如果存在则读取情侣舞
	if bhindex!=0 and (bhqz==bs1 or bhqz==bs2) then
	(
	readLovers=true
	
	
	 
	 if  bhqz==bs2 and cstoolroll.bip_list.selected=="男" then 
	 (
	 w=tempsel;tempsel=bhindex;bhindex=w;
	 )
	 
	 if bhqz==bs1 and cstoolroll.bip_list.selected=="女" then 
	 (
	 w=tempsel;tempsel=bhindex;bhindex=w;
	 )
	 
	 
	 
		bipfile=filepath+"\\"+bipfileitems[tempsel]
		if bipfile!=undefined then 
		try(	
		 t1=animationRange.start;	 t2=animationRange.end; 
		 animationRange = Interval 0 1
		 bip=bipname[24].controller
		 undo on( try( biped.deleteLayer bip  1)catch());    
	
		 bip.figureMode= false
		 if biped.numLayers bip >= 1 then   biped.deleteLayer bip  1 
		  bip.mixerMode = false;
		  
		 biped.loadBipfile bip bipfile
		 lastfilepath=filepath;
		 zz=#()
		 filepath=""
		 zz=filterString bipfile "\\"
		 vv=zz.count 
		 bipfilename=zz[vv]
		 showfile=replace bipfilename (bipfilename.count-3) 4 ""
		
		 for i=1 to zz.count-1 do
		 if i!=zz.count-1 then filepath =filepath+zz[i]+"\\" else filepath=filepath+zz[i]
		 if lastfilepath!=filepath then 
		  savedate();	
		 opf=1;
		 pathdlg.pathtext.text=filepath
		  --pathdlg.lbl2.text=bipfilename
		 cstoolroll.title=showfile;
		) catch()
		
		slidertime=0f
		st1=animationRange.start;
		 st2=animationRange.end; 
		  if ( st1==0 and st2==1) then animationRange = Interval t1 t2 
		  --lbl_bip.caption=bipfilename;
	if cstoolroll.bip_list.selected=="男" then
	   (
	   bip2=$女.controller
	   bipfile2=filepath+"\\"+bipfileitems[bhindex]
	
	   biped.loadBipfile bip2 bipfile2;
	   )
	   
	if cstoolroll.bip_list.selected=="女" then
	   (
	   bip2=$男.controller
	   bipfile2=filepath+"\\"+bipfileitems[bhindex]
	   biped.loadBipfile bip2   bipfile2
	   )
	   
	 
	)	 
	)
	 
	
	
	
	if readLovers==false then
	(
	bn=bipfileitems[pathdlg.bipfilelist.selection]
	
	
	girlrezult=findstring bn "girl"
	if girlrezult ==undefind then girlfind=false else girlfind=true
	
	boyrezult=findstring bn "boy"
	if boyrezult==undefind then boyfind=false else boyfind=true
	
	
	--如果带BOY或GIRL字符则判断配对是否存在.
	if girlfind==true then findppString=replace bn girlrezult 4 "boy" 
	else
	if boyfind==true then findppString=replace bn boyrezult 3 "girl" 
	
	if girlfind==true or boyfind==true then 
	bhindex=0
	for bipbh=1 to  bipfileitems.count do
	  (
	   if bipfileitems[bipbh]==findppString then   bhindex=bipbh
	 )
		
	 )
	--replace s 5 3 "inserted string" 
	--如果存在则读取情侣舞
	if bhindex!=0 and (girlfind==true or boyfind==true)  then
	 
	(
	readLovers=true
	
	sel=pathdlg.bipfilelist.selection
	 if girlfind==true and cstoolroll.bip_list.selected=="男" then 
	 (
	 w=sel;sel=bhindex;bhindex=w;
	 )
	 
	 if boyfind==true and cstoolroll.bip_list.selected=="女" then 
	 (
	 w=sel;sel=bhindex;bhindex=w;
	 )
	 
	 readLovers=true;
		  
		bipfile=filepath+"\\"+bipfileitems[sel]
		if bipfile!=undefined then 
		try(	
		 t1=animationRange.start;	 t2=animationRange.end; 
		 animationRange = Interval 0 1
		 bip=bipname[24].controller
		 undo on( try( biped.deleteLayer bip  1)catch());    
	
		 bip.figureMode= false
		 if biped.numLayers bip >= 1 then   biped.deleteLayer bip  1 
		  bip.mixerMode = false;
		  
		 biped.loadBipfile bip bipfile
		 lastfilepath=filepath;
		 zz=#()
		 filepath=""
		 zz=filterString bipfile "\\"
		 vv=zz.count 
		 bipfilename=zz[vv]
		 showfile=replace bipfilename (bipfilename.count-3) 4 ""
		
		 for i=1 to zz.count-1 do
		 if i!=zz.count-1 then filepath =filepath+zz[i]+"\\" else filepath=filepath+zz[i]
		 if lastfilepath!=filepath then 
		  savedate();	
		 opf=1;
		 pathdlg.pathtext.text=filepath
		  --pathdlg.lbl2.text=bipfilename
		 cstoolroll.title=showfile;
		) catch()
		
		slidertime=0f
		st1=animationRange.start;
		 st2=animationRange.end; 
		  if ( st1==0 and st2==1) then animationRange = Interval t1 t2 
		  --lbl_bip.caption=bipfilename;
	if cstoolroll.bip_list.selected=="男" then
	   (
	   bip2=$女.controller
	   bipfile2=filepath+"\\"+bipfileitems[bhindex]
	
	   biped.loadBipfile bip2 bipfile2;
	   )
	if cstoolroll.bip_list.selected=="女" then
	   (
	   bip2=$男.controller
	   bipfile2=filepath+"\\"+bipfileitems[bhindex]
	   biped.loadBipfile bip2   bipfile2
	   )
	   
	 )
	 
	 if readLovers==false then  readloversdance  "135" "136"
	 
	 if readLovers==false then readloversdance  "11" "12"
	
		 )
	 
	
	 else
	 if btn_shuang.checked==false then 
		(
		bipfile=filepath+"\\"+bipfileitems[sel]
		if bipfile!=undefined then 
		try(	
		 t1=animationRange.start;	 t2=animationRange.end; 
		 animationRange = Interval 0 1
		 bip=bipname[24].controller
		 undo on( try( biped.deleteLayer bip  1)catch());    
	
		 bip.figureMode= false
		 if biped.numLayers bip >= 1 then   biped.deleteLayer bip  1 
		  bip.mixerMode = false;
		  
		 biped.loadBipfile bip bipfile
		 lastfilepath=filepath;
		 zz=#()
		 filepath=""
		 zz=filterString bipfile "\\"
		 vv=zz.count 
		 bipfilename=zz[vv]
		 showfile=replace bipfilename (bipfilename.count-3) 4 ""
		
		 for i=1 to zz.count-1 do
		 if i!=zz.count-1 then filepath =filepath+zz[i]+"\\" else filepath=filepath+zz[i]
		 if lastfilepath!=filepath then 
		  savedate();	
		 opf=1;
		 pathdlg.pathtext.text=filepath
		  --pathdlg.lbl2.text=bipfilename
		 cstoolroll.title=showfile;
		) catch()
		
		slidertime=0f
		st1=animationRange.start;
		 st2=animationRange.end; 
		  if ( st1==0 and st2==1) then animationRange = Interval t1 t2 
		  lbl_bip.caption=bipfilename;
		   btn_save.enabled=true;
	
	   )
		
	 )
		
		on btn_del pressed do
		(
	try(makedir delpath)catch();
	
	try
	(
	--所有已删除的文件前缀名均加1.一但超过10则删除
	theFiles = getFiles (delpath+"*.bip")
	 
	for f in theFiles do
	(
	zz=filterString f  "\\"
	delfilename=replace zz[zz.count] (zz[zz.count].count-3) 4 "" 
		
	head=substring delfilename 1 2
	filebody=substring delfilename 3 delfilename.count
	
	headvalue=head as integer
	 
	 if headvalue==30 then  deleteFile f
	 else
	if headvalue<30 then 
	(
	 headvalue+=1;
	 print headvalue;
	 if headvalue<10 then 
	 headstring="0"+headvalue as string
	 else 
	 headstring=headvalue as string
	 renameFile  f (delpath+headstring+filebody+".bip")
	)
	
	)
	 
	
	--拷贝即将删除的文件
	delbipfile=filepath+"\\"+bipfileitems[pathdlg.bipfilelist.selection]
	copyFile  delbipfile  (getdir #maxroot +"\\DelBip\\"+"01_"+bipfileitems[pathdlg.bipfilelist.selection])
	
	--删除文件
	deleteFile delbipfile
	
	--更新显示
	
	 openpathdlg()
	
	)catch()  
	  
	
	)
			
			
		on btn_del rightClick do
		(
		 theFiles = getFiles (delpath+"*.bip")
	
	for f in theFiles do
	try
	(
	zz=filterString f  "\\"
	delfilename=replace zz[zz.count] (zz[zz.count].count-3) 4 "" 
		
	head=substring delfilename 1 2
	filebody=substring delfilename 3 delfilename.count
	truefilename=substring filebody 2 filebody.count
	print "turefilenmae="
	print truefilename
	headvalue=head as integer
	
	if headvalue==1 then  
	( copyFile  f  (filepath+"\\"+truefilename+".bip")
	   deleteFile f
	 )
	  else
	 if headvalue>1   then 
	(
	 headvalue-=1;
	 if headvalue<10 then 
	 headstring="0"+headvalue as string
	 else 
	 headstring=headvalue as string
	 renameFile  f (delpath+headstring+filebody+".bip")
	)
	
	)catch()
	 
	 openpathdlg()
		)
		
		on btn_ren pressed do
		(
		  createdialog rendlg 482 30
		)
		
		on btn_save pressed do
		(
		  bip=bipname[24].controller
		  biped.saveBipfile bip (filepath+"\\"+bipfilename)
		)	
	
		on btn_copy pressed do
		(
		tempx=bipfileitems[pathdlg.bipfilelist.selection]
		fnam=substring tempx  1 (tempx.count-4)
		copyFile (filepath+"\\"+bipfileitems[pathdlg.bipfilelist.selection]) (filepath+"\\"+fnam+"_copy.bip")
		bipfilename=bipfileitems[pathdlg.bipfilelist.selection]
		openpathdlg()
		)
		
		on btn_look pressed do
		(
			 loadfilepath=filepath
			txtfile=loadfilepath+"\\expert.txt"
			 expfile=createFile txtfile
			appendtext "\nBIP文件读取路径： "; appendtext loadfilepath
			appendtext "\n---------------------------------------------------\n"
			appendtext "BIP文件帧数:\n\n" ;
		
		
			bip=bipname[24].controller
			 theFiles = getFiles (loadfilepath+"\\*.bip") 
			--theFiles=#()
			--for i=1 to bipfileitems.count do append theFiles (loadfilepath+bipfileitems[i]);
			for f in theFiles do
				(
					bip=bipname[24].controller
					zz=#()
					zz=filterString f  "\\"
					filename=replace zz[zz.count] (zz[zz.count].count-3) 4 "" 			
					animationRange = Interval 0 1
					 bip.figureMode= false
					 biped.loadBipfile bip f	
					
				appendtext (filename+".bip");
				space="";for i=1 to 20-filename.count do space=space+" ";appendtext (space+"time:0 至 ")	
				  appendtext (integer(animationrange.end));
				appendtext "帧\n\n"
				flush expfile
				  --bipfile=savefilepath+"\\"+filename+".bip"
	
				  )
		
			close expfile
			ShellLaunch txtfile ""
		)
		on btn_R rightclick do
		(	
		   pathtext.text=""
		)
		on btn_R pressed do
		(
	
		   rebuildchar pathdlg.pathtext.text
		   filepath= newchar
		   isSame=0;
		   loadPathData();
		   
		   for i=1 to 20 do
		   if filepath==pathItems[i] then isSame=1;
		   
		   thisFiles = getFiles (filepath+"\\*.bip") 
			if thisFiles.count>0  then  
		   if isSame==0 then
		   (
			 for i=2 to 20 do pathItems[22-i]=pathItems[21-i]
			pathItems[1]=filepath;
			savePathData();
			if pathdata!=undefind then 
			pathdata.pathlist.items=pathItems
		   )
		   
		   openpathdlg()
	
		 --destroydialog pathdlg
		)
	)
	
	
	
	
	
	-- rollout setpara "保存设置" width:120 height:314
	-- (
	-- 	-- spinner spn1 "开始帧数" pos:[16,25] width:92 height:16 range:[-999,9999,0] type:#integer
	-- 	-- spinner spn2 "结束帧数" pos:[16,51] width:92 height:16 range:[-999,9999,0] type:#integer
	-- 	-- spinner spn3 "时间范围" pos:[16,78] width:92 height:16 range:[0,9999,0] type:#integer
	-- 	-- spinner spn4 "移动间隔" pos:[16,104] width:92 height:16 range:[0,9999,0] type:#integer
	-- 	-- spinner spn5 "增减间隔" pos:[16,131] width:92 height:16 range:[0,9999,0] type:#integer
	-- 	-- radiobuttons rdo1 "" pos:[6,185] width:102 height:32 labels:#("1/2X", "1/4X", "2X", "4X") default:1 columns:2
	-- 	-- groupBox grp1 "动画时间参数" pos:[2,2] width:113 height:155
	-- 	-- groupBox grp2 "速率切换" pos:[3,163] width:113 height:63
	-- 	groupBox grp3 "自动保存设置" pos:[4,2] width:113 height:70
		
	-- 	spinner spn11 "每间隔" pos:[16,25] width:67 height:16 range:[1,9999,1] type:#integer
	-- 	spinner spn12 "数量限制" pos:[16,50] width:96 height:16 enabled:true range:[0,500,0] type:#integer
	-- 	label lbl3 "分钟" pos:[85,25] width:29 height:19
		
	-- 	on setpara open do
	-- 	(
	-- 	   loadPathData()
	-- 	--    if bspeed==2 then rdo1.state=1
	-- 	--    if bspeed==1 then rdo1.state=2
	-- 	--    if bspeed==4 then rdo1.state=3
	-- 	--    if bspeed==5 then rdo1.state=4
	
	-- 	--   spn1.value=mystarttime
	-- 	--   spn2.value=myendtime
	-- 	--   spn3.value=myrangetime
	-- 	--   spn4.value=mymovetime
	-- 	--   spn5.value=myaddtime
	-- 	  spn11.value=autotimelimit
	-- 	  spn12.value=bipnumlimit
	-- 	  )
		  
	-- 	on setpara close do
	-- 	(
	-- 	  savedate()
	-- 	  paraflag=0
	-- 	)
		
	-- 	-- on spn1 changed val do
	-- 	-- 	(mystarttime=spn1.value;if mystarttime>=animationRange.end then (mystarttime=animationRange.end-1;spn1.value=mystarttime);animationRange = Interval mystarttime animationRange.end;)
	-- 	-- on spn2 changed val do
	-- 	-- 	(myendtime=spn2.value;if myendtime<=animationRange.start then (myendtime=animationRange.start+1;spn2.value=myendtime);animationRange = Interval animationRange.start myendtime;)
	
	-- 	-- on spn3 changed val do
	-- 	-- 	myrangetime=spn3.value
	-- 	-- on spn4 changed val do
	-- 	-- 	mymovetime=spn4.value
	-- 	-- on spn5 changed val do
	-- 	-- 	myaddtime=spn5.value
	-- 	on spn11 changed val do
	-- 		autotimelimit=spn11.value
	-- 	on spn12 changed val do
	-- 		bipnumlimit=spn12.value	
		
	-- 	-- on rdo1 changed stat do
	--     --   ( 
	
	-- 	--    stopAnimation() 	
	-- 	--    if stat==1 then bspeed=2
	-- 	--    if stat==2 then bspeed=1
	-- 	--    if stat==3 then bspeed=4
	-- 	--    if stat==4 then bspeed=5
	-- 	--    timeConfiguration.playbackSpeed=bspeed 
	-- 	--    anflag=1
	-- 	--    atime=0
	-- 	--    --slidertime=animationRange.start
	-- 	--   )
	-- )
	
	
	rollout cstoolroll "CSTools" width:120 height:515
	(
		bitmap Background    "Bitmap"    pos:[0, 24] width:117 height:240       transparent:(color 0 255 0)
		imgtag leftfootA_btn  "leftfoota" pos:[leftx,lefty] width:22  height:18      bitmap:image_leftfootA  transparent:(color 0 255 0)
		imgtag leftfootB_btn  "leftfootb" pos:[leftx,lefty+18] width:22  height:15  bitmap:image_leftfootB  transparent:(color 0 255 0)
		imgtag leftfootC_btn  "leftfootc" pos:[leftx+22,lefty] width:21  height:33  bitmap:image_leftfootC  transparent:(color 0 255 0)
		imgtag leftfootD_btn  "leftfootd" pos:[leftx+43,lefty] width:15  height:33  bitmap:image_leftfootD  transparent:(color 0 255 0)
	
		dropdownList bip_list "" pos:[0,1] width:55 height:22 items:#("Bip01")
		-- button refresh_bips "R" pos:[54,1] width:25 height:20
		-- button set_btn "设置" pos:[55,1] width:40 height:20
		button help_btn " BIP\CS工具" pos:[55,1] width:60 height:20 tooltip:"左键BIP工具,\r\n右键CS工具合集"
		button savefile_btn "save" pos:[2,331] width:22 height:20 images:#("$UI_ln\\Icons\\cstoolIcons\\bip2_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip2_a.bmp", 10, 3, 3, 4, 4)
		button openfile_btn "open" pos:[2,310] width:22 height:20 images:#("$UI_ln\\Icons\\cstoolIcons\\bip2_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip2_a.bmp", 10, 1, 1, 2, 2)
		button key_btn "key" pos:[9,266] width:22 height:20 images:#("$UI_ln\\Icons\\cstoolIcons\\bip_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip_a.bmp", 8, 1, 1, 2, 2)
		button plantedkey_btn "planted key" pos:[34,266] width:22 height:20 images:#("$UI_ln\\Icons\\cstoolIcons\\bip_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip_a.bmp", 8, 3, 3, 4, 4)
		button sliderkey_btn "slider key" pos:[59,266] width:22 height:20 images:#("$UI_ln\\Icons\\cstoolIcons\\bip_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip_a.bmp", 8, 5, 5, 6, 6)
		button freekey_btn "free  key" pos:[83,266] width:22 height:20 images:#("$UI_ln\\Icons\\cstoolIcons\\bip_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip_a.bmp", 8, 7, 7, 8, 8)
		checkbutton hori_btn "hoir" pos:[999,266] width:22 height:20 images:#("$UI_ln\\Icons\\cstoolIcons\\bip2_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip2_a.bmp", 10, 5, 5, 6, 6)
		checkbutton vert_btn "vert" pos:[999,266] width:22 height:20 images:#("$UI_ln\\Icons\\cstoolIcons\\bip2_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip2_a.bmp", 10, 7, 7, 8, 8)
		checkbutton rotate_btn "rotate" pos:[999,266] width:22 height:20 images:#("$UI_ln\\Icons\\cstoolIcons\\bip2_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip2_a.bmp", 10, 9, 9, 10, 10)
		button modebtn1 "Mixer" pos:[25,331] width:30 height:20 
		button modebtn2 "Layer" pos:[25,310] width:30 height:20
		button newlayer_btn "newlayer" pos:[999,288] width:22 height:20 images:#("$UI_ln\\Icons\\cstoolIcons\\bip_layer_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip_layer_a.bmp", 24, 5, 5, 6, 6)
		button deletelayer_btn "deletelayer" pos:[999,288] width:22 height:20 images:#("$UI_ln\\Icons\\cstoolIcons\\bip_layer_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip_layer_a.bmp", 24, 7, 7, 8, 8)
		button collapselayer_btn "collapselayer" pos:[999,288] width:22 height:20 images:#("$UI_ln\\Icons\\cstoolIcons\\bip_layer_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip_layer_a.bmp", 24, 13, 13, 14, 14)
		button layerkey_btn "layerkey" pos:[999,288] width:22 height:20 images:#("$UI_ln\\Icons\\cstoolIcons\\bip_layer_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip_layer_a.bmp", 24, 15, 15, 16, 16)
		button copy_btn "copy" pos:[3,288] width:22 height:20 images:#("$UI_ln\\Icons\\cstoolIcons\\bip_copypaste_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip_copypaste_a.bmp", 22, 3, 3, 4, 4)
		button paste_btn "paste" pos:[25,288] width:22 height:20 images:#("$UI_ln\\Icons\\cstoolIcons\\bip_copypaste_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip_copypaste_a.bmp", 22, 7, 7, 8, 8)
		button mirrorpaste_btn "MirrorPaste" pos:[48,288] width:22 height:20 images:#("$UI_ln\\Icons\\cstoolIcons\\bip_copypaste_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip_copypaste_a.bmp", 22, 9, 9, 10, 10)
		GroupBox modelabel "" pos:[73,281] width:45 height:26
		label posemode ":posture" pos:[74,290] width:50 height:14
		button MIX_btn "MIX" pos:[999,288] width:40 height:20
		checkbutton mixdoor_btn "mixmode" pos:[999,288] width:22 height:20 images:#("$UI_ln\\Icons\\bip_modes_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\bip_modes_a.bmp", 8, 7, 7, 8, 8)
		button MtoB_btn "M>B" pos:[999,288] width:33 height:20
		button MixFolder_btn "+" pos:[999,288] width:8 height:20
		
		Timer    tmr1   "Timer" pos:[-11,261] width:24 height:24 interval:100
		
		-- HyperLink lnkTips "转CGJoy,原作者未知" pos:[5,395] color:(color 255 20 100) \
		-- hovercolor:(color 255 0 255) visitedcolor:(color 255 20 100) \
		-- address:"https://www.cgjoy.com/forum.php?mod=viewthread&tid=150585"
		
		edittext startnumtext ""  pos:[-5,374] width:35 height:16
		button   time1_btn   "<<" pos:[30,374] width:20 height:18 images:#("$UI_ln\\Icons\\cstoolIcons\\VCR_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\VCR_a.bmp", 28, 3, 3, 4, 4)
		button   time2_btn   "==" pos:[50,374] width:20 height:18 images:#("$UI_ln\\Icons\\cstoolIcons\\VCR_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\VCR_a.bmp", 28, 9, 9, 10, 10)
		button   time3_btn   ">>" pos:[70,374] width:20 height:18 images:#("$UI_ln\\Icons\\cstoolIcons\\VCR_i.bmp", "$UI_ln\\Icons\\cstoolIcons\\VCR_a.bmp", 28, 11, 11, 12, 12)
		spinner  endnum      ""   pos:[88,374] width:40 height:16 type:#integer	 range:[0,9999,0]
		
		radioButtons rdo1 "" pos:[1,354] width:168 height:16 labels:#("1/4", "1/2","1X") default:3 columns:3
	
	fn copybmp bcode=
	(
	 
	 for i=0 to 15 do 
	 for j=0 to 15 do
	 (
	  aa=getpixels clk [j,i] 1
	  ix=btn[bcode].x+offset[bcode].x;iy=btn[bcode].y+offset[bcode].y
	  if aa[1].r<5 and aa[1].r<5 and aa[1].b<5 then () else  setpixels back[ix+j,iy+i] aa
	  )
	)
	
	
		
	
	fn getbipname num =
	( 
	  --max create mode
	 bipname=#("none","none","none","none","none","none","none","none","none","none","none","none","none","none",
			   "none","none","none","none","none","none","none","none","none","none")
	   if num!=0 then
	   (
	  try
	  (
	  t=biped.getNode allbips[num] 11 link:1; bipname[1]=t.name  --1
	  t=biped.getNode allbips[num] 17 link:1; bipname[2]=t.name   
	  t=biped.getNode allbips[num]  2 link:1; bipname[3]=t.name   --3
	  t=biped.getNode allbips[num]  1 link:1; bipname[4]=t.name 
	  t=biped.getNode allbips[num]  2 link:2; bipname[5]=t.name   --5 
	  t=biped.getNode allbips[num]  1 link:2; bipname[6]=t.name 
	  t=biped.getNode allbips[num]  2 link:3; bipname[7]=t.name   --7
	  t=biped.getNode allbips[num]  1 link:3; bipname[8]=t.name 
	  t=biped.getNode allbips[num]  2 link:4; bipname[9]=t.name 
	  t=biped.getNode allbips[num]  1 link:4; bipname[10]=t.name   --10
	  t=biped.getNode allbips[num]  6 link:1; bipname[11]=t.name 
	  t=biped.getNode allbips[num]  5 link:1; bipname[12]=t.name   --12
	  t=biped.getNode allbips[num]  6 link:2; bipname[13]=t.name 
	  t=biped.getNode allbips[num]  5 link:2; bipname[14]=t.name   
	  t=biped.getNode allbips[num]  6 link:3; bipname[15]=t.name   --15
	  t=biped.getNode allbips[num]  5 link:3; bipname[16]=t.name 
	  t=biped.getNode allbips[num]  8 link:1; bipname[17]=t.name 
	  t=biped.getNode allbips[num]  7 link:1; bipname[18]=t.name   --18
	  t=biped.getNode allbips[num]  9 link:1; bipname[22]=t.name   --22
	  t=biped.getNode allbips[num] 12 link:1; bipname[23]=t.name 
	  t=biped.getNode allbips[num] 13 link:1; bipname[24]=t.name   --24 
	
	   )catch() 
	  t1=undefind;try(t1=biped.getNode allbips[num]  9 link:4)catch(); if t1==undefind then  bipname[19]="none"   else  bipname[19]=t1.name
	  t2=undefind;try(t2=biped.getNode allbips[num]  9 link:3)catch(); if t2==undefind then  bipname[20]="none"   else bipname[20]=t2.name 
	  t3=undefind;try(t3=biped.getNode allbips[num]  9 link:2)catch(); if t3==undefind then  bipname[21]="none"   else bipname[21]=t3.name
	  for i=1 to bipname.count do
	  (
				if bipname[i]=="none" then bipname[i]==undefined else
						   bipname[i]= execute ("$'"+bipname[i]+"'")
				-- print  "bipname["+i as string+"]:\t"
				-- print bipname[i]
				 )
	  )
	
	
	
	  if bipname[19]=="none" and bipname[20]=="none" and bipname[21]=="none"  then 
		 (
		
		 copy  tmp1 back
		 splinenum=1;
		   btn[19]=rect 0 0 0 0	 
		   btn[20]=rect 0 0 0 0
			 btn[21]=rect 0 0 0 0
		 btn[22] = rect 39  58 40 55
		  offset[22]=point2  11  22
		 )else 
	 if bipname[19]=="none" and bipname[20]=="none"   then 
		 (
		
		 copy tmp2 back
		 splinenum=2
				btn[19]=rect 0 0 0 0	 
		   btn[20]=rect 0 0 0 0
			btn[21] = rect 40  58 39 26
		   btn[22] = rect 40  85 39 26
			offset[21]=point2   10  5
			offset[22]=point2  10  5
		 )else
		if bipname[19]=="none"  then 
		 (
		
		 copy tmp3 back 
		 splinenum=3
				btn[19]=rect 0 0 0 0	 
			btn[20] = rect 39  57 40 19
			btn[21] = rect 39  76 40 19
		   btn[22] = rect 39  95 40 19
			offset[20]=point2  11 2
			offset[21]=point2  11 1
			offset[22]=point2 11 0
		 
		 
		 )else
		 (
		
		   copy tmp4 back
		   splinenum=4
		   btn[19] = rect 35 59 41 13  
			btn[20] = rect 35  73 41 13
			btn[21] = rect 35  88 41 13
		   btn[22] = rect 35 102 41 13
		   offset[19]=point2  15  -3
			offset[20]=point2  15  -3
			offset[21]=point2  15  -4
		   offset[22]=point2  15  -4
	
		 )
		 havebip=0
		if bipname[24]=="none" or bipname[24]==undefind then  (copy tmplost back;splinenum=5) else havebip=1
		
	)
	
	
	
	fn allbipundefind x=
	(
	 bipname=#(undefind,undefind,undefind,undefind,undefind,undefind,undefind,undefind,undefind,undefind,undefind,undefind,undefind,undefind,undefind,undefind,undefind,undefind,undefind,undefind,undefind,undefind,undefind,undefind)
	
	)
	
	
	
	fn setmode tmode=
	(
	    copy_btn.pos.x=999
	    paste_btn.pos.x=999
	    mirrorpaste_btn.pos.x=999
	    modelabel.pos.x=999
	    posemode.pos.x=999
		MIX_btn.pos.x=999
		mixdoor_btn.pos.x=999
		MtoB_btn.pos.x=999
		MixFolder_btn.pos.x=999
		newlayer_btn.pos.x=999
		deletelayer_btn.pos.x=999
		collapselayer_btn.pos.x=999
		layerkey_btn.pos.x=999
	
	  if tmode==1 then
	   (
	   copy_btn.pos.x=3
	   paste_btn.pos.x=25
	   mirrorpaste_btn.pos.x=48
	   modelabel.pos.x=73
	   posemode.pos.x=74
	   )
	   
	  if tmode==2 then
	   (
	    MIX_btn.pos.x=5
		mixdoor_btn.pos.x=47
		MtoB_btn.pos.x=71
		MixFolder_btn.pos.x=105
		)
		
	  if tmode==3 then
	   (
		newlayer_btn.pos.x=9
		deletelayer_btn.pos.x=34
		collapselayer_btn.pos.x=59
		layerkey_btn.pos.x=84
	    )	
	)
		
		
	fn selectallchild index linkmode =
	  (
		 with redraw off
				(
					temparray =#()
					select (biped.getNode bipname[24] index link:linkmode)		
					for i = 1 to 25 do
					(
						for j = 1 to $selection.count do (append temparray ($selection[j]))
						max select child
					)			
					for i = 1 to temparray.count do (selectmore temparray[i])
				)
	  )
	
	
	fn readbutton x y=
	(
	  btncode=0;btndown=0;
	  for i=1 to btn.count do
	   (sx=btn[i].x;sy=btn[i].y;
		ex=btn[i].w+btn[i].x;
		ey=btn[i].h+btn[i].y;
		 if x>sx and y>sy and x<ex and y<ey then (btncode=i;btndown=1)
		 )
	)
	
	
	
		fn selectandshow w=
		(   
		try(for k=1 to sz.count do bipname[k].showTrajectory = off	)catch()
		if w==1 then 
		   (
		   clearselection();
		   
		  -- for i=1 to sz.count do
		  -- if sz[i]==0 then try(deselect bipname[i])catch()
		   )
		   if splinenum==1 then copy tmp1 back
		   else
		   if splinenum==2 then copy tmp2 back
		   else
		   if splinenum==3 then copy tmp3 back
		   esle
		   if splinenum==4 then copy tmp4 back
		clk  = image_select
		
	
		for i=1 to sz.count do
		if sz[i]==1 and bipname.count>1 then 
		   (
		   try(if showtrajflag==1 then bipname[i].showTrajectory=on)catch()
		   if havebip==1 then if bipname[i]!="none"  then copybmp i
			if w==1   then  
			try(selectmore bipname[i])catch()
			)
		 background.bitmap=back
		)
		
		
	 fn BipedPivot PivotNumber =
	  (
		if havebip==1 then
		(
		foot=$ ;clearselection();
		max motion mode;select foot;TheKeyIndex = getKeyIndex ($.controller) currentTime;max create mode;
		if TheKeyIndex != 0 then
		(
			TheKey = biped.getKey foot.controller TheKeyIndex;
			TheKey.ikPivotIndex = PivotNumber
			)
			)
		
	)	
		
	
	fn imglbuttondown bcode=
	  (
	   if  keyboard.shiftpressed == true then
		(
		if bcode==1    then   selectallchild  11 1   --1
		if bcode==2    then   selectallchild  17 1   
		if bcode==3    then   selectallchild   2 1   --3
		if bcode==4    then   selectallchild   1 1 
		if bcode==5    then   selectallchild   2 2   --5
		if bcode==6    then   selectallchild   1 2 
		if bcode==7    then   selectallchild   2 3   --7
		if bcode==8    then   selectallchild   1 3 
		if bcode==9    then   selectallchild   2 4 
		if bcode==10   then   selectallchild   1 4   --10
		if bcode==11   then   selectallchild   6 1 
		if bcode==12   then   selectallchild   5 1   --12
		if bcode==13   then   selectallchild   6 2 
		if bcode==14   then   selectallchild   5 2 
		if bcode==15   then   selectallchild   6 3   --15
		if bcode==16   then   selectallchild   5 3 
		if bcode==17   then   selectallchild   8 1 
		if bcode==18   then   selectallchild   7 1   --18
		if bcode==19   then   selectallchild   9 4 
		if bcode==20   then   selectallchild   9 3   --20
		if bcode==21   then   selectallchild   9 2 
		if bcode==22   then   selectallchild   9 1   --22
		if bcode==23   then   selectallchild  12 1 
		if bcode==24   then   selectallchild  13 1   --24
		)
	  else
	
	   if  keyboard.controlpressed == true then
	   (
		   sz[bcode]=1-sz[bcode]
		   selectandshow 1
		)
	   else
	   (
	   sz=#(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	   sz[bcode]=1
	   selectandshow 1
		)
	)	
		
	
	
		
	fn imglbuttondblclk bcode=
	   (
	
	   if keyboard.controlpressed == false then sz=#(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	   if bcode==24 then sz=#(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)
	   if bcode==3  then (sz[ 3]=1; sz[ 5]=1; sz[ 7]=1; sz[ 9]=1)
	   if bcode==5  then (sz[ 5]=1; sz[ 7]=1; sz[ 9]=1)
	   if bcode==7  then (sz[ 7]=1; sz[ 9]=1)   
	   if bcode==4  then (sz[ 4]=1; sz[ 6]=1; sz[ 8]=1; sz[10]=1)
	   if bcode==6  then (sz[ 6]=1; sz[ 8]=1; sz[10]=1)
	   if bcode==8  then (sz[ 8]=1; sz[10]=1)
	   if bcode==11 then (sz[11]=1; sz[13]=1; sz[15]=1; sz[17]=1)
	   if bcode==13 then (sz[13]=1; sz[15]=1; sz[17]=1)
	   if bcode==15 then (sz[15]=1; sz[17]=1)
	   if bcode==12 then (sz[12]=1; sz[14]=1; sz[16]=1; sz[18]=1)
	   if bcode==14 then (sz[14]=1; sz[16]=1; sz[18]=1)
	   if bcode==16 then (sz[16]=1; sz[18]=1)
	   selectandshow 1
			  if btncode==19 or btncode==20 or btncode==21 or btncode==22 then 
			   if keyboard.controlpressed == false then
			   (
				  sz=#(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
				selectandshow 1
				)
				else 
				(
				 sz[19]=1;sz[20]=1;sz[21]=1;sz[22]=1
				 selectandshow 1
				 )  
	   )
		
	fn readpose p=
	(	 
	 
		 try(
		  bip=bipname[24].controller
		  cos=biped.numCopyCollections bip
		  if cos==0 then  biped.createcopyCollection bip "zsj"
		  pdcw=0;   for i=1 to 21 do if sz[i]==1 then pdcw=1;
		  if pdcw==0 then select bipname[21];
		  biped.deleteAllCopies  bip  #pose
		  biped.deleteAllCopies bip #posture
		  biped.copyPosture bip #posture on on on
		  posturenum=biped.numCopies bip #posture 
		  if posturenum==1  then posemode.caption=":Posture" else posemode.caption=":Pose"	
		 )catch( )
	)
	
	
	
		
	fn imgrightclick bcode=
	  (
	   numflag=integer(mod bcode 2)
	   if bcode==24 then 
	   (
		   sz=#(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)
	   )
	   else
	   if bcode>=19 and bcode<=22 then
		  (
		   sz=#(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0)
	
	   )
	   else
	   if bcode>=3 and bcode<=18 then
	   if  keyboard.controlpressed == true then
		( 
	 
			   if numflag==1 then 
			 (
			 if sz[bcode]==1 and sz[bcode+1]==1 then 
				   (
					sz[bcode]=0;sz[bcode+1]=0
					)
					else
					(
					 sz[bcode+1]=1;sz[bcode]=1
					)
			  )
			 else
			 (
			 if sz[bcode]==1 and sz[bcode-1]==1 then 
				   (
					sz[bcode]=0;sz[bcode-1]=0
					)
					else
					(
					 sz[bcode-1]=1;sz[bcode]=1
					)
			  )	 
	  )
	  else
		(
		sz=#(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
		sz[bcode]=1;
		if numflag==1 then sz[bcode+1]=1
			 else		   sz[bcode-1]=1
		)
	   selectandshow 1
	   )	
		
		on cstoolroll open do
		(
		timeConfiguration.playbackSpeed=3
		 temptime = localTime as string
		  temps=filterString temptime ":"
		  lastsecond=temps[2] as integer
	
		  loaddate()
		  last_dialog_x=dialog_x
		  last_dialog_y=dialog_y
		  tempst=animationRange.start as integer
		--   startnumtext.text= tempst as string
		--    endnum.value=animationRange.end  
		   
		  if splinenum==1 then copy tmp1 back
		   else
		   if splinenum==2 then copy tmp2 back
		   else
		   if splinenum==3 then copy tmp3 back
		   else
		   if splinenum==4 then copy tmp4 back
	
		   getbipname bip_list.selection
	
		  if havebip==1 then readpose 0
		  sz=#(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1)
		  selectandshow 1
		  
		  
		  rootname="none"
	
	
		  xz=#()
		  for i in (selection as array) where (selection.count != 0) do
			(
				if classof i==Biped_Object then  (rootname=(getBipRootNode i ).name;append xz i;)
			)
			 allbipsName =#()
			   allbips = getallbips()
			   for i = 1 to allbips.count do (append allbipsName allbips[i].name)
			bip_list.items=allbipsName
			
			
	
			   if bip_list.items.count>0 then
			   if bip_list.selection<=0 or bip_list.selection>bip_list.items.count  then bip_list.selection=1
			   
			if rootname!="none"  then
			for i= 1 to bip_list.items.count do if rootname==bip_list.items[i] then bip_list.selection=i
			
				
				getbipname bip_list.selection
				
			if rootname!="none" then 
			(
			select xz
			 sz=#(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
			print "&************************"
			for i=1 to xz.count do for j=1 to bipname.count do if  xz[i]==bipname[j] then sz[j]=1 
			)
			else	
			(
			 sz=#(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1)
			 )
			selectandshow 1
		)
		
	
		on rdo1 changed stat do
	(
	timeConfiguration.playbackSpeed=stat
	)
		
		on cstoolroll lbuttondown pos do
		(
		  dw=getdialogpos cstoolroll
		  mx=mouse.screenpos.x-dw.x-3
		  my=mouse.screenpos.y-dw.y-52
		  readbutton mx my 
		  if btncode>=1 and btncode<=24 then 
			(
			  imglbuttondown btncode
			) 
			else
	
			if btncode==30 then
			(
			showbip=1-showbip;
			for obj in geometry do
			if classof obj == Biped_Object     then if showbip==1 then  obj.isHidden=on else obj.isHidden=off
			 
			
			--  if keyboard.controlpressed==true then
			--  (
			--   mpobj=(for o in geometry where (classof o== Biped_Object   )  collect o)
			--  for obj in mpobj do obj.ishidden=false
			--  select mpobj
			--  actionMan.executeAction 0 "281"  -- Tools: Hide Unselected
			--  selectandshow 1
			--  )
			 
			
		   )
			else
		   if btncode==27 then 
			(
		
		boxmodeflag=1-boxmodeflag;
		for obj in geometry do
		(
			if classof obj == Biped_Object then 
			(
			
			if boxmodeflag==1 then 
			obj.boxmode = on 
			else
			obj.boxmode = off 
			)
			
		)
				
				)
				
				else
				-- if btncode==29 then
				-- (
				-- showtrajflag=1-showtrajflag
				-- selectandshow 1
				-- )
				-- else
				if btncode==26 then
		(
		   actionMan.executeAction 0 "40264"
		
		if fullscreenflag== 0 then
			(		 
			menuMan.loadMenuFile "full.mnu"
			fullscreenflag=1
			)		
		else
			(
			 menuMan.loadMenuFile "DefaultUI.mnu"
			 fullscreenflag=0
			)
		 
		time = not
				(
							timeslider.isVisible()
					 ) 
							timeSlider.setVisible  time
		
		
		if trackbar.visible == true  then 
							trackbar.visible = false
					else
							  trackbar.visible = true
		 
		
		 
			)			
			else
				if btncode==32 then
			(
			lx=bipname[24].controller.bodyType
			lx+=1;if lx>3 then lx=0
			bipname[24].controller.bodyType=lx
			)
			
				-- else
				-- if btncode==28 then 
				-- (
				-- speedmode=1-speedmode
				--  if speedmode==1 then 
				--  (
				--  stopAnimation()
				--  timeConfiguration.playbackSpeed=3
				--  anflag=1
				--  atime=0
				--  --max time play
				--  )
				--  else 
				--  (
				--   stopAnimation()
				--    timeConfiguration.playbackSpeed=bspeed
				--  anflag=1
				--  atime=0
				--    --max time play
				--    )
				--   )
	
		)
		on cstoolroll rbuttondown pos  do
		(
		  dw=getdialogpos cstoolroll
		  mx=mouse.screenpos.x-dw.x-3
		  my=mouse.screenpos.y-dw.y-52
		  readbutton mx my 
		  if btncode>=1 and btncode<=24 then 
			(
			  imgrightclick btncode
			) else 
			-- if btncode==28 then
			-- (
			--  stopAnimation() 	
	
			-- ) else 
			if btncode==26 then
			(
	   state = not(timeslider.isVisible()) 
			trackbar.visible = state
			timeSlider.setVisible state
			) 
			else 
			if btncode==27 then
			(
			lx=bipname[24].controller.bodyType
			lx+=1;if lx>3 then lx=0
			bipname[24].controller.bodyType=lx
			)
			else
			try(
			 if btncode==30 then
			   mpobj=(for o in geometry where (isproperty o "skin" or isproperty o "Physique" )  collect o)
			--  if keyboard.controlpressed==true then
			--  (
			 
			--  for obj in mpobj do obj.ishidden=false
			--  select mpobj
			--  actionMan.executeAction 0 "281"  -- Tools: Hide Unselected
			--  selectandshow 1
			--  )
			--  else
			--  (
			--  xsbz=mpobj[1].ishidden
			--  for obj in mpobj do if xsbz==false then obj.ishidden=true else obj.ishidden=false 
			--  )
		   )
		   catch()
			
		)
		on cstoolroll lbuttondblclk pos  do
		(
		  dw=getdialogpos cstoolroll
		  mx=mouse.screenpos.x-dw.x-3
		  my=mouse.screenpos.y-dw.y-52
		  readbutton mx my 
		bip=bipname[24].controller
		 if btncode==9 and bip.fingers>1 then 
		 
		 (
		 hsz=#(0,0,0,0,0,0);
		 nowhandlx=1;
		 if selhanddlg!=undefind then destroydialog selhanddlg
		 createdialog selhanddlg;
		 hsz=#(0,0,0,0,0,0);hsz[bip.fingers+1]=1
		 selandshowhand()
		 )
		 else
		 if btncode==10 and bip.fingers>1 then (
		 hsz=#(0,0,0,0,0,0);
		 nowhandlx=2;
		 if selhanddlg!=undefind then destroydialog selhanddlg
		 createdialog selhanddlg;
		 hsz=#(0,0,0,0,0,0);hsz[bip.fingers+1]=1
		  selandshowhand()
		 )
		 else
		 if btncode>=1 and btncode<=24 then
	
			(
			  imglbuttondblclk btncode
			) 
			else
		if btncode==26 then 		
		( 
			)
		
	
		)
		
		on bip_list selected sel do
		(
		   if splinenum==1 then copy tmp1 back
		   else
		   if splinenum==2 then copy tmp2 back
		   else
		   if splinenum==3 then copy tmp3 back
		   else
		   if splinenum==4 then copy tmp4 back
	
		   print  bip_list.selection
			 getbipname bip_list.selection
			 sz=#(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1)
	
			 selectandshow 1
		)
		-- on refresh_bips pressed do
		-- (   
		 
		--   rootname="none"
	
	
		--   xz=#()
		--   for i in (selection as array) do
		--       if classof i==Biped_Object then  (rootname=(getBipRootNode i ).name;append xz i;)
	
	
	
		-- 	 allbipsName =#()
		--        allbips = getallbips()
		--        for i = 1 to allbips.count do (append allbipsName allbips[i].name)
		-- 	bip_list.items=allbipsName
			
			
	
		-- 	   if bip_list.items.count>0 then
		-- 	   if bip_list.selection<=0 or bip_list.selection>bip_list.items.count  then bip_list.selection=1
			   
		-- 	if rootname!="none"  then
		-- 	for i= 1 to bip_list.items.count do if rootname==bip_list.items[i] then bip_list.selection=i
			
				
		-- 		getbipname bip_list.selection
				
		-- 	if rootname!="none" then 
		-- 	(
		-- 	select xz
		--  	sz=#(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
		-- 	print "&************************"
		-- 	for i=1 to xz.count do for j=1 to bipname.count do if  xz[i]==bipname[j] then sz[j]=1 
		-- 	)
		-- 	else	
		-- 	(
		--      sz=#(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1)
		--      )
			  
		-- 	selectandshow 1
		-- )
		
		
	on savefile_btn rightclick do
	(
	autosavepath=getdir #maxroot+"AutoBip"
	try(makedir autosavepath )catch();
	
	try
	(
	bipfile=autosavepath+"\\"+"autobip1.bip"
	deleteFile bipfile
	for i=2 to 10 do 
	(
	index=i as string;
	index1=(i-1) as string;
	bipfile=autosavepath+"\\"+"autobip"+index+".bip"
	bipfile01=autosavepath+"\\"+"autobip"+index1+".bip"
	renameFile bipfile bipfile01
	)
	
	bip=bipname[24].controller
	bipfile=autosavepath+"\\"+"newbip.bip"
	biped.saveBipfile bip bipfile
	
	i=10;index=i as string;
	bipfile=autosavepath+"\\"+"newbip.bip"
	bipfile01=autosavepath+"\\"+"autobip"+index+".bip"
	renameFile bipfile bipfile01
	 )catch()
	   
	)
		
		
		on savefile_btn pressed do
		  if havebip==1 then 
		 ( bip=bipname[24].controller
	
		  if  keyboard.controlpressed==true then
			try (timescan=0;tmr1.active=false;bip=bipname[24].controller; biped.saveBipfiledlg  bip	"c:\\a.bip";tmr1.active=true;timescan=1;)catch()	else
	 
	
			 if bip.figureMode== true	  then
				 (
	       		if querybox "BIP处于编辑状态，要切换成运动模式并保存BIP文件么？" title:"提示" beep:false then
	               try (    local bipfile
		          pathfilename=filepath+"\\"+bipfilename;
			     bipfile = getsavefileName caption:"保存BIP文件" filename:pathfilename  types:"Bip file(*.Bip)|*.bip|All files(*.*)|*.*"
			     if bipfile!=undefined then 
				          bip.figureMode= false
				  biped.saveBipfile bip bipfile
			      lastfilepath=filepath;
		     	 zz=#()
			      filepath=""
			      zz=filterString bipfile "\\"
			      for i=1 to zz.count-1 do
			      if i!=zz.count-1 then filepath =filepath +zz[i]+"\\" else filepath =filepath+zz[i]
		      	 if lastfilepath!=filepath then 
				  savedate();
				 )catch()
				 )
				 
				 else 
			 (	    local bipfile
		     	pathfilename=filepath+"\\"+bipfilename;
			    bipfile = getsavefileName caption:"保存BIP文件" filename:pathfilename  types:"Bip file(*.Bip)|*.bip|All files(*.*)|*.*"
			   if bipfile!=undefined then 
			     try (
			      bip=bipname[24].controller
				  biped.saveBipfile bip bipfile
			      lastfilepath=filepath;
		 zz=#()
		 filepath=""
		 zz=filterString bipfile "\\"
		 vv=zz.count 
		 bipfilename=zz[vv]
		 showfile=replace bipfilename (bipfilename.count-3) 4 ""
	
		  
			      for i=1 to zz.count-1 do
			      if i!=zz.count-1 then filepath =filepath +zz[i]+"\\" else filepath =filepath+zz[i]
		      	 if lastfilepath!=filepath then 
				  savedate();
	     opf=1;
		 pathdlg.pathtext.text=filepath
				 
				 
			theFiles = getFiles (filepath+"\\*.bip") 
			bipfileitems=#()
			for f in theFiles do
				(
					zz=#()
					zz=filterString f  "\\"
					filename=replace zz[zz.count] (zz[zz.count].count-3) 4 ""
	                   append bipfileitems (filename+".bip")
	                ) 			
	         pathdlg.bipfilelist.items=bipfileitems 
			for i=1 to bipfileitems.count do 
			 if bipfileitems[i]==bipfilename then  pathdlg.bipfilelist.selection=i
	
	
			
		 -- pathdlg.lbl2.text=bipfilename
		 cstoolroll.title=showfile;
	                     )catch()
	 
	          )
	   )
		
	on openfile_btn rightclick do
	(
	 
	 autobippath=getdir #maxroot+"AutoBip"
	 autobipfile = getOpenFileName caption:"打开BIP文件" filename:(autobippath+"\\*.*") types:"Bip file(*.Bip)|*.bip|All files(*.*)|*.*"
	 bip=bipname[24].controller;
	 try(
	 biped.loadBipfile bip autobipfile
	 )catch(); 
	 
	)
	
		on openfile_btn pressed do
		if havebip==1 then 
			 if  keyboard.controlpressed==true then
			 (  
	           bip=bipname[24].controller; biped.loadbipfiledlg  bip 
			 ) 
			 else
			(	
			 local bipfile
		     pathfilename=filepath+"\*.bip";
		    bipfile = getOpenFileName caption:"打开BIP文件" filename:pathfilename types:"Bip file(*.BIP)|*.bip|Bip file(*.BVH)|*.bvh|All files(*.*)|*.*"
		  
	      bip=bipname[24].controller; 
		 try( biped.deleteLayer bip  1)catch();    
		 if bipfile!=undefined then 
		 try(	
		     t1=animationRange.start;	 t2=animationRange.end; 
		     animationRange = Interval 0 1
	      bip.figureMode= false;
	      bip.mixerMode = false;
		  
		 filelx=substring bipfile (bipfile.count-2) 3
		 if filelx=="bip" then  biped.loadBipfile bip bipfile
		 lastfilepath=filepath;
		 zz=#()
		 filepath=""
		 zz=filterString bipfile "\\"
		 
		 vv=zz.count 
		 bipfilename=zz[vv]
		 
	
		  
		 showfile=replace bipfilename (bipfilename.count-3) 4 ""
		
	       if filelx=="bvh" then  
		   (
		   
		   
		   if $sangum070816_Bip01==undefind then
		   (
	        mergeMAXFile "$UI_ln\\ICONS\\cstoolIcons\\newbip.max"  
		 rollout  explain "Untitled" width:318 height:27
	      (
		  label lbl1 "BVH文件读取相对较慢.请稍候...." pos:[13,4] width:282 height:21
	      )		
		   bipx=$sangum070816_Bip01.controller
		   bipx.figureMode= false
		   createdialog explain 318 27
		   biped.loadMocapFile bipx bipfile #noRedraw
		   
		   biped.saveBipfile bipx (getdir #maxroot+"temp.bip")
		   select  $sangum070816*
	        actionMan.executeAction 0 "40020"  -- Edit: Delete Objects
	          biped.loadBipfile bip  (getdir #maxroot+"temp.bip")
	     	destroydialog explain  
			  )
			select bipname[24]
	
		   
		   --,,,
		   )
	      pathdlg.bipfilelist.items=bipfileitems 
		  
		 for i=1 to zz.count-1 do
		 if i!=zz.count-1 then filepath =filepath+zz[i]+"\\" else filepath=filepath+zz[i]
		 if lastfilepath!=filepath then 
	      savedate();	
	     opf=1;
		 
		 pathdlg.pathtext.text=filepath
				 
			theFiles = getFiles (filepath+"\\*.bip") 
			bipfileitems=#()
			for f in theFiles do
				(
					zz=#()
					zz=filterString f  "\\"
					filename=replace zz[zz.count] (zz[zz.count].count-3) 4 ""
	                   append bipfileitems (filename+".bip")
	                ) 			
				
				for  i=1 to bipfileitems.count  do
			     for j=1 to bipfileitems.count do
				 (
				   if bipfileitems[i]< bipfileitems[j] then ( temp= bipfileitems[i]; bipfileitems[i]=bipfileitems[j];bipfileitems[j]=temp;)
				 ) 
				 
			 
			 
			for i =1 to bipfileitems.count do 
			 if bipfileitems[i]==bipfilename then  pathdlg.bipfilelist.selection=i
	
		
	     pathdlg.lbl_bip.caption=bipfilename 
		 cstoolroll.title=showfile;
		) catch()
		
		st1=animationRange.start;
		 st2=animationRange.end; 
		  if ( st1==0 and st2==1) then animationRange = Interval t1 t2 
	
		--max create mode
	
		)
			
			
		on key_btn pressed do
		if havebip==1 then
	(
			 if $==bipname[24] then
			 if keyboard.controlpressed == true then
			 (
			  max motion mode
			  $.transform.controller.trackSelection=1
			   
			   biped.setSelectedKey bipname[24].controller
	
			   $.transform.controller.trackSelection=2
			   biped.setSelectedKey bipname[24].controller
	
			  $.transform.controller.trackSelection=3
			 biped.setSelectedKey bipname[24].controller
	
			  pivotmode=0
			  --max create mode
			 )		 
			 else
			 (
			  max motion mode
			  if pivotmode==1 then   $.transform.controller.trackSelection=1
			  if pivotmode==2 then   $.transform.controller.trackSelection=2
			  if pivotmode==3 then   $.transform.controller.trackSelection=3
			  biped.setPlantedKey $
			  pivotmode=0
			  --max create mode
			 )
			 if sz[1]==1 or sz[2]==1 then biped.setSelectedKey bipname[1].controller
			 if sz[3]==1 or sz[5]==1 or sz[7]==1 or sz[9]==1 then biped.setSelectedKey bipname[3].controller
			 if sz[4]==1 or sz[6]==1 or sz[8]==1 or sz[10]==1 then biped.setSelectedKey bipname[4].controller
			 if sz[11]==1 or sz[13]==1 or sz[15]==1 or sz[17]==1 then biped.setSelectedKey bipname[11].controller
			 if sz[12]==1 or sz[14]==1 or sz[16]==1 or sz[18]==1 then biped.setSelectedKey bipname[12].controller
			 if sz[19]==1 or sz[20]==1 or sz[21]==1 or sz[22]==1 then biped.setSelectedKey bipname[22].controller
			 if sz[23]==1  then biped.setSelectedKey bipname[23].controller	
			   if sz[24]==1  then 
			 if keyboard.controlpressed == true then
			 (
			  max motion mode
			  bipname[24].transform.controller.trackSelection=1
			  biped.setSelectedKey bipname[24].controller
	
			   bipname[24].transform.controller.trackSelection=2
			  biped.setSelectedKey bipname[24].controller
	
			  bipname[24].transform.controller.trackSelection=3
			  biped.setSelectedKey bipname[24].controller
			 -- max create mode
			 )
			 
			 else
			 biped.setSelectedKey bipname[24].controller
			 
			  selectandshow 1
	
				
		)
		
		
		on plantedkey_btn pressed do
				if havebip==1 then
				 try(
			 if sz[3]==1  or sz[ 5]==1 or sz[ 7]==1 or sz[ 9]==1 then biped.setPlantedKey   bipname[3]
		  if sz[4]==1  or sz[ 6]==1 or sz[ 8]==1 or sz[10]==1 then biped.setPlantedKey   bipname[4]
		  if sz[11]==1 or sz[13]==1 or sz[15]==1 or sz[17]==1 then  biped.setPlantedKey   bipname[11]
		  if sz[12]==1 or sz[14]==1 or sz[16]==1 or sz[18]==1 then biped.setPlantedKey   bipname[12]
		  )catch()
				
		on sliderkey_btn pressed do
				if havebip==1 then
				 try(
			 if sz[3]==1  or sz[ 5]==1 or sz[ 7]==1 or sz[ 9]==1 then biped.setSlidingKey bipname[3]
		  if sz[4]==1  or sz[ 6]==1 or sz[ 8]==1 or sz[10]==1 then biped.setSlidingKey bipname[4]
		  if sz[11]==1 or sz[13]==1 or sz[15]==1 or sz[17]==1 then  biped.setSlidingKey bipname[11]
		  if sz[12]==1 or sz[14]==1 or sz[16]==1 or sz[18]==1 then biped.setSlidingKey bipname[12]
		  )catch()
		  
		on freekey_btn pressed do
				if havebip==1 then
				 try(
			 if sz[3]==1  or sz[ 5]==1 or sz[ 7]==1 or sz[ 9]==1 then biped.setfreekey   bipname[3]
		  if sz[4]==1  or sz[ 6]==1 or sz[ 8]==1 or sz[10]==1 then biped.setfreekey   bipname[4]
		  if sz[11]==1 or sz[13]==1 or sz[15]==1 or sz[17]==1 then  biped.setfreekey   bipname[11]
		  if sz[12]==1 or sz[14]==1 or sz[16]==1 or sz[18]==1 then biped.setfreekey   bipname[12]
		  )catch()
	
		on hori_btn changed state do
				if havebip==1 then(max move;max tool x;pivotmode=1)
		on vert_btn changed state do
				if havebip==1 then(max move;max tool z;pivotmode=2)
		on rotate_btn changed state do
				if havebip==1 then(max rotate;pivotmode=3)
		on modebtn1 pressed do
		(
			if havebip==1 then
			(
		       if modebtn1.caption=="Mixer" then 
				(
					if mode==1 then modebtn1.Caption="Pose"
					if mode==3 then modebtn1.caption="Layer" 
					setmode 2
					mode=2
					--themixer.hideMixer();   themixer.showMixer()
				) else      
				if modebtn1.caption=="Layer"  then 
				(
					if mode==1 then modebtn1.Caption="Pose"
					if mode==2 then modebtn1.caption="Mixer" 
					setmode 3
					mode=3
				) else
				if modebtn1.caption=="Pose" then 
				(
					if mode==2 then modebtn1.Caption="Mixer"
					if mode==3 then modebtn1.caption="Layer" 
					setmode 1
					mode=1
					readpose 0 
				) 
			)
		)
			
		on  modebtn2 pressed do
		(
			if havebip==1 then
			(
		       if modebtn2.caption=="Mixer"  then 
		     (
			 if mode==1 then modebtn2.Caption="Pose"
		     if mode==3 then modebtn2.caption="Layer" 
			 setmode 2
			 mode=2
			 --themixer.hideMixer();   themixer.showMixer()
			 )   else    
		   if modebtn2.caption=="Layer"  then 
		     (
			 if mode==1 then modebtn2.Caption="Pose"
		     if mode==2 then modebtn2.caption="Mixer" 
			 setmode 3
			 mode=3
			 )   else
		   if modebtn2.caption=="Pose"  then 
		     (
			 if mode==2 then modebtn2.Caption="Mixer"
		     if mode==3 then modebtn2.caption="Layer" 
			 setmode 1
		     mode=1
			 readpose 0
			 ) 
			
			)
		)
			
		
		
		on newlayer_btn pressed do
		(
		   -- max motion mode
		    bip=bipname[24].controller;
				if havebip==1 then 
				 if biped.numLayers bip >= 1 then
		       	 messagebox("当前已存在层,无法再增加了")
		           else
		         undo on( biped.createLayer bip 1 "Layer 2" )
		       slidertime=currenttime
					
		)
				 
			
				
		
				
				
		on deletelayer_btn pressed do
				if havebip==1 then undo on(bip=bipname[24].controller; if biped.numLayers bip >= 1 then   biped.deleteLayer bip  1 )
		on collapselayer_btn pressed do
				if havebip==1 then undo on(bip=bipname[24].controller; if biped.numLayers bip >= 1 then   biped.collapseAtLayer bip  0 )
		on layerkey_btn pressed do
				if havebip==1 then  undo on(biped.setSnapKey bipname[24])
		
		on copy_btn pressed  do
		  	if havebip==1 then
			try(        
		          bip=bipname[24].controller	
			       biped.deleteAllCopies  bip  #pose
				  biped.deleteAllCopies bip #posture
			     cos=biped.numCopyCollections bip
		          if cos==0 then  biped.createcopyCollection bip "zsj"
				  biped.copyPosture bip #posture on on on
			       biped.setCopyName bip #posture 1 "posture_good"
			       posturenum=biped.numCopies bip #posture 
			       posenum=biped.numCopies bip #pose 
				   
			        if posturenum==0 then 
			        (biped.deleteAllCopies  bip  #pose
				  biped.deleteAllCopies bip #posture
				  biped.copyPosture  bip #pose on on on 
				  biped.setCopyName bip #pose 1 "pose_good"		
			  	  posturenum=biped.numCopies bip #posture 
			       posenum=biped.numCopies bip #pose
				   )
				)   catch()
				
		on paste_btn pressed do
			if havebip==1 then
			
			undo on (
		      bip=bipname[24].controller
			 posturenum=biped.numCopies bip #posture 
		
			if posturenum==1  then 
			   biped.pastePosture  bip #posture false "posture_good"
			else
			   biped.pastePosture  bip #pose false "pose_good"	
	
		)
		
		on mirrorpaste_btn pressed do
				if havebip==1 then
				
				undo on (
			bip=bipname[24].controller
			posturenum=biped.numCopies bip #posture 
			if posturenum==1  then 
			   biped.pastePosture  bip #posture true "posture_good"
			else
			   biped.pastePosture  bip #pose true "pose_good"		
		)
		
			
		on MIX_btn pressed do
				if havebip==1 then( themixer.hideMixer();	themixer.showMixer();   )
			
		on mixdoor_btn changed state do
				if havebip==1 then(bip=bipname[24].controller; if mixdoor_btn.checked==true then  bip.mixerMode=true else bip.mixerMode = false; )
		
		on MtoB_btn pressed do
			if havebip==1 then
			undo on (	
		 bip=bipname[24].controller;
		 if mixdoor_btn.checked==true  and  bip.mixerMode==true then 
		  (
		   mymixer = bipname[24].transform.controller.mixer
		   mixdown mymixer true true 6 true 166.15
		   copyMixdownToBiped  mymixer
		   bip.mixerMode=false
		   mixdoor_btn.checked=false
		  )
		)
		
		on  MixFolder_btn pressed do
		(
		  if mergebip.open==false then createdialog mergebip 294 157
		     else DestroyDialog mergebip  
		)
		
		
		on startnumtext entered text do
		(
		start=startnumtext.text as integer
		if start==undefind then start=animationRange.start
		  if start>=endnum.value then   endnum.value=start+1;
		animationRange = Interval start endnum.value
		)
		
		
		on endnum entered  do
		(
		animationRange = Interval animationRange.start endnum.value
		)
		
		on time1_btn pressed do
		/*
			if keyboard.controlpressed==true then
			(
	        start=animationRange.start-myaddtime;end=animationRange.end
		    animationRange = Interval  start end   
			)
	
			 else
			 */
	    	(
			newtime=slidertime-mymovetime;
			if newtime-mymovetime<animationRange.start then
			(
	          start=animationRange.start-mymovetime;end=animationRange.end-mymovetime
		      animationRange = Interval  start end
			  )
			  slidertime=newtime;
		    )	
		
		
		on time2_btn pressed do
		(
		    start=currentTime-myrangetime/2;end=currentTime+myrangetime/2
		    animationRange = Interval  start end
		)
			
		on time3_btn pressed do
		/*
			if keyboard.controlpressed==true then
			 (
	          start=animationRange.start;end=animationRange.end+myaddtime
		      animationRange = Interval  start end	  	     
		     )
		    	else
	*/
	    	(
			newtime=slidertime+mymovetime;
			if newtime+mymovetime>animationRange.end then
			(
	          start=animationRange.start+mymovetime;end=animationRange.end+mymovetime
		      animationRange = Interval  start end
			  )
			  slidertime=newtime;
		    )	
		
		on time1_btn rightclick do 
			if keyboard.controlpressed==true then
			(
	        start=animationRange.start+myaddtime;end=animationRange.end
			if end-start<=0 then start=end-1;
		    animationRange = Interval  start end   
			)
	         else
			(
			start=mystarttime;end=mystarttime+myrangetime
		    animationRange = Interval  start end
			)
	
		on time2_btn rightclick do 
	if havebip==1 then
		(
		  	 range_begin=99999;
	range_end=-99999;
	for i =1 to 23 do
	(
	thiskey=bipname[i].controller.keys
	kn=thiskey.count
	if kn>0 then
	(
	rb=thiskey[1].time ;re=thiskey[kn].time ;
	
	if range_begin>rb then range_begin=rb
	if range_end<re then range_end=re
	)
	
	
	)
	
	 
	thiskey=bipname[24].controller.vertical.controller.keys
	kn=thiskey.count;
	if kn>0 then
	(
	rb=thiskey[1].time ;re=thiskey[kn].time ;
	if range_begin>rb then range_begin=rb
	if range_end<re then range_begin=re
	)
	
	
	thiskey=bipname[24].controller.horizontal.controller.keys
	kn=thiskey.count;
	if kn>0 then
	(
	rb=thiskey[1].time ;re=thiskey[kn].time ;
	if range_begin>rb then range_begin=rb
	if range_end<re then range_begin=re
	)
	
	thiskey=bipname[24].controller.turning.controller.keys
	kn=thiskey.count;
	if kn>0 then
	(
	rb=thiskey[1].time ;re=thiskey[kn].time ;
	if range_begin>rb then range_begin=rb
	if range_end<re then range_begin=re
	)
	
	animationRange = Interval  rb  re  
	)	
		else
		 animationRange = Interval  mystarttime myendtime
	
		on time3_btn rightclick do 
			if keyboard.controlpressed==true then
			 (
	          start=animationRange.start;end=animationRange.end-myaddtime
			  if end-start<=0 then end=start+1
		      animationRange = Interval  start end	  	     
		     )
			 else
		     (
		      start=myendtime-myrangetime;end=myendtime
		      animationRange = Interval  start end
		     )	
			 
		on cstoolroll moved pos do
	   (
	   
		tpos=getdialogpos cstoolroll
		dialog_x=tpos.x
		dialog_y=tpos.y
	   ) 
		
		on LeftFootA_btn mouseover do (LeftFootA_btn.bitmap = image_LeftFootA2)
		on LeftFootA_btn mouseout  do (LeftFootA_btn.bitmap = image_LeftFootA)
	
		
		on LeftFootB_btn mouseover do (LeftFootB_btn.bitmap = image_LeftFootB2)
		on LeftFootB_btn mouseout  do (LeftFootB_btn.bitmap = image_LeftFootB)
		
		on LeftFootC_btn mouseover do (LeftFootC_btn.bitmap = image_LeftFootC2)
		on LeftFootC_btn mouseout  do (LeftFootC_btn.bitmap = image_LeftFootC)
	
		
		on LeftFootD_btn mouseover do (LeftFootD_btn.bitmap = image_LeftFootD2)
		on LeftFootD_btn mouseout  do (LeftFootD_btn.bitmap = image_LeftFootD)
		
	
		on LeftFootA_btn  click do if $==bipname[16] or $==bipname[15] then try( BipedPivot 1;)catch()
		on LeftFootB_btn  click do if $==bipname[16] or $==bipname[15] then try( BipedPivot 3;)catch()
		on LeftFootC_btn  click do if $==bipname[16] or $==bipname[15] then try( BipedPivot 6;)catch()
		on LeftFootD_btn  click do if $==bipname[16] or $==bipname[15] then try( BipedPivot 8;)catch()
	
		-- on set_btn pressed do
		-- (
		
		--  if paraflag==1 then 
		-- 	   ( 
		-- 		paraflag=0;
		-- 		savedate();
		-- 		destroydialog setpara
		-- 		)
		-- 		else
		-- 		(
		-- 			createdialog setpara 120 310 (dialog_x-124) (dialog_y)
		-- 		  paraflag=1;
		-- 		  )
		-- )
		
		on help_btn rightclick do
		(
		
	if ottool != undefind then CloseRolloutfloater ottool
	
	
	ottool=newrolloutfloater "CS工具合集" 200 465  (dialog_x-210) (dialog_y)
	
	addrollout ot00          ottool   rolledUp: on
	addrollout turnBipframe  ottool   rolledUp: on 
	addrollout followobj     ottool   rolledUp: on
	
	addrollout ot05          ottool   rolledUp: off 
	addrollout ot02          ottool   rolledUp: off
	
	
	addrollout xhb           ottool   rolledUp: on 
	addrollout ot01          ottool   rolledUp: on
	addrollout aboutme       ottool   rolledUp: on
		
		)
		
		
		on help_btn pressed do
	(
	
		 if pathdlgflag==1 then 
			   ( 
				pathdlgflag=0;
				destroydialog pathdlg
				)
				else
				(
					createdialog pathdlg 223 500 (dialog_x+120) (dialog_y-2)
				  pathdlgflag=1;
				  )
	-- print bip_list.items[2]
	
	
	
	)
		
	on tmr1 tick do
	  if timescan==1 then
	(	
		if havebip==0 then
		(
			rootname="none"
			xz=#()
			allbipsName =#()
			allbips = getallbips()	  
			for i in (selection as array) where (selection.count != 0) do
			(
				if classof i==Biped_Object then  		  (rootname=(getBipRootNode i ).name;append xz i;)
			)
			if rootname=="none" and allbips.count>0 then select allbips[1]
			if rootname!="none" or  allbips.count>0 then  
			(
				for i = 1 to allbips.count do (append allbipsName allbips[i].name)
				bip_list.items=allbipsName
				if bip_list.items.count>0 then
				if bip_list.selection<=0 or bip_list.selection>bip_list.items.count  then bip_list.selection=1
				
				if rootname!="none"  then
				for i= 1 to bip_list.items.count do if rootname==bip_list.items[i] then bip_list.selection=i
					getbipname bip_list.selection
				
				sz=#(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
				
				for i=1 to xz.count do for j=1 to bipname.count do if  xz[i]==bipname[j] then sz[j]=1 
				selectandshow 0
				havebip=1
	
			)	
		
		)
	 
		
		if anflag==1 then 
		(
			atime+=1;
			if atime>2 then (anflag=0;atime=0;max time play)
		)
	
		 try(
		 bip=bipname[24].controller
			  )
		 catch(copy tmplost back;bip_list.items=#();splinenum=5;background.bitmap=back;havebip=0;allbipundefind 0; cstoolroll.title="CS工具";opf=0;	  if pathdlgflag==1 then pathdlg.pathtext.text=filepath);
	
	
		if dialog_x!=last_dialog_x or dialog_y!=last_dialog_y then 
		   (
		   -- if paraflag==1 then (spos=point2 (dialog_x+120) dialog_y;setdialogpos setpara spos)
			last_dialog_x=dialog_x;last_dialog_y=dialog_y;
			savedate()
			)
		 dw=getdialogpos cstoolroll
		if hiderollyflag==1 then
		(
			hidedlg=true;
			if dw.y>-310 then
			(
			dw.y-=90;
			setdialogpos  cstoolroll  dw
			)
			else
			(
			dw.y=-400;
			setdialogpos  cstoolroll  dw
			hiderollyflag=0
			)
		)
		else
		if showrollyflag==1  then
		(
			if dw.y<-90   then
			(
			dw.y+=90;
			setdialogpos  cstoolroll  dw
			)
			else
			(
			dw.y=0;
			setdialogpos  cstoolroll  dw
			showrollyflag=0
			hidedlg=false;
			)
			
		)
		else
	 
		(
		/*
			zbdlg.edt1.text=dw.x as string
			zbdlg.edt2.text=dw.y as string
			zbdlg.edt3.text=mouse.screenpos.x as string
			zbdlg.edt4.text=mouse.screenpos.y as string
		*/
			mx=mouse.screenpos.x-dw.x
			my=mouse.screenpos.y-dw.y
			
	
			if dw.y<0 and hidedlg==false  then 
			(dw.y=0;
			setdialogpos  cstoolroll  dw
			)
			if mx>0 and mx<120 and mouse.screenpos.y==0 and hidedlg==true then 
			(
			showrollyflag=1;	
			print "显示窗口"
			)
			
			else
			if dw.y==0 then
			if mx<0 or mx>122 or my>400 then hiderollyflag=1;
	
		)
		
	 
	-- if laststart!=animationRange.start or lastend!=animationRange.end then 
	-- 	(
	-- 	-- startnumtext.text=integer(animationRange.start) as string
	-- 	endnum.value=animationRange.end
	--      laststart=animationRange.start;lastend=animationRange.end	
	--     )
		
	-- laststart=animationRange.start;lastend=animationRange.end
		changebipname=""
	
		 if havebip==1 then
		 (
		 
		 changebip=true;
		 selbipflag=false;
		 
		for i in (selection as array) do
		if classof i==Biped_Object then 
		 ( selbipflag=true;
		  biprootname=i.controller.rootname
		  if biprootname==cstoolroll.bip_list.selected then changebip=false;
		  else
		  changebipname=biprootname
		)
		
		if changebip==true and selbipflag==false then changebip=false
	  --tsz=#(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	 
		if changebip==true then 
		(  
		  
		 thisbip=0
		  for j =1 to cstoolroll.bip_list.items.count do 
		   if cstoolroll.bip_list.items[j]==changebipname then thisbip=j
			  bip_list.selection=(int)thisbip	  
		  if thisbip==0 then 
			(		
			
	
				
					allbipsName =#()
					allbips = getallbips()
					for i = 1 to allbips.count do (append allbipsName allbips[i].name)
					bip_list.items=allbipsName
					
					bip_list.selection=allbipsName.count
			)
		)
		--	 getbipname  bip_list.selection
	 
			tsz=sz 
			sz=#(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
			--bip=bipname[24].controller
			for i in (selection as array) do
			(
				for j=1 to bipname.count do
						if i==bipname[j] then sz[j]=1;
				autosavepath=getdir #maxroot+"AutoBip"
				try(makedir autosavepath )catch();
				
				temptime = localTime as string
				temps=filterString temptime ":"
				second=temps[2] as integer
				
				if (second>lastsecond and second-lastsecond>=autotimelimit)  or (second<lastsecond and second+60-lastsecond>=autotimelimit) then 
				try
				(
				lastsecond=second
				autotime=0;
				bipfile=autosavepath+"\\"+"autobip1.bip"
				deleteFile bipfile
				for i=2 to bipnumlimit do 
				(
				index=i as string;
				index1=(i-1) as string;
				bipfile=autosavepath+"\\"+"autobip"+index+".bip"
				bipfile01=autosavepath+"\\"+"autobip"+index1+".bip"
				renameFile bipfile bipfile01
				)
	
				bip=bipname[24].controller
				bipfile=autosavepath+"\\"+"newbip.bip"
				biped.saveBipfile bip bipfile
	
				i=bipnumlimit ;index=i as string;
				bipfile=autosavepath+"\\"+"newbip.bip"
				bipfile01=autosavepath+"\\"+"autobip"+index+".bip"
				renameFile bipfile bipfile01
				)catch()
	
			)
		  
		  
	
			if tsz.count!=sz.count then selectandshow 1
			else
			(
			showflag=0
			for k=1 to tsz.count do if tsz[k]!=sz[k] then showflag=1
			getbipname  bip_list.selection
			if showflag==1 then selectandshow 0
			)
		  
			if $==bipname[24] then 
			(
			
				vert_btn.checked=false
				hori_btn.checked=false
				rotate_btn.checked=false
				
				hori_btn.pos.x   = 34; plantedkey_btn.pos.x = 999
				vert_btn.pos.x   = 59; sliderkey_btn.pos.x  = 999
				rotate_btn.pos.x = 83; freekey_btn.pos.x    = 999
				
			)
			  else
			(
		
			plantedkey_btn.pos.x=34;hori_btn.pos.x   = 999;
			sliderkey_btn.pos.x =59;vert_btn.pos.x   = 999;
			freekey_btn.pos.x   =83; rotate_btn.pos.x= 999;  
			total=0
			if sz[3]==1  or sz[ 5]==1 or sz[ 7]==1 or sz[ 9]==1 then total+=1
			if sz[4]==1  or sz[ 6]==1 or sz[ 8]==1 or sz[10]==1 then total+=1
			if sz[11]==1 or sz[13]==1 or sz[15]==1 or sz[17]==1 then total+=1
			if sz[12]==1 or sz[14]==1 or sz[16]==1 or sz[18]==1 then total+=1
			
			if sz[1]+sz[2]+sz[19]+sz[20]+sz[21]+sz[22]+sz[23]+sz[24]>0 then total=0
			
			if total>=1 then 
				(
				plantedkey_btn.enabled = true
				sliderkey_btn.enabled  = true
				freekey_btn.enabled    = true
				)
				else
				(	  
				plantedkey_btn.enabled = false
				sliderkey_btn.enabled  = false
				freekey_btn.enabled    = false
				)
			)
		  
		  )
		)
	)
	
	--
	--
	--
	--
	--
	createdialog cstoolroll 115 395  dialog_x dialog_y 
	
	
	--addrollout cstoolroll cstool
	
	clearListener()  ---------清除侦听器