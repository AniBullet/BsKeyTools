/*
* @Description: BsScriptHub v1.0 启动器 - 远程脚本集合平台
* @Author: Bullet.S
* @Date: 2024-12-25
* @Email: animator.bullet@foxmail.com
* @Version: 1.0
* @Compatibility: 3ds Max 2020-2026 (Python 3 + PySide2/PySide6)
*
* 功能说明:
*   - 远程脚本仓库浏览与搜索
*   - 分类管理与关键词过滤
*   - 脚本预览与详细信息展示
*   - 一键运行或下载脚本
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
        messageBox ("3ds Max 2020以下版本不支持此Python工具！\n\n当前Max版本号: " + (maxVer as string) + "\n\n建议:\n• 升级到3ds Max 2020或更高版本") title:"版本不支持" beep:false
        return false
    )
    return true
)

-- 获取Python脚本路径
fn fnGetBsScriptHubPath =
(
    local scriptsDir = (getDir #scripts)
    local pyPath = scriptsDir + "\\BulletScripts\\BsScriptHub.py"
    return pyPath
)

-- 清除Python缓存
fn fnClearPythonCache =
(
    local scriptsDir = (getDir #scripts)
    local cacheDir = scriptsDir + "\\BulletScripts\\__pycache__"
    
    if doesDirectoryExist cacheDir then
    (
        try
        (
            local files = getFiles (cacheDir + "\\BsScriptHub*.pyc")
            for f in files do deleteFile f
            format "[BsScriptHub] 已清除Python缓存\n"
        )
        catch()
    )
)

-- 启动 BsScriptHub
fn fnLaunchBsScriptHub =
(
    if not (fnCheckPythonSupport()) then return undefined
    
    -- 先清除可能的缓存
    fnClearPythonCache()
    
    local pyPath = fnGetBsScriptHubPath()
    local maxVer = fnGetMaxYear()
    
    format "[BsScriptHub] Max版本号: %\n" maxVer
    format "[BsScriptHub] 加载脚本: %\n" pyPath
    
    if doesFileExist pyPath then
    (
        try
        (
            -- 单例模式：如果模块已加载，直接调用show_window；否则才加载模块
            local pyCode = "
import sys
import importlib.util

_bs_module_path = r'" + pyPath + "'
_bs_module_name = 'BsScriptHub_Runtime'

# 检查模块是否已加载
if _bs_module_name in sys.modules:
    # 模块已存在，直接调用
    sys.modules[_bs_module_name].show_window()
else:
    # 首次加载模块
    _bs_spec = importlib.util.spec_from_file_location(_bs_module_name, _bs_module_path)
    _bs_module = importlib.util.module_from_spec(_bs_spec)
    sys.modules[_bs_module_name] = _bs_module
    _bs_spec.loader.exec_module(_bs_module)
    _bs_module.show_window()
"
            python.Execute pyCode
        )
        catch
        (
            local errMsg = getCurrentException()
            messageBox ("启动 BsScriptHub 失败！\n\n错误信息:\n" + errMsg + "\n\n脚本路径:\n" + pyPath + "\n\n建议：\n1. 删除 __pycache__ 文件夹\n2. 重启3ds Max后重试") title:"错误" beep:false
        )
    )
    else
    (
        messageBox ("找不到 BsScriptHub.py 文件！\n\n期望路径:\n" + pyPath + "\n\n请确保脚本安装完整。") title:"文件不存在" beep:false
    )
)

-- 执行启动
fnLaunchBsScriptHub()

-- 注册宏脚本
macroScript BsScriptHub
category:"_[BulletTools]"
buttonText:"脚本仓库"
toolTip:"BsScriptHub v1.0\n远程脚本集合平台\n支持Max 2020-2026"
(
    on execute do
    (
        fileIn ((getDir #Scripts) + @"\\BulletScripts\\BsScriptHub.ms")
    )
)

