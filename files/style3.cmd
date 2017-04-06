 set infile=%1
set outfile=%2
set resize=%~3
set bordercolor=%~4
set border=%~5
set bevel1=%~6
set bevel2=%~7
"C:\Program Files\ImageMagick-6.9.1-Q16\convert.exe" "%infile%" -resize "%resize%" -mattecolor %bordercolor%  -frame %border%x%border%+%bevel1%+%bevel2% "%outfile%" 