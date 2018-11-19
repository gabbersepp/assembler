######################################
## BR13EN (c) 2006 by Josef Biehler
## Beschreibung: Ein einfacher ROT13 Encoder
## http://biehler-josef.de
## support@biehler-josef.de
## Letzte Änderung: 10.04.2006
######################################

Ich hafte für keinerlei Schäden durch BEnutzung des Proigrammes.

ÜBERSICHT:
----------

Folgende Dateien müssen mitgeliefert worden sein:
BR13EN.COM
BR13EN.ASM
README.TXT

FUNKTION:
---------
BR13EN.COM verschlüsselt Daten nach dem ROT13 Mechanismus.
Es wird also auf den ASCII Code eines jeden Zeichens der Wert 13 addiert.
Sicherheitshinweis: ROT13 stellt keine sehr sichere Verschlüsselungsmethode dar!

HANDHABUNG:
----------
Aufruf des Programmes mittels: BR13EN.COM dateiname.xy
Der Dateiname darf allerdings nur 5 (!) Zeichen lang sein!.
Ansonsten wird die zu verschlüsselnde Datei überschrieben oder es kann zu sonstiugen Fehlverhalten kommen!

BUGS:
-----
Der Dateiname darf bisher nur 5 Zeichen lang sein.