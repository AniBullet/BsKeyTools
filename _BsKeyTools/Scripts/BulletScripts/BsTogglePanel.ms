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

-- 创建一个全局结构来封装 GetForegroundWindow，兼容所有 Max 版本
struct WindowHelper
(
	-- 使用 UIAccessor 来获取前台窗口（MaxScript 内置功能，兼容所有版本）
	fn getForegroundWindow =
	(
		try
		(
			-- UIAccessor.GetForegroundWindow() 返回前台窗口句柄
			return (UIAccessor.GetForegroundWindow())
		)
		catch
		(
			return 0
		)
	)
)

-- 创建全局 window 实例
if window == undefined do
(
	global window = WindowHelper()
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
        if iniCostTime != undefined then
        (
            local timeNow = (dotNetClass "System.DateTime").Now
            local bsTimeCost = timeNow.Subtract dateTime
            local newSeconds = mod (iniCostTime[4] + bsTimeCost.Seconds) 60
            local newMintes = mod ((iniCostTime[4] + bsTimeCost.Seconds)/60 + iniCostTime[3] + bsTimeCost.Minutes) 60
            local mewHours = mod (((iniCostTime[4] + bsTimeCost.Seconds)/60 + iniCostTime[3] + bsTimeCost.Minutes)/60 + iniCostTime[2] + bsTimeCost.Hours) 24
            local newDays = ((((iniCostTime[4] + bsTimeCost.Seconds)/60 + iniCostTime[3] + bsTimeCost.Minutes)/60 + iniCostTime[2] + bsTimeCost.Hours)/24) + iniCostTime[1] + bsTimeCost.days
            arrNewCostTime = #((newDays as integer),(mewHours as integer),(newMintes as integer),(newSeconds as integer))

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
        -- 使用字节下载 + UTF-8 解码，彻底解决编码问题（兼容所有版本）
        local urlLine = "https://v1.hitokoto.cn/?c=a&c=b&c=c&c=d&c=h&c=i&c=j"
        local isConnectInternet = (internet.CheckConnection url:urlLine force:true)
    
        if isConnectInternet == true then
        (
            try
            (
                -- 使用 DownloadData 获取字节数组，然后用 UTF-8 解码
                local webClient = dotNetObject "System.Net.WebClient"
                
                -- 设置请求头，明确要求 UTF-8 编码
                webClient.Headers.Add "Accept-Charset" "UTF-8"
                
                local bytesData = webClient.DownloadData urlLine
                local utf8 = (dotNetClass "System.Text.Encoding").UTF8
                local strAllLine = utf8.GetString bytesData
                
                -- 调试输出（如果需要可以取消注释）
                -- print ("原始数据: " + strAllLine)
                
                if strAllLine != undefined and strAllLine != "" then
                (
                    -- 解析 JSON 格式的返回数据
                    arrAllLine = filterString strAllLine "\""
                    
                    -- 调试输出（如果需要可以取消注释）
                    -- print ("分割后数组长度: " + arrAllLine.count as string)
                    -- if arrAllLine.count >= 10 then print ("第10项: " + arrAllLine[10])
                    
                    if arrAllLine.count >= 18 then
                    (
                        strMainLine = arrAllLine[10]
                        strFrom = arrAllLine[18]
                        -- strFromWho = if arrAllLine[21] == ":null," then "未知" else arrAllLine[22]
                        strOneLine = ("\"" + strMainLine + "\"" + " 《" + strFrom + "》\r\n" + "May all the beauty be blessed." + userName)
                        return strOneLine
                    )
                    else
                    (
                        return "May all the beauty be blessed." + userName
                    )
                )
                else
                (
                    return "May all the beauty be blessed." + userName
                )
            )
            catch
            (
                --检查网络是否能连接
                if internet.CheckConnection url:urlLine force:true == true then 
                (
                    print "网络服务器当前不可用,请稍后再试                        "
                    return "网络服务器暂时不可用..."
                )
                else 
                (
                    print "BsKeyTools ：无网络连接或链接未响应...                                "
                    return "请检查网络..."
                )
            )
        )
        else
        (
            print "BsKeyTools ：无网络连接...                                "
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
            -- Box2 构造需要两个点：左上角和右下角（兼容2026版本）
            local dialogBox = (Box2 [dialogPos.x, dialogPos.y] [dialogPos.x + rolTogglePanel.width, dialogPos.y + rolTogglePanel.height])
            
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
                    if not rolBsKeyTools.dialogBar then rolBsKeyTools.height = 250
                    if not rolBsKeyTools.dialogBar then rolBsKeyTools.timerTickTock.active = true
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