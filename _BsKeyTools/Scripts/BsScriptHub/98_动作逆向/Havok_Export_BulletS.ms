try(destroydialog rolHavokExportTool)catch()

global myFgColor
global myClickColor
global myCheckedColor

curColorThemeFile = colorMan.getFileName()
if (curColorThemeFile != undefined) then
(
	if (matchpattern curColorThemeFile pattern:"*light*") then
	(
		myFgColor    = (color 28 89 177)
		myClickColor = (color 0 139 139)
		myCheckedColor = (color 152 227 213)
	)
	else
	(
		myFgColor    = (color 0 255 92)
		myClickColor = (color 0 255 127)
		myCheckedColor = (color 10 140 120)
	)
)
else
(
	myFgColor    = (color 0 255 92)
	myClickColor = (color 0 255 127)
	myCheckedColor = (color 10 140 120)
)
----获取当前主题是深色还是浅色,来更改文字颜色 fnGetColorTheme.ms

rollout rolHavokExportTool "HavokExportTool v1.3" 
(
	edittext edtMeshPath "" across:3 readonly:true
	button btnGetMeshPath "选择 Skin 文件" across:3
	button btnGetMotList "获取动作列表" across:3
	edittext edtOutputPath "" across:2 width:145 readonly:true
	button btnGetOutputPath "选择导出路径" across:2 width:135
	button btnExport "批量导出" width:280
	progressBar pgbProgress value:0 height:16 color:white
	HyperLink lnkLink "HAVOK 3DS MAX PLUGIN" color:myfgColor hovercolor:myClickColor visitedcolor:myClickColor \
	address:"https://lukascone.wordpress.com/2019/03/21/havok-3ds-max-plugin/" across:2
	label lblLink "2021.11_[Bullet.S]_4869" across:2
	label lblTips "免费插件，仅供学习，请勿商用，后果自负" across:1

	local CB_GETCOUNT       = 0x0146
	local CB_GETCURSEL      = 0x0147
	local CB_SETCURSEL      = 0x014E
	local WM_COMMAND        = 0x0111
	local BM_GETCHECK       = 0x00F0
	local BST_UNCHECKED     = 0
	local BST_CHECKED       = 1
	local BST_INDETERMINATE = 2
	local BM_SETCHECK       = 241

	local meshFile = ""
	local arrMotionFile = #()
	local outPutPath = ""

	fn fnAutoImportMot =
	(
		local hwndImportRollout = dialogMonitorOps.getWindowHandle()
		-- local importButtonGetChild = windows.getChildHWND hwndImportRollout "Import"
		local strSelMot = ""
		strWinText = uiAccessor.getWindowText hwndImportRollout
		if (strWinText != undefined) then 
		(
			if (matchpattern strWinText pattern:"*Havok Import*") then 
			(
				if UIAccessor.getChildWindows hwndImportRollout != undefined then 
				(windowChildren = UIAccessor.getChildWindows hwndImportRollout)
				for i in windowChildren do
				(
					if ((UIAccessor.GetWindowClassName i == "ComboBox") and (windows.sendmessage i CB_GETCOUNT 0 0) != 0) then 
					(
						strSelMot = uiAccessor.getWindowText i
						if (strSelMot == "Back") then 
						(
							windows.sendmessage i CB_SETCURSEL 2 0
							windows.sendmessage hwndImportRollout WM_COMMAND (65536+(UIAccessor.GetWindowResourceID i)) i
						)
					)
					-- if ((UIAccessor.GetWindowClassName i == "Button") and (windows.sendmessage i BM_GETCHECK 0 0) == 0) then 
					-- (
					-- 	strSelMot = uiAccessor.getWindowText i
					-- 	if (strSelMot == "Invert &Top") then 
					-- 	(
					-- 		windows.sendmessage i BM_SETCHECK 1 0
					-- 		windows.sendmessage hwndImportRollout WM_COMMAND (65536+(UIAccessor.GetWindowResourceID i)) i
					-- 		-- print "111"
					-- 	)
					-- )
				)
			)
			UIAccessor.PressButtonByName hwndImportRollout "&Import"
			-- UIAccessor.SendMessageID hwndImportRollout #IDOK
			-- for i in UIAccessor.getChildWindows hwndImportRollout do 
			-- (
			-- 	if (UIAccessor.GetWindowClassName i == "Import") then 
			-- 	(
			-- 		UIAccessor.PressButton i
			-- 		-- windows.sendmessage hwndImportRollout WM_COMMAND (65536+(UIAccessor.GetWindowResourceID i)) i
			-- 	)
			-- )
			-- UIAccessor.PressDefaultButton()
			-- UIAccessor.PressButton importButtonGetChild
		)
		true
	)

	on rolHavokExportTool open do (gc();clearlistener())

	on rolHavokExportTool close do (try(DialogMonitorOps.unRegisterNotification id:#importDSMot;DialogMonitorOps.Enabled = false) catch())

	on btnGetMeshPath pressed do
	(
		local strMeshFile = getOpenFileName caption:"Load MAX File" types:"MAX(*.max)|*.max|"
		if (strMeshFile != undefined) then (edtMeshPath.text = strMeshFile;meshFile = strMeshFile)
	)

	on btnGetMotList pressed do
	(
		if (edtMeshPath.text != "") then
		(
			local dir = getSavePath caption:"请选择目录:" initialDir:(((getfilenamepath edtMeshPath.text) + @"ani"))
			if (dir != undefined) then (arrMotionFile = (getfiles (dir + "\\*.hkx")))
			print arrMotionFile
		)
		else (messagebox "请先选择 Skin 文件!\t" caption:"提示")
	)

	on btnGetOutputPath pressed do
	(
		local dir = getSavePath caption:"请选择目录:" initialDir:(maxFilePath)
		if (dir != undefined) then (edtOutputPath.text = dir;outPutPath = dir)
	)

	on btnExport pressed do 
	(
		DialogMonitorOps.Enabled = true
		DialogMonitorOps.RegisterNotification fnAutoImportMot id:#importDSMot

		for i=1 to arrMotionFile.count do
		(
			-- gc()
			resetMaxFile #noPrompt
			
			loadMaxFile meshFile useFileUnits:true quiet:true
			framerate = 60
			importFile arrMotionFile[i] using:HavokImport quiet:true
			
			clearselection()
			for o in (objects as array) where ((classof o ==  Dummy) or (classof o ==BoneGeometry)) do (selectmore o)
			
			exportFile (outPutPath + "\\" + (getfilenamefile arrMotionFile[i]) + ".FBX") #noPrompt selectedOnly:true using:FBXEXP
			savemaxfile  (outPutPath + "\\" +  (getfilenamefile arrMotionFile[i])+ ".max") quiet:true
			pgbProgress.value = 100.*i/arrMotionFile.count
		)
		DialogMonitorOps.unRegisterNotification id:#importDSMot
		DialogMonitorOps.Enabled = false
	)
)
createDialog rolHavokExportTool 315 140 fgcolor:myFgColor