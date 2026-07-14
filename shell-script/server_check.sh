#!/bin/bash
# 服务器巡检脚本：CPU、内存、磁盘、负载、端口
echo "====================服务器巡检报告 $(date)===================="
echo "1.系统负载："
uptime
echo -e "\n2.CPU使用率："
top -b -n 1 | grep Cpu
echo -e "\n3.内存使用："
free -h
echo -e "\n4.磁盘挂载使用率："
df -h | grep -v tmpfs
echo -e "\n5.当前监听端口："
ss -tulnp
echo "==========================================================":
