/*
    InvertSelection - 反转选择
    Author: Bullet.S
*/

try (
    oldSel = selection as array
    select objects
    for o in oldSel do deselect o
    format "反转选择完成，当前选中 % 个对象\n" selection.count
) catch (
    messageBox ("错误: " + (getCurrentException())) title:"InvertSelection"
)

