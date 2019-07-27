#!/bin/sh

if [ $# == 0 ]
then
    echo " 请输入需要配置的主机名"
fi

#自动化脚本
name=$1
dnskey=''
sudo passwd pi <<EOF
password1
password1
EOF
sudo passwd root<<EOF
password2
password2
EOF
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

#软件下载地址
wget http:///example.com/softwarename
tar zxvf softwarename
#mv build vpnserver
#rm build.tar.gz
sudo cp vpnserver/*.so /usr/lib/
mkdir -p /home/pi/.ssh &&touch /home/pi/.ssh/authorized_keys
#添加 ssh publick key
echo "ssh-rsa example key" >>  /home/pi/.ssh/authorized_keys
#sudo apt-get update
#sudo apt-get digt-update
#disable swap
sudo dphys-swapfile swapoff 
sudo dphys-swapfile uninstall 
sudo update-rc.d dphys-swapfile remove

#添加开机自启动
sudo sed -i "19a /home/pi/Desktop/vpnserver/vpnserver start &" /etc/rc.local
sudo reboot 
