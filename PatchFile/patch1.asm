Daten Segment
v1 db "halli","$"
Daten Ends
Code Segment
start:
mov ax,daten
mov ds,ax

lea dx,v1
mov ah,09h
int 21h

mov ah,4ch
int 21h

Code Ends
end start