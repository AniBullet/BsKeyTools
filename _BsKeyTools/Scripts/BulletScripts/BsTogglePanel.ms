try(destroydialog rolTogglePanel)catch()
try(destroydialog rolBsKeyTools)catch()
-- try(destroydialog rolFnKeys)catch()
-- try(destroydialog rolAddMyScripts)catch()
-- try(destroydialog rolCustomFps)catch()
-- try(destroydialog rolCustomBtn)catch()

global iniTogglePanelPos
global heightTogglePanel    = 30
global widthToggleTools     = 520
global isMouseInBsToolPanel = true

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false)
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false)
stLoadConfigAll.fnLoadConfigBsTogglePanel()

fn fnGetHitokoto = 
(
    local isConnectInternet = (internet.CheckConnection url:"https://v1.hitokoto.cn/?c=a&c=b&c=c&c=d&c=h&c=i&charset=gbk" force:true)

    if isConnectInternet == true then
    (
        local urlLine = "https://v1.hitokoto.cn/?c=a&c=b&c=c&c=d&c=h&c=i&charset=gbk&max_length=20"
        local strAllLine = (dotNetObject "System.Net.WebClient").downloadString urlLine
        if	strAllLine != undefined then
        (
            arrAllLine = filterString strAllLine "\""
            strMainLine = arrAllLine[10]
            strFrom = arrAllLine[18]
            -- strFromWho = if arrAllLine[21] == ":null," then "未知" else arrAllLine[22]
            strOneLine = ("\"" + strMainLine + "\"" + " 《" + strFrom + "》")
            -- print strAllLine
            -- print strOneLine
            return strOneLine
        )
    )
    else 
    (
        local arrDayWeek = #("日", "一", "二", "三", "四", "五", "六")
        local arrTime = (getUniversalTime())
		local dayWeekID = (mod arrTime[3] 7) as integer
		return (dateTime.Year as string + "/" + dateTime.Month as string + "/" + dateTime.Day as string + "  星期" + arrDayWeek[dayWeekID + 1] as string)
    )
)

rollout rolTogglePanel "rolTogglePanel" width:widthToggleTools height:heightTogglePanel 
(
    local ui_clientOffset         = undefined
    local toggleToolMouseState    = off
    local posToggleToolMouseMoved = [0,0]

    dotNetControl lblClosedString "Label" pos:[3,3] width:(widthToggleTools - 6) height:(heightTogglePanel - 6)

    timer timerTickTock interval:100 active:true
    
    on rolTogglePanel open do 
    (
        local strDayLine = fnGetHitokoto()
        lblClosedString.backcolor = BsDotBackColor
        lblClosedString.forecolor = BsDotForeColor
        lblClosedString.flatstyle = (dotnetclass "System.Windows.Forms.Flatstyle").flat
        lblClosedString.TextAlign = (dotnetclass "system.drawing.contentalignment").MiddleCenter
        lblClosedString.Font      = dotnetobject "System.Drawing.Font" "Microsoft YaHei" 10
        -- lblClosedString.Font      = BsDotFont
        lblClosedString.Text = strDayLine
    )

    on rolTogglePanel close do 
    (
        iniTogglePanelPos   = (GetDialogPos rolTogglePanel)
        stSetConfigAll.fnSetConfigBsTogglePanel()
    )

    on timerTickTock tick do 
    (
        if (ui_clientOffset != undefined) then (
            local mouseClientPos = mouse.screenPos - (getDialogPos rolTogglePanel) + ui_clientOffset
            
            local dialogPos = getDialogPos rolTogglePanel
            local dialogBox = (Box2 dialogPos.x dialogPos.y rolTogglePanel.width rolTogglePanel.height)
            
            if (contains dialogBox mouse.screenPos) then 
            (
                if isMouseInBsToolPanel then
                (
                    -- try(destroydialog rolBsKeyTools)catch()
                    -- try(destroydialog rolFnKeys)catch()
                    -- try(destroydialog rolAddMyScripts)catch()
                    -- try(destroydialog rolCustomFps)catch()
                    -- try(destroydialog rolCustomBtn)catch()
                    -- iniPos = (getDialogPos rolTogglePanel)
                    -- SetINISetting BulletConfig "BulletKeyToolsSet"  "Pos" (iniPos as string)
                    -- try
                    -- (
                    --     fileIn ((getDir #Scripts)+ @"\\BulletScripts\\BulletKeyTools.ms")
                    -- )
                    -- catch(messagebox "打开BsKeyTools失败,\r\n建议重启Max或重新安装...          ")
                    rolTogglePanel.height = 0
                    rolBsKeyTools.height = 250
                    isMouseInBsToolPanel = false
                    -- print (rolTogglePanel.height as string)
                    -- print (dialogBox as string + " // " + mouse.screenPos as string)
                )
            )
            else if (not isMouseInBsToolPanel) then 
            (
                rolTogglePanel.height = 30
                rolBsKeyTools.height = 0
                isMouseInBsToolPanel = true
            --     -- print (rolTogglePanel.height as string)
            --     -- print (dialogBox as string + " // " + mouse.screenPos as string)
            )
        )
    )

    on rolTogglePanel lbuttondown posMouse do
	(
		posToggleToolMouseMoved = posMouse
		toggleToolMouseState = on
        -- print (toggleToolMouseState as string)
	)
	
	on rolTogglePanel lbuttonup posMouse do
	(
		toggleToolMouseState = off
        -- print (toggleToolMouseState as string)
	)

    on rolTogglePanel mousemove pos do (
        if (ui_clientOffset == undefined) and (toggleToolMouseState == off) then ( ui_clientOffset = pos - (mouse.screenPos - (getDialogPos rolTogglePanel)) )
        if toggleToolMouseState == on then
		(
			SetDialogPos rolTogglePanel (mouse.screenpos - posToggleToolMouseMoved)
		)
    )

)
Createdialog rolTogglePanel fgcolor:myFgColor pos:iniTogglePanelPos style:#()