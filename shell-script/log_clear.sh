#!/bin/bash
# 清理30天日志文件
LOG_PATH="/var/log"
# 删除30天以上.log日志
find $LOG_PATH -type f -name "*.log" -mtime +30 -delete
echo "日志清理完成，清理路径：$LOG_PATH"
