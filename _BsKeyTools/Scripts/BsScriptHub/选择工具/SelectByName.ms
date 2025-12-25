/*
    SelectByName - 按名称选择对象
    Author: Bullet.S
*/

try (
    keyword = ""
    keyword = (GetUIValue (dotNetObject "System.Windows.Forms.InputBox") "请输入名称关键词:" "按名称选择" "")
    if keyword == undefined or keyword == "" then (
        messageBox "已取消" title:"SelectByName"
    ) else (
        select (for o in objects where matchPattern o.name pattern:("*" + keyword + "*") collect o)
        format "已选择 % 个对象\n" selection.count
    )
) catch (
    messageBox ("错误: " + (getCurrentException())) title:"SelectByName"
)

