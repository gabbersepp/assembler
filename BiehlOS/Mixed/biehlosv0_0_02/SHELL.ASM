;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BiehlOS
;; Mein Versuch, ein Betriebssystem zu entwickeln
;; (c) 2005-2006 by Josef Biehler
;; http://biehler-josef.de
;; biehlos@biehler-josef.de
;; Ich hafte für keinerlei Schäden! 
;; Näheres dazu in der gpl.txt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; boot.asm
;; Bootloader für BiehlOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
use16		
		MOV AX, CS
		MOV DS, AX
		MOV ES, AX
		;PUSH ES
		
		MOV AX,0
		MOV AL,3h
		INT 10H
	
		LEA DI, [BIEHLOS]			;Zeige den BiehlOS Schriftzug
		MOV AH, 05H
		INT 20H

		LEA DI, [WCOME]				;Copyrighthinweise
		MOV AH, 05H
		INT 20H
	
	MAIN_LOOP:
		LEA DI, [DISK]
		MOV AH, 05H
		INT 20H
		MOV AH, 03H
		LEA DI, [CMD_BUFFER]
		MOV CX, 100
		INT 20H
		
		MOV AH, 07H					;INT20H/AH=7H Up To Lower Case
		LEA DI, [CMD_BUFFER]
		INT 20H
		
		MOV AH, 08H					;entferne Anfangsleerzeichen
		LEA DI, [CMD_BUFFER]
		INT 20H

		MOV AH, 09H					;entferne Schlußleerzeichen
		LEA DI, [CMD_BUFFER]
		INT 20H
		
		MOV AH, 05H
		LEA DI, [CMD_BUFFER]
		;INT 20H
		
		MOV AH, 0AH					;Suche nächstes Lerzeichen
		LEA DI, [CMD_BUFFER]		;um auf Befehlsparameter zu vergleichen
		MOV AL, " "
		INT 20H
		
		CMP AX, 0
		JE NO_CMD_PARA
		ADD DI, AX					;DI zeigt auf Leerzeichen
		MOV BYTE [ES:DI], 0
									;Entferne Leerzeichen zwischen Befehl und Parameter
		INC DI
		MOV AH, 08H
		INT 20H
		
		;PUSH DI
		;LEA DI, [CMD_BUFFER]

		;POP DI
		
		XOR DX, DX
		CMP WORD [ES:DI], "/?"		;vergleiche auf Optionsparameter \?
		JNE NO_CMD_PARA

		MOV DX, 0FFFFH				;Wenn DX=0FFFFH: Befehl muss Hilfetext ausgeben
		
	NO_CMD_PARA:
		
		MOV AH, 0H					;INT20H/AH=0 Gib einzelnes Zeichen am Bildschirm aus
		MOV AL, 13
		INT 20H
		MOV AH, 0H
		MOV AL, 10
		INT 20H
		LEA SI, [COMMANDS]
		MOV CX, 2					;Anzahl an Befehlen
	CHK_CMD:	
		LEA DI, [CMD_BUFFER]
		MOV AH, 06H
		INT 20H
		CMP AX, 1
		JE CC_OK
		ADD SI, 15
		LOOP CHK_CMD
		;JMP CHECK_PROG					;Kein Befehl, könnte als ein Programmname sein
		JMP MAIN_LOOP
		
	CC_OK:
		
		ADD SI, 13
		MOV AX, [SI]
		CALL AX
		JMP MAIN_LOOP
		
		RETF
	
WCOME		DB	"BiehlOS v0.0.02",13,10,"(c) 2005-2006 by Josef Biehler",13,10,"http://biehler-josef.de",13,10
			DB	"biehlos@biehler-josef.de",13,10,"'help' eingeben, um Befehlsliste zu erhalten",13,10,13,10,0
DISK		DB	13,10,"fd>",0
BIEHLOS 	DB 	13,10				
			FILE 'gh.asm'
			DB	13,10,0
CMD_BUFFER	DB	101 DUP(0)
HELP_CMD	DB	"Folgende Befehle sind verfuegbar:",13,10
			DB	"help        :Zeigt diesen Text an",13,10
			DB	"shutdown    :Fährt das System herunter.",13,10
			DB	0
HELP_HELP_TEXT	DB	"Zeigt eine kurzer Hilfe zu allen Befehlen an.",13,10,0
SHUTDOWN_HELP_TEXT	DB	"Fährt das System herunter",13,10,0
COMMANDS:
			DB	"help",0,0,0,0,0,0,0,0,0	;12 Bytes/13. Byte 0
			DW	HELP
			DB	"shutdown",0,0,0,0,0
			DW	SHUTDOWN
			
SHUTDOWN:
			ADD SP, 2
			RETF
			
HELP:		
			CMP DX, 0FFFFH
			JE PRINT_HELP_HELP_TEXT
			LEA DI, [HELP_CMD]
			MOV AH, 05H
			INT 20H
			RET
			
	PRINT_HELP_HELP_TEXT:
			MOV AH, 05H
			LEA DI, [HELP_HELP_TEXT]
			INT 20H
			RET
			
	db 2*1024-$ DUP(0)
