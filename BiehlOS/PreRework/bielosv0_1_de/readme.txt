So, hier ist das neue BielOS.
(C) 2005-2006 Josef Biehler
biehler.cybton.com

bielos.de.tk

Die Bin�rdatei mit Rawrite oder einem anderen Imageschreibprogramm auf eine Diskette bannen und davon booten.

Achtung:
Wer damit den Bootsektor der Festpatte �berschrebt, ist selber schuld!
Ich �bernehme keine HAftung!

Kernel Version: 0.01
BielFS Version: 0.1
BielShell Version: 0.1

Infos:
Das komplette OS wurde nach gravierenden Fehlern komplett neu aufgebaut.
Es ist nun leider nicht mehr so gut kommentiert, allerdings sind LAbel NAmen besser gew�hlt und der Code ist strukturierter.
Au�erdem sind die Unterprogramm Aufrufe den C Calling Conventions gem��.
Das BielFS funktioniert nun einwandfrei.
Jede Datei kann maximal 4 Kb gro� sein und wird als Cluster gespeichert.