##############################################
## Beschreibung: Ein "Brainfuck To Assembler Codeconverter"
## BFTOASM v1.0 (C) 2006 by Josef Biehler
## http://biehler-josef.de
## support@biehler-josef.de
## Letzte Akktualisierung: 12.04.2006
##############################################

Ich hafte für keinerlei Schäden, die durch die Benutzung dieses Programmes entstehen.

DATEIEN:
--------
Folgende Dateien müssen mitgeliefert worden sein:

Datei		|Bedeutung
BFTOASM.asm	|Der Code von BFTOASM
BFTOASM.COM	|Das Programm
README.TXT	|Diese Datei
factor.txt	|Beispiel BF Code

BESCHREIBUNG:
-------------
BFTOASM verwandelt Brainfuck Code in Assemblercode.
Es ist also als Vorstufe zum Compiler zu sehen.
Da ich aber im Moment keine Lust habe, einen Compiler zu basteln, muss das erstmal genügen.
BFTOASM erzeugt zum FASM kompatiblen Code!
Der FASM liegt dem BFTOASM bei.
Die Bedienung des FASM ist einfach: fasm datei.xy
Näheres zum FASM in der entsprechenden README Datei.
Bedingt durch eine nicht vorhandene Codeoptimierung, kann die Ausgabedatei mitunzter schon sehr groß werden.
Dies stört aber weder den FASM noch den BFTOASM ;)


HANDHABUNG:
-----------
Der Umgang mit BFTOASM ist sehr einfach.
Einfach das Programm aufrufen mittels: bftoasm.com name.xy
"name.xy" ist der Dateiname des BF Codes.
Da es bei BF Code keinen Standard gibt, muss man wieder die Kombatibilität von UNIX/windows Code beachten.
Dazu bitte den Punkt Kompatibilität lesen.
Der Name der Ausgabedatei ist immer gleich der, der Eingabedatei.
Die Endung ist allerdings ".asm", wie es für Assemblercode üblich ist.
Wichtig:
Der Dateiname des BF Codes sollte der DOS 8+3 Namenskonvention entsprechen.

MELDUNGEN:
----------
Im Laufe des Betriebes können verschiedene Meldungen auftreten.

1.: "Richtige Benutzung: BFTOASM.COM dateiname.xy"
2.: "Fehler beim Oeffnen der Datei!"
3.: "Fehler beim Lesen der Datei!"
4.: "Es wurde eine ungleiche Anzahl an '[' und ']' Klammern gefunden."

Zu 1.:
Grund: BFTOASM wurde aufgerufen, ohne dass dem Programm ein Dateiname mit übergeben wurde.
------
Lösung: Rufen Sie das Programm richtig auf: bftoasm datei.xy

Zu 2.:
Grund: Es trat ein Fehler auf beim Öffnen der Datei.
------
Lösung: Es kann sein, dass auf die Datei bereits zugegriffen wird, oder dass die Datei nicht 
------- vorhanden ist. Tritt die Meldung auf, vielleicht mal andere Dateinamen ausprobieren.

Zu 3.:
Grund: Die Datei wurde zwar geöffnet, konnte aber nicht gelesen werden.
------ 
Lösung: Es könnte sein, dass der Zugriff verweigert wurde. Vielleicht greift bereits ein 
------- Programm auf die Datei zu.

Zu 4.:
Grund: Es wurden verschiedene Schleifen begonnen, aber nicht mehr beendet.
------ 
Lösung: Überarbeiten sie den Code, und bringen beenden sie jede Schleife ordnungsgemäß.
-------


KOMPATIBILITÄT:
---------------
Das Problem wurde bereits bei meinem Brainfuck Interpreter angesprochen.
Und zwar gibt es zwei wesentliche Varianten von BF Code:

-Code, der für UNIX Systeme geschrieben wurde
und
-Code, der für Windows Systeme geschrieben wurde

Diese Abgrenzung ergibt sich daraus, dass ein Druck auf die "Enter" Taste bei beiden Systemen falsch interpretiert wird.
Drückt man bei Windows die Enter Taste, erwartet das Programm ein ASCII 13.
UNIX hingegen erwartet ein ASCII 10.
wichtig wird dies dann, wenn ein BF Programm Eingaben von der Tastatur einliest und z.b. solange liest, bis Enter gedrückt wurde.
Ist der Code nun für Windows gemacht worden, würd es ein ASCII 13 erwarten.
Auf UNIX Systemen würde dies also eine Endlosschleife ergeben.
Deshalb kann angegeben werden, ob es sich um UNIX Code, oder um Windows Code handelt.
Handelt es sich um Windows Code, muss überhaupt nichts angegeben werden.
Handelt es sich hingegen um UNIX Code, muss am Anfang der Datei, die den BF Code enthält, der Parameter /u stehen.
Wichtig:
/u muss ganz am Anfang stehen, damit es vom BFTOASM anerkannt wird!
Der Beispielcode, der beiliegt (factor.txt), wurde ebenfalls für UNIX geschrieben.
Falls also jemand nicht genau versteht, wo dieses /u stehen muss, einfach die factor.txt mal öffnen, und man sieht es.


BUGS:
-----
Bisher kenne ich keine.
Sollten ihnen welche auffallen, so können sie mich gerne jederzeit kontaktieren (support@biehler-josef.de)

