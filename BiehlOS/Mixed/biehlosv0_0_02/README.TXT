;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BiehlOS
;; Mein Versuch, ein Betriebssystem zu entwickeln
;; (c) 2005-2006 by Josef Biehler
;; http://biehler-josef.de
;; biehlos@biehler-josef.de
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Das jetzt eingebaute Dateisystem bietet keine Ordnerfunktion mehr.
Dieser scheinbare R�ckschritt deshalb, weil es einfacher zu handhaben ist und ich den �berblick eher behalte.

Das OS kann u.a. mit Bochs getestet werden.
Der einfachheit halber, habe ich bereits ein Bochs Dowbnload Packet bereit gestellt.
Dazu unter biehlos.biehler-josef.de unter "Programme" das Bochs Packet runterladen und entpacken.
Dann diese BiehlOS Version entpacken und die Datei "boot.bin" in das Bochs Verzeichnis kopieren.
Anschlie�end einfach "start_os.bat" anklicken.

Es sind nun die ersten 2 Befehle verf�gbar:

		help
		shutdown

Meine aktuelle Planung sieht vor, dass ich einen eigenen VGA Treiber f�r den 13h Modus schreibe.
