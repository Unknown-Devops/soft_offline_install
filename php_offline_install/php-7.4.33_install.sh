#!/bin/bash
# 编译安装php7.4.33  目录 /usr/local/php/

MY_PATH=`pwd`

echo "########################检查php离线安装目录 /usr/local/php/ ###############################"
if [ ! -d "/usr/local/php/" ]; then
	   mkdir -p /usr/local/php/
else
	echo "####开始清空安装目录中其他内容####"
	rm -rf /usr/local/php/*
fi

echo "######################## 检查、创建www 用户###############################"

cat /etc/passwd |grep www >/dev/null  2>&1
if [ $? -eq 0 ];then
	echo -e '\033[1;32m 已创建www用户 \033[0m'
else
	/usr/sbin/groupadd www
	/usr/sbin/useradd -g www www
fi

echo "########################解压、编译安装安装php##############################################################"
/usr/bin/tar -zxf   php_rely.tar.gz
cd $MY_PATH/php_rely
yum install -y *rpm

cd $MY_PATH
unzip php-7.4.23-src.zip
cd php-7.4.23-src
chmod +x configure
chmod +x build/shtool

./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php --enable-mbstring --with-openssl --enable-ftp --with-gd --with-jpeg-dir=/usr --with-png-dir=/usr --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-pear --enable-sockets --with-freetype-dir=/usr --with-zlib --with-libxml-dir=/usr --with-xmlrpc --enable-zip --enable-fpm --enable-xml --enable-sockets --with-gd --with-zlib --with-iconv --enable-zip --with-freetype-dir=/usr/lib/ --enable-soap --enable-pcntl --enable-cli --with-curl

make && make install
if [ $? == 0 ];then
	echo "安装php7.4.33 成功！"
else
	echo "安装php7.4.33 失败！请检查后，重新安装！"
	exit
fi

echo "########################修改php配置###############################"
cp  -rp  $MY_PATH/php-7.4.23-src/php.ini-production  /usr/local/php/php.ini
cp  -rp  $MY_PATH/php-7.4.23-src/sapi/fpm/init.d.php-fpm  /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
cd /usr/local/php/etc
cp -rp php-fpm.conf.default php-fpm.conf
cp -rp /usr/local/php/etc/php-fpm.d/www.conf.default    /usr/local/php/etc/php-fpm.d/www.conf

sed -i "s#;pid = run/php-fpm.pid#pid = run/php-fpm.pid#g" /usr/local/php/etc/php-fpm.conf
sed -i "s#user = nobody#user = www#g"   /usr/local/php/etc/php-fpm.d/www.conf
sed -i "s#group = nobody#group = www#g"   /usr/local/php/etc/php-fpm.d/www.conf

# 加载环境变量
echo 'export PATH=/usr/local/php/bin:$PATH' >  /etc/profile.d/php.sh
source /etc/profile.d/php.sh


echo "########################启动php ###############################"
/etc/init.d/php-fpm start  

cp -rp $MY_PATH/check_php.sh  /home/check_php.sh
echo "* * * * * root /bin/bash  /home/check_php.sh  >/dev/null 2>&1"  >> /etc/crontab








