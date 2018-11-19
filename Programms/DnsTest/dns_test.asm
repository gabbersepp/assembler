;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ping v1.0
;; (c) 2005-2006 by Josef Biehler
;; http://www.biehler-josef.de
;; E-Mail: support@biehler-josef.de
;; Lizenz: Open Source 
;; Beschreibung: Pingt einen anderen Computer per IP oder Hostname an und gibt die Zeit zurück
;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License
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

IDC_BUTT01                   equ 2002
IDC_EDIT01 EQU 2003

.data
hInstance	DD	0
wsadata WSADATA <>
DLGNAME	DB	"IDD_DLG01",0
sock dd 0

	sin_family WORD AF_INET
	sin_port WORD 0
	sin_addr DWORD 0
	sin_zero BYTE 0,0,0,0,0,0,0,0
	IP_Addr db 30 DUP(0)
	HOSTN	DB	111 DUP(0)


GOFN OPENFILENAME <>

BUFF_DNAME DB "send.bin",0
R_CHAR DD 0
BUFFER DB 2050 DUP (0)

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

			INVOKE GetDlgItem,hWnd,IDC_BUTT01
			MOV EBX, EAX
			
			MOV EAX, wParam
			SHR EAX, 16
		
			.IF (AX==BN_CLICKED) && (lParam==EBX)
			
        
        INVOKE CreateFile, ADDR BUFF_DNAME, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, 0, OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL, 0
        			
        Invoke ReadFile, EAX, ADDR BUFFER, 2048, ADDR R_CHAR, 0
        
				INVOKE WSAStartup, 101h, addr wsadata
			
        INVOKE GetDlgItemText, hWnd, IDC_EDIT01, ADDR HOSTN, 100
        
				INVOKE inet_addr, ADDR HOSTN
				.IF EAX != INADDR_NONE
				
					mov sin_addr, EAX
					
				.ELSE
				
					INVOKE gethostbyname, ADDR HOSTN
				
					.IF EAX != 0
						
						MOV EAX, [EAX+12]
						MOV EAX, [EAX]
						MOV EAX, [EAX]
						MOV sin_addr, EAX

						
					.ELSE
	

					.ENDIF
            
				.ENDIF
				
										INVOKE socket, AF_INET, SOCK_DGRAM, 0
		
            MOV sock, EAX
            INVOKE htons, 53
            MOV sin_port, AX
			
            INVOKE sendto,sock,addr BUFFER, R_CHAR, 0, addr sin_family, 16
					
			.ENDIF			;BN_CLICKED-IF
		
	.ELSE
		MOV EAX,FALSE
		RET
	.ENDIF
		MOV EAX,TRUE
		RET
		
DlgProc ENDP

END start