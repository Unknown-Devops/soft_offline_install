#!/bin/bash
# 离线安装vim  

echo "#####################开始解压安装包#######################"
/usr/bin/tar  -zxvf  ./vim_install.tar.gz
if [ $? == 0 ];then
	echo "#########################解压成功，开始安装相关rpm包############################"
	cd vim_install
	yum -y install *rpm
fi
echo "###########################检测vim 版本###############################"
vim --version
