; 此脚本使用 HM VNISEdit 脚本编辑器向导生成

; 添加Unicode支持
Unicode true

; 安装程序初始定义常量
!define PRODUCT_NAME "BsKeyTools"
!define PRODUCT_VERSION "_v1.1.0"
!define PRODUCT_PUBLISHER "Bullet.S"
!define PRODUCT_WEB_SITE "anibullet.com"

; 定义版本范围和数量
!define VERSION_COUNT 18  ; 当前支持的最大版本数量
!define MIN_VERSION 9     ; 最小版本号(3dsMax 9)
!define MAX_VERSION 2026  ; 最大版本号

; 定义版本信息
!define VERSION_9    9    ; 为了统一命名格式
!define VERSION_2008 2008
!define VERSION_2009 2009
!define VERSION_2010 2010
!define VERSION_2011 2011
!define VERSION_2012 2012
!define VERSION_2013 2013
!define VERSION_2014 2014
!define VERSION_2015 2015
!define VERSION_2016 2016
!define VERSION_2017 2017
!define VERSION_2018 2018
!define VERSION_2019 2019
!define VERSION_2020 2020
!define VERSION_2021 2021
!define VERSION_2022 2022
!define VERSION_2023 2023
!define VERSION_2024 2024
!define VERSION_2025 2025
!define VERSION_2026 2026

; 定义版本对应的注册表版本号
!define REG_VERSION_9    "9.0"
!define REG_VERSION_2008 "10.0"
!define REG_VERSION_2009 "11.0"
!define REG_VERSION_2010 "12.0"
!define REG_VERSION_2011 "13.0"
!define REG_VERSION_2012 "14.0"
!define REG_VERSION_2013 "15.0"
!define REG_VERSION_2014 "16.0"
!define REG_VERSION_2015 "17.0"
!define REG_VERSION_2016 "18.0"
!define REG_VERSION_2017 "19.0"
!define REG_VERSION_2018 "20.0"
!define REG_VERSION_2019 "21.0"
!define REG_VERSION_2020 "22.0"
!define REG_VERSION_2021 "23.0"
!define REG_VERSION_2022 "24.0"
!define REG_VERSION_2023 "25.0"
!define REG_VERSION_2024 "26.0"
!define REG_VERSION_2025 "27.0"
!define REG_VERSION_2026 "28.0"

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
var maxVer
var InstallMode ; 安装模式: 0=自动检测, 1=手动选择
var MAXPATH ; 手动选择的3dsMax安装路径

; 为每个版本定义安装路径变量
!macro DefinePathVars
  var INSTPATH_9
  var INSTPATH_2008
  var INSTPATH_2009
  var INSTPATH_2010
  var INSTPATH_2011
  var INSTPATH_2012
  var INSTPATH_2013
  var INSTPATH_2014
  var INSTPATH_2015
  var INSTPATH_2016
  var INSTPATH_2017
  var INSTPATH_2018
  var INSTPATH_2019
  var INSTPATH_2020
  var INSTPATH_2021
  var INSTPATH_2022
  var INSTPATH_2023
  var INSTPATH_2024
  var INSTPATH_2025
  var INSTPATH_2026
!macroend

!insertmacro DefinePathVars

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

Function SetAutoMode
  StrCpy $InstallMode 0
FunctionEnd

Function SetManualMode
  StrCpy $InstallMode 1
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

; 定义安装版本Section的宏，用于生成所有版本的安装部分
!macro VersionSection VERSION SEC_ID VAR_NAME
Section "3dsMax ${VERSION}" ${SEC_ID}
  SetOutPath "${VAR_NAME}"
  SetOverwrite on
  File /r "${CURRENT_DIR}\Scripts"
  File /r "${CURRENT_DIR}\UI_ln"
  ${If} ${VERSION} == 9
    File /r "${CURRENT_DIR}\GhostTrails\9\plugins"
  ${Else}
    File /r "${CURRENT_DIR}\GhostTrails\${VERSION}\plugins"
  ${EndIf}
SectionEnd
!macroend

; 使用宏生成所有版本的Section
!insertmacro VersionSection "${VERSION_2026}" ${SEC_2026} "INSTPATH_2026"
!insertmacro VersionSection "${VERSION_2025}" ${SEC_2025} "INSTPATH_2025"
!insertmacro VersionSection "${VERSION_2024}" ${SEC_2024} "INSTPATH_2024"
!insertmacro VersionSection "${VERSION_2023}" ${SEC_2023} "INSTPATH_2023"
!insertmacro VersionSection "${VERSION_2022}" ${SEC_2022} "INSTPATH_2022"
!insertmacro VersionSection "${VERSION_2021}" ${SEC_2021} "INSTPATH_2021"
!insertmacro VersionSection "${VERSION_2020}" ${SEC_2020} "INSTPATH_2020"
!insertmacro VersionSection "${VERSION_2019}" ${SEC_2019} "INSTPATH_2019"
!insertmacro VersionSection "${VERSION_2018}" ${SEC_2018} "INSTPATH_2018"
!insertmacro VersionSection "${VERSION_2017}" ${SEC_2017} "INSTPATH_2017"
!insertmacro VersionSection "${VERSION_2016}" ${SEC_2016} "INSTPATH_2016"
!insertmacro VersionSection "${VERSION_2015}" ${SEC_2015} "INSTPATH_2015"
!insertmacro VersionSection "${VERSION_2014}" ${SEC_2014} "INSTPATH_2014"
!insertmacro VersionSection "${VERSION_2013}" ${SEC_2013} "INSTPATH_2013"
!insertmacro VersionSection "${VERSION_2012}" ${SEC_2012} "INSTPATH_2012"
!insertmacro VersionSection "${VERSION_2011}" ${SEC_2011} "INSTPATH_2011"
!insertmacro VersionSection "${VERSION_2010}" ${SEC_2010} "INSTPATH_2010"
!insertmacro VersionSection "${VERSION_2009}" ${SEC_2009} "INSTPATH_2009"
!insertmacro VersionSection "${VERSION_2008}" ${SEC_2008} "INSTPATH_2008"
!insertmacro VersionSection "${VERSION_9}"    ${SEC_9}    "INSTPATH_9"

; 手动安装Section
Section "手动安装" ${SEC_MANUAL}
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

;检查 3dsmax.exe 是否已运行
nsProcess::_FindProcess "3dsmax.exe"
Pop $R0
${If} $R0 = 0
  MessageBox MB_ICONEXCLAMATION|MB_OK "BsKeyTools 安装程序检测到 3dsmax.exe 正在运行中！$\n$\n安装可能会导致工具异常，请先关闭 3dsMax 再次打开本安装程序。$\n$\n如果你没有打开，可能是残留进程，建议手动关闭一下~"
${EndIf}

; 初始化变量
StrCpy $InstallMode 0  ; 默认为自动模式
StrCpy $MAXPATH ""     ; 初始化手动路径变量

; 定义检测Max版本的宏
!macro FindMaxVersion VERSION REG_VER VAR_NAME SECTION_ID
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\${REG_VER}" "Installdir"
  ${If} $maxVer != ""
    StrCpy $${VAR_NAME} $maxVer
    ; 如果检测到版本，显示Section并选中
    SectionSetText ${SECTION_ID} "3dsMax ${VERSION}"
    SectionSetFlags ${SECTION_ID} ${SF_SELECTED}
  ${Else}
    StrCpy $${VAR_NAME} ""
    ; 如果没有检测到版本，隐藏Section
    SectionSetText ${SECTION_ID} ""
    SectionSetFlags ${SECTION_ID} 0
  ${EndIf}
!macroend

; 使用宏来检测所有已安装的Max版本
!insertmacro FindMaxVersion "${VERSION_2026}" "${REG_VERSION_2026}" "INSTPATH_2026" ${SEC_2026}
!insertmacro FindMaxVersion "${VERSION_2025}" "${REG_VERSION_2025}" "INSTPATH_2025" ${SEC_2025}
!insertmacro FindMaxVersion "${VERSION_2024}" "${REG_VERSION_2024}" "INSTPATH_2024" ${SEC_2024}
!insertmacro FindMaxVersion "${VERSION_2023}" "${REG_VERSION_2023}" "INSTPATH_2023" ${SEC_2023}
!insertmacro FindMaxVersion "${VERSION_2022}" "${REG_VERSION_2022}" "INSTPATH_2022" ${SEC_2022}
!insertmacro FindMaxVersion "${VERSION_2021}" "${REG_VERSION_2021}" "INSTPATH_2021" ${SEC_2021}
!insertmacro FindMaxVersion "${VERSION_2020}" "${REG_VERSION_2020}" "INSTPATH_2020" ${SEC_2020}
!insertmacro FindMaxVersion "${VERSION_2019}" "${REG_VERSION_2019}" "INSTPATH_2019" ${SEC_2019}
!insertmacro FindMaxVersion "${VERSION_2018}" "${REG_VERSION_2018}" "INSTPATH_2018" ${SEC_2018}
!insertmacro FindMaxVersion "${VERSION_2017}" "${REG_VERSION_2017}" "INSTPATH_2017" ${SEC_2017}
!insertmacro FindMaxVersion "${VERSION_2016}" "${REG_VERSION_2016}" "INSTPATH_2016" ${SEC_2016}
!insertmacro FindMaxVersion "${VERSION_2015}" "${REG_VERSION_2015}" "INSTPATH_2015" ${SEC_2015}
!insertmacro FindMaxVersion "${VERSION_2014}" "${REG_VERSION_2014}" "INSTPATH_2014" ${SEC_2014}
!insertmacro FindMaxVersion "${VERSION_2013}" "${REG_VERSION_2013}" "INSTPATH_2013" ${SEC_2013}
!insertmacro FindMaxVersion "${VERSION_2012}" "${REG_VERSION_2012}" "INSTPATH_2012" ${SEC_2012}
!insertmacro FindMaxVersion "${VERSION_2011}" "${REG_VERSION_2011}" "INSTPATH_2011" ${SEC_2011}
!insertmacro FindMaxVersion "${VERSION_2010}" "${REG_VERSION_2010}" "INSTPATH_2010" ${SEC_2010}
!insertmacro FindMaxVersion "${VERSION_2009}" "${REG_VERSION_2009}" "INSTPATH_2009" ${SEC_2009}
!insertmacro FindMaxVersion "${VERSION_2008}" "${REG_VERSION_2008}" "INSTPATH_2008" ${SEC_2008}
!insertmacro FindMaxVersion "${VERSION_9}"    "${REG_VERSION_9}"    "INSTPATH_9"    ${SEC_9}

; 预先隐藏手动安装Section
SectionSetText ${SEC_MANUAL} ""
SectionSetFlags ${SEC_MANUAL} 0

FunctionEnd

Function .onSelChange
  ; 处理选择变化
  ${If} $InstallMode == 1
    ; 显示手动安装Section，隐藏所有自动版本
    SectionSetText ${SEC_MANUAL} "手动安装到: $MAXPATH"
    SectionSetFlags ${SEC_MANUAL} ${SF_SELECTED}
    
    ; 隐藏所有自动检测版本
    SectionSetText ${SEC_2026} ""
    SectionSetText ${SEC_2025} ""
    SectionSetText ${SEC_2024} ""
    SectionSetText ${SEC_2023} ""
    SectionSetText ${SEC_2022} ""
    SectionSetText ${SEC_2021} ""
    SectionSetText ${SEC_2020} ""
    SectionSetText ${SEC_2019} ""
    SectionSetText ${SEC_2018} ""
    SectionSetText ${SEC_2017} ""
    SectionSetText ${SEC_2016} ""
    SectionSetText ${SEC_2015} ""
    SectionSetText ${SEC_2014} ""
    SectionSetText ${SEC_2013} ""
    SectionSetText ${SEC_2012} ""
    SectionSetText ${SEC_2011} ""
    SectionSetText ${SEC_2010} ""
    SectionSetText ${SEC_2009} ""
    SectionSetText ${SEC_2008} ""
    SectionSetText ${SEC_9} ""
  ${Else}
    ; 隐藏手动安装Section
    SectionSetText ${SEC_MANUAL} ""
    SectionSetFlags ${SEC_MANUAL} 0
    
    ; 重新显示已安装的版本
    !macro RefreshVersionSection VERSION REG_VER VAR_NAME SECTION_ID
      ${If} $${VAR_NAME} != ""
        SectionSetText ${SECTION_ID} "3dsMax ${VERSION}"
        SectionSetFlags ${SECTION_ID} ${SF_SELECTED}
      ${Else}
        SectionSetText ${SECTION_ID} ""
        SectionSetFlags ${SECTION_ID} 0
      ${EndIf}
    !macroend
    
    !insertmacro RefreshVersionSection "${VERSION_2026}" "${REG_VERSION_2026}" "INSTPATH_2026" ${SEC_2026}
    !insertmacro RefreshVersionSection "${VERSION_2025}" "${REG_VERSION_2025}" "INSTPATH_2025" ${SEC_2025}
    !insertmacro RefreshVersionSection "${VERSION_2024}" "${REG_VERSION_2024}" "INSTPATH_2024" ${SEC_2024}
    !insertmacro RefreshVersionSection "${VERSION_2023}" "${REG_VERSION_2023}" "INSTPATH_2023" ${SEC_2023}
    !insertmacro RefreshVersionSection "${VERSION_2022}" "${REG_VERSION_2022}" "INSTPATH_2022" ${SEC_2022}
    !insertmacro RefreshVersionSection "${VERSION_2021}" "${REG_VERSION_2021}" "INSTPATH_2021" ${SEC_2021}
    !insertmacro RefreshVersionSection "${VERSION_2020}" "${REG_VERSION_2020}" "INSTPATH_2020" ${SEC_2020}
    !insertmacro RefreshVersionSection "${VERSION_2019}" "${REG_VERSION_2019}" "INSTPATH_2019" ${SEC_2019}
    !insertmacro RefreshVersionSection "${VERSION_2018}" "${REG_VERSION_2018}" "INSTPATH_2018" ${SEC_2018}
    !insertmacro RefreshVersionSection "${VERSION_2017}" "${REG_VERSION_2017}" "INSTPATH_2017" ${SEC_2017}
    !insertmacro RefreshVersionSection "${VERSION_2016}" "${REG_VERSION_2016}" "INSTPATH_2016" ${SEC_2016}
    !insertmacro RefreshVersionSection "${VERSION_2015}" "${REG_VERSION_2015}" "INSTPATH_2015" ${SEC_2015}
    !insertmacro RefreshVersionSection "${VERSION_2014}" "${REG_VERSION_2014}" "INSTPATH_2014" ${SEC_2014}
    !insertmacro RefreshVersionSection "${VERSION_2013}" "${REG_VERSION_2013}" "INSTPATH_2013" ${SEC_2013}
    !insertmacro RefreshVersionSection "${VERSION_2012}" "${REG_VERSION_2012}" "INSTPATH_2012" ${SEC_2012}
    !insertmacro RefreshVersionSection "${VERSION_2011}" "${REG_VERSION_2011}" "INSTPATH_2011" ${SEC_2011}
    !insertmacro RefreshVersionSection "${VERSION_2010}" "${REG_VERSION_2010}" "INSTPATH_2010" ${SEC_2010}
    !insertmacro RefreshVersionSection "${VERSION_2009}" "${REG_VERSION_2009}" "INSTPATH_2009" ${SEC_2009}
    !insertmacro RefreshVersionSection "${VERSION_2008}" "${REG_VERSION_2008}" "INSTPATH_2008" ${SEC_2008}
    !insertmacro RefreshVersionSection "${VERSION_9}"    "${REG_VERSION_9}"    "INSTPATH_9"    ${SEC_9}
  ${EndIf}
FunctionEnd

; 定义显示安装路径的宏
!macro DescSection SEC_ID VAR_NAME
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_ID} $${VAR_NAME}
!macroend

; 版本描述
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2026} "$INSTPATH_2026"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2025} "$INSTPATH_2025"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2024} "$INSTPATH_2024"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2023} "$INSTPATH_2023"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2022} "$INSTPATH_2022"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2021} "$INSTPATH_2021"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2020} "$INSTPATH_2020"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2019} "$INSTPATH_2019"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2018} "$INSTPATH_2018"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2017} "$INSTPATH_2017"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2016} "$INSTPATH_2016"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2015} "$INSTPATH_2015"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2014} "$INSTPATH_2014"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2013} "$INSTPATH_2013"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2012} "$INSTPATH_2012"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2011} "$INSTPATH_2011"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2010} "$INSTPATH_2010"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2009} "$INSTPATH_2009"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_2008} "$INSTPATH_2008"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_9} "$INSTPATH_9"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_MANUAL} "$MAXPATH"
!insertmacro MUI_FUNCTION_DESCRIPTION_END
