#!/bin/bash
# 安装gcc 编译包

echo "#####################开始解压安装包#######################"
/usr/bin/tar  -zxvf  ./gcc.tar.gz
cd gcc
if [ $? == 0 ];then
	echo "#########################解压成功，开始安装相关rpm包############################"
	 rpm -Uvh *.rpm --nodeps --force
fi
echo "###########################检测gcc版本###############################"
scl enable devtoolset-9 bash
echo "source /opt/rh/devtoolset-9/enable" >> /etc/profile

gcc -v  2>&1