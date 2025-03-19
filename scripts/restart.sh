#!/bin/bash

echo -e "\e[1;33m[信息]\e[0m 正在重启幻兽帕鲁服务器..."

# 先停止服务器
echo -e "\e[1;33m[信息]\e[0m 停止服务器..."
/scripts/stop.sh

# 检查停止结果
if [ $? -eq 0 ]; then
    # 检查是否需要更新
    if [ "${CHECK_UPDATE_ON_RESTART}" = "true" ]; then
        echo -e "\e[1;33m[信息]\e[0m 检查服务器更新..."
        /scripts/update.sh
    fi
    
    # 启动服务器
    echo -e "\e[1;33m[信息]\e[0m 重新启动服务器..."
    /scripts/start.sh
else
    echo -e "\e[1;31m[错误]\e[0m 服务器重启失败！无法正常停止服务器"
    exit 1
fi 