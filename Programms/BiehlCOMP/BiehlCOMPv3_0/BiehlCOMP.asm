;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BiehlCOMP v0.3
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
;INCLUDE \masm32\include\user32.inc
INCLUDE \masm32\include\kernel32.inc
;INCLUDELIB \masm32\lib\user32.lib
INCLUDELIB \masm32\lib\kernel32.lib

.DATA
Q1_LEN		DWORD	0			;Länge der ersten Zahl
Q2_LEN		DWORD	0			;Länge der zweiten Zahl
ERG_LEN		DWORD	0			;Ergebnis-Länge
TEMP		DB		0			;Zwischenspeicher für Übertrag
TEMP2		DB		0			;Zwischenspeicher für Übertrag
STATUS		DB		0			;Statusbyte
Q1_NKS_LEN	DWORD	0			;Länge der Nachkommastelllen (mit Komma) v. Zahl1
Q2_NKS_LEN	DWORD	0			;Länge der Nachkommastellen (mit Komma) v. Zahl2

.CODE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DLL_ENTRY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DLL_ENTRY PROC STDCALL hWnd:DWORD,temp1:DWORD,temp2:DWORD
MOV EAX,TRUE
RET
DLL_ENTRY ENDP

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
SubLongInt ENDP



END DLL_ENTRY
