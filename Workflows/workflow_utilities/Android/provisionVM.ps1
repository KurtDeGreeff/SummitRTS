#=======================================================================================
# Author: Justin Sider
# Purpose: Cmdlets for Powershell to run Device agent
#=======================================================================================

#=======================================================================================
# System Variables
#=======================================================================================
# This will remove the need to keep clicking R
set-ExecutionPolicy Bypass

# Enables all of the needed cmdlets
. "C:\Belay-Device-Code\agent-scripts\Agent_Support_Tools\Android\android-cmdlets.ps1"

$testName=$args[0]
$vmName=$args[1]
$SUTname=$args[2]
#create a provisioning folder
New-Item c:\share\SutResults\$testName\$SUTname\provisioning -type directory
#Create a device.log
$deviceLogFile = "c:\share\SutResults\$testName\$SUTname\provisioning\device.log"
deviceLog("Starting Provisioning of Android Device TestName: $TestName, SUTName:$SUTname")

$adb = "C:\Belay-Device-Code\agent-scripts\Agent_Support_Tools\Android\adb.exe"
pause 5
deviceLog("Killing any adb processes")
. $adb kill-server
pause 5
deviceLog("Starting new ADB process")
start-process -NoNewWindow "powershell.exe" ". $adb start-server"
pause 10
deviceLog("Connect to Android VM")
#Attempt to connect to the Android vm
start-process -NoNewWindow "powershell.exe" ". $adb connect 192.168.10.81:5555"
pause 5
start-process -NoNewWindow "powershell.exe" ". $adb connect 192.168.10.81:5555"
pause 5
#Install application
deviceLog("Install Android software: Handcent")
$softwarePath = "C:\Belay-Device-Code\sut-scripts\ANDROID\Software\Handcent\handcent.apk"
start-process -NoNewWindow -wait "powershell.exe" ". $adb install $softwarePath"
#List the installed packages and find app
deviceLog("Grabbing the list of installed packages")
$DroidAppList = @(. $adb shell pm list packages -f)
pause 10
$applistfile = "c:\share\SutResults\$testName\$SUTname\provisioning\applist.log"
$DroidAppList | out-File $applistfile
# Looking for this package:/data/app/com.handcent.nextsms-1.apk=com.handcent.nextsms
$ProvisionStatus = $false
foreach($app in $DroidAppList) {
	if ($app -eq "package:/data/app/com.handcent.nextsms-1.apk=com.handcent.nextsms") {
		deviceLog("The application was installed")
		$ProvisionStatus = $True
		break
	} else {
		deviceLog("The application was not installed")
		$ProvisionStatus = $false
	}
}
if($ProvisionStatus -eq $false){
	#write fail to the log file
	deviceLog("PROVISIONING_FAILED")
} elseif ($ProvisionStatus -eq $TRUE){
	#write pass to the log file
	deviceLog("PROVISIONING_PASSED")
}
pause 5
. $adb kill-server
####################### Provisioning Script