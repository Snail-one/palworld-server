#!/bin/bash

echo -e "\e[1;33m[信息]\e[0m 正在停止幻兽帕鲁服务器..."

# 检查服务器进程
if pgrep -f "PalServer-Linux" > /dev/null; then
    # 获取进程ID
    PID=$(pgrep -f "PalServer-Linux")
    
    # 先尝试优雅地关闭服务器
    if [ ! -z "${RCON_ENABLED}" ] && [ "${RCON_ENABLED}" = "true" ] && [ ! -z "${RCON_PORT}" ]; then
        echo -e "\e[1;33m[信息]\e[0m 尝试通过RCON优雅关闭服务器..."
        # 未实现RCON功能，所以简单延迟后发送SIGTERM信号
        sleep 5
    fi
    
    # 发送SIGTERM信号
    echo -e "\e[1;33m[信息]\e[0m 发送停止信号给进程ID: $PID"
    kill -15 $PID
    
    # 等待服务器关闭
    echo -e "\e[1;33m[信息]\e[0m 等待服务器关闭..."
    for i in {1..60}; do
        if ! pgrep -f "PalServer-Linux" > /dev/null; then
            echo -e "\e[1;32m[成功]\e[0m 服务器已经成功停止"
            
            # 创建停止后备份
            if [ "${BACKUP_ON_STOP}" = "true" ]; then
                echo -e "\e[1;33m[信息]\e[0m 创建停止前备份..."
                /scripts/backup.sh stop
            fi
            
            exit 0
        fi
        sleep 1
    done
    
    # 如果超时，则强制关闭
    echo -e "\e[1;31m[警告]\e[0m 服务器未能在预期时间内关闭，正在强制终止..."
    kill -9 $PID
    
    if ! pgrep -f "PalServer-Linux" > /dev/null; then
        echo -e "\e[1;32m[成功]\e[0m 服务器已经被强制停止"
    else
        echo -e "\e[1;31m[错误]\e[0m 无法停止服务器"
        exit 1
    fi
else
    echo -e "\e[1;33m[信息]\e[0m 服务器未运行"
fi 