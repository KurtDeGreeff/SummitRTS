#!/bin/bash
# Provisionvm.sh
# This script will:
# 
# write information about the test and SUT
# mount a share
# copy artifacts to the vm
# install software
# Copy provisioning Results
# unmount a share

#set the variables
logfile=/device/device.log
echo ---------- Starting to Provision the SUT ---------->> $logfile
testName=$1
vmname=$2
testcase=provisioning

#write some system information
echo Testname is :$testName >> $logfile
echo Vmname is: $vmname >> $logfile
echo Testcase is: $testcase >> $logfile

#Convert the /device/properties.txt file from dos to Unix
echo Converting /device/properties.txt file to Unix >>$logfile
dos2unix /device/properties.txt

# Mount the Cifs Shared drive
echo Mounting shared drive >> $logfile
. /device/connectShare.sh
sleep 10
# Copy the SUT scripts to this SUT /device dir
echo copying SUT scripts to this SUT >> $logfile
. /device/copyScripts.sh
sleep 20
#disconnect the Cifs Shared drive
echo disconnnecing Cifs shared drive >> $logfile
. /device/scripts/disconnectshare.sh
sleep 5
#Install software
echo installing software >> $logfile
. /device/Software/installWrapper.sh
sleep 30
#Did Provisioning pass?
#future need to add some logic here!
echo [PROVISIONING_PASSED] >> $logfile
#echo [PROVISIONING_FAILED] >> $logfile

#Mount the results Cifs Shared drive
echo mounting the Results share >> $logfile
. /device/connectShare.sh
sleep 10
#copy Results from SUT to results share
echo copying results >> $logfile
. /device/scripts/copyResults.sh $testName $vmname $testcase
sleep 20
#unmount shared drive
echo disconnecting results share >> $logfile
. /device/scripts/disconnectShare.sh

#exit
echo ---------- Finished to Provisioning the SUT ---------->> $logfile
exit 0