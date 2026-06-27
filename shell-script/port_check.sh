#!/bin/bash
#端口监控脚本，检测80端口监听状态
port=80
#抓取端口监听信息
result=$(ss -tulnp | grep ${port})

if [ -z "${result}" ]
then
  echo -e "\033[31m警告：${port}端口无程序监听，服务已停止！\033[0m"
else
  echo "${port}端口运行正常，服务正在监听"
fi
