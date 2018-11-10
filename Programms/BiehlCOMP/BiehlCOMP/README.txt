;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BiehlCOMP v0.4.0
;; (c) 2005-2006 by Josef Biehler
;; http://www.biehler-josef.de
;; http://www.biehlcomp.biehler-josef.de
;; E-Mail: support@biehler-josef.de
;; Ich hafte für keinerlei Schäden durch die Benutzung der DLL oder beigefügtem Code/Binärdaten.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BESCHREIBUNG:
-------------
Ich versuche hier eine Bibliothek zu entwickeln, die eine FÜlle an Funktionen enthält, 
die eventuell für Programmierer interessant sind.

BEDIENUNG:
----------
Man muss lediglich die Funktionen mit den entsprechenden Parametern aufrufen.
Eine Übersicht der Funktionen und die benötigten Parameter ist weiter unten zu finden.
Im Ordner "doc" sind unter Umständen noch zusätzliche (wichtige!) Informationen hinterlegt.


HANDHABUNG:
-----------
Jeder Funktion muss meist ein oder mehrere Parameter übergeben werden, Strings müssen null-terminiert sein!

Weiterer Hinweis:
Alle Funktionen verwenden den STDCALL Aufrufstandard.
Normalerweise wird standardmäßig der STDCALL Standard benutzt, wenn eine Funktion dieser DLL aufgerufen wird.


BEGRIFFSERKLÄRUNG:
------------------

Um Missverständnisse vorzubeugen:

Double-String:
Wenn ich in dieser Hilfedatei von einem Double-String spreche, MUSS jede Zahl, die dieser Funktion übergeben wird, ein Komma enthalten.
Ist kein Komma enthalten, so werden falsche Ergebnisse zurückgegeben.
Das zurückgegebene Ergebniss ist ebenfalls wieder ein Double-String.

Integer-String:
Ist von einem Integer-String die Rede, so DARF KEIN Komma in dem String enthalten sein!
Ist ein Komma enthalten, werden falsche Ergebnisse zurückgegeben.
Das zurückgegebene Ergebniss ist ebenfalls wieder ein Integer-String.

lptData:
=long Pointer to Data
=Ein Pointer auf einen Datenbereich

nLen:
=Länge

ANWENDUNGSBEISPIELE:
--------------------
Es sind 2 Anwendungsbeispielcodes beigefügt.
Zum einen ein C Beispiel und zum anderen ein Assembler Beispiel.
Das C Beispiel wurde mit "Dev-C++" kompiliert.


Übersicht aller Funktionen:
--------------------------

######POP3 Funktionen

(Eine Liste mit Fehlercodes kann in der doc\pop3fehler nachgelesen werden)

POP3_Init(lpPOP3Struct:DWORD)
  Initialisiert die POP3 Funktionen.
  Der Funktion muss ein Pointer auf eine Struktur übergeben werden.
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
  
  Die Rückgabe ist ein "Handle", der für jegliche Operation mit 
  den übrigen POP3 Funktionen benötigt wird.
  
  Es könnne beliebig viele POP3 Instanzen initialisiert werden.
  
POP3_Connect(hWnd: DWORD)
  Verbindet sich zum POP3 Server und meldet sich an.
  Wenn: Erfolgreich:       RÜckgabe = 0
        Nicht erfolgreich: RÜckgabe = -1 (Aufurf von POP3_GetLastError)
        
POP3_Noop(hWnd: DWORD)
  Sendet eine NOOP Anfrage an dne Server.
  Wenn: Erfolgreich:       RÜckgabe = 0
        Nicht erfolgreich: RÜckgabe = -1 (Aufurf von POP3_GetLastError)
        
POP3_Stat(hWnd: DWORD)
  Fragt die Anzahl an vorhandenen Mails ab und die Gesamtgröße.
  Wenn: Erfolgreich:       RÜckgabe = Pointer auf POP3_StatStruct
        Nicht erfolgreich: RÜckgabe = -1 (Aufurf von POP3_GetLastError)  

  --POP3_StatStruct---
  --------------------
  -- nCount: DWORD
  -- nSize:  DWORD
  --------------------
  
POP3_List(hWnd: DWORD, email:DWORD)
  GIbt bei Erfolg eine Liste mit den einzelnen E-Mails und ihren Größen zurück.
  Wenn: Erfolgreich:       RÜckgabe = Pointer auf Liste
        Nicht erfolgreich: RÜckgabe = -1 (Aufurf von POP3_GetLastError)  
          
   --POp3_ListStruct--
   -------------------
   -- nNum:  DWORD
   -- nSize: DWORD
   -- nNum2: DWORD
   -- nSize2:DWORD
   -- ...usw...
   -------------------
   
   nNum ist notwendig, falls eine E-Mail betrachtet werden will oder gelöscht werden will.
   
   'email' kennzeichnet ide Kennnummer einer Email.
   Ist 'email' größer als 0, so wird nur ein Array zurückgegeben mit der Nummer der Email und der Größe der E-Mail
   
POP3_GetLastError(hWnd: DWORD)
  Ermittelt den letzten aufgetretenen Fehler.
  
POP3_Quit(hWnd:DWORD)
  Beendet die Verbindung.
  Wenn: Erfolgreich:       RÜckgabe = 0
        Nicht erfolgreich: RÜckgabe = -1 (Aufurf von POP3_GetLastError)  
        
POP3_Dele(hWnd:DWORD, email:DWORD)
  Löscht eine Email mit der Kennnummer 'email'.
  Die Kennnummer ist vom POP3 Server abhängig und kann mit POP3_List abgefragt werden.
  Wenn: Erfolgreich:        Rückgabe = 0
        Nicht erfolgreich:  Rückgabe = -1 (Aufruf von POP3_GetLastError)
        
POP3_Rset(hWnd:DWORD)
  Setzt alle in einer Session getätigten DELE Befehle zurück.
  Wenn: Erfolgreich:        Rückgabe = 0
        Nicht erfolgreich:  Rückgabe = -1 (Aufruf von POP3_GetLastError)
          
######String Funktionen
Explode(lptStr:DWORD, nChar:DWORD)
  Teilt einen String bei dem Zeichen nChar.
  Ähnlich der PHP Funktion explode(), nur dass als Terminierungszeichen nur ein einzelnes
  Zeichen anstatt eines ganzen Strings angegeben werden kann.
  Die RÜckgabe ist ein Pointer auf ein Array, dass wiederum Pointer
  auf die Stringteile enthält.
  Ist ein Element des Arrays 0x00000000, so ist das Array zu Ende.
 
ExplodeFree(ptArray:DWORD)
  Löst ein durch Explode() erzeugtes Array wieder auf und gibt den Speicher frei.
  ptArray ist der Pointer, der von Explode() zurückgegeben wurde.
  
Len(lptStr:DWORD)
  Gibt die Länge eines Null-terminierten Strings zurück.
  
Pos(lptStr:DWORD, nCHar:DWORD)
  Sucht und gibt die Position von nCHar in lptStr zurück.
  Ist nCHar nicht vorhanden, so wird die Länge des Stringes zurückgegeben.
  
######URL De-/Encode
UrlDecode(lptData:DWORD, nLen:DWORD)
	url-decodiert einen mit lptData addressierten Datenbereich der Länge nLen
	Rückgabe ist ein mit GlobalAlloc allociierter Datenbereich.
	Das erste DWORD dieses Datenbereiches enthält die Länge der decodierten Daten.

UrlEncode(lptData:DWORD, nLen:DWORD)
	url-encodiert einen mit lptData addressierten Datenbereich der Länge nLen.
	Rückgabe ist ein mit GlobalAlloc allociierter Datenbereich, der die encodierten Daten enthält.

######Grundrechenarten (Addieren, Subtrahieren, Dividieren, Multiplizieren):

AddLongDouble(OFFSET Zahl1, OFFSET Zahl2, OFFSET Ergebnis)
	Mit dieser Funktion werden 2 Double-Strings addiert und gespeichert.

SubLongDouble(OFFSET Zahl1, OFFSET Zahl2, OFFSET Ergebnis)
	Mit dieser Funktion werden 2 Double-Strings subtrahiert und gespeichert.

GetIntLen(OFFSET Zahl)
	Es wird die Länge eines Integer-Stringes ermittelt und in EAX zurückgegeben.

CmpLongInt(OFFSET Zahl1, OFFSET Zahl2)
	Vergleicht die beiden Integer-Strings und gibt in EAX folgende Werte zurück:
	-1, wenn Zahl1 < Zahl2
	0, wenn Zahl1 = Zahl2
	1, wenn Zahl1 > Zahl2

AddLongInt(OFFSET Zahl1, OFFSET Zahl2, OFFSET Ergebnis)
	Addiert 2 Integer-Strings miteinander.

SubLongInt(OFFSET Zahl1, OFFSET Zahl2, OFFSET Ergebnis)
	Subtrahiert 2 Integer-Strings.

GetVer
	Gibt die Adreses zu einem nullterminiertem Versionsstring zurück.

GetSign(Adresse Zahl1)
	Ermittelt das Vorzeichen und gibt es in EAX (AL) zurück
	
