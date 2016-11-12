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
    $query = "select * from suts where Agent_Manager_ID like $AgentManagerID and Status_ID like 8"
    $RunningSUTData = @(RunSQLCommand $query)
    $RunningSutCount = $RunningSUTData.Count
    if ($RunningSutCount -le $Agent_Max_Concurrent) {
        writeLog("The Agent is not Maxed, lets look at the Assigned SUT's")
        # Get the list of Assigned SUTs
        $query = "select * from suts where Agent_Manager_ID like $AgentManagerID and Status_ID like 7"
        $AssignedSutData = @(RunSQLCommand $query)
        $AssignedSUTCount = $AssignedSutData.Count
        if ($AssignedSUTCount -ne $null){
            # Get the SUT info
            writeLog("Loop through each SUT to see if we can get the Workflow started.")
            foreach ($assignedSUT in $AssignedSutData) {
                $sutID = $assignedSUT.ID
                $sutName = $assignedSUT.Name
                $sutTestID = $assignedSUT.Test_Suite_ID
                $sutHypervisorType = $assignedSUT.Hypervisor_Type_ID
                $sutWorkflowID = $assignedSUT.Workflow_ID
                # See if the SUT Hypervisor is enabled 
                $query = "select * from hypervisors where Hypervisor_Type_ID like $sutHypervisorType and Status_ID like 11"
                $SutHypervisorData = @(RunSQLCommand $query)
                $SutHypervisorDataCount = $SutHypervisorData.Count
                # Check if any data was returned.
                if ($SutHypervisorDataCount -ne $null){
                    # There were enabled hypervisors!
                    writeLog("Loop through each Enabled Hypervisor to see if one is not at its max.")
                    foreach ($SUTHypervisor in $SutHypervisorData) {
                        $SutHypervisorID = $SUTHypervisor.ID
                        $SutHypervisorMax = $SUTHypervisor.Max_Concurrent_SUTS
                        $SutHypervisorIP = $SUTHypervisor.IP_Address
                        # Check to see if the hypervisor and less than Max
                        $query = "select * from suts where Hypervisor_ID like $SutHypervisorID and Status_ID like 8"
                        $runningSutHypervisorData = @(RunSQLCommand $query)
                        $RunningSutHypervisorCount = $runningSutHypervisorData.Count
                        if ($RunningSutHypervisorCount -lt $SutHypervisorMax) {
                            # The hypervisor is below the max, update the sut Hypervisor ID and start the Workflow.
                            writeLog("The hypervisor: $SutHypervisorIP is ready for a test. Assigning SUT.")
                            #First update the SUT with the Hypervisor Data
                            $query = "update suts set Hypervisor_ID = $SutHypervisorID where ID like $sutID"
                            RunSQLCommand $query
                            # Get the Workflow Data
                            writeLog("Query the DB for the SUT's workflow Data.")
                            $query = "select * from workflows where ID like $sutWorkflowID"
                            $workflowData = @(RunSQLCommand $query)
                            $workflow_Name = $workflowData.Name
                            $Workflow_Script = $workflowData.Script_Path
                            # Start the Workflow Script passing in needed data.
                            writeLog("Starting Workflow: $workflow_Name for sut: $sutID sutname: $sutName with Script path: $Workflow_Script")
                            Start-Process -WindowStyle Normal powershell.exe -ArgumentList "-file $Workflow_Script", "$sutID", "$sutName"
                            pause 5
                            # Where will this break to (It needs to break out of the list of Hypervisors)?
                            Break
                        } else {
                            # The Hypervisor is at the max.
                            writeLog("The Hypervisor: $SutHypervisorIP is running the Max number of SUTs.")
                        }
                    }
                } else {
                    # No Hypervisors are enabled
                    writeLog("There are no hypervisors enabled for this SUT.")
                }
            }
        } else {
            # There are no assigned Sut's exit loop.
            writeLog("There are not assigned suts to this Agent right now.")
        }
    } else {
        # The agent cannot run anymore SUT's exit loop.
        writeLog("The Agent is running the maximum number of SUTs right now.")
    }
    writeLog("The Agent has finished reviewing Assigned SUT's")
}
#=======================================================================================
#    _  _  _____                    ____       _             
#  _| || ||_   _|__  __ _ _ __ ___ | __ )  ___| | __ _ _   _ 
# |_  ..  _|| |/ _ \/ _` | '_ ` _ \|  _ \ / _ \ |/ _` | | | |
# |_      _|| |  __/ (_| | | | | | | |_) |  __/ | (_| | |_| |
#   |_||_|  |_|\___|\__,_|_| |_| |_|____/ \___|_|\__,_|\__, |
#                                                      |___/ 
#=======================================================================================