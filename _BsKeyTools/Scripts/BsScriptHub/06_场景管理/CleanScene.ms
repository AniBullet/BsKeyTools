/*
    CleanScene - 场景清理
    Author: Bullet.S
*/

try (
    cleanCount = 0
    
    -- 删除空的 Dummy 和 Point
    emptyHelpers = for o in helpers where o.children.count == 0 collect o
    for h in emptyHelpers do (
        try (delete h; cleanCount += 1) catch ()
    )
    
    -- 删除隐藏的空组
    for o in objects where isGroupHead o and o.children.count == 0 do (
        try (delete o; cleanCount += 1) catch ()
    )
    
    gc()
    
    info = "清理完成!\n已删除 " + cleanCount as string + " 个无用对象"
    format "%\n" info
    messageBox info title:"CleanScene"
) catch (
    messageBox ("错误: " + (getCurrentException())) title:"CleanScene"
)

