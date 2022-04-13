#!/bin/bash
# 编译安装redis  目录 /usr/local/redis

echo "########################检查redis离线安装目录 /usr/local/redis ###############################"
if [ ! -d "/usr/local/redis" ]; then
	   mkdir -p /usr/local/redis/{etc,logs,data}   
else
	echo "####开始清空安装目录中其他内容####"
	rm -rf /usr/local/redis/*
	mkdir -p /usr/local/redis/{etc,logs,data} 
fi

echo "########################解压、编译安装安装redis###############################"
cp -rp ./check_redis.sh /usr/local/redis/
tar -zxvf redis-6.2.1.tar.gz
cd redis-6.2.1;make && make  PREFIX=/usr/local/redis/ install 

if [ $? != 0 ];then
	gcc_version=`gcc -v  2>&1 |grep "gcc version" |awk '{print $3}' `
	if [ $gcc_version == '9.3.1' ];then
		echo "gcc 版本正常，请检查其他编译问题！"
	else
		echo"编译失败，请检查gcc版本是否为9.X！"
		exit
	fi
fi

echo "########################修改redis配置###############################"
cp  -rp ./redis.conf /usr/local/redis/etc/

sed -i "s/bind 127.0.0.1/bind 0.0.0.0/g" /usr/local/redis/etc/redis.conf     # 改为全局监听
sed -i "s/protected-mode yes/protected-mode no/g" /usr/local/redis/etc/redis.conf  # 开启redis  密码
sed -i "s/daemonize no/daemonize yes/g" /usr/local/redis/etc/redis.conf		 # 设置后台运行
sed -i "s/pidfile \/var\/run\/redis_6379.pid/pidfile \/usr\/local\/redis\/redis.pid/g" /usr/local/redis/etc/redis.conf  # 设置pid位置为/usr/local/redis
sed -i "s/dir \.\//dir \/usr\/local\/redis\/data/g" /usr/local/redis/etc/redis.conf  # 设置数据存储文件位置为/usr/local/redis/data
sed -i "s/logfile \"\"/logfile \"\/usr\/local\/redis\/logs\/redis.log\"/g" /usr/local/redis/etc/redis.conf    # 设置日志位置为 /usr/local/redis/logs
sed -i "s/# requirepass foobared/requirepass Redis-prod/g" /usr/local/redis/etc/redis.conf     # 设备密码为Redis-prod

echo "########################加载环境变量###############################"
echo "export PATH=${PATH}:/usr/local/redis/bin" >>/etc/profile
source /etc/profile

echo "######################## 检查、创建sshusr 用户###############################"

echo -e '\033[1;32m 1.创建sshusr用户 \033[0m'
cat /etc/passwd |grep sshusr >/dev/null  2>&1
if [ $? -eq 0 ];then
	echo -e '\033[1;32m 已创建sshusr用户 \033[0m'
	echo "Ysshusr-0412" |passwd --stdin sshusr >/dev/null  2>&1
	if [ $? -eq 0 ];then
		echo -e '\033[1;32m 更新sshusr用户密码成功！ \033[0m'
	fi
	cat /etc/sudoers |grep sshusr >/dev/null  2>&1
	if [ $? -eq 0 ];then
		echo -e '\033[1;32m sshusr用户已加入sudoers \033[0m'
	else
		echo "sshusr ALL=(ALL)   NOPASSWD: ALL" >> /etc/sudoers  # 允许普通用户sshusr sudo su root
	fi
else
	useradd -m sshusr
	echo "Ysshusr-0412" |passwd --stdin sshusr
	echo "sshusr ALL=(ALL)   NOPASSWD: ALL" >> /etc/sudoers  # 允许普通用户sshusr sudo su root
	sed  -i "s/Defaults    requiretty/#Defaults    requiretty/g"  /etc/sudoers
fi

echo "######################## 启动redis ###############################"
chown -R sshusr:sshusr /usr/local/redis
su - sshusr -c "/usr/local/redis/bin/redis-server /usr/local/redis/etc/redis.conf"

echo "######################## 添加计划任务，每分钟检查一次redis进程是否存在，不存在自动拉起 ###############################"
echo "* * * * * sshusr /bin/bash /usr/local/redis/check_redis.sh  >/dev/null 2>&1"  >> /etc/crontab


