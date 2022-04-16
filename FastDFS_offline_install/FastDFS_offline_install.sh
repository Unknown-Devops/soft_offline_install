#!/bin/bash
# 离线安装FastDFS 目录 /data/fastdfs  

my_path=`pwd`
network_name=`ip a |grep 'UP' |egrep -v 'lo|DOWN' |awk -F" |:" '{print $3}'`
server_ip=`ip a |grep $network_name |grep inet|awk  -F' |/' '{print $6}'`  


echo "########################检查fastDFS 离线安装目录 /data/fastdfs ###############################"
if [ ! -d "/data/fastdfs/" ]; then
		mkdir -p /data/fastdfs/tracker_data/data
		mkdir -p /data/fastdfs/storage_data/logs
		mkdir -p /data/fastdfs/store_path/data
else
	echo "####/data/fastdfs/fdfs_conf 已存在####"
fi

if [ ! -d  "/etc/fdfs/" ]; then
	echo "#### /etc/fdfs/ 不存在####"	
else	
	rm  -rf  /etc/fdfs/
fi

if [ ! -d  "/usr/local/fastdFS_nginx/" ]; then
		mkdir -p /usr/local/fastdFS_nginx/
else
	echo "#### /usr/local/fastdFS_nginx/conf 已存在####"
fi

echo "######################## 配置fastDFS ###############################"
cp -rp fdfs_conf  /data/fastdfs/
cp -rp fdfs  /etc/
cp -rp conf  /usr/local/fastdFS_nginx/

sed -i "s/bind_addr=SERVER_IP/bind_addr=$server_ip/g" /data/fastdfs/fdfs_conf/tracker.conf
sed -i "s/tracker_server=SERVER_IP:22122/tracker_server=$server_ip:22122/g" /data/fastdfs/fdfs_conf/storage.conf
sed -i "s/tracker_server=SERVER_IP:22122/tracker_server=$server_ip:22122/g" /data/fastdfs/fdfs_conf/mod_fastdfs.conf
sed -i "s/tracker_server=SERVER_IP:22122/tracker_server=$server_ip:22122/g" /data/fastdfs/fdfs_conf/client.conf


sed -i "s/bind_addr=SERVER_IP/bind_addr=$server_ip/g" /etc/fdfs/tracker.conf
sed -i "s/tracker_server=SERVER_IP:22122/tracker_server=$server_ip:22122/g" /etc/fdfs/storage.conf
sed -i "s/tracker_server=SERVER_IP:22122/tracker_server=$server_ip:22122/g" /etc/fdfs/mod_fastdfs.conf
mv /etc/fdfs/client.conf   /etc/fdfs/client.confbak
cp -rp  /data/fastdfs/fdfs_conf/client.conf  /etc/fdfs/



echo "########################  安装docker   ###############################"
cd fastDFS_docker
tar -zxvf docker_rpm.tar.gz

rpm -ivh ./docker_rpm/*rpm --nodeps --force

systemctl enable docker
systemctl start docker
systemctl status docker

if [ $? != 0 ];then
	echo -e "docker  安装异常，请检查！"
	exit
fi 

docker load < $my_path/fastdfs_delron.tar

if [ $? != 0 ];then
	echo -e "docker 镜像导入异常，请检查！"
	exit
fi 

docker tag 8487e86fc6ee delron/fastdfs:latest


echo "######################## 启动tracker 和storage ###############################"
docker run -tid   --restart=always --name  tracker \
-v /data/fastdfs/tracker_data/data:/fastdfs/tracker/data \
-v /data/fastdfs/fdfs_conf:/fdfs_conf \
--privileged=true \
--net=host  delron/fastdfs  tracker


docker run -ti -d   --restart=always  --name storage -v /data/fastdfs/store_path/:/var/fdfs/ -v /etc/fdfs/:/etc/fdfs/  -v /usr/local/fastdFS_nginx/conf:/usr/local/nginx/conf  --net=host delron/fastdfs   storage

firewall-cmd --zone=public --permanent --add-port=8888/tcp
firewall-cmd --zone=public --permanent --add-port=22122/tcp
firewall-cmd --zone=public --permanent --add-port=23001/tcp
firewall-cmd --reload

PROCESS_NUM=`/usr/bin/docker ps -a  |grep -E 'tracker|storage' |wc -l`
if [ $PROCESS_NUM == 2 ];then
	echo -e "docker fastdfs 安装成功，请根据readme中提示进行测试！"
	exit 0
fi 




