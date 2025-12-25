/*
    BakeAnimation - 烘焙动画
    Author: Bullet.S
*/

try (
    if selection.count == 0 then (
        messageBox "请先选择对象" title:"BakeAnimation"
    ) else (
        startFrame = animationRange.start as integer
        endFrame = animationRange.end as integer
        
        if queryBox ("将在帧 " + startFrame as string + " 到 " + endFrame as string + " 范围内烘焙动画，继续？") title:"BakeAnimation" then (
            for obj in selection do (
                for t = startFrame to endFrame do (
                    at time t (
                        with animate on (
                            obj.transform = obj.transform
                        )
                    )
                )
            )
            format "已烘焙 % 个对象的动画\n" selection.count
            messageBox "动画烘焙完成" title:"BakeAnimation"
        )
    )
) catch (
    messageBox ("错误: " + (getCurrentException())) title:"BakeAnimation"
)

