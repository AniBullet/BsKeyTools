/*
 * @Description: Demo专用工具集
 * @Author: Bullet.S
 * @Date: 2024-04-03 10:58:49
 * @LastEditors: Bullet.S
 * @LastEditTime: 2025-02-14 11:05:22
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
		local selFlowTex      = undefined
		local selSkyBoxTex    = undefined
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
		button btnSelectTrail "选中" pos:[10,90] width:40 height:24 tooltip:"选中" images:#("UVWUnwrapView_16i.bmp","UVWUnwrapView_16a.bmp",27,1,1,1,1,true,false)
		button btnUnfreezeTrail "解冻" pos:[55,90] width:40 height:24 tooltip:"解冻" images:#("UVWUnwrapView_16i.bmp","UVWUnwrapView_16a.bmp",27,19,19,19,19,true,false)
		button btnFreezeTrail "冻结" pos:[100,90] width:40 height:24 tooltip:"冻结" images:#("UVWUnwrapView_16i.bmp","UVWUnwrapView_16a.bmp",27,17,17,17,17,true,false)
		button btnHideTrail "隐藏" pos:[145,90] width:35 height:24 tooltip:"隐藏" images:#("UVWUnwrapView_16i.bmp","UVWUnwrapView_16a.bmp",27,6,6,6,6,true,false)
		button btnShowTrail "显示" pos:[185,90] width:35 height:24 tooltip:"显示" images:#("UVWUnwrapView_16i.bmp","UVWUnwrapView_16a.bmp",27,5,5,5,5,true,false)
		button btnDeleteTrail "清除" pos:[225,90] width:30 height:24 images:#("enss_tools_16i.bmp","enss_tools_16a.bmp",13,3,3,4,4,false,true)
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
		button btnMaterial "材质窗口" pos:[5,255] width:60 height:20
		dropdownlist ddlDefaultTex "" pos:[70,255] width:110 height:20 items:#("")
		button btnApplyTex "指定刀光" pos:[185,255] width:75 height:21 tooltip:"左键赋予刀光贴图，右键重新指定"
		-------------------------------------------------------------------------------------------------------------------------------------------
		dotNetControl dotLVFilesList "system.windows.forms.listView" selection:0 height:185 width:(rolBsAnimDemoTools.width - 10) pos:[5,-500]
		spinner spnU "横" pos:[10,240] width:50 height:20 range:[-99999,99999,4] type:#integer align:#left visible:false
		spinner spnV "纵" pos:[10,260] width:50 height:20 range:[-99999,99999,4] type:#integer align:#left visible:false
		label lblFrameOffset "↓ 隔帧 ↓" pos:[75,240] width:50 height:20 visible:false
		spinner spnFrameOffest "" pos:[75,260] width:40 height:20 range:[-99999,99999,1] type:#integer align:#left visible:false
		button btnOpenPath "仓库" pos:[125,240] width:40 height:20 visible:false 
		checkbutton ckbLoopToogle "循环" pos:[125,260] width:40 height:20 visible:false
		checkbutton ckbApplyEff "应用图集特效" pos:[170,240] width:90 height:40 visible:false checked:true
		-------序列帧工具来源 "https://www.cgjoy.com/thread-275528-1-1.html" 开发者：叶孤弦
		-------------------------------------------------------------------------------------------------------------------------------------------
		groupbox gpbSkyBox "天空球" pos:[5,55] width:(rolBsAnimDemoTools.width - 10) height:50 visible:false
		dropdownlist ddlSkyBoxTex "" pos:[15,75] width:120 height:20 items:#("") visible:false
		button btnCreateSkyBox "创建" pos:[140,75] width:40 height:20 visible:false
		button btnOpenSkyBox "打开" pos:[185,75] width:40 height:20 visible:false tooltip:"左键打开图片，右键打开文件夹，图片打开失败可能是没有安装支持的查看器"
		button btnDeleteSkyBox "清除" pos:[230,75] width:25 height:20 visible:false images:#("enss_tools_16i.bmp","enss_tools_16a.bmp",13,3,3,4,4,false,true)
		groupbox gbpLight "灯光箱" pos:[5,110] width:(rolBsAnimDemoTools.width - 80) height:75 visible:false
		button btnOmniLight "点光源" pos:[10,130] width:55 height:20 visible:false
		button btnSpotLight "聚光灯" pos:[70,130] width:55 height:20 visible:false
		button btnDirectLight "平行光" pos:[10,155] width:55 height:20 visible:false
		button btnSkyLight "环境光" pos:[70,155] width:55 height:20 visible:false
		-- button btnSelectLastLight "选↑灯" pos:[135,130] width:55 height:20 visible:false
		-- button btnSelectNextLight "选↓灯" pos:[135,155] width:55 height:20 visible:false
		button btnLightOn "灯光开" pos:[130,130] width:25 height:20 visible:false tooltip:"灯光开 (影响几乎所有灯光)" images:#("UVWUnwrapView_16i.bmp","UVWUnwrapView_16a.bmp",28,15,15,15,15,true,false)
		button btnLightOff "灯光关" pos:[159,130] width:25 height:20 visible:false tooltip:"灯光关 (影响几乎所有灯光)" images:#("UVWUnwrapView_16i.bmp","UVWUnwrapView_16a.bmp",28,13,13,13,13,true,false)
		button btnDeleteLight "清除灯光" pos:[130,155] width:55 height:20 visible:false tooltip:"清除灯光 (仅影响此工具创建的灯光)"
		button btnCameraPlane "添加背景" pos:[195,115] width:65 height:35 visible:false tooltip:"添加相机背景参考图"
		button btnRefCam "相机" pos:[195,155] width:30 height:30 visible:false tooltip:"选择相机（需要先创建参考背景）" images:#("Cameras_24i.bmp","Cameras_24i.bmp",3,3,3,3,3,false,false)
		button btnSelectCameraPlane "背景" pos:[230,155] width:30 height:30 visible:false tooltip:"选择背景面片（需要先创建参考背景）" images:#("Standard_24i.bmp","Standard_24i.bmp",11,10,10,10,10,false,false)
		groupbox gbpFloor "地板片" pos:[5,190] width:(rolBsAnimDemoTools.width - 10) height:50 visible:false
		button btnCreateFloor "一键创建" pos:[15,210] width:75 height:20 visible:false
		button btnUnfreezeFloor "解冻" pos:[95,210] width:40 height:20 visible:false tooltip:"解冻" images:#("UVWUnwrapView_16i.bmp","UVWUnwrapView_16a.bmp",27,19,19,19,19,true,false)
		button btnFreezeFloor "冻结" pos:[140,210] width:40 height:20 visible:false tooltip:"冻结" images:#("UVWUnwrapView_16i.bmp","UVWUnwrapView_16a.bmp",27,17,17,17,17,true,false)
		button btnReflection "镜面" pos:[185,210] width:35 height:20 visible:false tooltip:"地面反射开关" images:#("AutoGrid_16i.bmp","AutoGrid_16i.bmp",2,1,1,1,1,true,true)
		button btnDeleteFloor "清除" pos:[225,210] width:30 height:20 visible:false tooltip:"删除地板" images:#("enss_tools_16i.bmp","enss_tools_16a.bmp",13,3,3,4,4,false,true)
		button btnMakePreview "快速拍屏" pos:[5,250] width:60 height:25 visible:false tooltip:"快速预览视窗效果,可能跟实际渲染有差别"
		button btnOpenPrevPath "拍屏目录" pos:[70,250] width:60 height:25 visible:false tooltip:"打开拍屏目录"
		button btnMakeRenderer "渲染一帧" pos:[135,250] width:60 height:25 visible:false tooltip:"快速预览场景整体效果,注意先设置好渲染设置"
		button btnClearAll "清除所有" pos:[200,250] width:60 height:25 visible:false
		-------------------------------------------------------------------------------------------------------------------------------------------
		dotNetControl dotFlowMatList "system.windows.forms.listView" selection:0 height:100 width:(rolBsAnimDemoTools.width - 100) pos:[5,-500]
		checkbox ckbOpacityMat "开启透明" checked:false pos:[180,65] width:80 visible:false
		checkbutton ckbApplyEffMat "应用材质" pos:[175,85] width:80 height:30 visible:false checked:true
		button btnOpenEffPath "仓库" pos:[175,120] width:40 height:25 visible:false tooltip:"由于安装包大小，没有添加太多材质贴图，建议自行添加" images: #("bip_general_i.bmp","bip_general_i.bmp",30,5,5,6,6,false,true)
		button btnClearMat "清除" pos:[220,120] width:35 height:25 visible:false tooltip:"恢复初始材质球"
		groupbox gpbLineMat "卡通描边" pos:[5,155] width:(rolBsAnimDemoTools.width - 140) height:95 visible:false
		radiobuttons rdoNormalFlip "" labels:#("法线翻转","不变") columns:2 pos:[12,175] width:100 visible:false
		colorpicker cpLineColor "" pos:[8,199] width:25 height:20 visible:false color:(color 10 10 10)
		checkbutton ckbApplyLineMat "添加描边" pos:[40,199] width:85 height:20 visible:false checked:true
		button btnSelLineMesh "选" pos:[10,225] width:25 height:20 visible:false tooltip:"选中" images:#("UVWUnwrapView_16i.bmp","UVWUnwrapView_16a.bmp",27,1,1,1,1,true,false)
		button btnUnFreezeLineMesh "解" pos:[40,225] width:25 height:20 visible:false tooltip:"解冻" images:#("UVWUnwrapView_16i.bmp","UVWUnwrapView_16a.bmp",27,19,19,19,19,true,false)
		button btnFreezeLineMesh "冻" pos:[70,225] width:25 height:20 visible:false tooltip:"冻结" images:#("UVWUnwrapView_16i.bmp","UVWUnwrapView_16a.bmp",27,17,17,17,17,true,false)
		button btnDeleteLine "清除" pos:[100,225] width:25 height:20 visible:false images:#("enss_tools_16i.bmp","enss_tools_16a.bmp",13,3,3,4,4,false,true)
		groupbox gpbToonMat "简易卡通材质" pos:[140,155] width:(rolBsAnimDemoTools.width - 145) height:95 visible:false
		colorpicker cpPureToonColor "" pos:[140,175] width:25 height:20 visible:false color:(color 255 60 60)
		button btnApplyPureToonMat "应用纯色材质" pos:[170,175] width:85 height:20 visible:false
		button btnReCollectMat "整理 | #1页" pos:[145,200] width:70 height:20 visible:false
		button btnTint "环境" pos:[215,200] width:40 height:20 visible:false
		button btnRenderSet "渲染设置" pos:[205,225] width:50 height:20 visible:false
		edittext edtWatermarkText "水印" pos:[5,257] width:125 height:16 visible:false
		button btnAddWaterMark "生成" pos:[135,255] width:50 height:20 visible:false tooltip:"简陋水印, 默认创建在右下角，字体很小，跟随文件" images:#("enss_tools_16i.bmp","enss_tools_16a.bmp",13,5,5,6,6,false,true)
		button btnSelWM "选中" pos:[190,255] width:35 height:20 visible:false tooltip:"选中" images:#("UVWUnwrapView_16i.bmp","UVWUnwrapView_16a.bmp",27,1,1,1,1,true,false)
		button btnDelWM "清除" pos:[230,255] width:30 height:20 visible:false tooltip:"清除" images:#("enss_tools_16i.bmp","enss_tools_16a.bmp",13,3,3,4,4,false,true)
		-------------------------------------------------------------------------------------------------------------------------------------------
		dotnetcontrol lblTips "Label" text:"2024.4 [ Bullet.S ] ✨        动画师 Demo 简易环境" pos:[0,283] width:rolBsAnimDemoTools.width height:16

		local arrGhostTrails = #("刀光拖尾",#(gpbTrail,spnRadian,chkCreateLine,chkCreateTrail,btnSelectTrail,btnUnfreezeTrail,btnFreezeTrail, \
											btnHideTrail,btnShowTrail,btnDeleteTrail,gpbPreset,rdoTrailType,spnFrameToLag, \
											ckbSetRange,spnStartFrame,spnEndFrame,gpbMesh,spnSegments,spnSplineSteps,spnURepeat, \
											ckbFlipNormals,ckbGenerateMapping,btnMaterial,ddlDefaultTex,btnApplyTex))
		local arrDemoEff     = #("简单特效",#(dotLVFilesList,spnU,spnV,ckbApplyEff,lblFrameOffset,spnFrameOffest,btnOpenPath,ckbLoopToogle))
		local arrDemoScene   = #("环境灯光",#(gpbSkyBox,btnOpenSkyBox,ddlSkyBoxTex,btnCreateSkyBox,btnDeleteSkyBox,gbpLight,btnLightOn,btnLightOff, \
											btnOmniLight,btnSpotLight,btnDirectLight,btnSkyLight,btnDeleteLight,gbpFloor,btnCreateFloor, \
											btnFreezeFloor,btnUnfreezeFloor,btnDeleteFloor,btnMakePreview,btnOpenPrevPath,btnMakeRenderer,btnClearAll, \
											btnCameraPlane,btnSelectCameraPlane,btnRefCam,btnReflection))
		local arrDemoMat     = #("材质水印",#(edtWatermarkText,btnAddWaterMark,btnSelWM,ckbOpacityMat,ckbApplyEffMat,btnOpenEffPath,btnClearMat,gpbToonMat,rdoNormalFlip, \
											gpbLineMat,cpLineColor,ckbApplyLineMat,btnSelLineMesh,btnDeleteLine,cpPureToonColor,btnApplyPureToonMat, \
											btnUnFreezeLineMesh,btnFreezeLineMesh,btnReCollectMat,btnTint,btnRenderSet,btnDelWM))
		local arrAllToolsTab = #(arrGhostTrails,arrDemoScene,arrDemoEff,arrDemoMat)
	
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
			dotCtrl.Columns.Add str (dotCtrl.width - 25)
			dotCtrl.ForeColor = BsDotForeColor
			dotCtrl.BackColor = BsDotBackColor
			if dotCtrl.SelectedItems.Count > 0 then
			(
				dotCtrl.SelectedItems[0].BackColor = BsDotCheckColor
			)

			dotCtrl.Update()
			dotCtrl.Refresh()
		)

		fn fnRefreshTexFiles ui strUI path =
		(
			fnInitDotNetListView ui strUI
			local arrTexFiles = getFiles path
			rows = #()
			ui.Items.Clear()
			for i = 1 to arrTexFiles.count where arrTexFiles.count != 0 do
			(
				local li = dotNetObject "System.Windows.Forms.ListViewItem" ""
				li.useItemStyleForSubItems = false
				li.text = (getFilenameFile arrTexFiles[i])
				bold = (dotnetclass "System.Drawing.FontStyle").Bold
				li.subitems.add arrTexFiles[i]
				append rows li
			)		
			ui.Items.addRange rows
			return arrTexFiles
		)

		fn fnGetSelectedId ddl =
		(
			c = ddl.SelectedItems.Count - 1		
			id = 0		
			for i = 0 to c do id = ddl.SelectedItems.Item[i].Index + 1
			return id
		)

		fn fnSelTex ui arr =
		(
			local idSel = fnGetSelectedId ui
			if idSel > 0 then 
			(
				if doesFileExist arr[idSel] then
				(
					return arr[idSel]
				)
				else 
				(
					messagebox ("文件可能已被删除或移走，请检查！：\r\n\r\n" + (arr[idSel] as string) + "                                                                            ") title:"提示"
					return undefined
				)
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
				return arrFiles
			)
			else (messageBox "请检查刀光贴图路径是否不存在...                      ")
		)

		fn fnRefreshTex =
		(
			try
			(
				local arrTexFiles       = (fnGetFilesInPath ((getDir #scripts) + "\\BulletScripts\\Res\\BsGhostTrailsTex") ".*")
				local arrSkyBoxTexFiles = (fnGetFilesInPath ((getDir #scripts) + "\\BulletScripts\\Res\\BsSkyBox") ".hdr")
				selGhostTex  = arrTexFiles[1]
				selSkyBoxTex = arrSkyBoxTexFiles[1]
				rolBsAnimDemoTools.ddlDefaultTex.items = for i in arrTexFiles collect (getFilenameFile i)
				rolBsAnimDemoTools.ddlSkyBoxTex.items = for i in arrSkyBoxTexFiles collect (getFilenameFile i)
			)
			catch()
		)

		function fnApplyMat objs tex cutout:true =
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
						if cutout do 
						(
							i.material.opacityMap       = bitmapTex1
							i.material.opacityMapAmount = 100
						)
					)
					else 
					(
						try(i.modifiers[#GhostTrails].generateMap = on)catch()
						i.material                = physicalMaterial showInViewport:true name: ("Mat_BsGhostTrails_"+i.name)
						i.material.base_color_map = bitmapTex1
						if cutout do
						(
							i.material.cutout_map     = bitmapTex1
							i.material.cutout_map_on  = true
						)
					)
					showTextureMap i.material true
				)
			)
		)
		fn fnSetDefaultMat objs =
		(
			for i in objs do
			(
				if objs != undefined then
				(
					
					if ((maxVersion())[1] < 2200) then 
					(
						i.material   = standardMaterial()
					)
					else 
					(
						i.material = physicalMaterial()
					)
				)
			)
			completeRedraw()
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

		fn fnCreatLight type =
		(
			local posTarget = [0,0,0]
			if selection.count != 0 then
			(
				posTarget = selection[1].pos
			)
			local lightSpot = 
			(
				case type of
				(
					"omniLight": omniLight pos:[0,0,200]
					"Targetspot": Targetspot pos:[120,120,200] target:(targetObject pos:posTarget)
					"TargetDirectionallight": TargetDirectionallight pos:[0,120,200] target:(targetObject pos:posTarget)
					"SkyLight": SkyLight isSelected:on
				)
			)
			select lightSpot
			lightSpot.name = uniquename ("BsLights" + (type as string) + "_Light")
			try(lightSpot.target.name = uniquename ("BsLights" + (type as string) + "_Target"))catch()
		)
		----------相机视角添加参考图,修改子 ScreenLock Reference ---------------------------------------------------------------------
		fn createRefPlane cam mappingType:1 nDistance:1.0 =
		(
			refPlane = undefined
			bmap = selectBitMap()
			
			if bmap!=undefined then (
				
				-- Create material
				stdmat = Standardmaterial ()
				texMap = Bitmaptexture fileName:bmap.filename
				stdmat.diffuseMap = texMap
				
				if bmap.hasAlpha then (
					texMap.monoOutput = 1
					texMap.alphasource = 0
					mixMap = Mix color1:(color 255 255 255) map1:texMap color2:(color 0 0 0)
					stdmat.opacityMap = mixMap
				)			
				
				stdmat.selfIllumAmount = 100.0
				
				assignNewName stdmat
				showTextureMap stdmat on
				
				-- Create ref. Plane
				refPlane = Plane length:(bmap.height/1000.0) width:(bmap.width/1000.0) lengthsegs:1 widthsegs:1 name:(uniquename "CamRefPlane")
				refPlane.material = stdmat
				addModifier refPlane (SpaceCameraMap camera:cam)
				refPlane.modifiers[1].enabled = (if mappingType==1 then false else true)
				
				-- Align the plane with the camera
				refPlane.transform = cam.transform
				refPlane.scale = [1,1,1]
				vecDir = refPlane.dir*(-1)
				refPlane.pos = (vecDir * nDistance) + refPlane.pos
				
				-- Parent to cam / set non-renderable
				refPlane.parent = cam
				refPlane.renderable = false
				refPlane.showFrozenInGray = false
				
				-- Add to separate layer
				layName = "ScreenLock Refs"
				nLayer = LayerManager.getLayerFromName layName
				if nLayer==undefined then nLayer = layermanager.newLayerFromName layName
				nLayer.addNode refPlane
				nLayer.isFrozen = true			
			)
			refPlane
		)
	
		-- Add custom controls to camera
		fn addCustomCtrls theCam =
		(
			objAttrib = attributes screenLockRef_custProps (
				
				parameters custAttribParams rollout:custAttribRoll (
					pRefPlane type:#maxobject
					pScale type:#float default:100.0 ui:spnScale
					pOffsetX type:#worldunits default:0 ui:spnOffsetX
					pOffsetY type:#worldunits default:0 ui:spnOffsetY
					pOffsetZ type:#worldunits default:1.1 ui:spnOffsetZ
					pOpacity type:#float default:100.0 ui:spnOpacity
					pLockRef type:#boolean default:false
				)
				
				rollout custAttribRoll "Reference Image Controls" (				
					
					-- Get the Attribute Holder mod
					fn getThisMod = (custAttributes.getOwner this)
					
					-- Get the camera object
					fn getThisObj = (refs.dependentnodes (getThisMod()))[1]
					
					-- Get reference plane
					fn getRefPlane =
					(
						refPlane = undefined
						md = getThisMod()
						if (classof md.pRefPlane)==NodeTransformMonitor then (
							if (isValidNode md.pRefPlane.node) then refPlane = md.pRefPlane.node
						)
						refPlane
					)
					
					-- Set refPlane Opacity
					fn setOpacity refPlane val =
					(
						mat = refPlane.material
						if (isProperty mat #opacityMap) then (
							if (isProperty mat.opacityMap #mixAmount) then (
								mat.opacityMap.mixAmount = 100.0 - val
							) else (
								mat.opacity = val
							)
						)
					)
					
					-- Trim string
					fn trimString str maxLength =
					(
						newStr = str
						cropSymbol = "..."
						if str.count > maxLength then (			
							newStr = (substring str 1 (maxLength - cropSymbol.count)) + cropSymbol
						)
						newStr
					)
					
					checkbox chbVisible "显示" checked:true align:#left offset:[-10,0]
					button loadRefImage "加载图片..." width:134 height:22 align:#left offset:[-10,4] across:2
					button btnDelRefPlane "X" tooltip:"移除图片" width:22 height:22 pos:[(loadRefImage.pos.x+136),loadRefImage.pos.y]
					dropdownList dpdMappingType "" items:#("与参考平面绑定","从相机投影") selection:2 width:158 align:#center offset:[0,2]
					spinner spnScale "缩放 (%)       " range:[0.01,10000.0,100.0] type:#float fieldWidth:72 align:#left offset:[-6,0]
					spinner spnOffsetX "偏移 X         " range:[-100000.0,100000.0,0] type:#worldunits scale:0.001 fieldWidth:72 align:#left offset:[-6,0]
					spinner spnOffsetY "偏移 Y         " range:[-100000.0,100000.0,0] type:#worldunits scale:0.001 fieldWidth:72 align:#left offset:[-6,0]
					button btnResetTr "重置变换信息" width:158 height:22 align:#center offset:[0,0]
					spinner spnOffsetZ "到相机距离  " range:[-100000.0,100000.0,1.1] type:#worldunits scale:0.001 fieldWidth:46 align:#left offset:[-6,0]
					spinner spnOpacity "透明度 (%)  " range:[0,100.0,100.0] type:#float fieldWidth:74 align:#left offset:[-6,0]
					checkbutton btnLockRefPlane "解锁参考平面" checked:false width:158 height:22 align:#center offset:[0,0]
					
					-- timer tmLink interval:8000
					hyperLink hlink "" color:orange hoverColor:yellow visitedColor:orange address:"" align:#left offset:[0,2]
					
					-- local linkVal = 1
					fn showLink rnd:false = (
					-- 	txtArr = #("Clean your Splines Easily!","Create Animations Quickly!","Streamline your Rendering Jobs!","Speed Up your Renders!")
					-- 	urlArr = #("spline-cleaner","showcaser","overnight-batch-render","proxy-textures")
					-- 	if rnd then linkVal = random 1 txtArr.count
					hlink.text = "www.splinedynamics.com"; hlink.address = "https://www.splinedynamics.com/"
					)
					
					-- Update loadRefImage button text
					fn updateLoadImgBtn =
					(
						txt = "加载图片..."
						if this.pRefPlane!=undefined then (
							if (isValidNode this.pRefPlane.node) then (
								refPlane = this.pRefPlane.node
								if (isProperty refPlane.material #diffuseMap) then txt = trimString (filenameFromPath refPlane.material.diffuseMap.filename) 18
							)
						)
						loadRefImage.text = txt
					)
					
					-- Set the text of btnLockRefPlane
					fn setBtnLockRefPlaneTxt state =
					(
						btnLockRefPlane.text = (if state then "锁定参考背景" else "解锁参考背景")
					)
					
					on custAttribRoll open do (
						updateLoadImgBtn()
						btnLockRefPlane.checked = this.pLockRef
						setBtnLockRefPlaneTxt this.pLockRef
						showLink rnd:false
					)
					
					on chbVisible changed state do (
						refPlane = getRefPlane()
						if refPlane!=undefined then refPlane.isHidden = not state
					)
					
					on loadRefImage pressed do (
						cam = getThisObj()
						md = getThisMod()
						refPlane = createRefPlane cam mappingType:dpdMappingType.selection nDistance:1.1
						if refPlane!=undefined then (
							if (classof md.pRefPlane)==NodeTransformMonitor then (
								if (isValidNode md.pRefPlane.node) then delete md.pRefPlane.node
							)						
							md.pRefPlane = nodeTransformMonitor node:refPlane forwardTransformChangeMsgs:false
							refPlane.scale = [md.pScale, md.pScale, md.pScale] / 100.0
							in coordsys parent refPlane.pos = [md.pOffsetY, md.pOffsetY, -md.pOffsetZ]
							setOpacity refPlane md.pOpacity
							updateLoadImgBtn()
						)
					)
					
					on dpdMappingType selected item do (
						refPlane = getRefPlane()
						if refPlane!=undefined then (
							if (classOf refPlane.modifiers[1])==SpaceCameraMap then (
								refPlane.modifiers[1].enabled = (if item==1 then false else true)
							)
						)					
					)
					
					on btnDelRefPlane pressed do (
						qb = queryBox "清除参考背景?"
						if qb then (
							refPlane = getRefPlane()
							if (isValidNode refPlane) then (
								delete refPlane
								updateLoadImgBtn()
								nLayer = LayerManager.getLayerFromName "ScreenLock Refs"
								if nLayer!=undefined then (
									LayerManager.deleteLayerByName "ScreenLock Refs"
								)
							)
						)
					)
					
					on spnScale changed val do (
						refPlane = getRefPlane()
						if refPlane!=undefined then refPlane.scale = [val,val,val] / 100.0
					)
					
					on spnOffsetX changed val do (
						refPlane = getRefPlane()
						if refPlane!=undefined then (in coordsys parent refPlane.pos.x = val)
					)
					
					on spnOffsetY changed val do (
						refPlane = getRefPlane()
						if refPlane!=undefined then (in coordsys parent refPlane.pos.y = val)
					)
					
					on spnOffsetZ changed val do (
						refPlane = getRefPlane()
						if refPlane!=undefined then (in coordsys parent refPlane.pos.z = -val)
					)
					
					on spnOpacity changed val do (
						refPlane = getRefPlane()
						if refPlane!=undefined then setOpacity refPlane val
					)
					
					on btnResetTr pressed do (
						this.pScale = 100.0
						this.pOffsetX = 0
						this.pOffsetY = 0
						refPlane = getRefPlane()
						if refPlane!=undefined then (
							refPlane.scale = [1,1,1]
							in coordsys parent refPlane.pos = [0, 0, -this.pOffsetZ]
						)
					)
					
					on btnLockRefPlane changed state do (
						nLayer = LayerManager.getLayerFromName "ScreenLock Refs"
						if nLayer!=undefined then (
							nLayer.isFrozen = not state
							this.pLockRef = state
							setBtnLockRefPlaneTxt state
						)
					)
					
					-- on tmLink tick do showLink()
				)
			)
			eMod = EmptyModifier name:"ScreenLock Reference"
			addModifier theCam eMod
			custAttributes.add eMod objAttrib
		)

		fn fnToggleLights state = (
			-- 定义检测是否为灯光的条件
			fn isLight obj = (
				-- 检测是否存在灯光核心属性
				(isProperty obj "on") and 
				(isProperty obj "enabled") and 
				(superClassOf obj == Light or 
				matchPattern (classOf obj as string) pattern:"*Light*")
			)
		
			-- 根据选择状态筛选灯光
			local targetLights = if selection.count > 0 then (
				for obj in selection where isLight obj collect obj
			) else (
				for obj in objects where isLight obj collect obj
			)
		
			-- 执行开关操作并记录状态
			if targetLights.count > 0 then (
				undo "Toggle Lights" on (
					for light in targetLights do (
						light.on = state
						light.enabled = state
					)
				)
				format "已切换 % 盏灯光状态\n" targetLights.count
			) else (
				messageBox "未找到可操作的灯光对象！" title:"警告"
			)
		)

		fn fnAddWaterMark text =
		(
			local sldWM = sliderManipulator isSelected:on hide:on sldName:text xPos:0.8 yPos:1 name:(uniquename "BsWaterMark")
			sldWM.isfrozen = on
			sldWM.showFrozenInGray = off
			-- actionMan.executeAction 0 "59225"  -- Tools: Select and Manipulate
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
			shellLaunch "https://space.bilibili.com/2031113/lists/560782" ""
		)

		on tabBsADT Selected itm do
		(
			arrID = (itm.TabPageIndex + 1)
			if LastSubRollout != arrID do --避免点击重复
			(
				fnChangeToolsVisble arrID
				if arrID == 3 then 
				(
					dotLVFilesList.pos = [5,50]
					local pathTex = ((getDir #scripts) + "\\BulletScripts\\Res\\BsSpriteTex\\*.*")
					arrEffTexFiles = (fnRefreshTexFiles dotLVFilesList "特效图集 [双击预览]  (叶孤弦 分享)" pathTex)
				)
				else (dotLVFilesList.pos = [5,-500])
				if arrID == 4 then 
				(
					dotFlowMatList.pos = [5,50]
					local pathTex = ((getDir #scripts) + "\\BulletScripts\\Res\\BsFlowTex\\*.*")
					arrFlowTexFiles = (fnRefreshTexFiles dotFlowMatList "其他材质 [双击预览]" pathTex)
					btnMaterial.visible = true 
					btnMaterial.pos = [145,225]
				)
				else 
				(
					dotFlowMatList.pos = [5,-500]
					if arrID == 1 then (btnMaterial.pos = [5,255] ;btnMaterial.visible = true)
				)
			) 
		)
		
		on rolBsAnimDemoTools open do
		(
			fnInitDotTabs()
			fnChangeToolsVisble (tabBsADT.SelectedIndex + 1)
			fnRefreshInitValue()
			fnRefreshTex()
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
				try(delete $'BsGhostTrails_*';completeRedraw();messagebox "清除 GhostTrails 刀光相关物体成功!                      " title:"BsAnimDemoTools")catch()
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
			else if args.Button == (dotNetClass "System.Windows.Forms.MouseButtons").Left then 
			(
				selEffTex = (fnSelTex dotLVFilesList arrEffTexFiles)
			)
		)

		on dotLVFilesList doubleClick sender args do
		(
			try(shellLaunch selEffTex "")catch(messageBox "打开失败,请检查路径是否存在...                        " title:"BsAnimDemoTools")
		)

		on dotFlowMatList mouseup sender args do
		(
			if args.Button == (dotNetClass "System.Windows.Forms.MouseButtons").Right then
			(
				shellLaunch ((getDir #scripts) + "\\BulletScripts\\Res\\BsFlowTex\\") ""
			)
			else if args.Button == (dotNetClass "System.Windows.Forms.MouseButtons").Left then 
			(
				selFlowTex = (fnSelTex dotFlowMatList arrFlowTexFiles)
			)
		)

		on dotFlowMatList doubleClick sender args do
		(
			try(shellLaunch selFlowTex "")catch(messageBox "打开失败,请检查路径是否存在...                        " title:"BsAnimDemoTools")
		)

		on btnOpenEffPath pressed do 
		(
			try(shellLaunch ((getDir #scripts) + "\\BulletScripts\\Res\\BsFlowTex\\") "")catch(messageBox "打开失败,请检查路径是否存在...                        " title:"BsAnimDemoTools")
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

		on btnOmniLight pressed do 
		(
			fnCreatLight "omniLight"
		)

		on btnSpotLight pressed do 
		(
			fnCreatLight "Targetspot"
		)

		on btnDirectLight pressed do 
		(
			fnCreatLight "TargetDirectionallight"
		)

		on btnSkyLight pressed do 
		(
			fnCreatLight "SkyLight"
		)

		on btnDeleteLight pressed do 
		(
			undo "deleteLight" on
			(
				try(delete $'BsLights*';completeRedraw();messagebox "清除灯光成功!                      " title:"BsAnimDemoTools")catch()
			)
		)

		on btnCameraPlane pressed do
		(
			with undo off (
				if (selection.count > 0) then (
					local cam = selection[1]
					if (superClassOf cam)==camera then (
						if (isProperty cam.modifiers[1] #screenLockRef_custProps)==false then (
							addCustomCtrls cam
							max modify mode
							messagebox "请查看右边修改器，添加参考图片...                        "
						)
					) else (
						messagebox "请先选择一个 Camera 相机！                                      "
					)
				) else (
					messagebox "请先选择一个 Camera 相机！                                      "
				)
			)
		)

		on btnSelectCameraPlane pressed do
		(
			try(select ($'CamRefPlane*' as array)[1])catch(messagebox "当前场景没有相机参考背景或者已被改名...                          ")
		)

		on btnRefCam pressed do 
		(
			try(select ($'CamRefPlane*' as array)[1].parent)catch(messagebox "相机参考背景面片可能已删除，请重新创建...                        ")
		)

		on btnLightOn pressed do 
		(
			fnToggleLights on
		)

		on btnLightOff pressed do 
		(
			fnToggleLights off
		)

		on ddlSkyBoxTex selected id do
		(
			local arrTexFiles = (fnGetFilesInPath ((getDir #scripts) + "\\BulletScripts\\Res\\BsSkyBox") ".hdr")
			selSkyBoxTex = arrTexFiles[id]
		)

		on btnOpenSkyBox pressed do 
		(
			try(shellLaunch selSkyBoxTex "")catch(messageBox "打开失败,请检查路径是否存在...                        " title:"BsAnimDemoTools")
		)
		on btnOpenSkyBox rightclick do 
		(
			try(shellLaunch ((getDir #scripts) + "\\BulletScripts\\Res\\BsSkyBox") "")catch(messageBox "打开失败,请检查路径是否存在...                        " title:"BsAnimDemoTools")
		)

		on btnCreateSkyBox pressed do 
		(
			-- 创建唯一名称天空球
			local skySphere = Sphere radius:10000 segs:64 smooth:on name:(uniquename"BS_SkySphere")
    
			-- 添加Normal修改器并翻转法线
			addModifier skySphere (Normalmodifier flip:on)
			
			-- 设置背面消隐
			skySphere.backfacecull = on
			
			--否则预览窗不会显示贴图
			skySphere.mapcoords = on
			
			-- 创建环境材质
			local skyMat = StandardMaterial()
			skyMat.name = uniquename "SKY_MAT"
			skyMat.selfIllumAmount = 100  -- 自发光100%
			skyMat.showInViewport = true
			
			-- 设置环境贴图
			local envTex = Bitmaptexture fileName:rolBsAnimDemoTools.selSkyBoxTex gamma:1.0
			envTex.coordinates.mappingType = 1
			envTex.coordinates.mapping = 0  -- Spherical Environment
			skyMat.diffuseMap = envTex
			
			-- 设置材质给天空球
			skySphere.material = skyMat

			--设置颜色模式
			try(
				-- 启用Gamma校正并设置参数
				IDisplayGamma.colorCorrectionMode = #gamma  -- 启用Gamma校正模式:cite[4]
				IDisplayGamma.gamma = 2.2  -- 标准Gamma值（通常为2.2，根据需求调整）:cite[4]:cite[9]
				fileInGamma = 1.0  -- 输入贴图的Gamma值（默认1.0表示线性空间）:cite[4]
				fileOutGamma = 2.2  -- 输出图像的Gamma值:cite[4]

				-- 强制更新渲染设置（确保参数生效）
				renderers.current.settings.applyGammaCorrection = true
			)catch()
			---高版本3dsmax
			try(ColorPipelineMgr.mode = #OCIO_Default)catch()

			select skySphere
			completeRedraw()
			messagebox "天空球创建成功!请自行缩放大小。                      " title:"BsAnimDemoTools"
		)

		on btnDeleteSkyBox pressed do 
		(
			undo "deleteSkyBox" on
			(
				try(delete $'BS_SkySphere*';completeRedraw();messagebox "清除天空球成功!                      " title:"BsAnimDemoTools")catch()
			)
		)

		on btnCreateFloor pressed do 
		(
			-- 创建平面对象
			local floor_plane = plane length:100000 width:100000 pos:[0,0,0] isSelected:on name:(uniquename"BS_FloorPlane")

			-- 创建标准镜面材质
			floor_mat = standard()
			floor_mat.name = "Standard_Mirror"
			floor_mat.shaderType = 3  -- 使用Metal shader类型

			-- 核心镜面参数
			floor_mat.ambient = color 0 0 0    -- 环境色归零
			floor_mat.diffuse = color 0 0 0    -- 漫反射关闭
			floor_mat.specularLevel = 98      -- 高光强度
			floor_mat.glossiness = 97         -- 光泽度
			-- floor_mat.soften = 0.1            -- 高光柔化
			floor_mat.selfIllumAmount = 0     -- 自发光关闭

			-- 反射控制
			floor_mat.reflectionMapEnable = true
			floor_mat.reflectionMapAmount = 85  -- 反射强度
			-- floor_mat.useEnvironmentMap = true  -- 使用环境贴图

			-- 创建平面反射贴图（可选）
			reflectionMap = FlatMirror()
			-- reflectionMap.numBlurFrames = 3     -- 模糊帧数
			reflectionMap.applyBlur = true      -- 启用模糊
			floor_mat.reflectionMap = reflectionMap

			-- 材质高级设置
			-- floor_mat.superSample = on          -- 启用超级采样
			floor_mat.twoSided = off           -- 单面显示
			floor_mat.falloffType = 1          -- 衰减类型：垂直
			floor_mat.opacityFalloff = 50      -- 边缘透明度衰减

			-- 应用材质到平面
			floor_plane.material = floor_mat

			-- 视口显示优化
			floor_plane.backfaceCull = on       -- 背面消隐
			floor_plane.showVertexColors = off  -- 关闭顶点色显示

			select floor_plane
			messagebox "地面创建成功!请自行缩放大小。                      " title:"BsAnimDemoTools"
		)

		on btnReflection pressed do 
		(
			try(
				local BS_floor = $'BS_FloorPlane*'[1]
				BS_floor.material.reflectionMapEnable = not BS_floor.material.reflectionMapEnable
				if BS_floor.material.reflectionMapEnable then (completeRedraw();messagebox "开启地板镜面反射成功!                               " title:"BsAnimDemoTools")
				else (completeRedraw();messagebox "关闭地板镜面反射成功!                               " title:"BsAnimDemoTools")
			)catch(messagebox "找不到地板面片，或者命名不是\"BS_FloorPlane*\"                                 " title:"BsAnimDemoTools")
		)

		on btnDeleteFloor pressed do 
		(
			undo "deleteFloor" on
			(
				try(delete $'BS_FloorPlane*';completeRedraw();messagebox "清除地面成功!                      " title:"BsAnimDemoTools")catch()
			)
		)

		on btnUnfreezeFloor pressed do 
		(
			try
			(
				$'BS_FloorPlane*'[1].isfrozen = off
				$'BS_FloorPlane*'[1].showFrozenInGray = off
				select $'BS_FloorPlane*'[1]
			)catch()
		)

		on btnFreezeFloor pressed do 
		(
			try
			(
				$'BS_FloorPlane*'[1].isfrozen = on
				$'BS_FloorPlane*'[1].showFrozenInGray = off
				clearselection()
			)catch()
		)

		on btnMakePreview pressed do 
		(
			createPreview percentSize:100 \
			dspGeometry:true dspShapes:false dspLights:false \
			dspCameras:false dspHelpers:false dspParticles:true dspBones:false \
			dspGrid:true dspSafeFrame:false dspFrameNums:false dspBkg:true \
			rndLevel:#smoothhighlights
		)
	
		on btnOpenPrevPath pressed do (shellLaunch (getdir #preview) "")

		on btnMakeRenderer pressed do 
		(
			max quick render
		)

		on btnClearAll pressed do 
		(
			undo "deleteAllEnv" on
			(
				try(
					delete $'BS_FloorPlane*';
					delete $'BS_SkySphere*'
					delete $'BsLights*'
					completeRedraw()
					messagebox "清除环境成功!                      " title:"BsAnimDemoTools"
				)catch()
			)
		)

		on ckbApplyEffMat changed state do 
		(
			ckbApplyEffMat.state = true
			try(fnApplyMat $ selFlowTex cutout:ckbOpacityMat.state)catch(messageBox "失败,请检查是否选中左侧材质和场景内物体...             " title:"BsAnimDemoTools")
		)

		on btnClearMat pressed do 
		(
			try(fnSetDefaultMat $)catch(messageBox "失败,请检查是否选中场景内物体...             " title:"BsAnimDemoTools")
		)

		on ckbApplyLineMat changed state do 
		(
			ckbApplyLineMat.state = true
			if selection.count != 0 then 
			(
				for i in selection where i != undefined do 
				(
					outlineMesh = copy i 
					outlineMesh.name = uniquename (i.name + "_BsOutLine")
					-- 添加Normal修改器并翻转法线
					addModifier outlineMesh (Normalmodifier flip:on)
					addModifier outlineMesh (push ui:on pushvalue:-3) 
					-- 设置背面消隐
					outlineMesh.backfacecull = on
					
					--否则预览窗不会显示贴图
					outlineMesh.mapcoords = on
					
					-- 创建描边材质
					local outlineMat = InkNPaint()
					outlineMat.name           = uniquename "OUTLINE_MAT"
					outlineMat.paint_color    = cpLineColor.color
					outlineMat.showInViewport = true
					outlineMesh.material      = outlineMat
					select outlineMesh
					-- setCommandPanelTaskMode mode: #modify
				)
				completeRedraw()
				messageBox "创建描边完成,请调整右侧 Push Value (通常为负数)...                              " title:"BsAnimDemoTools"
			)
			else (messageBox "失败,请检查是否选中场景内物体...             " title:"BsAnimDemoTools")
		)

		on btnSelLineMesh pressed do 
		(
			try(select $'*_BsOutLine*'[1])catch(messageBox "失败,可能场景内没有描边物体或命名已被修改...                            " title:"BsAnimDemoTools")
		)

		on btnUnFreezeLineMesh pressed do 
		(
			try
			(
				$'*_BsOutLine*'[1].isfrozen = off
				$'*_BsOutLine*'[1].showFrozenInGray = off
				select $'*_BsOutLine*'[1]
			)catch()
		)

		on btnFreezeLineMesh pressed do 
		(
			try
			(
				$'*_BsOutLine*'[1].isfrozen = on
				$'*_BsOutLine*'[1].showFrozenInGray = off
				clearselection()
			)catch()
		)

		on btnDeleteLine pressed do 
		(
			undo "deleteBsOutLine" on
			(
				try(delete $'*_BsOutLine*';completeRedraw();messagebox "清除 BsOutLine 描边相关物体成功!                        " title:"BsAnimDemoTools")catch()
			)
		)

		on btnTint pressed do 
		(
			actionMan.executeAction 0 "40029"  -- Render: Environment Dialog Toggle
		)

		on btnRenderSet pressed do
		(
			actionMan.executeAction 0 "60010"  -- Render: Render SetUp...
		)

		on btnReCollectMat pressed do 
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
				btnReCollectMat.caption = "整理 | #" + k as string + "页"
			)
			if scenematerials.count==0 do (pushPrompt ("本场景没有任何材质"))
			enableSceneRedraw()
		)

		on btnAddWaterMark pressed do
		(
			if edtWatermarkText.text != "" then 
			(
				fnAddWaterMark edtWatermarkText.text
				completeRedraw()
				messageBox "水印添加成功!请在右侧属性面板中调整位置...\r\n\r\n文字大小只有这么大, 勉强可做文件个人标记~\r\n\r\n高级水印请用后期添加!                                                  " title:"BsAnimDemoTools"
			)
			else 
			(
				messageBox "请先在左侧输入水印文字...                          " title:"BsAnimDemoTools"
			)
		)

		on btnSelWM pressed do (actionMan.executeAction 0 "59225";select $BsWaterMark*[1])

		on btnDelWM pressed do 
		(
			undo "deleteWaterMark" on
			(
				try(delete $BsWaterMark*;completeRedraw();messagebox "清除水印成功!                      " title:"BsAnimDemoTools")catch()
			)
		)

		on btnApplyPureToonMat pressed do 
		(
			if selection.count != 0 then 
			(
				for i in selection where i != undefined do 
				(
					-- 创建纯色材质
					local pureToonMat = StandardMaterial()
					pureToonMat.name = uniquename "BsPureToonMat"
					pureToonMat.diffuse = cpPureToonColor.color
					pureToonMat.selfIllumAmount = 0
					pureToonMat.showInViewport = true
					i.material = pureToonMat
					select i
				)
				completeRedraw()
				messageBox "创建纯色材质成功!请自行调整颜色...                      " title:"BsAnimDemoTools"
			)
			else (messageBox "失败,请检查是否选中场景内物体...             " title:"BsAnimDemoTools")
		)
	)
	createDialog rolBsAnimDemoTools style:#()
)