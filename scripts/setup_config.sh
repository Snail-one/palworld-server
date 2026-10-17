#!/bin/bash

set -euo pipefail

echo -e "\e[1;33m[信息]\e[0m 设置服务器配置文件..."

# 配置文件路径
CONFIG_DIR="${SERVER_DIR}/Pal/Saved/Config/LinuxServer"
DEFAULT_CONFIG="${CONFIG_DIR}/PalWorldSettings.ini"
CONFIG_CONFIRMED_FILE="${CONFIG_DIR}/ConfigConfirmed.ini"
OFFICIAL_CONFIG="${SERVER_DIR}/DefaultPalWorldSettings.ini"

# 保留原环境变量名，用于跳过手动配置确认
SKIP_CONFIG_WAIT=${SKIP_CONFIG_WAIT:-"false"}

has_config_content() {
    [ -f "$1" ] && grep -q '[^[:space:]]' "$1"
}

# 确保配置目录存在
mkdir -p "${CONFIG_DIR}"

# 检查配置是否已确认
CONFIG_CONFIRMED="false"
if [ -f "${CONFIG_CONFIRMED_FILE}" ] && grep -qiE '^[[:space:]]*CONFIG_CONFIRMED=true[[:space:]]*$' "${CONFIG_CONFIRMED_FILE}"; then
    CONFIG_CONFIRMED="true"
fi

# 配置缺失或只有空白时初始化，恢复默认值后需要重新确认
if ! has_config_content "${DEFAULT_CONFIG}"; then
    if ! has_config_content "${OFFICIAL_CONFIG}"; then
        echo -e "\e[1;31m[错误]\e[0m 官方配置文件缺失或为空，无法初始化配置"
        echo -e "\e[1;33m[信息]\e[0m 请检查安装结果或上游文件结构是否发生变化: ${OFFICIAL_CONFIG}"
        exit 1
    fi
    echo -e "\e[1;33m[信息]\e[0m 游戏配置文件缺失或为空，复制官方配置文件..."
    cp "${OFFICIAL_CONFIG}" "${DEFAULT_CONFIG}"
    CONFIG_CONFIRMED="false"
    echo -e "\e[1;32m[成功]\e[0m 已复制官方配置文件"
fi

if [ "${CONFIG_CONFIRMED}" = "false" ]; then
    cat > "${CONFIG_CONFIRMED_FILE}" << EOF
# 幻兽帕鲁服务器配置确认文件
# 如果您已经确认了服务器配置，请将下面的值修改为 true
# 每次修改服务器配置后，您需要将此值重新设置为 true

CONFIG_CONFIRMED=false
EOF
    if [ "${SKIP_CONFIG_WAIT}" = "true" ]; then
        echo -e "\e[1;33m[信息]\e[0m 自动确认配置，继续启动服务器..."
        sed -i 's/CONFIG_CONFIRMED=false/CONFIG_CONFIRMED=true/g' "${CONFIG_CONFIRMED_FILE}"
    else
        echo -e "\e[1;32m[重要]\e[0m 配置尚未确认，容器将退出，游戏服务器不会启动"
        echo -e "\e[1;32m[路径]\e[0m 游戏配置文件位置: ${DEFAULT_CONFIG}"
        echo -e "\e[1;32m[路径]\e[0m 配置确认文件位置: ${CONFIG_CONFIRMED_FILE}"
        echo -e "\e[1;36m[确认]\e[0m 配置修改完成后，请将确认文件中的 CONFIG_CONFIRMED=false 修改为 CONFIG_CONFIRMED=true"
        echo -e "\e[1;36m[启动]\e[0m 确认后请手动执行 docker compose up -d，再次启动容器"
        # 78 通知入口脚本：需要用户配置，容器应正常退出而不是报错重启
        exit 78
    fi
else
    echo -e "\e[1;32m[信息]\e[0m 检测到配置已确认，继续启动服务器"
fi

if ! has_config_content "${DEFAULT_CONFIG}"; then
    echo -e "\e[1;31m[错误]\e[0m 游戏配置文件缺失或为空，拒绝启动，请检查: ${DEFAULT_CONFIG}"
    exit 1
fi

echo -e "\e[1;32m[成功]\e[0m 配置文件设置完成" 
