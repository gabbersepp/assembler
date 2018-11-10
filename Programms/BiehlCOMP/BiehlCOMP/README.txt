;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BiehlCOMP v0.4.0
;; (c) 2005-2006 by Josef Biehler
;; http://www.biehler-josef.de
;; http://www.biehlcomp.biehler-josef.de
;; E-Mail: support@biehler-josef.de
;; Ich hafte f�r keinerlei Sch�den durch die Benutzung der DLL oder beigef�gtem Code/Bin�rdaten.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BESCHREIBUNG:
-------------
Ich versuche hier eine Bibliothek zu entwickeln, die eine F�lle an Funktionen enth�lt, 
die eventuell f�r Programmierer interessant sind.

BEDIENUNG:
----------
Man muss lediglich die Funktionen mit den entsprechenden Parametern aufrufen.
Eine �bersicht der Funktionen und die ben�tigten Parameter ist weiter unten zu finden.
Im Ordner "doc" sind unter Umst�nden noch zus�tzliche (wichtige!) Informationen hinterlegt.


HANDHABUNG:
-----------
Jeder Funktion muss meist ein oder mehrere Parameter �bergeben werden, Strings m�ssen null-terminiert sein!

Weiterer Hinweis:
Alle Funktionen verwenden den STDCALL Aufrufstandard.
Normalerweise wird standardm��ig der STDCALL Standard benutzt, wenn eine Funktion dieser DLL aufgerufen wird.


BEGRIFFSERKL�RUNG:
------------------

Um Missverst�ndnisse vorzubeugen:

Double-String:
Wenn ich in dieser Hilfedatei von einem Double-String spreche, MUSS jede Zahl, die dieser Funktion �bergeben wird, ein Komma enthalten.
Ist kein Komma enthalten, so werden falsche Ergebnisse zur�ckgegeben.
Das zur�ckgegebene Ergebniss ist ebenfalls wieder ein Double-String.

Integer-String:
Ist von einem Integer-String die Rede, so DARF KEIN Komma in dem String enthalten sein!
Ist ein Komma enthalten, werden falsche Ergebnisse zur�ckgegeben.
Das zur�ckgegebene Ergebniss ist ebenfalls wieder ein Integer-String.

lptData:
=long Pointer to Data
=Ein Pointer auf einen Datenbereich

nLen:
=L�nge

ANWENDUNGSBEISPIELE:
--------------------
Es sind 2 Anwendungsbeispielcodes beigef�gt.
Zum einen ein C Beispiel und zum anderen ein Assembler Beispiel.
Das C Beispiel wurde mit "Dev-C++" kompiliert.


�bersicht aller Funktionen:
--------------------------

######POP3 Funktionen

(Eine Liste mit Fehlercodes kann in der doc\pop3fehler nachgelesen werden)

POP3_Init(lpPOP3Struct:DWORD)
  Initialisiert die POP3 Funktionen.
  Der Funktion muss ein Pointer auf eine Struktur �bergeben werden.
  Diese Struktur hat folgenden Aufbau:
  
  ---------------------------
  -- lptHost:     DWORD
  -- nPort:       DWORD
  -- uVersion:    DWORD
  -- lptUsername: DWORD
  -- lptPassword: DWORD
  -- Reserved:    QWord
  ----------------------------
  
  uVersion wird aktuell nicht genutzt, es sollte allerdings mit 100 
  initialisiert werden.
  
  Die R�ckgabe ist ein "Handle", der f�r jegliche Operation mit 
  den �brigen POP3 Funktionen ben�tigt wird.
  
  Es k�nnne beliebig viele POP3 Instanzen initialisiert werden.
  
POP3_Connect(hWnd: DWORD)
  Verbindet sich zum POP3 Server und meldet sich an.
  Wenn: Erfolgreich:       R�ckgabe = 0
        Nicht erfolgreich: R�ckgabe = -1 (Aufurf von POP3_GetLastError)
        
POP3_Noop(hWnd: DWORD)
  Sendet eine NOOP Anfrage an dne Server.
  Wenn: Erfolgreich:       R�ckgabe = 0
        Nicht erfolgreich: R�ckgabe = -1 (Aufurf von POP3_GetLastError)
        
POP3_Stat(hWnd: DWORD)
  Fragt die Anzahl an vorhandenen Mails ab und die Gesamtgr��e.
  Wenn: Erfolgreich:       R�ckgabe = Pointer auf POP3_StatStruct
        Nicht erfolgreich: R�ckgabe = -1 (Aufurf von POP3_GetLastError)  

  --POP3_StatStruct---
  --------------------
  -- nCount: DWORD
  -- nSize:  DWORD
  --------------------
  
POP3_List(hWnd: DWORD, email:DWORD)
  GIbt bei Erfolg eine Liste mit den einzelnen E-Mails und ihren Gr��en zur�ck.
  Wenn: Erfolgreich:       R�ckgabe = Pointer auf Liste
        Nicht erfolgreich: R�ckgabe = -1 (Aufurf von POP3_GetLastError)  
          
   --POp3_ListStruct--
   -------------------
   -- nNum:  DWORD
   -- nSize: DWORD
   -- nNum2: DWORD
   -- nSize2:DWORD
   -- ...usw...
   -------------------
   
   nNum ist notwendig, falls eine E-Mail betrachtet werden will oder gel�scht werden will.
   
   'email' kennzeichnet ide Kennnummer einer Email.
   Ist 'email' gr��er als 0, so wird nur ein Array zur�ckgegeben mit der Nummer der Email und der Gr��e der E-Mail
   
POP3_GetLastError(hWnd: DWORD)
  Ermittelt den letzten aufgetretenen Fehler.
  
POP3_Quit(hWnd:DWORD)
  Beendet die Verbindung.
  Wenn: Erfolgreich:       R�ckgabe = 0
        Nicht erfolgreich: R�ckgabe = -1 (Aufurf von POP3_GetLastError)  
        
POP3_Dele(hWnd:DWORD, email:DWORD)
  L�scht eine Email mit der Kennnummer 'email'.
  Die Kennnummer ist vom POP3 Server abh�ngig und kann mit POP3_List abgefragt werden.
  Wenn: Erfolgreich:        R�ckgabe = 0
        Nicht erfolgreich:  R�ckgabe = -1 (Aufruf von POP3_GetLastError)
        
POP3_Rset(hWnd:DWORD)
  Setzt alle in einer Session get�tigten DELE Befehle zur�ck.
  Wenn: Erfolgreich:        R�ckgabe = 0
        Nicht erfolgreich:  R�ckgabe = -1 (Aufruf von POP3_GetLastError)
          
######String Funktionen
Explode(lptStr:DWORD, nChar:DWORD)
  Teilt einen String bei dem Zeichen nChar.
  �hnlich der PHP Funktion explode(), nur dass als Terminierungszeichen nur ein einzelnes
  Zeichen anstatt eines ganzen Strings angegeben werden kann.
  Die R�ckgabe ist ein Pointer auf ein Array, dass wiederum Pointer
  auf die Stringteile enth�lt.
  Ist ein Element des Arrays 0x00000000, so ist das Array zu Ende.
 
ExplodeFree(ptArray:DWORD)
  L�st ein durch Explode() erzeugtes Array wieder auf und gibt den Speicher frei.
  ptArray ist der Pointer, der von Explode() zur�ckgegeben wurde.
  
Len(lptStr:DWORD)
  Gibt die L�nge eines Null-terminierten Strings zur�ck.
  
Pos(lptStr:DWORD, nCHar:DWORD)
  Sucht und gibt die Position von nCHar in lptStr zur�ck.
  Ist nCHar nicht vorhanden, so wird die L�nge des Stringes zur�ckgegeben.
  
######URL De-/Encode
UrlDecode(lptData:DWORD, nLen:DWORD)
	url-decodiert einen mit lptData addressierten Datenbereich der L�nge nLen
	R�ckgabe ist ein mit GlobalAlloc allociierter Datenbereich.
	Das erste DWORD dieses Datenbereiches enth�lt die L�nge der decodierten Daten.

UrlEncode(lptData:DWORD, nLen:DWORD)
	url-encodiert einen mit lptData addressierten Datenbereich der L�nge nLen.
	R�ckgabe ist ein mit GlobalAlloc allociierter Datenbereich, der die encodierten Daten enth�lt.

######Grundrechenarten (Addieren, Subtrahieren, Dividieren, Multiplizieren):

AddLongDouble(OFFSET Zahl1, OFFSET Zahl2, OFFSET Ergebnis)
	Mit dieser Funktion werden 2 Double-Strings addiert und gespeichert.

SubLongDouble(OFFSET Zahl1, OFFSET Zahl2, OFFSET Ergebnis)
	Mit dieser Funktion werden 2 Double-Strings subtrahiert und gespeichert.

GetIntLen(OFFSET Zahl)
	Es wird die L�nge eines Integer-Stringes ermittelt und in EAX zur�ckgegeben.

CmpLongInt(OFFSET Zahl1, OFFSET Zahl2)
	Vergleicht die beiden Integer-Strings und gibt in EAX folgende Werte zur�ck:
	-1, wenn Zahl1 < Zahl2
	0, wenn Zahl1 = Zahl2
	1, wenn Zahl1 > Zahl2

AddLongInt(OFFSET Zahl1, OFFSET Zahl2, OFFSET Ergebnis)
	Addiert 2 Integer-Strings miteinander.

SubLongInt(OFFSET Zahl1, OFFSET Zahl2, OFFSET Ergebnis)
	Subtrahiert 2 Integer-Strings.

GetVer
	Gibt die Adreses zu einem nullterminiertem Versionsstring zur�ck.

GetSign(Adresse Zahl1)
	Ermittelt das Vorzeichen und gibt es in EAX (AL) zur�ck
	
