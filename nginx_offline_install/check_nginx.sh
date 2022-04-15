#!/bin/bash
# check nginx

num1=`ps -C nginx -no-header|wc -l`

if [ $num1 -lt 2 ];then
        cd /usr/local/nginx/sbin/;./nginx -s stop;./nginx -c /usr/local/nginx/conf/nginx.conf"
fi

