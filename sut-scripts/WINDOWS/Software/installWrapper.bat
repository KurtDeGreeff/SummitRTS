@echo on
set exedir=%~dp0
cd %exedir%
set logfile=c:\device\device.log
set local_SW_count=1

echo ############# Starting Software Installation ############# %time% >> %logfile% 2>>&1

goto :MAIN

:Get_Windows_Software_Count
REM Check that the the properties file Exists
type c:\device\properties.txt
for /f "tokens=2* delims= " %%a in ('findstr /C:"WIN_SW_COUNT :: " "C:\device\properties.txt"') do (set Win_SW_Count=%%b)
echo Installing %Win_SW_Count% Software packages (from c:\device\properties.txt) >> %logfile%
goto :EOF

:get_SW_Details
type c:\device\properties.txt
for /f "tokens=2* delims= " %%a in ('findstr /C:"WIN_SW_NAME_%local_SW_count% :: " "C:\device\properties.txt"') do (set software=%%b)
for /f "tokens=2* delims= " %%a in ('findstr /C:"WIN_SW_VER_%local_SW_count% :: " "C:\device\properties.txt"') do (set version=%%b)
goto :EOF

:install_Software
if not %Win_SW_Count%== "0" (
	echo ------------------------------------------ >> %logfile% 
	REM install Software 
	echo The software Name is %software% >> %logfile% 
	echo The software Version is %version% >> %logfile% 
	echo The Local Software count is %local_SW_count% >> %logfile%
	REM Kick off the installer
	start /wait "" "c:\device\software\%software%\install%software%.bat" %version%
	echo Finished installing %software%%version% >> %logfile% 
	echo ------------------------------------------ >> %logfile% 
	if not %Win_SW_Count%==%local_SW_count% (
		set /A local_SW_count+=1
		goto get_SW_Details
	)
	echo No further Software Packages to install. >> %logfile%
	goto :EOF
	
)
echo No Software Packages to install. >> %logfile%
goto :EOF

:MAIN
call :Get_Windows_Software_Count
call :get_SW_Details
call :install_Software
call :exit

:exit
echo ############# Finished Installing all Software Packages ############# >> %logfile% 2>>&1
exit 0

