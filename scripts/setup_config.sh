#!/bin/bash

set -euo pipefail

echo -e "\e[1;33m[信息]\e[0m 设置服务器配置文件..."

# 配置文件路径
CONFIG_DIR="${SERVER_DIR}/Pal/Saved/Config/LinuxServer"
DEFAULT_CONFIG="${CONFIG_DIR}/PalWorldSettings.ini"
CONFIG_CONFIRMED_FILE="${CONFIG_DIR}/ConfigConfirmed.ini"
OFFICIAL_CONFIG="${SERVER_DIR}/DefaultPalWorldSettings.ini"

# 是否跳过配置等待
SKIP_CONFIG_WAIT=${SKIP_CONFIG_WAIT:-"false"}

# 确保配置目录存在
mkdir -p "${CONFIG_DIR}"

# 检查配置是否已确认
CONFIG_CONFIRMED="false"
if [ -f "${CONFIG_CONFIRMED_FILE}" ]; then
    CONFIG_CONFIRMED=$(grep -i "CONFIG_CONFIRMED=true" "${CONFIG_CONFIRMED_FILE}" > /dev/null && echo "true" || echo "false")
fi

# 如果配置未确认或配置文件不存在，则进行设置
if [ "${CONFIG_CONFIRMED}" = "false" ] || [ ! -f "${DEFAULT_CONFIG}" ]; then
    if [ ! -f "${OFFICIAL_CONFIG}" ]; then
        echo -e "\e[1;31m[错误]\e[0m 官方配置文件缺失，无法初始化配置"
        echo -e "\e[1;33m[信息]\e[0m 请检查安装结果或上游文件结构是否发生变化: ${OFFICIAL_CONFIG}"
        exit 1
    fi
    
    if [ ! -f "${DEFAULT_CONFIG}" ]; then
        echo -e "\e[1;33m[信息]\e[0m 复制官方配置文件..."
        cp "${OFFICIAL_CONFIG}" "${DEFAULT_CONFIG}"
        echo -e "\e[1;32m[成功]\e[0m 已复制官方配置文件"
    else
        echo -e "\e[1;32m[信息]\e[0m 检测到配置文件已存在"
    fi

    if [ ! -f "${CONFIG_CONFIRMED_FILE}" ] || [ "${CONFIG_CONFIRMED}" != "true" ]; then
        cat > "${CONFIG_CONFIRMED_FILE}" << EOF
# 幻兽帕鲁服务器配置确认文件
# 如果您已经确认了服务器配置，请将下面的值修改为 true
# 每次修改服务器配置后，您需要将此值重新设置为 true

CONFIG_CONFIRMED=false
EOF
    fi

    if [ "${SKIP_CONFIG_WAIT}" = "true" ]; then
        echo -e "\e[1;33m[信息]\e[0m 跳过配置确认等待..."
        sed -i 's/CONFIG_CONFIRMED=false/CONFIG_CONFIRMED=true/g' "${CONFIG_CONFIRMED_FILE}"
    else
        echo -e "\e[1;32m[重要]\e[0m 配置文件已创建，请修改配置文件后确认启动服务器"
        echo -e "\e[1;32m[路径]\e[0m 游戏配置文件位置: ${DEFAULT_CONFIG}"
        echo -e "\e[1;32m[路径]\e[0m 配置确认文件位置: ${CONFIG_CONFIRMED_FILE}"
        echo -e "\e[1;33m[等待]\e[0m 等待配置确认，或最多等待5分钟后自动停止容器..."
        echo -e "\e[1;36m[确认]\e[0m 配置修改完成后，请将确认文件中的 CONFIG_CONFIRMED=false 修改为 CONFIG_CONFIRMED=true"
        
        WAIT_TIME=0
        MAX_WAIT=300
        
        while [ "${CONFIG_CONFIRMED}" = "false" ] && [ ${WAIT_TIME} -lt ${MAX_WAIT} ]; do
            sleep 5
            WAIT_TIME=$((WAIT_TIME + 5))
            REMAINING=$((MAX_WAIT - WAIT_TIME))
            
            CONFIG_CONFIRMED=$(grep -i "CONFIG_CONFIRMED=true" "${CONFIG_CONFIRMED_FILE}" > /dev/null && echo "true" || echo "false")
            
            if [ $((WAIT_TIME % 30)) -eq 0 ]; then
                echo -e "\e[1;33m[等待]\e[0m 等待配置确认，还剩 ${REMAINING} 秒..."
            fi
        done
        
        if [ "${CONFIG_CONFIRMED}" = "true" ]; then
            echo -e "\e[1;32m[成功]\e[0m 检测到配置确认，继续启动服务器"
        else
            echo -e "\e[1;31m[错误]\e[0m 超过5分钟未收到配置确认，停止容器..."
            kill -15 1
            exit 1
        fi
    fi
else
    echo -e "\e[1;32m[信息]\e[0m 检测到配置已确认，跳过配置等待"
fi

echo -e "\e[1;32m[成功]\e[0m 配置文件设置完成" 
