#!/bin/sh

wget --no-check-certificate -O sf.tar.gz https://raw.githubusercontent.com/jame-zhang/pie/master/sf.tar.gz
tar zxvf /root/
cd /root/vpnserver/
make
