FAT_TAB1:
	DB	0
	DB	0
	DB	0
	;DB	11111111b
	;DB	00001111b
	
	DB 9*512-($-FAT_TAB1) DUP(0)
	
FAT_TAB2:
	DB	0
	DB	0
	DB	0

	
	DB 9*512-($-FAT_TAB2) DUP(0)
	
	
ROOT_DIR:
	;DB	"KERNEL  BIN"
	;DB	0
	;DB	0
	;DB	0
	;DW	0
	;DW	0
	;DW	0
	;DW	0
	;DW	0
	;DW	0
	;DW	2
	;DD	40
	
	
	DB 14*512-($-ROOT_DIR) DUP(0)

