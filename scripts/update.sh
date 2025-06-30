#!/bin/bash

echo -e "\e[1;33m[信息]\e[0m 检查幻兽帕鲁服务器更新..."

# 检查是否强制更新模式
if [ "${FORCE_UPDATE_ON_START}" = "true" ]; then
    echo -e "\e[1;33m[信息]\e[0m 强制更新模式已启用，跳过版本检查直接更新..."
    CURRENT_BUILDID="force"
    LATEST_BUILDID="update"
else
    # 正常的版本检查流程
    # 获取当前安装的构建ID
    if [ -f "${SERVER_DIR}/steamapps/appmanifest_${GAME_ID}.acf" ]; then
        CURRENT_BUILDID=$(grep -oP '"buildid"\s*"\K[^"]+' ${SERVER_DIR}/steamapps/appmanifest_${GAME_ID}.acf)
        echo -e "\e[1;36m当前构建ID:\e[0m $CURRENT_BUILDID"
    else
        echo -e "\e[1;31m[警告]\e[0m 无法获取当前构建ID，将尝试强制更新"
        CURRENT_BUILDID=0
    fi

    # 使用SteamCMD.net API获取最新构建ID
    echo -e "\e[1;33m[信息]\e[0m 获取最新构建ID..."
    API_URL="https://api.steamcmd.net/v1/info/${GAME_ID}"

    # 使用curl获取API响应
    echo -e "\e[1;33m[信息]\e[0m 查询SteamCMD.net API..."
    API_RESPONSE=$(curl -s --connect-timeout 10 --max-time 30 "$API_URL")
    CURL_EXIT_CODE=$?

    # 检查API响应是否成功
    if [ $CURL_EXIT_CODE -eq 0 ] && [ ! -z "$API_RESPONSE" ]; then
        # 打印API响应数据用于调试
        echo -e "\e[1;34m[调试]\e[0m API响应数据:"
        echo "$API_RESPONSE" | head -c 1000
        echo ""
        echo -e "\e[1;34m[调试]\e[0m ..."
        
        # 检查API是否返回成功状态
        API_STATUS=$(echo "$API_RESPONSE" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        echo -e "\e[1;34m[调试]\e[0m API状态: '$API_STATUS'"
        
        # 检查是否包含数据（这个API没有status字段，直接检查是否有data字段）
        HAS_DATA=$(echo "$API_RESPONSE" | grep -o '"data"' | head -1)
        echo -e "\e[1;34m[调试]\e[0m 是否包含data字段: '$HAS_DATA'"
        
        if [ "$API_STATUS" = "success" ] || [ ! -z "$HAS_DATA" ]; then
            # 从JSON结构中提取构建ID：data.2394010.depots.branches.public.buildid
            echo -e "\e[1;34m[调试]\e[0m 尝试提取构建ID..."
            
            # 方法1: 直接搜索buildid（应该能找到）
            LATEST_BUILDID=$(echo "$API_RESPONSE" | grep -o '"buildid":"[^"]*"' | head -1 | cut -d'"' -f4)
            echo -e "\e[1;34m[调试]\e[0m 方法1 - 直接搜索结果: '$LATEST_BUILDID'"
            
            # 方法2: 如果方法1失败，搜索branches部分
            if [ -z "$LATEST_BUILDID" ]; then
                echo -e "\e[1;34m[调试]\e[0m 方法1失败，尝试搜索branches部分..."
                LATEST_BUILDID=$(echo "$API_RESPONSE" | grep -o '"branches":[^}]*"buildid":"[^"]*"' | grep -o '"buildid":"[^"]*"' | cut -d'"' -f4)
                echo -e "\e[1;34m[调试]\e[0m 方法2 - branches搜索结果: '$LATEST_BUILDID'"
            fi
            
            # 方法3: 更精确的sed匹配
            if [ -z "$LATEST_BUILDID" ]; then
                echo -e "\e[1;34m[调试]\e[0m 方法2失败，尝试sed匹配..."
                LATEST_BUILDID=$(echo "$API_RESPONSE" | sed -n 's/.*"branches":[^}]*"public":[^}]*"buildid":"\([^"]*\)".*/\1/p')
                echo -e "\e[1;34m[调试]\e[0m 方法3 - sed匹配结果: '$LATEST_BUILDID'"
            fi
            
            if [ ! -z "$LATEST_BUILDID" ]; then
                echo -e "\e[1;32m[成功]\e[0m 通过SteamCMD.net API获取到构建ID: $LATEST_BUILDID"
            else
                echo -e "\e[1;33m[警告]\e[0m API响应中未找到buildid，尝试提取时间戳作为版本标识..."
                # 尝试提取更新时间作为版本标识
                LATEST_BUILDID=$(echo "$API_RESPONSE" | grep -o '"timeupdated":"[^"]*"' | head -1 | cut -d'"' -f4)
                if [ ! -z "$LATEST_BUILDID" ]; then
                    echo -e "\e[1;33m[信息]\e[0m 使用更新时间作为版本标识: $LATEST_BUILDID"
                fi
            fi
        else
            echo -e "\e[1;31m[错误]\e[0m API返回失败状态或未找到状态字段"
            echo -e "\e[1;34m[调试]\e[0m API状态: '$API_STATUS'"
            echo -e "\e[1;34m[调试]\e[0m 检查API响应中是否包含错误信息:"
            echo "$API_RESPONSE" | grep -i "error\|fail\|invalid" || echo "未找到明显错误信息"
            LATEST_BUILDID=""
        fi
    else
        echo -e "\e[1;31m[错误]\e[0m SteamCMD.net API请求失败 (退出码: $CURL_EXIT_CODE)，尝试备用方法..."
        echo -e "\e[1;34m[调试]\e[0m API响应长度: ${#API_RESPONSE} 字符"
        if [ ! -z "$API_RESPONSE" ]; then
            echo -e "\e[1;34m[调试]\e[0m API响应前100字符: $(echo "$API_RESPONSE" | head -c 100)"
        fi
        LATEST_BUILDID=""
    fi

    # 如果API失败，使用原来的SteamCMD方法作为备用
    if [ -z "$LATEST_BUILDID" ]; then
        echo -e "\e[1;33m[信息]\e[0m 使用SteamCMD备用方法..."
        timeout 30s ${STEAMCMD_DIR}/steamcmd.sh +login anonymous +app_info_update 1 +app_info_print ${GAME_ID} +quit > /tmp/app_info.txt
        
        if [ $? -eq 0 ]; then
            LATEST_BUILDID=$(grep -oP '"buildid"\s*"\K[^"]+' /tmp/app_info.txt | head -1)
            if [ ! -z "$LATEST_BUILDID" ]; then
                echo -e "\e[1;32m[成功]\e[0m 通过SteamCMD获取到构建ID"
            fi
        fi
    fi

    # 最终检查
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