@echo off
if "%2" == "debug" echo on
set debugstack=00
rem usage: kig iso_site_code gallery_id style_number [border_color]
rem must be started from folder with photos for inclusion in image gallery
rem can also be started with just kig. Then answer prompts.
rem ver 5 with 3 original styles supported with some Fast Stone intergration
rem ver 6 replaced 4th param optional border color. Some named colors supported
goto :main

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
if defined usercolor set bordercolor=%usercolor%
call :setup
call :iniread "%userpref%"
call :uifallback
call :html
call :style%style% %bordercolor%
echo Finished!
start notepad %htmlout%
@call :funcdebugger main end
goto :eof

:fileloop
@call :funcdebugger %~0 
:: Description: loop through files in current directory
echo var%~0 %~1 %~2 %~3 %~4
set process=%~1
set filesize=%~2
set bordertype=%~3
set imcolor=%~4
rem get the style and size params
if "%process%" == "jpg" set making=%filesize% JPG files with %bordertype% %imcolor% border
if "%process%" == "htmlwrite" set making=HTML fragment
echo ========== Making %making% ==========
set numb=
FOR /F " delims=" %%s IN ('dir /b %subdir%*.jpg') DO call :%process% %%s
@call :funcdebugger %~0 end
goto :eof

:style1
@call :funcdebugger %~0
:: Description: Creates the firts style of images
echo var%~0 %~1 %~2 %~3 %~4
call :fileloop jpg thumb no
call :fileloop jpg large no
@call :funcdebugger %~0 end
goto :eof

:style2
@call :funcdebugger %~0
:: Description: make picture with border, default white
rem  ----- make thumb with 2 px border ----- 
echo var%~0 %~1 %~2 %~3 %~4
set bordercolor=%~1
if defined usercolor set imcolor=%usercolor%
if not exist "%imconvert%" call :backupini
call :fileloop jpg thumb solid %bordercolor%
rem ----- make full with 10 px border ----- 
call :fileloop jpg large solid %imcolor%
rem  restore the previous inifile
if not exist "%imconvert%" call :bordercolor
@call :funcdebugger %~0 end
goto :eof

:style3
@call :funcdebugger %~0
echo var%~0 %~1 %~2 %~3 %~4 
call :fileloop jpg thumb embossed
rem ----- make full with 10 px border ----- 
call :fileloop jpg large embossed
rem remove existing files if present
rem if exist "%cd%\background\*.jpg" del "%cd%\background\*.jpg"
rem if exist "%cd%\foreground1\*.jpg" del "%cd%\foreground1\*.jpg"
rem if exist "%cd%\foreground2\*.jpg" del "%cd%\foreground2\*.jpg"

rem ----- make thumb with 2 px border ----- 
rem call :backupini
rem call :fileloop jpg thumb border solid

rem make forground picture step 1
rem call :fileloop jpg thumb border solid

rem make foreground croped 25
rem call :fileloop process jpg large style3step2

rem make darkened image
rem call :fileloop process jpg large style3step3
rem call :restoreini
@call :funcdebugger %~0 end
goto :eof

:style4
@call :funcdebugger %~0
echo var%~0 %~1 %~2 %~3 %~4
set bordercolor=%~1
:: Description: make picture with border, default white
rem  ----- make thumb with 2 px border ----- 
call :backupini
call :fileloop jpg thumb 3d  %bordercolor%
rem ----- make full with 10 px border ----- 
call :fileloop jpg large 3d  %bordercolor%
rem  restore the previous inifile
call :restoreini
@call :funcdebugger %~0 end
goto :eof



:style0
@call :funcdebugger %~0
:: Description: Setup for Fast Stone's partly manual processing
echo %~0 %~1 %~2 %~3 %~4
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


:jpg
echo var%~0 %~1 %~2 %~3 %~4
@call :funcdebugger %~0
set curfile=%~1
:: Description: Process a file for options specified.
set /a numb+=1
set curnumb=0%numb%
set curnumb=%curnumb:~-2%
call :picsize %filesize% %bordertype%
call :calcshortside "%curfile%" %longside% %border%
call :border %bordertype% %imcolor%
call :checkdir "%outpath%\%galleryname%"
@call :funcdebugger %~0
set filename=%galleryname%\gallery-%galleryname%_%curnumb%%thumb%.jpg
echo "%imconvert%" "%subdir%%curfile%" -resize "%newshortside%x%newshortside%^>" %imoptions%  "%outpath%\%filename%"
call "%imconvert%" "%subdir%%curfile%" -resize "%newshortside%x%newshortside%^>" %imoptions%  "%outpath%\%filename%"
if exist "%outpath%\%filename%" (
  echo made %filename% 
) else (
  echo output file %filename% missing 
)
echo.
@call :funcdebugger %~0 end
goto :eof

:picsize
echo var%~0 %~1 %~2 %~3 %~4
set filesize=%~1
set bordertype=%~2
if "%filesize%" == "thumb" (
  set thumb=_thumb
  set longside=%thumbside%
  if %bordertype% == no (
    set border=0
    set adjust=-1
  ) 
  if %bordertype% == solid  (
    set border=%thumbborder%
    set adjust=2
  )
  if %bordertype% == embossed (
    set border=%thembborder%
    set bevel1=%thembbevel1%
    set bevel2=%thembbevel2%
    set shave=%thembshave%
    set adjust=2
  )  
  if %bordertype% == 3d (
    set border=%th3dborder%
    set bevel2=%th3dbevel2%
    set adjust=2
  ) 
) 
if "%filesize%" == "large" (
  set thumb=
  set longside=%largeside%
  if %bordertype% == no (
    set border=0
    set adjust=-2
  ) 
  if %bordertype% == solid  (
    set border=%largeborder%
    set adjust=6
  )
  if %bordertype% == embossed (
    set border=%lgembborder%
    set bevel1=%lgembbevel1%
    set bevel2=%lgembbevel2%
    set shave=%lgembshave%
    set adjust=6
  ) 
  if %bordertype% == 3d (
    set border=%lg3dborder%   
    set bevel2=%lg3dbevel2%
    set adjust=6
  ) 
)
echo %~0 thumb=%thumb% longside=%longside% border=%border%
goto :eof

:border
@call :funcdebugger %~0
echo var%~0 %~1 %~2 %~3 %~4
set bordertype=%~1
set bordercolor=%~2
if "%topcorner%" == "TopLeft" set /A newshortside=(%lside%*%inshort%/%inlong%)-(%border%*2)+%adjust%
rem if "%topcorner%" == "TopLeft" set /A newshortside=(%lside%*%inshort%/%inlong%)
if "%topcorner%" == "TopLeft" set /A newlongside=%lside%-%border%*2
rem if "%orientation%" == "portrait" set /A shortside=%lside%*%width%/%height%
rem if "%topcorner%" == "RightTop" set /A newshortside=(%lside%*%inshort%/%inlong%)
if "%topcorner%" == "RightTop" set /A newshortside=(%lside%*%inshort%/%inlong%)-(%border%*2)+%adjust%
if "%topcorner%" == "RightTop" set /A newlongside=%lside%-%border%*2
echo %~0 long=%newlongside% short=%newshortside% orientation=%topcorner%
rem imagemagick params
if "%bordertype%" == "no" (set imoptions=)
if "%bordertype%" == "solid" (set imoptions=-mattecolor %bordercolor%  -frame %border%X%border%)
if "%bordertype%" == "embossed" set imoptions= ( +clone -shave %shave%x%shave% -alpha set -mattecolor #AAA6 -frame %border%x%border%+%bevel1%+%bevel2% ) -gravity center -composite
if "%bordertype%" == "3d" (set imoptions=-mattecolor %bordercolor%  -frame %border%X%border%+0+%bevel2%)
set imoptions
@call :funcdebugger %~0 end
goto :eof


:calcshortside
:: Description: Get the short side of picture
:: Required parameters:
:: pic
:: lside
:: border
echo var%~0 %~1 %~2 %~3 %~4
set pic=%~1
set lside=%~2
set border=%~3
if not defined border set border=0 
"%imidentify%" -format %%wx%%hx%%[orientation] "%pic%" >picspecs.txt
rem "%imidentify%" -format %%h "%pic%" >height.txt
rem "%imidentify%" -format %%[orientation] "%pic%" >orientation.txt
for /F "delims=x tokens=1-3" %%w in (picspecs.txt) do set inlong=%%w& set inshort=%%x& set topcorner=%%y
rem for /F %%w in (height.txt) do set inheight=%%w
rem for /F %%w in (orientation.txt) do set inheight=%%w
echo %~0 original file width %inwidth% height %inheight%  topcorner=%topcorner%
rem if defined width (if %width% geq %height% set orientation=landscape) else (set orientation=portrait)
rem if defined width (if "%width%" lss "%height%" set orientation=portrait) else (echo no width set)
rem if "%orientation%" == "landscape" set /A shortside=%lside%*%height%/%width%
set topcorner
set newlongside newshortside
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
if not defined usercolor (set color=%color%) else (set color=%usercolor%)
set imcolor=%color%
call :namedcolors
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
) else (
  set irfanview="C:\Program Files\IrfanView\i_view32.exe"
  set fsr="C:\Program Files\FastStone Photo Resizer\FSResizer.exe"

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

:htmlwrite
:: Description: Process a file for options specified.
@call :funcdebugger %~0
echo var%~0 %~1 %~2 %~3 %~4
set /a numb+=1
set curnumb=0%numb%
set curnumb=%curnumb:~-2%
call :checkdir "%outpath%\%galleryname%"
set largefilename=%galleryname%/gallery-%galleryname%_%curnumb%.jpg
set thumbfilename=%galleryname%/gallery-%galleryname%_%curnumb%_thumb.jpg
echo ^<a href="/sites/default/files/media/%site%/%largefilename%"^>^<img alt="photo %numb%" >> %htmlout%
echo src="/sites/default/files/media/%site%/%thumbfilename%" style="width: 215px; height: 162px !important;"/^> >> %htmlout%
echo ^&nbsp;^</a^> >> %htmlout%
@call :funcdebugger %~0 end
goto :eof


:html
@call :funcdebugger %~0
echo var%~0 %~1 %~2 %~3 %~4
set making=HTML fragment
set htmlout=gallery\%galleryname%\html.txt
echo ^<script type="text/javascript" src="/sites/default/files/gallery/imageGallery.js"^>^</script^> > %htmlout%
echo ^<p^>About these photos^</p^> >> %htmlout%
echo ^<div class="image-gallery"^> >> %htmlout%
@call :funcdebugger %~0 end
call :fileloop htmlwrite
@call :funcdebugger %~0
echo ^</div^> >> %htmlout%
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
@if "%debugfuncboundary%" == "on" (
  @if "%debugval%" == "end"  (
    echo ------------ End debug %func% --------------------------------------------------- 
  ) else (
    echo ============ Starting debug %func% ====================================================
  )
) else (           
  @if "%debugval%" == "end"  (
    @if defined debugfunc echo off
    @if defined debugfunc echo ------------ End debug %func% --------------------------------------------------- 
    @set debugfunc=
  ) else (
    @if "%debugval%" == "1" set debugfunc=on
    @if "%debugval%" == "1" echo on
    @if "%debugval%" == "1"  echo ============ Starting debug %func% ====================================================
  )
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

