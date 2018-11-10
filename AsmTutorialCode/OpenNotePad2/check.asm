.386
.model flat, stdcall
include \masm32\include\windows.inc
include \masm32\include\wsock32.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\wsock32.lib
include \masm32\include\shell32.inc
includelib \masm32\lib\shell32.lib


DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWoRD

.data
hInstance		DD		0
wsadata 		WSADATA <>
DLGNAME			DB		"IDD_DLG01",0
sock 			dd		0

s_family 		WORD 	AF_INET
s_port 			WORD 	0
s_addr 			DWORD 	0
s_zero 			BYTE 	0,0,0,0,0,0,0,0

BBB				DB 		100 DUP(0)

APP_NAME		DB	"NotePad2",0
OPEN_STRING		DB	"open",0
FILES			DB	"notepad2.exe",0
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
		INVOKE FindWindow, ADDR APP_NAME, NULL
	.IF EAX ==0
		INVOKE MessageBox,0,ADDR BBB,ADDR BBB,MB_OK
		INVOKE ShellExecute, hWnd, ADDR OPEN_STRING, ADDR FILES, 0,0,SW_SHOW
	.ENDIF
		INVOKE SendMessage, hWnd, WM_CLOSE, 0,0
	.ELSE
		MOV EAX,FALSE
		RET
	.ENDIF
		MOV EAX,TRUE
		RET
		
DlgProc ENDP

END start