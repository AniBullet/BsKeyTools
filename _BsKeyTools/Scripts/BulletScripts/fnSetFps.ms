/*
 * @Description: 设置帧率方法
 * @Author: Bullet.S
 * @Date: 2019-10-08 12:39:08
 * @LastEditors: Bullet.S
 * @LastEditTime: 2019-11-04 12:48:03
 * @Email: animator.bullet@foxmail.com
 */

Global valueFps
Global strCurrentFps = "当前帧率: " + framerate as string + " FPS"

rollout rolCustomFps ""
(
    edittext edtFpsValue "FPS: "  pos:[10,10] width:60 usePercentageWidth:true percentageWidth:44.0 labelOnTop:false text:"60" bold:true readOnly:false --帧率数值
    button btnSetFps "Set" pos:[80,8]
    label labTips strCurrentFps

    on rolCustomFps open do 
    (
        edtFpsValue.text = framerate as string
        labTips.text = "当前帧率: " + framerate as string + " FPS"
        valueFps = framerate as integer
    )

    on edtFpsValue entered val do 
    (
        if ((val != ".") and (val as integer != undefined) and (val != "") and (val as integer >= 0)) then
        (
            valueFps = (val as integer)
        )
        else messagebox "---------------------------\r\n请输入正确帧率数值\r\n"
    )
    on btnSetFps pressed do 
    (
        framerate = valueFps
        labTips.text = "当前帧率: " + framerate as string + " FPS"
        slidertime -= 1
		slidertime += 1
    )
)

fn fnSetFps numFps =
(
    framerate = numFps
    valueFps = numFps
    strCurrentFps = "当前帧率: " + framerate as string + " FPS"
    slidertime -= 1
    slidertime += 1
)