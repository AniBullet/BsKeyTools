try (destroydialog rolREAnimTools) catch ()
global rolREAnimTools
global rolMotViewer
global formNoesisCMD
global FBXBatchProcessor
global motImport
global motPath
global selCurGameID
global motExt
global noesis_path
global output_path
global arrMotFilesLoaded

rollout rolREAnimTools "RE_AnimTools_v1.5_Bullet.S" height:105 width:305
(
	local arrGamesName = #("MHWsOBT-怪物猎人荒野公测版","MHWs-怪物猎人荒野正式版","MHRise-怪物猎人崛起","MHRSunbreak-怪物猎人崛起曙光")

	label lblSelectGameMode "请选择目标游戏：" pos:[12,8] width:80
	dropdownlist ddlCurGames "" items:arrGamesName pos:[100,5] width:190
	subrollout subRolImporter "Importer" height:800 width:280
	
	fn fnRefreshMotExt selCurGameID =
	(
		case (selCurGameID as string) of
		(
			"1":motExt = ".959"
			"2":motExt = ".992"
			"3":motExt = ".484"
			"4":motExt = ".528"
			default:motExt = ".959"
		)
		motExt
	)

	on rolREAnimTools open do 
	(
		setdialogpos rolREAnimTools ((getdialogpos rolREAnimTools) + [400,-500])
		if selCurGameID != undefined and selCurGameID != 0 then ddlCurGames.selection = selCurGameID
		else selCurGameID = 2
		ddlCurGames.selection = selCurGameID
		fnRefreshMotExt selCurGameID
		-- print selCurGameID
	)

	on ddlCurGames selected id do 
	(
		selCurGameID = id
		fnRefreshMotExt selCurGameID
		rolMotViewer.fnRefreshMotFiles()
	)
)

rollout formNoesisCMD "Motlist Anim Importer"
(
	on formNoesisCMD rolledUp state do (if not state then rolREAnimTools.height -= 340 else rolREAnimTools.height += 340)
	
	group "Import" (
		button btn_import "Import MHWs Animation" width:230 align:#center
		checkbox chk_resetScene "导入时重置场景 | Reset On Import" checked:true align:#left
		checkbox chk_legacyFBX "使用旧板FBX | Use Legacy FBX" checked:false align:#left 
		checkbox chk_noefbxmulti "导出分离动画片断 | noefbxmulti" checked:false align:#left enabled:true
	)
	group "Config" (
		checkbox chk_OnlyAnim "仅导入更新动画 | Only Update Anim" checked:false align:#left
		checkbox chk_showPlugOpt  "显示FBX窗口 | Show FBX Options" checked:false align:#left
		checkbox chk_delFBX  "删除转换的FBX | Delete FBX Files" checked:false align:#left
		checkbox chk_showCMD  "显示调试窗口 | Show Console" checked:false align:#left enabled:true
		checkbox chk_keepFolder "保持文件夹结构 | Keep Folder Structure" checked:false align:#left
		label lbl_noesis "导出工具 | Noesis Path:" align:#left
		edittext edt_noesis "" align:#left width:170 across:2
		button btn_noesis "选择文件" align:#right
		label lbl_OutputPath "导出保存目录 | OutputPath:" align:#left
		edittext edt_output "" align:#left width:170 across:2
		button btn_output "选择目录" align:#right
		button btn_openpath ">> 打开转换后的 FBX 导出目录 <<" align:#center width:(rolREAnimTools.subRolImporter.width - 30)
		-- label lbl_scnpath "解出资源 | Extracted Pak Path:" align:#left
		-- edittext edt_scnpath "" align:#left width:180 across:2
		-- button btn_scnpath "Browse" align:#right
	)
	local ScaleValue   = 1.0
	local cmd          = ""
	local fbx_path     = ""
	local CB_GETCOUNT  = 0x0146
	local CB_GETCURSEL = 0x0147
	local CB_SETCURSEL = 0x014E
	local WM_COMMAND   = 0x0111
	
	fn noesisComponentsFound = (
		local state = false
		if noesis_path != undefined do 
		(
			if doesFileExist noesis_path do (
				state = true
			)
		)
		state
	)
	
	fn Import_MESH cmd setCoords = (
		
		
		if cmd == undefined then 
			cmd = "undefined"
		
		
		if doesFileExist cmd and cmd != undefined then (
			local showFbxOptions = chk_showPlugOpt.checked
			
			local files = #(cmd)
			
			for f = 1 to files.count do (
				cmd = files[f]
				
				local thisExt = getFilenameType cmd
				local orig_path = cmd
				local key = getFilenameFile (getFilenameFile cmd)
				
				if chk_resetScene.checked do 
					resetMaxFile #noPrompt
				
					framerate = 60
					fbx_path = (getFilenamePath cmd) + key
					outtxt_path = fbx_path + ".txt"
					
					-- 根据选项决定是否保持文件夹结构
					if chk_keepFolder.checked and motPath != undefined and motPath != "" then
					(
						local relativePath = substituteString (getFilenamePath cmd) (motPath + @"\") ""
						local fullOutputDir = output_path + @"\\" + relativePath
						makeDir fullOutputDir all:true
						fbx_path = fullOutputDir + key + ".fbx"
					)
					else
					(
						fbx_path = output_path + @"\\" + key + ".fbx"
					)
					
					cmd = (
						"\"" + noesis_path + "\" ?cmode \"" + cmd + "\" \"" + fbx_path + "\"" \
						+ " " + (if chk_legacyFBX.checked then " -fbxoldexport -fbxexportver FBX201400" else "")
					)
					if chk_noefbxmulti.checked then
					(
						cmd = cmd + " -fbxmultitake -animoutex .noefbxmulti"
						substituteString cmd ".fbx" ".noefbxmulti"
					)

					if chk_showCMD.checked then (
						DOSCommand ("\"" + cmd + " -logfile \"" + outtxt_path + "\"") 
					) else (
						HiddenDOSCommand ("\"" + cmd + " -logfile \"" + outtxt_path + "\"") startpath:(getFilenamePath noesis_path) donotwait:false
					)
					
					format "Import Command:\n%\n" cmd
					
					if doesFileExist outtxt_path and outtxt_path != undefined then (
						local fs = openFile outtxt_path
						if fs != undefined then (
							local noesisOutput = "\n"
							while not eof fs do
								noesisOutput = noesisOutput + (readline fs) + "\n"
							print noesisOutput
							close fs
							deletefile outtxt_path
							if findstring noesisOutput "Traceback" != undefined then 
								return false
						)
					)

					if chk_OnlyAnim.checked then (FbxImporterSetParam "Mode" #exmerge)
					else (FbxImporterSetParam "Mode" #create)
					FbxImporterSetParam "Animation" true
					FbxImporterSetParam "FillTimeline" true

					if not chk_noefbxmulti.checked then
					(
						if showFbxOptions then (--chk_impPrompt
							importFile fbx_path using:FBXIMP
						) else (
							importFile fbx_path #noPrompt using:FBXIMP
						)
						
						endFrame = animationrange.end/2
						for i in objects do scaletime i.controller animationrange.start animationrange.end (30.0/60.0)
						animationrange = interval animationrange.start endFrame
						messageBox "导入动画成功！                                 "
					)
					else 
					(
						try(deleteFile fbx_path)catch()
						delFiles = getfiles ((getFilenamePath fbx_path) + @"\*.noefbxmulti")
						for f in delFiles do (try(deleteFile f)catch())
						print ("导出" + (getFilenamePath cmd) + "分离动画成功，可点击面板打开导出目录查看多个FBX动画！                                            "))
					
					if chk_delFBX.checked then 
						try(deleteFile fbx_path)catch()
							
				chk_showPlugOpt.checked = false
			)
		) else print("Not found: " + cmd)
		renderMessageManager.HideWindow()
	)
	
	on formNoesisCMD open do (
		if noesis_path != undefined do 
		(
			if doesFileExist noesis_path do (
				edt_noesis.text = noesis_path
			)
		)

		if output_path != undefined do 
		(
			if doesFileExist output_path do (
				edt_output.text = output_path
			)
		)
	)
		
	on btn_noesis pressed do (
		cmd = getOpenFileName types:"Noesis|noesis.exe;noesis64.exe|All|*.*|"
		if cmd != undefined and cmd != "" do (
			edt_noesis.text = noesis_path = cmd
		)
	)
	
	on edt_noesis changed cmd do (
		edt_noesis.text = noesis_path = cmd
	)

	on btn_output pressed do (
		cmd = getSavePath caption:"请选择导出动画 FBX 文件路径:" initialDir:(if output_path != undefined then output_path else "")
		if cmd != undefined and cmd != "" do (
			edt_output.text = output_path = cmd
		)
	)
	
	on edt_output changed cmd do (
		edt_output.text = output_path = cmd
	)

	on btn_openpath pressed do 
	(
		if output_path != undefined and output_path != "" do (ShellLaunch output_path "")
	)
	
	on btn_import pressed do (
		if noesisComponentsFound() then (
			motImport = getOpenFileName types:("MOTLIST|*" + motExt + "|All|*.*|")
			Import_MESH motImport undefined
		) else (messagebox "无法定位 Noesis 文件!")
	)
	
	on chk_OnlyAnim changed state do 
	(
		chk_resetScene.state = not state
	)
)

rollout rolMotViewer "Motlist Viewer"
(
	on rolMotViewer rolledUp state do (if not state then rolREAnimTools.height -= 270 else rolREAnimTools.height += 270)

	editText edtMotlistPath "" text:"" labelOnTop:true height:20 fieldWidth:190 pos:[5,5]
	button btnOpenMotlistPath "选择" height:20 width:35 pos:[200,5]
	button btnRefreshFolder "刷新" height:20 width:30 pos:[235,5]
	ListBox ltbMotlistFiles "" selection:0 height:15 width:260 pos:[5,30]
	button btnImportSel "导入或分离选中" height:25 width:125 pos:[5,235]
	button btnConvertAll "分离列表所有" height:25 width:130 pos:[135,235]

	function GetMotFilesRecursive root pattern =
	(        
		dir_array = GetDirectories (root+"\*")
		
		if dir_array.count != 0 then
		(
			for d in dir_array do
				join dir_array (GetDirectories (d+"*"))    
		)
		else dir_array = #(root)
		
		my_files = #()                
		
		for f in dir_array do
			join my_files (getFiles (f + @"\" + pattern))
			
		my_files
	)

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

	fn fnRefreshMotFiles =
	(
		if (edtMotlistPath.text != undefined) and (edtMotlistPath.text != "") then 
        (
            arrMotFilesLoaded = (rolMotViewer.GetMotFilesRecursive rolMotViewer.edtMotlistPath.text (@"*" + motExt))
			qsort arrMotFilesLoaded rolMotViewer.fnPseudoNaturalSort
			rolMotViewer.ltbMotlistFiles.items = for i in arrMotFilesLoaded collect ((getfilenamefile i) + motExt)
			if arrMotFilesLoaded.count == 0 then (messagebox"请确认置顶目标游戏选择正确!                                         ")
			arrMotFilesLoaded
		)
	)

	on rolMotViewer open do
	(
		if motPath != undefined do 
		(
			if doesFileExist motPath do (
				rolMotViewer.edtMotlistPath.text = motPath
				rolMotViewer.fnRefreshMotFiles()
			)
		)
	)

	on btnRefreshFolder pressed do (fnRefreshMotFiles())

	on ltbMotlistFiles rightclick id do
	(
		try(shellLaunch edtMotlistPath.text "")catch()
	)

	on ltbMotlistFiles doubleClicked id do
	(
		if (doesFileExist arrMotFilesLoaded[ltbMotlistFiles.selection]) then
		(
			if formNoesisCMD.noesisComponentsFound() then (
				motImport = arrMotFilesLoaded[ltbMotlistFiles.selection]
				formNoesisCMD.Import_MESH motImport undefined
			) else (messagebox "无法加载 Motlist 文件!                               ";return false)
		)
		else (messagebox "无法加载 Motlist 文件!                               ")
	)

	on btnImportSel pressed do
	(
		selID = ltbMotlistFiles.selection
		if selID != 0 and (doesFileExist arrMotFilesLoaded[selID]) then
		(
			if formNoesisCMD.noesisComponentsFound() then (
				motImport = arrMotFilesLoaded[ltbMotlistFiles.selection]
				formNoesisCMD.Import_MESH motImport undefined
			) else (messagebox "无法加载 Motlist 文件!                               ";return false)
		)
		else (messagebox "无法加载 Motlist 文件!                               ")
	)

	on btnConvertAll pressed do
	(
		if formNoesisCMD.chk_noefbxmulti.checked then 
		(
			for i in arrMotFilesLoaded where arrMotFilesLoaded.count != 0 do
			(
				if formNoesisCMD.noesisComponentsFound() then (
					if doesFileExist i do (formNoesisCMD.Import_MESH i undefined)
				) else (messagebox "无法加载 Motlist 文件!                               ";return false)
			)
			messageBox "导出列表所有分离动画成功，可点击面板打开导出目录查看多个FBX动画！                                                      "
		)
		else (messagebox "批量操作仅支持【导出分离动画片断】!请勾选后重试!                               ")
	)

	on btnOpenMotlistPath pressed do (
		path = getSavePath caption:"请选择希望加载的 Motlist 根目录:" initialDir:(if motPath != undefined then motPath else "")
		if path != undefined and path != "" do (
			edtMotlistPath.text = motPath = path
			fnRefreshMotFiles()
		)
	)
	
	on edtMotlistPath changed path do (
		edtMotlistPath.text = motPath = path
	)
)

rollout FBXBatchProcessor "Bone Anim FBX Fix (荒野专用)"
(
	on FBXBatchProcessor rolledUp state do (if not state then rolREAnimTools.height -= 120 else rolREAnimTools.height += 120)

	local fbxFiles = #()
	local outputPath = ""
	local arrFixTarget = #("Camera", "Ground_Angle", "L_Leg_IK", "R_Leg_IK", "COG", "Hip", "root")

	button btnSelectFolder "选择动画 FBX 文件夹" align:#center offset:[0,0] width:240 height:25
	button btnProcess "开始批量处理并修复帧率" align:#center width:240 height:30 enabled:false
	progressBar pbProgress align:#center width:240 height:12 color:white
	label lblStatus "状态：等待操作" align:#left width:220 height:20
	
	fn fnCreateCopyAddLink target =
	(
		local pointNew = point name:target.name
		pointNew.constantscreensize = false
		pointNew.transform = target.transform
		in coordsys gimbal pointNew.rotation = (eulerAngles 0 0 0)

		local pC = Position_Constraint()
		pC.appendTarget target 100
		pointNew.Position.controller = pC
		pC.relative = false
		
		local oC = Orientation_Constraint()
		oC.appendTarget target 100
		pointNew.Rotation.controller = oC
		oC.relative = true

		local oldName = target.name
		target.name = "NeedDelete_" + oldName
	)

	fn fnFixZUpAxis =
	(
		local arrFixObj = for o in arrFixTarget collect (getnodebyname o)
		for i in arrFixObj do fnCreateCopyAddLink i
		local arrNewObj = for o in arrFixTarget collect (getnodebyname o)
		for i = 1 to arrNewObj.count - 2 do 
		(
			arrNewObj[i].parent = $'root'
		)
		for i in $'NeedDelete_Hip'.children do i.parent = $'Hip'
		$'Hip'.parent = $'COG'
	)

	fn getAllFBXFiles rootPath = 
	(
		local dir = dotNetClass "System.IO.Directory"
		local searchOption = dotNetClass "System.IO.SearchOption"
		dir.GetFiles rootPath "*.fbx"
	)
	
	fn parseFrameCount filename = 
	(
		local arrFilter = filterString filename "("
		frameNew = (filterString arrFilter[arrFilter.count] " ")[1] as integer
		if frameNew > 1 then
			frameNew
		else
			0
	)
	
	fn processFile inputFile = 
	(
		-- try (
			resetMaxFile #noPrompt

			FbxImporterSetParam "Animation" true
			FbxImporterSetParam "FillTimeline" true

			frameRate = 1
			importFile inputFile #noPrompt using:FBXIMP
			
			local frameCount = parseFrameCount (getFilenameFile inputFile)
			local endFrame = if frameCount > 0 then frameCount - 1 else 119
			frameRate = 60
			sliderTime = sliderTime
			for i in objects do scaletime i.controller animationrange.start animationrange.end (1.0/60.0)
			animationrange = interval animationrange.start endFrame
			local newNameTemp = filterString (filenameFromPath inputFile) "-"
			local newName = (filterString newNameTemp[newNameTemp.count] " ")
			local outputName = newName[1]
			outputName = substituteString outputName ".fbx" "_fixed.fbx"
			-- outputMaxName = substituteString outputName ".fbx" "_fixed.max"
			local finalPath = outputPath + "\\" + outputName

			FBXExporterSetParam "Animation" true
			FBXExporterSetParam "BakeAnimation" true
			FBXExporterSetParam "BakeResampleAnimation" false

			exportFile finalPath #noPrompt selectedOnly:false using:FBXEXP
			-- saveMaxFile finalMaxPath
			true
		-- )
		-- catch (
		-- 	format "处理文件时出错：%\n" (getCurrentException())
		-- 	false
		-- )
	)
	
	on btnSelectFolder pressed do
	(
		local path = getSavePath caption:"选择包含FBX文件的文件夹"
		if path != undefined do
		(
			outputPath = path + "\\Fixed"
			makeDir outputPath
			fbxFiles = getAllFBXFiles path
			btnProcess.enabled = fbxFiles.count > 0
			lblStatus.text = "找到 " + fbxFiles.count as string + " 个FBX文件"
		)
	)
	
	on btnProcess pressed do
	(
		if fbxFiles.count == 0 do return false
		
		btnSelectFolder.enabled = false
		btnProcess.enabled = false
		pbProgress.value = 0
		
		local successCount = 0
		if selCurGameID >= 1 and selCurGameID <= 2 then 
		(
			for i = 1 to fbxFiles.count do
			(
				lblStatus.text = ("正在处理文件：" + filenameFromPath fbxFiles[i])
				print ("正在处理文件：" + filenameFromPath fbxFiles[i])
				pbProgress.value = (i as float / fbxFiles.count) * 100
				
				if processFile fbxFiles[i] do successCount += 1
				
				gc()
			)	
		)
		
		lblStatus.text = ("处理完成！成功处理 " + successCount as string + "/" + fbxFiles.count as string + " 个文件")
		btnSelectFolder.enabled = true
		btnProcess.enabled = true
	)
)
createdialog rolREAnimTools
AddSubRollout rolREAnimTools.subRolImporter formNoesisCMD
AddSubRollout rolREAnimTools.subRolImporter rolMotViewer rolledUp:false
AddSubRollout rolREAnimTools.subRolImporter FBXBatchProcessor rolledUp:false