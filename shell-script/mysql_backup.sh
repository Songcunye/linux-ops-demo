#!/bin/bash
# MySQL自动备份，保留7天数据
DB_USER="root"
DB_PASS="你的数据库密码"
DB_NAME="test_db"
BACK_DIR="/data/mysql_back"
# 创建备份目录
mkdir -p $BACK_DIR
# 备份文件命名
BACK_FILE="$BACK_DIR/$DB_NAME-$(date +%Y%m%d).sql.gz"
# 备份压缩
mysqldump -u$DB_USER -p$DB_PASS $DB_NAME | gzip > $BACK_FILE
# 删除7天前备份
find $BACK_DIR -name "*.sql.gz" -mtime +7 -delete
echo "备份完成：$BACK_FILE"
