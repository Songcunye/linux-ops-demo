#!/bin/bash
# 获取根分区磁盘使用率
rate=$(df -h / | grep / | awk '{print $5}' | sed 's/%//g')

# 判断阈值，超过80%发出告警
if [ ${rate} -ge 80 ]
then
  echo -e "\033[31m警告：磁盘使用率已达到${rate}%，请及时清理垃圾文件\033[0m"
else
  echo "磁盘使用率正常，当前占用：${rate}%"
fi
