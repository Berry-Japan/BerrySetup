@echo off
REM Berry OS on Windows File System

set GRUBDIR=\BERRY
rem set GRUBHOME=%SystemDrive%%GRUBDIR%
set GRUBHOME=C:\%GRUBDIR%

set MSG=echo
if EXIST %GRUBHOME%\msgbox.js set MSG=%GRUBHOME%\msgbox.js

REM check boot.ini
if EXIST h:\boot.ini set BOOTDRIVE=h:
if EXIST g:\boot.ini set BOOTDRIVE=g:
if EXIST f:\boot.ini set BOOTDRIVE=f:
if EXIST e:\boot.ini set BOOTDRIVE=e:
if EXIST d:\boot.ini set BOOTDRIVE=d:
if EXIST c:\boot.ini set BOOTDRIVE=c:
set BOOTINI=%BOOTDRIVE%\boot.ini
if not EXIST %BOOTINI% goto ABORT1

REM
REM Recover bootloader
REM
attrib -r -h -s %BOOTINI%
if not EXIST %BOOTINI%.grubback goto NOBACK
find "Berry OS Bootloader" %BOOTINI% > nul
if %ERRORLEVEL% equ 1 goto NOGRUB
attrib -r -h -s %BOOTINI%.grubback
rem if EXIST %BOOTINI%.new del %BOOTINI%.new
rem copy %BOOTINI% %BOOTINI%.new > nul
del %BOOTINI%
copy %BOOTINI%.grubback %BOOTINI% > nul
del %BOOTINI%.grubback
attrib +r +h +s %BOOTINI%

%MSG% Success "GRUB was successfully uninstalled from NTLDR, Windows bootloader." 64
goto END

:ABORT1
%MSG% Failed "%BOOTINI% not found." 16
goto END

:NOBACK
attrib +r +h +s %BOOTINI%
%MSG% Failed "%BOOTINI%.grubback not found." 16
goto END

:NOGRUB
attrib +r +h +s %BOOTINI%
%MSG% Failed "No GRUB in %BOOTINI%." 16
goto END

:END
