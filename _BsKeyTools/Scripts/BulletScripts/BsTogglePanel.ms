try(destroydialog rolTogglePanel)catch()

global rolTogglePanel
global iniTogglePanelPos
global heightTogglePanel    = 80
global widthToggleTools     = 520
global isMouseInBsToolPanel = true
global arrDayWeek = #("日", "一", "二", "三", "四", "五", "六")

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false)
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false)
stLoadConfigAll.fnLoadConfigBsTogglePanel()

rollout rolTogglePanel "rolTogglePanel" width:widthToggleTools height:heightTogglePanel 
(
    local ui_clientOffset         = undefined
    local toggleToolMouseState    = off
    local posToggleToolMouseMoved = [0,0]
    local strDayLine              = ""
    local userName                = (" to \"" + (filterString  (getdir #userscripts) @"\")[3] + "\" ")

    dotNetControl lblOneWord "Label" pos:[2,2] width:(rolTogglePanel.width - 4) height:(rolTogglePanel.height - 4)

    timer timerTickTock interval:200 active:true
    
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
                strOneLine = ("\"" + strMainLine + "\"" + " 《" + strFrom + "》\r\n" + "May all the beauty be blessed." + userName)
                -- print strAllLine
                -- print strOneLine
                return strOneLine
            )
        )
    )

    fn fnGetDateTimeString =
    (
        local dateTime = (dotNetClass "System.DateTime").Now
        local arrTime = (getLocalTime())
        local dayWeek = arrDayWeek[(mod arrTime[3] 7) as integer + 1]

        return (dateTime.Year as string + "/" + dateTime.Month as string + "/" + \
        dateTime.Day as string + "  星期" + dayWeek + "  " + dateTime.Hour as string +" 时 " + \
        dateTime.Minute as string + " 分 " + dateTime.Second as string + " 秒")
    )

    fn fnStylizeLabel tempLabel =
    (
        tempLabel.backcolor = BsDotBackColor
        tempLabel.forecolor = BsDotForeColor
        tempLabel.flatstyle = (dotnetclass "System.Windows.Forms.Flatstyle").flat
        tempLabel.TextAlign = (dotnetclass "system.drawing.contentalignment").MiddleCenter
        tempLabel.Font      = dotnetobject "System.Drawing.Font" "Microsoft YaHei" 10
    )

    fn fnRefreshText =
    (
        if iniCollopseType == 2 then
        (
            return (dayTimeString + "\r\n" + "当前时间：" +
            fnGetDateTimeString()  + "\r\n" + strDayLine)
        )
        else if iniCollopseType == 1 then
        (
            return ("当前时间：" + fnGetDateTimeString())
        )
    )

    on rolTogglePanel open do 
    (
        local dateTime = (dotNetClass "System.DateTime").Now
        strDayLine = fnGetHitokoto()
        fnStylizeLabel lblOneWord
        if iniCollopseType == 1 then (rolTogglePanel.height = 30) 
        else (rolTogglePanel.height = heightTogglePanel)
        lblOneWord.height = (rolTogglePanel.height - 4)
        fnRefreshText()
        -- lblOneWord.Font      = BsDotFont
    )

    on rolTogglePanel close do 
    (
        iniTogglePanelPos   = (GetDialogPos rolTogglePanel)
        stSetConfigAll.fnSetConfigBsTogglePanel()
    )

    on timerTickTock tick do 
    (
        lblOneWord.Text = fnRefreshText()
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
                    rolTogglePanel.timerTickTock.active = false
                    rolTogglePanel.height = 0
                    rolBsKeyTools.height = 250
                    rolBsKeyTools.timerTickTock.active = true
                    -- isMouseInBsToolPanel = false
                    -- print (rolTogglePanel.height as string)
                    -- print (dialogBox as string + " // " + mouse.screenPos as string)
                )
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
Createdialog rolTogglePanel fgcolor:myFgColor pos:iniTogglePanelPos style:#() bitmap:(bitmap widthToggleTools heightTogglePanel color:(color 208 208 208))