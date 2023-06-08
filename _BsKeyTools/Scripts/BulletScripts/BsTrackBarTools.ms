/*
 * @Description: 自动备份工具,大改自SaveButton脚本
 * @Author: Bullet.S
 * @Date: 2021-05-08 17:18:12
 * @LastEditors: Bullet.S
 * @LastEditTime: 2023-06-08 11:28:15
 * @Email: animator.bullet@foxmail.com
 */


if form != undefined then (form.close();form = undefined)
try (cui.UnRegisterDialogBar rolBsTrackBarTools) catch()
try (destroyDialog rolBsTrackBarTools) catch()
try (destroydialog rolBsBackupManager) catch()
try (destroydialog rolBsStopTime) catch()

global rolBsTrackBarTools
global rolBsBackupManager
Global BulletConfig      = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径
global iniBackupPath     = ((getdir #autoback) + "\\BsBackup")
global iniMaxBackupCount = 60
global iniPosAutoBackup
Global iniPosBackupManager
global iniStopTime = #(21,9)
global iniStopState = false
global iniDockPos
global heightBsSize = 30
global widthBsSize  = 335
Global SIOFile      = dotNetClass "System.IO.File"
Global SIODir       = dotNetClass "System.IO.Directory"
global arrBsBackupFiles = #()

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))
catch(messagebox "脚本安装可能不完全,建议重新安装...        " beep:false)
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))
catch(messagebox "脚本安装可能不完全,建议重新安装...        " beep:false)
stLoadConfigAll.fnLoadConfigTrackBarTools()

fn fnDelFileDir targetDel =  --删除文件
(
	if (SIOFile.Exists targetDel == true) then ---判断是否存在文件
	(
		dotnet.loadAssembly "Microsoft.VisualBasic.dll"
	
		FileIO = dotnetclass "Microsoft.VisualBasic.FileIO.FileSystem"
		UIOption = (dotnetclass "Microsoft.VisualBasic.FileIO.UIOption").OnlyErrorDialogs
		RecycleOption = (dotnetclass "Microsoft.VisualBasic.FileIO.RecycleOption").SendToRecycleBin

		if getFileAttribute targetDel #readOnly == true or \
		getFileAttribute targetDel #hidden == true do --修改只读或者隐藏属性
		(
			setFileAttribute targetDel #readOnly false ; \
			setFileAttribute targetDel #hidden false
		)
		try 
		(
			FileIO.DeleteFile targetDel UIOption RecycleOption
			-- SIOFile.Delete(targetDel)
			(print ("已删除: "+ filenameFromPath targetDel  + " 至回收站"))
		)
		catch 
		(
			messagebox ("删除失败: "+ filenameFromPath targetDel + ". 请尝试手动删除。          ") title:"BsTrackBarTools"
			(shellLaunch (getfilenamepath targetDel) "")
		)
	)
)
fn fnDelDir dirDel =
(
	if (SIODir.Exists dirDel) == true do
	(
		dotnet.loadAssembly "Microsoft.VisualBasic.dll"
	
		FileIO = dotnetclass "Microsoft.VisualBasic.FileIO.FileSystem"
		UIOption = (dotnetclass "Microsoft.VisualBasic.FileIO.UIOption").OnlyErrorDialogs
		RecycleOption = (dotnetclass "Microsoft.VisualBasic.FileIO.RecycleOption").SendToRecycleBin

		if getFileAttribute dirDel #readOnly == true or getFileAttribute dirDel #hidden == true do
		(
			setFileAttribute dirDel #readOnly false ; setFileAttribute dirDel #hidden false
		)
		try 
		(
			FileIO.DeleteDirectory dirDel UIOption RecycleOption
			-- SIODir.Delete(dirDel) true
			(print ("已删除: "+ pathConfig.stripPathToLeaf dirDel + " 文件夹至回收站"))
		)
		catch 
		(
			messagebox ("删除失败: "+ pathConfig.stripPathToLeaf dirDel + " 文件夹. 请尝试手动删除.") title:"BsTrackBarTools"
			(shellLaunch dirDel "")
		)
	)
)

fn fnLoadDockPos rolTarget wSize hSize =
(
	if doesFileExist BulletConfig do
	(
		try
		(
			nameAttrClass = substring rolTarget.name 4 rolTarget.name.count
			btnsArr = rolTarget.controls
			iniDockPos = fnGetConfig iniDockPos nameAttrClass "DockPos" "cui_dock_bottom"
			case iniDockPos of
			(
				"cui_dock_top":
				(
					try(cui.UnRegisterDialogBar rolTarget)catch()
					--	rearrange buttons to be horizontal
					for b = 1 to btnsArr.count where (classof btnsArr[b]) == dotNetControl do
					(
						case b of
						(
							(1):
							(
								btnsArr[b].pos = [0,0]
								btnsArr[b].height = 30
								btnsArr[b].width = 15
							)
							default:
							(
								btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,0]
							)
						)
					)
					rolTarget.height = hSize
					rolTarget.width = wSize
					cui.RegisterDialogBar rolTarget minSize:[wSize,hSize] maxSize:[wSize,hSize] style:#(#cui_dock_horz)
					cui.DockDialogBar rolTarget #cui_dock_top
					try(setINISetting BulletConfig nameAttrClass "DockPos" (#cui_dock_top as string))catch()
				)
				"cui_dock_bottom":
				(
					try(cui.UnRegisterDialogBar rolTarget)catch()
					--	rearrange buttons to be horizontal
					for b = 1 to btnsArr.count where (classof btnsArr[b]) == dotNetControl do
					(
						case b of
						(
							(1):
							(
								btnsArr[b].pos = [0,0]
								btnsArr[b].height = 30
								btnsArr[b].width = 15
							)
							default:
							(
								btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,0]
							)
						)
					)
					rolTarget.height = hSize
					rolTarget.width = wSize
					cui.RegisterDialogBar rolTarget minSize:[wSize,hSize] maxSize:[wSize,hSize] style:#(#cui_dock_horz)
					cui.DockDialogBar rolTarget #cui_dock_bottom
					try(setINISetting BulletConfig nameAttrClass "DockPos" (#cui_dock_bottom as string))catch()
				)
				"cui_dock_left":
				(
					try(cui.UnRegisterDialogBar rolTarget)catch()
					--	rearrange buttons to be vertical 
					for b = 1 to btnsArr.count where (classof btnsArr[b]) == dotNetControl do
					(
						case b of
						(
							(1):
							(
								btnsArr[b].pos = [0,0]
								btnsArr[b].height = 15
								btnsArr[b].width = hSize + 50
							)
							(4):
							(
								btnsArr[b].pos = [0,btnsArr[b - 1].pos.y + btnsArr[b - 1].height]
							)
							(5):
							(
								btnsArr[b].pos = [btnsArr[b - 1].width,btnsArr[b - 2].pos.y + btnsArr[b - 2].height]
							)
							default:
							(
								btnsArr[b].pos = [0,btnsArr[b - 1].pos.y + btnsArr[b - 1].height]
							)
						)
					)
					rolTarget.height = wSize + 50
					rolTarget.width = hSize + 50
					--
					cui.RegisterDialogBar rolTarget minSize:[hSize + 50,wSize] maxSize:[hSize + 50,wSize] style:#(#cui_dock_vert)
					cui.DockDialogBar rolTarget #cui_dock_left
					try(setINISetting BulletConfig nameAttrClass "DockPos" (#cui_dock_left as string))catch()
				)
				"cui_dock_right":
				(
					try(cui.UnRegisterDialogBar rolTarget)catch()
					--	rearrange buttons to be vertical 
					for b = 1 to btnsArr.count where (classof btnsArr[b]) == dotNetControl do
					(
						case b of
						(
							(1):
							(
								btnsArr[b].pos = [0,0]
								btnsArr[b].height = 15
								btnsArr[b].width = hSize + 50
							)
							(4):
							(
								btnsArr[b].pos = [0,btnsArr[b - 1].pos.y + btnsArr[b - 1].height]
							)
							(5):
							(
								btnsArr[b].pos = [btnsArr[b - 1].width,btnsArr[b - 2].pos.y + btnsArr[b - 2].height]
							)
							default:
							(
								btnsArr[b].pos = [0,btnsArr[b - 1].pos.y + btnsArr[b - 1].height]
							)
						)
					)
					rolTarget.height = wSize + 50
					rolTarget.width = hSize + 50
					cui.RegisterDialogBar rolTarget minSize:[hSize + 50,wSize] maxSize:[hSize + 50,wSize] style:#(#cui_dock_vert)
					cui.DockDialogBar rolTarget #cui_dock_right
					try(setINISetting BulletConfig nameAttrClass "DockPos" (#cui_dock_right as string))catch()
				)
				default:
				(
					try(cui.UnRegisterDialogBar rolTarget)catch()
					for b = 1 to btnsArr.count where (classof btnsArr[b]) == dotNetControl do
					(
						case b of
						(
							(1):
							(
								btnsArr[b].pos = [0,0]
								btnsArr[b].height = 30
								btnsArr[b].width = 15
							)
							default:
							(
								btnsArr[b].pos = [btnsArr[b - 1].pos.x + btnsArr[b - 1].width,0]
							)
						)
					)
					rolTarget.height = hSize
					rolTarget.width = wSize
					-- cui.RegisterDialogBar rolTarget style:#(#cui_dock_bottom,#cui_dock_top,#cui_floatable, #style_toolwindow) maxSize:[190,30]
					setDialogPos rolTarget (readvalue ((getINISetting BulletConfig nameAttrClass "PosTrackBarTools") as stringStream))
				)
			)
		)
		catch()
	)
)

rollout rolBsStopTime "BsBackup_暂停时段设置" width:180 height:135
(
	group ""
	(
		radiobuttons rdoTimeRange "" pos:[30,20] labels:#("禁用","暂停时段") default:1
		
		spinner spiStartTimeH "【起始】  时" pos:[70,45] width:70 height:20 type:#integer range:[0,23,21] scale:1 enabled:false
		spinner spiEndTimeH "【结束】  时" pos:[70,70] width:70 height:20 type:#integer range:[0,23,9] scale:1 enabled:false

		button btnApply "确定" pos:[20,95] width:140 height:25
	)
	
	fn fnChangeVisibleState =
	(
		if rdoTimeRange.state == 2 then 
		(
			iniStopState = true
		)
		else
		(
			iniStopState = false
		)
		stSetConfigAll.fnSetConfigTrackBarTools()
		spiStartTimeH.enabled = spiEndTimeH.enabled = iniStopState
		return iniStopState
	)
	
	on rolBsStopTime open do
	(
		stLoadConfigAll.fnLoadConfigTrackBarTools()
		stSetConfigAll.fnSetConfigTrackBarTools()
		if iniStopState then rdoTimeRange.state = 2 else rdoTimeRange.state = 1
		fnChangeVisibleState()
		spiStartTimeH.value = iniStopTime[1]
		spiEndTimeH.value   = iniStopTime[2]
	)

	on rolBsStopTime close do
	(
		stSetConfigAll.fnSetConfigTrackBarTools()
	)
	
	on rdoTimeRange changed state do 
	(
		fnChangeVisibleState()
	)

	on spiStartTimeH changed val do
	(
		iniStopTime[1] = val
		stSetConfigAll.fnSetConfigTrackBarTools()
	)

	on spiEndTimeH changed val do
	(
		iniStopTime[2] = val
		stSetConfigAll.fnSetConfigTrackBarTools()
	)

	on btnApply pressed do 
	(
		try (destroydialog rolBsStopTime) catch ()
	)
)

rcmenu menuBsTrackBarTools
(
	submenu "停靠位置"
	(
		menuItem mItemTop "上" checked:(if rolBsTrackBarTools.dialogBar and (cui.getDockState rolBsTrackBarTools) == "cui_dock_top" then true else false)
		menuItem mItemBottom "下" checked:(if rolBsTrackBarTools.dialogBar and (cui.getDockState rolBsTrackBarTools) == "cui_dock_bottom" then true else false)
		menuItem mItemLeft "左" checked:(if rolBsTrackBarTools.dialogBar and (cui.getDockState rolBsTrackBarTools) == "cui_dock_left" then true else false)
		menuItem mItemRight "右" checked:(if rolBsTrackBarTools.dialogBar and (cui.getDockState rolBsTrackBarTools) == "cui_dock_right" then true else false)
		separator menuSepDock
		menuItem mItemFloat "浮" checked:(if not rolBsTrackBarTools.dialogBar then true else false)
	)

	submenu "备份数量"
	(
		menuItem mItemBackupInfinite "无限制" checked:(if iniMaxBackupCount == 0 then true else false)
		separator mItemBackupCount
		menuItem mItemBackup3 "3" checked:(if iniMaxBackupCount == 3 then true else false)
		menuItem mItemBackup7 "7" checked:(if iniMaxBackupCount == 7 then true else false)
		menuItem mItemBackup24 "24" checked:(if iniMaxBackupCount == 24 then true else false)
		menuItem mItemBackup40 "40" checked:(if iniMaxBackupCount == 40 then true else false)
		menuItem mItemBackup60 "60" checked:(if iniMaxBackupCount == 60 then true else false)
		menuItem mItemBackup80 "80" checked:(if iniMaxBackupCount == 80 then true else false)
		menuItem mItemBackup100 "100" checked:(if iniMaxBackupCount == 100 then true else false)
	)

	submenu "路径配置"
	(
		menuItem mItemBackupPath "设定"
		menuItem mItemResetPath "重置"
	)

	menuItem mItemStopTime "暂停时段"
	
	menuItem mItemIsStartup "自启开关"
	separator menuSepClose
	menuItem mItemClose "关闭"

	local startupPath            = (getDir #StartupScripts)+ "\\BsTrackBarToolsStartup.ms"
	local startupBsTrackBarTools = (getDir #Scripts) + "\\BulletScripts\\StartupMS\\BsTrackBarToolsStartup.ms"

	on menuBsTrackBarTools open do
	(
		if(SIOFile.Exists startupPath) then (mItemIsStartup.checked = true)
		else (mItemIsStartup.checked = false)
	)

	on mItemStopTime picked do
	(
		try (destroydialog rolBsStopTime) catch ()
		if (iniPosBackupManager != 0) then 
		(Createdialog rolBsStopTime fgcolor:myFgColor pos:iniPosBackupManager style:#(#style_titlebar, #style_sysmenu, #style_toolwindow))
		else (Createdialog rolBsStopTime fgcolor:myFgColor style:#(#style_titlebar, #style_sysmenu, #style_toolwindow))
	)

	on mItemBackupPath picked do 
	(
		local dirOpened = getSavePath caption:"请选择备份路径: " initialDir:iniBackupPath

        if (dirOpened != undefined) then 
		(
			iniBackupPath = dirOpened
			rolBsBackupManager.edtBackupPath.text = iniBackupPath
			rolBsBackupManager.fnRefreshBackupAll()
			stSetConfigAll.fnSetConfigTrackBarTools()
		)
	)

	on mItemResetPath picked do 
	(
		iniBackupPath = ((getdir #autoback) + "\\BsBackup")
		rolBsBackupManager.edtBackupPath.text = iniBackupPath
		rolBsBackupManager.fnRefreshBackupAll()
		stSetConfigAll.fnSetConfigTrackBarTools()
	)

	on mItemIsStartup picked do
	(
		if (mItemIsStartup.checked == true) then 
		(
			fnDelFileDir startupPath
			mItemIsStartup.checked = false
			messagebox ("已解除 BsTrackBarTools 自启！                  ")  title:"自启设置"
		)
		else 
		(
			if (not (SIOFile.Exists startupPath)) do
			(
				try 
				(
					-- SIOFile.Copy startupBsTrackBarTools startupPath
					FileIO.Copyfile startupBsTrackBarTools startupPath UIOption
					messagebox ("已打开 BsTrackBarTools 自启！                  ")  title:"自启设置"
					mItemIsStartup.checked = true
					setFileAttribute startupPath #readOnly true
				)
				catch
				(
					-- messagebox ("自启失败，烦请管理员运行 max 或手动处理：\r\n\r\n把 StartupMS\\BsTrackBarToolsStartup.ms 复制到\r\n\r\n" + (getDir #StartupScripts) + "                    ")
					-- (shellLaunch (getfilenamepath startupBsTrackBarTools) "")
				)
			)
		)
	)

	on mItemTop picked do
	(
		if not mItemTop.checked then 
		(
			if iniDockPos == "float" then (iniPosAutoBackup = (GetDialogPos rolBsTrackBarTools))
			iniDockPos = "cui_dock_top"
			stSetConfigAll.fnSetConfigTrackBarTools()
			fnLoadDockPos rolBsTrackBarTools widthBsSize heightBsSize
			if (rolBsTrackBarTools.SaveInterval > 0) then rolBsTrackBarTools.clock.active = true
		)
	)

	on mItemBottom picked do
	(
		if not mItemBottom.checked then 
		(
			if iniDockPos == "float" then (iniPosAutoBackup = (GetDialogPos rolBsTrackBarTools))
			iniDockPos = "cui_dock_bottom"
			stSetConfigAll.fnSetConfigTrackBarTools()
			fnLoadDockPos rolBsTrackBarTools widthBsSize heightBsSize
			if (rolBsTrackBarTools.SaveInterval > 0) then rolBsTrackBarTools.clock.active = true
		)
	)

	on mItemLeft picked do
	(
		if not mItemLeft.checked then 
		(
			if iniDockPos == "float" then (iniPosAutoBackup = (GetDialogPos rolBsTrackBarTools))
			iniDockPos = "cui_dock_left"
			stSetConfigAll.fnSetConfigTrackBarTools()
			fnLoadDockPos rolBsTrackBarTools widthBsSize heightBsSize
			if (rolBsTrackBarTools.SaveInterval > 0) then rolBsTrackBarTools.clock.active = true
		)
	)

	on mItemRight picked do
	(
		if not mItemRight.checked then 
		(
			if iniDockPos == "float" then (iniPosAutoBackup = (GetDialogPos rolBsTrackBarTools))
			iniDockPos = "cui_dock_right"
			stSetConfigAll.fnSetConfigTrackBarTools()
			fnLoadDockPos rolBsTrackBarTools widthBsSize heightBsSize
			if (rolBsTrackBarTools.SaveInterval > 0) then rolBsTrackBarTools.clock.active = true
		)
	)

	on mItemFloat picked do
	(
		if not mItemFloat.checked then 
		(
			iniDockPos = "float"
			stSetConfigAll.fnSetConfigTrackBarTools()
			fnLoadDockPos rolBsTrackBarTools widthBsSize heightBsSize
			if (rolBsTrackBarTools.SaveInterval > 0) then rolBsTrackBarTools.clock.active = true
		)
	)

	on mItemClose picked do
	(
		if form != undefined then ( form.close(); form = undefined  )
		try (cui.UnRegisterDialogBar rolBsTrackBarTools) catch()
		try (destroyDialog rolBsTrackBarTools) catch()
	)

	on mItemBackup4 picked do 
	(
		iniMaxBackupCount = 4
		stSetConfigAll.fnSetConfigTrackBarTools()
	)

	on mItemBackup7 picked do 
	(
		iniMaxBackupCount = 7
		stSetConfigAll.fnSetConfigTrackBarTools()
	)

	on mItemBackup24 picked do 
	(
		iniMaxBackupCount = 24
		stSetConfigAll.fnSetConfigTrackBarTools()
	)

	on mItemBackup40 picked do 
	(
		iniMaxBackupCount = 40
		stSetConfigAll.fnSetConfigTrackBarTools()
	)

	on mItemBackup60 picked do 
	(
		iniMaxBackupCount = 60
		stSetConfigAll.fnSetConfigTrackBarTools()
	)

	on mItemBackup80 picked do 
	(
		iniMaxBackupCount = 80
		stSetConfigAll.fnSetConfigTrackBarTools()
	)

	on mItemBackup100 picked do 
	(
		iniMaxBackupCount = 100
		stSetConfigAll.fnSetConfigTrackBarTools()
	)

	on mItemBackupInfinite picked do 
	(
		iniMaxBackupCount = 0
		stSetConfigAll.fnSetConfigTrackBarTools()
	)

)

rollout rolBsTrackBarTools "BsTrackBarTools_v1.1" 
(
	local form, mcolor, rcLIST,  SaveInterval, saveInterval_FN , autobackup
	local INIfile = ( getDir #maxData ) + "\\BulletConfig.ini"
	local mcolor = dotnetclass "System.drawing.color" 
	local malign = dotnetclass "System.Drawing.ContentAlignment"
	
	local dnFontStyle = dotNetClass "System.Drawing.FontStyle"
	local myFontStyle = dotnet.combineenums dnFontStyle.bold --dnFontStyle.italic

	dotnetcontrol btnConfig "Button" height:30 width:15 pos:[0,0]
	dotnetcontrol btnFilesCount "Button" height:30 width:80 pos:[15,0]
	-- dotnetcontrol btnUndock "Button" height:40 width:15 pos:[0,0]
	-- dotnetcontrol btnDockTop "Button" height:15 width:15 pos:[15,0]
	-- dotnetcontrol btnDockBottom "Button" height:15 width:15 pos:[15,15]
	dotnetcontrol btnTimer "Button" height:30 width:80 pos:[95,0] --replace
	dotnetcontrol btnBackup "Button" height:30 width:40 pos:[175,0] --increment
	dotnetcontrol btnSaveAs "Button" height:30 width:40 pos:[215,0]  --save as
	dotnetcontrol btnBackupManager "Button" height:30 width:80 pos:[255,0]  --打开备份文件夹
	
	timer clock "testClock" interval:1000 active:false  --tick once a second

	fn fnButtonStyle tarButton textButton =
	(
		tarButton.text = textButton
		tarButton.flatstyle = dotnetobject "System.Windows.Forms.FlatStyle" Flat
		tarButton.FlatAppearance.BorderColor = mcolor.gray 
		tarButton.FlatAppearance.MouseOverBackColor = BsDotCheckColor
		tarButton.backcolor = BsDotBackColor
		tarButton.ForeColor = BsDotForeColor
	)

	fn saveInterval_FN TimeInterval = 
	(
		clock.active = true -- si le pr�c�dent == 0, on active
		
		setINISetting INIfile "SaveButton" "SaveInterval" TimeInterval  forceUTF16:false --force ASCII
		
		SaveInterval = TimeInterval as integer
		
		if clock.ticks < SaveInterval*60 then
		(
			btnTimer.backcolor = BsDotCheckColor
			btnTimer.FlatAppearance.MouseOverBackColor = BsDotCheckColor
		)
	)
	
	fn SaveMenu = --rightCLIC 
	(
		rcMenu rcLIST
		(
			menuitem m_off "关闭计时" 		checked:(if SaveInterval == 0 then true else false)
			menuitem m_restart "重新计时" 		 checked:false
			menuItem m_autoback "自动备份" checked:(if autobackup == "true" then true else false)
			
			separator sep1  
			
			menuitem m_1 "1 分钟" 	checked:(if SaveInterval == 1 then true else false)
			menuitem m_3 "3 分钟" 	checked:(if SaveInterval == 3 then true else false)
			menuitem m_5 "5 分钟" 	checked:(if SaveInterval == 5 then true else false)
			menuItem m_10 "10 分钟"	checked:(if SaveInterval == 10 then true else false)
			menuItem m_15 "15 分钟"	checked:(if SaveInterval == 15 then true else false)
			menuItem m_20 "20 分钟"	checked:(if SaveInterval == 20 then true else false)
			menuItem m_30 "30 分钟"	checked:(if SaveInterval == 30 then true else false)
			menuItem m_45 "45 分钟"	checked:(if SaveInterval == 45 then true else false)
			menuItem m_60 "60 分钟"	checked:(if SaveInterval == 60 then true else false)
			
			on m_off picked do 	
			( 
				btnTimer.text = "关闭计时" 
				saveInterval_FN "0" 
				
				btnTimer.backcolor = BsDotCheckColor
				btnTimer.FlatAppearance.MouseOverBackColor = BsDotCheckColor
				
				clock.active = false
				clock.ticks = 0
			)

			on m_autoback picked do 
			(
				m_autoback.checked = not m_autoback.checked
				autobackup = (m_autoback.checked as string)
				setINISetting INIfile "SaveButton" "Autobackup" autobackup
			)
			
			on m_1 picked do 	( saveInterval_FN "1"  )
			on m_3 picked do 	( saveInterval_FN "3"  )
			on m_5 picked do 	( saveInterval_FN "5"  )
			on m_10 picked do 	( saveInterval_FN "10"  )
			on m_15 picked do 	( saveInterval_FN "15"  )
			on m_20 picked do 	( saveInterval_FN "20"  )
			on m_30 picked do 	( saveInterval_FN "30"  )
			on m_45 picked do 	( saveInterval_FN "45"  )
			on m_60 picked do 	( saveInterval_FN "60"  )

			on m_restart picked do
			(
				clock.ticks = 0
				
				btnTimer.backcolor = BsDotCheckColor
				btnTimer.FlatAppearance.MouseOverBackColor = BsDotCheckColor
			)
		)
	)

	fn fnFilesCount = 
	(
		tarPath = maxFilePath
		numFiles = 0
		if maxFileName != "" then
		(
			tarPath = (iniBackupPath + "\\" + (getFilenameFile maxFileName) + ".backup")
			numFiles = (getfiles (tarPath + "\\*.max")).count
			if numFiles != 0 then (numFiles = numFiles + 1) else (numFiles = 0)
		)
		else (fnButtonStyle rolBsTrackBarTools.btnFilesCount ("暂无备份"))
		if numFiles == 0 then 
		(
			fnButtonStyle rolBsTrackBarTools.btnFilesCount ("暂无备份")
		)
		else 
		(
			fnButtonStyle rolBsTrackBarTools.btnFilesCount ("当前版本" + numFiles as string)
		)
		rolBsTrackBarTools.btnFilesCount.FlatAppearance.BorderColor = mcolor.gray 
	)
	
	fn fnIsStopTime =
	(
		local isStopTime = false

		if iniStopState then 
		(
			local dateTime = (dotNetClass "System.DateTime").Now
			local curHour = dateTime.Hour
	
			timeStart = iniStopTime[1]
			timeEnd = iniStopTime[2]
	
			case of 
			(
				(iniStopTime[2] == iniStopTime[1]):
				(
					isStopTime = (if curHour == iniStopTime[2] then true else false)
				)
				(iniStopTime[2] < iniStopTime[1]):
				(
					if (curHour >= iniStopTime[1] and curHour <= 23) or \
					(curHour >= 0 and curHour <= iniStopTime[2]) then 
					(
						isStopTime = true
					)
					else (isStopTime = false)
				)
				(default):
				(
					if (curHour >= iniStopTime[1] and curHour <= iniStopTime[2]) then
					(
						isStopTime = true
					)
					else (isStopTime = false)
				)
			)
		)
		return isStopTime
	)

	fn fnTrackBarQuickSave =
	(
		if objects.count != 0 and getSaveRequired() then 
		(
			if maxFilePath == "" then 
			(
				-- messagebox "------------------------------------\r\n\r\n当前场景未保存过,\r\n\r\n请先保存初始版本~\r\n\r\n------------------------------------"
				-- -- max file saveas
				-- btnTimer.text = "请先保存" 
				-- saveInterval_FN "0" 
				
				-- btnTimer.backcolor = BsDotCheckColor
				-- btnTimer.FlatAppearance.MouseOverBackColor = BsDotCheckColor
				
				-- clock.active = false
				-- clock.ticks = 0

				local strCurFilePath    = (iniBackupPath + "\\@BsAutoBackup.max")
				local strCurFileName    = "@BsAutoBackup"
			)
			else
			(
				local strCurFilePath    = (maxFilePath + maxFileName)
				local strCurFileName    = getFilenameFile maxFileName
			)
			local strBackupPathRoot = iniBackupPath + "\\" + strCurFileName + ".backup"
			local arrBackupFiles = getfiles (strBackupPathRoot + "\\*.max")
			qsort arrBackupFiles fnPseudoNaturalSort
			-- print arrBackupFiles
			if iniMaxBackupCount != 0 then
			(
				if arrBackupFiles.count >= iniMaxBackupCount then 
				(
					for i = 1 to (arrBackupFiles.count - iniMaxBackupCount + 1) do 
					(
						fnDelFileDir arrBackupFiles[i]
					)
				)
				-- print iniMaxBackupCount
				-- print arrBackupFiles.count
			)

			if matchpattern strCurFilePath pattern:("*.backup\\*.max") then 
			(
				strBackupPathRoot = maxFilePath
				arrBackupFiles = getfiles (strBackupPathRoot + "\\*.max")
				qsort arrBackupFiles fnPseudoNaturalSort
				strSaveFileName   = getFilenameFile arrBackupFiles[arrBackupFiles.count]
				arrEndCountFilter = (filterString strSaveFileName "_")
				strSaveCount      = ((execute arrEndCountFilter[arrEndCountFilter.count])) as string
				strSaveName       = substring strSaveFileName 1 (strSaveFileName.count - strSaveCount.count - 1)
				strSaveCount      = ((execute strSaveCount) + 1) as string
				strBackupFilePath = strBackupPathRoot + "\\" + strSaveName + "_" + strSaveCount + ".max"
				saveMaxFile strBackupFilePath
				displayTempPrompt ("已备份并打开：" + strBackupFilePath) 10000
				messagebox ("当前备份的是已备份文件，请注意跟源文件对比新旧！\r\n\r\n可能的源文件：" + strSaveName + ".max\r\n\r\n刚才备份的文件：" + strCurFilePath + ".max                                                                           ") title:"BsTrackBarTools"
			) 
			else
			(
				if (not (SIODir.Exists strBackupPathRoot))
				do (SIODir.CreateDirectory strBackupPathRoot)
				if arrBackupFiles.count == 0 then 
				(
					strSaveCount = "1"
				) 
				else if arrBackupFiles.count > 0 then
				(
					strSaveFileName   = getFilenameFile arrBackupFiles[arrBackupFiles.count]
					arrEndCountFilter = (filterString strSaveFileName "_")
					strSaveCount      = ((execute arrEndCountFilter[arrEndCountFilter.count]) + 1) as string
				)
				strBackupFilePath = strBackupPathRoot + "\\" + strCurFileName + "_" + strSaveCount + ".max"
				-- saveMaxFile strCurFilePath
				if (not (SIOFile.Exists strBackupFilePath)) do
				(
					try 
					(
						saveMaxFile strBackupFilePath clearNeedSaveFlag:false useNewFile:false
						displayTempPrompt ("已备份至：" + strBackupFilePath) 10000 
					)
					catch()
				)
			)
			rolBsTrackBarTools.fnFilesCount()
			rolBsBackupManager.fnRefreshBackupAll()
		)
		else (displayTempPrompt ("当前文件无内容或无改动，不需要自动备份，也可点击迭代强制备份！") 10000)
	)
	
	on rolBsTrackBarTools open do
	(
		stLoadConfigAll.fnLoadConfigTrackBarTools()
		stSetConfigAll.fnSetConfigTrackBarTools()
		fnLoadDockPos rolBsTrackBarTools widthBsSize heightBsSize
		callbacks.removeScripts #filePostOpen id:#UpdateBsBackup
		callbacks.removeScripts #filePostSave id:#UpdateBsBackup
		callbacks.removeScripts #systemPostReset id:#UpdateBsBackup
		callbacks.addScript #systemPostReset "rolBsTrackBarTools.fnFilesCount()" id:#UpdateBsBackup
		callbacks.addScript #filePostOpen "rolBsTrackBarTools.fnFilesCount()" id:#UpdateBsBackup
		callbacks.addScript #filePostSave "rolBsTrackBarTools.fnFilesCount()" id:#UpdateBsBackup
		callbacks.removeScripts id:#SaveButtonCallback
		callbacks.addScript #filePostOpenProcess "rolBsTrackBarTools.clock.ticks = 0" id:#SaveButtonCallback
		
		callbacks.removeScripts id:#SaveButtonResetCallback
		callbacks.addScript #systemPostReset "rolBsTrackBarTools.clock.ticks = 0" id:#SaveButtonResetCallback
		SaveMenu() 
		Inter = ( getINISetting INIfile "SaveButton" "SaveInterval" ) 
		autobackup = ( getINISetting INIfile "SaveButton" "Autobackup" ) 
		if autobackup == "" then (setINISetting INIfile "SaveButton" "Autobackup" "false";autobackup = "false")

		if Inter == "" then
		( 
			setINISetting INIfile "SaveButton" "SaveInterval" "15" forceUTF16:false --force ASCII
			
			SaveInterval = 15
			clock.active = true
		)
		else
		(
			if Inter as integer != 0 then (saveInterval_FN Inter)
			else 
			(
				SaveInterval = 0
				clock.active = false
				btnTimer.text = "关闭计时"
			)
		)
		-- fnButtonStyle btnDockTop "▲"
		-- fnButtonStyle btnDockBottom "▼"
		fnButtonStyle btnTimer "激活备份"
		btnTimer.font = dotNetObject "System.Drawing.Font" "Arial" 9 myFontStyle
		fnButtonStyle btnBackup "迭代"
		fnButtonStyle btnSaveAs "另存"
		fnButtonStyle btnBackupManager "备份管理"
		fnFilesCount()
		fnButtonStyle btnConfig ""
		local objToolTip = dotnetobject "System.Windows.Forms.ToolTip"  
		objToolTip.SetToolTip btnFilesCount "左键打开面板，右键打开文件夹"
		objToolTip.Active = True
		objToolTip.tooltipicon = (dotnetclass "System.Windows.Forms.ToolTipIcon").none
		-- other types of tooltip icon are 
		--.Error
		-- .info
		-- .none
		btnConfig.BackColor = BsDotCheckColor
		
	)
	
	on rolBsTrackBarTools close do
	(
		iniPosAutoBackup = (GetDialogPos rolBsTrackBarTools)
		-- iniDockPos = ((cui.getDockState rolBsTrackBarTools) as string)
		-- print iniDockPos
		callbacks.removeScripts #filePostOpen id:#UpdateBsBackup
		callbacks.removeScripts #filePostSave id:#UpdateBsBackup
		stSetConfigAll.fnSetConfigTrackBarTools()
		callbacks.removeScripts id:#SaveButtonCallback
		callbacks.removeScripts id:#SaveButtonResetCallback
		clock.active = false
		
		if form != undefined then ( form.close(); form = undefined  )
	)
	
	on btnConfig mouseDown senderArg arg do
	(
		popupMenu menuBsTrackBarTools pos:[mouse.screenpos.x,mouse.screenpos.y + 20]
	)
	
	on btnTimer mouseDown senderArg arg do -- replace
	(
		if arg.button == arg.button.left or arg.button == arg.button.right do
		(
			-- sceneName = maxFilePath + maxFileName
			-- saveMaxFile sceneName quiet:true
				
			-- clearlistener()
			-- print "文件已覆盖保存"

			
			-- clock.ticks = 0
			
			-- btnTimer.backcolor = BsDotCheckColor
			-- btnTimer.FlatAppearance.MouseOverBackColor = BsDotCheckColor

			popUpMenu rcLIST pos:( [arg.x  , arg.y - 10 ] ) rollout:rolBsTrackBarTools align:#align_topleft
		)
		-- if arg.button == arg.button.right do
		-- (
			
		-- )
		
	)
	
	on btnBackup mouseDown senderArg arg do -- incremental
	(
		if arg.button == arg.button.left do
		(
			setSaveRequired true

			fnTrackBarQuickSave()

			clock.ticks = 0
			
			btnTimer.backcolor = BsDotCheckColor
			btnTimer.FlatAppearance.MouseOverBackColor = BsDotCheckColor
		)
-- 		
	)
	
	on btnSaveAs mouseDown senderArg arg do --save as
	(
		if arg.button == arg.button.left do
		(
			theName = getMAXSaveFileName() 
			
			if theName != undefined then
			(
				saveMaxFile theName
				
				clock.ticks = 0
				
				btnTimer.backcolor = BsDotCheckColor
				btnTimer.FlatAppearance.MouseOverBackColor = BsDotCheckColor
				
				clearlistener()
				print "保存成功"
			)
			else
			(
				clearlistener()
				print "保存失败"
			)
		)
	)

	on btnFilesCount MouseDown senderArg arg do
	(
		if arg.button == btnFilesCount.mousebuttons.left then
		(
			if maxFileName != "" then
			(
				if matchpattern (maxFilePath + maxFileName) pattern:("*.backup\\*.max") then 
				(
					try(shellLaunch maxfilepath "")catch()
				)
				else
				(
					try(shellLaunch (iniBackupPath + "\\" + (getFilenameFile maxFileName) + ".backup") "")catch()
				)
			)
			else (try(shellLaunch iniBackupPath "")catch())
		)
	)

	on btnBackupManager MouseDown senderArg arg do
	(
		if arg.button == btnFilesCount.mousebuttons.left then
		(
			try (destroydialog rolBsBackupManager) catch ()
			if (iniPosBackupManager != 0) then (Createdialog rolBsBackupManager fgcolor:myFgColor pos:iniPosBackupManager style:#())
			else (Createdialog rolBsBackupManager fgcolor:myFgColor style:#())
		)
	)

	
	on clock tick do
	(
		if not fnIsStopTime() then
		(
			if SaveInterval > 0 do
			(
				Inter = SaveInterval * 60
				
				T = clock.ticks
				
				(
					if T<60 then ( TimeTXT = "00 : 00 : " + T as string  )
					else
					(
						if T > 3600 then --display Hours, min, secs
						(
							hours = T/3600 as integer
							
							minREST = ( T - hours*3600 )
							mins = minREST / 60 as integer
							
							secs = minREST - mins*60
							
							TimeTXT = hours as string + " : " + mins as string + " : " + secs as string
						)
						else --display mins secs
						(
						
							mins = T/60 as integer
							secs = T - mins*60
							
							TimeTXT = "0 : " + mins as string + " : " + secs as string
						)
					)
					
					btnTimer.text = TimeTXT
					
				)
				
				if T == Inter do
				(
					if autobackup == "true" then
					(
						fnTrackBarQuickSave()
						clock.ticks = 0
				
						btnTimer.backcolor = BsDotCheckColor
						btnTimer.FlatAppearance.MouseOverBackColor = BsDotCheckColor
					)
				)

				if T > Inter do
				(
					
					if (mod T 2)==0 then
					(
						COL = mcolor.Red
						
						btnTimer.text = "请保存 !!"
					)
					else
					(
						COL = BsDotBackColor
						
						btnTimer.text = TimeTXT
					)
					OverCOL = mcolor.darkred

					btnTimer.backcolor = COL
					btnTimer.FlatAppearance.MouseOverBackColor = OverCOL
					
				)
			)
		)
		else btnTimer.text = "暂停时段"
	)
)

if (iniPosAutoBackup != 0) then (createDialog rolBsTrackBarTools widthBsSize heightBsSize pos:iniPosAutoBackup style:#(#style_sysmenu,#style_toolwindow))
else (createDialog rolBsTrackBarTools widthBsSize heightBsSize style:#(#style_sysmenu,#style_toolwindow))

-- cui.RegisterDialogBar rolBsTrackBarTools style:#(#cui_dock_bottom,#cui_dock_top,#cui_floatable, #style_toolwindow) maxSize:[190,30]
-- cui.DockDialogBar rolBsTrackBarTools  #cui_dock_top
if (rolBsTrackBarTools.SaveInterval > 0) then rolBsTrackBarTools.clock.active = true


rcmenu menuBsFiles
(
	menuItem mItemOpenFile "打开文件"
	menuItem mItemDelete "删除文件"
	menuItem mItemOpenMenu "打开目录"

	on mItemOpenFile picked do 
	(
		if (rolBsBackupManager.mlbBackupFiles.selection as array).count == 1 then 
		(
			tarFile = arrBsBackupFiles[(rolBsBackupManager.mlbBackupFiles.selection as array)[1]]
			if (doesfileexist tarFile) then
			(
				if CheckForSave() then (loadMaxFile tarFile useFileUnits:true)
			)
		)
	)

	on mItemDelete picked do 
	(
		if (queryBox "确定删除选中的已备份文件？                        " title:"BsTrackBarTools" beep:false) then
		(
			arrFileDelete = (rolBsBackupManager.mlbBackupFiles.selection as array)
			for i = 1 to arrFileDelete.count do 
			(
				fnDelFileDir arrBsBackupFiles[i]
			)
			rolBsBackupManager.fnRefreshFilesList()
		)
	)

	on mItemOpenMenu picked do 
	(
		if (rolBsBackupManager.mlbBackupFiles.selection as array).count == 1 then 
		(
			tarFile = arrBsBackupFiles[(rolBsBackupManager.mlbBackupFiles.selection as array)[1]]
			pathFile = (getfilenamepath tarFile)
			if (doesdirectoryexist pathFile) then
			(
				try(shellLaunch pathFile "")catch()
			)
		)
	)
)

rcmenu menuBsFolder
(
	menuItem mItemOpenFile "打开备份库"
	menuItem mItemDelete "删除备份库"

	on mItemOpenFile picked do 
	(
		if (rolBsBackupManager.mlbBackupFolders.selection as array).count == 1 then 
		(
			idFolderSelected = (rolBsBackupManager.mlbBackupFolders.selection as array)[1]
			nameFolderSelected = (rolBsBackupManager.mlbBackupFolders.items)[idFolderSelected]
			nameFolderSelected = (substituteString nameFolderSelected "📂 " "")
			tarFolder = (rolBsBackupManager.edtBackupPath.text + "\\" + nameFolderSelected + ".backup")
			if (doesdirectoryexist tarFolder) then
			(
				try(shellLaunch tarFolder "")catch()
			)
		)
	)

	on mItemDelete picked do 
	(
		if (rolBsBackupManager.mlbBackupFolders.selection as array).count != 0 then 
		(
			if (queryBox "确定删除选中备份库和当中的【所有】文件？                        " title:"BsTrackBarTools" beep:false) then
			(
				with undo on 
				(
					arrDirDelete = #()
					for i in (rolBsBackupManager.mlbBackupFolders.items as array) do 
					(
						nameFolder = (substituteString i "📂 " "")
						append arrDirDelete (rolBsBackupManager.edtBackupPath.text + "\\" + nameFolder + ".backup")
					)
					arrDirID = (rolBsBackupManager.mlbBackupFolders.selection as array)
					for i in arrDirID do 
					(
						fnDelDir arrDirDelete[i]
					)
					rolBsBackupManager.fnRefreshBackupAll()
					rolBsTrackBarTools.fnFilesCount()
				)
			)
		)
	)
)

rollout rolBsBackupManager "" width:430 height:320
(
	local posMouMove     = [0,0]
	local switchMouState = false

	groupbox grpMain " BsBackupManager_v1.1" \
	width:(rolBsBackupManager.width - 10) height:(rolBsBackupManager.height - 5) pos:[5,0]
	button btnClose "X" pos:[rolBsBackupManager.width - 15,0] height:15 width:15
	button btnRefreshFolder "R" align:#left border:false \
	height:20 width:25 pos:[10,20] tooltip:"左：刷新当前文件和备份目录\r\n右：刷新 3dsMax 自动保存目录"
	button btnOpenCurrentDir "打开" tooltip:"打开备份文件夹" \
	height:20 width:25 pos:[35,20] border:false
	editText edtBackupPath "" text:"" labelOnTop:true align:#left \
	height:20 fieldWidth:355 pos:[65,20] readOnly:true 
	-- button btnPrevFolder "↑" tooltip:"返回上层目录" \
	-- height:20 width:25 pos:[340,20] border:false
	editText edtInputFilter "" text:"" labelOnTop:true align:#left \
	height:17 fieldWidth:375 pos:[10,47]
	checkbutton ckbReverse "↑ ↓" pos:[390,47] height:18 width:30
	MultiListBox mlbBackupFolders "" align:#left selection:0 \
	height:15 width:170 pos:[10,70]
	MultiListBox mlbBackupFiles "" align:#right selection:0 \
	height:18 width:240 pos:[180,70]
	label lblCountFolder "" height:15 width:120 pos:[15,275]
	label lblCountFiles "" height:15 width:120 pos:[15,295]

	fn fnGetLastFolder strFolder =
	(
		if ((strFolder != iniPosAutoBackup) and (doesDirectoryExist strFolder)) then
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

	fn fnRefreshFolderList strFilesDir =
	(
		arrFolders = #()
		arrFoldersName = #()
		if strFilesDir != undefined then 
		(
			if ((strFilesDir != "") and (doesDirectoryExist strFilesDir)) then
			(
				local tempDir = GetDirectories (strFilesDir + "/*")
				for i in tempDir do 
				(
					append arrFolders (substring i 1 (i.count-1))
				)
				qsort arrFolders fnPseudoNaturalSort
				
				if arrFolders[1] != undefined then
				(
					for c in arrFolders do  --获取文件夹名字,后面切换脚本类别和列表会用到
					(
						append arrFoldersName ("📂 " + (getFilenameFile c))
					)
				)
				rolBsBackupManager.mlbBackupFolders.items = arrFoldersName
				rolBsBackupManager.edtBackupPath.text = strFilesDir
			)
		)
		else messagebox "-------------------------------------\r\n\r\n文件夹可能已不存在\r\n\r\n请尝试刷新\r\n\r\n-------------------------------------"
		lblCountFolder.text = "备份库：" + arrFolders.count as string + " 个"
	)

	fn fnRefreshFilesList type:".max" =
	(
		-- mlbBackupFiles.selection = 0
		idFolderSelected = 0
		nameFolderSelected = ""
		arrBsBackupFiles = #()
		arrFilesName = #()
		tarFolder = undefined
		if (mlbBackupFolders.selection as array).count == 1 then
		(
			idFolderSelected = (mlbBackupFolders.selection as array)[1]
			nameFolderSelected = (mlbBackupFolders.items)[idFolderSelected]
			nameFolderSelected = (substituteString nameFolderSelected "📂 " "")
			tarFolder = (edtBackupPath.text + "\\" + nameFolderSelected + ".backup\\")
		)
		else 
		(
			tarFolder = ((getdir #autoback) + "\\")
		)
		if tarFolder != undefined then 
		(
			if (doesDirectoryExist tarFolder) then
			(
				(arrBsBackupFiles = getFiles (tarFolder + "\\*" + type))
				qsort arrBsBackupFiles fnPseudoNaturalSort
				if ckbReverse.state == true then 
				(
					tempArray = for i = arrBsBackupFiles.count to 1 by -1 collect arrBsBackupFiles[i]
					arrBsBackupFiles = for i in tempArray collect i
				)
				if arrBsBackupFiles[1] != undefined then
				(
					for c in arrBsBackupFiles do  --获取文件名字,后面切换脚本类别和列表会用到
					(
						(append arrFilesName ("📄 " + (getFilenameFile c) + type))
					)
				)
				rolBsBackupManager.mlbBackupFiles.items = arrFilesName
			)
		)
		else messagebox "-------------------------------------\r\n\r\n文件版本可能已不存在\r\n\r\n请尝试刷新\r\n\r\n-------------------------------------"
		lblCountFiles.text = "已备份版本：" + arrBsBackupFiles.count as string + " 个"
	)

	fn fnJudgeFolderSelected =
	(
		idSelected = 0
		if maxfilename != "" then
		(
			if not (matchpattern (maxFilePath + maxFileName) pattern:("*.backup\\*.max")) then 
			(
				arrFolder = (rolBsBackupManager.mlbBackupFolders.items as array)
				for i = 1 to arrFolder.count do
				(
					if (matchpattern arrFolder[i] pattern:("📂 " + (getfilenamefile maxfilename))) then idSelected = i
				)
				rolBsBackupManager.edtInputFilter.text = (getfilenamefile maxfilename)
				try(rolBsBackupManager.mlbBackupFiles.selection = 0)catch()
			)
			else 
			(
				fileName = (getfilenamefile maxfilename)
				arrNameFilter = (filterString fileName "_")
				strCountNum = arrNameFilter[arrNameFilter.count]
				tarName = substring fileName 1 (fileName.count - strCountNum.count - 1)
				arrFolder = (rolBsBackupManager.mlbBackupFolders.items as array)
				for i = 1 to arrFolder.count do
				(
					if (matchpattern arrFolder[i] pattern:("📂 " + tarName)) then idSelected = i
				)
				rolBsBackupManager.edtInputFilter.text = tarName
				try(rolBsBackupManager.mlbBackupFiles.selection = (finditem (rolBsBackupManager.mlbBackupFiles.items as array) ("📄 " + maxfilename)))catch()
			)
			try(rolBsBackupManager.mlbBackupFolders.selection = idSelected)catch()
		)
	)

	fn fnRefreshBackupAll =
	(
		fnRefreshFolderList iniBackupPath
		fnJudgeFolderSelected()
		fnRefreshFilesList()
		fnJudgeFolderSelected()
	)

	on rolBsBackupManager open do 
	(
		callbacks.removeScripts #filePostOpen id:#BsBackupManager
		callbacks.removeScripts #filePostSave id:#BsBackupManager
		callbacks.addScript #filePostOpen "rolBsBackupManager.fnRefreshBackupAll()" id:#BsBackupManager
		callbacks.addScript #filePostSave "rolBsBackupManager.fnRefreshBackupAll()" id:#BsBackupManager
		btnRefreshFolder.images  = #("UVWUnwrapModes_16i.bmp","UVWUnwrapModes_16i.bmp",28,3,3,4,4,false,false)
		btnOpenCurrentDir.images = #("bip_general_i.bmp","bip_general_i.bmp",30,5,5,6,6,false,true)
		-- btnPrevFolder.images     = #("MergeAnim_24i.bmp","MergeAnim_24i.bmp",4,1,1,1,1,false,true)
		edtBackupPath.text = iniBackupPath
		fnRefreshBackupAll()
	)

	on rolBsBackupManager close do 
	(
		iniPosBackupManager = (GetDialogPos rolBsBackupManager)
		stSetConfigAll.fnSetConfigTrackBarTools()
		callbacks.removeScripts #filePostOpen id:#BsBackupManager
		callbacks.removeScripts #filePostSave id:#BsBackupManager
	)

	on btnClose pressed do 
	(
		try (destroydialog rolBsBackupManager) catch()
	)

	on rolBsBackupManager lbuttondown posMou do
	(
		posMouMove = posMou
		switchMouState = on
	)

	on rolBsBackupManager lbuttonup posMou do
	(
		switchMouState = off
		iniPosBackupManager = (GetDialogPos rolBsBackupManager)
		stSetConfigAll.fnSetConfigTrackBarTools()
	)

	on rolBsBackupManager mbuttondown pos do 
	(
		try (destroydialog rolBsBackupManager) catch()
	)

	on rolBsBackupManager mouseMove pos do
	(
		if switchMouState == on then
		(
			SetDialogPos rolBsBackupManager (mouse.screenpos - posMouMove)
		)
	)

	-- on btnPrevFolder pressed do 
	-- (
	-- 	edtBackupPath.text = (fnGetLastFolder edtBackupPath.text)
	-- 	fnRefreshBackupAll()
	-- )

	on btnRefreshFolder pressed do 
	(
		rolBsBackupManager.fnRefreshBackupAll()
	)

	on btnRefreshFolder rightclick do 
	(
		mlbBackupFolders.selection = 0
		rolBsBackupManager.fnRefreshFilesList()
	)

	on btnOpenCurrentDir pressed do 
	(
		try(shellLaunch iniBackupPath "")catch()
	)

	on mlbBackupFolders selected arg do
	(
		if (rolBsBackupManager.mlbBackupFolders.selection as array).count == 1 then
		(
			rolBsBackupManager.fnRefreshFilesList()
			selItems = mlbBackupFolders.items[(mlbBackupFolders.selection as array)[1]]
			edtInputFilter.text = (substring selItems 3 selItems.count)
		)
	)

	on mlbBackupFiles doubleClicked id do
	(
		tarFile = arrBsBackupFiles[id]
		if (doesfileexist tarFile) then
		(
			if CheckForSave() then (loadMaxFile tarFile useFileUnits:true)
		)
	)

	on edtInputFilter changed textFolder do
	(
		if textFolder != "" then 
		(
			local arrID = #()
			for i in (rolBsBackupManager.mlbBackupFolders.items as array) do 
			(
				if (matchpattern i pattern:("*" + textFolder + "*")) then
				(
					append arrID (finditem (rolBsBackupManager.mlbBackupFolders.items as array) i)
				)
			)
			mlbBackupFolders.selection = arrID
		)
		else 
		(
			mlbBackupFolders.selection = 0
		)
		rolBsBackupManager.fnRefreshFilesList()
	)

	on mlbBackupFiles rightclick do
	(
		popupMenu menuBsFiles pos:mouse.screenpos
	)

	on mlbBackupFolders rightclick do
	(
		popupMenu menuBsFolder pos:mouse.screenpos
	)

	on ckbReverse changed state do 
	(
		rolBsBackupManager.fnRefreshFilesList()
	)
)