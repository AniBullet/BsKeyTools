/*
 * @Description: 自动备份工具,大改自SaveButton脚本
 * @Author: Bullet.S
 * @Date: 2021-05-08 17:18:12
 * @LastEditors: Bullet.S
 * @LastEditTime: 2021-08-04 17:40:42
 * @Email: animator.bullet@foxmail.com
 */
try
(
	if form != undefined then ( form.close(); form = undefined  )
	
	cui.UnRegisterDialogBar rolAutoBackup 
	destroyDialog rolAutoBackup
)
catch()


rollout rolAutoBackup "自动备份" 
(
	local form, mcolor, rcLIST,  SaveInterval, saveInterval_FN , autobackup
	local INIfile = ( getDir #maxData ) + "\\BulletConfig.ini"
	local mcolor = dotnetclass "System.drawing.color" 
	local malign = dotnetclass "System.Drawing.ContentAlignment"
	
	local dnFontStyle = dotNetClass "System.Drawing.FontStyle"
	local myFontStyle = dotnet.combineenums dnFontStyle.bold --dnFontStyle.italic
	local timeColor = mcolor.FromArgb 152 227 213

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
			btnTimer.backcolor = timeColor
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
				
				btnTimer.backcolor = timeColor
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
				
				btnTimer.backcolor = timeColor
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
			
			btnTimer.backcolor = timeColor
			btnTimer.FlatAppearance.MouseOverBackColor = mcolor.Gainsboro
			
			clock.active = false
			clock.ticks = 0
		)
		else
		(
			local nameCurrentFile = (filterString (getFilenameFile maxFileName) "@Backup_")[1]
			local arrTime = for i in (getLocalTime()) collect i as string
			local strNameSplit = "@Backup_"
			local fileSave = ""
	
			strNameSplit = strNameSplit + arrTime[2] + "_" + arrTime[4] + "_" + arrTime[5] + "h" + arrTime[6] + "m" + arrTime[7] + "s" + arrTime[8] + "ms"
	
			fileSave = maxFilePath + nameCurrentFile + strNameSplit + ".max"
			saveMaxFile fileSave
			clearlistener()
			print ("已快速备份至：\r\n" + fileSave) 
		)
	)
	
	on rolAutoBackup open do
	(
		callbacks.removeScripts id:#SaveButtonCallback
		callbacks.addScript #filePostOpenProcess "rolAutoBackup.clock.ticks = 0" id:#SaveButtonCallback
		
		callbacks.removeScripts id:#SaveButtonResetCallback
		callbacks.addScript #systemPostReset "rolAutoBackup.clock.ticks = 0" id:#SaveButtonResetCallback
		SaveMenu() 
		Inter = ( getINISetting INIfile "SaveButton" "SaveInterval" ) 
		autobackup = ( getINISetting INIfile "SaveButton" "Autobackup" ) 
		if autobackup == "" then (setINISetting INIfile "SaveButton" "Autobackup" "true";autobackup = "true")

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
		btnTimer.FlatAppearance.BorderColor = timeColor
		btnTimer.FlatAppearance.MouseOverBackColor = mcolor.Gainsboro 
		btnTimer.backcolor = timeColor
		btnTimer.font = dotNetObject "System.Drawing.Font" "Arial" 9 myFontStyle

		btnBackup.text = "迭代"
		btnBackup.flatstyle = dotnetobject "System.Windows.Forms.FlatStyle" Flat
		btnBackup.FlatAppearance.BorderColor = timeColor
		btnBackup.FlatAppearance.MouseOverBackColor = mcolor.Gainsboro 
		btnBackup.backcolor = timeColor
-- 		btnBackup.TextAlign = malign.BottomCenter
-- 		btnBackup.font = dotNetObject "System.Drawing.Font" "Arial" 9 myFontStyle

		btnSaveAs.text = "另存"
		btnSaveAs.flatstyle = dotnetobject "System.Windows.Forms.FlatStyle" Flat
		btnSaveAs.FlatAppearance.BorderColor = timeColor
		btnSaveAs.FlatAppearance.MouseOverBackColor = mcolor.Gainsboro 
		btnSaveAs.backcolor = timeColor
	)
	
	on rolAutoBackup close do
	(
		callbacks.removeScripts id:#SaveButtonCallback
		callbacks.removeScripts id:#SaveButtonResetCallback
		clock.active = false
		
		if form != undefined then ( form.close(); form = undefined  )
	)
	
	on undock_BTN pressed do
	(
		cui.UnRegisterDialogBar rolAutoBackup 
		cui.RegisterDialogBar rolAutoBackup style:#(#cui_dock_bottom,#cui_dock_top,#cui_floatable, #style_toolwindow)
		if (SaveInterval > 0) then clock.active = true
	)
	
	on btnClose pressed do
	(
		try
		(
			if form != undefined then ( form.close(); form = undefined  )
			
			cui.UnRegisterDialogBar rolAutoBackup 
			destroyDialog rolAutoBackup
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
			
			-- btnTimer.backcolor = timeColor
			-- btnTimer.FlatAppearance.MouseOverBackColor = mcolor.Gainsboro

			popUpMenu rcLIST pos:( [arg.x  , arg.y - 10 ] ) rollout:rolAutoBackup align:#align_topleft
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
			
			btnTimer.backcolor = timeColor
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
				
				btnTimer.backcolor = timeColor
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
			
					btnTimer.backcolor = timeColor
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
					COL = timeColor  
					
					btnTimer.text = TimeTXT
				)
				OverCOL 	= mcolor.darkred
				
				
				
				btnTimer.backcolor = COL
				btnTimer.FlatAppearance.MouseOverBackColor = OverCOL
				
			)
		)
	)
)
createDialog rolAutoBackup 200 25 style:#(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox)

cui.RegisterDialogBar rolAutoBackup style:#(#cui_dock_bottom,#cui_dock_top,#cui_floatable, #style_toolwindow)
cui.DockDialogBar rolAutoBackup  #cui_dock_bottom
if (rolAutoBackup.SaveInterval > 0) then rolAutoBackup.clock.active = true