/*
 * @Description: Demo专用工具集
 * @Author: Bullet.S
 * @Date: 2024-04-03 10:58:49
 * @LastEditors: Bullet.S
 * @LastEditTime: 2025-01-15 18:12:33
 * @Email: animator.bullet@foxmail.com
 */
--E8C18FB749BA820E0525422425AFBED057AD5AEB7FE98E2F17C688B869B454

try(destroyDialog rolBsAnimDemoTools )catch()

global rolBsAnimDemoTools
global offsetBsADT = [0,0]
global dragStateBsADT = off

(
	local LastSubRollout = 1
	
	rollout rolBsAnimDemoTools "" width:265 height:300
	(
		local selGhostTex     = undefined
		local selEffTex       = undefined
		local selTex          = undefined
		local arrEffTexFiles  = #()
		local arrFlowTexFiles = #()
		local dotColor        = dotnetclass "System.Drawing.Color"
		button btnRegister "免费注册刀光" pos:[rolBsAnimDemoTools.width - 120,0] width:80 height:16 border:false
		button btnAbout "?" pos:[rolBsAnimDemoTools.width - 40,0] height:16 width:20
		button btnClose "X" pos:[rolBsAnimDemoTools.width - 20,0] height:16 width:20
		label lblTitle "BsAnimDemo_v1.0" pos:[5,3]
		dotNetControl tabBsADT "System.Windows.Forms.TabControl" height:30 width:rolBsAnimDemoTools.width pos:[0,20] align:#center
		------------------------------------------------------------------------------------------------------------------------------
		groupbox gpbTrail "" pos:[5,50] width:(rolBsAnimDemoTools.width - 10) height:70
		spinner spnRadian "弧度 " pos:[30,65] width:60 height:20 type:#float range:[-20,20,0] scale:0.1
		checkbutton chkCreateLine "1.创建线" pos:[100,65] width:75 height:20 checked:true
		checkbutton chkCreateTrail "2.创建刀光" pos:[180,65] width:75 height:20 checked:true
		button btnSelectTrail "选中" pos:[10,90] width:40 height:24
		button btnUnfreezeTrail "解冻" pos:[55,90] width:40 height:24
		button btnFreezeTrail "冻结" pos:[100,90] width:40 height:24
		button btnHideTrail "隐藏" pos:[145,90] width:35 height:24
		button btnShowTrail "显示" pos:[185,90] width:35 height:24
		button btnDeleteTrail "清除" pos:[225,90] width:30 height:24
		-------------------------------------------------------------------------------------------------------------------------------------
		groupbox gpbPreset "" pos:[5,120] width:(rolBsAnimDemoTools.width - 10) height:65
		radiobuttons rdoTrailType "类型:" labels:#("移动","固定") columns:2 pos:[15,135] offsets:#([40,-16],[0,-16])
		spinner spnFrameToLag "帧延迟" pos:[185,136] width:65 height:20 type:#integer range:[0,1000,3]
		checkbox ckbSetRange "指定帧范围" pos:[15,158] width:80 height:20 checked:false enabled:false
		spinner spnStartFrame "起始" pos:[120,160] width:55 height:20 type:#integer range:[0,999999,animationrange.start] enabled:false
		spinner spnEndFrame "结束" pos:[195,160] width:55 height:20 type:#integer range:[0,999999,animationrange.end] enabled:false
		----------------------------------------------------------------------------------------------------------------------------------------
		groupbox gpbMesh "" pos:[5,185] width:(rolBsAnimDemoTools.width - 10) height:65
		spinner spnSegments "每帧段数" pos:[40,200] width:90 height:20 type:#float range:[0.0001,1000,10.0]
		spinner spnSplineSteps "线 段数" pos:[175,200] width:75 height:20 type:#integer range:[0,1000,6]
		spinner spnURepeat "U 重复" pos:[40,224] width:55 height:20 type:#float range:[0.0001,1000,1.0]
		checkbox ckbFlipNormals "翻转法线" pos:[110,223] width:70 height:20 checked:false
		checkbox ckbGenerateMapping "生成映射" pos:[185,223] width:70 height:20 checked:true
		-----------------------------------------------------------------------------------------------------------------------------------------
		button btnMaterial "材质窗口" pos:[5,255] width:65 height:20
		dropdownlist ddlDefaultTex "" pos:[75,255] width:105 height:20 items:#("")
		button btnApplyTex "指定刀光" pos:[185,255] width:75 height:21 tooltip:"左键赋予刀光贴图，右键重新指定"
		-------------------------------------------------------------------------------------------------------------------------------------------
		dotNetControl dotLVFilesList "system.windows.forms.listView" selection:0 height:185 width:(rolBsAnimDemoTools.width - 10) pos:[5,-500]
		spinner spnU "横" pos:[10,240] width:50 height:20 range:[-99999,99999,4] type:#integer align:#left visible:false
		spinner spnV "纵" pos:[10,260] width:50 height:20 range:[-99999,99999,4] type:#integer align:#left visible:false
		label lblFrameOffset "↓ 隔帧 ↓" pos:[75,240] width:50 height:20 visible:false
		spinner spnFrameOffest "" pos:[75,260] width:40 height:20 range:[-99999,99999,0] type:#integer align:#left visible:false
		button btnOpenPath "仓库" pos:[125,240] width:40 height:40 visible:false
		checkbutton ckbLoopToogle "循环开关" pos:[170,240] width:90 height:20 visible:false
		checkbutton ckbApplyEff "应用图集特效" pos:[170,260] width:90 height:20 visible:false checked:true
		-------序列帧工具来源 "https://www.cgjoy.com/thread-275528-1-1.html" 开发者：叶孤弦
		-------------------------------------------------------------------------------------------------------------------------------------------
		groupbox gpbSkyBox "天空盒" pos:[5,55] width:(rolBsAnimDemoTools.width - 10) height:50 visible:false
		dropdownlist ddlSkyBoxTex "" pos:[15,75] width:80 height:20 items:#("") visible:false
		button btnCreateSkyBox "创建" pos:[100,75] width:50 height:20 visible:false
		button btnDeleteSkyBox "清除" pos:[155,75] width:50 height:20 visible:false
		button btnOpenSkyBox "打开" pos:[210,75] width:40 height:20 visible:false
		groupbox gbpLight "灯光箱" pos:[5,110] width:(rolBsAnimDemoTools.width - 10) height:75 visible:false
		button btnOmniLight "点光源" pos:[15,130] width:55 height:20 visible:false
		button btnSpotLight "聚光灯" pos:[75,130] width:55 height:20 visible:false
		button btnDirectLight "平行光" pos:[135,130] width:55 height:20 visible:false
		button btnSkyLight "环境光" pos:[195,130] width:55 height:20 visible:false
		button btnSelectLastLight "选上个灯" pos:[15,155] width:55 height:20 visible:false
		button btnSelectNextLight "选下个灯" pos:[75,155] width:55 height:20 visible:false
		button btnToggleLight "灯光开关" pos:[135,155] width:55 height:20 visible:false
		button btnDeleteLight "清除灯光" pos:[195,155] width:55 height:20 visible:false
		groupbox gbpFloor "地板片" pos:[5,190] width:(rolBsAnimDemoTools.width - 10) height:50 visible:false
		button btnCreateFloor "一键创建" pos:[15,210] width:70 height:20 visible:false
		button btnFreezeFloor "冻结" pos:[90,210] width:50 height:20 visible:false
		button btnUnfreezeFloor "解冻" pos:[145,210] width:50 height:20 visible:false
		button btnDeleteFloor "清除" pos:[200,210] width:50 height:20 visible:false
		button btnMakePreview "快速拍屏" pos:[5,250] width:60 height:25 visible:false
		button btnOpenPrevPath "拍屏目录" pos:[70,250] width:60 height:25 visible:false
		button btnMakeRenderer "渲染预览" pos:[135,250] width:60 height:25 visible:false tooltip:"仅用作快速预览环境设置, \r\n不影响之前的渲染保存路径设置等"
		button btnClearAll "清除所有" pos:[200,250] width:60 height:25 visible:false
		-------------------------------------------------------------------------------------------------------------------------------------------
		dotNetControl dotFlowMatList "system.windows.forms.listView" selection:0 height:100 width:(rolBsAnimDemoTools.width - 10) pos:[5,-500]
		radiobuttons rdoMatType "" labels:#("普通","流体") columns:2 pos:[10,160] width:100 visible:false
		checkbutton ckbApplyEffMat "应用材质" pos:[110,160] width:90 height:20 visible:false checked:true
		button btnClearMat "清除" pos:[205,160] width:55 height:20 visible:false
		groupbox gpbToonMat "卡通材质" pos:[5,185] width:(rolBsAnimDemoTools.width - 10) height:65 visible:false
		edittext edtWatermarkText "水印" pos:[5,257] width:125 height:16 visible:false
		button btnFileWM "文件水印" pos:[135,255] width:60 height:20 visible:false
		button btnRnderWM "渲染水印" pos:[200,255] width:60 height:20 visible:false
		-------------------------------------------------------------------------------------------------------------------------------------------
		dotnetcontrol lblTips "Label" text:"2024.4 [ Bullet.S ] ✨        动画师 Demo 简易环境" pos:[0,283] width:rolBsAnimDemoTools.width height:16

		local arrGhostTrails = #("刀光拖尾",#(gpbTrail,spnRadian,chkCreateLine,chkCreateTrail,btnSelectTrail,btnUnfreezeTrail,btnFreezeTrail, \
											btnHideTrail,btnShowTrail,btnDeleteTrail,gpbPreset,rdoTrailType,spnFrameToLag, \
											ckbSetRange,spnStartFrame,spnEndFrame,gpbMesh,spnSegments,spnSplineSteps,spnURepeat, \
											ckbFlipNormals,ckbGenerateMapping,btnMaterial,ddlDefaultTex,btnApplyTex))
		local arrDemoEff     = #("简单特效",#(dotLVFilesList,spnU,spnV,ckbApplyEff,lblFrameOffset,spnFrameOffest,btnOpenPath,ckbLoopToogle))
		local arrDemoScene   = #("环境灯光",#(gpbSkyBox,btnOpenSkyBox,ddlSkyBoxTex,btnCreateSkyBox,btnDeleteSkyBox,gbpLight,btnToggleLight, \
											btnOmniLight,btnSpotLight,btnDirectLight,btnSkyLight,btnSelectLastLight,btnSelectNextLight,btnDeleteLight, \
											gbpFloor,btnCreateFloor,btnFreezeFloor,btnUnfreezeFloor,btnDeleteFloor,btnMakePreview,btnOpenPrevPath,btnMakeRenderer,btnClearAll))
		local arrDemoMat     = #("材质水印",#(edtWatermarkText,btnFileWM,btnRnderWM,rdoMatType,ckbApplyEffMat,btnClearMat,gpbToonMat))
		local arrAllToolsTab = #(arrGhostTrails,arrDemoEff,arrDemoScene,arrDemoMat)
	
		fn fnInitDotTabs =
		(
			lblTips.font       = dotnetobject "System.Drawing.Font" "Roboto" 8
			lblTips.TextAlign  = (dotnetclass "system.drawing.contentalignment").MiddleCenter
			lblTips.BackColor  = (dotColor.FromArgb	200 200 200)
			lblTips.ForeColor  = (dotColor.FromArgb 139 0 0)
			tabBsADT.sizeMode  = (dotnetclass "System.Windows.Forms.TabSizeMode").Fixed
			tabBsADT.itemSize  = dotNetObject "System.Drawing.Size" 65 30
			tabBsADT.dock      = tabBsADT.dock.Fill
			tabBsADT.Drawmode  = tabBsADT.Drawmode.OwnerDrawFixed
	
			for aTab = 1 to arrAllToolsTab.count do
			(
				tabBsADT.TabPages.add arrAllToolsTab[aTab][1]
			)
		)

		fn fnInitDotNetListView dotCtrl str =
		(	
			local align = dotNetClass "HorizontalAlignment"
		
			dotCtrl.Clear()
			dotCtrl.View = (dotNetClass "System.Windows.Forms.View").Details	
			dotCtrl.FullRowSelect = true
			dotCtrl.GridLines = false		
			dotCtrl.ShowItemToolTips = true
			dotCtrl.MultiSelect = false
			dotCtrl.CheckBoxes = false
			dotCtrl.HideSelection = false
			dotCtrl.Columns.Add str (rolBsAnimDemoTools.width - 35)
			dotCtrl.ForeColor = BsDotForeColor
			dotCtrl.BackColor = BsDotBackColor
			if dotCtrl.SelectedItems.Count > 0 then
			(
				dotCtrl.SelectedItems[0].BackColor = BsDotCheckColor
			)

			dotCtrl.Update()
			dotCtrl.Refresh()
		)

		fn fnRefreshTexFiles =
		(
			fnInitDotNetListView dotLVFilesList "特效图集 [双击预览]  (叶孤弦 分享)"
			local arrTexFiles = getFiles ((getDir #scripts) + "\\BulletScripts\\Res\\BsSpriteTex\\*.*")
			rows = #()
			dotLVFilesList.Items.Clear()
			for i = 1 to arrTexFiles.count where arrTexFiles.count != 0 do
			(
				local li = dotNetObject "System.Windows.Forms.ListViewItem" ""
				li.useItemStyleForSubItems = false
				li.text = (getFilenameFile arrTexFiles[i])
				bold = (dotnetclass "System.Drawing.FontStyle").Bold
				li.subitems.add arrTexFiles[i]
				append rows li
			)		
			dotLVFilesList.Items.addRange rows
			arrEffTexFiles = arrtexFiles
		)

		fn fnRefreshFlowTexFiles =
		(
			fnInitDotNetListView dotFlowMatList "其他材质贴图 [双击预览]  (来源网络)"
			local arrTexFiles = getFiles ((getDir #scripts) + "\\BulletScripts\\Res\\BsFlowTex\\*.*")
			rows = #()
			dotFlowMatList.Items.Clear()
			for i = 1 to arrTexFiles.count where arrTexFiles.count != 0 do
			(
				local li = dotNetObject "System.Windows.Forms.ListViewItem" ""
				li.useItemStyleForSubItems = false
				li.text = (getFilenameFile arrTexFiles[i])
				bold = (dotnetclass "System.Drawing.FontStyle").Bold
				li.subitems.add arrTexFiles[i]
				append rows li
			)		
			dotFlowMatList.Items.addRange rows
			arrFlowTexFiles = arrtexFiles
		)

		fn fnGetSelectedId ddl =
		(
			c = ddl.SelectedItems.Count - 1		
			id = 0		
			for i = 0 to c do id = ddl.SelectedItems.Item[i].Index + 1
			return id
		)
	
		fn fnSelEffTex =
		(
			local idSelFile = fnGetSelectedId dotLVFilesList
	
			if idSelFile > 0  then
			(
				if doesFileExist arrEffTexFiles[idSelFile] then
				(
					selEffTex = arrEffTexFiles[idSelFile]
				)
				else (messagebox ("文件可能已被删除或移走，请检查！：\r\n\r\n" + (arrEffTexFiles[idSelFile] as string) + "                                                                            ") title:"提示")
			)
		)

		fn fnSelTex =
		(
			local idSelFile = fnGetSelectedId dotFlowMatList
	
			if idSelFile > 0  then
			(
				if doesFileExist arrFlowTexFiles[idSelFile] then
				(
					selTex = arrFlowTexFiles[idSelFile]
				)
				else (messagebox ("文件可能已被删除或移走，请检查！：\r\n\r\n" + (arrFlowTexFiles[idSelFile] as string) + "                                                                            ") title:"提示")
			)
		)

		fn fnRefreshInitValue = 
		(
			try
			(
				rdoTrailType.state       = $.modifiers[#GhostTrails].movingorstill + 1
				spnFrameToLag.value      = $.modifiers[#GhostTrails].old_frames
				spnStartFrame.value      = $.modifiers[#GhostTrails].startFrame/80
				spnEndFrame.value        = $.modifiers[#GhostTrails].endFrame/80
				spnSegments.value        = $.modifiers[#GhostTrails].segmentsperframe
				spnSplineSteps.value     = $.modifiers[#GhostTrails].splineSteps
				spnURepeat.value         = $.modifiers[#GhostTrails].pb_urepeat
				ckbFlipNormals.state     = $.modifiers[#GhostTrails].flipNormals
				ckbGenerateMapping.state = $.modifiers[#GhostTrails].generateMap
			)catch()
		)

		fn fnChangeToolsVisble id =
		(
			for i = 1 to arrAllToolsTab.count do 
			(
				if i == id then
				(
					for j in arrAllToolsTab[i][2] do j.visible = true
				)
				else (for j in arrAllToolsTab[i][2] do j.visible = false)
			)
			LastSubRollout = id
		)

		fn fnMakeSpline pos1 pos2 sinkF:0 = 
		(
			local dir = normalize (pos2-pos1)
			local dist = (distance pos1 pos2)/2.0
			local pos = pos1 + dir * dist
			pos.z -= (dist*sinkF)
			local new_spline = splineShape ()
				addNewSpline new_spline
					addKnot new_spline 1 #smooth #curve pos1
						addKnot new_spline 1 #smooth #curve pos
					addKnot new_spline 1 #smooth #curve pos2
				updateshape new_spline
			return new_spline
		)

		fn fnGetFilesInPath strFilesDir type =
		(
			if ((strFilesDir != "") and (doesDirectoryExist strFilesDir)) then
			(
				local arrFiles    = #()
				local arrTexFiles = getFiles (strFilesDir + "\\*" + type)

				for i in arrTexFiles where arrTexFiles.count != 0 do 
				(
					append arrFiles i
				)

				ddlDefaultTex.items = for i in arrFiles collect (getFilenameFile i)
				return arrFiles
			)
			else (messageBox "请检查刀光贴图路径是否不存在...                      ")
		)

		fn fnRefreshTex =
		(
			try
			(
				local arrTexFiles = (fnGetFilesInPath ((getDir #scripts) + "\\BulletScripts\\Res\\BsGhostTrailsTex") ".*")
				selGhostTex = arrTexFiles[1]
			)
			catch()
		)

		function fnApplyMat objs tex =
		(
			for i in objs do
			(
				if objs != undefined then
				(
					
					bitmapTex1 = (Bitmaptexture filename:tex)
					if ((maxVersion())[1] < 2200) then 
					(
						i.material = standardMaterial showInViewport:true name: ("Mat_BsGhostTrails_"+i.name)
						i.material.diffuseMap       = bitmapTex1
						i.material.opacityMap       = bitmapTex1
						i.material.opacityMapAmount = 100
					)
					else 
					(
						try(i.modifiers[#GhostTrails].generateMap = on)catch()
						i.material                = physicalMaterial showInViewport:true name: ("Mat_BsGhostTrails_"+i.name)
						i.material.base_color_map = bitmapTex1
						i.material.cutout_map     = bitmapTex1
						i.material.cutout_map_on  = true
					)
					showTextureMap i.material true
				)
			)
		)

		--设置UV大小
		fn uvScaleSet obj GridX GridY =
		(
			if obj != undefined then
			(
				GridU = 1.0/GridX
				GridV = 1.0/GridY
				--选择所有uv多边形 											uv多边形 编号
				subobjectLevel = 3
				obj.modifiers[#unwrap_uvw].unwrap6.selectFacesByNode #{1..(obj.modifiers[#unwrap_uvw].numberPolygons())} obj
				obj.modifiers[#unwrap_uvw].unwrap2.ScaleSelectedXY GridU GridV [0,1,0]
			)
		)
		--设置UV动画
		fn SEUVPosSet obj GridX GridY =
		(
			--选择所有uv多边形 													uv多边形 编号
			if obj != undefined then
			(
				local offsetMove = rolBsAnimDemoTools.spnFrameOffest.value
				obj.modifiers[#unwrap_uvw].unwrap6.selectFacesByNode #{1..(obj.modifiers[#unwrap_uvw].numberPolygons())} obj
				for Y = 1 to GridY do
				(
					if Y != 1 then 
					(
						sliderTime+=offsetMove
						obj.modifiers[#unwrap_uvw].unwrap2.MoveSelected [-(1-1.0/GridX),-(1.0/GridY),0]
						-- print ("y: " + sliderTime as string)
					)
					for X in 1 to (GridX-1) do
					(
						sliderTime+=offsetMove
						obj.modifiers[#unwrap_uvw].unwrap2.MoveSelected [(1.0/GridX),0,0]
						-- print ("x: " + sliderTime as string)
					)
				)
			)
		)

		fn fnGetController tempObj = 
		(
			if tempObj != undefined and tempObj.modifiers[#unwrap_uvw] != undefined then
			(
				local arrCtrl = #()
				for i = 1 to tempObj.modifiers[#unwrap_uvw].numsubs do append arrCtrl tempObj.modifiers[#unwrap_uvw][i].controller
				return arrCtrl
			)
			else return undefined
		)

		fn fnSetOutOfRangeType tempObj type = 
		(
			arrCtrl = fnGetController tempObj
			for i in arrCtrl where arrCtrl != undefined do
			(
				if i != undefined then
				(
					setBeforeORT arrCtrl type
					setAfterORT arrCtrl type
				)
			)
		)

		on btnRegister pressed do
		(
			if (queryBox ("是否复制注册码到剪切板？                        ") title:"BsAnimMemoTools") do
			(
				getclipboardText()
				setclipboardText "E8C18FB749BA820E0525422425AFBED057AD5AEB7FE98E2F17C688B869B454"
				messageBox "复制成功,选中刀光点击注册粘贴即可(下面可创建)。                                   " title:"BsAnimMemoTools"
			)
		)

		on btnAbout pressed do 
		(
			shellLaunch "https://space.bilibili.com/2031113/channel/collectiondetail?sid=560782" ""
		)

		on tabBsADT Selected itm do
		(
			arrID = (itm.TabPageIndex + 1)
			if LastSubRollout != arrID do --避免点击重复
			(
				fnChangeToolsVisble arrID
				if arrID == 2 then (dotLVFilesList.pos = [5,50];fnRefreshTexFiles())
				else (dotLVFilesList.pos = [5,-500])
				if arrID == 4 then (dotFlowMatList.pos = [5,50];fnRefreshFlowTexFiles())
				else (dotFlowMatList.pos = [5,-500])
			) 
		)
		
		on rolBsAnimDemoTools open do
		(
			fnInitDotTabs()
			fnChangeToolsVisble (tabBsADT.SelectedIndex + 1)
			fnRefreshInitValue()
			selGhostTex = fnRefreshTex()
		)

		on btnClose pressed do 
		(
			try (destroydialog rolBsAnimDemoTools) catch ()
		)

		on rolBsAnimDemoTools mbuttondown pos do 
		(
			try (destroydialog rolBsAnimDemoTools) catch ()
		)
		
		on rolBsAnimDemoTools lbuttondown posMou do
		(
			setSysCur #move
			offsetBsADT = posMou
			dragStateBsADT = on
		)
		
		on rolBsAnimDemoTools lbuttonup posMou do
		(
			dragStateBsADT = off
		)
		
		on rolBsAnimDemoTools mouseMove pos do
		(
			if dragStateBsADT == on then
			(
				SetDialogPos rolBsAnimDemoTools (mouse.screenpos - offsetBsADT)
			)
		)

		on chkCreateLine changed state do
		(
			chkCreateLine.state = true
			if selection.count == 2 then
			(
				sliderTime = 0
				local p1 = selection[1].pos
				local p2 = selection[2].pos
				local spline = fnMakeSpline p1 p2 sinkF:spnRadian.value
				local newName = "BsGhostTrails_" + spline.name
				spline.name = newName
				CenterPivot spline
				lc = Link_Constraint()
				spline.transform.controller = lc
				lc.key_mode = 0
				lc.addTarget selection[1] 0
				spline.showFrozenInGray = off
				spline.isfrozen = on

				select spline
			) 
			else 
			(
				messagebox "请先选择两个物体 (需要两点位置) ...             " title:"BsAnimDemoTools"
			)
		)
		
		on chkCreateTrail changed state do
		(
			chkCreateTrail.state = true
			if selection.count == 0 do (messagebox "请先创建并选择线...             " title:"BsAnimDemoTools")
			for i in selection where selection.count != 0 do 
			(
				if validModifier i GhostTrails then 
				(
					modPanel.addModToSelection (GhostTrails ()) ui:on
				)
			)
		)

		on btnDeleteTrail pressed do
		(
			undo "deleteGhostTrails" on
			(
				try(delete $'BsGhostTrails_*';messagebox "清除 GhostTrails 刀光相关物体成功!                      " title:"BsAnimDemoTools")catch()
			)
		)

		on btnSelectTrail pressed do
		(
			try(select $'BsGhostTrails_*';max modify mode)catch()
		)

		on btnUnfreezeTrail pressed do
		(
			try
			(
				select $'BsGhostTrails_*'
				$.isfrozen = off
				$.showFrozenInGray = off
			)catch()
		)

		on btnFreezeTrail pressed do
		(
			try
			(
				select $'BsGhostTrails_*'
				$.isfrozen = on
				$.showFrozenInGray = off
			)catch()
		)

		on btnHideTrail pressed do
		(
			try(hide $'BsGhostTrails_*')catch()
		)

		on btnShowTrail pressed do
		(
			try(unhide $'BsGhostTrails_*')catch()
		)

		on spnFrameToLag changed val do
		(
			try
			(
				$.modifiers[#GhostTrails].old_frames = val
			)catch()
		)

		on spnStartFrame changed val do
		(
			try
			(
				$.modifiers[#GhostTrails].startFrame = val*80
			)catch()
		)

		on spnEndFrame changed val do
		(
			try
			(
				$.modifiers[#GhostTrails].endFrame = val*80
			)catch()
		)

		on spnSegments changed val do
		(
			try
			(
				$.modifiers[#GhostTrails].segmentsperframe = val
			)catch()
		)

		on spnSplineSteps changed val do
		(
			try
			(
				$.modifiers[#GhostTrails].splineSteps = val
			)catch()
		)

		on spnURepeat changed val do
		(
			try
			(
				$.modifiers[#GhostTrails].pb_urepeat = val
			)catch()
		)

		on ckbFlipNormals changed state do
		(
			try
			(
				$.modifiers[#GhostTrails].flipNormals = state
			)catch()
		)

		on ckbGenerateMapping changed state do
		(
			try
			(
				$.modifiers[#GhostTrails].generateMap = state
			)catch()
		)

		on rdoTrailType changed id do
		(
			if id == 2 then
			(
				ckbSetRange.enabled   = on
				spnFrameToLag.enabled = off
				try
				(
					$.modifiers[#GhostTrails].movingorstill = 1
				)catch()
			)
			else
			(
				spnFrameToLag.enabled = on
				ckbSetRange.enabled   = off
				spnStartFrame.enabled = off
				spnEndFrame.enabled   = off
				try
				(
					$.modifiers[#GhostTrails].movingorstill = 0
				)catch()
			)
		)

		on ckbSetRange changed state do
		(
			if state then
			(
				spnStartFrame.enabled = on
				spnEndFrame.enabled   = on
			)
			else
			(
				spnStartFrame.enabled = off
				spnEndFrame.enabled   = off
			)
		)

		on btnMaterial pressed do
		(
			max mtledit
		)

		on ddlDefaultTex selected id do
		(
			local arrTexFiles = (fnGetFilesInPath ((getDir #scripts) + "\\BulletScripts\\Res\\BsGhostTrailsTex") ".*")
			selGhostTex = arrTexFiles[id]
			-- print selGhostTex
		)

		on btnApplyTex pressed do
		(
			try(fnApplyMat $ selGhostTex )catch(messageBox "失败,请检查是否选中刀光物体...             " title:"BsAnimDemoTools")
			btnApplyTex.text = "指定刀光"
		)

		on btnApplyTex rightclick do
		(
			selGhostTex = getOpenFileName caption:"选择刀光贴图" filename:((getDir #scripts) + "\\BulletScripts\\Res\\BsGhostTrailsTex\\【中】红.png") \
			types:"刀光贴图(*.tga;*.png;*.dds)|*.tga;*.png;*.dds|所有文件(*.*)|*.*|"
			btnApplyTex.text = getfilenamefile selGhostTex
		)

		on btnOpenPath pressed do
		(
			try(shellLaunch ((getDir #scripts) + "\\BulletScripts\\Res\\BsSpriteTex\\") "")catch(messageBox "打开失败,请检查路径是否存在...                        " title:"BsAnimDemoTools")
		)

		on ckbApplyEff changed state do
		(
			ckbApplyEff.state = true
			if selEffTex != undefined then
			(
				local frameCount = animationrange.end - animationrange.start
				if frameCount >= (spnU.value * spnV.value * spnFrameOffest.value) then
				(
					undo on(
						---------分UV---------
						sliderTime = animationrange.start	
						local obj
						if selection[1] != undefined then (
							obj = selection[1]
							------上贴图---------
							if obj != undefined do (fnApplyMat obj selEffTex)
							if obj.Modifiers[#unwrap_uvw]!=undefined then deleteModifier obj obj.modifiers[#unwrap_uvw]	
							modPanel.addModToSelection (Unwrap_UVW ()) ui:on
						)
						uvScaleSet obj spnU.value spnV.value
						----------创建动画----------------
						if selection[1] != undefined then (
						maxops.setDefaultTangentType #step #step			
						set animate on
						SEUVPosSet obj spnU.value spnV.value
						maxops.setDefaultTangentType #flat #flat
						subobjectLevel = 0
					))
				)
				else (messagebox ("帧数区间不足以支持序列帧动画，结束帧至少需要到 " + (animationrange.start + (spnU.value * spnV.value * spnFrameOffest.value)) as string + " ...                          ") title:"BsAnimDemoTools")
			)
			else (messagebox "请先选择上方序列帧...\r\n\r\n也可自行添加入库~                                " title:"BsAnimDemoTools")
		)

		on dotLVFilesList mouseup sender args do
		(
			if args.Button == (dotNetClass "System.Windows.Forms.MouseButtons").Right then
			(
				shellLaunch ((getDir #scripts) + "\\BulletScripts\\Res\\BsSpriteTex\\") ""
			)
			else if args.Button == (dotNetClass "System.Windows.Forms.MouseButtons").Left then fnSelEffTex()
		)

		on dotLVFilesList doubleClick sender args do
		(
			try(shellLaunch selEffTex "")catch()
		)

		on dotFlowMatList mouseup sender args do
		(
			if args.Button == (dotNetClass "System.Windows.Forms.MouseButtons").Right then
			(
				shellLaunch ((getDir #scripts) + "\\BulletScripts\\Res\\BsFlowTex\\") ""
			)
			else if args.Button == (dotNetClass "System.Windows.Forms.MouseButtons").Left then fnSelTex()
		)

		on dotFlowMatList doubleClick sender args do
		(
			try(shellLaunch selTex "")catch()
		)

		on ckbLoopToogle changed state do 
		(
			if state then 
			(
				fnSetOutOfRangeType $ #loop
			)
			else 
			(
				fnSetOutOfRangeType $ #constant
			)
		)
	)
	createDialog rolBsAnimDemoTools style:#()
)