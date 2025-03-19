#!/bin/bash

echo -e "\e[1;33m[信息]\e[0m 设置自动备份任务..."

# 备份频率 (小时)
BACKUP_INTERVAL=${BACKUP_INTERVAL:-"6"}
# 备份保留数量
BACKUP_RETENTION=${BACKUP_RETENTION:-"10"}

# 检查是否启用备份
if [ "${ENABLE_BACKUPS}" != "true" ]; then
    echo -e "\e[1;33m[信息]\e[0m 自动备份功能已禁用，跳过设置备份任务"
    exit 0
fi

echo -e "\e[1;33m[信息]\e[0m 配置用户级别cron任务，每${BACKUP_INTERVAL}小时进行一次备份"

# 创建用户cron配置
CRON_FILE="/home/palworld/cron_jobs/palworld-backup"

# 创建cron任务到用户目录
cat > ${CRON_FILE} << EOF
# 每${BACKUP_INTERVAL}小时运行一次备份
0 */${BACKUP_INTERVAL} * * * /scripts/backup.sh auto >> ${SERVER_DIR}/Logs/backup.log 2>&1
# 每天0点进行一次日备份
0 0 * * * /scripts/backup.sh daily >> ${SERVER_DIR}/Logs/backup.log 2>&1
# 每周日0点进行一次周备份
0 0 * * 0 /scripts/backup.sh weekly >> ${SERVER_DIR}/Logs/backup.log 2>&1
EOF

# 将cron任务导入到用户crontab
crontab ${CRON_FILE}

echo -e "\e[1;32m[成功]\e[0m 自动备份任务设置完成"
echo -e "\e[1;36m备份间隔:\e[0m 每${BACKUP_INTERVAL}小时"
echo -e "\e[1;36m每日备份:\e[0m 每天0点"
echo -e "\e[1;36m每周备份:\e[0m 每周日0点" 