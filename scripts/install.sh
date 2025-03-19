#!/bin/bash

echo -e "\e[1;33m[信息]\e[0m 开始安装幻兽帕鲁服务器..."

# 安装SteamCMD
if [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
    echo -e "\e[1;31m[错误]\e[0m SteamCMD未找到，可能Dockerfile中的安装失败..."
    echo -e "\e[1;33m[信息]\e[0m 尝试重新安装SteamCMD..."
    mkdir -p ${STEAMCMD_DIR}
    cd ${STEAMCMD_DIR}
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
fi
echo -e "\e[1;33m[信息]\e[0m SteamCMD 已安装"

echo -e "\e[1;33m[信息]\e[0m 使用 SteamCMD 安装幻兽帕鲁服务器..."

# 安装Palworld服务器
echo -e "\e[1;33m[信息]\e[0m 下载幻兽帕鲁服务器..."
${STEAMCMD_DIR}/steamcmd.sh +force_install_dir ${SERVER_DIR} +login anonymous +app_update ${GAME_ID} validate +quit

# 检查安装结果
if [ -f "${SERVER_DIR}/PalServer.sh" ]; then
    echo -e "\e[1;32m[成功]\e[0m 幻兽帕鲁服务器安装完成！"
    # 设置可执行权限
    chmod +x ${SERVER_DIR}/PalServer.sh
else
    echo -e "\e[1;31m[错误]\e[0m 幻兽帕鲁服务器安装失败！"
    exit 1
fi 