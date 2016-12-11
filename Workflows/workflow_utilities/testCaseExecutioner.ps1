#=======================================================================================
# Author: Justin Sider
# Purpose: Running a Testcase against a 'System Under Test'
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
# User Arguments
#=======================================================================================

$testName=$args[0]
$vmName=$args[1]
$SUTname=$args[2]
$testCase=$args[3]
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

####################################
# Start Of SUT Configuration
####################################

# Echo a line about starting the test
writeLog("Starting Testcase ${testCase} for test: ${testName} on Template VM : ${vmName}")
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
	
	####################################
	# Start Test Case 
	####################################
	
	# Revert to a Snapshot named PostProvision
	writeLog("RevertSnapshot is reverting to a PostProvision Snapshot of the SUT")
	if (! (RevertSnapshot $vmName $MAXWAITSECS)) {
		writeLog("${vmName} failed to Revert Snapshot.")
		$AgentStatus = $False
		return $AgentStatus
		Break
	}
	
	# wait 3 seconds
	writeLog ("Pausing 3 seconds")
	pause 3
	
	# Wait for VMtools to start
	if ($OS_Type -ne "Android") {
		#Android does not currently work with vmtools
		writeLog("WaitForTools. Waiting no more than ${TOOLSWAIT} seconds.")
		if(! (WaitForTools $vmName $TOOLSWAIT)) {
			writeLog("${vmName} WaitForTools Failed. VMTools failed to respond. ")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}
	}
	
	# wait 3 seconds
	writeLog ("Pausing 3 seconds")
	pause 3
	
	writeLog("Starting ${testCase}")
	#run test case batch script
	writeLog ("Running execute_testcase script for ${testCase} with SubScript: ${testcase_script}")
	#Determine OS_Type to run OS specific command
	if ($OS_Type -eq "Windows") {
		$Echo = Invoke-VMScript -ScriptText "c:\device\execute_testcase.bat $testName $vmName $testCase $testcase_script" -VM $vmName -GuestUser $VMUN -GuestPassword $VMPW -ScriptType Bat -ErrorAction SilentlyContinue
		if ($Echo.ExitCode -ne 0) {
			writeLog("${vmName} Invoke-VMScript Failed. ${testcase_script} failed to run. ")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}
	} Elseif ($OS_Type -eq "Linux"){
		#Perform the Linux equivalent
		# wait 30 seconds
		writeLog ("Pausing 30 seconds for linux vmtools to restart")
		pause 30
		#Invoke-VMScript -ScriptText "/bin/bash /device/execute_testcase.sh $testName $vmname $testCase $testcase_script" -VM $vmname -GuestUser $VMUN -GuestPassword $VMPW -ErrorAction SilentlyContinue
		if (! (Invoke-VMScript -ScriptText "/bin/bash /device/execute_testcase.sh $testName $vmname $testCase $testcase_script" -VM $vmname -GuestUser $VMUN -GuestPassword $VMPW -ErrorAction SilentlyContinue)) {
			writeLog("The testcase $testcase_script script failed to run")
			$AgentStatus = $False
			return $AgentStatus
			break
		}
	} Elseif ($OS_Type -eq "Android") {
		#Start the ADB Testcase script
		if (! (. "C:\Belay-Device-Code\sut-scripts\ANDROID\$testcase_script" $testname $vmName $SUTname $testcase)) {
			writeLog("The testcase $testcase_script script failed to run")
			$AgentStatus = $False
			return $AgentStatus
			break
		}
	} Else {
		#No OP
		WriteLog("No OS_Type-($OS_Type) was found to execute the testcase")
		$AgentStatus = $False
		return $AgentStatus
		Break
	}
	writeLog("End of ${testCase}")
	
	# wait 3 seconds
	writeLog ("Pausing 3 seconds")
	pause 3

	# Determine Pass/Fail by searching for a result string in the Test's device.log file.
	$filename = "c:\share\SutResults\${testName}\${vmName}\${testcase_name}\device.log"
	$SearchString = "TEST_PASSED"
	$Sel = select-string -pattern $SearchString -path $FileName
	If ($Sel -ne $null) {
		$query = "update test_cases set Testcase_Status='Complete', Testcase_Result='PASS' where SUT_Name = '$vmName' and Testcase_name = '$testcase_name'"
		RunSQLCommand $query
		writeLog("The testcase has Passed, We found the correct string in device.log")
	} Else {
		$SearchString = "TEST_FAILED"
		$Sel = select-string -pattern $SearchString -path $FileName
		If ($Sel -ne $null) {
			$query = "update test_cases set Testcase_Status='Complete', Testcase_Result='FAIL' where SUT_Name = '$vmName' and Testcase_name = '$testcase_name'"
			RunSQLCommand $query
			writeLog("The Testcase has Failed, We did not find the correct string in device.log")
		} Else {
			$SearchString = "CRITICAL"
			$Sel = select-string -pattern $SearchString -path $FileName
			If ($Sel -ne $null) {
				$query = "update test_cases set Testcase_Status='Complete', Testcase_Result='CRITICAL' where SUT_Name = '$vmName' and Testcase_name = '$testcase_name'"
				RunSQLCommand $query
				writeLog("The Testcase is Critical, we found the Critical string in device.log")
			} Else {
				$query = "update test_cases set Testcase_Status='Complete', Testcase_Result='unknown' where SUT_Name = '$vmName' and Testcase_name = '$testcase_name'"
				RunSQLCommand $query
				writeLog("The testcase is unknown, We found no strings in device.log")
			}
		}
	}
	# Add Logfile paths to the Database
	writeLog("Add Logfile paths to the Database")
	AddSUTLogFilesToDB $Testcase_Id $testName $vmName $testcase_name
}
writeLog("DestroySUT Agent status is ${AgentStatus}")
return $AgentStatus
####################################
# End of Test Case 
####################################