MOV AX, CS
MOV DS, AX
MOV SI, STRING
MOV AH, 05H
INT 20H
RETF

STRING DB "asdfg",0