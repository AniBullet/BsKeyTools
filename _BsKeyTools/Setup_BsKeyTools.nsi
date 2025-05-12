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
!define SEC26 26 ; 2026
!define SEC25 25 ; 2025
!define SEC24 24 ; 2024
!define SEC23 23 ; 2023
!define SEC22 22 ; 2022
!define SEC21 21 ; 2021
!define SEC20 20 ; 2020
!define SEC19 19 ; 2019
!define SEC18 18 ; 2018
!define SEC17 17 ; 2017
!define SEC16 16 ; 2016
!define SEC15 15 ; 2015
!define SEC14 14 ; 2014
!define SEC13 13 ; 2013
!define SEC12 12 ; 2012
!define SEC11 11 ; 2011
!define SEC10 10 ; 2010
!define SEC09 9  ; 2009
!define SEC08 8  ; 2008
!define SEC9  90 ; 3dsMax 9

; 定义变量
var maxVer
var v9     ; 3dsMax 9
var v2008  ; 3dsMax 2008
var v2009  ; 3dsMax 2009
var v2010  ; 3dsMax 2010
var v2011  ; 3dsMax 2011
var v2012  ; 3dsMax 2012
var v2013  ; 3dsMax 2013
var v2014  ; 3dsMax 2014
var v2015  ; 3dsMax 2015
var v2016  ; 3dsMax 2016
var v2017  ; 3dsMax 2017
var v2018  ; 3dsMax 2018
var v2019  ; 3dsMax 2019
var v2020  ; 3dsMax 2020
var v2021  ; 3dsMax 2021
var v2022  ; 3dsMax 2022
var v2023  ; 3dsMax 2023
var v2024  ; 3dsMax 2024
var v2025  ; 3dsMax 2025
var v2026  ; 3dsMax 2026
var InstallMode ; 安装模式: 0=自动检测, 1=手动选择
var MAXPATH ; 手动选择的3dsMax安装路径

SetCompressor lzma

; ------ MUI 现代界面定义 (1.67 版本以上兼容) ------
!include "MUI2.nsh"
!include "LogicLib.nsh" ; 引入逻辑库
!include "Sections.nsh" ; 引入Sections库
!include "FileFunc.nsh" ; 引入文件功能库
!include "InstallOptions.nsh" ; 引入InstallOptions库

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
Page custom InstallModePage

; 手动选择Max路径页面（条件显示）
Page custom CustomPathPage CustomPathLeave

; 组件选择页面（自动模式时显示）
!define MUI_PAGE_CUSTOMFUNCTION_PRE ComponentPrePage
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
  ${If} ${VER_NAME} == "2026"
    ${If} $v2026 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2025"
    ${If} $v2025 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2024"
    ${If} $v2024 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2023"
    ${If} $v2023 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2022"
    ${If} $v2022 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2021"
    ${If} $v2021 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2020"
    ${If} $v2020 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2019"
    ${If} $v2019 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2018"
    ${If} $v2018 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2017"
    ${If} $v2017 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2016"
    ${If} $v2016 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2015"
    ${If} $v2015 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2014"
    ${If} $v2014 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2013"
    ${If} $v2013 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2012"
    ${If} $v2012 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2011"
    ${If} $v2011 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2010"
    ${If} $v2010 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2009"
    ${If} $v2009 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "2008"
    ${If} $v2008 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
  ${ElseIf} ${VER_NAME} == "9"
    ${If} $v9 != ""
      SectionSetText ${SEC_ID} "3dsMax ${VER_NAME}"
      SectionSetFlags ${SEC_ID} 1
    ${Else}
      SectionSetFlags ${SEC_ID} 0
      SectionSetText ${SEC_ID} ""
    ${EndIf}
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
  !insertmacro ShowVersionSection ${SEC26} "2026"
  !insertmacro ShowVersionSection ${SEC25} "2025"
  !insertmacro ShowVersionSection ${SEC24} "2024"
  !insertmacro ShowVersionSection ${SEC23} "2023"
  !insertmacro ShowVersionSection ${SEC22} "2022"
  !insertmacro ShowVersionSection ${SEC21} "2021"
  !insertmacro ShowVersionSection ${SEC20} "2020"
  !insertmacro ShowVersionSection ${SEC19} "2019"
  !insertmacro ShowVersionSection ${SEC18} "2018"
  !insertmacro ShowVersionSection ${SEC17} "2017"
  !insertmacro ShowVersionSection ${SEC16} "2016"
  !insertmacro ShowVersionSection ${SEC15} "2015"
  !insertmacro ShowVersionSection ${SEC14} "2014"
  !insertmacro ShowVersionSection ${SEC13} "2013"
  !insertmacro ShowVersionSection ${SEC12} "2012"
  !insertmacro ShowVersionSection ${SEC11} "2011"
  !insertmacro ShowVersionSection ${SEC10} "2010"
  !insertmacro ShowVersionSection ${SEC09} "2009"
  !insertmacro ShowVersionSection ${SEC08} "2008"
  !insertmacro ShowVersionSection ${SEC9} "9"
FunctionEnd

; 自定义函数 - 手动选择3dsMax路径页面
Function CustomPathPage
  ; 如果不是手动模式，跳过此页面
  ${If} $InstallMode != 1
    Abort
  ${EndIf}
  
  ; 显示自定义页面
  !insertmacro MUI_HEADER_TEXT "3dsMax 路径设置" "请指定3dsMax安装路径和版本。"
  
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
  
  ; 添加版本选择下拉菜单
  ${NSD_CreateLabel} 10 50 100 20 "3dsMax 版本:"
  Pop $0
  ${NSD_CreateDropList} 120 50 150 20 ""
  Pop $R1
  
  ; 添加版本选项
  ${NSD_CB_AddString} $R1 "3ds Max 2026"
  ${NSD_CB_AddString} $R1 "3ds Max 2025"
  ${NSD_CB_AddString} $R1 "3ds Max 2024"
  ${NSD_CB_AddString} $R1 "3ds Max 2023"
  ${NSD_CB_AddString} $R1 "3ds Max 2022"
  ${NSD_CB_AddString} $R1 "3ds Max 2021"
  ${NSD_CB_AddString} $R1 "3ds Max 2020"
  ${NSD_CB_AddString} $R1 "3ds Max 2019"
  ${NSD_CB_AddString} $R1 "3ds Max 2018"
  ${NSD_CB_AddString} $R1 "3ds Max 2017"
  ${NSD_CB_AddString} $R1 "3ds Max 2016"
  ${NSD_CB_AddString} $R1 "3ds Max 2015"
  ${NSD_CB_AddString} $R1 "3ds Max 2014"
  ${NSD_CB_AddString} $R1 "3ds Max 2013"
  ${NSD_CB_AddString} $R1 "3ds Max 2012"
  ${NSD_CB_AddString} $R1 "3ds Max 2011"
  ${NSD_CB_AddString} $R1 "3ds Max 2010"
  ${NSD_CB_AddString} $R1 "3ds Max 2009"
  ${NSD_CB_AddString} $R1 "3ds Max 2008"
  ${NSD_CB_AddString} $R1 "3ds Max 9"
  
  ; 默认选择最新版本
  ${NSD_CB_SelectString} $R1 "3ds Max 2026"
  
  ; 添加说明标签
  ${NSD_CreateLabel} 10 80 370 60 "请指定任意目录路径和对应的3dsMax版本。$\r$\n$\r$\n选择版本将决定使用哪个版本的插件文件。$\r$\n$\r$\n无需检查目录是否为3dsMax安装目录，可以是任意目录。"
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
    MessageBox MB_ICONEXCLAMATION|MB_OK "请指定安装路径。"
    Abort
  ${EndIf}
  
  ; 获取下拉列表的当前选择索引
  System::Call "user32::SendMessage(i $R1, i ${CB_GETCURSEL}, i 0, i 0) i .r0"
  
  ${If} $0 == ${CB_ERR}
    MessageBox MB_ICONEXCLAMATION|MB_OK "请选择3dsMax版本。"
    Abort
  ${EndIf}
  
  ; 根据索引值直接设置版本号
  ${If} $0 == 0
    StrCpy $R0 "2026"
  ${ElseIf} $0 == 1
    StrCpy $R0 "2025"
  ${ElseIf} $0 == 2
    StrCpy $R0 "2024"
  ${ElseIf} $0 == 3
    StrCpy $R0 "2023"
  ${ElseIf} $0 == 4
    StrCpy $R0 "2022"
  ${ElseIf} $0 == 5
    StrCpy $R0 "2021"
  ${ElseIf} $0 == 6
    StrCpy $R0 "2020"
  ${ElseIf} $0 == 7
    StrCpy $R0 "2019"
  ${ElseIf} $0 == 8
    StrCpy $R0 "2018"
  ${ElseIf} $0 == 9
    StrCpy $R0 "2017"
  ${ElseIf} $0 == 10
    StrCpy $R0 "2016"
  ${ElseIf} $0 == 11
    StrCpy $R0 "2015"
  ${ElseIf} $0 == 12
    StrCpy $R0 "2014"
  ${ElseIf} $0 == 13
    StrCpy $R0 "2013"
  ${ElseIf} $0 == 14
    StrCpy $R0 "2012"
  ${ElseIf} $0 == 15
    StrCpy $R0 "2011"
  ${ElseIf} $0 == 16
    StrCpy $R0 "2010"
  ${ElseIf} $0 == 17
    StrCpy $R0 "2009"
  ${ElseIf} $0 == 18
    StrCpy $R0 "2008"
  ${ElseIf} $0 == 19
    StrCpy $R0 "9"
  ${Else}
    StrCpy $R0 "2026" ; 默认使用最新版本
  ${EndIf}
  
  ; 确保路径以反斜杠结尾
  StrCpy $R5 $MAXPATH "" -1
  ${If} $R5 != "\"
    StrCpy $MAXPATH "$MAXPATH\"
  ${EndIf}
  
  DetailPrint "手动模式 - 安装路径: $MAXPATH"
  DetailPrint "手动模式 - 选择版本: $R0"
FunctionEnd

; 组件选择页面PrePage函数
Function ComponentPrePage
  ${If} $InstallMode == 1
    Abort ; 手动模式下跳过组件选择页面
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

Section "3dsMax 2026" ${SEC26}
  SetOutPath "$v2026"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2026\plugins\*.*"
SectionEnd

Section "3dsMax 2025" ${SEC25}
  SetOutPath "$v2025"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2025\plugins\*.*"
SectionEnd

Section "3dsMax 2024" ${SEC24}
  SetOutPath "$v2024"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2024\plugins\*.*"
SectionEnd

Section "3dsMax 2023" ${SEC23}
  SetOutPath "$v2023"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2023\plugins\*.*"
SectionEnd

Section "3dsMax 2022" ${SEC22}
  SetOutPath "$v2022"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2022\plugins\*.*"
SectionEnd

Section "3dsMax 2021" ${SEC21}
  SetOutPath "$v2021"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2021\plugins\*.*"
SectionEnd

Section "3dsMax 2020" ${SEC20}
  SetOutPath "$v2020"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2020\plugins\*.*"
SectionEnd

Section "3dsMax 2019" ${SEC19}
  SetOutPath "$v2019"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2019\plugins\*.*"
SectionEnd

Section "3dsMax 2018" ${SEC18}
  SetOutPath "$v2018"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2018\plugins\*.*"
SectionEnd

Section "3dsMax 2017" ${SEC17}
  SetOutPath "$v2017"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2017\plugins\*.*"
SectionEnd

Section "3dsMax 2016" ${SEC16}
  SetOutPath "$v2016"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2016\plugins\*.*"
SectionEnd

Section "3dsMax 2015" ${SEC15}
  SetOutPath "$v2015"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2015\plugins\*.*"
SectionEnd

Section "3dsMax 2014" ${SEC14}
  SetOutPath "$v2014"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2014\plugins\*.*"
SectionEnd

Section "3dsMax 2013" ${SEC13}
  SetOutPath "$v2013"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2013\plugins\*.*"
SectionEnd

Section "3dsMax 2012" ${SEC12}
  SetOutPath "$v2012"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2012\plugins\*.*"
SectionEnd

Section "3dsMax 2011" ${SEC11}
  SetOutPath "$v2011"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2011\plugins\*.*"
SectionEnd

Section "3dsMax 2010" ${SEC10}
  SetOutPath "$v2010"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2010\plugins\*.*"
SectionEnd

Section "3dsMax 2009" ${SEC09}
  SetOutPath "$v2009"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2009\plugins\*.*"
SectionEnd

Section "3dsMax 2008" ${SEC08}
  SetOutPath "$v2008"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\2008\plugins\*.*"
SectionEnd

Section "3dsMax 9" ${SEC9}
  SetOutPath "$v9"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts\*.*"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  File /r "${CURRENT_DIR}\GhostTrails\9\plugins\*.*"
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
  
  ; 使用在CustomPathLeave中保存的版本信息
  DetailPrint "使用版本: $R0"
  
  ; 设置输出目录
  SetOutPath "$MAXPATH"
  SetOverwrite on
  
  ; 复制到Scripts目录
  CreateDirectory "$MAXPATH\Scripts"
  SetOutPath "$MAXPATH\Scripts"
  File /r "${CURRENT_DIR}\Scripts\*.*"
  
  ; 复制到UI_ln目录
  CreateDirectory "$MAXPATH\UI_ln"
  SetOutPath "$MAXPATH\UI_ln"
  File /r "${CURRENT_DIR}\UI_ln\*.*"
  
  ; 复制到plugins目录 - 根据选择的版本
  CreateDirectory "$MAXPATH\plugins"
  SetOutPath "$MAXPATH\plugins"
  
  ${If} $R0 == "9"
    File /r "${CURRENT_DIR}\GhostTrails\9\plugins\*.*"
  ${ElseIf} $R0 == "2008"
    File /r "${CURRENT_DIR}\GhostTrails\2008\plugins\*.*"
  ${ElseIf} $R0 == "2009"
    File /r "${CURRENT_DIR}\GhostTrails\2009\plugins\*.*"
  ${ElseIf} $R0 == "2010"
    File /r "${CURRENT_DIR}\GhostTrails\2010\plugins\*.*"
  ${ElseIf} $R0 == "2011"
    File /r "${CURRENT_DIR}\GhostTrails\2011\plugins\*.*"
  ${ElseIf} $R0 == "2012"
    File /r "${CURRENT_DIR}\GhostTrails\2012\plugins\*.*"
  ${ElseIf} $R0 == "2013"
    File /r "${CURRENT_DIR}\GhostTrails\2013\plugins\*.*"
  ${ElseIf} $R0 == "2014"
    File /r "${CURRENT_DIR}\GhostTrails\2014\plugins\*.*"
  ${ElseIf} $R0 == "2015"
    File /r "${CURRENT_DIR}\GhostTrails\2015\plugins\*.*"
  ${ElseIf} $R0 == "2016"
    File /r "${CURRENT_DIR}\GhostTrails\2016\plugins\*.*"
  ${ElseIf} $R0 == "2017"
    File /r "${CURRENT_DIR}\GhostTrails\2017\plugins\*.*"
  ${ElseIf} $R0 == "2018"
    File /r "${CURRENT_DIR}\GhostTrails\2018\plugins\*.*"
  ${ElseIf} $R0 == "2019"
    File /r "${CURRENT_DIR}\GhostTrails\2019\plugins\*.*"
  ${ElseIf} $R0 == "2020"
    File /r "${CURRENT_DIR}\GhostTrails\2020\plugins\*.*"
  ${ElseIf} $R0 == "2021"
    File /r "${CURRENT_DIR}\GhostTrails\2021\plugins\*.*"
  ${ElseIf} $R0 == "2022"
    File /r "${CURRENT_DIR}\GhostTrails\2022\plugins\*.*"
  ${ElseIf} $R0 == "2023"
    File /r "${CURRENT_DIR}\GhostTrails\2023\plugins\*.*"
  ${ElseIf} $R0 == "2024"
    File /r "${CURRENT_DIR}\GhostTrails\2024\plugins\*.*"
  ${ElseIf} $R0 == "2025"
    File /r "${CURRENT_DIR}\GhostTrails\2025\plugins\*.*"
  ${ElseIf} $R0 == "2026"
    File /r "${CURRENT_DIR}\GhostTrails\2026\plugins\*.*"
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
  !insertmacro HideVersionSection ${SEC26}
  !insertmacro HideVersionSection ${SEC25}
  !insertmacro HideVersionSection ${SEC24}
  !insertmacro HideVersionSection ${SEC23}
  !insertmacro HideVersionSection ${SEC22}
  !insertmacro HideVersionSection ${SEC21}
  !insertmacro HideVersionSection ${SEC20}
  !insertmacro HideVersionSection ${SEC19}
  !insertmacro HideVersionSection ${SEC18}
  !insertmacro HideVersionSection ${SEC17}
  !insertmacro HideVersionSection ${SEC16}
  !insertmacro HideVersionSection ${SEC15}
  !insertmacro HideVersionSection ${SEC14}
  !insertmacro HideVersionSection ${SEC13}
  !insertmacro HideVersionSection ${SEC12}
  !insertmacro HideVersionSection ${SEC11}
  !insertmacro HideVersionSection ${SEC10}
  !insertmacro HideVersionSection ${SEC09}
  !insertmacro HideVersionSection ${SEC08}
  !insertmacro HideVersionSection ${SEC9}
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

; 在自动模式下始终隐藏手动安装选项
SectionSetText ${SEC_MANUAL} ""
SectionSetFlags ${SEC_MANUAL} 0

; 扫描已安装的max版本
DetailPrint "检测已安装的3dsMax版本..."

; MAX2026:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\28.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC26} 1
  StrCpy $v2026 $maxVer
${Else}
  SectionSetFlags ${SEC26} 0
  SectionSetText ${SEC26} ""
${EndIf}

; MAX2025:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\27.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC25} 1
  StrCpy $v2025 $maxVer
${Else}
  SectionSetFlags ${SEC25} 0
  SectionSetText ${SEC25} ""
${EndIf}

; MAX2024:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\26.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC24} 1
  StrCpy $v2024 $maxVer
${Else}
  SectionSetFlags ${SEC24} 0
  SectionSetText ${SEC24} ""
${EndIf}

; MAX2023:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\25.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC23} 1
  StrCpy $v2023 $maxVer
${Else}
  SectionSetFlags ${SEC23} 0
  SectionSetText ${SEC23} ""
${EndIf}

; MAX2022:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\24.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC22} 1
  StrCpy $v2022 $maxVer
${Else}
  SectionSetFlags ${SEC22} 0
  SectionSetText ${SEC22} ""
${EndIf}

; MAX2021:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\23.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC21} 1
  StrCpy $v2021 $maxVer
${Else}
  SectionSetFlags ${SEC21} 0
  SectionSetText ${SEC21} ""
${EndIf}

; MAX2020:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\22.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC20} 1
  StrCpy $v2020 $maxVer
${Else}
  SectionSetFlags ${SEC20} 0
  SectionSetText ${SEC20} ""
${EndIf}

; MAX2019:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\21.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC19} 1
  StrCpy $v2019 $maxVer
${Else}
  SectionSetFlags ${SEC19} 0
  SectionSetText ${SEC19} ""
${EndIf}

; MAX2018:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\20.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC18} 1
  StrCpy $v2018 $maxVer
${Else}
  SectionSetFlags ${SEC18} 0
  SectionSetText ${SEC18} ""
${EndIf}

; MAX2017:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\19.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC17} 1
  StrCpy $v2017 $maxVer
${Else}
  SectionSetFlags ${SEC17} 0
  SectionSetText ${SEC17} ""
${EndIf}

; MAX2016:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\18.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC16} 1
  StrCpy $v2016 $maxVer
${Else}
  SectionSetFlags ${SEC16} 0
  SectionSetText ${SEC16} ""
${EndIf}

; MAX2015:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\17.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC15} 1
  StrCpy $v2015 $maxVer
${Else}
  SectionSetFlags ${SEC15} 0
  SectionSetText ${SEC15} ""
${EndIf}

; MAX2014:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\16.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC14} 1
  StrCpy $v2014 $maxVer
${Else}
  SectionSetFlags ${SEC14} 0
  SectionSetText ${SEC14} ""
${EndIf}

; MAX2013:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\15.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC13} 1
  StrCpy $v2013 $maxVer
${Else}
  SectionSetFlags ${SEC13} 0
  SectionSetText ${SEC13} ""
${EndIf}

; MAX2012:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\14.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC12} 1
  StrCpy $v2012 $maxVer
${Else}
  SectionSetFlags ${SEC12} 0
  SectionSetText ${SEC12} ""
${EndIf}

; MAX2011:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\13.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC11} 1
  StrCpy $v2011 $maxVer
${Else}
  SectionSetFlags ${SEC11} 0
  SectionSetText ${SEC11} ""
${EndIf}

; MAX2010:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\12.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC10} 1
  StrCpy $v2010 $maxVer
${Else}
  SectionSetFlags ${SEC10} 0
  SectionSetText ${SEC10} ""
${EndIf}

; MAX2009:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\11.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC09} 1
  StrCpy $v2009 $maxVer
${Else}
  SectionSetFlags ${SEC09} 0
  SectionSetText ${SEC09} ""
${EndIf}

; MAX2008:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\10.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC08} 1
  StrCpy $v2008 $maxVer
${Else}
  SectionSetFlags ${SEC08} 0
  SectionSetText ${SEC08} ""
${EndIf}

; MAX9.0:
setRegView 64
ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\9.0" "Installdir"
${If} $maxVer != ""
  SectionSetFlags ${SEC9} 1
  StrCpy $v9 $maxVer
${Else}
  SectionSetFlags ${SEC9} 0
  SectionSetText ${SEC9} ""
${EndIf}

; 在自动模式下始终隐藏手动安装选项
SectionSetText ${SEC_MANUAL} ""
SectionSetFlags ${SEC_MANUAL} 0

FunctionEnd

; 版本描述
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC26} $v2026
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC25} $v2025
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC24} $v2024
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC23} $v2023
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC22} $v2022
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC21} $v2021
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC20} $v2020
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC19} $v2019
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC18} $v2018
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC17} $v2017
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC16} $v2016
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC15} $v2015
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC14} $v2014
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC13} $v2013
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC12} $v2012
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC11} $v2011
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC10} $v2010
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC09} $v2009
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC08} $v2008
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC9} $v9
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_MANUAL} $MAXPATH
!insertmacro MUI_FUNCTION_DESCRIPTION_END
