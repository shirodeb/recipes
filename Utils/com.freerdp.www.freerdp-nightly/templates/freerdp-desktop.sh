#!/bin/bash

export LD_LIBRARY_PATH=/opt/apps/com.freerdp.www.freerdp-nightly/files/lib/
EXEC="/opt/apps/com.freerdp.www.freerdp-nightly/files/bin/xfreerdp"

PROMPT_ZH="FreeRDP是一个命令行程序\n您可以在终端中通过xfreerdp命令使用。或者通过本包装脚本。\n请问是否需要简易链接选项？选择否可以自行输入命令行参数"

if zenity --question --no-wrap --text="$PROMPT_ZH"; then
    cred=$(zenity --forms --text="请输入远程桌面链接登入信息\n（请不要输入|符号 ）" --add-entry="地址" --add-entry="用户名" --add-password="密码")
    if [ $? = "1" ]; then
        exit
    fi
    echo $cred | awk -F'|' '{print "/u:" $2 " /p:" $3 " /v:" $1}' | xargs $EXEC
else
    cmdline=$(zenity --entry --text="请输入命令行参数")
    if [ $? = "1" ]; then
        exit
    fi
    echo $cmdline | xargs $EXEC
fi
