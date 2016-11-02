#=======================================================================================
#  ____                            _ _   ____ _____ ____  
# / ___| _   _ _ __ ___  _ __ ___ (_) |_|  _ \_   _/ ___| 
# \___ \| | | | '_ ` _ \| '_ ` _ \| | __| |_) || | \___ \ 
#  ___) | |_| | | | | | | | | | | | | |_|  _ < | |  ___) |
# |____/ \__,_|_| |_| |_|_| |_| |_|_|\__|_| \_\|_| |____/ 
#=======================================================================================
# Cmdlets for Aborting SUT's
#=======================================================================================
function AbortTests ($AbortTestStatus){
	writeLog("This line represents Aborting all SUT's where the SUT_Status is not 'COMPLETE' and the Test_Status is '$AbortTestStatus'")
	#Query DB, if any test is set to $AbortTestStatus we need to find all of the related SUT's and Testcases, set them to COMPLETE/Aborted
	$query = "select * from test_suites where Status_ID = '$AbortTestStatus'"
	$QueryCountData = @(RunSQLCommand $query)
	$QueryCount = $QueryCountData.count
	#Overall tests (if Empty, move on)
	if($QueryCount -ne 0) {
		writeLog("The Manager found ${QueryCount} tests that need to be aborted.")
		$query = "select ID,Name,Status_ID from test_suites where Status_ID = '$AbortTestStatus'"
		$RUNNINGTests = @(RunSQLCommand $query)
		foreach($RUNNINGTest in $RUNNINGTests){
			$testName = $RUNNINGTest.Name
			$testID = $RUNNINGTest.ID
			writeLog("The Manager is Searching for SUT's that are not 'COMPLETE' and that belong to test :${testName}")
			#Get any SUT's that are not in a 'COMPLETE' state
			$query = "Select * from suts where Test_Suite_ID = '$testID' and Status_ID != 9"
			$RUNNINGSUTs = @(RunSQLCommand $query)
			#TestCases
			if($RUNNINGSUTs -ne ""){
				foreach($RUNNINGSUT in $RUNNINGSUTs){
					$SUTname = $RUNNINGSUT.Name
					$SUTID = $RUNNINGSUT.ID
					AbortSingleSUT $SUTID $SUTname $testID $testName
				}
			}
			writeLog("The Manager has Aborted all RUNNING SUT's that belong to test :${testName}")
			#Set the overall test to COMPLETE.
			$query = "update test_suites set Status_ID=9 where ID = $testID"
			RunSQLCommand $query
		}
		writeLog("The Manager has No more tests to Abort.")
	}
}

#=======================================================================================
function AbortNotCOMPLETESUTs{
	writeLog("This line represents Aborting any SUTs not 'COMPLETE' with a ANY Test_Status")
	$query = "Select * from SUTs where Status_ID != 9 and Status_ID != 6"
	$RUNNINGSUTs = @(RunSQLCommand $query)
	#TestCases
	if($RUNNINGSUTs -ne ""){
		foreach($RUNNINGSUT in $RUNNINGSUTs){
			$SUTname = $RUNNINGSUT.Name
			$SUTID = $RUNNINGSUT.ID
			$testID = $RUNNINGSUT.Test_Suite_ID
			$query = "select name from test_suites where ID= $testID"
			$testNameData = @(RunSQLCommand $query)
			$testName = $testNameData.Name
			AbortSingleSUT $SUTID $SUTname $testID $testName
		}
	}
}

#=======================================================================================
function AbortCANCELLEDSUTs{
	writeLog("This line represents Aborting any SUTs with the SUT_Status of 'CANCELLED'")
	$query = "Select * from suts where Status_ID = 10"
	$RUNNINGSUTs = @(RunSQLCommand $query)
	#TestCases
	if($RUNNINGSUTs -ne ""){
		foreach($RUNNINGSUT in $RUNNINGSUTs){
			$SUTname = $RUNNINGSUT.SUT_Name
			$SUTID = $RUNNINGSUT.ID
			$testID = $RUNNINGSUT.Test_Suite_ID
			$query = "select name from test_suites where ID= $testID"
			$testNameData = @(RunSQLCommand $query)
			$testName = $testNameData.Name
			AbortSingleSUT $SUTID $SUTname $testID $testName
		}
	}
}

#=======================================================================================
function AbortNotCompleteTestcases {
	# In the even the system was not shut down correctly, we should ensure there are not lingering test cases.
	writeLog("The Manager is Aborting non-complete testcases.")
	$query = "update test_cases set Status_ID=9, Result_ID=5 where (Status_ID like 8 or Status_ID like 10 or Status_ID like 7)"
	RunSQLCommand $query
}

#=======================================================================================
function AbortSingleSUT ($SUTID, $SUTname, $testID, $testName)  {
	writeLog("The Manager is Aborting SUT: ${SUTname} that belongs to test: ${testName}")
	#Update any Not Complete Testcases for the SUT to Aborted
	$query = "update test_cases set Status_ID=9, Result_ID=5 where SUT_ID = $SUTID and Status_ID not like 9"
	RunSQLCommand $query
	#Update the SUT to Aborted
	$query = "update suts set Status_ID=9 where ID = $SUTID"
	RunSQLCommand $query
}

#=======================================================================================
function FinishCompletedTests {
	writeLog("This line represents marking a Test as complete when all SUT's are COMPLETE")
	# Get a list of running Tests
	$query = "select ID,Name from test_suites where Status_ID like 8"
	$RunningTestData = @(RunSQLCommand $query)
	foreach($RunningTestName in $RunningTestData) {
		$ActiveTestName = $RunningTestName.Name
		$ActiveTestID = $RunningTestName.ID
		#Determine if the Test has any running SUT's
		writeLog("Determining if test : '$ActiveTestName' is complete")
		$query = "select * from suts where Test_Suite_ID like '$ActiveTestID' and Status_ID not like 9"
		$RunningSUTData = @(RunSQLCommand $query)
		$RunningSUTDataCount = $RunningSUTData.count
		if ($RunningSUTDataCount -eq 0) {
			# If the test has no running SUT's, mark the test as complete.
			writeLog("This test '$ActiveTestName' is Now complete")
			$query = "update test_suites set Status_ID=9 where ID = '$ActiveTestID'"
			RunSQLCommand $query
		}
	}
}
#=======================================================================================
function ReviewRunningTests(){
	writeLog("Reviewing Running tests for Non-Queued SUTs")
	# Query DB for all running test ID's
	$query = "select id from test_suites where Status_ID = 8"
	$RunningTestsData = @(RunSQLCommand $query)
	if ($RunningTestsData.Count -ne 0) {
		foreach ($RunningTest in $RunningTestsData){
			$RunningTestSuiteID = $RunningTest.id 
			# Determine if the test has a Persistent SUT
			$query = "select ID,Status_ID,SUT_Type_ID from suts where SUT_Type_ID = 2 and Test_Suite_ID = $RunningTestSuiteID"
			$RunningTestsPersistentSutData = @(RunSQLCommand $query)
			if ($RunningTestsPersistentSutData -ne 0){
				writeLog("We found Persistent SUTs, lets check thier status!")
				# Check the status of each persistent SUT, if its not waiting on persistent, do nothing at this time.
				foreach($PersistentSUT in $RunningTestsPersistentSutData) {
					$PersistentSutStatus = $PersistentSUT.Status_ID
					if ($PersistentSutStatus -eq 14) {
						$QueueTransient = "True"
					} elseif ($PersistentSutStatus -eq 8){
						writeLog("A persisent SUT is still running")
						$QueueTransient = "False"
					} elseif ($PersistentSutStatus -eq 6){
						writeLog("A persisent SUT is still Queued")
						$QueueTransient = "False"
					} else {
						# The Persistent SUT is not in a status we expected. Abort the test MEOW!
						writeLog("The persistent SUT status is: '$PersistentSutStatus' We cannot process this Aborting test.")
						$query = "update test_suites set Status_ID = 10 where ID = $RunningTestSuiteID"
						RunSQLCommand $query
					}
				}
				if ($QueueTransient -eq "True"){
					# Queue all submitted SUT's that are waiting on a Persistent SUT.
					writeLog("All Persistent SUT's are waiting, Updating Transient SUT's to queued")
					$query = "update suts set Status_ID = 6 where Test_Suite_ID = $RunningTestSuiteID and SUT_Type_ID not like 2 and Status_ID = 13"
					RunSQLCommand $query
				} else {
					# A persistent SUT was still running, do nothing this time.
					writeLog("At least 1 persistent node was running on test id: $RunningTestSuiteID we will check again soon.")
				}		
			} else {
				# If the test does not have a Persistent SUT, do nothing, all Transient SUT's should be queued.
				writeLog("This test does not have a persisent SUT Test_Suite_ID:$RunningTestSuiteID")
			}
		}
	} else {
		# No Running Tests were found.
		writeLog("No Running Tests were found")
	}
	writeLog("Finished reviewing Running tests function.")
}

#=======================================================================================
function ReviewQueuedTest() {
	writeLog("Reviewing Queued tests")
	# Query DB for all Queued test ID's
	$query = "select id from test_suites where Status_ID = 6"
	$QueuedTestsData = @(RunSQLCommand $query)
	if ($QueuedTestsData.Count -ne 0) {
		foreach ($QueuedTest in $QueuedTestsData){
			$QueuedTestSuiteID = $QueuedTest.id 
			# Determine if the test has a Persistent SUT
			$query = "select ID,Status_ID,SUT_Type_ID from suts where SUT_Type_ID = 2 and Test_Suite_ID = $QueuedTestSuiteID"
			$QueuedTestPersistentSutData = @(RunSQLCommand $query)
			if ($QueuedTestPersistentSutData -ne 0){
				writeLog("We found Persistent SUTs, lets Queue them.")
				# Mark each persistent SUT as queued.
				foreach($PersistentSUT in $QueuedTestPersistentSutData) {
					$PersistentSUTID = $PersistentSUT.ID
					writeLog("Setting Persistent SUT id : $PersistentSUTID to Queued")
					$query = "update suts set Status_ID = 6 where id = $PersistentSUTID"
					RunSQLCommand $query
				}
				# Update the Tranisent SUT's to Waiting on Persistent
				writeLog("Updating the Tranisent SUT's status to Waiting on Persistent")
				$query = "update suts set Status_ID = 13 where SUT_Type_ID = 1 and Test_Suite_ID = $QueuedTestSuiteID"
				RunSQLCommand $query
			} else {
				# If the test does not have a persistent SUT, just Queue all of the Transient SUT's.
				writeLog("The test id: $QueuedTestSuiteID does not have any Persistent SUTs, Marking all SUTs to Queued.")
				$query = "update suts set Status_ID = 6 where Test_Suite_ID = $QueuedTestSuiteID"
				RunSQLCommand $query
			}
			# Set the Overall Test to Running
			writeLog("Now that an SUT is queued, we are marking the test as Running.")
			$query = "update test_suites set Status_ID = 8 where ID = $QueuedTestSuiteID"
			RunSQLCommand $query
		}
	} else {
		# No Queued tests were found.
		writeLog("No Queued Tests were found")
	}
	writeLog("Finished reviewing Queued tests function.")
}

#=======================================================================================
function AssignQueuedSUTs() {
#Get a list of all of the Queued SUT's
#foreach
#  Are any agent_mgrs below the MAX that can run the Available workflow? (Agent_mgr + Hypervisor_Type/IP + Workflow) and enabled status.
#  is the hypervisor active?
#  Is the hypervisor maxed?
#  Does that hypervisor have the template available?
#  if all yes, Assign the SUT.


# or do I want to do it based on Hypervisor availability?

}

#=======================================================================================
#    _  _  _____                    ____       _             
#  _| || ||_   _|__  __ _ _ __ ___ | __ )  ___| | __ _ _   _ 
# |_  ..  _|| |/ _ \/ _` | '_ ` _ \|  _ \ / _ \ |/ _` | | | |
# |_      _|| |  __/ (_| | | | | | | |_) |  __/ | (_| | |_| |
#   |_||_|  |_|\___|\__,_|_| |_| |_|____/ \___|_|\__,_|\__, |
#                                                      |___/ 
#=======================================================================================