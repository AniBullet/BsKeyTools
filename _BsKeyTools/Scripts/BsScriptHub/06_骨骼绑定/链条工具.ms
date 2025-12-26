/*
 * BsScriptHub Wrapper
 * 脚本名称: 链条工具
 * 原始位置: Quote/ChainsTools.ms
 */
(
    local scriptPath = (getDir #scripts) + "\\BulletScripts\\Quote\\ChainsTools.ms"
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
