#!/bin/bash

hostname=$(hostname)
#server="http://dorm.jame-zhang.top:1887/"
server="http://127.0.0.1:1687/"
while :
do
    ip=`curl -s ip.3322.net`
    lanIP=`ifconfig|grep "192.168"|awk '{print $2}'`
    updatedTime=`date "+%Y-%m-%d %H:%M:%S"`
    curl -s -d "id=$hostname&ipaddr=$ip&updatedTime=$updatedTime&lanIP=$lanIP" $server
    sleep 1s
done