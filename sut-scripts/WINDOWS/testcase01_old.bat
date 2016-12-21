rem testcase01.bat
rem This script will:
rem
rem Perform the first test case
set logfile=c:\device\device.log

echo ---------- Begining testcase 01 ---------- >> %logfile%

goto :MAIN

:determineOS
REM Determine the TEST OS family
ver | findstr /i "6\." > nul
IF %ERRORLEVEL% EQU 0 (
	set TESTOS=Win7
	goto :EOF
)
ver | findstr /i "10\." > nul
IF %ERRORLEVEL% EQU 0 (
	set TESTOS=Win7
	goto :EOF
)
set TESTOS=xp
goto :EOF

:win7
rem start calc application Windows 7
echo Family is Win7 >> %logfile%
start c:\device\WINDOWS\psexec.exe -s -i 1 "calc.exe" /accepteula
ping 1.1.1.1 -n 1 -w 3000 > NUL
start /wait /min c:\device\WINDOWS\psexec.exe -s -i 1 "c:\device\WINDOWS\screenshot\sshot.bat" tc1-1 /accepteula
goto :EOF

:xp
rem start calc application Windows XP
echo Family is XP >> %logfile%
start calc.exe
ping 1.1.1.1 -n 1 -w 3000 > NUL
start /wait /min c:\device\WINDOWS\screenshot\sshot.bat tc1-1
goto :EOF

:determine_Result
set processList=c:\device\processes.log
tasklist >> %processList%
rem determine if the number was even or odd
echo Determining whether the number is even or odd.
findstr /i /C:"calc.exe" %processList%

if %errorlevel%==0 (
	echo The test Passed >> %logfile%
	echo [TEST_PASSED] >> %logfile%
	goto :EOF
)
 
echo The test Failed >> %logfile%
echo [TEST_FAILED] >> %logfile%
goto :EOF

:MAIN
call :determineOS
call :%TESTOS%
call :determine_Result
call :exit

:exit
echo ---------- End testcase 01 ---------- >> %logfile%
exit 0