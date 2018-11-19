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
CHKSUM_PROG PROTO
T_PROG PROTO

IDC_STATIC       equ  1
IDC_STATIC2      equ   2
IDC_STATIC7      equ    7
;IDC_IPADDR01     equ            2003
IDC_EDIT01       equ            1417740288
IDC_BUTT01       equ            2005
IDC_GRP02        equ            2006
IDC_TIMER        equ            1000
IDC_EDIT04       equ            1419839556

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
	
	ucType DB 8
	ucCode DB 0
	usChkS DW 0
		
	DATAS		DB	32 dup("a")
	CHKSUM	DD	0
	
Fehler		DB	"Kein Hostname oder ping angegeben!",0
Fehler_host	DB	"Fehler beim ermitteln der IP!",0
Fehler_Daten	DB	"Fehler beim Senden der Daten",0
FORMAT_STRING	DB	"Der gemessene Ping: %lu ms",0
FORMAT_STRING2	DB	"Der durchschnittliche Ping: %lu ms",0
STRING_BUFFER	DB	SIZEOF FORMAT_STRING2+50 DUP(0)

F1			DB	0

AP_NAME DB "Ping",0

RECV_BUFFER	DB	100 DUP(0)
STRUCT_BUFFER	DB	100 DUP(0)
blen dd 16
temp dd 0
TimerSec DD  1234
TimerID	DD	0
PING		DD		0
PING_GES	DD	0
.code
start:
	INVOKE GetModuleHandle,0
	MOV hInstance,EAX
	INVOKE DialogBoxParam,hInstance,ADDR DLGNAME,0,ADDR DlgProc,0
	INVOKE ExitProcess,0
	invoke InitCommonControls 

DlgProc PROC hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	.IF uMsg==WM_CLOSE
		INVOKE EndDialog,hWnd,0
	;.ELSEIF uMsg==WM_LBUTTONDOWN 
	;	MOV EAX, lParam
	;	MOV BX, AX				;xPos
	;	SHR EAX, 16				;yPos
		
	.ELSEIF uMsg==WM_COMMAND
	
		;INVOKE WSAStartup, 101h, addr wsadata
		;.IF EAX != 0
		
		;.ELSE
			;MOV PING, 0
			INVOKE GetDlgItem,hWnd,IDC_BUTT01
			MOV EBX, EAX
			
			MOV F1, 0
			MOV CHKSUM, 0
			MOV usChkS, 0
			MOV PING_GES, 0
			MOV EAX, wParam
			SHR EAX, 16
		
			.IF (AX==BN_CLICKED) && (lParam==EBX)
			
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
	
						INVOKE SetDlgItemText, hWnd, IDC_STATIC2, Addr Fehler_host
						MOV F1, 1
						;INVOKE MessageBox,0,ADDR AP_NAME,ADDR AP_NAME,MB_OK
					.ENDIF
					
				.ENDIF
				;INVOKE GetDlgItemText, hWnd, IDC_IPADDR01, ADDR IP_Addr, 17
				;INVOKE MessageBox,0,ADDR IP_Addr,ADDR AP_NAME,MB_OK
				;INVOKE inet_addr, addr IP_Addr
				;.IF EAX == INADDR_NONE
				;	MOV F2, 1
				;.ELSE
				;	mov sin_addr, EAX
				;.ENDIF
				
				.IF (F1==1) ;&& (F2==1)
				
					INVOKE SetDlgItemText, hWnd, IDC_STATIC2, ADDR Fehler
					
				.ELSE
					;INVOKE MessageBox,0,ADDR AP_NAME,ADDR AP_NAME,MB_OK
					CALL CHKSUM_PROG

					INVOKE socket, AF_INET, SOCK_RAW, IPPROTO_ICMP
				
					.IF EAX != INVALID_SOCKET
				
						MOV sock, EAX
						MOV ECX, 5
						MOV EBX, 2						;IDC_STATIC2..6
					PING_LOOP:
						PUSH ECX
						PUSH EBX
						INVOKE GetTickCount
						MOV TimerSec, EAX
						INVOKE sendto,sock,addr ucType, 36, 0, addr sin_family, 16

						.IF EAX != SOCKET_ERROR
			
							INVOKE recvfrom, sock, addr RECV_BUFFER, 100, 0, addr STRUCT_BUFFER, addr blen
							INVOKE GetTickCount
							SUB EAX, TimerSec
							MOV PING, EAX
							ADD PING_GES, EAX
							;.if eax != SOCKET_ERROR
								;PUSH EDI
								;lea edi, RECV_BUFFER
								;add edi,EAX	;zeige auf letztes empfangenes zeichen
								;SUB EDI, 516 ;zeige auf ICMP Header
								;mov ax, [edi]
								;cmp ax, 0
								;jne jjj
								;MOV EAX, PING
								PUSH EAX
								PUSH OFFSET FORMAT_STRING
								PUSH OFFSET STRING_BUFFER
								CALL wsprintf
								POP EAX
								POP EAX
								POP EAX
								POP EBX
								INVOKE SetDlgItemText, hWnd, EBX, ADDR STRING_BUFFER

								;POP EDI
							;.ENDIF	
							
						.ELSE
						
								INVOKE SetDlgItemText, hWnd, EBX, ADDR Fehler_Daten
						.ENDIF
						INC EBX
						POP ECX
						DEC ECX
						CMP ECX, 0
						JE PING_LOOP_END
						
						JMP PING_LOOP
						
						PING_LOOP_END:
								
						XOR EDX, EDX
						MOV EBX, 5
						MOV EAX, PING_GES
						DIV EBX
						PUSH EAX
						PUSH OFFSET FORMAT_STRING2
						PUSH OFFSET STRING_BUFFER
						CALL wsprintf
						POP EAX
						POP EAX
						POP EAX
						;POP EBX
						INVOKE SetDlgItemText, hWnd, IDC_STATIC7, ADDR STRING_BUFFER
						
					.ENDIF
				
				.ENDIF
					
			.ENDIF			;BN_CLICKED-IF

		;.ENDIF				;WSA-IF
		
	.ELSE
		MOV EAX,FALSE
		RET
	.ENDIF
		MOV EAX,TRUE
		RET
		
DlgProc ENDP

CHKSUM_PROG	PROC 
		
	LEA EDI, ucType
	MOV ECX, 18
	LOOP_CHK:
		MOV EAX, CHKSUM
		XOR EBX, EBX
		MOV BX, [EDI]
		ADD EAX, EBX
		INC EDI
		INC EDI
		MOV CHKSUM, EAX
	LOOP LOOP_CHK
	MOV EAX, CHKSUM
	SHR EAX, 16
	ADD CHKSUM, EAX
	MOV EAX, CHKSUM
	NOT EAX;, EAX
	MOV usChkS, AX
	
	RET
	
CHKSUM_PROG ENDP

T_PROG PROC
INC PING
T_PROG ENDP

END start