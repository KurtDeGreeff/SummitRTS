#=======================================================================================
#  ____                            _ _   ____ _____ ____  
# / ___| _   _ _ __ ___  _ __ ___ (_) |_|  _ \_   _/ ___| 
# \___ \| | | | '_ ` _ \| '_ ` _ \| | __| |_) || | \___ \ 
#  ___) | |_| | | | | | | | | | | | | |_|  _ < | |  ___) |
# |____/ \__,_|_| |_| |_|_| |_| |_|_|\__|_| \_\|_| |____/ 
#=======================================================================================
function CancelRunningSUTs() {
    # Query the DB for any SUT's that are running.
    writeLog("Cancelling running SUTs")
    $query = "select * from suts where Status_ID = 8 and Agent_Manager_ID = $AgentManagerID"
    $RunningSUTData = @(RunSQLCommand $query)
    if ($RunningSUTData -ne $null) {
        foreach ($RunningSUT in $RunningSUTData) {
            $SUT_ID = $RunningSUT.ID
            $SUT_NAME = $RunningSUT.Name
            writeLog("Setting Sut: $SUT_NAME to Cancelled.")
            $query = "update suts set Status_ID = 10 where ID = $SUT_ID"
            RunSQLCommand $query
        }
    } else {
        writeLog("No Suts were running. moving on!")
    }
    writeLog("Finished reviewing Running Suts for this Agent Manager")
}
#=======================================================================================
function RequeueAssignedSuts() {
    #Query the DB for any SUT's assigned to this Agent Mgr.
    writeLog("Re-Queueing Assigned Suts before we shut this Ageng Manager down")
    $query = "select * from suts where Status_ID = 7 and Agent_Manager_ID = $AgentManagerID"
    $RequeueSUTData = @(RunSQLCommand $query)
    if ($RequeueSUTData -ne $null) {
        foreach($requeueSUT in $RequeueSUTData) {
            $SUT_ID = $requeueSUT.ID
            $SUT_NAME = $requeueSUT.Name
            writeLog("Setting Sut: $SUT_NAME to Queued.")
            $query = "update suts set Status_ID = 6 where ID = $SUT_ID"
            RunSQLCommand $query            
        }
    } else {
        writeLog("No Suts need to be Re-Queued")
    }
    writeLog("Finished reviewing Requeued Suts.")
}
#=======================================================================================
function StartAssignedSUT() {
# Check to see if the Agent Manager is at its Max

# Get the list of Assigned SUTs

# Get the SUT info

# See if the SUT Hypervisor is available and less than Max

# Start the Workflow

}
#=======================================================================================
#    _  _  _____                    ____       _             
#  _| || ||_   _|__  __ _ _ __ ___ | __ )  ___| | __ _ _   _ 
# |_  ..  _|| |/ _ \/ _` | '_ ` _ \|  _ \ / _ \ |/ _` | | | |
# |_      _|| |  __/ (_| | | | | | | |_) |  __/ | (_| | |_| |
#   |_||_|  |_|\___|\__,_|_| |_| |_|____/ \___|_|\__,_|\__, |
#                                                      |___/ 
#=======================================================================================