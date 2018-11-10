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
ERG		DB	100000 DUP(?)

.data
hInstance	DD	0
BUFFER2	DB	"hall omdumh astmmi",0 

DLGNAME	DB	"IDD_DLG01",0
DLLHWND	DD	0
DLL db "BiehlCOMP.dll",0
SbLoDou db "SubLongInt",0
AdLoDou DB "AddLongInt",0
CmpLongInt DB "CmpLongInt",0
Explode DB "Explode",0

urlencode db "Explode",0
asd dd 0ffffffffh
m db "m",0
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
	.ELSEIF uMsg==WM_COMMAND
		MOV EAX, wParam
		;.IF AX==IDC_BUTT01
			SHR EAX, 16
			.IF AX==BN_CLICKED
					
				;INVOKE GetDlgItemText, hWnd, IDC_EDIT01, ADDR BUFFER1, 3000
				;.IF EAX != 0
				;INVOKE GetDlgItemText, hWnd, IDC_EDIT02, ADDR BUFFER2, 3000
				;.ENDIF
				;.IF EAX != 0
					MOV EAX, wParam
					.IF AX==IDC_BUTT01
											;	INVOKE MessageBox, hWnd, 0, 0, MB_OK

						INVOKE LoadLibrary,ADDR DLL
						MOV DLLHWND, EAX
						INVOKE GetProcAddress,EAX,ADDR urlencode
						.IF EAX !=0

  mov ebx, " "
	PUSH ebx
	PUSH OFFSET BUFFER2
	CALL EAX

	MOV EDI, EAX
	
	PRINT_LOOP:
	CMP DWORD PTR [EDI], 0FFFFFFFFH
	JE PRINT_LOOP_END
	
	PUSH EDI
	INVOKE MessageBox, hWnd, [EDI], 0, MB_OK
	POP EDI
	ADD EDI, 4
	JMP PRINT_LOOP
	
	PRINT_LOOP_END:
	
						.ELSE
							INVOKE MessageBox, 0, EAX, 0, MB_OK

.ENDIF
						PUSH EBX
						INVOKE FreeLibrary,DLLHWND
						POP EAX
						;MOV EAX, [EAX]
											
					.ENDIF
				;.ENDIF
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