BRAIN.COM v1.0
Ein kleiner, einfacher Brainfuck Interpreter.

Ich hafte f�r keinerlei Sch�den. Mehr Informationen in der beiliegenden gpl.txt

(C) 2006 by Josef Biehler
URL: biehler-josef.de
E-Mail: support@biehler-josef.de

Folgende Dateien m�ssten mitgeliefert worden sein:
----------------------------
brain.asm | Der Sourcecode von BRAIN.COM
brain.com | Das Programm
README.txt| Diese Datei
Neu.txt   | Auflistung der Neuerungen
-------------------------------

Zur Kontaktaufnahme bitte obige E-MAil Adresse benutzen.

BEDIENUNG:
------------
Es steht dem Programmierer ein Variablenfeld von 1000 St�ck bereit.
Au�erdem darf jeder BF Code 10000 Bytes lang sein (ca. 10Kb)
Die Bedienung von BRAIN.COM ist einfach:
Einfach in der Kommandozeile "brain dateiname.xy" eingeben und schon l�uft alles.
Allerdings muss unter 2 Arten von Brainfuck Code unterschieden werden!
F�r n�here Informationen bitte den Punkt "Korrekte Darstellung" lesen.

FEHLER:
------------
BRAIN.COM beinhaltet mehrere Fehler�berpr�fungsroutinen.
Es k�nnen folgende Meldungen auftreten:
(1):"Der Interpreter fand eine ungleiche ANzahl von '[' und ']' Klammern vor."
(2):"Datei nicht gefunden."
(3):"Fehler beim Oeffnen der Datei"
(4):"Kein Dateiname angegeben."
(5):"Richtige Benutzung: brain.com dateiname.xy"
(6):"Zugriffsfehler der Variablen."

M�gliche Probleme:
(1):Der Interpreter �berpr�ft zu allererst, ob zu jeder "[" auch eine "]" Klammer vorhanden ist.
Ist dies nicht der Fall, gibt er obige Meldung aus.
L�sung: Den BF Code nochmals durchdenken und Klammern schlie�en, bzw. entfernen

(2):Der Interpreter hat die angegebene Datei nicht gefunden.
L�sung: Den richtigen Dateinamen angeben.
Hinweis: Der Dateiname darf keine Sonderzeichen enthalten!

(3):Beim versuch die Datei auszulesen trat ein Fehler auf.
Es k�nnte vielleicht sein, dass auf die Datei bereits zugegriffen wird o.�.
L�sung: Keine Ahnung, trat bei mir noch nie auf.

(4):Es wurde kein Dateiname angegeben.
L�sung: Einen Dateinamen angeben.

(5):Tritt zusammen mit dem Fehler (4) auf.
L�sung: Einen Dateinamen angeben.

(6):Es wurde versucht auf Variablen zuzugreifen, die sich au�erhalb des Variablenspeichers befinden.
Dies tritt auf, wenn z.b. am Anfang sofort ein "<" steht.
Oder auch, wenn 1000 Variablen generiert werden.
Das w�re der Fall, wenn 1000mal ein ">" steht, aber dazwischen nie ein "<".
L�sung: Den Code �berarbeiten und m�gliche Fehlerquellen ausl�schen.


KORREKTE DARSTELLUNG:
--------------------------
Man muss zwischen 2 BF Codearten unterscheiden.

Einmal die Codes, die f�r Windows / DOS geschrieben wurden
und
Zweitens die Codes, die f�r UNIX Systemen geschrieben wurden.

Sollten Sie einen Code ausprobieren, der f�r UNIX entwickelt worden ist, m�ssen Sie am Anfang der Datei "/u" einf�gen.
Dadurch wird dem Interpreter mitgeteilt, dass es sich um UNIX COde handelt und behandelt die eingegebenen Zeilenumbr�che anders.

Wenn ein Code interpretiert werden soll, der f�r Windows entwickelt wurde, muss �berhaupt nichts angegeben werden.

Beispiel f�r UNIX:

/u
++++++++++[>+++++++>++++++++++>+++<<<-]>++.>+.+++++++
..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.,

(Wichtig:
Das "/u" muss direkt am Anfang stehen!)

Gleiches Beispiel f�r Windows:

++++++++++[>+++++++>++++++++++>+++<<<-]>++.>+.+++++++
..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.,


