#=======================================================================================
#  ____                            _ _   ____ _____ ____  
# / ___| _   _ _ __ ___  _ __ ___ (_) |_|  _ \_   _/ ___| 
# \___ \| | | | '_ ` _ \| '_ ` _ \| | __| |_) || | \___ \ 
#  ___) | |_| | | | | | | | | | | | | |_|  _ < | |  ___) |
# |____/ \__,_|_| |_| |_|_| |_| |_|_|\__|_| \_\|_| |____/ 
#=======================================================================================
# Parameters
Param(
    [Parameter(Mandatory=$True)]
      [string]$testname,
    [Parameter(Mandatory=$False)]
      [string]$xmlDocument,
    [Parameter(Mandatory=$False)]
      [string]$targetServer
)

set-ExecutionPolicy Bypass -Force #wonder if this should be moved to a deployment script.

# Set the Working directory.
$MYINV = $MyInvocation
$SCRIPTDIR = split-path $MYINV.MyCommand.Path
write-host $SCRIPTDIR

# import logging, connection details, and mysql cmdlets.
. "$SCRIPTDIR\..\utilities\general-cmdlets.ps1"
. "$SCRIPTDIR\..\utilities\connection_details.ps1"
. "$SCRIPTDIR\..\utilities\mysql_cmdlets.ps1"
# set log file
$LogFile = "c:\SummitRTS\submitTest\submitTest.log"
# defaults
$DefaulttargetServer = "localhost"
$DefaulXMLDocument = "$SCRIPTDIR\exampleXML.xml"
#Create index counters
$vmCount = 1000

# Set defaults if params are blank
if ($xmlDocument -eq $null){
	writeLog("No xml Document was provided")
	writeLog("Using Default File, '$DefaulXMLDocument'")
	$xmlDocument = $DefaulXMLDocument
}
if ($targetServer -eq $null){
	writeLog("No targetServer was provided")
	writeLog("Using Default targetServer, '$DefaulttargetServer'")
	$targetServer = $DefaulttargetServer
}

#Determine if testname is a duplicate
writeLog("Querying the Database for Duplicate TestNames")
$query = "select * from test_suites where name = '$testname'"
$TestNameData = @(RunSQLCommand $query)
if($TestNameData -ne 0){
	writeLog("We found a duplicate TestName: $testname")
	writeLog("Please submit a Unique TestName")
	BREAK
}

#Import XML
writeLog("Importing the XML Document '$xmlDocument' to begin parsing")
[xml]$xmlData = get-content "$xmlDocument"
$SUTS = $xmldata.Device_TestPlan.sut
#Get the total number of SUT's (added to the DB later)
$SUTCOUNT = $SUTS.count
writeLog("TotalVMs: $SUTCOUNT")

#Enter the Test into the Database with a Status of Submitted and Retrieve Test_ID
writeLog("Entering TestName: $testname and TotalVMs: $SUTCOUNT into the Database")
$query = "INSERT INTO test_suites (Name, Status_ID, Total_SUT) VALUES ('$testname','5',$SUTCOUNT)"
$testSuiteID = @(RunSQLInsert $query)[1] #this will grab the test suite ID
writeLog("TestSuite ID is : $testSuiteID")

#Insert data for each SUT 
foreach($SUT in $SUTS) {
    #SUT info
    # Reset the TestCase count for each SUT
    $testCaseOrder = 0
    #Step up the SUT index
    $vmCount++
    writeLog("SUT Index - $vmcount")
    $CurrentSUT = $SUT.name
    $SUT_Type = $sut.type
    $SUT_Hyp_Type = $sut.Hypervisor_type
    $SUT_Workflow_Type = $SUT.Workflow
    $uniqueSUTName = $testname + $vmCount + $CurrentSUT
    writeLog("The SUT information is ")
    writeLog("Name: $uniqueSUTName, ")
    writeLog("Type: $SUT_Type")
    writeLog("HypervisorType: $SUT_Hyp_Type")
    # Retrieve SUT_Type_ID
    $query = "select ID, Name from SUT_TYPE where Name like '$SUT_Type'"
    $Sut_Type_Data = @(RunSQLCommand $query)
    $SUT_Type_ID = $Sut_Type_Data.ID
    # Retrieve VM_Template_ID
    $Template_Name = $SUT.provision_SUT.template.easy_name
    $query = "select ID, Ref_Name from VM_TEMPLATES where Ref_Name like '$Template_Name'"
    $Template_Data = @(RunSQLCommand $query)
    $VM_Template_ID = $Template_Data.ID
    # Retrieve SUT_Hyp_Type
    $query = "select ID, Name from HYPERVISOR_TYPES where Name like '$SUT_Hyp_Type'"
    $Sut_Hyp_Data = @(RunSQLCommand $query)
    $Hypervisor_Type_ID = $Sut_Hyp_Data.ID
    # Retrieve Workflow_ID
    $query = "select ID, Name from WORKFLOWS where Name like '$SUT_Workflow_Type'"
    $WORKFLOW_Data = @(RunSQLCommand $query)
    $Workflow_ID = $WORKFLOW_Data.ID
    ############################################
    # Enter base SUT into DB and retrieve SUT_ID
    ############################################
      $query = "INSERT INTO SUTs (Name,Status_ID,Test_Suite_ID,VM_Template_ID,Hypervisor_Type_ID,Workflow_ID,SUT_Type_ID,Console_Active,Hypervisor_ID,Agent_Manager_ID,Log_File,IP_Address,Remote_Console_URL) Values('$uniqueSUTName','5','$testSuiteID','$VM_Template_ID','$Hypervisor_Type_ID',  '$Workflow_ID','$SUT_Type_ID','0',99,99,'none_yet','none_yet','none_yet')"
      $SUTInsertID = @(RunSQLInsert $query)[1]
      writeLog("SUT_ID is: $SUTInsertID")
    ############################################
    # provision_SUT
    ############################################
      $testCaseOrder++
      $query = "INSERT INTO TEST_CASES (Name, SUT_ID, Status_ID, Result_ID, Order_Index) VALUES ('provision_SUT', $SUTInsertID, 5, 6, $testCaseOrder)"
      $testCaseID = @(RunSQLInsert $query)[1]
      # Insert Script details for provisioning
      $query = "INSERT INTO TEST_CASE_SCRIPTS (Script_Path, Test_Case_ID, Order_Index) VALUES ('no-script', $testCaseID, 1)"
	    RunSQLCommand $query
    ############################################
    # Configure_SUT
    ############################################
      $testCaseOrder++
      $query = "INSERT INTO TEST_CASES (name, sut_id, status_id, Result_ID, order_index) VALUES ('configure_SUT', $SUTInsertID, 5, 6, $testCaseOrder)"
      $testCaseID = @(RunSQLInsert $query)[1]
      # Insert Script details for Configure_SUT
      $Configure_Script = $sut.configure_SUT.configure_Script.name
      $query = "INSERT INTO TEST_CASE_SCRIPTS (script_path, test_case_id, order_index) VALUES ('$Configure_Script', $testCaseID, 1)"
	    RunSQLCommand $query      
      #Future Software Processing
    ############################################
    #Testcases
    ############################################
      $testcases = $SUT.testcases.testcase
	    foreach($testcase in $testcases) {
          # reset the Testcase_script count for each Testcase
          $testCaseScriptOrder = 0
          $testCaseName = $testcase.name
		      writeLog("Entering Testcase: $testCaseName into the Database")
          $testCaseOrder++
		      # Insert Testcase data into DB
          $query = "INSERT INTO TEST_CASES (name, sut_id, status_id, Result_ID, order_index) VALUES ('$testCaseName', $SUTInsertID, 5, 6, $testCaseOrder)"
		      $testCaseID = @(RunSQLInsert $query)[1]
          $testCaseScripts = $testcase.testcase_scripts.testcase_script
          foreach ($testCaseScript in $testCaseScripts ) {
              $testCaseScriptName = $testCaseScript.name
              writeLog("Entering TestcaseScript: $testCaseScriptName into the Database")
              $testCaseScriptOrder++
              # Insert Testcase Script Data into DB.
		          $query = "INSERT INTO TEST_CASE_SCRIPTS (script_path, test_case_id, order_index) VALUES ('$testCaseScriptName', '$testCaseID', '$testCaseScriptOrder')"
		          RunSQLCommand $query
          }
	    }
    ############################################
    # Destroy SUT Logic
    ############################################
      $testCaseOrder++
      $destroyValue = $sut.destroy_SUT.property
      if ($destroyValue -eq "true"){
          $query = "INSERT INTO TEST_CASES (name, sut_id, status_id, Result_ID, order_index) VALUES ('Destroy_SUT', $SUTInsertID, 5, 6, $testCaseOrder)"
          $testCaseID = @(RunSQLInsert $query)[1]
          # Insert Script details for Destroy_SUT
          $query = "INSERT INTO TEST_CASE_SCRIPTS (script_path, test_case_id, order_index) VALUES ('no-script', $testCaseID, 1)"
	        RunSQLCommand $query
      }
}

# Mark the test as Queued, while leaving the SUT's as submitted. To ensure the Queue Manager 
#   can assign things appropriately.
writeLog("Marking the Test as QUEUED, now that all of the SUT's and testcases have been created.")
$query = "update test_suites set Status_ID='6' Where Name='$testname'"
RunSQLCommand $query
writeLog("==========================================================================")

#=======================================================================================
#    _  _  _____                    ____       _             
#  _| || ||_   _|__  __ _ _ __ ___ | __ )  ___| | __ _ _   _ 
# |_  ..  _|| |/ _ \/ _` | '_ ` _ \|  _ \ / _ \ |/ _` | | | |
# |_      _|| |  __/ (_| | | | | | | |_) |  __/ | (_| | |_| |
#   |_||_|  |_|\___|\__,_|_| |_| |_|____/ \___|_|\__,_|\__, |
#                                                      |___/ 
#=======================================================================================