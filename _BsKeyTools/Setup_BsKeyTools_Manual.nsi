; 此脚本使用 HM VNISEdit 脚本编辑器向导生成

; 添加Unicode支持
Unicode true

; 安装程序初始定义常量
!define PRODUCT_NAME "BsKeyTools"
!define PRODUCT_VERSION "_v1.1.0"
!define PRODUCT_PUBLISHER "Bullet.S"
!define PRODUCT_WEB_SITE "anibullet.com"

; 定义变量
var MAXPATH ; 3dsMax安装路径

SetCompressor lzma

; ------ MUI 现代界面定义 (1.67 版本以上兼容) ------
!include "MUI2.nsh"
!include "LogicLib.nsh" ; 引入逻辑库
!include "Sections.nsh" ; 引入Sections库
!include "FileFunc.nsh" ; 引入文件功能库

; MUI 预定义常量
!define MUI_ABORTWARNING
!define MUI_ICON ".\max.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP ".\sideImg.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP ".\logo.bmp"

; 欢迎页面
!insertmacro MUI_PAGE_WELCOME
!define MUI_TEXT_WELCOME_INFO_TITLE "欢迎安装 ${PRODUCT_NAME}${PRODUCT_VERSION}"
!define MUI_TEXT_WELCOME_INFO_TEXT "此程序将引导你完成 $(^NameDA) 的安装。$\r$\n$\r$\n在安装之前，建议先关闭所有 3dsMax 程序。$\r$\n$\r$\n这将确保安装程序能够更新所需的文件，$\r$\n$\r$\n从而避免在安装后打开工具失败报错。$\r$\n$\r$\n$_CLICK"
; 许可协议页
!define MUI_INNERTEXT_LICENSE_TOP "要阅读协议的其余部分，请按键盘 [PgDn] 键向下翻页。"
!define MUI_INNERTEXT_LICENSE_BOTTOM "如果你接受许可证的条款，请点击 [我接受(I)] 继续安装。$\r$\n$\r$\n你必须在同意后才能安装 $(^NameDA) 。"
; 定义当前脚本所在目录上级的路径
!define PARENT_DIR ".."
; 定义当前脚本所在目录的路径
!define CURRENT_DIR "."
!insertmacro MUI_PAGE_LICENSE "${PARENT_DIR}\LICENSE"

; 自定义Max路径指定页面
Page custom CustomPathPage CustomPathLeave

; 安装过程页面
!insertmacro MUI_PAGE_INSTFILES
; 安装完成页面
!define MUI_TEXT_FINISH_INFO_TEXT "$(^NameDA) 已经成功安装到本机。$\r$\n$\r$\n点击 [完成(F)] 关闭安装程序。"
!define MUI_FINISHPAGE_SHOWREADME
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION Info
!define MUI_FINISHPAGE_SHOWREADME_TEXT "查看帮助视频"
!define MUI_FINISHPAGE_LINK "Github"
!define MUI_FINISHPAGE_LINK_LOCATION "https://github.com/AniBullet/BsKeyTools"
!define MUI_FINISHPAGE_LINK_COLOR "872657"

!insertmacro MUI_PAGE_FINISH
Function Info
ExecShell "open" "https://space.bilibili.com/2031113/lists/560782"
Functionend

; 安装界面包含的语言设置
!insertmacro MUI_LANGUAGE "SimpChinese"
;!insertmacro MUI_LANGUAGE "English"

; 自定义函数
Function CustomPathPage
  ; 显示自定义页面
  !insertmacro MUI_HEADER_TEXT "3dsMax 路径设置" "请指定3dsMax安装路径。"
  
  ; 创建一个对话框
  nsDialogs::Create 1018
  Pop $0
  
  ; 添加标签和输入框 - 3dsMax路径
  ${NSD_CreateLabel} 10 10 100 20 "3dsMax 安装路径:"
  Pop $0
  ${NSD_CreateDirRequest} 120 10 250 20 $MAXPATH
  Pop $R0
  ${NSD_CreateBrowseButton} 380 10 50 20 "浏览..."
  Pop $0
  ${NSD_OnClick} $0 BrowseMaxPath
  
  ; 添加说明标签
  ${NSD_CreateLabel} 10 40 370 40 "请指定3dsMax安装路径。$\r$\n$\r$\n通常路径为类似：C:\Program Files\Autodesk\3ds Max 20XX"
  Pop $0
  
  nsDialogs::Show
FunctionEnd

Function BrowseMaxPath
  ${NSD_GetText} $R0 $0
  nsDialogs::SelectFolderDialog "选择3dsMax安装目录" $0
  Pop $0
  ${If} $0 != error
    ${NSD_SetText} $R0 $0
  ${EndIf}
FunctionEnd

Function CustomPathLeave
  ; 获取输入框的值
  ${NSD_GetText} $R0 $MAXPATH
  
  ; 检查路径是否有效
  ${If} $MAXPATH == ""
    MessageBox MB_ICONEXCLAMATION|MB_OK "请指定3dsMax安装路径。"
    Abort
  ${EndIf}
FunctionEnd

; ------ MUI 现代界面定义结束 ------

Name "${PRODUCT_NAME}${PRODUCT_VERSION}"
OutFile "_BsKeyTools_Manual.exe"
ShowInstDetails show
ShowUnInstDetails show

; 安装部分
Section "安装 BsKeyTools" SEC01
  SetOutPath "$MAXPATH"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts"
  File /r "${CURRENT_DIR}\UI_ln"
  
  ; 检查版本号
  ${GetFileName} $MAXPATH $R0
  ${If} $R0 == "3ds Max 9"
    File /r "${CURRENT_DIR}\GhostTrails\9\plugins"
  ${ElseIf} $R0 == "3ds Max 2008"
    File /r "${CURRENT_DIR}\GhostTrails\2008\plugins"
  ${ElseIf} $R0 == "3ds Max 2009"
    File /r "${CURRENT_DIR}\GhostTrails\2009\plugins"
  ${ElseIf} $R0 == "3ds Max 2010"
    File /r "${CURRENT_DIR}\GhostTrails\2010\plugins"
  ${ElseIf} $R0 == "3ds Max 2011"
    File /r "${CURRENT_DIR}\GhostTrails\2011\plugins"
  ${ElseIf} $R0 == "3ds Max 2012"
    File /r "${CURRENT_DIR}\GhostTrails\2012\plugins"
  ${ElseIf} $R0 == "3ds Max 2013"
    File /r "${CURRENT_DIR}\GhostTrails\2013\plugins"
  ${ElseIf} $R0 == "3ds Max 2014"
    File /r "${CURRENT_DIR}\GhostTrails\2014\plugins"
  ${ElseIf} $R0 == "3ds Max 2015"
    File /r "${CURRENT_DIR}\GhostTrails\2015\plugins"
  ${ElseIf} $R0 == "3ds Max 2016"
    File /r "${CURRENT_DIR}\GhostTrails\2016\plugins"
  ${ElseIf} $R0 == "3ds Max 2017"
    File /r "${CURRENT_DIR}\GhostTrails\2017\plugins"
  ${ElseIf} $R0 == "3ds Max 2018"
    File /r "${CURRENT_DIR}\GhostTrails\2018\plugins"
  ${ElseIf} $R0 == "3ds Max 2019"
    File /r "${CURRENT_DIR}\GhostTrails\2019\plugins"
  ${ElseIf} $R0 == "3ds Max 2020"
    File /r "${CURRENT_DIR}\GhostTrails\2020\plugins"
  ${ElseIf} $R0 == "3ds Max 2021"
    File /r "${CURRENT_DIR}\GhostTrails\2021\plugins"
  ${ElseIf} $R0 == "3ds Max 2022"
    File /r "${CURRENT_DIR}\GhostTrails\2022\plugins"
  ${ElseIf} $R0 == "3ds Max 2023"
    File /r "${CURRENT_DIR}\GhostTrails\2023\plugins"
  ${ElseIf} $R0 == "3ds Max 2024"
    File /r "${CURRENT_DIR}\GhostTrails\2024\plugins"
  ${ElseIf} $R0 == "3ds Max 2025"
    File /r "${CURRENT_DIR}\GhostTrails\2025\plugins"
  ${ElseIf} $R0 == "3ds Max 2026"
    File /r "${CURRENT_DIR}\GhostTrails\2026\plugins"
  ${Else}
    ; 如果无法识别版本，使用最新版本的插件
    MessageBox MB_ICONINFORMATION|MB_OK "无法自动识别3dsMax版本，将使用最新版本插件。"
    File /r "${CURRENT_DIR}\GhostTrails\2026\plugins"
  ${EndIf}
SectionEnd

Function .onInit
!insertmacro MUI_LANGDLL_DISPLAY

; 检查 3dsmax.exe 是否已运行
nsProcess::_FindProcess "3dsmax.exe"
Pop $R0
${If} $R0 = 0
  MessageBox MB_ICONEXCLAMATION|MB_OK "BsKeyTools 安装程序检测到 3dsmax.exe 正在运行中！$\n$\n安装可能会导致程序异常，请先关闭 3dsMax 再次打开本安装程序。$\n$\n如果不是在你打开的情况下，那么可能是莫名工作进程，请手动结束一下进程~"
${EndIf}

; 初始化路径变量
StrCpy $MAXPATH ""

FunctionEnd 