#!/bin/bash

set -euo pipefail

SERVER_PORT=${SERVER_PORT:-"8211"}
PUBLIC_IP=${PUBLIC_IP:-""}
PUBLIC_PORT=${PUBLIC_PORT:-""}
MAX_PLAYERS=${MAX_PLAYERS:-"16"}
WORKER_THREADS=${WORKER_THREADS:-""}
PUBLIC_LOBBY=${PUBLIC_LOBBY:-"false"}
LOG_FORMAT=${LOG_FORMAT:-"text"}

STARTUP_ARGS="-useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS"

if [ -n "$SERVER_PORT" ]; then STARTUP_ARGS="$STARTUP_ARGS -port=$SERVER_PORT"; fi
if [ -n "$PUBLIC_IP" ]; then STARTUP_ARGS="$STARTUP_ARGS -publicip=$PUBLIC_IP"; fi
if [ -n "$PUBLIC_PORT" ]; then STARTUP_ARGS="$STARTUP_ARGS -publicport=$PUBLIC_PORT"; fi
if [ -n "$MAX_PLAYERS" ]; then STARTUP_ARGS="$STARTUP_ARGS -players=$MAX_PLAYERS"; fi
if [ -n "$WORKER_THREADS" ]; then STARTUP_ARGS="$STARTUP_ARGS -NumberOfWorkerThreadsServer=$WORKER_THREADS"; fi
if [ "$PUBLIC_LOBBY" = "true" ]; then STARTUP_ARGS="$STARTUP_ARGS -publiclobby"; fi
if [ -n "$LOG_FORMAT" ]; then STARTUP_ARGS="$STARTUP_ARGS -logformat=$LOG_FORMAT"; fi

echo -e "\e[1;33m[信息]\e[0m 启动服务器: port=${SERVER_PORT}, players=${MAX_PLAYERS}, lobby=${PUBLIC_LOBBY}, log=${LOG_FORMAT}"
cd "${SERVER_DIR}"
mkdir -p "${SERVER_DIR}/Logs"
echo -e "\e[1;33m[信息]\e[0m 启动参数: $STARTUP_ARGS"
./PalServer.sh $STARTUP_ARGS 
