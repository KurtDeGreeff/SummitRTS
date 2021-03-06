REM This script will accept an argument and install the Correct version of Chrome.
REM the Argument is the Version
set exedir=%~dp0
cd %exedir%
set logfile=c:\LocalDropbox\result.log
set version=%1

echo =============== Chrome Installtion Script =============== >> %logfile% 2>>&1

goto :MAIN

:installbrowser
if exist "%exedir%%version%\installchrome.exe" (
	%exedir%%version%\installchrome.exe /silent /install
	REM not sure if that is correct
	REM Kill Chrome
	"c:\LocalDropbox\pskill.exe" /accepteula chrome.exe
	goto :EOF
)
echo The file does not exist (%exedir%%version%\installchrome.exe) >> %logfile%
echo [PROVISIONING_FAILED] >> %logfile%
echo [TEST_FAILED] >> %logfile%
goto :exit

:copyBrowseScript
echo Copying mybrowser.bat to LocalDropbox folder >> %logfile% 2>>&1
REM copy "myBrowser.bat" to c:\LocalDropbox
xcopy /y mybrowser.bat c:\LocalDropbox
goto :EOF

:MAIN
call :installbrowser
call :copyBrowseScript
call :exit

:exit
echo =============== Finish Chrome Installtion Script =============== >> %logfile% 2>>&1
exit 0