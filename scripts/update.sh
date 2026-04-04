#!/bin/bash

set -euo pipefail

echo -e "\e[1;33m[信息]\e[0m 检查幻兽帕鲁服务器更新..."

if [ "${FORCE_UPDATE_ON_START}" = "true" ]; then
    echo -e "\e[1;33m[信息]\e[0m 强制更新模式，跳过版本检查"
    CURRENT_BUILDID="force"
    LATEST_BUILDID="update"
else
    if [ -f "${SERVER_DIR}/steamapps/appmanifest_${GAME_ID}.acf" ]; then
        CURRENT_BUILDID=$(grep -oP '"buildid"\s*"\K[^"]+' "${SERVER_DIR}/steamapps/appmanifest_${GAME_ID}.acf")
        echo -e "\e[1;36m当前构建ID:\e[0m $CURRENT_BUILDID"
    else
        echo -e "\e[1;31m[警告]\e[0m 无法获取当前构建ID，将尝试强制更新"
        CURRENT_BUILDID=0
    fi

    API_URL="https://api.steamcmd.net/v1/info/${GAME_ID}"

    API_RESPONSE=$(curl -s --connect-timeout 10 --max-time 30 "$API_URL")
    CURL_EXIT_CODE=$?

    if [ $CURL_EXIT_CODE -eq 0 ] && [ -n "$API_RESPONSE" ]; then
        API_STATUS=$(echo "$API_RESPONSE" | grep -o '"status": *"[^"]*"' | sed 's/.*"status": *"\([^"]*\)".*/\1/')
        HAS_DATA=$(echo "$API_RESPONSE" | grep -o '"data"' | head -1)
        
        if [ "$API_STATUS" = "success" ] || [ -n "$HAS_DATA" ]; then
            LATEST_BUILDID=$(echo "$API_RESPONSE" | grep -o '"buildid": *"[^"]*"' | sed 's/.*"buildid": *"\([^"]*\)".*/\1/')
            
            if [ -z "$LATEST_BUILDID" ]; then
                LATEST_BUILDID=$(echo "$API_RESPONSE" | grep -o '"branches": *{[^}]*"public": *{[^}]*"buildid": *"[^"]*"' | grep -o '"buildid": *"[^"]*"' | sed 's/.*"buildid": *"\([^"]*\)".*/\1/')
            fi
            
            if [ -z "$LATEST_BUILDID" ]; then
                LATEST_BUILDID=$(echo "$API_RESPONSE" | grep -o '"branches": *{[^}]*"buildid": *"[^"]*"' | grep -o '"buildid": *"[^"]*"' | sed 's/.*"buildid": *"\([^"]*\)".*/\1/')
            fi
            
            if [ -z "$LATEST_BUILDID" ]; then
                LATEST_BUILDID=$(echo "$API_RESPONSE" | sed -n 's/.*"branches": *{[^}]*"public": *{[^}]*"buildid": *"\([^"]*\)".*/\1/p')
            fi
            
            if [ -z "$LATEST_BUILDID" ]; then
                JSON_TAIL=$(echo "$API_RESPONSE" | tail -c 2000)
                LATEST_BUILDID=$(echo "$JSON_TAIL" | grep -o '"buildid": *"[^"]*"' | head -1 | sed 's/.*"buildid": *"\([^"]*\)".*/\1/')
            fi
            
            if [ -n "$LATEST_BUILDID" ]; then
                echo -e "\e[1;32m[成功]\e[0m 获取到最新构建ID: $LATEST_BUILDID"
            else
                LATEST_BUILDID=$(echo "$API_RESPONSE" | grep -o '"timeupdated": *"[^"]*"' | head -1 | sed 's/.*"timeupdated": *"\([^"]*\)".*/\1/')
                if [ -n "$LATEST_BUILDID" ]; then
                    echo -e "\e[1;33m[信息]\e[0m 使用更新时间作为版本标识: $LATEST_BUILDID"
                fi
            fi
        else
            echo -e "\e[1;31m[错误]\e[0m API返回失败状态或未找到状态字段"
            LATEST_BUILDID=""
        fi
    else
        echo -e "\e[1;31m[错误]\e[0m SteamCMD.net API请求失败 (退出码: $CURL_EXIT_CODE)，尝试备用方法..."
        LATEST_BUILDID=""
    fi

    if [ -z "$LATEST_BUILDID" ]; then
        echo -e "\e[1;33m[信息]\e[0m 使用SteamCMD备用方法..."
        if timeout 30s "${STEAMCMD_DIR}/steamcmd.sh" +login anonymous +app_info_update 1 +app_info_print "${GAME_ID}" +quit > /tmp/app_info.txt; then
            LATEST_BUILDID=$(grep -oP '"buildid"\s*"\K[^"]+' /tmp/app_info.txt | head -1)
            if [ -n "$LATEST_BUILDID" ]; then
                echo -e "\e[1;32m[成功]\e[0m 通过SteamCMD获取到构建ID"
            fi
        fi
    fi

    if [ -z "$LATEST_BUILDID" ]; then
        echo -e "\e[1;31m[错误]\e[0m 无法获取最新构建ID"
        exit 1
    fi
fi

echo -e "\e[1;36m最新构建ID:\e[0m $LATEST_BUILDID"

if [ "$CURRENT_BUILDID" != "$LATEST_BUILDID" ] || [ "${FORCE_UPDATE_ON_START}" = "true" ]; then
    if [ "${FORCE_UPDATE_ON_START}" = "true" ]; then
        echo -e "\e[1;33m[信息]\e[0m 强制更新模式：开始更新服务器..."
    else
        echo -e "\e[1;33m[信息]\e[0m 发现新版本，开始更新..."
    fi
    
    if "${STEAMCMD_DIR}/steamcmd.sh" +force_install_dir "${SERVER_DIR}" +login anonymous +app_update "${GAME_ID}" validate +quit; then
        echo -e "\e[1;32m[成功]\e[0m 服务器更新完成！"
        chmod +x "${SERVER_DIR}/PalServer.sh"
    else
        echo -e "\e[1;31m[错误]\e[0m 服务器更新失败！"
        exit 1
    fi
else
    echo -e "\e[1;32m[成功]\e[0m 服务器已是最新版本"
fi 
