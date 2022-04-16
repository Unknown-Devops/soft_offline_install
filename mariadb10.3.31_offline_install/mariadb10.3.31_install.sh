#!/bin/bash
# 离线安装mariadb10.3.31   

echo "########################检查mariadb 离线安装目录 ###############################"
MY_PATH=`pwd`
if [ ! -d "/data/mariadb_data/" ]; then
	   mkdir -p /data/mariadb_data/
else
	echo "####开始清空安装目录中其他内容####"
	rm -rf /data/mariadb_data/*
fi



echo "########################开始删除mariadb ###############################"
mDB_name=`rpm -qa|grep mariadb`
rpm -e --nodeps $mDB_name
if [ $? == 0 ];then
	echo "卸载mariadb成功！"
else
	echo "请检查mariaDB 是否卸载！"
fi

echo "###########################禁用SElinux###############################"
setenforce 0
echo -e '\033[1;32m 修改 \033[1;33m /etc/selinux/config \033[0m 配置文件 \033[0m'
sed -i "s/enforcing/disabled/g" /etc/selinux/config


echo "#######################开始安装mariadb10.3.31 ###########################"
cat /etc/passwd |grep mysql >/dev/null  2>&1
if [ $? -eq 0 ];then
	echo -e '\033[1;32m 已创建mysql用户 \033[0m'
else
	/usr/sbin/groupadd mysql
	/usr/sbin/useradd -g mysql mysql
fi


tar -zxvf mariadb-10.3.31-linux-systemd-x86_64.tar.gz  -C  /usr/local/
mv /usr/local/mariadb-10.3.31-linux-systemd-x86_64   /usr/local/mariadb
chown -R mysql:mysql  /usr/local/mariadb
chown -R mysql:mysql  /data/mariadb_data/

cd  /usr/local/mariadb;./scripts/mysql_install_db --user=mysql --datadir=/data/mariadb_data

if [ $? == 0 ];then
	echo "安装mariadb10.3.31 成功！"
else
	echo "安装mariadb10.3.31 失败，请检查后，重新安装！"
	rm -rf /usr/local/mariadb
	exit
fi

echo "#######################mariadb10.3.31 配置并启动###########################"
# 配置环境变量
echo 'export PATH=/usr/local/mariadb/bin:$PATH' >  /etc/profile.d/mariadb.sh
source /etc/profile.d/mariadb.sh

# 修改启动脚本
cp  -rp  /usr/local/mariadb/support-files/mysql.server /etc/init.d/mariadb
sed -i 's#^basedir=#basedir=/usr/local/mariadb#'  /etc/init.d/mariadb    
sed -i 's#^datadir=#datadir=/data/mariadb_data/#'  /etc/init.d/mariadb    
chmod  +x  /etc/init.d/mariadb

# 修改配置文件
sed  -i '/binlog_format/alog_bin=mariadb-bin\nskip_name_resolve=on'  /usr/local/mariadb/support-files/wsrep.cnf

cp  -rp   /usr/local/mariadb/support-files/wsrep.cnf   /etc/my.cnf
# 启动服务
chkconfig --add mariadb 
systemctl enable mariadb
systemctl start mariadb

echo "###########################配置自启动脚本##############################"
cp -rp $MY_PATH/check_mariadb.sh /home/check_mariadb.sh
echo "* * * * * root /bin/bash /home/check_mariadb.sh  >/dev/null 2>&1"  >> /etc/crontab




