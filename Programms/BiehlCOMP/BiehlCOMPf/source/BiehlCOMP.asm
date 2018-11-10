;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BiehlCOMP v0.4.0
;; (c) 2005-2006 by Josef Biehler
;; http://www.biehler-josef.de
;; http://www.biehlcomp.biehler-josef.de
;; E-Mail: support@biehler-josef.de
;; Lizenz: Open Source (d.h. der Code und die DLL kann u.a. kostenlos verwendet werden)
;; Beschreibung:Diese DLL bietet zum aktuellen Zeitpunkt eine mathematische FUnktion,
;; 				mit der theoretisch unendlich lange Zahlen verarbeitet werden können.
;;
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
.MODEL FLAT, STDCALL
INCLUDE \masm32\include\windows.inc
INCLUDE \masm32\include\user32.inc
INCLUDE \masm32\include\kernel32.inc
INCLUDELIB \masm32\lib\user32.lib
INCLUDELIB \masm32\lib\kernel32.lib
include \masm32\include\masm32.inc

includelib \masm32\lib\masm32.lib


GetSign PROTO :DWORD
SubLongInt PROTO :DWORD, :DWORD, :DWORD
RemoveSignQ1 PROTO :DWORD
RemoveSignQ2 PROTO :DWORD
Pos PROTO :DWORD, :DWORD

.DATA
Q1_LEN		DWORD	0			;Länge der ersten Zahl
Q2_LEN		DWORD	0			;Länge der zweiten Zahl
ERG_LEN		DWORD	0			;Ergebnis-Länge
TEMP		DB		0			;Zwischenspeicher für Übertrag
TEMP2		DB		0			;Zwischenspeicher für Übertrag
STATUS		DB		0			;Statusbyte
Q1_NKS_LEN	DWORD	0			;Länge der Nachkommastelllen (mit Komma) v. Zahl1
Q2_NKS_LEN	DWORD	0			;Länge der Nachkommastellen (mit Komma) v. Zahl2
VER_STR		DB		"0.4.0",0		;Versionsnummer
Q1_SIGN		DB		"+"			;Vorzeichen der Zahlen
Q2_SIGN		DB		"+"			;Vorzeichen der Zahlen
ERG_SIGN	DB		"+"			;Vorzeichen des Ergebnisses
GLOBAL_STATUS DB 	0			;Globaler Status		
hwnd1 DWORD			0

FNAME Db "test.bmp",0
wsP	DB "%u",0
TEMP_WSOUT DB 15 DUP(0)
wsp2 DB "%02X",0

.CODE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DLL_ENTRY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DLL_ENTRY PROC STDCALL hWnd:DWORD,temp1:DWORD,temp2:DWORD
mov EAX, hWnd
mov hwnd1, eax 
MOV EAX,TRUE
RET
DLL_ENTRY ENDP


urldecode PROC STDCALL str2:DWORD, len2:DWORD

	PUSH EBX
	PUSH ECX
	PUSH EDI
	PUSH ESI
	PUSH EDX
	
	XOR EDX, EDX
	MOV ECX, len2
	MOV ESI, str2
	
	INVOKE GlobalAlloc, GMEM_FIXED, ECX
	MOV EDI, EAX
	PUSH EDI
	ADD EDI, 4
	ud_Loop:
		MOV AL, [ESI]
		CMP AL, "%"
		JE ud_HEX
		CMP AL, "+"
		JE ud_SP
		CMP Al, 0
		JE ud_LOOP_END
		
		INC EDX
		MOV [EDI], AL
		INC EDI
		INC ESI
		LOOP ud_Loop
		JMP ud_LOOP_END
		
	ud_HEX:
		INC ESI
		MOV AL, [ESI]
		MOV [TEMP_WSOUT], AL
		INC ESI
		MOV AL, [ESI]
		MOV [TEMP_WSOUT+1], AL
		MOV BYTE PTR [TEMP_WSOUT+2], 0
		PUSH EDX
		INVOKE htodw, ADDR TEMP_WSOUT
		POP EDX
		INC EDX
		MOV [EDI], AL
		INC EDI
		INC ESI
		LOOP ud_Loop
		JMP ud_LOOP_END
		
	ud_SP:
		INC EDX
		MOV BYTE PTR [EDI], " "
		INC ESI
		INC EDI
		LOOP ud_Loop
		
	ud_LOOP_END:
	POP EAX
	MOV EDI, EAX
	MOV [EDI], EDX
	
	POP EDX
	POP ESI
	POP EDI
	POP ECX
	POP EBX
	RET
urldecode ENDP
	

Is_A_Z PROC STDCALL str2:BYTE
	MOV AL, str2
	CMP AL, "A"
	JAE IAZ_NEXT
	MOV AX, 1
	RET
	IAZ_NEXT:
	CMP AL, "Z"
	JA IAZ_1
	MOV AX, 0
	RET
	IAZ_1:
	MOV AX, 1
	RET
Is_A_Z ENDP

Is_a_z PROC STDCALL str2:BYTE
	MOV AL, str2
	CMP AL, "a"
	JAE Ia_z_NEXT
	MOV AX, 1
	RET
	Ia_z_NEXT:
	CMP AL, "z"
	JA Ia_z_1
	MOV AX, 0
	RET
	Ia_z_1:
	MOV AX, 1
	RET
Is_a_z ENDP


Is_Num PROC STDCALL str2:BYTE
	MOV AL, str2
	CMP AL, "0"
	JAE IN_NEXT
	MOV AX, 1
	RET
	IN_NEXT:
	CMP AL, "9"
	JA IN_1
	MOV AX, 0
	RET
	IN_1:
	MOV AX, 1
	RET
Is_Num ENDP

ChkChar PROC STDCALL str2:BYTE
	PUSH EBX
	
	MOV AL, str2
	CMP AL, "_"
	JE CC_0
	CMP AL, "-"
	JE CC_0
	CMP AL, "."
	JE CC_0
	CMP AL, " "
	JE CC_0
	INVOKE Is_Num, AL
	CMP AX, 0
	JE CC_0
	INVOKE Is_A_Z, str2
	CMP AX, 0
	JE CC_0
	INVOKE Is_a_z, str2
	CMP AX, 0
	JE CC_0
	MOV AX, 1
	RET
	CC_0:
	MOV AX, 0
	RET
ChkChar ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; urlencode PROTO :DWORD, :DWORD
;; Version: 0.01
;; (C) 2005-2006 by Josef Biehler
;; Beschreibung: urlencode()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
urlencode PROC STDCALL str2:DWORD, len2:DWORD
	PUSH ESI
	PUSH EBX
	PUSH ECX
	PUSH EDI
	MOV ESI, str2
	MOV ECX, len2
	XOR EBX, EBX
	;Berechne die zu erwartende Stringgröße des Ergebnisses
	
	CALC_LOOP:
		
		MOV AL, [ESI]
		INVOKE ChkChar, AL
		.IF AL != 0
		
			ADD EBX, 3
			
		.ELSE
		
			INC EBX
			
		.ENDIF
		INC ESI
		LOOP CALC_LOOP
		
	CALC_END:
	;INVOKE wsprintf, ADDR Fehler_Open, ADDR wsP, EBX
	;INVOKE MessageBox,0,ADDR Fehler,ADDR Fehler_Open,MB_OK
	
	;POP EDI
	;POP ECX
	;POP EBX
	;POP ESI
	;RET
	INVOKE GlobalAlloc, GMEM_FIXED, EBX
	PUSH EAX
	MOV ESI, str2
	MOV EDI, EAX
	MOV ECX, len2
	PUSH ECX
	INVOKE wsprintf, ADDR FNAME, ADDR wsP, ECX
	;INVOKE MessageBox,0,ADDR Fehler,ADDR FNAME,MB_OK
	POP ECX
	XOR EAX, EAX
	DO_LOOP:
		
		MOV AL, [ESI]
		PUSH ECX
		INVOKE ChkChar, AL
		POP ECX
		MOV BL, AL
		MOV AL, [ESI]
		.IF BL == 0
			
			CMP AL, " "
			JNE NO_SP
			MOV AL, "+"
			NO_SP:
			MOV [EDI], AL
			INC EDI
		
		.ELSE
			
			MOV WORD PTR [TEMP_WSOUT], 0
			MOV BYTE PTR [EDI], "%"
			INC EDI
			PUSH ECX
			;PUSHA
			MOV BYTE PTR [EDI], "0"
			INC EDI
			MOV BYTE PTR [EDI], "0"
			DEC EDI
			INVOKE wsprintf, ADDR TEMP_WSOUT, ADDR wsp2, EAX
			jmp asdf
			PUSH EDI
			MOV AX, WORD PTR [TEMP_WSOUT]
			CMP AH, "0"
			JNA HEX_N
			;MOV AL, [TEMP_WSOUT]
			;INC EDI
			;MOV [EDI], AL
			;DEC EDI
			HEX_N:
			INC EDI
			CMP AL, "0"
			JNA HEX_NO
			;MOV AL, [TEMP_WSOUT+1]
			MOV [EDI], AL
			HEX_NO:
			POP EDI
			;INVOKE MessageBox,0,ADDR Fehler,ADDR TEMP_WSOUT,MB_OK
			;;POPA
			asdf:
			mov eax, DWORD PTR [TEMP_WSOUT]
			mov [edi], eax
			POP ECX
			;MOV WORD PTR [EDI], "as"
			INC EDI
			INC EDI
			
		.ENDIF
		INC ESI
	
		;LOOP DO_LOOP
		DEC ECX
		CMP ECX, 0
		JNE DO_LOOP
		
	DO_END:
	POP EAX
	POP EDI
	POP ECX
	POP EBX
	POP ESI
	RET
		
urlencode ENDP		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Len PROTO :DWORD
;; Version 0.01
;; (c) 2005-2006 Josef Biehler
;; Beschreibung: Gibt die Länge eines Null-terminierten Stringes zurück
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Len PROC STDCALL str2:DWORD
	PUSH EDI
	PUSH ECX
	MOV EDI, str2
	XOR ECX, ECX
	Len_Loop:
		CMP BYTE PTR [EDI], 0
		JE Len_Loop_End
		INC EDI
		INC ECX
		JMP Len_Loop
		
	Len_Loop_End:
	MOV EAX, ECX
	POP ECX
	POP EDI
	RET
Len ENDP
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; AddLongDouble OFFSET Zahl1, OFFSET Zahl2, OFFSET Ergebnis
;; Version 0.03
;; (C) 2005-2006 by Josef Biehler
;; Beschreibung:
;; 				Addiert 2 nullterminierte Zahlen (als String vorliegend)
;;				und speichert das Ergebnis als nullterminierten String.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AddLongDouble PROC STDCALL Q1:DWORD, Q2:DWORD, ERG:DWORD

	PUSH ESI
	PUSH EDI
	PUSH EBX
	PUSH ECX
	
	MOV ECX, 0
	MOV EDI, Q1			;  Quelle1
	MOV ESI, Q2			;+ Quelle2
	MOV EBX, ERG		;= Ergebnis
	
						;Setze alle Variablen auf 0
	MOV TEMP, 0
	
	MOV Q1_LEN, 0
	MOV Q2_LEN, 0
	MOV ERG_LEN, 0
	MOV Q1_NKS_LEN, 0
	MOV Q2_NKS_LEN, 0
	
						;Ermittle Länge v. Zahl1
BCOMP_LOOP_SEARCH_0:
	MOV AL,[EDI]
	INC EDI
	CMP AL,0
	JE BCOMP_LS0_OK
	INC ECX
	JMP BCOMP_LOOP_SEARCH_0
	
BCOMP_LS0_OK:
	MOV Q1_LEN,ECX
	
	MOV ECX, 0
	
						;Ermittle Länge v. Zahl2
	
BCOMP_LOOP_SEARCH_0_Q2:
	MOV AL,[ESI]
	INC ESI
	CMP AL,0
	JE BCOMP_LS0_OKQ2
	INC ECX
	JMP BCOMP_LOOP_SEARCH_0_Q2
	
BCOMP_LS0_OKQ2:
	MOV Q2_LEN,ECX
	
	PUSH ESI
	PUSH EDI
						;Ermittle Länge v. Nachkommastellen (mit Komma) v. Zahl1
	MOV ECX, 0
	MOV ESI, Q1
	ADD ESI, Q1_LEN
	MOV ECX, Q1_LEN
BCOMP_LOOP_SEARCH_NKS_Q1:
	MOV AL, [ESI]
	DEC ESI
	CMP AL, ","
	JE BC_L_S_NKS_OKQ1
	CMP AL, "."
	JE BC_L_S_NKS_OKQ1
	INC Q1_NKS_LEN
	LOOP BCOMP_LOOP_SEARCH_NKS_Q1
	
BC_L_S_NKS_OKQ1:		;Wenn Nachkommastellen vorhanden, erniedrige Q1_LEN um eins
	.IF ECX != 0
	DEC Q1_LEN
	.ENDIF
	;MOV Q1_NKS_LEN, 0
	;SUB ECX, Q1_NKS_LEN
	;MOV Q1_NKS_LEN, ECX
	
						;Ermittle Länge 
	MOV ECX, 0
	MOV ESI, Q2
	ADD ESI, Q2_LEN
	MOV ECX, Q2_LEN
BCOMP_LOOP_SEARCH_NKS_Q2:
	MOV AL, [ESI]
	DEC ESI
	CMP AL, ","
	JE BC_L_S_NKS_OKQ2
	CMP AL, "."
	JE BC_L_S_NKS_OKQ2
	INC Q2_NKS_LEN
	LOOP BCOMP_LOOP_SEARCH_NKS_Q2
	
BC_L_S_NKS_OKQ2:		;Wenn Nachkommastellen vorhanden, erniedrige Q2_LEN um eins
	.IF ECX != 0
	DEC Q2_LEN
	.ENDIF
	;SUB ECX, Q2_NKS_LEN
	;MOV Q2_NKS_LEN, ECX
	DEC Q2_NKS_LEN
	DEC Q1_NKS_LEN
	
	POP EDI
	POP ESI
						;Setze ESI und EDI auf den Schluß der beiden "Zahlen"
	DEC ESI
	DEC EDI
	DEC ESI
	DEC EDI
	JMP BCOMP_MAIN_LOOP	;Überspringe Prüfung
	
BCOMP_SET:				;Prüfung, ob Komma bereits im Ergebnis gespeichert wurde
	TEST STATUS, 01b
	JNE BCOMP_MAIN_LOOP
	OR STATUS, 01b
	MOV [EBX], BYTE PTR ","
	INC ERG_LEN
	INC EBX
	
BCOMP_MAIN_LOOP:
	MOV AL, [ESI]
	MOV AH, [EDI]
	DEC ESI
	DEC EDI
						;Überprüfe auf Komma/Punkt
	CMP AL, "."
	JE BCOMP_SET;MAIN_LOOP
	CMP AL, ","
	JE BCOMP_SET;MAIN_LOOP
	CMP AH, "."
	JE BCOMP_SET;MAIN_LOOP
	CMP AH, ","
	JE BCOMP_SET;MAIN_LOOP
	
						;Überprüfung, welche Zahl mehr Nachkommastellen hat
						;und dementsprechend behandeln
	MOV ECX, Q1_NKS_LEN
	CMP ECX, Q2_NKS_LEN
	JE Q1_Q2_EQUAL
	JB Q1_NKS_BELOW
	JA Q2_NKS_BELOW
	
Q1_Q2_EQUAL:
	DEC Q1_NKS_LEN
	DEC Q2_NKS_LEN
	;DEC ESI
	;DEC EDI
	DEC Q1_LEN
	DEC Q2_LEN
	JMP AFTER_BCOMP_SET
	
Q1_NKS_BELOW:
	INC EDI
	;DEC ESI
	DEC Q2_LEN
	MOV AH, 48
	DEC Q2_NKS_LEN
	JMP AFTER_BCOMP_SET
	
Q2_NKS_BELOW:
	INC ESI
	;DEC EDI
	DEC Q1_LEN
	MOV AL, 48
	DEC Q1_NKS_LEN
						;Hauptteil: Berechnung und speicherung
AFTER_BCOMP_SET:
	;DEC Q1_NKS_LEN
	;DEC Q2_NKS_LEN
	SUB AL, 48
	SUB AH, 48
	ADD AL, AH
	ADD AL, TEMP		;Addiere Übertrag letzter Addition
	XOR AH, AH
	PUSH EBX
	MOV BL, 10
	DIV BL
	POP EBX
	;Quotient AL
	;Rest AH
	MOV TEMP, AL		;Speichere Übertrag
	ADD AH, 48
	MOV [EBX],AH
	INC EBX
	INC ERG_LEN
	;DEC ESI
	;DEC EDI
	;DEC Q1_LEN
	;DEC Q2_LEN
						;Überprüfung, welche Zahl länger ist, und Überprüfung, ob Berechnung zu Ende ist
	MOV EAX, Q1_LEN
	CMP EAX, Q2_LEN
	JE BCOMP_LEN_EQUAL
	JA BCOMP_Q1_ABOVE
	JB BCOMP_Q2_ABOVE
	
BCOMP_Q1_ABOVE:
	CMP Q1_LEN, 0
	JE BCOMP_READY
	CMP Q2_LEN, 0
	JNE BCOMP_MAIN_LOOP
	MOV Q2_LEN, 1
	INC ESI
	MOV [ESI], BYTE PTR 48
	JMP BCOMP_MAIN_LOOP
	
BCOMP_Q2_ABOVE:
	CMP Q2_LEN, 0
	JE BCOMP_READY
	CMP Q1_LEN, 0
	JNE BCOMP_MAIN_LOOP
	MOV Q1_LEN, 1
	INC EDI
	MOV [EDI], BYTE PTR 48
	JMP BCOMP_MAIN_LOOP
	
BCOMP_LEN_EQUAL:
	CMP Q1_LEN, 0
	JE BCOMP_READY
	CMP Q2_LEN, 0
	JE BCOMP_READY
	JMP BCOMP_MAIN_LOOP
	
BCOMP_READY:			;Ist noch ein Übertrag vorhanden?
	
	CMP TEMP, 0
	JE BCOMP_ADD_NO_TEMP
	MOV Al, TEMP
	ADD AL, 48
	MOV [EBX], AL
	INC EBX
	INC ERG_LEN
	
BCOMP_ADD_NO_TEMP:
	;Drehe nun den String um.
	;Tausche dazu das erste und das letzte BYte, usw.
	
	MOV ESI, ERG	;ESI zeigt auf den Anfang des Ergebnisses
	MOV EDI, ERG	
	ADD EDI, ERG_LEN;EBX		
	DEC EDI			;EDI zeigt auf das Ende des Ergebnis-stringes
	;DEC EDI
	
BCOMP_CH_LOOP:
	MOV AL, [ESI]
	MOV AH, [EDI]
	MOV [EDI], AL
	MOV [ESI], AH	;Letztes-x und erstes+x Byte vertauschen

	INC ESI
	DEC EDI
	CMP EDI, ESI
	JE BCOMP_ALL_OK
	JB BCOMP_ALL_OK
	JMP BCOMP_CH_LOOP
	
BCOMP_ALL_OK:
	MOV ESI, ERG
	ADD ESI, ERG_LEN
	MOV [ESI], BYTE PTR 0
	POP ECX
	POP EBX
	POP EDI
	POP ESI
	
	RET
AddLongDouble ENDP
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SubLongDouble OFFSET Zahl1, OFFSET Zahl2, OFFSET Ergebnis
;; (C) 2005-2006 by Josef Biehler
;; Version: 0.03
;; Beschreibung:
;; 				Subtrahiert 2 nullterminierte Zahlen (als String vorliegend)
;;				und speichert das Ergebnis als nullterminierten String.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SubLongDouble PROC STDCALL Q1:DWORD, Q2:DWORD, ERG:DWORD

	PUSH ESI
	PUSH EDI
	PUSH EBX
	PUSH ECX
	
	MOV ECX, 0
	MOV EDI, Q1				;  Quelle1
	MOV ESI, Q2				;+ Quelle2
	MOV EBX, ERG			;= Ergebnis
	MOV TEMP, 0
	
	MOV TEMP2, 0
	MOV Q1_LEN, 0			;Setze Variablen auf 0
	MOV Q2_LEN, 0	
	MOV ERG_LEN, 0
	MOV Q1_NKS_LEN, 0
	MOV Q2_NKS_LEN, 0
	
							;Ermittle Länge v. Zahl1
BCOMP_SLD_LOOP_SEARCH_0:
	MOV AL,[EDI]
	INC EDI
	CMP AL,0
	JE BCOMP_SLD_LS0_OK
	INC ECX
	JMP BCOMP_SLD_LOOP_SEARCH_0
	
BCOMP_SLD_LS0_OK:
	MOV Q1_LEN,ECX
	
	MOV ECX, 0
							;Ermittle Länge v. Zahl2
BCOMP_SLD_LOOP_SEARCH_0_Q2:
	MOV AL,[ESI]
	INC ESI
	CMP AL,0
	JE BCOMP_SLD_LS0_OKQ2
	INC ECX
	JMP BCOMP_SLD_LOOP_SEARCH_0_Q2
	
BCOMP_SLD_LS0_OKQ2:
	MOV Q2_LEN,ECX
	
	PUSH ESI
	PUSH EDI
							;Ermittle Länge der Nachkommastellen v. Zahl1 und Zahl2
	MOV ECX, 0
	MOV ESI, Q1
	ADD ESI, Q1_LEN
	MOV ECX, Q1_LEN
BCOMP_SLD_LOOP_SEARCH_NKS_Q1:
	MOV AL, [ESI]
	DEC ESI
	CMP AL, ","
	JE BC_SLD_L_S_NKS_OKQ1
	CMP AL, "."
	JE BC_SLD_L_S_NKS_OKQ1
	INC Q1_NKS_LEN
	LOOP BCOMP_SLD_LOOP_SEARCH_NKS_Q1
	
BC_SLD_L_S_NKS_OKQ1:
	.IF ECX != 0
	DEC Q1_LEN
	.ENDIF
	;MOV Q1_NKS_LEN, 0
	;SUB ECX, Q1_NKS_LEN
	;MOV Q1_NKS_LEN, ECX
	
	
	MOV ECX, 0
	MOV ESI, Q2
	ADD ESI, Q2_LEN
	MOV ECX, Q2_LEN
BCOMP_SLD_LOOP_SEARCH_NKS_Q2:
	MOV AL, [ESI]
	DEC ESI
	CMP AL, ","
	JE BC_SLD_L_S_NKS_OKQ2
	CMP AL, "."
	JE BC_SLD_L_S_NKS_OKQ2
	INC Q2_NKS_LEN
	LOOP BCOMP_SLD_LOOP_SEARCH_NKS_Q2
	
BC_SLD_L_S_NKS_OKQ2:
	.IF ECX != 0
	DEC Q2_LEN
	.ENDIF
	;SUB ECX, Q2_NKS_LEN
	;MOV Q2_NKS_LEN, ECX
	DEC Q2_NKS_LEN
	DEC Q1_NKS_LEN
	
	POP EDI
	POP ESI
	
	DEC ESI
	DEC EDI
	DEC ESI
	DEC EDI
	JMP BCOMP_SLD_MAIN_LOOP
	
BCOMP_SLD_SET:					;Überprüfung, ob Komma bereits in ERG gespeichert
	TEST STATUS, 01b
	JNE BCOMP_SLD_MAIN_LOOP
	OR STATUS, 01b
	MOV [EBX], BYTE PTR ","
	INC ERG_LEN
	INC EBX
	
								;Haupt-Schleife
BCOMP_SLD_MAIN_LOOP:
	MOV AL, [ESI]
	MOV AH, [EDI]
	DEC ESI
	DEC EDI
	
	CMP AL, "."
	JE BCOMP_SLD_SET;MAIN_LOOP
	CMP AL, ","
	JE BCOMP_SLD_SET;MAIN_LOOP
	CMP AH, "."
	JE BCOMP_SLD_SET;MAIN_LOOP
	CMP AH, ","
	JE BCOMP_SLD_SET;MAIN_LOOP
								;Welche Zahl hat mehr Nachkommastellen?
	MOV ECX, Q1_NKS_LEN
	CMP ECX, Q2_NKS_LEN
	JE Q1_SLD_Q2_EQUAL
	JB Q1_SLD_NKS_BELOW
	JA Q2_SLD_NKS_BELOW
	
Q1_SLD_Q2_EQUAL:
	DEC Q1_NKS_LEN
	DEC Q2_NKS_LEN
	;DEC ESI
	;DEC EDI
	DEC Q1_LEN
	DEC Q2_LEN
	JMP AFTER_SLD_BCOMP_SET
	
Q1_SLD_NKS_BELOW:
	INC EDI
	;DEC ESI
	DEC Q2_LEN
	MOV AH, 48
	DEC Q2_NKS_LEN
	JMP AFTER_SLD_BCOMP_SET
	
Q2_SLD_NKS_BELOW:
	INC ESI
	;DEC EDI
	DEC Q1_LEN
	MOV AL, 48
	DEC Q1_NKS_LEN
	
								
AFTER_SLD_BCOMP_SET:
	;DEC Q1_NKS_LEN
	;DEC Q2_NKS_LEN
	SUB AL, 48
	SUB AH, 48
	ADD AL, TEMP
	ADD AL, TEMP2
	MOV TEMP2, 0
	CMP AL, AH
	JE SLD_AL_AH_EQUAL
	JB SLD_AL_BELOW
	JA SLD_AH_BELOW
	
SLD_AH_BELOW:
	ADD AH, 10
	MOV TEMP2, 1
	
SLD_AL_BELOW:

SLD_AL_AH_EQUAL:				;Berechnung, Speicherung

	SUB AH, AL
	MOV AL, AH
	;SUB AL, TEMP
	XOR AH, AH
	PUSH EBX
	MOV BL, 10
	DIV BL
	POP EBX
	;Quotient AL
	;Rest AH
	MOV TEMP, AL
	ADD AH, 48
	MOV [EBX],AH
	INC EBX
	INC ERG_LEN
	;DEC ESI
	;DEC EDI
	;DEC Q1_LEN
	;DEC Q2_LEN
								;welche Zahl ist länger/Berechnung zuende?
	MOV EAX, Q1_LEN
	CMP EAX, Q2_LEN
	JE BCOMP_SLD_LEN_EQUAL
	JA BCOMP_SLD_Q1_ABOVE
	JB BCOMP_SLD_Q2_ABOVE
	
BCOMP_SLD_Q1_ABOVE:
	CMP Q1_LEN, 0
	JE BCOMP_SLD_READY
	CMP Q2_LEN, 0
	JNE BCOMP_SLD_MAIN_LOOP
	MOV Q2_LEN, 1
	INC ESI
	MOV [ESI], BYTE PTR 48
	JMP BCOMP_SLD_MAIN_LOOP
	
BCOMP_SLD_Q2_ABOVE:
	CMP Q2_LEN, 0
	JE BCOMP_SLD_READY
	CMP Q1_LEN, 0
	JNE BCOMP_SLD_MAIN_LOOP
	MOV Q1_LEN, 1
	INC EDI
	MOV [EDI], BYTE PTR 48
	JMP BCOMP_SLD_MAIN_LOOP
	
BCOMP_SLD_LEN_EQUAL:
	CMP Q1_LEN, 0
	JE BCOMP_SLD_READY
	CMP Q2_LEN, 0
	JE BCOMP_SLD_READY
	JMP BCOMP_SLD_MAIN_LOOP
	
BCOMP_SLD_READY:
	
	;CMP TEMP, 0
	;JE BCOMP_SLD_ADD_NO_TEMP
	;MOV Al, TEMP
	;ADD AL, 48
	;MOV [EBX], AL
	;INC EBX
	;INC ERG_LEN
	
BCOMP_SLD_ADD_NO_TEMP:
	;Drehe nun den String um.
	;Tausche dazu das erste und das letzte BYte, usw.
	
	MOV ESI, ERG	;ESI zeigt auf den Anfang des Ergebnisses
	MOV EDI, ERG	
	ADD EDI, ERG_LEN;EBX		
	DEC EDI			;EDI zeigt auf das Ende des Ergebnis-stringes
	;DEC EDI
	
BCOMP_SLD_CH_LOOP:
	MOV AL, [ESI]
	MOV AH, [EDI]
	MOV [EDI], AL
	MOV [ESI], AH	;Letztes-x und erstes+x Byte vertauschen

	INC ESI
	DEC EDI
	CMP EDI, ESI
	JE BCOMP_SLD_ALL_OK
	JB BCOMP_SLD_ALL_OK
	JMP BCOMP_SLD_CH_LOOP
	
BCOMP_SLD_ALL_OK:
	MOV ESI, ERG
	ADD ESI, ERG_LEN
	MOV [ESI], BYTE PTR 0
	POP ECX
	POP EBX
	POP EDI
	POP ESI
	
	RET
SubLongDouble ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GetIntLen Adresse Zahl
;; (c) 2005-2006 by Josef Biehler
;; Version 0.1
;; Rückgabe: EAX (Länge der "Zahl" (bei FLOAT: Länge MIT Komma!)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetIntLen PROC STDCALL Q1:DWORD
	PUSH ESI
	PUSH ECX
	XOR ECX, ECX
	MOV ESI, Q1
LEN_MAIN_LOOP:
	MOV AL, [ESI]
	CMP AL, 0
	JE LEN_MAIN_LOOP_END
	INC ECX
	INC ESI
	JMP LEN_MAIN_LOOP
	
LEN_MAIN_LOOP_END:
	MOV EAX, ECX
	POP ECX
	POP ESI
	RET
GetIntLen ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CmpLongInt Adresse Zahl1, Adresse Zahl2
;; (c) 2005-2006 by Josef Biehler
;; Version: 0.1
;; RÜckgabe: EAX (-1: Zahl1<Zahl2, 0: Zahl1=Zahl2, 1: Zahl1>Zahl2, 2: Fehler)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CmpLongInt PROC STDCALL Q1:DWORD, Q2:DWORD
	PUSH ESI
	PUSH EDI
	PUSH EBX
	PUSH ECX
	MOV ESI, Q1
	MOV EDI, Q2
	
						;Ermittle Länge beider Zahlenstrings
	INVOKE GetIntLen, ESI
	MOV Q1_LEN, EAX
	MOV ECX, EAX
	INVOKE GetIntLen, EDI
	CMP EAX, Q1_LEN		;Ein String länger oder kürzer?
	JE CLI_MAIN_LOOP
	JA CLI_Q2_ABOVE
	JB CLI_Q1_ABOVE
	
CLI_MAIN_LOOP:
	MOV AL, [ESI]
	MOV AH, [EDI]
	CMP AH, AL
	JA CLI_Q2_ABOVE
	JB CLI_Q1_ABOVE
	INC ESI
	INC EDI
	LOOP CLI_MAIN_LOOP
	MOV EAX, 0
	JMP CLI_MAIN_END
	
CLI_Q2_ABOVE:
	MOV EAX, -1
	JMP CLI_MAIN_END
	
CLI_Q1_ABOVE:
	MOV EAX, 1
CLI_MAIN_END:
	POP ECX
	POP EBX
	POP EDI
	POP ESI
	RET
CmpLongInt ENDP

	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; AddLongInt OFFSET Zahl1, OFFSET Zahl2, OFFSET Ergebnis
;; Version 0.02
;; (C) 2005-2006 by Josef Biehler
;; Beschreibung:
;; 				Addiert 2 nullterminierte Integer Strings (als String vorliegend)
;;				und speichert das Ergebnis als nullterminierten String.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AddLongInt PROC STDCALL Q1:DWORD, Q2:DWORD, ERG:DWORD

	PUSH ESI
	PUSH EDI
	PUSH EBX
	PUSH ECX
	
	MOV ECX, 0
	MOV EDI, Q1			;  Quelle1
	MOV ESI, Q2			;+ Quelle2
	MOV EBX, ERG		;= Ergebnis
	
						;Setze alle Variablen auf 0
	MOV TEMP, 0
	MOV Q1_LEN, 0
	MOV Q2_LEN, 0
	MOV ERG_LEN, 0
	
	
						;Ermittle Länge v. Zahl1
	INVOKE GetIntLen, Q1
	MOV Q1_LEN, EAX
	INVOKE GetIntLen, Q2
	MOV Q2_LEN, EAX
	
	
	CMP GLOBAL_STATUS, 0
	JNE AFTER_SET_SIGN
	;test
	INVOKE GetSign, Q1
	MOV Q1_SIGN, AL
	INVOKE GetSign, Q2
	.IF AL=="-"
		MOV Q2_SIGN, "-"
	.ELSE
		MOV Q2_SIGN, "+"
	.ENDIF
	;MOV Q2_SIGN, AL
	;MOV Q2_SIGN, "-"
	
	INVOKE RemoveSignQ1, Q1
	MOV Q1, EAX
	INVOKE RemoveSignQ2, Q2
	MOV Q2, EAX

	MOV AL, Q2_SIGN
	MOV ERG_SIGN, AL
	CMP Q1_SIGN, AL
	JE AFTER_SET_SIGN
	INVOKE CmpLongInt, Q1, Q2
	CMP EAX, 1
	JE ADD_Q1_Q2
	CMP EAX, -1
	JE ADD_Q2_Q1

	MOV GLOBAL_STATUS, "+"
	INVOKE SubLongInt, Q1, Q2, ERG
	RET
	JMP AFTER_SET_SIGN
	
;ERG_SIGN_POSITIV:
	MOV AL, ERG_SIGN
	MOV GLOBAL_STATUS, AL
	INVOKE AddLongInt, Q1, Q2, ERG
	RET
	
ADD_Q1_Q2:
	MOV EDI, Q1
	MOV ESI, Q2
	MOV AL, Q1_SIGN
	MOV GLOBAL_STATUS, AL
	INVOKE SubLongInt, Q1, Q2, ERG
	RET
	
	
ADD_Q2_Q1:
	;PUSH ESI
	;;PUSH EDI
	;POP ESI
	;POP EDI
	PUSH Q1_LEN
	PUSH Q2_LEN
	POP Q1_LEN
	POP Q2_LEN
	PUSH Q1
	PUSH Q2
	POP Q1
	POP Q2
	MOV EDI, Q1
	MOV ESI, Q2
	MOV AL, Q2_SIGN
	MOV GLOBAL_STATUS, AL
	INVOKE SubLongInt, Q1, Q2, ERG
	RET

AFTER_SET_SIGN:
	MOV EDI, Q1
	MOV ESI, Q2
	MOV AL, ERG_SIGN
	
;test
	;DEC Q1_LEN
	;DEC Q2_LEN
	ADD ESI, Q2_LEN
	ADD EDI, Q1_LEN
	DEC ESI
	DEC EDI


	
AddLongInt_BCOMP_MAIN_LOOP:
	MOV AL, [ESI]
	MOV AH, [EDI]
	DEC ESI
	DEC EDI
	DEC Q1_LEN
	DEC Q2_LEN
						;Hauptteil: Berechnung und speicherung
	SUB AL, 48
	SUB AH, 48
	ADD AL, AH
	ADD AL, TEMP		;Addiere Übertrag letzter Addition
	XOR AH, AH
	PUSH EBX
	MOV BL, 10
	DIV BL
	POP EBX
	;Quotient AL
	;Rest AH
	MOV TEMP, AL		;Speichere Übertrag
	ADD AH, 48
	MOV [EBX],AH
	INC EBX
	INC ERG_LEN
						;Überprüfung, welche Zahl länger ist, und Überprüfung, ob Berechnung zu Ende ist
	MOV EAX, Q1_LEN
	CMP EAX, Q2_LEN
	JE AddLongInt_BCOMP_LEN_EQUAL
	JA AddLongInt_BCOMP_Q1_ABOVE
	JB AddLongInt_BCOMP_Q2_ABOVE
	
AddLongInt_BCOMP_Q1_ABOVE:
	CMP Q1_LEN, 0
	JE AddLongInt_BCOMP_READY
	CMP Q2_LEN, 0
	JA AddLongInt_BCOMP_MAIN_LOOP  ;Wenn Q2_Len =0, ist die Zahl zuende: Fülle mit Nullen aus
	MOV Q2_LEN, 1
	INC ESI
	MOV [ESI], BYTE PTR 48
	JMP AddLongInt_BCOMP_MAIN_LOOP
	
AddLongInt_BCOMP_Q2_ABOVE:
	CMP Q2_LEN, 0
	JE AddLongInt_BCOMP_READY
	CMP Q1_LEN, 0
	JA AddLongInt_BCOMP_MAIN_LOOP
	MOV Q1_LEN, 1
	INC EDI
	MOV [EDI], BYTE PTR 48
	JMP AddLongInt_BCOMP_MAIN_LOOP
	
AddLongInt_BCOMP_LEN_EQUAL:
	CMP Q1_LEN, 0
	JE AddLongInt_BCOMP_READY
	CMP Q2_LEN, 0
	JE AddLongInt_BCOMP_READY
	JMP AddLongInt_BCOMP_MAIN_LOOP
	
AddLongInt_BCOMP_READY:			;Ist noch ein Übertrag vorhanden?
	
	CMP TEMP, 0
	JE AddLongInt_BCOMP_ADD_NO_TEMP
	MOV Al, TEMP
	ADD AL, 48
	MOV [EBX], AL
	INC EBX
	INC ERG_LEN
	
AddLongInt_BCOMP_ADD_NO_TEMP:
	;Drehe nun den String um.
	;Tausche dazu das erste und das letzte BYte, usw.
	
	MOV ESI, ERG	;ESI zeigt auf den Anfang des Ergebnisses
	MOV EDI, ERG	
	ADD EDI, ERG_LEN;EBX
	CMP GLOBAL_STATUS, 0
	JE NO_GS
	MOV AL, GLOBAL_STATUS
	MOV ERG_SIGN, AL
NO_GS:
	MOV AL, ERG_SIGN
	MOV [EDI], AL
	INC ERG_LEN
	INC EDI	
	DEC EDI			;EDI zeigt auf das Ende des Ergebnis-stringes
	;DEC EDI
	
AddLongInt_BCOMP_CH_LOOP:
	MOV AL, [ESI]
	MOV AH, [EDI]
	MOV [EDI], AL
	MOV [ESI], AH	;Letztes-x und erstes+x Byte vertauschen

	INC ESI
	DEC EDI
	CMP EDI, ESI
	JE AddLongInt_BCOMP_ALL_OK
	JB AddLongInt_BCOMP_ALL_OK
	JMP AddLongInt_BCOMP_CH_LOOP
	
AddLongInt_BCOMP_ALL_OK:
	MOV ESI, ERG
	ADD ESI, ERG_LEN
	MOV [ESI], BYTE PTR 0
	POP ECX
	POP EBX
	POP EDI
	POP ESI
	MOV GLOBAL_STATUS, 0
	RET
AddLongInt ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SubLongInt OFFSET Zahl1, OFFSET Zahl2, OFFSET Ergebnis
;; (C) 2005-2006 by Josef Biehler
;; Version: 0.01
;; Beschreibung:
;; 				Subtrahiert 2 nullterminierte Integer Strings (als String vorliegend)
;;				und speichert das Ergebnis als nullterminierten String.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SubLongInt PROC STDCALL Q1:DWORD, Q2:DWORD, ERG:DWORD

	PUSH ESI
	PUSH EDI
	PUSH EBX
	PUSH ECX
	
	MOV ECX, 0
	MOV EDI, Q1				;  Quelle1
	MOV ESI, Q2				;+ Quelle2
	MOV EBX, ERG			;= Ergebnis
	MOV TEMP, 0
	MOV TEMP2, 0
	
						;Ermittle Länge v. Zahl1
	INVOKE GetIntLen, Q1
	MOV Q1_LEN, EAX
	INVOKE GetIntLen, Q2
	MOV Q2_LEN, EAX
	
	CMP GLOBAL_STATUS, 0
	JNE AFTER_SET_SIGN
	
	INVOKE GetSign, Q1
	MOV Q1_SIGN, AL
	INVOKE GetSign, Q2
	.IF AL=="-"
		MOV Q2_SIGN, "+"
	.ELSE
		MOV Q2_SIGN, "-"
	.ENDIF
	;MOV Q2_SIGN, AL
	;MOV Q2_SIGN, "-"
	
	INVOKE RemoveSignQ1, Q1
	MOV Q1, EAX
	INVOKE RemoveSignQ2, Q2
	MOV Q2, EAX

	MOV AL, Q2_SIGN
	MOV ERG_SIGN, AL
	CMP Q1_SIGN, AL
	JE ERG_SIGN_POSITIV
	INVOKE CmpLongInt, Q1, Q2
	CMP EAX, 1
	JE SUB_Q1_Q2
	CMP EAX, -1
	JE SUB_Q2_Q1

	MOV ERG_SIGN, "+"
	JMP AFTER_SET_SIGN
	
ERG_SIGN_POSITIV:
	MOV AL, ERG_SIGN
	MOV GLOBAL_STATUS, AL
	INVOKE AddLongInt, Q1, Q2, ERG
	RET
	
SUB_Q1_Q2:
	MOV EDI, Q1
	MOV ESI, Q2
	MOV AL, Q1_SIGN
	MOV ERG_SIGN, AL
	JMP AFTER_SET_SIGN
	
SUB_Q2_Q1:
	;PUSH ESI
	;;PUSH EDI
	;POP ESI
	;POP EDI
	PUSH Q1_LEN
	PUSH Q2_LEN
	POP Q1_LEN
	POP Q2_LEN
	PUSH Q1
	PUSH Q2
	POP Q1
	POP Q2
	MOV EDI, Q1
	MOV ESI, Q2
	MOV AL, Q2_SIGN
	MOV ERG_SIGN, AL

AFTER_SET_SIGN:
	
	
	ADD ESI, Q2_LEN
	ADD EDI, Q1_LEN
	DEC ESI
	DEC EDI
	
								;Haupt-Schleife
BCOMP_SLD_MAIN_LOOP:
	MOV AL, [ESI]
	MOV AH, [EDI]
	DEC ESI
	DEC EDI
	DEC Q1_LEN
	DEC Q2_LEN
								
	SUB AL, 48
	SUB AH, 48
	ADD AL, TEMP
	ADD AL, TEMP2
	MOV TEMP2, 0
	CMP AL, AH
	JE SLD_AL_AH_EQUAL
	JB SLD_AL_BELOW
	JA SLD_AH_BELOW
	
SLD_AH_BELOW:
	ADD AH, 10
	MOV TEMP2, 1
	
SLD_AL_BELOW:

SLD_AL_AH_EQUAL:				;Berechnung, Speicherung

	SUB AH, AL
	MOV AL, AH
	;SUB AL, TEMP
	XOR AH, AH
	PUSH EBX
	MOV BL, 10
	DIV BL
	POP EBX
	;Quotient AL
	;Rest AH
	MOV TEMP, AL
	ADD AH, 48
	MOV [EBX],AH
	INC EBX
	INC ERG_LEN
								;welche Zahl ist länger/Berechnung zuende?
	MOV EAX, Q1_LEN
	CMP EAX, Q2_LEN
	JE BCOMP_SLD_LEN_EQUAL
	JA BCOMP_SLD_Q1_ABOVE
	JB BCOMP_SLD_Q2_ABOVE
	
BCOMP_SLD_Q1_ABOVE:
	CMP Q1_LEN, 0
	JE BCOMP_SLD_READY
	CMP Q2_LEN, 0
	JNE BCOMP_SLD_MAIN_LOOP
	MOV Q2_LEN, 1
	INC ESI
	MOV [ESI], BYTE PTR 48
	JMP BCOMP_SLD_MAIN_LOOP
	
BCOMP_SLD_Q2_ABOVE:
	CMP Q2_LEN, 0
	JE BCOMP_SLD_READY
	CMP Q1_LEN, 0
	JNE BCOMP_SLD_MAIN_LOOP
	MOV Q1_LEN, 1
	INC EDI
	MOV [EDI], BYTE PTR 48
	JMP BCOMP_SLD_MAIN_LOOP
	
BCOMP_SLD_LEN_EQUAL:
	CMP Q1_LEN, 0
	JE BCOMP_SLD_READY
	CMP Q2_LEN, 0
	JE BCOMP_SLD_READY
	JMP BCOMP_SLD_MAIN_LOOP
	
BCOMP_SLD_READY:
	;Drehe nun den String um.
	;Tausche dazu das erste und das letzte BYte, usw.
	
	MOV ESI, ERG	;ESI zeigt auf den Anfang des Ergebnisses
	MOV EDI, ERG	
	ADD EDI, ERG_LEN;EBX
	CMP GLOBAL_STATUS, 0
	JE NO_GLOBAL_STATUS
	MOV AL, GLOBAL_STATUS
	MOV ERG_SIGN, AL
NO_GLOBAL_STATUS:		
	MOV AL, ERG_SIGN
	MOV [EDI], AL
	INC EDI
	INC ERG_LEN
	DEC EDI			;EDI zeigt auf das Ende des Ergebnis-stringes
	;DEC EDI
	
BCOMP_SLD_CH_LOOP:
	MOV AL, [ESI]
	MOV AH, [EDI]
	MOV [EDI], AL
	MOV [ESI], AH	;Letztes-x und erstes+x Byte vertauschen

	INC ESI
	DEC EDI
	CMP EDI, ESI
	JE BCOMP_SLD_ALL_OK
	JB BCOMP_SLD_ALL_OK
	JMP BCOMP_SLD_CH_LOOP
	
BCOMP_SLD_ALL_OK:
	MOV ESI, ERG
	ADD ESI, ERG_LEN
	MOV [ESI], BYTE PTR 0
	POP ECX
	POP EBX
	POP EDI
	POP ESI
	
	MOV GLOBAL_STATUS, 0
	RET
SubLongInt ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GetSign, Adresse Zahl1
;; (c) 2005-2006 by Josef Biehler
;; Version: 0.1
;; Beschreibung:
;; Ermittle das Vorzeichen der Zahl und gib es in EAX (AL) zurück.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetSign PROC STDCALL Q1:DWORD
	PUSH ESI
	MOV ESI, Q1
	MOV AL, [ESI]
	CMP AL, "+"
	JE GS_P
	CMP AL, "-"
	JE GS_N
	JMP GS_P
	
GS_P:
	XOR EAX, EAX
	MOV AL, "+"
	POP ESI
	RET
	
GS_N:
	XOR EAX, EAX
	MOV AL, "-"
	POP ESI
	RET
	
GetSign ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GetVer
;; (c) 2005-2006 by Josef Biehler
;; Version: 0.1
;; Beschreibung:
;; Gibt in EAX die Adresse eines nullterminierten Stringes zurück, der die 
;; Versionsnummer der .DLL anzeigt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetVer PROC STDCALL
	MOV EAX, OFFSET VER_STR
	RET
GetVer ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RemoveSign, Zahl
;; Entferne Vorzeichen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RemoveSignQ1 PROC STDCALL Q1:DWORD
	PUSH ESI
	MOV ESI, Q1
	CMP BYTE PTR [ESI], "+"
	JE OK
	CMP BYTE PTR [ESI], "-"
	JE OK
	MOV EAX, Q1
	POP ESI
	RET
	
OK:
	DEC Q1_LEN
	INC Q1
	MOV EAX, Q1
	POP ESI
	RET
RemoveSignQ1 ENDP

RemoveSignQ2 PROC STDCALL Q2:DWORD
	PUSH ESI
	MOV ESI, Q2
	CMP BYTE PTR [ESI], "+"
	JE OK
	CMP BYTE PTR [ESI], "-"
	JE OK
	MOV EAX, Q2
	POP ESI
	RET

OK:
	DEC Q2_LEN
	INC Q2
	MOV EAX, Q2
	POP ESI
	RET
RemoveSignQ2 ENDP
	

END DLL_ENTRY
