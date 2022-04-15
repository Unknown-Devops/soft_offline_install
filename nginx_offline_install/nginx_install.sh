#!/bin/bash
# 离线安装nginx ，默认目录/usr/local/nginx ,日志轮转文件，/etc/logrotate.d/nginx

echo "########################     检查nginx 工作目录   ###############################"
if [  -d "/usr/local/nginx" ]; then
	echo  -e  " nginx 安装目录/usr/local/nginx 已经存在，请检查，并删除此目录，才可以继续安装！"
	exit 1
fi

echo "########################    检查nginx 启动账号 sshusr  ###############################"

echo -e '\033[1;32m 1.创建sshusr用户 \033[0m'
cat /etc/passwd |grep sshusr >/dev/null  2>&1
if [ $? -eq 0 ];then
	echo -e '\033[1;32m 已创建sshusr用户 \033[0m'
	echo "sshusr@12#$" |passwd --stdin sshusr >/dev/null  2>&1
	if [ $? -eq 0 ];then
		echo -e '\033[1;32m 更新sshusr用户密码成功！ \033[0m'
	fi
	
else
	useradd -m sshusr
	echo "sshusr@12#$" |passwd --stdin sshusr
fi

echo "########################开始配置nginx日志轮转压缩###############################"
cp -rf  ./nginx    /etc/logrotate.d/nginx   # 使用logrotate 进行日志轮转

echo "#####################在/usr/local/nginx编译安装nginx############################"
tar -zxf ./nginx.tar.gz  -C  /usr/local/
if [ `whoami`  == "root" ];then
	chown -R  sshusr:sshusr /usr/local/nginx
fi


echo "#############################配置nginx自启动####################################"
cp  -rf  ./check_nginx.sh /home/check_nginx.sh

if [ $? == 0 ];then
	echo "* * * * * sshusr /bin/bash /home/check_nginx.sh  >/dev/null 2>&1"  >> /etc/crontab
fi

