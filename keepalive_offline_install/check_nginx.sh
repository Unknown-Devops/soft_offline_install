#!/bin/bash
# check nginx

num1=`ps -C nginx -no-header|wc -l`

if [ $num1 -lt 2 ];then
        su - sshusr -c "cd /usr/local/nginx/sbin/;./nginx -s stop;./nginx -c /usr/local/nginx/conf/nginx.conf"
fi

# 2秒内 nginx 未启动成功，关闭keepalive 切换至另一台keepalive
sleep 2

num2=`ps -C nginx -no-header|wc -l`
if [ $num2 -lt 2 ];then
        systemctl stop keepalived
fi
