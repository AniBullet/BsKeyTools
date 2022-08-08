; �ýű�ʹ�� HM VNISEdit �ű��༭���򵼲���

; ��װ�����ʼ���峣��
!define PRODUCT_NAME "BsKeyTools"
!define PRODUCT_VERSION "0.9.9"
!define PRODUCT_PUBLISHER "Bullet.S"
!define PRODUCT_WEB_SITE "anibullet.com"
;!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
;!define PRODUCT_UNINST_ROOT_KEY "HKLM"
var maxVer

SetCompressor lzma

; ------ MUI �ִ����涨�� (1.67 �汾���ϼ���) ------
!include "MUI.nsh"

; MUI Ԥ���峣��
!define MUI_ABORTWARNING
!define MUI_ICON "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\max.ico"
;!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall-blue-full.ico"

; ��ӭҳ��
!insertmacro MUI_PAGE_WELCOME
; ����Э��ҳ��
!define MUI_LICENSEPAGE_CHECKBOX
!insertmacro MUI_PAGE_LICENSE "E:\_S\Scripts\GitHub\BsKeyTools\LICENSE"
; ���ѡ��ҳ��
!insertmacro MUI_PAGE_COMPONENTS
; ��װĿ¼ѡ��ҳ��
; !insertmacro MUI_PAGE_DIRECTORY
; ��װ����ҳ��
!insertmacro MUI_PAGE_INSTFILES
; ��װ���ҳ��
!define MUI_FINISHPAGE_SHOWREADME
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION Info
!define MUI_FINISHPAGE_SHOWREADME_TEXT "�鿴������Ƶ"

!insertmacro MUI_PAGE_FINISH
Function Info
ExecShell "open" "https://space.bilibili.com/2031113/channel/collectiondetail?sid=560782"
Functionend

; ��װж�ع���ҳ��
;!insertmacro MUI_UNPAGE_INSTFILES

; ��װ�����������������
!insertmacro MUI_LANGUAGE "SimpChinese"

; ��װԤ�ͷ��ļ�
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
; ------ MUI �ִ����涨����� ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "K֡����_BsKeyTools����ɱ�����Σ�.exe"
; InstallDir "d:\Program Files\Autodesk\3ds Max 2014"
; InstallDir "$INSTDIR"
ShowInstDetails show
ShowUnInstDetails show

Section "3dsMax 2023" SEC01
  SetOutPath "$1"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
SectionEnd

Section "3dsMax 2022" SEC02
  SetOutPath "$2"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
SectionEnd
  
Section "3dsMax 2021" SEC03
  SetOutPath "$3"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
SectionEnd

Section "3dsMax 2020" SEC04
  SetOutPath "$4"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
SectionEnd

Section "3dsMax 2019" SEC05
  SetOutPath "$5"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
SectionEnd

Section "3dsMax 2018" SEC06
  SetOutPath "$6"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
SectionEnd

Section "3dsMax 2017" SEC07
  SetOutPath "$7"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
SectionEnd

Section "3dsMax 2016" SEC08
  SetOutPath "$8"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
SectionEnd

Section "3dsMax 2015" SEC09
  SetOutPath "$9"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
SectionEnd

Section "3dsMax 2014" SEC10
  SetOutPath "$R2"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
SectionEnd

Section "3dsMax 2013" SEC11
  SetOutPath "$R3"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
SectionEnd

Section "3dsMax 2012" SEC12
  SetOutPath "$R4"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
SectionEnd

Section "3dsMax 2011" SEC13
  SetOutPath "$R5"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
SectionEnd

Section "3dsMax 2010" SEC14
  SetOutPath "$R6"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
SectionEnd

Section "3dsMax 2009" SEC15
  SetOutPath "$R7"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
SectionEnd

Section "3dsMax 2008" SEC16
  SetOutPath "$R8"
  SetOverwrite on
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\Scripts"
  File /r "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\UI_ln"
SectionEnd

Section "3dsMax 9" SEC17
  SetOutPath "$R9"
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

;��� 3dsmax.exe �Ƿ�������
  FindProcDLL::FindProc "3dsmax.exe"
  Pop $R0
  IntCmp $R0 1 0 no_run
  MessageBox MB_ICONSTOP "ж�س����⵽ 3dsmax.exe �������У���ر�֮���ٰ�װ��"
 	Quit
 	no_run:

!insertmacro MUI_LANGDLL_DISPLAY

; ɨ���Ѱ�װ��max�汾

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