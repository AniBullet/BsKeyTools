/*
    ExportSelectedFBX - 导出选中对象为FBX
    Author: Bullet.S
*/

try (
    if selection.count == 0 then (
        messageBox "请先选择要导出的对象" title:"ExportSelectedFBX"
    ) else (
        savePath = getSaveFileName caption:"导出FBX" types:"FBX文件(*.fbx)|*.fbx"
        if savePath != undefined then (
            exportFile savePath #noPrompt selectedOnly:true using:FBXEXP
            format "已导出到: %\n" savePath
            messageBox ("导出成功:\n" + savePath) title:"ExportSelectedFBX"
        )
    )
) catch (
    messageBox ("错误: " + (getCurrentException())) title:"ExportSelectedFBX"
)

