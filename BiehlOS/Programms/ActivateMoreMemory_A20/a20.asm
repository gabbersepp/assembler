;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Aktivieren des 21. Adressbits				
;; Versucht auf mehrere Arten, dies zu tun		
;; (c) 2005-2006 by Josef Biehler				
;; http://biehler-josef.de						
;; biehlos@biehler-josef.de					
;;	
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
use16

		MOV AX, CS
		MOV ES, AX
		MOV DS, AX

		CALL A20KPORT
	
		CALL CHECK_A20
		CMP AX, 0
		JE A20_OK

		CALL A20KCMD
	
		CALL CHECK_A20
		CMP AX, 0
		JE A20_OK

		CALL A20PORT
	
		CALL CHECK_A20
		CMP AX, 0
		JE A20_OK

		CALL A20INT
	
		CALL CHECK_A20
		CMP AX, 0
		JE A20_OK

		LEA DI, [A20_NO]
		MOV AH,05H
		INT 20H
		RETF						;Programm beenden
	

	A20_OK:
		LEA DI, [A20_YES]
		MOV AH, 05H
		INT 20H
		RETF						;Programm beenden
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Setze das 21. Bit per Tastatur Ports
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	A20KPORT:
		CLI

		MOV AL, 0D0H			;Outputportstatus an Buffer legen
		OUT 64H, AL
		
		;CALL WAIT_KB

		IN AL, 60H				;Status holen
		OR AL, 10B				;A20 setzen
		PUSH AX
		
		;CALL WAIT_KB
       
		MOV AL, 0D1H			;Schreibe zu Outputport
		OUT 64H, AL
       
		;CALL WAIT_KB
       
		POP AX
		OUT 60H, AL

		STI
		RET

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Setze das 21. Bit per tastaturbefehl
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	A20KCMD:
		A20KCMD_CHECKCMD:				;Warte,bis CMD Buffer leer ist
			IN AL, 64H
			TEST AL, 10B
			JZ A20KCMD_CHECKCMD
			
		MOV AL, 0DFH
		OUT 64H, AL
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Setze das 21.Bit per Port
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	A20PORT:
		IN AL, 92H
		MOV AH, AH
		TEST AL, 10B
		JNZ A20PORT_NEXT
		RET
	A20PORT_NEXT:
		MOV AL, 0FDH
		OUT 92H, AL
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Setze 21. Bit per INT
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	A20INT:
		MOV AX, 2401H
		INT 15H
		RET
		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Überprüfe A20
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	CHECK_A20:
		PUSH DS
		MOV AX, 0FFFFH
		MOV DS, AX
		MOV DI, 7c0H
		MOV BYTE [DS:DI], "A"
		MOV AX, 0H
		MOV DS, AX
		MOV DI, 7B0H
		MOV AL, [DS:DI]
		CMP AL, "A"
		JE CA20_NO
		MOV AX, 0
		POP DS
		RET
	CA20_NO:
		MOV AX, 1
		POP DS
		RET

	A20_NO DB "Das HMA konnte nicht aktiviert werden.", 13, 10, 0
	A20_YES DB "Das HMA konnte aktiviert werden.", 13, 10, 0