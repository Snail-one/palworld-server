#!/bin/bash

# 备份类型 (可以是 daily, weekly, manual, pre-update 等)
BACKUP_TYPE=${1:-"manual"}
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME="palworld_${BACKUP_TYPE}_${DATE}.tar.gz"

# 检查是否启用备份
if [ "${ENABLE_BACKUPS}" != "true" ] && [ "${BACKUP_TYPE}" != "manual" ] && [ "${BACKUP_TYPE}" != "pre-update" ]; then
    echo -e "\e[1;33m[信息]\e[0m 自动备份功能已禁用，跳过备份"
    exit 0
fi

echo -e "\e[1;33m[信息]\e[0m 创建备份: $BACKUP_NAME"

# 确保备份目录存在
mkdir -p ${BACKUP_DIR}

# 检查是否存在保存目录
if [ ! -d "${SERVER_DIR}/Pal/Saved" ]; then
    echo -e "\e[1;31m[错误]\e[0m 未找到保存文件夹，备份失败"
    exit 1
fi

# 备份重要文件
echo -e "\e[1;33m[信息]\e[0m 压缩备份文件..."
tar -czf ${BACKUP_DIR}/${BACKUP_NAME} -C ${SERVER_DIR}/Pal/Saved .

# 检查备份结果
if [ $? -eq 0 ]; then
    # 获取备份文件大小
    BACKUP_SIZE=$(du -h ${BACKUP_DIR}/${BACKUP_NAME} | cut -f1)
    echo -e "\e[1;32m[成功]\e[0m 备份完成！文件大小: $BACKUP_SIZE"
    
    # 备份保留数量
    BACKUP_RETENTION=${BACKUP_RETENTION:-"10"}
    
    # 清理旧备份
    if [ "$(ls -1 ${BACKUP_DIR}/palworld_${BACKUP_TYPE}_*.tar.gz 2>/dev/null | wc -l)" -gt ${BACKUP_RETENTION} ]; then
        echo -e "\e[1;33m[信息]\e[0m 清理旧备份文件（保留最新${BACKUP_RETENTION}个）..."
        ls -1t ${BACKUP_DIR}/palworld_${BACKUP_TYPE}_*.tar.gz | tail -n +$((BACKUP_RETENTION+1)) | xargs -r rm
        echo -e "\e[1;32m[成功]\e[0m 已清理旧备份"
    fi
else
    echo -e "\e[1;31m[错误]\e[0m 备份失败！"
    exit 1
fi 