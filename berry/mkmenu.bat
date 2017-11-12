REM call from setup.bat

set OPT=/berry/vmlinuz boot=cdrom berry_dir=/berry/berry
set FAILSAFE=vga=normal nosound noacpi noapic noscsi nodma nousb nopcmcia nofirewire noagp nomce nodhcp xmodule=vesa

set TITLE=%~1(%5,%4)
set RDISK=%2
set PARTITION=%3
set TYPE=%4
set LANG=lang=%5
set CONF=%6

set OPT=%OPT% %LANG%
if "%TYPE%" == "media" set OPT=%OPT% vga=791 splash=silent overlay=/berry/berry.img desktop=media
if "%TYPE%" == "normal" set OPT=%OPT% vga=791 splash=silent overlay=/berry/berry.img
if "%TYPE%" == "failsafe" set OPT=%OPT% %FAILSAFE%

:MAKEMENU
echo.>> %CONF%
echo title %TITLE%>> %CONF%
echo root (hd%RDISK%,%PARTITION%)>> %CONF%
echo kernel %OPT%>> %CONF%
echo initrd /berry/initrd.gz>> %CONF%
