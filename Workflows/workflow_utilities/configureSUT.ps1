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

# Other Args
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
# Echo a line about starting the test
writeLog("Starting Configure_SUT for test: ${testName}")
writeLog("The SUTname for this test is : ${SUTname}")
writeLog("The Template_VM used for this test is ${TemplateName}")

#Function to Grab the Template username and password
$query = "select * from template_vm_information where Easy_Name like '$TemplateName'"
$TemplateVMData = @(RunSQLCommand $query)
$OS_Type = $TemplateVMData.OS_Type
$Tools_Available = $TemplateVMData.Tools_Available
writeLog("Template OS_Type is : $OS_Type")
writeLog("Template Tools_Available is : $Tools_Available")

####################################
# Start Of SUT Configuration
####################################

# Echo a line about starting the test
writeLog("Starting SUT Configuration for test: ${testName} on Template VM : ${vmName}")
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
	
	# Ensure the Template VM is not powered on
	writeLog("ShutdownVm is shutting down the Template VM. Not waiting for more than ${MAXWAITSECS} seconds.")
	if (! (ShutdownVm $vmName $MAXWAITSECS)) {
		writeLog("StopVM is forcing a shutdown on the Template VM. Notwaiting for more than ${MAXWAITSECS} seconds.")
		if (! (StopVm $vmName $MAXWAITSECS)) {
			writeLog("${vmName} StopVm Failed. Unable to shutdown VM.")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}
	}
	
	# wait 3 seconds
	writeLog ("Pausing 3 seconds")
	pause 3
	
	# Clone the Template VM
	writeLog("CloneVM is creating a clone of the Template VM")
	$vmClone = $SUTname
	if (! (CloneVM $vmName $vmClone)) {
		writeLog("${vmName} failed to Clone.")
		$AgentStatus = $False
		return $AgentStatus
		Break
	}
	$vmName = $vmClone
	writeLog("Reset the SUT name to ${vmName} to simplify scripts.")
	
	# wait 3 seconds
	writeLog ("Pausing 3 seconds")
	pause 3
	
	# Change a Vm from Non-Persistent to Persistent
	writeLog("SetHardDisk is setting disk to Persistent. Waiting no more than ${MAXWAITSECS} seconds.")
	if (! (SetHardDisk "Persistent" $vmClone $MAXWAITSECS)) {
		writeLog("${vmName} SetHardDisk failed. Unable to set Hard disk to Persistent.")
		$AgentStatus = $False
		return $AgentStatus
		Break
	}
	
	# wait 3 seconds
	writeLog ("Pausing 3 seconds")
	pause 3
	
	# Power on the Cloned VM
	writeLog("StartVM is powering on the SUT VM")
	if (! (StartVM $vmName)) {
		writeLog("${vmName} failed to power on.")
		$AgentStatus = $False
		return $AgentStatus
		Break
	}
	
	# wait 3 seconds
	writeLog ("Pausing 3 seconds")
	pause 3
	
	# Wait for Power
	writeLog("WaitForPower. Waiting no more than ${MAXWAITSECS} seconds.")
	if(! (WaitForPower $vmName $MAXWAITSECS)) {
		writeLog("${vmName} WaitForPower Failed. VMTools failed to respond. ")
		$AgentStatus = $False
		return $AgentStatus
		Break
	}
	
	# wait 3 seconds
	writeLog ("Pausing 3 seconds")
	pause 3
	
	# Wait for VMtools to start
	if ($OS_Type -ne "Android") {
		# Android does not currently support VMtools
		writeLog("WaitForTools. Waiting no more than ${TOOLSWAIT} seconds.")
		if(! (WaitForTools $vmName $TOOLSWAIT)) {
			writeLog("${vmName} WaitForTools Failed. VMTools failed to respond. ")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}
	}
	
	if($OS_Type -eq "Android") {
		writeLog("Waiting 60 seconds for Android to power on")
		pause 60
	}
	
	# wait 60 seconds
	writeLog ("Pausing 60 seconds to obtain proper IPaddress")
	pause 60
	
	# Get and write the IPAddress from the vm to the Database
	if($Tools_Available -eq $true){
		writeLog("Querying the Hypervisor for the IP for vm: $vmName")
		if (! (GetIPAddress $vmName)) {
			writeLog("${vmName} failed to get IP Address.")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}
	} elseif($Tools_Available -eq $true){
		writeLog("The vm: $vmname does not have vmtools available.")
	}
		
	# wait 3 seconds
	writeLog ("Pausing 3 seconds")
	pause 3
		
	# Get and write out the Console URL link
	writeLog ("Getting Console URL link to write to log file")
	if (! (GetConsoleUrl $vmName $hypVersion $MAXWAITSECS)) {
		writeLog("${vmName} failed to get URL.")
		$AgentStatus = $False
		return $AgentStatus
		Break
	}
	
	# wait 3 seconds
	writeLog ("Pausing 3 seconds")
	pause 3
}
writeLog("ConfigureSUT Agent status is ${AgentStatus}")
return $AgentStatus
####################################
# End Of SUT Configuration
####################################