#!/bin/bash

set -euo pipefail

# 检查Docker是否已安装
if ! command -v docker &> /dev/null; then
    echo -e "\e[1;31m[错误]\e[0m Docker未安装！"
    echo -e "\e[1;33m[信息]\e[0m 请先安装Docker和Docker Compose"
    exit 1
fi

# 检查 Docker Compose 命令
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD=(docker-compose)
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD=(docker compose)
else
    echo -e "\e[1;31m[错误]\e[0m Docker Compose 未安装！"
    echo -e "\e[1;33m[信息]\e[0m 请安装 Docker Compose v2，或提供 docker-compose 命令"
    exit 1
fi

# 创建目录
mkdir -p 777 palworld

echo -e "\e[1;33m[信息]\e[0m 启动幻兽帕鲁服务器..."
"${DOCKER_COMPOSE_CMD[@]}" up -d
echo -e "\e[1;32m[成功]\e[0m 幻兽帕鲁服务器已启动"
echo -e "\e[1;36m状态:\e[0m docker exec -it palworld-server /scripts/status.sh"
echo -e "\e[1;36m日志:\e[0m docker logs -f palworld-server"
