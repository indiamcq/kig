:: Installer for kig (Kalaam Image Gallery)
@echo off
set startpath=%~dp0
set echoecholog=on
set projectlog="%startpath%Instal.log"
set iview="%ProgramFiles(x86)%\IrfanView\i_view32.exe"
set fsr="%ProgramFiles(x86)%\FastStone Photo Resizer\FSResizer.exe"
set irfanview32="%ProgramFiles%\IrfanView\i_view32.exe"
set fsr32="C:\Program Files\FastStone Photo Resizer\FSResizer.exe"  
call :echolog "=============================================="
call :echolog %date%
call :echolog "----------------------------------------------"
call :echolog KIG installer.
echo.
call :echolog "Set up for 64bit and 32 bit Win 7 and 8 machines."
call :echolog "May need tweaking for XP"
call :echolog "----------------------------------------------"
call :checkdir "C:\ProgramData\kig"
call :checkdir "C:\Programs\kig"
FOR /F " delims=" %%s IN ('reg query HKEY_CURRENT_USER\Environment /v PATH') DO set upath=%%s
echo %upath% > "C:\ProgramData\kig\userpath-backup.txt"
set upath=%upath:~22%
if "%upath%" == "~22" set upath=c:\users\%USERNAME%
if "%upath:~-1008%" == "%upath:~-10024%" (
  rem the condition on the next line ensures the path is not added twice
  if "%upath:C:\Programs\kig=%" == "%upath%" setx Path "%upath%;C:\Programs\kig"
  call :echolog The KIG path is in your User PATH.
) else (
  call :echolog User path too long to be added to automatically.
  call :echolog "Please add  ;C:\Programs\kig to the end of your User or System PATH manually.""
)
set kigpath=C:\Programs\kig
call :echolog Coping files to C:\Programs\kig folder
copy /y "%startpath%\files\*.cmd" "%kigpath%\*.cmd"
copy /y "%startpath%\files\*.exe" "%kigpath%\*.exe"
if not exist "%startpath%\files\matchbook-site-lookup.txt" copy /y "%startpath%\files\matchbook-site-lookup.txt" "C:\ProgramData\kig\matchbook-site-lookup.txt"
if not exist "%startpath%\files\production-site-lookup.txt" if exist "%startpath%\files\production-site-lookup.txt" copy /y "%startpath%\files\production-site-lookup.txt" "C:\ProgramData\kig\production-site-lookup.txt"
if not exist "%startpath%\files\quality.ini" if exist "%startpath%\files\quality.ini" copy /y "%startpath%\files\quality.ini" "C:\ProgramData\kig\quality.ini"
if not exist "%startpath%\files\server.txt" copy /y "%startpath%\files\server.txt" "C:\ProgramData\kig\server.txt"
if exist "%kigpath%\kig.cmd" call :echolog "kig.cmd installed"
if not exist "%kigpath%\kig.cmd" call :echolog "CRITICAL ERROR. kig.cmd not found."
if not exist "%kigpath%\kig.cmd" set critical=critical
set /P server=Enter "y" if you want to use Matchbook site number lookup: 
if "%server%" == "y" copy /y "%startpath%\files\matchbook-site-lookup.txt" "C:\ProgramData\kig\site-lookup.txt"
if "%server%" == "y" echo You will need to edit the C:\ProgramData\kig\site-lookup.txt file for the matchbook server you are using.
if "%server%" neq "y" if exist "C:\ProgramData\kig\production-site-lookup.txt" copy /y "%startpath%\files\production-site-lookup.txt" "C:\ProgramData\kig\site-lookup.txt"
if not exist "C:\ProgramData\kig\production-site-lookup.txt" echo You will need to add a file C:\ProgramData\kig\production-site-lookup.txt to the folder C:\ProgramData\kig

call :echolog Checking for image programs:
rem Sort out 64 bit from 32 bit
if exist "C:\Program Files (x86)" (
  if not exist %iview% call :echolog "CRITICAL ERROR. Irfanview not installed normally. Please do a full Irfanview install"
  if not exist %iview% set critical=critical
  if exist %iview% call :echolog "    Irfanview found."

  if not exist %fsr% call :echolog "WARNING. FastStone Photo Resizer NOT found! This is only needed for style option 0"
  if not exist %fsr% set warning=warning
  if exist %fsr% call :echolog "     FastStone Photo Resizer found!"

) else (
  if not exist %irfanview32% call :echolog "CRITICAL ERROR. Irfanview not installed normally. Please do a full Irfanview install"
  if not exist %iview32% set critical=critical
  if exist %irfanview32% call :echolog "    Irfanview found."
  

  if not exist %fsr32% call :echolog "WARNING. FastStone Photo Resizer NOT found! This is only needed for style option 0"
  if not exist %fsr32% set warning=warning
  if exist %fsr32% call :echolog "     FastStone Photo Resizer found!"
)
set inifile="C:\Users\%USERNAME%\AppData\Roaming\IrfanView\i_view32.ini"
if not exist %inifile% call :echolog "CRITICAL ERROR. Irfanview settings file not found at C:\Users\%USERNAME%\AppData\Roaming\IrfanView It may not have been used or is not installed. Please run Irfanview once before using KIG."
if not exist %inifile% set critical=critical
if exist %inifile% call :echolog "    FastStone Photo Resizer found."

if defined critical call :echolog "Please read messages above as some CRITICAL errors occured."
if defined warning call :echolog "Please read messages above as some WARNING errors occured."
if exist "%kigpath%\kig.cmd" call :echolog KIG installed!
start "notepad.exe" "%projectlog%"
set /P stop=Press enter when done: 
goto :eof

:checkdir
:: Description: checks if dir exists if not it is created
:: See also: ifnotexist
:: Required preset variabes: 1
:: projectlog
:: Optional preset variables:
:: echodirnotfound
:: Required parameters: 1
:: dir
:: Required functions:
:: funcdebugstart
:: funcdebugend
if defined masterdebug call :funcdebugstart checkdir
set dir=%~1
set report=Checking dir %dir%
if exist %dir% (
      echo . . . Found! %dir% 
) else (
    call :removecommonatstart dirout "%dir%"
    if defined echodirnotfound echo Creating . . . %dirout%
    call :echolog ". . . not found. %dir%" 
    call :echolog mkdir %dir% 
    mkdir "%dir%"
)
if defined masterdebug call :funcdebugend
goto :eof

:echolog
:: Description: echoes a message to log file and to screen
:: Class: command - internal
:: Required preset variables: 1
:: projectlog
:: Required parameters: 1
:: message
if defined masterdebug call :funcdebugstart echolog
set message=%~1 %~2 %~3 %~4 %~5 %~6 %~7 %~8 %~9
if defined echoecholog echo %message%
echo %message% >>%projectlog%
set message=
if defined masterdebug call :funcdebugend
goto :eof