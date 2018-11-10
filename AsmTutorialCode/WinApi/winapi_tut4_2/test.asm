.386
.model flat, stdcall
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib
DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWoRD

IDD_DLG01                    equ 2000
IDC_EDIT01                   equ 2001

.data
hInstance	DD	0
DLLHWND	 DD	 0
DLL DB "testdll.dll",0
MSGPROC DB "MSGPROG",0
FUNKTION2 DB "SayHello",0
TEXT DB "Hallo",0
CAPTION DB "Überschrift",0
.code
start:
	INVOKE GetModuleHandle,0
	MOV hInstance,EAX
	INVOKE DialogBoxParam,hInstance,IDD_DLG01,0,ADDR DlgProc,0
	INVOKE ExitProcess,0


DlgProc PROC hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	.IF uMsg==WM_CLOSE
		INVOKE EndDialog,hWnd,0
	.ELSEIF uMsg==WM_COMMAND
		MOV EAX, wParam
		SHR EAX, 16
		.IF AX==BN_CLICKED
			INVOKE LoadLibrary,ADDR DLL
			MOV DLLHWND, EAX
			INVOKE GetProcAddress,EAX,ADDR MSGPROC
			.IF EAX !=0
				PUSH OFFSET CAPTION
				PUSH OFFSET TEXT
				PUSH hWnd
				CALL EAX
			.ENDIF
			INVOKE GetProcAddress, DLLHWND, ADDR FUNKTION2
			.IF EAX != 0
				PUSH OFFSET TEXT
				CALL EAX
			.ENDIF
			INVOKE FreeLibrary,DLLHWND					
		.ENDIF
	.ELSE
		MOV EAX,FALSE
		RET
	.ENDIF
		MOV EAX,TRUE
		RET
		
DlgProc ENDP

END start