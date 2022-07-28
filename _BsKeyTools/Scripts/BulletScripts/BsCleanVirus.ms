/*
 * @Description: 杀毒工具
 * @Author: Bullet.S
 * @Date: 2022-02-13 15:37:02
 * @LastEditors: Bullet.S
 * @LastEditTime: 2022-07-29 01:17:56
 * @Email: animator.bullet@foxmail.com
 */
global rolBsCleanVirus
global rolBsVirusScanLog
global iniStartupBsCleanVirus = 0
try(destroyDialog rolBsCleanVirus)catch()
try(destroyDialog rolBsVirusScanLog) catch()

Global BulletConfig = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false)
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false)
stLoadConfigAll.fnLoadConfigBsCleanVirus ()

rollout rolBsVirusScanLog "病毒扫描日志  【杀毒不会破坏源文件，请注意杀毒后保存/另存文件！】" (
	dotNetControl lbxLog "system.windows.forms.listView" height: 400 width: 850 offset: [-13, -5]
	
	button btnClearAllLog "清除所有日志" align: #left height: 25 width: 100 pos: [10, -50]
		
	struct signature_log (
		fn getLogFile = (
			d = execute ("@\"" + (getDir #maxData) + "\\scanlog.ini\"")
			return d
		), 
		
		fn getVerboseLevel = (
			ini = getLogFile()
			v = getIniSetting ini "SETTINGS" "VERBOSELEVEL"
			if(v == "") do return 1
			return try(v as integer) catch(1)
		),
		
		fn setVerboseLevel lvl = (
			ini = getLogFile()
			setIniSetting ini "SETTINGS" "VERBOSELEVEL" (lvl as string)
		),
		
		fn getLogType type = (
			return case type of (
				#threat: "Threat"
				#warn: "Warning"
				default: "Default"
			)
		),
		
		fn getTranslatedLogType type = (
			return case type of (
				#threat: "威胁"
				#warn:  "警告"
				default:  "默认"
			)
		),
		
		fn getTime = (
			t = #()
			for i in getLocalTime() do (
				s = (i as string)
				if(s.count < 2) do s = "0" + s
				append t s
			)
			
			return t[4] + "." + t[2] + "." + t[1] + " " + t[5] + ":" + t[6] + ":" + t[7]
		),
		
		fn write msg type: #threat = (
			ini = getLogFile()
			
			s = getLogType type
			k = getTime()
			
			setIniSetting ini s k msg
		),
		
		fn get type: #threat = (
			ini = getLogFile()
			s = getLogType type
			s = getTranslatedLogType type
			
			out = #()
			
			for i in (getIniSetting ini s) do (
				tmp = #()
				tmp[1] = i
				tmp[2] = s
				tmp[3] = (getIniSetting ini s i)
				append out tmp
			)
			
			return out
		),
		
		fn getAll = (
			out = #()
			ini = getLogFile()
			
			for i in (getIniSetting ini) where i != "SETTINGS" do (
								
				for ii in (getIniSetting ini i) do (
					tmp = #()
					tmp[1] = ii
					tmp[2] = i
					tmp[3] = (getIniSetting ini i ii)

					append out tmp
				)
			)
			
			return out
		),
		
		fn clearAll = (
			out = #()
			ini = getLogFile()
			
			for i in (getIniSetting ini) where i != "SETTINGS" do (
				delIniSetting ini i
			)
		)
	)
	
	fn setBottomBarVertPos = (
		v = 36
		size = GetDialogSize rolBsVirusScanLog
		btnClearAllLog.pos.y = size.y - v
	)
	
	fn getDotNetColor r g b = (DotNetClass "System.Drawing.Color").fromargb r g b 
	
	fn initDotNet =
	(	
		setBottomBarVertPos()
		
		align = dotNetClass "HorizontalAlignment"
		
		lbxLog.Clear()
		lbxLog.View = (dotNetClass "System.Windows.Forms.View").Details	
		lbxLog.FullRowSelect = true
		lbxLog.GridLines = true		
		lbxLog.ShowItemToolTips = true
		lbxLog.MultiSelect = false
		lbxLog.CheckBoxes = false
		lbxLog.HideSelection = false
		lbxLog.Columns.Add "#" 35
		lbxLog.Columns.Add ("日期") 130
		lbxLog.Columns.Add ("类型") 70 align.center
		lbxLog.Columns.Add ("信息") (850 - 35 - 130 - 70 - 5) 
					
		lbxLog.Update()
		lbxLog.Refresh()
	)
		
	fn getSelectedId =
	(
		c = lbxLog.SelectedItems.Count - 1		
		id = 0		
		for i = 0 to c do id = lbxLog.SelectedItems.Item[i].Index + 1
		return id
	)
	
	fn getSelectedItem =
	(
		item = undefined
		c = lbxLog.SelectedItems.Count - 1					
		for i = 0 to c do item = lbxLog.SelectedItems.Item[i]
		return item
	)
	
	fn setDotnetBoldFont = (
		bold = (dotnetclass "System.Drawing.FontStyle").Bold
		return dotnetobject "System.Drawing.Font" "Arial" 8 bold
	)
	
	fn addToLbxList r =
	(				
		lbxLog.Items.Clear()
		rows = #()	
		i = 1
		for x in r do	
		(
			li = dotNetObject "System.Windows.Forms.ListViewItem" ""
			li.useItemStyleForSubItems = false
			bold = (dotnetclass "System.Drawing.FontStyle").Bold
						
			li.text = (i as string) + "."
			li.subitems.add x[1]	
			
			type = case x[2] of (
				"Threat": "威胁"
				"Warning":  "警告"
				default:  "默认"
			)
			
			li.subitems.add type
					
			msg = substituteString x[3] "病毒检测并删除" "病毒已移除"
			msg = substituteString msg "病毒已检测到但没有从脚本自启文件夹移除!" "检测到但未删除"
			
			li.subitems.add msg
			li.tag = x[3]		
			
			bg = getDotNetColor 183 183 183; fg = getDotNetColor 67 67 67
			
			case x[2] of (
				"Threat": (
					bg = getDotNetColor 147 196 125
					fg = getDotNetColor 56 118 79
				)
				"Warning": (
					bg = getDotNetColor 255 229 153
					fg = getDotNetColor 215 144 0
				)
			)
			
			li.subItems.Item[2].backColor = bg
			li.subItems.Item[2].foreColor = fg
			li.subItems.Item[2].Font = setDotnetBoldFont()
						
			append rows li		
			i += 1
		)
		
		lbxLog.Items.addRange rows
	)	
	
	fn buildThreatList = (
		
		slog = signature_log()
		r = slog.getAll()
				
		addToLbxList r
	)
		
	fn clearAllLog = (
		slog = signature_log()
		slog.clearAll()
		
		buildThreatList()
	)
	
	fn getOnlineHelp = (
		shellLaunch "http://3dground.net/manual/prune-scene#virus-active-protecton" ""
	)
	
	fn contextMenuItem m n enabled: true =
	(
		item = undefined	
		c = m.Items.Count - 1
		for i = c to 0 by - 1 where c > 0 do
		(
			ii = m.Items.Item[i].Text
			if(ii == n) do
			(
				item = m.Items.Item[i]
				item.Enabled = enabled
				exit
			)
		)
		
		return item
	)
	
	fn bindContextMenu =
	(
		id = getSelectedId()
			
		contextMenu = dotNetObject "System.Windows.Forms.ContextMenuStrip"
			
		if(id != 0) do (		
			lngOnlineHelp =  "在线帮助"
			dotNet.addEventHandler (contextMenu.Items.Add(lngOnlineHelp)) "Click" getOnlineHelp				
		)
					
		lbxLog.ContextMenuStrip = contextMenu
	)
	
	on lbxLog MouseUp do
	(		
		bindContextMenu()
	)
			
	on rolBsVirusScanLog open do (
		initDotNet()		
		buildThreatList()
	)
	
	on rolBsVirusScanLog resized size do (
		lbxLog.width = size.x
		lbxLog.height = size.y - 50
		
		setBottomBarVertPos()
	)
	
	on btnClearAllLog pressed do clearAllLog()
)

rollout rolBsCleanVirus  "BsCleanVirus_v1.0"
(
    local startupBsCleanVirusTools = (getDir #Scripts) + "\\BulletScripts\\StartupMS\\BsCleanVirusStartup.ms"
	local startupLocalPath = (getDir #StartupScripts)+ "\\BsCleanVirusStartup.ms"

    group "【解析自 PruneScene 免费功能，仅供学习】"
    (
        checkbutton ckbStartup "开启 主动防御 [杀毒自启] " width:150 height:30 pos:[10,30]
        button btnCleanNow "立即查杀病毒" width:90 height:30 pos:[165,30]
        button btnCleanLog "日志" width:45 height:30 pos:[260,30]
    )

    group "杀毒特征库"
    (
        listbox lbxVirusLib "" width:295 height:10 pos:[10,90] readonly:true
    )

    group ""
    (
        HyperLink lnkPruneScene "杀毒特征来源：PruneScene" color:myfgColor hovercolor:myClickColor visitedcolor:myClickColor 
        pos:[15,250] address:"http://3dground.net/manual/prune-scene#virus-active-protecton"

        HyperLink lnkBsNotion "解析修改：Bullet.S" color:myfgColor hovercolor:myClickColor visitedcolor:myClickColor 
        pos:[205,250] address:"https://www.notion.so/bullet4869/BsKeyTools-17b5ba7c37ae45f6a69ce90f45fa0657"
    )

    fn fnRefreshVirusLib =
    (
        lbxVirusLib.Items = #()
        arrSignatureFiles = (getFiles (((getDir #scripts) + "\\BulletScripts\\ScanVirus\\")+ "signature.*.mcr"))
        lbxVirusLib.Items = for i in arrSignatureFiles collect (getFilenameFile i)
        lbxVirusLib.selection = 0
    )

    on rolBsCleanVirus open do
    (
        stLoadConfigAll.fnLoadConfigBsCleanVirus ()  ---------------脚本配置等赋值
		stSetConfigAll.fnSetConfigBsCleanVirus  ()  ----------------保存配置到ini文件
        ckbStartup.state = (SIOFile.Exists rolBsCleanVirus.startupLocalPath)
        fnRefreshVirusLib()
    )

	on rolBsCleanVirus close do -- 关闭时记忆配置
	(
        stSetConfigAll.fnSetConfigBsCleanVirus ()
	)

    on btnCleanNow pressed do
    (
        for f in getFiles (((getDir #scripts) + "\\BulletScripts\\ScanVirus\\")+ "signature.*.mcr") do
        (
            try(FileIn f) 
            catch(messagebox "加载杀毒失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false)
        )
        messageBox "检测结束，请注意弹窗和查看日志！并且注意保存/另存文件！                                                 "
        try(destroyDialog rolBsVirusScanLog) catch()
        createDialog rolBsVirusScanLog 850 450 style: #(#style_toolwindow, #style_resizing, #style_sysmenu, #style_toolwindow)
    )

    on btnCleanLog pressed do 
    (
        try(destroyDialog rolBsVirusScanLog) catch()
        createDialog rolBsVirusScanLog 850 450 style: #(#style_toolwindow, #style_resizing, #style_sysmenu, #style_toolwindow)
    )

    on ckbStartup changed state do
    (
        if (not state) then 
        (
            fnDelFileDir startupLocalPath;iniStartupBsCleanVirus = 0
            messagebox "已经关闭杀毒自启，请重新启动3dsMax！                                          "
        )
		else 
		(
			if (not (SIOFile.Exists startupLocalPath)) then
			(
				try 
				(
					SIOFile.Copy startupBsCleanVirusTools startupLocalPath
					messagebox ("已经打开主动防御，如安装杀毒卫士，\r\n\r\n请把插件进程管理中的\"signature\"相关回调启用！                                                                ")
					setFileAttribute startupLocalPath #readOnly true
                    iniStartupBsCleanVirus = 1
                    for f in getFiles (((getDir #scripts) + "\\BulletScripts\\ScanVirus\\")+ "signature.*.mcr") do
                    (
                        try(FileIn f) 
                        catch(messagebox "加载杀毒失败，可能脚本错误或安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装，还有问题烦请联系我...                            " beep:false)
                    )
				)
				catch
				(
					messagebox ("自启失败，烦请手动处理：\r\n把 BsCleanVirusStartup.ms 复制到\r\n\r\n" + (getDir #StartupScripts) + "                    ")
					(shellLaunch (getfilenamepath startupBsCleanVirusTools) "")
				)
			)
            else (messagebox "已经开启自启，请勿重复操作！                                          ")
		)
        stSetConfigAll.fnSetConfigBsCleanVirus ()
    )
    ------------------------------------------------------------------------------------------------------

)
Createdialog rolBsCleanVirus 315 280 fgcolor:myFgColor