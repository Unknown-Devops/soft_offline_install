#!/bin/bash
# check node_exporter
#

num=`ps -efww |grep "/root/node_exporter-1.2.2.linux-amd64/node_exporter"  |grep -v "prome_node-monitor.sh"|grep -v grep|wc -l`

if [ $num -lt 1 ];then 
	nohup /root/node_exporter-1.2.2.linux-amd64/node_exporter >>/root/node_exporter-1.2.2.linux-amd64/exporter.log 2>&1  &
fi
