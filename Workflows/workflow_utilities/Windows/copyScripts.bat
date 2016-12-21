rem copyScripts.bat
rem This script will copy Scripts/files to the SUT

@echo on
set exedir=%~dp0
cd %exedir%
set logfile=c:\device\device.log

echo ------------- Starting to Copy Scripts to Target ------------- >> %logfile% 

goto :MAIN

:get_Info
rem This will be used to pull information from the properties file
goto :EOF

:copyFiles
REM This Function will copy the Test files, Software, etc. to the target
IF NOT EXIST x:\ goto SHARE_ERROR
echo Starting to move Target scripts to the VM >> %logfile% 
xcopy x:\sut-scripts\WINDOWS c:\device\ /s /e /y
echo Finished moving scripts to Target >> %logfile%
goto :EOF

:SHARE_ERROR
echo The Shared drive does not exist! >> %logfile%
echo [PROVIONING_FAILED] >> %logfile%
echo ------------- Finished Copy Scripts to Target ------------- >> %logfile% 
exit 1

:MAIN
call :get_Info
call :copyFiles
call :exit

:exit
echo ------------- Finished Copy Scripts to Target ------------- >> %logfile% 
exit 0
