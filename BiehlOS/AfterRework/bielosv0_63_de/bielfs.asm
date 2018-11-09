
;#################################
;beginn 2.sektor (lba 1)
;inhalt: filetable
;länge: 4Sektoren 4.5.6.7.

filetable:
db "kernel.bin"
dw 1
db "shell.bin",0
dw 2
db "help.txt",0,0
dw 4
db "shell.lib",0
dw 3
db "asd",0,0,0,0,0,0,0
dw 7
db "status.os",0
dw 5

db 2048-($-filetable) dup(0)
;##################################
;beginn 6. sektor
;inhalt: clusteradressen
;länge: 4sektoren 8.9.10.11.

cluster:

;1.cluster: kernel.bin

dw 6			;root dir
db 0
db 4,5,6,7
db 0
db 1

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
db 1

dw 4
db 0
db 10,11,12,13
db 1
db 1

dw 5
db 0
db 14,15,16,17
db 1
db 1

dw 7
db 0
db 18,19,1,2
db 1
db 1

db 2048-($-cluster) dup(0)