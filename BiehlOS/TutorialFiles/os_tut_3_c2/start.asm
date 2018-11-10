[BITS 16]
EXTERN _main
start:

jmp 07c0h:main_entry

main_entry:
mov ax,cs
mov ds,ax
mov es,ax
cli
mov ss,ax
mov sp,9000h
sti


mov ah,02h
mov al,1
mov cl,2
mov ch,0
mov dl,0
mov dh,0
lea bx,[kernel]
int 13h


call _main
jmp $

;##funktion zur Stringausagbe / Begrenzungszeichen: ASCII 0
GLOBAL _prnt
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


GLOBAl _get_char
_get_char:
mov ah,0
int 16h
ret


GLOBAL _boot
_boot db "Der erste C Kernel",13,10,0

times 510-($-$$) db 0
dw 0aa55h

kernel: