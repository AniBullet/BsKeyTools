; 添加Unicode支持
Unicode true

; 安装程序初始定义常量
!define PRODUCT_NAME "BsKeyTools"
!define PRODUCT_VERSION "_v1.1.0_测试用"
!define PRODUCT_PUBLISHER "Bullet.S"
!define PRODUCT_WEB_SITE "anibullet.com"
!define APPDATA_PLUGINS_PATH "C:\ProgramData\Autodesk\ApplicationPlugins"

; 自定义安装程序底部的文本
BrandingText "BsKeyTools - 动画师 K 帧工具"

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
!define SEC_ALL 21 ; 添加一个隐藏的Section，用于手动安装

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
var SelectedVersion ; 手动模式下选择的Max版本
var DropListHwnd ; 下拉列表的窗口句柄，用于后续操作

SetCompressor lzma

; ------ MUI 现代界面定义 (1.67 版本以上兼容) ------
!include "MUI2.nsh"
!include "LogicLib.nsh" ; 引入逻辑库
!include "Sections.nsh" ; 引入Sections库
!include "FileFunc.nsh" ; 引入文件功能库
!include "WinMessages.nsh"

; MUI 预定义常量
!define MUI_ABORTWARNING
!define MUI_ICON ".\max.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP ".\sideImg.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP ".\logo.bmp"

; 组件页面自定义函数，直接在这里定义，重要！！
; 注释掉原有定义，使用页面条件跳过而非自定义函数
; !define MUI_COMPONENTSPAGE_CUSTOMFUNCTION_PRE ComponentsPagePre
!define MUI_TEXT_COMPONENTS_TITLE "选择版本"
!define MUI_TEXT_COMPONENTS_SUBTITLE "选择你想安装 $(^NameDA) 的 3dsMax 版本。"
!define MUI_INNERTEXT_COMPONENTS_DESCRIPTION_TITLE "安装路径"
!define MUI_INNERTEXT_COMPONENTS_DESCRIPTION_INFO "将光标悬停在版本名称之上，即可显示它的安装路径。"

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

; 在组件页面显示之前检查安装模式
Function .onSelChange
  ${If} $InstallMode == 1
    Abort
  ${EndIf}
FunctionEnd

; 组件选择页面（自动模式时显示）
ComponentText "请勾选你想安装到的版本，并取消勾选你不想安装的版本。 $\r$\n$\r$\n$_CLICK" "" "选定安装的版本: "
!define MUI_PAGE_CUSTOMFUNCTION_PRE VerifyAutoInstall
!insertmacro MUI_PAGE_COMPONENTS

; 检查安装模式和版本，确定是否显示组件页面
Function VerifyAutoInstall
  ; 如果是手动模式，则跳过组件页面
  ${If} $InstallMode == 1
    Abort
    Return
  ${EndIf}
  
  ; 检查是否有任何版本被检测到
  StrCpy $R0 0 ; 计数器
  
  ; 重新设置各版本Section状态，确保界面与当前状态同步
  ${If} $v2026 != ""
    SectionSetText ${SEC_2026} "3dsMax 2026"
    SectionSetFlags ${SEC_2026} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2026} ""
    SectionSetFlags ${SEC_2026} 0
  ${EndIf}
  
  ${If} $v2025 != ""
    SectionSetText ${SEC_2025} "3dsMax 2025"
    SectionSetFlags ${SEC_2025} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2025} ""
    SectionSetFlags ${SEC_2025} 0
  ${EndIf}
  
  ${If} $v2024 != ""
    SectionSetText ${SEC_2024} "3dsMax 2024"
    SectionSetFlags ${SEC_2024} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2024} ""
    SectionSetFlags ${SEC_2024} 0
  ${EndIf}
  
  ${If} $v2023 != ""
    SectionSetText ${SEC_2023} "3dsMax 2023"
    SectionSetFlags ${SEC_2023} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2023} ""
    SectionSetFlags ${SEC_2023} 0
  ${EndIf}
  
  ${If} $v2022 != ""
    SectionSetText ${SEC_2022} "3dsMax 2022"
    SectionSetFlags ${SEC_2022} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2022} ""
    SectionSetFlags ${SEC_2022} 0
  ${EndIf}
  
  ${If} $v2021 != ""
    SectionSetText ${SEC_2021} "3dsMax 2021"
    SectionSetFlags ${SEC_2021} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2021} ""
    SectionSetFlags ${SEC_2021} 0
  ${EndIf}
  
  ${If} $v2020 != ""
    SectionSetText ${SEC_2020} "3dsMax 2020"
    SectionSetFlags ${SEC_2020} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2020} ""
    SectionSetFlags ${SEC_2020} 0
  ${EndIf}
  
  ${If} $v2019 != ""
    SectionSetText ${SEC_2019} "3dsMax 2019"
    SectionSetFlags ${SEC_2019} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2019} ""
    SectionSetFlags ${SEC_2019} 0
  ${EndIf}
  
  ${If} $v2018 != ""
    SectionSetText ${SEC_2018} "3dsMax 2018"
    SectionSetFlags ${SEC_2018} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2018} ""
    SectionSetFlags ${SEC_2018} 0
  ${EndIf}
  
  ${If} $v2017 != ""
    SectionSetText ${SEC_2017} "3dsMax 2017"
    SectionSetFlags ${SEC_2017} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2017} ""
    SectionSetFlags ${SEC_2017} 0
  ${EndIf}
  
  ${If} $v2016 != ""
    SectionSetText ${SEC_2016} "3dsMax 2016"
    SectionSetFlags ${SEC_2016} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2016} ""
    SectionSetFlags ${SEC_2016} 0
  ${EndIf}
  
  ${If} $v2015 != ""
    SectionSetText ${SEC_2015} "3dsMax 2015"
    SectionSetFlags ${SEC_2015} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2015} ""
    SectionSetFlags ${SEC_2015} 0
  ${EndIf}
  
  ${If} $v2014 != ""
    SectionSetText ${SEC_2014} "3dsMax 2014"
    SectionSetFlags ${SEC_2014} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2014} ""
    SectionSetFlags ${SEC_2014} 0
  ${EndIf}
  
  ${If} $v2013 != ""
    SectionSetText ${SEC_2013} "3dsMax 2013"
    SectionSetFlags ${SEC_2013} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2013} ""
    SectionSetFlags ${SEC_2013} 0
  ${EndIf}
  
  ${If} $v2012 != ""
    SectionSetText ${SEC_2012} "3dsMax 2012"
    SectionSetFlags ${SEC_2012} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2012} ""
    SectionSetFlags ${SEC_2012} 0
  ${EndIf}
  
  ${If} $v2011 != ""
    SectionSetText ${SEC_2011} "3dsMax 2011"
    SectionSetFlags ${SEC_2011} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2011} ""
    SectionSetFlags ${SEC_2011} 0
  ${EndIf}
  
  ${If} $v2010 != ""
    SectionSetText ${SEC_2010} "3dsMax 2010"
    SectionSetFlags ${SEC_2010} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2010} ""
    SectionSetFlags ${SEC_2010} 0
  ${EndIf}
  
  ${If} $v2009 != ""
    SectionSetText ${SEC_2009} "3dsMax 2009"
    SectionSetFlags ${SEC_2009} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2009} ""
    SectionSetFlags ${SEC_2009} 0
  ${EndIf}
  
  ${If} $v2008 != ""
    SectionSetText ${SEC_2008} "3dsMax 2008"
    SectionSetFlags ${SEC_2008} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_2008} ""
    SectionSetFlags ${SEC_2008} 0
  ${EndIf}
  
  ${If} $v9 != ""
    SectionSetText ${SEC_9} "3dsMax 9"
    SectionSetFlags ${SEC_9} 1
    IntOp $R0 $R0 + 1
  ${Else}
    SectionSetText ${SEC_9} ""
    SectionSetFlags ${SEC_9} 0
  ${EndIf}
  
  ; 如果没有检测到任何版本，提示用户并转到手动模式
  ${If} $R0 == 0
    MessageBox MB_ICONINFORMATION|MB_OK "未检测到任何3dsMax版本。将切换到手动安装模式。"
    StrCpy $InstallMode 1
    Abort ; 跳过组件页面
  ${EndIf}
  
  ; 更新可见的Section，确保手动安装Section不可见
  SectionSetText ${SEC_MANUAL} ""
  SectionSetFlags ${SEC_MANUAL} 0
FunctionEnd

; 安装过程页面
!insertmacro MUI_PAGE_INSTFILES

; 安装完成页面
!define MUI_FINISHPAGE_TITLE "安装完成"
!define MUI_FINISHPAGE_TITLE_3LINES "BsKeyTools 已成功安装"
!define MUI_FINISHPAGE_TEXT "$(^NameDA) 已经成功安装到本机。$\r$\n$\r$\n点击 [完成(F)] 关闭安装程序。"
!define MUI_FINISHPAGE_SHOWREADME
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION Info
!define MUI_FINISHPAGE_SHOWREADME_TEXT "查看帮助视频"
!define MUI_FINISHPAGE_LINK "Github"
!define MUI_FINISHPAGE_LINK_LOCATION "https://github.com/AniBullet/BsKeyTools"
!define MUI_FINISHPAGE_LINK_COLOR "872657"
!define MUI_PAGE_CUSTOMFUNCTION_PRE CompletePagePre

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
  ; 确保UI状态与变量状态同步 - 记住单选按钮句柄
  StrCpy $R5 $1
  ${NSD_OnClick} $1 SetAutoMode
  
  ; 手动选择选项
  ${NSD_CreateRadioButton} 10 40 300 20 "手动指定 3dsMax 安装路径"
  Pop $2
  ; 确保UI状态与变量状态同步 - 记住单选按钮句柄
  StrCpy $R6 $2
  ${NSD_OnClick} $2 SetManualMode
  
  ; 添加说明标签
  ${NSD_CreateLabel} 20 70 350 100 "自动检测模式将查找已安装的所有3dsMax版本，$\r$\n$\r$\n并允许你选择要安装到的版本。$\r$\n$\r$\n手动模式允许你指定一个特定的3dsMax安装路径进行安装。$\r$\n$\r$\n如果自动检测失败，请使用此选项。"
  Pop $0
  
  ; 根据当前选择模式设置界面显示状态
  ${If} $InstallMode == 1
    ${NSD_Check} $R6 ; 选中手动安装
    ${NSD_Uncheck} $R5 ; 取消选中自动安装
  ${Else}
    ${NSD_Check} $R5 ; 选中自动安装
    ${NSD_Uncheck} $R6 ; 取消选中手动安装
    ; 确保变量值正确
    StrCpy $InstallMode 0
  ${EndIf}
  
  nsDialogs::Show
FunctionEnd

; 定义显示版本Section的宏
!macro ShowVersionSection SEC_ID VER_NAME
  ${If} $${VER_NAME} != ""
    SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
    SectionSetFlags ${SEC_ID} 1
  ${EndIf}
!macroend

; 定义隐藏版本Section的宏
!macro HideVersionSection SEC_ID
  SectionSetText ${SEC_ID} ""
  SectionSetFlags ${SEC_ID} 0
!macroend

Function SetManualMode
  StrCpy $InstallMode 1
  
  ; 简化：在手动模式下隐藏所有自动安装Section
  DetailPrint "切换到手动安装模式"
  DetailPrint "隐藏所有自动检测的版本"
  
  ; 隐藏所有自动版本Section
  SectionSetText ${SEC_2026} ""
  SectionSetFlags ${SEC_2026} 0
  SectionSetText ${SEC_2025} ""
  SectionSetFlags ${SEC_2025} 0
  SectionSetText ${SEC_2024} ""
  SectionSetFlags ${SEC_2024} 0
  SectionSetText ${SEC_2023} ""
  SectionSetFlags ${SEC_2023} 0
  SectionSetText ${SEC_2022} ""
  SectionSetFlags ${SEC_2022} 0
  SectionSetText ${SEC_2021} ""
  SectionSetFlags ${SEC_2021} 0
  SectionSetText ${SEC_2020} ""
  SectionSetFlags ${SEC_2020} 0
  SectionSetText ${SEC_2019} ""
  SectionSetFlags ${SEC_2019} 0
  SectionSetText ${SEC_2018} ""
  SectionSetFlags ${SEC_2018} 0
  SectionSetText ${SEC_2017} ""
  SectionSetFlags ${SEC_2017} 0
  SectionSetText ${SEC_2016} ""
  SectionSetFlags ${SEC_2016} 0
  SectionSetText ${SEC_2015} ""
  SectionSetFlags ${SEC_2015} 0
  SectionSetText ${SEC_2014} ""
  SectionSetFlags ${SEC_2014} 0
  SectionSetText ${SEC_2013} ""
  SectionSetFlags ${SEC_2013} 0
  SectionSetText ${SEC_2012} ""
  SectionSetFlags ${SEC_2012} 0
  SectionSetText ${SEC_2011} ""
  SectionSetFlags ${SEC_2011} 0
  SectionSetText ${SEC_2010} ""
  SectionSetFlags ${SEC_2010} 0
  SectionSetText ${SEC_2009} ""
  SectionSetFlags ${SEC_2009} 0
  SectionSetText ${SEC_2008} ""
  SectionSetFlags ${SEC_2008} 0
  SectionSetText ${SEC_9} ""
  SectionSetFlags ${SEC_9} 0
  
  DetailPrint "手动安装将在代码中自动处理"
  
  ; 立即更新界面状态，确保下一步时模式正确
  ${If} $R6 != ""
    ${NSD_Check} $R6 ; 选中手动安装
  ${EndIf}
  ${If} $R5 != ""
    ${NSD_Uncheck} $R5 ; 取消选中自动安装
  ${EndIf}
FunctionEnd

Function SetAutoMode
  StrCpy $InstallMode 0
  
  ; 在自动模式下隐藏手动安装Section
  DetailPrint "切换到自动检测模式"
  DetailPrint "隐藏手动安装Section"
  SectionSetText ${SEC_MANUAL} ""
  SectionSetFlags ${SEC_MANUAL} 0
  
  ; 恢复所有自动检测的版本
  DetailPrint "恢复显示自动检测到的版本"
  
  ; 检查每个版本，仅显示已检测到的版本
  StrCpy $R0 0 ; 计数器，用于统计检测到的版本数量
  
  ${If} $v2026 != ""
    SectionSetText ${SEC_2026} "3dsMax 2026"
    SectionSetFlags ${SEC_2026} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2026版本安装选项"
  ${Else}
    SectionSetText ${SEC_2026} ""
    SectionSetFlags ${SEC_2026} 0
  ${EndIf}
  
  ${If} $v2025 != ""
    SectionSetText ${SEC_2025} "3dsMax 2025"
    SectionSetFlags ${SEC_2025} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2025版本安装选项"
  ${Else}
    SectionSetText ${SEC_2025} ""
    SectionSetFlags ${SEC_2025} 0
  ${EndIf}
  
  ${If} $v2024 != ""
    SectionSetText ${SEC_2024} "3dsMax 2024"
    SectionSetFlags ${SEC_2024} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2024版本安装选项"
  ${Else}
    SectionSetText ${SEC_2024} ""
    SectionSetFlags ${SEC_2024} 0
  ${EndIf}
  
  ${If} $v2023 != ""
    SectionSetText ${SEC_2023} "3dsMax 2023"
    SectionSetFlags ${SEC_2023} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2023版本安装选项"
  ${Else}
    SectionSetText ${SEC_2023} ""
    SectionSetFlags ${SEC_2023} 0
  ${EndIf}
  
  ${If} $v2022 != ""
    SectionSetText ${SEC_2022} "3dsMax 2022"
    SectionSetFlags ${SEC_2022} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2022版本安装选项"
  ${Else}
    SectionSetText ${SEC_2022} ""
    SectionSetFlags ${SEC_2022} 0
  ${EndIf}
  
  ${If} $v2021 != ""
    SectionSetText ${SEC_2021} "3dsMax 2021"
    SectionSetFlags ${SEC_2021} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2021版本安装选项"
  ${Else}
    SectionSetText ${SEC_2021} ""
    SectionSetFlags ${SEC_2021} 0
  ${EndIf}
  
  ${If} $v2020 != ""
    SectionSetText ${SEC_2020} "3dsMax 2020"
    SectionSetFlags ${SEC_2020} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2020版本安装选项"
  ${Else}
    SectionSetText ${SEC_2020} ""
    SectionSetFlags ${SEC_2020} 0
  ${EndIf}
  
  ${If} $v2019 != ""
    SectionSetText ${SEC_2019} "3dsMax 2019"
    SectionSetFlags ${SEC_2019} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2019版本安装选项"
  ${Else}
    SectionSetText ${SEC_2019} ""
    SectionSetFlags ${SEC_2019} 0
  ${EndIf}
  
  ${If} $v2018 != ""
    SectionSetText ${SEC_2018} "3dsMax 2018"
    SectionSetFlags ${SEC_2018} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2018版本安装选项"
  ${Else}
    SectionSetText ${SEC_2018} ""
    SectionSetFlags ${SEC_2018} 0
  ${EndIf}
  
  ${If} $v2017 != ""
    SectionSetText ${SEC_2017} "3dsMax 2017"
    SectionSetFlags ${SEC_2017} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2017版本安装选项"
  ${Else}
    SectionSetText ${SEC_2017} ""
    SectionSetFlags ${SEC_2017} 0
  ${EndIf}
  
  ${If} $v2016 != ""
    SectionSetText ${SEC_2016} "3dsMax 2016"
    SectionSetFlags ${SEC_2016} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2016版本安装选项"
  ${Else}
    SectionSetText ${SEC_2016} ""
    SectionSetFlags ${SEC_2016} 0
  ${EndIf}
  
  ${If} $v2015 != ""
    SectionSetText ${SEC_2015} "3dsMax 2015"
    SectionSetFlags ${SEC_2015} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2015版本安装选项"
  ${Else}
    SectionSetText ${SEC_2015} ""
    SectionSetFlags ${SEC_2015} 0
  ${EndIf}
  
  ${If} $v2014 != ""
    SectionSetText ${SEC_2014} "3dsMax 2014"
    SectionSetFlags ${SEC_2014} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2014版本安装选项"
  ${Else}
    SectionSetText ${SEC_2014} ""
    SectionSetFlags ${SEC_2014} 0
  ${EndIf}
  
  ${If} $v2013 != ""
    SectionSetText ${SEC_2013} "3dsMax 2013"
    SectionSetFlags ${SEC_2013} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2013版本安装选项"
  ${Else}
    SectionSetText ${SEC_2013} ""
    SectionSetFlags ${SEC_2013} 0
  ${EndIf}
  
  ${If} $v2012 != ""
    SectionSetText ${SEC_2012} "3dsMax 2012"
    SectionSetFlags ${SEC_2012} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2012版本安装选项"
  ${Else}
    SectionSetText ${SEC_2012} ""
    SectionSetFlags ${SEC_2012} 0
  ${EndIf}
  
  ${If} $v2011 != ""
    SectionSetText ${SEC_2011} "3dsMax 2011"
    SectionSetFlags ${SEC_2011} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2011版本安装选项"
  ${Else}
    SectionSetText ${SEC_2011} ""
    SectionSetFlags ${SEC_2011} 0
  ${EndIf}
  
  ${If} $v2010 != ""
    SectionSetText ${SEC_2010} "3dsMax 2010"
    SectionSetFlags ${SEC_2010} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2010版本安装选项"
  ${Else}
    SectionSetText ${SEC_2010} ""
    SectionSetFlags ${SEC_2010} 0
  ${EndIf}
  
  ${If} $v2009 != ""
    SectionSetText ${SEC_2009} "3dsMax 2009"
    SectionSetFlags ${SEC_2009} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2009版本安装选项"
  ${Else}
    SectionSetText ${SEC_2009} ""
    SectionSetFlags ${SEC_2009} 0
  ${EndIf}
  
  ${If} $v2008 != ""
    SectionSetText ${SEC_2008} "3dsMax 2008"
    SectionSetFlags ${SEC_2008} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 2008版本安装选项"
  ${Else}
    SectionSetText ${SEC_2008} ""
    SectionSetFlags ${SEC_2008} 0
  ${EndIf}
  
  ${If} $v9 != ""
    SectionSetText ${SEC_9} "3dsMax 9"
    SectionSetFlags ${SEC_9} 1
    IntOp $R0 $R0 + 1
    DetailPrint "已启用3dsMax 9版本安装选项"
  ${Else}
    SectionSetText ${SEC_9} ""
    SectionSetFlags ${SEC_9} 0
  ${EndIf}
  
  ; 如果没有检测到任何版本，显示提示并切换到手动模式
  ${If} $R0 == 0
    DetailPrint "未检测到任何3dsMax版本，将切换到手动安装模式"
    MessageBox MB_ICONINFORMATION|MB_OK "未检测到任何3dsMax版本。将切换到手动安装模式。"
    StrCpy $InstallMode 1
  ${Else}
    DetailPrint "检测到 $R0 个3dsMax版本"
    
    ; 立即更新界面状态，确保下一步时模式正确
    ${If} $R5 != ""
      ${NSD_Check} $R5 ; 选中自动安装
    ${EndIf}
    ${If} $R6 != ""
      ${NSD_Uncheck} $R6 ; 取消选中手动安装
    ${EndIf}
  ${EndIf}
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
  !insertmacro MUI_HEADER_TEXT "3dsMax 路径设置" "请指定安装路径和版本。"
  
  ; 创建一个对话框
  nsDialogs::Create 1018
  Pop $0
  
  ; 添加标签和输入框 - 安装路径
  ${NSD_CreateLabel} 10 10 100 20 "安装路径:"
  Pop $0
  ${NSD_CreateDirRequest} 120 10 250 20 $MAXPATH
  Pop $R0
  ${NSD_CreateBrowseButton} 380 10 50 20 "浏览..."
  Pop $0
  ${NSD_OnClick} $0 BrowseMaxPath
  
  ; 添加标签和下拉列表 - 3dsMax版本选择
  ${NSD_CreateLabel} 10 40 100 20 "3dsMax 版本:"
  Pop $0
  ${NSD_CreateDropList} 120 40 180 20 ""
  Pop $DropListHwnd
  
  ; 向下拉列表添加版本选项
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2026"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2025"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2024"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2023"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2022"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2021"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2020"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2019"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2018"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2017"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2016"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2015"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2014"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2013"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2012"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2011"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2010"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2009"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 2008"
  ${NSD_CB_AddString} $DropListHwnd "3dsMax 9"
  
  ; 默认选择最新版本
  ${NSD_CB_SelectString} $DropListHwnd "3dsMax 2026"
  
  ; 添加说明标签
  ${NSD_CreateLabel} 10 70 390 60 "请指定要安装的目标文件夹（可以是任意位置，如桌面文件夹）$\r$\n$\r$\n并选择对应的3dsMax版本以安装适合该版本的插件。"
  Pop $0
  
  nsDialogs::Show
FunctionEnd

Function BrowseMaxPath
  ${NSD_GetText} $R0 $0
  nsDialogs::SelectFolderDialog "选择安装目录" $0
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
    MessageBox MB_ICONEXCLAMATION|MB_OK "请指定安装路径。"
    Abort
  ${EndIf}
  
  ; 获取下拉列表选择的版本 - 使用可靠的原生API方法
  ; 1. 获取当前选中的索引
  SendMessage $DropListHwnd ${CB_GETCURSEL} 0 0 $0
  
  ; 2. 检查是否有选择
  ${If} $0 == CB_ERR
    MessageBox MB_ICONEXCLAMATION|MB_OK "请选择3dsMax版本。"
    Abort
  ${EndIf}
  
  ; 3. 获取选择项文本
  System::Call "user32::SendMessage(i $DropListHwnd, i ${CB_GETLBTEXT}, i r0, t .r1)"
  StrCpy $SelectedVersion $1
  
  ; 确保已选择版本
  ${If} $SelectedVersion == ""
    MessageBox MB_ICONEXCLAMATION|MB_OK "请选择3dsMax版本。"
    Abort
  ${EndIf}
FunctionEnd

Name "${PRODUCT_NAME}${PRODUCT_VERSION}"
OutFile "_BsKeyTools.exe"
ShowInstDetails show
ShowUnInstDetails show

; 工具函数：确保路径以反斜杠结尾
Function AddBackslash
  Exch $R0
  Push $R1
  
  StrCpy $R1 $R0 1 -1
  ${If} $R1 != "\"
    StrCpy $R0 "$R0\"
  ${EndIf}
  
  Pop $R1
  Exch $R0
FunctionEnd

!define SECTION_SELECTED 1

; 统一安装函数，简化代码，减少重复
Function InstallVersionFiles
  ; 参数: 
  ; $R9 - 版本号(如"2024")
  ; $R8 - 版本路径变量(如$v2024)
  
  ; 检查路径是否为空
  ${If} $R8 == ""
    MessageBox MB_ICONSTOP|MB_OK "错误：安装路径为空，无法安装3dsMax $R9"
    SetErrors
    Abort "安装失败：无效的安装路径"
  ${EndIf}
  
  ; 确保路径格式正确（末尾添加反斜杠）
  Push "$R8"
  Call AddBackslash
  Pop $R0
  
  ; Scripts目录
  CreateDirectory "$R0Scripts"
  ClearErrors
  SetOutPath "$R0Scripts"
  File /r "Scripts\*.*"
  ${If} ${Errors}
    MessageBox MB_ICONSTOP|MB_OK "复制Scripts文件夹失败，安装中止。"
    SetErrors
    Abort "安装失败：复制Scripts文件失败"
  ${EndIf}
  
  ; UI_ln目录
  CreateDirectory "$R0UI_ln"
  ClearErrors
  SetOutPath "$R0UI_ln"
  File /r "UI_ln\*.*"
  ${If} ${Errors}
    MessageBox MB_ICONSTOP|MB_OK "复制UI_ln文件夹失败，安装中止。"
    SetErrors
    Abort "安装失败：复制UI_ln文件失败"
  ${EndIf}
  
  ; plugins目录
  CreateDirectory "$R0plugins"
  ClearErrors
  SetOutPath "$R0plugins"
  
  ; 根据不同版本安装对应的插件文件
  ${If} $R9 == "2026"
    File /r "GhostTrails\2026\plugins\*.*"
  ${ElseIf} $R9 == "2025"
    File /r "GhostTrails\2025\plugins\*.*"
  ${ElseIf} $R9 == "2024"
    File /r "GhostTrails\2024\plugins\*.*"
  ${ElseIf} $R9 == "2023"
    File /r "GhostTrails\2023\plugins\*.*"
  ${ElseIf} $R9 == "2022"
    File /r "GhostTrails\2022\plugins\*.*"
  ${ElseIf} $R9 == "2021"
    File /r "GhostTrails\2021\plugins\*.*"
  ${ElseIf} $R9 == "2020"
    File /r "GhostTrails\2020\plugins\*.*"
  ${ElseIf} $R9 == "2019"
    File /r "GhostTrails\2019\plugins\*.*"
  ${ElseIf} $R9 == "2018"
    File /r "GhostTrails\2018\plugins\*.*"
  ${ElseIf} $R9 == "2017"
    File /r "GhostTrails\2017\plugins\*.*"
  ${ElseIf} $R9 == "2016"
    File /r "GhostTrails\2016\plugins\*.*"
  ${ElseIf} $R9 == "2015"
    File /r "GhostTrails\2015\plugins\*.*"
  ${ElseIf} $R9 == "2014"
    File /r "GhostTrails\2014\plugins\*.*"
  ${ElseIf} $R9 == "2013"
    File /r "GhostTrails\2013\plugins\*.*"
  ${ElseIf} $R9 == "2012"
    File /r "GhostTrails\2012\plugins\*.*"
  ${ElseIf} $R9 == "2011"
    File /r "GhostTrails\2011\plugins\*.*"
  ${ElseIf} $R9 == "2010"
    File /r "GhostTrails\2010\plugins\*.*"
  ${ElseIf} $R9 == "2009"
    File /r "GhostTrails\2009\plugins\*.*"
  ${ElseIf} $R9 == "2008"
    File /r "GhostTrails\2008\plugins\*.*"
  ${ElseIf} $R9 == "9"
    File /r "GhostTrails\9\plugins\*.*"
  ${EndIf}
  
  ${If} ${Errors}
    ; 修改错误处理，提供更明确的信息但不中止安装
    DetailPrint "注意：复制plugins文件夹时遇到问题，可能文件已存在或被占用。"
    DetailPrint "如果plugins功能不正常，请尝试关闭3dsMax后重新安装。"
  ${EndIf}
FunctionEnd

; 移除宏定义，直接在各Section中实现相关代码

Section "-InstallSelectedVersions" ; 隐藏的安装处理Section
  ${If} $InstallMode == 1
    Return ; 手动模式下跳过
  ${EndIf}
SectionEnd

; 修改自动安装的版本Section，使用通用安装函数
Section "3dsMax 2026" ${SEC_2026}
  SectionGetFlags ${SEC_2026} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2026"
    StrCpy $R8 $v2026
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2025" ${SEC_2025}
  SectionGetFlags ${SEC_2025} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2025"
    StrCpy $R8 $v2025
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2024" ${SEC_2024}
  SectionGetFlags ${SEC_2024} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2024"
    StrCpy $R8 $v2024
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2023" ${SEC_2023}
  SectionGetFlags ${SEC_2023} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2023"
    StrCpy $R8 $v2023
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2022" ${SEC_2022}
  SectionGetFlags ${SEC_2022} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2022"
    StrCpy $R8 $v2022
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2021" ${SEC_2021}
  SectionGetFlags ${SEC_2021} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2021"
    StrCpy $R8 $v2021
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2020" ${SEC_2020}
  SectionGetFlags ${SEC_2020} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2020"
    StrCpy $R8 $v2020
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2019" ${SEC_2019}
  SectionGetFlags ${SEC_2019} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2019"
    StrCpy $R8 $v2019
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2018" ${SEC_2018}
  SectionGetFlags ${SEC_2018} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2018"
    StrCpy $R8 $v2018
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2017" ${SEC_2017}
  SectionGetFlags ${SEC_2017} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2017"
    StrCpy $R8 $v2017
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2016" ${SEC_2016}
  SectionGetFlags ${SEC_2016} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2016"
    StrCpy $R8 $v2016
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2015" ${SEC_2015}
  SectionGetFlags ${SEC_2015} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2015"
    StrCpy $R8 $v2015
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2014" ${SEC_2014}
  SectionGetFlags ${SEC_2014} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2014"
    StrCpy $R8 $v2014
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2013" ${SEC_2013}
  SectionGetFlags ${SEC_2013} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2013"
    StrCpy $R8 $v2013
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2012" ${SEC_2012}
  SectionGetFlags ${SEC_2012} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2012"
    StrCpy $R8 $v2012
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2011" ${SEC_2011}
  SectionGetFlags ${SEC_2011} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2011"
    StrCpy $R8 $v2011
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2010" ${SEC_2010}
  SectionGetFlags ${SEC_2010} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2010"
    StrCpy $R8 $v2010
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2009" ${SEC_2009}
  SectionGetFlags ${SEC_2009} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2009"
    StrCpy $R8 $v2009
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2008" ${SEC_2008}
  SectionGetFlags ${SEC_2008} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "2008"
    StrCpy $R8 $v2008
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 9" ${SEC_9}
  SectionGetFlags ${SEC_9} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    ; 设置版本参数
    StrCpy $R9 "9"
    StrCpy $R8 $v9
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

; 当安装程序初始化时执行
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
; 调用改进的检测函数
StrCpy $R9 "2026"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\28.0"
StrCpy $R7 ${SEC_2026}
Call DetectMaxVersion

StrCpy $R9 "2025"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\27.0"
StrCpy $R7 ${SEC_2025}
Call DetectMaxVersion

StrCpy $R9 "2024"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\26.0"
StrCpy $R7 ${SEC_2024}
Call DetectMaxVersion

StrCpy $R9 "2023"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\25.0"
StrCpy $R7 ${SEC_2023}
Call DetectMaxVersion

StrCpy $R9 "2022"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\24.0"
StrCpy $R7 ${SEC_2022}
Call DetectMaxVersion

StrCpy $R9 "2021"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\23.0"
StrCpy $R7 ${SEC_2021}
Call DetectMaxVersion

StrCpy $R9 "2020"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\22.0"
StrCpy $R7 ${SEC_2020}
Call DetectMaxVersion

StrCpy $R9 "2019"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\21.0"
StrCpy $R7 ${SEC_2019}
Call DetectMaxVersion

StrCpy $R9 "2018"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\20.0"
StrCpy $R7 ${SEC_2018}
Call DetectMaxVersion

StrCpy $R9 "2017"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\19.0"
StrCpy $R7 ${SEC_2017}
Call DetectMaxVersion

StrCpy $R9 "2016"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\18.0"
StrCpy $R7 ${SEC_2016}
Call DetectMaxVersion

StrCpy $R9 "2015"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\17.0"
StrCpy $R7 ${SEC_2015}
Call DetectMaxVersion

StrCpy $R9 "2014"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\16.0"
StrCpy $R7 ${SEC_2014}
Call DetectMaxVersion

StrCpy $R9 "2013"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\15.0"
StrCpy $R7 ${SEC_2013}
Call DetectMaxVersion

StrCpy $R9 "2012"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\14.0"
StrCpy $R7 ${SEC_2012}
Call DetectMaxVersion

StrCpy $R9 "2011"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\13.0"
StrCpy $R7 ${SEC_2011}
Call DetectMaxVersion

StrCpy $R9 "2010"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\12.0"
StrCpy $R7 ${SEC_2010}
Call DetectMaxVersion

StrCpy $R9 "2009"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\11.0"
StrCpy $R7 ${SEC_2009}
Call DetectMaxVersion

StrCpy $R9 "2008"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\10.0"
StrCpy $R7 ${SEC_2008}
Call DetectMaxVersion

StrCpy $R9 "9"
StrCpy $R8 "SOFTWARE\Autodesk\3dsMax\9.0"
StrCpy $R7 ${SEC_9}
Call DetectMaxVersion

; 确保在所有情况下都隐藏手动安装的Section
SectionSetText ${SEC_MANUAL} ""
SectionSetFlags ${SEC_MANUAL} 0
FunctionEnd

; 手动安装模式和版本检测功能已移至 VerifyAutoInstall 函数中实现

; 手动安装Section - 此处保留但不会在组件选择页面中显示
Section "-手动安装" ${SEC_MANUAL}
  ; 只在手动模式下执行
  ${If} $InstallMode != 1
    Return
  ${EndIf}
  
  ; 检查路径是否为空
  ${If} $MAXPATH == ""
    MessageBox MB_ICONSTOP|MB_OK "错误：手动安装路径为空，无法完成安装。"
    SetErrors
    Abort "安装失败：手动安装路径为空"
  ${EndIf}
  
  ; 确保路径以反斜杠结尾
  Push "$MAXPATH"
  Call AddBackslash
  Pop $R0
  
  ; 从下拉列表选择文本中直接提取版本号
  ${If} $SelectedVersion == ""
    MessageBox MB_ICONSTOP|MB_OK "错误：未选择3dsMax版本，无法完成安装。"
    SetErrors
    Abort "安装失败：未选择3dsMax版本"
  ${EndIf}
  
  ; 直接获取版本号（移除"3dsMax "前缀）
  StrCpy $1 $SelectedVersion 6 0 ; 获取前6个字符
  ${If} $1 == "3dsMax"
    ; 如果前缀是"3dsMax "，则提取版本号部分
    StrCpy $R2 $SelectedVersion "" 7 ; 从第7个字符开始提取
  ${Else}
    ; 如果格式不符合预期，使用默认版本
    StrCpy $R2 "2024"
  ${EndIf}
  
  ; 安装文件
  StrCpy $R9 $R2
  StrCpy $R8 $R0
  Call InstallVersionFiles
SectionEnd

; 处理自动检测模式下安装完成后的清理
Section "-Cleanup" ${SEC_ALL}
  ; 安装AnimRef文件夹到ApplicationPlugins目录
  DetailPrint "安装AnimRef到ApplicationPlugins目录..."
  
  ; 确保目标文件夹存在
  CreateDirectory "${APPDATA_PLUGINS_PATH}"
  CreateDirectory "${APPDATA_PLUGINS_PATH}\AnimRef"
  ClearErrors
  
  ; 设置输出路径并复制文件
  SetOutPath "${APPDATA_PLUGINS_PATH}\AnimRef"
  File /r "AnimRef\*.*"
  
  ${If} ${Errors}
    DetailPrint "警告：复制AnimRef文件夹时遇到问题，可能需要管理员权限。"
    MessageBox MB_ICONEXCLAMATION|MB_OK "AnimRef文件夹可能未成功安装。请确保您具有管理员权限，或手动复制AnimRef文件夹到：${APPDATA_PLUGINS_PATH}"
  ${Else}
    DetailPrint "AnimRef文件夹已成功安装"
  ${EndIf}
  
  DetailPrint "安装完成"
SectionEnd

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
  ; 手动安装选项的描述移除，确保不会在组件列表中显示
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; 版本检测函数 - 用来替代宏
Function DetectMaxVersion
  ; 参数:
  ; $R9 - 版本号(如"2024")
  ; $R8 - 注册表路径
  ; $R7 - 对应的Section ID
  
  setRegView 64
  ReadRegStr $0 HKLM "$R8" "Installdir"
  
  ; 存储路径到对应的变量
  ${If} $R9 == "2026"
    StrCpy $v2026 $0
  ${ElseIf} $R9 == "2025"
    StrCpy $v2025 $0
  ${ElseIf} $R9 == "2024"
    StrCpy $v2024 $0
  ${ElseIf} $R9 == "2023"
    StrCpy $v2023 $0
  ${ElseIf} $R9 == "2022"
    StrCpy $v2022 $0
  ${ElseIf} $R9 == "2021"
    StrCpy $v2021 $0
  ${ElseIf} $R9 == "2020"
    StrCpy $v2020 $0
  ${ElseIf} $R9 == "2019"
    StrCpy $v2019 $0
  ${ElseIf} $R9 == "2018"
    StrCpy $v2018 $0
  ${ElseIf} $R9 == "2017"
    StrCpy $v2017 $0
  ${ElseIf} $R9 == "2016"
    StrCpy $v2016 $0
  ${ElseIf} $R9 == "2015"
    StrCpy $v2015 $0
  ${ElseIf} $R9 == "2014"
    StrCpy $v2014 $0
  ${ElseIf} $R9 == "2013"
    StrCpy $v2013 $0
  ${ElseIf} $R9 == "2012"
    StrCpy $v2012 $0
  ${ElseIf} $R9 == "2011"
    StrCpy $v2011 $0
  ${ElseIf} $R9 == "2010"
    StrCpy $v2010 $0
  ${ElseIf} $R9 == "2009"
    StrCpy $v2009 $0
  ${ElseIf} $R9 == "2008"
    StrCpy $v2008 $0
  ${ElseIf} $R9 == "9"
    StrCpy $v9 $0
  ${EndIf}
  
  ; 根据检测结果设置Section状态
  ${If} $0 != ""
    SectionSetFlags $R7 1
    SectionSetText $R7 "3dsMax $R9"
  ${Else}
    SectionSetFlags $R7 0
    SectionSetText $R7 ""
  ${EndIf}
FunctionEnd

Function CompletePagePre
  IfErrors 0 NoInstallErrors
    ; 如果有错误，不显示完成页面
    DetailPrint "安装过程中发生错误，不显示完成页面"
    MessageBox MB_ICONSTOP|MB_OK "安装未能成功完成。请检查安装日志，修复问题后重试。"
    Abort ; 跳过完成页面
  NoInstallErrors:
    DetailPrint "安装成功完成，显示完成页面"
FunctionEnd