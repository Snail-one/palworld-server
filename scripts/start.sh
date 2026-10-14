#!/bin/bash

set -euo pipefail

SERVER_PORT=${SERVER_PORT:-"8211"}
PUBLIC_IP=${PUBLIC_IP:-""}
PUBLIC_PORT=${PUBLIC_PORT:-""}
MAX_PLAYERS=${MAX_PLAYERS:-"16"}
WORKER_THREADS=${WORKER_THREADS:-""}
ENABLE_MULTITHREADING=${ENABLE_MULTITHREADING:-"false"}
PUBLIC_LOBBY=${PUBLIC_LOBBY:-"false"}
LOG_FORMAT=${LOG_FORMAT:-"text"}
ENABLE_GAMEDATA_API=${ENABLE_GAMEDATA_API:-"false"}

for setting in ENABLE_MULTITHREADING ENABLE_GAMEDATA_API; do
    if [ "${!setting}" != "true" ] && [ "${!setting}" != "false" ]; then
        echo -e "\e[1;31m[错误]\e[0m ${setting} 必须为 true 或 false"
        exit 1
    fi
done

if [ -n "$WORKER_THREADS" ]; then
    if [[ ! "$WORKER_THREADS" =~ ^[1-9][0-9]*$ ]]; then
        echo -e "\e[1;31m[错误]\e[0m WORKER_THREADS 必须为正整数"
        exit 1
    fi
    if [ "$ENABLE_MULTITHREADING" != "true" ]; then
        echo -e "\e[1;31m[错误]\e[0m 设置 WORKER_THREADS 时必须同时设置 ENABLE_MULTITHREADING=true"
        exit 1
    fi
fi

# 官方说明：v1.0 及以后，不设置这组参数可能获得更好的性能。
STARTUP_ARGS=()
if [ "$ENABLE_MULTITHREADING" = "true" ]; then
    STARTUP_ARGS+=(-useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS)
    if [ -n "$WORKER_THREADS" ]; then STARTUP_ARGS+=("-NumberOfWorkerThreadsServer=$WORKER_THREADS"); fi
fi

if [ -n "$SERVER_PORT" ]; then STARTUP_ARGS+=("-port=$SERVER_PORT"); fi
if [ -n "$PUBLIC_IP" ]; then STARTUP_ARGS+=("-publicip=$PUBLIC_IP"); fi
if [ -n "$PUBLIC_PORT" ]; then STARTUP_ARGS+=("-publicport=$PUBLIC_PORT"); fi
if [ -n "$MAX_PLAYERS" ]; then STARTUP_ARGS+=("-players=$MAX_PLAYERS"); fi
if [ "$PUBLIC_LOBBY" = "true" ]; then STARTUP_ARGS+=("-publiclobby"); fi
if [ -n "$LOG_FORMAT" ]; then STARTUP_ARGS+=("-logformat=$LOG_FORMAT"); fi
if [ "$ENABLE_GAMEDATA_API" = "true" ]; then STARTUP_ARGS+=(-enable-gamedata-api); fi

echo -e "\e[1;33m[信息]\e[0m 启动服务器: port=${SERVER_PORT}, players=${MAX_PLAYERS}, lobby=${PUBLIC_LOBBY}, log=${LOG_FORMAT}"
cd "${SERVER_DIR}"
mkdir -p "${SERVER_DIR}/Logs"
echo -e "\e[1;33m[信息]\e[0m 启动参数: ${STARTUP_ARGS[*]}"
./PalServer.sh "${STARTUP_ARGS[@]}" 
