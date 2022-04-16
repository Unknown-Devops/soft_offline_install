#!/bin/bash
# 每分钟检查一次mysql 是否异常，服务不存在则自动拉起

port=`netstat -nlt|grep 3306|wc -l`
process=`ps -ef |grep mysql|grep -v grep |wc -l`

if [ $port -eq 1 ] && [ $process -gt 1 ]
then
	echo "MySQL服务正常"
else
	systemctl start mysqld
fi

