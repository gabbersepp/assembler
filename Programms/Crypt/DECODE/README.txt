######################################
## DECODE (c) 2006 by Josef Biehler
## Beschreibung: Ein Decoder
## Informationen zum verwendeten Algorithmus siehe meine Seite
## http://biehler-josef.de
## support@biehler-josef.de
## Letzte �nderung: 10.04.2006
######################################

Ich hafte f�r keinerlei Sch�den durch Benutzung des Programmes.

�BERSICHT:
----------

Folgende Dateien m�ssen mitgeliefert worden sein:
DECODE.ASM
DECODE.COM
README.TXT

FUNKTION:
---------
DECODE.COM entschl�sselt Daten nach einem einfachen Algorithmus.
Informationen dazu findet man auf meiner Seite (http://biehler-josef.de).
Um die daten wieder richtig zu entschl�sseln, ist ein Schl�ssel notwendig.
Er darf hier maximal 100 Zeichen lang sein!

HANDHABUNG:
----------
Aufruf des Programmes mittels: DECODE.COM dateiname.xy
Der Dateiname darf allerdings nur 5 (!) Zeichen lang sein!.
Ansonsten wird die zu entschl�sselnde Datei �berschrieben oder es kann zu sonstiugen Fehlverhalten kommen!

BUGS:
-----
Der Dateiname darf bisher nur 5 Zeichen lang sein.