try(destroydialog rolBsTimeCost)catch()

global dateTime = (dotNetClass "System.DateTime").Now
global bsInitTime = ((dateTime.day * 86400) + (dateTime.Hour * 3600) + (dateTime.Minute * 60) + (dateTime.Second))
global dayTimeString = ""

fn fnGetTimeCost =
(
    local timeNow = (dotNetClass "System.DateTime").Now
    local bsSecondTime = (timeNow.day * 86400) + (timeNow.Hour * 3600) + (timeNow.Minute * 60) + (timeNow.Second)
    local bsTimeCost = (bsSecondTime - bsInitTime)

    return ("本次已运行： " + ((bsTimeCost/86400) as integer) as string + " 天 " + 
    ((((mod bsTimeCost 86400) as integer)/3600) as integer) as string + " 小时 " + 
    ((((mod ((mod bsTimeCost 86400) as integer) 3600) as integer)/60) as integer) as string + " 分钟 " + 
    ((mod ((mod ((mod ((mod bsTimeCost 86400) as integer) 3600) as integer) 60) as integer) 60) as integer) as string + " 秒钟")
)

rollout rolBsTimeCost "BsTimeCost"
(
    timer timerCost interval:200 active:true

    on timerCost tick do (dayTimeString = fnGetTimeCost())
)
createdialog rolBsTimeCost 0 0 style:#() pos:[999999,999999]