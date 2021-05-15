/*
 * @Description: 
 * @Author: Bullet.S
 * @Date: 2019-10-09 21:29:04
 * @LastEditors: Bullet.S
 * @LastEditTime: 2021-01-09 22:50:04
 * @Email: animator.bullet@foxmail.com
 */


Global arrKeysTime = #()
Global arrLinkKeys = #()
Global keyFirst
Global keyEnd
Global fnAddKyes
Global fnSelectKeys
Global fnSelLinkKeys

fn fnAddKyes tempObj Link:off =
(	
    local numObjSubs
    local numLinkSubs
    local tempSubAnim
    local tempController
    local tempLinkObj
    local tempLinkSubAnim
    local tempLinkController
    
    if tempObj.controller != undefined then
    (
        numObjSubs = tempObj.numSubs   ---------子动画数量
        for n = 1 to numObjSubs do 
        (
            tempSubAnim = GetSubAnim tempObj n
            if tempSubAnim != undefined then
            (
                tempController = tempSubAnim.Controller
                if (classof tempController != UndefinedClass) then
                (
                    if (classof tempObj != Biped_Object) then
                    (
                        if ((classof tempController != Link_Constraint) and (classof tempController != LinkTimeControl)) then
                        (
                            if tempController != undefined then 
                            (
                                if tempController.keys[1] != undefined then
                                (
                                    -- arrKeysTime += for i in tempController.keys collect i.time
                                    for i in tempController.keys do 
                                    (
                                        appendIfUnique arrKeysTime i.time
                                    )
-- 									print (n as string + ":" + arrKeysTime as string)
                                )
                            )
                        )
                        else
                        (
                            if Link == on then
                            (
                                tempLinkObj = tempController
                                if tempLinkObj != undefined then
                                (
                                    numLinkSubs = tempLinkObj.numSubs
                                    for n = 1 to numLinkSubs do
                                    (
                                        tempLinkSubAnim = GetSubAnim tempLinkObj n
                                        for n = 1 to numLinkSubs do
                                        (
                                            tempLinkSubAnim = GetSubAnim tempLinkObj n
                                            if (GetSubAnimName tempLinkObj n) == #Link_Times then
                                            (
                                                if tempLinkSubAnim.keys[1] != undefined then
                                                (
                                                    for i in tempLinkSubAnim.keys do 
                                                    (
                                                        appendIfUnique arrLinkKeys i
                                                    )
                                                )
                                            )
                                        )
                                        if tempLinkSubAnim.numSubs > 0 do (fnAddKyes tempLinkSubAnim)
                                    )
                                )
                            )
                            -- else 
                            -- (
                            -- 	print "Link:off"
                            -- )
                        )
                    )
                    else 
                    (
                        if tempObj.controller != undefined then 
                        (
                            if tempObj.controller.keys[1] != undefined then
                            (
                                -- arrKeysTime += for i in tempController.keys collect i.time
                                for i in tempObj.controller.keys do 
                                (
                                    append arrKeysTime i.time
                                )
-- 									print (n as string + ":" + arrKeysTime as string)
                            )
                        )
                    )
                )----------------上面收集非biped的正常帧和收集link帧, 下面收集biped帧
            )
            if tempSubAnim.numSubs > 0 do (fnAddKyes tempSubAnim)  ----子动画递归
        )
    )
)

fn fnCollectKeys = ---------收集关键帧
(
    arrKeysTime = #()
    arrBipedKeys = #() ----------------先清空数组
    arrLinkKeys = #()
    
    case of  -----------处理选中,未选中则处理全部
    (
        (selection.count == 0):
        (
            for i in objects do 
            (
                if rolloutBulletKeyTools.btnJudgeLinkKey.checked == false then fnAddKyes i
                else fnAddKyes i link:on
            )
        )
        default:(
            for i in selection do 
            (
                if rolloutBulletKeyTools.btnJudgeLinkKey.checked == false then fnAddKyes i
                else fnAddKyes i link:on
            )
        )
    )
    -- arrKeysTime = makeUniqueArray arrKeysTime  ---去除重复帧数
    sort arrKeysTime  ----帧数排序
    if ((arrKeysTime.count != 0) and (arrKeysTime.count > 1)) then
    (
        keyFirst = arrKeysTime[1]            ------找到首帧
        keyEnd = arrKeysTime[arrKeysTime.count]   -----------找到尾帧
    )
    else
    (
        if (arrKeysTime.count == 1) then
        (
            keyFirst = arrKeysTime[1]
            keyEnd = keyFirst + 1
        )
    )
)

fn fnChangeedtSliderTime =   ------------关键帧数字随滑条改变
(
    edtSliderTime.text = slidertime as string
)

fn fnSelLinkKeys keyBegin KeyEnd symbol =  ---------------选择link帧方法
(
    if arrLinkKeys.count != 0 then
    (
        for i in arrLinkKeys do   -------link帧选中
        (
            i.selected = false ---先取消之前link帧选中状态
            case of  -------------判断link帧位置,数字是随便取的方便判断情况
            (
                (symbol == 0):(if i.time <= KeyEnd then i.selected = true)
                (symbol == 1):(if i.time >= keyBegin then i.selected = true)
                (symbol == 2):(i.selected = true)
            )
        )
    )
)

fn fnSelKeys keyBegin KeyEnd symbol=  ---------------选择帧的方法
(
    fn fnSelectKeys keyBegin KeyEnd symbol =  -------因为有选中和没选择状态, 所以加一个方法精简下
    (
        deselectKeys $           --清除之前选中的关键帧
        if arrKeysTime.count != 0 then
        (
            selectkeys $ keyBegin KeyEnd  -------------选中正常帧
            fnSelLinkKeys keyBegin KeyEnd symbol --------------选中link帧
        )
        else
        (
            fnSelLinkKeys keyBegin KeyEnd symbol
        )
    )
    case of 
    (
        (selection.count == 0):  ----------判断是否有选中物体
        (
            select objects    ---没有选择物体则选择所有物体
            fnSelectKeys keyBegin KeyEnd symbol
        )
        default:  ----------------
        (
            fnSelectKeys keyBegin KeyEnd symbol
        )
    )
)

--------------------↓获取普通帧,Link帧不行↓-------------------------------------
fn getControllers obj ctrls:#() =
(
    for item in refs.dependsOn obj do   
    (
        if isController item AND item.keyable do
            append ctrls item

        getControllers item ctrls:ctrls
    )
    ctrls
)

fn getAllKeys obj =
(
    local objCtrlr = getControllers obj
    local allkeysArray = #()

    for ctrlr in objCtrlr do
    (
        keysArray = ctrlr.keys
    -- 	print keysArray
        for k in keysArray do appendIfUnique allkeysArray k.time
    )
    return (sort allkeysArray)
)
-------------------------------------------------------------