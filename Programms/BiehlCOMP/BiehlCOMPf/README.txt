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

######URL De-/Encode
urldecode(lptData:DWORD, nLen:DWORD)
	url-decodiert einen mit lptData addressierten Datenbereich der Länge nLen
	Rückgabe ist ein mit GlobalAlloc allociierter Datenbereich.
	Das erste DWORD dieses Datenbereiches enthält die Länge der decodierten Daten.

urlencode(lptData:DWORD, nLen:DWORD)
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
	
