;#############################
interrupt:
;ints


;###Int 21h
int21h:
pusha
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
mov al,1  ;Fehlercode
int21h_e:
popa
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
db 1024-($-interrupt) dup(0)