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

######URL De-/Encode
urldecode(lptData:DWORD, nLen:DWORD)
	url-decodiert einen mit lptData addressierten Datenbereich der L�nge nLen
	R�ckgabe ist ein mit GlobalAlloc allociierter Datenbereich.
	Das erste DWORD dieses Datenbereiches enth�lt die L�nge der decodierten Daten.

urlencode(lptData:DWORD, nLen:DWORD)
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
	
