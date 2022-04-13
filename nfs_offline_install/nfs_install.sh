#!/bin/bash
# 离线安装 nfs

/usr/bin/tar  -zxvf  ./nfs_offline_install.tar.gz
cd nfs_offline_install
yum install -y ./*rpm

cd ../
cp -rp ./exports  /etc/

systemctl restart  rpcbind 
systemctl enable  rpcbind 
systemctl restart  nfs
systemctl enable  nfs

echo "#############################配置nfs自启动####################################"
cp  -rf  ./check_nfs.sh /home/check_nfs.sh

if [ $? == 0 ];then
	echo "* * * * * root /bin/bash /home/check_nfs.sh  >/dev/null 2>&1"  >> /etc/crontab
fi
