;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BiehlOS
;; Mein Versuch, ein Betriebssystem zu entwickeln
;; (c) 2005-2006 by Josef Biehler
;; http://biehler-josef.de
;; biehlos@biehler-josef.de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Das jetzt eingebaute Dateisystem bietet keine Ordnerfunktion mehr.
Dieser scheinbare Rückschritt deshalb, weil es einfacher zu handhaben ist und ich den Überblick eher behalte.

Das OS kann u.a. mit Bochs getestet werden.
Der einfachheit halber, habe ich bereits ein Bochs Dowbnload Packet bereit gestellt.
Dazu unter biehlos.biehler-josef.de unter "Programme" das Bochs Packet runterladen und entpacken.
Dann diese BiehlOS Version entpacken und die Datei "boot.bin" in das Bochs Verzeichnis kopieren.
Anschließend einfach "start_os.bat" anklicken.

Es sind nun die ersten 2 Befehle verfügbar:

		help
		shutdown

Meine aktuelle Planung sieht vor, dass ich einen eigenen VGA Treiber für den 13h Modus schreibe.
