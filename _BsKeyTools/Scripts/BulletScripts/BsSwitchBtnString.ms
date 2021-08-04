global dateTime = (dotNetClass "System.DateTime").Now
global arrDayWeek = #("日", "一", "二", "三", "四", "五", "六")
global fnSwitchBtnString

fn fnSwitchBtnString =
(
    local arrTime = (getLocalTime())
    local dayWeekID = (mod arrTime[3] 7) as integer
    case dayWeekID of 
    (
        (1):("安如磐石")
        (2):("固若金汤")
        (3):("俱收并蓄")
        (4):("天动万象")
        (5):("靖妖傩舞")
        (6):("天理长驱")
        (7):("桂花载酒")
        default:("天动万象")
    )
)