;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Kommandointerpreter für BiehlOS					;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	MOV AX, CS
	MOV DS, AX
	MOV ES, AX
	
	JMP AFTER_DATA
	
		NO_PC_TEXT	DB	"Unbekannter Befehl/programm",13,10,0
		NOT_MEM_T	DB	"Nicht genuegend Speicher",13,10,0
		HELLO		DB	"BiehlOS v0.0.01",13,10
					DB	"(c) 2005-2007 by Josef Biehler",13,10
					DB	"http://biehler-josef.de",13,10
					DB	"biehlos@biehler-josef.de",13,10
					DB	"'help' eingeben, um Befehlsuebersicht zu erhalten",13,10, 0
		DISK		DB	"fd:>",0
		NL_E		DB	13,10,0
		CMD_BUFFER	DB	200 DUP(0)
		DIR_INFO_STRUCT:
					DW	0
					DW	0
					DW	0
	
	AFTER_DATA:

		MOV AX,03h
		INT 10H
		
		MOV AH, 05H
		MOV SI, HELLO
		INT 20H
		
		SHELL_LOOP:
			
			MOV AX, CS
			MOV DS, AX
			MOV ES, AX
			
			MOV AH, 05H
			MOV SI, NL_E
			INT 20H
			
			MOV AH, 05H
			MOV SI, DISK
			INT 20H
			
			MOV AH, 06H
			MOV SI, CMD_BUFFER
			MOV CX, 200
			INT 20H
			
			;MOV AH, 05H
			;MOV SI, CMD_BUFFER
			;INT 20H
			
			MOV AH, 05H
			MOV SI, NL_E
			INT 20H
			
			MOV SI, CMD_BUFFER
			MOV AH, 0BH
			INT 20H					;Entferne Leerzeichen am Anfang
			
			MOV SI, CMD_BUFFER
			MOV AH, 09H
			MOV BL, " "
			INT 20H					;Explode
			
			MOV BX, AX
									;Das Element 0 sollte jetzt der Befehl sein.
			MOV CX, AX
			
			MOV DS, CX
			MOV SI, 0
			MOV AX, [DS:SI]
			MOV DS, AX
			MOV AH, 07H
			INT 20H					;LoToUpperCase
			
			MOV DS, BX
			MOV SI, 0
			MOV AX, [DS:SI]
			MOV DS, AX
			
			MOV AX, CS
			MOV ES, AX
			MOV DI, CMD_LIST
			
			Check_CMD:
			
			;db 512-$ dup(90h)
			;mov aH, 0eh
			;mov al, "j"
			;int 10h
			;jmp $
				CMP WORD [ES:DI], 0FFFFH
				JE No_CMD
				
			CHK_LOOP1:
				CMP BYTE [DS:SI], 0
				JE CHK_END_OK
				
				MOV BL, [DS:SI]
				CMP BL, [ES:DI]
				JE CHK_NEXT
				
				SUB DI, SI
				ADD DI, 12
				MOV SI, 0
				JMP Check_CMD
				
			CHK_NEXT:
				INC DI
				INC SI
				JMP CHK_LOOP1
				
			CHK_END_OK:
				
				SUB DI, SI
				ADD DI, 10
				
				MOV AH, 0AH
				MOV BX, CX
				
				INT 20H				;Explode Array auflösen
				
				;MOV BX, CMD_LIST
				;ADD BX, 10
				;jmp $
				CALL WORD [ES:DI]
				
				JMP SHELL_LOOP
				

				
			;wenn kleienr als 2....
			;CMP AX, 2
			;JB 
			
			No_CMD:


				;Teste auf Programm
				MOV BX, 1
				MOV AH, 0EH
				INT 20H
				
								;Überprüfuen auf Fehler
				
				MOV ES, AX
				MOV DI, 0
				MOV SI, 0
				
				MOV DX, CX
				
				XOR CX, CX

				COPY_LOOP:
					MOV AL, [DS:SI]
					CMP AL, "."
					JE COPY_CMD_DOT
					CMP AL, 0
					JE COPY_CMD_0
					MOV [ES:DI], AL
					INC CX
					INC SI
					INC DI
					JMP COPY_LOOP
					
				COPY_CMD_0:
					JMP SHELL_LOOP
				;	MOV AX, 11
				;	SUB AX, CX
				;	MOV BYTE [ES:DI], 
				COPY_CMD_DOT:
					MOV AX, 11
					SUB AX, CX
					INC SI
					
					SUB AX, 3
					MOV CX, AX
					
					COPY_CMD_L:
						MOV BYTE [ES:DI], " "
						INC DI
						LOOP COPY_CMD_L
						
					MOV CX, 3
					
					COPY_CMD_EXT:
						MOV AL, [DS:SI]
						CMP AL, 0
						JE COPY_EXT_L
						MOV [ES:DI], AL
						INC DI
						INC SI
						LOOP COPY_CMD_EXT
						
						JMP AFTER_COPY_EXT_L
						
					COPY_EXT_L:
						MOV BYTE [ES:DI], " "
						LOOP COPY_EXT_L
						
					AFTER_COPY_EXT_L:
							
				
				MOV AH, 0AH
				MOV BX, DX
				
				INT 20H				;Explode Array auflösen
				
				
				PUSH ES
				POP DS
				MOV SI, 0			;DS:SI Dateiname
				MOV AH, 04H
				INT 20H
				
				CMP AX, 2
				JB NO_PROG_NO_CMD
				
				XOR DX, DX
				MOV BX, 16
				DIV BX
				INC AX
				
				MOV BX, AX
				MOV AH, 0EH
				INT 20H					;Speicher anfordern
				
				CMP AX, 2
				JB NOT_ENOUGH_MEM
				
				MOV BX, AX
				
				MOV DX, AX
				MOV CX, 0
				MOV AH, 10H
				INT 20H					;Programm laden
				
				CMP AX, 2
				JB NO_PROG_NO_CMD
				;mov ds, bx
				;mov ax, [ds:0]
				;jmp $
				MOV [CS:SHELL_JMP+3], BX
				NOP
				NOP
				NOP
				NOP
				NOP
				SHELL_JMP: CALL 2000H:0H
			
				
			JMP SHELL_LOOP
			
			NO_PROG_NO_CMD:
				MOV AX, CS
				MOV DS, AX
				MOV Si, NO_PC_TEXT
				MOV AH, 05H
				INT 20H
				JMP SHELL_LOOP
				
			NOT_ENOUGH_MEM:
				PUSH CS
				POP DS
				MOV SI, NOT_MEM_T
				MOV AH, 05H
				INT 20H
				JMP SHELL_LOOP
			
		CMD_LIST:		;10 Zeichen pro Befehl; 
		
			DB	"HELP",0,0,0,0,0,0
			DW	CMD_HELP
			
			DW	0FFFFH
			
		CMD_HELP:
		
			MOV AH, 05H
			MOV BX, CS
			MOV DS, BX
			MOV SI, HELP_TEXT
			INT 20H
			
			RET
			
		CMD_HELP_PARAM:
		
			DB	0
			
		HELP_TEXT:
		
			DB	13,10,"Das ist die Hilfe",13,10,0
		
		JMP $