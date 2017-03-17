@echo off
if "%2" == "debug" echo on
set debugstack=00
rem usage: kig iso_site_code gallery_id style_number [border_color]
rem must be started from folder with photos for inclusion in image gallery
rem can also be started with just kig. Then answer prompts.
rem ver 5 with 3 original styles supported with some Fast Stone intergration
rem ver 6 replaced 4th param optional border color. Some named colors supported

:main
@call :funcdebugger main
echo.
echo Making HTML and resized photos and thumbnails for K Image gallery.
echo.
echo Available from: https://github.com/indiamcq/kig
echo.
rem get parameters if passed
set cl=%1
set site=%1
set galleryname=%2
set style=%3
set usercolor=%4
call :setup
call :iniread "%userpref%"
call :uifallback
call :fileloop process html
:: generate the file links and files
call :style%style%
echo Finished!
start notepad html.txt
if not defined cl pause
@call :funcdebugger main end
goto :eof

:fileloop
@call :funcdebugger %~0 
:: Description: loop through files in current directory
set function=%~1
set filetype=%~2
set filesize=%~3
set filestyle=%~4
call :%filesize%%filestyle%
set numb=
echo ---------- Making %making% ----------
if "%filestyle%" == "solidborder" call :prepini
if "%filestyle%" == "style3step4" call :prepini
set subdir=
if "%filestyle%" == "style3step1" set outpath=%cd%\foreground1
if "%filestyle%" == "style3step2" set outpath=%cd%\foreground2
if "%filestyle%" == "style3step3" set outpath=%cd%\background
if "%filestyle%" == "style3step2" set subdir=forground1\
if "%filestyle%" == "style3step4" set subdir=background\
if "%filetype%" == "html" call :htmlpre
echo %subdir%
FOR /F " delims=" %%s IN ('dir /b %subdir%*.jpg') DO set curfile=%%s &call :%function%
if "%filetype%" == "html" call :htmlpost
@call :funcdebugger %~0 end
goto :eof

:style1
@call :funcdebugger %~0
:: Description: Creates the firts style of images
call :fileloop process jpg thumb noborder
rem call :fileloop process jpg large noborder
@call :funcdebugger %~0 end
goto :eof

:style2
@call :funcdebugger %~0
:: Description: make picture with border, default white
rem  ----- make thumb with 2 px border ----- 
call :backupini
call :fileloop process jpg thumb solidborder
rem ----- make full with 10 px border ----- 
call :fileloop process jpg large solidborder
rem  restore the previous inifile
call :restoreini
@call :funcdebugger %~0 end
goto :eof

:style3
@call :funcdebugger %~0
rem remove existing files if present
if exist "%cd%\background\*.jpg" del "%cd%\background\*.jpg"
if exist "%cd%\foreground1\*.jpg" del "%cd%\foreground1\*.jpg"
if exist "%cd%\foreground2\*.jpg" del "%cd%\foreground2\*.jpg"

rem ----- make thumb with 2 px border ----- 
call :backupini
call :fileloop process jpg thumb solidborder

rem make forground picture step 1
call :fileloop process jpg large style3step1

rem make foreground croped 25
call :fileloop process jpg large style3step2

rem make darkened image
call :fileloop process jpg large style3step3
call :restoreini
@call :funcdebugger %~0 end
goto :eof

:style0
@call :funcdebugger %~0
:: Description: Setup for Fast Stone's partly manual processing
if exist %fsr% (
  call :start %fsr%
) else (
  echo Free Stone Installer was not found.
)

rem ----- make thumb with 2 px border ----- 
call :backupini
call :fileloop process jpg thumb solidborder
call :restoreini
rem do some Fast Stone Resizer stuff
if exist %fsr% (
  echo setting %fspr% options.
  echo You must click on Advance options and set the appropriate style.ccf
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
  :: now specify the output folder
  call "%setcontrol%" "%fspr%" "[CLASS:TEdit; INSTANCE:2]" "%cd%\readytoupload"
)
@call :funcdebugger %~0 end
goto :eof

:advancedoff
@call :funcdebugger %~0
:: Description: Turn off advanced options in inifile
call setini "%inifile%" Batch AdvCrop 0
call setini "%inifile%" Batch AdvResize 0
call setini "%inifile%" Batch AdvCanvas 0
call setini "%inifile%" Batch AdvBrightness 0
call setini "%inifile%" Batch AdvWatermark 0
@call :funcdebugger %~0 end
goto :eof



:process
@call :funcdebugger %~0
:: Description: Process a file for options specified.
set /a numb+=1
set curnumb=0%numb%
set curnumb=%curnumb:~-2%
call :checkdir "%outpath%\%galleryname%"
if "%filetype%" == "jpg" set filename=\%galleryname%\gallery-%galleryname%_%curnumb%%thumb%.jpg
rem if "%filetype%" == "html" set thumbfilename=gallery-%galleryname%_%curnumb%_thumb.jpg
rem if "%filetype%" == "html" set largefilename=gallery-%galleryname%_%curnumb%.jpg
rem if "%filetype%" == "swm" set filename=gallery-%galleryname%_%curnumb%%thumb%.jpg
rem Convert file to new size
if "%filetype%" == "jpg"  (
  if exist "%imconvert%" (
    call "%imconvert%" "%subdir%%curfile%" -resize "%shortside%x%shortside%^>" "%outpath%\%filename%"
  ) else (
    if exist %irfanview% call %irfanview% "%subdir%%curfile%" %options% /convert="%outpath%\%filename%"
  )
)
if "%filestyle%" == "style3step2" copy /y "%outpath%\%filename%" "C:\TEMP\forground.jpg"
if "%filetype%" == "html" echo %endmarkup%^<a  >> html.txt
if "%filetype%" == "html" echo href="/sites/default/files/media/%site%/%largefilename%"^>^<img alt="photo %numb%" >> html.txt
if "%filetype%" == "html" echo src="/sites/default/files/media/%site%/%thumbfilename%" style="width: 215px; height: 162px !important;" >> html.txt
if "%filetype%" == "jpg" (
  if exist "%outpath%\%filename%" (
    echo made %filename% 
  ) else (
    echo output file %filename% missing 
  )
)
@call :funcdebugger %~0 end
goto :eof


:start
@call :funcdebugger %~0
:: Description: Start external program
:: Required Parameters:
:: var1
:: Optional Parameters:
:: var2
:: var3
:: var4
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
@call :funcdebugger %~0 end
goto :eof

:getline
@call :funcdebugger %~0
:: Description: Get a specific line from a file
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
@call :funcdebugger %~0 end
goto :eof

:colorini
call :namedcolors
if not defined bordercolor set color=16777215
call setini "%curini%" Effects CanvColor %color%
goto :eof


:borderini
@call :funcdebugger %~0
:: Description: Sets border width and color by writing to ini file.
:: Required parameters:
:: width
:: color
set width=%~1
set color=%~2
set sidelength=%~3
call :namedcolors
if not defined bordercolor set color=0
if "%sidelength%" == "thumb" set longside=215
call setini "%curini%" Batch  AdvCrop 0
call setini "%curini%" Batch  AdvResize 1
call setini "%curini%" Batch  AdvResizeOpt 1
call setini "%curini%" Batch  AdvResizeL %longside%
call setini "%curini%" Batch  AdvCanvas 1
call setini "%curini%" Effects CanvL %width%
call setini "%curini%" Effects CanvR %width%
call setini "%curini%" Effects CanvT %width%
call setini "%curini%" Effects CanvB %width%
call setini "%curini%" Effects CanvInside 1
call setini "%curini%" Effects CanvColor %color%
call setini "%curini%" Effects CanvMethod 0
call setini "%curini%" JPEG "Save Quality" %largeimagequality%
if defined thumb call setini "%curini%" JPEG "Save Quality" thumbimagequality%
if defined thumb call setini "%curini%" Batch AdvSharpen 1
if defined thumb call setini "%curini%" Batch AdvSharpenVal %thumbsharpenvalue%
@call :funcdebugger %~0 end
goto :eof

:lookup
@call :funcdebugger %~0
:: Description: Lookup a value in a file before the = and get value after the =
:: Required parameters:
:: findval
:: datafile
SET findval=%~1
set datafile=%~2
set lookupreturn=
FOR /F "tokens=1,2 delims==" %%i IN (%datafile%) DO @IF %%i EQU %findval% SET lookupreturn=%%j
rem @echo %lookupreturn%
@call :funcdebugger %~0 end
goto :eof

:getfiledatetime
@call :funcdebugger %~0
:: Description: Returns a variable with a files modification date and time in yyMMddhhmm  similar to setdatetime. Note 4 digit year makes comparison number too big for batch to handle.
:: Revised: 2016-05-04
:: Classs: command - internal - date -time
:: Required parameters:
:: varname
:: file
:: Depends on:
:: ampmhour
if defined debugdefinefunc echo %beginfuncstring% %0 %debugstack% %beginfuncstringtail%
set varname=%~1
if not defined varname echo missing varname parameter & goto :eof
set file=%~2
if not exist "%file%" set %varname%=0 &goto :eof
set filedate=%~t2
rem got and mofified this from: http://www.robvanderwoude.com/datetiment.php#IDate
FOR /F "tokens=1-6 delims=:%dateseparator% " %%A IN ("%~t2") DO (
  IF "%dateformat%"=="0" (
      SET fdd=%%B
      SET fmm=%%A
      SET fyyyy=%%C
  )
  IF "%dateformat%"=="1" (
      SET fdd=%%A
      SET fmm=%%B
      SET fyyyy=%%C
  )
  IF "%dateformat%"=="2" (
      SET fdd=%%C
      SET fmm=%%B
      SET fyyyy=%%A
  )
  set fnn=%%E
  call :ampmhour %%F %%D
)
set %varname%=%fyyyy:~2%%fMM%%fdd%%fhh%%fnn%
if defined debugdefinefunc echo %endfuncstring% %0 %debugstack%
@call :funcdebugger %~0 end
goto :eof

:detectdateformat
@call :funcdebugger %~0
:: Description: Get the date format from the Registery: 0=US 1=AU 2=iso
set KEY_DATE="HKCU\Control Panel\International"
FOR /F "usebackq skip=2 tokens=3" %%A IN (`REG QUERY %KEY_DATE% /v iDate`) DO set dateformat=%%A
rem get the date separator: / or -
FOR /F "usebackq skip=2 tokens=3" %%A IN (`REG QUERY %KEY_DATE% /v sDate`) DO set dateseparator=%%A
rem get the time separator: : or ?
FOR /F "usebackq skip=2 tokens=3" %%A IN (`REG QUERY %KEY_DATE% /v sTime`) DO set timeseparator=%%A
rem set project log file name by date
@call :funcdebugger %~0 end
goto :eof

:iniread
@call :funcdebugger %~0
:: Description: Handles variables list supplied in an ini file. A simple ini file with different keys. Sections are not used.
:: Required parameters:
:: list - a filename with name=value on each line of the file
set list=%~1
FOR /F "eol=[ delims== tokens=1,2" %%s IN (%list%) DO (
    set %%s=%%t
  )
@call :funcdebugger %~0 end
goto :eof

:setup
@call :funcdebugger %~0
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
set previnifile=%kigprogramdata%\i_view32.ini.prev
set kiginifile=%kigprogramdata%\i_view32.ini
set kigsitelookup=%kigprogramdata%\site-lookup.txt
set outpath=%cd%\gallery
set fspr=FastStone Photo Resizer
set userpref=%kigprogramdata%\user-pref.ini
set endmarkup=/^^^>^^^</a^^^>^^^&nbsp;
rem create outpath if needed
if not exist "%cd%\readytoupload" md readytoupload
rem set the program path
if exist "C:\Program Files (x86)" (
  set irfanview="C:\Program Files (x86)\IrfanView\i_view32.exe"
  set fsr="C:\Program Files (x86)\FastStone Photo Resizer\FSResizer.exe"
  set imconvert=C:\Program Files\ImageMagick-6.9.1-Q16\convert.exe
) else (
  set irfanview="C:\Program Files\IrfanView\i_view32.exe"
  set fsr="C:\Program Files\FastStone Photo Resizer\FSResizer.exe"
  set imconvert=C:\Program Files\ImageMagick-6.9.1-Q16\convert.exe
)
call :detectdateformat
@call :funcdebugger %~0 end
goto :eof

:uifallback
@call :funcdebugger %~0
rem make sure variables are set
if not defined site echo usage with parameters: kig iso_site_code gallery_id style_number [site_number] &echo.
if not defined site echo You must specify a Project code.&set /P site=Enter Project code: 
if not defined galleryname echo How do you want to distinguish this gallery from other galleries?&set /P galleryname=Gallery name or code: 
if not defined style echo What style do you want for the pictures?&set /P style=Choose theme number 1 or 2 or 3 or 0 for use with FastStone. Blank = 1: 
rem if not defined projnumb echo What is the project number?&set /P projnumb=Enter number or leave blank for site code: 
if not defined style set style=1
if not defined galleryname set galleryname=1
if not exist %irfanview% echo %irfanview% was not found.&echo Only the HTML will be created.&echo You will have to create the files manually!
if not exist %fsr% echo %fsr% was not found.&echo Only the HTML will be created.&echo You will have to create the files manually!
@call :funcdebugger %~0 end
goto :eof

:htmlpre
@call :funcdebugger %~0
rem HTML
if exist "%cd%\readytoupload\*.jpg" del "%cd%\readytoupload\*.jpg"
echo ^<script type="text/javascript" src="/sites/default/files/gallery/imageGallery.js"^>^</script^> > html.txt
echo ^<p^>About these photos^</p^> >> html.txt
echo ^<div class="image-gallery"^> >> html.txt
@call :funcdebugger %~0 end
goto :eof

:htmlpost
@call :funcdebugger %~0
echo %endmarkup% >> html.txt
echo ^</div^> >> html.txt
@call :funcdebugger %~0 end
goto :eof

:html
@call :funcdebugger %~0
set making=HTML
@call :funcdebugger %~0 end
goto :eof

:thumbnoborder
@call :funcdebugger %~0  1
set making=thumb size with no borders
set options=/resize_long=215 /resample /aspectratio /jpgq=%thumbimagequality% /sharpen=%thumbsharpenvalue%
rem set imoptions=-resize '215x215^^>'
set thumb=_thumb
set longside=214
set shortside=162
@call :funcdebugger %~0 end
goto :eof

:largenoborder
@call :funcdebugger %~0
set making=large size with no borders
set options=/resize_long=1024 /resample /aspectratio /jpgq=%largeimagequality%
set imoptions=-resize '1024x1024^^>'
set thumb=
set longside=1024
set shortside=768
@call :funcdebugger %~0 end
goto :eof

:thumbsolidborder
@call :funcdebugger %~0
set curini=C:\ProgramData\kig\thumb-solidborder.ini
set making=thumb size with borders
set options=/jpgq=%thumbnailquality% /advancedbatch 
set thumb=_thumb
if exist %irfanview% call %irfanview% /killmesoftly
@call :funcdebugger %~0 end
goto :eof

:largesolidborder
@call :funcdebugger %~0
set curini=C:\ProgramData\kig\large-solidborder.ini
set making=large size with borders
set options=/jpgq=%largeimagequality%  /advancedbatch 
set thumb=
if exist %irfanview% call %irfanview% /killmesoftly
@call :funcdebugger %~0 end
goto :eof

:largestyle3step1
@call :funcdebugger %~0
set making=large image hi quality
set options=/resize_long=1024 /resample /aspectratio /jpgq=100
set thumb=
@call :funcdebugger %~0 end
goto :eof

:largestyle3step2
@call :funcdebugger %~0
set making=cropped large image hi quality
set options=/jpgq=100 /crop=(25,25,974,768,4) 
set thumb=
@call :funcdebugger %~0 end
goto :eof

:largestyle3step3
@call :funcdebugger %~0
set making=cropped large image hi quality
set options=/resize_long=1024 /resample /aspectratio /jpgq=100 /bright=-100
set thumb=
@call :funcdebugger %~0 end
goto :eof

:largestyle3step4
@call :funcdebugger %~0
set curini=C:\ProgramData\kig\large-style3step4.ini
set making=combine two files into one
set options=/jpgq=%largeimagequality%  /advancedbatch 
set thumb=
@call :funcdebugger %~0 end
goto :eof


:ampmhour
@call :funcdebugger %~0
:: Description: Converts AM/PM time to 24hour format. Also splits
:: Created: 2016-05-04 
:: Used by: getfiledatetime 
:: Required parameters:
:: ampm
:: thh
if defined debugdefinefunc echo %beginfuncstring% %0 %debugstack% %beginfuncstringtail%
set ampm=%~1
set thh=%~2
if "%ampm%" == "AM" (
  if "%thh%" == "12" (
    set fhh=00
  ) else (
    set fhh=%thh%
  )
) else if "%ampm%" == "PM" (
  if "%thh%" == "12" (
    set fhh=12
  ) else (
    rem added handling to prevent octal number error caused by leading zero
    if "%thh:~0,1%" == "0" set /A fhh=%thh:~-1%+12
    if "%thh:~0,1%" neq "0" set /A fhh=%thh%+12
  )
) else  (
  set fhh=%thh%
)
if defined debugdefinefunc echo %endfuncstring% %0 %debugstack%
@call :funcdebugger %~0 end
goto :eof

:namedcolors
@call :funcdebugger %~0
if "%bordercolor%" == "black" set color=0
if "%bordercolor%" == "red" set color=255
if "%bordercolor%" == "green" set color=32768
if "%bordercolor%" == "brown" set color=2763429
if "%bordercolor%" == "blue" set color=16711680
if "%bordercolor%" == "grey" set color=12632256
if "%bordercolor%" == "silver" set color=12632256
if "%bordercolor%" == "white" set color=16777215
@call :funcdebugger %~0 end
goto :eof

:writeserver
@call :funcdebugger %~0
set server=%~1
echo %server% > %kigprogramdata%\server.txt
set projnumb=
@call :funcdebugger %~0 end
goto :eof

:funcdebugger0
@set func=%~1
@set debugval=%~2
@if "%debugval%" == "1" set debugstack=%debugstack%%debugval%
@if "%debugval%" == "1" set return=on
@if "%debugval%" == "1"  echo ============ Starting debug %func% ====================================================
@if "%debugval%" == "end" (
  if "%debugstack:~-1%" == "1" echo ------------ End debug %func% --------------------------------------------------- 
)
@if "%debugval%" == "end" if "%debugstack:~-1%" == "1" set return=off
@if "%debugval%" == "end" set debugstack=%debugstack:~0,-1%
@if "%debugval%" == "end" if "%debugstack:~-1%" == "1" set return=on
@if not defined debugval set debugstack=%debugstack%0
@if not defined debugval set return=off
@echo %return%
@goto :eof

:funcdebugger1
goto :eof

:funcdebugger2
@if defined funcborder echo [============= starting %~0 ==========
set func=%~1
set debugval=%~2
set curstack=%debugstack%
set nextstack=%debugstack:~0,-2%
set curstate=%debugstack:~-1%
set nextstate=%nextstack:~-1%
if defined funcborder (
  if  "%debuugval%" == "end"   (
    echo ---------- %func% end ----------]
  ) else (
    echo [============= starting %func% ==========
  )
)
if defined debugval (
  echo off
  rem debugval defined now test if end
  if "%debuugval%" == "end"   (
    rem this is end of function
    echo ---------- %func% end ----------]
    if "%curstate%" == "1" (
      echo on
      if "%nextstate%" == "0" (
        echo off
      ) 
    )
  ) else (
    set debugstack=%debugstack%1
    echo [============= starting %func% ==========
    echo on
  )
) else (
  rem debugval not defined don't turn on debugging
  set debugstack=%debugstack%0
) 
if "%debuugval%" == "end"  set debugstack=%nextstack%
goto :eof

:funcdebugger
@set func=%~1
@set debugval=%~2
if "%debugfuncboundary%" == "on" (
@if "%debugval%" == "end"  (
  echo ------------ End debug %func% --------------------------------------------------- 
) else (
  echo ============ Starting debug %func% ====================================================
)
) else (           
@if "%debugval%" == "1" set %func%debug=on
@if "%debugval%" == "1" echo on
@if "%debugval%" == "1"  echo ============ Starting debug %func% ====================================================
@if "%func%debug" == "on" echo off
@if "%func%debug" == "on" echo ------------ End debug %func% --------------------------------------------------- 


)
 @goto :eof
 
:comparedate
@call :funcdebugger %~0
set file1=%~1
set file2=%~2
set action=%~3
set param1=%~4
set param2=%~5
set param3=%~6
call :getfiledatetime testone "%file1%"
call :getfiledatetime testtwo "%file2%"
if "%testone%" GTR "%testtwo%" call :%action% %param1% %param2% %param3%
@call :funcdebugger %~0 end
goto :eof

:prepini
if defined usercolor set bordercolor=%usercolor%
if defined usercolor call :colorini %bordercolor%
set curini=C:\ProgramData\kig\%filesize%-%filestyle%.ini
copy /y "%curini%" "%inifile%"
goto :eof

:backupini
copy /y "%inifile%" "%previnifile%"
goto :eof

:restoreini
copy /y "%previnifile%" "%inifile%"
goto :eof

:checkdir
:: Description: checks if dir exists if not it is created
:: See also: ifnotexist
:: Required preset variabes:
:: projectlog
:: Optional preset variables:
:: echodirnotfound
:: Required parameters:
:: dir
:: Depends on:
:: funcdebugstart
:: funcdebugend
@call :funcdebugger %~0
set dir=%~1
if not defined dir echo missing required directory parameter & goto :eof
if not exist "%dir%" (
    mkdir "%dir%"
)
@call :funcdebugger %~0 end
goto :eof

