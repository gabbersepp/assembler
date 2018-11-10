6plus10 v1.0
Mein Interpreter für meine eigene Esoterische Programmiersprache.

"6plus10" ist unter der GNU Public License veröffentlicht.
Ich hafte für keinerlei Schäden. Mehr Informationen in der beiliegenden gpl.txt

(C) 2006 by Josef Biehler
URL: biehler-josef.de
E-Mail: support@biehler-josef.de

Folgende Dateien müssten mitgeliefert worden sein:
----------------------------
gpl.txt   | Die Lizenzbedingungen
6plus10.asm | Der Sourcecode von BRAIN.COM
6plus10.com | Das Programm
README.txt| Diese Datei
Neu.txt   | Auflistung der Neuerungen
bsp.txt	  | Ein Beispielprogramm in 6+10; gibt "Hello World!" aus.
-------------------------------

Zur Kontaktaufnahme bitte obige E-MAil Adresse benutzen.

BEDIENUNG:
------------
Es steht dem Programmierer ein Variablenfeld von 1000 Stück bereit.
Außerdem darf jeder 6+10 Code 10000 Bytes lang sein (ca. 10Kb)
Die Bedienung von 6plus10 ist einfach:
Einfach in der Kommandozeile "6plus10 dateiname.xy" eingeben und schon läuft alles (wenn man sich im richtigen Ordner befindet).
Der Kommentar kann durch den "*" Operator gebildet werden (siehe mein Tutorial) oder auch jedes Zeichen, was kein Befehl ist, gilt als Kommentar.

Die hier vorliegende Version hat fast keine fehlerüberprüfungen.
Stacküber- bzw. -unterläufe werden nicht überprüft!
Genausowenig, ob der zugewiesene Variablenbereich über- oder unterschritten wurde!
Deshalb bitte auf eine saubere Programmierung achten!

Hinweis:
--------
Leider ist 6plus10 im Moment noch verbuggt.
Zum Beispiel funktonieren die LAbels nicht immer.
Es scheint so, als ob der Interpreter nicht alle Namen und Zeichenkombinationen aktzeptiert.
deshalb: Wenn mal eine Schleife nicht funktioniert, einfach mal einen anderen Labelnamen ausprobieren.
Und der Sicherheit halber keine 6plus10 Befehle in den Labeln verwenden.

