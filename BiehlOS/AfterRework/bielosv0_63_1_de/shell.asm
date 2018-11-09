;#############################
;beginn 20.sektor
beginn_shell:
mov ax,cs
mov ds,ax
mov es,ax

cli
push ax
push es
mov ax,0
mov es,ax
		MOV WORD [ES:1CH*4],INT1CH
		MOV WORD [ES:1CH*4+2],CS
pop es
pop ax
sti

MOV AX,CS
MOV [GET_CHAR_CS],AX
lea bx,[shell2]
push bx
call _readproc
pop bx
LEA BX,[shell3]
PUSH BX
CALL _readproc
POP BX


lea bx,[shell_ok]
push bx
call _prnt
pop cx

		LEA BX,[shell_help]
		PUSH BX
		CALL _prnt
		POP BX
		
		LEA BX,[KEY_DRV]
		PUSH BX
		CALL _readproc
		POP BX
		CMP AX,0
		JE read_always
		
		MOV CX,AX
		MOV AX,CS
		XOR DX,DX
		MOV BX,16
		MUL BX
		ADD AX,CX
		XOR DX,DX
		DIV BX
		;PUSH ES
		;PUSH DS
		;mov word [sprung1+3],ax ;wichtig: hier die Sprungadresse im Code ändern
		;sprung1: CALL 7c0h:0h
		;jmp $
		;POP DS
		;POP ES
		
read_always: ;ab hier wird die Kommandozeile abgefragt
lea bx,[buffer]
mov cx,100
set_b_0:
mov byte [bx],0
inc bx
loop set_b_0
lea bx,[buffer2]
mov cx,100
set_b2_0:
mov byte [bx],0
inc bx
loop set_b2_0
lea bx,[entera]
push bx
call _prnt
pop cx

lea bx,[fd]
push bx
call _prnt
pop cx

		LEA BX,[backslash]
		PUSH BX
		CALL _prnt
		POP BX
		
		LEA BX,[dir]
		PUSH word BX
		CALL _prnt
		POP BX
		
		LEA BX,[e_kl]
		PUSH BX
		CALL _prnt
		POP BX
		
		
;mov ah,04h
lea bx,[buffer]
PUSH BX
call GETC_STRING
mov cx,100
;int 21h
pop bx


		
;##entferne das erste Leerzeichen nach dem Befehl
xor dx,dx
mov cx,100
entferne_leer:
cmp byte [bx]," "
JE entferne_ok
inc bx
inc dx
loop entferne_leer
jmp asdfg
entferne_ok:
mov byte [bx],0
asdfg:


		MOV CX,100
		PUSH CX
		LEA BX,[buffer]
		PUSH BX
		CALL LowToUpperCase
		POP BX
		POP CX
		
push dx

lea bx,[entera]
push bx
call _prnt
pop bx

mov word [cs:neu_var],0 ;definiere neue Variable
;mov word [07c0h:2h],0
mov cx,[anzahl_befehle]

check_befehl:
;push cx
lea bx,[buffer]
push bx
lea bx,[befehle]
add bx,[cs:neu_var]
add word [cs:neu_var],10
push bx
call _checkstr
pop dx
pop dx
cmp ax,0
JnE ok
loop check_befehl
pop dx
jmp check_befehl_failed
;jmp after_ok
ok:
;hier muss buffer auf den Parameter -? überorüft werden und gegebenfalls entsprechenden Wert übergeben
;test
pop dx
;push bx
lea si,[buffer]
add si,dx
inc si
cmp word [si],"-?"
JnE no_ask
mov dx,0aah
no_ask:
;pop bx
add bx,8
mov ax,[bx]
lea bx,[buffer]
add bx,5
call ax
after_ok:
pop dx
mov cx,100
lea bx,[buffer]
del_buffer: ;###setze buffer wieder auf null
mov byte [bx],0
inc bx
loop del_buffer

jmp read_always

;#######################Befehl nicht gefunden: Entweder kein Befehl, oder Programm
;#######################
check_befehl_failed:
		lea bx,[buffer]
		push bx
		call _readproc
		pop bx
	
		MOV DX,AX
		cmp ax,0
		JE check_proc_failed
							;ret1=dateiname in Filetable
							
		mov si,[ret1]
		sub si,10
		mov cx,10
		
check_proc_ext:
		lodsb
		cmp al,0
		JE check_proc_failed
		cmp al,"."
		JE check_proc_ext_dot
		loop check_proc_ext
		jmp check_proc_failed
		
check_proc_ext_dot:
		cmp word [si],"os"
		JE check_proc_ext_ok
		LEA BX,[buffer]
		PUSH BX
		CALL CHECKSCRIPT
		POP BX
		CMP AX,1
		JnE NO_SCRIPT				;AX=0: KEin Script
		;MOV CX,2048
		;PUSH CX
		PUSH DX
		CALL COUNT_LINE				;Zähle Anzahl an Zeilen im Script / Rückgabe: AX
		POP DX
		;POP CX
		MOV CX,AX					;CX=Anzahl Zeilen
		
	
;----------------------------------------------------------------------------------------------------------
;-- Ab hier wird der integrierte Scriptinterpreter umgesetzt
;----------------------------------------------------
SCRIPT_START:
		PUSH CX
		PUSH SI
		PUSH CX
		LEA SI,[buffer]
		MOV CX,100
SET_BUFFER_0:
		MOV byte [SI],0
		INC SI
		LOOP SET_BUFFER_0
		POP CX
		POP SI
		LEA BX,[buffer]
		PUSH BX
		PUSH DX						;PUSHE Quelle
		;MOV BX,10
		;PUSH BX
		PUSH WORD 10
		CALL _copy					;BUFFER enthält nun den ersten Befehl
		POP BX
		POP DX
		POP BX
		PUSH DX
		xor dx,dx
		mov cx,100
entferne_leer2:
		cmp byte [bx]," "
		JE entferne_ok2
		inc bx
		inc dx
		loop entferne_leer2
		jmp asdfg2
entferne_ok2:
		mov byte [bx],0
asdfg2:
		;POP DX						;DX enthält Adresse


		MOV CX,100
		PUSH CX
		LEA BX,[buffer]
		PUSH BX
		CALL LowToUpperCase
		POP BX
		POP CX
		
		LEA SI,[befehle]
		MOV word [cs:neu_var],0 	;definiere neue Variable
		MOV CX,[anzahl_befehle]

CHECK_COMMAND:
		LEA BX,[buffer]
		push bx
		lea bx,[befehle]
		add bx,[cs:neu_var]
		add word [cs:neu_var],10
		push bx
		call _checkstr
		pop dx
		pop dx
		cmp ax,0
		JnE CC_OK
		loop CHECK_COMMAND
		POP DX
		POP CX
		DEC CX
		CMP CX,0
		JE NO_LOOP1
		JMP SCRIPT_START
NO_LOOP1:
		mov cx,100
		lea bx,[buffer]
		del_buffer2: ;###setze buffer wieder auf null
		mov byte [bx],0
		inc bx
		loop del_buffer2
		jmp read_always;CHECK_COMMAND_FAILED
CC_OK:
		ADD BX,8
		MOV AX,[BX]
		;LEA BX,[buffer]
		;add bx,12
		;MOV al,[bx]
		;PUSH BX
		;call _prnt
		;pop bx
		;jmp $
		CALL AX
		POP DX
		;ADD DX,100
		CALL RIGHTDX
		POP CX
		DEC CX
		CMP CX,0
		JnE SCRIPT_START
		;LOOP SCRIPT_START
		mov cx,100
		lea bx,[buffer]
		del_buffer1: ;###setze buffer wieder auf null
		mov byte [bx],0
		inc bx
		loop del_buffer1
		JMP read_always
		
CHECK_COMMAND_FAILED:
		POP DX
		;ADD DX,100
		CALL RIGHTDX
		POP CX
		DEC CX
		CMP CX,0
		JE NO_LOOP2
		JMP SCRIPT_START
NO_LOOP2:
		mov cx,100
		lea bx,[buffer]
		del_buffer3: ;###setze buffer wieder auf null
		mov byte [bx],0
		inc bx
		loop del_buffer3
		JMP read_always

RIGHTDX:
		PUSH CX
		PUSH BX
		MOV AX,0
		MOV BX,DX
		MOV CX,100
		
RDX_S:
		CMP BYTE [BX],10
		JE RDX_S_OK
		INC BX
		INC AX
		LOOP RDX_S
		POP BX
		POP CX
		RET
		
RDX_S_OK:
		ADD DX,AX
		INC DX
		POP BX
		POP CX
RET
		
		
	
		
NO_SCRIPT:
		LEA BX,[check_ext_failed]
		PUSH BX
		CALL _prnt
		POP BX
		
check_proc_failed:
		lea bx,[check_all_failed]
		push bx
		call _prnt
		pop bx
		jmp read_always

check_proc_ext_ok:
		;------------------------------
		;-- DX = Adresse
		;berechne CS:0h
		MOV CX,DX
		MOV AX,CS
		XOR DX,DX
		MOV BX,16
		MUL BX
		ADD AX,CX
		ADD AX,0h
		XOR DX,DX
		DIV BX
		PUSH ES
		PUSH DS
		PUSH SS
		PUSHA
		PUSH SP
		LEA BX,[buffer]
		mov word [sprung+3],ax ;wichtig: hier die Sprungadresse im Code ändern
		sprung: CALL 7c0h:0h
PROC_AFTER_CALL:
		POP SP
		POPA
		POP SS
		POP DS
		POP ES
		;CALL CloseFile
		;sti
		;CALL DX
		JMP read_always
ret
check_ext_failed db "Datei nicht ausführbar",13,10,0
check_all_failed db "Befehl oder Programm nicht gefunden",13,10,0
shell2 db "shell.lib",0
shell3 db "shell2.lib",0
;neu_var dw 0
buffer db 100 dup(0)
buffer2 db 100 dup(0)
dir db "root",50 dup(0)
dir_cluster dw 6
anzahl_befehle dw 15
entera db 13,10,0
fd db "fd:",0
backslash db "/",0
e_kl db ">",0
shell_ok db "BielShell v1.0",13,10,0
verfs db "BielFS v0.9",13,10
kernelver db "Kernel v0.01",13,10,0
shell_help	DB 	"help eingeben, um Hilfe zu erhalten",13,10
			DB 	"oder 'show help.txt' eingeben.",13,10,0
neu_var dw 0


befehle:
db "show",0,0,0,0
dw show
db "echo",0,0,0,0
dw echo
db "sver",0,0,0,0
dw sver
db "help",0,0,0,0
dw help
db "halt",0,0,0,0
dw halt
db "sdir",0,0,0,0
dw sdir
db "tiny",0,0,0,0
dw tinyedit
db "date",0,0,0,0
dw date
db "time",0,0,0,0
dw time
db "cd",0,0,0,0,0,0
dw cd
db "cls",0,0,0,0,0
dw cls
db "mkdir",0,0,0
dw mkdir
db "tasks",0,0,0
dw tasks
db "kill",0,0,0,0
dw kill
db "tsr",0,0,0,0,0
dw tsr

tsr:
		CMP DX,0AAH
		JE TSR_HELP
		
		LEA BX,[buffer]
		ADD BX,4			;BX zeigt auf Prozess ID
		
		MOV AL,[BX]
		SUB AL,48
		XOR AH,AH
		MOV CH,10
		MUL CH
		MOV CL,AL
		INC BX
		MOV AL,[BX]
		SUB AL,48
		ADD CL,AL
		MOV AL,CL
		MOV DL,CL
		
		LEA SI,[PROCESS_TABLE]
		ADD SI,2
		MOV CX,113
		
TSR_SEARCH_TSR:
		CMP BYTE [SI],DL
		JE TSR_SEARCH_OK
		ADD SI,15
		LOOP TSR_SEARCH_TSR
		JMP TSR_SEARCH_TSR_END
		
TSR_SEARCH_OK:
		INC SI
		MOV BYTE [SI],1
		LEA BX,[TSR_SEARCH_OK_TEXT]
		PUSH BX
		CALL _prnt
		POP BX
		JMP TSR_END
		
TSR_SEARCH_TSR_END:
		LEA BX,[TSR_FAILED]
		PUSH BX
		CALL _prnt
		POP BX

TSR_END:
RET
		
TSR_HELP:
		LEA BX,[TSR_HELP_TEXT]
		PUSH BX
		CALL _prnt
		POP BX
RET

TSR_SEARCH_OK_TEXT	DB	"OK.",13,10,0
TSR_FAILED			DB	"ID nicht gefunden.",13,10,0
TSR_HELP_TEXT		DB	"tsr <ID>",13,10
					DB	"Gibt einem laufendem Prozess den Status TSR.",13,10
					DB	"Eine korrekte ID entnehmen sie bitte dem 'tasks' Befehl.",13,10,0

kill:
		CMP DX,0AAH
		JE KILL_HELP
		
		LEA BX,[buffer]
		ADD BX,5
		
		CMP BYTE [BX],49
		JB KILL_NO_PARA
		
		MOV AL,[BX]
		SUB AL,48
		XOR AH,AH
		MOV CH,10
		MUL CH
		MOV CL,AL
		INC BX
		MOV AL,[BX]
		SUB AL,48
		ADD CL,AL
		MOV AL,CL
					;Task ID in CL
		LEA SI,[PROCESS_TABLE]
		MOV CX,113
		ADD SI,2
KILL_CHECK_ID:
		CMP BYTE [SI],AL
		JE KILL_CHECK_ID_OK
		
		ADD SI,15
		LOOP KILL_CHECK_ID
		JMP KILL_ID_NOT_FOUND
		
KILL_CHECK_ID_OK:
		MOV BYTE [SI],0

		MOV CX,2048
		INC SI
		INC SI
		MOV BX,[SI]
		
DEL_RAM:
		MOV BYTE [BX],0
		INC BX
		LOOP DEL_RAM

		LEA BX,[KILL_OK]
		PUSH BX
		CALL _prnt
		POP BX
RET
KILL_ID_NOT_FOUND:
		LEA BX,[KILL_NO_ID]
		PUSH BX
		CALL _prnt
		POP BX
RET
KILL_NO_PARA:
		LEA BX,[KILL_NO_PARA_TEXT]
		PUSH BX
		CALL _prnt
		POP BX
RET
KILL_HELP:
		LEA BX,[KILL_HELP_TEXT]
		PUSH BX
		CALL _prnt
		POP BX
RET
KILL_OK				DB	"OK.",13,10,0
KILL_NO_ID			DB	"ID nicht gefunden.",13,10,0
KILL_NO_PARA_TEXT	DB	"Keine ID angegeben.",13,10,0
KILL_HELP_TEXT		DB	"kill <ID>",13,10,"ID darf maximal 99 sein und muss min. 10 sein!",13,10,0
tasks:
		CMP DX,0AAH
		JE TASKS_HELP
		LEA BX,[TASK_PRINT1]
		PUSH BX
		CALL _prnt
		POP BX
		LEA SI,[PROCESS_TABLE]
		MOV CX,113
		ADD SI,2			;SI zeigt auf tasknummer
		
TASK_CHECK:
		CMP BYTE [SI],0
		JE TASK_CHECK_NEXT
		MOV AL,[SI]
		CALL write_int
		PUSH WORD 6
		CALL PRINT_LEER
		POP AX
		INC SI
		MOV AL,[SI]
		CALL write_int		
		PUSH WORD 3
		CALL PRINT_LEER
		POP AX
		INC SI
		;INC SI
		;MOV AL,[SI]
		;CALL write_int
		;DEC SI
		;MOV AX,[SI]
		;PUSH AX
		;MOV AL,AH
		;CALL write_int
		;POP AX
		;CALL write_int
		;INC SI
		;INC SI
		;MOV AL,[SI]
		;call write_int
		
		;PUSH WORD 13
		;CALL PRINT_LEER
		;POP AX
		INC SI
		INC SI
		PUSH SI
		CALL _prnt
		POP SI
		LEA BX,[entera]
		PUSH BX
		CALL _prnt
		PUSH BX
		CALL _prnt
		POP BX
		POP BX
		ADD SI,11
		LOOP TASK_CHECK
		JMP TASK_END
		
TASK_CHECK_NEXT:
		ADD SI,15
		LOOP TASK_CHECK
		
TASK_END:
RET
TASK_PRINT1	DB	"TASK ID | TSR | Prozessname",13,10,0;Speicheradresse | Prozessname",13,10,0

TASKS_HELP:
		LEA BX,[TASKS_HELP_TEXT]
		PUSH BX
		CALL _prnt
		POP BX
RET
TASKS_HELP_TEXT:
DB	"tasks",13,10
DB	"Gib Informationen zu allen laufenden Tasks aus.",13,10,0
PRINT_LEER:
		PUSH BP
		MOV BP,SP
		PUSH AX
		PUSH CX
		ADD BP,4
		;MOV AH,0AH
		MOV AL," "
		MOV CX,[BP];17
		MOV AH,0EH
PRINT_LEER_LOOP:
		INT 10H
		LOOP PRINT_LEER_LOOP
		MOV AH,0EH
		MOV AL,"|"
		INT 10H
		;INT 10H
		;MOV AH,0EH
		;MOV AL,"|"
		;INT 10H
		POP CX
		POP AX
		POP BP
RET

mkdir:
		;-------------------------------------------------------
		;-- Erstelle ein Verzeichnis
		;-- Parameter: Dateiname
		;------------------------
		CMP DX,0AAH
		JE MKDIR_HELP
		LEA BX,[buffer]
		ADD BX,6		;BX zeigt auf Ordnernamen
		MOV SI,[speicher]
		MOV CX,2048
MKDIR_DEL_SP:
		MOV byte [SI],0
		INC SI
		LOOP MKDIR_DEL_SP

		MOV SI,[speicher]
		MOV WORD [SI],".."
		ADD SI,10		;SI zeigt auf Clusternummer
		MOV DI,[dir_cluster]
		MOV [SI],DI		;SI=Cluster
		PUSH WORD [speicher]
		PUSH WORD 1
		PUSH BX
		CALL _writeproc
		POP BX
		POP DI
		POP DI

		CMP AX,0
		JNE MKDIR_FAILED
		
		;PUSH BX
		;CALL _readproc
		;POP BX
		;[ret2] enthält nun 
RET
MKDIR_F_TEXT	DB	"Ordner konnte nicht erstellt werden",13,10,0
MKDIR_FAILED:
		LEA BX,[MKDIR_F_TEXT]
		PUSH BX
		CALL _prnt
		POP BX
RET

MKDIR_HELP:
		LEA BX,[MKDIR_HELP_TEXT]
		PUSH BX
		CALL _prnt
		POP BX
RET
MKDIR_HELP_TEXT:
DB	"mkdir <Verzeichnis>",13,10
DB	"Erstellt das angegebene Verzeichnis",13,10
DB	"Der Name darf nur 7 Zeichen land sein",13,10
DB	"Leerzeichen sind nicht erlaubt",13,10,0

cls:
		CMP DX,0AAH
		JE CLS_HELP
		MOV AH,0
		MOV AL,2
		INT 10H
RET

CLS_HELP:
		LEA BX,[CLS_HELP_TEXT]
		PUSH BX
		CALL _prnt
		POP BX
RET

CLS_HELP_TEXT:
DB	"cls",13,10
DB	"Leert den Bildschirm",13,10,0


cd:
		CMP DX,0AAh
		JE CD_HELP
		LEA BX,[buffer]
		ADD BX,3			;BX zeigt auf den Anfangsbuchstaben des Ordners
		PUSH BX
		CALL _readproc		;Ordnerdatei wird in den RAM geladen
		POP BX
							;speichere jetzt die Clusternummer nach DIR_CLUSTER
		PUSH BX
		MOV BX,[ret2]
		MOV [dir_cluster],BX
		POP BX
		CMP AX,0
		JE CD_FAILED
		LEA SI,[filetable]
		MOV CX,2048
		MOV DI,AX
COPY_NEU_ALT:
		MOV AL,[DI]
		MOV BYTE [SI],AL
		INC DI
		INC SI
		LOOP COPY_NEU_ALT
		
		CALL CloseFile
		PUSH BX
		MOV DI,BX
		CMP WORD [DI],".."
		JE DEL_LAST_DIR
		LEA BX,[dir]
		MOV CX,52
DEL_VAR_DIR:
		CMP BYTE [BX],0
		JE DEL_VAR_DIR_0
		INC BX
		LOOP DEL_VAR_DIR

DEL_VAR_DIR_0:
		MOV BYTE [BX],"/"
		INC BX
		DEC CX
		MOV BX,CX
		MOV CX,52
		SUB CX,BX
		;MOV BYTE [BX],0
		;INC BX
		;LOOP DEL_VAR_DIR
		POP BX
							;Kopiere nun den Dateinamen in die VAriable dir
		LEA DX,[dir]
		ADD DX,CX
		PUSH DX
		PUSH BX						;PUSHE Quelle
		;MOV BX,10
		;PUSH BX
		PUSH WORD 0
		CALL _copy					;BUFFER enthält nun den ersten Befehl
		POP BX
		POP DX
		POP DX
RET
DEL_LAST_DIR:
		LEA BX,[dir]
		MOV CX,52
		ADD BX,52			;prüfe von hinten an
		
DLD_S:
		CMP BYTE [BX],"/"
		JE DLD_S_OK
		DEC BX
		LOOP DLD_S
		JMP DLD_S_NON

DLD_S_OK:	
		;INC BX
		MOV CX,52
DLD_S_OK_DEL:
		CMP BYTE [BX],0
		JE DLD_S_NON
		MOV BYTE [BX],0
		INC BX
		LOOP DLD_S_OK_DEL
		;PUSH BX
		;PUSH [speicher]
		;PUSH WORD 0
		;CALL _copy
		;POP DX
		;POP DX
		;POP BX
DLD_S_NON:
		POP BX
RET

		
CD_HELP:
		LEA BX,[CD_HELP_TEXT]
		PUSH BX
		CALL _prnt
		POP BX
RET
CD_HELP_TEXT	DB "cd <Verzeichnis>",13,10
				DB "Wechselt in das angegebene Verzeichnis.",13,10,0
		
CD_FAILED:
		LEA BX,[cd_f]
		PUSH BX
		CALL _prnt
		POP BX
RET
cd_f db "Ordner nicht gefunden",13,10,0


time:
		CMP DX,0AAH
		JE TIME_HELP
lea bx,[time_text]
push bx
call _prnt
pop bx
mov ah,02h
int 1ah
call BCDToChar
mov ah,0eh
int 10h
mov al,ch
mov ah,0eh
int 10h
mov ah,0eh
mov al,":"
int 10h
mov ch,cl
call BCDToChar
mov ah,0eh
int 10h
mov al,ch
mov ah,0eh
int 10h
mov ah,0eh
mov al,":"
int 10h
mov ch,dh
call BCDToChar
mov ah,0eh
int 10h
mov al,ch
int 10h
ret
TIME_HELP:
		LEA BX,[TIME_HELP_TEXT]
		PUSH BX
		CALL _prnt
		POP BX
RET
TIME_HELP_TEXT:
DB	"time",13,10
DB	"Gibt die aktuelle Zeit aus",13,10,0
time_text db "Aktuelle Zeit: ",0

date:
cmp dx,0aah
JE date_help
lea bx,[date_text]
push bx
call _prnt
pop bx
mov ah,04h
int 1ah
push cx
;al=richtig
mov al,dl
call write_int
mov al,"."
mov ah,0eh
int 10h
;mov al,ch
mov al,dh
call write_int
mov al,"."
mov ah,0eh
int 10h
pop cx
mov al,cl
;mov al,ch
call write_int
ret
date_help:
lea bx,[date_help_text]
push bx
call _prnt
pop bx
ret
date_help_text:
db "date",13,10
db "Gibt das aktuelle Datum aus.",13,10,0
date_text db "Aktuelles Datum: ",0

show:
cmp dx,0aah
JE show_help
lea bx,[buffer]
add bx,5
push bx
call _readproc
pop bx

;ax=adresse
cmp ax,0
JnE show_ok

lea bx,[show_failed]
push bx
call _prnt
pop bx

ret
show_failed db "Datei nicht gefunden",13,10,0
show_next_line db 13,10,"Taste druecken, um die nächsten 24 Zeilen anzuzeigen.",13,10,13,10,0
show_ok:
;80x25 nach 25 zeichen zähler 1 erhöhen

mov si,ax
push si
call _prnt
pop si
ret
show_help:
lea bx,[show_help_text]
push bx
call _prnt
pop bx
CALL CloseFile
ret
show_help_text:
db "show <Dateiname>",13,10
db "Lies die angegebene Datei aus gib sie auf dem Bildschirm aus",13,10,0

tinyedit:
cmp dx,0aah
JE tinyedit_help
;setze after_shell auf 0
mov cx,2048
;mov bx,after_shell
mov bx,[speicher]
tinyedit1:
mov byte [bx],0
inc bx
loop tinyedit1

MOV CX,2048
mov bx,[speicher]
push bx
mov ah,04
int 21h
pop bx
;text gespeichert
;nach enter: text speichern
lea bx,[entera]
push bx
call _prnt
pop bx
lea bx,[msg1]
push bx
call _prnt
pop bx
lea bx,[buffer]
push bx
mov ah,04
int 21h
pop bx
;buffer=dateiname
mov bx,[speicher]
push bx
mov bx,1
push bx
lea bx,[buffer]
push bx
call _writeproc
pop bx
pop bx
pop bx
cmp al,0
JnE tinyfailed
ret
tinyfailed:
lea bx,[tinyf1]
push bx
call _prnt
pop bx
ret

tinyedit_help:
lea bx,[tinyedit_help_text]
push bx
call _prnt
pop bx
ret
tinyedit_help_text:
db "tiny",13,10
db "Oeffnet einen kleinen TExteditor.",13,10
db "Beim druecken von [Enter] wird die Texteingabe beendet und zur Dateinamenseingabe aufgefordert.",13,10,0
tinyf1 db "Fehler beim speichern",13,10,0
msg1 db "Bitte Dateiname angeben:",13,10,0


sdir:
cmp dx,0aah
JE sdir_help
lea bx,[filetable]
mov cx,[max_files]
dec cx
sdir2:
push cx
mov cx,10
sdir1:
;###gehe die ganze Filetable durch und gib die Namen aus
mov al,[bx]
cmp al,0
JE sdir1_1
mov ah,0eh
int 10h
sdir1_1:
inc bx
loop sdir1
pop cx
;inc bx
xor ax,ax
mov ax,170
sub ax,cx
mov dx,12
mul dx

lea bx,[filetable]

add bx,ax
cmp byte [bx],0
JE no_0

push bx
lea bx,[entera]
push bx
call _prnt
pop bx
pop bx
no_0:

loop sdir2
ret

sdir_help:
lea bx,[sdir_help_text]
push bx
call _prnt
pop bx
ret
sdir_help_text:
db "sdir",13,10
db "Zeigt alle Dateien an.",13,10,0

halt:
lea bx,[boot_end]
push bx
lea bx,[kernel_end]
push bx
push bx
ret

help:
lea bx,[text_help]
push bx
call _prnt
pop cx
ret

sver:
lea bx,[shell_ok]
push bx
call _prnt
pop cx
lea bx,[verfs]
push bx
call _prnt
pop cx
ret

echo:
		cmp dx,0aah
		JE echo_help
		LEA BX,[buffer]
		ADD BX,5
		CMP byte [BX]," "
		JE ECHO_NEW_LINE
		PUSH BX
		CALL _prnt
		POP BX
ret
ECHO_NEW_LINE:
		MOV AL,13
		MOV AH,0EH
		INT 10H
		MOV AL,10
		INT 10H
RET

echo_help:
lea bx,[echo_help_text]
push bx
call _prnt
pop bx
ret
echo_help_text:
db "echo [Text]",13,10
db "Der angegebene Text wird ausgegeben.",13,10,0

text_help:
db "Befehl: |Wirkung:",13,10
db "date:   |Zeigt das aktuelle Datum an.",13,10
db "time:   |Zeigt die aktuelle Zeit an.",13,10
db "cd  :   |Wechselt den Ordner",13,10
db "mkdir:  |Erstelt ein Verzeichnis",13,10
db "cls :   |Leert den Bildschirm",13,10
db "show:   |Gibt den Inhalt beliebiger Dateien aus.",13,10
db "tiny:   |Oeffnet einen kleinen Texteditor",13,10
db "sdir:   |Zeigt alle Dateien an.",13,10
db "help:   |Zeigt diesen Text an.",13,10
db "tasks:  |Zeigt alle laufenden Prozesse an.",13,10
db "kill:   |Beendet einen Prozess.",13,10
db "tsr:    |Setzt den Status eines Programms auf TSR.",13,10
db "sver:   |Zeigt die Versionsnummern der Systemkomponenten",13,10
db "echo:   |Gibt den nachfolgenden Text aus",13,10
db "halt:   |Faehrt das System hinunter",13,10,0

;db 2048-($-beginn_shell) dup(0)
after_shell:

;##
;2.Teil der Shell




db 6144-($-beginn_shell) dup(0)