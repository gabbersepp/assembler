;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   BR13EN.COM v1.0 A simple ROT13 Encoder
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
use16
org 100h
JMP AFTER_DATA
	STRING	DB	0
	BUFFER	DB	0
	FEHLER1	DB	"BR13EN.COM (C) 2006 by Josef Biehler",13,10,"Richtige Benutzung: BR13EN.COM dateiname.xy",13,10,"$"
	FEHLER2	DB	"Es trat ein Fehler beim Öffnen der Datei auf.$"
	FEHLER3	DB	"Es trat ein Fehler beim Lesen der Datei auf.$"
	PRESS_K	DB	"Bitte Taste drücken zum beenden.$"
	DATN	DB	130	DUP(0)
	HANDLER	DW	0
	HANDLEW	DW	0
AFTER_DATA:

	MOV AX,CS
	MOV DS,AX
	MOV ES,AX
	
	;;;;;;;;;;;;;;;;;;;; Überprüfe die Kommandozeile
	MOV BX,80H
	MOV CL,[DS:BX]
	XOR CH,CH
	CMP CX,0
	JNE COMMANDLINE_OK ;;; CX > 0? Wenn ja, Dateiname angegeben
	
	MOV AH,09H
	LEA DX,[FEHLER1]
	INT 21H
	LEA DX,[PRESS_K]
	INT 21H
	MOV AH,01H
	INT 21H
	JMP BR_END
	
COMMANDLINE_OK:
	
	;;;;;;;;;;;;;;;;;;;; Kopiere die Kommandozeile in die Variable DATN
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
	
	;;;;;;;;;;;;;;;;;;; Öffne die Datei
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
	JMP BR_END
	
OPEN_DATA_OK:
	
	;;;;;;;;;;;;;;;;;;;;;;;; Forme den Dateinamen für die Ausgabe um
	MOV [HANDLER],AX
	LEA SI,[DATN]
S_P:
	LODSB
	CMP AL,"."
	JE PUNKT
	CMP AL,0
	JE BR_END
	JMP S_P
PUNKT:
	MOV DL,[SI]
	INC SI
	MOV DH,[SI]
	INC SI
	MOV BL,[SI]
	INC SI
	MOV BH,[SI]
	DEC SI
	DEC SI
	DEC SI
	DEC SI
	MOV BYTE [SI],"("
	INC SI
	MOV BYTE [SI],"r"
	INC SI
	MOV BYTE [SI],")"
	INC SI
	MOV BYTE [SI],"."
	INC SI
	MOV BYTE [SI],DL
	INC SI
	MOV BYTE [SI],DH
	INC SI
	MOV BYTE [SI],BL
	INC SI
	MOV BYTE [SI],BH
	
	MOV AH,41H
	LEA DX,[DATN]
	INT 21H
	
	MOV AH,3CH
	LEA DX,[DATN]
	MOV CX,0
	INT 21H
	
	;LEA DX,[DATN]
	;MOV AH,09H
	;INT 21H
	JC READ_DATA_FAILED
	
	MOV AH,3DH
	LEA DX,[DATN]
	MOV AL,2
	INT 21H	
	
	JC READ_DATA_FAILED
	
	MOV [HANDLEW],AX
	
RD_WR_BYTE:
	MOV BX,[HANDLER]
	MOV AH,3FH
	MOV CX,1
	LEA DX,[STRING]
	INT 21H
	
	JC READ_DATA_FAILED
	
	CMP AX,0
	JE BR_OK_END
	
	LEA SI,[STRING]
	ADD BYTE [SI],13
	
	MOV BX,[HANDLEW]
	MOV AH,40H
	LEA DX,[STRING]
	MOV CX,1
	INT 21H
	
	JMP RD_WR_BYTE
	
READ_DATA_FAILED:
	LEA DX,[FEHLER3]
	MOV AH,09H
	INT 21H
	LEA DX,[PRESS_K]
	INT 21H
	MOV AH,01H
	INT 21H
	JMP BR_END
	
BR_OK_END:
	MOV AH,3EH
	MOV BX,[HANDLEW]
	INT 21H
	MOV AH,3EH
	MOV BX,[HANDLER]
	INT 21H

BR_END:
	MOV AH,4CH
	INT 21H