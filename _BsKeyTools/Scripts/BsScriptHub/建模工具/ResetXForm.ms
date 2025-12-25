/*
    ResetXForm - 批量重置变换
    Author: Bullet.S
*/

try (
    if selection.count == 0 then (
        messageBox "请先选择对象" title:"ResetXForm"
    ) else (
        undo on (
            for obj in selection where superClassOf obj == GeometryClass do (
                ResetXForm obj
                collapseStack obj
            )
        )
        format "已处理 % 个对象\n" selection.count
        messageBox ("已重置 " + selection.count as string + " 个对象的变换") title:"ResetXForm"
    )
) catch (
    messageBox ("错误: " + (getCurrentException())) title:"ResetXForm"
)

