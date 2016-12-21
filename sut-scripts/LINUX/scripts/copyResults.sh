#!/bin/bash
logfile=/device/device.log
testName=$1
vmname=$2
testcase=$3

echo ------------- Starting to Copy log files to Results Directory ------------- >> $logfile 

# Future check to ensure the mount point exists

#copy Artifacts to Results directory
myresultsdir=/mnt/results/SutResults/$testName/$vmname/$testcase
mkdir /mnt/results/SutResults/$testName/$vmname/$testcase/
echo Results Directory: $myresultsdir >> $logfile
\cp -R /device/device.log $myresultsdir/device.log
#\cp -R /device/*.jpg $myresultsdir
#\cp -R /device/*.png $myresultsdir

echo ------------- Finished Copying Log files to Results Directory ------------- >> $logfile 
