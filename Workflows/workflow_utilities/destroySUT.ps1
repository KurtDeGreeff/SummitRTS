#=======================================================================================
# Purpose: Destroying a 'System Under Test'
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

$vmName = $SUTname

# Enables all of the needed cmdlets
. "$SCRIPTDIR\..\..\Hypervisor-cmdlets\$hypervisor_Type\hypervisor-cmdlets.ps1"

#=======================================================================================
# User Arguments
#=======================================================================================
$MAXWAITSECS = 60 * 3
$TOOLSWAIT = 60 * 6
$VCcenterCONN = $Null
$AgentStatus = $true

#=======================================================================================
# Echo a line about starting the test
writeLog("Starting Testcase ID ${testcase_ID} for test: ${testName} on SUT: ${vmName}")
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

####################################
# Start Of SUT Destruction
####################################

# Echo a line about starting the test
writeLog("Starting DestroySUT for test: ${testName} on SUT : ${SUTname}")

# Start a loop that we can break out of if needed
if ($AgentStatus = $true) {
	# Connect to the Vcenter or server
	if ($hypervisor_Type -eq "vSphere"){
	writeLog("ConnectVcenter is attaching to vcenter ${Vcenter}.")
		if(! $DEVICECONN -and ! ($DEVICECONN = ConnectVcenter)) {
			writeLog("ConnectVcenter ${Vcenter} Failed.")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}
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
	if ($hypervisor_Type -eq "vSphere"){
		writeLog("DeleteVm is deleting the SUT VM")
		if (! (DeleteVm $vmName)) {
			writeLog("${vmName} failed to delete.")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}
	} elseif ($hypervisor_Type -eq "vBox") {
		DeleteVm $vmName
	} elseif ($hypervisor_Type -eq "vmwks") {
		DeleteVm $VMX_Path
	}

	# wait  seconds
	writeLog ("Pausing 3 seconds")
	pause 3
	
	# Disconnect from vCenter
	if ($hypervisor_Type -eq "vSphere"){
		writeLog("DisconnetVC is dropping the connection to vcenter ${Vcenter}.")
		if (! (DisconnetVC $DEVICECONN)) {
			writeLog("DisconnetVC ${Vcenter} Failed.")
		}
	}
}
writeLog("DestroySUT Agent status is ${AgentStatus}")
return $AgentStatus
####################################
# End Of SUT Destruction
####################################