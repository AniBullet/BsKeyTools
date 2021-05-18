global dateTime = (dotNetClass "System.DateTime").Now
global arrDayWeek = #("日", "一", "二", "三", "四", "五", "六")
global fnSwitchBtnString

fn fnSwitchBtnString =
(
    local arrTime = (getUniversalTime())
    local dayWeekID = (mod arrTime[3] 7) as integer
    case dayWeekID of 
    (
        (1):("蹦蹦炸弹")
        (2):("轰轰火花")
        (3):("火焰烧尽")
        (4):("靖妖傩舞")
        (5):("天动万象")
        (6):("剑光如我")
        (7):("向着星辰")
        default:("天动万象")
    )
)