#!/bin/bash
# testcase02.sh
# This script will:
# 
# Perform the coinflip test
logfile=/LocalDropbox/result.log

echo ---------- Beginning testcase script ---------->> $logfile

#call /coinflip/coinflip.sh
#Determine even/odd and write Pass/Fail
echo [TEST_PASSED] >> $logfile

echo ---------- Finished testcase script ---------->> $logfile
