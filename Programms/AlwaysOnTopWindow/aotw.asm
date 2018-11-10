.386
.model flat, stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib

DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWoRD




.data
hInstance	DD	0
DLGNAME	DB	"IDD_DLG01",0
.code
start:
	INVOKE GetModuleHandle,0
	MOV hInstance,EAX
	INVOKE DialogBoxParam,hInstance,ADDR DLGNAME,0,ADDR DlgProc,0
	INVOKE ExitProcess,0


DlgProc PROC hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	.IF uMsg==WM_CLOSE
		INVOKE EndDialog,hWnd,0
	.ELSEIF uMsg==WM_INITDIALOG
		INVOKE SetWindowPos,hWnd,HWND_TOPMOST,0,0,272,191,0
	.ELSE
		MOV EAX,FALSE
		RET
	.ENDIF
		MOV EAX,TRUE
		RET
		
DlgProc ENDP

END start