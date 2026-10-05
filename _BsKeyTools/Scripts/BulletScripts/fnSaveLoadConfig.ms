Global BulletConfig = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径
global fnLoadToolBtnConfig
global fnSetToolBtnConfig
global fnLoadMsBtnConfig
global fnSetMsBtnConfig
global stSetConfigAll
global stLoadConfigAll
global fnGetConfig
global fnBsFixDialogPos
global fnBsGetIniPos
global fnBsSetIniPos
global fnBsEnsureDialogVisible
struct myScript (id,msName,dir)

-- 窗口位置统一校验：返回可见的位置；无效或最小化哨兵坐标返回 undefined
-- 依赖 getDialogPos 与 System.Windows.Forms.Screen 使用同一套虚拟桌面像素坐标（多屏混合 DPI 缩放需在 Max 内验证）
fn fnBsFixDialogPos pos size =
(
	if (classOf pos) != Point2 do return undefined
	if pos.x <= -30000 or pos.y <= -30000 do return undefined
	local w = amax 1 size.x
	local h = amax 1 size.y
	local needW = amin w 120
	local needH = amin h 30
	local screenClass = dotNetClass "System.Windows.Forms.Screen"
	local screens = try (screenClass.AllScreens) catch (format "[BsKeyTools] 读取显示器信息失败，跳过窗口位置校验: %\n" (getCurrentException()); undefined)
	if screens == undefined do return pos
	local isVisible = false
	for s in screens while not isVisible do
	(
		local wa = s.WorkingArea
		local visW = (amin (pos.x + w) (wa.X + wa.Width)) - (amax pos.x wa.X)
		if visW >= needW and pos.y >= (wa.Y - 10) and pos.y <= (wa.Y + wa.Height - needH) do isVisible = true
	)
	if isVisible do return pos
	local px = (amax -100000 (amin 100000 pos.x)) as integer
	local py = (amax -100000 (amin 100000 pos.y)) as integer
	local wa = (screenClass.FromPoint (dotNetObject "System.Drawing.Point" px py)).WorkingArea
	local x = if w >= wa.Width then wa.X else (amax wa.X (amin pos.x (wa.X + wa.Width - w)))
	local y = if h >= wa.Height then wa.Y else (amax wa.Y (amin pos.y (wa.Y + wa.Height - h)))
	[x, y]
)

-- 读取 ini 中的窗口位置，返回校验后的 Point2；没有记录或记录无效返回 0（保持各工具 "!= 0" 的判断习惯）
fn fnBsGetIniPos iniFile section key =
(
	local str = getINISetting iniFile section key
	if str == "" or str == "0" or str == "undefined" do return 0
	local parts = filterString str "[], "
	local p = undefined
	if parts.count == 2 do
	(
		local x = parts[1] as float
		local y = parts[2] as float
		if x != undefined and y != undefined do p = [x, y]
	)
	local fixed = fnBsFixDialogPos p [120,30]
	if fixed == undefined then
	(
		format "[BsKeyTools] 忽略无效窗口位置 [%] %: %\n" section key str
		0
	)
	else
	(
		if fixed != p do format "[BsKeyTools] 窗口位置 [%] % 不在可见屏幕内，已修正: % -> %\n" section key str fixed
		fixed
	)
)

-- 保存窗口位置；最小化/无效坐标不写入，避免覆盖上一次的有效位置
fn fnBsSetIniPos iniFile section key val =
(
	if val == 0 do return false
	local fixed = fnBsFixDialogPos val [120,30]
	if fixed == undefined then
	(
		format "[BsKeyTools] 跳过保存无效窗口位置 [%] %: %\n" section key val
		false
	)
	else
	(
		setINISetting iniFile section key (fixed as string)
		true
	)
)

-- 已打开的浮动窗口若不在可见屏幕内，直接移回最近的显示器；返回是否发生了移动
fn fnBsEnsureDialogVisible rol =
(
	if not (isKindOf rol RolloutClass) or not rol.open or rol.dialogBar do return false
	local pos = getDialogPos rol
	local fixed = fnBsFixDialogPos pos (getDialogSize rol)
	if fixed == undefined or fixed == pos do return false
	setDialogPos rol fixed
	format "[BsKeyTools] % 窗口不在可见屏幕内，已移回: % -> %\n" rol.name pos fixed
	true
)

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
		if (i != undefined and i.count != 8) or i == undefined then
		(
			i = #((myScript id:1 msName:"<＋＋>" dir:""), \
			(myScript id:2 msName:"<＋＋>" dir:""), \
			(myScript id:3 msName:"<＋＋>" dir:""), \
			(myScript id:4 msName:"<＋＋>" dir:""), \
			(myScript id:5 msName:"<＋＋>" dir:""), \
			(myScript id:6 msName:"<＋＋>" dir:""), \
			(myScript id:7 msName:"<＋＋>" dir:""), \
			(myScript id:8 msName:"<＋＋>" dir:""))
			messagebox ("很抱歉，自定脚本列表 " + tempMsArrayCount as string + " 初始化或读取失败，已重置...                                                         ")

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
		iniPos               = fnBsGetIniPos BulletConfig "BulletKeyToolsSet" "Pos"
		iniRolDockPos        = fnGetConfig iniRolDockPos "BulletKeyToolsSet" "DockPos" "float"
		switchToolPanel      = fnGetConfig switchToolPanel "BulletKeyToolsSet" "ToolPanel" (switchToolPanel as string)
		-- switchMSPanel        = fnGetConfig switchMSPanel "BulletKeyToolsSet" "MSPanel" (switchMSPanel as string)
		idBtn                = fnGetConfig idBtn "BulletKeyToolsSet" "idBtn" (idBtn as string)
		iniBsAutoCheckUpdate = fnGetConfig iniBsAutoCheckUpdate "BulletKeyToolsSet"  "AutoCheckUpdate" (iniBsAutoCheckUpdate as string)
		iniIsIcon            = fnGetConfig iniIsIcon "BulletKeyToolsSet" "IsIcon" (iniIsIcon as string)
		iniCollopseType      = fnGetConfig iniCollopseType "BulletKeyToolsSet" "CollopseType" (iniCollopseType as string)
		iniCostTime          = fnGetConfig iniCostTime "BulletKeyToolsSet" "CostTime" (iniCostTime as string)
		fnLoadToolBtnConfig()
		-- print "Loaded BsKeyTools Config"
	),
	fn fnLoadConfigBsScriptsSet =
	(
		idMsBtn            = fnGetConfig idMsBtn "BulletKeyToolsSet" "idMsBtn" (idMsBtn as string)
		iniBsScriptsSetPos = fnBsGetIniPos BulletConfig "BsScriptsSet" "Pos"
		fnLoadMsBtnConfig()
	),
	fn fnLoadConfigBsOpenTools =
	(
		iniPosOpenTools   = fnBsGetIniPos BulletConfig "BsOpenToolsSet" "PosOpenTools"
		iniSelectedID     = fnGetConfig iniSelectedID "BsOpenToolsSet" "SelectedID" (iniSelectedID as string)
		iniLikedFolder    = fnGetConfig iniLikedFolder "BsOpenToolsSet" "LikedFolder" (with printAllElements on (iniLikedFolder as string))
		iniFilterPrefix   = fnGetConfig iniFilterPrefix "BsOpenToolsSet" "FilterPrefix" (with printAllElements on (iniFilterPrefix as string))
		iniWidthOpenTools = fnGetConfig iniWidthOpenTools "BsOpenToolsSet" "WidthOpenTools" (iniWidthOpenTools as string)
		iniDesktop        = fnGetConfig iniDesktop "BsOpenToolsSet" "Desktop" (iniDesktop as string)
		iniAutoFbxPreview = fnGetConfig iniAutoFbxPreview "BsOpenToolsSet" "AutoFbxPreview" (iniAutoFbxPreview as string)
		iniSortMode       = fnGetConfig iniSortMode "BsOpenToolsSet" "SortMode" (iniSortMode as string)
	),
	fn fnLoadConfigBsRefTools =
	(
		iniPosRefTools   = fnBsGetIniPos BulletConfig "BsRefToolsSet" "PosRefTools"
		iniRefFolder1    = fnGetConfig iniRefFolder1 "BsRefToolsSet" "RefFolder1" (iniRefFolder1 as string)
		iniRefFolder2    = fnGetConfig iniRefFolder2 "BsRefToolsSet" "RefFolder2" (iniRefFolder2 as string)
		iniRefFolder3    = fnGetConfig iniRefFolder3 "BsRefToolsSet" "RefFolder3" (iniRefFolder3 as string)
		iniRefFolder4    = fnGetConfig iniRefFolder4 "BsRefToolsSet" "RefFolder4" (iniRefFolder4 as string)
		iniFilterRefName = fnGetConfig iniFilterRefName "BsRefToolsSet" "FilterRefName" (iniFilterRefName as string)
		iniLastRefFolder = fnGetConfig iniLastRefFolder "BsRefToolsSet" "LastRefFolder" (iniLastRefFolder as string)
	),
	fn fnLoadConfigSelSetTools =
	(
		iniPosSelSetTools = fnBsGetIniPos BulletConfig "BsSelSetToolsSet" "PosSelSetTools"
	),
	fn fnLoadConfigVportTools =
	(
		iniPosVportTools   = fnBsGetIniPos BulletConfig "BsVportTools" "PosVportTools"
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
		iniTogglePanelPos = fnBsGetIniPos BulletConfig "BsTogglePanelSet" "TogglePanelPos"
	),
	fn fnLoadConfigTrackBarTools =
	(
		iniDockPos          = fnGetConfig iniDockPos "BsTrackBarTools" "DockPos" "cui_dock_bottom"
		iniPosAutoBackup    = fnBsGetIniPos BulletConfig "BsTrackBarTools" "PosTrackBarTools"
		iniPosBackupManager = fnBsGetIniPos BulletConfig "BsTrackBarTools" "PosBackupManager"
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
		fnBsSetIniPos BulletConfig "BulletKeyToolsSet" "Pos" iniPos
		SetINISetting BulletConfig "BulletKeyToolsSet" "DockPos" (iniRolDockPos as string)
		SetINISetting BulletConfig "BulletKeyToolsSet" "ToolPanel" (switchToolPanel as string)
		-- SetINISetting BulletConfig "BulletKeyToolsSet" "MSPanel" (switchMSPanel as string)
		SetINISetting BulletConfig "BulletKeyToolsSet" "idBtn" (idBtn as string)
		SetINISetting BulletConfig "BulletKeyToolsSet" "AutoCheckUpdate" (iniBsAutoCheckUpdate as string)
		SetINISetting BulletConfig "BulletKeyToolsSet" "IsIcon" (iniIsIcon as string)
		SetINISetting BulletConfig "BulletKeyToolsSet" "CollopseType" (iniCollopseType as string)
		SetINISetting BulletConfig "BulletKeyToolsSet" "CostTime" (arrNewCostTime as string)
		fnSetToolBtnConfig()
	),
	fn fnSetConfigBsScriptsSet =
	(
		fnBsSetIniPos BulletConfig "BsScriptsSet" "Pos" iniBsScriptsSetPos
		SetINISetting BulletConfig "BulletKeyToolsSet" "idMsBtn" (idMsBtn as string)
		fnSetMsBtnConfig()
	),
	fn fnSetConfigBsOpenTools =
	(
		fnBsSetIniPos BulletConfig "BsOpenToolsSet" "PosOpenTools" iniPosOpenTools
		SetINISetting BulletConfig "BsOpenToolsSet" "SelectedID" (iniSelectedID as string)
		SetINISetting BulletConfig "BsOpenToolsSet" "LikedFolder" (with printAllElements on (iniLikedFolder as string))
		SetINISetting BulletConfig "BsOpenToolsSet" "FilterPrefix" (with printAllElements on (iniFilterPrefix as string))
		SetINISetting BulletConfig "BsOpenToolsSet" "WidthOpenTools" (iniWidthOpenTools as string)
		SetINISetting BulletConfig "BsOpenToolsSet" "Desktop" (iniDesktop as string)
		SetINISetting BulletConfig "BsOpenToolsSet" "AutoFbxPreview" (iniAutoFbxPreview as string)
		SetINISetting BulletConfig "BsOpenToolsSet" "SortMode" (iniSortMode as string)
	),
	fn fnSetConfigBsRefTools =
	(
		fnBsSetIniPos BulletConfig "BsRefToolsSet" "PosRefTools" iniPosRefTools
		SetINISetting BulletConfig "BsRefToolsSet" "RefFolder1" (iniRefFolder1 as string)
		SetINISetting BulletConfig "BsRefToolsSet" "RefFolder2" (iniRefFolder2 as string)
		SetINISetting BulletConfig "BsRefToolsSet" "RefFolder3" (iniRefFolder3 as string)
		SetINISetting BulletConfig "BsRefToolsSet" "RefFolder4" (iniRefFolder4 as string)
		SetINISetting BulletConfig "BsRefToolsSet" "FilterRefName" (iniFilterRefName as string)
		SetINISetting BulletConfig "BsRefToolsSet" "LastRefFolder" (iniLastRefFolder as string)
	),
	fn fnSetConfigSelSetTools =
	(
		fnBsSetIniPos BulletConfig "BsSelSetToolsSet" "PosSelSetTools" iniPosSelSetTools
	),
	fn fnSetConfigVportTools =
	(
		fnBsSetIniPos BulletConfig "BsVportTools" "PosVportTools" iniPosVportTools
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
		fnBsSetIniPos BulletConfig "BsTogglePanelSet" "TogglePanelPos" iniTogglePanelPos
	),
	fn fnSetConfigTrackBarTools =
	(
		SetINISetting BulletConfig "BsTrackBarTools" "DockPos" (iniDockPos as string)
		fnBsSetIniPos BulletConfig "BsTrackBarTools" "PosTrackBarTools" iniPosAutoBackup
		fnBsSetIniPos BulletConfig "BsTrackBarTools" "PosBackupManager" iniPosBackupManager
		SetINISetting BulletConfig "BsTrackBarTools" "BackupPath" (iniBackupPath as string)
		SetINISetting BulletConfig "BsTrackBarTools" "MaxBackupCount" (iniMaxBackupCount as string)
		SetINISetting BulletConfig "BsTrackBarTools" "StopTime" (iniStopTime as string)
		SetINISetting BulletConfig "BsTrackBarTools" "StopState" (iniStopState as string)
	)
)