#!/bin/bash
# 离线升级openssh8.4

echo "###########################   检查用户、安装包、准备安装环境   #############################"
if [ $(id -u) != "0" ]; then
    echo "请使用root执行脚本!! "
    exit 1
fi

# 获取工作目录
myPath=`pwd`

#检查安装包：
openssh="openssh-8.4p1"
openssl="openssl-1.1.1k"

if [ ! -f ${openssh}.tar.gz ]
then
  echo ' openssh安装包不存在，请检查'
else
  echo ' openssh 已下载'
fi

if [ ! -f ${openssl}.tar.gz ]
then
  echo ' openssl 安装包不存在，请检查'
else
  echo 'openssl 已下载'
fi

#检查，安装依赖包
if [ ! -f soft.tar.gz ]
then
  echo ' 相关依赖包不存在，请检查'
else
  echo '依赖包已下载'
  tar  -zxvf  soft.tar.gz;cd soft ;yum localinstall   -y   ./*rpm
fi

cd $myPath

systemctl enable xinetd.service
systemctl enable telnet.socket
systemctl start telnet.socket
systemctl start xinetd.service

echo -e 'pts/0\npts/1\npts/2\npts/3'  >>/etc/securetty

systemctl restart xinetd.service
echo "telnet 启动成功"
sleep 3

echo "###########################开始升级OPENSSL#############################"
tar xfz ${openssl}.tar.gz
echo "备份OpenSSL..."
mv /usr/bin/openssl /usr/bin/openssl_bak
mv /usr/include/openssl /usr/include/openssl_bak

echo "开始安装OpenSSL..."
sleep 3
cd ${openssl}
./config shared --prefix=/usr/local/openssl  && make && make install
# 注意如果之前编译过openssl 可能无法覆盖，需要更换目录

if [ $? -eq 0 ] ;then
	echo "openssl安装成功..."
else
	echo -e "openssl 安装失败，请检查！" && exit 1
fi

ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/openssl/include/openssl /usr/include/openssl
echo "加载动态库..."
echo "/usr/local/openssl/lib" >> /etc/ld.so.conf
/sbin/ldconfig
echo "查看确认版本。。。"
openssl version
echo "OpenSSL 升级完成..."
sleep 5

echo "###########################    开始升级OPENSSH     #############################"
cd $myPath
/usr/bin/tar -zxvf ${openssh}.tar.gz
cd ${openssh}
chown -R root.root ${openssh}
./configure --prefix=/usr/ --sysconfdir=/etc/ssh  --with-openssl-includes=/usr/local/openssl/include \
 --with-ssl-dir=/usr/local/openssl/   --with-zlib   --with-md5-passwords   --with-pam  && make && make install

if [ $? -eq 0 ] ;then
	echo "openssh安装成功..."
else
	echo -e "openssh 安装失败，请检查！" && exit 1
fi

cp -a contrib/redhat/sshd.init /etc/init.d/sshd
cp -a contrib/redhat/sshd.pam /etc/pam.d/sshd.pam
chmod +x /etc/init.d/sshd
systemctl enable sshd

# sshd服务添加为启动项 ...
mv  /usr/lib/systemd/system/sshd.service  /tmp/
systemctl restart sshd.service
ss  -lntp
echo "查看SSH版本信息。。。"
ssh -V
sleep 3
echo "telnet服务关闭..."
systemctl disable xinetd.service
systemctl stop xinetd.service
systemctl disable telnet.socket
systemctl stop telnet.socket
# echo "所有服务升级完成，进行堡垒机连接测试..."
sleep 3
# centOS7.4升级openssh8.4
echo "修改ssh配置..."
rm -f /etc/ssh/*host*

sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
cat /etc/ssh/sshd_config|grep -v "#"  |grep -v "^$" |grep -E "PasswordAuthenticatio|PubkeyAuthentication|PermitRootLogin"
# echo "PermitRootLogin no"  >> /etc/ssh/sshd_config
service sshd restart
