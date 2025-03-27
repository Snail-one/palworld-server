#!/bin/bash

# 从环境变量读取配置
IPV6_GAME_PORT="${IPV6_GAME_PORT:-8211}"
IPV4_GAME_PORT="${SERVER_PORT:-8211}"

# 启用 IPv6 端口转发
echo "Starting IPv6 to IPv4 port forwarding..."
socat UDP6-LISTEN:${IPV6_GAME_PORT},ipv6-v6only=1,fork UDP4:127.0.0.1:${IPV4_GAME_PORT} &
# 加入 tcp 端口转发
socat TCP6-LISTEN:${IPV6_GAME_PORT},ipv6-v6only=1,fork TCP4:127.0.0.1:${IPV4_GAME_PORT} &

# 保持脚本运行
wait
