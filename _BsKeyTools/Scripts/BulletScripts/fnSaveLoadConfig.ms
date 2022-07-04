Global BulletConfig = execute ("@\"" + (getDir #maxData) + "\\BulletConfig.ini\"")  --配置文件路径
global fnLoadToolBtnConfig
global fnSetToolBtnConfig
global stSetConfigAll
global stLoadConfigAll
global fnGetConfig

fn fnGetConfig attr nameAttrClass nameAttr valueAttr =  --设置初始信息方法
(
	local oldPrintAllElements  = options.printAllelements
	options.printAllelements = true
	attr = (GetINISetting BulletConfig nameAttrClass nameAttr) as string  --先提取文件中的记录
	if ((nameAttr == "ArrMyScripts") or (nameAttr == "LikedFolder") \
	or (nameAttr == "Desktop") or (matchpattern nameAttr  pattern:"RefFolder*") \
	or (nameAttr == "LastRefFolder")) then(attr = substituteString attr "dir:" "dir:@")
	if attr == "" then (attr = execute valueAttr) else (attr = execute attr) --判断记录为空与否得到需要的记录参数
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

struct stLoadConfigAll
(
	fn fnLoadConfigBsKeyToolsAll =
	(
		iniPos               = fnGetConfig iniPos "BulletKeyToolsSet" "Pos" "0"
		switchToolPanel      = fnGetConfig switchToolPanel "BulletKeyToolsSet"  "ToolPanel" (switchToolPanel as string)
		switchMSPanel        = fnGetConfig switchMSPanel "BulletKeyToolsSet"  "MSPanel" (switchMSPanel as string)
		idBtn                = fnGetConfig idBtn "BulletKeyToolsSet"  "idBtn" (idBtn as string)
		idMsBtn              = fnGetConfig idMsBtn "BulletKeyToolsSet"  "idMsBtn" (idMsBtn as string)
		iniArrMyScripts      = fnGetConfig iniArrMyScripts "BulletKeyToolsSet"  "ArrMyScripts" (iniArrMyScripts as string)
		iniBsAutoCheckUpdate = fnGetConfig iniBsAutoCheckUpdate "BulletKeyToolsSet"  "AutoCheckUpdate" (iniBsAutoCheckUpdate as string)
		iniIsIcon            = fnGetConfig iniIsIcon "BulletKeyToolsSet"  "IsIcon" (iniIsIcon as string)
		fnLoadToolBtnConfig()
		if (iniArrMyScripts.count != 10) then
		(
			iniArrMyScripts = #((myScript id:1 msName:"<＋＋>" dir:""), \
			(myScript id:2 msName:"<＋＋>" dir:""), \
			(myScript id:3 msName:"<＋＋>" dir:""), \
			(myScript id:4 msName:"<＋＋>" dir:""), \
			(myScript id:5 msName:"<＋＋>" dir:""), \
			(myScript id:6 msName:"<＋＋>" dir:""), \
			(myScript id:7 msName:"<＋＋>" dir:""), \
			(myScript id:8 msName:"<＋＋>" dir:""),
			(myScript id:9 msName:"<＋＋>" dir:""),
			(myScript id:10 msName:"<＋＋>" dir:""))
		)
		-- print "Loaded BsKeyTools Config"
	),
	fn fnLoadConfigBsAnimButton =
	(
		iniPosAnimButtonTools = fnGetConfig iniPosAnimButtonTools "BsAnimButtonSet" "PosAnimButton" "0"
		iniAnimButtonSelected = fnGetConfig iniAnimButtonSelected "BsAnimButtonSet" "AnimButtonSelected" "0"
	),
	fn fnLoadConfigBsOpenTools =
	(
		iniPosOpenTools   = fnGetConfig iniPosOpenTools "BsOpenToolsSet" "PosOpenTools" "0"
		iniSelectedID     = fnGetConfig iniSelectedID "BsOpenToolsSet" "SelectedID" (iniSelectedID as string)
		iniLikedFolder    = fnGetConfig iniLikedFolder "BsOpenToolsSet"  "LikedFolder" (iniLikedFolder as string)
		iniFilterPrefix   = fnGetConfig iniFilterPrefix "BsOpenToolsSet"  "FilterPrefix" (iniFilterPrefix as string)
		iniWidthOpenTools = fnGetConfig iniWidthOpenTools "BsOpenToolsSet"  "WidthOpenTools" (iniWidthOpenTools as string)
		iniDesktop        = fnGetConfig iniDesktop "BsOpenToolsSet"  "Desktop" (iniDesktop as string)
	),
	fn fnLoadConfigBsRefTools =
	(
		iniPosRefTools   = fnGetConfig iniPosRefTools "BsRefToolsSet" "PosRefTools" "0"
		iniRefFolder1    = fnGetConfig iniRefFolder1 "BsRefToolsSet"  "RefFolder1" (iniRefFolder1 as string)
		iniRefFolder2    = fnGetConfig iniRefFolder2 "BsRefToolsSet"  "RefFolder2" (iniRefFolder2 as string)
		iniRefFolder3    = fnGetConfig iniRefFolder3 "BsRefToolsSet"  "RefFolder3" (iniRefFolder3 as string)
		iniRefFolder4    = fnGetConfig iniRefFolder4 "BsRefToolsSet"  "RefFolder4" (iniRefFolder4 as string)
		iniFilterRefName = fnGetConfig iniFilterRefName "BsRefToolsSet"  "FilterRefName" (iniFilterRefName as string)
		iniLastRefFolder = fnGetConfig iniLastRefFolder "BsRefToolsSet"  "LastRefFolder" (iniLastRefFolder as string)
	),
	fn fnLoadConfigSelSetTools =
	(
		iniPosSelSetTools = fnGetConfig iniPosSelSetTools "BsSelSetToolsSet" "PosSelSetTools" "0"
	),
	fn fnLoadConfigBsCleanVirus =
	(
		iniStartupBsCleanVirus = fnGetConfig iniStartupBsCleanVirus "BsCleanVirus" "StartupBsCleanVirus" "0"
	)
)
struct stSetConfigAll
(
	fn fnSetConfigBsKeyTools =
	(
		SetINISetting BulletConfig "BulletKeyToolsSet"  "Pos" (iniPos as string)
		SetINISetting BulletConfig "BulletKeyToolsSet"  "ToolPanel" (switchToolPanel as string)
		SetINISetting BulletConfig "BulletKeyToolsSet"  "MSPanel" (switchMSPanel as string)
		SetINISetting BulletConfig "BulletKeyToolsSet"  "idBtn" (idBtn as string)
		SetINISetting BulletConfig "BulletKeyToolsSet"  "idMsBtn" (idMsBtn as string)
		SetINISetting BulletConfig "BulletKeyToolsSet"  "ArrMyScripts" (iniArrMyScripts as string)
		SetINISetting BulletConfig "BulletKeyToolsSet"  "AutoCheckUpdate" (iniBsAutoCheckUpdate as string)
		SetINISetting BulletConfig "BulletKeyToolsSet"  "IsIcon" (iniIsIcon as string)
		fnSetToolBtnConfig()
	),
	fn fnSetConfigBsAnimButton =
	(
		SetINISetting BulletConfig "BsAnimButtonSet" "PosAnimButton" (iniPosAnimButtonTools as string)
		SetINISetting BulletConfig "BsAnimButtonSet" "AnimButtonSelected" (rolBsAnimButton.dotnetTabCon.SelectedIndex as string)
	),
	fn fnSetConfigBsOpenTools =
	(
		SetINISetting BulletConfig "BsOpenToolsSet"  "PosOpenTools" (iniPosOpenTools as string)
		SetINISetting BulletConfig "BsOpenToolsSet"  "SelectedID" (iniSelectedID as string)
		SetINISetting BulletConfig "BsOpenToolsSet"  "LikedFolder" (iniLikedFolder as string)
		SetINISetting BulletConfig "BsOpenToolsSet"  "FilterPrefix" (iniFilterPrefix as string)
		SetINISetting BulletConfig "BsOpenToolsSet"  "WidthOpenTools" (iniWidthOpenTools as string)
		SetINISetting BulletConfig "BsOpenToolsSet"  "Desktop" (iniDesktop as string)
	),
	fn fnSetConfigBsRefTools =
	(
		SetINISetting BulletConfig "BsRefToolsSet"  "PosRefTools" (iniPosRefTools as string)
		SetINISetting BulletConfig "BsRefToolsSet"  "RefFolder1" (iniRefFolder1 as string)
		SetINISetting BulletConfig "BsRefToolsSet"  "RefFolder2" (iniRefFolder2 as string)
		SetINISetting BulletConfig "BsRefToolsSet"  "RefFolder3" (iniRefFolder3 as string)
		SetINISetting BulletConfig "BsRefToolsSet"  "RefFolder4" (iniRefFolder4 as string)
		SetINISetting BulletConfig "BsRefToolsSet"  "FilterRefName" (iniFilterRefName as string)
		SetINISetting BulletConfig "BsRefToolsSet"  "LastRefFolder" (iniLastRefFolder as string)
	),
	fn fnSetConfigSelSetTools =
	(
		SetINISetting BulletConfig "BsSelSetToolsSet"  "PosSelSetTools" (iniPosSelSetTools as string)
	),
	fn fnSetConfigBsCleanVirus =
	(
		SetINISetting BulletConfig "BsCleanVirus"  "StartupBsCleanVirus" (iniStartupBsCleanVirus as string)
	)
)