/*
 * @Description: 自动备份工具,大改自SaveButton脚本
 * @Author: Bullet.S
 * @Date: 2021-05-08 17:18:12
 * @LastEditors: Bullet.S
 * @LastEditTime: 2022-08-31 16:01:55
 * @Email: animator.bullet@foxmail.com
 */


try(destroyDialog rolBsTrackBarTools)catch()
try
(
	if form != undefined then ( form.close(); form = undefined  )
	cui.UnRegisterDialogBar rolBsTrackBarTools 
	destroyDialog rolBsTrackBarTools
)
catch()
stLoadConfigAll.fnLoadConfigTrackBarTools()
global iniBackupPath = ((getdir #autoback) + "\\BsBackup")
Global BulletConfig = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径
global iniMaxBackupCount = 50
global iniPosAutoBackup
global iniDockPos
global rolBsTrackBarTools

rollout rolBsTrackBarTools "自动备份" 
(
	local form, mcolor, rcLIST,  SaveInterval, saveInterval_FN , autobackup
	local INIfile = ( getDir #maxData ) + "\\BulletConfig.ini"
	local mcolor = dotnetclass "System.drawing.color" 
	local malign = dotnetclass "System.Drawing.ContentAlignment"
	
	local dnFontStyle = dotNetClass "System.Drawing.FontStyle"
	local myFontStyle = dotnet.combineenums dnFontStyle.bold --dnFontStyle.italic

	button undock_BTN "" height:25 width:10 pos:[0,0] toolTip:"undock"
	dotnetcontrol btnTimer "System.Windows.Forms.Button" height:25 width:80 pos:[10,0] --replace
	dotnetcontrol btnBackup "System.Windows.Forms.Button" height:25 width:40 pos:[92,0] --increment
	dotnetcontrol btnSaveAs "System.Windows.Forms.Button" height:25 width:40 pos:[135,0]  --save as
	button btnClose "X" height:25 width:20 pos:[180,0] border:false
	
	
	timer clock "testClock" interval:1000 active:false  --tick once a second

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

	
	fn fnQuickSave =
	(
		if maxFilePath == "" then 
		(
			messagebox "------------------------------------\r\n当前场景未保存过,\r\n请先保存初始版本~"
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
		)
	)
	
	on rolBsTrackBarTools open do
	(
		fnLoadDockPos rolBsTrackBarTools rolBsTrackBarTools.width rolBsTrackBarTools.height
		stLoadConfigAll.fnLoadConfigTrackBarTools()
		stSetConfigAll.fnSetConfigTrackBarTools()
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
		btnTimer.text = "等待激活"
		btnTimer.flatstyle = dotnetobject "System.Windows.Forms.FlatStyle" Flat
		btnTimer.FlatAppearance.BorderColor = mcolor.white
		btnTimer.FlatAppearance.MouseOverBackColor = mcolor.Gainsboro 
		btnTimer.backcolor = mcolor.white
		btnTimer.font = dotNetObject "System.Drawing.Font" "Arial" 9 myFontStyle

		btnBackup.text = "迭代"
		btnBackup.flatstyle = dotnetobject "System.Windows.Forms.FlatStyle" Flat
		btnBackup.FlatAppearance.BorderColor = mcolor.white
		btnBackup.FlatAppearance.MouseOverBackColor = mcolor.Gainsboro 
		btnBackup.backcolor = mcolor.white
-- 		btnBackup.TextAlign = malign.BottomCenter
-- 		btnBackup.font = dotNetObject "System.Drawing.Font" "Arial" 9 myFontStyle

		btnSaveAs.text = "另存"
		btnSaveAs.flatstyle = dotnetobject "System.Windows.Forms.FlatStyle" Flat
		btnSaveAs.FlatAppearance.BorderColor = mcolor.white
		btnSaveAs.FlatAppearance.MouseOverBackColor = mcolor.Gainsboro 
		btnSaveAs.backcolor = mcolor.white
	)
	
	on rolBsTrackBarTools close do
	(
		iniPosAutoBackup = (GetDialogPos rolBsTrackBarTools)
		iniDockPos = ((cui.getDockState rolBsTrackBarTools) as string)
		stSetConfigAll.fnSetConfigTrackBarTools()
		callbacks.removeScripts id:#SaveButtonCallback
		callbacks.removeScripts id:#SaveButtonResetCallback
		clock.active = false
		
		if form != undefined then ( form.close(); form = undefined  )
	)
	
	on undock_BTN pressed do
	(
		cui.UnRegisterDialogBar rolBsTrackBarTools 
		cui.RegisterDialogBar rolBsTrackBarTools style:#(#cui_dock_bottom,#cui_dock_top,#cui_floatable, #style_toolwindow)
		if (SaveInterval > 0) then clock.active = true
	)
	
	on btnClose pressed do
	(
		try
		(
			if form != undefined then ( form.close(); form = undefined  )
			
			cui.UnRegisterDialogBar rolBsTrackBarTools 
			destroyDialog rolBsTrackBarTools
		)
		catch()
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
					COL 			= mcolor.Red
					
					btnTimer.text = "请保存 !!"
				)
				else
				(
					COL = mcolor.white  
					
					btnTimer.text = TimeTXT
				)
				OverCOL 	= mcolor.darkred
				
				
				
				btnTimer.backcolor = COL
				btnTimer.FlatAppearance.MouseOverBackColor = OverCOL
				
			)
		)
	)
)
createDialog rolBsTrackBarTools 200 25 style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)

cui.RegisterDialogBar rolBsTrackBarTools style:#(#cui_dock_bottom,#cui_dock_top,#cui_floatable, #style_toolwindow) maxSize:[200,25]
cui.DockDialogBar rolBsTrackBarTools  #cui_dock_top
if (rolBsTrackBarTools.SaveInterval > 0) then rolBsTrackBarTools.clock.active = true