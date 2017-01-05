#=======================================================================================
# Purpose: Support routines for various Automated VMware Workstation tasks
#=======================================================================================
# This will remove the need to keep clicking R
set-ExecutionPolicy Bypass

# Enables all of the needed cmdlets
writeLog("Root Execution directory is '${SCRIPTDIR}'")

#=======================================================================================
# Set the path for vmRun.exe
$vmRun = "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"
$VMX_Path = $DATASTORE + "\" + $vmName + "\" + $vmName + ".vmx"

#=======================================================================================
function ShutdownVm {
	. $vmRun stop $VMX_Path 
	return $true
}

#=======================================================================================
function DeleteVm {
	# Permanently delete the Vm
	. $vmRun deleteVM $VMX_Path 
}

#=======================================================================================
function CloneVM {
	$Clone_VMX_Path = $DATASTORE + "\" + $vmClone + "\" + $vmClone + ".vmx"
	writeLog("The Template vm being used is ${VMX_Path}, and the clone/SUT vm is ${Clone_VMX_Path}")
	writeLog("$vmRun clone $VMX_Path $Clone_VMX_Path full")
	. $vmRun clone $VMX_Path $Clone_VMX_Path full
	start-sleep 30
	writeLog("debug 30 seconds")
	return $True
}

#=======================================================================================
function StartVM($vmName) {
	#Start the VM
	. $vmRun start $VMX_Path
	return $True
}
	
#=======================================================================================
function CreateSnapshot {
	#set the Snapshot name
	$SnapshotName = "PostProvision"
	
	#Take a snapshot of the VM
	. $vmRun snapshot $VMX_Path $SnapshotName
	return $True
}

#=======================================================================================
function RevertSnapshot {
	# Revert the Snapshot
	$SnapshotName = "PostProvision"
	#revert the snapshot
	. $vmRun revertToSnapshot $VMX_Path $SnapshotName
	#Start the vm back up
	. $vmRun start $VMX_Path
	return $True
}

#=======================================================================================
function GetIPAddress {
	$VMIP = . $vmrun getGuestipaddress $VMX_Path
	writeLog("Adding IP: $VMIP to DB for SUT $vmName")
	$query = "update suts set IP_Address='$VMIP' where Name = '$vmName'"
	RunSQLCommand $query
	return $True
}

#=======================================================================================
function CopyFilestoSUT {
	writeLog ("Copying Specify Files to the VM.")
	#Determine OS_Type to run OS specific command
	if ($OS_Type -eq "Windows") {
		. $vmRun -gu $VMUN -gp $VMPW copyFileFromHostToGuest $VMX_Path "c:\share\SutResults\${testName}\${SUTname}\properties.txt" "C:\LocalDropbox\properties.txt"
		. $vmRun -gu $VMUN -gp $VMPW copyFileFromHostToGuest $VMX_Path "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Windows\provisionVM.bat" "C:\LocalDropbox\provisionVM.bat"
		. $vmRun -gu $VMUN -gp $VMPW copyFileFromHostToGuest $VMX_Path "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Windows\execute_testcase.bat" "C:\LocalDropbox\execute_testcase.bat"
		. $vmRun -gu $VMUN -gp $VMPW copyFileFromHostToGuest $VMX_Path "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Windows\connectShare.bat" "C:\LocalDropbox\connectShare.bat"
		. $vmRun -gu $VMUN -gp $VMPW copyFileFromHostToGuest $VMX_Path "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Windows\copyScripts.bat" "C:\LocalDropbox\copyScripts.bat"
	} ElseIf ($OS_Type -eq "Linux") {
		. $vmRun -gu $VMUN -gp $VMPW copyFileFromHostToGuest $VMX_Path "c:\share\SutResults\${testName}\${SUTname}\properties.txt" "/LocalDropbox/properties.txt"
		. $vmRun -gu $VMUN -gp $VMPW copyFileFromHostToGuest $VMX_Path "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Linux\provisionVM.sh" "/LocalDropbox/provisionVM.sh"
		. $vmRun -gu $VMUN -gp $VMPW copyFileFromHostToGuest $VMX_Path "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Linux\execute_testcase.sh" "/LocalDropbox/execute_testcase.sh"
		. $vmRun -gu $VMUN -gp $VMPW copyFileFromHostToGuest $VMX_Path "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Linux\connectShare.sh" "/LocalDropbox/connectShare.sh"
		. $vmRun -gu $VMUN -gp $VMPW copyFileFromHostToGuest $VMX_Path "C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Linux\copyScripts.sh" "/LocalDropbox/copyScripts.sh"
	} Elseif ($OS_Type -eq "Android") {
		# Use ADB to Copy files
	} Else {
		#No OP
		WriteLog("No OS_Type-($OS_Type) was found to copy the files")
		$AgentStatus = $False
		return $AgentStatus
	}
}

#=======================================================================================
function ExecuteSUTProvisionScript {
	writeLog ("Running $Script_Path")
	#Determine OS_Type to run OS specific command
	if ($OS_Type -eq "Windows") {
		. $vmRun -gu $VMUN -gp $VMPW runProgramInGuest $VMX_Path c:\LocalDropbox\$Script_Path $testName $vmName
	} ElseIf ($OS_Type -eq "Linux") {
		. $vmrun -gu $VMUN -gp $VMPW runscriptinguest $VMX_Path /bin/bash ". /LocalDropbox/$Script_Path $testName $vmName"
	} Elseif ($OS_Type -eq "Android") {
		# Use ADB to execute files
	} Else {
		#No OP
		WriteLog("No OS_Type-($OS_Type) was found to copy the files")
		$AgentStatus = $False
		return $AgentStatus
	}
}

#=======================================================================================
function ExecuteSUTScript {
	writeLog ("Running execute_testcase script for ${testCase} with subScript: $Script_Path")
	#Determine OS_Type to run OS specific command
	if ($OS_Type -eq "Windows") {
		. $vmRun -gu $VMUN -gp $VMPW runProgramInGuest $VMX_Path c:\LocalDropbox\execute_testcase.bat $testName $vmName $testcase_name $Script_Path
	} ElseIf ($OS_Type -eq "Linux") {
		. $vmrun -gu $VMUN -gp $VMPW runscriptinguest $VMX_Path /bin/bash ". /LocalDropbox/execute_testcase.sh $testName $vmName $testcase_name $Script_Path"
	} Elseif ($OS_Type -eq "Android") {
		# Use ADB to execute files
	} Else {
		#No OP
		WriteLog("No OS_Type-($OS_Type) was found to execute the files")
		$AgentStatus = $False
		return $AgentStatus
	}
}