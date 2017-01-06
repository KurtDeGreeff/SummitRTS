#=======================================================================================
# Purpose: Support routines for various Automated VirtualBox tasks
#=======================================================================================
# This will remove the need to keep clicking R
set-ExecutionPolicy Bypass

# Enables all of the needed cmdlets
writeLog("Root Execution directory is '${SCRIPTDIR}'")

#=======================================================================================
# Set the path for vBoxManage.exe
$vBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$task_timeout = 90000

#=======================================================================================
function ShutdownVm($vmName, $maxWaitTimeInSecs=$MAXWAITSECS) {
	. $vBoxManage controlvm $vmName poweroff
	return $true
}

#=======================================================================================
function StopVm($vmName, $maxWaitTimeInSecs=$MAXWAITSECS) {
	. $vBoxManage controlvm $vmName poweroff
	return $true
}

#=======================================================================================
function DeleteVm($vmName, $maxWaitTimeInSecs=$MAXWAITSECS) {
	# Permanently delete the Vm
	. $vBoxManage unregistervm $vmName --delete
}

#=======================================================================================
function CloneVM($vmName, $vmClone) {
	writeLog("The Template vm being used is ${vmName}, and the clone/SUT vm is ${vmClone}, to Datastore $DATASTORE")
	. $vBoxManage clonevm $vmName --name $vmClone --basefolder $DATASTORE
	return $True
}

#=======================================================================================
function RegisterClone($vmName) {
	writeLog("Registering the newly created clone/SUT vm ${vmName}")
	writeLog("Path to new vm is '$DATASTORE\$vmName\$vmName.vbox'")
	. $vBoxManage registervm $DATASTORE\$vmName\$vmName.vbox
	return $True
}

#=======================================================================================
function StartVM($vmName) {
	#Start the VM
	. $vBoxManage startvm $vmName
	return $True
}
	
#=======================================================================================
function CreateSnapshot($vmName, $maxWaitTimeInSecs=$MAXWAITSECS) {
	#set the Snapshot name
	$SnapshotName = "PostProvision"
	
	#Take a snapshot of the VM
	. $vBoxManage snapshot $vmName take $SnapshotName
	return $True
}

#=======================================================================================
function RevertSnapshot($vmName, $maxWaitTimeInSecs=$MAXWAITSECS) {
	# Revert the Snapshot
	$SnapshotName = "PostProvision"
	. $vBoxManage controlvm $vmName poweroff
	#revert the snapshot
	. $vBoxManage snapshot $vmName restorecurrent
	# Power the vm back on
	. $vBoxManage startvm $vmName
	writeLog("Wait for the vm to recover from the RevertSnapshot")
	Pause 60
	return $True
}

#=======================================================================================
function GetIPAddress($vmName) {
	$myvar = . $vBoxManage guestproperty enumerate $vmName --patterns "*/IP"
	$myarray = $myvar -split ' '
	$VMIP = $myarray[3]
	$VMIP = $VMIP.Substring(0,$VMIP.Length-1)
	writeLog("Adding IP: $VMIP to DB for SUT $vmName")
	$query = "update suts set IP_Address='$VMIP' where Name = '$vmName'"
	RunSQLCommand $query
	return $True
}

#=======================================================================================
function CopyFilestoSUT {
	if ($OS_Type -eq "Windows") {
		writeLog("Copying Windows files to SUT")
		. $vBoxManage guestcontrol $vmname copyto --target-directory c:\LocalDropbox\properties.txt C:\share\SutResults\${testName}\${SUTname}\properties.txt --username $VMUN --password $VMPW
		. $vBoxManage guestcontrol $vmname copyto --target-directory c:\LocalDropbox\provisionVM.bat C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Windows\provisionVM.bat --username $VMUN --password $VMPW
		. $vBoxManage guestcontrol $vmname copyto --target-directory c:\LocalDropbox\execute_testcase.bat C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Windows\execute_testcase.bat --username $VMUN --password $VMPW
		. $vBoxManage guestcontrol $vmname copyto --target-directory c:\LocalDropbox\connectShare.bat C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Windows\connectShare.bat --username $VMUN --password $VMPW
		. $vBoxManage guestcontrol $vmname copyto --target-directory c:\LocalDropbox\copyScripts.bat C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Windows\copyScripts.bat --username $VMUN --password $VMPW
	} ElseIf ($OS_Type -eq "Linux") {
		. $vBoxManage guestcontrol $vmname copyto --target-directory /LocalDropbox/properties.txt c:\share\SutResults\${testName}\${SUTname}\properties.txt --username $VMUN --password $VMPW
		. $vBoxManage guestcontrol $vmname copyto --target-directory /LocalDropbox/provisionVM.sh C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Linux\provisionVM.sh --username $VMUN --password $VMPW
		. $vBoxManage guestcontrol $vmname copyto --target-directory /LocalDropbox/execute_testcase.sh C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Linux\execute_testcase.sh --username $VMUN --password $VMPW
		. $vBoxManage guestcontrol $vmname copyto --target-directory /LocalDropbox/connectShare.sh C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Linux\connectShare.sh --username $VMUN --password $VMPW
		. $vBoxManage guestcontrol $vmname copyto --target-directory /LocalDropbox/copyScripts.sh C:\OPEN_PROJECTS\SummitRTS\Workflows\workflow_utilities\Linux\copyScripts.sh --username $VMUN --password $VMPW
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
	if ($OS_Type -eq "Windows") {
		writeLog("executing Windows Script $Script_Path.")
		. $vBoxManage guestcontrol $vmName run c:\LocalDropbox\$Script_Path $testName $vmName --username $VMUN --password $VMPW
	} ElseIf ($OS_Type -eq "Linux") {
		#Perform the Linux equivalent
		. $vBoxManage guestcontrol $vmName run /bin/bash /LocalDropbox/$Script_Path $testName $vmName --username $VMUN --password $VMPW
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
	if ($OS_Type -eq "Windows") {
		writeLog("executing Windows TestCase Script $Script_Path.")
		. $vBoxManage guestcontrol $vmName run c:\LocalDropbox\execute_testcase.bat $testName $vmName $testcase_name $Script_Path --username $VMUN --password $VMPW --timeout $task_timeout
	} ElseIf ($OS_Type -eq "Linux") {
		#Perform the Linux equivalent
		. $vBoxManage guestcontrol $vmName run /bin/bash /LocalDropbox/execute_testcase.sh $testName $vmName $testcase_name $Script_Path --username $VMUN --password $VMPW --timeout $task_timeout
	} Elseif ($OS_Type -eq "Android") {
		# Use ADB to execute files
	} Else {
		#No OP
		WriteLog("No OS_Type-($OS_Type) was found to execute the files")
		$AgentStatus = $False
		return $AgentStatus
	}
}