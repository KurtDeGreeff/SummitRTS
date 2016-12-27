rem Execute_testcase.bat
rem This script will:
rem
rem Run each test case
rem Mount the Results share
rem Copy the result.log to the results share
rem disconnect from the results share

set logfile=c:\LocalDropbox\result.log

set testName=%~1
set vmname=%~2
set testcase=%~3
set testcase_script=%~4

echo ########## Begining %testcase% ########## >> %logfile%

echo testName is :%testName% >> %logfile%
echo Vmname is : %vmname% >> %logfile%
echo Testcase is : %testcase% >> %logfile%
echo Testcase Script is : %testcase_script% >> %logfile%

goto :MAIN

:executeTestCase
echo Executing %testcase% Script >> %logfile%
if exist "c:\LocalDropbox\%testcase_script%" (
	start /wait "" c:\LocalDropbox\%testcase_script%
	echo Finished Executing %testcase% Script: %testcase_script% >> %logfile%
	goto :EOF
)
echo The file does not exist (c:\LocalDropbox\%testcase_script%) >> %logfile%
echo [TEST_FAILED] >> %logfile%
goto :exit
	
:mount_Share
echo Attempting to connect to shared drive >> %logfile%
if exist "c:\LocalDropbox\connectShare.bat" (
	start /wait "" "c:\LocalDropbox\connectShare.bat" results
	echo Finished connecting to the shared drive >> %logfile%
	echo ########## Finished %testcase% ########## >> %logfile%
	goto :EOF
)
echo The file does not exist (c:\LocalDropbox\connectShare.bat) >> %logfile%
echo [TEST_FAILED] >> %logfile%
goto :exit

:copyTestResults
echo Copying Provisioning results back to results Directory >> %logfile%
if exist "c:\LocalDropbox\batch\copyResults.bat" (
	start /wait "" "c:\LocalDropbox\batch\copyResults.bat" %testName% %vmname% %testcase%
	echo Finished Copying Provisioning results back to Results directory >> %logfile%
	goto :EOF
)
echo The file does not exist (c:\LocalDropbox\batch\copyResults.bat) >> %logfile%
echo [TEST_FAILED] >> %logfile%
goto :exit

:Disconnect_Share
echo Disconnecting from Shared Drive >> %logfile%
if exist "c:\LocalDropbox\batch\disconnectShare.bat" (
	start /wait "" "c:\LocalDropbox\batch\disconnectShare.bat"
	echo Finished Disconnecting from Shared Drive >> %logfile%
	goto :EOF
)
echo The file does not exist (c:\LocalDropbox\batch\disconnectShare.bat) >> %logfile%
echo [TEST_FAILED] >> %logfile%
goto :exit

:MAIN
call :executeTestCase
call :mount_Share
call :copyTestResults
call :Disconnect_Share
call :exit

:exit
exit 0