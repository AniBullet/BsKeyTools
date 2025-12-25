/*
    CenterPivot - 轴心居中
    Author: Bullet.S
*/

try (
    if selection.count == 0 then (
        messageBox "请先选择对象" title:"CenterPivot"
    ) else (
        undo on (
            for obj in selection do (
                CenterPivot obj
            )
        )
        format "已将 % 个对象的轴心居中\n" selection.count
    )
) catch (
    messageBox ("错误: " + (getCurrentException())) title:"CenterPivot"
)

