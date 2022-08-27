/*
   FRACTURE VORONOI - v1.1 - april 2009 - 3ds max 9     
                                                        
   Divides an object in parts (Voronoi cells).          
   - several iterations;                                
   - original UVs are preserved and 'projected' onto    
   the new faces;                                       
   - simple planar mapping is applied to a new channel  
   and consistent throughout the new parts;             
   - new material ID is applied to the new faces;       
   - can keep intermediate generations;                 
   - can build hierarchy.                               
                                                        
   GARP - 2009                                          

*/
global rltFractureVoronoi
try destroyDialog rltFractureVoronoi catch()

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
global rltFractureVoronoi
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
		while (fn_check_create rltFractureVoronoi)==0 do 
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

-----------------------------------------------------------------------------------------------------------------------------

(	-- start script

global rltFractureVoronoi
try destroyDialog rltFractureVoronoi catch()

rollout rltFractureVoronoi "破碎工具_F.R.A.C.T.U.R.E_v1.11"
(
	GroupBox boxSetUp "" pos:[5,0] width:116 height:83
	fn geometryFilter obj = superClassOf obj == GeometryClass
	pickbutton pbObject "拾取物体" pos:[10,11] width:106 height:25 filter:geometryFilter toolTip:"拾取一个需要切割的物体"
--	pickButton pbObject "拾取物体" pos:[10,11] width:106 height:25 filter:geometryFilter tooltip:"拾取一个需要切割的物体"

	spinner spnNbParts "切割数量:" pos:[38,41] width:80 height:16 enabled:false range:[2,1000,10] type:#integer
	spinner spnNbIter "细分级别:" pos:[38,61] width:80 height:16 enabled:false range:[1,10,1] type:#integer
	GroupBox boxMat "" pos:[5,80] width:116 height:89
	spinner spnNewID "新材质ID:" pos:[38,92] width:80 height:16 enabled:false range:[1,100,1] type:#integer indeterminate:true
	checkbox cbKeepMat "保留材质" pos:[12,109] width:89 height:15 enabled:false checked:true
	spinner spnNewCh "新贴图通道:" pos:[48,132] width:70 height:16 enabled:false range:[1,10,3] type:#integer
	checkbox cbRWMS "R-W Map Size" pos:[12,149] width:93 height:15 enabled:false checked:true
	GroupBox boxHierarchy "" pos:[5,166] width:116 height:55
	checkbox cbKeepGen "保持细分级别" pos:[12,178] width:106 height:15 enabled:false checked:false
	checkbox cbLinkGen "建立链接" pos:[12,198] width:95 height:15 enabled:false checked:false
	GroupBox boxCreate "" pos:[126,0] width:116 height:170
	button btnCreate "切割成10个" pos:[132,11] width:106 height:25 enabled:false toolTip:"点按钮,开始按设置参数进行切割"
	checkbox chk_DelSouceObj "删除原物体" pos:[135,38] width:102 height:18 enabled:false checked:false 
	radiobuttons rdoColor "" pos:[133,55] width:79 height:32 enabled:false labels:#("随机色  ", "指定色  ") default:1 columns:1
	colorPicker cpParts "" pos:[204,74] width:24 height:12 fieldWidth:20 visible:false
	radiobuttons rdoCenter "" pos:[133,87] width:107 height:32 enabled:false labels:#("边界盒质心  ", "体积为质心  ") default:1 columns:1
	checkbox chk_CapHoles "自动补面" pos:[133,119] width:76 height:18 enabled:false checked:true
	progressBar pbProgress "" pos:[131,138] width:106 height:13 value:0 color:[0,96,0]
	label lblProStatus "" pos:[131,153] width:100 height:14
	GroupBox grp31 "" pos:[126,166] width:116 height:55
	checkbox chk_BonOn "BoneOn" pos:[131,176] width:58 height:18 checked:true
	checkbox chk_FullFrame "满帧" pos:[193,176] width:45 height:18 enabled:true checked:false
	button myBroken "破碎烘焙" pos:[131,195] width:106 height:20 toolTip:"将破碎的物体拼接成单一物体,并绑定骨骼赋予动作"

	GroupBox BoneCreate "碎块加骨_Author:San_oOo_||_Mod:Bullet.S" pos:[5,225] width:237 height:150
	checkbutton ckb_preview "先点击预览 Skin Pose" pos:[10,248] width:145 height:40 toolTip:"选择物体并点击此按钮"
	button bt_help "?" pos:[220,248] width:16 height:40 toolTip:"帮助"
	edittext txt_name "命名前缀:" pos:[10,295] width:140 height:16
	spinner spn_offset "距离:" pos:[170,295] width:65 height:16 range:[1,1e+006,0] type:#float
	button bt_check_intersect "检查穿插" pos:[155,248] width:65 height:20 toolTip:"移动物体位置后，请点击检查交错"
	button bt_back_to_original "原始位置" pos:[155,268] width:65 height:20 toolTip:"重置 pose (到原始 Pose)"
	
	checkbox ch_delete_original "删除原始碎块" pos:[10,320] width:128 height:16
	checkbox ch_skin_original "跟原始碎块一致的 Skin pose" pos:[10,336] width:152 height:16
	checkbox ch_skin_frame "创建 Skin pose 帧" pos:[30,352] width:136 height:16
	button bt_create "创建" pos:[165,322] width:70 height:45

	local theObject			-- holds the original object
	
	on rltFractureVoronoi open do
	(
		txt_name.text = "Fracture"
		spn_offset.value = 30
		ch_delete_original. checked=true
-- 			ch_skin_frame. checked=true
		
		fn_anibon_off rltFractureVoronoi
	)

	on rltFractureVoronoi close do
	(
		enableSceneRedraw()
		CompleteRedraw()
		callbacks.removeScripts id:#FVcbID01
		if ckb_preview.checked==true do 
		(
			fn_delete_copymeshes ()
		)
	)
	on pbObject picked obj do
	(
		pbObject.text = obj.name
		theObject = obj
		spnNbParts.enabled = true
		spnNbIter.enabled = true
		spnNewID.enabled = true
		cbKeepMat.enabled = true
		spnNewCh.enabled = true
		cbRWMS.enabled = true
		cbLinkGen.enabled = true
		btnCreate.enabled = true
		btnCreate.tooltip = "start creating parts"
		rdoColor.enabled = true
		rdoCenter.enabled = true
		chk_CapHoles.enabled = true
		cpParts.color = obj.wireColor
		cpParts.visible = true
		chk_DelSouceObj.enabled = true

		when obj deleted do
		(
			btnCreate.enabled = false
			btnCreate.tooltip = pbObject.text + " has been deleted!"
			pbObject.text = "Pick Object"
		)
		
		undo off
		(	-- gets new mat ID for new faces
			m = edit_mesh()
			addModifier obj m
			spnNewID.value = amax(for i = 1 to obj.numfaces collect getFaceMatID obj i) + 1
			deleteModifier obj m
		)
	
	)	-- end on btnMesh picked theMesh
	on spnNbParts changed val do
	(
		btnCreate.caption = "切割成" + ((val ^ spnNbIter.value) as string) + "个"
	)
	on spnNbIter changed val do
	(
		btnCreate.caption = "切割成" + ((spnNbParts.value ^ val) as string) + "个"
		cbKeepGen.enabled = val != 1
	)
	on btnCreate pressed do
	(
		undo on
		(
			disableSceneRedraw()
			clearSelection()
			start = timeStamp()
			
			local nbParts = spnNbParts.value
			local nbIter = spnNbIter.value
			local keepGen = cbKeepGen.checked
			local linkGen = cbLinkGen.checked
			local aPartsStart = #()
			local aPartsEnd = #()
			local aAllParts = #()
			local aAllCoords = #()
			local thePlane = plane width:1 length:1 widthSegs:1 lengthSegs:1	-- plane helper for slice plane
			local theMesh = editable_mesh()
			local abortBreaking = false
			
			lblProStatus.caption = " Breaking..."
			
			--	BREAKING UP
			---------------

			-- clean copy (no custom attributes, keyframes, weird transforms, etc
			theCopy = copy theObject
			theCopy.name = "toto"
			resetXForm theCopy
			convertToMesh theCopy
			theMesh.mesh = theCopy.mesh
			theMesh.transform = theCopy.transform
			theMesh.pivot = [0,0,0]
			resetXForm theMesh
			convertToMesh theMesh
			delete theCopy
			
			-- material and UVs
			if cbKeepMat.checked do theMesh.material = theObject.material
			addModifier theMesh (uvwMap mapChannel:spnNewCh.value realWorldMapSize:cbRWMS.checked)
			convertToMesh theMesh
			setFaceSelection theMesh #{}
			
			-- parts creation
			aPartsEnd = #(theMesh)
			for iter = 1 to nbIter while not abortBreaking do
			(
				aPartsStart = aPartsEnd
				aPartsEnd = #()
				
				for obj in aPartsStart while not abortBreaking do
				(	
					aPartsTemp = for i = 1 to nbParts collect copy obj
					pSys = pcloud emitter:obj formation:3 total_number:nbParts quantityMethod:1 viewPercent:100 seed:(random 0 100)
					aCoords = for i = 1 to nbParts collect particlePos pSys i	-- fill with random coordinates
					delete pSys
					for i = 1 to nbParts - 1 do for j = i + 1 to nbParts while not abortBreaking do	-- for each pair of coords
					(
						thePlane.pos = (aCoords[i] + aCoords[j]) / 2
						thePlane.dir = aCoords[j] - aCoords[i]
						
						addModifier aPartsTemp[i] (sliceModifier slice_type:2)
						addModifier aPartsTemp[j] (sliceModifier slice_type:3)
						aPartsTemp[i].slice.slice_plane.transform = thePlane.transform
						aPartsTemp[j].slice.slice_plane.transform = thePlane.transform
						if chk_CapHoles.checked do addModifier aPartsTemp[i] (cap_holes())
						if chk_CapHoles.checked do addModifier aPartsTemp[j] (cap_holes())
						convertToMesh aPartsTemp[i]
						convertToMesh aPartsTemp[j]
						
						if keyboard.escPressed do abortBreaking = queryBox "Do you want to abort and delete already created parts?"
					)	-- end i loop
					aPartsEnd += aPartsTemp
					aAllParts += aPartsTemp
					aAllCoords += aCoords
					
					total = nbParts * ((nbParts^nbIter - 1) / (nbParts - 1))
					prog = 100 * aAllParts.count / total
					pbProgress.value = prog
					pbProgress.color = [200 - prog * 2,prog * 2,0]
				)	-- end obj loop
			)	-- end iter loop
			
			if not abortBreaking then
			(
				lblProStatus.caption = " Finalizing..."
				
				-- 	TIDYING UP
				--------------
				
				delete theMesh
				delete thePlane
				--hide theObject

				-- intermediate generations
				if not keepGen and nbIter != 1 do
				(
					ind = 0
					for i = 1 to nbIter - 1 do for j = 1 to nbParts^i do
					(
					ind += 1
					delete aAllParts[ind]
					aAllCoords[ind] = undefined
					)
					aAllParts = for obj in aAllParts where not isDeleted obj collect obj
					aAllCoords = for c in aAllCoords where c != undefined collect c
				)
				
				-- coordinates
				if rdoCenter.state == 1 then centerPivot aAllParts
				else for i = 1 to aAllParts.count do aAllParts[i].pivot = aAllCoords[i]
				resetXForm aAllParts
				convertToMesh aAllParts
				
	
				
				-- new faces ID
				newID = spnNewID.value
				for obj in aAllParts do
				(
					for f in getFaceSelection obj do setFaceMatID obj f newID
					setFaceSelection obj #{}
				)
				
				-- names
				if not keepGen or nbIter == 1 then
					for i = 1 to aAllParts.count do aAllParts[i].name = theObject.name + "_Part_" + i as string
				else
				(
					for i = 1 to nbParts do aAllParts[i].name = theObject.name + "_Part_" + i as string
					indP = 0
					indC = nbParts
					for i = 1 to nbIter - 1 do for j = 1 to nbParts^i do
					(
						indP += 1
						for k = 1 to nbParts do
						(
							indC += 1
							aAllParts[indC].name = aAllParts[indP].name + "_" + k as string
						)	-- end k loop
					)	-- end j loop
				)	-- end else
				
				-- layers
				-- (comment out this block if you don't want any layer, intermediate generations will not be hidden)
				-- (FROM HERE...)
				if not keepGen or nbIter == 1 then
				(
					if layerManager.getLayerFromName (theObject.name + "_Parts") == undefined then
						theLayer = layerManager.newLayerFromName (theObject.name + "_Parts")
					else theLayer = layerManager.getLayerFromName (theObject.name + "_Parts")
					for obj in aAllParts do theLayer.addNode obj
				)	-- end if
				else
				(
					aTheLayers = for i = 1 to nbIter collect
					(
						if layerManager.getLayerFromName (theObject.name + "_Gen_" + i as string) == undefined then
							layerManager.newLayerFromName (theObject.name + "_Gen_" + i as string)
						else layerManager.getLayerFromName (theObject.name + "_Gen_" + i as string)
					)
					for i = 1 to nbIter - 1 do aTheLayers[i].isHidden = true
					ind = 0
					for i = 1 to nbIter do for j = 1 to nbParts^i do
					(
						ind += 1
						aTheLayers[i].addNode aAllParts[ind]
					)	-- end i loop
				)	-- end else
				-- (...TO HERE)
	
				-- hierarchy
				if linkGen do
				(
					if not KeepGen or nbIter == 1 then for obj in aAllParts do attachObjects theObject obj move:false
					else
					(
						for i = 1 to nbParts do attachObjects theObject aAllParts[i] move:false
						indP = 0
						indC = nbParts
						for i = 1 to nbIter - 1 do for j = 1 to nbParts^i do
						(
							indP += 1
							for k = 1 to nbParts do
							(
								indC += 1
								attachObjects aAllParts[indP] aAllParts[indC] move:false
							)	-- end k loop
						)	-- end j loop
					)	-- end else
				)	-- end if linkGen
				
				-- colors
				if rdoColor.state == 1 then for obj in aAllParts do obj.wireColor = random black white
				else aAllParts.wireColor = cpParts.color
				convertTo aAllParts Editable_Poly				
				lblProStatus.caption = " Done in " + (formattedPrint ((timeStamp() - start) / 1000.0) format:".1f") + "sec."
				enableSceneRedraw()
				completeRedraw()
			)
			else
			(
				delete thePlane
				delete theMesh
				delete aAllParts
				pbProgress.value = 0
				lblProStatus.caption = " Stopped"
				enableSceneRedraw()
			)	-- end test abortBreaking
			--20170307 添加是否删除原物体的功能
			if chk_DelSouceObj.checked then delete theObject
				else hide theObject
		)	-- end undo off
		
	)	-- end btnCreate pressed
	on myBroken pressed do
	(
	undo on
		(
		disableSceneRedraw()
		try
			(	
			Global perSel = #() 
			selObj = selection as array
			SelectionSets["烘焙碎片"] = selObj
			macros.run "Modifier Stack" "Convert_to_Poly"	
	
			
			for i = 1 to selObj.count do
				(
				--20170306 添加计算物体的质心修改功能 不能直接改质心 会破坏动画 创建一个临时物体链接到原物体 暂停
	
					
				newBone = BoneSys.createBone [10,0,0] [0,0,0] [0,0,1]	
				newBone.transform = selObj[i].transform
					
				newBone.name =uniquename "D_bone"
				if chk_BonOn.checked then --判断是否BoneOn
					(
					newBone.boneEnable = true
					newBone.boneScaleType = #none
					)
					else newBone.boneEnable = false
				append perSel newBone
				
	
				if chk_FullFrame.checked then --检测满帧选项是否打开
					(
					sliderTime = animationRange.start
					for t = animationRange.start to animationRange.end do --满帧状态
						(
						 set animate on
						 at time t
						 newBone.transform = selObj[i].transform
						 set animate off
						)
					)
					else
					(
					Key_Pos = selObj[i].pos.controller.keys
					Key_Rotation = selObj[i].rotation.controller.keys
					Key_Scale = selObj[i].scale.controller.keys
						
					newBone.rotation.controller = tcb_rotation()
					sliderTime = animationRange.start
					newBone.rotation = selObj[i].rotation
					newBone.pos = selObj[i].pos
					newBone.scale = selObj[i].scale
						
					if Key_Rotation[1]!= undefined do 
						if Key_Rotation[1].time != animationRange.start do addNewKey newBone.rotation.controller Key_Rotation[1].time
					if Key_Pos[1]!= undefined do 
						if Key_Pos[1].time != animationRange.start do addNewKey newBone.pos.controller Key_Pos[1].time
					if Key_Scale[1]!= undefined do 
						if Key_Scale[1].time != animationRange.start do addNewKey newBone.scale.controller Key_Scale[1].time
	
	
					set animate on
					for keyTime = 1 to Key_Rotation.count do
						(
						--if Key_Rotation[1].time != animationRange.start do addNewKey newBone.rotation.controller Key_Rotation[1].time
						t = Key_Rotation[keyTime].time
						at time t 
							newBone.rotation = selObj[i].rotation
							)
					for keyTime = 1 to Key_Pos.count do
						(
						t = Key_Pos[keyTime].time
						--if Key_Pos[1].time != animationRange.start do addNewKey newBone.pos.controller Key_Pos[1].time
						--if t != animationRange.start do addNewKey newBone.position.controller t
						at time t 
							newBone.position = selObj[i].position
						)
					for keyTime = 1 to Key_Scale.count do
						(
						t = Key_Scale[keyTime].time
						at time t 
							newBone.scale = selObj[i].scale
						)
					set animate off
					)				
			
				)
	
			--添加骨骼选择集
			--selectionSets["D_BoneAll"] = perSel 
			--给骨骼加上末端物体
			perSelEnd = #()
			for o in perSel do
				(
				if o.children.count == 0 do 
					(
					BoneEnd=bonesys.createbone [0,0,0] [o.width,0,0] [0,0,1]
					in coordsys o.transform 
						(
						BoneEnd.rotation = o.rotation				
						BoneEnd.pos = o.pos + [o.length,0,0]
						BoneEnd.parent = o
						)
					append perSelEnd BoneEnd
					)
				)
			selectionSets["D_BoneEnd"] =perSelEnd
			hide perSelEnd
	
			--开始拼合模型	
			select selObj
			AttachObj = copy selObj[1]
	
			AttachObj.name = "AttachObj"
			AttachObj.pivot = selection.center
			convertTo AttachObj (Editable_Poly)
			AttachFaceID = #()
			append AttachFaceID #{1..AttachObj.Verts.count}		
			for i = 2 to selObj.count do 
				(
				TempObj = copy selObj[i]
				polyOp.attach AttachObj TempObj
				append AttachFaceID #{AttachFaceID[i-1].count+1..AttachObj.Verts.count}
				)
			--清理模型 包括关键帧 选中的面等等
			deletekeys AttachObj
			AttachObj.EditablePoly.SetSelection #Vertex #{}
			AttachObj.EditablePoly.SetSelection #Edge #{}
			AttachObj.EditablePoly.SetSelection #Face #{}
				
			--添加Skin修改器
			select AttachObj
			addModifier AttachObj (Skin ())
			for i = 1 to perSel.count do 
				(
				--print ("i = "+ i as string)
				skinops.addbone AttachObj.modifiers[#Skin] perSel[i] 1
				skinOps.SelectBone AttachObj.modifiers[#Skin] i
				skinOps.SelectVertices AttachObj.modifiers[#Skin] AttachFaceID[i]
		
				skinOps.setWeight AttachObj.modifiers[#Skin] 1
				)
			skinOps.RemoveZeroWeights AttachObj.modifiers[#Skin]
			--Skin修改器结束
			$bone*.wirecolor = color 214 228 153
			myPoint = Point pos:[0,0,0]
			myPoint.size = 200
			baseBone = BoneSys.createBone [10,0,0] [0,0,0] [0,0,1]
			baseBone.transform = myPoint.transform
			baseBone.wirecolor = red
			if chk_BonOn.checked then 
				(
				baseBone.boneEnable = true
				baseBone.boneScaleType = #none
				)
				else baseBone.boneEnable = false
			if $bone_root == undefined then baseBone.name = "bone_root"
				else baseBone.name = uniquename "bone_root"
			
			for i in perSel do
				(
				i.parent = baseBone
				)
			--添加包括根节点的骨骼选择集
			selectionSets["D_BoneAll"] = perSel + #(baseBone)
			select myPoint
			max delete
			hide selObj
			select AttachObj
			)
			catch
			(
			messagebox("请选中需要加骨骼的物体                ")
			) 
		enableSceneRedraw()
		redrawViews()
		)
	)-- end myBroken pressed

	on bt_help pressed  do 
		(
-- 			rltFractureVoronoi.ckb_preview.changed (rltFractureVoronoi.ckb_preview.checked = true)
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
					chk_BonOn.enabled = not ckb_preview.state
					chk_FullFrame.enabled = not ckb_preview.state
					myBroken.enabled = not ckb_preview.state
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
							fn_anibon_on rltFractureVoronoi
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
							
							fn_step_calc rltFractureVoronoi
							fn_move_copymeshes rltFractureVoronoi
							if (fn_check_create rltFractureVoronoi)==0 then 
								(
									while (fn_check_create rltFractureVoronoi)==0 do 
										(
											spn_offset.value+=1
											fn_move_copymeshes rltFractureVoronoi
											)
									) else 
									(
										if selec.count!=1 do 
											(
												while (fn_check_create rltFractureVoronoi)==1 do 
													(
														spn_offset.value-=1
														fn_move_copymeshes rltFractureVoronoi
														)
												spn_offset.value+=1
												fn_move_copymeshes rltFractureVoronoi
												fn_check_create rltFractureVoronoi	
												)
										)
							
							) else 
							(
								messagebox "请选择物体!               "
								ckb_preview.checked=false
								chk_BonOn.enabled = not ckb_preview.state
								chk_FullFrame.enabled = not ckb_preview.state
								myBroken.enabled = not ckb_preview.state
							)
					) else 
					(
						if querybox "所有 transform 变换将会丢失，继续？                             " title:"Anim meshes to bones" == true then 
						(
							fn_delete_copymeshes ()
							fn_anibon_off rltFractureVoronoi
							chk_BonOn.enabled = not ckb_preview.state
							chk_FullFrame.enabled = not ckb_preview.state
							myBroken.enabled = not ckb_preview.state
						) 
						else 
						(
							ckb_preview. checked=true
							chk_BonOn.enabled = not ckb_preview.state
							chk_FullFrame.enabled = not ckb_preview.state
							myBroken.enabled = not ckb_preview.state
						)
					)
			)
			
	on spn_offset changed val do 
		(
			fn_move_copymeshes rltFractureVoronoi
-- 			fn_check_create rltFractureVoronoi
			fn_collision_mover ()
			redrawViews ()
			)
			
	on bt_back_to_original pressed do with undo on
		(
			fn_back_to_original ()
			fn_check_create rltFractureVoronoi
			)
			
	on bt_check_intersect pressed do 
		(
-- 			fn_check_create rltFractureVoronoi
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
			if (fn_check_create rltFractureVoronoi)==0 then 
				(
					messagebox "模型有交错!\n点击“检查穿插”, 如果你手动移动过物体"
					) else 
					(
						if (querybox "这个操作无法回退，建议先另存！！！继续？                       " title:"Anim meshes to bones") ==true do 
							(
								try 
									(
										---------reset script
										ckb_preview.checked=false
										fn_anibon_off rltFractureVoronoi
										
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
														messagebox ("Skin pose 保存在第 "+(((anibon_skinpose_time as integer)/TicksPerFrame) as string)+" 帧                       ") beep: false
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





createDialog rltFractureVoronoi 250 380 60 130 style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)
--createDialog rltFractureVoronoi 250 220 60 130

)	-- end scrip