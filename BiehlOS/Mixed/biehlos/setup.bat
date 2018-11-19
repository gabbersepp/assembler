@echo off

echo BiehlOS v0.0.01
echo ==========================================
echo.          
echo.
echo Zum Bestaetigen der Lizenzbedingungen, bitte eine Taste druecken.
echo Um den Setup abzubrechen, das Fenster schließen.
pause
cls   
echo.   
echo 2. Disk Setup
echo -------------------------------
echo.
echo Bitte eine formatierte Diskette in das Laufwerk a: einlegen.
echo Bitte beachten: Jegliche Daten auf der Diskette gehen verloren!
echo.
pause  
cls
echo.
echo 3. Assembliere Codes...
echo ---------------------------
echo.
@copy fasm.exe src\
@copy rawwritewin.exe src\
cd src

FASM fat.asm
IF NOT EXIST fat.bin GOTO BOOT_ASM_FAILED

fasm boot.asm
IF NOT EXIST boot.bin GOTO BOOT_ASM_FAILED
echo Bootsector erfolgreich assembliert
echo.

FASM kernel.asm kernel.exc
IF NOT EXIST kernel.exc GOTO KERNEL_ASM_FAILED
ECHO Kernel erfolgreich assembliert
echo.

FASM shell.asm shell.exc
IF NOT EXIST shell.exc GOTO SHELL_ASM_FAILED
ECHO Shell erfolgreich assembliert
echo.

FASM test.asm
echo.

GOTO SKIP_K_F

:KEYB_ASM_FAILED
ECHO Es trat ein Fehler auf, beim assemblieren einer oder mehrerer Dateien.
ECHO Der Setup wird fortgesetzt, da die Datei(en) nicht wichtig ist(sind).
GOTO SKIP2

:SKIP_K_F
echo Alles erfolgreich assembliert.
:SKIP2
echo Bitte Taste drücken, um mit dem Setup fortzufahren.
PAUSE
CLS

ECHO.
ECHO 3. Kopiere Systemdateien
ECHO -------------------------
ECHO.
ECHO Formatiere a:\
rawwritewin boot.bin 
ECHO Kopiere Kernel auf a:\
copy kernel.exc a:\
echo.
ECHO Kopiere Shell auf a:\
copy shell.exc a:\
copy test.bin a:\
echo.
echo.
ECHO Kopiere Textdateien
mkdir a:\src
copy *.asm a:\src\
cd ..
copy *.txt a:\
cd src
ECHO.
ECHO Loesche temporaere Dateien...
ECHO.
del rawwritewin.exe, fasm.exe, kernel.bin, shell.bin, boot.bin, fat.bin
cd ..
ECHO.
ECHO Setup erfolgreich beendet.
ECHO Das BiehlOS kann nun von dieser Diskette gestartet werden.
GOTO SETUP_END

:KERNEL_ASM_FAILED
:BOOT_ASM_FAILED
:SHELL_ASM_FAILED
ECHO Setup nicht errolgreich!
ECHO Eine wichtige Systemdatei konnte nicht assembliert werden.
ECHO Setup wird beendet.

:SETUP_END
@echo on
PAUSE
