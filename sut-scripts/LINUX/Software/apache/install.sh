#!/bin/bash

logfile=/LocalDropbox/result.log
version=$1
echo ----- Installing Apache version: $version ----- >>$logfile

#Install latest apache (need to verify command)
echo installing httpd service >>$logfile
yum install httpd -y
service httpd start

#Disable iptables so we can browse to the web server
echo Disabling iptables >>$logfile
/etc/init.d/iptables save
/etc/init.d/iptables stop

echo ----- Finished Installing Apache version: $version ----- >>$logfile
