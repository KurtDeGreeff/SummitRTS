REM This Script will disconnect the shared drive
REM set some variables
@echo on
set exedir=%~dp0
cd %exedir%
set logfile=c:\device\device.log

goto :MAIN

:disconnectShare
echo --------------------------------------------- >> %logfile% 2>>&1
echo Disconnecting Device Shared Drives >> %logfile% 2>>&1
REM Map Drive with user Credentials
net use * /Delete /y
goto :EOF

:MAIN
call :disconnectShare
call :exit

:exit
echo Finished Disconnecting Shared Drive >> %logfile% 2>>&1
echo --------------------------------------------- >> %logfile% 2>>&1
exit 0