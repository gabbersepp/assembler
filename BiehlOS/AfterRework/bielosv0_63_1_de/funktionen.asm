;###################################
;beginn 10.sektor
;inhalt: c funktionen
;länge 4 sektoren: 12.13.14.15.

inclch:

;-----------------------------------------------------------------------------------------
;-- Überprüfe, ob [Parameter] ein Scriptname ist
;-------------------------------------------------------------------------------------------
CHECKSCRIPT:
		PUSH BP
		MOV BP,SP
		PUSH SI
		PUSH DI
		PUSH CX
		
		ADD BP,4
		MOV SI,[BP]
		MOV CX,10
		
CS_START:	
		CMP byte [SI],"."
		JE CS_DOT
		INC SI
		LOOP CS_START
		JMP CS_NO_SCRIPT
		
CS_DOT:
		INC SI
		CMP WORD [SI],"bs"
		JE CS_DOT_NEXT
		JMP CS_NO_SCRIPT
		
CS_DOT_NEXT:
		INC SI
		MOV AX,1
		CMP BYTE [SI],"s"
		JE CS_OK
		
CS_NO_SCRIPT:
		MOV AX,0
		
CS_OK:	POP CX
		POP DI
		POP SI
		POP BP
RET

;-----------------------------------------------------------------------------------------
;-- Überprüfe, wieviele Zeilen das Script hat
;----------------------------------------------------------------------------------------
COUNT_LINE:
CHECKLINE:
		PUSH BP
		MOV BP,SP
		PUSH SI
		PUSH DI
		PUSH CX
		
		XOR AX,AX
		ADD BP,4
		MOV SI,[BP]
		;ADD BP,2
		;MOV CX,[BP]
		mov cx,2048
		
CL_START:
		CMP byte [SI],10
		JE CL_LINE
		INC SI
		loop CL_START
		JMP CL_END
		
CL_LINE:
		INC AX
		INC SI
		LOOP CL_START
		
CL_END:
		POP CX
		POP DI
		POP SI
		POP BP
RET
		
;---------------------------------------------------------------------
;-- Frage die Tastatur ab
;------------------------------------------------------------------------
GETC:
	mov ah,0
	int 16h
RETF

GETC_STRING:
	pusha
	MOV SI,BX
PUSH BX
MOV AX,[GET_CHAR_CS]
MOV BX,[GET_CHAR]
MOV [SPRUNG_GETC+3],AX
MOV [SPRUNG_GETC+1],BX
POP BX
rd_str1:
;		MOV SI,BX
;mov ah,0
;int 16h

SPRUNG_GETC: CALL 07c0h:07c0h
cmp al,13
JE GETC_STRING_ENDE
cmp al,8
JE back1
mov ah,0eh
int 10h
mov [bx],al
JCXZ GETC_STRING_ENDE
dec cx
inc bx
jmp rd_str1
back1:
;lea si,[buffer]
cmp bx,si
JE rd_str1
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
jmp rd_str1
GETC_STRING_ENDE:
popa
RET
		
;------------------------------------------------------------------------------------------
;-- Kopiere Quelle bis [Zeichen] nach Ziel
;---------------------------------------------------------------------------------------
_copy:
;------------------------------------------------------------
		PUSH BP
		MOV BP,SP
		PUSH SI
		PUSH DI
		PUSH CX
		
		ADD BP,4
		MOV AX,[BP]			;Offset Ziel
		ADD BP,2
		MOV DI,[BP]			;offset Quelle
		ADD BP,2
		MOV SI,[BP]			;Zeichen
		MOV CX,0
copy_beginn:
		cmp [di],al
		JE copy_end
		inc cx
		mov ah,[di]
		mov [si],ah
		inc di
		inc si
		jmp copy_beginn

copy_end:
		mov ax,cx
		pop cx
		POP DI
		POP SI
		POP BP
ret
;-----------------------------------------------------------------------------------------
;-- Wandel den Befehl in Kleinbuchstaben um
;------------------------------------------------------------------------------------------
LowToUpperCase:
		push bp
		mov bp,sp
		push si
		push di
		push cx
		ADD BP,4
		MOV SI,[BP]		;SI zeigt auf den String
		ADD BP,2
		MOV CX,[BP]	;Wandle solange um, bis CX=0 oder [si]=0
		
LowToUpperCase_Start:
			MOV AL,[SI]
			CMP AL,0
			JE LTUC_END
			CMP AL,"A"
			JAE LTUC_BIG
LTUC_TEMP:
			INC SI
			LOOP LowToUpperCase_Start
			JMP LTUC_END		;Sicherheitshalber zum Ende springen
			
LTUC_BIG:
			CMP AL,91
			JAE LTUC_TEMP
			ADD byte [SI],32
			INC SI
			LOOP LowToUpperCase_Start
			JMP LTUC_END
			
LTUC_END:
		POP CX
		POP DI
		POP SI
		POP BP
RET
		
BCDToChar:
	MOV AL, CH			; Copy CH to AL
	SHR AL, 4			; Write Hi Nibble to Lo Nibble
	ADD AL, 48			; convert to ASCI
	AND CH, 0Fh			; delete Hi-Nibbel
	ADD CH, 48			; convert to ASCI
RET

CloseFile:
		PUSH SI
		PUSH CX
		PUSH BX
		SUB word [speicher],800h
		MOV CX,2048
		MOV SI,[speicher]
		
CF_START:
		MOV byte [SI],0
		INC SI
		LOOP CF_START
		POP BX
		POP CX
		POP SI
RET

ret
write_int:
push bx
;al=zahl
xor ah,ah
mov bh,10
div bh
mov bl,ah
add al,48
mov ah,0eh
int 10h
mov al,bl
add al,48
int 10h
pop bx
ret


_prnt:
	JMP AFTER_PRNT_DATA
LINE	DB	0
AFTER_PRNT_DATA:
push bp
mov bp, sp
push ax
push si
push cx
mov ax, [bp + 4]
mov si,ax


;###
;test

xor dx,dx
;mov si,ax
mov ah,0eh
mov cx,2048
show_schleife:
lodsb
cmp al,0
JE show_ende
;cmp al,0
;JE null
inc dl
int 10h
cmp dl,80
JE show_80
cmp al,10
JE show_80
;null:
loop show_schleife
jmp show_ende

show_80:
mov dl,0
inc dh
cmp dh,20
JE show_24
loop show_schleife
jmp show_ende

show_24:
mov dx,0
lea bx,[show_next_line]
push bx
call _prnt
pop bx
mov ah,0h
int 16h
mov ah,0eh
loop show_schleife

show_ende:

pop cx
pop si
pop ax
pop bp

ret
;GLOBAL _readproc
_readproc:
	JMP AFTER_READ_DATA
DAT_N	DW 0
AFTER_READ_DATA:

;dateiname auf Stack
push bp
mov bp,sp
push ax
push si
push cx
push bx
push dx
push di
;mov ax,[bp+6]
;add bp,6
;mov ax,[bp]
;sub bp,6
;mov [adr],ax
add bp,4
lea di,[filetable]
mov [ret1],di
mov si,[bp]
MOV AX,SI
MOV [DAT_N],AX
;----------------------------------
;-- Wandle Dateiname zu Kleinbuchstaben um
		MOV CX,10
		PUSH CX
		PUSH SI
		CALL LowToUpperCase
		POP SI
		POP CX
;mov si,kern
cmp byte [si],0
JE redp_check_failed
mov cx,max_files
redp_check:
cmpsd
JE check_next4

add di,8
mov si,[bp]
loop redp_check
jmp redp_check_failed

check_next4:
cmpsd
JE check_next2
add di,4
mov [ret1],di
mov si,[bp]
loop redp_check
jmp redp_check_failed

check_next2:
cmpsw

JE redp_check_ok
add di,2
mov [ret1],di				;ret1 hat nun die Adresse des Dateinamens
mov si,[bp]
loop redp_check
jmp redp_check_failed

redp_check_ok:
mov si,di
mov [ret1],di
lodsw ;ax=cluster
jmp read_cluster

redp_check_failed:
;lea bx,[failed]
;push bx
;call _prnt
pop di
pop dx
pop bx
pop cx
pop si
pop ax
mov ax,0 ;0=fehler
pop bp
ret


read_cluster:

lea si,[cluster]
mov bx,ax

rd_cl:
lodsw
cmp ax,bx
JE right_cluster
add si,7
cmp byte [si],0aah
JnE rd_cl
jmp redp_check_failed

right_cluster:
MOV word [ret2],AX
;push bp
;push ax
;push si
;push cx
;push bx
;push dx
;push di
;lea si,[cluster]
;inc si
;inc si

mov ah,02h
mov al,4
mov ch,[si]
inc si
mov cl,[si]
inc si
inc si
inc si
inc si
mov dl,0
mov dh,[si]
;lea bx,[kernel]
;mov bx,[adr]
mov bx,[speicher]

int 13h

;-------------------------------
;-- schreibe processtable
;---
;-- copy: ziel, quelle, zeichen
		LEA SI,[PROCESS_TABLE]
		ADD SI,2
		INC WORD [TABLE_NUM]
		
		MOV CX,113		;Maximale Anzahl an Einträgen
		
CHECK_PT_0:
		CMP BYTE [SI],0
		JE CHECK_PT_0_OK
		ADD SI,15		;Zeige auf nächsten Eintrag
		LOOP CHECK_PT_0
		JMP CHECK_PT_0_FAILED
		
CHECK_PT_0_OK:
		MOV AX,[TABLE_NUM]
		MOV [SI],AL
		INC SI
		;INC SI
		MOV BYTE [SI],0
		INC SI
		MOV AX,[speicher]
		MOV [SI],AX
		INC SI
		INC SI
		
		MOV AX,[DAT_N]
		PUSH SI
		PUSH AX
		PUSH WORD 0
		CALL _copy
		POP SI
		POP AX
		POP AX
CHECK_PT_0_FAILED:
pop di
pop dx
pop bx
pop cx
pop si
pop ax
mov ax,[speicher]
add word [speicher],2048;800h
pop bp
ret


;GLOBAL _checkstr
_checkstr:
push bp
mov bp,sp
add bp,4
push si
push di
push cx
push bx
push ax

mov si,[bp]
add bp,2
mov di,[bp]

_checkstr1:
lodsb
mov cl,[di]
inc di
cmp cl,0
Je _checkstr1ende
cmp al,0
JE _checkstr1ende
cmp cl,al
JE _checkstr1

_checkstr1ende:

pop si
mov bx,ax
mov ax,1
cmp bl,cl
Je string_ok

mov ax,0 ;0=fehler

string_ok:

pop bx
pop cx
pop di
pop si
pop bp
ret

;GLOBAL _get_char
_get_char:
mov ah,0h
int 16h
ret

;GLOBAL _writeproc
_writeproc:
push bp
mov bp,sp
push si
push di
push ax
push bx
push cx
push dx

add bp,4
mov si,[bp];[si]=dateiname
add bp,2
mov ax,[bp] ;ax=0:nicht überschreiben/1:überschreiben
add bp,2
mov dx,[bp]

sub bp,4

lea di,[filetable]
mov cx,[max_files]

write_proc_schleife: ;dateiname erstmal suchen
write_proc_check_4:
cmpsd
JE write_proc_check_next4
add di,8
mov si,[bp]
loop write_proc_schleife
jmp write_proc_no_string

write_proc_check_next4:
cmpsd
JE write_proc_check_next2
add di,4
mov si,[bp]
loop write_proc_schleife
jmp write_proc_no_string

write_proc_check_next2:
cmpsw
JE write_proc_check_string
add di,2
mov si,[bp]
loop write_proc_schleife
jmp write_proc_no_string

write_proc_check_string:
cmp ax,0 ;=nicht überschreiben
JE write_proc_failed
mov si,di
lodsw ;ax=clusternummer
mov bx,ax
jmp write_proc_write_filetable_ok

write_proc_no_string:
;suche als erstes freien Cluster
;schreibe dann dateinamen+cluster in filetable
lea si,[cluster]
mov cx,[anzahl_cluster]

write_proc_check_cluster:
add si,8
lodsb
cmp al,0
JE write_proc_check_cluster_ok
loop write_proc_check_cluster
mov ax,1 ;ax=1=kein freier cluster
jmp write_proc_failed

write_proc_check_cluster_ok:
sub si,1
mov byte [si],1
sub si,8			;[si]=clusternummer WORD
lodsw 				;ax=cluster
mov bx,ax

lea si,[filetable]
mov cx,[max_files]

write_proc_check_filename:
lodsb
cmp al,0
JE write_proc_check_filename_ok
add si,11
loop write_proc_check_filename
mov ax,2 ;ax=2=kein Filetable eintrag mehr möglich
jmp write_proc_failed

write_proc_check_filename_ok:
sub si,1
mov di,si
mov si,[bp]

mov cx,5
rep movsw ;dateiname wird kopiert
mov [di],bx
push bx
push dx
;schreibe speicher cluster+table auf fd

;------------------------------------------------------
;-- dir_cluster=clusternummer des aktuellen dirs
;-- suche cluster und setze daten ein
;-----------------------------------------------------

		PUSH SI
		PUSH BX
		PUSH AX
		LEA SI,[cluster]
		MOV BX,[dir_cluster]

RD_W_CL:
		LODSW
		CMP AX,BX
		JE RD_W_CL_RCL
		ADD SI,7
		CMP BYTE [si],0AAh
		JnE RD_W_CL
		MOV AX,6				;AX=6=Fehler: Clusterstrucktur zerstört
		POP AX
		POP BX
		POP SI
		JMP write_proc_failed
		
RD_W_CL_RCL:
		MOV CH,[SI]
		INC SI
		MOV CL,[SI]
		INC SI
		INC SI
		INC SI
		INC SI
		MOV DH,[SI]
		MOV DL,0
		MOV AH,03H
		LEA BX,[filetable]
		INT 13h

		POP AX
		POP BX
		POP SI
		
;mov ah,03h
;mov al,4
;mov ch,0
;mov cl,4
;mov dl,0
;mov dh,0
;lea bx,[filetable]
;int 13h

mov ah,03h
mov al,4
mov cl,8
mov ch,0
mov dl,0
mov dh,0
lea bx,[cluster]
int 13h
pop dx
pop bx

write_proc_write_filetable_ok:
;bx=cluster
;dx=adresse
lea si,[cluster]
mov cx,[anzahl_cluster]

write_proc_search_clusterBX:

lodsw
cmp ax,bx
JE write_proc_search_clusterBX_ok
add si,7
loop write_proc_search_clusterBX
mov ax,4 ;ax=4=cluster nicht gefunden
jmp write_proc_failed

write_proc_search_clusterBX_ok:

mov bx,dx
mov ah,3h
mov al,4
mov ch,[si]
inc si
mov cl,[si]
add si,4
mov dh,[si]
mov dl,0

int 13h

;inc word [anzahl_cluster]
;mov ah,03h
;mov al,1
;mov cl,1
;mov ch,0
;mov dl,0
;mov dh,0
;mov bx,0
;int 13h

pop dx
pop cx
pop bx
pop ax
mov ax,0
pop di
pop si
pop bp
ret

write_proc_failed:

pop dx
pop cx
pop bx
pop di
pop di
pop si
pop bp
ret

;####Rückgabe Variablen
ret1 dw 0
ret2 dw 0
ret3 dw 0
db 2048-($-inclch) dup(0)