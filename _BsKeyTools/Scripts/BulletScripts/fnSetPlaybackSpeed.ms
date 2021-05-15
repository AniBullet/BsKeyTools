/*
 * @Description: 修改动画播放速率
 * @Author: Bullet.S
 * @Date: 2019-10-09 13:10:54
 * @LastEditors: Bullet.S
 * @LastEditTime: 2019-10-09 19:45:07
 * @Email: animator.bullet@foxmail.com
 */

Global valuePlaySpeed = ""

fn judgePlaySpeedValue =
(
    case of
    (
        (timeConfiguration.playbackSpeed == 1):(valuePlaySpeed = "--1/4x--")
        (timeConfiguration.playbackSpeed == 2):(valuePlaySpeed = "--1/2x--")
        (timeConfiguration.playbackSpeed == 3):(valuePlaySpeed = "-- 1x --")
        (timeConfiguration.playbackSpeed == 4):(valuePlaySpeed = "-- 2x --")
        (timeConfiguration.playbackSpeed == 5):(valuePlaySpeed = "-- 4x --")
    )
)

fn fnSetSpeed numSpeed =
(
    timeConfiguration.playbackSpeed = numSpeed
    judgePlaySpeedValue ()
)
