#!/bin/bash
logfile=/LocalDropbox/result.log
#example for now (this is hardcoded in writeproperties.ps1, so you will see this in properties.txt)
#$LINUX_SW_COUNT = "2"
#$LINUX_SW_NAME_1 = "apache"
#$LINUX_SW_VER_1 = "latest"
#$LINUX_SW_NAME_2 = "firefox"
#$LINUX_SW_VER_2 = "27.0.1"

echo ---------- Beginning to install Software for SUT ---------->> $logfile

#Get the Linux_sw_count from /LocalDropbox/properties.txt
LINUX_SW_COUNT=`echo $a | sed -n /LINUX_SW_COUNT/p /LocalDropbox/properties.txt | awk '{print $3}'`
#read the file!
echo Installing $LINUX_SW_COUNT Software packages to this SUT >> $logfile

#loop through the number of packages to install, getting the info from properties.txt
#
# Hard-coding the software install for now
#
#and install the software
#if latest, just do a yum install
#if the version is not latest, good luck! 
LINUX_SW_NAME_1=`echo $a | sed -n /LINUX_SW_NAME_1/p /LocalDropbox/properties.txt | awk '{print $3}'`
LINUX_SW_VER_1=`echo $a | sed -n /LINUX_SW_VER_1/p /LocalDropbox/properties.txt | awk '{print $3}'`
echo Installing Software: $LINUX_SW_NAME_1 and Version:$LINUX_SW_VER_1 to this SUT >>$logfile
. /LocalDropbox/Software/$LINUX_SW_NAME_1/install.sh $LINUX_SW_VER_1

#exit
echo ---------- Finished installing Software for SUT ---------->> $logfile



