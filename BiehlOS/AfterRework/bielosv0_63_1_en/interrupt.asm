;#############################
interrupt:
;ints


;###Int 21h
int21h:
;pusha
PUSH BX
PUSH CX
PUSH DX
PUSH ES
PUSH DS
cmp ah,0h
JE pr_z
cmp ah,01h
JE pr_str
cmp ah,02h
JE rd_z
cmp ah,03h
JE rd_z_a
cmp ah,04h
JE rd_str
CMP AH,05H
JE LOAD_PROG
mov al,1  ;Fehlercode
int21h_e:
;popa
POP DS
POP ES
POP DX
POP CX
POP BX
iret
;###Int 21h Ende


;### Zeichen ausgeben
pr_z:
mov ah,0eh
int 10h
iret
;###Zeichenausgeben ende

;### Stringausgabe int 21h ah=01h begrenzungszeichen=ASCII 0 BX=OFFSET
pr_str:
cmp byte [bx],0
JE int21h_e
mov ah,0eh
mov al,[bx]
int 10h
inc bx
jmp pr_str
;### Stringausgabe ende

;###Zeichen von Tastatur einlesen
rd_z:
mov ah,0
int 16h
jmp int21h_e
;### 

;###Zeichen von Tastatur lesen und ausgeben
rd_z_a:
mov ah,0
int 16h
mov ah,0eh
int 10h
JMP int21h_e
POPA
iret
;###Zeichen einlesen ende

;###String einlesen
;#BX:Offset
rd_str:
mov ah,0
int 16h
cmp al,13
JE int21h_e
cmp al,8
JE back
mov ah,0eh
int 10h
mov [bx],al
JCXZ int21h_e
dec cx
inc bx
jmp rd_str
back:
lea si,[buffer]
cmp bx,si
JE rd_str
mov ah,0eh
int 10h
mov byte [bx],0
dec bx
inc cx
mov al," "
mov ah,0eh
int 10h
mov al,8
mov ah,0eh
int 10h
jmp rd_str
;###String einlesen ende

;----------------------------------------------------------------
;-- LOAD_PROG --
;-- Parameter: AH=05 / BX = Offset Dateiname 
;-- Rückgabe: AX = Adresse
;--------------------------------------------------------------
LOAD_PROG:
		MOV AX,CS
		MOV ES,AX
		
		LEA SI,[buffer]
		MOV CX,100
		
LP_S:	
		MOV AL,[DS:BX]
		MOV BYTE [ES:SI],AL
		INC BX
		INC SI
		LOOP LP_S
		
		MOV AX,CS
		MOV DS,AX
		MOV ES,AX
		LEA BX,[buffer]
		PUSH BX
		CALL _readproc
		POP BX
		JMP int21h_e
		

;---------------------------------------------------
;-- INT6H --
;-- Invalid Opcode Exception
;--------------------------------------------------------
INT6H:
PUSHA
PUSH ES
PUSH DS
		MOV AX,CS
		MOV DS,AX
		MOV ES,AX
		LEA BX,[INVALID_OPCODE]
		MOV AH,01
		INT 21h
POP DS
POP ES
POPA
		POP BX
		LEA BX,[PROC_AFTER_CALL]
		PUSH BX
IRET
INVALID_OPCODE	DB	"Es wurde ein unzulässiger Befehl ausgeführt",13,10,0

;############################################################
;-- Timer, wird 18,2 mal pro sekunde aufgerufen
;-----------------------------------------------------------
INT1CH:
		PUSHA
		PUSH ES
		PUSH DS
		MOV AX,07c0h
		MOV ES,AX
		MOV AX,07c0h
		MOV DS,AX
		LEA SI,[PROCESS_TABLE]
		ADD SI,3
		MOV CX,133
		
INT1CH_CHECK_PROZESS_TABLE:
		CMP BYTE [SI],1
		JE TSR_OK
		ADD SI,15
		LOOP INT1CH_CHECK_PROZESS_TABLE
		JMP CHECK_TSR_END
		
TSR_OK:
		INC SI
		MOV AX,[SI]
		
		PUSH CX
		MOV CX,AX
		MOV AX,CS
		XOR DX,DX
		MOV BX,16
		MUL BX
		ADD AX,CX
		ADD AX,2h
		XOR DX,DX
		DIV BX
		POP CX
		PUSHA
		PUSH ES
		PUSH DS
		mov word [sprung_int1ch+3],ax ;wichtig: hier die Sprungadresse im Code ändern
		sprung_int1ch: CALL 7c0h:2h
		POP DS
		POP ES
		POPA
		ADD SI,14
		LOOP INT1CH_CHECK_PROZESS_TABLE
		
CHECK_TSR_END:
		POP DS
		POP ES
		POPA
IRET

db 1024-($-interrupt) dup(0)