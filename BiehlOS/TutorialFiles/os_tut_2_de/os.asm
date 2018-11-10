;0000:07c0h
;Beginn bei 07ch:0000h

org 0
jmp 07c0h:s

;Zuerst mal benötigen wir einige Daten

bootstr db "Lade BielOS v1.3...",13,10,0
boot_ok db "OK.",13,10,0
load_int db "Lade Int21h Funktionen...",13,10,0
load_int_def db "Lade Int21h Definitionen...",13,10,0
load_kern db "Lade Kernel...",13,10,0
kern_ver db "BielOS Kernel v1.0 (C) 2005 by Josef Biehler",13,10,0
end_str db "Der PC kann ausgeschaltet werden.",13,10,0

s:
mov ax,7c0h
mov ds,ax
mov es,ax

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

;##gib “OK” aus
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

;##gib Meldung aus
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

;###Interruptsektor (Interruptfunktionen) nachladen
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

;###gib Meldung aus
lea bx,[load_kern]
mov ah,01h
int 21h

;###lade Kernel
mov ah,02h
mov al,2
mov ch,0
mov cl,4
mov dh,0
mov dl,0
mov bx,800h
int 13h

;##rufe Kernel auf
call kernel


;##gibe meldung aus
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
iret

db 1024-($-400h) dup(0)
kernel:
lea bx,[kern_ver]
mov ah,01h
int 21h

;###springe zurück
back_jmp:

ret

db 1024-($-800h) dup(0)
