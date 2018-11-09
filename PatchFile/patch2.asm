daten segment
vn db "patch1.exe","0"
stelle dw 512
buffer dw 544
handle dw ?
nstr db "Bingo$"
buffer1 db 544 dup(0)
daten ends
code segment
assume cs:code,ds:daten
start:
mov ax,daten
mov ds,ax

mov ah,3dh
lea dx,vn
mov al,2
int 21h
jc ende


mov bx,ax
mov handle,ax
mov ah,3fh
mov cx,buffer
lea dx,buffer1
int 21h
jc ende





schleife:
lea bx,buffer1
add bx,stelle
lea si,nstr

schleife2:
cmp [si],byte ptr "$"
JE schleife2e
mov dl,byte ptr [si]
mov [bx],dl
inc si
inc bx
jmp schleife2


schleife2e:
mov ah,41h
lea dx,vn
int 21h

mov ah,3ch
lea dx,vn
int 21h

mov handle,ax

mov ah,40h
mov bx,handle
mov cx,buffer
lea dx,buffer1
int 21h
jc ende

mov ah,3eh
mov bx,handle
int 21h

ende:
mov ah,4ch
int 21h
code ends
end start