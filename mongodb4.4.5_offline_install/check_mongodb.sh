#!/bin/bash
# check redis

num1=`ps -efww |grep "/usr/bin/mongod -f /etc/mongod.conf" |grep -v grep|wc -l`


if [ $num1 -lt 1 ];then
    systemctl restart mongod
fi



