#!/bin/bash
# check tomcat

num1=`ps -ef |grep  catalina  |grep -v grep |wc -l `

if [ $num1 -lt 1 ];then
        su - sshusr -c "cd  /usr/local/tomcat/bin;sh startup.sh"
fi
# 两秒内Tomcat重启失败，停止keepalive ，让vip 飘走
sleep 2
num2=`ps -ef |grep  catalina  |grep -v grep |wc -l `
if [ $num2 -lt 1 ];then
        systemctl stop keepalived
fi

