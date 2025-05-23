try(destroydialog BsVportTools)catch()
try (callbacks.removeScripts #filePostOpen id:#UpdateBsVport) catch ()

global iniPosVportTools
global BsVportTools
global vpdStruct
global fnRefreshVportSet
global arrVportValue = #()
global fileINISave = ""
global iniVportToolsWidth = 415
global pathVportLog = ((getdir #temp) + "\\BsVportLog")
if (not(doesDirectoryExist pathVportLog)) then (HiddenDosCommand ("mkdir " + "\"" +pathVportLog + "\""))

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false title:"BsVportTools")
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false title:"BsVportTools")
stLoadConfigAll.fnLoadConfigVportTools ()

struct vpdStruct (vpListName = "undefined",vpType = #view_none, vpGroupType = #user, vpStartCoord = [0,0,0], vpEndCoord = [0,0,0], vpVS = [0,0], vpFOV = 0, vpFD = 0, vpTM = undefined, vpNode = undefined)

rcmenu menuBsVportRightClick
(
	menuItem mItemDelVportSet "删除"

	on mItemDelVportSet picked do
	(
		BsVportTools.fnDelVportSet()
	)
)

rollout BsVportTools "BsVportTools_v1.1"
(
	MultiListBox mlbVportSet "" width:143 height:15 pos:[3,65]
	button btnCreateCam "" width:40 height:35 pos:[5,5] tooltip:"以 \"P\" 自由视角创建相机"
	button btnSaveVportINI "" width:30 height:20 pos:[45,5] tooltip:"保存导出视角列表"
	button btnLoadVportINI "" width:30 height:20 pos:[75,5] tooltip:"加载导入视角列表"
	button btnDelVportSet "" width:20 height:20 pos:[105,5] tooltip:"移除所选视角"
	button btnImage "" width:20 height:20 pos:[125,5] tooltip:"切换是否显示视窗截图\r\n功能简述：保存当前视角参数\r\n完全不影响文件本身，只存参数\r\n随文件名保存的历史记录上限 50 条"
	edittext edtAddVport "" width:145 height:17 pos:[0,45]
	button btnAddVportSet "" width:80 height:15 pos:[45,25] tooltip:"保存当前视角"
	button btnRefreshPreview "R" width:20 height:15 pos:[125,25] tooltip:"刷新"

	dotnetcontrol btnPreview "button" pos:[150,5] width:260 height:260

	fn fnDotnetBitmap fName =
	(
		if doesFileExist fName then
		(
			local img = (dotnetclass "System.Drawing.Image").fromfile fName 
			local retBmp = dotnetObject "System.Drawing.Bitmap" img.Width img.height img.PixelFormat
			local g = (dotnetclass "system.drawing.graphics").fromImage retBmp
			g.SmoothingMode      = g.SmoothingMode.HighQuality
			g.CompositingQuality = g.CompositingQuality.HighQuality
			g.InterpolationMode  = g.InterpolationMode.HighQualityBicubic
			g.PixelOffsetMode    = g.PixelOffsetMode.highQuality
			g.drawimage img 0 0 img.Width img.height
			img.Dispose();
			retBmp
		)
		else return undefined
	)

	fn fnReloadPreview =
	(
		filename = (substituteString fileINISave ".ini" ("_" + ((BsVportTools.mlbVportSet.selection as array)[1]) as string + ".bmp"))
		btnPreview.image = (fnDotnetBitmap filename)
	)
	
	local views = #(#view_persp_user, #view_iso_user, #view_top, #view_bottom, #view_left, #view_right, #view_front, #view_back, #view_spot, #view_camera)

	fn getFilesequenceFile f &base &digits = 
	(
		f = getFilenameFile f
		base = trimRight f "0123456789"
		digits = subString f (base.count + 1) -1
	)

	fn fnPseudoNaturalSort a b =  --文件名排序新方法--https://forums.cgsociety.org/t/sorting-filenames/1219205/4
	(
		a = a as string
		b = b as string
		getFilesequenceFile a &aBase &aDigits
		-- hackhackhack.  This pads a number with zeros to 6 digits without using a loop.
		-- things will fail if there's more digits.. 6 'seems' safe.
		aDigits = subString ((1000000 + (aDigits as integer)) as string) 2 -1
		getFilesequenceFile b &bBase &bDigits
		bDigits = subString ((1000000 + (bDigits as integer)) as string) 2 -1
		a = aBase + aDigits
		b = bBase + bDigits
	
		case of (
		(a == b): 0
		(a < b): -1
		(a > b): 1
		)
	)

	fn fnCreateFromCam =
	(
		if ((maxVersion())[1] < 18000) then 
		(macros.run "Lights and Cameras" "Camera_CreateFromView")
		else(macros.run "Lights and Cameras" "StandardCamera_CreateFromView")
	)

	fn fnGetVportINI fileINI nameAttrClass nameAttr valueAttr =  --设置初始信息方法
	(
		local oldPrintAllElements  = options.printAllelements
		options.printAllelements = true
		attr = (GetINISetting fileINI nameAttrClass nameAttr) as string  --先提取文件中的记录
		if (attr == "") or (attr == "undefined") then (attr = execute valueAttr) else (attr = execute attr) --判断记录为空与否得到需要的记录参数
		options.printAllelements = oldPrintAllElements
		attr
	)
	
	fn fnSaveVportINI ignoreMsg:false =
	(
		-- if maxfilename != ""then
		-- (
			arrINIFile = getFiles (pathVportLog + "\*.ini")
			qsort arrINIFile BsVportTools.fnPseudoNaturalSort
			arrFileCount = #()
			arrFileName = #()
			if arrINIFile.count != 0 then
			(
				for f in arrINIFile do
				(
					nameTemp = getfilenamefile f
					append arrFileCount nameTemp
					append arrFileName ((GetINISetting f "BsVportToolsSet" "MaxFile") as string)
					qsort arrFileCount BsVportTools.fnPseudoNaturalSort
				)
				saveCount = (execute arrFileCount[arrFileCount.count]) + 1
			)
			else (saveCount = 1)
			fileINI = pathVportLog + "\\" + saveCount as string + ".ini"
			nameFile = (maxfilepath + maxfilename)
			if finditem arrFileName nameFile != 0 do
			(
				if not ignoreMsg then
				(
					if (queryBox "当前文件已存在视角镜头配置，是否覆盖？                        " \
					title:"BsVportTools" beep:false) then
					(
						fileINI = arrINIFile[finditem arrFileName nameFile]
					)
					else (return false)
				)
				else (fileINI = arrINIFile[finditem arrFileName nameFile])
			)
			SetINISetting fileINI "BsVportToolsSet" "ListCount" (arrVportValue.count as string)
			SetINISetting fileINI "BsVportToolsSet" "MaxFile" (maxfilepath + maxfilename)
			delIniSetting fileINI "BsVportToolsList"
			for i = 1 to arrVportValue.count do
			(
				SetINISetting fileINI "BsVportToolsList" (i as string) (arrVportValue[i] as string)
			)
			fileINISave = fileINI
			arrINIFile = getFiles (pathVportLog + "\*.ini")
			qsort arrINIFile BsVportTools.fnPseudoNaturalSort
			if arrINIFile.count > 50 then 
			(
				deletefile arrINIFile[1]
				for i in (getfiles (substituteString arrINIFile[1] ".ini" ("_*.bmp"))) do 
				(
					deletefile i
				)
			)
			return true
		-- )
	)

	fn fnUpdateVportList = 
	(
		if arrVportValue.count != 0 then
		(
			mlbItems = #()
			for i in arrVportValue do 
			(
				if (i.vpNode) != undefined then
				(
					if (getnodebyname i.vpNode) != undefined then 
					(
						append mlbItems ("[" + i.vpNode + "]_" + i.vpListName)
					)
					else 
					(
						append mlbItems ("[丢失" + i.vpNode + "]_" + i.vpListName)
					)
				)
				else append mlbItems ("[" + (BsVportTools.fnSwitchTypeString i.vpType) + "]_" + i.vpListName)
			)
			BsVportTools.mlbVportSet.items = mlbItems
		)
		else (BsVportTools.mlbVportSet.items = arrVportValue;edtAddVport.text = "")
	)

	fn fnLoadVportINI fileINI =
	(
		listCount = (fnGetVportINI fileINI "BsVportToolsSet"  "ListCount" "0")
		if listCount != 0 then
		(
			for i = 1 to listCount do
			(
				valueVport = (fnGetVportINI fileINI "BsVportToolsList" (i as string) (with printAllelements on ("" as string)))
				if valueVport != "" then append arrVportValue valueVport
			)
			BsVportTools.fnUpdateVportList()
		)
		else (messagebox ("未读取到镜头配置，文件已损坏或所选文件类型不对，请检查~                                ") beep:false title:"BsVportTools")
	)

	fn fnRefreshVportSet =
	(
		-- if maxfilename != "" then
		-- (
			arrVportValue = #()
			arrINIFile = getFiles (pathVportLog + "\*.ini")
			qsort arrINIFile BsVportTools.fnPseudoNaturalSort
			arrFileName = #()
			if arrINIFile.count != 0 then
			(
				for f in arrINIFile do
				(
					append arrFileName ((GetINISetting f "BsVportToolsSet" "MaxFile") as string)
				)
				nameFile = (maxfilepath + maxfilename)
				if finditem arrFileName nameFile != 0 then
				(
					fileINISave = arrINIFile[finditem arrFileName nameFile]
					BsVportTools.fnLoadVportINI fileINISave

				)
				else (BsVportTools.fnUpdateVportList())
			)
			-- else (BsVportTools.fnUpdateVportList())
		-- )
	)

	fn fnSwitchTypeString vpType =
	(
		case vpType of 
		(
			(#view_top):(return "Top")
			(#view_bottom):(return "Bottom") 
			(#view_right):(return "Right") 
			(#view_left):(return "Left")
			(#view_front):(return "Front")
			(#view_back):(return "Back") 
			(#view_persp_user):(return "Pers")
			(#view_iso_user):(return "User")
			(#view_camera):(return "Camera") 
			(#view_spot):(return "Light") 
			(#view_shape):(return "Shape")
			(#view_grid):(return "Grid")
			default:(return "Undefined")
		)
	) 

	fn checkVT views vt = 
	( 
		local idx = (findItem views vt)
		case of
		(
			(idx > 0 and idx < 3): #user
			(idx > 2 and idx < 9): #ortho
			(idx > 8): #camlight
			(idx == 0):  undefined
		)
	)
	fn p2Top3 value = point3 value.x value.y 0
	fn p3Top2 value = point2 value.x value.y
	fn minmaxSwap p3min p3max =
	(
		if p3min.x > p3max.x do swap p3min.x p3max.x
		if p3min.y > p3max.y do swap p3min.y p3max.y
		if p3min.z > p3max.z do swap p3min.z p3max.z
		#(p3min, p3max)
	)
	fn collectVPD supportedViews:views =
	(
		local vpd = vpdStruct()
		local bounds = minmaxSwap ((MapScreenToView [0,0] 0) * Inverse(getViewTM())) ((MapScreenToView (GetViewSize()) 0) * Inverse(getViewTM()))

		vpd.vpListName = (if ((BsVportTools.edtAddVport.text != "") or (BsVportTools.edtAddVport.text != undefined)) then (BsVportTools.edtAddVport.text))
		vpd.vpType = (viewport.getType())
		vpd.vpGroupType = checkVT supportedViews vpd.vpType
		vpd.vpStartCoord = bounds[1] 
		vpd.vpEndCoord = bounds[2] 
		vpd.vpVS = GetViewSize()
		vpd.vpFOV = getViewFOV()
		vpd.vpFD = viewport.getFocalDistance()
		vpd.vpTM = viewport.getTM()
		vpd.vpNode = if (node = viewport.getCamera()) != undefined then (node.name)
		vpd
	)
	fn restoreViewport vpd =
	(
		local deadData = off
		viewport.SetType vpd.vpType
		case vpd.vpGroupType of
		(
			#user:
			(
				viewport.setTM vpd.vpTM
				if vpd.vpType == #view_persp_user then (viewport.SetFOV vpd.vpFOV ; viewport.SetFocalDistance vpd.vpFD)
				else (viewport.ZoomToBounds off vpd.vpStartCoord vpd.vpEndCoord ; viewport.zoom (vpd.vpFOV/(viewport.getFOV())))
			)
			#ortho:
			(
				viewport.ZoomToBounds off vpd.vpStartCoord vpd.vpEndCoord
				viewport.zoom (vpd.vpFOV/(viewport.getFOV()))
			)
			#camlight: (if isValidNode (getnodebyname vpd.vpNode) and viewport.canSetToViewport (getnodebyname vpd.vpNode) then viewport.setCamera (getnodebyname vpd.vpNode) else deadData = on)
		) ; completeredraw() ; deadData
	)
	
	fn fnMakeThumbnail filename =(
		grab_bmp = gw.getViewportDib()
		croppedScreenGrab = bitmap grab_bmp.height grab_bmp.height 
		pasteBitmap grab_bmp croppedScreenGrab [((grab_bmp.width - grab_bmp.height)/2)+1,1] [0,0]  -- paste the orginal image to the tempImage, this results in a cropped image widh same height as width
		outputMap  = bitmap (btnPreview.width - 2) (btnPreview.width - 2)
		copy croppedScreenGrab outputMap 
		close grab_bmp
		close croppedScreenGrab
		
		gc light:true
		outputMap.filename = filename
		save outputMap quiet:true
		return true
	)

	fn fnAddVportSet = 
	(
		-- if maxfilename != "" then
		-- (
			if ((BsVportTools.edtAddVport.text != "") and (BsVportTools.edtAddVport.text != undefined)) then
			(
				saveVpd = (BsVportTools.collectVPD())
				existCount = 0
				for i = 1 to arrVportValue.count do 
				(
					if arrVportValue[i].vpListName == BsVportTools.edtAddVport.text then
					(
						arrVportValue[i] = saveVpd
						existCount = i
					)
				)
				if existCount == 0 then 
				(
					append arrVportValue saveVpd
					BsVportTools.fnSaveVportINI ignoreMsg:true
					BsVportTools.fnUpdateVportList()
					BsVportTools.mlbVportSet.selection = arrVportValue.count
				)
				else 
				(
					BsVportTools.fnUpdateVportList()
					BsVportTools.mlbVportSet.selection = existCount
				)
				filename = (substituteString fileINISave ".ini" ("_" + ((BsVportTools.mlbVportSet.selection as array)[1]) as string + ".bmp"))
				forceCompleteRedraw()
				fnMakeThumbnail filename
				fnReloadPreview()
				btnPreview.text = BsVportTools.mlbVportSet.items[(BsVportTools.mlbVportSet.selection as array)[1]]
			)
		-- )
	)

	fn fnDelVportSet = 
	(
		if (BsVportTools.mlbVportSet.selection as array).count != 0 then
		(
			if (queryBox "是否确认删除选中视角镜头参数？                   " \
			title:"BsVportTools" beep:false) then
			(
				arrDelID = (BsVportTools.mlbVportSet.selection as array)
				-- print arrDelID
				for i = arrDelID.count to 1 by -1 where arrDelID.count != 0 do 
				(
					deleteitem arrVportValue arrDelID[i]
					deleteFile (substituteString fileINISave ".ini" ("_" + arrDelID[i] as string + ".bmp"))
					print (substituteString fileINISave ".ini" ("_" + arrDelID[i] as string + ".bmp"))
				)
				fnUpdateVportList()
				BsVportTools.mlbVportSet.selection = 0
				BsVportTools.fnSaveVportINI ignoreMsg:true
			)
		)
	)

	on btnRefreshPreview pressed do 
	(
		BsVportTools.mlbVportSet.selection = 0
		btnPreview.image = undefined
		edtAddVport.text = ""
	)

	on btnImage pressed do 
	(
		if BsVportTools.width == 415 then
		(
			BsVportTools.width = 150
		)
		else 
		(
			BsVportTools.width = 415
		) 
		iniVportToolsWidth = BsVportTools.width
	)

	on BsVportTools open do
	(
		stLoadConfigAll.fnLoadConfigVportTools()  ---------------脚本位置等赋值
		stSetConfigAll.fnSetConfigVportTools()  ----------------保存位置信息到ini文件
		btnAddVportSet.images  = #("enss_tools_16i.bmp","enss_tools_16a.bmp",13,5,5,6,6,false,true)
		btnDelVportSet.images  = #("enss_tools_16i.bmp","enss_tools_16a.bmp",13,3,3,4,4,false,true)
		btnSaveVportINI.images = #("bip_general_i.bmp","bip_general_i.bmp",30,7,7,8,8,false,true)
		btnLoadVportINI.images = #("bip_general_i.bmp","bip_general_i.bmp",30,5,5,6,6,false,true)
		btnImage.images         = #("UVWUnwrapView_16i.bmp","UVWUnwrapView_16i.bmp",28,15,15,16,16,false,false)
		btnCreateCam.images    = #("Cameras_24i.bmp","Cameras_24i.bmp",3,3,3,3,3,false,true)
		fnRefreshVportSet()
		fnUpdateVportList()

		btnPreview.flatstyle                         = btnPreview.flatstyle.flat
		btnPreview.FlatAppearance.BorderSize         = 1
		btnPreview.backcolor                         = BsDotBackColor
		btnPreview.forecolor                         = dotColor.FromArgb white.r white.g white.b
		btnPreview.FlatAppearance.MouseDownBackColor = BsDotBackColor
		btnPreview.FlatAppearance.MouseOverBackColor = BsDotBackColor
		-- btnPreview.text = "视窗镜头预览图"
		btnPreview.TextAlign = (dotnetclass "system.drawing.contentalignment").TopLeft
		btnPreview.image = undefined
	)

	on BsVportTools close do -- 关闭记忆浮动窗口位置
	(
		iniPosVportTools = (GetDialogPos BsVportTools)
        stSetConfigAll.fnSetConfigVportTools ()
		BsVportTools.fnSaveVportINI ignoreMsg:true
		try (callbacks.removeScripts #filePostOpen id:#UpdateBsVport) catch ()
	)

	-- on edtAddVport entered txt do
	-- (
	-- 	fnAddVportSet()
	-- )

	on btnSaveVportINI pressed do
	(
		if arrVportValue.count != 0 then
		(
			fnSaveVportINI()
		)
		else (messagebox "请先保存视角镜头参数再储存配置！                    " title:"BsVportTools" beep:false)
	)	

	on btnLoadVportINI pressed do
	(
		local pathLoad = getOpenFileName caption:"Load INI File" types:"INI(*.ini)|*.ini|All(*.*)|*.*" historyCategory:"BsVportLog" filename:(pathVportLog + @"\")
		if pathLoad != undefined then
		(
			fnLoadVportINI pathLoad
		)
	)

	on mlbVportSet doubleClicked val do 
	(
		valueVpd = arrVportValue[(mlbVportSet.selection as array)[1]]
		restoreViewport valueVpd
	)

	on mlbVportSet selected arg do
	(
		if (BsVportTools.mlbVportSet.selection as array).count == 1 then
		(
			fnReloadPreview()
			btnPreview.text = BsVportTools.mlbVportSet.items[(BsVportTools.mlbVportSet.selection as array)[1]]
		)
		else (btnPreview.image = undefined;btnPreview.text = "(暂时仅能预览选中一个)")
	)
	
	on mlbVportSet rightclick do 
	(
		popupmenu menuBsVportRightClick
	)

	on btnAddVportSet pressed do
	(
		fnAddVportSet()
	)

	on btnDelVportSet pressed do undo "RemoveVportSet" on
	(
		fnDelVportSet()
	)

	on btnCreateCam pressed do 
	(
		If (viewport.Gettype() == #view_persp_user) and (not theHold.Holding()) then 
		(
			BsVportTools.fnCreateFromCam()
			if BsVportTools.edtAddVport.text == "" then BsVportTools.edtAddVport.text = "noName"
			BsVportTools.fnAddVportSet()
			viewport.setCamera $
			(messagebox ("已移动或创建相机:  " + $.name + "\r\n\r\n可去自带修改面板更改相机类型。              ") beep:false title:"BsVportTools")
		)
		else (messagebox "请按“P”在自由视角创建，之后可能优化为任意视角~                  " beep:false title:"BsVportTools")
	)

)
if (iniPosVportTools != 0) then 
(Createdialog BsVportTools iniVportToolsWidth 270 fgcolor:myFgColor pos:iniPosVportTools style:#(#style_titlebar, #style_sysmenu, #style_toolwindow))
else (Createdialog BsVportTools iniVportToolsWidth 270 fgcolor:myFgColor style:#(#style_titlebar, #style_sysmenu, #style_toolwindow))

callbacks.addScript #filePostOpen "BsVportTools.fnRefreshVportSet()" id:#UpdateBsVport