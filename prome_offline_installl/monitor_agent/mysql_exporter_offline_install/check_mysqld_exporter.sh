#!/bin/bash

num=`ps -efww |grep /root/mysqld_exporter-0.13.0.linux-amd64/mysqld_exporter  |grep -v grep| wc -l`
if [  $num -lt 1 ];then
	cd /root/mysqld_exporter-0.13.0.linux-amd64;nohup /root/mysqld_exporter-0.13.0.linux-amd64/mysqld_exporter  --config.my-cnf=/root/mysqld_exporter-0.13.0.linux-amd64/.my.cnf   >> /root/mysqld_exporter-0.13.0.linux-amd64/log_mysql_exporter.log 2>&1 &
fi
