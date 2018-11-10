##############################################
## Beschreibung: Ein "Brainfuck To Assembler Codeconverter"
## BFTOASM v1.0 (C) 2006 by Josef Biehler
## http://biehler-josef.de
## support@biehler-josef.de
## Letzte Akktualisierung: 12.04.2006
##############################################

Ich hafte f�r keinerlei Sch�den, die durch die Benutzung dieses Programmes entstehen.

DATEIEN:
--------
Folgende Dateien m�ssen mitgeliefert worden sein:

Datei		|Bedeutung
BFTOASM.asm	|Der Code von BFTOASM
BFTOASM.COM	|Das Programm
README.TXT	|Diese Datei
factor.txt	|Beispiel BF Code

BESCHREIBUNG:
-------------
BFTOASM verwandelt Brainfuck Code in Assemblercode.
Es ist also als Vorstufe zum Compiler zu sehen.
Da ich aber im Moment keine Lust habe, einen Compiler zu basteln, muss das erstmal gen�gen.
BFTOASM erzeugt zum FASM kompatiblen Code!
Der FASM liegt dem BFTOASM bei.
Die Bedienung des FASM ist einfach: fasm datei.xy
N�heres zum FASM in der entsprechenden README Datei.
Bedingt durch eine nicht vorhandene Codeoptimierung, kann die Ausgabedatei mitunzter schon sehr gro� werden.
Dies st�rt aber weder den FASM noch den BFTOASM ;)


HANDHABUNG:
-----------
Der Umgang mit BFTOASM ist sehr einfach.
Einfach das Programm aufrufen mittels: bftoasm.com name.xy
"name.xy" ist der Dateiname des BF Codes.
Da es bei BF Code keinen Standard gibt, muss man wieder die Kombatibilit�t von UNIX/windows Code beachten.
Dazu bitte den Punkt Kompatibilit�t lesen.
Der Name der Ausgabedatei ist immer gleich der, der Eingabedatei.
Die Endung ist allerdings ".asm", wie es f�r Assemblercode �blich ist.
Wichtig:
Der Dateiname des BF Codes sollte der DOS 8+3 Namenskonvention entsprechen.

MELDUNGEN:
----------
Im Laufe des Betriebes k�nnen verschiedene Meldungen auftreten.

1.: "Richtige Benutzung: BFTOASM.COM dateiname.xy"
2.: "Fehler beim Oeffnen der Datei!"
3.: "Fehler beim Lesen der Datei!"
4.: "Es wurde eine ungleiche Anzahl an '[' und ']' Klammern gefunden."

Zu 1.:
Grund: BFTOASM wurde aufgerufen, ohne dass dem Programm ein Dateiname mit �bergeben wurde.
------
L�sung: Rufen Sie das Programm richtig auf: bftoasm datei.xy

Zu 2.:
Grund: Es trat ein Fehler auf beim �ffnen der Datei.
------
L�sung: Es kann sein, dass auf die Datei bereits zugegriffen wird, oder dass die Datei nicht 
------- vorhanden ist. Tritt die Meldung auf, vielleicht mal andere Dateinamen ausprobieren.

Zu 3.:
Grund: Die Datei wurde zwar ge�ffnet, konnte aber nicht gelesen werden.
------ 
L�sung: Es k�nnte sein, dass der Zugriff verweigert wurde. Vielleicht greift bereits ein 
------- Programm auf die Datei zu.

Zu 4.:
Grund: Es wurden verschiedene Schleifen begonnen, aber nicht mehr beendet.
------ 
L�sung: �berarbeiten sie den Code, und bringen beenden sie jede Schleife ordnungsgem��.
-------


KOMPATIBILIT�T:
---------------
Das Problem wurde bereits bei meinem Brainfuck Interpreter angesprochen.
Und zwar gibt es zwei wesentliche Varianten von BF Code:

-Code, der f�r UNIX Systeme geschrieben wurde
und
-Code, der f�r Windows Systeme geschrieben wurde

Diese Abgrenzung ergibt sich daraus, dass ein Druck auf die "Enter" Taste bei beiden Systemen falsch interpretiert wird.
Dr�ckt man bei Windows die Enter Taste, erwartet das Programm ein ASCII 13.
UNIX hingegen erwartet ein ASCII 10.
wichtig wird dies dann, wenn ein BF Programm Eingaben von der Tastatur einliest und z.b. solange liest, bis Enter gedr�ckt wurde.
Ist der Code nun f�r Windows gemacht worden, w�rd es ein ASCII 13 erwarten.
Auf UNIX Systemen w�rde dies also eine Endlosschleife ergeben.
Deshalb kann angegeben werden, ob es sich um UNIX Code, oder um Windows Code handelt.
Handelt es sich um Windows Code, muss �berhaupt nichts angegeben werden.
Handelt es sich hingegen um UNIX Code, muss am Anfang der Datei, die den BF Code enth�lt, der Parameter /u stehen.
Wichtig:
/u muss ganz am Anfang stehen, damit es vom BFTOASM anerkannt wird!
Der Beispielcode, der beiliegt (factor.txt), wurde ebenfalls f�r UNIX geschrieben.
Falls also jemand nicht genau versteht, wo dieses /u stehen muss, einfach die factor.txt mal �ffnen, und man sieht es.


BUGS:
-----
Bisher kenne ich keine.
Sollten ihnen welche auffallen, so k�nnen sie mich gerne jederzeit kontaktieren (support@biehler-josef.de)

