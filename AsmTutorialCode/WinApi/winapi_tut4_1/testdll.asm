.386
.MODEL FLAT, STDCALL
INCLUDE \masm32\include\windows.inc
INCLUDE \masm32\include\user32.inc
INCLUDELIB \masm32\lib\user32.lib

.DATA

.CODE
DLL_ENTRY PROC STDCALL hWnd:DWORD,temp1:DWORD,temp2:DWORD
MOV EAX,TRUE
RET
DLL_ENTRY ENDP

MSGPROG PROC STDCALL hWnd:DWORD,a:DWORD,b:DWORD
INVOKE MessageBox,hWnd,a,b,MB_OK
RET
MSGPROG ENDP

SayHello PROC STDCALL HelloText:DWORD
INVOKE MessageBox, 0, HelloText, HelloText, MB_OK
RET
SayHello ENDP

END DLL_ENTRY
