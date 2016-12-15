#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#=================================================================#
#   System Required:  Debian7/8, Ubuntu14.04                      #
#   Description: One click Install ShadowsocksR Server            #
#   Thanks: @hellofwy <https://github.com/hellofwy>               #
#   Fork: @FunctionClub <https://github.com/FunctionClub>         #
#   Author： AlphaBrock https://alphabrock.cn                     #
#=================================================================#

#Check Root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

#Set DNS
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

#Disable selinux
if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
fi

clear

#InstallBasicPackages
apt-get update -y
apt-get install git tar python-pip unzip bc python-m2crypto curl wget unzip gcc swig automake make perl cpio build-essential ntpdate -y
apt-get install language-pack-zh-hans -y
pip install shadowsocks

#Set Time Zone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate 1.asia.pool.ntp.org

#Clone Something
cd /usr/local
git clone https://github.com/breakwa11/shadowsocks.git
git clone https://github.com/AlphaBrock/SSR-Bash

#Intall libsodium
cd /root
wget --no-check-certificate -O libsodium-1.0.10.tar.gz https://github.com/jedisct1/libsodium/releases/download/1.0.10/libsodium-1.0.10.tar.gz
tar -xf libsodium-1.0.10.tar.gz && cd libsodium-1.0.10
./configure && make && make install
echo "/usr/local/lib" > /etc/ld.so.conf.d/local.conf && ldconfig
cd ../ && rm -rf libsodium* 

 #Install Softlink
wget -N --no-check-certificate -O /usr/local/bin/ssr https://raw.githubusercontent.com/AlphaBrock/SSR-Bash/master/ssr
chmod +x /usr/local/bin/ssr

echo '安装完成！输入 ssr 即可使用本程序~'
