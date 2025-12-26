/*
    SelectByMaterial - 按材质选择
    Author: Bullet.S
*/

try (
    if selection.count != 1 then (
        messageBox "请先选择一个对象" title:"SelectByMaterial"
    ) else (
        targetMat = $.material
        if targetMat == undefined then (
            messageBox "选中对象没有材质" title:"SelectByMaterial"
        ) else (
            result = for o in objects where o.material == targetMat collect o
            select result
            format "找到 % 个使用相同材质的对象\n" result.count
        )
    )
) catch (
    messageBox ("错误: " + (getCurrentException())) title:"SelectByMaterial"
)

