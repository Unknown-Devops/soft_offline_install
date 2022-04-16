#!/bin/bash
# 离线安装Docker 

my_path=`pwd`

echo "########################  安装docker   ###############################"

tar -zxvf docker_rpm.tar.gz

yum  localinstall  -y  ./docker_rpm/*rpm 
systemctl enable docker
systemctl start docker
systemctl status docker

if [ $? != 0 ];then
	echo -e "docker  安装异常，请检查！"
	exit
fi 


