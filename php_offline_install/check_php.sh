#!/bin/bash
# check php

num1=`ps -efww | grep php-fpm |grep -v grep|wc -l`


if [ $num1 -lt 2 ];then
    /etc/init.d/php-fpm  restart  
fi



