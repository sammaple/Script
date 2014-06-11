#!/bin/sh
#check mongo process and restart if down
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
echo "$MONGOPATH"

DATE=`date -d "today" +"%Y-%m-%d-%H:%M"`
echo $DATE
#��ps����鿴mongo����
MM=`ps aux|grep "mongo"|grep "28018"|grep -v "grep"|wc -l`
echo "$MM"
#if����жϽ����Ƿ���ڣ���������ڣ������־��¼������memcached����
if [ "$MM" == "0" ];then
    echo "$DATE The mongo is problem and restart" >> /root/mongo_check.logs
    
    #start mongodb first
    cd /$WEBHOME/$MONGOPATH
    pwd
    ./startup.sh
    cd -

else
    echo "$DATE The mongo is ok" >> /root/mongo_check.logs
fi

#��Ӽƻ�����ÿ5���Ӽ��һ�Ρ�
#yum install crontab;chkconfig --level 35 crond on;crontab -u root -e to edit
#*/5 * * * * /bin/bash    /root/tomcat/mongo_check.sh
