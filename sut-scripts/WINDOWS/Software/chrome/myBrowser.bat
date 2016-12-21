REM This script Forces BrowseToUrl to use the .exe described below
set logfile=c:\device\device.log
REM Find path to exe
cd c:\

echo -------- Starting Browsing Script ------- >> %logfile%

goto :MAIN

:FindBrowserExe
dir /s /b C:"chrome.exe" >> c:\device\mybrowser.txt 2>>&1
REM Set Variable to .exe path
set /p mybrowserpath= <c:\device\mybrowser.txt
goto :EOF

:setURL
REM get the url from txt file in c:\device
set /p myurl= <c:\device\browse\url.txt
echo %mybrowserpath% >> %logfile% 2>>&1
echo %myurl% >> %logfile% 2>>&1
goto :EOF

:determineOS
REM Determine the TEST OS family
ver | findstr /i "6\." > nul
IF %ERRORLEVEL% EQU 0 (
	set TESTOS=Win7
	goto :EOF
)
set TESTOS=xp
goto :EOF

:xp
echo Starting Specific Browse File >> %logfile% 2>>&1
REM open the browser with the URL
start "" "%mybrowserpath%" --new-window %myurl%
timeout 60
start "" "%mybrowserpath%" --new-window %myurl%
timeout 60
goto :EOF

:ver_Win7
echo OS is Win 7 >> %logfile% 2>>&1
start c:\device\psexec.exe -s -i 1 "%mybrowserpath%" --new-window %myurl% /accepteula
timeout 60
start c:\device\psexec.exe -s -i 1 "%mybrowserpath%" --new-window %myurl% /accepteula
timeout 60
goto :EOF

:MAIN
call :FindBrowserExe
call :setURL
call :determineOS
call :%TESTOS%
call :exit

:exit
echo Finished Browsing Script >> %logfile% 2>>&1
echo --------------------------------------------- >> %logfile% 2>>&1
exit 0