try(destroydialog rolDmcExport)catch()

global arrDmcMotCount = #()
global CB_GETCOUNT = 0x0146
global CB_GETCURSEL = 0x0147
global CB_SETCURSEL = 0x014E
global WM_COMMAND = 0x0111
global strSelMot = "null"
global idCurSelMot = 0

global dmcMeshFile
global arrDmcMotionFile
global dmcOutputPath

rollout rolDmcExport "DmcExportTool_v2.0__Bullet.S"
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

	progressBar pgbValue value:100 color:green orient:#horizontal height:12

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
							append arrDmcMotCount tempCountNum
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

	on rolDmcExport open do (arrDmcMotCount = #();pgbValue.value = 0;clearlistener())
	
	on btnGetMotNum pressed do
	(	
		if arrDmcMotionFile != undefined and arrDmcMotionFile.count != 0 then 
		(
			DialogMonitorOps.Enabled = true
			DialogMonitorOps.RegisterNotification fnGetMotNum id:#getDmcMotCount
			for i = 1 to arrDmcMotionFile.count do
			(
				print ("动作文件: " + arrDmcMotionFile[i])
				importFile arrDmcMotionFile[i] using:REEngineImport
			)
			DialogMonitorOps.unRegisterNotification id:#getDmcMotCount
			DialogMonitorOps.Enabled = false
		)
	)

	on btnMeshFile pressed do 
	(
		dmcMeshFile = getOpenFileName leName caption:"选择模型文件" filename:".max" types:"max(*.max)|*.max|" historyCategory:"DmcPath"
		if dmcMeshFile != undefined then (edtMeshPath.text = dmcMeshFile)
	)

	on btnMotPath pressed do 
	(
		local dirOpened = ""
		dirOpened = getSavePath caption:"请选择路径:" initialDir:"DmcPath"
		if (dirOpened != undefined) then 
		(
			edtMotPath.text = dirOpened
			arrDmcMotionFile = getfiles (dirOpened + "\\*.motlist.85")
		)
	)

	on btnOutputPath pressed do 
	(
		dmcOutputPath = getSavePath caption:"请选择路径:" initialDir:"DmcPath"
		if dmcOutputPath != undefined then (edtOutputPath.text = dmcOutputPath)
	)

	on btnExport pressed do 
	(
		if arrDmcMotionFile != undefined and arrDmcMotionFile.count != 0 then 
		(
			DialogMonitorOps.Enabled = true
			DialogMonitorOps.RegisterNotification fnAutoImportMot id:#importDmcMot
			for i=1 to arrDmcMotionFile.count do
			(
				pgbValue.value = 100.*i/arrDmcMotionFile.count
				local tempNum = arrDmcMotCount[i]
				for j=0 to tempNum - 1 do
				(
					idCurSelMot = j
					resetMaxFile #noPrompt
					framerate = 60
					loadMaxFile dmcMeshFile useFileUnits:true quiet:true
					importFile arrDmcMotionFile[i] using:REEngineImport
					hideByCategory.geometry = true
					targetBone = getNodeByName "WeaponConst"
					for k in objects where classof k == dummy do selectmore k
					for m in selection do m.boneEnable = true
					rootBone = getNodeByName "root"
					animButtonState = true
					for n in selection as array do 
					(
						selectKeys n -0.0125f -0.0125f
						deleteKeys n #selection
						addNewKey n.controller 0f
						at time n.scale.controller.keys[1].time (n.scale.controller.value = [1,1,1])
					)
					arrRootKeys = rootBone.scale.controller.keys
					for h = 1 to arrRootKeys.count do
					(
						at time arrRootKeys[h].time
						(
							rootBone.scale.controller.value = [1,1,1]
						)
					)
					rootBone.position.controller = Position_XYZ ()
					for i in selection as array do
					(
						i.boneEnable = true
						i.position.controller = Position_XYZ ()
						i.rotation.controller = Euler_XYZ ()
						i.scale.controller = ScaleXYZ ()
					)
					targetBone.position.controller = tcb_position ()
					targetBone.rotation.controller = tcb_rotation ()
					targetBone.scale.controller = tcb_scale ()
					targetBone.position.controller = Position_XYZ ()
					targetBone.rotation.controller = Euler_XYZ ()
					targetBone.scale.controller = ScaleXYZ ()
					exportFile (dmcOutputPath + "\\" + strSelMot + ".FBX") #noPrompt selectedOnly:true using:FBXEXP
					-- savemaxfile  (dmcOutputPath + "\\" + strSelMot + ".max")
				)
			)
			DialogMonitorOps.unRegisterNotification id:#importDmcMot
			DialogMonitorOps.Enabled = false
		)
	)
)
createDialog rolDmcExport 340 125