.386
.MODEL FLAT, STDCALL
INCLUDE \masm32\include\windows.inc
INCLUDE \masm32\include\user32.inc
INCLUDE \masm32\include\kernel32.inc
INCLUDELIB \masm32\lib\user32.lib
INCLUDELIB \masm32\lib\kernel32.lib

Main PROTO :DWORD
IDC_BUTTON1 EQU 2001

.DATA
CLASS_NAME DB "EinfachsFenster",0
APP_NAME DB "Programm",0
hInstance DD 0
hWnd DD 0
BTN_CL_NAME DB "button",0
BTN_TEXT DB "Klick mich!",0
MSGB_TEXT DB "Hier steht Text",13,10,"Hier auch",0
MSGB_CAPTION DB "Überschrift",0

.CODE
START:

INVOKE GetModuleHandle,0
MOV hInstance,EAX

INVOKE Main,hInstance
INVOKE ExitProcess,0

Main PROC hInst:DWORD
LOCAL wc:WNDCLASSEX
LOCAL msg:MSG

MOV wc.cbSize,SIZEOF WNDCLASSEX
MOV wc.style, CS_HREDRAW or CS_VREDRAW
MOV wc.lpfnWndProc, OFFSET WndProc
MOV wc.cbClsExtra, 0
MOV wc.cbWndExtra,0
MOV EAX, hInstance
MOV wc.hInstance, EAX
MOV wc.hbrBackground, COLOR_WINDOW+1
MOV wc.lpszMenuName, 0
MOV wc.lpszClassName, OFFSET CLASS_NAME
INVOKE LoadIcon,0,IDI_APPLICATION
MOV wc.hIcon,EAX
MOV wc.hIconSm, EAX
INVOKE LoadCursor, 0, IDC_ARROW
MOV wc.hCursor, EAX
INVOKE RegisterClassEx, ADDR wc

INVOKE CreateWindowEx, 0, ADDR CLASS_NAME, ADDR APP_NAME, WS_OVERLAPPEDWINDOW, 500, 300, 230, 200, 0, 0, hInst, 0
MOV hWnd, EAX

INVOKE ShowWindow, hWnd, SW_SHOWDEFAULT

.WHILE TRUE
INVOKE GetMessage, ADDR msg, 0, 0, 0
.BREAK .IF (!EAX)
INVOKE DispatchMessage, ADDR msg
.ENDW
MOV EAX, msg.wParam

RET
Main ENDP

WndProc PROC hWnd2:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
.IF uMsg==WM_DESTROY
INVOKE PostQuitMessage, 0
.ELSEIF uMsg==WM_CREATE
INVOKE CreateWindowEx, 0, ADDR BTN_CL_NAME, ADDR BTN_TEXT, WS_CHILD or WS_VISIBLE, 10,10,100,50,hWnd2,IDC_BUTTON1,hInstance,0
.ELSEIF uMsg==WM_COMMAND
INVOKE GetDlgItem,hWnd2,IDC_BUTTON1
.IF lParam==EAX
MOV EAX,wParam
SHR EAX,16
.IF EAX==BN_CLICKED
INVOKE MessageBox,hWnd2,ADDR MSGB_TEXT,ADDR MSGB_CAPTION,MB_OK
.ENDIF
.ENDIF

.ELSE
INVOKE DefWindowProc, hWnd2, uMsg, wParam, lParam
RET
.ENDIF
MOV EAX, FALSE
RET
WndProc ENDP

END START
