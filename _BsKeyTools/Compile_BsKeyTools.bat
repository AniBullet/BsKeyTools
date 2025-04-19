@echo off
chcp 65001
setlocal enabledelayedexpansion

echo 正在查找NSIS编译器...

:: 首先尝试从注册表获取NSIS安装路径（这是最准确的方法）
set "NSIS_FOUND=0"

:: 检查64位注册表
reg query "HKLM\SOFTWARE\NSIS" /ve 2>nul | find "REG_SZ" > nul
if not errorlevel 1 (
    for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\NSIS" /ve 2^>nul ^| find "REG_SZ"') do (
        set "NSIS_REG=%%b"
        if exist "!NSIS_REG!\makensis.exe" (
            set "NSIS_EXE=!NSIS_REG!\makensis.exe"
            echo 从64位注册表找到NSIS编译器: "!NSIS_EXE!"
            set "NSIS_FOUND=1"
            goto :found_nsis
        )
    )
)

:: 检查32位注册表
reg query "HKLM\SOFTWARE\Wow6432Node\NSIS" /ve 2>nul | find "REG_SZ" > nul
if not errorlevel 1 (
    for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Wow6432Node\NSIS" /ve 2^>nul ^| find "REG_SZ"') do (
        set "NSIS_REG=%%b"
        if exist "!NSIS_REG!\makensis.exe" (
            set "NSIS_EXE=!NSIS_REG!\makensis.exe"
            echo 从32位注册表找到NSIS编译器: "!NSIS_EXE!"
            set "NSIS_FOUND=1"
            goto :found_nsis
        )
    )
)

:: 检查其他可能的注册表位置
for %%k in (
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\NSIS"
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\NSIS_is1"
    "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\NSIS"
    "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\NSIS_is1"
) do (
    reg query %%k /v "InstallLocation" 2>nul | find "REG_SZ" > nul
    if not errorlevel 1 (
        for /f "tokens=2*" %%a in ('reg query %%k /v "InstallLocation" 2^>nul ^| find "REG_SZ"') do (
            set "NSIS_REG=%%b"
            if exist "!NSIS_REG!\makensis.exe" (
                set "NSIS_EXE=!NSIS_REG!\makensis.exe"
                echo 从卸载信息注册表找到NSIS编译器: "!NSIS_EXE!"
                set "NSIS_FOUND=1"
                goto :found_nsis
            )
        )
    )
)

:: 如果注册表没找到，尝试在PATH中查找
for /f "tokens=*" %%a in ('where makensis 2^>nul') do (
    set "NSIS_EXE=%%a"
    echo 在系统PATH中找到NSIS编译器: "!NSIS_EXE!"
    set "NSIS_FOUND=1"
    goto :found_nsis
)

:: 如果上述方法都没找到，尝试常见安装路径
echo 在注册表和PATH中未找到NSIS，尝试在常见位置搜索...

:: 尝试常见的NSIS安装路径
set "NSIS_PATHS="
set "NSIS_PATHS=!NSIS_PATHS! C:\Program Files\NSIS"
set "NSIS_PATHS=!NSIS_PATHS! C:\Program Files (x86)\NSIS"
set "NSIS_PATHS=!NSIS_PATHS! D:\Program Files\NSIS"
set "NSIS_PATHS=!NSIS_PATHS! D:\Program Files (x86)\NSIS"

:: 尝试附加不同驱动器的可能路径
for %%d in (C D E F G) do (
    set "NSIS_PATHS=!NSIS_PATHS! %%d:\NSIS"
)

echo 正在搜索常见路径中的NSIS编译器...

for %%p in (!NSIS_PATHS!) do (
    echo 检查路径: %%p
    if exist "%%p\makensis.exe" (
        set "NSIS_EXE=%%p\makensis.exe"
        echo 在常见路径中找到NSIS编译器: "!NSIS_EXE!"
        set "NSIS_FOUND=1"
        goto :found_nsis
    )
)

:: 查找子目录中可能包含版本号的NSIS安装（这部分有点复杂，简化处理）
echo 搜索其他可能的NSIS安装路径...
for %%d in (C D E F G) do (
    if exist "%%d:\" (
        if exist "%%d:\Program Files\NSIS" (
            if exist "%%d:\Program Files\NSIS\makensis.exe" (
                set "NSIS_EXE=%%d:\Program Files\NSIS\makensis.exe"
                echo 找到NSIS编译器: "!NSIS_EXE!"
                set "NSIS_FOUND=1"
                goto :found_nsis
            )
        )
        if exist "%%d:\Program Files (x86)\NSIS" (
            if exist "%%d:\Program Files (x86)\NSIS\makensis.exe" (
                set "NSIS_EXE=%%d:\Program Files (x86)\NSIS\makensis.exe"
                echo 找到NSIS编译器: "!NSIS_EXE!"
                set "NSIS_FOUND=1"
                goto :found_nsis
            )
        )
    )
)

:: 如果还是没找到，提示用户手动输入
if "%NSIS_FOUND%"=="0" (
    echo 未找到NSIS编译器！
    echo 请手动指定NSIS编译器的路径:
    set /p NSIS_PATH="输入NSIS安装路径 (例如 C:\Program Files\NSIS): "
    if exist "!NSIS_PATH!\makensis.exe" (
        set "NSIS_EXE=!NSIS_PATH!\makensis.exe"
        set "NSIS_FOUND=1"
        goto :found_nsis
    ) else (
        echo 指定路径下未找到makensis.exe，编译失败！
        goto :end
    )
)

:found_nsis
echo.
echo 开始编译 Setup_BsKeyTools.nsi...
echo.

:: 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

:: 编译NSIS脚本
"%NSIS_EXE%" /V2 "Setup_BsKeyTools.nsi"

if %errorlevel% equ 0 (
    echo.
    echo 编译成功！
) else (
    echo.
    echo 编译失败，错误代码: %errorlevel%
)

:end
echo.
echo 按任意键退出...
pause > nul 