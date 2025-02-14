; �ýű�ʹ�� HM VNISEdit �ű��༭���򵼲���

; ��װ�����ʼ���峣��
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

; ------ MUI �ִ����涨�� (1.67 �汾���ϼ���) ------
!include "MUI2.nsh"

; MUI Ԥ���峣��
!define MUI_ABORTWARNING
!define MUI_ICON "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\max.ico"
;!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall-blue-full.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\sideImg.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\logo.bmp"

; ��ӭҳ��
!insertmacro MUI_PAGE_WELCOME
!define MUI_TEXT_WELCOME_INFO_TITLE "��ӭ��װ ${PRODUCT_NAME}${PRODUCT_VERSION}"
!define MUI_TEXT_WELCOME_INFO_TEXT "�˳������������ $(^NameDA) �İ�װ��$\r$\n$\r$\n�ڰ�װ֮ǰ�������ȹر����� 3dsMax ����$\r$\n$\r$\n�⽫ȷ����װ�����ܹ�����������ļ���$\r$\n$\r$\n�Ӷ������ڰ�װ��򿪹���ʧ�ܱ���$\r$\n$\r$\n$_CLICK"
; ���Э��ҳ��
!define MUI_INNERTEXT_LICENSE_TOP "Ҫ�Ķ�Э������ಿ�֣��밴���� [PgDn] �����·�ҳ��"
!define MUI_INNERTEXT_LICENSE_BOTTOM "�����������֤��������� [�ҽ���(I)] ������װ��$\r$\n$\r$\n�������ͬ�����ܰ�װ $(^NameDA) ��"
!insertmacro MUI_PAGE_LICENSE "E:\_S\Scripts\GitHub\BsKeyTools\LICENSE"
; ���ѡ��ҳ��
!insertmacro MUI_PAGE_COMPONENTS
!define MUI_TEXT_COMPONENTS_TITLE "ѡ��汾"
!define MUI_TEXT_COMPONENTS_SUBTITLE "ѡ�����밲װ $(^NameDA) �� 3dsMax �汾��"
!define MUI_INNERTEXT_COMPONENTS_DESCRIPTION_TITLE "��װ·��"
!define MUI_INNERTEXT_COMPONENTS_DESCRIPTION_INFO "�������ͣ�ڰ汾����֮�ϣ�������ʾ���İ�װ·����"
ComponentText "�빴ѡ���밲װ���İ汾����ȡ����ѡ�㲻�밲װ�İ汾�� $\r$\n$\r$\n$_CLICK" "" "ѡ����װ�İ汾: "
; ��װĿ¼ѡ��ҳ��
; !insertmacro MUI_PAGE_DIRECTORY
; ��װ����ҳ��
!insertmacro MUI_PAGE_INSTFILES
; ��װ���ҳ��
!define MUI_TEXT_FINISH_INFO_TEXT "$(^NameDA) �Ѿ��ɹ���װ��������$\r$\n$\r$\n��� [���(F)] �رհ�װ����"
!define MUI_FINISHPAGE_SHOWREADME
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION Info
!define MUI_FINISHPAGE_SHOWREADME_TEXT "�鿴������Ƶ"
!define MUI_FINISHPAGE_LINK "Github"
!define MUI_FINISHPAGE_LINK_LOCATION "https://github.com/AniBullet/BsKeyTools"
!define MUI_FINISHPAGE_LINK_COLOR "872657"

!insertmacro MUI_PAGE_FINISH
Function Info
ExecShell "open" "https://space.bilibili.com/2031113/lists/560782"
Functionend

; ��װж�ع���ҳ��
;!insertmacro MUI_UNPAGE_INSTFILES

; ��װ�����������������
!insertmacro MUI_LANGUAGE "SimpChinese"
;!insertmacro MUI_LANGUAGE "English"

; ��װԤ�ͷ��ļ�
;!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
; ------ MUI �ִ����涨����� ------

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

;��� 3dsmax.exe �Ƿ�������
 	nsProcess::_FindProcess "3dsmax.exe"
  Pop $R0
  ${If} $R0 = 0
		MessageBox MB_ICONEXCLAMATION|MB_OK "BsKeyTools ��װ�����⵽ 3dsmax.exe �������У�$\n$\n��װ�Կɼ��������������� 3dsMax ���ٴ򿪲����$\n$\n�����������������Ī���ţ������󷨽��һ������~"
	${EndIf}

; ɨ���Ѱ�װ��max�汾

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

; �����������
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
 *  �����ǰ�װ�����ж�ز���  *
 ******************************/

;Section Uninstall
;  Delete "$INSTDIR\uninst.exe"
;  RMDIR "$INSTDIR\Scripts\BulletScripts"
;  RMDIR "$INSTDIR\Scripts\BulletScripts"
;  RMDIR "$INSTDIR\UI_ln"

;  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
;  SetAutoClose true
;SectionEnd

;#-- ���� NSIS �ű��༭�������� Function ���α�������� Section ����֮���д���Ա��ⰲװ�������δ��Ԥ֪�����⡣--#

;Function un.onInit
;MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "��ȷʵҪ��ȫ�Ƴ� $(^Name) ���������е������" IDYES +2
;  Abort
  ;�������Ƿ�����
;  FindProcDLL::FindProc "3dsmax.exe"
;   Pop $R0
;   IntCmp $R0 1 0 no_run
;   MessageBox MB_ICONSTOP "ж�س����⵽ 3dsmax.exe �������У���ر�֮����ж�أ�"
;   Quit
;   no_run:
;FunctionEnd

;Function un.onUninstSuccess
;  HideWindow
;  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) �ѳɹ��ش����ļ�����Ƴ���"
;FunctionEnd
