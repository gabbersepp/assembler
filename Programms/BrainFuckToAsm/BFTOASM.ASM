;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   BFTOASM v1.0 A simple Brainfuck to Assembler Converter
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
	
	;BF_CODE	DB	10001 DUP(0)
	BF_CODE db 10000 DUP(0)
	AUSGABE db 500 DUP(0)
	BF_LEN	DW	0
	;BF_CODE_ARRAY DB 3000 DUP(0)
	iSTACK DB 512 DUP(0)
	ENDE	DB	"MOV AH,4CH",13,10,"INT 21H",13,10,0
	START	DB	"USE16",13,10,"ORG 100H",13,10,"MOV AX,CS",13,10,"MOV DS,AX",13,10,"MOV ES,AX",13,10,"LEA DI,[VAR3]",13,10,0
	PLUS	DB	"INC BYTE [DI]",13,10,0
	MINUS	DB	"DEC BYTE [DI]",13,10,0
	BACK	DB	"DEC DI",13,10,0
	FORWARD	DB	"INC DI",13,10,0
	BEGIN_LOOP	DB	"CMP BYTE [DI],0",13,10,"JE L",0
	END_LOOP	DB	"CMP BYTE [DI],0",13,10,"JNE L",0
	;KOMMA	DB	"MOV AH,01H",13,10,"INT 21H",13,10,"MOV BYTE [DI],AL",13,10,0
	KOMMA	DB	"CALL KOMMA_CALL",13,10,0
	KOMMA_CALL	DB	"KOMMA_CALL:",13,10,"MOV AH,01",13,10,"INT 21H",13,10,"CMP AL,13",13,10,"JNE NO_ENTER",13,10,"PUSH AX",13,10,"PUSH DX",13,10,"MOV AH,02H",13,10,"MOV Dl,10",13,10,"INT 21H",13,10,"POP DX",13,10,"POP AX",13,10,"NO_ENTER:",13,10,"CMP BYTE [UNIX],1",13,10,"JNE RD_OK",13,10,"CMP AL,13",13,10,"JNE RD_OK",13,10,"XOR AL,7",13,10,"RD_OK:",13,10,"MOV BYTE [DI],AL",13,10,"RET",13,10,0
	;PUNKT	DB	"MOV AH,02H",13,10,"MOV DL,[DI]",13,10,"INT 21H",13,10,0
	PUNKT_CALL	DB	"PUNKT_CALL:",13,10,"MOV AH,02H",13,10,"MOV DL,[DI]",13,10,"CMP DL,10",13,10,"JE PR_13",13,10,"CMP DL,13",13,10,"JE PR_13",13,10,"INT 21H",13,10,"JMP AFTER_PR_13",13,10,"PR_13:",13,10,"MOV DL,10",13,10,"INT 21H",13,10,"MOV DL,13",13,10,"INT 21H",13,10,"AFTER_PR_13:",13,10,"RET",13,10,0
	PUNKT	DB	"CALL PUNKT_CALL",13,10,0
	VAR3	DB	"VAR3 DB 0",13,10,0
	VARI	DB	"VARI DB       ",0
	VARI_2	DB	" DUP(0)",13,10,0
	UNIX	DB	"UNIX DB 0",13,10,0
	DATN DB 130 DUP(0)
	LEN	DW	0
	BF_OPEN_ARRAY	DW	2000 DUP(0)
	BF_CLOSE_ARRAY	DW	2000 DUP(0)
	FEHLER4	DB	"BFTOASM v1.0 (c) 2006 by Josef Biehler",13,10,"$"
	FEHLER1	DB	"Richtige Benutzung: BFTOASM.COM dateiname.xy",13,10,"$"
	PRESS_K	DB	"Bitte Taste druecken zum beenden",13,10,"$"
	FEHLER2	DB	"Fehler beim Oeffnen der Datei!",13,10,"$"
	FEHLER3	DB	"Fehler beim Lesen der Datei!",13,10,"$"
	ALL_OK	DB	"Datei umgewandelt.",13,10,"$"
	FEHLER5	DB	"Es wird moeglicherweise der Variablenspeicher unterschritten.",13,10,"$"
	FEHLER6	DB	"Es wurde eine ungleiche Anzahl an '[' und ']' Klammern gefunden.",13,10,"$"
	HANDLEW	DW	0
AFTER_DATA:

	;initialisiere Stack/Update Segmentregister
	MOV AX,CS
	MOV ES,AX
	MOV AX,iSTACK
	MOV SS,AX
	MOV SP,200H


	;�berpr�fe Kommandozeile
	MOV BX,80H
	MOV CL,[DS:BX]
	XOR CH,CH
	CMP CX,0
	JNE COMMANDLINE_OK
	
	MOV AH,09H			;keine Kommandozeile angegeben
	LEA DX,[FEHLER4]
	INT 21H
	LEA DX,[FEHLER1]
	INT 21H
	LEA DX,[PRESS_K]
	INT 21H
	MOV AH,01H
	INT 21H
	MOV AH,4CH
	INT 21H
	
COMMANDLINE_OK:
						;Kopiere Dateinamen in [DATN]
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
						;Datei konnte nicht ge�ffnet werden -> gib Fehlermeldung aus
	LEA DX,[FEHLER2]
	MOV AH,09H
	INT 21H
	LEA DX,[PRESS_K]
	INT 21H
	MOV AH,01H
	INT 21H
	MOV AH,4CH
	INT 21H
	
OPEN_DATA_OK:
						;Lade BF Code (maximal 10000 Zeichen)
	MOV BX,AX
	MOV AH,3FH
	MOV CX,10000
	LEA DX,[BF_CODE]
	INT 21H
	
	JNC READ_DATA_OK
						;Fehler beim Lesen der Datei -> gib Fehler aus
	LEA DX,[FEHLER3]
	MOV AH,09H
	INT 21H
	LEA DX,[PRESS_K]
	INT 21H
	MOV AH,01H
	INT 21H
	MOV AH,4CH
	INT 21H
	
SD_OK:
	DEC SI
	MOV BYTE [SI]," "
	LOOP SEARCH_DOLLAR
	JMP AFSD
	
READ_DATA_OK:
	
						;�berpr�fe auf /u Parameter (ja=UNIX Code)
	PUSH AX
	PUSH SI
	LEA SI,[BF_CODE]
	CMP WORD [SI],"/u"
	JNE RDDO2
	LEA SI,[UNIX]
	ADD SI,8
	MOV BYTE [SI],49	;Ja, dann bearbeite die Variable [UNIX]
	
RDDO2:
	POP SI
	POP AX

	MOV [BF_LEN],AX
	MOV CX,AX
	LEA SI,[BF_CODE]
						;suche im BF Code "$" und ersetze sie durch " ", da "$" das Begrenzungszeichen vom Converter ist
SEARCH_DOLLAR:
	LODSB
	CMP AL,"$"
	JE SD_OK
	LOOP SEARCH_DOLLAR
	
AFSD:

						;Wandle den Dateinamen um, indem die Dateiendung durch ".asm" ausgetauscht wird
	LEA SI,[DATN]
CHECK_EXT:
	LODSB
	CMP AL,"."
	JE CHECK_EXT_OK
	CMP AL,0
	JNE CHECK_EXT
	;mov ah,2
	;mov dl,"1"
	;int 21h
	MOV AH,4CH
	INT 21H
CHECK_EXT_OK:
	MOV BYTE [SI],"a"
	INC SI
	MOV BYTE [SI],"s"
	INC SI
	MOV BYTE [SI],"m"
	INC SI
	MOV BYTE [SI],0		;Sollte die vorherige Dateiendung l�nger als 3 Zeichen sein, wird hier vorsichtshalber eine 0 (=ende des Dateinamens) angeh�ngt
	
	LEA SI,[BF_CODE]
	ADD SI,[BF_LEN]
	MOV BYTE [SI],"$"	;setze das Begrenzungszeichen an das Ende des BF Codes
	
	LEA SI,[BF_CODE]
	XOR DX,DX
	XOR BX,BX
	XOR CX,CX
	XOR DI,DI

CH_KL:
	LODSB
	CMP AL,"<"
	JE CH_KL_B
	CMP AL,">"
	JE CH_KL_F
	CMP AL,"["
	JE CH_KL_O
	CMP AL,"]"
	JE CH_KL_C
	CMP AL,"$"
	JE CH_KL_END
	JMP CH_KL
	
CH_KL_B:
	INC DX
	JMP CH_KL
CH_KL_F:
	INC BX
	JMP CH_KL
	
CH_KL_O:
	INC DI
	JMP CH_KL
	
CH_KL_C:
	INC CX
	JMP CH_KL
	
CH_KL_END:
	;CMP DX,BX
	JMP CH_KL_OK ;JB
	
	LEA DX,[FEHLER5]
	MOV AH,09H
	INT 21H
	LEA DX,[PRESS_K]
	INT 21H
	MOV AH,01H
	INT 21H
	MOV AH,4CH
	INT 21H
	
CH_KL_OK:

	CMP DI,CX
	JE CH_KL_OK2
	
	LEA DX,[FEHLER6]
	MOV AH,09H
	INT 21H
	LEA DX,[PRESS_K]
	INT 21H
	MOV AH,01H
	INT 21H
	MOV AH,4CH
	INT 21H
	
CH_KL_OK2:

	
						;## l�sche Datei *.asm, erstelle sie, �ffne sie
	MOV AH,41H
	LEA DX,[DATN]
	INT 21H
	
	MOV AH,3CH
	LEA DX,[DATN]
	MOV CX,0
	INT 21H
	
	MOV AH,3DH
	LEA DX,[DATN]
	MOV AL,2
	INT 21H	
	
	MOV [HANDLEW],AX	;Sichere den Dateihandle
	
	
	;##testend

	
	LEA SI,[BF_CODE]
	XOR BX,BX
	XOR DX,DX
SEARCH_K:				;�berpr�fe die Anzahl an ">" und somit die Gr��e des Variablenspeichers
	LODSB
	CMP AL,"$"
	JE SEARCH_K_END
	CMP AL,">"
	JE KLA_FOR
	JMP SEARCH_K
	
KLA_FOR:
	INC DX
	JMP SEARCH_K
	
SEARCH_K_END:			;Manipuliere entsprechende Variablen, verwandle die Speichergr��e in einen String
	MOV AX,DX
	LEA SI,[VARI]		
	ADD SI,8
	XOR DX,DX
	MOV CX,5
DIV_LOOP:
	MOV DX,0
	MOV BX,10
	DIV BX
	PUSH DX
	LOOP DIV_LOOP
	
	POP AX
	POP BX
	POP CX
	POP DX
	POP DI
	;PUSH AX
	
	ADD AX,48
	MOV BYTE [SI],AL
	INC SI
	
	ADD BX,48
	MOV AX,BX
	MOV BYTE [SI],AL
	INC SI
	
	ADD CX,48
	MOV AX,CX
	MOV BYTE [SI],AL
	INC SI

	ADD DX,48
	MOV AX,DX
	MOV BYTE [SI],AL
	INC SI
	
	CMP DI,0
	JNE NO_NULL
	ADD DI,1
NO_NULL:
	ADD DI,48
	MOV AX,DI
	MOV BYTE [SI],AL
	INC SI
	
	


	;POP AX
	
	;ADD DX,5
	;PUSH SI
	;PUSH DX
	;CALL COPY
	;POP DX
	;POP SI
		
	XOR BX,BX
	LEA SI,[BF_CODE]
	LEA DX,[AUSGABE]
	
	LEA DI,[START]
	;PUSH DI
	;PUSH DX
	;CALL COPY
	;POP DX
	;POP DI
								;Schreibe den Startcode in die Ausgabedatei
	PUSH DX
	MOV CX,65
	MOV BX,[HANDLEW]
	MOV AH,40H
	LEA DX,[START]
	INT 21H
	POP DX
	
	ADD DX,65
	
	;####test
	PUSH SI
	PUSH CX
	PUSH DI
	PUSH DX
	PUSH BX
								;suche die Klammern und die zugeh�rigen"]"
COC_E:
	LEA SI,[BF_OPEN_ARRAY]
	LEA DI,[BF_CLOSE_ARRAY]
	LEA BX,[BF_CODE]
	MOV CX,[BF_LEN]
	
SEARCH:
	MOV AL,[BX]
	INC BX
	CMP AL,"["
	JE S_O
	LOOP SEARCH
	POP BX
	POP DX
	POP DI
	POP CX
	POP SI
	JMP SCHLEIFE
	
S_O:
	MOV WORD [SI],BX
	DEC WORD [SI]
	INC SI
	INC SI
	CALL S_C
	MOV WORD [DI],AX
	INC DI
	INC DI
	LOOP SEARCH
	POP BX
	POP DX
	POP DI
	POP CX
	POP SI
	JMP SCHLEIFE
	
S_C:
	PUSH BX
	PUSH SI
	PUSH DI
	PUSH CX
	PUSH DX
	
	XOR DX,DX
	MOV SI,BX
	
S_S_C:
	LODSB
	CMP AL,"["
	JE S_S_C_O
	CMP AL,"]"
	JE S_S_C_C
	LOOP S_S_C
	JMP S_C_END
	
S_S_C_O:
	INC DX
	LOOP S_S_C
	JMP S_C_END
	
S_S_C_C:
	CMP DX,0
	JE S_C_OK
	DEC DX
	LOOP S_S_C
	JMP S_C_END
	
S_C_OK:
	DEC SI
	MOV AX,SI
S_C_END:
	POP DX
	POP CX
	POP DI
	POP SI
	POP BX
RET
;###test end

						;Main Loop
SCHLEIFE:
	INC BX
	LODSB
	CMP AL,"$"
	JE BF_SAVE
	CMP AL,"+"
	JE DO_PLUS
	CMP AL,"."
	JE DO_PUNKT
	CMP AL,","
	JE DO_KOMMA
	CMP AL,"["
	JE DO_BEGIN_LOOP
	CMP AL,"]"
	JE DO_END_LOOP
	CMP AL,"-"
	JE DO_MINUS
	CMP AL,"<"
	JE DO_BACK
	CMP AL,">"
	JE DO_FORWARD
	JMP SCHLEIFE
	
DO_BACK:
	LEA DI,[BACK]
	;PUSH DI
	;PUSH DX
	;CALL COPY
	;POP DX
	;POP DI
	PUSH DX
	MOV CX,8
	MOV BX,[HANDLEW]
	MOV AH,40H
	LEA DX,[BACK]
	INT 21H
	POP DX
	ADD DX,8
	JMP SCHLEIFE
	
DO_FORWARD:
	LEA DI,[FORWARD]
	;PUSH DI
	;PUSH DX
	;CALL COPY
	;POP DX
	;POP DI
	PUSH DX
	MOV CX,8
	MOV BX,[HANDLEW]
	MOV AH,40H
	LEA DX,[FORWARD]
	INT 21H
	POP DX
	ADD DX,8
	JMP SCHLEIFE
	
DO_MINUS:
	LEA DI,[MINUS]
	;PUSH DI
	;PUSH DX
	;CALL COPY
	;POP DX
	;POP DI	
	PUSH DX
	MOV CX,15
	MOV BX,[HANDLEW]
	MOV AH,40H
	LEA DX,[MINUS]
	INT 21H
	POP DX
	ADD DX,15
	JMP SCHLEIFE
	
DO_END_LOOP:
	PUSH BX
	MOV BX,SI
	DEC BX
	;MOV DI,DX
	LEA DI,[AUSGABE]
	MOV BYTE [DI],"L"
	INC DI
	INC DX
	PUSH DI
	PUSH BX
	CALL INTTOSTRING
	POP BX
	POP DI
	ADD DI,5
	;MOV DI,DX
	MOV BYTE [DI],":"
	INC DX
	INC DI
	MOV BYTE [DI],13
	INC DX
	INC DI
	MOV BYTE [DI],10
	INC DX
	INC DI
	
	PUSH DX
	MOV CX,8
	MOV BX,[HANDLEW]
	MOV AH,40H
	LEA DX,[AUSGABE]
	INT 21H
	POP DX
	
	LEA DI,[END_LOOP]
	
	PUSH DX
	MOV CX,22
	MOV BX,[HANDLEW]
	MOV AH,40H
	LEA DX,[END_LOOP]
	INT 21H
	POP DX
	
	;PUSH DI
	;PUSH DX
	;CALL COPY
	;POP DX
	;POP DI
	ADD DX,22
	MOV BX,SI
	DEC BX
	MOV AX,BX
	;CALL SEARCH_END
	PUSH SI
	PUSH DI
	PUSH BX
	PUSH CX
	XOR CX,CX
	LEA SI,[BF_CLOSE_ARRAY]
SCK:
	MOV WORD BX,[SI]
	ADD SI,2
	CMP BX,AX
	JE SCK_OK
	INC CX
	JMP SCK
SCK_OK:
	MOV AX,CX
	POP CX
	POP BX
	POP DI
	POP SI
	LEA BX,[BF_OPEN_ARRAY]
	ADD BX,AX
	ADD BX,AX
	;MOV SI,[BX]
	;PUSH WORD [BX]
	LEA DI,[AUSGABE]
	PUSH DI
	PUSH WORD [BX]
	CALL INTTOSTR
	POP BX
	POP DI
	ADD DI,5
	;MOV DI,DX
	MOV BYTE [DI],13
	INC DX
	INC DI
	MOV BYTE [DI],10
	INC DX
	
	PUSH DX
	MOV CX,7
	MOV BX,[HANDLEW]
	MOV AH,40H
	LEA DX,[AUSGABE]
	INT 21H
	POP DX
	
	POP BX
	JMP SCHLEIFE
	
DO_BEGIN_LOOP:
	PUSH BX
	MOV BX,SI
	DEC BX
	MOV DI,DX
	LEA DI,[AUSGABE]
	MOV BYTE [DI],"L"
	INC DI
	PUSH DI
	PUSH BX
	CALL INTTOSTRING
	POP BX
	POP DI
	ADD DI,5
	;MOV DI,DX
	MOV BYTE [DI],":"
	INC DX
	INC DI
	MOV BYTE [DI],13
	INC DX
	INC DI
	MOV BYTE [DI],10
	INC DX
	INC DI
	
	PUSH DX
	MOV CX,8
	MOV BX,[HANDLEW]
	MOV AH,40H
	LEA DX,[AUSGABE]
	INT 21H
	POP DX
	
	LEA DI,[BEGIN_LOOP]
	;PUSH DI
	;PUSH DX
	;CALL COPY
	;POP DX
	;POP DI
	
	PUSH DX
	MOV CX,21
	MOV BX,[HANDLEW]
	MOV AH,40H
	LEA DX,[BEGIN_LOOP]
	INT 21H
	POP DX
	
	
	ADD DX,21
	MOV BX,SI
	DEC BX
	MOV AX,BX
	CALL SEARCH_END
	LEA BX,[BF_CLOSE_ARRAY]
	ADD BX,AX
	ADD BX,AX
	;MOV SI,[BX]
	;PUSH WORD [BX]
	LEA DI,[AUSGABE]
	PUSH DI
	PUSH WORD [BX]
	CALL INTTOSTR
	POP BX
	POP DI
	ADD DI,5
	;MOV DI,DX
	MOV BYTE [DI],13
	INC DX
	INC DI
	MOV BYTE [DI],10
	INC DX
	
	PUSH DX
	MOV CX,7
	MOV BX,[HANDLEW]
	MOV AH,40H
	LEA DX,[AUSGABE]
	INT 21H
	POP DX
	
	POP BX
	JMP SCHLEIFE
	
	
DO_PLUS:
	LEA DI,[PLUS]
	;PUSH DI
	;PUSH DX
	;CALL COPY
	;POP DX
	;POP DI
	
	PUSH DX
	MOV CX,15
	MOV BX,[HANDLEW]
	MOV AH,40H
	LEA DX,[PLUS]
	INT 21H
	POP DX
	
	ADD DX,15
	JMP SCHLEIFE
	
DO_KOMMA:
	LEA DI,[KOMMA]
	;PUSH DI
	;PUSH DX
	;CALL COPY
	;POP DX
	;:POP DI
	
	PUSH DX
	MOV CX,17
	MOV BX,[HANDLEW]
	MOV AH,40H
	LEA DX,[KOMMA]
	INT 21H
	POP DX
	
	ADD DX,17;39
	JMP SCHLEIFE
	
DO_PUNKT:
	LEA DI,[PUNKT]
	;PUSH DI
	;PUSH DX
	;CALL COPY
	;POP DX
	;POP DI
	
	PUSH DX
	MOV CX,17
	MOV BX,[HANDLEW]
	MOV AH,40h
	LEA DX,[PUNKT]
	INT 21H
	POP DX
	
	ADD DX,17;34
	JMP SCHLEIFE
	
BF_SAVE:
								;Schreibe Unterprozeduren, Variablen und Beendigungscode in die Datei
	LEA DI,[ENDE]
	LEA DX,[AUSGABE]
	PUSH DI
	PUSH DX
	CALL COPY
	POP DX
	POP DI
	ADD DX,21
	
	LEA DI,[VAR3]
	PUSH DI
	PUSH DX
	CALL COPY
	POP DX
	POP DI
	ADD DX,11
	
	LEA DI,[VARI]
	PUSH DI
	PUSH DX
	CALL COPY
	POP DX
	POP DI
	ADD DX,14
	LEA DI,[VARI_2]
	PUSH DI
	PUSH DX
	CALL COPY
	POP DX
	POP DI
	ADD DX,9
	
	LEA DI,[PUNKT_CALL]
	PUSH DI
	PUSH DX
	CALL COPY
	POP DX
	POP DI
	ADD DX,173
	
	LEA DI,[KOMMA_CALL]
	PUSH DI
	PUSH DX
	CALL COPY
	POP DX
	POP DI
	ADD DX,228
	
	LEA DI,[UNIX]
	PUSH DI
	PUSH DX
	CALL COPY
	POP DX
	POP DI
	ADD DX,11
	
	MOV [LEN],DX
	
	
	;MOV AH,41H
	;;LEA DX,[DATN]
	;INT 21H
	
	;MOV AH,3CH
	;LEA DX,[DATN]
	;MOV CX,0
	;INT 21H
	
	;MOV AH,3DH
	;LEA DX,[DATN]
	;MOV AL,2
	;INT 21H	
	
	MOV BX,[HANDLEW]
	MOV AH,40H
	LEA DX,[AUSGABE]
	MOV CX,467
	INT 21H
	
	MOV AH,3EH
	MOV BX,[HANDLEW]
	INT 21H
	
	LEA DX,[FEHLER4]
	MOV AH,09H
	INT 21H
	LEA DX,[ALL_OK]
	INT 21H
	
	MOV AH,4CH
	INT 21H
	
	;###Kopiere Quelle nach Ziel; Begrenzungszeichen: 0; Parameter: Pushe Quelle, Ziel
COPY:
	PUSH BP
	MOV BP,SP
	PUSH DI
	PUSH SI
	PUSH AX
	ADD BP,4
	MOV SI,[BP]	;Wohin
	ADD BP,2
	MOV DI,[BP]	;Woher
	
COPY_LOOP:
	MOV AL,[DI]
	INC DI
	CMP AL,0
	JE COPY_LOOP_END
	MOV [SI],AL
	INC SI
	JMP COPY_LOOP
	
COPY_LOOP_END:
	
	POP AX
	POP SI
	POP DI
	POP BP
RET
	
	
	;###suche Position der "[" Klammer im BF_OPEN_ARRAY; Parameter: AX=Position der "[" Im code
SEARCH_END:
	PUSH SI
	PUSH DI
	PUSH CX
	PUSH BX
	PUSH DX
	
	XOR DX,DX
	LEA SI,[BF_OPEN_ARRAY]
	MOV CX,1000
	
S_E_START:
	LODSW
	CMP AX,BX
	JE S_E_START_OK
	INC DX
	LOOP S_E_START
	MOV AH,4CH
	INT 21H
	
S_E_START_OK:
	MOV AX,DX
	POP DX
	POP BX
	POP CX
	POP DI
	POP SI
RET
	
	
	;####Verwandle Zahlen in einen String; Parameter: Pushe Ziel, Zahl
	
INTTOSTR:
INTTOSTRING:
	PUSH BP
	MOV BP,SP
	ADD BP,4
	PUSH DX
	PUSH BX
	PUSH AX
	PUSH CX
	PUSH SI
	PUSH DI
	MOV AX,[BP]	;zahl
	ADD BP,2
	MOV SI,[BP]	;Wohin?
	MOV CX,5
	
DIV_LOOP1:
	MOV DX,0
	MOV BX,10
	DIV BX
	PUSH DX
	LOOP DIV_LOOP1
	
	POP AX
	POP BX
	POP CX
	POP DX
	POP DI
	;PUSH AX
	
	ADD AX,48
	MOV BYTE [SI],AL
	INC SI
	
	ADD BX,48
	MOV AX,BX
	MOV BYTE [SI],AL
	INC SI
	
	ADD CX,48
	MOV AX,CX
	MOV BYTE [SI],AL
	INC SI

	ADD DX,48
	MOV AX,DX
	MOV BYTE [SI],AL
	INC SI
	
	ADD DI,48
	MOV AX,DI
	MOV BYTE [SI],AL
	INC SI
	
	POP DI
	POP SI
	POP CX
	POP AX
	POP BX
	POP DX
	POP BP
RET