#!/bin/bash
# 离线安装mongoDB 4.4.5  

echo "##############################禁用SElinux#####################################"
setenforce 0
echo -e '\033[1;32m 修改 \033[1;33m /etc/selinux/config \033[0m 配置文件 \033[0m'
sed -i "s/enforcing/disabled/g" /etc/selinux/config

echo "######################## 开始离线安装 mongoDB-4.4.5  ###########################"

yum localinstall -y cyrus-*
yum localinstall -y mongodb-*


if [ $? == 0 ];then
	echo "安装mongoDB 4.4.5   成功！"
else
	echo "安装mongoDB 4.4.5  失败，请检查后，重新安装！"

fi

echo "######################## 开始启动 mongoDB-4.4.5 ###############################"

systemctl daemon-reload
systemctl start mongod
systemctl enable mongod
systemctl status mongod

echo "######################## 添加计划任务，每分钟检查一次mongodb进程是否存在，不存在自动拉起进程是否存在，不存在自动拉起 ###############################"
cp -rp  ./check_mongodb.sh  /home/check_mongodb.sh
echo "* * * * * root /bin/bash /home/check_mongodb.sh  >/dev/null 2>&1"  >> /etc/crontab

