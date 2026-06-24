#!/bin/bash
#磁盘使用率监控脚本
rate=$(df -h / | grep / awk '{print$5}| sed 's/%//g')

if [ ${rate} -ge 80 ]
then
	echo -e"\033[31m警告：磁盘使用率已达${rate}% ，请及时清理文件\033[0m"
else
	echo "磁盘使用率正常，当前占用${rate}%
fi
