#!/bin/bash

echo -e "\e[1;32m[信息]\e[0m 启动幻兽帕鲁服务器..."

# 获取服务器配置参数
SERVER_PORT=${SERVER_PORT:-"8211"}
PUBLIC_IP=${PUBLIC_IP:-""}
PUBLIC_PORT=${PUBLIC_PORT:-""}
MAX_PLAYERS=${MAX_PLAYERS:-"16"}
WORKER_THREADS=${WORKER_THREADS:-""}
PUBLIC_LOBBY=${PUBLIC_LOBBY:-"false"}
LOG_FORMAT=${LOG_FORMAT:-"text"}

# 设置启动参数
STARTUP_ARGS="-useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS"

# 添加服务器参数 (根据官方文档 https://docs.palworldgame.com/settings-and-operation/arguments)
if [ ! -z "$SERVER_PORT" ]; then STARTUP_ARGS="$STARTUP_ARGS -port=$SERVER_PORT"; fi
if [ ! -z "$PUBLIC_IP" ]; then STARTUP_ARGS="$STARTUP_ARGS -publicip=$PUBLIC_IP"; fi
if [ ! -z "$PUBLIC_PORT" ]; then STARTUP_ARGS="$STARTUP_ARGS -publicport=$PUBLIC_PORT"; fi
if [ ! -z "$MAX_PLAYERS" ]; then STARTUP_ARGS="$STARTUP_ARGS -players=$MAX_PLAYERS"; fi
if [ ! -z "$WORKER_THREADS" ]; then STARTUP_ARGS="$STARTUP_ARGS -NumberOfWorkerThreadsServer=$WORKER_THREADS"; fi
if [ "$PUBLIC_LOBBY" = "true" ]; then STARTUP_ARGS="$STARTUP_ARGS -publiclobby"; fi
if [ ! -z "$LOG_FORMAT" ]; then STARTUP_ARGS="$STARTUP_ARGS -logformat=$LOG_FORMAT"; fi


echo -e "\e[1;33m[信息]\e[0m 服务器设置:"
echo -e "\e[1;36m最大玩家数:\e[0m $MAX_PLAYERS"
echo -e "\e[1;36m服务器端口:\e[0m $SERVER_PORT"
if [ ! -z "$PUBLIC_PORT" ]; then echo -e "\e[1;36m公共端口:\e[0m $PUBLIC_PORT"; fi
echo -e "\e[1;36m公共IP:\e[0m $PUBLIC_IP"
if [ "$PUBLIC_LOBBY" = "true" ]; then echo -e "\e[1;36m社区服务器:\e[0m 是"; fi
if [ ! -z "$WORKER_THREADS" ]; then echo -e "\e[1;36m工作线程数:\e[0m $WORKER_THREADS"; fi
echo -e "\e[1;36m日志格式:\e[0m $LOG_FORMAT"

# 启动服务器
cd ${SERVER_DIR}
echo -e "\e[1;32m[信息]\e[0m 执行启动命令..."
echo -e "\e[1;33m启动参数:\e[0m $STARTUP_ARGS"

# 创建启动日志目录
mkdir -p ${SERVER_DIR}/Logs

# 启动服务器
./PalServer.sh $STARTUP_ARGS 