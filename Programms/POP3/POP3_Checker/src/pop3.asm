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
include \masm32\include\Winmm.inc
includelib \masm32\lib\Winmm.lib
include \masm32\include\Advapi32.inc
includelib \masm32\lib\Advapi32.lib
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
IDC_BUTTON04 EQU 5004
IDC_BUTTON05 EQU 5005
IDC_BUTTON06 EQU 5006

IDC_STATIC01  EQU 6001
IDC_STATIC02  EQU 6002
IDC_STATIC04  EQU 6004

IDC_CHK01 EQU 7001

IDC_EDIT01 EQU 8000
IDC_EDIT02  EQU 8001

IDM_CHECK EQU 4001
IDM_CONFIG EQU 4003
IDM_EXIT EQU 4002

IDC_ADD_POP3_EDIT01                   equ 20003
IDC_ADD_POP3_EDIT02                   equ 20004
IDC_ADD_POP3_EDIT03                   equ 20007
IDC_ADD_POP3_EDIT04                   equ 20008
IDC_ADD_POP3_BUTTON01                   equ 20009
IDC_ADD_POP3_EDIT05                   EQU 20010

TIMER_ID EQU 9999

.data
hInstance	DD	0
nfi  NOTIFYICONDATA <>
nfi2 NOTIFYICONDATA <>
POINT_x DD 0
POINT_y DD 0

POS RECT <>

REG_AUTO_PLACE db "Software\\Microsoft\\Windows\\CurrentVersion\\Run",0
REG_HWND DD 0
POP3_NAME DB "POP3 Checker",0

MENU1 DB "IDM_MEN", 0

MENU_HWND DD 0
DLGNAME	DB	"IDD_DLG01",0
CFG_DLG DB "IDD_CONFIG",0
ADD_POP3_DLG DB "IDD_ADD_POP3",0

;;##BiehlCOMP DLL Funktionen
Explode_Addr DD 0
Len_Addr DD 0
POP3_Init_Addr DD 0
POP3_Connect_Addr DD 0
POP3_Stat_Addr DD 0
BIEHLCOMP_DLL DB "BiehlCOMP.dll",0
BIEHL_EXPLODE DB "Explode",0
BIEHL_LEN DB "Len",0
BIEHL_INIT DB "POP3_Init",0
BIEHL_CONNECT DB "POP3_Connect",0
BIEHL_STAT DB "POP3_Stat",0

DLLHWND DD 0

;;######Ini Datei
POP3_INI  DB  "./pop3.ini",0

;Sektion "config"
CFG_AUTO_START  DB  "autostart",0
CFG_VAR_TIME DB "time",0
CFG_VAR_SOUND DB "sound",0
SECTION_CFG DB  "config",0

;Sektion "accounts"
SECTION_ACC DB "accounts",0
ACC__VAR_ACCS DB "accounts_",0
ACC_VAR_COUNT DB "count",0

ACC_VAR_HOST DB "host",0
ACC_VAR_PORT DB "port",0
ACC_VAR_PASS DB "pass",0
ACC_VAR_NICK DB "nick",0


BTN_CLASSNAME DB "button",0
STATIC_CLASSNAME DB "static",0
WERT DB "1",0

POP3 DB "pop3.exe",0
POP3_WAVE DB "pop3.wav",0

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


BUFFER_HMEM DD 0

TAB01_SEL DB  0
TAB02_SEL DB  0

wsP DB "%u",0

STRUCT_HWND DD 0      ;Pointr auf Tabelle mit Pointer auf POP3 Strukturen
HWND_HWND DD  0     ;Pointer auf tabelle mit POP3 Handles
HWND_COUNT DD 0
CFG_TIME DD 0

MAIL_COUNT_TEXT_PART1 DB "Sie haben ",0
MAIL_COUNT_TEXT_PART2 DB " neue E-Mails ",0

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
  
	 PUSH OFFSET BIEHLCOMP_DLL
	 CALL LoadLibrary
	 
	 MOV DLLHWND, EAX
	 
	 PUSH OFFSET BIEHL_EXPLODE
	 PUSH DLLHWND
	 CALL GetProcAddress
	 MOV Explode_Addr, EAX
	 
	 PUSH OFFSET BIEHL_LEN
	 PUSH DLLHWND
	 CALL GetProcAddress
	 MOV Len_Addr, EAX
	 
	 PUSH OFFSET BIEHL_INIT
	 PUSH DLLHWND
	 CALL GetProcAddress
	 MOV POP3_Init_Addr, EAX
	 
	 PUSH OFFSET BIEHL_CONNECT
	 PUSH DLLHWND
	 CALL GetProcAddress
	 MOV POP3_Connect_Addr, EAX
	 
	 PUSH OFFSET BIEHL_STAT
	 PUSH DLLHWND
	 CALL GetProcAddress
	 MOV POP3_Stat_Addr, EAX
	 
	 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Hole hier Acountdaten und alloiziere Speicher
	 
	 PUSH DWORD PTR 30000
   PUSH GMEM_FIXED
   CALL GlobalAlloc
        
   MOV BUFFER_HMEM, EAX
        
	 PUSH OFFSET POP3_INI
   PUSH 0
   PUSH OFFSET ACC_VAR_COUNT
   PUSH OFFSET SECTION_ACC
   CALL GetPrivateProfileInt
   
   PUSH EAX     
   XOR EDX, EDX
   MOV EBX, 4
   MUL EBX
   
   PUSH EAX
   PUSH (GMEM_FIXED or GMEM_ZEROINIT)
   CALL GlobalAlloc
   
   MOV STRUCT_HWND, EAX
   
   MOV EDI, EAX
   POP ECX            ;ECX = Anzahl an Accounts
   ;DEC ECX
   
   CMP ECX, 0
   JE GAL_END
   
   GET_ACC_LOOP:      ;Strukturen holen, ausfüllen
    
    GAL_STEP1:
      DEC ECX
      PUSH ECX
    
      PUSH EDI
      PUSH ECX
      
      PUSH 28
      PUSH (GMEM_FIXED or GMEM_ZEROINIT)
      CALL GlobalAlloc
      
      POP ECX
      POP EDI
      MOV [EDI], EAX
      ADD EDI, 4
      
      PUSH ECX
      PUSH EAX
      CALL GET_HOST         ;Hole HOST und kopiere in Struktur
      
      PUSH ECX
      PUSH EAX
      CALL GET_NICK
      
      PUSH ECX
      PUSH EAX
      CALL GET_PASS
      
      PUSH ECX
      PUSH EAX
      CALL GET_PORT
    
      PUSH EAX
      CALL POP3_Init
      
    ; PUSH EAX 
    ; CALL POP3_Connect
  
      PUSH EAX
      
      MOV EAX, HWND_COUNT
      INC EAX
      XOR EDX, EDX
      MOV EBX, 4
      MUL EBX
      
      PUSH EAX
      
      PUSH EAX
      PUSH GMEM_FIXED
      CALL GlobalAlloc
      
      PUSHA
      PUSH HWND_HWND
      CALL GlobalFree
      POPA
      MOV HWND_HWND, EAX
      
      INC HWND_COUNT
      
      MOV ESI, EAX
      POP EAX
      ADD ESI, EAX
      SUB ESI, 4
      
      POP EAX
      MOV [ESI], EAX
      
      POP ECX
      
      CMP ECX, 0
      JE GAL_END
      JMP GET_ACC_LOOP
    
   ; INVOKE MessageBox, hWnd, [EAX+16], 0, MB_OK
   GAL_END:
  ;
    
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
  ;INVOKE InsertMenu, MENU_HWND, 0, MF_BYPOSITION, IDC_CHECK, ADDR MENU_CHECK
  ;INVOKE InsertMenu, MENU_HWND, 1, MF_BYPOSITION or MF_SEPARATOR, 0, 0
  INVOKE InsertMenu, MENU_HWND, 2, MF_BYPOSITION, IDC_CONFIG, ADDR MENU_CONFIG
  INVOKE InsertMenu, MENU_HWND, 3, MF_BYPOSITION, IDC_CLOSE, ADDR MENU_CLOSE
  
  PUSH OFFSET POP3_INI
  PUSH 0
  PUSH OFFSET CFG_VAR_TIME
  PUSH OFFSET SECTION_CFG
  CALL GetPrivateProfileInt
  
  MOV EBX, 1000
  XOR EDX, EDX
  MUL EBX
    
  MOV CFG_TIME, EAX
  
  PUSH OFFSET POP3_TIMER_PROC
  PUSH CFG_TIME
  PUSH TIMER_ID
  PUSH hWnd
  CALL SetTimer

  .ELSEIF uMsg==WM_PAINT
  
    INVOKE ShowWindow, hWnd, SW_HIDE

  .ELSEIF uMsg==ICON_MSG
    .IF lParam==WM_RBUTTONDOWN
        ;INVOKE MessageBox, 0, 0, 0, MB_OK
        INVOKE GetCursorPos, ADDR POINT_x
        INVOKE SetForegroundWindow,hWnd 
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
        INVOKE Shell_NotifyIcon, NIM_DELETE, ADDR nfi
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

POP3_TIMER_PROC PROC STDCALL hWnd:DWORD, uMsg:DWORD, idEvent:DWORD, dwTimer:DWORD
  PUSH EDI
  PUSH ESI
  PUSH EDX
  PUSH ECX
  
  ;invoke MessageBox, 0, addr MENU_CHECK, addr MENU_CHECK, MB_OK
    
  MOV EDI, HWND_HWND
  MOV ECX, HWND_COUNT
  XOR EDX, EDX
  
  CMP ECX, 0
  JE NO_P3T_LOOP
  
  P3T_LOOP:
    PUSH [EDI]
    CALL POP3_Connect
    PUSH [EDI]
    CALL POP3_Stat
    
    ADD EDX, [EAX]
    
    ADD EDI, 4
    LOOP P3T_LOOP
    
  NO_P3T_LOOP:
  
  PUSH EDX
  
  PUSH BUFFER_HMEM
  CALL SET_BUFFER_0
  
  PUSH EDX
  PUSH OFFSET wsP
  PUSH BUFFER_HMEM
  CALL wsprintf
  ADD ESP, 12

  MOV ESI, BUFFER_HMEM
  ADD ESI, 20
  
  PUSH ESI
  PUSH OFFSET MAIL_COUNT_TEXT_PART1
  CALL COPY_BUFFER
    
  PUSH OFFSET MAIL_COUNT_TEXT_PART1
  CALL Len
 
  ;ADD EAX, OFFSET MAIL_COUNT_TEXT_PART1
  ADD ESI, EAX
      
  PUSH ESI
  PUSH BUFFER_HMEM
  CALL COPY_BUFFER
      
  PUSH BUFFER_HMEM
  CALL Len
  
	ADD ESI, EAX
	
	PUSH ESI
	PUSH OFFSET MAIL_COUNT_TEXT_PART2
  CALL COPY_BUFFER
	
  MOV EDI, BUFFER_HMEM
  ADD EDI, 20
  PUSH EDI
  CALL Len
  INC EAX
	
  
    MOV EDI, OFFSET nfi.szTip
	MOV ESI,BUFFER_HMEM
	ADD ESI, 20
	MOV ECX, EAX
	COPY_LOOP2:
     MOV AL, [ESI]
     MOV [EDI], AL
     INC EDI
     INC ESI
     LOOP COPY_LOOP2
     
  INVOKE Shell_NotifyIcon, NIM_MODIFY,ADDR nfi 
  
  ;invoke MessageBox, hWnd, 0, 0, MB_OK
  INVOKE GetDlgItem, hWnd, ICON_ID
  INVOKE SendMessage, EAX, WM_MOUSEMOVE , 0, 0
   
  POP EDX
  CMP EDX, 0
  JE TIMER_PROC_END
  
  PUSH SND_FILENAME
  PUSH 0
  PUSH OFFSET POP3_WAVE
  CALL PlaySound
  
  TIMER_PROC_END:
  
  POP ECX
  POP EDX
  POP ESI
  POP EDI
  
  
  
  
RET
POP3_TIMER_PROC ENDP



GET_PORT PROC STDCALL lpStruct:DWORD, nNum:DWORD
PUSHA
 
 
  PUSH OFFSET POP3_INI
  PUSH 30000
  PUSH BUFFER_HMEM
  PUSH 0
  PUSH OFFSET ACC__VAR_ACCS
  PUSH OFFSET SECTION_ACC
  CALL GetPrivateProfileString
  
  PUSH "|"
  PUSH BUFFER_HMEM
  CALL Explode
  
  MOV EDI, EAX
  XOR EDX, EDX
  MOV EBX, 4
  MOV EAX, nNum
  MUL EBX
  ADD EDI, EAX          ;Zeige auf Pointer, der auf Sectionsnamen zeigt
  
  MOV EAX, [EDI]
  
  PUSH OFFSET POP3_INI
  PUSH 0
  PUSH OFFSET ACC_VAR_PORT
  PUSH EAX
  CALL GetPrivateProfileInt
  
  ;Copybvuffer source, destination
  
  MOV EDI, lpStruct
  ADD EDI, 4
  
  MOV [EDI], EAX
  
POPA
RET
GET_PORT ENDP

GET_PASS PROC STDCALL lpStruct:DWORD, nNum:DWORD
PUSHA
 
 
  PUSH OFFSET POP3_INI
  PUSH 30000
  PUSH BUFFER_HMEM
  PUSH 0
  PUSH OFFSET ACC__VAR_ACCS
  PUSH OFFSET SECTION_ACC
  CALL GetPrivateProfileString
  
  PUSH "|"
  PUSH BUFFER_HMEM
  CALL Explode
  
  MOV EDI, EAX
  XOR EDX, EDX
  MOV EBX, 4
  MOV EAX, nNum
  MUL EBX
  ADD EDI, EAX          ;Zeige auf Pointer, der auf Sectionsnamen zeigt
  
  MOV EAX, [EDI]
  
  PUSH OFFSET POP3_INI
  PUSH 30000
  PUSH BUFFER_HMEM
  PUSH 0
  PUSH OFFSET ACC_VAR_PASS
  PUSH EAX
  CALL GetPrivateProfileString
  
  ;Copybvuffer source, destination
  
  MOV EDI, lpStruct
  ADD EDI, 16
  
  PUSH BUFFER_HMEM
  CALL Len
  
  PUSH EDI
  INC EAX
  PUSH EAX
  PUSH (GMEM_FIXED or GMEM_ZEROINIT)
  CALL GlobalAlloc
  POP EDI
  
  PUSH EAX
  PUSH EAX
  PUSH BUFFER_HMEM
  CALL COPY_BUFFER
  POP EAX
  
  MOV [EDI], EAX
  
POPA
RET
GET_PASS ENDP

GET_NICK PROC STDCALL lpStruct:DWORD, nNum:DWORD
PUSHA
 
 
  PUSH OFFSET POP3_INI
  PUSH 30000
  PUSH BUFFER_HMEM
  PUSH 0
  PUSH OFFSET ACC__VAR_ACCS
  PUSH OFFSET SECTION_ACC
  CALL GetPrivateProfileString
  
  PUSH "|"
  PUSH BUFFER_HMEM
  CALL Explode
  
  MOV EDI, EAX
  XOR EDX, EDX
  MOV EBX, 4
  MOV EAX, nNum
  MUL EBX
  ADD EDI, EAX          ;Zeige auf Pointer, der auf Sectionsnamen zeigt
  
  MOV EAX, [EDI]
  
  PUSH OFFSET POP3_INI
  PUSH 30000
  PUSH BUFFER_HMEM
  PUSH 0
  PUSH OFFSET ACC_VAR_NICK
  PUSH EAX
  CALL GetPrivateProfileString
  
  ;Copybvuffer source, destination
  
  MOV EDI, lpStruct
  ADD EDI, 12
  
  PUSH BUFFER_HMEM
  CALL Len
  
  PUSH EDI
  INC EAX
  PUSH EAX
  PUSH (GMEM_FIXED or GMEM_ZEROINIT)
  CALL GlobalAlloc
  POP EDI
  
  PUSH EAX
  PUSH EAX
  PUSH BUFFER_HMEM
  CALL COPY_BUFFER
  POP EAX
  
  MOV [EDI], EAX
  
POPA
RET
GET_NICK ENDP

GET_HOST PROC STDCALL lpStruct:DWORD, nNum:DWORD
PUSHA
 
 
  PUSH OFFSET POP3_INI
  PUSH 30000
  PUSH BUFFER_HMEM
  PUSH 0
  PUSH OFFSET ACC__VAR_ACCS
  PUSH OFFSET SECTION_ACC
  CALL GetPrivateProfileString
  
  PUSH "|"
  PUSH BUFFER_HMEM
  CALL Explode
  
  MOV EDI, EAX
  XOR EDX, EDX
  MOV EBX, 4
  MOV EAX, nNum
  MUL EBX
  ADD EDI, EAX          ;Zeige auf Pointer, der auf Sectionsnamen zeigt
  
  MOV EAX, [EDI]
  
  PUSH OFFSET POP3_INI
  PUSH 30000
  PUSH BUFFER_HMEM
  PUSH 0
  PUSH OFFSET ACC_VAR_HOST
  PUSH EAX
  CALL GetPrivateProfileString
  
  ;Copybvuffer source, destination
  
  MOV EDI, lpStruct
  
  PUSH BUFFER_HMEM
  CALL Len
  
  PUSH EDI
  INC EAX
  PUSH EAX
  PUSH (GMEM_FIXED or GMEM_ZEROINIT)
  CALL GlobalAlloc
  POP EDI
  
  PUSH EAX
  PUSH EAX
  PUSH BUFFER_HMEM
  CALL COPY_BUFFER
  POP EAX
  
  MOV [EDI], EAX
  
POPA
RET
GET_HOST ENDP

HideGroupbox PROC hWnd:DWORD, box:DWORD
  .IF box==1
      ;INVOKE EnumChildWindows, GB01_HWND, ADDR ECW_CALL, 0
      INVOKE GetDlgItem, hWnd, IDC_STATIC01
      INVOKE ShowWindow, EAX, SW_HIDE
      INVOKE GetDlgItem, hWnd, IDC_CHK01
      INVOKE ShowWindow, EAX, SW_HIDE
      INVOKE GetDlgItem, hWnd, IDC_STATIC02
      INVOKE ShowWindow, EAX, SW_HIDE
      INVOKE GetDlgItem, hWnd, IDC_BUTTON04
      INVOKE ShowWindow, EAX, SW_HIDE
      INVOKE GetDlgItem, hWnd, IDC_BUTTON05
      INVOKE ShowWindow, EAX, SW_HIDE
      INVOKE GetDlgItem, hWnd, IDC_BUTTON06
      INVOKE ShowWindow, EAX, SW_HIDE
      INVOKE GetDlgItem, hWnd, IDC_EDIT01
      INVOKE ShowWindow, EAX, SW_HIDE
      
  .ELSEIF box==2
      PUSH IDC_STATIC04
      PUSH hWnd
      CALL GetDlgItem
      PUSH SW_HIDE
      PUSH EAX
      CALL ShowWindow
      
      PUSH IDC_EDIT02
      PUSH hWnd
      CALL GetDlgItem
      PUSH SW_HIDE
      PUSH EAX
      CALL ShowWindow
  .ENDIF
  RET
HideGroupbox ENDP

ShowGroupbox PROC hWnd:DWORD, box:DWORD
  .IF box==1
      INVOKE GetDlgItem, hWnd, IDC_STATIC01
      INVOKE ShowWindow, EAX, SW_SHOWDEFAULT
      INVOKE GetDlgItem, hWnd, IDC_CHK01
      INVOKE ShowWindow, EAX, SW_SHOWDEFAULT
      
      INVOKE GetDlgItem, hWnd, IDC_STATIC02
      INVOKE ShowWindow, EAX, SW_SHOWDEFAULT
      INVOKE GetDlgItem, hWnd, IDC_BUTTON04
      INVOKE ShowWindow, EAX, SW_SHOWDEFAULT
      INVOKE GetDlgItem, hWnd, IDC_BUTTON05
      INVOKE ShowWindow, EAX, SW_SHOWDEFAULT
      INVOKE GetDlgItem, hWnd, IDC_BUTTON06
      INVOKE ShowWindow, EAX, SW_SHOWDEFAULT
      INVOKE GetDlgItem, hWnd, IDC_EDIT01
      INVOKE ShowWindow, EAX, SW_SHOWDEFAULT
      
  .ELSEIF box==2
      PUSH IDC_STATIC04
      PUSH hWnd
      CALL GetDlgItem
      PUSH SW_SHOWNORMAL
      PUSH EAX
      CALL ShowWindow
      
      PUSH IDC_EDIT02
      PUSH hWnd
      CALL GetDlgItem
      PUSH SW_SHOWNORMAL
      PUSH EAX
      CALL ShowWindow
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
      PUSH 2
      PUSH hWnd
      CALL HideGroupbox
      
      PUSH OFFSET POP3_INI
      PUSH 1000
      PUSH BUFFER_HMEM
      PUSH 0
      PUSH OFFSET CFG_VAR_SOUND
      PUSH OFFSET SECTION_CFG
      CALL GetPrivateProfileString
      
      PUSH IDC_EDIT02
      PUSH hWnd
      CALL GetDlgItem
      
      PUSH BUFFER_HMEM
      PUSH 0
      PUSH WM_SETTEXT
      PUSH EAX
      CALL SendMessage
      
      PUSH OFFSET POP3_INI
      PUSH 1000
      PUSH BUFFER_HMEM
      PUSH 0
      PUSH OFFSET CFG_VAR_TIME
      PUSH OFFSET SECTION_CFG
      CALL GetPrivateProfileString
      
      PUSH IDC_EDIT01
      PUSH hWnd
      CALL GetDlgItem
      
      PUSH BUFFER_HMEM
      PUSH 0
      PUSH WM_SETTEXT
      PUSH EAX
      CALL SendMessage
      
      
  .ELSEIF uMsg==WM_COMMAND
      MOV EAX, wParam
      MOV EBX, wParam
      SHR EBX, 16
      CMP BX, BN_CLICKED
      JNE CFG_WM_COMMAND_END
        CMP AX, IDC_BUTTON04
        JE CFG_WM_COMMAND_BUTT04
        CMP AX, IDC_BUTTON05
        JE CFG_WM_COMMAND_BUTT05
        CMP AX, IDC_BUTTON06
        JE CFG_WM_COMMAND_BUTT06
        CMP AX, IDC_BUTTON03
        JE CFG_WM_COMMAND_BUTT03
        
        JMP CFG_WM_COMMAND_END
        
          CFG_WM_COMMAND_BUTT03:
          
            PUSH IDC_CHK01
            PUSH hWnd
            CALL GetDlgItem
            
            PUSH 0
            PUSH 0
            PUSH BM_GETCHECK
            PUSH EAX
            CALL SendMessage
            
            CMP EAX, BST_CHECKED
            JNE NOT_CHECKED
            
              MOV EDI, BUFFER_HMEM
              MOV BYTE PTR [EDI], "1"
              INC EDI
              MOV BYTE PTR [EDI], 0
              
              PUSH OFFSET POP3_INI
              PUSH BUFFER_HMEM
              PUSH OFFSET CFG_AUTO_START
              PUSH OFFSET SECTION_CFG
              CALL WritePrivateProfileString
              
              PUSH OFFSET REG_HWND
              PUSH KEY_ALL_ACCESS
              PUSH 0
              PUSH OFFSET REG_AUTO_PLACE
              PUSH HKEY_LOCAL_MACHINE
              CALL RegOpenKeyEx
            	
            	PUSH BUFFER_HMEM
            	CALL SET_BUFFER_0
            	
            	PUSH 1000
            	PUSH BUFFER_HMEM
            	PUSH 0
            	CALL GetModuleFileName
            	
            	INC EAX
            	
            	PUSH EAX
            	PUSH BUFFER_HMEM
            	PUSH REG_SZ
            	PUSH 0
            	PUSH OFFSET POP3_NAME
            	PUSH REG_HWND
            	CALL RegSetValueEx
            	
            	PUSH REG_HWND
            	CALL RegCloseKey
            	
            	JMP AFTER_NOT_CHECKED
            
            
            NOT_CHECKED:
            
              MOV EDI, BUFFER_HMEM
              MOV BYTE PTR [EDI], "0"
              INC EDI
              MOV BYTE PTR [EDI], 0
              
              PUSH OFFSET POP3_INI
              PUSH BUFFER_HMEM
              PUSH OFFSET CFG_AUTO_START
              PUSH OFFSET SECTION_CFG
              CALL WritePrivateProfileString
              
              PUSH OFFSET REG_HWND
              PUSH KEY_ALL_ACCESS
              PUSH 0
              PUSH OFFSET REG_AUTO_PLACE
              PUSH HKEY_LOCAL_MACHINE
              CALL RegOpenKeyEx

              PUSH OFFSET POP3_NAME
              PUSH REG_HWND
              CALL RegDeleteValue
              
              PUSH REG_HWND
              CALL RegCloseKey
            
            AFTER_NOT_CHECKED:
            
            PUSH IDC_EDIT01
            PUSH hWnd
            CALL GetDlgItem
        
            PUSH BUFFER_HMEM
            PUSH 1000
            PUSH WM_GETTEXT
            PUSH EAX
            CALL SendMessage
        
            PUSH OFFSET POP3_INI
            PUSH BUFFER_HMEM
            PUSH OFFSET CFG_VAR_TIME
            PUSH OFFSET SECTION_CFG
            CALL WritePrivateProfileString
            
            PUSH IDC_EDIT02
            PUSH hWnd
            CALL GetDlgItem
            
            PUSH BUFFER_HMEM
            PUSH 1000
            PUSH WM_GETTEXT
            PUSH EAX
            CALL SendMessage
            
            PUSH OFFSET POP3_INI
            PUSH BUFFER_HMEM
            PUSH OFFSET CFG_VAR_SOUND
            PUSH OFFSET SECTION_CFG
            CALL WritePrivateProfileString
            
            JMP CFG_WM_COMMAND_END
        
          CFG_WM_COMMAND_BUTT04:
            PUSH DWORD PTR 0
            PUSH OFFSET ADD_POP3_PROC
            PUSH DWORD PTR 0
            PUSH OFFSET ADD_POP3_DLG
            PUSH hInstance
            CALL DialogBoxParam
            JMP CFG_WM_COMMAND_END
            
         CFG_WM_COMMAND_BUTT05:
            JMP CFG_WM_COMMAND_END
            
         CFG_WM_COMMAND_BUTT06:
            JMP CFG_WM_COMMAND_END
            
      CFG_WM_COMMAND_END:
      
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

ADD_POP3_PROC PROC STDCALL hWnd:DWORD, uMsg:DWORD,wParam:DWORD,lParam:DWORD 
  CMP uMsg, WM_CLOSE
  JE ADD_POP3_WM_CLOSE
  CMP uMsg, WM_COMMAND
  JE ADD_POP3_WM_COMMAND
  
  MOV EAX, FALSE
  
  JMP ADD_POP3_PROC_END
  
  
    ADD_POP3_WM_COMMAND:
      MOV EAX, wParam
      SHR EAX, 16
      CMP AX, BN_CLICKED
      JE ADD_POP3_WM_COMMAND_BN_CLICKED
      MOV EAX, TRUE
      JMP ADD_POP3_PROC_END
      
      ADD_POP3_WM_COMMAND_BN_CLICKED:
        
        PUSH BUFFER_HMEM
        CALL SET_BUFFER_0
        
        PUSH IDC_ADD_POP3_EDIT05
        PUSH hWnd
        CALL GetDlgItem
        ;INVOKE GetDlgItem, hWnd, IDC_ADD_POP3_EDIT05              ;E-Mail 
        
        ;Abshcnitt, um Sektionsname abzufragen
        PUSH BUFFER_HMEM
        PUSH 1000
        PUSH WM_GETTEXT
        PUSH EAX
        CALL SendMessage
        ;        INVOKE SendMessage, EAX, WM_GETTEXT, 1000, BUFFER_HMEM
        
        
        MOV EDI, BUFFER_HMEM
        ADD EDI, EAX                ;Länge von eingelesenen Daten auf BUFFER_HMEM adieren, um Sektion zusamnmenstelen zu können
        
        ADD EDI, 10
        
        PUSH EDI
        
        ;Kopiere hier den Abshcnitt für die Ini zusammen
        PUSH EDI
        PUSH OFFSET ACC_VAR_HOST
        CALL COPY_BUFFER
        ADD EDI, EAX
        MOV BYTE PTR [EDI], "="
        INC EDI
        
        PUSH IDC_ADD_POP3_EDIT01  ;Host
        PUSH hWnd
        CALL GetDlgItem
        
        PUSH EDI
        PUSH 1000
        PUSH WM_GETTEXT
        PUSH EAX
        CALL SendMessage
        
        ADD EDI, EAX
        INC EDI
        
        PUSH EDI
        PUSH OFFSET ACC_VAR_PORT
        CALL COPY_BUFFER
        ADD EDI, EAX
        MOV BYTE PTR [EDI], "="
        INC EDI
        
        PUSH IDC_ADD_POP3_EDIT02  ;Port
        PUSH hWnd
        CALL GetDlgItem
        
        PUSH EDI
        PUSH 1000
        PUSH WM_GETTEXT
        PUSH EAX
        CALL SendMessage
        
        ADD EDI, EAX
        INC EDI
        
        PUSH EDI
        PUSH OFFSET ACC_VAR_NICK
        CALL COPY_BUFFER
        ADD EDI, EAX
        MOV BYTE PTR [EDI], "="
        INC EDI
        
        PUSH IDC_ADD_POP3_EDIT03  ;NICK
        PUSH hWnd
        CALL GetDlgItem
        
        PUSH EDI
        PUSH 1000
        PUSH WM_GETTEXT
        PUSH EAX
        CALL SendMessage
        
        ADD EDI, EAX
        INC EDI
        
        PUSH EDI
        PUSH OFFSET ACC_VAR_PASS
        CALL COPY_BUFFER
        ADD EDI, EAX
        MOV BYTE PTR [EDI], "="
        INC EDI
        
        PUSH IDC_ADD_POP3_EDIT04  ;PASSWORT
        PUSH hWnd
        CALL GetDlgItem
        
        PUSH EDI
        PUSH 1000
        PUSH WM_GETTEXT
        PUSH EAX
        CALL SendMessage
        
        ADD EDI, EAX
        INC EDI
        
        POP EDI
        
        PUSH OFFSET POP3_INI
        PUSH EDI
        PUSH BUFFER_HMEM
        CALL WritePrivateProfileSection
        
        PUSH BUFFER_HMEM
        CALL SET_BUFFER_0
        
        ;Hole hier alle eingetragenen Accounts
        PUSH OFFSET POP3_INI
        PUSH 30000
        PUSH BUFFER_HMEM
        PUSH 0
        PUSH OFFSET ACC__VAR_ACCS
        PUSH OFFSET SECTION_ACC
        CALL GetPrivateProfileString
        
        ;PUSH "|"
        ;PUSH BUFFER_HMEM
        ;CALL Explode
        
        ;Füge neuen hinzu
        
        PUSH BUFFER_HMEM
        CALL Len
        MOV EDI, BUFFER_HMEM
        ADD EDI, EAX
        
        MOV ESI, EDI
        ADD ESI, 2000
        
        PUSH EDI
        PUSH ESI
        
        PUSH IDC_ADD_POP3_EDIT05
        PUSH hWnd
        CALL GetDlgItem
        ;INVOKE GetDlgItem, hWnd, IDC_ADD_POP3_EDIT05              ;E-Mail 
        
        ;Abshcnitt, um Sektionsname abzufragen
        PUSH ESI
        PUSH 1000
        PUSH WM_GETTEXT
        PUSH EAX
        CALL SendMessage
        
        POP ESI
        POP EDI
        
        PUSH EDI
        PUSH ESI
        CALL COPY_BUFFER
        
        ADD EDI, EAX
        MOV BYTE PTR [EDI], "|"
        
        INC EDI
        MOV BYTE PTR [EDI], 0
        INC EDI
        MOV BYTE PTR [EDI], 0
        
        PUSH OFFSET POP3_INI
        PUSH BUFFER_HMEM
        PUSH OFFSET ACC__VAR_ACCS
        PUSH OFFSET SECTION_ACC
        CALL WritePrivateProfileString
      
        PUSH OFFSET POP3_INI
        PUSH 0
        PUSH OFFSET ACC_VAR_COUNT
        PUSH OFFSET SECTION_ACC
        CALL GetPrivateProfileInt
        INC EAX
        
        PUSH EAX
        PUSH BUFFER_HMEM
        CALL SET_BUFFER_0
        POP EAX
        
        
        PUSH EAX
        PUSH OFFSET wsP
        PUSH BUFFER_HMEM
        CALL wsprintf
        ADD ESP, 12
        
        PUSH OFFSET POP3_INI
        PUSH BUFFER_HMEM
        PUSH OFFSET ACC_VAR_COUNT
        PUSH OFFSET SECTION_ACC
        CALL WritePrivateProfileString
        
        
        PUSH BUFFER_HMEM
        CALL GlobalFree
        
        JMP ADD_POP3_WM_CLOSE
        
        
        
    ADD_POP3_WM_CLOSE:
      PUSH DWORD PTR 0
      PUSH hWnd
      CALL EndDialog
      MOV EAX, TRUE
      
  ADD_POP3_PROC_END:

RET
ADD_POP3_PROC ENDP

SET_BUFFER_0 PROC lpStr:DWORD
PUSH EDI

MOV EDI, lpStr
SB0_LOOP:
  CMP BYTE PTR [EDI], 0
  JE SB0_LOOP_END
  MOV BYTE PTR [EDI], 0
  INC EDI
  JMP SB0_LOOP
SB0_LOOP_END:

POP EDI
RET
SET_BUFFER_0 ENDP

COPY_BUFFER PROC STDCALL SOURCE:DWORD, DEST:DWORD
PUSH EDI
PUSH ESI
PUSH ECX

MOV EDI, SOURCE
MOV ESI, DEST
XOR EAX, EAX
CB_LOOP:
  CMP BYTE PTR [EDI], 0
  JE CB_LOOP_END
  MOV CL, [EDI]
  MOV [ESI], CL
  INC EDI
  INC ESI
  INC EAX
  JMP CB_LOOP
  
CB_LOOP_END:
POP ECX
POP ESI
POP EDI
RET
COPY_BUFFER ENDP

Explode PROC lpStr:DWORD, nChar:DWORD
PUSH nChar
PUSH lpStr
CALL Explode_Addr
RET
Explode ENDP

Len PROC lpStr:DWORD
PUSH lpStr
CALL Len_Addr
RET
Len ENDP

POP3_Init PROC lpStruct:DWORD
PUSH lpStruct
CALL POP3_Init_Addr
RET
POP3_Init ENDP

POP3_Connect PROC hWnd:DWORD
PUSH hWnd
CALL POP3_Connect_Addr
RET
POP3_Connect ENDP

POP3_Stat PROC hWnd:DWORD
PUSH hWnd
CALL POP3_Stat_Addr
RET
POP3_Stat ENDP

END start