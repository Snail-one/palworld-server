#!/bin/bash

echo -e "\e[1;33m=== 幻兽帕鲁服务器停止工具 ===\e[0m"

# 检查Docker是否已安装
if ! command -v docker &> /dev/null; then
    echo -e "\e[1;31m[错误]\e[0m Docker未安装！"
    exit 1
fi

# 检查Docker Compose是否已安装
if ! command -v docker-compose &> /dev/null; then
    echo -e "\e[1;31m[错误]\e[0m Docker Compose未安装！"
    exit 1
fi

# 检查服务器是否在运行
if ! docker ps | grep -q "palworld-server"; then
    echo -e "\e[1;33m[信息]\e[0m 幻兽帕鲁服务器未运行"
    exit 0
fi

# 优雅地停止服务器
echo -e "\e[1;33m[信息]\e[0m 正在优雅地停止幻兽帕鲁服务器..."
docker exec -it palworld-server /scripts/stop.sh

# 停止容器
echo -e "\e[1;33m[信息]\e[0m 停止Docker容器..."
docker-compose down

if [ $? -eq 0 ]; then
    echo -e "\e[1;32m[成功]\e[0m 幻兽帕鲁服务器已停止"
else
    echo -e "\e[1;31m[错误]\e[0m 服务器停止失败！"
    exit 1
fi 