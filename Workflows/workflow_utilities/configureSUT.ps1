#=======================================================================================
# Purpose: Perform Post Provisioning steps to configure SUT for testing.
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
$testcase_ID=$args[4]

$vmName = $SUTname
$testcase_name = "SUT_Configuration"

# Enables all of the needed Hypervisor cmdlets
. "$SCRIPTDIR\..\..\Hypervisor-cmdlets\$hypervisor_Type\hypervisor-cmdlets.ps1"
. "$SCRIPTDIR\..\workflow_utilities\workflow-cmdlets.ps1"

#=======================================================================================
# User Arguments
#=======================================================================================
$MAXWAITSECS = 60 * 3
$TOOLSWAIT = 60 * 6
$VCcenterCONN = $Null
$AgentStatus = $true

#=======================================================================================

# Echo a line about starting the test
writeLog("Starting SUT Configuration for test: ${testName}")
writeLog("The SUTname for this test is : ${SUTname}")

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
			vt.OS_User_Name,
			vt.OS_User_PWD,
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
$VMUN = $sutData.OS_User_Name
$VMPW = $sutData.OS_User_PWD
#=======================================================================================
####################################
# Base SUT Configuration
####################################
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

	# Copy the files to the Target vm that will be run from the Host server
	writeLog ("Copying Specify Files to the VM.")
	#Determine OS_Type to run OS specific command
	if (! (CopyFilestoSUT $vmName, $VMUN, $VMPW)) {
		writeLog("${vmName} Copying files to SUT Failed.")
		$AgentStatus = $False
		return $AgentStatus
		Break
	}


# Get Testcase script information
$query = "select * from test_case_scripts where Test_Case_ID like $testcase_ID order by Order_Index"
$testcasescriptdata = @(RunSQLCommand $query)
$counter = 0
# create a loop to iterate through each of the testcases scripts.
do {
	if ($AgentStatus = $true) {
		##########################################
		# Run User specified Configuration Scripts
		##########################################
		$TestcaseScript_ID = $testcasescriptdata[$counter].ID
		$Script_Path = $testcasescriptdata[$counter].Script_Path
		$Order_Index = $testcasescriptdata[$counter].Order_Index

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
		# wait 3 seconds
		writeLog ("Pausing 3 seconds")
		pause 3

		# Run Configuration script
		writeLog ("Running $Script_Path")
		#Determine OS_Type to run OS specific command
		if (! (ExecuteSUTScript $vmName, $VMUN, $VMPW, $Script_Path)) {
			writeLog("${vmName} Running the specified Script $Script_Path Failed.")
			$AgentStatus = $False
			return $AgentStatus
			Break
		}	

	}
	$counter++
} while ($counter -lt $testcasescriptdata.count)

# Add Logfile paths to the Database
writeLog("Add Logfile paths to the Database")
AddSUTLogFilesToDB $Testcase_Id $testName $vmName $testcase_name

# Determine Pass/Fail by searching for a result string in the Test's log file.
writeLog("Determine Pass/Fail by searching for a result string in the Test's log file.")
$filename = "c:\share\SutResults\${testName}\${vmName}\${testcase_name}\result.log"
$SearchStringPass = "PROVISIONING_PASSED"
$SelPASS = select-string -pattern $SearchStringPass -path $FileName
$SearchStringFail = "PROVISIONING_FAILED"
$SelFAIL = select-string -pattern $SearchStringFail -path $FileName
if ($SelFAIL -ne $null) {
	$query = "update test_cases set Status_ID='9', Result_ID='2' where ID like $testcase_ID"
	RunSQLCommand $query
	writeLog("Provisioning has Failed, We found a failure string in result.log")
	$AgentStatus = $False
	Break
}
If ($SelPASS -eq $null)	{
	$query = "update test_cases set Status_ID='9', Result_ID='2' where ID like $testcase_ID"
	RunSQLCommand $query
	writeLog("Provisioning has Failed, We did not find the correct string in result.log")
} Else {
	$query = "update test_cases set Status_ID='9', Result_ID='1' where ID like $testcase_ID"
	RunSQLCommand $query
	writeLog("Provisioning has Passed, We found the correct string in result.log")
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
	
writeLog("configureSUT Agent status is ${AgentStatus}")
return $AgentStatus
####################################
# End Of SUT Provisioning
####################################