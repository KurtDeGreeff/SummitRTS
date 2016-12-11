#=======================================================================================
# Purpose: Support routines for various Automated VirtualBox tasks
#=======================================================================================
# This will remove the need to keep clicking R
set-ExecutionPolicy Bypass

# Enables all of the needed cmdlets
writeLog("Root Execution directory is '${SCRIPTDIR}'")

#=======================================================================================
# Set the path for vmRun.exe
$vmRun = "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"

#=======================================================================================
function ShutdownVm($VMX_Path, $maxWaitTimeInSecs=$MAXWAITSECS) {
	. $vmRun stop $VMX_Path 
	return $true
}

#=======================================================================================
function DeleteVm($VMX_Path, $maxWaitTimeInSecs=$MAXWAITSECS) {
	# Permanently delete the Vm
	. $vmRun deleteVM $VMX_Path 
}

#=======================================================================================
function CloneVM($VMX_Path, $Clone_VMX_Path) {
	writeLog("The Template vm being used is ${VMX_Path}, and the clone/SUT vm is ${Clone_VMX_Path}")
	writeLog("$vmRun clone $VMX_Path $Clone_VMX_Path full")
	. $vmRun clone $VMX_Path $Clone_VMX_Path full
	start-sleep 30
	writeLog("debug 30 seconds")
	return $True
}

#=======================================================================================
function StartVM($vmName, $VMX_Path) {
	#Start the VM
	. $vmRun start $VMX_Path
	return $True
}
	
#=======================================================================================
function CreateSnapshot($VMX_Path, $maxWaitTimeInSecs=$MAXWAITSECS) {
	#set the Snapshot name
	$SnapshotName = "PostProvision"
	
	#Take a snapshot of the VM
	. $vmRun snapshot $VMX_Path $SnapshotName
	return $True
}

#=======================================================================================
function RevertSnapshot($VMX_Path, $maxWaitTimeInSecs=$MAXWAITSECS) {
	# Revert the Snapshot
	$SnapshotName = "PostProvision"
	#revert the snapshot
	. $vmRun revertToSnapshot $VMX_Path $SnapshotName
	#Start the vm back up
	. $vmRun start $VMX_Path
	return $True
}

#=======================================================================================
function GetIPAddress($VMX_Path) {
	$VMIP = . $vmrun getGuestipaddress $VMX_Path
	writeLog("Adding IP: $VMIP to DB for SUT $vmName")
	$query = "update sut_information set SUT_IPaddress='$VMIP' where SUT_Name = '$vmName'"
	RunSQLCommand $query
	return $True
}