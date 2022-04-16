#!/bin/bash
# 每分钟检查一次mariadb 是否异常，服务不存在则自动拉起

PORT=`ss -nlt|grep 3306|wc -l`
PROCESS=`ps -efww |grep "/usr/local/mariadb/"|grep -v grep |wc -l`

if [ $PORT -eq 1 ] && [ $PROCESS -gt 1 ]
then
        echo "mariadb服务正常"
else
        systemctl start mariadb
fi
