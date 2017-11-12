@echo off
REM Berry OS on Windows File System

set GRUBDIR=\berry
rem set GRUBHOME=%SystemDrive%%GRUBDIR%
set GRUBHOME=C:%GRUBDIR%

set MSG=echo
if EXIST %GRUBHOME%\msgbox.js set MSG=%GRUBHOME%\msgbox.js

rem %SystemDrive%
c:
cd %GRUBDIR%\

REM check boot.ini
if EXIST h:\boot.ini set BOOTDRIVE=h:
if EXIST g:\boot.ini set BOOTDRIVE=g:
if EXIST f:\boot.ini set BOOTDRIVE=f:
if EXIST e:\boot.ini set BOOTDRIVE=e:
if EXIST d:\boot.ini set BOOTDRIVE=d:
if EXIST c:\boot.ini set BOOTDRIVE=c:
set BOOTINI=%BOOTDRIVE%\boot.ini
if not EXIST %BOOTINI% goto ABORT1

:CHECKBOOTINI
find /I "default" %BOOTINI% | find "partition(1)" > nul
if %ERRORLEVEL% equ 0 set PARTITION=0
find /I "default" %BOOTINI% | find "partition(2)" > nul
if %ERRORLEVEL% equ 0 set PARTITION=1
find /I "default" %BOOTINI% | find "partition(3)" > nul
if %ERRORLEVEL% equ 0 set PARTITION=2
find /I "default" %BOOTINI% | find "partition(4)" > nul
if %ERRORLEVEL% equ 0 set PARTITION=3

find /I "default" %BOOTINI% | find "rdisk(0)" > nul
if %ERRORLEVEL% equ 0 set RDISK=0
find /I "default" %BOOTINI% | find "rdisk(1)" > nul
if %ERRORLEVEL% equ 0 set RDISK=1
find /I "default" %BOOTINI% | find "rdisk(2)" > nul
if %ERRORLEVEL% equ 0 set RDISK=2
find /I "default" %BOOTINI% | find "rdisk(3)" > nul
if %ERRORLEVEL% equ 0 set RDISK=3

REM make menu.lst
rem set CONF=%GRUBHOME%\menu.lst
set CONF=c:\menu.lst

if EXIST %CONF%.bak del %CONF%.bak
if not EXIST %CONF% goto MAKEMENU
copy %CONF% %CONF%.bak > nul
del %CONF%

:MAKEMENU
echo default=0 > %CONF%
echo timeout=7 >> %CONF%
echo splashimage=(hd%RDISK%,%PARTITION%)/berry/splash.xpm.gz>> %CONF%
if EXIST %GRUBHOME%\berry.sh call %GRUBHOME%\mkmenu.bat "Berry OS " %RDISK% %PARTITION% media ja %CONF%
call %GRUBHOME%\mkmenu.bat "Berry OS " %RDISK% %PARTITION% normal ja %CONF%
call %GRUBHOME%\mkmenu.bat "Berry OS " %RDISK% %PARTITION% failsafe ja %CONF%
call %GRUBHOME%\mkmenu.bat "Berry OS " %RDISK% %PARTITION% normal en %CONF%
call %GRUBHOME%\mkmenu.bat "Berry OS " %RDISK% %PARTITION% failsafe en %CONF%
echo.>> %CONF%
echo title Boot Menu (C:)>> %CONF%
echo rootnoverify (hd%RDISK%,%PARTITION%)>> %CONF%
echo makeactive>> %CONF%
echo chainloader +1>> %CONF%
echo.>> %CONF%
echo title Shutdown>> %CONF%
echo halt>> %CONF%

:BOOTINISETUP
REM
REM Setup bootloader
REM
attrib -r -h -s %BOOTINI%
find "Berry OS Bootloader" %BOOTINI% > nul
if %ERRORLEVEL% equ 0 goto RESETATTRIB
if EXIST %BOOTINI%.grubback goto GRUBADD
copy %BOOTINI% %BOOTINI%.grubback > nul
attrib +r +h +s %BOOTINI%.grubback

:GRUBADD
rem echo.>> %BOOTINI%
echo c:\grldr="Berry OS Bootloader">> %BOOTINI%

:RESETATTRIB
attrib +r +h +s %BOOTINI%

%MSG% Success "GRUB was successfully installed to NTLDR, the Windows bootloader." 64
goto END

:ABORT1
%MSG% Failed "%BOOTINI% not found." 16
goto END

:END
