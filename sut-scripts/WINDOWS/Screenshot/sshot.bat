@echo off
REM Used to take a screen capture of the system under test.
Set exeDir=%~dp0
Set imgNumber=%1
Set testDir=c:\device\
Set logFile=c:\device\device.log

echo ------------------- Starting to take screen catpure ------------------- >> %logfile%

goto :MAIN

:setImgName
if %1blank == blank ( set imgNumber=device )
goto :EOF

:screenShotFunction
echo Starting to take screencapture of machine >> %logfile%
start /wait %exeDir%screenshot.exe -d %testDir% -o %imgNumber%
goto :EOF

:MAIN
call :setImgName
call :screenShotFunction
call :exit

:exit
echo ------------------- Finished taking screen-capture ------------------- >> %logfile% 
exit 0