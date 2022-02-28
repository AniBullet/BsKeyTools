; 该脚本使用 HM VNISEdit 脚本编辑器向导产生

; 安装程序初始定义常量
!define PRODUCT_NAME "BsKeyTools"
!define PRODUCT_VERSION "0.9.8.4"
!define PRODUCT_PUBLISHER "Bullet.S"
!define PRODUCT_WEB_SITE "anibullet.com"
;!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
;!define PRODUCT_UNINST_ROOT_KEY "HKLM"

SetCompressor lzma

; ------ MUI 现代界面定义 (1.67 版本以上兼容) ------
!include "MUI.nsh"

; MUI 预定义常量
!define MUI_ABORTWARNING
!define MUI_ICON "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\max.ico"
;!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall-blue-full.ico"

; 欢迎页面
!insertmacro MUI_PAGE_WELCOME
; 许可协议页面
!define MUI_LICENSEPAGE_CHECKBOX
!insertmacro MUI_PAGE_LICENSE "E:\_S\Scripts\GitHub\BsKeyTools\LICENSE"
; 安装目录选择页面
!insertmacro MUI_PAGE_DIRECTORY
; 安装过程页面
!insertmacro MUI_PAGE_INSTFILES
; 安装完成页面
!insertmacro MUI_PAGE_FINISH

; 安装卸载过程页面
;!insertmacro MUI_UNPAGE_INSTFILES

; 安装界面包含的语言设置
!insertmacro MUI_LANGUAGE "SimpChinese"

; 安装预释放文件
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
; ------ MUI 现代界面定义结束 ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "K帧工具_BsKeyTools（装完重启MAX,误杀请信任）.exe"
; InstallDir "d:\Program Files\Autodesk\3ds Max 2014"
InstallDir "$INSTDIR"
ShowInstDetails show
ShowUnInstDetails show

Section "MainSection" SEC01
  SetOutPath "$INSTDIR"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
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

;检查 3dsmax.exe 是否已运行
  Push $R0
  Push "3dsmax.exe"
  ProcessWork::existsprocess
  Pop $R0
  IntCmp $R0 1 0 no_run
  MessageBox MB_ICONSTOP "卸载程序检测到 3dsmax.exe 正在运行，请关闭之后再安装！"
 	Quit
 	no_run:

  !insertmacro MUI_LANGDLL_DISPLAY
  
; 扫描已安装的max版本

; MAX2022:
  setRegView 64
  ReadRegStr $1 HKLM "SOFTWARE\Autodesk\3dsMax\24.0" "Installdir"
  ${If} $1 != ""
    StrCpy $INSTDIR $1
  ${EndIf}

; MAX2021:
  setRegView 64
  ReadRegStr $1 HKLM "SOFTWARE\Autodesk\3dsMax\23.0" "Installdir"
  ${If} $1 != ""
    StrCpy $INSTDIR $1
  ${EndIf}

; MAX2020:
  setRegView 64
  ReadRegStr $1 HKLM "SOFTWARE\Autodesk\3dsMax\22.0" "Installdir"
  ${If} $1 != ""
    StrCpy $INSTDIR $1
  ${EndIf}

; MAX2019:
  setRegView 64
  ReadRegStr $1 HKLM "SOFTWARE\Autodesk\3dsMax\21.0" "Installdir"
  ${If} $1 != ""
    StrCpy $INSTDIR $1
  ${EndIf}

; MAX2018:
  setRegView 64
  ReadRegStr $1 HKLM "SOFTWARE\Autodesk\3dsMax\20.0" "Installdir"
  ${If} $1 != ""
    StrCpy $INSTDIR $1
  ${EndIf}

; MAX2017:
  setRegView 64
  ReadRegStr $1 HKLM "SOFTWARE\Autodesk\3dsMax\19.0" "Installdir"
  ${If} $1 != ""
    StrCpy $INSTDIR $1
  ${EndIf}

; MAX2016:
  setRegView 64
  ReadRegStr $1 HKLM "SOFTWARE\Autodesk\3dsMax\18.0" "Installdir"
  ${If} $1 != ""
    StrCpy $INSTDIR $1
  ${EndIf}

; MAX2015:
  setRegView 64
  ReadRegStr $1 HKLM "SOFTWARE\Autodesk\3dsMax\17.0" "Installdir"
  ${If} $1 != ""
    StrCpy $INSTDIR $1
  ${EndIf}

; MAX2014:
  setRegView 64
  ReadRegStr $1 HKLM "SOFTWARE\Autodesk\3dsMax\16.0" "Installdir"
  ${If} $1 != ""
    StrCpy $INSTDIR $1
  ${EndIf}

; MAX2013:
  setRegView 64
  ReadRegStr $1 HKLM "SOFTWARE\Autodesk\3dsMax\15.0" "Installdir"
  ${If} $1 != ""
    StrCpy $INSTDIR $1
  ${EndIf}

; MAX2012:
  setRegView 64
  ReadRegStr $1 HKLM "SOFTWARE\Autodesk\3dsMax\14.0" "Installdir"
  ${If} $1 != ""
    StrCpy $INSTDIR $1
  ${EndIf}

; MAX2011:
  setRegView 64
  ReadRegStr $1 HKLM "SOFTWARE\Autodesk\3dsMax\13.0" "Installdir"
  ${If} $1 != ""
    StrCpy $INSTDIR $1
  ${EndIf}

; MAX2010:
  setRegView 64
  ReadRegStr $1 HKLM "SOFTWARE\Autodesk\3dsMax\12.0" "Installdir"
  ${If} $1 != ""
    StrCpy $INSTDIR $1
  ${EndIf}

FunctionEnd

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
