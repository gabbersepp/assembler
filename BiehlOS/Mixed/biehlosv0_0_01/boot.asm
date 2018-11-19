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
	MOV ES,AX
		
	CLI
	MOV WORD [ES:6H*4],INT6H
	MOV WORD [ES:6H*4+2],CS
	MOV AX,9000H
	MOV SS,AX
	MOV SP,200H
	STI
		
	LODSD
	
	LEA BX,[LOAD1]
	MOV AH,0EH
		
LOAD_PRNT:
	MOV AL,[BX]
	INT 10H
	CMP BYTE [BX],0
	JE LOAD_PRNT_END
	INC BX
	JMP LOAD_PRNT
	
LOAD_PRNT_END:
	JMP $
		
INT6H:
	LEA BX,[NO_386]
	MOV AH,0EH
		
INT6H_PRNT:
	MOV AL,[BX]
	INT 10H
	CMP BYTE [BX],0
	JE PRNT_END
	INC BX
	JMP INT6H_PRNT
		
PRNT_END:
	JMP $
	
		
NO_386	DB	"Der Prozessor traf auf einen unbekannten Befehl.",13,10
		DB	"Das BiehlOS benötigt mindestens einen 386er Prozessor.",13,10
		DB	"Vielleicht ist Ihr CPU zu alt.",13,10
		DB	"Der PC kann jetzt ausgeschaltet werden.",13,10,0
LOAD1	DB	"Lade BiehlOS v0.01",13,10,"Der PC kann jetzt ausgeschaltet werden.",13,10,0
VAR1	DW	0
DB 510-$ DUP(0)
		DW 0AA55h