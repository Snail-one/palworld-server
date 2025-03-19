#!/bin/bash

echo -e "\e[1;33m==== 幻兽帕鲁服务器状态 ====\e[0m"

# 检查服务器进程
if pgrep -f "PalServer-Linux" > /dev/null; then
    echo -e "\e[1;32m[状态]\e[0m 服务器正在运行"
    
    # 获取进程ID
    PID=$(pgrep -f "PalServer-Linux")
    echo -e "\e[1;36m进程ID:\e[0m $PID"
    
    # 获取运行时间
    RUNTIME=$(ps -o etime= -p $PID)
    echo -e "\e[1;36m运行时间:\e[0m $RUNTIME"
    
    # 获取CPU和内存使用情况
    CPU_USAGE=$(ps -p $PID -o %cpu | tail -n 1 | tr -d ' ')
    MEM_USAGE=$(ps -p $PID -o %mem | tail -n 1 | tr -d ' ')
    echo -e "\e[1;36mCPU使用率:\e[0m $CPU_USAGE%"
    echo -e "\e[1;36m内存使用率:\e[0m $MEM_USAGE%"
    
    # 显示磁盘使用情况
    DISK_USAGE=$(df -h ${SERVER_DIR} | tail -n 1 | awk '{print $5}')
    echo -e "\e[1;36m磁盘使用率:\e[0m $DISK_USAGE"
    
    # 显示备份信息
    BACKUP_COUNT=$(find ${BACKUP_DIR} -name "palworld_*.tar.gz" | wc -l)
    LATEST_BACKUP=$(find ${BACKUP_DIR} -name "palworld_*.tar.gz" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)
    
    if [ ! -z "$LATEST_BACKUP" ]; then
        BACKUP_TIME=$(stat -c %y "$LATEST_BACKUP" | cut -d. -f1)
        BACKUP_SIZE=$(du -h "$LATEST_BACKUP" | cut -f1)
        echo -e "\e[1;36m备份数量:\e[0m $BACKUP_COUNT"
        echo -e "\e[1;36m最新备份:\e[0m $(basename "$LATEST_BACKUP")"
        echo -e "\e[1;36m备份时间:\e[0m $BACKUP_TIME"
        echo -e "\e[1;36m备份大小:\e[0m $BACKUP_SIZE"
    else
        echo -e "\e[1;33m[警告]\e[0m 尚未创建备份"
    fi
else
    echo -e "\e[1;31m[状态]\e[0m 服务器未运行"
fi 