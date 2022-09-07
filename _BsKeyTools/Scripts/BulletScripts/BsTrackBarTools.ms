/*
 * @Description: 自动备份工具,大改自SaveButton脚本
 * @Author: Bullet.S
 * @Date: 2021-05-08 17:18:12
 * @LastEditors: Bullet.S
 * @LastEditTime: 2022-09-07 13:48:34
 * @Email: animator.bullet@foxmail.com
 */


if form != undefined then ( form.close(); form = undefined  )
try (cui.UnRegisterDialogBar rolBsTrackBarTools) catch()
try (destroyDialog rolBsTrackBarTools) catch()
try (destroydialog rolBsBackupManager) catch()
try (callbacks.removeScripts #filePostOpen id:#UpdateBsBackup) catch ()
try (callbacks.removeScripts #filePostSave id:#UpdateBsBackup) catch ()

global rolBsTrackBarTools
global rolBsBackupManager
Global BulletConfig      = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径
global iniBackupPath     = ((getdir #autoback) + "\\BsBackup")
global iniMaxBackupCount = 50
global iniPosAutoBackup
Global iniPosBackupManager
global iniDockPos
global heightBsSize = 30
global widthBsSize  = 255
Global SIOFile      = dotNetClass "System.IO.File"
Global SIODir       = dotNetClass "System.IO.Directory"

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))
catch(messagebox "脚本安装可能不完全,建议重新安装...        " beep:false)
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))
catch(messagebox "脚本安装可能不完全,建议重新安装...        " beep:false)
stLoadConfigAll.fnLoadConfigTrackBarTools()

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

rcmenu menuBsTrackBarTools
(
	submenu "停靠"
	(
		menuItem mItemTop "上"
		menuItem mItemBottom "下"
		menuItem mItemLeft "左"
		menuItem mItemRight "右"
		separator menuSepDock
		menuItem mItemFloat "浮"
	)
	menuItem mItemIsStartup "自启"
	separator menuSepClose
	menuItem mItemClose "关闭"

	local startupPath            = (getDir #StartupScripts)+ "\\BsTrackBarToolsStartup.ms"
	local startupBsTrackBarTools = (getDir #Scripts) + "\\BulletScripts\\StartupMS\\BsTrackBarToolsStartup.ms"

	on menuBsTrackBarTools open do
	(
		if(SIOFile.Exists startupPath) then (mItemIsStartup.checked = true)
		else (mItemIsStartup.checked = false)
		if not rolBsTrackBarTools.dialogBar then 
		(
			mItemFloat.checked = true
			mItemBottom.checked = mItemLeft.checked = mItemTop.checked = mItemRight.checked = false
		)
		else 
		(
			case (cui.getDockState rolBsTrackBarTools) as string  of
			(
				("cui_dock_top"):
				(
					mItemTop.checked = true
					mItemBottom.checked = mItemLeft.checked = mItemRight.checked = mItemFloat.checked = false
				)
				("cui_dock_bottom"):
				(
					mItemBottom.checked = true
					mItemTop.checked = mItemLeft.checked = mItemRight.checked = mItemFloat.checked = false
				)
				("cui_dock_left"):
				(
					mItemLeft.checked = true
					mItemBottom.checked = mItemTop.checked = mItemRight.checked = mItemFloat.checked = false
				)
				("cui_dock_right"):
				(
					mItemRight.checked = true
					mItemBottom.checked = mItemLeft.checked = mItemTop.checked = mItemFloat.checked = false
				)
				default:
				(
					mItemFloat.checked = true
					mItemBottom.checked = mItemLeft.checked = mItemTop.checked = mItemRight.checked = false
				)
			)
		)
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
					SIOFile.Copy startupBsTrackBarTools startupPath
					messagebox ("已打开 BsTrackBarTools 自启！                  ")  title:"自启设置"
					mItemIsStartup.checked = true
					setFileAttribute startupPath #readOnly true
				)
				catch
				(
					messagebox ("自启失败，烦请管理员运行 max 或手动处理：\r\n\r\n把 StartupMS\\BsTrackBarToolsStartup.ms 复制到\r\n\r\n" + (getDir #StartupScripts) + "                    ")
					(shellLaunch (getfilenamepath startupBsTrackBarTools) "")
				)
			)
		)
	)

	on mItemTop picked do
	(
		if not mItemTop.checked then 
		(
			iniDockPos = "cui_dock_top"
			stSetConfigAll.fnSetConfigTrackBarTools()
			fnLoadDockPos rolBsTrackBarTools widthBsSize heightBsSize
			if (rolBsTrackBarTools.SaveInterval > 0) then clock.active = true
		)
	)

	on mItemBottom picked do
	(
		if not mItemBottom.checked then 
		(
			iniDockPos = "cui_dock_bottom"
			stSetConfigAll.fnSetConfigTrackBarTools()
			fnLoadDockPos rolBsTrackBarTools widthBsSize heightBsSize
			if (rolBsTrackBarTools.SaveInterval > 0) then clock.active = true
		)
	)

	on mItemLeft picked do
	(
		if not mItemLeft.checked then 
		(
			iniDockPos = "cui_dock_left"
			stSetConfigAll.fnSetConfigTrackBarTools()
			fnLoadDockPos rolBsTrackBarTools widthBsSize heightBsSize
			if (rolBsTrackBarTools.SaveInterval > 0) then clock.active = true
		)
	)

	on mItemRight picked do
	(
		if not mItemRight.checked then 
		(
			iniDockPos = "cui_dock_right"
			stSetConfigAll.fnSetConfigTrackBarTools()
			fnLoadDockPos rolBsTrackBarTools widthBsSize heightBsSize
			if (rolBsTrackBarTools.SaveInterval > 0) then clock.active = true
		)
	)

	on mItemFloat picked do
	(
		if not mItemFloat.checked then 
		(
			iniDockPos = "float"
			stSetConfigAll.fnSetConfigTrackBarTools()
			fnLoadDockPos rolBsTrackBarTools widthBsSize heightBsSize
			if (rolBsTrackBarTools.SaveInterval > 0) then clock.active = true
		)
	)

	on mItemClose picked do
	(
		if form != undefined then ( form.close(); form = undefined  )
		try (cui.UnRegisterDialogBar rolBsTrackBarTools) catch()
		try (destroyDialog rolBsTrackBarTools) catch()
	)
)

rollout rolBsTrackBarTools "BsTrackBarTools_v1.0" 
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
	-- dotnetcontrol btnOpenPath "Button" height:30 width:80 pos:[255,0]  --打开备份文件夹
	
	timer clock "testClock" interval:1000 active:false  --tick once a second

	fn fnButtonStyle tarButton textButton =
	(
		tarButton.text = textButton
		tarButton.flatstyle = dotnetobject "System.Windows.Forms.FlatStyle" Flat
		tarButton.FlatAppearance.BorderColor = mcolor.gray 
		tarButton.FlatAppearance.MouseOverBackColor = mcolor.white 
		tarButton.backcolor = BsDotBackColor
		-- tarButton.ForeColor = BsDotForeColor
	)

	fn saveInterval_FN TimeInterval = 
	(
		clock.active = true -- si le pr�c�dent == 0, on active
		
		setINISetting INIfile "SaveButton" "SaveInterval" TimeInterval  forceUTF16:false --force ASCII
		
		SaveInterval = TimeInterval as integer
		
		if clock.ticks < SaveInterval*60 then
		(
			btnTimer.backcolor = mcolor.white
			btnTimer.FlatAppearance.MouseOverBackColor = mcolor.Gainsboro
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
				
				btnTimer.backcolor = mcolor.white
				btnTimer.FlatAppearance.MouseOverBackColor = mcolor.Gainsboro
				
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
				
				btnTimer.backcolor = mcolor.white
				btnTimer.FlatAppearance.MouseOverBackColor = mcolor.Gainsboro
			)
		)
	)

	fn fnFilesCount = 
	(
		tarPath = maxFilePath
		numFiles = 0
		if maxFileName != "" then
		(
			if matchpattern (maxFilePath + maxFileName) pattern:("*.backup\\*.max") then 
			(
				tarPath = maxFilePath
			)
			else
			(
				tarPath = (iniBackupPath + "\\" + (getFilenameFile maxFileName) + ".backup")
			)
			numFiles = (getfiles (tarPath + "\\*.max")).count
		)
		else 
		(
			tarPath =  iniBackupPath
			numFiles = (getDirectories iniBackupPath).count
		)
		fnButtonStyle btnFilesCount (numFiles as string +" 文件/夹")
		btnFilesCount.FlatAppearance.BorderColor = mcolor.white 
	)
	
	fn fnQuickSave =
	(
		if maxFilePath == "" then 
		(
			messagebox "------------------------------------\r\n\r\n当前场景未保存过,\r\n\r\n请先保存初始版本~\r\n\r\n------------------------------------"
			-- max file saveas
			btnTimer.text = "请先保存" 
			saveInterval_FN "0" 
			
			btnTimer.backcolor = mcolor.white
			btnTimer.FlatAppearance.MouseOverBackColor = mcolor.Gainsboro
			
			clock.active = false
			clock.ticks = 0
		)
		else
		(
			local strCurFilePath    = (maxFilePath + maxFileName)
			local strCurFileName    = getFilenameFile maxFileName
			local strBackupPathRoot = iniBackupPath + "\\" + strCurFileName + ".backup"
			local arrBackupFiles = getfiles (strBackupPathRoot + "\\*.max")
			qsort arrBackupFiles fnPseudoNaturalSort
			-- print arrBackupFiles

			if matchpattern strCurFilePath pattern:("*.backup\\*.max") then 
			(
				strBackupPathRoot = maxFilePath
				arrBackupFiles    = getfiles (strBackupPathRoot + "\\*.max")
				qsort arrBackupFiles fnPseudoNaturalSort
				strSaveFileName   = getFilenameFile arrBackupFiles[arrBackupFiles.count]
				arrEndCountFilter = (filterString strSaveFileName "_")
				strSaveCount      = ((execute arrEndCountFilter[arrEndCountFilter.count])) as string
				strSaveName       = substring strSaveFileName 1 (strSaveFileName.count - strSaveCount.count - 1)
				strSaveCount      = ((execute strSaveCount) + 1) as string
				strBackupFilePath = strBackupPathRoot + "\\" + strSaveName + "_" + strSaveCount + ".max"
				saveMaxFile strBackupFilePath
				displayTempPrompt ("已备份并打开：" + strBackupFilePath) 10000
				messagebox ("当前备份的是已备份文件，请注意跟源文件对比新旧！\r\n\r\n可能的源文件：" + strSaveName + ".max\r\n\r\n刚才备份的文件：" + strCurFileName + ".max                                                                           ") title:"BsKeyTools"
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
				saveMaxFile strCurFilePath
				if (not (SIOFile.Exists strBackupFilePath)) do
				(
					try 
					(
						SIOFile.Copy strCurFilePath strBackupFilePath
						displayTempPrompt ("已备份至：" + strBackupFilePath) 10000 
					)
					catch()
				)
			)
			rolBsTrackBarTools.fnFilesCount()
		)
	)
	
	on rolBsTrackBarTools open do
	(
		stLoadConfigAll.fnLoadConfigTrackBarTools()
		stSetConfigAll.fnSetConfigTrackBarTools()
		fnLoadDockPos rolBsTrackBarTools widthBsSize heightBsSize
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
		-- fnButtonStyle btnOpenPath "打开已备份"
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
		btnConfig.BackColor = dotColor.FromArgb white.r white.g white.b
		
	)
	
	on rolBsTrackBarTools close do
	(
		iniPosAutoBackup = (GetDialogPos rolBsTrackBarTools)
		-- iniDockPos = ((cui.getDockState rolBsTrackBarTools) as string)
		-- print iniDockPos
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
			
			-- btnTimer.backcolor = mcolor.white
			-- btnTimer.FlatAppearance.MouseOverBackColor = mcolor.Gainsboro

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
			fnQuickSave()

			clock.ticks = 0
			
			btnTimer.backcolor = mcolor.white
			btnTimer.FlatAppearance.MouseOverBackColor = mcolor.Gainsboro
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
				
				btnTimer.backcolor = mcolor.white
				btnTimer.FlatAppearance.MouseOverBackColor = mcolor.Gainsboro
				
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
		if arg.button == btnFilesCount.mousebuttons.right then
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
		else if arg.button == btnFilesCount.mousebuttons.left then
		(
			try (destroydialog rolBsBackupManager) catch ()
			if (iniPosBackupManager != 0) then (Createdialog rolBsBackupManager fgcolor:myFgColor pos:iniPosBackupManager style:#())
			else (Createdialog rolBsBackupManager fgcolor:myFgColor style:#())
		)
	)

	
	on clock tick do
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
					fnQuickSave()
					clock.ticks = 0
			
					btnTimer.backcolor = mcolor.white
					btnTimer.FlatAppearance.MouseOverBackColor = mcolor.Gainsboro
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
					COL = mcolor.white
					
					btnTimer.text = TimeTXT
				)
				OverCOL = mcolor.darkred

				btnTimer.backcolor = COL
				btnTimer.FlatAppearance.MouseOverBackColor = OverCOL
				
			)
		)
	)
)

if (iniPosAutoBackup != 0) then (createDialog rolBsTrackBarTools widthBsSize heightBsSize pos:iniPosAutoBackup style:#(#style_sysmenu,#style_toolwindow))
else (createDialog rolBsTrackBarTools widthBsSize heightBsSize style:#(#style_sysmenu,#style_toolwindow))

-- cui.RegisterDialogBar rolBsTrackBarTools style:#(#cui_dock_bottom,#cui_dock_top,#cui_floatable, #style_toolwindow) maxSize:[190,30]
-- cui.DockDialogBar rolBsTrackBarTools  #cui_dock_top
if (rolBsTrackBarTools.SaveInterval > 0) then rolBsTrackBarTools.clock.active = true
callbacks.addScript #filePostOpen "rolBsTrackBarTools.fnFilesCount()" id:#UpdateBsBackup
callbacks.addScript #filePostSave "rolBsTrackBarTools.fnFilesCount()" id:#UpdateBsBackup

rollout rolBsBackupManager "" width:340 height:260
(
	local posMouMove     = [0,0]
	local switchMouState = false

	groupbox grpMain "BsBackupManager_v1.0-----------(按住这里可拖动)" \
	width:(rolBsBackupManager.width - 10) height:(rolBsBackupManager.height - 5) pos:[5,0]
	button btnClose "X" pos:[rolBsBackupManager.width - 15,0] height:15 width:15
	button btnRefreshFolder "R" align:#left border:false \
	height:20 width:25 pos:[10,20] tooltip:"左：刷新当前文件目录\r\n右：重置场景"
	button btnOpenCurrentDir "打开" tooltip:"打开当前文件夹" \
	height:20 width:25 pos:[35,20] border:false
	editText edtBackupPath "" text:"" labelOnTop:true align:#right \
	height:20 fieldWidth:230 pos:[65,20] readOnly:true 
	button btnPrevFolder "↑" tooltip:"返回上层目录，也可右击面板空白处" \
	height:20 width:25 pos:[300,20] border:false
	editText edtImputFilter "" text:"" labelOnTop:true align:#right \
	height:17 fieldWidth:115 pos:[10,48]
	MultiListBox mlbBackupFolders "" align:#left selection:0 \
	height:12 width:115 pos:[10,70]
	MultiListBox mlbBackupFiles "" align:#right selection:0 \
	height:14 width:200 pos:[130,45]
	label lblCountFolder "" height:15 width:100 pos:[15,235]
	label lblCountFiles "" height:15 width:100 pos:[210,235]

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
		lblCountFolder.text = "已备份动画：" + arrFolders.count as string + " 个"
	)

	fn fnRefreshFilesList type:".max" =
	(
		idFolderSelected = 0
		nameFolderSelected = ""
		arrFiles = #()
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
			tarFolder = (edtBackupPath.text + "\\")
		)
		if tarFolder != undefined then 
		(
			if (doesDirectoryExist tarFolder) then
			(
				(arrFiles = getFiles (tarFolder + "\\*" + type))
				qsort arrFiles fnPseudoNaturalSort
				if arrFiles[1] != undefined then
				(
					for c in arrFiles do  --获取文件名字,后面切换脚本类别和列表会用到
					(
						(append arrFilesName ("📄 " + (getFilenameFile c) + type))
					)
				)
				rolBsBackupManager.mlbBackupFiles.items = arrFilesName
			)
		)
		else messagebox "-------------------------------------\r\n\r\n文件版本可能已不存在\r\n\r\n请尝试刷新\r\n\r\n-------------------------------------"
		lblCountFiles.text = "已备份版本：" + arrFiles.count as string + " 个"
	)

	fn fnJudgeFolderSelected =
	(
		if maxfilename != "" then
		(
			idSelected = 0
			arrFolder = (rolBsBackupManager.mlbBackupFolders.items as array)
			for i = 1 to arrFolder.count do
			(
				if (matchpattern arrFolder[i] pattern:("*" + (getfilenamefile maxfilename) + "*")) then idSelected = i
			)
			rolBsBackupManager.mlbBackupFolders.selection = idSelected
		)
	)

	on rolBsBackupManager open do 
	(
		btnRefreshFolder.images  = #("UVWUnwrapModes_16i.bmp","UVWUnwrapModes_16i.bmp",28,3,3,4,4,false,false)
		btnOpenCurrentDir.images = #("bip_general_i.bmp","bip_general_i.bmp",30,5,5,6,6,false,true)
		btnPrevFolder.images     = #("MergeAnim_24i.bmp","MergeAnim_24i.bmp",4,1,1,1,1,false,true)
		edtBackupPath.text = iniBackupPath
		mlbBackupFolders.selection = 0
		fnRefreshFolderList iniBackupPath
		fnJudgeFolderSelected()
		fnRefreshFilesList()
	)

	on rolBsBackupManager close do 
	(
		iniPosBackupManager = (GetDialogPos rolBsBackupManager)
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
	)

	on rolBsBackupManager rbuttondown pos do 
	(
		
	)

	on rolBsBackupManager mouseMove pos do
	(
		if switchMouState == on then
		(
			SetDialogPos rolBsBackupManager (mouse.screenpos - posMouMove)			
		)
	)
)