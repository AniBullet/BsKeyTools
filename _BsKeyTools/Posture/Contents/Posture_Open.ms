-- Posture 版本适配脚本
-- 根据当前3ds Max版本加载对应的脚本文件

fn loadAppropriatePostureScript = 
(
    -- 获取当前Max版本（取两位数字）
    local maxVerNum = ((maxVersion())[1] / 1000)
    local scriptPath = "C:\\ProgramData\\Autodesk\\ApplicationPlugins\\Posture\\Contents\\"
    local scriptFile = ""
    
    -- 根据版本选择适当的脚本文件
    if maxVerNum >= 28 then
        scriptFile = scriptPath + "2026\\" + "Posture.py"
    else if maxVerNum == 27 then
        scriptFile = scriptPath + "2025\\" + "Posture.py"
    else if maxVerNum >= 23 and maxVerNum <= 26 then
        scriptFile = scriptPath + "2021\\" + "Posture.py"
    else if maxVerNum >= 20 and maxVerNum <= 22 then
        scriptFile = scriptPath + "2020\\" + "Posture.py"
    else
    (
        messageBox "当前3ds Max版本不受Posture支持。\n支持的版本范围: 2018-2026" title:"Posture 版本错误"
        return false
    )
    
    -- 构建脚本路径并执行
    if doesFileExist scriptFile then
    (
        -- print ("加载脚本文件: " + scriptFile)
        python.ExecuteFile(scriptFile)
        return true
    )
    else
    (
        messageBox ("无法找到脚本文件: " + scriptFile) title:"Posture 错误"
        return false
    )
)

-- 执行版本检查和脚本加载
loadAppropriatePostureScript()