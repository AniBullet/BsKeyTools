global dateTime = (dotNetClass "System.DateTime").Now
global arrDayWeek = #("日", "一", "二", "三", "四", "五", "六")
global arrDayElement = #("pyro.png","anemo.png","cyro.png","dendro.png","electro.png","geo.png","hydro.png")
global fnSwitchBtnString
global fnChangeBtnElement

fn fnSwitchBtnString =
(
    local arrTime = (getLocalTime())
    local dayWeekID = (mod arrTime[3] 7) as integer
    -- 返回格式：#(页签名称字符串或数组, 元素图标)
    -- 页签名称支持两种格式：
    -- 1. 字符串 "归离浮生" - 每个字符对应一个页签
    -- 2. 数组 #("归","离","浮","生","天","动","万","象") - 支持更多页签
    case (dayWeekID + 1) of 
    (
        (1):(#("归离浮生天动万象",arrDayElement[1]))
        (2):(#("安如磐石靖妖傩舞",arrDayElement[2]))
        (3):(#("无风之地桂花载酒",arrDayElement[3]))
        (4):(#("高天之歌归离浮生",arrDayElement[4]))
        (5):(#("天动万象安如磐石",arrDayElement[5]))
        (6):(#("靖妖傩舞无风之地",arrDayElement[6]))
        (7):(#("桂花载酒高天之歌",arrDayElement[7]))
        default:(#("天动万象归离浮生",arrDayElement[1]))
    )
)

fn fnChangeBtnElement curElement =
(
    idElement = (finditem arrDayElement curElement)
    idElement += 1
    if idElement > 7 then idElement = 1
    return arrDayElement[idElement]
)