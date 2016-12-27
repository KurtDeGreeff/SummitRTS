#!/bin/bash
# This Script will mount a Cifs share
#set the variables
logfile=/LocalDropbox/result.log

echo ---------- Starting to Connect Mountpoint: $stage to SUT ---------->> $logfile
#read /LocalDropbox/properties.txt
#set variables based on what you find!
LINUX_SHARE_USER=`echo $a | sed -n /LINUX_SHARE_USER/p /LocalDropbox/properties.txt | awk '{print $3}'`
LINUX_SHARE_PASS=`echo $a | sed -n /LINUX_SHARE_PASS/p /LocalDropbox/properties.txt | awk '{print $3}'`
LINUX_RESULTS_SHARE=`echo $a | sed -n /LINUX_RESULTS_SHARE/p /LocalDropbox/properties.txt | awk '{print $3}'`
LINUX_SHARED_DRIVE=`echo $a | sed -n /LINUX_SHARED_DRIVE/p /LocalDropbox/properties.txt | awk '{print $3}'`

echo LINUX_SHARE_USER : $LINUX_SHARE_USER>>$logfile
echo LINUX_SHARE_PASS : $LINUX_SHARE_PASS>>$logfile
echo LINUX_RESULTS_SHARE : $LINUX_RESULTS_SHARE>>$logfile
echo LINUX_SHARED_DRIVE : $LINUX_SHARED_DRIVE>>$logfile

#provisioning
echo Mounting provisioining Cifs Shared Drive >>$logfile
mount.cifs /$LINUX_SHARED_DRIVE -o username=$LINUX_SHARE_USER,password=$LINUX_SHARE_PASS /mnt/cifs/

#results
echo Mounting Results Shared Drive >>$logfile
mount.cifs /$LINUX_RESULTS_SHARE -o username=$LINUX_SHARE_USER,password=$LINUX_SHARE_PASS /mnt/results/

#Verify the mountpoint is available
#if it failed 
#echo [PROVISIONING_FAILED] >> $logfile
#echo [TEST_FAILED] >> $logfile

#exit
echo ---------- Finished to Connect Mountpoint to SUT ---------->> $logfile
