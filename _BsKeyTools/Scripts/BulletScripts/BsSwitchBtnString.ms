global dateTime = (dotNetClass "System.DateTime").Now
global arrDayWeek = #("日", "一", "二", "三", "四", "五", "六")
global arrDayElement = #("pyro.png","anemo.png","cyro.png","dendro.png","electro.png","geo.png","hydro.png")
global fnSwitchBtnString
global fnChangeBtnElement

fn fnSwitchBtnString =
(
    local arrTime = (getLocalTime())
    local dayWeekID = (mod arrTime[3] 7) as integer
    case (dayWeekID + 1) of 
    (
        (1):(#("归离浮生",arrDayElement[1]))
        (2):(#("安如磐石",arrDayElement[2]))
        (3):(#("无风之地",arrDayElement[3]))
        (4):(#("高天之歌",arrDayElement[4]))
        (5):(#("天动万象",arrDayElement[5]))
        (6):(#("靖妖傩舞",arrDayElement[6]))
        (7):(#("桂花载酒",arrDayElement[7]))
        default:(#("天动万象",arrDayElement[1]))
    )
)

fn fnChangeBtnElement curElement =
(
    idElement = (finditem arrDayElement curElement)
    idElement += 1
    if idElement > 7 then idElement = 1
    return arrDayElement[idElement]
)