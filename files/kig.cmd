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
call :funcdebugger kig-main "off" %1 %2 %3 %4 
@echo.
@echo    Making HTML and resized photos and thumbnails for K Image gallery.
@echo                               v3
@echo         Available from: https://github.com/indiamcq/kig
@echo.
rem get parameters if passed
set site=%1
set galleryname=%2
set style=%3
set usercolor=%4
set checkcmdline=%~3
call :setup
call :iniread "%userpref%"
if not exist "%imconvert%" echo %imconvert% was not found.&echo Only the HTML will be created.&echo Please install ImageMagick and add path to user-pref.ini. &set fatal=true
call :uifallback
call :stylecheck
if defined fatal exit /b
call :html %site% %galleryname%
call :style %style% %site% %galleryname% %bordercolor%
echo Finished!
start notepad %htmlout%
@call :funcdebugger kig-main end "%varset%"
goto :eof

:style
@call :funcdebugger %~0 "off" %~1 %~2 %~3 %~4 %~5 %~6
set style=%~1
set site=%~2
set galleryname=%~3
set bordercolor=%~4
call :iniread "%kigprogramdata%\style%style%.ini"
if defined usercolor set bordercolor=%usercolor%
set imoptions=%thumboptions%
call :fileloop jpg "%site%" "%galleryname%" "%stylename%" "%thumbside%" "_thumb" 
set imoptions=%largeoptions%
call :fileloop jpg "%site%" "%galleryname%" "%stylename%" "%largeside%" 
set varset=style site galleryname bordercolor thumboptions largeoptions
@call :funcdebugger %~0 end "%varset%"
goto :eof

:fileloop
@call :funcdebugger %~0 "off" %~1 %~2 %~3 %~4 %~5 %~6 %~7 %~8 %~9
:: Description: loop through files in current directory
set process=%~1
set site=%~2
set galleryname=%~3
set stylename=%~4
set longside=%~5
set thumb=%~6
call :checkdir "%outpath%\%galleryname%"
rem get the style and size params
if "%process%" == "jpg" set making=%equal10% Making JPG%thumb% files with %stylename% %bordercolor% border %equal10%%equal10%%equal10%%equal10%%equal10%
if "%process%" == "htmlwrite" set making=%equal10% Making HTML fragment %equal10%%equal10%%equal10%%equal10%%equal10%
echo %making:~0,79%
set numb=
FOR /F " delims=" %%s IN ('dir /b %subdir%*.jpg') DO call :%process% "%%s" "%site%" "%galleryname%" "%stylename%" "%longside%"
set varset=process site galleryname stylename longside thumb making
@call :funcdebugger %~0 end "%varset%"
goto :eof

:jpg
@call :funcdebugger %~0 "off" %1 %2 %3 %4 %~5 %~6 %~7 %~8
set curfile=%~1
set site=%~2
set galleryname=%~3
set stylename=%~4
set longside=%~5
:: Description: Process a file for options specified.
set /a numb+=1
set curnumb=0%numb%
set curnumb=%curnumb:~-2%
call :calcshortside "%curfile%" "%longside%"
call :border "%longside%" "%orientation%"
@call :funcdebugger %~0 "off" "[restart echo after calls]"
set filename=%galleryname%\gallery-%galleryname%_%curnumb%%thumb%.jpg
if defined thumb (
  echo if defined fblevel4  echo "%imconvert%" "%curdir%\%curfile%" %thubmoptions% "%outpath%\%filename%" > "%kigpath%\makejpg.cmd"
  echo echo "%imconvert%" "%curdir%\%curfile%" %thumboptions% "%outpath%\%filename%"^>^> "%logfile%" .> "%kigpath%\makejpg.cmd"
  echo "%imconvert%" "%curdir%\%curfile%" %thumboptions% "%outpath%\%filename%" >> "%kigpath%\makejpg.cmd"

) else (
  echo if defined fblevel4  echo "%imconvert%" "%curdir%\%curfile%" %largeoptions% "%outpath%\%filename%"  > "%kigpath%\makejpg.cmd"
  echo echo "%imconvert%" "%curdir%\%curfile%" %largeoptions% "%outpath%\%filename%" ^>^> "%logfile%" >> "%kigpath%\makejpg.cmd"
  echo "%imconvert%" "%curdir%\%curfile%" %largeoptions% "%outpath%\%filename%" >> "%kigpath%\makejpg.cmd"
)
call "%kigpath%\makejpg.cmd"
if defined fblevel1 (
  if exist "%outpath%\%filename%" (
    echo made %filename% 
  ) else (
    echo output file %filename% missing 
  )
)
@if defined fblevel2 echo.
set varset=curfile site galleryname bordercolor name numb curnumb imoptions
@call :funcdebugger %~0 end "%varset%"
goto :eof

:border
@call :funcdebugger %~0 "off" %1 %2 %3 %4 %~5 %~6
set lside=%~1
if "%borderposition%" == "inside" (
  set border=0
) else (
  if defined thumb (
    set border=%thumbborder%
  ) else (
    set border=%largeborder%
  )
)
set /A newlongside=%lside%-(%border%*2)
set /A newlongplusborderside=%lside%+(%border%*2)
set /A newshortside=((%lside%*%inshort%)/%inlong%)-(%border%*2)
set /A newshortnoborderside=((%lside%*%inshort%)/%inlong%)
set /A newshortplusborderside=((%lside%*%inshort%)/%inlong%)+(%border%*2)
set resize=%newlongside%x%newshortside%
set fullsize=%lside%x%newshortnoborderside%
set resizeaddborder=%newlongplusborderside%x%newshortplusborderside%
set varset=lside newshortside newlongside resize fullsize
@call :funcdebugger %~0 end "%varset%"
goto :eof

:calcshortside
:: Description: Get the short side of picture
:: Required parameters:
:: pic
:: lside
:: border
@call :funcdebugger %~0 "off" %1 %2 %3 %4 %~5 %~6 %~7 %~8
set pic=%~1
if not defined border set border=0 
"%imidentify%" -format %%wx%%hx%%[orientation] "%pic%" >picspecs.txt
for /F "delims=x tokens=1-3" %%w in (picspecs.txt) do set inlong=%%w& set inshort=%%x& set orientation=%%y
set varset=pic inlong inshort orientation
@call :funcdebugger %~0 end "%varset%"
goto :eof

:start
@call :funcdebugger %~0 "off" %1 %2 %3 %4 %~5 %~6
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
set varset=var1 var2 var3 var4
@call :funcdebugger %~0 end "%varset%"
goto :eof

:getline
@call :funcdebugger %~0 "off" %1 %2 %3 %4 %~5 %~6
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
set varset=count getline
@call :funcdebugger %~0 end "%varset%"
goto :eof


:lookup
@call :funcdebugger %~0 "off" %1 %2 %3 %4 %~5 %~6
:: Description: Lookup a value in a file before the = and get value after the =
:: Required parameters:
:: findval
:: datafile
SET findval=%~1
set datafile=%~2
set lookupreturn=
FOR /F "tokens=1,2 delims==" %%i IN (%datafile%) DO @IF %%i EQU %findval% SET lookupreturn=%%j
rem @echo %lookupreturn%
set varset=findval datafile lookupreturn
@call :funcdebugger %~0 end "%varset%"
goto :eof



:iniread
@call :funcdebugger %~0 "off" %1 %2 %3 %4 %~5 %~6
:: Description: Handles variables list supplied in an ini file. A simple ini file with different keys. Sections are not used.
:: Required parameters:
:: list - a filename with name=value on each line of the file
set list=%~1
FOR /F "eol=[ delims== tokens=1,2" %%s IN (%list%) DO (
    set %%s=%%t
  )
@call :funcdebugger %~0 end "%varset%"
goto :eof

:setup
@call :funcdebugger %~0 "off" %1 %2 %3 %4 %~5 %~6
rem the following shoud not need editing
set fatal=
set bordercolor=
set kigpath=C:\Programs\kig
set kigprogramdata=D:\All-SIL-Publishing\github\kig\branches\kig3\files\ProgramData
rem set kigprogramdata=C:\ProgramData\kig
set curdir=%cd%
set outpath=%cd%\gallery
set userpref=%kigprogramdata%\user-pref.ini
rem set userpref=D:\All-SIL-Publishing\github\kig\branches\kig3\files\ProgramData\user-pref.ini
set equal10===========
rem create outpath if needed
call :checkdir "%outpath%"
call :detectdateformat
call :date
call :time
set logfile=%kigprogramdata%\kig_%curdate%.log
echo :: %curdate% %curhh_mm% kig %site% %galleryname% %style% %usercolor% >> "%logfile%"
set varset=kig outpath userpref
@call :funcdebugger %~0 end "%varset%"
goto :eof

:uifallback
@call :funcdebugger %~0 "off" %1 %2 %3 %4 %~5 %~6
rem make sure variables are set
if not defined checkcmdline (
  if defined usersite set site=%usersite%
  if defined userstyle set style=%userstyle%
  if defined usergalleryname set galleryname=%usergalleryname%
  if defined usertbordercolor set bordercolor=%usertbordercolor%
)
if not defined site echo usage with parameters: kig iso_site_code gallery_id style_number [border_color] &echo.
if not defined site echo You must specify a Project code.&set /P site=Enter Project code or leave blank for "%defaultsite%": 
if not defined galleryname echo How do you want to distinguish this gallery from other galleries?&set /P galleryname=Gallery name or code: 
if not defined style call :stylelist
if not defined style echo What style do you want for the pictures?&set /P style=Choose style from the list above. Blank = %defaultstyle%: 
if not defined checkcmdline if not defined defaultbordercolor echo Do you want to specify a border color?&set /P usercolor=Enter a color word or leave blank for default color "%defaultbordercolor%": 
if not defined site set site=%defaultsite%
if not defined style set style=%defaultstyle%
if not defined galleryname set galleryname=%defaultgalleryname%
set varset=site galleryname style usercolor
@call :funcdebugger %~0 end "%varset%"
goto :eof

:htmlwrite
:: Description: Process a file for options specified.
@call :funcdebugger %~0 "off" %1 %2 %3 %4 %~5 %~6
set curfile=%~1
set site=%~2
set galleryname=%~3
set /a numb+=1
set curnumb=0%numb%
set curnumb=%curnumb:~-2%
set largefilename=%galleryname%/gallery-%galleryname%_%curnumb%.jpg
set thumbfilename=%galleryname%/gallery-%galleryname%_%curnumb%_thumb.jpg
echo ^<a href="/sites/default/files/media/%site%/%largefilename%"^>^<img alt="photo %numb%" >> %htmlout%
echo src="/sites/default/files/media/%site%/%thumbfilename%" style="width: 215px; height: 162px !important;"/^> >> %htmlout%
echo ^&nbsp;^</a^> >> %htmlout%
set varset=curfile site galleryname numb curnumb largefilename thumbfilename
@call :funcdebugger %~0 end  "%varset%"
goto :eof


:html
@call :funcdebugger %~0 "off" %1 %2 %3 %4 %~5 %~6
set site=%~1
set galleryname=%~2
set making=HTML fragment
set htmlout=gallery\%galleryname%\html.txt
if exist "%htmlout%" del /Q gallery\%galleryname%\*.*
echo ^<script type="text/javascript" src="/sites/default/files/gallery/imageGallery.js"^>^</script^> > %htmlout%
echo ^<p^>About these photos^</p^> >> %htmlout%
echo ^<div class="image-gallery"^> >> %htmlout%
@call :funcdebugger %~0 off
call :fileloop htmlwrite %site% %galleryname%
@call :funcdebugger %~0 "off" %1 %2 %3 %4 %~5 %~6
echo ^</div^> >> %htmlout%
set varset=making htmlout
@call :funcdebugger %~0 end  "%varset%"
goto :eof





:funcdebugger1
if "%debugval%" == "end"  (
  set endfunc=start%func%
  if %endfunc% == "on" echo off
  if defined debugfunc echo ------------ End debug %func% --------------------------------------------------- 
  if defined fblevel3 if "%fname%" == "debug%func%" for /F %%s IN ("%~3") DO set %%s
  if "%debugfuncboundary%" == "on" echo ------------ End debug %func% --------------------------------------------------- 
) else if "%debugval%" == "on" (
  set startfunc=start%func%
  set %startfunc%=on
  echo on
  echo ============ Starting debug %func% ====================================================
)
if "%debugfuncboundary%" == "on" (
    echo ============ Starting debug %func% ====================================================
    @if defined fblevel2 echo param:%func% %~3 %~4 %~5 %~6 %~7 %~8 %~9  
) else (
  if defined fblevel2 echo param:%func% %~3 %~4 %~5 %~6 %~7 %~8 %~9
)
goto :eof

:funcdebugger
set func=%~1
set debugval=%~2
set list=%~3
if "%debugval%" == "end" if defined echoon echo off
rem echo param::debugger "off" %~1 %~2 %~3 %~4 %~5 %~6 %~7 %~8 %~9
if defined fblevel2 if "%debugval%" == "off" echo ====== param:%func% %~3 %~4 %~5 %~6 %~7 %~8 %~9
if defined fblevel3 if "%debugval%" == "end" echo ================== Exit report for %func% =======================
if defined fblevel3 if "%debugval%" == "end" for /F "tokens=1-10 delims= " %%a IN ("%list%") DO (
  if "%%a" neq "" set %%a
  if "%%b" neq "" set %%b
  if "%%c" neq "" set %%c
  if "%%d" neq "" set %%d
  if "%%e" neq "" set %%e
  if "%%f" neq "" set %%f
  if "%%g" neq "" set %%g
  if "%%h" neq "" set %%h
  if "%%i" neq "" set %%i
  if "%%j" neq "" set %%j
  echo.
)
if "%debugval%" == "on" echo on & set echoon=on
@goto :eof
 
:comparedate
@call :funcdebugger %~0 "off" %1 %2 %3 %4 %~5 %~6
set file1=%~1
set file2=%~2
set action=%~3
set param1=%~4
set param2=%~5
set param3=%~6
call :getfiledatetime testone "%file1%"
call :getfiledatetime testtwo "%file2%"
if "%testone%" GTR "%testtwo%" call :%action% %param1% %param2% %param3%
set varset=file1 file2 action param1 param2 param3
@call :funcdebugger %~0 end "%varset%"
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
@call :funcdebugger %~0 "off" %1 %2 %3 %4 %~5 %~6
set dir=%~1
if not defined dir echo missing required directory parameter & goto :eof
if not exist "%dir%" (
    mkdir "%dir%"
)
set varset=dir
@call :funcdebugger %~0 end "%varset%"
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

:time
:: Description: Retrieve time in several shorter formats than %time% provides
:: Created: 2016-05-05
FOR /F "tokens=1-4 delims=:%timeseparator%." %%A IN ("%time%") DO (
  set curhhmm=%%A%%B
  set curhhmmss=%%A%%B%%C
  set curhh_mm=%%A:%%B
  set curhh_mm_ss=%%A:%%B:%%C
)
goto :eof

:date
:: Description: Returns multiple variables with date in three formats, the year in wo formats, month and day date.
:: Revised: 2016-05-04
:: Classs: command - internal - date -time
:: Required preset variables:
:: dateformat
:: dateseparator
rem got this from: http://www.robvanderwoude.com/datetiment.php#IDate
if defined debugdefinefunc echo %beginfuncstring% %0 %debugstack% %beginfuncstringtail%
FOR /F "tokens=1-4 delims=%dateseparator% " %%A IN ("%date%") DO (
    IF "%dateformat%"=="0" (
        SET fdd=%%C
        SET fmm=%%B
        SET fyyyy=%%D
    )
    IF "%dateformat%"=="1" (
        SET fdd=%%B
        SET fmm=%%C
        SET fyyyy=%%D
    )
    IF "%dateformat%"=="2" (
        SET fdd=%%D
        SET fmm=%%C
        SET fyyyy=%%B
    )
)
set curdate=%fyyyy%-%fmm%-%fdd%
set curisodate=%fyyyy%-%fmm%-%fdd%
set curyyyymmdd=%fyyyy%%fmm%%fdd%
set curyymmdd=%fyyyy:~2%%fmm%%fdd%
set curUSdate=%fmm%/%fdd%/%fyyyy%
set curAUdate=%fdd%/%fmm%/%fyyyy%
set curyyyy=%fyyyy%
set curyy=%fyyyy:~2%
set curmm=%fmm%
set curdd=%fdd%
goto :eof

:stylecheck
if not exist "%kigprogramdata%\style%style%.ini" (
  echo Style %style% does not exist! 
  echo Choose another style. 
  call :stylelist
  set fatal=true
)
goto :eof

:stylelist
echo Available style numbers and description:
FOR /L %%n IN (1,1,50) DO call :stylewrite %%n
echo.
echo           Note: Enter only numbers.
goto :eof

:stylewrite
set numb=%~1
if exist "%kigprogramdata%\style%numb%.ini" call :iniread "%kigprogramdata%\style%numb%.ini"
if exist "%kigprogramdata%\style%numb%.ini" (  echo %numb% %stylename% border) else (  goto :eof)
goto :eof