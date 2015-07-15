@echo off
set server=production
echo %server% > %kigprogramdata%\server.txt
echo server set to %server%