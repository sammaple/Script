#!/bin/sh
#check memcached process and restart if down
PATH=$PATH:/opt/env/memcache/bin/memcached
DATE=`date -d "today" +"%Y-%m-%d-%H:%M"`
#��ps����鿴memcached����
MM=`ps -aux |grep "memcached" |grep "11211" |grep -v "grep" |wc -l`
#if����жϽ����Ƿ���ڣ���������ڣ������־��¼������memcached����
if [ "$MM" == "0" ]; then
    echo "$DATE The memcached is problem and restart" >> /root/memcached_check.logs
    /opt/env/memcache/bin/memcached -t 8 -d -m 2048 -p 11211 -u nobody
else
    echo "$DATE The memcached is ok" >>/root/memcached_check.logs
fi

#��Ӽƻ�����ÿ5���Ӽ��һ�Ρ�
#*/5 * * * * /bin/bash    /root/sh/memcached_check.sh
