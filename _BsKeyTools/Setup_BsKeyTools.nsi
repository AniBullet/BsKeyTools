; 该脚本使用 HM VNISEdit 脚本编辑器向导产生

; 安装程序初始定义常量
!define PRODUCT_NAME "BsKeyTools"
!define PRODUCT_VERSION "_v1.0.1"
!define PRODUCT_PUBLISHER "Bullet.S"
!define PRODUCT_WEB_SITE "anibullet.com"
;!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
;!define PRODUCT_UNINST_ROOT_KEY "HKLM"
var maxVer
var v2024
var v2025

SetCompressor lzma

; ------ MUI 现代界面定义 (1.67 版本以上兼容) ------
!include "MUI2.nsh"

; MUI 预定义常量
!define MUI_ABORTWARNING
!define MUI_ICON "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\max.ico"
;!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall-blue-full.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\sideImg.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\logo.bmp"

; 欢迎页面
!insertmacro MUI_PAGE_WELCOME
!define MUI_TEXT_WELCOME_INFO_TITLE "欢迎安装 ${PRODUCT_NAME}${PRODUCT_VERSION}"
!define MUI_TEXT_WELCOME_INFO_TEXT "此程序将引导你完成 $(^NameDA) 的安装。$\r$\n$\r$\n在安装之前，建议先关闭所有 3dsMax 程序。$\r$\n$\r$\n这将确保安装程序能够更新所需的文件，$\r$\n$\r$\n从而避免在安装后打开工具失败报错。$\r$\n$\r$\n$_CLICK"
; 许可协议页面
!define MUI_INNERTEXT_LICENSE_TOP "要阅读协议的其余部分，请按键盘 [PgDn] 键向下翻页。"
!define MUI_INNERTEXT_LICENSE_BOTTOM "如果你接受许可证的条款，请点击 [我接受(I)] 继续安装。$\r$\n$\r$\n你必须在同意后才能安装 $(^NameDA) 。"
!insertmacro MUI_PAGE_LICENSE "E:\_S\Scripts\GitHub\BsKeyTools\LICENSE"
; 组件选择页面
!insertmacro MUI_PAGE_COMPONENTS
!define MUI_TEXT_COMPONENTS_TITLE "选择版本"
!define MUI_TEXT_COMPONENTS_SUBTITLE "选择你想安装 $(^NameDA) 的 3dsMax 版本。"
!define MUI_INNERTEXT_COMPONENTS_DESCRIPTION_TITLE "安装路径"
!define MUI_INNERTEXT_COMPONENTS_DESCRIPTION_INFO "将光标悬停在版本名称之上，即可显示它的安装路径。"
ComponentText "请勾选你想安装到的版本，并取消勾选你不想安装的版本。 $\r$\n$\r$\n$_CLICK" "" "选定安装的版本: "
; 安装目录选择页面
; !insertmacro MUI_PAGE_DIRECTORY
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

; 安装卸载过程页面
;!insertmacro MUI_UNPAGE_INSTFILES

; 安装界面包含的语言设置
!insertmacro MUI_LANGUAGE "SimpChinese"
;!insertmacro MUI_LANGUAGE "English"

; 安装预释放文件
;!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
; ------ MUI 现代界面定义结束 ------

Name "${PRODUCT_NAME}${PRODUCT_VERSION}"
OutFile "_BsKeyTools.exe"
; InstallDir "d:\Program Files\Autodesk\3ds Max 2014"
; InstallDir "$INSTDIR"
ShowInstDetails show
ShowUnInstDetails show

Section "3dsMax 2025" SEC19
  SetOutPath "$v2025"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
SectionEnd

Section "3dsMax 2024" SEC18
  SetOutPath "$v2024"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\2024\plugins"
SectionEnd

Section "3dsMax 2023" SEC01
  SetOutPath "$1"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\2023\plugins"
SectionEnd

Section "3dsMax 2022" SEC02
  SetOutPath "$2"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\2022\plugins"
SectionEnd
  
Section "3dsMax 2021" SEC03
  SetOutPath "$3"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\2021\plugins"
SectionEnd

Section "3dsMax 2020" SEC04
  SetOutPath "$4"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\2020\plugins"
SectionEnd

Section "3dsMax 2019" SEC05
  SetOutPath "$5"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\2019\plugins"
SectionEnd

Section "3dsMax 2018" SEC06
  SetOutPath "$6"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\2018\plugins"
SectionEnd

Section "3dsMax 2017" SEC07
  SetOutPath "$7"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\2017\plugins"
SectionEnd

Section "3dsMax 2016" SEC08
  SetOutPath "$8"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\2016\plugins"
SectionEnd

Section "3dsMax 2015" SEC09
  SetOutPath "$9"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\2015\plugins"
SectionEnd

Section "3dsMax 2014" SEC10
  SetOutPath "$R2"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\2014\plugins"
SectionEnd

Section "3dsMax 2013" SEC11
  SetOutPath "$R3"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\2013\plugins"
SectionEnd

Section "3dsMax 2012" SEC12
  SetOutPath "$R4"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\2012\plugins"
SectionEnd

Section "3dsMax 2011" SEC13
  SetOutPath "$R5"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\2011\plugins"
SectionEnd

Section "3dsMax 2010" SEC14
  SetOutPath "$R6"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\2010\plugins"
SectionEnd

Section "3dsMax 2009" SEC15
  SetOutPath "$R7"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\2009\plugins"
SectionEnd

Section "3dsMax 2008" SEC16
  SetOutPath "$R8"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\2008\plugins"
SectionEnd

Section "3dsMax 9" SEC17
  SetOutPath "$R9"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\GhostTrails\9\plugins"
SectionEnd

;Section -Post
;  WriteUninstaller "$INSTDIR\uninst.exe"
;  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
;  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
;  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
;  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
;  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
;SectionEnd

Function .onInit

!insertmacro MUI_LANGDLL_DISPLAY

;检查 3dsmax.exe 是否已运行
 	nsProcess::_FindProcess "3dsmax.exe"
  Pop $R0
  ${If} $R0 = 0
		MessageBox MB_ICONEXCLAMATION|MB_OK "BsKeyTools 安装程序检测到 3dsmax.exe 正在运行，$\n$\n安装仍可继续，但建议重启 3dsMax 后再打开插件！$\n$\n否则可能遇到报错，但莫惊慌，重启大法解决一切困难~"
	${EndIf}

; 扫描已安装的max版本

; MAX2025:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\27.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec19} 1
    StrCpy $v2025 $maxVer
  ${Else}
  	SectionSetFlags ${Sec19} 0
    SectionSetText ${Sec19} ""
  ${EndIf}

; MAX2024:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\26.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec18} 1
    StrCpy $v2024 $maxVer
  ${Else}
  	SectionSetFlags ${Sec18} 0
    SectionSetText ${Sec18} ""
  ${EndIf}

; MAX2023:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\25.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec01} 1
    StrCpy $1 $maxVer
  ${Else}
  	SectionSetFlags ${Sec01} 0
    SectionSetText ${Sec01} ""
  ${EndIf}

; MAX2022:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\24.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec02} 1
    StrCpy $2 $maxVer
  ${Else}
  	SectionSetFlags ${Sec02} 0
    SectionSetText ${Sec02} ""
  ${EndIf}

; MAX2021:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\23.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec03} 1
    StrCpy $3 $maxVer
  ${Else}
    SectionSetFlags ${Sec03} 0
    SectionSetText ${Sec03} ""
  ${EndIf}

; MAX2020:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\22.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec04} 1
    StrCpy $4 $maxVer
  ${Else}
    SectionSetFlags ${Sec04} 0
    SectionSetText ${Sec04} ""
  ${EndIf}

; MAX2019:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\21.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec05} 1
    StrCpy $5 $maxVer
  ${Else}
    SectionSetFlags ${Sec05} 0
    SectionSetText ${Sec05} ""
  ${EndIf}

; MAX2018:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\20.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec06} 1
    StrCpy $6 $maxVer
  ${Else}
  	SectionSetFlags ${Sec06} 0
    SectionSetText ${Sec06} ""
  ${EndIf}

; MAX2017:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\19.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec07} 1
    StrCpy $7 $maxVer
  ${Else}
  	SectionSetFlags ${Sec07} 0
    SectionSetText ${Sec07} ""
  ${EndIf}

; MAX2016:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\18.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec08} 1
    StrCpy $8 $maxVer
  ${Else}
  	SectionSetFlags ${Sec08} 0
    SectionSetText ${Sec08} ""
  ${EndIf}

; MAX2015:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\17.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec09} 1
    StrCpy $9 $maxVer
  ${Else}
  	SectionSetFlags ${Sec09} 0
    SectionSetText ${Sec09} ""
  ${EndIf}

; MAX2014:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\16.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec10} 1
    StrCpy $R2 $maxVer
  ${Else}
  	SectionSetFlags ${Sec10} 0
    SectionSetText ${Sec10} ""
  ${EndIf}

; MAX2013:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\15.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec11} 1
    StrCpy $R3 $maxVer
  ${Else}
  	SectionSetFlags ${Sec11} 0
    SectionSetText ${Sec11} ""
  ${EndIf}

; MAX2012:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\14.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec12} 1
    StrCpy $R4 $maxVer
  ${Else}
  	SectionSetFlags ${Sec12} 0
    SectionSetText ${Sec12} ""
  ${EndIf}

; MAX2011:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\13.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec13} 1
    StrCpy $R5 $maxVer
  ${Else}
  	SectionSetFlags ${Sec13} 0
    SectionSetText ${Sec13} ""
  ${EndIf}

; MAX2010:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\12.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec14} 1
    StrCpy $R6 $maxVer
  ${Else}
  	SectionSetFlags ${Sec14} 0
    SectionSetText ${Sec14} ""
  ${EndIf}

; MAX2009:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\11.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec15} 1
    StrCpy $R7 $maxVer
  ${Else}
  	SectionSetFlags ${Sec15} 0
    SectionSetText ${Sec15} ""
  ${EndIf}

; MAX2008:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\10.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec16} 1
    StrCpy $R8 $maxVer
  ${Else}
  	SectionSetFlags ${Sec16} 0
    SectionSetText ${Sec16} ""
  ${EndIf}

; MAX9.0:
  setRegView 64
  ReadRegStr $maxVer HKLM "SOFTWARE\Autodesk\3dsMax\9.0" "Installdir"
  ${If} $maxVer != ""
    SectionSetFlags ${Sec17} 1
    StrCpy $R9 $maxVer
  ${Else}
  	SectionSetFlags ${Sec17} 0
    SectionSetText ${Sec17} ""
  ${EndIf}

FunctionEnd

; 区段组件描述
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec01} $1
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec02} $2
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec03} $3
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec04} $4
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec05} $5
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec06} $6
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec07} $7
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec08} $8
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec09} $9
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec10} $R2
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec11} $R3
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec12} $R4
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec13} $R5
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec14} $R6
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec15} $R7
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec16} $R8
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec17} $R9
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec18} $v2024
  !insertmacro MUI_DESCRIPTION_TEXT ${Sec19} $v2025
!insertmacro MUI_FUNCTION_DESCRIPTION_END

/******************************
 *  以下是安装程序的卸载部分  *
 ******************************/

;Section Uninstall
;  Delete "$INSTDIR\uninst.exe"
;  RMDIR "$INSTDIR\Scripts\BulletScripts"
;  RMDIR "$INSTDIR\Scripts\BulletScripts"
;  RMDIR "$INSTDIR\UI_ln"

;  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
;  SetAutoClose true
;SectionEnd

;#-- 根据 NSIS 脚本编辑规则，所有 Function 区段必须放置在 Section 区段之后编写，以避免安装程序出现未可预知的问题。--#

;Function un.onInit
;MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "您确实要完全移除 $(^Name) ，及其所有的组件？" IDYES +2
;  Abort
  ;检测程序是否运行
;  FindProcDLL::FindProc "3dsmax.exe"
;   Pop $R0
;   IntCmp $R0 1 0 no_run
;   MessageBox MB_ICONSTOP "卸载程序检测到 3dsmax.exe 正在运行，请关闭之后再卸载！"
;   Quit
;   no_run:
;FunctionEnd

;Function un.onUninstSuccess
;  HideWindow
;  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) 已成功地从您的计算机移除。"
;FunctionEnd
