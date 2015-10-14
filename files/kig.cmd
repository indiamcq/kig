@echo off
if "%2" == "debug" echo on
rem usage: kig iso_site_code gallery_id style_number [site_number]
rem must be started from folder with photos for inclusion in image gallery
rem can also be started with just kig. Then answer prompts.
rem ver 5 with 3 original styles supported with some Fast Stone intergration
echo.
echo Making HTML and resized photos and thumbnails for K Image gallery.
echo.
rem the following shoud not need editing
set mathbookip=192.16.10.253
set kigpath=C:\Programs\kig
set setcontrol=%kigpath%\SetTextInControl.exe
set sendtext=%kigpath%\SendText.exe
set controlclickxy=%kigpath%\ControlClickxy.exe
set controlclick=%kigpath%\ControlClick.exe
set sendtextcontrol=%kigpath%\SendTexttoControl.exe      
set inifile=C:\Users\%USERNAME%\AppData\Roaming\IrfanView\i_view32.ini
set kigprogramdata=C:\ProgramData\kig
set kiginifile=%kigprogramdata%\i_view32.ini
set kigsitelookup=%kigprogramdata%\site-lookup.txt
set outpath=%cd%\readytoupload


rem set the program path
if exist "C:\Program Files (x86)" (
  set irfanview="C:\Program Files (x86)\IrfanView\i_view32.exe"
  set fsr="C:\Program Files (x86)\FastStone Photo Resizer\FSResizer.exe"
) else (
  set irfanview="C:\Program Files\IrfanView\i_view32.exe"
  set fsr="C:\Program Files\FastStone Photo Resizer\FSResizer.exe"
)
rem echo on
set fspr=FastStone Photo Resizer
set numb=
set endmarkup=
set cl=%1
set site=%1
set galleryname=%2
set style=%3
set projnumb=%4
if /I "%projnumb%" ==  "m" call :setserver matchbook
if /I "%projnumb%" ==  "p" call :setserver production
rem set the server
if not defined server call :getserver
if not defined server set server=matchbook
if defined server copy /y "%kigprogramdata%\%server%-site-lookup.txt" "%kigprogramdata%\site-lookup.txt"
@echo Server set to %server%
@echo off
rem Lookup project number 
if not defined projnumb if exist "%kigsitelookup%" call :lookup %site% "%kigsitelookup%"
if defined lookupreturn set projnumb=%lookupreturn%
if defined lookupreturn echo Site number for %site% set to: %lookupreturn%
if not exist "%kiginifile%" copy "%inifile%" "%kiginifile%"

rem make sure variables are set
if not defined site echo usage with parameters: kig iso_site_code gallery_id style_number [site_number] &echo.
if not defined site echo You must specify a Project code.&set /P site=Enter Project code: 
if not defined galleryname echo How do you want to distinguish this gallery from other galleries?&set /P galleryname=Gallery name or code: 
if not defined style echo What style do you want for the pictures?&set /P style=Choose theme number 1 or 2 or 3 or 0 for use with FastStone. Blank = 1: 
if not defined projnumb echo What is the project number?&set /P projnumb=Enter number or leave blank for site code: 
if not defined style set style=1
if not defined galleryname set galleryname=1
if not exist %irfanview% echo %irfanview% was not found.&echo Only the HTML will be created.&echo You will have to create the files manually!
if not exist %fsr% echo %fsr% was not found.&echo Only the HTML will be created.&echo You will have to create the files manually!
if exist "%cd%\readytoupload\*.jpg" del "%cd%\readytoupload\*.jpg"
rem HTML
echo ^<script type="text/javascript" src="/sites/default/files/gallery/imageGallery.js"^>^</script^> > html.txt
echo ^<p^>About these photos^</p^> >> html.txt
echo ^<div class="image-gallery"^> >> html.txt
set numb=
:: generate the file links and files
call :style%style%
echo %endmarkup% >> html.txt
echo ^</div^> >> html.txt
echo Finished!
start notepad html.txt
if not defined cl pause
goto :eof

:style1
if not exist "%cd%\readytoupload" md readytoupload
echo ----- make large size and thumb with no borders ----- 
FOR /F " delims=" %%s IN ('dir /b *.jpg') DO set curfile=%%s &call :processfiles
goto :eof

:style2
if not exist "%cd%\readytoupload" md readytoupload
FOR /F " delims=" %%s IN ('dir /b *.jpg') DO set curfile=%%s &call :processhtml
echo ----- make thumb with 1 px black border ----- 
set curini=C:\ProgramData\kig\thumb-border1pxwhite.ini
if exist "%curini%" (
  copy /y "%curini%" "%inifile%"
) else (
  if exist %irfanview% call %irfanview% /killmesoftly
  call :advancedoff
  call setini "%inifile%" Batch  AdvCanvas 1
  call setini "%inifile%" Effects CanvL -1
  call setini "%inifile%" Effects CanvR -1
  call setini "%inifile%" Effects CanvT -1
  call setini "%inifile%" Effects CanvB -1
  call setini "%inifile%" Effects CanvInside 1
  call setini "%inifile%" Effects CanvColor 0
    copy /y "%inifile%" "%curini%"
)
set thumb=_thumb
set numb=
set options=/resize_long=215 /resample /aspectratio /jpgq=30 /advancedbatch 
FOR /F " delims=" %%s IN ('dir /b *.jpg') DO set curfile=%%s &call :processfile
echo ----- make full with 10 px white border ----- 
set curini=C:\ProgramData\kig\full-border10pxwhite.ini
if exist "%curini%" (
  copy /y "%curini%" "%inifile%"
) else (
  if exist %irfanview% call %irfanview% /killmesoftly
  call :advancedoff
  call setini "%inifile%" Batch AdvCanvas 1
  call setini "%inifile%" Effects CanvL -10
  call setini "%inifile%" Effects CanvR -10
  call setini "%inifile%" Effects CanvT -10
  call setini "%inifile%" Effects CanvB -10
  call setini "%inifile%" Effects CanvInside 1
  call setini "%inifile%" Effects CanvColor 16777215
    copy /y "%inifile%" "%curini%"
)
set thumb=
set numb=
set options=/resize_long=1024 /resample /aspectratio /jpgq=70 /advancedbatch 
FOR /F " delims=" %%s IN ('dir /b *.jpg') DO set curfile=%%s &call :processfile
goto :eof

:style3
if exist "%cd%\background\*.jpg" del "%cd%\background\*.jpg"
if exist "%cd%\foreground1\*.jpg" del "%cd%\foreground1\*.jpg"
if exist "%cd%\foreground2\*.jpg" del "%cd%\foreground2\*.jpg"

FOR /F " delims=" %%s IN ('dir /b *.jpg') DO set curfile=%%s &call :processhtml
echo ----- make thumb with white 1 px border ----- 
set curini=C:\ProgramData\kig\thumb-border1pxwhite.ini
if exist "%curini%" (
  copy /y "%curini%" "%inifile%"
) else (
  if exist %irfanview% call %irfanview% /killmesoftly
  call :advancedoff
  call setini "%inifile%" Batch  AdvCanvas 1
  call setini "%inifile%" Effects CanvL -1
  call setini "%inifile%" Effects CanvR -1
  call setini "%inifile%" Effects CanvT -1
  call setini "%inifile%" Effects CanvB -1
  call setini "%inifile%" Effects CanvInside 1
  call setini "%inifile%" Effects CanvColor 16777215
  copy /y "%inifile%" "%curini%"
)
set outpath=%cd%\readytoupload
set thumb=_thumb
set numb=
set options=/resize_long=215 /resample /aspectratio /jpgq=30 /advancedbatch 
FOR /F " delims=" %%s IN ('dir /b *.jpg') DO set curfile=%%s &call :processfile
:: make forground picture step 1
echo ----- making foreground to size step 1 ----- 
set outpath=%cd%\foreground1
set thumb=
set numb=
set options=/resize_long=1024 /resample /aspectratio /jpgq=100
FOR /F " delims=" %%s IN ('dir /b *.jpg') DO set curfile=%%s &call :processfile
:: make forground picture step 2
echo ----- cropping foreground and adding white 1 px border step 2 ----- 
set curini=C:\ProgramData\kig\crop25x25-border1pxblack.ini
if exist "%curini%" (
  copy /y "%curini%" "%inifile%"
) else (
    if exist %irfanview% call %irfanview% /killmesoftly
    call :advancedoff
    call setini "%inifile%" Batch AdvCanvas 1
    call setini "%inifile%" Batch AdvCrop 1
    call setini "%inifile%" Batch AdvCropW 973
    call setini "%inifile%" Batch AdvCropH 718
    call setini "%inifile%" Batch AdvCropC 4
    call setini "%inifile%" Effects CanvColor 16777215
    copy /y "%inifile%" "%curini%"
)
set outpath=%cd%\foreground2
set thumb=
set numb=
set options= /jpgq=100 /advancedbatch 
FOR /F " delims=" %%s IN ('dir /b foreground1\*.jpg') DO set curfile=%cd%\foreground1\%%s &call :processfile
:: make background picture ===========================================
echo ----- making background to size and making darker----- 
set curini=C:\ProgramData\kig\full-darkened-100.ini
if exist "%curini%" (
  copy /y "%curini%" "%inifile%"
) else (
  if exist %irfanview% call %irfanview% /killmesoftly
  call :advancedoff
  call setini "%inifile%" Batch AdvResize 1
  call setini "%inifile%" Batch AdvResizeL 1024.00
  call setini "%inifile%" Batch AdvBrightness 1
  call setini "%inifile%" Batch AdvBrightnessVal -100
  copy /y "%inifile%" "%curini%"
)
set outpath=%cd%\background
set thumb=
set numb=
set options=/resize_long=1024 /resample /aspectratio /jpgq=100 /advancedbatch 
FOR /F " delims=" %%s IN ('dir /b *.jpg') DO set curfile=%%s &call :processfile
:: add watermark to background
echo ----- adding foreground to background ----- 
set curini=C:\ProgramData\kig\watermark.ini
if exist "%curini%" (
  copy /y "%curini%" "%inifile%"
) else (
  if exist %irfanview% call %irfanview% /killmesoftly
  call :advancedoff
  call setini "%inifile%" Batch AdvWatermark 1
  call setini "%inifile%" BatchWatermark Coord 25;25;
  call setini "%inifile%" BatchWatermark Corner 0
  call setini "%inifile%" BatchWatermark Transp 0
  copy /y "%inifile%" "%curini%"
)
set thumb=
set numb=
set subfolder=background
set outpath=%cd%\readytoupload
set options=/jpgq=70 /advancedbatch 
FOR /F " delims=" %%s IN ('dir /b background\*.jpg') DO set curfile=%cd%\%subfolder%\%%s &call :processwmfile
goto :eof

:style0
if exist %fsr% (
  call :start %fsr%
) else (
  echo Free Stone Installer was not found.
)
if not exist "%cd%\readytoupload" md readytoupload
FOR /F " delims=" %%s IN ('dir /b *.jpg') DO set curfile=%%s &call :processhtml
echo ----- make thumb with white 1 px border ----- 
set curini=C:\ProgramData\kig\thumb-border1pxwhite.ini
if exist "%curini%" (
  copy /y "%curini%" "%inifile%"
) else (
  if exist %irfanview% call %irfanview% /killmesoftly
  call :advancedoff
  call setini "%inifile%" Batch  AdvCanvas 1
  call setini "%inifile%" Effects CanvL -1
  call setini "%inifile%" Effects CanvR -1
  call setini "%inifile%" Effects CanvT -1
  call setini "%inifile%" Effects CanvB -1
  call setini "%inifile%" Effects CanvInside 1
  call setini "%inifile%" Effects CanvColor 16777215
  copy /y "%inifile%" "%curini%"
)
set outpath=%cd%\readytoupload
set thumb=_thumb
set numb=
set options=/resize_long=215 /resample /aspectratio /jpgq=30 /advancedbatch 
FOR /F " delims=" %%s IN ('dir /b *.jpg') DO set curfile=%%s &call :processfile
if exist %fsr% (
  echo setting %fspr% options.
  echo You mast click on Advance options and set the appropriate style.ccf
  :: clear text in folder control
  call "%setcontrol%" "%fspr%" "[CLASS:TEdit; INSTANCE:1]" ""
  :: clear text in file nameing control
  call "%setcontrol%" "%fspr%" "[CLASS:TbsCustomEdit; INSTANCE:1]" ""
  :: send text to  folder control
  call "%sendtextcontrol%" "%fspr%" "[CLASS:TEdit; INSTANCE:1]" "%cd%\{enter}"
  :: send text to renaming control
  call "%sendtextcontrol%" "%fspr%" "[CLASS:TbsCustomEdit; INSTANCE:1]" "gallery-%galleryname%{#}{#}"
  :: add all files to Input list
  call "%controlclick%" "%fspr%" "[CLASS:TbsSkinButton; INSTANCE:11]"
  :: make a folder if not exist
  if not exist "%cd%\readytoupload" md readytoupload
  :: now specify the output folder
  call "%setcontrol%" "%fspr%" "[CLASS:TEdit; INSTANCE:2]" "%cd%\readytoupload"
)
goto :eof

:advancedoff
call setini "%inifile%" Batch AdvCrop 0
call setini "%inifile%" Batch AdvResize 0
call setini "%inifile%" Batch AdvCanvas 0
call setini "%inifile%" Batch AdvBrightness 0
call setini "%inifile%" Batch AdvWatermark 0
goto :eof

:processfiles
set /a numb+=1
set curnumb=0%numb%
set curnumb=%curnumb:~-2%

set bigfilename=gallery-%galleryname%_%curnumb%.jpg
set thumbfilename=gallery-%galleryname%_%curnumb%_thumb.jpg
rem Convert files to new size
rem Write the code for each picture
echo %endmarkup%^<a  >> html.txt
echo href="/sites/default/files/media/%site%/%bigfilename%"^>^<img alt="" >> html.txt
echo src="/sites/default/files/media/%site%/%thumbfilename%" style="width: 215px; height: 162px !important;" >> html.txt
if exist %irfanview% call %irfanview% "%curfile%" /resize_long=1024 /resample /aspectratio /jpgq=70 /convert="%outpath%\%bigfilename%"
if exist %irfanview% call %irfanview% "%curfile%" /resize_long=215 /resample /aspectratio /jpgq=30 /convert="%outpath%\%thumbfilename%"
set endmarkup=/^^^>^^^</a^^^>^^^&nbsp;
if exist "%outpath%\%bigfilename%" (
  echo made %bigfilename% and %thumbfilename% 
) else (
  echo output file %bigfilename% missing 
)
goto :eof

:processfile
set /a numb+=1
set curnumb=0%numb%
set curnumb=%curnumb:~-2%
set filename=gallery-%galleryname%_%curnumb%%thumb%.jpg
rem Convert file to new size
if exist %irfanview% call %irfanview% "%curfile%" %options% /convert="%outpath%\%filename%"
if exist "%outpath%\%filename%" (
  echo made %filename% 
) else (
  echo output file %filename% missing 
)
goto :eof

:processwmfile
set /a numb+=1
set curnumb=0%numb%
set curnumb=%curnumb:~-2%
set filename=gallery-%galleryname%_%curnumb%%thumb%.jpg
:: set curfile=%cd%\%subfolder%\%filename%
rem Convert file to new size
if exist %irfanview% call %irfanview% /killmesoftly
call setini "%inifile%" BatchWatermark Image "%cd%\foreground2\%filename%"
if exist %irfanview% call %irfanview% "%curfile%" %options% /convert="%outpath%\%filename%"
if exist "%outpath%\%filename%" (
  echo made %filename% 
) else (
  echo output file %filename% missing 
)
goto :eof


:processhtml
set /a numb+=1
set curnumb=0%numb%
set curnumb=%curnumb:~-2%
set outpath=%cd%\readytoupload
set bigfilename=gallery-%galleryname%_%curnumb%.jpg
set thumbfilename=gallery-%galleryname%_%curnumb%_thumb.jpg
rem Convert files to new size
rem Write the code for each picture
echo %endmarkup%^<a  >> html.txt
echo href="/sites/default/files/media/%site%/%bigfilename%"^>^<img alt="" >> html.txt
echo src="/sites/default/files/media/%site%/%thumbfilename%" style="width: 215px; height: 162px !important;" >> html.txt
set endmarkup=/^^^>^^^</a^^^>^^^&nbsp;
goto :eof

:start
set var1=%~1
set var2=%~2
set var3=%~3
set var4=%~4
if "%var1%" == "%var1: =%" (
 start "%var1%" "%var2%" "%var3%" "%var4%"
) else (
 start "" "%var1%" "%var2%" "%var3%" "%var4%"
)
echo started "%var1%" %var2% %var3% %var4%
goto :eof

:getline
:: Description: Get a specific line from a file
:: Class: command - internal
:: Required parameters:
:: linetoget
:: file
if defined echogetline echo on
set /A count=%~1-1
if "%count%" == "0" (
    for /f %%i in (%~2) do (
        set getline=%%i
        goto :eof
    )
) else (
    for /f "skip=%count% " %%i in (%~2) do (
        set getline=%%i
        goto :eof
    )
)
@echo off
goto :eof

:border
set width=%~1
set color=%~2
if "%color%" == "white" set color=16777215
if "%color%" == "black" set color=0
call setini "%inifile%" Batch  AdvCanvas 1
call setini "%inifile%" Effects CanvL -%width%
call setini "%inifile%" Effects CanvR -%width%
call setini "%inifile%" Effects CanvT -%width%
call setini "%inifile%" Effects CanvB -%width%
call setini "%inifile%" Effects CanvInside 1
call setini "%inifile%" Effects CanvColor %color%
goto :eof

:lookup
:: Description: Lookup a value in a file before the = and get value after the =
:: Required parameters:
:: findval
:: datafile
SET findval=%~1
set datafile=%~2
set lookupreturn=
FOR /F "tokens=1,2 delims==" %%i IN (%datafile%) DO @IF %%i EQU %findval% SET lookupreturn=%%j
rem @echo %lookupreturn%
goto :eof

:getline
:: Description: Get a specific line from a file
:: Class: command - internal
:: Required parameters:
:: linetoget
:: file
if defined echogetline echo on
set /A count=%~1-1
if "%count%" == "0" (
    for /f %%i in (%~2) do (
        set getline=%%i
        goto :eof
    )
) else (
    for /f "skip=%count% " %%i in (%~2) do (
        set getline=%%i
        goto :eof
    )
)
goto :eof

:getserver
call :getline 1 "%kigprogramdata%\server.txt"
set server=%getline%
goto :eof

:setserver
set server=%~1
echo %server% > %kigprogramdata%\server.txt
set projnumb=
goto :eof
