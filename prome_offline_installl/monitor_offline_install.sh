#!/bin/bash
# 离线安装docker 和 prometheus  grafana，alertmanager 

my_path=`pwd`


echo "########################  安装docker   ###############################"
tar -zxf $my_path/docker_rpm.tar.gz
cd $my_path/docker_rpm

rpm -ivhU * --nodeps --force
systemctl enable docker
systemctl start docker
systemctl status docker

if [ $? != 0 ];then
	echo -e "docker  安装异常，请检查！"
	exit
fi 

docker load < $my_path/monitor.tar

if [ $? != 0 ];then
	echo -e "docker 镜像导入异常，请检查！"
	exit
fi 

echo "########################  安装prometheus，grafana，alertmanager ###############################"
cd $my_path
mkdir -p  /data/prometheus/data
mkdir -p  /data/alertmanager
mkdir -p  /data/grafana/data

cp -rp  $my_path/grafana.ini /data/grafana/
tar -zxf $my_path/grafana_data.tar.gz 
mv $my_path/data/grafana/data/*  /data/grafana/data/
tar -zxf $my_path/prometheus_data.tar.gz
mv $my_path/prometheus_data/*   /data/prometheus/
mv $my_path/alertmanager.yml /data/alertmanager/alertmanager.yml

docker run  -d -p 9090:9090  -u root --restart=always  -v /data/prometheus/data:/prometheus \
-v /data/prometheus:/etc/prometheus \
-v /etc/localtime:/etc/localtime:ro \
--name prometheus prom/prometheus

docker run  -d  -p 3000:3000 -u root --restart=always  -v "/data/grafana/grafana.ini:/etc/grafana/grafana.ini" \
-v "/data/grafana/data/:/var/lib/grafana" \
-v /etc/localtime:/etc/localtime:ro \
 --name grafana grafana/grafana
 
docker run -d  -p 9093:9093 -u root --restart=always  -v /data/alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
-v /etc/localtime:/etc/localtime:ro \
 --name alertmanager prom/alertmanager:latest

 




