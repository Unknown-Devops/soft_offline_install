#!/bin/bash
# 离线安装tomcat  ，默认目录/usr/local/tomcat 

echo "Tomcat 启动需要jdk （当前版本tomcat需要jdk 8以上版本），请确认是否安装jdk"

echo "#####################在/usr/local/tomcat安装tomcat############################"
tar -zxf ./apache-tomcat-8.5.69.tar.gz 
mv  ./apache-tomcat-8.5.69  /usr/local/tomcat

echo "#############################配置tomcat自启动####################################"
cp  -rf  ./check_tomcat.sh /home/check_tomcat.sh

if [ $? == 0 ];then
	echo "* * * * * root /bin/bash /home/check_tomcat.sh  >/dev/null 2>&1"  >> /etc/crontab
fi


