######################################
## BR13EN (c) 2006 by Josef Biehler
## Beschreibung: Ein einfacher ROT13 Encoder
## http://biehler-josef.de
## support@biehler-josef.de
## Letzte �nderung: 10.04.2006
######################################

Ich hafte f�r keinerlei Sch�den durch BEnutzung des Proigrammes.

�BERSICHT:
----------

Folgende Dateien m�ssen mitgeliefert worden sein:
BR13EN.COM
BR13EN.ASM
README.TXT

FUNKTION:
---------
BR13EN.COM verschl�sselt Daten nach dem ROT13 Mechanismus.
Es wird also auf den ASCII Code eines jeden Zeichens der Wert 13 addiert.
Sicherheitshinweis: ROT13 stellt keine sehr sichere Verschl�sselungsmethode dar!

HANDHABUNG:
----------
Aufruf des Programmes mittels: BR13EN.COM dateiname.xy
Der Dateiname darf allerdings nur 5 (!) Zeichen lang sein!.
Ansonsten wird die zu verschl�sselnde Datei �berschrieben oder es kann zu sonstiugen Fehlverhalten kommen!

BUGS:
-----
Der Dateiname darf bisher nur 5 Zeichen lang sein.