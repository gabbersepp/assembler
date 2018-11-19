######################################
## BR13DE (c) 2006 by Josef Biehler
## Beschreibung: Ein einfacher ROT13 Decoder
## http://biehler-josef.de
## support@biehler-josef.de
## Letzte �nderung: 10.04.2006
######################################

Ich hafte f�r keinerlei Sch�den durch BEnutzung des Proigrammes.

�BERSICHT:
----------

Folgende Dateien m�ssen mitgeliefert worden sein:
BR13DE.COM
BR13DE.ASM
README.TXT

FUNKTION:
---------
BR13DE.COM entschl�sselt Daten nach dem ROT13 Mechanismus.
Es wird also vom ASCII Code eines jeden Zeichens der Wert 13 subtrahiert.
Sicherheitshinweis: ROT13 stellt keine sehr sichere Verschl�sselungsmethode dar!

HANDHABUNG:
----------
Aufruf des Programmes mittels: BR13DE.COM dateiname.xy
Der Dateiname darf allerdings nur 5 (!) Zeichen lang sein!.
Ansonsten wird die zu entschl�sselnde Datei �berschrieben oder es kann zu sonstiugen Fehlverhalten kommen!

BUGS:
-----
Der Dateiname darf bisher nur 5 Zeichen lang sein.