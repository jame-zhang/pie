#!/bin/bash
#log文件长度限定

programe_name="vpnserver"
programe1_file="/home/pi/Desktop/vpnserver/vpnserver" 
programe2_file="/home/pi/client.sh"
lens_line=10
log_file="/home/pi/check.log"
PIDS=`ps -ef|grep $programe_name|grep -v grep|awk '{print $2}'`
PIDS2=`ps -ef|grep client.sh|grep -v grep|awk '{print $2}'`
#log_file exist or not
if [ -e "$log_file" ]; then
	lines=`wc -l $log_file|awk '{print $1}'`
else
	lines=0
fi
# vpnserver is running or not
if [ "$PIDS" != "" ]; then
	s="`date`: vpnserver is running"
else
	s="`date`: vpnserver is offline, start now"
	sudo $programe1_file start
if
if [ "$PIDS2" != "" ]; then
	s=$s
else
	sudo $programe2_file
fi
if [ $lines -ge $lens_line ]; then
	echo $s > $log_file
else
	echo $s >> $log_file
fi