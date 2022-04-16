#!/bin/bash
# mysql exporter  install
#
my_path=`pwd`

tar  -zxf  $my_path/mysqld_exporter-0.13.0.linux-amd64.tar.gz  -C  /root/
cp -rp $my_path/check_mysqld_exporter.sh  /root/check_mysqld_exporter.sh

cat << EOF >>  /root/mysqld_exporter-0.13.0.linux-amd64/.my.cnf
[client]
host=IP
port=3306
user=root
password=PASSWORD
EOF
echo "* * * * * root /bin/bash /root/check_mysqld_exporter.sh  >/dev/null 2>&1"  >> /etc/crontab

