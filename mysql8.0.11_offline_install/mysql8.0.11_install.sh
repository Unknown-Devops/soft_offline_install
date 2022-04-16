#!/bin/bash
# 离线安装mysql8.0.11   


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


echo "#######################开始安装mysql8.0.11###########################"
/usr/bin/rpm -ivh ./net-tools-2.0-0.25.20131004git.el7.x86_64.rpm
mkdir ./mysql-8.0.11

tar -xvf mysql-8.0.11-1.el7.x86_64.rpm-bundle.tar -C ./mysql-8.0.11
cd mysql-8.0.11
yum -y  localinstall mysql-community-{server-8.0.11,client,common,libs}-* 


if [ $? == 0 ];then
	echo "安装mysql-#8.0.11 成功！"
else
	echo "安装mysql-8.0.11 失败，请检查后，重新安装！"
	cd ../;rm -rf ./mysql-8.0.11
	exit
fi

echo "#######################Mysql8.0.11 开始初始化###########################"
# mysql_install_db --datadir=/var/lib/mysql
mysqld --defaults-file=/etc/my.cnf --initialize-insecure --user=mysql --datadir=/var/lib/mysql
chown mysql:mysql /var/lib/mysql -R
systemctl enable mysqld
systemctl start mysqld

echo -e "mysql 默认密码是\033[1;31mMySQL未设置密码！\033[0m 请及时设置密码！"

echo "###########################配置自启动脚本##############################"
cp -rp ../check_mysql.sh /home/check_mysql.sh
echo "* * * * * root /bin/bash /home/check_mysql.sh  >/dev/null 2>&1"  >> /etc/crontab




