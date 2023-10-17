#!/bin/bash
#echo $LANG
if [ $LANG = zh_CN.UTF-8 ];then
	zenity --info --title="警告!" --text="没有root权限的Wireshark基本什么都无法进行！" --width=350 --height=100
	else
	zenity --info --title="Warning!" --text="You could almost do nothing using Wireshark without root privileges！" --width=350 --height=100
fi

exec /opt/apps/org.wireshark/files/bin/wireshark