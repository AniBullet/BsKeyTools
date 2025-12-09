/*
* @Description: 时光机 v2.0 启动器 - Python版本启动脚本
* @Author: Bullet.S
* @Date: 2024-12-09
* @Email: animator.bullet@foxmail.com
* @Version: 2.0
* @Compatibility: 3ds Max 2020-2026 (Python 3 + PySide2/PySide6)
*
* Python/Qt 版本支持说明:
*   - 3ds Max 2020-2023: Python 3 + PySide2 (Qt5) -> BsOpenToolsPy_PySide2.py
*   - 3ds Max 2024-2026: Python 3 + PySide6 (Qt6) -> BsOpenToolsPy_PySide6.py
*
* 注意: 3ds Max 2017-2019 使用Python 2，建议使用原版MAXScript工具
*/

-- 获取Max版本号 (2020=22, 2024=26 等)
fn fnGetMaxYear =
(
    local maxVer = (maxVersion())[1] / 1000
    return maxVer
)

-- 检查Max版本是否支持Python 3 + PySide
fn fnCheckPythonSupport =
(
    local maxVer = fnGetMaxYear()
    
    -- Max 2020 (版本号22) 开始使用Python 3 + PySide2
    if maxVer < 22 then
    (
        messageBox "3ds Max 2020以下版本不支持此Python工具！\n\n当前Max版本号: " + (maxVer as string) + "\n\n建议:\n• 升级到3ds Max 2020或更高版本\n• 或右键使用原版MAXScript工具 (BsOpenTools.ms)" title:"版本不支持" beep:false
        return false
    )
    return true
)

-- 根据Max版本获取对应的Python脚本路径
fn fnGetPythonScriptPath =
(
    local scriptsDir = (getDir #scripts)
    local maxVer = fnGetMaxYear()
    local pyFileName = ""
    
    -- Max 2025+ (版本号27+) 使用PySide6
    -- Max 2025=27, 2026=28
    if maxVer >= 27 then
    (
        pyFileName = "BsOpenToolsPy_PySide6.py"
    )
    -- Max 2020-2024 (版本号22-26) 使用PySide2
    else
    (
        pyFileName = "BsOpenToolsPy_PySide2.py"
    )
    
    local pyPath = scriptsDir + "\\BulletScripts\\" + pyFileName
    format "[BsOpenTools] 选择脚本: % (maxVer=%)\n" pyFileName maxVer
    return pyPath
)

-- 清除Python缓存
fn fnClearPythonCache =
(
    local scriptsDir = (getDir #scripts)
    local cacheDir = scriptsDir + "\\BulletScripts\\__pycache__"
    
    -- 尝试删除__pycache__目录
    if doesDirectoryExist cacheDir then
    (
        try
        (
            local files = getFiles (cacheDir + "\\*.*")
            for f in files do deleteFile f
            format "[BsOpenTools] 已清除Python缓存: %\n" cacheDir
        )
        catch()
    )
)

-- 启动Python版本时光机
fn fnLaunchBsOpenToolsPy =
(
    if not (fnCheckPythonSupport()) then return undefined
    
    -- 先清除可能的缓存
    fnClearPythonCache()
    
    local pyPath = fnGetPythonScriptPath()
    local maxVer = fnGetMaxYear()
    
    format "[BsOpenTools] Max版本号: %\n" maxVer
    format "[BsOpenTools] 加载脚本: %\n" pyPath
    format "[BsOpenTools] Python版本: %\n" (python.Execute "import sys; print(sys.version)" as string)
    
    if doesFileExist pyPath then
    (
        try
        (
            -- 方法1: 使用importlib动态导入模块 (强制重新加载)
            local pyCode = "
import sys
import importlib.util
import gc

_bs_module_path = r'" + pyPath + "'
_bs_module_name = 'BsOpenToolsPy_Runtime'

# 清理旧模块引用
for _mod_name in list(sys.modules.keys()):
    if 'BsOpenTools' in _mod_name:
        del sys.modules[_mod_name]
gc.collect()

# 动态加载模块
_bs_spec = importlib.util.spec_from_file_location(_bs_module_name, _bs_module_path)
_bs_module = importlib.util.module_from_spec(_bs_spec)
sys.modules[_bs_module_name] = _bs_module
_bs_spec.loader.exec_module(_bs_module)

# 调用显示窗口函数
_bs_module.show_window()
"
            python.Execute pyCode
        )
        catch
        (
            local errMsg = getCurrentException()
            messageBox ("启动Python时光机失败！\n\n错误信息:\n" + errMsg + "\n\n脚本路径:\n" + pyPath + "\n\n建议：\n1. 删除 __pycache__ 文件夹\n2. 重启3ds Max后重试") title:"错误" beep:false
        )
    )
    else
    (
        messageBox ("找不到Python脚本文件！\n\n期望路径:\n" + pyPath + "\n\n请确保脚本安装完整。") title:"文件不存在" beep:false
    )
)

-- 执行启动
fnLaunchBsOpenToolsPy()

-- 注册宏脚本
macroScript BsOpenToolsPy
category:"_[BulletTools]"
buttonText:"时光机Py"
toolTip:"时光机 v2.0 (Python版)\n支持Max 2020-2026"
-- Icon:#("Systems",2)
(
    on execute do
    (
        fileIn ((getDir #Scripts) + @"\\BulletScripts\\BsOpenToolsPy.ms")
    )
)

