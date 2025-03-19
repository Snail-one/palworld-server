#!/bin/bash

echo -e "\e[1;33m[信息]\e[0m 检查幻兽帕鲁服务器更新..."

# 获取当前安装的构建ID
if [ -f "${SERVER_DIR}/steamapps/appmanifest_${GAME_ID}.acf" ]; then
    CURRENT_BUILDID=$(grep -oP '"buildid"\s*"\K[^"]+' ${SERVER_DIR}/steamapps/appmanifest_${GAME_ID}.acf)
    echo -e "\e[1;36m当前构建ID:\e[0m $CURRENT_BUILDID"
else
    echo -e "\e[1;31m[警告]\e[0m 无法获取当前构建ID，将尝试强制更新"
    CURRENT_BUILDID=0
fi

# 获取最新构建ID
echo -e "\e[1;33m[信息]\e[0m 获取最新构建ID..."
${STEAMCMD_DIR}/steamcmd.sh +login anonymous +app_info_update 1 +app_info_print ${GAME_ID} +quit > /tmp/app_info.txt
LATEST_BUILDID=$(grep -oP '"buildid"\s*"\K[^"]+' /tmp/app_info.txt | head -1)
echo -e "\e[1;36m最新构建ID:\e[0m $LATEST_BUILDID"

# 检查是否需要更新
if [ "$CURRENT_BUILDID" != "$LATEST_BUILDID" ]; then
    echo -e "\e[1;33m[信息]\e[0m 发现新版本，开始更新..."
    
    # 备份当前服务器数据
    echo -e "\e[1;33m[信息]\e[0m 备份当前服务器数据..."
    /scripts/backup.sh pre-update
    
    # 更新服务器
    ${STEAMCMD_DIR}/steamcmd.sh +force_install_dir ${SERVER_DIR} +login anonymous +app_update ${GAME_ID} validate +quit
    
    # 检查更新结果
    if [ $? -eq 0 ]; then
        echo -e "\e[1;32m[成功]\e[0m 服务器更新完成！"
        # 设置可执行权限
        chmod +x ${SERVER_DIR}/PalServer.sh
    else
        echo -e "\e[1;31m[错误]\e[0m 服务器更新失败！"
        exit 1
    fi
else
    echo -e "\e[1;32m[成功]\e[0m 服务器已是最新版本"
fi 