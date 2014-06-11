#!/bin/sh
#
#folder list tree
#
#tomcat
#------apache-tomcat
#------mongodb
#
#

WEBHOME=root/tomcat
TOMCATPATH=apache-tomcat-7.0.54
MONGOPATH=mongodb-linux-x86_64-2.4.6

echo "$WEBHOME"
echo "$TOMCATPATH"
echo "$MONGOPATH"

#start mongodb first
cd /$WEBHOME/$MONGOPATH
pwd
./startup_front.sh
cd -

#start tomcat second
cd /$WEBHOME/$TOMCATPATH/bin
pwd
./startup.sh
cd -



