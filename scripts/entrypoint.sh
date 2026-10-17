#!/bin/bash

set -euo pipefail

echo -e "\e[1;32m[信息]\e[0m 初始化幻兽帕鲁服务器..."

if [ ! -d "${SERVER_DIR}" ]; then
    echo -e "\e[1;31m[错误]\e[0m 服务器数据目录不存在: ${SERVER_DIR}"
    exit 1
fi

WRITE_TEST_FILE="${SERVER_DIR}/.write-test.$$"
if ! touch "${WRITE_TEST_FILE}" 2>/dev/null; then
    echo -e "\e[1;31m[错误]\e[0m 服务器数据目录不可写: ${SERVER_DIR}"
    echo -e "\e[1;33m[信息]\e[0m 请检查挂载目录权限，确保容器用户可以写入该目录"
    exit 1
fi
rm -f "${WRITE_TEST_FILE}"

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
CONFIG_EXIT_CODE=0
/scripts/setup_config.sh || CONFIG_EXIT_CODE=$?
if [ "${CONFIG_EXIT_CODE}" -eq 78 ]; then
    # 配置未确认属于正常停止，配合 on-failure 避免自动重启
    exit 0
elif [ "${CONFIG_EXIT_CODE}" -ne 0 ]; then
    exit "${CONFIG_EXIT_CODE}"
fi

# 启动服务器
echo -e "\e[1;32m[信息]\e[0m 启动幻兽帕鲁服务器..."
exec /scripts/start.sh 
