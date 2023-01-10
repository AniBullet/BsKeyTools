try(destroydialog rolTogglePanel)catch()

global rolTogglePanel
global iniTogglePanelPos
global heightTogglePanel    = 100
global widthToggleTools     = 355
global isMouseInBsToolPanel = true
global arrDayWeek = #("日", "一", "二", "三", "四", "五", "六")

try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnSaveLoadConfig.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false)
try(FileIn ((getDir #scripts) + "\\BulletScripts\\fnGetColorTheme.ms"))
catch(messagebox "打开失败，工具可能安装不完全，\r\n\r\n建议查看设置中的帮助或重新安装...                            " beep:false)
stLoadConfigAll.fnLoadConfigBsTogglePanel()

(
	fn getWindowClass =
	(
		local source  = "using System;"
		source += "using System.Runtime.InteropServices;"
		source += "public class Window"
		source += "{"
		source += "	[DllImport(\"user32.dll\")]"
		source += "	public static extern IntPtr GetForegroundWindow();"
		source += "}"

		local csharpProvider = dotNetObject "Microsoft.CSharp.CSharpCodeProvider"
		local compilerParams = dotNetObject "System.CodeDom.Compiler.CompilerParameters"
		compilerParams.GenerateInMemory = true
		compilerParams.ReferencedAssemblies.Add "System.dll"
		local compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
		compilerResults.CompiledAssembly.CreateInstance "Window"
	)
	if NOT isKindOf ::window dotNetObject do window = getWindowClass()
)

fn fnGetParentHwnd chwnd =
(
    parentHwnd = UIAccessor.GetParentWindow chwnd
    if parentHwnd != 0P then
    (
        fnGetParentHwnd parentHwnd
    )
    else 
    (
        return chwnd
    )
)
-- 检查前台窗口是否能触发面板收缩展开
fn fnMaxWindowIsActive =
(
    local stateActive = false
    local childrenHwndAll = (windows.getChildrenHWND #max)
    local parentHwnd = (fnGetParentHwnd (window.getForegroundWindow()))

    for i in childrenHwndAll do 
    (
        if finditem i parentHwnd != 0 then (stateActive = true)
        if UIAccessor.getWindowText parentHwnd == "rolBipedTools" then (stateActive = true)
    )
    return stateActive
)

rollout rolTogglePanel "rolTogglePanel" width:widthToggleTools height:heightTogglePanel 
(
    local ui_clientOffset         = undefined
    local toggleToolMouseState    = off
    local posToggleToolMouseMoved = [0,0]
    local strDayLine              = ""
    local userName                = (" to \"" + (filterString  (getdir #userscripts) @"\")[3] + "\" ")

    dotNetControl lblOneWord "Label" pos:[2,2] width:(rolTogglePanel.width - 4) height:(rolTogglePanel.height - 4)

    timer timerTickTock interval:200 active:true
    
    fn fnGetTimeCost =
    (
        if dateTime != undefined then
        (
            local timeNow = (dotNetClass "System.DateTime").Now
            local bsTimeCost = timeNow.Subtract dateTime
            arrNewCostTime = #(bsTimeCost.days,bsTimeCost.Hours,bsTimeCost.Minutes,bsTimeCost.Seconds)

            return ("Link Start : " + 
            arrNewCostTime[1] as string + " 天 " + 
            arrNewCostTime[2] as string + " 小时 " + 
            arrNewCostTime[3] as string + " 分钟 " + 
            arrNewCostTime[4] as string + " 秒钟")
        )
        else (return "抱歉，无法获取当前时间，请重试！")
    )

    fn fnGetHitokoto = 
    (
        local isConnectInternet = (internet.CheckConnection url:"https://v1.hitokoto.cn/?c=a&c=b&c=c&c=d&c=h&c=i&c=j&charset=gbk" force:true)
    
        if isConnectInternet == true then
        (
            local urlLine = "https://v1.hitokoto.cn/?c=a&c=b&c=c&c=d&c=h&c=i&c=j&charset=gbk"
            local strAllLine = (try ((dotNetObject "System.Net.WebClient").downloadString urlLine) catch())
            if strAllLine != undefined then
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
        else
        (
            --检查网络是否能连接
            if internet.CheckConnection url:"https://v1.hitokoto.cn/?c=a&c=b&c=c&c=d&c=h&c=i&c=j&charset=gbk" force:true == true then 
            (print "网络服务器当前不可用,请稍后再试                        ")
            else (print "BsKeyTools ：无网络连接或链接未响应...                                ")
            return "请检查网络..."
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
            local dayTimeString = fnGetTimeCost()
            local dateTime = (dotNetClass "System.DateTime").Now
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
        fnStylizeLabel lblOneWord
        if iniCollopseType == 1 then 
        (
            rolTogglePanel.height = 30
            rolTogglePanel.width  = 355
        ) 
        else 
        (
            strDayLine = fnGetHitokoto()
            rolTogglePanel.height = heightTogglePanel
            rolTogglePanel.width  = widthToggleTools
        )
        lblOneWord.height = (rolTogglePanel.height - 4)
        lblOneWord.width  = (rolTogglePanel.width - 4)
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
        isMaxActive = fnMaxWindowIsActive()
        -- print isMaxActive
        if (ui_clientOffset != undefined) then 
        (
            local mouseClientPos = mouse.screenPos - (getDialogPos rolTogglePanel) + ui_clientOffset
            
            local dialogPos = getDialogPos rolTogglePanel
            local dialogBox = (Box2 dialogPos.x dialogPos.y rolTogglePanel.width rolTogglePanel.height)
            
            if (contains dialogBox mouse.screenPos) and isMaxActive then 
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