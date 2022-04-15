#!/bin/bash
# check nginx


num1=`ps -ef |grep  catalina  |grep -v grep |wc -l `

if [ $num1 -lt 1 ];then
        su - njles -c "cd  /usr/local/tomcat/bin;sh startup.sh"
fi


