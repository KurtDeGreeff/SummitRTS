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
#    _  _  _____                    ____       _             
#  _| || ||_   _|__  __ _ _ __ ___ | __ )  ___| | __ _ _   _ 
# |_  ..  _|| |/ _ \/ _` | '_ ` _ \|  _ \ / _ \ |/ _` | | | |
# |_      _|| |  __/ (_| | | | | | | |_) |  __/ | (_| | |_| |
#   |_||_|  |_|\___|\__,_|_| |_| |_|____/ \___|_|\__,_|\__, |
#                                                      |___/ 
#=======================================================================================