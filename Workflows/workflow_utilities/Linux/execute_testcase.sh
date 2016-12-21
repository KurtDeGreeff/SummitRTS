#!/bin/bash
# Execute_testcase.sh
# This script will:
# 
# Run each test case
# Mount the Results share
# Copy the device.log to the results share
# disconnect from the results share

logfile=/device/device.log
testName=$1
vmname=$2
testcase=$3
testcase_script=$4

echo ---------- Beginning testcase: $testcase ---------->> $logfile

echo testName is :$testName >> $logfile
echo Vmname is : $vmname >> $logfile
echo Testcase is : $testcase >> $logfile
echo Testcase Script is : $testcase_script >> $logfile

#Execute testcase script
. /device/$testcase_script
sleep 10
#Ensure it exists first of course
# if not
# echo [TEST_FAILED] >> $logfile

#Mount the results Cifs Shared drive
echo mounting the Results share >> $logfile
. /device/connectShare.sh
sleep 10

#copy Results from SUT to results share
echo copying results >> $logfile
. /device/scripts/copyResults.sh $testName $vmname $testcase
sleep 10
#disconnect mount
. /device/scripts/disconnectShare.sh
sleep 5
#exit
echo ---------- Finishing testcase: $testcase ---------->> $logfile
exit 0