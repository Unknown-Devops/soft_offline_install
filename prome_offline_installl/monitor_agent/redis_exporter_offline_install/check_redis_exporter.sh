#!/bin/bash

num=`ps -efww |grep /root/redis_exporter-v1.31.3.linux-amd64/redis_exporter  |grep -v grep| wc -l`
if [  $num -lt 1 ];then
	nohup /root/redis_exporter-v1.31.3.linux-amd64/redis_exporter  --redis.addr redis://127.0.0.1:6380 --redis.password "PASSWORD" >> /root/redis_exporter-v1.31.3.linux-amd64/log_redis_exporter.log 2>&1 &
fi
