@echo on
set exedir=%~dp0
cd %exedir%
set logfile=c:\LocalDropbox\result.log
set testName=%1
set vmname=%2
set testcase=%3

echo ------------- Starting to Copy log files to Results Directory ------------- >> %logfile% 

goto :MAIN

:get_Info
REM Eventually this will be pulled from the properties file.
goto :EOF

:copyresults
rem copy directory
set myresultsdir= x:\SutResults\%testName%\%vmname%\%testcase%
echo Results Directory %myresultsdir% >> %logfile%
echo d | xcopy c:\LocalDropbox\*.log %myresultsdir% /i /y
echo d | xcopy c:\LocalDropbox\*.jpg %myresultsdir% /i /y
echo d | xcopy c:\LocalDropbox\*.png %myresultsdir% /i /y
goto :EOF

:SHARE_ERROR
REM Currently this is not used. Need to add an error catcher to the xcopy statements
echo The Shared drive does not exist! >> %logfile%
echo [%testcase%_FAILED] >> %logfile%
echo ------------- Finished Copying Log files to Results Directory ------------- >> %logfile% 
exit 1

:MAIN
call :get_Info
call :copyresults
call :exit

:exit
echo ------------- Finished Copying Log files to Results Directory ------------- >> %logfile% 
exit 0