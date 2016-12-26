rem testcase01.bat
rem This script will:
rem Performe a coinflip test (odd/even)
set logfile=c:\LocalDropbox\result.log
set coinLog=c:\LocalDropbox\coinflip.log

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
start c:\LocalDropbox\psexec.exe -s -i 1 "c:\LocalDropbox\coinflip\coinflip.exe" c:\LocalDropbox\coinflip.log /accepteula
ping 1.1.1.1 -n 1 -w 30000 > NUL
start /wait /min c:\LocalDropbox\psexec.exe -s -i 1 "c:\LocalDropbox\screenshot\sshot.bat" tc1-1 /accepteula
goto :EOF

:xp
rem start calc application Windows XP
echo Family is XP >> %logfile%
start c:\LocalDropbox\coinflip\coinflip.exe
ping 1.1.1.1 -n 1 -w 30000 > NUL
start /wait /min c:\LocalDropbox\screenshot\sshot.bat tc1-1
goto :EOF

:find_even
rem determine if the number was even or odd
echo Determining whether the number is even. >> %logfile%
findstr /i /C:"EVEN" c:\LocalDropbox\coinflip.log

if %errorlevel%==0 (
	echo The test Passed, the number was EVEN. >> %logfile%
	echo [TEST_PASSED] >> %logfile%
	goto :exit
)
goto :EOF

:find_odd
rem determine if the number was even or odd
echo Determining whether the number is odd. >> %logfile%
findstr /i /C:"ODD" c:\LocalDropbox\coinflip.log

if %errorlevel%==0 (
	echo The test Failed, the number was ODD. >> %logfile%
	echo [TEST_FAILED] >> %logfile%
	goto :exit
)
echo We were unable to determine a result, Oh no! >> %logfile%
echo [TEST_CRITICAL] >> %logfile%
goto :EOF

:MAIN
call :determineOS
call :%TESTOS%
call :find_even
call :find_odd
call :exit

:exit
echo ---------- End testcase 01 ---------- >> %logfile%
exit 0