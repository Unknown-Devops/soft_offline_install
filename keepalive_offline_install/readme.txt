1、自动修改/etc/keepalive 配置文件， 执行方式为 sh  keepalive_install.sh  真实ip 真实端口  虚拟ip 虚拟端口
（VIP 改为虚拟ip  v_port 改为虚拟端口  RIP 改为真实ip ，r_port 改为后端监测服务的端口）

2、根据实际情况去掉原本计划任务中的定时任务，改为使用keepalive 监控

3、脚本中默认后端程序为nginx ，如果后端不是nginx ，需要修改/etc/keepalived/keepalived.conf 配置文件中的
notify_down /etc/keepalived/check_nginx.sh 中的脚本名
例如：
后端是mysql ，则改为
notify_down /etc/keepalived/check_mysql.sh
同时将mysql 监控脚本放到 /etc/keepalived/check_mysql.sh

4、启动keepalive 需要关闭防火墙，或者防火墙放通vrrp协议
firewall-cmd --direct --permanent --add-rule ipv4 filter INPUT 0 --in-interface  网卡名 --destination 224.0.0.18 --protocol vrrp -j ACCEPT 
firewall-cmd --reload

5、注意双活设备必须是同一个网段的，一台设备