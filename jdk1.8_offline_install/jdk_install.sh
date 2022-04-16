#!/bin/bash
# 离线安装jdk-8u291  目录 /usr/local/java

echo "########################检查jdk-8u291 离线安装目录 /usr/local/java ###############################"
if [ ! -d "/usr/local/java" ]; then
	   mkdir -p /usr/local/java
else
	echo "####开始清空安装目录中其他内容####"
	rm -rf /usr/local/java/*
fi

echo "########################解压、离线安装jdk-8u291 ###############################"

tar -zxvf jdk-8u291-linux-x64.tar.gz  -C /usr/local/java/

cat <<EOF >> /etc/profile
export JAVA_HOME=/usr/local/java/jdk1.8.0_291/
export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
export PATH=\$PATH:\$JAVA_HOME/bin
EOF

unset i
unset -f pathmunge

source /etc/profile 

echo "########################检查java 版本 ###############################"

java -version