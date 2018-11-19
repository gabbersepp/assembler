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
;;			Stelle Dateisystem, Speicherverwaltung und Interruptfunktionen bereit
;; 			Lade Shell
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
use16
		MOV AX, CS
		MOV DS, AX
		MOV ES, AX
		;MOV KERNEL_SEG,[AX]
		
		LEA DI, [HELLO_STRING]
	PR:
		MOV AH, 0EH
		MOV AL, [ES:DI]
		CMP AL, 0
		JE PR_END
		INT 10H
		INC DI
		JMP PR
		
	PR_END:
	
		MOV AX, 0H
		MOV ES, AX
		CLI
		MOV AX, 9000H
		MOV SP, 0H
		MOV SS, AX
		MOV WORD [ES:20H*4],INT20H		;Setze INT 20H
		MOV WORD [ES:20H*4+2],CS
		STI

		MOV AX, CS
		MOV ES, AX
		
		PUSH CS
		PUSH SHELL
		CALL 1460H:GetFileSize
		ADD SP, 4
		
		CMP AX, 2
		JAE FILE_OK
		
			PUSH CS
			PUSH SHELL_NOT_FOUND
			CALL 1460H:PrintStr
			ADD SP, 4
			
			JMP $
		
		FILE_OK:
			
		XOR DX, DX
		MOV BX, 16
		DIV BX
		INC AX						;Block Anzahl berechnen
		
		;mov cx, 100
		;mov ax, 3
		;klo:
		;mov ax, 0fh
		PUSH AX
		CALL 1460H:GetFreeMem
		ADD SP, 2

		;mov ah, 0eh
		;add al, 48
		;int 10h
		;mov al, " "
		;int 10h
		;loop klo
		;mov ah, 0eh
		;mov al, "j"
		;int 10h
		;jmp $
		;;;;;;
		;PUSH CS
		;PUSH WORD SHELL_NOT_FOUND
		;PUSH WORD "e"
		;CALL 1460H:Explode
		;ADD SP, 6

		;MOV ES, AX
		;MOV DI, 2
		;MOV AX, [ES:DI]
		;ADD DI, 2
		
		;MOV DS, AX
		;MOV SI, 0
		;MOV AH, 05H
		;INT 20H
		;jmp $
		PUSH AX
		PUSH WORD 0H
		PUSH CS
		PUSH WORD SHELL
		CALL 1460H:LoadFile
		POP AX
		POP AX
		POP AX
		POP AX

		MOV [CS:SHELL_JMP+3], AX
		NOP
		NOP
		NOP
		NOP
		NOP
		SHELL_JMP: CALL 2000H:0H
		
		JMP $
		
		MOV BX, AX
		MOV AH, 0eH
		mov al, "j"
		int 10h
		call 1500H:0h
		JMP $
		PUSH CS
		PUSH SHELL
		CALL 1460H:GetFileSize
		jmp $
		PUSH WORD 2000
		CALL 1460H:GetFreeMem
		ADD SP, 2
		MOV BX, AX
		CALL 1460H:GetLastError
		
		JMP $
		
		MEM_START		EQU	((14600H+KERNEL_END)/10H)+10H ;hier fängt der nutzbare Speicher an, ab hier Verwaltung aktiv
		SHELL			DB	"SHELL   EXC"
		SHELL_NOT_FOUND	DB	"Die SHELL.EXC wurde nicht gefunden.",13,10,"Der PC kann jetzt ausgeschalten werden.",13,10,0
		
		HELLO_STRING	DB	"Kernel geladen",13,10,0
		LastError		DW	0
		
		BUFF_512		DB	512 DUP(0)
		FILESIZE		DD	0
		TEMP			DW	0
		DIR_OFF			DW	2*9*512				;Offset des aktuellen Verzeichnisses
		DIR_SEG			DW	1000H				;Segmentadresse des aktuellen verzeichnisses
		DIR_COUNT		DW	224					;Anzahl an Einträgen im aktuellen Verzeichnis
		NEXT_CLST		DW	0
		
		FN_TEMP			DW	0
		CHS_STRUCT:
						DB	3
			C			DB	0
			H			DB	0
			S			DB	0
		
		FILE_STRUCT:
							DB	29
			DIR_NAME		DB	11 DUP(0)
			DIR_ATTR		DB 	0
			DIR_M_TIME		DB 	0
			DIR_TIME		DW	0
			DIR_DATE		DW	0
			DIR_FOUND		DW	0
			DIR_CHG_TIME	DW	0
			DIR_CHG_DATE	DW	0
			DIR_FIRST_CLST	DW	0
			DIR_FILE_SIZE	DD	0
			
			
	INT20H:
		;PUSH DS
		PUSH ES
		PUSH SI
		PUSH DI
		PUSH AX
		MOV AX, CS
		MOV ES, AX
		;MOV DS, AX
		POP AX
		
		MOV DI, INT20H_LIST
		
		I20H_CHECK:
			CMP BYTE [ES:DI], 0FFH
			JE I20H_FAILED
			
			CMP AH, [ES:DI]
			JE I20H_OK
			INC DI
			INC DI
			INC DI
			JMP I20H_CHECK
			
		I20H_OK:
			INC DI
			CALL WORD [ES:DI]
			JMP I20_END
			
		I20H_FAILED:
			MOV [ES:LastError], 05H
			JMP I20_END
			
		INT20H_LIST:
		
		DB 00H
		DW I20H_GetLastError
		
		DB 01H
		DW I20H_GetFATEntry
		
		DB 02H
		DW I20H_LBAToCHS
		
		DB 03H
		DW I20H_ReadFileName
		
		DB 04H
		DW I20H_GetFileSize
		
		DB 05H
		DW I20H_PrintStr
		
		DB 06H
		DW I20H_ReadStr
		
		DB 07H
		DW I20H_LowToUpperCase
		
		DB 08H
		DW I20H_Pos
		
		DB 09H
		DW I20H_Explode
		
		DB 0AH
		DW I20H_ExplFree
		
		DB 0BH
		DW I20H_DelFrontSpace
		
		DB 0CH
		DW I20H_CheckStr
		
		DB 0DH
		DW I20H_GetDirAddr
		
		DB 0EH
		DW I20H_GetFreeMem
		
		DB 0FH
		DW I20H_SetMemFree
		
		DB 10H
		DW I20H_LoadFile
		
		DB 0FFH
		
	I20_END:
		POP DI
		POP SI
		POP ES
		;POP DS
		IRET
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Parameter: /					;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	I20H_GetLastError:
		CALL 1460H:GetLastError
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Parameter: BX = FAT Eintrag	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	I20H_GetFATEntry:
		PUSH BX
		CALL 1460H:GetFATEntry
		POP BX
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Parameter: BX = LBA			;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	I20H_LBAToCHS:
		PUSH BX
		CALL 1460H:LBAToCHS
		POP BX
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Parameter: DS = Segment (dateiname)		;;
	;; 			  SI = Offset (dateiname)		;;
	;; Rückgabe: (E)AX = Seg:Off 8FILE_STRUCT	;;
	;;			(E)AX < 2 Fehler				;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	I20H_ReadFileName:
		PUSH DS
		PUSH SI
		CALL 1460H:ReadFileName
		POP SI
		POP DS
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Parameter: DS = Segment (Dateiname)			;;
	;; 			  SI = Offset (Dateiname)			;;
	;; Rückgabe: EAX >= 2 (Dateigröße)				;;
	;;			 EAX < 2 evtl Fehler (wenn GLE = 0) ;;
	;;					kein Fehler					;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	I20H_GetFileSize:
		PUSH DS
		PUSH SI
		CALL 1460H:GetFileSize
		POP SI
		POP DS
		RET

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Parameter: DS = Segment							;;
	;; 			  SI = Offset							;;
	;; DS:SI Pointer auf nullterminierten String		;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	I20H_PrintStr:
		PUSH DS
		PUSH SI
		CALL 1460H:PrintStr
		POP SI
		POP DS
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; ReadChar	PROTO									;;
	;; Liest ein Zeichen ein							;;
	;; Rückgabe: EAX = Char								;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ReadChar:
		MOV AX, 0
		INT 16H
		XOR AH, AH
		RETF
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Parameter: DS:SI = Buffer						;;
	;;			  CX = nMaxCount						;;
	;; Rückgabe:										;;
	;;			EAX = Anzahl eingelesener Zeichen		;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	I20H_ReadStr:
		PUSH DS
		PUSH SI
		PUSH CX
		CALL 1460H:ReadStr
		POP CX
		POP SI
		POP DS
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Parameter: DS:SI String 							;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	I20H_LowToUpperCase:
		PUSH DS
		PUSH SI
		CALL 1460H:LowToUpperCase
		POP SI
		POP DS
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Parameter: DS:SI String							;;
	;;			  AL = Zeichen							;;
	;; Rückgabe: EAX < 2 (Fehler oder Pos an 0|1)		;;
	;;			 EAX >= 2 position						;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	I20H_Pos:
		PUSH DS
		PUSH SI
		PUSH AX
		CALL 1460H:Pos
		POP AX
		POP SI
		POP DS
		RET
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Parameter: DS:SI String							;;
	;; 			  BL = Zeichen							;;
	;; RÜckgabe:	EAX > 2 (Segmentadresse von Array)	;;
	;;				EAX < 2 (Fehler: Kein freier Spchr)	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	I20H_Explode:
		PUSH DS
		PUSH SI
		PUSH BX
		CALL 1460H:Explode
		POP BX
		POP SI
		POP DS
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Parameter: BX = Segment							;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	I20H_ExplFree:
		PUSH BX
		CALL 1460H:ExplFree
		POP BX
		RET
		

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Parameter: DS:SI = String						;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	I20H_DelFrontSpace:
		PUSH DS
		PUSH SI
		CALL 1460H:DelFrontSpace
		POP SI
		POP DS
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Parameter: DS:SI String1, ES:DI String2,BX=nCount;;
	;; RÜckgabe: AX = 0 (String nicht gleich)			;;
	;;			 AX = 2 (String gleich)					;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	I20H_CheckStr:
		PUSH SI
		PUSH DI
		PUSH DS
		PUSH ES
		PUSH BX
		CALL 1460H:CheckStr
		POP BX
		POP ES
		POP DS
		POP DI
		POP SI
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Parameter: DS:SI DIR_INFO_STRUCT					;;
	;; R+ückgabe: /										;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	I20H_GetDirAddr:
		PUSH DS
		PUSH SI
		CALL 1460H:GetDirAddr
		POP SI
		POP DS
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Parameter: BX = nBlockCount						;;
	;; RÜckgabe: EAX < 2 (fehler)						;;
	;;			 EAX > 2 (Segmentadresse)				;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	I20H_GetFreeMem:
		PUSH BX
		CALL 1460H:GetFreeMem
		POP BX
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Parameter: BX = Segment							;;
	;; RÜckgabe: EAX < 2 (fehler)						;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	I20H_SetMemFree:
		PUSH BX
		CALL 1460H:SetMemFree
		POP BX
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Parameter: DS:SI Dateiname, DX:CX Speicher		;;
	;; Rückgabe: EAX < 2 (fehler)						;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	I20H_LoadFile:
		PUSH DX
		PUSH CX
		PUSH DS
		PUSH SI
		CALL 1460H:LoadFile
		POP SI
		POP DS
		POP CX
		POP DX
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; GetDirAddr PROTO Seg:WORD, Off:WORD				;;
	;; Füllt eine DIR_INFO_STRUCT						;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	GetDirAddr:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSH DS
		PUSH ES
		PUSH DI
		PUSH SI
		MOV AX, CS
		MOV ES, AX
		
		MOV SI, [SS:BP]
		ADD BP, 2
		MOV AX, [SS:BP]
		MOV DS, AX
		MOV DI, DIR_SEG
		MOV AX, [ES:DI]
		MOV [DS:SI], AX
		ADD SI, 2
		;SHL EAX, 16
		MOV DI, DIR_OFF
		MOV AX, [ES:DI]
		MOV [DS:SI], AX
		ADD SI, 2
		MOV DI, DIR_COUNT
		MOV AX, [ES:DI]
		MOV [DS:SI], AX
		POP SI
		POP DI
		POP ES
		POP DS
		POP BP
	RETF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; DelFrontSpace PROTO Seg:WORD, Off:WORD			;;
	;; Entferne Leerzeichen am Anfang					;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; ExplFree PROTO Seg:WORD							;;
	;; Rückgabe: /										;;
	;; Löst ein von E§xplode erzeugtes Array wieder auf	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ExplFree:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSHA
		MOV AX, [SS:BP]
		MOV DS, AX
		MOV SI, 0

		PUSH ES
		PUSH DI
		MOV DI, 0

		ExplLoop:
			MOV AX, [DS:SI]
			CMP AX, 0FFFFH
			JE ExplLoopEnd
			PUSHA
			PUSH AX
			CALL 1460H:SetMemFree
			ADD SP, 2
			POPA
			ADD SI, 2
			JMP ExplLoop
		ExplLoopEnd:
		
		PUSH DS
		CALL 1460H:SetMemFree
		POP DS
		POP DI
		POP ES
		POPA
		POP BP
	RETF
			
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Explode PROTO Seg:WORD, Off:WORD, nChar:WORD		;;
	;; Rückgabe:	EAX = Segment von Array				;;
	;;			    EAX < 2 (Fehler)					;;
	;; Teilt einen String nach einem definiertem Zeichen;;
	;; Array: wenn letztes Element = 0FFFFH, Array aus	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	Explode:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSHA
		PUSH DS
		PUSH ES
		MOV BX, [SS:BP]
		ADD BP, 2
		MOV SI, [SS:BP]
		ADD BP, 2
		MOV AX, [SS:BP]
		MOV DS, AX
		
		XOR CX, CX
		EX_SEARCH_CHAR:				;Suche wie oft der String geteilt werden muss
			
			CMP BYTE [DS:SI], 0
			JE EX_S_END
			CMP BYTE [DS:SI], BL
			JE EX_S_OK

			INC SI
			JMP EX_SEARCH_CHAR
			
		EX_S_OK:
			INC CX
			INC SI
			JMP EX_SEARCH_CHAR
			
		EX_S_END:
				
			XOR DX, DX
			MOV AX, 2
			MUL CX
			XOR DX, DX
			MOV CX, 16
			DIV CX
			INC AX
			
			PUSH AX
			CALL 1460H:GetFreeMem
			ADD SP, 2
			
			CMP AX, 2
			JB EX_NO_MEM
			
			MOV ES, AX
			MOV DI, 0
			SUB BP, 2
			MOV SI, [SS:BP]
			
		EX_MAIN:
			PUSH ES
			PUSH DS
			PUSH SI
			PUSH BX
			CALL 1460H:Pos
			POP BX
			POP SI
			POP DS
			POP ES
			
			PUSH AX
			MOV CX, 16
			XOR DX, DX
			DIV CX
			INC AX
			MOV CX, AX
			POP AX
			
			MOV DX, AX
			
			PUSH ES
			PUSH CX
			CALL 1460H:GetFreeMem
			ADD SP, 2
			POP ES
			
			CMP AX, 2
			JB EX_NO_MEM
			
			;ADD SI, DX
			PUSH AX
			PUSH ES
			PUSH DI
			MOV ES, AX
			MOV DI, 0
			MOV CX, DX
			EX_WRITE:
				MOV AL, [DS:SI]
				INC SI
				MOV [ES:DI], AL
				INC DI
				LOOP EX_WRITE
			POP DI
			POP ES
			POP AX
			
			MOV [ES:DI], AX
			ADD DI, 2
			
			;ADD SI, DX
			INC SI
			
			CMP BYTE [DS:SI], 0
			JE EX_MAIN_END
			
			JMP EX_MAIN
			
			EX_NO_MEM:
				POP ES
				POP DS
				POPA
				POP BP
				MOV EAX, 1
				PUSH WORD 0FFFFH
				CALL 1460H:SetLastError
				ADD SP, 2
				RETF
			EX_MAIN_END:
				MOV WORD [ES:DI], 0FFFFH
				MOV AX, ES
		
				MOV [CS:FN_TEMP], AX
				POP ES
				POP DS
				POPA
				POP BP
				MOV AX, [CS:FN_TEMP]
			
			RETF
			
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Pos PROTO Seg:WOIRD, Off:WORD, nChar:WORD		;;
	;; Sucht ein zeichen nChar in einem String			;;
	;; Rückgabe: EAX < 2 (Fehler oder Pos an 0|1)		;;
	;;			 EAX >= 2 position						;;
	;; Neu: keine fehlerrückgabe						;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	Pos:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSHA
		PUSH DS
		PUSH ES
		MOV BX, [SS:BP]
		ADD BP, 2
		MOV SI, [SS:BP]
		ADD BP, 2
		MOV AX, [SS:BP]
		MOV DS, AX
		XOR AX, AX
		P_LOOP:
			CMP BYTE [DS:SI], 0
			JE P_END
			CMP BYTE [DS:SI], BL
			JE P_OK
			INC SI
			INC AX
			JMP P_LOOP
		
		P_END:
			;MOV EAX, 1	
		P_OK:
			MOV [CS:FN_TEMP], AX
			POP ES
			POP DS
			POPA
			MOV AX, [CS:FN_TEMP]
			POP BP
		RETF
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; LowToUpperCase PROTO Seg:WORD, Off:WORD			;;
	;; Verändert in einem String die Klein- zu Groß		;;
	;; buchstaben										;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LowToUpperCase:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSHA
		PUSH DS
		PUSH ES
		
		MOV SI, [SS:BP]
		ADD BP, 2
		MOV AX, [SS:BP]
		MOV DS, AX
		
		LTUC_LOOP:
			
			CMP BYTE [DS:SI], 0
			JE LTUC_END
			CMP BYTE [DS:SI], 97
			JB LTUC_NO
			CMP BYTE [DS:SI], 122
			JA LTUC_NO
			
			SUB BYTE [DS:SI], 32
			INC SI
			JMP LTUC_LOOP
			
		LTUC_NO:
			INC SI
			JMP LTUC_LOOP
			
		LTUC_END:
			POP ES
			POP DS
			POPA
			POP BP
			RETF
			
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; ReadStr PROTO Seg:WORD, Off:WORD, nMaxCount:WORD	;;
	;; Liest String ein, maximal nMaxCount Zeichen		;;
	;; Fügt 0 automatisch an							;;
	;; Rückgabe:										;;
	;;         EAX = Eingelesene Zeichen (ohne ENTER)	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ReadStr:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSHA
		PUSH DS
		PUSH ES
		DEC BYTE [SS:BP]
		MOV CX, [SS:BP]
		ADD BP, 2
		MOV SI, [SS:BP]
		ADD BP, 2
		MOV AX, [SS:BP]
		MOV DS, AX
		SUB BP, 2
		
		
	RDS_LOOP:
		CALL 1460H:ReadChar
		CMP AL, 08H
		JE RDS_BACK
		CMP AL, 13
		JE RDS_ENTER
		MOV [DS:SI], AL
		INC SI
		MOV AH, 0EH
		INT 10H
		LOOP RDS_LOOP
		JMP RDS_END
		
	RDS_BACK:
		CMP SI, [SS:BP]
		JE RDS_NO_BACK
		DEC SI
		MOV BYTE [DS:SI], 0H
		MOV AH, 0EH
		INT 10H
		MOV AL, " "
		INT 10H
		MOV AL, 8
		INT 10H
		LOOP RDS_LOOP
		
	RDS_NO_BACK:
		LOOP RDS_LOOP
		
	RDS_ENTER:
	RDS_END:
		
		MOV BYTE [DS:SI], 0
		SUB BP, 2
		MOV AX, [SS:BP]
		SUB AX, CX
		MOV BYTE [DS:SI], 0
		MOV [CS:FN_TEMP], AX
		
		POP ES
		POP DS
		POPA
		MOV AX, [CS:FN_TEMP]
		POP BP
		RETF
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; PrintStr PROTO Seg:WORD, Off:WORD				;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	PrintStr:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSHA
		PUSH DS
		PUSH ES
		MOV DI, [BP]
		ADD BP, 2
		MOV AX, [BP]
		MOV ES, AX
	PRs:
		MOV AH, 0EH
		MOV AL, [ES:DI]
		CMP AL, 0
		JE PRs_END
		INT 10H
		INC DI
		JMP PRs
		
	PRs_END:
		POP ES
		POP DS
		POPA
		POP BP
		RETF
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; SetMemFree PROTO Segment:WORD					;;
	;; RÜckgabe: EAX < 2 Fehler							;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SetMemFree:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSHA
		PUSH DS
		PUSH ES
		MOV AX, [SS:BP]
		DEC AX
		MOV DS, AX
		MOV SI, 4
		
		;XOR DX, DX
		MOV AX, [DS:SI]			;Blockanzahl
		INC AX
		;MOV BX, 16
		;MUL BX
		
		MOV BX, DS
		ADD BX, AX
		MOV DS, BX
		MOV SI, 0
		
		CMP WORD [DS:SI], 0
		JE SMF_0
		CMP WORD [DS:SI], 1
		JE SMF_1
		CMP WORD [DS:SI], 2
		JE SMF_2
		
		POP ES
		POP DS
		POPA
		MOV AX, 1
		PUSH WORD 08H
		CALL 1460H:SetLastError
		ADD SP, 2
		JMP SMF_END
		
	SMF_0:
		MOV AX, [SS:BP]
		DEC AX
		MOV DS, AX
		MOV SI, 0
		MOV WORD [DS:SI], 0H
		POP ES
		POP DS
		POPA
		MOV AX, 23
		JMP SMF_END
		
	SMF_1:
		MOV AX, [SS:BP]
		DEC AX
		MOV DS, AX
		MOV SI, 0
		MOV WORD [DS:SI], 2H
		POP ES
		POP DS
		POPA
		MOV AX, 23
		JMP SMF_END
				
	SMF_2:
		ADD SI, 4
		MOV BX, [DS:SI]
		MOV AX, [SS:BP]
		DEC AX
		MOV DS, AX
		MOV SI, 0
		MOV WORD [DS:SI], 2H
		ADD SI, 4
		MOV AX, [DS:SI]
		ADD AX, BX
		MOV [DS:SI], AX
		POP ES
		POP DS
		POPA
		MOV AX, 23
		JMP SMF_END
		
	SMF_END:
		POP BP
		RETF
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; CopyBuffer PROTO segQuelle:WORD, offQuelle:WORD	;;
	;;				    segZiel:WORD, offZiel:WORD		;;
	;;					nCount:WORD						;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CopyBuffer:
		PUSH BP
		MOV BP, SP
		ADD Bp, 6
		PUSHA
		PUSH DS
		PUSH ES
		
		MOV CX, [SS:BP]
		ADD BP, 2
		MOV SI, [SS:BP]
		ADD BP, 2
		MOV BX, [SS:BP]
		MOV DS, BX
		ADD BP, 2
		MOV DI, [SS:BP]
		ADD BP, 2
		MOV BX, [SS:BP]
		MOV ES, BX
		
	CB_LOOP:
		MOV AL, [ES:DI]
		MOV [DS:SI], AL
		INC DI
		INC SI
		LOOP CB_LOOP
			
	POP ES
	POP DS
	POPA
	POP BP
	RETF
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; LoadFile PROTO segMem:WORD, offMem:WORD,		;;
	;;				  segFile:WORD, offFile:WORD	;;
	;; Rückgabe: EAX >= 2 (Alles OK)				;;
	;;			 EAX < 2 Fehler						;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LoadFile:
	;retf
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH DS
		PUSH SI
		
		MOV SI, [SS:BP]
		ADD BP, 2
		MOV AX, [SS:BP]
		MOV DS, AX
		
		PUSH DS
		PUSH SI
		CALL 1460H:ReadFileName
		POP SI
		POP DS
		
		CMP EAX, 2
		JB RFN_FAILED
		
		PUSH EAX
		PUSH DS
		PUSH SI
		CALL 1460H:GetFileSize
		POP SI
		POP DS
		
		MOV [CS:FILESIZE], EAX
		POP EAX
			
		MOV SI, AX
		SHR EAX, 16
		MOV DS, AX				;DS:SI = FILE_STRUCT
		
		ADD SI, 26
		MOV AX, [DS:SI]			;Erster Cluster
		
		;ADD BP, 2
		;MOV DI, [SS:BP]
		;ADD BP, 2
		;MOV BX, [SS:BP]
		;MOV ES, BX				;DS:SI Speicher
		
		ADD BP, 2
		MOV CX, [SS:BP]
		ADD BP, 2
		MOV BX, [SS:BP]
		;MOV ES, BX				;DS:SI Speicher
		
	LF_LOOP:
		;PUSH CX
		;PUSH BX
		ADD AX, 31				;Sektor
		PUSH AX
		CALL 1460H:LBAToCHS
		;POP BX					;BX = Sektor
		
		MOV SI, AX
		SHR EAX, 16
		MOV DS, AX

		INC SI
		
		PUSH ES
		PUSH CX
		PUSH BX					;BX = Segment
		
		MOV CH, [DS:SI]
		INC SI
		MOV DH, [DS:SI]
		MOV DL, 0 
		INC SI
		MOV CL, [DS:SI]
		MOV AL, 1
		MOV AH, 02H
		;MOV BX, DI
		MOV BX, BUFF_512
		PUSH CS
		POP ES
		INT 13H
		
		POP BX
		POP CX
		POP ES
		
		ADD DI, 512
		
		POP AX					;AX = Sektor
		SUB AX, 31
		
		PUSH AX
		CALL 1460H:GetFATEntry
		ADD SP, 2
		;POP BX	
		
		CMP AX, 0FF7H
		JAE LF_LOOP_END
		
			PUSH CS
			PUSH WORD BUFF_512
			PUSH BX
			PUSH CX
			PUSH WORD 512
			CALL 1460H:CopyBuffer
			ADD SP, 10
		
			SUB [CS:FILESIZE], 512
			ADD CX, 512
			
		JMP LF_LOOP
		
	RFN_FAILED:
		MOV AX, 1
		PUSH WORD 06H
		CALL 1460H:SetLastError
		ADD SP, 2
		
		POP SI
		POP DS
		POP DX
		POP CX
		POP BX
		POP BP
		RETF
		
	LF_LOOP_END:

			PUSH CS
			PUSH WORD BUFF_512
			PUSH BX
			PUSH CX
			MOV EAX, [FILESIZE]
			PUSH AX
			CALL 1460H:CopyBuffer
			ADD SP, 10
			
		MOV AX, 32
		POP SI
		POP DS
		POP DX
		POP CX
		POP BX
		POP BP
		RETF
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; GetFileSize PROTO segFile:WORD, offFile:WORD	;;
	;; Ermittelt die Dateigröße in Bytes			;;
	;; AX < 2 evtl. Fehler (wenn GLE=0 kein fehler	;;
	;; AX > 2 Dateigröße							;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	GetFileSize:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSH BX
		PUSH CX
		PUSH DS
		PUSH SI
		MOV AX, [SS:BP]
		ADD BP, 2
		MOV BX, [SS:BP]
		PUSH BX
		PUSH AX
		CALL 1460H:ReadFileName
		POP BX
		POP BX
		
		CMP AX, 2
		JAE GFS_FILE_EX
		MOV EAX, 1
		PUSH AX 
		CALL 1460H:SetLastError
		POP AX
		JMP GFS_END
		
	GFS_FILE_EX:
		MOV SI, AX
		SHR EAX, 16
		MOV DS, AX
		
		ADD SI, 28					;Zeige auf Dateigröße
		
		MOV EAX, [DS:SI]
		;SHL EAX, 16
		;ADD SI, 2
		;MOV AX, [DS:SI]
		CMP EAX, 2
		JAE GFS_END
		CALL 1460H:SetLastErrorEx
		
	GFS_END:
		POP SI
		POP DS
		POP CX
		POP BX
		POP BP
		RETF
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; SetLastError PROTO uErrorCode	;;
	;; Setze den Fehlercode				;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SetLastError:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSHA
		MOV AX, CS
		MOV ES, AX
		MOV AX, [SS:BP]
		MOV [ES:LastError], AX
		POPA
		POP BP
		RETF
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; SetLastErrorEx PROTO				;;
	;; Setze den Fehlercode auf 0		;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SetLastErrorEx:
		PUSH WORD 0
		CALL 1460H:SetLastError
		ADD SP, 2
		RETF
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; GetFreeMem PROTO CountBlock				;;
	;; Reserviert gewünschte Menge an			;;
	;; Speicherblöcken; 1 Block = 16 Byte		;;
	;; Rückgabe: EAX < 2 Fehler (nicht genügend	;;
	;; Speicher; GetLastError = maximal 		;;
	;; mögliche Blockanzahl);					;;
	;; Wenn GLE = 0FFFFH (kein Speicher frei)	;;
	;; AX > 2 = Segment							;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Aufbau des Headers:						;;
	;; ID (0=frei und nachfolgende auch			;;
	;;	   1=belegt; 2=frei aber nachfolgender	;;
	;;	   Block nicht)							;;
	;; STATUS ?									;;
	;; CountBlock = Anzahl an Blöcken			;;
	;; TEMP 10xDB ?								;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	GetFreeMem:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSHA
		PUSH DS
		PUSH ES
		
		MOV AX, MEM_START
		MOV ES, AX
		MOV DI, 0
		
		GFM_LOOP:
			CMP WORD [ES:0], 0
			JE GFM_OK
			CMP WORD [ES:0], 2
			JE GFM_OK2
			CMP WORD [ES:0], 1
			;JNE GFM_NO_MEM
			
			MOV AX, ES
			ADD AX, [ES:4]
			INC AX;ADD AX, 16
			MOV ES, AX
			CMP AX, 8000H
			JAE GFM_NO_MEM
			
			JMP GFM_LOOP
			
		GFM_OK:
			MOV AX, ES
			MOV BX, 8000H
			SUB BX, AX
			CMP BX, [SS:BP]
			JA GFM_ENOUGH_MEM
			JMP GFM_NOT_ENOUGH_MEM
			
		GFM_OK2:
			MOV BX, [SS:BP]
			CMP BX, [ES:4]
			JB GFM_ENOUGH_MEM
			MOV AX, ES
			ADD AX, [ES:4]
			INC AX;ADD AX, 16
			MOV ES, AX
			
			CMP AX, 8000H
			JAE GFM_NO_MEM
			
			JMP GFM_LOOP
			
		GFM_NO_MEM:
			PUSH WORD 0FFFFH
			CALL 1460H:SetLastError
			ADD SP, 2
			POP ES
			POP DS
			POPA
			POP BP
			MOV EAX, 1
			RETF
			
		GFM_NOT_ENOUGH_MEM:
			DEC BX
			PUSH BX
			CALL 1460H:SetLastError
			ADD SP, 2
			POP ES
			POP DS
			POPA
			POP BP
			MOV EAX, 1
			RETF
			
		GFM_ENOUGH_MEM:
			MOV WORD [ES:0], 1
			MOV BX, [SS:BP]
			MOV [ES:4], BX
			MOV AX, ES
			INC AX
			MOV [CS:FN_TEMP], AX
			POP ES
			POP DS
			POPA 
			POP BP
			XOR EAX, EAX
			MOV AX, [CS:FN_TEMP]
			RETF

			
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; ReadFileName PROTO SEG:WORD, OFF:WORD	;;
	;; Sucht den angegebenen Dateinamen 		;;
	;; im aktuellen Verzeichnis					;;
	;; Wenn (E)AX < 2 Fehler					;;
	;; ansonsten:								;;
	;; Highword EAX = Segment von FILE_STRUCT	;;
	;; Lowword (AX) = Offset von FILE_STRUCT	;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ReadFileName:
		CALL 1460H:SetLastErrorEx
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI
		PUSH DI
		PUSH ES
		
		MOV SI, [SS:BP]	;Offset
		ADD BP, 2
		MOV AX, [SS:BP]	
		MOV DS, AX
		
		MOV AX, [ES:DIR_SEG]
		;MOV ES, AX
		MOV DI, [ES:DIR_OFF]
		MOV CX, [ES:DIR_COUNT]
		MOV ES, AX
		
		RFN_LOOP:
		
			PUSH CX
			
			MOV CX, 11

			PUSH SI
			PUSH DI
			PUSH DS
			PUSH ES
			PUSH CX
			CALL 1460H:CheckStr
			POP CX
			POP ES
			POP DS
			POP DI
			POP SI
			
			CMP AX, 2
			JE RFN_OK
			ADD DI, 32
			POP CX
			LOOP RFN_LOOP
			JMP RFN_NOT_FOUND
			
		RFN_OK:
			POP CX
			
			MOV AX, ES					;(E)AX = Segment:Offset
			SHL EAX, 16
			MOV AX, DI
			
			POP ES
			POP DI
			POP SI
			POP DX
			POP CX
			POP BX
		
			JMP RFN_END
			
		RFN_NOT_FOUND:
			POP ES
			POP DI
			POP SI
			POP DX
			POP CX
			POP BX
			MOV AX, 1
			MOV [CS:LastError], 06H
			
		RFN_END:
			POP BP
			RETF
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; CheckStr																;;
	;; Vergleiche 2 Strings miteinander, bis  max. Anzahl erreicht			;;
	;; Parameter:	Pushe String 1 Offset									;;
	;; 				Pushe String 2 Offset									;;
	;;				Pushe String 1 Segment									;;
	;;				Pushe String 2 Segment									;;
	;;				Pushe Anzahl zu prüfender Zeichen						;;
	;; Back:        AX = 0 (Strings nicht gleich)							;;
	;;				AX = 2 (Strings gleich)									;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CheckStr:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSH ES
		PUSH DS
		PUSH SI
		PUSH DI
		PUSH BX
		PUSH CX
			
		MOV CX, [BP]			;Max. Anzahl der zu prüfenden Zeichen
		ADD BP, 2
		MOV DS, [BP]
		ADD BP, 2
		MOV ES, [BP]
		ADD BP, 2
		MOV SI, [BP]
		ADD BP, 2
		MOV DI, [BP]

	CHSTR:
		MOV BL,[ES:DI]
		MOV BH,[DS:SI]
			
		MOV AX,0
		CMP BH,BL
		JNE CHSTR_END
		INC SI
		INC DI
		LOOP CHSTR
			
	CHSTR_C:	
		MOV AX,2
	CHSTR_END:
		POP CX
		POP BX
		POP DI
		POP SI
		POP DS
		POP ES
		POP BP
		RETF
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; LBAToCHS PROTO LBA:WORD				;;
	;; Rechnet die übergebene LBA   		;;
	;; ins CHS Format um					;;
	;; Rückgabe: AX = Offset von CHS_STRUCT	;;
	;; 			Highword EAX = Segment		;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LBAToCHS:
		PUSH BP
		MOV BP, SP
		ADD BP, 6
		PUSHA
		PUSH DS
		PUSH ES
		
		MOV AX, CS
		MOV ES, AX
		MOV AX,[BP]				;AX=LBA
			
	SPUR:
		MOV BX,36
		XOR DX,DX
		DIV BX
		XOR AH,AH
		MOV [ES:C], AL
		

	HEAD:
		MOV BX,18
		MOV AX,[BP]
		XOR DX,DX
		DIV BX
		MOV BX,2
		XOR DX,DX
		DIV BX
		XOR DH,DH
		MOV [ES:H], DL
			
	SEKTOR:
		MOV AX,[BP]
		MOV BX,18
		XOR DX,DX
		DIV BX
		ADD DX,1
		XOR DH,DH
		MOV [ES:S], DL
		
		POP ES
		POP DS
		POPA
		MOV EAX, CS
		SHL EAX, 16
		MOV AX, CHS_STRUCT
		POP BP
		RETF
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; GetLastError PROTO			;;
	;; Gibt den letzten Fehlerzurück;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	GetLastError:
		MOV AX, [ES:LastError]
		RETF
		
	
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;; GetCluster														;;
		;; Ermittle den Inhalt eines FAt12 Clustereintrages					;;
		;; Parameter: 	Pushe Clusternummer									;;
		;; Back:	  	AX = Inhalt des Clustertabelleneintrag				;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		GetFATEntry:
			PUSH BP
			MOV BP, SP
			PUSH ES
			PUSH DS
			PUSH DI
			PUSH SI
			PUSH BX
			PUSH CX
			PUSH DX
			
			MOV SI, 0
			MOV SI, [ES:DIR_OFF]
			MOV AX, [ES:DIR_SEG]
			MOV ES, AX
			
			ADD BP, 6
			MOV AX, [BP]
			
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
			MOV AX, 1000H
			MOV DS, AX
			POP AX
			MOV SI, 0
			ADD SI, AX
			MOV CL, [ES:SI]
			INC SI
			MOV BL, [ES:SI]
			SHL BL, 4
			SHR BL, 4
			MOV CH, BL
			MOV AX, CX
			
			POP DX
			POP CX
			POP BX
			POP SI
			POP DI
			POP DS
			POP ES
			POP BP
			RETF
		
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
			MOV CL, [ES:SI]
			SHR CL, 4
			SHL CL, 4
			INC SI
			MOV CH, [ES:SI]
			SHR CX, 4
			MOV AX, CX
			
			POP DX
			POP CX
			POP BX
			POP SI
			POP DI
			POP DS
			POP ES
			POP BP
			RETF


		
		
		
		db 5*1024-$ DUP(0)
		KERNEL_END: