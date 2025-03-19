#!/bin/bash

echo -e "\e[1;33m[信息]\e[0m 设置服务器配置文件..."

# 配置文件路径
CONFIG_DIR="${SERVER_DIR}/Pal/Saved/Config/LinuxServer"
DEFAULT_CONFIG="${CONFIG_DIR}/PalWorldSettings.ini"
CONFIG_CONFIRMED_FILE="${CONFIG_DIR}/ConfigConfirmed.ini"
OFFICIAL_CONFIG="${SERVER_DIR}/DefaultPalWorldSettings.ini"

# 是否跳过配置等待
SKIP_CONFIG_WAIT=${SKIP_CONFIG_WAIT:-"false"}

# 确保配置目录存在
mkdir -p ${CONFIG_DIR}

# 检查配置是否已确认
CONFIG_CONFIRMED="false"
if [ -f "${CONFIG_CONFIRMED_FILE}" ]; then
    CONFIG_CONFIRMED=$(grep -i "CONFIG_CONFIRMED=true" "${CONFIG_CONFIRMED_FILE}" > /dev/null && echo "true" || echo "false")
fi

# 如果配置未确认或配置文件不存在，则进行设置
if [ "${CONFIG_CONFIRMED}" = "false" ] || [ ! -f "${DEFAULT_CONFIG}" ]; then
    # 确保官方配置文件存在
    if [ ! -f "${OFFICIAL_CONFIG}" ]; then
        echo -e "\e[1;33m[信息]\e[0m 寻找官方配置文件..."
        # 寻找可能的官方配置文件位置
        POTENTIAL_PATHS=(
            "${SERVER_DIR}/DefaultPalWorldSettings.ini"
            "${SERVER_DIR}/Pal/Config/DefaultPalWorldSettings.ini"
            "${SERVER_DIR}/Pal/Content/Configs/DefaultPalWorldSettings.ini"
            "${SERVER_DIR}/Pal/Content/Config/DefaultPalWorldSettings.ini"
            "${SERVER_DIR}/Engine/Config/DefaultPalWorldSettings.ini"
            "${SERVER_DIR}/PalServer/Saved/Config/LinuxServer/DefaultPalWorldSettings.ini"
            "${SERVER_DIR}/Saved/Config/LinuxServer/DefaultPalWorldSettings.ini"
        )
        
        for path in "${POTENTIAL_PATHS[@]}"; do
            if [ -f "$path" ]; then
                OFFICIAL_CONFIG="$path"
                echo -e "\e[1;32m[成功]\e[0m 找到官方配置文件: $OFFICIAL_CONFIG"
                break
            fi
        done
        
        # 如果仍未找到，则尝试在整个服务器目录中查找
        if [ ! -f "${OFFICIAL_CONFIG}" ]; then
            echo -e "\e[1;33m[信息]\e[0m 在整个服务器目录中搜索配置文件..."
            FOUND_CONFIG=$(find ${SERVER_DIR} -name "*PalWorldSettings*.ini" -type f | grep -v "Saved" | head -n 1)
            if [ ! -z "$FOUND_CONFIG" ]; then
                OFFICIAL_CONFIG="$FOUND_CONFIG"
                echo -e "\e[1;32m[成功]\e[0m 找到官方配置文件: $OFFICIAL_CONFIG"
            fi
        fi
    fi
    
    # 复制官方配置文件或创建默认配置（如果配置文件不存在）
    if [ ! -f "${DEFAULT_CONFIG}" ]; then
        if [ -f "${OFFICIAL_CONFIG}" ]; then
            echo -e "\e[1;33m[信息]\e[0m 复制官方配置文件..."
            cp "${OFFICIAL_CONFIG}" "${DEFAULT_CONFIG}"
            echo -e "\e[1;32m[成功]\e[0m 已复制官方配置文件"
        else
            echo -e "\e[1;33m[警告]\e[0m 未找到官方配置文件，创建基本配置..."
            # 生成基本配置内容
            cat > ${DEFAULT_CONFIG} << EOF
[/Script/Pal.PalGameWorldSettings]
OptionSettings=(
    ServerName="幻兽帕鲁专用服务器",
    ServerDescription="专用服务器",
    ServerPassword="",
    PublicPort=8211,
    PublicIP="",
    RCONEnabled=True,
    RCONPort=25575,
    Region="",
    bUseAuth=True,
    BanListURL="https://api.palworldgame.com/api/banlist.txt",
    AdminPassword="",
    ServerPlayerMaxNum=16,
    ServerThreadNum=2,
    DayTimeSpeedRate=1.000000,
    NightTimeSpeedRate=1.000000,
    ExpRate=1.000000,
    PalCaptureRate=1.000000,
    PalSpawnNumRate=1.000000,
    PalDamageRateAttack=1.000000,
    PalDamageRateDefense=1.000000,
    PlayerDamageRateAttack=1.000000,
    PlayerDamageRateDefense=1.000000,
    PlayerStomachDecreaseRate=1.000000,
    PlayerStaminaDecreaseRate=1.000000,
    PlayerAutoHPRegeneRate=1.000000,
    PlayerAutoHpRegeneRateInSleep=1.000000,
    PalStomachDecreaseRate=1.000000,
    PalStaminaDecreaseRate=1.000000,
    PalAutoHPRegeneRate=1.000000,
    PalAutoHpRegeneRateInSleep=1.000000,
    BuildObjectDamageRate=1.000000,
    BuildObjectDeteriorationDamageRate=1.000000,
    CollectionDropRate=1.000000,
    CollectionObjectHpRate=1.000000,
    CollectionObjectRespawnSpeedRate=1.000000,
    EnemyDropItemRate=1.000000,
    DeathPenalty=All,
    bEnablePlayerToPlayerDamage=False,
    bEnableFriendlyFire=False,
    bEnableInvaderEnemy=True,
    bActiveUNKO=False,
    bEnableAimAssistPad=True,
    bEnableAimAssistKeyboard=False,
    DropItemMaxNum=3000,
    DropItemMaxNum_UNKO=100,
    BaseCampMaxNum=128,
    BaseCampWorkerMaxNum=15,
    DropItemAliveMaxHours=1.000000,
    bAutoResetGuildNoOnlinePlayers=False,
    AutoResetGuildTimeNoOnlinePlayers=72.000000,
    GuildPlayerMaxNum=20,
    PalEggDefaultHatchingTime=72.000000,
    WorkSpeedRate=1.000000,
    bIsMultiplay=True,
    bIsPvP=False,
    bCanPickupOtherGuildDeathPenaltyDrop=False,
    bEnableNonLoginPenalty=True,
    bEnableFastTravel=True,
    bIsStartLocationSelectByMap=True,
    bExistPlayerAfterLogout=False,
    bEnableDefenseOtherGuildPlayer=False,
    CoopPlayerMaxNum=4,
    ServerPassword="",
    bUseAuth=True,
    VersionNum=3
)
EOF
        fi
    else
        echo -e "\e[1;32m[信息]\e[0m 检测到配置文件已存在"
    fi

    # 创建或更新配置确认文件
    cat > ${CONFIG_CONFIRMED_FILE} << EOF
# 幻兽帕鲁服务器配置确认文件
# 如果您已经确认了服务器配置，请将下面的值修改为 true
# 每次修改服务器配置后，您需要将此值重新设置为 true

CONFIG_CONFIRMED=false
EOF

    # 是否需要等待用户确认
    if [ "${SKIP_CONFIG_WAIT}" = "true" ]; then
        echo -e "\e[1;33m[信息]\e[0m 跳过配置确认等待..."
        # 自动确认配置
        sed -i 's/CONFIG_CONFIRMED=false/CONFIG_CONFIRMED=true/g' "${CONFIG_CONFIRMED_FILE}"
    else
        # 提示用户修改配置文件
        echo -e "\e[1;32m[重要]\e[0m 配置文件已创建，请修改配置文件后确认启动服务器"
        echo -e "\e[1;32m[路径]\e[0m 游戏配置文件位置: ${DEFAULT_CONFIG}"
        echo -e "\e[1;32m[路径]\e[0m 配置确认文件位置: ${CONFIG_CONFIRMED_FILE}"
        echo -e "\e[1;33m[等待]\e[0m 等待配置确认，或最多等待5分钟后自动停止容器..."
        echo -e "\e[1;36m[确认]\e[0m 配置修改完成后，请将确认文件中的 CONFIG_CONFIRMED=false 修改为 CONFIG_CONFIRMED=true"
        
        # 等待用户确认，最多等5分钟
        WAIT_TIME=0
        MAX_WAIT=300 # 5分钟 = 300秒
        
        while [ "${CONFIG_CONFIRMED}" = "false" ] && [ ${WAIT_TIME} -lt ${MAX_WAIT} ]; do
            sleep 5
            WAIT_TIME=$((WAIT_TIME + 5))
            REMAINING=$((MAX_WAIT - WAIT_TIME))
            
            # 重新检查配置确认状态
            CONFIG_CONFIRMED=$(grep -i "CONFIG_CONFIRMED=true" "${CONFIG_CONFIRMED_FILE}" > /dev/null && echo "true" || echo "false")
            
            if [ $((WAIT_TIME % 30)) -eq 0 ]; then
                echo -e "\e[1;33m[等待]\e[0m 等待配置确认，还剩 ${REMAINING} 秒..."
            fi
        done
        
        # 检查确认状态
        if [ "${CONFIG_CONFIRMED}" = "true" ]; then
            echo -e "\e[1;32m[成功]\e[0m 检测到配置确认，继续启动服务器"
        else
            echo -e "\e[1;31m[错误]\e[0m 超过5分钟未收到配置确认，停止容器..."
            # 使用kill命令向PID 1发送SIGTERM信号，这会使容器停止而不是重启
            kill -15 1
            # 确保脚本退出
            exit 1
        fi
    fi
else
    echo -e "\e[1;32m[信息]\e[0m 检测到配置已确认，跳过配置等待"
fi

echo -e "\e[1;32m[成功]\e[0m 配置文件设置完成" 