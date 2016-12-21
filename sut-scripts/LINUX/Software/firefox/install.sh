#!/bin/bash

ff_tarball="./firefox.tar.bz2"

if [ -e ${ff_tarball} ]; then
    cd /tmp
    tar -Jxvf ${ff_tarball}
else
    echo "tarball ${ff_tarball} not found"
    exit 2
fi

cd firefox/
./run-mozilla.sh
