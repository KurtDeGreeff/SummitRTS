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
. "$SCRIPTDIR\..\utilities\general-cmdlets.ps1"
. "$SCRIPTDIR\..\utilities\connection_details.ps1"
. "$SCRIPTDIR\..\utilities\mysql_cmdlets.ps1"
. "$SCRIPTDIR\manager-cmdlets.ps1"
# Set Shell Title
$host.ui.RawUI.WindowTitle = "SummitRTS Queue Manager"
#=======================================================================================
# Script Arguments
#=======================================================================================

# The manager Requires the following items to get started properly
$ManagerAction=$args[0]
# Set the log file for the Manager.
$LogFile = "C:\SummitRTS\Queue_Manager\Queue_Manager.log"

#=======================================================================================
# Device Manager
#=======================================================================================
$ManagerRUNNING = $true
			
do {
	####################################
	# Status Check  
	####################################
	#Query the DB for the Manager Status
	writeLog("#######################################################")
	writeLog("Querying the Database to determine Queue Manager Status")
	$query = "select Status_ID,Wait,Log_File from queue_manager"
	$ManagerData = @(RunSQLCommand $query)
	$ManagerStatus = $ManagerData[0].Status_ID
	$ManagerWait = $ManagerData[0].Wait
	$LogFile = $ManagerData[0].Log_File
	writeLog("Manager Status is : ${ManagerStatus}")
	writeLog("Manager Wait is : ${ManagerWait}")

	####################################
	# Set Status to Starting up  
	####################################
	if($ManagerAction -eq "START"){
		#Set the status of the Manager to "Starting_Up"
		writeLog("The Manager status is ${ManagerStatus}, Lets start it up!")
		$query = "update queue_manager set Status_ID = 3"
		RunSQLCommand $query
		# wait 10 seconds
		writeLog ("Pausing 10 seconds")
		$ManagerAction = "Done"
		pause 10
	}

	####################################
	# Start-up Tasks 
	####################################
	if($ManagerStatus -eq 3){ #Starting_Up
		#No Test should be RUNNING when started.
		writeLog("The Manager status is ${ManagerStatus} : Starting_Up, While we are starting up, lets Abort any Not Complete Tests/SUT's")
		#Abort all SUT's where the Test_Status is 'SUBMITTED'
		AbortTests 5 #SUBMITTED
		#Abort all SUT's where the Test_Status is 'Assigned'
		AbortTests 7 #Assigned
		#Abort all SUT's where the SUT_Status is not 'COMPLETE' and the Test_Status is 'RUNNING'
		AbortTests 8 #RUNNING
		#Abort all SUT's where the SUT_Status is not 'COMPLETE' and the Test_Status is 'CANCELLED'
		AbortTests 10 #CANCELLED
		#Abort all SUT's where the SUT_Status is not 'COMPLETE' and the Test_Status is 'COMPLETE'
		AbortTests 9 #COMPLETE
		#Abort any SUTs not 'COMPLETE' or not 'QUEUED' with a ANY Test_Status
		AbortNotCOMPLETESUTs
		#Abort any TestCases that are not Complete or QUEUED
		AbortNotCompleteTestcases
		writeLog("There are no more Assigned or RUNNING tests to Abort, Setting the Agent to 'Up'")
		#Set the status of the Manager to Available/Active
		$query = "update queue_manager set Status_ID = 2"
		RunSQLCommand $query
		# wait 10 seconds
		writeLog ("Pausing 10 seconds")
		pause 10
	}

	####################################
	# Normal Operation Tasks 
	####################################
	if($ManagerStatus -eq 2){ # Up and Running
		#Abort any Test with a Test_Status of 'CANCELLED', and any of its SUT's that are not COMPLETE
		AbortTests 10 #CANCELLED
		#Abort any SUTs with the SUT_Status of 'CANCELLED'
		AbortCANCELLEDSUTs
		# wait 10 seconds
		writeLog ("Pausing 10 seconds")
		pause 10
		# Review Running Test Suites
		ReviewRunningTests
		# wait 5 seconds
		writeLog ("Pausing 5 seconds")
		# Review Queued Test Suites
		ReviewQueuedTest
		# wait 5 seconds
		writeLog ("Pausing 5 seconds")
		# Review Queued SUTs
		AssignQueuedSUTs		
		# wait 10 seconds
		writeLog ("Pausing 10 seconds")
		pause 10
		# This line represents marking tests complete(no more SUT's to run)
		FinishCompletedTests
		# wait 10 seconds
		writeLog ("Pausing 10 seconds")
		pause 10
		# Wait the Full QueueManager Wait time.
		writeLog ("Pausing ${ManagerWait} seconds")
		pause $ManagerWait
	}

	####################################
	# Shutdown Tasks 
	####################################
	if($ManagerStatus -eq 4){ #Shutting_down
		writeLog("The Manager status is ${ManagerStatus}: Shutting_down, While we are Shutting down, lets Abort any RUNNING tests")
		#Abort all SUT's where the Test_Status is 'SUBMITTED'
		AbortTests 5 #SUBMITTED
		#Abort all SUT's where the Test_Status is 'Assigned'
		AbortTests 7 #Assigned
		#Abort all SUT's where the SUT_Status is not 'COMPLETE' and the Test_Status is 'RUNNING'
		AbortTests 8 #RUNNING
		#Abort all SUT's where the SUT_Status is not 'COMPLETE' and the Test_Status is 'CANCELLED'
		AbortTests 10 #CANCELLED
		#Abort all SUT's where the SUT_Status is not 'COMPLETE' and the Test_Status is 'COMPLETE'
		AbortTests 9 #COMPLETE
		#Abort any SUTs not 'COMPLETE' or not 'QUEUED' with a ANY Test_Status
		AbortNotCOMPLETESUTs
		# This line represents marking tests complete(no more SUT's to run)
		FinishCompletedTests
		#set status of Manager to "DOWN"
		writeLog("The Manager Status is now being set to down, and the process will stop RUNNING.")
		$query = "update queue_manager set Status_ID = 1"
		RunSQLCommand $query
		$ManagerRUNNING = $false
		return $ManagerRUNNING
	}

} while ($ManagerRUNNING -eq $true)
#=======================================================================================
#    _  _  _____                    ____       _             
#  _| || ||_   _|__  __ _ _ __ ___ | __ )  ___| | __ _ _   _ 
# |_  ..  _|| |/ _ \/ _` | '_ ` _ \|  _ \ / _ \ |/ _` | | | |
# |_      _|| |  __/ (_| | | | | | | |_) |  __/ | (_| | |_| |
#   |_||_|  |_|\___|\__,_|_| |_| |_|____/ \___|_|\__,_|\__, |
#                                                      |___/ 
#=======================================================================================