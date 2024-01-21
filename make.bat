@echo off
set include=%~pd0fasm\include
set arch=x86
if exist "%programfiles(x86)%" set arch=AMD64
if "%1"=="" goto:make
if exist "%~n1.dll" del "%~n1.dll"
"%~pd0fasm\fasm.exe" %*
goto:eof
:make
"%~pd0fasm\fasm.exe" layouts\kbd_ru-us_undead.asm
"%~pd0fasm\fasm.exe" layouts\kbd_us-ru_undead.asm
"%~pd0fasm\fasm.exe" layouts\kbd_ru-us_undead_colemak-dh.asm
"%~pd0fasm\fasm.exe" layouts\kbd_us-ru_undead_colemak-dh.asm
goto:eof
