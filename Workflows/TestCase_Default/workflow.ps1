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
# Set the log file for the Manager.
Write-Host "Just print something to the screen, sutid: $SUT_ID sutname: $sutName"
write-host "$SUT_ID"
write-host "$sutName"
start-sleep 60



#=======================================================================================
#    _  _  _____                    ____       _             
#  _| || ||_   _|__  __ _ _ __ ___ | __ )  ___| | __ _ _   _ 
# |_  ..  _|| |/ _ \/ _` | '_ ` _ \|  _ \ / _ \ |/ _` | | | |
# |_      _|| |  __/ (_| | | | | | | |_) |  __/ | (_| | |_| |
#   |_||_|  |_|\___|\__,_|_| |_| |_|____/ \___|_|\__,_|\__, |
#                                                      |___/ 
#=======================================================================================