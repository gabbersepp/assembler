BRAIN.COM v1.0
Ein kleiner, einfacher Brainfuck Interpreter.

Ich hafte für keinerlei Schäden. Mehr Informationen in der beiliegenden gpl.txt

(C) 2006 by Josef Biehler
URL: biehler-josef.de
E-Mail: support@biehler-josef.de

Folgende Dateien müssten mitgeliefert worden sein:
----------------------------
brain.asm | Der Sourcecode von BRAIN.COM
brain.com | Das Programm
README.txt| Diese Datei
Neu.txt   | Auflistung der Neuerungen
-------------------------------

Zur Kontaktaufnahme bitte obige E-MAil Adresse benutzen.

BEDIENUNG:
------------
Es steht dem Programmierer ein Variablenfeld von 1000 Stück bereit.
Außerdem darf jeder BF Code 10000 Bytes lang sein (ca. 10Kb)
Die Bedienung von BRAIN.COM ist einfach:
Einfach in der Kommandozeile "brain dateiname.xy" eingeben und schon läuft alles.
Allerdings muss unter 2 Arten von Brainfuck Code unterschieden werden!
Für nähere Informationen bitte den Punkt "Korrekte Darstellung" lesen.

FEHLER:
------------
BRAIN.COM beinhaltet mehrere Fehlerüberprüfungsroutinen.
Es können folgende Meldungen auftreten:
(1):"Der Interpreter fand eine ungleiche ANzahl von '[' und ']' Klammern vor."
(2):"Datei nicht gefunden."
(3):"Fehler beim Oeffnen der Datei"
(4):"Kein Dateiname angegeben."
(5):"Richtige Benutzung: brain.com dateiname.xy"
(6):"Zugriffsfehler der Variablen."

Mögliche Probleme:
(1):Der Interpreter überprüft zu allererst, ob zu jeder "[" auch eine "]" Klammer vorhanden ist.
Ist dies nicht der Fall, gibt er obige Meldung aus.
Lösung: Den BF Code nochmals durchdenken und Klammern schließen, bzw. entfernen

(2):Der Interpreter hat die angegebene Datei nicht gefunden.
Lösung: Den richtigen Dateinamen angeben.
Hinweis: Der Dateiname darf keine Sonderzeichen enthalten!

(3):Beim versuch die Datei auszulesen trat ein Fehler auf.
Es könnte vielleicht sein, dass auf die Datei bereits zugegriffen wird o.ä.
Lösung: Keine Ahnung, trat bei mir noch nie auf.

(4):Es wurde kein Dateiname angegeben.
Lösung: Einen Dateinamen angeben.

(5):Tritt zusammen mit dem Fehler (4) auf.
Lösung: Einen Dateinamen angeben.

(6):Es wurde versucht auf Variablen zuzugreifen, die sich außerhalb des Variablenspeichers befinden.
Dies tritt auf, wenn z.b. am Anfang sofort ein "<" steht.
Oder auch, wenn 1000 Variablen generiert werden.
Das wäre der Fall, wenn 1000mal ein ">" steht, aber dazwischen nie ein "<".
Lösung: Den Code überarbeiten und mögliche Fehlerquellen auslöschen.


KORREKTE DARSTELLUNG:
--------------------------
Man muss zwischen 2 BF Codearten unterscheiden.

Einmal die Codes, die für Windows / DOS geschrieben wurden
und
Zweitens die Codes, die für UNIX Systemen geschrieben wurden.

Sollten Sie einen Code ausprobieren, der für UNIX entwickelt worden ist, müssen Sie am Anfang der Datei "/u" einfügen.
Dadurch wird dem Interpreter mitgeteilt, dass es sich um UNIX COde handelt und behandelt die eingegebenen Zeilenumbrüche anders.

Wenn ein Code interpretiert werden soll, der für Windows entwickelt wurde, muss überhaupt nichts angegeben werden.

Beispiel für UNIX:

/u
++++++++++[>+++++++>++++++++++>+++<<<-]>++.>+.+++++++
..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.,

(Wichtig:
Das "/u" muss direkt am Anfang stehen!)

Gleiches Beispiel für Windows:

++++++++++[>+++++++>++++++++++>+++<<<-]>++.>+.+++++++
..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.,


