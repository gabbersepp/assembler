use16
start:

jmp 07c0h:main

main:
mov ax,cs
mov ds,ax
mov es,ax
cli
mov ax,9000h;9c0h
mov ss,ax
mov sp,200h
push ax
push es
mov ax,0
mov es,ax
mov word [es:21h*4],int21h
mov word [es:21h*4+2],cs
		MOV WORD [ES:6H*4],INT6H
		MOV WORD [ES:6H*4+2],CS
pop es
pop ax
sti
;push ax

mov ah,0
mov al,2
int 10h

mov ah,02h
mov al,4
mov cl,12
mov ch,0
mov dl,0
mov dh,0
lea bx,[inclch]
int 13h

lea bx,[boot]
push bx
call _prnt
pop cx

lea bx,[fs1]
push bx
call _prnt
pop cx

mov ah,02h
mov al,4
mov ch,0
mov cl,4
mov dl,0
mov dh,0
lea bx,[filetable]
int 13h

mov ah,02h
mov al,4
mov cl,8
mov ch,0
mov dl,0
mov dh,0
lea bx,[cluster]
int 13h

lea bx,[intkern]
push bx
call _prnt
pop cx

mov ah,02h
mov al,4
mov cl,2
mov ch,0
mov dl,0
mov dh,0
lea bx,[interrupt]
int 13h

lea bx,[dname]
push bx
call _readproc
pop cx
call ax;1e00h

boot_end:
lea bx,[ende]
push bx
call _prnt
pop cx
jmp $

ende db "Der PC kann jetzt ausgeschaltet werden.",13,10,0
boot db "Lade BielOS v0.63",13,10,0
fs1 db "Lade Dateisystem...",13,10,0
intkern db "Lade Interrupts und Kernel...",13,10,0
failed db "Datei nicht gefunden!",13,10,0
max_files dw 170
speicher dw kernel;1d00h
dname1 db "kernel.bin"
anzahl_cluster dw 17
GET_CHAR dw GETC
GET_CHAR_CS dw 0
dname db "kernel.bin"
db 510-($-start) dup(0)
dw 0aa55h