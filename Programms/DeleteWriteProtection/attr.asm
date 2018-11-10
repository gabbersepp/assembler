;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Attr.exe
;; Setzt die Dateiattribute einer Datei zurück
;; Lizenz: GPL
;; Autor: Josef Biehler (biehler-josef.de)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.386
.model flat, stdcall
;option casemap:none
include \masm32\include\windows.inc
include \masm32\include\wsock32.inc
include \masm32\include\comctl32.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\comdlg32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\comctl32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\wsock32.lib
includelib \masm32\lib\comdlg32.lib

DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWoRD



.data
hInstance	DD	0
DLGNAME	DB	"IDD_DLG01",0
AP_NAME DB "Client",0
CMD_LINE	DD 0
.code
start:
	INVOKE GetModuleHandle,0
	MOV hInstance,EAX
	INVOKE GetCommandLine
	MOV CMD_LINE, EAX
	INVOKE DialogBoxParam,hInstance,ADDR DLGNAME,0,ADDR DlgProc,0
	;INVOKE MessageBox,0, CMD_LINE,ADDR AP_NAME,MB_OK
	INVOKE ExitProcess,0


DlgProc PROC hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	.IF uMsg==WM_CLOSE
		INVOKE EndDialog,hWnd,0
	.ELSEIF uMsg==WM_INITDIALOG
		MOV EAX, CMD_LINE
		XOR ECX, ECX
		
		LOOP1:
			MOV BL, BYTE PTR [EAX]
			INC ECX
			INC EAX
			CMP BL, 0
			JE LOOP1_END
			JMP LOOP1
		
		LOOP1_END:
		
		MOV EAX, CMD_LINE
		DEC ECX
		
		LOOP2:
			INC EAX
			MOV BL, BYTE PTR [EAX]
			CMP BL, 34
			JE LOOP2_END
			INC EAX
			LOOP LOOP2
			
		LOOP2_END:
		
		INC EAX
		PUSH EAX
		
		LOOP3:
			MOV BL, BYTE PTR [EAX]
			CMP BL, 34
			JE LOOP3_END
			INC EAX
			LOOP LOOP3
			
		LOOP3_END:
		MOV BYTE PTR [EAX], 0
		
		POP EAX 
		
		PUSH EAX
		INVOKE SetFileAttributes, EAX, FILE_ATTRIBUTE_NORMAL
		POP EAX
		;INVOKE MessageBox,0, EAX,ADDR AP_NAME,MB_OK
		INVOKE SendMessage, hWnd, WM_CLOSE, 0,0
		
	.ELSE
		MOV EAX,FALSE
		RET
	.ENDIF
		MOV EAX,TRUE
		RET
		
DlgProc ENDP


END start