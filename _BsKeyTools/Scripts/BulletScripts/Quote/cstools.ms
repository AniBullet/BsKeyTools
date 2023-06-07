--转自CGJOY:https://www.cgjoy.com/forum.php?mod=viewthread&tid=150585
--原作者未知,Bullet.S精简修改,版权归原作者,请勿商用!后果自负!

global confCSTools = ((getDir #maxData) + "cstool.ini")

if doesFileExist confCSTools == false then
	(
		-- f = createFile ((getDir #maxData) + "cstool.ini");close f
		setinisetting confCSTools "Main" "Initial" "OK"
	)
	if cstoolroll!=undefined then destroydialog cstoolroll
	if pathdlg!=undefined then destroydialog pathdlg
	if setpara!=undefined then destroydialog setpara
	if mergebip!=undefined then destroydialog mergebip
	
	
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
	
	
	fn fnGetCSTConfig attr nameAttrClass nameAttr =  --设置初始信息方法
	(
		valueAttr = attr
		local oldPrintAllElements  = options.printAllelements
		options.printAllelements = true
		attr = (GetINISetting confCSTools nameAttrClass nameAttr) as string  --先提取文件中的记录
		if (matchpattern nameAttr pattern:"filepath" == true) then (attr = ("@" + attr))
		if (attr == "") or (attr == "undefined") then (attr = valueAttr)
		options.printAllelements = oldPrintAllElements
		attr
	)
	
	
	
	function savedate  =
	(
	--    f=createFile((getDir #maxData) + "cstool.ini")
	-- 	format "%\t%\n" dialog_x dialog_y to:f
	-- 	format "%\t%\t%\t%\t%\n" mystarttime myendtime myrangetime mymovetime myaddtime to:f
	--    format "%\n" bspeed to:f
	--    format "%\n" filepath  to: f
	--    format "%\n" autotimelimit to:f
	--    format "%\n" bipnumlimit  to:f
	--    close f
		setinisetting confCSTools "Main" "dialog_x" (dialog_x as string)
		setinisetting confCSTools "Main" "dialog_y" (dialog_y as string)
		setinisetting confCSTools "Main" "mystarttime" (mystarttime as string)
		setinisetting confCSTools "Main" "myendtime" (myendtime as string)
		setinisetting confCSTools "Main" "myrangetime" (myrangetime as string)
		setinisetting confCSTools "Main" "mymovetime" (mymovetime as string)
		setinisetting confCSTools "Main" "myaddtime" (myaddtime as string)
		setinisetting confCSTools "Main" "bspeed" (bspeed as string)
		setinisetting confCSTools "Main" "filepath" (filepath as string)
		setinisetting confCSTools "Main" "autotimelimit" (autotimelimit as string)
		setinisetting confCSTools "Main" "bipnumlimit" (bipnumlimit as string)
	)
		
	function loaddate  =
	(
		dialog_x = (fnGetCSTConfig dialog_x "Main" "dialog_x") as integer
		dialog_y = (fnGetCSTConfig dialog_y "Main" "dialog_y") as integer
		mystarttime = (fnGetCSTConfig mystarttime "Main" "mystarttime")
		myendtime = (fnGetCSTConfig myendtime "Main" "myendtime")
		myrangetime = (fnGetCSTConfig myrangetime "Main" "myrangetime")
		mymovetime = (fnGetCSTConfig mymovetime "Main" "mymovetime")
		myaddtime = (fnGetCSTConfig myaddtime "Main" "myaddtime")
		bspeed = (fnGetCSTConfig bspeed "Main" "bspeed")
		filepath = (fnGetCSTConfig filepath "Main" "filepath")
		autotimelimit = (fnGetCSTConfig autotimelimit "Main" "autotimelimit")
		bipnumlimit = (fnGetCSTConfig bipnumlimit "Main" "bipnumlimit")

	-- f = openfile ((getDir #maxData) + "cstool.ini")

	-- if f != undefined then 
	--    try
	-- 	  (
	--    dialog_x=readvalue f;dialog_y=readvalue f;
	--    mystarttime =readvalue f; myendtime =readvalue f; myrangetime =readvalue f; mymovetime =readvalue f;myaddtime =readvalue f;    
	--    bspeed=readvalue f;
	--    filepath=readLine f
	--    autotimelimit=readvalue f
	--    bipnumlimit =readvalue f
	--    format "%\t%\n" dialog_x dialog_y 
	--    format "%\t%\t%\t%\t%\n" mystarttime myendtime myrangetime mymovetime myaddtime 
	--    format "%\n" bspeed 
	--    format "%\n" filepath  
	--    format "%\n" autotimelimit
	--    format "%\n" bipnumlimit  
	--    close f 
	--   ) 	catch()
	--   else 
	--   try( 

	--    f=createFile((getDir #maxData) + "cstool.ini")
	-- 	format "%\t%\t%\n" dialog_x dialog_y to:f
	-- 	format "%\t%\t%\t%\t%\n" mystarttime myendtime myrangetime mymovetime myaddtime to:f
	--    format "%\n" bspeed to:f
	--    format "%\n" filepath  to: f
	--    format "%\n" autotimelimit to:f
	--    format "%\n" bipnumlimit  to:f
	--    close f
		
	--   )catch() 
		
	)
		
	-- function loadPathData  =
	--    (
	-- 	f = openfile ((getDir #maxData) + "bipPath.ini")
	
	-- 	if f != undefined then 
	-- 	   try
	-- 		  (
	-- 	   for i=1 to 20 do  pathItems[i]=readline f 
	-- 		for i=1 to 20 do  format "%\n" pathItems[i]
	-- 	   close f 
	-- 	  ) 	catch()
	-- 	  else  
	-- 	  try( 
	-- 	   f=createFile((getDir #maxData) + "bipPath.ini")
	-- 	   for i=1 to 20 do
	-- 		format "%\n" pathItems[i] to:f
	-- 	   close f
	-- 	  )catch()
	--    )
	   
	-- loaddate()
	-- if dialog_y<=0 then dialog_y=1
	-- loadPathData()
	
	loaddate()
	
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
	
	
	sdlx=0;
	jzlx=0;
	
	
	
	
	
	
	
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
		-- button help_btn " BIP\CS工具" pos:[55,1] width:60 height:20 tooltip:"左键BIP工具,\r\n右键CS工具合集"
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
		
	   on cstoolroll close do
	   (
			savedate()
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
	)
	--
	createdialog cstoolroll 115 395  dialog_x dialog_y style:#(#style_titlebar, #style_toolwindow, #style_sysmenu)
	
	
	--addrollout cstoolroll cstool
	
	clearListener()  ---------清除侦听器