#!/bin/bash
# Execute_testcase.sh
# This script will:
# 
# disconnect from the results share
logfile=/device/device.log

echo ---------- Starting to Disconnect Mountpoint ---------->> $logfile

#disconnect the mountpoint
umount -l /mnt/cifs
umount -l /mnt/results

echo ---------- Finished Disconnecting Mountpoint to SUT ---------->> $logfile
