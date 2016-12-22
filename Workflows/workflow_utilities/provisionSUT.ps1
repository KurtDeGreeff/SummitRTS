#=======================================================================================
# Purpose: Provision a 'System Under Test'
#=======================================================================================

#=======================================================================================
# System Variables
#=======================================================================================
# This will remove the need to keep clicking R
set-ExecutionPolicy Bypass


#=======================================================================================
# Agent Arguments
#=======================================================================================
$testName=$args[0]
$SUTname=$args[1]
$hypervisor_Type=$args[2]
$LogFile=$args[3]

# Enables all of the needed cmdlets
. "$SCRIPTDIR\..\..\Hypervisor-cmdlets\$hypervisor_Type\hypervisor-cmdlets.ps1"

# Other Args
$MAXWAITSECS = 60 * 3
$TOOLSWAIT = 60 * 6
$VCcenterCONN = $Null
$AgentStatus = $true

#=======================================================================================
# Echo a line about starting the test
writeLog("Starting Configure_SUT for test: ${testName}")
writeLog("The SUTname for this test is : ${SUTname}")
writeLog("The Hyervisor_type used for this test is ${hypervisor_Type}")

#=======================================================================================
# Get All the SUT related items needed to run the workflow
$query = "select sut.ID,
			sut.Name,
			sut.Test_Suite_ID,
			sut.VM_Template_ID,
			sut.Hypervisor_Type_ID,
			sut.Hypervisor_ID,
			sut.SUT_Type_ID,
			sut.date_modified,
			ts.Name as TestName,
			vt.Ref_Name,
			vt.OS_Type,
			ht.Name as Hypervisor_Type,
			h.IP_Address as Hypervisor_IP,
            h.Username,
            h.Password,
            h.version,
            h.Mgmt_IP,
            h.Datacenter,
            h.Datastore,
			st.Name as SUT_Type
		from SUTs sut
		join TEST_SUITES ts on sut.Test_Suite_ID=ts.ID
		join VM_TEMPLATES vt on sut.VM_Template_ID=vt.ID
		join HYPERVISOR_TYPES ht on sut.Hypervisor_Type_ID=ht.ID
		join HYPERVISORS h on sut.Hypervisor_ID=h.ID
		join SUT_TYPE st on sut.SUT_Type_ID=st.ID
        where sut.ID like $SUT_ID;"
$sutData = @(RunSQLCommand $query)
$testname = $sutData.testname
$hyp_IP = $sutData.Hypervisor_IP
$hyp_UN = $sutData.Username
$hyp_PW = $sutData.Password
$hyp_MGR = $sutData.Mgmt_IP
$DATACENTER = $sutData.Datacenter
$DATASTORE = $sutData.Datastore
$hypVersion = $sutData.version
$hypervisor_Type = $sutData.Hypervisor_Type
$templateName = $sutData.Ref_Name
$OS_Type = $sutData.OS_Type
$hypervisor_Id = $sutData.Hypervisor_ID
$VM_Template_ID = $sutData.VM_Template_ID

# Get Tools Available status
$query = "select Tools_Available from hypervisor_vms where Hypervisor_Id like $hypervisor_Id and VM_Template_ID like $VM_Template_ID"
$Tools_Available = (@(RunSQLCommand $query)).tools_available


####################################
# Start Of SUT Configuration
####################################
$vmName = $templateName
$vCenter = $hyp_MGR

# Echo a line about starting the test
writeLog("Starting SUT Configuration for test: ${testName} on Template VM : ${vmName}")
writeLog("The SUTname for this test is : ${SUTname}")

# Start a loop that we can break out of if needed
if ($AgentStatus = $true) {
	# Connect to the vCenter or server
	if ($hypervisor_Type -eq "vSphere"){
		writeLog("ConnectVcenter is attaching to vcenter ${vCenter}.")
		if(! $DEVICECONN -and ! ($DEVICECONN = ConnectVcenter)) {
			writeLog("ConnectVcenter ${vCenter} Failed.")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}
	} else {
		writeLog("Hypervisor_Type is: $hypervisor_Type, not connecting to vCenter.")
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
	if ($hypervisor_Type -eq "vSphere"){
		writeLog("SetHardDisk is setting disk to Persistent. Waiting no more than ${MAXWAITSECS} seconds.")
		if (! (SetHardDisk "Persistent" $vmClone $MAXWAITSECS)) {
			writeLog("${vmName} SetHardDisk failed. Unable to set Hard disk to Persistent.")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}
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
	} elseif($OS_Type -eq "Android") {
		writeLog("Waiting 60 seconds for Android to power on")
		pause 60
	}
	
	# wait 60 seconds
	writeLog ("Pausing 60 seconds to obtain proper IPaddress")
	pause 60
	
	# Get and write the IPAddress from the vm to the Database
	if($Tools_Available -eq 1){
		writeLog("Querying the Hypervisor for the IP for vm: $vmName")
		if (! (GetIPAddress $vmName)) {
			writeLog("${vmName} failed to get IP Address.")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}
	} elseif($Tools_Available -eq 0){
		writeLog("The vm: $vmname does not have vmtools available.")
	}
		
	# wait 3 seconds
	writeLog ("Pausing 3 seconds")
	pause 3
		
	# Get and write out the Console URL link
	if ($hypervisor_Type -eq "vSphere"){
		writeLog ("Getting Console URL link to write to log file")
		if (! (GetConsoleUrl $vmName $hypVersion $MAXWAITSECS)) {
			writeLog("${vmName} failed to get URL.")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}
	} else {
		writeLog("No Console url available for this Hypervisor.")
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