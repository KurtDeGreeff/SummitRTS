rem Provisionvm.bat
rem This script will:
rem
rem write information about the test and SUT
rem mount a share
rem copy artifacts to the vm
rem install software
rem Copy provisioning Results
rem unmount a share


set logfile=c:\device\device.log
set testName=%~1
set vmname=%~2
set testcase=Provisioning

echo ########## Starting Provision VM stage ########## >> %logfile%

goto :MAIN

:Write_Info
echo TestName is :%testName% >> %logfile%
echo Vmname is : %vmname% >> %logfile%
echo the hostname is : >> %logfile%
hostname >> %logfile% 
echo the Username is : >> %logfile%
whoami >> %logfile% 
echo the System version is : >> %logfile%
ver >> %logfile%
echo Writing Systeminfo to separate log file >> %logfile%
systeminfo >> c:\device\systeminfo.log
goto :EOF

:mount_Share
echo Attempting to connect to shared drive >> %logfile%
if exist "c:\device\connectShare.bat" (
	start /wait "" "c:\device\connectShare.bat" provision
	echo Finished connecting to the shared drive >> %logfile%
	goto :EOF
)
echo The file does not exist (c:\device\connectShare.bat) >> %logfile%
echo [PROVISIONING_FAILED] >> %logfile%
goto :exit

:Copy_Target_Scripts
echo Attempting to copy Target scripts to vm >> %logfile%
if exist "c:\device\copyScripts.bat" (
	start /wait "" c:\device\copyScripts.bat
	echo Finished copying target Scripts to vm >> %logfile%
	goto :EOF
)
echo The file does not exist (c:\device\copyScripts.bat) >> %logfile%
echo [PROVISIONING_FAILED] >> %logfile%
goto :exit

:Disconnect_Share
echo Disconnecting from Shared Drive >> %logfile%
if exist "c:\device\batch\disconnectShare.bat" (
	start /wait "" "c:\device\batch\disconnectShare.bat"
	echo Finished Disconnecting from Shared Drive >> %logfile%
	goto :EOF
)
echo The file does not exist (c:\device\batch\disconnectShare.bat) >> %logfile%
echo [PROVISIONING_FAILED] >> %logfile%
goto :exit

:Install_Software
echo Installing Requested Software >> %logfile%
if exist "c:\device\Software\installWrapper.bat" (
	start /wait "" c:\device\Software\installWrapper.bat
	echo Finished Installing Requested Software >> %logfile%
	goto :EOF
)
echo The file does not exist (c:\device\Software\installWrapper.bat) >> %logfile%
echo [PROVISIONING_FAILED] >> %logfile%
goto :exit

:Write_pass
REM - Might be used in the future to determine pass/fail of provisioning
echo [PROVISIONING_PASSED] >> %logfile%
echo ########## Finished Provisioning Phase ########## >> %logfile%
goto :EOF

:mount_Share_final
echo Attempting to connect to shared drive >> %logfile%
if exist "c:\device\connectShare.bat" (
	start /wait "" "c:\device\connectShare.bat" results
	echo Finished connecting to the shared drive >> %logfile%
	goto :EOF
)
echo The file does not exist (c:\device\connectShare.bat) >> %logfile%
echo [PROVISIONING_FAILED] >> %logfile%
goto :exit

:copyResults
echo Copying Provisioning results back to results Directory >> %logfile%
if exist "c:\device\batch\copyResults.bat" (
	start /wait "" "c:\device\batch\copyResults.bat" %testName% %vmname% %testcase%
	echo Finished Copying Provisioning results back to Results directory >> %logfile%
	goto :EOF
)
echo The file does not exist (c:\device\batch\copyResults.bat) >> %logfile%
echo [PROVISIONING_FAILED] >> %logfile%
goto :exit

:MAIN
call :Write_Info
call :mount_Share
call :Copy_Target_Scripts
call :Disconnect_Share
call :Install_Software
call :Write_pass
call :mount_Share_final
call :copyResults
call :Disconnect_Share
call :exit

:exit
echo Provisioning ErrorLevel is : %errorlevel% >> %logfile%
exit 0