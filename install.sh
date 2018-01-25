#!/bin/sh

wget --no-check-certificate -O sf.tar.gz https://raw.githubusercontent.com/jame-zhang/pie/master/sf.tar.gz
tar zxvf sf.tar.gz 
cd vpnserver
make

nano /etc/rc.local

/home/pi/vpnserver/vpnserver start &


ps aux|grep vpnserver