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

	JMP 07C0H:MAIN
		
MAIN:
	MOV AX,CS
	MOV DS,AX
	MOV ES,AX
	
	MOV AX,0
	MOV AL,3
	INT 10H
	
	MOV AX,0
	MOV ES,AX
		
	CLI
	MOV WORD [ES:6H*4],INT6H
	MOV WORD [ES:6H*4+2],CS
	MOV AX,9000H
	MOV SS,AX
	MOV SP,200H
	STI
		
	
	LEA BX,[LOAD1]
	MOV AH,0EH
		
LOAD_PRNT:
	MOV AL,[BX]
	CMP BYTE [BX],0
	JE LOAD_PRNT_END
	INC BX
	INT 10H
	JMP LOAD_PRNT
	
LOAD_PRNT_END:
	
	MOV CX, 1
LOAD_DATA:
	PUSH CX
	PUSH CX
	;PUSH 1000H
	CALL LBA_CHS
	POP DX
	MOV CL,AH
	MOV CH,AL
	MOV AX, 1000H
	MOV ES, AX
	MOV AH,02H
	MOV DH,BH
	MOV DL,0
	MOV AL,1
	;LEA BX,[MEMORY]
	MOV BX,[VAR1]
	INT 13H
	ADD [VAR1],512
	POP CX
	INC CX
	CMP CX,82
	JE LD_END
	JMP LOAD_DATA
	
LD_END:
	PUSH ES
	PUSH DS
	CALL 1000H:0H
	POP DS
	POP ES
							;bearbeite nun die Routine INT6H, damit man sich eine weitere Ausgaberoutine spart
	MOV WORD [INT6H+2], OFF
	JMP INT6H
	JMP $
		
INT6H:
	LEA BX,[NO_386]
	MOV AH,0EH
		
INT6H_PRNT:
	MOV AL,[BX]
	CMP BYTE [BX],0
	JE PRNT_END
	INC BX
	INT 10H
	JMP INT6H_PRNT
		
PRNT_END:
	JMP $
	
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; LBA_CHS: Rechne LBA in CHS um								;;
		;; Parameter: Pushe LBA											;;
		;; Rückgabe: AH=Sektor											;;
		;;			 AL=Spur											;;
		;;			 BH=Head											;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		LBA_CHS:
			PUSH BP
			MOV BP,SP
			PUSH DX
			PUSH CX
			ADD BP,6
			MOV AX,[BP]				;AX=LBA
			
		SPUR:
			MOV BX,36
			XOR DX,DX
			DIV BX
			XOR AH,AH
			PUSH AX
			
		HEAD:
			MOV BX,18
			MOV AX,[BP]
			XOR DX,DX
			DIV BX
			MOV BX,2
			XOR DX,DX
			DIV BX
			XOR DH,DH
			PUSH DX
			
		SEKTOR:
			MOV AX,[BP]
			MOV BX,18
			XOR DX,DX
			DIV BX
			ADD DX,1
			XOR DH,DH
			PUSH DX
			
			POP CX
			MOV AH,CL
			POP CX
			MOV BH,CL
			POP CX
			MOV AL,CL
			POP CX
			POP DX
			POP BP
		RET
		
NO_386	DB	"Der Prozessor traf auf einen unbekannten Befehl.",13,10
OFF		DB	"Der PC kann jetzt ausgeschaltet werden.",13,10,0
LOAD1	DB	"Lade BiehlOS v0.0.02",13,10
		DB	"Lade Kernel",13,10,0
VAR1	DW	0

DB 510-$ DUP(0)
		DW 0AA55h
file 'kernel.bin'