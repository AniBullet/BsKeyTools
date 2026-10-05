/*
* @Description: 快速打开max文件，并保存常用目录
* @Author: Bullet.S
* @Date: 2019-11-23 01:41:13
 * @LastEditors: Bullet.S
 * @LastEditTime: 2025-11-22 21:46:22
* @Email: animator.bullet@foxmail.com
*/


try(destroydialog rolBsOpenTools)catch()
try(destroydialog rolAddItem)catch()

struct itemsFolder (name,dir)
Global iniPosOpenTools
Global iniWidthOpenTools = 340
Global iniDesktop        = (itemsFolder name:"Desktop" dir:"")
Global iniSelectedID     = 1
Global iniLikedFolder    = #()
Global iniFilterPrefix   = #()
Global iniAutoFbxPreview = true  -- 默认自动弹出 FBX 预览
Global iniSortMode       = 1    -- 排序模式: 1=名称↑ 2=名称↓ 3=日期↑ 4=日期↓

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))
catch(messagebox "脚本安装可能不完全,建议重新安装...        " beep:false)
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))
catch(messagebox "脚本安装可能不完全,建议重新安装...        " beep:false)
stLoadConfigAll.fnLoadConfigBsOpenTools ()

struct itemsFolder (name,dir)
global dateTime = (dotNetClass "System.DateTime").Now
global arrDayWeek = #("日", "一", "二", "三", "四", "五", "六")
Global BulletConfig = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径

-- Global iniRefPicDir			= (itemsFolder name:"RefPicDir" dir:"")
Global posMouMove         = [0,0]
Global switchMouState     = false

Global arrFolders         = #()
Global arrFoldersName     = #()
Global arrFiles           = #()
Global arrFilesName       = #()
Global dirLiked           = ""
Global dirOpened          = ""
Global arrDirItems        = #()
Global arrPreItems        = #()
Global arrRecentFiles     = #()
Global arrRecentFilesName = #()
Global arrFileType        = #(".max",".fbx",".bip",".ms*", ".mzp")
Global rolBsOpenTools
Global fnRefreshList
Global tempLastFolder

rollout rolAddItem "添加常用路径" width:340 height:80
(
	groupbox gbxAddDir "添加常用路径  ---------- Tips：右击框内条目删除 " width:330 height:70 pos:[5,5]
	
	edittext edtAddDir "收藏命名" pos:[10,50] fieldWidth:210 height:20 labelOnTop:false text:""
	button btnOpenDir "选择目录"  pos:[275,25] width:55 height:20 tooltip:"选择添加目录，默认打开当前文件目录"
	edittext edtDirStr "" pos:[5,25] fieldWidth:262 height:20 readOnly:true
	
	-- groupbox gbxAddPre "添加过滤前缀  ---------- Tips：右击框内条目删除 "  width:330 height:70 pos:[5,5]
	-- edittext edtPrefix ""  text:"" fieldWidth:262 height:35 pos:[5,35]

	button btnAddItems "添加" width:55 height:25 pos:[275,45]

	fn fnAddToFavorite =
	(
		if ((edtDirStr.text != "") and (edtAddDir.text != "") and (edtDirStr.visible == true)) then
		(
			local fnExist = 0
			for i = 1 to iniLikedFolder.count do 
			(
				if matchPattern iniLikedFolder[i].dir pattern:edtDirStr.text then 
				(
					fnExist = 1
				)
			)
			if fnExist == 0 then
			(
				append iniLikedFolder (itemsFolder edtAddDir.text edtDirStr.text)
				arrDirItems = #()
				for i = iniLikedFolder.count to 1 by -1 do
				(
					append arrDirItems iniLikedFolder[i].name
				)
				rolBsOpenTools.ltbLikedFolder.items = arrDirItems
				rolBsOpenTools.ltbLikedFolder.selection = 1
				-- fnRefreshList rolBsOpenTools.edtBrowseFolder.text type:arrFileType[rolBsOpenTools.rdoFileType.state]
			)
			else (messagebox "----------------------------------------\r\n可能常用目录中已存在此目录~")
		)
	)

	on btnOpenDir pressed do 
	(
		local dir = getSavePath caption:"请选择目录:" initialDir:(maxFilePath)
		if (dir != undefined) then
		(
			edtDirStr.text = dir
		)
	)

	on edtAddDir changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtAddDir.text = tempText
		-- print edtAddDir.text
	)

	on edtPrefix changed txt do 
	(
		tempText = substituteString txt "\n" ""
		edtPrefix.text = tempText
		-- print edtPrefix.text
	)

	on btnAddItems pressed do 
	(
		fnAddToFavorite()
		try(destroydialog rolAddItem)catch()
		rolBsOpenTools.fnRefreshList rolBsOpenTools.edtBrowseFolder.text type:arrFileType[rolBsOpenTools.rdoFileType.state]
		iniSelectedID = rolBsOpenTools.ltbLikedFolder.selection
		stSetConfigAll.fnSetConfigBsOpenTools ()
	)
)

rollout rolBsOpenTools "" width:580 height:400
(
	groupbox grpMain "时光机_v1.3" \
	width:570 height:395 pos:[5,0]
	button btnClose "X" pos:[rolBsOpenTools.width - 15,0] height:15 width:15 border:false
	editText edtBrowseFolder "" text:"" labelOnTop:false align:#right \
	height:20 fieldWidth:425 pos:[70,22] readOnly:true 
	button btnOpenAddress "..." align:#right tooltip:"选择打开目录" \
	height:22 width:30 pos:[37,20] border:false
	button btnAddPathToVavorite "✚" align:#left border:false \
	height:22 width:30 pos:[505,20] tooltip:"添加当前路径至常用目录"
	button btnOpenCurrentDir "O" tooltip:"打开当前文件夹" \
	height:22 width:30 pos:[535,20] border:false
	-- button btnRemoveFolder "━" align:#left \
	-- height:20 width:25 pos:[10,20] tooltip:"删除选中的收藏目录"
	-- button btnAddFolder "✚" align:#left border:false \
	-- height:20 width:20 pos:[35,20] tooltip:"新增常用目录"
	button btnRefreshFolder "↻" align:#left border:false \
	height:22 width:25 pos:[10,20] tooltip:"左：刷新当前文件目录\r\n\r\n右：重置场景"
	label lblLikedFolderTitle "常用目录" align:#left \
	height:18 width:60 pos:[15,50]
	button btnAddLikedFolder "＋" border:true \
	height:18 width:18 pos:[75,50] tooltip:"添加常用目录"
	button btnDelLikedFolder "－" border:true \
	height:18 width:18 pos:[95,50] tooltip:"删除选中常用目录"
	listbox ltbLikedFolder "" selection:0 \
	height:22 Width:105 pos:[10,75]
	editText edtInputFilter "" text:"" labelOnTop:false align:#left \
	height:17 fieldWidth:100 pos:[115,75]
	listBox ltbFilesList "" align:#right selection:0 \
	height:22 width:340 pos:[225,75]
	label lblFilterPrefixTitle "过滤词缀" align:#left \
	height:18 width:60 pos:[125,50]
	button btnAddFilterPrefix "＋" border:true \
	height:18 width:18 pos:[180,50] tooltip:"添加过滤词缀"
	button btnDelFilterPrefix "－" border:true \
	height:18 width:18 pos:[200,50] tooltip:"删除选中过滤词缀"
	listBox ltbFilterPrefix "" align:#left selection:0 \
	height:10 width:100 pos:[120,100]
	dropdownList ddlSort "" pos:[410,47] width:60 items:#("名称 ↑", "名称 ↓", "日期 ↑", "日期 ↓") \
	tooltip:"文件排序方式"
	button btnPrevFolder "上层" tooltip:"返回上层目录，也可右击面板空白处" \
	height:18 width:40 pos:[475,50] border:true
	checkbutton chePreview "预览 >>" pos:[520,50] height:18 width:50 border:true tooltip:"展开预览窗口" checked:false
	
	-- 预览窗口相关UI元素
	groupbox grpPreview "Max文件预览窗口，FBX会弹出额外预览窗（仅高版本max）" width:360 height:200 pos:[585,5] visible:false
	dotNetControl dncMaxPreview "System.Windows.Forms.PictureBox" width:350 height:170 pos:[590,25]
	
	-- 文件属性显示区域
	groupbox grpFileInfo "文件属性" width:360 height:155 pos:[585,210] visible:false
	label lblFileInfo "" width:340 height:120 pos:[590,230] align:#left
	
	-- 文件操作按钮（与 FBX 自动预览在同一行，平均分配宽度）
	button btnCopyPath "复制路径" width:115 height:20 pos:[585,375] tooltip:"复制文件完整路径到剪贴板"
	button btnCopyFileName "复制文件名" width:115 height:20 pos:[705,375] tooltip:"复制文件名到剪贴板"
	-- FBX 自动预览控制（与按钮在同一行，只在 FBX 格式时显示）
	checkbox ckbAutoFbxPreview "自动预览 FBX" pos:[825,378] width:140 height:15 checked:true visible:false \
		tooltip:"勾选后，在预览模式下选择FBX文件会自动弹出预览窗口"
	radioButtons rdoFileType "" columns:4 \
	pos:[230,50] labels:#(".max",".fbx",".bip",".ms") 

	checkbox ckbSilentOpen "静默打开Max" pos:[125,240] width:90 height:15 checked:true
	button btnRecentFileDir "最近打开" border:true \
	height:25 width:100 pos:[120,260] tooltip:"最近打开文件"
	button btnDesktopDir "桌面自定" border:true \
	height:25 width:100 pos:[120,285] tooltip:"自定文件夹，默认桌面，右键可重设"
	button btnScriptsDir "脚本目录" border:true \
	height:25 width:100 pos:[120,310] tooltip:"脚本文件夹\r\n左：根目录\r\n右：自启目录"
	button btnAutobackDir "自动保存" border:true \
	height:25 width:100 pos:[120,335] tooltip:"自动保存目录"
	-- button btnPreviewDir "<轮回梦境>" border:false \
	-- height:25 width:70 pos:[10,310] tooltip:"左：预览视频默认文件夹\r\n右：快速拍屏渲染预览动画"
	groupBox grpDate "" width:570 height:30 pos:[5,365]
	label lblLikedFolder "" height:15 width:140 pos:[10,375]
	label lblCountTips "" height:15 width:80 pos:[470,375]
	label lblDateTime "" height:15 width:140 pos:[180,375] 
	HyperLink lnkLink "Bullet.S" color:myfgColor hovercolor:myClickColor visitedcolor:myClickColor \
	pos:[330,375] address:"https://space.bilibili.com/2031113"
	-- checkbutton ckbLockWidth "🔒" pos:[86,312] width:20 height:20 border:false \
	-- toolTip:"是否解锁宽度调节\r\n右：重置宽度" checked:false
	-- slider sldSetWidth "" pos:[113,312] range:[340,540,iniWidthOpenTools] ticks:0 \
	-- width:222 type:#integer toolTip:"调节面板宽度,以显示更多字" enabled:false
	-- label labLogo "-------------------------  TECH OTAKUS SAVE THE WORLD -" pos:[12,365]
	------------------------------------------------- ↑ UI -------------------------------------
	
	-- global charClass = dotNetClass "System.Char" --dotnet charclass used for isDigit comparisment
	-- dotNetClass:System.Char

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
	fn fnSortByDateFile a b =  --按修改日期排序（文件）
	(
		local fiA = dotNetObject "System.IO.FileInfo" a
		local fiB = dotNetObject "System.IO.FileInfo" b
		fiA.LastWriteTime.CompareTo fiB.LastWriteTime
	)

	fn fnSortByDateFolder a b =  --按修改日期排序（文件夹）
	(
		local diA = dotNetObject "System.IO.DirectoryInfo" a
		local diB = dotNetObject "System.IO.DirectoryInfo" b
		diA.LastWriteTime.CompareTo diB.LastWriteTime
	)
-------------------------------------↑ 文件排序方法 --------------------------------------------------

	Fn fnLoadRecentFileList = -------获取最近打开文件列表
	(
		local recentfiles = (getdir #maxData) + "RecentDocuments.xml"
		if doesfileexist recentfiles then
		(
			arrRecentFiles     = #()
			arrRecentFilesName = #()
			xDoc = dotnetobject "system.xml.xmldocument"	
			xDoc.Load recentfiles
			Rootelement = xDoc.documentelement

			arrRecentFiles = for i = 0 to rootelement.childnodes.item[4].childnodes.itemof[0].childnodes.count-1 collect 
			(
				rootelement.childnodes.item[4].childnodes.itemof[0].childnodes.itemof[i].childnodes.itemof[3].innertext	
			)
			Return arrRecentFiles
			LRXML = Undefined
			XDoc = Undefined
			XDoc = nothing	
		)
		if arrRecentFiles[1] != undefined then
		(
			for c in arrRecentFiles do  --获取文件夹名字,后面切换脚本类别和列表会用到
			(
				append arrRecentFilesName ("📄 " + (getFilenameFile (substring c 1 (c.count-1))))
			)
		)
	)

	fn fnGetLastFolder strFolder =
	(
		if ((strFolder != "") and (doesDirectoryExist strFolder)) then
		(
			local arrFilterStr = filterstring strFolder @"\"
			local strLastFolder = ""
			for i = 1 to (arrFilterStr.count - 1) do 
			(
				strLastFolder = strLastFolder  + arrFilterStr[i] + @"\\"
			)
		)
		return strLastFolder
	)
	
	fn fnRefreshList strFilesDir filename:(rolBsOpenTools.ltbFilterPrefix.selected) type:".max" =
	(
		arrFolders = #()
		arrFiles = #()
		arrFoldersName = #()
		arrFilesName = #()
		arrAll = #()
		arrFinal = #()
		if strFilesDir != undefined then 
		(
			if ((strFilesDir != "") and (doesDirectoryExist strFilesDir)) then
			(
				local tempDir = GetDirectories (strFilesDir + "/*")
				for i in tempDir do 
				(
					append arrFolders (substring i 1 (i.count-1))
				)
			if ddlSort.selection >= 3 then
				qsort arrFolders fnSortByDateFolder
			else
				qsort arrFolders fnPseudoNaturalSort
			(arrFilesBeforeFilter = getFiles (strFilesDir + "\\*" + type))
			if ddlSort.selection >= 3 then
				qsort arrFilesBeforeFilter fnSortByDateFile
			else
				qsort arrFilesBeforeFilter fnPseudoNaturalSort
				if (filename != undefined) then
				(
					for i in arrFilesBeforeFilter do 
					(
						if (matchpattern (getfilenamefile i) \
						pattern:("*" + filename + "*")) then 
						(append arrFiles i)
					)
					rolBsOpenTools.edtInputFilter.text = filename
				)
				else arrFiles = arrFilesBeforeFilter
				
				if arrFolders[1] != undefined then
				(
					for c in arrFolders do  --获取文件夹名字,后面切换脚本类别和列表会用到
					(
						append arrFoldersName ("📂 " + (getFilenameFile c))
					)
				)
				if arrFiles[1] != undefined then
				(
					for c in arrFiles do  --获取文件名字,后面切换脚本类别和列表会用到
					(
						(append arrFilesName ("📄 " + (getFilenameFile c) + type))
					)
				)
				local isReversed = (ddlSort.selection == 2 or ddlSort.selection == 4)
				if isReversed then 
				(
					arrAll = (arrFoldersName + arrFilesName)
					tempArray = for i = arrAll.count to 1 by -1 collect arrAll[i]
					arrFinal = for i in tempArray collect i
					rolBsOpenTools.ltbFilesList.items = arrFinal
				)
				else
				(
					rolBsOpenTools.ltbFilesList.items = arrFoldersName + arrFilesName
				)
				rolBsOpenTools.edtBrowseFolder.text = strFilesDir
				for i = 1 to iniLikedFolder.count do 
				(
					if matchPattern iniLikedFolder[i].dir pattern:strFilesDir then 
					(
						rolBsOpenTools.ltbLikedFolder.selection = iniLikedFolder.count + 1 - i
					)
				)
			)
			else 
			(
				if ((iniSelectedID != 0) and (iniLikedFolder.count > 0)) then
				(
					rolBsOpenTools.ltbLikedFolder.selection = iniSelectedID
					fnRefreshList iniLikedFolder[iniLikedFolder.count + 1 - iniSelectedID].dir
				)
			)
		)
		else messagebox "-------------------------------------\r\n文件夹可能已不存在\r\n请尝试刷新\r\n"
		lblCountTips.text = "文件：" + arrFiles.count as string
		lblLikedFolder.text = if ltbLikedFolder.selected == undefined then "请添加常用目录" else ltbLikedFolder.selected
	)
	
	fn fnRefreshAddress =
	(
		if (maxFilePath != "") then 
		(
			local tempMaxFilePath = (substring maxFilePath 1 (maxFilePath.count-1))
			fnRefreshList tempMaxFilePath type:arrFileType[rdoFileType.state]
		)
		else 
		(
			if rolBsOpenTools.ltbLikedFolder.selection != 0 then 
			(
				local tempSelectionID = rolBsOpenTools.ltbLikedFolder.selection
				edtBrowseFolder.text = iniLikedFolder[iniLikedFolder.count + 1 - tempSelectionID].dir
			)
			else 
			(
				edtBrowseFolder.text = " ( 打开目录 )"
			)
		)
	)

	fn fnRefLikedFolderItems =
	(
		arrDirItems = #()
		if iniLikedFolder.count != 0 then
		(
			for i = iniLikedFolder.count to 1 by -1 do
			(
				if (doesDirectoryExist iniLikedFolder[i].dir) then 
				(
					append arrDirItems iniLikedFolder[i].name
				)
				else 
				(
					messagebox (iniLikedFolder[i].dir + "\r\n文件夹不存在\r\n已从常用路径中删除                                                                          \r\n")
					deleteitem iniLikedFolder i
				)
			)
		)
		else 
		(
			lblLikedFolder.text = "请添加常用目录"
		)
		rolBsOpenTools.ltbLikedFolder.items = arrDirItems
	)

	fn fnRefreshFilterItems =
	(
		local arrPreItems = #()
		for i = iniFilterPrefix.count to 1 by -1 do
		(
			append arrPreItems iniFilterPrefix[i]
		)
		rolBsOpenTools.ltbFilterPrefix.items = arrPreItems
	)

	fn fnLoadBip fBip =
	(
		-- biped.loadBipFile <biped_ctrl> <file_name> \
		-- [#matchFileStruct] [#zeroHgt] [#noRedraw] \
		-- [#loadMaxObjects][#promptForDuplicates] [#retargetHeight] \
		-- [#retargetLimbSizes] [#scaleIKObjectSize] [#loadSubAnimControllers] \
		-- [#loadSelectedMaxObjects nodename_array] \
		-- [#loadSelectedSubAnimControllers bipednodename_array int_array]

		local numSelbiped = #()   -------判断选择了几个biped骨架
		if selection.count != 0 then
		(
			for i in (selection as array) where ((classof i == Biped_Object) and (i.ishidden == false)) do  
			(
				appendIfUnique numSelbiped i.controller.rootNode  --添加到骨架数组
			)
			for b in numSelbiped do 
			(
				biped.loadBipFile b.controller fBip #noRedraw
				forceCompleteRedraw()
			)
		)
	)

	fn fnRefreshDate =
	(
		local arrTime = (getLocalTime())
		local dayWeekID = (mod arrTime[3] 7) as integer
		lblDateTime.text = dateTime.Year as string + "/" + dateTime.Month as string + "/" \
		+ dateTime.Day as string + "  星期" + arrDayWeek[dayWeekID + 1] as string
	)

	-- 预览相关函数
	fn fnTogglePreviewWindow state =
	(
		if state then
		(
			rolBsOpenTools.width = 950
			grpPreview.visible = true
			grpFileInfo.visible = true
			chePreview.text = "预览 <<"
		)
		else
		(
			rolBsOpenTools.width = 580
			grpPreview.visible = false
			grpFileInfo.visible = false
			chePreview.text = "预览 >>"
		)
	)

	-- 获取Max文件版本号（转换为20xx格式）
	fn fnGetMaxVersionString versionNumber =
	(
		-- 直接使用版本号，不需要转换
		return versionNumber as string
	)
	
	-- 获取文件属性信息
	fn fnGetFileProperties filePath =
	(
		local fileExt = getFilenameType filePath
		local infoText = ""
		fileExt = (toLower fileExt)
		case fileExt of
		(
			".max":
			(
				-- Max文件属性
				try
				(
					-- 尝试加载MaxFileUtilities库
					local assemblyPath = (getDir #scripts) + "\\BulletScripts\\Res\\MaxFileUtilitiesDotNet.dll"
					if doesFileExist assemblyPath then
					(
						local assembly = dotnet.loadAssembly assemblyPath
						local mfuMFI = dotNetObject "MaxFileUtilities.MaxFileInterface"
						
						-- 获取基本信息
						local generalInfo = mfuMFI.GetGeneralInformation filePath
						local meshInfo = mfuMFI.GetMeshTotalsInformation filePath
						local sceneInfo = mfuMFI.GetSceneTotalsInformation filePath
						
						-- 构建信息文本
						-- infoText = "Max文件属性:\n"
						-- infoText += "Max版本号: " + (generalInfo.MaxVersion as string) + "\n"
						if generalInfo.ReadableSavedAsVersion != undefined then
						(
							infoText += "保存版本: " + (generalInfo.ReadableSavedAsVersion as string) + "\n"
						)
						infoText += "\n"
						-- infoText += "场景统计:\n"
						infoText += "物体总数: " + (sceneInfo.Total as string) + "\n"
						infoText += "几何体: " + (sceneInfo.NbOfObjects as string) + "  ||  "
						infoText += "形状: " + (sceneInfo.NbOfShapes as string) + "  ||  "
						infoText += "灯光: " + (sceneInfo.NbOfLights as string) + "  ||  "
						infoText += "相机: " + (sceneInfo.NbOfCameras as string) + "  ||  "
						infoText += "辅助对象: " + (sceneInfo.NbOfHelpers as string) + "  ||  "
						infoText += "空间扭曲: " + (sceneInfo.NbOfSpaceWarps as string) + "  ||  "
												
						-- 尝试获取骨骼信息
						try
						(
							-- 获取所有对象名称，查找骨骼
							local allObjects = mfuMFI.GetObjectsNames filePath
							local boneCount = 0
							for objName in allObjects do
							(
								-- 检查是否包含骨骼相关关键词
								if matchPattern objName pattern:"*Bone*" or matchPattern objName pattern:"*Bip*" or matchPattern objName pattern:"*Armature*" then
								(
									boneCount += 1
								)
							)
							-- infoText += "骨骼统计:\n"
							infoText += "骨骼数量: " + (boneCount as string) + "\n\n"
						)
						catch
						(
							-- infoText += "骨骼统计:\n"
							infoText += "骨骼数量: 无法获取\n\n"
						)
						
						-- infoText += "网格统计:\n"
						infoText += "顶点数: " + (meshInfo.NbOfVertices as string) + "  ||  "
						infoText += "面数: " + (meshInfo.NbOfFaces as string) + "\n\n"
					)
					else
					(
						infoText = "未找到MaxFileUtilities库\n无法获取详细属性\n\n"
					)
				)
				catch
				(
					infoText = "获取Max文件属性失败\n" + (getCurrentException()) + "\n\n"
				)
			)
			".fbx":
			(
				-- FBX文件属性
				infoText = "FBX文件属性:\n"
				infoText += "文件类型: FBX格式\n\n"
			)
			".bip":
			(
				-- BIP文件属性
				infoText = "BIP文件属性:\n"
				infoText += "文件类型: Biped动画\n\n"
			)
			".ms":
			(
				-- MS文件属性
				infoText = "MS文件属性:\n"
				infoText += "文件类型: MAXScript脚本\n\n"
			)
			default:
			(
				infoText = "未知文件类型\n\n"
			)
		)
		
		-- 添加通用文件信息
		try
		(
			-- 使用dotNet FileInfo获取文件信息
			local fileInfo = dotNetObject "System.IO.FileInfo" filePath
			if fileInfo != undefined and fileInfo.Exists then
			(
				-- 获取文件大小
				local fileSize = fileInfo.Length
				local fileSizeKB = fileSize / 1024.0
				local fileSizeMB = fileSize / (1024.0 * 1024.0)
				local sizeText = if fileSizeMB >= 1.0 then 
				(
					-- 保留一位小数显示MB
					((fileSizeMB * 10) as integer / 10.0) as string + " MB"
				) else 
				(
					-- 保留一位小数显示KB
					((fileSizeKB * 10) as integer / 10.0) as string + " KB"
				)
				infoText += "文件大小: " + sizeText + "  ||  "
				
				-- 获取修改时间
				local lastWriteTime = fileInfo.LastWriteTime
				local timeString = lastWriteTime.ToString "yyyy/MM/dd HH:mm:ss"
				infoText += "修改时间: " + timeString
			)
			else
			(
				infoText += "文件大小: 无法获取\n"
				infoText += "修改时间: 无法获取"
			)
		)
		catch
		(
			infoText += "文件大小: 获取失败\n"
			infoText += "修改时间: 获取失败"
		)
		
		return infoText
	)

	fn fnPreviewFile filePath =
	(
		if filePath == undefined or filePath == "" then return false
		
		-- 显示文件属性
		local propertiesText = fnGetFileProperties filePath
		lblFileInfo.text = propertiesText
		grpFileInfo.visible = true
		
		local fileExt = getFilenameType filePath
		fileExt = (toLower fileExt)
		case fileExt of
		(
			".max":
			(
				-- Max文件预览缩略图
				try
				(
					-- 尝试获取Max文件的缩略图
					local thumbnailFound = false
					
					-- 使用专门的dotNet库获取Max文件缩略图
					try
					(
						-- 尝试加载MaxFileUtilities库
						local assemblyPath = (getDir #scripts) + "\\BulletScripts\\Res\\MaxFileUtilitiesDotNet.dll"
						if doesFileExist assemblyPath then
						(
							local assembly = dotnet.loadAssembly assemblyPath
							local mfuMFI = dotNetObject "MaxFileUtilities.MaxFileInterface"
							
							-- 获取缩略图
							local thumb = mfuMFI.GetThumbnail filePath
							if thumb != undefined then
							(
								-- 直接使用dotNet bitmap，设置SizeMode确保图片完全显示
								dncMaxPreview.SizeMode = (dotNetClass "System.Windows.Forms.PictureBoxSizeMode").Zoom
								dncMaxPreview.Image = thumb
								thumbnailFound = true
							)
						)
					)
					catch
					(
						-- 如果获取缩略图失败，记录错误信息
						print "获取Max文件缩略图失败: " + (getCurrentException())
					)
					
					-- 如果没有找到缩略图，显示文件信息
					if not thumbnailFound then
					(
						-- 清除图片
						dncMaxPreview.Image = undefined
					)
				)
				catch
				(
					-- 清除图片
					dncMaxPreview.Image = undefined
				)
			)
			".fbx":
			(
				-- FBX文件预览 - 使用 Python FBX Viewer
				-- 根据 checkbox 状态决定是否自动弹出预览
				dncMaxPreview.visible = true
				dncMaxPreview.Image = undefined
				
				-- 检查是否需要自动弹出预览
				if ckbAutoFbxPreview.checked then
				(
					local pythonScriptPath = (getDir #scripts) + "\\BulletScripts\\BsAnimLib.py"
					
					if doesFileExist pythonScriptPath then
					(
						-- 加载Python脚本（会自动清理旧窗口）
						try(python.ExecuteFile pythonScriptPath)catch()
						
						-- 调用预览函数
						try
						(
							python.execute ("show_fbx_viewer(r'" + filePath + "')")
						)
						catch
						(
							print ("FBX预览失败: " + (getCurrentException() as string))
						)
					)
					else
					(
						-- 回退到外部FBX Review
						local fbxReviewPath = (getDir #scripts) + "\\BulletScripts\\Res\\fbxreview.exe"
						if doesFileExist fbxReviewPath then
						(
							shellLaunch fbxReviewPath filePath
						)
					)
				)
			)
			".bip":
			(
				-- 清除图片
				dncMaxPreview.visible = true
				dncMaxPreview.Image = undefined
			)
			".ms":
			(
				-- 清除图片
				dncMaxPreview.visible = true
				dncMaxPreview.Image = undefined
			)
			default:
			(
				-- 清除图片
				dncMaxPreview.visible = true
				dncMaxPreview.Image = undefined
			)
		)
	)

	fn fnGetSelectedFilePath =
	(
		local selectedID = ltbFilesList.selection
		if selectedID == 0 then return undefined
		
		local idNew = selectedID
		if (ddlSort.selection == 2 or ddlSort.selection == 4) then 
		(
			idNew = (arrFiles.count + arrFolders.count) + 1 - selectedID
		)
		
		if idNew > arrFolders.count then
		(
			local idFile = idNew - arrFolders.count
			return arrFiles[idFile]
		)
		return undefined
	)
	
	----------------------------------------------------------------------------------------------------
	
	on rolBsOpenTools open do 
	(
		-- sldSetWidth.value        = iniWidthOpenTools
		-- rolBsOpenTools.width     = iniWidthOpenTools
		btnRefreshFolder.images  = #("UVWUnwrapModes_16i.bmp","UVWUnwrapModes_16i.bmp",28,3,3,3,3,true,false)
		-- ckbLockWidth.images      = #("LockButtonExt_i.bmp","LockButtonExt_i.bmp",2,1,1,2,2,true,false)
		btnAddPathToVavorite.images = #("enss_tools_16i.bmp","enss_tools_16a.bmp",13,5,5,6,6,false,true)
		btnOpenCurrentDir.images = #("bip_general_i.bmp","bip_general_i.bmp",30,5,5,6,6,false,true)
		-- btnPrevFolder.images     = #("MergeAnim_24i.bmp","MergeAnim_24i.bmp",4,1,1,1,1,false,true)
		
		-- 初始化预览窗口
		grpPreview.visible = false
		grpFileInfo.visible = false
		chePreview.state = false
		
		-- 初始化 FBX 自动预览 checkbox
		ckbAutoFbxPreview.checked = iniAutoFbxPreview
		-- 根据当前文件类型决定是否显示
		if rdoFileType.state == 2 then  -- .fbx
			ckbAutoFbxPreview.visible = true
		else
			ckbAutoFbxPreview.visible = false
		
		-- 设置PictureBox的SizeMode，确保图片能够完整显示
		dncMaxPreview.SizeMode = (dotNetClass "System.Windows.Forms.PictureBoxSizeMode").Zoom
		
		stLoadConfigAll.fnLoadConfigBsOpenTools ()  ---------------脚本位置等赋值
		stSetConfigAll.fnSetConfigBsOpenTools ()  ----------------保存位置信息到ini文件	
		ddlSort.selection = iniSortMode
		fnRefLikedFolderItems ()
		fnRefreshAddress ()
		fnRefreshList maxFilePath type: arrFileType[rdoFileType.state]
		lblCountTips.text = "文件：" + arrFiles.count as string
		lblLikedFolder.text = if ltbLikedFolder.selected == undefined then "请添加常用目录" else ltbLikedFolder.selected
		ltbFilterPrefix.selection = 0
		fnRefreshFilterItems ()
		ltbLikedFolder.selection = iniSelectedID
		fnRefreshDate ()
	)

	on rolBsOpenTools close do -- 关闭记忆浮动窗口位置
	(
		iniPosOpenTools   = (GetDialogPos rolBsOpenTools)
		iniSelectedID     = rolBsOpenTools.ltbLikedFolder.selection
		iniWidthOpenTools = rolBsOpenTools.width
		iniAutoFbxPreview = ckbAutoFbxPreview.checked
		iniSortMode       = ddlSort.selection
		stSetConfigAll.fnSetConfigBsOpenTools ()
	)

	on rolBsOpenTools mbuttondown pos do 
	(
		try (destroydialog rolBsOpenTools) catch ()
		try(destroydialog rolAddItem)catch()
	)

	on rolBsOpenTools lbuttondown posMou do
	(
		posMouMove = posMou
		switchMouState = on
	)

	on rolBsOpenTools lbuttonup posMou do
	(
		switchMouState = off
	)

	on rolBsOpenTools rbuttondown pos do 
	(
		tempLastFolder = fnGetLastFolder edtBrowseFolder.text
		fnRefreshList tempLastFolder type:arrFileType[rdoFileType.state]
		rolBsOpenTools.ltbFilesList.selection = 0
	)

	on rolBsOpenTools mouseMove pos do
	(
		if switchMouState == on then
		(
			SetDialogPos rolBsOpenTools (mouse.screenpos - posMouMove)			
		)
	)

	-- on rolBsOpenTools resized pos do
	-- (
	-- 	grpMain.width          = rolBsOpenTools.width - 10
	-- 	grpDate.width          = rolBsOpenTools.width - 10
	-- 	edtBrowseFolder.width  = rolBsOpenTools.width - 130
	-- 	ltbFilesList.width     = rolBsOpenTools.width - 95
	-- 	btnOpenCurrentDir.pos  = [rolBsOpenTools.width - 35,20]
	-- 	btnPrevFolder.pos      = [rolBsOpenTools.width - 60,20]

	-- )
	------------------------------------------------------------------------------

	-- on ckbLockWidth changed state do 
	-- (
	-- 	if state == on then sldSetWidth.enabled = true 
	-- 	else sldSetWidth.enabled = false
	-- )

	-- on ckbLockWidth rightclick do
	-- (
	-- 	rolBsOpenTools.width = 340
	-- 	sldSetWidth.value    = 340
	-- )

	-- on sldSetWidth changed ticks do
	-- (
	-- 	rolBsOpenTools.width = ticks
	-- )

	on btnRefreshFolder pressed do 
	(
		fnRefreshAddress ()
		fnRefreshList edtBrowseFolder.text type:arrFileType[rdoFileType.state]
	)

	on btnPrevFolder pressed do 
	(
		tempLastFolder = fnGetLastFolder edtBrowseFolder.text
		fnRefreshList tempLastFolder type:arrFileType[rdoFileType.state]
		rolBsOpenTools.ltbFilesList.selection = 0
	)

	on btnRefreshFolder rightclick do 
	(
		if CheckForSave() then 
		(
			resetMaxFile #noPrompt
			max tool maximize
		)
	)

	on btnOpenCurrentDir pressed do 
	(
		if (doesDirectoryExist edtBrowseFolder.text) then
		(
			shellLaunch edtBrowseFolder.text ""
		)
	)

	on edtBrowseFolder changed txt do
	(
		fnRefreshList txt type:arrFileType[rdoFileType.state]
	)

	on rdoFileType changed state do
	(
		fnRefreshList rolBsOpenTools.edtBrowseFolder.text type:arrFileType[state]
		
		-- 只在 FBX 格式时显示自动预览 checkbox
		if state == 2 then  -- .fbx
		(
			ckbAutoFbxPreview.visible = true
		)
		else
		(
			ckbAutoFbxPreview.visible = false
		)
	)

	on btnOpenAddress pressed do 
	(
		dirOpened = getSavePath caption:"请选择Max文件路径:" initialDir:(maxFilePath)
		if (dirOpened != undefined) then
		(
			edtBrowseFolder.text = dirOpened
			fnRefreshList dirOpened type:arrFileType[rdoFileType.state]
		)
	)
	
	on btnAddLikedFolder pressed do 
	(
		try(destroydialog rolAddItem)catch()
		createdialog rolAddItem fgcolor:myfgColor pos:mouse.screenpos
	)

	on btnDelLikedFolder pressed do
	(
		if iniLikedFolder.count > 0 and ltbLikedFolder.selection != 0 then
		(
			idDel = iniLikedFolder.count + 1 - ltbLikedFolder.selection
			local delName = iniLikedFolder[idDel].name
			local confirmResult = queryBox ("确定要删除常用目录 \"" + delName + "\" 吗?") title:"删除确认" beep:false
			if confirmResult then
			(
				deleteItem iniLikedFolder idDel
				print idDel
				fnRefLikedFolderItems ()
			)
		)
	)

	on btnAddPathToVavorite pressed do 
	(
		try(destroydialog rolAddItem)catch()
		createdialog rolAddItem fgcolor:myfgColor pos:mouse.screenpos
		
		if (edtBrowseFolder.text != "") then
		(
			rolAddItem.edtDirStr.text = edtBrowseFolder.text
			rolAddItem.fnAddToFavorite()
		)
	)

	on btnAddFilterPrefix pressed do 
	(
		if (edtInputFilter.text != "") then
		(
			if (findItem iniFilterPrefix edtInputFilter.text) != 0 then 
			(
				messagebox "-------------------------------------\r\n可能过滤词缀中已存在~"
			)
			else
			(
				append iniFilterPrefix edtInputFilter.text
				arrPreItems = #()
				for i = iniFilterPrefix.count to 1 by -1 do
				(
					append arrPreItems iniFilterPrefix[i]
				)
				rolBsOpenTools.ltbFilterPrefix.items = arrPreItems
				rolBsOpenTools.ltbFilterPrefix.selection = 1
			)
			rolBsOpenTools.fnRefreshList rolBsOpenTools.edtBrowseFolder.text type:arrFileType[rolBsOpenTools.rdoFileType.state]
		)
		else 
		(
			messagebox "--------------------------------------\r\n请在按钮下方输入过滤词缀~\r\n--------------------------------------"
		)
	)

	on btnDelFilterPrefix pressed do 
	(
		if iniFilterPrefix.count > 0 and ltbFilterPrefix.selection != 0 then
		(
			idDel = iniFilterPrefix.count + 1 - ltbFilterPrefix.selection
			local delPrefix = iniFilterPrefix[idDel]
			local confirmResult = queryBox ("确定要删除过滤词缀 \"" + delPrefix + "\" 吗?") title:"删除确认" beep:false
			if confirmResult then
			(
				deleteItem iniFilterPrefix idDel
				fnRefreshFilterItems ()
				fnRefreshList edtBrowseFolder.text type:arrFileType[rdoFileType.state]
			)
		)
	)

	on ltbLikedFolder selected id do
	(
		if iniLikedFolder[id] != undefined then
		(
			strDir = iniLikedFolder[iniLikedFolder.count + 1 - id].dir
			fnRefreshList strDir type:arrFileType[rdoFileType.state]
		)
		iniSelectedID = id
	)
	
	on ltbLikedFolder rightclick id do
	(
		btnDelLikedFolder.pressed()
	)

	on ltbFilterPrefix selected id do
	(
		fnRefreshList edtBrowseFolder.text type:arrFileType[rdoFileType.state]
	)
	
	on ltbFilterPrefix rightclick id do
	(
		btnDelFilterPrefix.pressed()
	)

	on ltbFilesList rightclick id do
	(
		tempLastFolder = fnGetLastFolder edtBrowseFolder.text
		fnRefreshList tempLastFolder type:arrFileType[rdoFileType.state]
		rolBsOpenTools.ltbFilesList.selection = 0
	)

	on ltbFilesList doubleClicked id do
	(
		if (doesDirectoryExist edtBrowseFolder.text) then
		(
			idNew = id
			if (ddlSort.selection == 2 or ddlSort.selection == 4) then 
			(
				idNew = (arrFiles.count + arrFolders.count) + 1 - id
			)
			-- if edtBrowseFolder.text == (getdir #preview) then ramplayer arrFiles[idNew] ""
			-- else 
			-- (
				case of
				(
					((idNew <= arrFolders.count) and (idNew > 0)):
					(
						edtBrowseFolder.text = arrFolders[idNew]
						fnRefreshList edtBrowseFolder.text type:arrFileType[rdoFileType.state]
						-- fnRefreshList edtBrowseFolder.text type:arrFileType[rdoFileType.state]
					)
					(idNew > arrFolders.count):
					(
						local idFile = idNew - arrFolders.count
						case of 
						(
							(rdoFileType.state == 1):
							(
								if CheckForSave() then 
								(
									loadMaxFile arrFiles[idFile] useFileUnits:true quiet:ckbSilentOpen.state
								)
							)
							(rdoFileType.state == 2):(importFile arrFiles[idFile] #noPrompt using:FBXIMP)
							(rdoFileType.state == 3):(fnLoadBip arrFiles[idFile])
							(rdoFileType.state == 4):(fileIn arrFiles[idFile])
						)
					)
				)
			-- )
		)
		else 
		(
			if edtBrowseFolder.text == "( 最近打开 Max 文件列表 )" then
			(
				if doesFileExist arrRecentFiles[id] then 
				(
					loadMaxFile (arrRecentFiles[id]) useFileUnits:true quiet:ckbSilentOpen.state
					local tempDir = getfilenamepath arrRecentFiles[id]
					fnRefreshList tempDir type:arrFileType[rdoFileType.state]
				)
			)
		)
	)

	on btnDesktopDir pressed do 
	(
		if iniDesktop.dir == "" then 
		(
			iniDesktop.dir = (@"C:\Users\" + (filterString  (getdir #userscripts) @"\")[3] + @"\Desktop\")
		)
		fnRefreshList iniDesktop.dir type:arrFileType[rdoFileType.state]
	)

	on btnDesktopDir rightclick do 
	(
		dirOpened = getSavePath caption:"请设置桌面路径:" initialDir:(maxFilePath)
		if (dirOpened != undefined) then
		(
			iniDesktop.dir = dirOpened
			fnRefreshList iniDesktop.dir type:arrFileType[rdoFileType.state]
		)
	)

	on btnAutobackDir pressed do 
	(
		rdoFileType.state  = 1
		fnRefreshList (getdir #autoback) type:".max"
	)

	on btnScriptsDir pressed do
	(
		rdoFileType.state  = 4
		fnRefreshList (getdir #scripts) type:".ms*"
	)

	on btnScriptsDir rightclick do
	(
		rdoFileType.state  = 4
		fnRefreshList (getdir #startupScripts) type:".ms*"
	)

	on btnRecentFileDir pressed do 
	(
		fnLoadRecentFileList ()
		for i in arrRecentFiles do 
		(
			if doesFileExist i then
			(
				append arrRecentFilesName ("📄 " + (getFilenameFile i) + ".max")
			)
			else append arrRecentFilesName ("📄 ( X )  " + (getFilenameFile i) + ".max")
		)
		rdoFileType.state  = 1
		ltbFilesList.items = arrRecentFilesName
		edtBrowseFolder.text = "( 最近打开 Max 文件列表 )"
		lblCountTips.text = "文件：" + arrRecentFiles.count as string
		lblLikedFolder.text = if ltbLikedFolder.selected == undefined then "请添加常用目录" else ltbLikedFolder.selected
	)

	on btnClose pressed do 
	(
		try (destroydialog rolBsOpenTools) catch()
	)
	
	-- 文件操作按钮事件
	on btnCopyPath pressed do
	(
		local selectedFile = fnGetSelectedFilePath()
		if selectedFile != undefined and doesFileExist selectedFile then
		(
			try
			(
				-- 使用dotNet剪贴板功能
				local clipboard = dotNetClass "System.Windows.Forms.Clipboard"
				clipboard.SetText selectedFile
				messageBox "文件路径已复制到剪贴板！" title:"复制成功"
			)
			catch
			(
				messageBox "复制失败：" + (getCurrentException()) title:"复制失败"
			)
		)
		else
		(
			messageBox "请先选择一个文件！" title:"提示"
		)
	)
	
	on btnCopyFileName pressed do
	(
		local selectedFile = fnGetSelectedFilePath()
		if selectedFile != undefined and doesFileExist selectedFile then
		(
			try
			(
				local fileName = getFilenameFile selectedFile + getFilenameType selectedFile
				-- 使用dotNet剪贴板功能
				local clipboard = dotNetClass "System.Windows.Forms.Clipboard"
				clipboard.SetText fileName
				messageBox "文件名已复制到剪贴板！" title:"复制成功"
			)
			catch
			(
				messageBox "复制失败：" + (getCurrentException()) title:"复制失败"
			)
		)
		else
		(
			messageBox "请先选择一个文件！" title:"提示"
		)
	)

	on edtInputFilter entered textFolder do
	(
		fnRefreshList edtBrowseFolder.text filename:textFolder type:arrFileType[rdoFileType.state]
	)

	on ddlSort selected sel do
	(
		iniSortMode = sel
		fnRefreshList edtBrowseFolder.text type:arrFileType[rdoFileType.state]
		stSetConfigAll.fnSetConfigBsOpenTools ()
	)

	-- 预览相关事件
	on chePreview changed state do
	(
		fnTogglePreviewWindow state
		if chePreview.state and ltbFilesList.selection != 0 then
		(
			local selectedFile = fnGetSelectedFilePath()
			if selectedFile != undefined then
			(
				fnPreviewFile selectedFile
			)
		)
	)

	on ckbAutoFbxPreview changed state do
	(
		-- 保存 FBX 自动预览设置
		iniAutoFbxPreview = state
		stSetConfigAll.fnSetConfigBsOpenTools ()
	)
	
	on ltbFilesList selected id do
	(
		if chePreview.state and id != 0 then
		(
			local selectedFile = fnGetSelectedFilePath()
			-- print selectedFile
			if selectedFile != undefined then
			(
				fnPreviewFile selectedFile
			)
		)
	)
)
if (iniPosOpenTools != 0) then (Createdialog rolBsOpenTools fgcolor:myFgColor pos:iniPosOpenTools style:#() lockHeight:true)
else (Createdialog rolBsOpenTools fgcolor:myFgColor style:#() lockHeight:true)
fnBsEnsureDialogVisible rolBsOpenTools
------------------------toolbar----------------------------------------------------
macroScript BsOpenTools
category:"_[BulletTools]"
buttonText:"时光机"
toolTip:"时光机"
-- Icon:#("Systems",2)
(
	on execute do
	(
		fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BsOpenTools.ms")
	)
)
-------------------------------------------------------------------------------------