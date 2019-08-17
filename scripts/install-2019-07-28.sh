#!/bin/bash

if [ $# == "0" ]
then
    echo "请输入需要配置的主机名和是否配置静态IP *1.100，中间以空格隔开"
    echo "如：./in.sh zhangzm100 static"
    exit 1
fi

#自动化脚本
name=$1
dnskey=''
sudo passwd pi <<EOF
password
password
EOF
sudo passwd root<<EOF
 
 
EOF

#按照依赖
#sudo apt-get install libncurses5-dev libncursesw5-dev -y
#设置语言和区域
sudo sed -i 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen
sudo sed -i 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
#配置时区
sudo chmod 666 /etc/timezone
sudo rm /etc/localtime
sudo echo "UTC" > /etc/timezone
sudo dpkg-reconfigure -f noninteractive tzdata
#更改主机名
sudo chmod 666 /etc/hostname
echo $name > /etc/hostname
sudo sed -i '$d' /etc/hosts
sudo sed -i '$a  127.0.1.1       '$name /etc/hosts
sudo hostnamectl set-hostname $name
sudo systemctl restart avahi-daemon

#开始ssh
sudo update-rc.d ssh enable
sudo invoke-rc.d ssh start
#关闭蓝牙
sudo systemctl disable hciuart
#sudo sed -i "51a dtoverlay=pi3-disable-bt" /boot/config.txt
#设置wait for boot disable
sudo rm -f /etc/systemd/system/dhcpcd.service.d/wait.conf
mkdir /home/pi/Desktop/
cd /home/pi/Desktop/
wget http://dorm.jame-zhang.top:186/script/build.tar.gz
tar zxvf build.tar.gz
#mv build vpnserver
#rm build.tar.gz
sudo cp vpnserver/*.so /usr/lib/
mkdir -p /home/pi/.ssh &&touch /home/pi/.ssh/authorized_keys
#配置 ssh 公钥
echo "ssh-rsa AAAAB3N....." >>  /home/pi/.ssh/authorized_keys

#sudo apt-get update
#sudo apt-get digt-update
#disable swap
sudo dphys-swapfile swapoff 
sudo dphys-swapfile uninstall 
sudo update-rc.d dphys-swapfile remove
sudo sed -i "19a /home/pi/Desktop/vpnserver/vpnserver start &" /etc/rc.local

#客户端和守护进程脚本下载
wget http://example.com:port/check.sh -O /home/pi/check.sh
chmod a+x /home/pi/check.sh
wget  http://example.com:port/client.sh -O /home/pi/client.sh
chmod a+x /home/pi/client.sh
crontab -r
crontab -l > mycron
echo "* * * * * /home/pi/check.sh" >> mycron
crontab mycron
rm mycron

sudo sed -i "18a /home/pi/check.sh &" /etc/rc.local

if [ "$2" != "" ]
then
	sudo echo "
# Example static IP configuration:
interface eth0
static ip_address=192.168.1.100/24
#static ip6_address=fd51:42f8:caae:d92e::ff/64
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8

" >> /etc/dhcpcd.conf
fi
#更改softether 主机域名
sudo /home/pi/Desktop/vpnserver/vpnserver start
sleep 5s
sudo /home/pi/Desktop/vpnserver/vpncmd 127.0.0.1:1194 /SERVER /PASSWORD:"password" /CMD DynamicDnsSetHostname  $name
echo "新域名的 dnskey 如下，请注意保存！"
sed -n '19, 19p' /home/pi/Desktop/vpnserver/vpn_server.config|awk '{print $3}'


#sudo reboot 
