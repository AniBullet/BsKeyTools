; 添加Unicode支持
Unicode true

; 安装程序初始定义常量
!define PRODUCT_NAME "BsCleanVirus"
!define PRODUCT_VERSION "_v1.1"
!define PRODUCT_PUBLISHER "Bullet.S"
!define PRODUCT_WEB_SITE "anibullet.com"

; 自定义安装程序底部的文本
BrandingText "BsCleanVirus - 3dsMax 杀毒工具独立版"

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
!define SEC_ALL 21

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
!define MUI_WELCOMEFINISHPAGE_BITMAP ".\sideImg2.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP ".\logo.bmp"

!define MUI_TEXT_COMPONENTS_TITLE "选择版本"
!define MUI_TEXT_COMPONENTS_SUBTITLE "选择你想安装 $(^NameDA) 的 3dsMax 版本。"
!define MUI_INNERTEXT_COMPONENTS_DESCRIPTION_TITLE "安装路径"
!define MUI_INNERTEXT_COMPONENTS_DESCRIPTION_INFO "将光标悬停在版本名称之上，即可显示它的安装路径。"

; 欢迎页面
!insertmacro MUI_PAGE_WELCOME
!define MUI_TEXT_WELCOME_INFO_TITLE "欢迎安装 ${PRODUCT_NAME}${PRODUCT_VERSION}"
!define MUI_TEXT_WELCOME_INFO_TEXT "此程序将引导你完成 $(^NameDA) 的安装。$\r$\n$\r$\n这是一个独立的 3dsMax 杀毒工具，$\r$\n$\r$\n完全兼容 BsKeyTools【K 帧工具集】。$\r$\n$\r$\n在安装之前，建议先关闭所有 3dsMax 程序。$\r$\n$\r$\n这将确保安装程序能够更新所需的文件，$\r$\n$\r$\n从而避免在安装后打开工具失败报错。$\r$\n$\r$\n$_CLICK"

; 许可协议页面
!define MUI_INNERTEXT_LICENSE_TOP "要阅读协议的其余部分，请按键盘 [PgDn] 键向下翻页。"
!define MUI_INNERTEXT_LICENSE_BOTTOM "如果你接受许可证的条款，请点击 [我接受(I)] 继续安装。$\r$\n$\r$\n你必须在同意后才能安装 $(^NameDA) 。"
!define PARENT_DIR ".."
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
!define MUI_FINISHPAGE_TITLE_3LINES "BsCleanVirus 已成功安装"
!define MUI_FINISHPAGE_TEXT "$(^NameDA) 已经成功安装。$\r$\n$\r$\n启动方式：$\r$\n$\r$\n在 3dsMax 菜单栏选择 BsKeyTools -> 杀毒工具$\r$\n$\r$\n点击 [完成(F)] 关闭安装程序。"
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

; ------ MUI 现代界面定义结束 ------

; 自定义函数 - 安装模式选择页面
Function InstallModePage
  !insertmacro MUI_HEADER_TEXT "选择安装模式" "请选择自动检测安装路径或手动指定安装路径。"
  
  nsDialogs::Create 1018
  Pop $0
  
  ; 自动检测选项（默认选中）
  ${NSD_CreateRadioButton} 10 10 300 20 "自动检测 3dsMax 安装路径（推荐）"
  Pop $1
  StrCpy $R5 $1
  ${NSD_OnClick} $1 SetAutoMode
  
  ; 手动选择选项
  ${NSD_CreateRadioButton} 10 40 300 20 "手动指定 3dsMax 安装路径"
  Pop $2
  StrCpy $R6 $2
  ${NSD_OnClick} $2 SetManualMode
  
  ; 添加说明标签
  ${NSD_CreateLabel} 20 70 350 100 "自动检测模式将查找已安装的所有3dsMax版本，$\r$\n$\r$\n并允许你选择要安装到的版本。$\r$\n$\r$\n手动模式允许你指定一个特定的3dsMax安装路径进行安装。$\r$\n$\r$\n如果自动检测失败，请使用此选项。"
  Pop $0
  
  ; 根据当前选择模式设置界面显示状态
  ${If} $InstallMode == 1
    ${NSD_Check} $R6
    ${NSD_Uncheck} $R5
  ${Else}
    ${NSD_Check} $R5
    ${NSD_Uncheck} $R6
    StrCpy $InstallMode 0
  ${EndIf}
  
  nsDialogs::Show
FunctionEnd

Function SetManualMode
  StrCpy $InstallMode 1
  
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
  
  ${If} $R6 != ""
    ${NSD_Check} $R6
  ${EndIf}
  ${If} $R5 != ""
    ${NSD_Uncheck} $R5
  ${EndIf}
FunctionEnd

Function SetAutoMode
  StrCpy $InstallMode 0
  
  DetailPrint "切换到自动检测模式"
  DetailPrint "隐藏手动安装Section"
  SectionSetText ${SEC_MANUAL} ""
  SectionSetFlags ${SEC_MANUAL} 0
  
  DetailPrint "恢复显示自动检测到的版本"
  
  StrCpy $R0 0
  
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
  
  ${If} $R0 == 0
    DetailPrint "未检测到任何3dsMax版本，将切换到手动安装模式"
    MessageBox MB_ICONINFORMATION|MB_OK "未检测到任何3dsMax版本。将切换到手动安装模式。"
    StrCpy $InstallMode 1
  ${Else}
    DetailPrint "检测到 $R0 个3dsMax版本"
    
    ${If} $R5 != ""
      ${NSD_Check} $R5
    ${EndIf}
    ${If} $R6 != ""
      ${NSD_Uncheck} $R6
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
  ${NSD_CreateLabel} 10 70 390 60 "请指定要安装的3dsMax根目录，$\r$\n$\r$\n并选择对应的3dsMax版本以安装适合该版本的插件。$\r$\n$\r$\n（比如：C:\Program Files\Autodesk\3ds Max 2026）"
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
  
  ; 获取下拉列表选择的版本
  SendMessage $DropListHwnd ${CB_GETCURSEL} 0 0 $0
  
  ${If} $0 == CB_ERR
    MessageBox MB_ICONEXCLAMATION|MB_OK "请选择3dsMax版本。"
    Abort
  ${EndIf}
  
  System::Call "user32::SendMessage(i $DropListHwnd, i ${CB_GETLBTEXT}, i r0, t .r1)"
  StrCpy $SelectedVersion $1
  
  ${If} $SelectedVersion == ""
    MessageBox MB_ICONEXCLAMATION|MB_OK "请选择3dsMax版本。"
    Abort
  ${EndIf}
FunctionEnd

Name "${PRODUCT_NAME}${PRODUCT_VERSION}"
OutFile "BsCleanVirus_Standalone.exe"
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

; 统一安装函数 - 只安装 BsCleanVirus 相关文件
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
  
  ; Scripts\BulletScripts 目录
  CreateDirectory "$R0Scripts"
  CreateDirectory "$R0Scripts\BulletScripts"
  CreateDirectory "$R0Scripts\BulletScripts\ScanVirus"
  CreateDirectory "$R0Scripts\BulletScripts\StartupMS"
  CreateDirectory "$R0Scripts\BulletScripts\Lang"
  CreateDirectory "$R0Scripts\Startup"
  
  ClearErrors
  
  ; 复制核心文件
  DetailPrint "正在复制 BsCleanVirus 核心文件..."
  SetOutPath "$R0Scripts\BulletScripts"
  File "Scripts\BulletScripts\BsCleanVirus.ms"
  File "Scripts\BulletScripts\fnSaveLoadConfig.ms"
  File "Scripts\BulletScripts\fnGetColorTheme.ms"
  
  ${If} ${Errors}
    MessageBox MB_ICONSTOP|MB_OK "复制核心文件失败，安装中止，可能需要关闭3dsMax后重试！"
    SetErrors
    Abort "安装失败：复制核心文件失败"
  ${EndIf}
  
  ; 复制病毒特征库
  DetailPrint "正在复制病毒特征库..."
  SetOutPath "$R0Scripts\BulletScripts\ScanVirus"
  File "Scripts\BulletScripts\ScanVirus\*.mcr"
  
  ${If} ${Errors}
    MessageBox MB_ICONSTOP|MB_OK "复制病毒特征库失败，安装中止，可能需要关闭3dsMax后重试！"
    SetErrors
    Abort "安装失败：复制病毒特征库失败"
  ${EndIf}
  
  ; 复制启动脚本
  DetailPrint "正在复制启动脚本..."
  SetOutPath "$R0Scripts\BulletScripts\StartupMS"
  File "Scripts\BulletScripts\StartupMS\BsCleanVirusStartup.ms"
  
  SetOutPath "$R0Scripts\Startup"
  File "Scripts\Startup\00.ms"
  File "Scripts\Startup\BsCleanVirusStartup.ms"
  File "Scripts\Startup\BsKeyToolsMacro.ms"
  File "Scripts\Startup\BsKeyToolsMenuBar.ms"
  
  ${If} ${Errors}
    DetailPrint "注意：复制启动脚本时遇到问题，可能文件已存在。"
  ${EndIf}
  
  ; 复制语言文件（可选）
  DetailPrint "正在复制语言文件..."
  SetOutPath "$R0Scripts\BulletScripts\Lang"
  File /nonfatal "Scripts\BulletScripts\Lang\*.lng"
  
  DetailPrint "BsCleanVirus 安装完成到 3dsMax $R9"
FunctionEnd

Section "-InstallSelectedVersions"
  ${If} $InstallMode == 1
    Return
  ${EndIf}
SectionEnd

; 各版本安装Section
Section "3dsMax 2026" ${SEC_2026}
  SectionGetFlags ${SEC_2026} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2026"
    StrCpy $R8 $v2026
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2025" ${SEC_2025}
  SectionGetFlags ${SEC_2025} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2025"
    StrCpy $R8 $v2025
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2024" ${SEC_2024}
  SectionGetFlags ${SEC_2024} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2024"
    StrCpy $R8 $v2024
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2023" ${SEC_2023}
  SectionGetFlags ${SEC_2023} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2023"
    StrCpy $R8 $v2023
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2022" ${SEC_2022}
  SectionGetFlags ${SEC_2022} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2022"
    StrCpy $R8 $v2022
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2021" ${SEC_2021}
  SectionGetFlags ${SEC_2021} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2021"
    StrCpy $R8 $v2021
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2020" ${SEC_2020}
  SectionGetFlags ${SEC_2020} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2020"
    StrCpy $R8 $v2020
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2019" ${SEC_2019}
  SectionGetFlags ${SEC_2019} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2019"
    StrCpy $R8 $v2019
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2018" ${SEC_2018}
  SectionGetFlags ${SEC_2018} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2018"
    StrCpy $R8 $v2018
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2017" ${SEC_2017}
  SectionGetFlags ${SEC_2017} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2017"
    StrCpy $R8 $v2017
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2016" ${SEC_2016}
  SectionGetFlags ${SEC_2016} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2016"
    StrCpy $R8 $v2016
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2015" ${SEC_2015}
  SectionGetFlags ${SEC_2015} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2015"
    StrCpy $R8 $v2015
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2014" ${SEC_2014}
  SectionGetFlags ${SEC_2014} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2014"
    StrCpy $R8 $v2014
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2013" ${SEC_2013}
  SectionGetFlags ${SEC_2013} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2013"
    StrCpy $R8 $v2013
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2012" ${SEC_2012}
  SectionGetFlags ${SEC_2012} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2012"
    StrCpy $R8 $v2012
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2011" ${SEC_2011}
  SectionGetFlags ${SEC_2011} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2011"
    StrCpy $R8 $v2011
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2010" ${SEC_2010}
  SectionGetFlags ${SEC_2010} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2010"
    StrCpy $R8 $v2010
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2009" ${SEC_2009}
  SectionGetFlags ${SEC_2009} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2009"
    StrCpy $R8 $v2009
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 2008" ${SEC_2008}
  SectionGetFlags ${SEC_2008} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "2008"
    StrCpy $R8 $v2008
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

Section "3dsMax 9" ${SEC_9}
  SectionGetFlags ${SEC_9} $0
  IntOp $0 $0 & ${SECTION_SELECTED}
  ${If} $0 == ${SECTION_SELECTED}
    StrCpy $R9 "9"
    StrCpy $R8 $v9
    Call InstallVersionFiles
  ${EndIf}
SectionEnd

; 当安装程序初始化时执行
Function .onInit
!insertmacro MUI_LANGDLL_DISPLAY

; 检查 3dsmax.exe 是否已运行
nsProcess::_FindProcess "3dsmax.exe"
Pop $R0
${If} $R0 = 0
  MessageBox MB_ICONEXCLAMATION|MB_OK "BsCleanVirus 安装程序检测到 3dsmax.exe 正在运行中！$\n$\n安装可能会导致工具异常，请先关闭 3dsMax 再次打开本安装程序。$\n$\n如果你没有打开，可能是残留进程，建议手动关闭一下~"
${EndIf}
  
; 初始化变量
StrCpy $InstallMode 0
StrCpy $MAXPATH ""

; 检测所有版本的3dsMax
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

; 手动安装Section
Section "-手动安装" ${SEC_MANUAL}
  ${If} $InstallMode != 1
    Return
  ${EndIf}
  
  ${If} $MAXPATH == ""
    MessageBox MB_ICONSTOP|MB_OK "错误：手动安装路径为空，无法完成安装。"
    SetErrors
    Abort "安装失败：手动安装路径为空"
  ${EndIf}
  
  Push "$MAXPATH"
  Call AddBackslash
  Pop $R0
  
  ${If} $SelectedVersion == ""
    MessageBox MB_ICONSTOP|MB_OK "错误：未选择3dsMax版本，无法完成安装。"
    SetErrors
    Abort "安装失败：未选择3dsMax版本"
  ${EndIf}
  
  StrCpy $1 $SelectedVersion 6 0
  ${If} $1 == "3dsMax"
    StrCpy $R2 $SelectedVersion "" 7
  ${Else}
    StrCpy $R2 "2024"
  ${EndIf}
  
  StrCpy $R9 $R2
  StrCpy $R8 $R0
  Call InstallVersionFiles
SectionEnd

; 清理Section
Section "-Cleanup" ${SEC_ALL}
  DetailPrint "BsCleanVirus 安装完成"
  DetailPrint "在 BsKeyTools 菜单中的“杀毒工具”启动面板"
  DetailPrint "或 F11 中运行以下命令来启动杀毒工具面板："
  DetailPrint 'FileIn (getDir #scripts + "\\BulletScripts\\BsCleanVirus.ms")'
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
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; 版本检测函数
Function DetectMaxVersion
  ; 参数:
  ; $R9 - 版本号(如"2024")
  ; $R8 - 注册表路径
  ; $R7 - 对应的Section ID
  
  setRegView 64
  ReadRegStr $0 HKLM "$R8" "Installdir"
  
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
    DetailPrint "安装过程中发生错误，不显示完成页面"
    MessageBox MB_ICONSTOP|MB_OK "安装未能成功完成。请检查安装日志，修复问题后重试。"
    Abort
  NoInstallErrors:
    DetailPrint "安装成功完成，显示完成页面"
FunctionEnd

