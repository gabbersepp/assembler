######################################################
# Brainfuck Built-In Interpreter (BFBII.COM)
# v1.0
# (C) 2006 by Josef Biehler
# Letztes Update: 09.04.2006
# biehler-josef.de
# support@biehler-josef.de
######################################################

(Ich hafte für keinerlei Schäden an Gerät und Mensch durch nicht-funktionierenn der Software!)

BFBII.COM arbeitet ähnlich wie ein Interpreter.
Der Unterschied ist, dass das Programm eine abgespeckte Version eines Interpreters erzeugt, an den der BF Code angehängt wird.
Dem Anwender wird so praktischerweise vorgegaugelt, er würde ein compiliertes BF Programm in den Händen halten.
Der Nachteil ist, dass dieser abgespeckte Interpreter immer ca. 8,5Kb Größe hat.
Selbst wenn der BF Code lediglich aus einem "." besteht, ist die erzeugte Datei trotzdem ca. 8,5Kb groß.

Wie dem auch sei.
Die Benutzung des Programms ist ganz einfach.
Einfach das Programm BFBII.COM aufrufen:
######
BFBII.COM Dateiname.txt
######
Dann wird, wenn kein Fehler auftrat, eine .COM Datei erstellt, die sofort lauffähig ist.
Ein solches Beispielprogramm ist mit beigefügt. Es heißt: lese6.com
Es liest ganz einfach 6 Buchstaben ein und gibt sie in umgekehrter Reihenfolge wieder aus.

Das Programm wurde für den FASM entwickelt.

Folgende Dateien müsten mitgelieferten worden sein:
---------------------
README.TXT
INT.ASM
INT.COM
BFII.ASM
BFII.COM
lese6.com