REM This Script will Map the Shared drive
REM set some variables
@echo off
set exedir=%~dp0
cd %exedir%
set logfile=c:\device\device.log
set stage=%1
set count=0

echo ---------- Connecting to Shared Drive for stage "%stage%" ---------- >> %logfile% 

goto :MAIN

:getStage
if "%stage%" == "provision" (
	set mystage=provision
	goto :EOF
)
if "%stage%" == "results" (
	set mystage=Results
	goto :EOF
)
echo No stage was passed in >> %logfile%
goto error

:Provision
type c:\device\properties.txt

for /f "tokens=2* delims= " %%a in ('findstr /C:"WIN_SHARE :: " "C:\device\properties.txt"') do (set Win_Share=%%b)
for /f "tokens=2* delims= " %%a in ('findstr /C:"WIN_SHARE_USER :: " "C:\device\properties.txt"') do (set Win_Share_Username=%%b)
for /f "tokens=2* delims= " %%a in ('findstr /C:"WIN_SHARE_PASS :: " "C:\device\properties.txt"') do (set Win_Share_Password=%%b)

echo The Shared Drive is : %Win_Share% >> %logfile%
echo The Share Username is : %Win_Share_Username% >> %logfile%
echo The Share Password is : %Win_Share_Password% >> %logfile%

net use x: %Win_Share% /user:%Win_Share_Username% %Win_Share_Password%
goto :EOF

:Results
type c:\device\properties.txt

for /f "tokens=2* delims= " %%a in ('findstr /C:"WIN_RESULTS_SHARE :: " "C:\device\properties.txt"') do (set WIN_RESULTS_SHARE=%%b)
for /f "tokens=2* delims= " %%a in ('findstr /C:"WIN_SHARE_USER :: " "C:\device\properties.txt"') do (set Win_Share_Username=%%b)
for /f "tokens=2* delims= " %%a in ('findstr /C:"WIN_SHARE_PASS :: " "C:\device\properties.txt"') do (set Win_Share_Password=%%b)

echo The Shared Drive is : %WIN_RESULTS_SHARE% >> %logfile%
echo The Share Username is : %Win_Share_Username% >> %logfile%
echo The Share Password is : %Win_Share_Password% >> %logfile%

net use x: %WIN_RESULTS_SHARE% /user:%Win_Share_Username% %Win_Share_Password%
goto :EOF

:checkDrive
set /a count+=1
echo The count is %count% >> %logfile%
if %count%==10 (
	echo The count is :%count%, Thats too many, getting out of here! %logfile%
	goto :error
	)
IF NOT EXIST x:\ (
	echo the drive did not connect, Trying again >> %logfile%
	goto :MAIN
	)
echo The drive connected properly >> %logfile%
goto :EOF

:error
echo There was an error mounting the shared drive >> %logfile%
echo [PROVISIONING_FAILED] >> %logfile%
echo [TEST_FAILED] >> %logfile%
goto :exit

:MAIN
call :getStage
call :%mystage%
call :checkDrive
call :exit

:exit
echo -------- Finished Connecting to Shared Drive -------- >> %logfile%
exit 0