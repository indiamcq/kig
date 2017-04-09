set gsite=%1
set ggal=%2
set gstyle=%3
set gcol=%4
set gpath=%5
echo kig.cmd %gsite% %ggal% %gstyle% "%gcol:"=%" "%gpath%"
call kig.cmd %gsite% %ggal% %gstyle% "%gcol:"=%" "%gpath%"
start explorer "%5\gallery\%2"

