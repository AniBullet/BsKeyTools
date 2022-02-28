; �ýű�ʹ�� HM VNISEdit �ű��༭���򵼲���

; ��װ�����ʼ���峣��
!define PRODUCT_NAME "BsKeyTools"
!define PRODUCT_VERSION "0.9.8.4"
!define PRODUCT_PUBLISHER "Bullet.S"
!define PRODUCT_WEB_SITE "anibullet.com"
;!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
;!define PRODUCT_UNINST_ROOT_KEY "HKLM"

SetCompressor lzma

; ------ MUI �ִ����涨�� (1.67 �汾���ϼ���) ------
!include "MUI.nsh"

; MUI Ԥ���峣��
!define MUI_ABORTWARNING
!define MUI_ICON "E:\_S\Scripts\GitHub\BsKeyTools\_BsKeyTools\max.ico"
;!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall-blue-full.ico"

; ��ӭҳ��
!insertmacro MUI_PAGE_WELCOME
; ���Э��ҳ��
!define MUI_LICENSEPAGE_CHECKBOX
!insertmacro MUI_PAGE_LICENSE "E:\_S\Scripts\GitHub\BsKeyTools\LICENSE"
; ��װĿ¼ѡ��ҳ��
!insertmacro MUI_PAGE_DIRECTORY
; ��װ����ҳ��
!insertmacro MUI_PAGE_INSTFILES
; ��װ���ҳ��
!insertmacro MUI_PAGE_FINISH

; ��װж�ع���ҳ��
;!insertmacro MUI_UNPAGE_INSTFILES

; ��װ�����������������
!insertmacro MUI_LANGUAGE "SimpChinese"

; ��װԤ�ͷ��ļ�
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
; ------ MUI �ִ����涨����� ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "K֡����_BsKeyTools��װ������MAX,��ɱ�����Σ�.exe"
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

;��� 3dsmax.exe �Ƿ�������
  Push $R0
  Push "3dsmax.exe"
  ProcessWork::existsprocess
  Pop $R0
  IntCmp $R0 1 0 no_run
  MessageBox MB_ICONSTOP "ж�س����⵽ 3dsmax.exe �������У���ر�֮���ٰ�װ��"
 	Quit
 	no_run:

  !insertmacro MUI_LANGDLL_DISPLAY
  
; ɨ���Ѱ�װ��max�汾

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
