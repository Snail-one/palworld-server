#!/bin/bash

echo -e "\e[1;36m"
cat << "EOF"
██████╗  █████╗ ██╗     ██╗    ██╗ ██████╗ ██████╗ ██╗     ██████╗
██╔══██╗██╔══██╗██║     ██║    ██║██╔═══██╗██╔══██╗██║     ██╔══██╗
██████╔╝███████║██║     ██║ █╗ ██║██║   ██║██████╔╝██║     ██║  ██║
██╔═══╝ ██╔══██║██║     ██║███╗██║██║   ██║██╔══██╗██║     ██║  ██║
██║     ██║  ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║███████╗██████╔╝
╚═╝     ╚═╝  ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═════╝
EOF
echo -e "\e[0m"
echo -e "\e[1;33m=== 幻兽帕鲁服务器启动工具 ===\e[0m"

# 检查Docker是否已安装
if ! command -v docker &> /dev/null; then
    echo -e "\e[1;31m[错误]\e[0m Docker未安装！"
    echo -e "\e[1;33m[信息]\e[0m 请先安装Docker和Docker Compose"
    exit 1
fi

# 检查Docker Compose是否已安装
if ! command -v docker-compose &> /dev/null; then
    echo -e "\e[1;31m[错误]\e[0m Docker Compose未安装！"
    echo -e "\e[1;33m[信息]\e[0m 请先安装Docker Compose"
    exit 1
fi

# 创建目录
mkdir -p server-data

echo -e "\e[1;33m[信息]\e[0m 启动幻兽帕鲁服务器..."
docker-compose up -d

if [ $? -eq 0 ]; then
    echo -e "\e[1;32m[成功]\e[0m 幻兽帕鲁服务器已启动"
    echo -e "\e[1;33m[信息]\e[0m 您可以通过以下命令查看服务器状态：\e[0m"
    echo -e "\e[1;36mdocker exec -it palworld-server /scripts/status.sh\e[0m"
    echo -e "\e[1;33m[信息]\e[0m 您可以通过以下命令查看服务器日志：\e[0m"
    echo -e "\e[1;36mdocker logs -f palworld-server\e[0m"
else
    echo -e "\e[1;31m[错误]\e[0m 服务器启动失败！"
    exit 1
fi 