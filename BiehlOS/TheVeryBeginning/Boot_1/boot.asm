org 0

jmp 07c0h:s

s: 

mov ax,7c0h 

mov ds,ax 

mov es,ax 


;### printing boot strings 

;both routines prints only a string 

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

lea bx,[boot_ok] 

pr_str66: 

cmp byte [bx],0 

JE ende6 

mov ah,0eh 

mov al,[bx] 

int 10h 

inc bx 

jmp pr_str66

ende6: 

jmp $ 

bootstr db "Load OS v0.01...",13,10,0 

boot_ok db "OK.",13,10,0 

db 510-$ dup(0) 

dw 0aa55h