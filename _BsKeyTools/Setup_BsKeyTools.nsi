; 此脚本使用 HM VNISEdit 脚本编辑器向导生成

; 添加Unicode支持
Unicode true

; 安装程序初始定义常量
!define PRODUCT_NAME "BsKeyTools"
!define PRODUCT_VERSION "_v1.0.7"
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
!define SEC_9    "SEC01"
!define SEC_2008 "SEC02"
!define SEC_2009 "SEC03"
!define SEC_2010 "SEC04"
!define SEC_2011 "SEC05"
!define SEC_2012 "SEC06"
!define SEC_2013 "SEC07"
!define SEC_2014 "SEC08"
!define SEC_2015 "SEC09"
!define SEC_2016 "SEC10"
!define SEC_2017 "SEC11"
!define SEC_2018 "SEC12"
!define SEC_2019 "SEC13"
!define SEC_2020 "SEC14"
!define SEC_2021 "SEC15"
!define SEC_2022 "SEC16"
!define SEC_2023 "SEC17"
!define SEC_2024 "SEC18"
!define SEC_2025 "SEC19"
!define SEC_2026 "SEC20"

; 定义变量
var maxVer
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
; 组件选择页面
!insertmacro MUI_PAGE_COMPONENTS
!define MUI_TEXT_COMPONENTS_TITLE "选择版本"
!define MUI_TEXT_COMPONENTS_SUBTITLE "选择你想安装 $(^NameDA) 的 3dsMax 版本。"
!define MUI_INNERTEXT_COMPONENTS_DESCRIPTION_TITLE "安装路径"
!define MUI_INNERTEXT_COMPONENTS_DESCRIPTION_INFO "将光标悬停在版本名称之上，即可显示它的安装路径。"
ComponentText "请勾选你想安装到的版本，并取消勾选你不想安装的版本。 $\r$\n$\r$\n$_CLICK" "" "选定安装的版本: "

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

Name "${PRODUCT_NAME}${PRODUCT_VERSION}"
OutFile "_BsKeyTools.exe"
ShowInstDetails show
ShowUnInstDetails show

; 定义安装版本Section的宏，用于生成所有版本的安装部分
!macro VersionSection VERSION SEC_ID VAR_NAME
Section "3dsMax ${VERSION}" ${SEC_ID}
  SetOutPath "$${VAR_NAME}"
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
!insertmacro VersionSection "${VERSION_2026}" "${SEC_2026}" "INSTPATH_2026"
!insertmacro VersionSection "${VERSION_2025}" "${SEC_2025}" "INSTPATH_2025"
!insertmacro VersionSection "${VERSION_2024}" "${SEC_2024}" "INSTPATH_2024"
!insertmacro VersionSection "${VERSION_2023}" "${SEC_2023}" "INSTPATH_2023"
!insertmacro VersionSection "${VERSION_2022}" "${SEC_2022}" "INSTPATH_2022"
!insertmacro VersionSection "${VERSION_2021}" "${SEC_2021}" "INSTPATH_2021"
!insertmacro VersionSection "${VERSION_2020}" "${SEC_2020}" "INSTPATH_2020"
!insertmacro VersionSection "${VERSION_2019}" "${SEC_2019}" "INSTPATH_2019"
!insertmacro VersionSection "${VERSION_2018}" "${SEC_2018}" "INSTPATH_2018"
!insertmacro VersionSection "${VERSION_2017}" "${SEC_2017}" "INSTPATH_2017"
!insertmacro VersionSection "${VERSION_2016}" "${SEC_2016}" "INSTPATH_2016"
!insertmacro VersionSection "${VERSION_2015}" "${SEC_2015}" "INSTPATH_2015"
!insertmacro VersionSection "${VERSION_2014}" "${SEC_2014}" "INSTPATH_2014"
!insertmacro VersionSection "${VERSION_2013}" "${SEC_2013}" "INSTPATH_2013"
!insertmacro VersionSection "${VERSION_2012}" "${SEC_2012}" "INSTPATH_2012"
!insertmacro VersionSection "${VERSION_2011}" "${SEC_2011}" "INSTPATH_2011"
!insertmacro VersionSection "${VERSION_2010}" "${SEC_2010}" "INSTPATH_2010"
!insertmacro VersionSection "${VERSION_2009}" "${SEC_2009}" "INSTPATH_2009"
!insertmacro VersionSection "${VERSION_2008}" "${SEC_2008}" "INSTPATH_2008"
!insertmacro VersionSection "${VERSION_9}"    "${SEC_9}"    "INSTPATH_9"

Function .onInit

!insertmacro MUI_LANGDLL_DISPLAY

;检查 3dsmax.exe 是否已运行
nsProcess::_FindProcess "3dsmax.exe"
Pop $R0
${If} $R0 = 0
  MessageBox MB_ICONEXCLAMATION|MB_OK "BsKeyTools 安装程序检测到 3dsmax.exe 正在运行中！$\n$\n安装可能会导致工具异常，请先关闭 3dsMax 再次打开本安装程序。$\n$\n如果你没有打开，可能是残留进程，建议手动关闭一下~"
${EndIf}

; 定义检测Max版本的宏
!macro FindMaxVersion VERSION REG_VER VAR_NAME
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\${REG_VER}" "Installdir"
  ${If} $maxVer != ""
    StrCpy $${VAR_NAME} $maxVer
  ${Else}
    StrCpy $${VAR_NAME} ""
  ${EndIf}
!macroend

; 使用宏来检测所有已安装的Max版本
!insertmacro FindMaxVersion "${VERSION_2026}" "${REG_VERSION_2026}" "INSTPATH_2026"
!insertmacro FindMaxVersion "${VERSION_2025}" "${REG_VERSION_2025}" "INSTPATH_2025"
!insertmacro FindMaxVersion "${VERSION_2024}" "${REG_VERSION_2024}" "INSTPATH_2024"
!insertmacro FindMaxVersion "${VERSION_2023}" "${REG_VERSION_2023}" "INSTPATH_2023"
!insertmacro FindMaxVersion "${VERSION_2022}" "${REG_VERSION_2022}" "INSTPATH_2022"
!insertmacro FindMaxVersion "${VERSION_2021}" "${REG_VERSION_2021}" "INSTPATH_2021"
!insertmacro FindMaxVersion "${VERSION_2020}" "${REG_VERSION_2020}" "INSTPATH_2020"
!insertmacro FindMaxVersion "${VERSION_2019}" "${REG_VERSION_2019}" "INSTPATH_2019"
!insertmacro FindMaxVersion "${VERSION_2018}" "${REG_VERSION_2018}" "INSTPATH_2018"
!insertmacro FindMaxVersion "${VERSION_2017}" "${REG_VERSION_2017}" "INSTPATH_2017"
!insertmacro FindMaxVersion "${VERSION_2016}" "${REG_VERSION_2016}" "INSTPATH_2016"
!insertmacro FindMaxVersion "${VERSION_2015}" "${REG_VERSION_2015}" "INSTPATH_2015"
!insertmacro FindMaxVersion "${VERSION_2014}" "${REG_VERSION_2014}" "INSTPATH_2014"
!insertmacro FindMaxVersion "${VERSION_2013}" "${REG_VERSION_2013}" "INSTPATH_2013"
!insertmacro FindMaxVersion "${VERSION_2012}" "${REG_VERSION_2012}" "INSTPATH_2012"
!insertmacro FindMaxVersion "${VERSION_2011}" "${REG_VERSION_2011}" "INSTPATH_2011"
!insertmacro FindMaxVersion "${VERSION_2010}" "${REG_VERSION_2010}" "INSTPATH_2010"
!insertmacro FindMaxVersion "${VERSION_2009}" "${REG_VERSION_2009}" "INSTPATH_2009"
!insertmacro FindMaxVersion "${VERSION_2008}" "${REG_VERSION_2008}" "INSTPATH_2008"
!insertmacro FindMaxVersion "${VERSION_9}"    "${REG_VERSION_9}"    "INSTPATH_9"

; 在检测完安装路径后设置章节状态
; 注意：节索引按它们在脚本中的定义顺序从0开始

; 3dsMax 2026 (节索引 0)
${If} $INSTPATH_2026 != ""
  SectionSetFlags 0 1 ; 1 = 选中
${Else}
  SectionSetFlags 0 0 ; 0 = 不选中
  SectionSetText 0 ""
${EndIf}

; 3dsMax 2025 (节索引 1)
${If} $INSTPATH_2025 != ""
  SectionSetFlags 1 1
${Else}
  SectionSetFlags 1 0
  SectionSetText 1 ""
${EndIf}

; 3dsMax 2024 (节索引 2)
${If} $INSTPATH_2024 != ""
  SectionSetFlags 2 1
${Else}
  SectionSetFlags 2 0
  SectionSetText 2 ""
${EndIf}

; 3dsMax 2023 (节索引 3)
${If} $INSTPATH_2023 != ""
  SectionSetFlags 3 1
${Else}
  SectionSetFlags 3 0
  SectionSetText 3 ""
${EndIf}

; 3dsMax 2022 (节索引 4)
${If} $INSTPATH_2022 != ""
  SectionSetFlags 4 1
${Else}
  SectionSetFlags 4 0
  SectionSetText 4 ""
${EndIf}

; 3dsMax 2021 (节索引 5)
${If} $INSTPATH_2021 != ""
  SectionSetFlags 5 1
${Else}
  SectionSetFlags 5 0
  SectionSetText 5 ""
${EndIf}

; 3dsMax 2020 (节索引 6)
${If} $INSTPATH_2020 != ""
  SectionSetFlags 6 1
${Else}
  SectionSetFlags 6 0
  SectionSetText 6 ""
${EndIf}

; 3dsMax 2019 (节索引 7)
${If} $INSTPATH_2019 != ""
  SectionSetFlags 7 1
${Else}
  SectionSetFlags 7 0
  SectionSetText 7 ""
${EndIf}

; 3dsMax 2018 (节索引 8)
${If} $INSTPATH_2018 != ""
  SectionSetFlags 8 1
${Else}
  SectionSetFlags 8 0
  SectionSetText 8 ""
${EndIf}

; 3dsMax 2017 (节索引 9)
${If} $INSTPATH_2017 != ""
  SectionSetFlags 9 1
${Else}
  SectionSetFlags 9 0
  SectionSetText 9 ""
${EndIf}

; 3dsMax 2016 (节索引 10)
${If} $INSTPATH_2016 != ""
  SectionSetFlags 10 1
${Else}
  SectionSetFlags 10 0
  SectionSetText 10 ""
${EndIf}

; 3dsMax 2015 (节索引 11)
${If} $INSTPATH_2015 != ""
  SectionSetFlags 11 1
${Else}
  SectionSetFlags 11 0
  SectionSetText 11 ""
${EndIf}

; 3dsMax 2014 (节索引 12)
${If} $INSTPATH_2014 != ""
  SectionSetFlags 12 1
${Else}
  SectionSetFlags 12 0
  SectionSetText 12 ""
${EndIf}

; 3dsMax 2013 (节索引 13)
${If} $INSTPATH_2013 != ""
  SectionSetFlags 13 1
${Else}
  SectionSetFlags 13 0
  SectionSetText 13 ""
${EndIf}

; 3dsMax 2012 (节索引 14)
${If} $INSTPATH_2012 != ""
  SectionSetFlags 14 1
${Else}
  SectionSetFlags 14 0
  SectionSetText 14 ""
${EndIf}

; 3dsMax 2011 (节索引 15)
${If} $INSTPATH_2011 != ""
  SectionSetFlags 15 1
${Else}
  SectionSetFlags 15 0
  SectionSetText 15 ""
${EndIf}

; 3dsMax 2010 (节索引 16)
${If} $INSTPATH_2010 != ""
  SectionSetFlags 16 1
${Else}
  SectionSetFlags 16 0
  SectionSetText 16 ""
${EndIf}

; 3dsMax 2009 (节索引 17)
${If} $INSTPATH_2009 != ""
  SectionSetFlags 17 1
${Else}
  SectionSetFlags 17 0
  SectionSetText 17 ""
${EndIf}

; 3dsMax 2008 (节索引 18)
${If} $INSTPATH_2008 != ""
  SectionSetFlags 18 1
${Else}
  SectionSetFlags 18 0
  SectionSetText 18 ""
${EndIf}

; 3dsMax 9 (节索引 19)
${If} $INSTPATH_9 != ""
  SectionSetFlags 19 1
${Else}
  SectionSetFlags 19 0
  SectionSetText 19 ""
${EndIf}

FunctionEnd

; 定义显示安装路径的宏
!macro DescSection SEC_ID VAR_NAME
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_ID} $${VAR_NAME}
!macroend

; 版本描述
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro DescSection "${SEC_9}"    "INSTPATH_9"
  !insertmacro DescSection "${SEC_2008}" "INSTPATH_2008"
  !insertmacro DescSection "${SEC_2009}" "INSTPATH_2009"
  !insertmacro DescSection "${SEC_2010}" "INSTPATH_2010"
  !insertmacro DescSection "${SEC_2011}" "INSTPATH_2011"
  !insertmacro DescSection "${SEC_2012}" "INSTPATH_2012"
  !insertmacro DescSection "${SEC_2013}" "INSTPATH_2013"
  !insertmacro DescSection "${SEC_2014}" "INSTPATH_2014"
  !insertmacro DescSection "${SEC_2015}" "INSTPATH_2015"
  !insertmacro DescSection "${SEC_2016}" "INSTPATH_2016"
  !insertmacro DescSection "${SEC_2017}" "INSTPATH_2017"
  !insertmacro DescSection "${SEC_2018}" "INSTPATH_2018"
  !insertmacro DescSection "${SEC_2019}" "INSTPATH_2019"
  !insertmacro DescSection "${SEC_2020}" "INSTPATH_2020"
  !insertmacro DescSection "${SEC_2021}" "INSTPATH_2021"
  !insertmacro DescSection "${SEC_2022}" "INSTPATH_2022"
  !insertmacro DescSection "${SEC_2023}" "INSTPATH_2023"
  !insertmacro DescSection "${SEC_2024}" "INSTPATH_2024"
  !insertmacro DescSection "${SEC_2025}" "INSTPATH_2025"
  !insertmacro DescSection "${SEC_2026}" "INSTPATH_2026"
!insertmacro MUI_FUNCTION_DESCRIPTION_END
