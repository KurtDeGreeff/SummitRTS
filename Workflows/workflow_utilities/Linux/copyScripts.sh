#!/bin/bash
#copyScripts.sh
#This script will copy Scripts/files to the SUT
logfile=/device/device.log

echo ---------- Starting to Copy SUT-Scripts to SUT ---------->>$logfile

# if the mount does not exist, error out
# echo The Shared drive does not exist! >> $logfile
#echo [PROVIONING_FAILED] >> $logfile
LINUX_SHARE_SCRIPTS_DIR=`echo $a | sed -n /LINUX_SHARE_SCRIPTS_DIR/p /device/properties.txt | awk '{print $3}'`
LINUX_LOCAL_SCRIPTS_DIR=`echo $a | sed -n /LINUX_LOCAL_SCRIPTS_DIR/p /device/properties.txt | awk '{print $3}'`

echo LINUX_SHARE_SCRIPTS_DIR: $LINUX_SHARE_SCRIPTS_DIR>>$logfile
echo LINUX_LOCAL_SCRIPTS_DIR: $LINUX_LOCAL_SCRIPTS_DIR>>$logfile

#Copy SUT files
\cp -R /mnt/cifs$LINUX_SHARE_SCRIPTS_DIR/* $LINUX_LOCAL_SCRIPTS_DIR
chmod 777 /device/*

#exit
echo ---------- Finished Copying SUT-Scripts to SUT ---------->>$logfile
