#!/bin/bash
# Provisionvm.sh
# This script will:
# 
# write information about the test and SUT
# mount a share
# copy artifacts to the vm
# install software
# Copy configure_SUT Results
# unmount a share

#set the variables
logfile=/LocalDropbox/result.log
echo ---------- Starting to Provision the SUT ---------->> $logfile
testName=$1
vmname=$2
testcase=configure_SUT

#write some system information
echo Testname is :$testName >> $logfile
echo Vmname is: $vmname >> $logfile
echo Testcase is: $testcase >> $logfile

#Convert the /LocalDropbox/properties.txt file from dos to Unix
echo Converting /LocalDropbox/properties.txt file to Unix >>$logfile
dos2unix /LocalDropbox/properties.txt

# Mount the Cifs Shared drive
echo Mounting shared drive >> $logfile
. /LocalDropbox/connectShare.sh
sleep 10
# Copy the SUT scripts to this SUT /LocalDropbox dir
echo copying SUT scripts to this SUT >> $logfile
. /LocalDropbox/copyScripts.sh
sleep 20
#disconnect the Cifs Shared drive
echo disconnnecing Cifs shared drive >> $logfile
. /LocalDropbox/scripts/disconnectshare.sh
sleep 5
#Install software
echo installing software >> $logfile
. /LocalDropbox/Software/installWrapper.sh
sleep 30
#Did Provisioning pass?
#future need to add some logic here!
echo [PROVISIONING_PASSED] >> $logfile
#echo [PROVISIONING_FAILED] >> $logfile

#Mount the results Cifs Shared drive
echo mounting the Results share >> $logfile
. /LocalDropbox/connectShare.sh
sleep 10
#copy Results from SUT to results share
echo copying results >> $logfile
. /LocalDropbox/scripts/copyResults.sh $testName $vmname $testcase
sleep 20
#unmount shared drive
echo disconnecting results share >> $logfile
. /LocalDropbox/scripts/disconnectShare.sh

#exit
echo ---------- Finished to Provisioning the SUT ---------->> $logfile
exit 0