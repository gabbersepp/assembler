;use16
start:

jmp 07c0h:main

main:
mov ax,cs
mov ds,ax
mov es,ax
cli
mov ax,9000h;9c0h
mov sp,200h
mov ss,ax
push ax
push es
mov ax,0
mov es,ax
mov word [es:21h*4],int21h
mov word [es:21h*4+2],cs
pop es
pop ax
sti

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
boot db "Lade BielOS v0.1",13,10,0
fs1 db "Lade Dateisystem...",13,10,0
intkern db "Lade Interrupts und Kernel...",13,10,0
failed db "Datei nicht gefunden!",13,10,0
max_files dw 170
speicher dw kernel;1d00h
dname db "kernel.bin"
anzahl_cluster dw 4

db 510-($-start) dup(0)
dw 0aa55h

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
iret
;### 

;###Zeichen von Tastatur lesen und ausgeben
rd_z_a:
mov ah,0
int 16h
mov ah,0eh
int 10h
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
mov al," "
mov ah,0eh
int 10h
mov al,8
mov ah,0eh
int 10h
jmp rd_str
;###String einlesen ende

db 1024-($-interrupt) dup(0)


;#################################
;beginn 2.sektor (lba 1)
;inhalt: filetable
;länge: 4Sektoren 4.5.6.7.

filetable:
db "kernel.bin"
dw 1

db "shell.bin",0
dw 2


db 2048-($-filetable) dup(0)
;##################################
;beginn 6. sektor
;inhalt: clusteradressen
;länge: 4sektoren 8.9.10.11.

cluster:

;1.cluster: kernel.bin

dw 1
db 0 ;spur
db 16,17,18,19
db 0 ;head
db 1

dw 2
db 0
db 2,3,4,5
db 1
db 1

dw 3
db 0
db 6,7,8,9
db 1
db 0

dw 4
db 0
db 10,11,12,13
db 1
db 0

db 2048-($-cluster) dup(0)


;###################################
;beginn 10.sektor
;inhalt: c funktionen
;länge 4 sektoren: 12.13.14.15.

inclch:

;GLOBAL _prnt
_prnt:
push bp
mov bp, sp
push ax
push si
mov ax, [bp + 4]
mov si,ax


prnt1:
mov al,[si]
cmp al,0
JE prnte
inc si
mov ah,0eh
int 10h
jmp prnt1

prnte:

pop si
pop ax
pop bp
ret

;GLOBAL _readproc
_readproc:
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
mov si,[bp]
;mov si,kern
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
mov si,[bp]
loop redp_check
jmp redp_check_failed

check_next2:
cmpsw

JE redp_check_ok
add di,2
mov si,[bp]
loop redp_check
jmp redp_check_failed


redp_check_ok:
mov si,di
lodsw ;ax=cluster
jmp read_cluster

redp_check_failed:
;lea bx,[failed]
;push bx
;call _prnt
pop bx
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
pop di
pop dx
pop bx
pop cx
pop si
pop ax
mov ax,[speicher]
add word [speicher],800h
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
mov ah,03h
mov al,4
mov ch,0
mov cl,4
mov dl,0
mov dh,0
lea bx,[filetable]
int 13h

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
db 2048-($-inclch) dup(0)

;#####################################
;beginn 16. sektor
;kernel.bin
kernel:

lea bx,[boot_ok]
push bx
call _prnt
pop cx

lea bx,[shell]
push bx
call _readproc
pop cx
call ax
;push ax

;mov ax,cs
;mov bx,10h
;mul bx
;pop bx
;add ax,bx
;mov bx,10h
;div bx
;mov es,ax

;mov word [sprung+3],ax ;wichtig: hier die Sprungadresse im Code ändern
;pusha
;push es
;push ds
;sprung: call 0a0h:0
;pop ds
;pop es
;popa
kernel_end:
ret
shell db "shell.bin",0
boot_ok db "Ladevorgang beendet.",13,10
lshell db "Lade Shell...",13,10,0
db 2048-($-kernel) dup(0)

;#############################
;beginn 20.sektor
beginn_shell:
mov ax,cs
mov ds,ax
mov es,ax

lea bx,[shell_ok]
push bx
call _prnt
pop cx

;lea bx,[shell]
;push bx
;push bx
;call _checkstr

;##test
;mov ax,0
;push ax
;mov ax,1
;push ax
;lea bx,[shell]
;push bx
;call _writeproc
;pop cx
;pop cx
;pop cx
;jmp $

read_always: ;ab hier wird die Kommandozeile abgefragt
lea bx,[entera]
push bx
call _prnt
pop cx

lea bx,[fd]
push bx
call _prnt
pop cx

mov ah,04h
lea bx,[buffer]
push bx
int 21h
pop bx


;##entferne das erste Leerzeichen nach dem Befehl
mov cx,100
entferne_leer:
cmp byte [bx]," "
JE entferne_ok
inc bx
loop entferne_leer
jmp asdfg
entferne_ok:
mov byte [bx],0
asdfg:

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
jmp after_ok
ok:
add bx,8
mov ax,[bx]
lea bx,[buffer]
add bx,5
call ax
after_ok:
mov cx,100
lea bx,[buffer]
del_buffer: ;###setze buffer wieder auf null
mov byte [bx],0
inc bx
loop del_buffer


jmp read_always

ret
;neu_var dw 0
buffer db 100 dup(0)
anzahl_befehle dw 6
entera db 13,10,0
fd db "fd:>",0
shell_ok db "BielShell v0.1",13,10,0
verfs db "BielFS v0.1",13,10
kernelver db "Kernel v0.01",13,10,0
neu_var dw 0

befehle:
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

tinyedit:

;setze after_shell auf 0
mov cx,2048
mov bx,after_shell
tinyedit1:
mov byte [bx],0
inc bx
loop tinyedit1

lea bx,[after_shell]
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
lea bx,[after_shell]
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
tinyf1 db "Fehler beim speichern",13,10,0
msg1 db "Bitte Dateiname angeben:",13,10,0


sdir:
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

halt:
lea bx,[boot_end]
push bx
lea bx,[kernel_end]
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
;lea bx,[buffer]
;add bx,5
push bx
call _prnt
pop cx
ret

text_help:
db "Befehl: |Wirkung:",13,10
db "tiny:   |Oeffnet einen kleinen Texteditor",13,10
db "sdir:   |Zeigt alle Dateien an.",13,10
db "help:   |Zeigt diesen Text an.",13,10
db "sver:   |Zeigt die Versionsnummern der Systemkomponenten",13,10
db "echo:   |Gibt den nachfolgenden Text aus",13,10
db "halt:   |Faehrt das System hinunter",13,10,0

db 2048-($-beginn_shell) dup(0)
after_shell: