So, hier ist das neue BielOS.
(C) 2005-2006 Josef Biehler
biehler.cybton.com

bielos.de.tk

Die Binärdatei mit Rawrite oder einem anderen Imageschreibprogramm auf eine Diskette bannen und davon booten.

Achtung:
Wer damit den Bootsektor der Festpatte überschrebt, ist selber schuld!
Ich übernehme keine HAftung!

Kernel Version: 0.01
BielFS Version: 0.9
BielShell Version: 1.0

Das BielFS wurde nun erweitert. Es sind nun auch Ordnersturkturen möglich.
Der Grundordner heißt 'root'.
Ein Hinweis zu den Befehlen
cd
und 
mkdir

Es kann nur ein Verzeichnisname angegeben, der innerhalb des aktuellen Ordners liegt, bzw. der innerhalb des jeweiligen Ordners erstellt werden soll.
z.b. cd xyz
oder mkdir xyd

Pfadangaben, wie: cd root/xyz/tzu
gehen noch nicht!

Desweiteren wurde die Shell so umgearbeitet, dass die Befehle auch als Batchscript ausgeführt werden können.
Ein solches Script muss die Dateiendung .bss haben.
Jeder Befehl muss mindestens ein Leerzeichen enthalten.
z.b.: 
"echo " funktioniert
aber:
"echo" nicht!
ABER:
"show help.txt" funktioniert ebenfalls, hier ist bereits ein Leerzeichen enthalten!

Desweiteren führt eine Benutzung des HALT Befehls in einer Scriptdatei zum Absturz.
Auch kann es während der normalen Benutzung des BielOS zum Absturz kommen, wenn der Befehl HALT angewendet wird.
Ich kenne die Ursache, aber den Auslöser nicht.

Und eine weitere Neuerung:
Es ist egal, ob man die Befehle groß, oder klein schreibt.
Auch bei Programmen ist die Schreibweise egal.
Nur wenn mit dem Editor "tiny" eine Datei erstellt wird, muss der Dateiname kleingeschrieben werden.

Desweiteren:
Ein ausführbares Programm muss die Endung .os haben.