#=======================================================================================
# Purpose: Cmdlets for Powershell to run an agent
#=======================================================================================

#=======================================================================================
# System Variables
#=======================================================================================
# This will remove the need to keep clicking R
set-ExecutionPolicy Bypass

# Enables all of the needed cmdlets
. "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Android\android-cmdlets.ps1"

$testName=$args[0]
$vmName=$args[1]
$SUTname=$args[2]
$testCase=$args[3]
#create a testcase folder
New-Item c:\share\SutResults\$testName\$SUTname\$testcase -type directory
#Create a result.log
$androidLogFile = "c:\share\SutResults\$testName\$SUTname\$testcase\result.log"
androidLog("Starting Testcase: $testcase of Android TestName: $TestName, SUTName:$SUTname")
#setup the adb command
$adb = "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Android\adb.exe"
pause 5
androidLog("Killing any adb services")
. $adb kill-server
pause 5
androidLog("Starting new ADB service")
start-process -NoNewWindow "powershell.exe" ". $adb start-server"
pause 10
androidLog("Connect to Android VM")
#Attempt to connect to the Android vm
start-process -NoNewWindow -wait "powershell.exe" ". $adb connect 192.168.10.81:5555"
pause 5
start-process -NoNewWindow -wait "powershell.exe" ". $adb connect 192.168.10.81:5555"
pause 5

#start the application
androidLog("Start the Application")
start-process -NoNewWindow -wait "powershell.exe" ". $adb shell am start com.handcent.nextsms"
pause 10
#grab a screen Capture
androidLog("Taking screen Capture")
. $adb shell screencap /sdcard/screen.png
androidLog("Copying Screen capture to share")
#Copy the screen capture down to share
. $adb pull /sdcard/screen.png c:\share\SutResults\$testName\$SUTname\$testcase

#grab the running processes
androidLog("Grabbing the list of running processes")
$DroidProcessList = @(. $adb shell ps)
pause 10
$processlistfile = "c:\share\SutResults\$testName\$SUTname\$testcase\proclist.log"
$DroidProcessList | Out-File $processlistfile
#determine and write pass/fail
androidLog("Determining whether the correct process was running")
$TestCaseResult = $false
foreach($process in $DroidProcessList) {
	if ($process -like "*com.handcent.nextsms*") {
		androidLog("The process is running!")
		$TestCaseResult = $True
		break
	} else {
		androidLog("The process is not running, oh No!")
		$TestCaseResult = $false
	}
}
if($TestCaseResult -eq $false){
	#write fail to the log file
	androidLog("TEST_FAILED")
} elseif ($TestCaseResult -eq $TRUE){
	#write pass to the log file
	androidLog("TEST_PASSED")
}
androidLog("End of Testcase: $testcase")

start-sleep 5
. $adb kill-server
###################### TestCase Script