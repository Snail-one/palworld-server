#!/bin/bash

set -euo pipefail

# 检查Docker是否已安装
if ! command -v docker &> /dev/null; then
    echo -e "\e[1;31m[错误]\e[0m Docker未安装！"
    exit 1
fi

# 检查 Docker Compose 命令
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD=(docker-compose)
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD=(docker compose)
else
    echo -e "\e[1;31m[错误]\e[0m Docker Compose 未安装！"
    exit 1
fi

# 检查服务器是否在运行
if ! docker ps | grep -q "palworld-server"; then
    echo -e "\e[1;33m[信息]\e[0m 幻兽帕鲁服务器未运行"
    exit 0
fi

# 停止容器
echo -e "\e[1;33m[信息]\e[0m 停止Docker容器..."
"${DOCKER_COMPOSE_CMD[@]}" down
echo -e "\e[1;32m[成功]\e[0m 幻兽帕鲁服务器已停止"
