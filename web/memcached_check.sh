#!/bin/sh
#check memcached process and restart if down
PATH=$PATH:/opt/env/memcache/bin/memcached
DATE=`date -d "today" +"%Y-%m-%d-%H:%M"`
#用ps命令查看memcached进程
MM=`ps -aux |grep "memcached" |grep "11211" |grep -v "grep" |wc -l`
#if语句判断进程是否存在，如果不存在，输出日志记录并重启memcached服务
if [ "$MM" == "0" ]; then
    echo "$DATE The memcached is problem and restart" >> /root/memcached_check.logs
    /opt/env/memcache/bin/memcached -t 8 -d -m 2048 -p 11211 -u nobody
else
    echo "$DATE The memcached is ok" >>/root/memcached_check.logs
fi

#添加计划任务，每5分钟检测一次。
#*/5 * * * * /bin/bash    /root/sh/memcached_check.sh
