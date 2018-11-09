
;0000:07c0h
;Beginn bei 07ch:0000h

org 0
jmp 07c0h:s

s:
mov ax,7c0h
mov ds,ax
mov es,ax


;###daten laden
mov ah,02h
mov al,1
mov ch,0
mov cl,7
mov dl,0
mov dh,0
mov bx,0c00h
int 13h

;### Bootstrings ausgeben
lea bx,[bootstr]
pr_str6:
cmp byte [bx],0
JE ende
mov ah,0eh
mov al,[bx]
int 10h
inc bx
jmp pr_str6
ende:

lea bx,[load_int_def]
pr_str66:
cmp byte [bx],0
JE ende6
mov ah,0eh
mov al,[bx]
int 10h
inc bx
jmp pr_str66
ende6:

;###Interruptdefinition nachladen
mov ah,02h
mov al,1
mov ch,0
mov cl,2
mov dl,0
mov dh,0
mov bx,200h
int 13h


lea bx,[boot_ok]
pr_str666:
cmp byte [bx],0
JE ende66
mov ah,0eh
mov al,[bx]
int 10h
inc bx
jmp pr_str666
ende66:

lea bx,[load_int]
pr_str6666:
cmp byte [bx],0
JE ende666
mov ah,0eh
mov al,[bx]
int 10h
inc bx
jmp pr_str6666
ende666:

;###Interruptsektor nachladen
mov ah,02h
mov al,2
mov ch,0
mov cl,3
mov dl,0
mov dh,0
mov bx,400h
int 13h


;### Int 21h setzen
mov ax,0
mov es,ax
cli
mov word [es:4*21h],int21h
mov word [es:4*21h+2],cs
mov ax,09000h
mov ss,ax
mov sp,100
sti

mov ax,7c0h
mov es,ax



;##ab hier beginnt der "richtige" bootloader
;### "ok" ausgeben
mov ah,01h
lea bx,[boot_ok]
int 21h

;###lade kernel
lea bx,[load_kern]
mov ah,01h
int 21h

mov ah,02h
mov al,2
mov ch,0
mov cl,5
mov dh,0
mov dl,0
mov bx,800h
int 13h

;jmp 07c0h:kernel
call kernel
asd:


mov ah,01h
lea bx,[end_str]
int 21h

jmp $
db 510-$ dup(0)
dw 0aa55h


;####################################################################
;###beginn 2. Sektor bei 200h


;###Int 21h
int21h:
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
cmp ah,05h
JE searchg
cmp ah,06h
JE write
mov al,1  ;Fehlercode
int21h_e:
iret
;###Int 21h Ende


db 512-($-200h) dup(0)

;###################################################################
;###beginn 3. und 4. Sektor bei 400h

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
mov ah,0eh
int 10h
mov [bx],al
inc bx
jmp rd_str
;###String einlesen ende

;###Programm an 8000h laden
;al=kennung
searchg:
mov byte [addi],0h
;mov si,1400h
lea si,[bielfs]
mov cl,[anzahl_max_fs]
xor ch,ch
;mov bx,8000h
search:
add si,8
add si,3
push ax
cmp byte [si],al
JE search_ok
after_search_ok:
pop ax
add si,5
loop search

;###programm nicht gefunden
cmp byte [addi],1h
JE found
;lea si,[fehler]
mov al,1 ;al=1=Fehler
jmp int21h_e
;pr_str5:
;cmp byte [si],0
;JE int21h_e
;mov ah,0eh
;mov al,[si]
;int 10h
;inc si
;jmp pr_str5

search_ok:
mov [addi],1 ;wurde ein Programm gefunden?
sub si,3
mov al,1
mov ah,02h
mov cl,[si]
inc si
mov ch,[si]
inc si
mov dh,[si]
mov dl,0
int 13h
add bx,200h
inc si
jmp after_search_ok
found:
xor al,al
iret
;###ende

;####Programm auf FD schreiben
kenn db 0
write:
mov  [addi],0
mov [spur],0
mov [kopf],0
mov [sek],0
mov [kenn],al
push bx
mov si,0e00h ;freier Sektorcounter laden
schl_write:
lodsw
cmp word ax,0
JA schl_write_ok
jmp schl_write

schl_write_ok:
push es
mov fs,si
xor dx,dx
mov gs,ax
mov es,ax ;ax (freien Sektor zwischenspeichern)
mov bx,1440
div bx
;AX=quotient=kopf
mov [kopf],al
xor dx,dx
mov ax,es
;mov bx,18
mov bx,19
div bx
;Ax=quotient=spur
mov [spur],al
mov ah,18
mov ah,19
mul ah
xor ah,ah
mov cx,ax
mov ax,es
sub ax,cx
;ax=echter Sektor
mov cl,al
xor ah,ah
;mov gs,ax
mov [sek],al
mov ch,[spur]
mov dh,[kopf]
mov dl,0
mov ax,07c0h
mov es,ax
pop es
pop bx
mov ah,03h
mov al,1
int 13h

;###
;ab hier Datzeisystemeintreag hinzufügen
;mov bx,0e00h ;Filetrable laden
;mov si,0e00h
;mov cl,[sek]
;xor ch,ch
;mov cx,gs
;fs_search: ;sektornummer suchen und durch 0 ersetzen
;lodsw
;cmp ax,cx
;JE fs_search_ok
;jmp fs_search
;fs_search_ok:
mov di,fs
dec di
dec di
mov ax,0
stosw
;mov bx,ax
;mov word [ds:si],0000h

lea si,[anzahl_fs]
lodsb
inc al
lea di,[anzahl_fs]
xor ah,ah
stosb


mov ch,0
mov dh,0
mov dl,0
mov cl,7
mov ah,03h
mov al,2
mov bx,0c00h
int 13h



;mov bx,1400h
lea bx,[bielfs]
xor ax,ax
mov al,[anzahl_fs]
dec al
mov cx,16
mul cx
add bx,ax
add bx,8
mov al,[sek]
mov [bx],al
;ch=spur
inc bx
mov al,[spur]
mov [bx],al
inc bx
mov al,[kopf]
mov [bx],al
inc bx
mov al,[kenn]
mov [bx],al

mov ch,0
mov dh,0
mov dl,0
mov cl,9
mov ah,03h
mov al,2
;mov bx,1400h
lea bx,[bielfs]
int 13h

iret

db 1024-($-400h) dup(0)


;#########################################################
;beginn 5. und 6. Sektor bei 800h

kernel:
lea bx,[kern_ver]
mov ah,01h
int 21h

mov ah,01h
lea bx,[load_fs]
int 21h

mov ah,02h
mov al,4
mov ch,0
mov cl,8
mov dh,0
mov dl,0
mov bx,0e00h
int 13h

Lea bx,[fs1]
mov ah,01h
int 21h



;programm laden
;mov ah,05h
;int 21h

;cmp al,1
;JE failed

;mov al,49
;mov ah,05h
;int 21h

;mov ah,06h
;mov al,50
;mov bx,8000h
;int 21h

;mov ah,0h
;int 16h
;mov ah,0eh
;int 10h
;#kennung ist nun in al

;programm laden
;mov ah,05h
;int 21h

;jump:
;call 07c0h:8000h
;back_jmp:

mov ah,01h
lea bx,[load_shell]
int 21h

mov ah,05h
mov al,"S"
mov bx,1600h
int 21h


mov ax,1600h
push ax
ret

back_jmp:

pop ax
lea bx,[asd]
push bx
ret

;failed:
;lea bx,[fehler]
;mov ah,01h
;int 21h
;jmp back_jmp

db 1024-($-800h) dup(0)
;############################################################
;beginn 7. Sektor bei c00h
addi db 0
spur db 0
kopf db 0
sek db 0
anzahl_fs db 6
anzahl_max_fs db 64
byt db 0
entera db 13,10,0
bootstr db "Lade BielOS v1.3...",13,10,0
boot_ok db "OK.",13,10,0
load_int db "Lade Int21h Funktionen...",13,10,0
load_int_def db "Lade Int21h Definitionen...",13,10,0
load_kern db "Lade Kernel...",13,10,0
kern_ver db "BielOS Kernel v1.0 (C) 2005 by Josef Biehler",13,10,0
end_str db "Der PC kann jetzt ausgeschaltet werden.",13,10,0
load_fs db "Lade BielFS Dateisystem...",13,10,0
fs1 db "BielFS v0.5 (C) 2005 by Josef Biehler",13,10,0
load_shell db "Lade Shell...",13,10,0
fehler db "Programm nicht gefunden!",13,10,0
db 512-($-0c00h) dup(0)


;#########################################################
;beginn 8.  Sektor bei e00h
dw 19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,45,46,47,47,49,50,51,52,53,54,56,57,58,59,60
;80 Spuren
;18 Sektoren/Spur
;2880 gesamtsektoren
db 512-($-0e00h) dup(0)

;###########################################################
;beginn 9. Sektor bei 1000h
;maximal 32 einträge
;###erster Dateisystemeintrag
;Sektornummer,spur,seite,kennung
bielfs:
db "shell.os"
db 12,0,0,"S",0,0,0,0
db "shell.os"
db 13,0,0,"S",0,0,0,0
db "shell.os"
db 14,0,0,"S",0,0,0,0
db "shell.os"
db 15,0,0,"S",0,0,0,0
db "shell.os"
db 16,0,0,"S",0,0,0,0
db "test1.os"
db 17,0,0,"a",0,0,0,0

db 1024-($-1000h) dup(0)

;###########################################################
;beginn 11.Sektor bei 1400h
;maximal 32 einträge
;###erster Dateisystemeintrag
;Sektornummer,spur,seite,kennung
;bielfs:
;db "shell.os"
;db 12,0,0,"S",0,0,0,0
;db "shell.os"
;db 13,0,0,"S",0,0,0,0
;db "test1.os"
;db 14,0,0,"a",0,0,0,0
db 512-($-1400h) dup(0)

;##########################################################
;beginn 12.Sektor bei 1600h
;Shell
jmp af_data
sh db "help eingeben um Hilfe zu erhalten",13,10,0
tab db "            ",0
x512 db " x 512 Bytes",0
shell db "BielShell v1.0 (C) 2005 by Josef Biehler",13,10,0
disk db 13,10,"fd:",0
ver db "BielOS v1.3",13,10,"BielOS Kernel v1.0",13,10,"BielFS v0.5",13,10,"BielShell v1.0",13,10,0
anzahl_commands db 9
wcmd db "Unbekannter Befehl!",13,10,0
buffer db 100 dup(0)
af_data:
mov ah,01h
lea bx,[shell]
int 21h
mov ah,01h
lea bx,[sh]
int 21h
;lade befehlsliste
lea bx,[befehlsliste]
mov ah,05h
int 21h

;##ab hier beginnt die Commandshell "richtig"
;lese ständig die Kommandzeile




;mov ah,06h
;mov bx,0h
;mov al,"f"
;int 21h

;mov ah,05h
;mov al,"f"
;mov bx,2000h
;int 21h
;call 2000h
;jmp $
;mov ah,03
;mov dx,0
;mov cl,1
;mov ch,1
;mov al,1
;mov bx,0
;int 13h

;mov ah,02h
;,mov dx,0
;,mov cl,1
;mov ch,1
;mov al,1
;mov bx,3000h
;int 13h
;call 3000h
;jmp $

read_always:
mov ah,01h
lea bx,[disk]
int 21h

mov ah,04h
lea bx,[buffer]
int 21h

lea bx,[entera]
mov ah,01h
int 21h



lea edi,[befehlsliste]
lea esi,[buffer]
add esi,5
mov cl,[anzahl_commands]
xor ch,ch
;edi auf "h"
;esi auf 2. Zeichen nach "proc"
search_cmd:
cmpsd
JE search_cmd_ok
lea esi,[buffer]
add edi,2
loop search_cmd
jmp wrong_cmd

search_cmd_ok:
mov esi,edi
lodsw
xor bx,bx
call ax

jmp read_always

wrong_cmd:
lea bx,[wcmd]
mov ah,01h
int 21h
jmp read_always

db 1024-($-1600h) dup(0)

;########################################################
;beginn 14. 15. 16. sektor bei 1a00
befehlsliste:

dd "null"
dw halt
dd "sver"
dw sver
dd "prnt"
dw prnt
dd "halt"
dw halt
dd "help"
dw help
dd "sdir"
dw sdir
dd "proc"
dw proc
dd "set "
dw set
dd "date"
dw date

date:
cmp bx,0AAAAH
JE date_set

mov al,6h ;6=aktueller Tag
out 70h,al
in al,71h

;prüfe den Tag
mov bl,al
lea si,[tage]
mov cx,7
check_day:
lodsb
cmp bl,al
JE check_day_ok
lodsw
loop check_day
check_day_ok:
lodsw
mov bx,ax
mov al,bl
mov ah,0h
int 21h
mov al,bh
mov ah,0h
int 21h
mov al," "
mov ah,0h
int 21h

;monatstag ausgeben
mov al,7h
out 70h,al
in al,71h
xor ah,ah
mov bl,10
div bl	;ah=rest/al=ergebnis
push ax
xor ah,ah
add al,48
int 21h
pop ax
mov al,ah
add al,48
mov ah,0
int 21h
mov al,"."
mov ah,0h
int 21h

;monat ausgeben
mov al,8
out 70h,al
in al,71h
xor ah,ah
mov bl,10
div bl	;ah=rest/al=ergebnis
push ax
xor ah,ah
add al,48
int 21h
pop ax
mov al,ah
add al,48
mov ah,0
int 21h
mov al,"."
mov ah,0h
int 21h

mov al,9h
out 70h,al
in al,71h
xor ah,ah
mov bl,10
div bl	;ah=rest/al=ergebnis
push ax
xor ah,ah
add al,48
int 21h
pop ax
mov al,ah
add al,48
mov ah,0
int 21h


ret

date_set:

;mov al,6
;out 70h,al
;mov al,7
;out 71h,al

ret



tage:
db 1
db "SO"
db 2
db "MO"
db 3
db "DI"
db 4
db "MI"
db 5
db "DO"
db 6
db "FR"
db 7
db "SA"

ret




set:
lea edi,[befehlsliste]
lea esi,[buffer]
add esi,4
mov cl,[anzahl_commands]
xor ch,ch

search_cmd_set:
cmpsd
JE search_cmd_ok_set
lea esi,[buffer]
add esi,4
add edi,2
loop search_cmd_set
jmp wrong_cmd_set

search_cmd_ok_set:
mov esi,edi
lodsw

;buffer um 4 Bytes verschieben
lea si,[buffer]
add si,4
mov di,3000h
mov cx,100
schiebe:
movsb
loop schiebe
mov cx,100
mov si,3000h
lea di,[buffer]
schiebe2:
movsb
loop schiebe2



mov bx,0AAAAh
call ax
ret
wrong_cmd_set:
lea bx,[wcmd]
mov ah,01h
int 21h
ret

proc:

;lea esi,[buffer]
;lodsw
;cmp word ax,"pr"
;JnE noprog
;lodsw
;cmp word ax,"oc"
;JnE noprog

lea esi,[buffer]
add esi,5
;inc esi


;ds:esi
;es:edi
;cmpsd

;#ab hier wird der eingegebene programmname mit dem FS verglichen
mov cl,[anzahl_max_fs]
xor ch,ch
lea edi,[bielfs]
xor dx,dx

search_prog_name:
cmpsd
JE prog_right_fs1
mov dl,0
jmp prog_wrong_fs

prog_right_fs1:
mov dl,1

cmpsd
JE prog_right_fs2
mov dh,0
jmp prog_wrong_fs

prog_right_fs2:
add edi,3
mov al,[edi]
mov ah,05h
mov bx,8000h
int 21h
call 0fc0h:0h
;jmp read_always ;erneut abfragen
;programm kann geladen werden
ret ;wieder lesen

prog_wrong_fs:
cmp dl,0
JE first_0
cmp dh,0
JE second_0

first_0:
;Ersten 4 Buchstaben stimmen nicht überein
mov esi,edi
lodsd
lodsd
lodsd
mov edi,esi
lea esi,[buffer]
add esi,5
mov fs,si
loop search_prog_name
jmp falsch ;Programm nicht gefunden

second_0:
;2. 4 Zeichen falsch
mov esi,edi
lodsd
lodsd
mov edi,esi
lea esi,[buffer]
add esi,5
mov gs,di
loop search_prog_name
;jmp falsch ;Programm nicht gefunden


falsch:
;#programm nicht gefunden
lea bx,[fehler]
mov ah,01h
int 21h
jmp read_always

ret

sdir:
;an Stelle 3000h wird ein buffer reserviert
mov bx,3000h
mov cx,0ffh
set_0:;den speicher auf 0 setzen
mov byte [bx],0h
inc bx
loop set_0
;##jetzt BielFS duirchgehen, und an Stelle [3000h+kennung] 1 scheiben
mov bx,3000h
mov cl,[anzahl_fs]
xor ch,ch
lea si,[bielfs]
set_1:
mov di,4000h
mov bp,4600h
add si,11
lodsb
mov ah,0h
add bx,ax
add bp,ax
inc byte [bp]
mov byte [bx],1
;int 21h
mov byte [5000h],2
mul byte [5000h]
add di,ax
dec si
mov word [di],si
inc si
add si,4
mov bx,3000h
loop set_1

mov si,4000h
mov cx,0ffh
mov bx,3000h

show:
cmp byte [bx],1
JE eins_ok
inc bx
loop show

jmp show_eins_ende
eins_ok:
mov byte [bx],0
mov cx,0ffh
mov bp,4600h
sub bx,3000h
add bp,bx
mov ax,bx
xor bx,bx
mov dx,2
mul dx
;mul byte [5000h]
;mov byte [5000h],2
mov si,4000h
add si,ax
mov word ax,[si]
mov gs,si
mov si,ax
;mov al,[si]
mov ah,0h
;int 21h


;hier muss nun der Dateiname ausgegeben werden
sub si,11
mov dx,8
prnt_dir:
mov ah,0h
mov al,[si]
int 21h
dec dx
cmp dx,0
JE prnt_dir_end
inc si
jmp prnt_dir
prnt_dir_end:
mov ah,1
lea bx,[tab]
int 21h
add byte [bp],48
mov al,[bp]
mov ah,0h
int 21h
lea bx,[x512]
mov ah,01h
int 21h
lea bx,[entera]
mov ah,01h
int 21h
mov bx,3000h
xor ax,ax
xor dx,dx
mov si,0
mov di,0
mov cx,0ffh
loop show
show_eins_ende:
mov bp,4600h
mov cx,0ffh
set_again_0:
mov byte [bp],0
inc bp
loop set_again_0
ret



help:
lea bx,[befehle]
mov ah,1h
int 21h
ret

sver:
lea bx,[ver]
mov ah,01h
int 21h
ret

prnt:
lea si,[buffer]
add si,5
prnt1:
lodsb
cmp al,0h
JE prnte
mov ah,0h
int 21h
jmp prnt1
prnte:
ret

halt:
pop bx
lea bx,[back_jmp]
push bx
ret


befehle:
db "Befehl:|Wirkung:",13,10
db "help  :|Zeigt diesen Text an.",13,10
db "sdir  :|Zeigt alle Dateien an.",13,10
db "sver  :|Zeigt die Versionsnummern der OS Komponenten an.",13,10
db "prnt  :|Gibt die nachfolgende Zeichenkette aus.",13,10
db "proc  :|Startet das nachfolgende Programm.",13,10
db "date  :|Gib aktuelles Datum aus.",13,10
db "set   :|Hilft Einstellungen eines Programmes bzw. eines Befehls zu ändern.",13,10
db "halt  :|Faehrt das System hinunter.",13,10,0
db 1536-($-1a00h) dup(0)
;#######################################################
;beginn 17. sektor bei 2000h
programm:
mov bx,9600h
mov ah,0h
mov al,"!"
int 21h
retf

db 512-($-2000h) dup(0)



