#!/bin/bash
# 离线安装LibreOffice7.0.6

myPath=`pwd`
echo "######################## 开始离线安装 LibreOffice7.0.6  ###########################"

tar -zxvf LibreOffice_7.0.6_Linux_x86-64_rpm.tar.gz
tar -zxvf LibreOffice_7.0.6_Linux_x86-64_rpm_langpack_zh-CN.tar.gz

mv LibreOffice_7.0.6.2_Linux_x86-64_rpm/ /usr/local/
mv LibreOffice_7.0.6.2_Linux_x86-64_rpm_langpack_zh-CN /usr/local/

unzip library.zip
cd library
yum localinstall -y *rpm

cd /usr/local/LibreOffice_7.0.6.2_Linux_x86-64_rpm/RPMS/
yum localinstall -y lib*
ldconfig

if [ $? == 0 ];then
	echo "安装LibreOffice7.0.6  成功！"
else
	echo "安装LibreOffice7.0.6 失败，请检查后，重新安装！"

fi

ls -tha  `which libreoffice7.0` 
echo "######################## 开始安装 LibreOffice7.0.6 中文语言包 ###############################"
cd /usr/local/LibreOffice_7.0.6.2_Linux_x86-64_rpm_langpack_zh-CN/RPMS/

yum localinstall -y  *rpm
if [ $? == 0 ];then
	echo "安装LibreOffice7.0.6中文包  成功！"
else
	echo "安装LibreOffice7.0.6中文包 失败，请检查后，重新安装！"

fi
echo "######################## 开始安装中文字体 ###############################"
cd $myPath
unzip  fonts.zip
mv zhFonts   /usr/share/fonts/
mkfontscale;mkfontdir;fc-cache
