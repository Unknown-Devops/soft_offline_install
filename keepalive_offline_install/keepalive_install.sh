#!/bin/bash
# 离线安装keepalive

RIP=$1
r_port=$2

VIP=$3
v_port=$4

RouteID=`echo $VIP |awk -F'.' '{print $4}'`
NetCard=`/usr/sbin/ip a |grep $RIP  |awk '{print $NF}'`

echo "########################开始离线安装keepalive ###############################"
tar -zxvf keepalive.tar.gz -C ./
cd keepalive
rpm -ivh lm_sensors-libs-3.4.0-8.20160601gitf9185e5.el7.x86_64.rpm
rpm -ivh net-snmp-*
rpm -ivh ipset-libs-7.1-1.el7.x86_64.rpm
rpm -ivh libnl-1.1.4-3.el7.x86_64.rpm
# rpm -ivh keepalived-1.3.5-19.el7.x86_64.rpm
rpm -ivh keepalived-2.0.7-1.el7.x86_64.rpm
echo "########################调整 keepalive 配置 ###############################"
# 开启keepalive日志
sed -i 's/KEEPALIVED_OPTIONS="-D"/KEEPALIVED_OPTIONS="-D -d -S 0"/g' /etc/sysconfig/keepalived
sed -i  '/local7/a\local0\.\*                     /var/log/keepalived.log '  /etc/rsyslog.conf   
service rsyslog restart 


cp   -rp   ../check_nginx.sh    /etc/keepalived/check_nginx.sh    # 更换为需要使用的监控脚本
chmod +x    /etc/keepalived/check_nginx.sh

cp -rp  ../keepalived.conf /etc/keepalived/keepalived.conf


# 启动keepalive 需要关闭防火墙，或者防火墙放通vrrp协议
firewall-cmd --direct --permanent --add-rule ipv4 filter INPUT 0 --in-interface  $NetCard --destination 224.0.0.18 --protocol vrrp -j ACCEPT 
firewall-cmd --reload


# 修改配置
sed -i "s/RIP/$RIP/g" /etc/keepalived/keepalived.conf
sed -i "s/VIP/$VIP/g" /etc/keepalived/keepalived.conf
sed -i "s/r_port/$r_port/g" /etc/keepalived/keepalived.conf
sed -i "s/v_port/$v_port/g" /etc/keepalived/keepalived.conf
sed -i "s/RouteID/$RouteID/g" /etc/keepalived/keepalived.conf
sed -i "s/NetCard/$NetCard/g" /etc/keepalived/keepalived.conf

systemctl  start keepalived
systemctl  enable  keepalived