try(destroydialog rolSF6Export)catch()

global arrSF6MotCount = #()
global CB_GETCOUNT = 0x0146
global CB_GETCURSEL = 0x0147
global CB_SETCURSEL = 0x014E
global WM_COMMAND = 0x0111
global strSelMot = "null"
global idCurSelMot = 0

global dmcMeshFile
global arrSF6MotionFile
global SF6OutputPath

rollout rolSF6Export "SF6_ExportTool_v1.0__Bullet.S"
(
	editText edtMeshPath "" text:"" labelOnTop:true align:#left 
	height:20 fieldWidth:210 readOnly:true across:2
	button btnMeshFile "1.模型文件" align:#right tooltip:"选择目录" width:95 height:20
	editText edtMotPath "" text:"" labelOnTop:true align:#left 
	height:20 fieldWidth:210 readOnly:true across:2
	button btnMotPath "2.动作目录" align:#right tooltip:"选择目录" width:95 height:20
	editText edtOutputPath "" text:"" labelOnTop:true align:#left 
	height:20 fieldWidth:210 readOnly:true across:2
	button btnOutputPath "3.导出目录" align:#right tooltip:"选择目录" width:95 height:20
	
	button btnGetMotNum "4. 获取动作数" across:2 width:155 height:20
	button btnExport "5. 批量导出" across:2 width:155 height:20

	progressBar pgbValue value:100 color:white orient:#horizontal height:12

	local targetBone
	local rootBone
	local arrRootKeys

	fn fnGetMotNum =
	(
		local hwndImportRollout = dialogMonitorOps.getWindowHandle()
		strWinText = uiAccessor.getWindowText hwndImportRollout
		if (strWinText != undefined) then 
		(
			if (matchpattern strWinText pattern:"*Revil Motion Import*") then 
			(
				windowChildren = UIAccessor.getChildWindows hwndImportRollout
				for j in windowChildren do
				(
					if (UIAccessor.GetWindowClassName j == "ComboBox") then 
					(
						tempCountNum = (windows.sendmessage j CB_GETCOUNT 0 0)
						strCurSel = (uiAccessor.getWindowText j)
						if tempCountNum != 0 then 
						(
							print ("当前选中 < " + strCurSel + " > 动作总数: " + tempCountNum as string)
							append arrSF6MotCount tempCountNum
						)
						
					)
				)
				UIAccessor.PressButtonByName hwndImportRollout "Cancel"
			)
		)
		true
	)
	
	fn fnAutoImportMot =
	(
		local hwndImportRollout = dialogMonitorOps.getWindowHandle()
		strWinText = uiAccessor.getWindowText hwndImportRollout
		if (strWinText != undefined) then 
		(
			if (matchpattern strWinText pattern:"*Revil Motion Import*") then 
			(
				if UIAccessor.getChildWindows hwndImportRollout != undefined then 
				(windowChildren = UIAccessor.getChildWindows hwndImportRollout)
				for j in windowChildren do
				(
					if ((UIAccessor.GetWindowClassName j == "ComboBox") and (windows.sendmessage j CB_GETCOUNT 0 0)!=0) then 
					(
						windows.sendmessage j CB_SETCURSEL idCurSelMot 0
						windows.sendmessage hwndImportRollout WM_COMMAND (65536+(UIAccessor.GetWindowResourceID j)) j
						strSelMot = uiAccessor.getWindowText j
						print ("输出动作: " + strSelMot)
					)
				)
			)
			UIAccessor.PressButtonByName hwndImportRollout "Import"
		)
		true
	)

	on rolSF6Export open do (arrSF6MotCount = #();pgbValue.value = 0;clearlistener())
	
	on btnGetMotNum pressed do
	(	
		if arrSF6MotionFile != undefined and arrSF6MotionFile.count != 0 then 
		(
			DialogMonitorOps.Enabled = true
			DialogMonitorOps.RegisterNotification fnGetMotNum id:#getDmcMotCount
			for i = 1 to arrSF6MotionFile.count do
			(
				print ("动作文件: " + arrSF6MotionFile[i])
				importFile arrSF6MotionFile[i] using:REEngineImport
			)
			DialogMonitorOps.unRegisterNotification id:#getDmcMotCount
			DialogMonitorOps.Enabled = false
		)
	)

	on btnMeshFile pressed do 
	(
		dmcMeshFile = getOpenFileName leName caption:"选择模型文件" filename:".max" types:"max(*.max)|*.max|" historyCategory:"SF6Path"
		if dmcMeshFile != undefined then (edtMeshPath.text = dmcMeshFile)
	)

	on btnMotPath pressed do 
	(
		local dirOpened = ""
		dirOpened = getSavePath caption:"请选择路径:" initialDir:"SF6Path"
		if (dirOpened != undefined) then 
		(
			edtMotPath.text = dirOpened
			arrSF6MotionFile = getfiles (dirOpened + "\\*.motlist.653")
		)
	)

	on btnOutputPath pressed do 
	(
		SF6OutputPath = getSavePath caption:"请选择路径:" initialDir:"SF6Path"
		if SF6OutputPath != undefined then (edtOutputPath.text = SF6OutputPath)
	)

	on btnExport pressed do 
	(
		if arrSF6MotionFile != undefined and arrSF6MotionFile.count != 0 then 
		(
			DialogMonitorOps.Enabled = true
			DialogMonitorOps.RegisterNotification fnAutoImportMot id:#importDmcMot
			for i=1 to arrSF6MotionFile.count do
			(
				pgbValue.value = 100.*i/arrSF6MotionFile.count
				local tempNum = arrSF6MotCount[i]
				for j=0 to tempNum - 1 do
				(
					idCurSelMot = j
					resetMaxFile #noPrompt
					framerate = 60
					loadMaxFile dmcMeshFile useFileUnits:true quiet:true
					importFile arrSF6MotionFile[i] using:REEngineImport
					hideByCategory.geometry = true
					for k in objects where classof k == dummy do selectmore k
					for m in selection do m.boneEnable = true

					exportFile (SF6OutputPath + "\\" + strSelMot + ".FBX") #noPrompt selectedOnly:true using:FBXEXP

				)
			)
			DialogMonitorOps.unRegisterNotification id:#importDmcMot
			DialogMonitorOps.Enabled = false
		)
	)
)
createDialog rolSF6Export 340 125