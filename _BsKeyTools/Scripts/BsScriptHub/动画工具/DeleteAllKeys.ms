/*
    DeleteAllKeys - 删除所有关键帧
    Author: Bullet.S
*/

try (
    if selection.count == 0 then (
        messageBox "请先选择对象" title:"DeleteAllKeys"
    ) else (
        if queryBox "确定要删除选中对象的所有关键帧吗？" title:"DeleteAllKeys" then (
            for obj in selection do (
                deleteKeys obj #allKeys
            )
            format "已删除 % 个对象的关键帧\n" selection.count
            messageBox "关键帧已删除" title:"DeleteAllKeys"
        )
    )
) catch (
    messageBox ("错误: " + (getCurrentException())) title:"DeleteAllKeys"
)

