.386
.MODEL FLAT, STDCALL
INCLUDE \masm32\include\windows.inc
INCLUDE \masm32\include\user32.inc
INCLUDE \masm32\include\kernel32.inc
INCLUDELIB \masm32\lib\user32.lib
INCLUDELIB \masm32\lib\kernel32.lib

Main PROTO :DWORD

.DATA
CLASS_NAME DB "EinfachsFenster",0
APP_NAME DB "Programm",0
hInstance DD 0
hWnd DD 0

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

INVOKE CreateWindowEx, 0, ADDR CLASS_NAME, ADDR APP_NAME, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, 0, 0, hInst, 0
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
.ELSE
INVOKE DefWindowProc, hWnd2, uMsg, wParam, lParam
RET
.ENDIF
MOV EAX, FALSE
RET
WndProc ENDP

END START
