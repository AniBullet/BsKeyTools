-- 修改:Bullet.S 2022.07

if CGfine_tools != undefined then closeRolloutFloater CGfine_tools
CGfine_tools=newrolloutfloater "多向渲染" 235 885
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

global tarRenderCamera
global tarRotateParent

rollout rolBaseConfig "基础设置" width:224 height:200
(

	pickbutton pbtCamera "点击选择相机" pos:[10,5] width:100 height:20 tooltip:"点击后选择渲染相机"
	pickbutton pbtParent "选择旋转父级" pos:[110,5] width:100 height:20 tooltip:"用来旋转相机的父级 Point"

	GroupBox grp1 "渲染范围" pos:[8,30] width:205 height:65
	button btnEnvironment "环境设置" pos:[128,72] width:80 height:15
	label lbl81 "范围" pos:[24,50] width:41 height:19
	label lbl82 "至" pos:[128,50] width:17 height:16
	spinner st "" pos:[64,50] width:56 height:16 range:[-1000,1000,0] type:#integer scale:1
	spinner End "" pos:[152,50] width:56 height:16 range:[-1000,1000,0] type:#integer scale:1
	label lbl31 "跳帧" pos:[24,72] width:48 height:18
	spinner spn19 "" pos:[64,72] width:56 height:16 range:[1,1000,5] type:#integer
	GroupBox grp63 "输出大小" pos:[8,100] width:205 height:40
	label lbl2 "宽：" pos:[20,120] width:20 height:16
	label lbl3 "高：" pos:[125,120] width:20 height:16
	spinner spn2 "" pos:[45,120] width:56 height:16 range:[0,10000,1024] type:#integer scale:1
	spinner spn3 "" pos:[145,120] width:56 height:16 range:[0,10000,1024] type:#integer scale:1

	on rolBaseConfig open do
	(
		rolBaseConfig.st.range =[0,1000,rendstart]
		rolBaseConfig.End.range =[0,1000,rendend]
		rolBaseConfig.spn19.range =[0,1000,rendNThFrame]
	)

	on pbtCamera picked obj do 
	(
		if superclassof obj == camera and not isDeleted obj and isValidNode obj then
		(
			tarRenderCamera = obj
			pbtCamera.text = obj.name
		)
	)

	on btnEnvironment pressed do (actionMan.executeAction 0 "40029")

	on pbtParent picked obj do 
	(
		if not isDeleted obj and isValidNode obj then
		(
			tarRotateParent = obj
			pbtParent.text = obj.name
		)
	)

	on spn19 changed val do
	(
		rendNThFrame=val	
	)

	on st changed val do
	rolBaseConfig.st.value = val
	on End changed val do
	rolBaseConfig.End.value = val
	
	on spn2 changed val do
	rolBaseConfig.spn2.value = val
	on spn3 changed val do
	rolBaseConfig.spn3.value = val
)

rollout AutoRender "单文件渲染" width:224 height:358
(
	button btn1 "8方向" pos:[160,97] width:43 height:25
	button bc "保存" pos:[168,25] width:41 height:23
	dropdownList geshi "" pos:[21,25] width:43 height:22 items:#("png", "tga", "jpg", "avi", "bmp", "tif")
	edittext bcwz "" pos:[16,52] width:191 height:16
	GroupBox grp64 "输出格式与路径" pos:[8,5] width:205 height:72
	button btn10 "2方向" pos:[64,97] width:43 height:25
	button btn17 "5方向" pos:[112,97] width:43 height:25
	button btn15 "单方向" pos:[16,97] width:43 height:25
	
	GroupBox grp45 "自定义渲染" pos:[8,135] width:205 height:69
	label lbl76 "方向数量" pos:[22,155] width:56 height:19
	label lbl77 "旋转角度" pos:[22,180] width:56 height:19
	spinner spn75 "" pos:[84,155] width:56 height:16 range:[1,360,5] type:#integer
	spinner spn76 "" pos:[84,180] width:56 height:16 range:[-360,360,45] type:#integer
	button btn68 "渲染" pos:[149,160] width:56 height:33
	GroupBox grp24 "快速渲染" pos:[8,80] width:205 height:48
	edittext wjm "文件名" pos:[69,27] width:91 height:14 enabled:true

	on btn1 pressed do
	(
		
		for i = 0 to 0 do  	
		
		( 
	               b=tarRotateParent
	               cam=tarRenderCamera
				 rotate b (angleaxis 0 [0,0,1])
		  n=bcwz.text+wjm.text+(i as string)+"." + geshi.selected 	  
		  
		  a=render Camera:cam fromframe:rolBaseConfig.st.value toframe:rolBaseConfig.End.value\
	outputwidth:rolBaseConfig.spn2.value outputheight:rolBaseConfig.spn3.value outputfile:n 
	  	 	  close a 		 	 )
	
			for i = 1 to 7 do 
		
			( 
		               b=tarRotateParent
		               cam=tarRenderCamera
					 rotate b (angleaxis 45 [0,0,1])
			  n=bcwz.text+wjm.text+(i as string)+"." + geshi.selected
		
			  a=render Camera:cam fromframe:rolBaseConfig.st.value toframe:rolBaseConfig.End.value\
		outputwidth:rolBaseConfig.spn2.value outputheight:rolBaseConfig.spn3.value outputfile:n
		
			  close a 		
		
			 )
			for i = 0 to 0 do
	(
	b=tarRotateParent
	rotate b (angleaxis 45 [0,0,1])
	)
		)
	on bc pressed do
	(
			lj=getSavepath()
			if lj != undefined do
			bcwz.text = lj+"\\"
		)
	on btn10 pressed do
	(
		
		for i = 0 to 0 do  	
		
		( 
	               b=tarRotateParent
	               cam=tarRenderCamera
				 rotate b (angleaxis 0 [0,0,1])
		  n=bcwz.text+wjm.text+(i as string)+"." + geshi.selected 	  
		  
		  a=render Camera:cam fromframe:rolBaseConfig.st.value toframe:rolBaseConfig.End.value\
	outputwidth:rolBaseConfig.spn2.value outputheight:rolBaseConfig.spn3.value outputfile:n 
	  	 	  close a 		 	 )
	
			for i = 1 to 1 do 
		
			( 
		               b=tarRotateParent
		               cam=tarRenderCamera
					 rotate b (angleaxis 180 [0,0,1])
			  n=bcwz.text+wjm.text+(i as string)+"." + geshi.selected
		
			  a=render Camera:cam fromframe:rolBaseConfig.st.value toframe:rolBaseConfig.End.value\
		outputwidth:rolBaseConfig.spn2.value outputheight:rolBaseConfig.spn3.value outputfile:n
		
			  	
		
			  close a 		
		
			 )
				for i = 0 to 0 do
	(
	b=tarRotateParent
	rotate b (angleaxis 180 [0,0,1])
	)
		)
	on btn17 pressed do
	(
		
		for i = 0 to 0 do  	
		
		( 
	               b=tarRotateParent
	               cam=tarRenderCamera
				 rotate b (angleaxis 0 [0,0,1])
		  n=bcwz.text+wjm.text+(i as string)+"." + geshi.selected 	  
		  
		  a=render Camera:cam fromframe:rolBaseConfig.st.value toframe:rolBaseConfig.End.value\
	outputwidth:rolBaseConfig.spn2.value outputheight:rolBaseConfig.spn3.value outputfile:n 
	  	 	  close a 		 	 )
	
			for i = 1 to 4 do 
		
			( 
		               b=tarRotateParent
		               cam=tarRenderCamera
					 rotate b (angleaxis 45 [0,0,1])
			  n=bcwz.text+wjm.text+(i as string)+"." + geshi.selected
		
			  a=render Camera:cam fromframe:rolBaseConfig.st.value toframe:rolBaseConfig.End.value\
		outputwidth:rolBaseConfig.spn2.value outputheight:rolBaseConfig.spn3.value outputfile:n
		
			  	
		
			  close a 		
		
			 )
			for i = 1 to 5 do
	(
	b=tarRotateParent
	rotate b (angleaxis 180 [0,0,1])
	)
		)
	on btn15 pressed do
	(
		for i = 0 to 0 do  	
		
		( 
	               b=tarRotateParent
	               cam=tarRenderCamera
				 rotate b (angleaxis 0 [0,0,1])
		  n=bcwz.text+wjm.text+(i as string)+"." + geshi.selected 	  
		  
		  a=render Camera:cam fromframe:rolBaseConfig.st.value toframe:rolBaseConfig.End.value\
	outputwidth:rolBaseConfig.spn2.value outputheight:rolBaseConfig.spn3.value outputfile:n 
	  	 	  close a 		 	 )
	)
	on spn75 changed val do
		spn75.value = val
	on spn76 changed val do
		spn76.value = val
	on btn68 pressed do
	(
			for i = 0 to 0 do  	
		
		( 
	               b=tarRotateParent
	               cam=tarRenderCamera
				 rotate b (angleaxis 0 [0,0,1])
		  n=bcwz.text+wjm.text+(i as string)+"." + geshi.selected 	  
		  
		  a=render Camera:cam fromframe:rolBaseConfig.st.value toframe:rolBaseConfig.End.value\
	outputwidth:rolBaseConfig.spn2.value outputheight:rolBaseConfig.spn3.value outputfile:n 
	  	 	  close a 		 	 )
		for i = 1 to (spn75.value-1) do 
	
		( 
	               b=tarRotateParent
	               cam=tarRenderCamera
				 rotate b (angleaxis (spn76.value) [0,0,1])
		  n=bcwz.text+wjm.text+(i as string)+"." + geshi.selected
	
		  a=render Camera:cam fromframe:rolBaseConfig.st.value toframe:rolBaseConfig.End.value\
	outputwidth:rolBaseConfig.spn2.value outputheight:rolBaseConfig.spn3.value outputfile:n
		  close a 		
	
		 )
	for i = 0 to (spn75.value-1) do
	(
	b=tarRotateParent
	rotate b (angleaxis 180 [0,0,1])
	)
	)
)

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
rollout MultipleRender "多个文件渲染" width:220 height:357
(
	GroupBox grp103 "输出设置" pos:[8,8] width:205 height:45
	label lbl178 "前缀" pos:[22,29] width:50 height:17
	edittext etDir "" pos:[50,28] width:70 height:14
	label lbl179 "格式" pos:[130,29] width:50 height:17
	dropdownList geshi01 "" pos:[160,25] width:43 height:22 items:#("png", "tga", "jpg", "avi", "bmp", "tif")
	
	GroupBox grp102 "方向角度设置" pos:[8,60] width:205 height:73
	label lbl76 "方向数量" pos:[22,80] width:56 height:19
	spinner spn75 "" pos:[84,80] width:56 height:16 range:[1,360,5] type:#integer
	label lbl77 "旋转角度" pos:[22,105] width:56 height:19
	spinner spn76 "" pos:[84,105] width:56 height:16 range:[-360,360,45] type:#integer
	button btAll "渲染" pos:[149,83] width:56 height:33
	
	function RenderObj path ActionName prefix=
(
	--打开文件


	bOK = true
	if doesFileExist (path+ActionName+".max") != true then return false
	if doesFileExist (path+ActionName) != true then
	(
		--路径不存在,建立路径
		bOK = makeDir (path+ActionName)
		if bOK == false then
		(
			--messageBox "路径["+path+ActionName+"]无法创建"
			return false
		)
	)
	--resetMaxFile(#noPrompt)
	bOK = loadMaxFile (path+ActionName+".max")
	if bOK == false then
	(
		messageBox "无法打开文件["+path+ActionName+"]"
		return false
	)
	dir = #("0","1","2","3","4","5","6","7")
	setProperty autobackup "enabled" false																												
	for d = 1 to (spn75.value) do
	(
																	
		outfilename = (path+ActionName+"\\"+prefix+dir[d]+"." + geshi01.selected)
		render outputfile:outfilename camera:tarRenderCamera fromframe:rendStart toframe:rendEnd nthframe:rendNThFrame outputwidth:renderwidth outputheight:renderheight renderer:#production
		--变换镜头
		animate off
		(															
			rotate tarRotateParent (angleaxis (spn76.value) [0,0,1])
		)															
	)	
		setProperty autobackup "enabled" true	
																												
		--按照8方向进行渲染
			
)	
	on btAll pressed do
	(
	path = getsavepath()
	if path == undefined then
	(
		--messageBox "操作取消"
	)
	else
	(		
		--path = getFilenamePath objname
		--etDir.text = path
		--dirs = getDirectories (etDir.text+"\\*.*")
		dirs = getDirectories (path +"*.*")
		for d in dirs do
		(
			files = getFiles (d+"*.max")
			for f in files do
			(
				name = getFilenameFile f
				RenderObj d name etDir.text
			)
		)
																																		messageBox "渲染完成"
	)	
																	
	)
	)
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
rollout otherTools "其他工具" width:220 height:357
(
	GroupBox grp40 "整理丢失贴图" pos:[8,53] width:205 height:48
	button btn110 "整理贴图" pos:[20,75] width:180 height:20
	
	GroupBox grp35 "清理BIP复制信息" pos:[8,224] width:205 height:48
	button btn109 "确定清理" pos:[20,243] width:180 height:20
	
	button btn19 "路径" pos:[16,130] width:40 height:20
	button btn20 "导出" pos:[160,130] width:40 height:21
	 
	edittext lbl6 "" pos:[64,130] width:88 height:20
	GroupBox grp24 "贴图文件导出" pos:[8,112] width:205 height:48
	GroupBox grp37 "材质球工具" pos:[8,168] width:205 height:48
	button hit10 "整理/ 翻到1页" pos:[16,184] width:96 height:24 toolTip:"材质编辑器整理，翻页"
	GroupBox grp85 "标准灯光摄像机系统" pos:[8,8] width:205 height:45
	button btn217 "一键创建" pos:[20,25] width:180 height:20
	button btn22 "双面所有材质球" pos:[120,184] width:88 height:24 toolTip:"打开材质球里的双面显示"
	local mapfiles=#()
	local k
	local savefilepath = ""
	local path = ""

	
	global savefilepath= ""
global mapfiles=#()
fn addmap mapfile =
(
    local mapfileN=mapfile as name
    local index=finditem mapfiles mapfileN
    if index == 0 do append mapfiles mapfileN
)

fn copybitmap old_files new_patch =
(
    for f in old_files do 
    (
        filename = filenameFromPath f
        newfile = (new_patch + "\\" + filename)
        copyFile f newfile 
    )
)

	
	
	on btn109 pressed do
	(
	   if (classof $ == Biped_Object) then
				(
					biped.deleteAllCopyCollections $.controller	
				)
				else
				(
					Messagebox "请先选择一个Bip骨骼"
	 				)
	 )
	on btn19 pressed do
	(    
	         local path = ""
	         path = getSavePath caption:"选择保存文件路径:"  initialDir:savefilepath 
	         if path != undefined then 
	            try(
	                lbl6.text = path;
	                savefilepath = path;
	                )catch()    
	)
	on btn20 pressed do
	(
	    enumeratefiles addmap
	    sort mapfiles
	    copybitmap mapfiles savefilepath
	)
	on hit10 pressed do
	(
		disableSceneRedraw()
		if scenematerials.count>0 and geometry.count>0 do
		(
			s = scenematerials.count
			x=int(s/24)
			y=mod s 24 
			if k== undefined then k=1
			if k > x+2 do k=1
			if y>0 and k == x+1 then
			(
				for j=1 to 24 do
				(
					new_mat_name = (j+24*(k-1)) as string + " - Default"
					meditMaterials[j] = standard name:new_mat_name
				)
				for i = 1 to y do
				(
					meditMaterials[i] = sceneMaterials[i+24*(k-1)]
				)
				
			)else
			(
				for j=1 to 24 do
				(
					meditMaterials[j]=sceneMaterials[j+24*(k-1)]
				)
			)
			k=k+1
			pushPrompt ("第 "as string+k as string+" 批材质成功运行!! "as string +s as string+"个场景材质。")
			if k==x+1 and y==0 do k=1
			if k==x+2 and y>0 do k=1
			hit10.caption = "整理/ 翻到第" + k as string + "页"
		)
		if scenematerials.count==0 do (pushPrompt ("本场景没有任何材质"))
		enableSceneRedraw()
	)
	on btn217 pressed do
	(
			Dummy pos:[0,0,0] name:"Dummy001"
			Targetcamera orthoProjection:on transform:(matrix3 [1,0,0] [0,0,1] [0,-1,0] [-823.7417,-827.2067,673.8179]) target:(Targetobject name:"Camera001目标" transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0] )) name:"Camera001"
			Skylight pos:[100,100,0] name:"标准天光"
			$标准天光.multiplier = 0.7
			TargetDirectionallight name:"标准主光" pos:[0,-5000,4000] target:(Targetobject name:"标准主光目标点" pos:[0,0,0]) isselection:on
			max modify mode
			$标准主光.color=white
			$标准主光.baseobject.castshadows=on
			$标准主光.shadowgenerator=raytraceshadow()
			$标准主光.shadowgenerator=Area_Shadows()
			$标准主光.hotspot=1000
			$标准主光.falloff=1002
			$标准主光.overshoot=on
			select #($Camera001, $Camera001目标, $标准天光, $标准主光目标点, $标准主光)
			$.parent = $Dummy001
			clearSelection()
			max vpt camera
		)
	on btn22 pressed do
	(
		for i in sceneMaterials do 
		try (i.twoSided = on) catch()
	)
	on btn110 pressed do
	()
)
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
addrollout rolBaseConfig CGfine_tools
addrollout AutoRender CGfine_tools
addrollout MultipleRender CGfine_tools
addrollout OtherTools CGfine_tools