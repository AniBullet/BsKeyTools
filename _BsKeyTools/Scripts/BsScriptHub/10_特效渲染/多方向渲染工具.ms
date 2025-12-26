/*
 * BsScriptHub Wrapper
 * 脚本名称: 多方向渲染工具
 * 原始位置: Quote/多方向渲染工具（集成修改版）.ms
 */
(
    local scriptPath = (getDir #scripts) + "\\BulletScripts\\Quote\\多方向渲染工具（集成修改版）.ms"
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
