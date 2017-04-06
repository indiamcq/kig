set infile=%1
set outfile=%2
set resize=%~3
"%imconvert%" "%curdir%\%curfile%" -resize "%resize%" "%outpath%\%filename%"