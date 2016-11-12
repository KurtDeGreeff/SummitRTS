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
. "$SCRIPTDIR\agentmgr-cmdlets.ps1"
# Set Shell Title
$host.ui.RawUI.WindowTitle = "SummitRTS Agent Manager"
#=======================================================================================
# Script Arguments
#=======================================================================================
# The manager Requires the following items to get started properly
$AgentManagerAction=$args[0]
# Set the log file for the Manager.
$LogFile = "C:\SummitRTS\Agent_Manager\Agent_Manager.log"

# Might want to get properties from the DB here. So we know where to copy logs to.



#=======================================================================================
# Agent Manager
#=======================================================================================
$AgentManagerRUNNING = $true

do {
	####################################
	# Status Check  
	####################################
    # Determine This Agent Managers IP 
    $AgentManagerIP = "127.0.0.1"
    
	#Query the DB for the Agent Manager Status
	writeLog("#######################################################")
	writeLog("Querying the Database to determine Agent Manager Status")
	$query = "select Status_ID,Wait,LogFile from agent_managers where IP_Address = '$AgentManagerIP'"
	$AgentManagerData = @(RunSQLCommand $query)
	$AgentManagerID = $AgentManagerData[0].ID
	$AgentManagerStatus = $AgentManagerData[0].Status_ID
	$AgentManagerWait = $AgentManagerData[0].Wait
	$LogFile = $AgentManagerData[0].LogFile
	$Agent_Max_Concurrent = $AgentManagerData[0].Max_Concurrent_SUTS
	writeLog("Agent Manager ID is : ${AgentManagerID}")
	writeLog("Agent Manager Status is : ${AgentManagerStatus}")
	writeLog("Agent Manager Wait is : ${AgentManagerWait}")

	####################################
	# Set Status to Starting up  
	####################################
    if($AgentManagerAction -eq "START"){
        #Set the status of the Agent Manager to "Starting_Up"
		writeLog("The Manager status is ${AgentManagerStatus}, Lets start it up!")
		$query = "update agent_managers set Status_ID = 3 where ID = $AgentManagerID"
		RunSQLCommand $query
		$AgentManagerAction = "Done"
        # wait 10 seconds
		writeLog ("Pausing 10 seconds")
        pause 10
    }

	####################################
	# Start-up Tasks 
	####################################
    if($AgentManagerStatus -eq 3){ #Starting_Up
        # Cancel any Running SUT's for this Agent Manager
        CancelRunningSUTs
		# wait 10 seconds
		writeLog ("Pausing 10 seconds")
		pause 10
        # Set the status of the Manager to Up
        $query = "update agent_managers set Status_ID = 2 where ID = $AgentManagerID"
		RunSQLCommand $query
    }

	####################################
	# Normal Operation Tasks 
	####################################
    if($AgentManagerStatus -eq 2){ # Up and Running
        # Start Assigned Sut
        StartAssignedSUT
		# wait 10 seconds
		writeLog ("Pausing 10 seconds")
		pause 10        
        writeLog("Pausing $AgentManagerWait seconds.")
        pause $AgentManagerWait
    }

	####################################
	# Shutdown Tasks 
	####################################
    if($AgentManagerStatus -eq 4){ #Shutting_down
        # Cancel any Running SUT's for this Agent Manager
        CancelRunningSUTs
		# wait 10 seconds
		writeLog ("Pausing 10 seconds")
		pause 10
		#set status of Agent Manager to "DOWN"
		writeLog("The Agent Manager Status is now being set to down, and the process will stop RUNNING.")
		$query = "update agent_managers set Status_ID = 1 where ID = $AgentManagerID"
		RunSQLCommand $query
        # Requeue any Assigned SUT's
        RequeueAssignedSuts
		$AgentManagerRUNNING = $false
		return $AgentManagerRUNNING        
    }

} while ($AgentManagerRUNNING -eq $true)
#=======================================================================================
#    _  _  _____                    ____       _             
#  _| || ||_   _|__  __ _ _ __ ___ | __ )  ___| | __ _ _   _ 
# |_  ..  _|| |/ _ \/ _` | '_ ` _ \|  _ \ / _ \ |/ _` | | | |
# |_      _|| |  __/ (_| | | | | | | |_) |  __/ | (_| | |_| |
#   |_||_|  |_|\___|\__,_|_| |_| |_|____/ \___|_|\__,_|\__, |
#                                                      |___/ 
#=======================================================================================