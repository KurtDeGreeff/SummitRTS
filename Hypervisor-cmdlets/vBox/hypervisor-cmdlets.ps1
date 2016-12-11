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

#=======================================================================================
function ShutdownVm($vmName, $maxWaitTimeInSecs=$MAXWAITSECS) {
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
	writeLog("The Template vm being used is ${vmName}, and the clone/SUT vm is ${vmClone}")
	. $vBoxManage clonevm $vmName --name $vmClone --basefolder $DATASTORE
	return $True
}

#=======================================================================================
function RegisterClone($vmName) {
	writeLog("Registering the newly created clone/SUT vm ${vmName}")
	writeLog("Path to new vm is '$$DATASTORE\$vmName\$vmName.vbox'")
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
	return $True
}

#=======================================================================================
function GetIPAddress($vmName) {
	$myvar = . $vBoxManage guestproperty enumerate $vmName --patterns "*/IP"
	$myarray = $myvar -split ' '
	$VMIP = $myarray[3]
	$VMIP = $VMIP.Substring(0,$VMIP.Length-1)
	writeLog("Adding IP: $VMIP to DB for SUT $vmName")
	$query = "update sut_information set SUT_IPaddress='$VMIP' where SUT_Name = '$vmName'"
	RunSQLCommand $query
	return $True
}