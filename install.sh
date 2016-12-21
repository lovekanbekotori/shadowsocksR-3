#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#=================================================================#
#   System Required:  Debian7/8, Ubuntu14.04 Centos6              #
#   Description: One click Install ShadowsocksR Server            #
#   Thanks: @hellofwy <https://github.com/hellofwy>               #
#   Fork: @FunctionClub <https://github.com/FunctionClub>         #
#   Author： AlphaBrock https://alphabrock.cn                     #
#=================================================================#

clear
echo

echo

# Make sure only root can run our script
function rootness(){
    if [[ $EUID -ne 0 ]]; then
       echo "Error:This script must be run as root!" 1>&2
       exit 1
    fi
}

function Set_DNS(){
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
}

# Disable selinux
function disable_selinux(){
if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
fi
}

# Check OS
function checkos(){
    if [ -f /etc/redhat-release ];then
        OS='CentOS'
    elif [ ! -z "`cat /etc/issue | grep bian`" ];then
        OS='Debian'
    elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
        OS='Ubuntu'
    else
        echo "Not support OS, Please reinstall OS and retry!"
        exit 1
    fi
}

# Get version
function getversion(){
    if [[ -s /etc/redhat-release ]];then
        grep -oE  "[0-9.]+" /etc/redhat-release
    else    
        grep -oE  "[0-9.]+" /etc/issue
    fi    
}

# CentOS version
function centosversion(){
    local code=$1
    local version="`getversion`"
    local main_ver=${version%%.*}
    if [ $main_ver == $code ];then
        return 0
    else
        return 1
    fi        
}

# Pre-installation settings
function pre_install(){
    # Not support CentOS 5
    if centosversion 5; then
        echo "Not support CentOS 5, please change OS to CentOS 6+/Debian 7+/Ubuntu 12+ and retry."
        exit 1
    fi


#InstallBasicPackages
#apt-get update -y
#apt-get install git tar python-pip unzip bc python-m2crypto curl wget unzip gcc swig automake make perl cpio build-essential ntpdate -y
#apt-get install language-pack-zh-hans -y
#pip install shadowsocks

# Install necessary dependencies
if [ "$OS" == 'CentOS' ]; then
    yum install -y wget unzip openssl-devel gcc swig python python-devel python-setuptools autoconf libtool libevent git ntpdate
    yum install -y m2crypto automake make curl curl-devel zlib-devel perl perl-devel cpio expat-devel gettext-devel
else
    apt-get -y update
    apt-get -y install python python-dev python-pip python-m2crypto curl wget unzip gcc swig automake make perl cpio build-essential git ntpdate
    pip install shadowsocks
fi
}

#Set Time Zone
#rm -rf /etc/localtime
#ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#ntpdate 1.asia.pool.ntp.org


function Clone_Something(){
cd /usr/local
git clone  https://github.com/breakwa11/shadowsocks.git                                       
git clone https://github.com/AlphaBrock/SSR-Bash 
}

#add run on systemstart up 
function ssr_chkconfig(){
    if [ "$OS" == 'CentOS' ];then
        echo "bash /usr/local/SSR-Bash/ssadmin.sh start" >> /etc/rc.d/rc.sysinit
    else
        wget -N --no-check-certificate -O /etc/init.d/shadowsocks https://raw.githubusercontent.com/AlphaBrock/SSR-Bash/master/ssr_chkconfig 
        chmod +x /etc/init.d/shadowsocks
        update-rc.d -f shadowsocks defaults
    fi
}

function Install_libsodium(){
cd /root
wget --no-check-certificate -O libsodium-1.0.10.tar.gz https://github.com/jedisct1/libsodium/releases/download/1.0.10/libsodium-1.0.10.tar.gz
tar -xf libsodium-1.0.10.tar.gz && cd libsodium-1.0.10
./configure && make && make install
echo "/usr/local/lib" > /etc/ld.so.conf.d/local.conf && ldconfig
cd ../ && rm -rf libsodium* 
}

function Install_Softlink(){
wget -N --no-check-certificate -O /usr/local/bin/ssr https://raw.githubusercontent.com/AlphaBrock/SSR-Bash/master/ssr
chmod +x /usr/local/bin/ssr
 }

#改成北京时间
function check_datetime(){
	rm -rf /etc/localtime
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	ntpdate 1.asia.pool.ntp.org
}

#启动ssr-bash管理程序
function run_ssr(){
    ssr
}

 # Install ShadowsocksR
function install_shadowsocks(){
    rootness
    Set_DNS
    disable_selinux
    checkos
    pre_install
    Clone_Something
    ssr_chkconfig
    Install_libsodium
    Install_Softlink
    check_datetime
    run_ssr
	
}
# Initialization step
action=$1
[ -z $1 ] && action=install
case "$action" in
install)
    install_shadowsocks
    ;;
*)
    echo "Arguments error! [${action} ]"
    echo "Usage: `basename $0` {install}"
    ;;
esac

