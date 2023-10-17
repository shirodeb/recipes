#!/bin/bash
#echo $LANG
#if [ $LANG = zh_CN.UTF-8 ];then
#	zenity --info --title="警告!" --text="Wireshark绝大部分功能将需要使用root权限，请在了解安全风险后在弹窗内输入用户密码！" --width=350 --height=100
#	else
#	zenity --info --title="Warning!" --text="Most functions of the Wireshark requires root privileges，please enter your password in the pop-up window after understanding the security risks！" --width=350 --height=100
#fi

pkexec /opt/apps/org.wireshark/files/bin/wireshark
