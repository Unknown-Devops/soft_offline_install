#!/bin/bash
#  node_exporter  install
#
my_path=`pwd`

tar -zxf  $my_path/node_exporter-1.2.2.linux-amd64.tar.gz  -C /root/
cp -rp $my_path/prome_node-monitor.sh /root/prome_node-monitor.sh

echo "* * * * * root /bin/bash /root/prome_node-monitor.sh  >/dev/null 2>&1"  >> /etc/crontab

