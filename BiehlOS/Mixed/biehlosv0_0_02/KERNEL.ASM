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
;; kernel.asm
;; Kernel für BiehlOS
;; Aufgaben:
;;			Stelle Dateisystem, Speicherverwaltung und Inbterruptfunktionne bereit
;; 			Lade Shell
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
use16
KERNEL:
	MOV AX, CS
	MOV ES, AX
	MOV DS, AX
	
									;38 Sektoren für Filetable
									;24 Sektoren für Speicherverwaltung
									;12 Sektoren für Cluster
									;08 Sektoren für eigentlichen Kernel
	
	PUSH ES						
	MOV AX, 0H
	MOV ES, AX
	CLI
	MOV WORD [ES:20H*4],INT20H		;Setze INT 20H
	MOV WORD [ES:20H*4+2],CS
	STI
	POP ES
	
	MOV AH, 05H
	LEA DI, [LOAD_SHELL]
	INT 20H
	
	LEA DI, [DAT_SHELL]
	MOV AH, 04H
	INT 20H
	CALL 1A40H:0H
	RETF
	
	DAT_SHELL	DB	"shell.os",0
	LOAD_SHELL	DB	"Lade Shell...",13,10,0
	TEMP	DB	0
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; BiehlOS Interrupt 20h
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	INT20H:
		
		CMP AH, 0H
		JE PR_CH
		CMP AH, 1H
		JE RD_CH
		CMP AH, 2
		JE RD_ONLY_CH
		CMP AH, 3
		JE RD_STR
		CMP AH, 4H
		JE RD_FILE
		CMP AH, 5H
		JE PR_STR
		CMP AH, 6H
		JE CSTR
		CMP AH, 7H
		JE UPTLCASE
		CMP AH, 8H
		JE DELFSP
		CMP AH, 9H
		JE DELBSP
		CMP AH, 0AH
		JE GETPOS
		
	INT20H_END:
		IRET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Int 20H/AH=0H/AL=CHAR
	;; Gib AL auf dem Bildschirm aus
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	PR_CH:
		PUSH AX
		MOV AH, 0EH
		INT 10H
		POP AX
		JMP INT20H_END
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Int 20H/AH=1H
	;; Lese CHAR von Tastatur ein
	;; und gib es aus
	;; Back: AL=CHAR
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	RD_CH:
		MOV AH, 0H
		INT 16H
		MOV AH, 0EH
		INT 10H
		JMP INT20H_END
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; INT 20H/AH=2H
	;; Lese CHAR von Tastatur ein
	;; und gib es NICHT aus
	;; Back: AL=CHAR
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	RD_ONLY_CH:
		MOV AH, 0H
		INT 16H
		JMP INT20H_END
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; INT 20H/AH=3H
	;; Lese String von Tastatur ein
	;; 		ES=Segment(Buffer)
	;;		DI=Offset(Buffer)
	;;		CX=max. Anzahl
	;;	Back:
	;;		CX=Gelesen Zeichen (Anzahl)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	RD_STR:
		PUSH DI
		PUSH BX
		PUSH DX
		PUSH CX
		MOV BX, DI
		
	RDSTR_MAIN_LOOP:
		MOV AH, 0H
		INT 16H
		CMP AL, 08
		JE RDSTR_BACK
		CMP AL, 13
		JE RDSTR_ENTER
		MOV AH, 0EH
		MOV [ES:DI], AL
		INC DI
		INT 10H
		DEC CX
		CMP CX, 0
		JNE RDSTR_MAIN_LOOP
		;LOOP RDSTR_MAIN_LOOP
		JMP RDSTR_ENTER
		
	RDSTR_BACK:
		DEC DI
		CMP BX, DI
		JA RDSTR_NO_BACK
		MOV AH, 0EH
		INT 10H
		MOV AL, " "
		INT 10H
		MOV AL, 8
		INT 10H
		INC CX
		JMP RDSTR_MAIN_LOOP
		;INC CX
		
		;LOOP RDSTR_MAIN_LOOP
		;JMP RDSTR_ENTER
		
	RDSTR_NO_BACK:
		INC DI
		INC CX
		JMP RDSTR_MAIN_LOOP
		;INC CX
		;LOOP RDSTR_MAIN_LOOP
		
	RDSTR_ENTER:
		MOV BYTE [ES:DI], 0
		MOV AX, CX
		POP CX
		SUB CX, AX
		MOV AX, CX
		
		POP DX
		POP BX
		POP DI
		JMP INT20H_END
		
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; INT 20H/AH=4H
	;; Lese Datei
	;;		ES=Segment(Dateiname)
	;;		DI=Offset(Dateiname)
	;; Back:
	;;		AX=0(Fehler: Datei nicht gefunden)
	;;		AX=1(Fehler: Nicht genügend freier Speicher)
	;;		AX=2(Fehler: Unbekant)
	;;		AX>2(Block ID)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	RD_FILE:
		PUSH ES
		PUSH DI
		CALL 1000H:ReadFile
		POP DI
		POP ES
		JMP INT20H_END
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; INT20H/AH=5H
	;; Schreibe String auf Bildschirm
	;; ES=Segment
	;; DI=Offset
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	PR_STR:
		MOV AH, 0EH
		MOV AL, [ES:DI]
		CMP AL, 0
		JE INT20H_END
		INT 10H
		INC DI
		JMP PR_STR
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; INT20H/AH=6H
	;; Vergleiche 2 null-terminierte Strings
	;; (c) 2005-2006 by Josef Biehler
	;; ES:DI String1
	;; DS:SI String2
	;; Back: 
	;;		0=Strings verschieden
	;;		1=Strings gleich
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CSTR:
		PUSH WORD 0
		PUSH SI
		PUSH DI
		PUSH ES
		PUSH DS
		CALL 1000H:CHKSTR
		POP DS
		POP ES
		POP DI
		POP SI
		ADD SP, 2
		JMP INT20H_END
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; INT20H/AH=7H
	;; Verwandle Groß- in Kleinbuchstaben
	;; (c) 2005-2006 by Josef Biehler
	;; ES:DI String
	;; [String muss null-terminiert sein]
	;; [String wird verändert!]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	UPTLCASE:
		PUSH ES
		PUSH DI
		CALL 1000H:UpToLowerCase
		POP DI
		POP ES
		JMP INT20H_END
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; INT290H/AH=8H
	;; Entferne Anfangsleerzeichen
	;; (c) 2005-2006 by Josef Biehler
	;; ES:DI String
	;; [String muss null-terminiert sein]
	;; [String wird verändert!]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DELFSP:
		PUSH ES
		PUSH DI
		CALL 1000H:DelFrontSpace
		POP DI
		POP ES
		JMP INT20H_END
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; INT20H/AH=9H
	;; Entferne Schlußleerzeichzen
	;; ES:DI String
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DELBSP:
		PUSH ES
		PUSH DI
		CALL 1000H:DelBackSpace
		POP DI
		POP ES
		JMP INT20H_END
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; INT20H/AH=0AH
	;; Ermittle Position eines Zeichens
	;; ES:DI String, AL=Zeichen
	;; BACK:
	;;		AX=0(Zeichen nicht vorhanden)
	;;		AX>0(Position)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	GETPOS:
		XOR AH, AH
		PUSH ES
		PUSH DI
		PUSH AX
		CALL 1000H:Pos
		POP DI
		POP DI
		POP ES
		JMP INT20H_END
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Pos
	;; (c) 2005-2006 by Josef Biehler
	;; Ermittle Position eines Zeichens
	;; PUSH SEGMENT
	;; PUSH OFFSET
	;; PUSH ZEICHEN
	;; BACK:
	;;		AX=0 Zeichen nicht gefunden
	;;		AX>0 Position
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	Pos:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSH DS
		PUSH SI
		PUSH BX
		
		MOV AX, [BP]
		ADD BP, 2
		MOV SI, [BP]
		ADD BP, 2
		MOV DS, [BP]
		XOR BX, BX

	POS_LOOP:
		CMP BYTE [DS:SI], AL
		JE POS_OK
		CMP BYTE [DS:SI], 0
		JE POS_END
		INC SI
		INC BX
		JMP POS_LOOP
		
	POS_OK:
		MOV AX, BX
		
	POS_END:
		POP BX
		POP SI
		POP DS
		POP BP
		RETF
		
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; DelBackSpace
	;; (c) 2005-2006 by Josef Biehler
	;; Entferne Schlußleerzeichen
	;; PUSH SEGMENT
	;; PUSH OFFSET
	;; [STRING=null-terminiert]
	;; [String wird verändert!]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DelBackSpace:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSH DS
		PUSH SI
		PUSH BX
		
		MOV SI, [BP]
		ADD BP, 2
		MOV DS, [BP]
		XOR BX, BX
		
		PUSH DS
		PUSH SI
		PUSH BX
		CALL 1000H:Pos					;Ermittle Position von ASCII 0 (=Ende des Stringes)
		POP BX
		POP SI
		POP DS
		
		CMP AX, 0						;nur enter gedrückt
		JE DBS_END
		DEC AX
		
		ADD SI, AX						;SI zeigt auf letztes Zeichen
		
	DBS_LOOP:
		CMP BYTE [DS:SI], " "
		JE DBS_OK
		JMP DBS_END
		
	DBS_TEMP:
		DEC AX
		DEC SI
		CMP AX, 0
		JE DBS_END
		JMP DBS_LOOP
		
	DBS_OK:
		MOV BYTE [DS:SI], 0
		JMP DBS_TEMP
		
	DBS_END:
		POP BX
		POP SI
		POP DS
		POP BP
		RETF
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; DelFrontSpace
	;; (c) 2005-2006 by Josef Biehler
	;; entferne Anfangsleerzeichen eines Stringes
	;; PUSHE SEGMENT
	;; PUSHE OFFSET
	;; [STRING=null-terminiert]
	;; [String wird verändert!]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DelFrontSpace:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSH DS
		PUSH SI
		PUSH BX
		PUSH CX
		
		MOV SI, [BP]
		ADD BP, 2
		MOV DS, [BP]
		SUB BP, 2
		
	DS_MAIN_LOOP_DEL_FRONT:
		MOV BL, [DS:SI]
		CMP BL, 0
		JE DEL_FRONT_END
		CMP BL, " "
		JE DEL_FRONT_OK
		JMP DEL_FRONT_END
		INC SI
		JMP DS_MAIN_LOOP_DEL_FRONT
		
	DEL_FRONT_OK:
		INC SI
		MOV BL, [DS:SI]
		CMP BL, 0
		JE DEL_FRONT_OK_END
		DEC SI
		MOV [DS:SI], BL
		INC SI
		JMP DEL_FRONT_OK
		
	DEL_FRONT_OK_END:
		DEC SI
		MOV BYTE [DS:SI], 0
		MOV SI, [BP]
		JMP DS_MAIN_LOOP_DEL_FRONT
		
	DEL_FRONT_END:
		POP CX
		POP BX
		POP SI
		POP DS
		POP BP
		RETF
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; UpToLowerCase
	;; (c) 2005-2006 by Josef Biehler
	;; Groß- zu Kleinbuchstaben umwandeln
	;; PUSHE SEGMENT
	;; PUSHE OFFSET
	;; [String wird direkt verändert!]
	;; String muss null-terminiert sein!
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	UpToLowerCase:
		PUSH BP
		MOV BP, SP
		PUSH BX
		PUSH CX
		PUSH DS
		PUSH SI
		ADD BP, 6
		MOV SI, [BP]
		ADD BP, 2
		MOV DS, [BP]
		
	UTLC_LOOP:
		MOV BL, [DS:SI]
		CMP BL, 0
		JE UTCL_END
		CMP BL, 65
		JAE UTCL_OK
	UTCL_TEMP:					
		INC SI
		JMP UTLC_LOOP
		
	UTCL_OK:
		CMP BL, 90
		JA UTCL_TEMP
		ADD BYTE [DS:SI], 32
		JMP UTCL_TEMP
		
	UTCL_END:
		POP SI
		POP DS
		POP CX
		POP BX
		POP BP
		RETF
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; ReadFile
	;; Lese eine Datei an einen zugewiesenen Speicher
	;; PUSHE SEGMENT_DATEI_NAME
	;; PUSHE OFFSET_DATEI_NAME
	;; Back:
	;;		AX=0(Fehler: Datei nicht gefunden)
	;;		AX=1(Fehler: Nicht genügend freier Speicher)
	;;		AX=2(Fehler: Unbekannt)
	;;		AX>2(Block ID [Handle])
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ReadFile:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSH DS
		PUSH SI
		PUSH BX
		PUSH CX
		PUSH ES
		PUSH DI
		MOV AX, [BP]
		MOV DI, AX
		ADD BP, 2
		MOV AX, [BP]
		MOV ES, AX					;ES:DI=Dateiname
		CALL 1000H:ReadFileName
		CMP AX, 0FFFFH
		JE RF_FAILED
		PUSH AX
		CALL 1000H:GetFileSize
		POP BX						;BX=Clusternummer
		
		;MOV CX, 1000H
		;MOV DS, CX
		;LEA SI, [CLUSTER]
									;Berechnung, um den Poinbter auf den richtigen Cluster zu bringen
		;PUSH BX
		;PUSH AX						;AX wird später noch benötigt
		;XOR DX, DX
		;MOV AX, BX					;AX=Clusternummer
		;MOV BX, 4
		;MUL BX
		;ADD SI, AX					;SI zeigt auf richtigen Cluster
		;POP AX
		;POP BX
									;AX=Anzahl benötigter Speicherblocks
		PUSH AX
		CALL 1000H:GetFreeMem
		POP CX
		
		CMP AX, 0
		JE RF_FAILED_NO_FREE_MEM	;AX=0:=Nicht genügend Speichrblocks
		
		;BX=Clusternummer
		;AX=Block ID
		MOV GS, AX					;Block ID sichern
	RF_MAIN_LOOP:
		MOV CX, 1000H
		MOV DS, CX
		LEA SI, [CLUSTER]
		PUSH BX
		PUSH AX						;AX wird später noch benötigt
		XOR DX, DX
		MOV AX, BX					;AX=Clusternummer
		MOV BX, 4
		MUL BX
		ADD SI, AX					;SI zeigt auf richtigen Cluster
		POP AX
		POP BX
		
		PUSH BX
		PUSH AX
		CALL 1000H:ReadCluster
		POP AX
		POP BX
		
		ADD SI, 2
		CMP WORD [DS:SI], 0FFFFH
		JE RF_ML_OK					;letzter Cluster gewesen
		
		INC AX
		MOV BX, [DS:SI]
		JMP RF_MAIN_LOOP
		
	RF_ML_OK:
		MOV AX, GS					;Block ID zurückholen
		JMP RF_END
		
		RF_FAILED:

		RF_FAILED_NO_FREE_MEM:
	RF_END:
	
		POP DI
		POP ES
		POP CX
		POP BX
		POP SI
		POP DS
		POP BP
		RETF

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; ReadFileName
	;; Suche Dateinamen in FILETABLE
	;; ES:DI=Dateiname
	;; Back: AX=0FFFFH (Nicht gefunden)
	;;		 AX>0 (Clusternummer)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ReadFileName:
		PUSH DS
		PUSH SI
		PUSH BX
		PUSH CX
		
		MOV AX, 1000H
		MOV DS, AX
		LEA SI, [FILETABLE]
		MOV CX, 1440
		
	RFN_LOOP:
		PUSH WORD 0
		PUSH SI
		PUSH DI
		PUSH ES
		PUSH DS
		CALL 1000H:CHKSTR
		POP DS
		POP ES
		POP DI
		POP SI
		ADD SP, 2
		CMP AX, 1
		JE RFN_OK
		ADD SI, 13
		LOOP RFN_LOOP
		MOV AX, 0ffffh
		JMP RFN_END
		
	RFN_OK:
		ADD SI, 11
		MOV AX, [SI]
		JMP RFN_END
		
	RFN_END:
		POP CX
		POP BX
		POP SI
		POP DI
		RETF

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
		RETF		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; GetFileSize
	;; Ermittle die benötigte Anzahl an Speicherblocks
	;; (Ein Speicherblock == 1 Cluster == 2 Sektoren
	;; PUSHE Ersten Cluster
	;; AX=0 (Fehler), AX > 0 (Anzahl Speicherblocks)
	;; DS:SI = 1000H:CLUSTER
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	GetFileSize:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSH SI
		PUSH DI
		PUSH DS
		PUSH CX
		PUSH BX
		PUSH DX
		
		MOV BX, [BP]
		MOV AX, 1000H
		MOV DS, AX
		LEA SI, [CLUSTER]
		;DEC BX
		MOV AX,4
		XOR DX, DX
		MUL BX
		ADD SI, AX					;SI zeigt auf den ersten benötigten Cluster 
		XOR BX, BX
		MOV CX, 1440				;maximale Anzahl an möglichen Clustern
		
	GFS_MAIN_LOOP:
		INC BX						;BX zeigt die Anzahl an Clustern an
		ADD SI, 2					;SI zeigt auf das WORD, das den nächsten Cluster anzeigt
		MOV AX, [SI]
		CMP AX, 0FFFFH				;0FFFFH = letzter Cluster
		JE GFS_ML_OK
		PUSH BX						;Sichere BX für die Berechnung
		MOV BX, AX
		MOV AX, 4
		XOR DX, DX					;DX auf 0 setzen, ansonsten gegebenfalls falsche Ergebnisse
		MUL BX
		LEA SI, [CLUSTER]
		ADD SI, AX					;SI zeigt auf den nächsten benötigten Cluster
		POP BX						
		LOOP GFS_MAIN_LOOP
		MOV AX, 0
		JMP GFS_END
		
	GFS_ML_OK:
		MOV AX, BX
		
	GFS_END:
		POP DX
		POP BX
		POP CX
		POP DS
		POP DI
		POP SI
		POP BP
		RETF
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; ReadCluster
	;; Lese EINEN Cluster in Speicher
	;; PUSHE Clusternummer
	;; PUSHE Memory Block ID
	;; Back:
	;;		 AX=0 (Fehler)
	;; 		 AX>0 ("handle" == Block ID)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ReadCluster:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSH DS
		PUSH SI
		PUSH ES
		PUSH DI
		PUSH DX
		PUSH CX
		PUSH BX
		
		MOV AX, 1000H
		MOV ES, AX
		LEA DI, [CLUSTER]
		
		MOV CX, [BP]
		ADD BP, 2
		MOV BX, [BP]			;Clusternummer
		
		XOR DX, DX
		MOV AX, 4
		MUL BX	
		
		ADD DI, AX				;DI zeigt auf entsprechenden Cluster
		
		PUSH CX
		CALL 1000H:SetFreeMem
		POP CX				

		PUSH CX
		PUSH WORD 1
		CALL 1000H:GetMemData
		POP CX
		POP CX
		
		MOV BX, AX				;Segment Adresse sichern
		
		PUSH CX
		PUSH WORD 2
		CALL 1000H:GetMemData
		POP CX
		POP CX
		
		CMP CX, 1440
		JA RDC_FAILED				;ungültige Block ID
		
		PUSH CX						;Block ID für später sichern
		
		MOV CX, [ES:DI]				;CX=Sektornummer
		MOV FS, CX					;Sichere CX in Register FS
		
		MOV ES, BX					;Vorbereitung auf INT 13H
		;MOV BX, AX
		PUSH AX
		


		PUSH CX
		CALL 1000H:LBA_CHS
		POP CX
		MOV CL,AH
		MOV CH,AL
		MOV AH,02H
		MOV DH,BH
		MOV DL,0
		MOV AL,1
		POP BX	
					;Zuvor gepushte Offsetadresse zurückholen
		INT 13H
		ADD BX, 512
		PUSH BX
		
		MOV CX, FS
		INC CX					;Wähle nächsten Sektor an
		
		PUSH CX
		CALL 1000H:LBA_CHS
		POP CX
		MOV CL,AH
		MOV CH,AL
		MOV AH,02H
		MOV DH,BH
		MOV DL,0
		MOV AL,1
		POP BX					;Zuvor gepushte Offsetadresse zurückholen
		INT 13H
		
		
		POP AX					;gesicherte Block ID zurückgeben
		JMP RDC_END
		
	RDC_FAILED:
		MOV AX, 0				;AX=0: Fehler
		
	RDC_END:
		POP BX
		POP CX
		POP DX
		POP DI
		POP ES
		POP SI
		POP DS
		POP BP
		RETF
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; GetMemData
	;; Ermittelt die Daten eines Speicherblockes
	;; PUSHE Block ID
	;; PUSHE {0|1|2}
	;;	0=Gib Speicher Block Status Word zurück
	;;	1=Gib Speicher Block Segment Adresse zurück
	;;	2=Gib Speicher Block Offset Aresse zurück
	;; Back:
	;;	AX=0(Fehler)
	;;	AX>0(gewünschter Rückgabewert)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	GetMemData:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSH DS
		PUSH SI
		PUSH BX
		PUSH CX

		MOV AX, 1000H
		MOV DS, AX
		LEA SI, [MEMORY]
	
		MOV CX, [BP]			;CX={0|1|2}
		ADD BP, 2
	
		MOV AX, 8
		XOR DX, DX
		MOV BX, [BP]
		CMP BX, 1440
		;JA GMD_FAILED			;Block ID größer als 1440 geht nicht
		MUL BX
		
		ADD SI, AX			;SI zeigt auf Speicher Block

		CMP CX, 1
		JE GMD_SEGMENT
		JA GMD_OFFSET
		JB GMD_STATUS

	GMD_OFFSET:
		ADD SI, 2			;SI zeigt auf Offset
		MOV AX, [SI]
		JMP GMD_END
		
	GMD_SEGMENT:
		ADD SI, 4
		MOV AX, [SI]
		JMP GMD_END
		
	GMD_STATUS:
		ADD SI, 6
		MOV AX, [SI]
	
	GMD_END:
		POP CX
		POP BX
		POP SI
		POP DS
		POP BP
		RETF
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; SetFreeMem
	;; Reserviere einen Speicherblock
	;; PUSHE Block ID
	;; Back:
	;;		AX=0(Fehler:Block nicht frei)
	;;		AX=1(Fehler:Block nicht vorhanden)
	;;		AX=2(OK)	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SetFreeMem:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSH DS
		PUSH SI
		PUSH DX
		PUSH BX
		
		MOV AX, 1000H
		MOV DS, AX
		LEA SI, [MEMORY]
		MOV AX, [BP]
		CMP AX, 1440
		JA SFM_TOO_BIG
		CMP AX, 0
		JB SFM_TOO_LOW
		XOR DX, DX
		MOV BX, 8
		MUL BX
		ADD AX, 6
		ADD SI, AX
		MOV [DS:SI], WORD 1000000000000000b		;setze Bit 0 (Speicher besetzt)
		MOV AX, 2
		JMP SFM_END
		
	SFM_TOO_LOW:
	SFM_TOO_BIG:
		MOV AX, 1
		
	SFM_END:
		POP BX
		POP DX
		POP SI
		POP DS
		POP BP
		RETF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; GetFreeMem
	;; Suche einen freien Speicherblock
	;; PUSH Anzahl an benötigten Speicherblöcken
	;; Back: AX=0 (Nicht genügend freier Speicher)
	;;		 AX>0 (Block ID)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	GetFreeMem:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSH ES
		PUSH DS
		PUSH SI
		PUSH DI
		PUSH CX
		PUSH BX
		
		MOV BX, [BP]
		
		MOV AX, 1000H
		MOV DS, AX
		LEA SI, [MEMORY]
		MOV CX, 1440
		
	GFM_LOOP:
		ADD SI, 6
		MOV Ax, [DS:SI]
		CMP AX, 0
		JE GFM_LOOP_OK
		MOV AX, [BP]
		CMP BX, AX
		;JB GFM_FAILED
		JE GFM_TEMP_OK
		MOV BX, AX
	GFM_TEMP_OK:
		ADD SI, 2
		LOOP GFM_LOOP
	GFM_FAILED:
		MOV AX, 0
		JMP GFM_END
		
	GFM_LOOP_OK:
		DEC BX
		CMP BX, 0
		JE GFM_FINAL_OK
		
		ADD SI, 2
		LOOP GFM_LOOP
		MOV AX, 0
		JMP GFM_END
		
	GFM_FINAL_OK:
		MOV AX, [BP]
		DEC CX
		ADD CX, AX
		MOV AX, 1440
		SUB AX, CX
		JMP GFM_END
		
	GFM_END:
		POP BX
		POP CX
		POP DI
		POP SI
		POP DS
		POP ES
		POP BP
		RETF
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; CHKSTR: Vergleiche 2 Strings miteinander, bis BEGRENZUNGSZEICHEN ;;
		;; Parameter:	Pushe Zeichen, Quelle2 und Quelle1					;;
		;; 				PUSHE SEGMENT:QUELLE1,SEGMENT:QUELLE2				;;
		;; Rückgabe:	AX=1 Strings OK / AX=0 Strings falsch				;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		CHKSTR:
			PUSH BP
			MOV BP,SP
			PUSH ES
			PUSH DS
			PUSH DI
			PUSH SI
			PUSH BX
			PUSH CX
			PUSH DX
			ADD BP,6
			MOV ES,[BP]
			ADD BP,2
			MOV DS,[BP]
			ADD BP,2
			MOV SI,[BP]
			ADD BP,2
			MOV DI,[BP]
			ADD BP,2
			MOV CX,[BP]
			XOR DX,DX
			
		CHSTR:
			MOV BL,[ES:DI]
			MOV BH,[DS:SI]
			MOV AX,0
			CMP BH,CL
			JE CHSTR_C
			CMP BL,CL
			JE CHSTR_C
			CMP BH,BL
			JNE CHSTR_END
			INC SI
			INC DI
			JMP CHSTR
			
		CHSTR_C:	
			MOV AX,1
			CMP BH,BL
			JE CHSTR_END
			MOV AX,0
		CHSTR_END:
			POP DX
			POP CX
			POP BX
			POP SI
			POP DI
			POP DS
			POP ES
			POP BP
		RETF
		
	DB 8*512-($-KERNEL) DUP(0)
	
FILETABLE:
				;Muster:
				;FILENAME 	DB 	"1234567890",0
				;CLUSTER	DW	1
	DB 	"shell.os",0,0,0
	DW	0
	DB  "asd",0,0,0,0,0,0,0,0
	DW 2
	
	DB 38*512-($-FILETABLE) DUP(0)
	
CLUSTER:
				;Muster:
				;SEKTOR_NR	DW	123
				;NEXT_CLUSTER DW 0 (0=Freier Cluster, 0FFFFH=letzter Cluster, 0FFFEH=kaputter Cluster)
	
	DW	83		;Cluster 0
	DW	01H	
	
	DW 85		;Cluster 1
	DW 0FFFFH	
	
	DW 87
	DW 0FFFFH
				
	DB 12*512-($-CLUSTER) DUP(0)
	

MEMORY:
				;Muster:
				;FILETABLE_NR	DW	2
				;OFFSET			DW
				;SEGMENT		DW
				;STATUS_WORD	DW	0 (z.b. TSR,....) 1000000000000000 Bit 1 gesetzt=Belegt
				
	DW 0
	DW 0H
	DW 1000H
	DW 1000000000000000b
	
	DW 0
	DW 0A400H
	DW 1000H
	DW 0
	
	DW 0
	DW 0A800H
	DW 1000H
	DW 0
	
	DW 0
	DW 0AC00H
	DW 1000H
	DW 0
	

	
	DB 24*512-($-MEMORY) DUP(0)

SHELL:
	FILE 'SHELL.BIN'

	