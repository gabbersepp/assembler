.386
.model flat, stdcall
;option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
include \masm32\include\user32.inc
includelib \masm32\lib\shell32.lib
include \masm32\include\shell32.inc
includelib \masm32\lib\user32.lib
;includelib \masm32\test\BiehlCOMP.lib
DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWoRD
ConfigDlgProc PROTO :DWORD, :DWORD, :DWORD, :DWORD
;AddLongInt PROTO :DWORD, :DWORD, :DWORD

ICON_ID EQU 2000
ICON_MSG EQU WM_USER+1

IDC_CONFIG equ 1000
IDC_CLOSE equ 1001
IDC_CHECK EQU 1002
IDC_TAB01 EQU 3000
IDC_BUTTON01 EQU 5001
IDC_BUTTON02 EQU 5002
IDC_BUTTON03 EQU 5003

IDC_STATIC01  EQU 6001
IDC_CHK01 EQU 7001

IDM_CHECK EQU 4001
IDM_CONFIG EQU 4003
IDM_EXIT EQU 4002

.data
hInstance	DD	0
nfi  NOTIFYICONDATA <>
POINT_x DD 0
POINT_y DD 0

POS RECT <>

MENU1 DB "IDM_MEN", 0

MENU_HWND DD 0
DLGNAME	DB	"IDD_DLG01",0
CFG_DLG DB "IDD_CONFIG",0

POP3_INI  DB  "./pop3.ini",0
CFG_AUTO_START  DB  "autostart",0
SECTION_CFG DB  "config",0
BTN_CLASSNAME DB "button",0
STATIC_CLASSNAME DB "static",0
WERT DB "1",0

POP3 DB "pop3.exe",0
MEM_HWND  DD  0
TAB_HWND  DD  0

GB01_HWND DD  0
GB02_HWND DD  0
MENU_CLOSE DB "Beenden",0
MENU_CHECK DB "Überprüfe POP3 Konten",0
MENU_CONFIG DB "Einstellungen",0

STATIC01_LABEL  DB  "Bei Windowsstart ausführen:",0
TAB_SHEET_1 DB "Haupt",0
TAB_SHEET_2 DB "Sonstiges",0

TAB01_SEL DB  0
TAB02_SEL DB  0

TAB01 DD TCIF_TEXT
	  DD 0
	  DD 0
	  DD TAB_SHEET_1
	  DD 0
	  DD -1
	  DD 0
TAB02 DD TCIF_TEXT
	  DD 0
	  DD 0
	  DD TAB_SHEET_2
	  DD 0
	  DD -1
	  DD 0
	  
.code
start:
	INVOKE GetModuleHandle,0
	MOV hInstance,EAX
	INVOKE DialogBoxParam,hInstance,ADDR DLGNAME,0,ADDR DlgProc,0
	INVOKE ExitProcess,0


DlgProc PROC hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	.IF uMsg==WM_CLOSE
    INVOKE Shell_NotifyIcon, NIM_DELETE, ADDR nfi
		INVOKE EndDialog,hWnd,0;SendMessage, hWnd, WM_SYSCOMMAND, SC_MINIMIZE, 0;
	.ELSEIF uMsg==WM_INITDIALOG
	
   invoke LoadMenu, hInstance, ADDR MENU1
      .IF EAX == 0 
    INVOKE ExitProcess, 0
    .ENDIF
   INVOKE SetMenu, hWnd, EAX
   INVOKE DrawMenuBar, hWnd
	 INVOKE ExtractIcon, hInstance, ADDR POP3, 0
	 PUSH EAX
	 INVOKE SendMessage,hWnd, WM_SETICON, ICON_BIG , EAX
	 POP EAX
	 ;INVOKE LoadIcon, 0, IDI_APPLICATION
	 MOV nfi.hIcon, EAX
	 PUSH hWnd
	 POP nfi.hwnd
	 MOV nfi.cbSize, SIZEOF nfi
	 MOV nfi.uID, ICON_ID
	 MOV nfi.uFlags, NIF_ICON or NIF_MESSAGE or NIF_TIP
	 MOV nfi.uCallbackMessage, ICON_MSG
	 
	; MOV nfi.szTip, OFSET DLGNAME
	 MOV EDI, OFFSET nfi.szTip
	 MOV ESI, OFFSET DLGNAME
	 MOV ECX, (SIZEOF DLGNAME)+1
	 COPY_LOOP:
     MOV AL, [ESI]
     MOV [EDI], AL
     INC EDI
     INC ESI
     LOOP COPY_LOOP
     
   INVOKE Shell_NotifyIcon, NIM_ADD,ADDR nfi 

  INVOKE CreatePopupMenu
  MOV MENU_HWND, EAX
  INVOKE InsertMenu, MENU_HWND, 0, MF_BYPOSITION, IDC_CHECK, ADDR MENU_CHECK
  INVOKE InsertMenu, MENU_HWND, 1, MF_BYPOSITION or MF_SEPARATOR, 0, 0
  INVOKE InsertMenu, MENU_HWND, 2, MF_BYPOSITION, IDC_CONFIG, ADDR MENU_CONFIG
  INVOKE InsertMenu, MENU_HWND, 3, MF_BYPOSITION, IDC_CLOSE, ADDR MENU_CLOSE
  
  .ELSEIF uMsg==ICON_MSG
    .IF lParam==WM_RBUTTONDOWN
        ;INVOKE MessageBox, 0, 0, 0, MB_OK
        INVOKE GetCursorPos, ADDR POINT_x
        invoke SetForegroundWindow,hWnd 
        INVOKE TrackPopupMenu, MENU_HWND, TPM_CENTERALIGN, POINT_x, POINT_y, 0, hWnd, 0
       ; INVOKE PostMessage, hWnd, WM_NULL, 0, 0
    .ELSEIF lParam==WM_LBUTTONDBLCLK
        INVOKE ShowWindow, hWnd, SW_SHOWNORMAL
    .ENDIF
  .ELSEIF uMsg==WM_SIZE
     .IF wParam==SIZE_MINIMIZED   
        INVOKE ShowWindow,hWnd, SW_HIDE
    .ENDIF
  .ELSEIF uMsg==WM_COMMAND
    MOV EAX, wParam
    .IF (AX==IDC_CLOSE) || (AX == IDM_EXIT)
        INVOKE ExitProcess, 0
    .ELSEIF (AX == IDC_CONFIG) || (AX == IDM_CONFIG)
        	INVOKE DialogBoxParam,hInstance,ADDR CFG_DLG,0,ADDR ConfigDlgProc,0
    .ENDIF
    
	.ELSE
		MOV EAX,FALSE
		RET
	.ENDIF
		MOV EAX,TRUE
		RET
		
DlgProc ENDP


HideGroupbox PROC hWnd:DWORD, box:DWORD
  .IF box==1
      ;INVOKE EnumChildWindows, GB01_HWND, ADDR ECW_CALL, 0
      INVOKE GetDlgItem, hWnd, IDC_STATIC01
      INVOKE ShowWindow, EAX, SW_HIDE
      INVOKE GetDlgItem, hWnd, IDC_CHK01
      INVOKE ShowWindow, EAX, SW_HIDE
  .ELSEIF box==2
  
  .ENDIF
  RET
HideGroupbox ENDP

ShowGroupbox PROC hWnd:DWORD, box:DWORD
  .IF box==1
      INVOKE GetDlgItem, hWnd, IDC_STATIC01
      INVOKE ShowWindow, EAX, SW_SHOWDEFAULT
      INVOKE GetDlgItem, hWnd, IDC_CHK01
      INVOKE ShowWindow, EAX, SW_SHOWDEFAULT
  .ELSEIF box==2
  
  .ENDIF
  RET
ShowGroupbox ENDP

ConfigDlgProc PROC hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD  
	.IF uMsg==WM_CLOSE
      INVOKE EndDialog,hWnd,0
	.ELSEIF uMsg==WM_INITDIALOG
	    INVOKE SendDlgItemMessage,hWnd,IDC_TAB01,TCM_INSERTITEM,1,ADDR TAB01
      INVOKE SendDlgItemMessage,hWnd,IDC_TAB01,TCM_INSERTITEM,2,ADDR TAB02
      INVOKE GetDlgItem, hWnd, IDC_TAB01
      MOV TAB_HWND, EAX
      
      INVOKE CreateWindowEx,0,ADDR BTN_CLASSNAME,0,WS_CHILD or WS_VISIBLE or BS_GROUPBOX,4,16,250,200,TAB_HWND,IDC_BUTTON01,hInstance,0
      INVOKE CreateWindowEx,0,ADDR BTN_CLASSNAME,0,WS_CHILD or WS_VISIBLE or BS_GROUPBOX,4,16,250,200,TAB_HWND,IDC_BUTTON02,hInstance,0
      INVOKE GetDlgItem, hWnd, IDC_BUTTON01
      MOV GB01_HWND, EAX
      INVOKE GetDlgItem, hWnd, IDC_BUTTON02
      MOV GB02_HWND, EAX
      
      ;INVOKE WritePrivateProfileString, ADDR SECTION_CFG, ADDR CFG_AUTO_START, ADDR WERT, ADDR POP3_INI
      INVOKE GetPrivateProfileInt, ADDR SECTION_CFG, ADDR CFG_AUTO_START, 0, ADDR POP3_INI
      .IF EAX == 1
        INVOKE SendDlgItemMessage, hWnd, IDC_CHK01, BM_SETCHECK, BST_CHECKED, 0
      .ENDIF
      
      MOV TAB01_SEL, 1
  .ELSEIF uMsg==WM_NOTIFY
      MOV EAX, lParam
      MOV ESI, EAX
      INVOKE GetDlgItem, hWnd, IDC_TAB01
      .IF EAX == [ESI]
          ADD ESI, 8
          MOV EAX, [ESI]
          .IF EAX == TCN_SELCHANGE
            INVOKE SendMessage, TAB_HWND, TCM_GETCURSEL, 0, 0
            .IF EAX == 0
                MOV TAB01_SEL, 1
                MOV TAB02_SEL, 0
                INVOKE ShowWindow,GB02_HWND,SW_HIDE
                INVOKE ShowWindow, GB01_HWND, SW_SHOWDEFAULT
                INVOKE HideGroupbox, hWnd, 2
                INVOKE ShowGroupbox, hWnd, 1
            .ELSEIF EAX == 1
                MOV TAB02_SEL, 1
                MOV TAB01_SEL, 0
                INVOKE ShowWindow,GB01_HWND,SW_HIDE
                INVOKE ShowWindow, GB02_HWND, SW_SHOWDEFAULT 
                INVOKE HideGroupbox, hWnd, 1          
                INVOKE ShowGroupbox, hWnd, 2    
            .ENDIF
          .ENDIF
       .ENDIF
       
  .ELSE
    MOV EAX, FALSE
    RET
  .ENDIF
  MOV EAX, TRUE
  RET

ConfigDlgProc ENDP
END start