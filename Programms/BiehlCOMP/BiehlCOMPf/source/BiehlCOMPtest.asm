.386
.model flat, stdcall
;option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib
;includelib \masm32\test\BiehlCOMP.lib
DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWoRD
;AddLongInt PROTO :DWORD, :DWORD, :DWORD


;     include files
;     ~~~~~~~~~~~~~
      include \MASM32\INCLUDE\masm32.inc
      include \MASM32\INCLUDE\gdi32.inc
      include \MASM32\INCLUDE\Comctl32.inc
      include \MASM32\INCLUDE\comdlg32.inc
      include \MASM32\INCLUDE\shell32.inc

;     libraries
;     ~~~~~~~~~
      includelib \MASM32\LIB\masm32.lib

      includelib \MASM32\LIB\gdi32.lib
      includelib \MASM32\LIB\Comctl32.lib
      includelib \MASM32\LIB\comdlg32.lib
      includelib \MASM32\LIB\shell32.lib
      
;IDC_EDIT01	EQU	2001
;IDC_EDIT02	EQU	2002
;IDC_BUTT01	EQU	2003

IDD_DLG01                    equ 2000
IDC_EDIT01                   equ 2001
IDC_EDIT02                   equ 2002
IDC_BUTT01                   equ 2003
IDC_BUTT02                   equ 2004
;IDC_TIMER					 equ 2005
IDC_BUTT03					 equ 2005

.DATA?
abc db 100 dup(?)
BUFFER1	DB	3000 DUP(?)
BUFFER2	DB	3000 DUP(?)
ERG		DB	100000 DUP(?)

.data
hInstance	DD	0
DLGNAME	DB	"IDD_DLG01",0
DLLHWND	DD	0
DLL db "BiehlCOMP.dll",0
SbLoDou db "SubLongInt",0
AdLoDou DB "AddLongInt",0
CmpLongInt DB "CmpLongInt",0
asd dd 0ffffffffh
qwe db 100 dup(0)
timer dd 0
TIMERID	DD	0
.code
start:
	INVOKE GetModuleHandle,0
	MOV hInstance,EAX
	INVOKE DialogBoxParam,hInstance,ADDR DLGNAME,0,ADDR DlgProc,0
	INVOKE ExitProcess,0


DlgProc PROC hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	.IF uMsg==WM_CLOSE
		INVOKE EndDialog,hWnd,0
	;.ELSEIF uMsg==WM_INITDIALOG
		;INVOKE SetTimer, hWnd, IDC_TIMER, 10, 0
		;MOV TIMERID, EAX
	.ELSEIF uMsg==WM_TIMER
		INC timer
	.ELSEIF uMsg==WM_COMMAND
		MOV EAX, wParam
		;.IF AX==IDC_BUTT01
			SHR EAX, 16
			.IF AX==BN_CLICKED
				PUSH ESI
				PUSH ECX
				MOV CX, 3000
				MOV ESI, OFFSET BUFFER1
				SET_B1_0:
					MOV BYTE PTR [ESI], 0
					INC ESI
					LOOP SET_B1_0
				MOV CX, 3000
				MOV ESI, OFFSET BUFFER2
				SET_B2_0:
					MOV BYTE PTR [ESI], 0
					INC ESI
					LOOP SET_B2_0
				MOV CX, 3000
				MOV ESI, OFFSET ERG
				SET_ERG_0:
					MOV BYTE PTR [ESI], 0
					INC ESI
					LOOP SET_ERG_0
				POP ECX
				POP ESI
					
				INVOKE GetDlgItemText, hWnd, IDC_EDIT01, ADDR BUFFER1, 3000
				.IF EAX != 0
				INVOKE GetDlgItemText, hWnd, IDC_EDIT02, ADDR BUFFER2, 3000
				.ENDIF
				.IF EAX != 0
					MOV EAX, wParam
					.IF AX==IDC_BUTT01
						INVOKE LoadLibrary,ADDR DLL
						MOV DLLHWND, EAX
						INVOKE GetProcAddress,EAX,ADDR SbLoDou
						.IF EAX !=0
							PUSH OFFSET ERG
							PUSH OFFSET BUFFER2
							PUSH OFFSET BUFFER1
							CALL EAX
						.ENDIF
						INVOKE FreeLibrary,DLLHWND
						INVOKE MessageBox, hWnd, ADDR ERG, 0, MB_OK
					;	push edx
				;				MOV EDX,123
		;invoke dwtoa,edx,ADDR qwe
		;invoke MessageBox, hWnd, ADDR qwe, ADDR qwe, MB_OK
		;pop edx
						
					.ELSEIF AX==IDC_BUTT02
						INVOKE LoadLibrary,ADDR DLL
						MOV DLLHWND, EAX
						INVOKE GetProcAddress,EAX,ADDR AdLoDou
						.IF EAX !=0
							;INVOKE SetTimer, hWnd, IDC_TIMER, 1, 0
							;MOV TIMERID, EAX
							;mov timer, 0
							PUSH OFFSET ERG
							PUSH OFFSET BUFFER2
							PUSH OFFSET BUFFER1
							CALL EAX
							;INVOKE KillTimer, hWnd, TIMERID
							;invoke dwtoa, timer, ADDR qwe
							;invoke MessageBox, hWnd, ADDR qwe, ADDR qwe, MB_OK
						.ENDIF
						INVOKE FreeLibrary,DLLHWND
						INVOKE MessageBox, hWnd, ADDR ERG, 0, MB_OK
					.ELSEIF AX==IDC_BUTT03
						INVOKE LoadLibrary,ADDR DLL
						MOV DLLHWND, EAX
						INVOKE GetProcAddress,EAX,ADDR CmpLongInt
						.IF EAX !=0
							;INVOKE SetTimer, hWnd, IDC_TIMER, 1, 0
							;MOV TIMERID, EAX
							;mov timer, 0
							PUSH OFFSET BUFFER2
							PUSH OFFSET BUFFER1
							CALL EAX
							;INVOKE KillTimer, hWnd, TIMERID
							invoke dwtoa, EAX, ADDR qwe
							invoke MessageBox, hWnd, ADDR qwe, ADDR qwe, MB_OK
						.ENDIF
						INVOKE FreeLibrary,DLLHWND
											
					.ENDIF
				.ENDIF
			.ENDIF
		;.ENDIF
	.ELSE
		MOV EAX,FALSE
		RET
	.ENDIF
		MOV EAX,TRUE
		RET
		
DlgProc ENDP

END start