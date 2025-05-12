; 此脚本使用 HM VNISEdit 脚本编辑器向导生成

; 添加Unicode支持
Unicode true

; 安装程序初始定义常量
!define PRODUCT_NAME "BsKeyTools"
!define PRODUCT_VERSION "_v1.1.0"
!define PRODUCT_PUBLISHER "Bullet.S"
!define PRODUCT_WEB_SITE "anibullet.com"

; 自定义安装程序底部的文本
BrandingText "BsKeyTools 动画师 K 帧工具"

; 定义Section ID
!define SEC_MANUAL 0
!define SEC_2026 1
!define SEC_2025 2
!define SEC_2024 3
!define SEC_2023 4
!define SEC_2022 5
!define SEC_2021 6
!define SEC_2020 7
!define SEC_2019 8
!define SEC_2018 9
!define SEC_2017 10
!define SEC_2016 11
!define SEC_2015 12
!define SEC_2014 13
!define SEC_2013 14
!define SEC_2012 15
!define SEC_2011 16
!define SEC_2010 17
!define SEC_2009 18
!define SEC_2008 19
!define SEC_9 20

; 定义变量
var v9
var v2008
var v2009
var v2010
var v2011
var v2012
var v2013
var v2014
var v2015
var v2016
var v2017
var v2018
var v2019
var v2020
var v2021
var v2022
var v2023
var v2024
var v2025
var v2026

var InstallMode ; 安装模式: 0=自动检测, 1=手动选择
var MAXPATH ; 手动选择的3dsMax安装路径

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
; 许可协议页面
!define MUI_INNERTEXT_LICENSE_TOP "要阅读协议的其余部分，请按键盘 [PgDn] 键向下翻页。"
!define MUI_INNERTEXT_LICENSE_BOTTOM "如果你接受许可证的条款，请点击 [我接受(I)] 继续安装。$\r$\n$\r$\n你必须在同意后才能安装 $(^NameDA) 。"
; 定义当前脚本所在目录上级的路径
!define PARENT_DIR ".."
; 定义当前脚本所在目录的路径
!define CURRENT_DIR "."
!insertmacro MUI_PAGE_LICENSE "${PARENT_DIR}\LICENSE"

; 安装模式选择页面
Page custom InstallModePage InstallModeLeave

; 手动选择Max路径页面（条件显示）
Page custom CustomPathPage CustomPathLeave

; 组件选择页面（自动模式时显示）
!define MUI_TEXT_COMPONENTS_TITLE "选择版本"
!define MUI_TEXT_COMPONENTS_SUBTITLE "选择你想安装 $(^NameDA) 的 3dsMax 版本。"
!define MUI_INNERTEXT_COMPONENTS_DESCRIPTION_TITLE "安装路径"
!define MUI_INNERTEXT_COMPONENTS_DESCRIPTION_INFO "将光标悬停在版本名称之上，即可显示它的安装路径。"
ComponentText "请勾选你想安装到的版本，并取消勾选你不想安装的版本。 $\r$\n$\r$\n$_CLICK" "" "选定安装的版本: "
!insertmacro MUI_PAGE_COMPONENTS

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

; ------ MUI 现代界面定义结束 ------

; 自定义函数 - 安装模式选择页面
Function InstallModePage
  !insertmacro MUI_HEADER_TEXT "选择安装模式" "请选择自动检测安装路径或手动指定安装路径。"
  
  nsDialogs::Create 1018
  Pop $0
  
  ; 自动检测选项（默认选中）
  ${NSD_CreateRadioButton} 10 10 300 20 "自动检测 3dsMax 安装路径（推荐）"
  Pop $1
  ${NSD_Check} $1
  ${NSD_OnClick} $1 SetAutoMode
  
  ; 手动选择选项
  ${NSD_CreateRadioButton} 10 40 300 20 "手动指定 3dsMax 安装路径"
  Pop $2
  ${NSD_OnClick} $2 SetManualMode
  
  ; 添加说明标签
  ${NSD_CreateLabel} 20 70 350 100 "自动检测模式将查找已安装的所有3dsMax版本，$\r$\n$\r$\n并允许你选择要安装到的版本。$\r$\n$\r$\n手动模式允许你指定一个特定的3dsMax安装路径进行安装。$\r$\n$\r$\n如果自动检测失败，请使用此选项。"
  Pop $0
  
  ; 默认设置为自动模式
  StrCpy $InstallMode 0
  
  nsDialogs::Show
FunctionEnd

; 定义显示版本Section的宏
!macro ShowVersionSection SEC_ID VER_NAME
  ${If} $${VER_NAME} != ""
    SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
    SectionSetFlags ${SEC_ID} 1
  ${EndIf}
!macroend

Function SetAutoMode
  StrCpy $InstallMode 0
  
  ; 隐藏手动安装Section
  SectionSetText ${SEC_MANUAL} ""
  SectionSetFlags ${SEC_MANUAL} 0
  
  ; 恢复所有自动检测的版本
  DetailPrint "恢复显示自动检测到的版本"
  
  ; 使用宏显示所有已检测的版本
  !insertmacro ShowVersionSection ${SEC_2026} "2026"
  !insertmacro ShowVersionSection ${SEC_2025} "2025"
  !insertmacro ShowVersionSection ${SEC_2024} "2024"
  !insertmacro ShowVersionSection ${SEC_2023} "2023"
  !insertmacro ShowVersionSection ${SEC_2022} "2022"
  !insertmacro ShowVersionSection ${SEC_2021} "2021"
  !insertmacro ShowVersionSection ${SEC_2020} "2020"
  !insertmacro ShowVersionSection ${SEC_2019} "2019"
  !insertmacro ShowVersionSection ${SEC_2018} "2018"
  !insertmacro ShowVersionSection ${SEC_2017} "2017"
  !insertmacro ShowVersionSection ${SEC_2016} "2016"
  !insertmacro ShowVersionSection ${SEC_2015} "2015"
  !insertmacro ShowVersionSection ${SEC_2014} "2014"
  !insertmacro ShowVersionSection ${SEC_2013} "2013"
  !insertmacro ShowVersionSection ${SEC_2012} "2012"
  !insertmacro ShowVersionSection ${SEC_2011} "2011"
  !insertmacro ShowVersionSection ${SEC_2010} "2010"
  !insertmacro ShowVersionSection ${SEC_2009} "2009"
  !insertmacro ShowVersionSection ${SEC_2008} "2008"
  !insertmacro ShowVersionSection ${SEC_9} "9"
FunctionEnd

Function InstallModeLeave
  ; 不需要额外验证，只需使用选择的模式值
FunctionEnd

; 自定义函数 - 手动选择3dsMax路径页面
Function CustomPathPage
  ; 如果不是手动模式，跳过此页面
  ${If} $InstallMode != 1
    Abort
  ${EndIf}
  
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
  ; 如果不是手动模式，跳过验证
  ${If} $InstallMode != 1
    Return
  ${EndIf}
  
  ; 获取输入框的值
  ${NSD_GetText} $R0 $MAXPATH
  
  ; 检查路径是否有效
  ${If} $MAXPATH == ""
    MessageBox MB_ICONEXCLAMATION|MB_OK "请指定3dsMax安装路径。"
    Abort
  ${EndIf}
FunctionEnd

Name "${PRODUCT_NAME}${PRODUCT_VERSION}"
OutFile "_BsKeyTools.exe"
ShowInstDetails show
ShowUnInstDetails show

; 定义一个宏用于复制所有需要的文件
!macro CopyAllFiles DESTDIR VERSION
  ; 检查路径是否为空
  ${If} "${DESTDIR}" == ""
    MessageBox MB_ICONSTOP|MB_OK "错误：安装路径为空，无法复制文件到 ${VERSION} 版本。"
    DetailPrint "安装失败: 路径为空 - ${VERSION}"
    Abort "安装路径为空 - ${VERSION}"
  ${EndIf}
  
  DetailPrint "正在复制文件到: ${DESTDIR}"
  
  ; 设置输出目录
  SetOutPath "${DESTDIR}"
  SetOverwrite on
  
  ; 复制到Scripts目录
  CreateDirectory "${DESTDIR}\Scripts"
  SetOutPath "${DESTDIR}\Scripts"
  File /r "${CURRENT_DIR}\Scripts\*.*"
  
  ; 复制到UI_ln目录
  CreateDirectory "${DESTDIR}\UI_ln"
  SetOutPath "${DESTDIR}\UI_ln"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  
  ; 复制到plugins目录
  CreateDirectory "${DESTDIR}\plugins"
  SetOutPath "${DESTDIR}\plugins"
  ${If} ${VERSION} == "9"
    File /r "${CURRENT_DIR}\GhostTrails\9\plugins\*.*"
  ${Else}
    File /r "${CURRENT_DIR}\GhostTrails\${VERSION}\plugins\*.*"
  ${EndIf}
!macroend

Section "3dsMax 2026" ${SEC_2026}
  DetailPrint "检查安装路径: $v2026"
  ${If} $v2026 != ""
    !insertmacro CopyAllFiles "$v2026" "2026"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2026安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2026"
  ${EndIf}
SectionEnd

Section "3dsMax 2025" ${SEC_2025}
  DetailPrint "检查安装路径: $v2025"
  ${If} $v2025 != ""
    !insertmacro CopyAllFiles "$v2025" "2025"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2025安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2025"
  ${EndIf}
SectionEnd

Section "3dsMax 2024" ${SEC_2024}
  DetailPrint "检查安装路径: $v2024"
  ${If} $v2024 != ""
    !insertmacro CopyAllFiles "$v2024" "2024"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2024安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2024"
  ${EndIf}
SectionEnd

Section "3dsMax 2023" ${SEC_2023}
  DetailPrint "检查安装路径: $v2023"
  ${If} $v2023 != ""
    !insertmacro CopyAllFiles "$v2023" "2023"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2023安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2023"
  ${EndIf}
SectionEnd

Section "3dsMax 2022" ${SEC_2022}
  DetailPrint "检查安装路径: $v2022"
  ${If} $v2022 != ""
    !insertmacro CopyAllFiles "$v2022" "2022"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2022安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2022"
  ${EndIf}
SectionEnd

Section "3dsMax 2021" ${SEC_2021}
  DetailPrint "检查安装路径: $v2021"
  ${If} $v2021 != ""
    !insertmacro CopyAllFiles "$v2021" "2021"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2021安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2021"
  ${EndIf}
SectionEnd

Section "3dsMax 2020" ${SEC_2020}
  DetailPrint "检查安装路径: $v2020"
  ${If} $v2020 != ""
    !insertmacro CopyAllFiles "$v2020" "2020"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2020安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2020"
  ${EndIf}
SectionEnd

Section "3dsMax 2019" ${SEC_2019}
  DetailPrint "检查安装路径: $v2019"
  ${If} $v2019 != ""
    !insertmacro CopyAllFiles "$v2019" "2019"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2019安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2019"
  ${EndIf}
SectionEnd

Section "3dsMax 2018" ${SEC_2018}
  DetailPrint "检查安装路径: $v2018"
  ${If} $v2018 != ""
    !insertmacro CopyAllFiles "$v2018" "2018"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2018安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2018"
  ${EndIf}
SectionEnd

Section "3dsMax 2017" ${SEC_2017}
  DetailPrint "检查安装路径: $v2017"
  ${If} $v2017 != ""
    !insertmacro CopyAllFiles "$v2017" "2017"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2017安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2017"
  ${EndIf}
SectionEnd

Section "3dsMax 2016" ${SEC_2016}
  DetailPrint "检查安装路径: $v2016"
  ${If} $v2016 != ""
    !insertmacro CopyAllFiles "$v2016" "2016"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2016安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2016"
  ${EndIf}
SectionEnd

Section "3dsMax 2015" ${SEC_2015}
  DetailPrint "检查安装路径: $v2015"
  ${If} $v2015 != ""
    !insertmacro CopyAllFiles "$v2015" "2015"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2015安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2015"
  ${EndIf}
SectionEnd

Section "3dsMax 2014" ${SEC_2014}
  DetailPrint "检查安装路径: $v2014"
  ${If} $v2014 != ""
    !insertmacro CopyAllFiles "$v2014" "2014"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2014安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2014"
  ${EndIf}
SectionEnd

Section "3dsMax 2013" ${SEC_2013}
  DetailPrint "检查安装路径: $v2013"
  ${If} $v2013 != ""
    !insertmacro CopyAllFiles "$v2013" "2013"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2013安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2013"
  ${EndIf}
SectionEnd

Section "3dsMax 2012" ${SEC_2012}
  DetailPrint "检查安装路径: $v2012"
  ${If} $v2012 != ""
    !insertmacro CopyAllFiles "$v2012" "2012"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2012安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2012"
  ${EndIf}
SectionEnd

Section "3dsMax 2011" ${SEC_2011}
  DetailPrint "检查安装路径: $v2011"
  ${If} $v2011 != ""
    !insertmacro CopyAllFiles "$v2011" "2011"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2011安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2011"
  ${EndIf}
SectionEnd

Section "3dsMax 2010" ${SEC_2010}
  DetailPrint "检查安装路径: $v2010"
  ${If} $v2010 != ""
    !insertmacro CopyAllFiles "$v2010" "2010"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2010安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2010"
  ${EndIf}
SectionEnd

Section "3dsMax 2009" ${SEC_2009}
  DetailPrint "检查安装路径: $v2009"
  ${If} $v2009 != ""
    !insertmacro CopyAllFiles "$v2009" "2009"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2009安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2009"
  ${EndIf}
SectionEnd

Section "3dsMax 2008" ${SEC_2008}
  DetailPrint "检查安装路径: $v2008"
  ${If} $v2008 != ""
    !insertmacro CopyAllFiles "$v2008" "2008"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 2008安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 2008"
  ${EndIf}
SectionEnd

Section "3dsMax 9" ${SEC_9}
  DetailPrint "检查安装路径: $v9"
  ${If} $v9 != ""
    !insertmacro CopyAllFiles "$v9" "9"
  ${Else}
    MessageBox MB_ICONSTOP|MB_OK "错误：3dsMax 9安装路径为空，无法安装。"
    DetailPrint "安装失败: 无法安装到3dsMax 9"
  ${EndIf}
SectionEnd

; 手动安装Section
Section "手动安装" ${SEC_MANUAL}
  ; 调试信息
  DetailPrint "手动安装到: $MAXPATH"
  
  ; 检查路径是否为空
  ${If} $MAXPATH == ""
    MessageBox MB_ICONSTOP|MB_OK "错误：手动安装路径为空，无法完成安装。"
    Abort "手动安装路径为空"
  ${EndIf}
  
  ; 确保路径以反斜杠结尾
  StrCpy $R5 $MAXPATH "" -1
  ${If} $R5 != "\"
    StrCpy $MAXPATH "$MAXPATH\"
  ${EndIf}
  
  DetailPrint "处理后的安装路径: $MAXPATH"
  
  ; 检查版本号并使用对应版本插件
  ${GetFileName} $MAXPATH $R0
  DetailPrint "检测到的3dsMax版本: $R0"
  
  ${If} $R0 == "3ds Max 9"
    !insertmacro CopyAllFiles "$MAXPATH" "9"
  ${ElseIf} $R0 == "3ds Max 2008"
    !insertmacro CopyAllFiles "$MAXPATH" "2008"
  ${ElseIf} $R0 == "3ds Max 2009"
    !insertmacro CopyAllFiles "$MAXPATH" "2009"
  ${ElseIf} $R0 == "3ds Max 2010"
    !insertmacro CopyAllFiles "$MAXPATH" "2010"
  ${ElseIf} $R0 == "3ds Max 2011"
    !insertmacro CopyAllFiles "$MAXPATH" "2011"
  ${ElseIf} $R0 == "3ds Max 2012"
    !insertmacro CopyAllFiles "$MAXPATH" "2012"
  ${ElseIf} $R0 == "3ds Max 2013"
    !insertmacro CopyAllFiles "$MAXPATH" "2013"
  ${ElseIf} $R0 == "3ds Max 2014"
    !insertmacro CopyAllFiles "$MAXPATH" "2014"
  ${ElseIf} $R0 == "3ds Max 2015"
    !insertmacro CopyAllFiles "$MAXPATH" "2015"
  ${ElseIf} $R0 == "3ds Max 2016"
    !insertmacro CopyAllFiles "$MAXPATH" "2016"
  ${ElseIf} $R0 == "3ds Max 2017"
    !insertmacro CopyAllFiles "$MAXPATH" "2017"
  ${ElseIf} $R0 == "3ds Max 2018"
    !insertmacro CopyAllFiles "$MAXPATH" "2018"
  ${ElseIf} $R0 == "3ds Max 2019"
    !insertmacro CopyAllFiles "$MAXPATH" "2019"
  ${ElseIf} $R0 == "3ds Max 2020"
    !insertmacro CopyAllFiles "$MAXPATH" "2020"
  ${ElseIf} $R0 == "3ds Max 2021"
    !insertmacro CopyAllFiles "$MAXPATH" "2021"
  ${ElseIf} $R0 == "3ds Max 2022"
    !insertmacro CopyAllFiles "$MAXPATH" "2022"
  ${ElseIf} $R0 == "3ds Max 2023"
    !insertmacro CopyAllFiles "$MAXPATH" "2023"
  ${ElseIf} $R0 == "3ds Max 2024"
    !insertmacro CopyAllFiles "$MAXPATH" "2024"
  ${ElseIf} $R0 == "3ds Max 2025"
    !insertmacro CopyAllFiles "$MAXPATH" "2025"
  ${ElseIf} $R0 == "3ds Max 2026"
    !insertmacro CopyAllFiles "$MAXPATH" "2026"
  ${Else}
    ; 如果无法识别版本，使用最新版本的插件
    MessageBox MB_ICONINFORMATION|MB_OK "无法自动识别3dsMax版本，将使用最新版本插件。"
    !insertmacro CopyAllFiles "$MAXPATH" "2026"
  ${EndIf}
SectionEnd

; 定义隐藏版本Section的宏
!macro HideVersionSection SEC_ID
  SectionSetText ${SEC_ID} ""
  SectionSetFlags ${SEC_ID} 0
!macroend

Function SetManualMode
  StrCpy $InstallMode 1
  
  ; 简化：先隐藏所有自动安装Section，再显示手动安装Section
  DetailPrint "切换到手动安装模式"
  
  ; 显示手动安装Section
  SectionSetText ${SEC_MANUAL} "手动安装"
  SectionSetFlags ${SEC_MANUAL} 1
  
  ; 使用宏隐藏所有自动版本项
  !insertmacro HideVersionSection ${SEC_2026}
  !insertmacro HideVersionSection ${SEC_2025}
  !insertmacro HideVersionSection ${SEC_2024}
  !insertmacro HideVersionSection ${SEC_2023}
  !insertmacro HideVersionSection ${SEC_2022}
  !insertmacro HideVersionSection ${SEC_2021}
  !insertmacro HideVersionSection ${SEC_2020}
  !insertmacro HideVersionSection ${SEC_2019}
  !insertmacro HideVersionSection ${SEC_2018}
  !insertmacro HideVersionSection ${SEC_2017}
  !insertmacro HideVersionSection ${SEC_2016}
  !insertmacro HideVersionSection ${SEC_2015}
  !insertmacro HideVersionSection ${SEC_2014}
  !insertmacro HideVersionSection ${SEC_2013}
  !insertmacro HideVersionSection ${SEC_2012}
  !insertmacro HideVersionSection ${SEC_2011}
  !insertmacro HideVersionSection ${SEC_2010}
  !insertmacro HideVersionSection ${SEC_2009}
  !insertmacro HideVersionSection ${SEC_2008}
  !insertmacro HideVersionSection ${SEC_9}
FunctionEnd

; 定义检测版本并设置变量的宏
!macro DetectMaxVersion VER_NAME REG_PATH
  setRegView 64
  ReadRegStr $v${VER_NAME} HKLM "${REG_PATH}" "Installdir"
  ${If} $v${VER_NAME} != ""
    SectionSetFlags ${SEC_${VER_NAME}} 1
    SectionSetText ${SEC_${VER_NAME}} "3dsMax ${VER_NAME}"
  ${Else}
    SectionSetFlags ${SEC_${VER_NAME}} 0
    SectionSetText ${SEC_${VER_NAME}} ""
  ${EndIf}
!macroend

Function .onInit

!insertmacro MUI_LANGDLL_DISPLAY

;检查 3dsmax.exe 是否已运行
nsProcess::_FindProcess "3dsmax.exe"
Pop $R0
${If} $R0 = 0
  MessageBox MB_ICONEXCLAMATION|MB_OK "BsKeyTools 安装程序检测到 3dsmax.exe 正在运行中！$\n$\n安装可能会导致工具异常，请先关闭 3dsMax 再次打开本安装程序。$\n$\n如果你没有打开，可能是残留进程，建议手动关闭一下~"
${EndIf}

; 初始化变量
StrCpy $InstallMode 0  ; 默认为自动模式
StrCpy $MAXPATH ""     ; 初始化手动路径变量

; 检测所有版本的3dsMax
DetailPrint "检测已安装的3dsMax版本..."
!insertmacro DetectMaxVersion "2026" "SOFTWARE\Autodesk\3dsMax\28.0"
!insertmacro DetectMaxVersion "2025" "SOFTWARE\Autodesk\3dsMax\27.0"
!insertmacro DetectMaxVersion "2024" "SOFTWARE\Autodesk\3dsMax\26.0"
!insertmacro DetectMaxVersion "2023" "SOFTWARE\Autodesk\3dsMax\25.0"
!insertmacro DetectMaxVersion "2022" "SOFTWARE\Autodesk\3dsMax\24.0"
!insertmacro DetectMaxVersion "2021" "SOFTWARE\Autodesk\3dsMax\23.0"
!insertmacro DetectMaxVersion "2020" "SOFTWARE\Autodesk\3dsMax\22.0"
!insertmacro DetectMaxVersion "2019" "SOFTWARE\Autodesk\3dsMax\21.0"
!insertmacro DetectMaxVersion "2018" "SOFTWARE\Autodesk\3dsMax\20.0"
!insertmacro DetectMaxVersion "2017" "SOFTWARE\Autodesk\3dsMax\19.0"
!insertmacro DetectMaxVersion "2016" "SOFTWARE\Autodesk\3dsMax\18.0"
!insertmacro DetectMaxVersion "2015" "SOFTWARE\Autodesk\3dsMax\17.0"
!insertmacro DetectMaxVersion "2014" "SOFTWARE\Autodesk\3dsMax\16.0"
!insertmacro DetectMaxVersion "2013" "SOFTWARE\Autodesk\3dsMax\15.0"
!insertmacro DetectMaxVersion "2012" "SOFTWARE\Autodesk\3dsMax\14.0"
!insertmacro DetectMaxVersion "2011" "SOFTWARE\Autodesk\3dsMax\13.0"
!insertmacro DetectMaxVersion "2010" "SOFTWARE\Autodesk\3dsMax\12.0"
!insertmacro DetectMaxVersion "2009" "SOFTWARE\Autodesk\3dsMax\11.0"
!insertmacro DetectMaxVersion "2008" "SOFTWARE\Autodesk\3dsMax\10.0"
!insertmacro DetectMaxVersion "9" "SOFTWARE\Autodesk\3dsMax\9.0"

; 预先隐藏手动安装Section
SectionSetText ${SEC_MANUAL} ""
SectionSetFlags ${SEC_MANUAL} 0

FunctionEnd

; 版本描述
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2026} $v2026
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2025} $v2025
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2024} $v2024
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2023} $v2023
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2022} $v2022
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2021} $v2021
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2020} $v2020
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2019} $v2019
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2018} $v2018
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2017} $v2017
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2016} $v2016
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2015} $v2015
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2014} $v2014
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2013} $v2013
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2012} $v2012
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2011} $v2011
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2010} $v2010
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2009} $v2009
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2008} $v2008
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_9} $v9
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_MANUAL} $MAXPATH
!insertmacro MUI_FUNCTION_DESCRIPTION_END
