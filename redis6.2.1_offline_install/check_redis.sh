#!/bin/bash
# check redis

num1=`ps -efww |grep "/usr/local/redis/bin/redis-server /usr/local/redis/etc/redis.conf" |grep -v grep|wc -l`


if [ $num1 -lt 1 ];then
    /usr/local/redis/bin/redis-server /usr/local/redis/etc/redis.conf
fi



