@echo off
set include=%~pd0fasm\include
set arch=x86
if exist "%programfiles(x86)%" set arch=AMD64
if "%1"=="" goto:make
if exist "%~n1.dll" del "%~n1.dll"
"%~pd0fasm\fasm.exe" %*
goto:eof
:make
"%~pd0fasm\fasm.exe" layouts\kbdusru.asm
"%~pd0fasm\fasm.exe" layouts\workman.asm
"%~pd0fasm\fasm.exe" layouts\kbdruen_undead.asm
"%~pd0fasm\fasm.exe" layouts\kbdusru_undead.asm
"%~pd0fasm\fasm.exe" setup\reg_layout.asm
goto:eof
