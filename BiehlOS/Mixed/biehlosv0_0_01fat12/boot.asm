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
	JMP 		AFTER_BPB
	NOP
	OS_NAME	DB	"BiehlOS "
	BPS		DW	512
	SPC		DB	1
	RESSEC	DW	1
	NFATS	DB	2
	ROOTE	DW	224
	TOTSEC	DW	2880
	MEDTYP	DB	0F0H
	FATSIZE	DW	9
	SPT		DW	18
	NH		DW	2
	HS		DD	0
	TOTS	DD	0
	DRVNUM	DB	0
	RES		DB	0
	BOOTS	DB	29H
	VID		DD	0
	VLABEL	DB	"NO NAME    "
	FSTP1	DB	"FAT12   "
	
AFTER_BPB:

	JMP 07C0H:MAIN
		
MAIN:
	MOV AX,CS
	MOV DS,AX
	MOV ES,AX
	
	MOV AX,0
	MOV ES,AX
		
	CLI
	;MOV WORD [ES:6H*4],INT6H
	;MOV WORD [ES:6H*4+2],CS
	MOV AX,9000H
	MOV SS,AX
	MOV SP,200H
	STI
	
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
	CMP CX,34
	JE LD_END
	JMP LOAD_DATA
	
LD_END:
	LEA DI, [datn]
	mov ax, cs
	mov es, ax
	call ReadFileName			;AX=Erster cLUSTER
	CMP AX, 0
	JNE WEITER
	LEA DI, [FEHLER]
	MOV AH, 0EH
	
PR_F:
	MOV AL, [ES:DI]
	INT 10H
	INC DI
	CMP AL, 0
	JNE PR_F
	JMP $
	
WEITER:
	MOV BX, AX					;Sichere Cluster
	ADD AX, 31					;AX=Anfangssektor
	MOV [VAR1], 4200h
	
	
LOAD_KERNEL:
	PUSH BX
	PUSH AX
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
	MOV BX,[VAR1]
	INT 13H
	ADD [VAR1],512
	
	;MOV SI, 0
	;MOV AX, 1000h
	;MOV DS, AX

	POP AX						;AX=Erster Cluster
	CALL GetCluster
	MOV BX, AX
	CMP AX, 0FFFH
	JE LOAD_END
	ADD AX, 31
	JMP LOAD_KERNEL
	
LOAD_END:

	JMP 1420H:0H
	
	
	;insgesamt 4200h bytes an daten
	
datn db "KERNEL  BIN"
	
	GetCluster:
		;Parameter: AX=Clusternummer
		;Back: AX=Clusterinhalt
		PUSH AX
		MOV BX, 2
		XOR DX, DX
		DIV BX
		POP AX
		CMP DX, 0
		JNE GC_UNGERADE
		
		MOV  BX, 3
		XOR DX, DX
		MUL BX
		MOV BX, 2
		DIV BX
		PUSH AX
		MOV AX, 1000h
		MOV DS, AX
		POP AX
		MOV SI, 0
		ADD SI, AX
		MOV CL, [DS:SI]
		INC SI
		MOV BL, [DS:SI]
		SHL BL, 4
		SHR BL, 4
		MOV CH, BL
		MOV AX, CX
		RET
		
	GC_UNGERADE:	
		MOV  BX, 3
		XOR DX, DX
		MUL BX
		MOV BX, 2
		DIV BX
		;DEC AX
		PUSH AX
		MOV AX, 1000h
		MOV DS, AX
		POP AX
		MOV SI, 0
		ADD SI, AX
		MOV CL, [DS:SI]
		SHR CL, 4
		SHL CL, 4
		INC SI
		MOV CH, [DS:SI]
		SHR CX, 4
		MOV AX, CX
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; ReadFileName: Suche in FS Dateiname
	;; Parameter: ES:DI Dateiname
	;; Back:
	;;		AX=0 Fehler(Nicht gefunden)
	;;		AX>0 Nummer des Filetable Eintrages
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ReadFileName:
		MOV CX, 224
	READ_FN:
		MOV AX, 1000H
		MOV DS, AX
		MOV SI, 18*512	;zeige auf Root Dir
		MOV AX, 11
		MOV DL, 0
		PUSH CX
		CALL CHKSTR
		POP CX
		CMP AX, 1
		JE DAT_OK
		LOOP READ_FN
		MOV AX, 0
		RET
	DAT_OK:
		MOV AX, 224
		SUB AX, CX
		XOR DX, DX
		MOV BX, 32
		MUL BX
		MOV SI, 18*512
		ADD SI, AX			;SI zeigt auf den benötigten Filetable EIntrag
		ADD SI, 26			;SI Zeigt auf den Cluster
		MOV AX, [DS:SI]
		RET
		
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
			ADD BP,4
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
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; CHKSTR: Vergleiche 2 Strings miteinander, bis BEGRENZUNGSZEICHEN ;;
		;; Parameter:	ES:DI String eins, DS:SI String 2, AX=Anzahl Zeichen;;
		;;				DX=Zeichen
		;; Rückgabe:	AX=1 Strings OK / AX=0 Strings falsch				;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		CHKSTR:
			MOV CX, AX

		CHSTR:
			MOV BL,[ES:DI]
			MOV BH,[DS:SI]
			MOV AX,0
			CMP BH,BL
			JNE CHSTR_END
			INC SI
			INC DI
			LOOP CHSTR
			;MOV AX, 0
			;RET
			
		CHSTR_C:	
			MOV AX,1
		CHSTR_END:
		RET

VAR1	DW	0
FEHLER DB "File not Found",0
DB 510-$ DUP(0)
		DW 0AA55h
		
file 'fat.bin'