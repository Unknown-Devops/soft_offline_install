#!/bin/bash
# check nfs

num_rpcbind=`ps -efww |grep "/sbin/rpcbind" |grep -v grep|wc -l`
num_nfs=`ps -efww |grep "nfsd" |grep -v grep|wc -l`

if [ $num_rpcbind -lt 1 ];then
    systemctl restart  rpcbind
fi

if [ $num_nfs -lt 2 ];then
    systemctl restart  nfs
fi



