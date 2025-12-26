/*
 * BsScriptHub Wrapper
 * 脚本名称: 窗口句柄查看器
 * 原始位置: Quote/simple_hwnd_viewer.ms
 */
(
    local scriptPath = (getDir #scripts) + "\\BulletScripts\\Quote\\simple_hwnd_viewer.ms"
    if doesFileExist scriptPath then (
        try (
            fileIn scriptPath
        ) catch (
            messageBox ("执行脚本失败:\n" + (getCurrentException())) title:"BsScriptHub" beep:false
        )
    ) else (
        messageBox ("找不到脚本文件:\n" + scriptPath + "\n\n请确保 BsKeyTools 安装完整。") title:"BsScriptHub" beep:false
    )
)
