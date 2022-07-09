global dateTime = (dotNetClass "System.DateTime").Now
global arrDayWeek = #("日", "一", "二", "三", "四", "五", "六")
global fnSwitchBtnString

fn fnSwitchBtnString =
(
    local arrTime = (getLocalTime())
    local dayWeekID = (mod arrTime[3] 7) as integer
    case (dayWeekID + 1)of 
    (
        (1):("桂花载酒")
        (2):("安如磐石")
        (3):("无风之地")
        (4):("高天之歌")
        (5):("天动万象")
        (6):("靖妖傩舞")
        (7):("归离浮生")
        default:("天动万象")
    )
)