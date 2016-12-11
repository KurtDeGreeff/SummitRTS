#=======================================================================================
# Purpose: Destroying a 'System Under Test'
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
$vmName = $SUTname
# Defaults
$VMUN = "administrator"
$VMPW = "BelayTech2015"
$LogFile = "c:\share\SutResults\$testName\$SUTname\agent.log"
$MAXWAITSECS = 60 * 3
$TOOLSWAIT = 60 * 6
$VCcenterCONN = $Null
$AgentStatus = $true

#=======================================================================================
# Belay Device
#=======================================================================================
#Function to Grab the Template username and password
$query = "select * from template_vm_information where Easy_Name like '$TemplateName'"
$TemplateVMData = @(RunSQLCommand $query)
$OS_Type = $TemplateVMData.OS_Type
writeLog("Template OS_Type is : $OS_Type")
####################################
# Start Of SUT Configuration
####################################

# Echo a line about starting the test
writeLog("Starting DestroySUT for test: ${testName} on VM : ${vmName}")
writeLog("The SUTname for this test is : ${SUTname}")

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
	
	# wait 5 seconds
	writeLog ("Pausing 5 seconds")
	pause 5
	
	# Shutdown the VM
	if ($OS_Type -ne "Android") {
		writeLog("ShutdownVm is shutting down VM. Not waiting for more than ${MAXWAITSECS} seconds.")
		if (! (ShutdownVm $vmName $MAXWAITSECS)) {
			writeLog("StopVM is forcing a shutdown on the VM. Notwaiting for more than ${MAXWAITSECS} seconds.")
			if (! (StopVm $vmName $MAXWAITSECS)) {
				writeLog("${vmName} StopVm Failed. Unable to shutdown VM.")
				$AgentStatus = $False
				return $AgentStatus
				Break
			}
		}
	} elseif($OS_Type -eq "Android") {
		writeLog("ShutdownVm is shutting down VM. Not waiting for more than ${MAXWAITSECS} seconds.")
		if (! (StopVm $vmName $MAXWAITSECS)) {
			writeLog("${vmName} StopVm Failed. Unable to shutdown VM.")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}
	}
	
	# wait 5 seconds
	writeLog ("Pausing 5 seconds")
	pause 5
	
	# Delete the SUT VM
	writeLog("DeleteVm is deleting the SUT VM")
	if (! (DeleteVm $vmName)) {
		writeLog("${vmName} failed to delete.")
		$AgentStatus = $False
		return $AgentStatus
		Break
	}
	
	# wait  seconds
	writeLog ("Pausing 3 seconds")
	pause 3
	
	# Disconnect from vCenter
	writeLog("DisconnetVC is dropping the connection to vcenter ${Vcenter}.")
	if (! (DisconnetVC $DEVICECONN)) {
		writeLog("DisconnetVC ${Vcenter} Failed.")
	}
}
writeLog("DestroySUT Agent status is ${AgentStatus}")
return $AgentStatus
####################################
# End Of SUT Destruction
####################################