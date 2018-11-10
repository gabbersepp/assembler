
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   BFBII.COM v1.0 A simple code-built-in interpreter for the most usefull programming language: Brainfuck
;   Copyright (C) 2006 Josef Biehler
;	URL: biehler-josef.de
;	Mail: support@biehler-josef.de
;
;    This program is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program; if not, write to the Free Software
;    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ORG	100h			
	USE16				

	JMP AFTER_DATA
	
	;BF_CODE	DB	10001 DUP("$")
	BF_LEN	DW	0
	;BF_CODE_ARRAY DB 3000 DUP(0)
	;iSTACK DB 512 DUP(0)
	BF_OPEN_ARRAY DW 1000 DUP(0)
	BF_CLOSE_ARRAY DW 1000 DUP(0)
	DATN	DB	128 DUP(0)
	;COUNT_ARRAY DB 11 DUP(0)
	FEHLER1 DB "Der Interpreter fand eine ungleiche ANzahl von '[' und ']' Klammern vor.",13,10,"$"
	FEHLER2 DB "Datei nicht gefunden.",13,10,"$"
	FEHLER3 DB "Fehler beim Oeffnen der Datei",13,10,"$"
	FEHLER4 DB "Kein Dateiname angegeben.",13,10,"$"
	FEHLER7 DB "BRAIN.COM v1.1",13,10
	FEHLER5	DB "Richtige Benutzung: brain.com dateiname.xy",13,10,"$"
	FEHLER8	DB "Fehler beim Erstellen der .COM Datei",13,10,0,"$"
	PRESS_K DB "Bitte Taste druecken zum beenden.",13,10,"$"
AFTER_DATA:

	MOV AX,CS
	MOV DS,AX
	MOV ES,AX
	;LEA AX,[iSTACK]
	;MOV SS,AX
	;MOV SP,512
	
	MOV BX,80H
	MOV CL,[DS:BX]
	XOR CH,CH
	CMP CX,0
	JNE COMMANDLINE_OK
	
	MOV AH,09H
	LEA DX,[FEHLER4]
	INT 21H
	LEA DX,[FEHLER5]
	INT 21H
	LEA DX,[PRESS_K]
	INT 21H
	MOV AH,01H
	INT 21H
	JMP BF_END
	
COMMANDLINE_OK:
	
	LEA SI,[DATN]
	MOV BX,82H
	XOR DX,DX
	DEC CX
	
COPY_DATN:
	MOV DL,[DS:BX]
	MOV [DS:SI],DL
	INC SI
	INC BX
	LOOP COPY_DATN
	
	MOV AX,CS
	MOV DS,AX
	
	MOV AH,03DH
	MOV AL,0
	LEA DX,[DATN]
	INT 21H
	
	JNC OPEN_DATA_OK
	
	LEA DX,[FEHLER2]
	MOV AH,09H
	INT 21H
	LEA DX,[PRESS_K]
	INT 21H
	MOV AH,01H
	INT 21H
	JMP BF_END
	
OPEN_DATA_OK:
	
	MOV BX,AX
	MOV AH,3FH
	MOV CX,10000
	LEA DX,[BF_CODE]
	INT 21H
	
	JNC READ_DATA_OK
	
	LEA DX,[FEHLER3]
	MOV AH,09H
	INT 21H
	LEA DX,[PRESS_K]
	INT 21H
	MOV AH,01H
	INT 21H
	JMP BF_END
	
SD_OK:
	DEC SI
	MOV BYTE [SI]," "
	LOOP SEARCH_DOLLAR
	JMP AFSD
	
READ_DATA_OK:

	MOV [BF_LEN],AX
	MOV CX,AX
	LEA SI,[BF_CODE]
	
SEARCH_DOLLAR:
	LODSB
	CMP AL,"$"
	JE SD_OK
	LOOP SEARCH_DOLLAR
	
AFSD:
	LEA SI,[BF_CODE]
	MOV CX,[BF_LEN]
	;LEA DI,[BF_CODE_ARRAY]
	
	XOR BX,BX
	XOR DX,DX
	MOV CX,[BF_LEN]
COUNT_OPEN_CLOSE:
	LODSB
	CMP AL,"["
	JE COC_O
	CMP AL,"]"
	JE COC_C
	LOOP COUNT_OPEN_CLOSE

COC_O:
	INC BX
	LOOP COUNT_OPEN_CLOSE
	JMP COC_E1
COC_C:
	INC DX
	LOOP COUNT_OPEN_CLOSE
	JMP COC_E1
	
COC_E1:
	CMP DX,BX
	JnE COC_E
	LEA DX,[FEHLER1]
	MOV AH,09H
	INT 21H
	LEA DX,[PRESS_K]
	INT 21H
	MOV AH,01H
	INT 21H
	JMP BF_END

COC_E:

	LEA SI,[DATN]
CHECK_EXT:
	LODSB
	CMP AL,"."
	JE CHECK_EXT_OK
	CMP AL,0
	JE BF_END
	JMP CHECK_EXT
CHECK_EXT_OK:
	MOV BYTE [SI],"c"
	INC SI
	MOV BYTE [SI],"o"
	INC SI
	MOV BYTE [SI],"m"
	INC SI
	MOV BYTE [SI],0
	
	MOV AH,41H
	LEA DX,[DATN]
	JNC CREATE_COM_FILE
	MOV AH,09H
	LEA DX,[FEHLER8]
	INT 21H
	LEA DX,[PRESS_K]
	INT 21H
	MOV AH,01H
	INT 21H
	JMP BF_END
	
CREATE_COM_FILE:
	MOV AH,3CH
	LEA DX,[DATN]
	MOV CX,0
	INT 21H
	JNC SAVE_COM_FILE
	MOV AH,09H
	LEA DX,[FEHLER8]
	INT 21H
	LEA DX,[PRESS_K]
	INT 21H
	MOV AH,01H
	INT 21H
	JMP BF_END
	
SAVE_COM_FILE:
	MOV BX,AX
	MOV AH,40H
	LEA DX,[BFPI]
	MOV CX,[BF_LEN]
	ADD CX,8584
	INT 21H
BF_END:
	MOV AH,4CH
	INT 21H

BFPI:
file 'INT.com'
BF_CODE DB 10001 DUP("$")