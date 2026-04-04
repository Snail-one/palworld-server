#!/bin/bash

set -euo pipefail

echo -e "\e[1;32m[信息]\e[0m 初始化幻兽帕鲁服务器..."

# 检查服务器安装
if [ ! -f "${SERVER_DIR}/PalServer.sh" ]; then
    echo -e "\e[1;33m[信息]\e[0m 服务器未安装，开始安装..."
    /scripts/install.sh
else
    if [ "${CHECK_UPDATE}" = "true" ]; then
        echo -e "\e[1;33m[信息]\e[0m 检查服务器更新..."
        /scripts/update.sh
    fi
fi

# 设置服务器配置
echo -e "\e[1;33m[信息]\e[0m 检查服务器配置..."
/scripts/setup_config.sh

# 启动服务器
echo -e "\e[1;32m[信息]\e[0m 启动幻兽帕鲁服务器..."
exec /scripts/start.sh 
