#=======================================================================================
# Author: Justin Sider
# Purpose: Provision a 'System Under Test'
#=======================================================================================

#=======================================================================================
# System Variables
#=======================================================================================
# This will remove the need to keep clicking R
set-ExecutionPolicy Bypass

# Enables all of the needed cmdlets
. "$SCRIPTDIR\device-cmdlets.ps1"
. "$SCRIPTDIR\mysql-cmdlets.ps1"
. "$SCRIPTDIR\$hypervisor_Type\hypervisor-cmdlets.ps1"
writeLog("Root Execution directory is '${SCRIPTDIR}'")

# Enable Powercli
enable-vsphere-cli-in-powershell

#=======================================================================================
# Agent Arguments
#=======================================================================================
$testName=$args[0]
$vmName=$args[1]
$SUTname=$args[2]
$testcase_name=$args[3]
$Testcase_Id=$args[4]
$vmName = $SUTname
# Defaults
$LogFile = "c:\share\SutResults\$testName\$SUTname\agent.log"
$MAXWAITSECS = 60 * 3
$TOOLSWAIT = 60 * 6
$VCcenterCONN = $Null
$AgentStatus = $true

#=======================================================================================
# Belay Device
#=======================================================================================

# Echo a line about starting the test
writeLog("Starting Provisioning for test: ${testName}")
writeLog("The SUTname for this test is : ${SUTname}")
writeLog("The Template_VM used for this test is ${TemplateName}")

#Function to Grab the Template username and password
$query = "select * from template_vm_information where Easy_Name like '$TemplateName'"
$TemplateVMData = @(RunSQLCommand $query)
$VMUN = $TemplateVMData.OS_Username
$VMPW = $TemplateVMData.OS_Password
$OS_Type = $TemplateVMData.OS_Type
writeLog("Template UN is : $VMUN")
writeLog("Template PW is : $VMPW")
writeLog("Template OS_Type is : $OS_Type")

# Start a loop that we can break out of if needed
if ($AgentStatus = $true) {
	# Connect to the Vcenter or server
	writeLog("ConnectVcenter is attaching to vcenter ${Vcenter}.")
	if(! $DEVICECONN -and ! ($DEVICECONN = ConnectVcenter)) {
		writeLog("ConnectVcenter ${Vcenter} Failed.")
		$AgentStatus = $False
		return $AgentStatus
		Break
	}
	
	# Rename the SUTname to vmName
	$vmName = $SUTname
	writeLog("Reset the SUT name to ${vmName} to simplify scripts.")
	
	# wait 3 seconds
	writeLog ("Pausing 3 seconds")
	pause 3
	
	####################################
	# Start Of provisioning
	####################################
	
	# Copy the files to the Target vm that will be run from the Host server
	writeLog ("Copying Specify Files to the VM.")
	#Determine OS_Type to run OS specific command
	if ($OS_Type -eq "Windows") {
		Copy-VMGuestFile -Source "c:\share\SutResults\${testName}\${SUTname}\properties.txt" -Destination "c:\device" -LocalToGuest -vm $vmName -GuestUser $VMUN -GuestPassword $VMPW
		Copy-VMGuestFile -Source "C:\Belay-Device-Code\agent-scripts\Agent_Support_Tools\Windows\provisionVM.bat" -Destination "c:\device" -LocalToGuest -vm $vmName -GuestUser $VMUN -GuestPassword $VMPW
		Copy-VMGuestFile -Source "C:\Belay-Device-Code\agent-scripts\Agent_Support_Tools\Windows\execute_testcase.bat" -Destination "c:\device" -LocalToGuest -vm $vmName -GuestUser $VMUN -GuestPassword $VMPW
		Copy-VMGuestFile -Source "C:\Belay-Device-Code\agent-scripts\Agent_Support_Tools\Windows\connectShare.bat" -Destination "c:\device" -LocalToGuest -vm $vmName -GuestUser $VMUN -GuestPassword $VMPW
		Copy-VMGuestFile -Source "C:\Belay-Device-Code\agent-scripts\Agent_Support_Tools\Windows\copyScripts.bat" -Destination "c:\device" -LocalToGuest -vm $vmName -GuestUser $VMUN -GuestPassword $VMPW
	} Elseif ($OS_Type -eq "Linux") {
		Copy-VMGuestFile -Source "c:\share\SutResults\${testName}\${SUTname}\properties.txt" -Destination "/device/properties.txt" -LocalToGuest -vm $vmname -GuestUser $VMUN -GuestPassword $VMPW
		Copy-VMGuestFile -Source "C:\Belay-Device-Code\agent-scripts\Agent_Support_Tools\Linux\provisionVM.sh" -Destination "/device/provisionVM.sh" -LocalToGuest -vm $vmname -GuestUser $VMUN -GuestPassword $VMPW
		Copy-VMGuestFile -Source "C:\Belay-Device-Code\agent-scripts\Agent_Support_Tools\Linux\execute_testcase.sh" -Destination "/device/execute_testcase.sh" -LocalToGuest -vm $vmname -GuestUser $VMUN -GuestPassword $VMPW
		Copy-VMGuestFile -Source "C:\Belay-Device-Code\agent-scripts\Agent_Support_Tools\Linux\connectShare.sh" -Destination "/device/connectShare.sh" -LocalToGuest -vm $vmname -GuestUser $VMUN -GuestPassword $VMPW
		Copy-VMGuestFile -Source "C:\Belay-Device-Code\agent-scripts\Agent_Support_Tools\Linux\copyScripts.sh" -Destination "/device/copyScripts.sh" -LocalToGuest -vm $vmname -GuestUser $VMUN -GuestPassword $VMPW
	} Elseif ($OS_Type -eq "Android") {
		# No files to copy for ADB, command run on the agent via ADB
		writeLog("No files were copied for Android")
	} Else {
		#No OP
		WriteLog("No OS_Type-($OS_Type) was found to copy the files")
		$AgentStatus = $False
		return $AgentStatus
	}
	# wait 3 seconds
	writeLog ("Pausing 10 seconds")
	pause 10
	
	# Run provision script
	writeLog ("Running $testcase_script")
	#Determine OS_Type to run OS specific command
	if ($OS_Type -eq "Windows") {
		$Echo = Invoke-VMScript -ScriptText "c:\device\$testcase_script $testName $vmName" -VM $vmName -GuestUser $VMUN -GuestPassword $VMPW -ScriptType Bat -ErrorAction SilentlyContinue
		if ($Echo.ExitCode -ne 0) {
			writeLog("${vmName} Invoke-VMScript Failed. $testcase_script failed to run. ")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}
	} ElseIf ($OS_Type -eq "Linux") {
		#Perform the Linux equivalent
		$Echo = Invoke-VMScript -ScriptText "/bin/bash /device/$testcase_script $testName $vmname" -VM $vmname -GuestUser $VMUN -GuestPassword $VMPW -ErrorAction SilentlyContinue
		if ($Echo.ExitCode -ne 0) {
			writeLog("${vmName} Invoke-VMScript Failed. $testcase_script failed to run. ")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}
	} Elseif ($OS_Type -eq "Android") {
		#Start the ADB Provision script
		if (! (. "C:\Belay-Device-Code\agent-scripts\Agent_Support_Tools\Android\$testcase_script" $testname $vmName $SUTname)) {
			writeLog("The provision1 script: $testcase_script failed to run")
			$AgentStatus = $False
			return $AgentStatus
			break
		}
	} Else {
		WriteLog("No OS_Type-($OS_Type) was found to execute the script")
		$AgentStatus = $False
		return $AgentStatus
	}
	# wait 3 seconds
	writeLog ("Pausing 3 seconds")
	pause 3
	
	# Add Logfile paths to the Database
	writeLog("Add Logfile paths to the Database")
	AddSUTLogFilesToDB $Testcase_Id $testName $vmName $testcase_name
	
	# Determine Pass/Fail by searching for a result string in the Test's log file.
	writeLog("Determine Pass/Fail by searching for a result string in the Test's log file.")
	$filename = "c:\share\SutResults\${testName}\${vmName}\${testcase_name}\device.log"
	$SearchStringPass = "PROVISIONING_PASSED"
	$SelPASS = select-string -pattern $SearchStringPass -path $FileName
	$SearchStringFail = "PROVISIONING_FAILED"
	$SelFAIL = select-string -pattern $SearchStringFail -path $FileName
	if ($SelFAIL -ne $null) {
		$query = "update test_cases set Testcase_Status='Complete', Testcase_Result='FAIL' where SUT_Name = '$vmName' and Testcase_name = '$testcase_name'"
		RunSQLCommand $query
		writeLog("Provisioning has Failed, We found a failure string in device.log")
		$AgentStatus = $False
		Break
	}
	If ($SelPASS -eq $null)	{
		$query = "update test_cases set Testcase_Status='Complete', Testcase_Result='FAIL' where SUT_Name = '$vmName' and Testcase_name = '$testcase_name'"
		RunSQLCommand $query
		writeLog("Provisioning has Failed, We did not find the correct string in device.log")
	} Else {
		$query = "update test_cases set Testcase_Status='Complete', Testcase_Result='PASS' where SUT_Name = '$vmName' and Testcase_name = '$testcase_name'"
		RunSQLCommand $query
		writeLog("Provisioning has Passed, We found the correct string in device.log")
	}

	# Take a Snapshot named PostProvision
	writeLog("CreateSnapshot is creating a PostProvision Snapshot of the SUT")
	if (! (CreateSnapshot $vmName $MAXWAITSECS)) {
		writeLog("${vmName} failed to Snapshot.")
		$AgentStatus = $False
		return $AgentStatus
		Break
	}
	
	# wait 10 seconds
	writeLog ("Pausing 10 seconds")
	pause 10
	
}
writeLog("provisionSUT Agent status is ${AgentStatus}")
return $AgentStatus
####################################
# End Of SUT Provisioning
####################################