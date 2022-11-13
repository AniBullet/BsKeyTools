Global BulletConfig = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径
global fnLoadToolBtnConfig
global fnSetToolBtnConfig
global fnLoadMsBtnConfig
global fnSetMsBtnConfig
global stSetConfigAll
global stLoadConfigAll
global fnGetConfig
global fnLoadDockPos
struct myScript (id,msName,dir)

fn fnGetConfig attr nameAttrClass nameAttr valueAttr =  --设置初始信息方法
(
	local oldPrintAllElements  = options.printAllelements
	options.printAllelements = true
	attr = (GetINISetting BulletConfig nameAttrClass nameAttr) as string  --先提取文件中的记录
	if ((matchpattern nameAttr pattern:"ArrMyScripts?" == true) or (nameAttr == "LikedFolder") \
	or (nameAttr == "Desktop") or (matchpattern nameAttr  pattern:"RefFolder*") \
	or (nameAttr == "LastRefFolder")) then (attr = substituteString attr "dir:" "dir:@")
	if (attr == "") or (attr == "undefined") then 
	(
		if (nameAttr == "BackupPath") or (nameAttr == "DockPos") then (attr = (execute ("@\"" + valueAttr + "\""))) else (attr = execute valueAttr)
	) 
	else 
	(
		if (nameAttr == "BackupPath") or (nameAttr == "DockPos")  then (attr = (execute ("@\"" + attr + "\""))) else (attr = execute attr)
	) --判断记录为空与否得到需要的记录参数
	options.printAllelements = oldPrintAllElements
	attr
)
fn fnLoadToolBtnConfig =
(
	iniToolBtnAll = fnGetConfig iniToolBtnAll "BulletKeyToolsSet" "ToolBtnAll" (with printAllelements on (iniToolBtnAll as string))
)
fn fnSetToolBtnConfig =
(
	SetINISetting BulletConfig "BulletKeyToolsSet" "ToolBtnAll" (with printAllelements on (iniToolBtnAll as string))
)

fn fnLoadMsBtnConfig =
(
	iniArrMyScripts1 = fnGetConfig iniArrMyScripts1 "BulletKeyToolsSet" "ArrMyScripts1" (iniArrMyScripts1 as string)
	iniArrMyScripts2 = fnGetConfig iniArrMyScripts2 "BulletKeyToolsSet" "ArrMyScripts2" (iniArrMyScripts2 as string)
	iniArrMyScripts3 = fnGetConfig iniArrMyScripts3 "BulletKeyToolsSet" "ArrMyScripts3" (iniArrMyScripts3 as string)
	iniArrMyScripts4 = fnGetConfig iniArrMyScripts4 "BulletKeyToolsSet" "ArrMyScripts4" (iniArrMyScripts4 as string)
	iniArrMyScripts5 = fnGetConfig iniArrMyScripts5 "BulletKeyToolsSet" "ArrMyScripts5" (iniArrMyScripts5 as string)

	local arrMyScriptsSet = #(iniArrMyScripts1,iniArrMyScripts2,iniArrMyScripts4,iniArrMyScripts4,iniArrMyScripts5)
	local tempMsArrayCount = 1
	for i in arrMyScriptsSet do
	(
		if (i != undefined and i.count != 10) or i == undefined then
		(
			i = #((myScript id:1 msName:"<＋＋>" dir:""), \
			(myScript id:2 msName:"<＋＋>" dir:""), \
			(myScript id:3 msName:"<＋＋>" dir:""), \
			(myScript id:4 msName:"<＋＋>" dir:""), \
			(myScript id:5 msName:"<＋＋>" dir:""), \
			(myScript id:6 msName:"<＋＋>" dir:""), \
			(myScript id:7 msName:"<＋＋>" dir:""), \
			(myScript id:8 msName:"<＋＋>" dir:""),
			(myScript id:9 msName:"<＋＋>" dir:""),
			(myScript id:10 msName:"<＋＋>" dir:""))
			messagebox ("自定脚本列表 " + tempMsArrayCount as string + " 初始化或读取失败，已重置...                                                         ")

			SetINISetting BulletConfig "BulletKeyToolsSet" ("ArrMyScripts" + tempMsArrayCount as string) (i as string)
			arrMyScriptsSet[tempMsArrayCount] = i
		)
		tempMsArrayCount += 1
	)
)

fn fnSetMsBtnConfig =
(
	SetINISetting BulletConfig "BulletKeyToolsSet"  "ArrMyScripts1" (iniArrMyScripts1 as string)
	SetINISetting BulletConfig "BulletKeyToolsSet"  "ArrMyScripts2" (iniArrMyScripts2 as string)
	SetINISetting BulletConfig "BulletKeyToolsSet"  "ArrMyScripts3" (iniArrMyScripts3 as string)
	SetINISetting BulletConfig "BulletKeyToolsSet"  "ArrMyScripts4" (iniArrMyScripts4 as string)
	SetINISetting BulletConfig "BulletKeyToolsSet"  "ArrMyScripts5" (iniArrMyScripts5 as string)
)

struct stLoadConfigAll
(
	fn fnLoadConfigBsKeyToolsAll =
	(
		iniPos               = fnGetConfig iniPos "BulletKeyToolsSet" "Pos" "0"
		switchToolPanel      = fnGetConfig switchToolPanel "BulletKeyToolsSet" "ToolPanel" (switchToolPanel as string)
		switchMSPanel        = fnGetConfig switchMSPanel "BulletKeyToolsSet" "MSPanel" (switchMSPanel as string)
		idBtn                = fnGetConfig idBtn "BulletKeyToolsSet" "idBtn" (idBtn as string)
		idMsBtn              = fnGetConfig idMsBtn "BulletKeyToolsSet" "idMsBtn" (idMsBtn as string)
		iniBsAutoCheckUpdate = fnGetConfig iniBsAutoCheckUpdate "BulletKeyToolsSet"  "AutoCheckUpdate" (iniBsAutoCheckUpdate as string)
		iniIsIcon            = fnGetConfig iniIsIcon "BulletKeyToolsSet" "IsIcon" (iniIsIcon as string)
		iniCollopseType      = fnGetConfig iniCollopseType "BulletKeyToolsSet" "CollopseType" (iniCollopseType as string)
		fnLoadToolBtnConfig()
		fnLoadMsBtnConfig()
		-- print "Loaded BsKeyTools Config"
	),
	fn fnLoadConfigBsOpenTools =
	(
		iniPosOpenTools   = fnGetConfig iniPosOpenTools "BsOpenToolsSet" "PosOpenTools" "0"
		iniSelectedID     = fnGetConfig iniSelectedID "BsOpenToolsSet" "SelectedID" (iniSelectedID as string)
		iniLikedFolder    = fnGetConfig iniLikedFolder "BsOpenToolsSet" "LikedFolder" (iniLikedFolder as string)
		iniFilterPrefix   = fnGetConfig iniFilterPrefix "BsOpenToolsSet" "FilterPrefix" (iniFilterPrefix as string)
		iniWidthOpenTools = fnGetConfig iniWidthOpenTools "BsOpenToolsSet" "WidthOpenTools" (iniWidthOpenTools as string)
		iniDesktop        = fnGetConfig iniDesktop "BsOpenToolsSet" "Desktop" (iniDesktop as string)
	),
	fn fnLoadConfigBsRefTools =
	(
		iniPosRefTools   = fnGetConfig iniPosRefTools "BsRefToolsSet" "PosRefTools" "0"
		iniRefFolder1    = fnGetConfig iniRefFolder1 "BsRefToolsSet" "RefFolder1" (iniRefFolder1 as string)
		iniRefFolder2    = fnGetConfig iniRefFolder2 "BsRefToolsSet" "RefFolder2" (iniRefFolder2 as string)
		iniRefFolder3    = fnGetConfig iniRefFolder3 "BsRefToolsSet" "RefFolder3" (iniRefFolder3 as string)
		iniRefFolder4    = fnGetConfig iniRefFolder4 "BsRefToolsSet" "RefFolder4" (iniRefFolder4 as string)
		iniFilterRefName = fnGetConfig iniFilterRefName "BsRefToolsSet" "FilterRefName" (iniFilterRefName as string)
		iniLastRefFolder = fnGetConfig iniLastRefFolder "BsRefToolsSet" "LastRefFolder" (iniLastRefFolder as string)
	),
	fn fnLoadConfigSelSetTools =
	(
		iniPosSelSetTools = fnGetConfig iniPosSelSetTools "BsSelSetToolsSet" "PosSelSetTools" "0"
	),
	fn fnLoadConfigVportTools =
	(
		iniPosVportTools   = fnGetConfig iniPosVportTools "BsVportTools" "PosVportTools" "0"
		iniVportToolsWidth = fnGetConfig iniPosVportTools "BsVportTools" "VportToolsWidth" "150"
	),
	fn fnLoadConfigBsCleanVirus =
	(
		iniStartupBsCleanVirus = fnGetConfig iniStartupBsCleanVirus "BsCleanVirus" "StartupBsCleanVirus" "0"
	),
	fn fnGetVerboseLevel = (
        ini = (execute ("@\"" + (getDir #maxData) + "\\scanlog.ini\""))
        v = getIniSetting ini "SETTINGS" "VERBOSELEVEL"
        if(v == "") do return 1
        return try(v as integer) catch(1)
    ),
	fn fnLoadConfigBsTogglePanel =
	(
		iniTogglePanelPos = fnGetConfig iniTogglePanelPos "BsTogglePanelSet" "TogglePanelPos" "0"
	),
	fn fnLoadConfigTrackBarTools =
	(
		iniDockPos          = fnGetConfig iniDockPos "BsTrackBarTools" "DockPos" "cui_dock_bottom"
		iniPosAutoBackup    = fnGetConfig iniPosAutoBackup "BsTrackBarTools" "PosTrackBarTools" "0"
		iniPosBackupManager = fnGetConfig iniPosBackupManager "BsTrackBarTools" "PosBackupManager" "0"
		iniBackupPath       = fnGetConfig iniBackupPath "BsTrackBarTools" "BackupPath" ((getdir #autoback) + "\\BsBackup")
		iniMaxBackupCount   = fnGetConfig iniMaxBackupCount "BsTrackBarTools" "MaxBackupCount" (iniMaxBackupCount as string)
		iniStopTime         = fnGetConfig iniStopTime "BsTrackBarTools" "StopTime" (iniStopTime as string)
		iniStopState        = fnGetConfig iniStopState "BsTrackBarTools" "StopState" (iniStopState as string)
	)
)
struct stSetConfigAll
(
	fn fnSetConfigBsKeyTools =
	(
		SetINISetting BulletConfig "BulletKeyToolsSet" "Pos" (iniPos as string)
		SetINISetting BulletConfig "BulletKeyToolsSet" "ToolPanel" (switchToolPanel as string)
		SetINISetting BulletConfig "BulletKeyToolsSet" "MSPanel" (switchMSPanel as string)
		SetINISetting BulletConfig "BulletKeyToolsSet" "idBtn" (idBtn as string)
		SetINISetting BulletConfig "BulletKeyToolsSet" "idMsBtn" (idMsBtn as string)
		SetINISetting BulletConfig "BulletKeyToolsSet" "AutoCheckUpdate" (iniBsAutoCheckUpdate as string)
		SetINISetting BulletConfig "BulletKeyToolsSet" "IsIcon" (iniIsIcon as string)
		SetINISetting BulletConfig "BulletKeyToolsSet" "CollopseType" (iniCollopseType as string)
		fnSetToolBtnConfig()
		fnSetMsBtnConfig()
	),
	fn fnSetConfigBsOpenTools =
	(
		SetINISetting BulletConfig "BsOpenToolsSet" "PosOpenTools" (iniPosOpenTools as string)
		SetINISetting BulletConfig "BsOpenToolsSet" "SelectedID" (iniSelectedID as string)
		SetINISetting BulletConfig "BsOpenToolsSet" "LikedFolder" (iniLikedFolder as string)
		SetINISetting BulletConfig "BsOpenToolsSet" "FilterPrefix" (iniFilterPrefix as string)
		SetINISetting BulletConfig "BsOpenToolsSet" "WidthOpenTools" (iniWidthOpenTools as string)
		SetINISetting BulletConfig "BsOpenToolsSet" "Desktop" (iniDesktop as string)
	),
	fn fnSetConfigBsRefTools =
	(
		SetINISetting BulletConfig "BsRefToolsSet" "PosRefTools" (iniPosRefTools as string)
		SetINISetting BulletConfig "BsRefToolsSet" "RefFolder1" (iniRefFolder1 as string)
		SetINISetting BulletConfig "BsRefToolsSet" "RefFolder2" (iniRefFolder2 as string)
		SetINISetting BulletConfig "BsRefToolsSet" "RefFolder3" (iniRefFolder3 as string)
		SetINISetting BulletConfig "BsRefToolsSet" "RefFolder4" (iniRefFolder4 as string)
		SetINISetting BulletConfig "BsRefToolsSet" "FilterRefName" (iniFilterRefName as string)
		SetINISetting BulletConfig "BsRefToolsSet" "LastRefFolder" (iniLastRefFolder as string)
	),
	fn fnSetConfigSelSetTools =
	(
		SetINISetting BulletConfig "BsSelSetToolsSet" "PosSelSetTools" (iniPosSelSetTools as string)
	),
	fn fnSetConfigVportTools =
	(
		SetINISetting BulletConfig "BsVportTools" "PosVportTools" (iniPosVportTools as string)
		SetINISetting BulletConfig "BsVportTools" "VportToolsWidth" (iniVportToolsWidth as string)
	),
	fn fnSetConfigBsCleanVirus =
	(
		SetINISetting BulletConfig "BsCleanVirus" "StartupBsCleanVirus" (iniStartupBsCleanVirus as string)
	),
	fn fnSetVerboseLevel lvl = (
        ini = (execute ("@\"" + (getDir #maxData) + "\\scanlog.ini\""))
        setIniSetting ini "SETTINGS" "VERBOSELEVEL" (lvl as string)
    ),
	fn fnSetConfigBsTogglePanel =
	(
		SetINISetting BulletConfig "BsTogglePanelSet" "TogglePanelPos" (iniTogglePanelPos as string)
	),
	fn fnSetConfigTrackBarTools =
	(
		SetINISetting BulletConfig "BsTrackBarTools" "DockPos" (iniDockPos as string)
		SetINISetting BulletConfig "BsTrackBarTools" "PosTrackBarTools" (iniPosAutoBackup as string)
		SetINISetting BulletConfig "BsTrackBarTools" "PosBackupManager" (iniPosBackupManager as string)
		SetINISetting BulletConfig "BsTrackBarTools" "BackupPath" (iniBackupPath as string)
		SetINISetting BulletConfig "BsTrackBarTools" "MaxBackupCount" (iniMaxBackupCount as string)
		SetINISetting BulletConfig "BsTrackBarTools" "StopTime" (iniStopTime as string)
		SetINISetting BulletConfig "BsTrackBarTools" "StopState" (iniStopState as string)
	)
)