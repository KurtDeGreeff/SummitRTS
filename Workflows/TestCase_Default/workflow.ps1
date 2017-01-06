#=======================================================================================
#  ____                            _ _   ____ _____ ____  
# / ___| _   _ _ __ ___  _ __ ___ (_) |_|  _ \_   _/ ___| 
# \___ \| | | | '_ ` _ \| '_ ` _ \| | __| |_) || | \___ \ 
#  ___) | |_| | | | | | | | | | | | | |_|  _ < | |  ___) |
# |____/ \__,_|_| |_| |_|_| |_| |_|_|\__|_| \_\|_| |____/ 
#=======================================================================================
# System Variables
set-ExecutionPolicy Bypass -Force

$MYINV = $MyInvocation
$SCRIPTDIR = split-path $MYINV.MyCommand.Path

# import logging, connection details, and mysql cmdlets.
. "$SCRIPTDIR\..\..\utilities\general-cmdlets.ps1"
. "$SCRIPTDIR\..\..\utilities\connection_details.ps1"
. "$SCRIPTDIR\..\..\utilities\mysql_cmdlets.ps1"

# Set Shell Title
$host.ui.RawUI.WindowTitle = "SummitRTS Tescase Default Workflow"
#=======================================================================================
# Script Arguments
#=======================================================================================
# The manager Requires the following items to get started properly
$SUT_ID=$args[0]
$sutName=$args[1]
$SharedDrive=$args[2]
# Set the log file for the Manager.
Write-Host "Just print something to the screen, sutid: $SUT_ID sutname: $sutName"
write-host "$SUT_ID"
write-host "$sutName"
write-host "$SharedDrive"

#=======================================================================================
# Mark the SUT as Running and Begin test.
$query = "update suts set Status_ID='8' where ID = '$SUT_ID'"
RunSQLCommand $query

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
			ht.Name as Hypervisor_Type,
			st.Name as SUT_Type
		from SUTs sut
		join TEST_SUITES ts on sut.Test_Suite_ID=ts.ID
		join VM_TEMPLATES vt on sut.VM_Template_ID=vt.ID
		join HYPERVISOR_TYPES ht on sut.Hypervisor_Type_ID=ht.ID
		join SUT_TYPE st on sut.SUT_Type_ID=st.ID
        where sut.ID like $SUT_ID;"
$sutData = @(RunSQLCommand $query)
$testname = $sutData.testname
$hypervisor_Type = $sutData.Hypervisor_Type
$templateName = $sutData.Ref_Name
#=======================================================================================
# Create the Result directory for the SUTname
New-Item "$SharedDrive\SutResults\$testName\$sutName" -type directory
# Create the SUT-Workflow log file
$LogFile = "$SharedDrive\SutResults\$testName\$sutName\workflow.log"
#=======================================================================================
writeLog("Information the Agent needs to run the test")
writeLog("----------------------")
writeLog("SUT_ID: $sut_ID")
writeLog("SutName: $sutName")
writeLog("Testname: $testname")
writeLog("hypervisor Type: $hypervisor_Type")
writeLog("templateName: $templateName")
writeLog("----------------------")
#=======================================================================================
# Insert Full Agent Logfile Path into DB (SUT_Information)
$AgentLogPath = $LogFile.Replace('\',"\\")
writeLog("Writing AgentLog '$AgentLogPath' to the Database")
$query = "update suts set Log_File='$AgentLogPath' where Name = '$sutName'"
RunSQLCommand $query

#=======================================================================================
# Get all properties for test and write properties.txt file
writeLog("Starting sub-process to create Properties.txt file")
. "${SCRIPTDIR}\writeProperties.ps1" $testName $sutName $LogFile $SharedDrive

#=======================================================================================
# Query Database Testcases table for the SUT, and run each Testcase:
# Make a collection of the testcases
$query = "select ID, Name, Order_Index from test_cases where SUT_ID like $sut_ID order by Order_Index"
$testcaseData = @(RunSQLCommand $query)
foreach($row in $testcaseData) {
    $testcase_name = $row.Name
    $testcase_ID = $row.ID
	if ($testcase_name -eq "Destroy_SUT") {
		writeLog("Testcase is DestroySUT Exiting Testcase loop")
		writeLog("$testcase_name")
		writeLog("$testcase_script")
		break
	} 

	# Determine if the SUT/Testcase has been Aborted, if so break to DestroySUT
	$query = "select Result_ID from test_cases where SUT_ID = '$sut_ID' and ID = '$testcase_ID'"
	$TestCaseResultdata = @(RunSQLCommand $query)
	$testcase_result = $TestCaseResultdata.Result_ID
	if ($testcase_result -eq "5") {
		writeLog("The SUT has been aborted, ending test and destroying SUT")
		break
	}
	# Execute the SUT Provisioning Phase
	ElseIf ($testcase_name -eq "provision_SUT") {
		writeLog("----------")
		writeLog("Testcase is Provisioning")
		writeLog("$testcase_name")
		#Update Testcase table (update Configure SUT row, mark it as running)
		$query = "update test_cases set Status_ID='8' where ID = '$testcase_ID'"
		RunSQLCommand $query
		#Kick off subprocess to Provision SUT
		if (! (. "${SCRIPTDIR}\..\workflow_utilities\provisionSUT.ps1" $testName $SUTname $hypervisor_Type $LogFile $testcase_ID)) {
			writeLog("Something failed during Provisioning, we should destroy node now.")
			$query = "update test_cases set Status_ID='9', Result_ID='4' where ID = '$testcase_ID'"
			RunSQLCommand $query
			#Mark all of the other SUT testcases as COMPLETE, Not_Run
			$query = "update test_cases set Status_ID='9', Result_ID='5' where SUT_ID = '$sut_ID' and name not like 'Provisioning'"
			RunSQLCommand $query
			writeLog("----------")
			#Break to Destroy_SUT
			Break
		} Else {
			writeLog("Provisioning COMPLETED!")
			#update the Testcase table (update Provision SUT row, mark it as COMPLETE)
			$query = "update test_cases set Status_ID='9', Result_ID='1' where ID = '$testcase_ID'"
			RunSQLCommand $query
            #Determine if the SUT passed the Configuration phase.
			$query = "select * from test_cases where ID = '$testcase_ID'"
			$ProvisioningData = @(RunSQLCommand $query)
			$ProvisioningResult = $ProvisioningData.Result_ID
			writeLog("The Provisioning result is $ProvisioningResult")
			if ($ProvisioningResult -ne "1") {
				writeLog("-----------------------------")
				writeLog("The SUT did not pass provisioning")
				writeLog("Not running any test cases, Lets destroy the SUT")
				writeLog("-----------------------------")
				Break
			}
			writeLog("The SUT passed provisioning, moving on!")
			# Update the SUT table (Deactivate Console URL)
			if ($hypervisor_Type -eq "vSphere"){
				writeLog("Activating the Console URL for SUT on Hypervisor: $hypervisor_Type")
				$query = "update suts set Console_Active='1' where ID = '$sut_ID'"
				RunSQLCommand $query
				writeLog("The SUT passed provision_SUT phase, moving on!")
				writeLog("----------")
			} else {
				writeLog("Not activating Console URL for SUT on Hypervisor : $hypervisor_Type")
				writeLog("The SUT passed provision_SUT phase, moving on!")
				writeLog("----------")					
			}
		}
	}
    # SUT Configuration
	ElseIf ($testcase_name -eq "configure_SUT") {
		writeLog("----------")
		writeLog("Testcase is SUT_Configuration, Configuring VM")
		writeLog("TestCase Name - $testcase_name")
		#Update Testcase table (update Configure SUT row, mark it as running)
		$query = "update test_cases set Status_ID='8' where ID = '$testcase_ID'"
		RunSQLCommand $query
		#Kick off subprocess to Configure SUT and check return code
		if (! (. "${SCRIPTDIR}\..\workflow_utilities\configureSUT.ps1" $testName $SUTname $hypervisor_Type $LogFile $testcase_ID)) {
			writeLog("Something failed during configuration, we should destroy the SUT now.")
			#update the Testcase table (update Configure SUT row, mark it as COMPLETE, fail)
			$query = "update test_cases set Status_ID='9', Result_ID='4' where ID = '$testcase_ID'"
			RunSQLCommand $query
			#Mark all of the other SUT testcases as COMPLETE, Not_Run
			$query = "update test_cases set Status_ID='9', Result_ID='5' where SUT_ID = '$sut_ID' and Status_ID not like '9'"
			RunSQLCommand $query
			writeLog("----------")
			#Break to Destroy SUT
			Break
		} Else {
			writeLog("SUT_Configuration COMPLETED!")
			#update the Testcase table (update Configure SUT row, mark it as COMPLETE, pass)
			$query = "update test_cases set Status_ID='9', Result_ID='1' where ID = '$testcase_ID'"
			RunSQLCommand $query
			#Determine if the SUT passed Configure_SUT phase
			$query = "select * from test_cases where ID = '$testcase_ID'"
			$ConfigureSUTData = @(RunSQLCommand $query)
			$ConfigureSUTResult = $ConfigureSUTData.Result_ID
			writeLog("The Configure_SUT result is $ConfigureSUTResult")
			if ($ConfigureSUTResult -ne "1") {
				writeLog("-----------------------------")
				writeLog("The SUT did not pass Configure_SUT Phase")
				writeLog("Not running any test cases, Lets destroy the SUT")
				$query = "update test_cases set Status_ID='9', Result_ID='2' where ID = '$testcase_ID'"
				RunSQLCommand $query
				writeLog("-----------------------------")
				Break
			}
            writeLog("----------")
		}
	}
    # Iterate through all of the Testcases
	Else {
		writeLog("----------")
		writeLog("this must be a normal testcase")
		writeLog("$testcase_name")
		#Update Testcase table (update Testcase row, mark it as running)
		$query = "update test_cases set Status_ID='8' where ID = '$testcase_ID'"
		RunSQLCommand $query
		#Kick off subprocess to Execute_Testcase and get return code
		if (! (. "${SCRIPTDIR}\..\workflow_utilities\testCaseExecutioner.ps1" $testName $SUTname $hypervisor_Type $LogFile $Testcase_Id $testcase_name)) {
			writeLog("Something failed during the Testcase, we should destroy SUT now.")
			#update the Testcase table (update Provision SUT row, mark it as COMPLETE, fail)
			$query = "update test_cases set Status_ID='9', Result_ID='4' where ID = '$testcase_ID'"
			RunSQLCommand $query
			#Mark all of the other SUT testcases as COMPLETE, Not_Run
			$query = "update test_cases set Status_ID='9', Result_ID='5' where SUT_ID = '$sut_ID' and Result_ID = '6'"
			RunSQLCommand $query
			writeLog("----------")
			# Break to DestroySUT
			Break
		} Else {
			writeLog("Testcase COMPLETED!")
			#update the Testcase table (update Provision SUT row, mark it as COMPLETE)
			$query = "update test_cases set Status_ID='9' where ID = '$testcase_ID'"
			RunSQLCommand $query
			writeLog("moving on!")
			writeLog("----------")
		}
	}
}

#=======================================================================================

####################################
# Start Of SUT Destruction
####################################
writeLog("I made it out of the loop Destroying the vm")
# Update Testcase table (update Destroy_SUT row, mark it as running, no_result)
$query = "update test_cases set Status_ID='8' where Name='Destroy_SUT' and SUT_ID = '$sut_ID'"
RunSQLCommand $query
# Update the SUT table (Deactivate Console URL)
$query = "update suts set Console_Active='0' where ID = '$sut_ID'"
RunSQLCommand $query
# Kick off subprocess to Destroy_SUT

if (! (. "${SCRIPTDIR}\..\workflow_utilities\destroySUT.ps1" $testName $SUTname $hypervisor_Type $LogFile)) {

	writeLog("Something failed when destroying the VM, Crap!")
	#update the Testcase table (update Destroy_SUT row, mark it as COMPLETE, fail)
	$query = "update test_cases set Status_ID='9', Result_ID='2' where Name='DestroySUT' and SUT_ID = '$sut_ID'"
	RunSQLCommand $query
} Else {
	writeLog("Destroy VM COMPLETED!")
	#update the Testcase table (update Destroy_SUT row, mark it as COMPLETE, pass)
	$query = "update test_cases set Status_ID='9', Result_ID='1' where Name='Destroy_SUT' and SUT_ID = '$sut_ID'"
	RunSQLCommand $query
}
####################################
# End Of SUT Destruction
####################################

#Mark the SUT as COMPLETE and exit.
writeLog("Marking the SUT as COMPLETE and exiting the script")
$query = "update suts set Status_ID='9' where ID = '$sut_ID'"
RunSQLCommand $query

#=======================================================================================
#    _  _  _____                    ____       _             
#  _| || ||_   _|__  __ _ _ __ ___ | __ )  ___| | __ _ _   _ 
# |_  ..  _|| |/ _ \/ _` | '_ ` _ \|  _ \ / _ \ |/ _` | | | |
# |_      _|| |  __/ (_| | | | | | | |_) |  __/ | (_| | |_| |
#   |_||_|  |_|\___|\__,_|_| |_| |_|____/ \___|_|\__,_|\__, |
#                                                      |___/ 
#=======================================================================================