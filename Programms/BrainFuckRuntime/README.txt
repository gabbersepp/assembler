######################################################
# Brainfuck Built-In Interpreter (BFBII.COM)
# v1.0
# (C) 2006 by Josef Biehler
# Letztes Update: 09.04.2006
# biehler-josef.de
# support@biehler-josef.de
######################################################

(Ich hafte f�r keinerlei Sch�den an Ger�t und Mensch durch nicht-funktionierenn der Software!)

BFBII.COM arbeitet �hnlich wie ein Interpreter.
Der Unterschied ist, dass das Programm eine abgespeckte Version eines Interpreters erzeugt, an den der BF Code angeh�ngt wird.
Dem Anwender wird so praktischerweise vorgegaugelt, er w�rde ein compiliertes BF Programm in den H�nden halten.
Der Nachteil ist, dass dieser abgespeckte Interpreter immer ca. 8,5Kb Gr��e hat.
Selbst wenn der BF Code lediglich aus einem "." besteht, ist die erzeugte Datei trotzdem ca. 8,5Kb gro�.

Wie dem auch sei.
Die Benutzung des Programms ist ganz einfach.
Einfach das Programm BFBII.COM aufrufen:
######
BFBII.COM Dateiname.txt
######
Dann wird, wenn kein Fehler auftrat, eine .COM Datei erstellt, die sofort lauff�hig ist.
Ein solches Beispielprogramm ist mit beigef�gt. Es hei�t: lese6.com
Es liest ganz einfach 6 Buchstaben ein und gibt sie in umgekehrter Reihenfolge wieder aus.

Das Programm wurde f�r den FASM entwickelt.

Folgende Dateien m�sten mitgelieferten worden sein:
---------------------
README.TXT
INT.ASM
INT.COM
BFII.ASM
BFII.COM
lese6.com