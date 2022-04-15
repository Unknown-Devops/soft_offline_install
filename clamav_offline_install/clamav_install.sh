#!/bin/bash
# 离线安装clamav，默认目录/usr/local/clamav 

MY_PATH=`pwd`
echo "#####################在/usr/local/clamav 编译安装clamav############################"
# 创建用户
groupadd clamav && useradd -g clamav clamav && id clamav
# 创建工作目录

if	[ !  -d /usr/local/clamav ];then
	tar xf $MY_PATH/clamav.tar.gz  -C /usr/local/
else
	rm -rf /usr/local/clamav
	tar xf $MY_PATH/clamav.tar.gz  -C /usr/local/
fi
chown -R clamav.clamav  /usr/local/clamav

if [  $? == 0 ];then
	echo -e "clamav 安装成功！"
else
	echo -e "clamav 安装失败！"
	exit
fi


echo "############################# clamav 启动 ####################################"
# 更新病毒库
/usr/local/clamav/bin/freshclam 

cp -rp  $MY_PATH/clamav-freshclam.service   /usr/lib/systemd/system/
systemctl daemon-reload
#  启动clamav
systemctl start clamav-freshclam.service
systemctl enable clamav-freshclam.service 
systemctl status clamav-freshclam.service
ln -s /usr/local/clamav/bin/clamscan  /usr/local/sbin/clamscan

cat <<EOF >>/etc/crontab
1 2  * * *  root  /usr/local/clamav/bin/freshclam --quiet
1 3  * * *  root  /usr/local/clamav/bin/clamscan  -r   -i  -l  /usr/local/clamav/logs/clamscan_result.log
EOF
