include 'boot.asm'

include 'interrupt.asm'

include 'bielfs.asm'


include 'funktionen.asm'


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
key_g db "key_g.sys",0
db 2048-($-kernel) dup(0)

include 'shell.asm'

after_shell2:
db "Hilfedatei für BielOS.",13,10
db "Der Parameter eines jeden Befehls ist mit angegeben.",13,10
db "Steht der Parameter in eckigen Klammern, so ist er optional.",13,10
db "Die Befehlszeile kann maximal 100 Zeichen aufnehmen.",13,10
;db "Es wird nicht überprüft, ob das Maximum eingehalten wird.",13,10
db "Normalerweise kann durch den Parameter -? eine kurze Hilfe aufgerufen werden.",13,10
db "Dies gilt allerdings NICHT fuer die eingebaute Scriptsprache.",13,10
db "z.b.: tiny -?",13,10
;db "Es wird zwischen Groß und Kleinschreibung unterschieden!",13,10
db 13,10
db "-------------",13,10
db "echo [text] = Der Text nach dem ersten Lerzeichen wird ausgegeben.",13,10
db "wird kein Text mit angegeben, so wid nichts ausgegeben.",13,10
db "-------------",13,10
db "halt = Das System wird runtergefahren.",13,10
db "-------------",13,10
db "sver = Es werden die Versionsnummern des Kernels, der Shell und"
db " des Dateisystemes angezeigt.",13,10
db "-------------",13,10
db "help = Zeigt eine kurze Hilfe an zu allen Befehlen.",13,10
db "-------------",13,10
db "sdir = Zeigt alle Dateien im Ordner an.",13,10
db "-------------",13,10
db "tiny = Oeffnet einen kleinen Texteditor.",13,10
db "-------------",13,10
db "time (date) = Zeigt aktuelle(s) Zeit (Datum) an.",13,10
db "-------------",13,10
db "cls = Leert den Bildschirm.",13,10
db "-------------",13,10
db "mkdir <Verzeichnisname> = Erstellt im aktuellen Ordner einen weiteren Ordner.",13,10
db "-------------",13,10
db "cd <Verzeichnisname> = Wechselt in das angegebene Verzeichnis.",13,10
db "-------------",13,10
db "show <dateiname> = Es wird die angegebene Datei ausgelesen und"
db " ausgegeben.",13,10,0
db 2048-($-after_shell2) dup(0)
STATUS_PROC:

file 'status.bin'

;include 'key.asm'
db "hilf.txt",0,0
dw 4
db "..",0,0,0,0,0,0,0,0
dw 6

