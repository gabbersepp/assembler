.386
.model flat, stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib

IDD_DLG01					 equ 2000
IDC_EDIT01                   equ 2001
IDC_BUTT01                   equ 2002
DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWoRD

.data

AP_NAME	DB	"MSGBOX Überschrift",0
hInstance	DD	0
BUFFER DB 100 DUP(0)

.code
start:

	INVOKE GetModuleHandle, 0
	MOV hInstance,EAX
	
	INVOKE DialogBoxParam,hInstance,IDD_DLG01,0,ADDR DlgProc,0
	INVOKE ExitProcess,EAX
	
DlgProc proc hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	.IF uMsg==WM_CLOSE
		INVOKE EndDialog,hWnd,0
	.ELSEIF uMsg==WM_COMMAND
		MOV EAX,wParam
		SHR EAX,16
		.IF AX==BN_CLICKED
			INVOKE SendDlgItemMessage, hWnd, IDC_EDIT01, WM_GETTEXT, 100, ADDR BUFFER
			INVOKE MessageBox,0,ADDR BUFFER,ADDR AP_NAME,MB_OK
		.ENDIF
		.ELSE
		MOV EAX,FALSE
		RET
	.ENDIF
		MOV EAX,TRUE
		RET
DlgProc ENDP
	
	END start
	
end start