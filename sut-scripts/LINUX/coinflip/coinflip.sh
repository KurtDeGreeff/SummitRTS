#!/bin/bash

python_exe=`which python`
python_code="./coinflip.py"
logfile=/device/device.log

if [ -e ${python_code} ]; then
    ${python_exe} ${python_code} ${logfile}
else
    echo "${python_code} not found" 
    exit 1
fi

exit 0