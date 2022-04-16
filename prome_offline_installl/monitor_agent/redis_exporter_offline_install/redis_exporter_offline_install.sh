#!/bin/bash
#  redis exporter  install
#
my_path=`pwd`

tar  -zxf  $my_path/redis_exporter-v1.31.3.linux-amd64.tar.gz  -C  /root/
cp -rp $my_path/check_redis_exporter.sh  /root/check_redis_exporter.sh

echo "* * * * * root /bin/bash /root/check_redis_exporter.sh  >/dev/null 2>&1"  >> /etc/crontab

