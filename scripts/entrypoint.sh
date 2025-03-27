#!/bin/bash

# 显示欢迎信息
echo -e "\e[1;36m"
cat << "EOF"
██████╗  █████╗ ██╗     ██╗    ██╗ ██████╗ ██████╗ ██╗     ██████╗
██╔══██╗██╔══██╗██║     ██║    ██║██╔═══██╗██╔══██╗██║     ██╔══██╗
██████╔╝███████║██║     ██║ █╗ ██║██║   ██║██████╔╝██║     ██║  ██║
██╔═══╝ ██╔══██║██║     ██║███╗██║██║   ██║██╔══██╗██║     ██║  ██║
██║     ██║  ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║███████╗██████╔╝
╚═╝     ╚═╝  ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═════╝
EOF
echo -e "\e[0m"
echo -e "\e[1;33m=== 幻兽帕鲁服务器 ===\e[0m"
echo -e "\e[1;33m=== 作者:  蜗牛   ===\e[0m"
echo -e "\e[1;33m=== 脚本版本: 1.0 ===\e[0m"
echo -e "\e[1;32m=== 初始化中... ===\e[0m"

# 检查服务器安装
if [ ! -f "${SERVER_DIR}/PalServer.sh" ]; then
    echo -e "\e[1;33m[信息]\e[0m 服务器未安装，开始安装..."
    /scripts/install.sh
else
    echo -e "\e[1;32m[成功]\e[0m 服务器已安装"
    
    # 检查更新
    if [ "${CHECK_UPDATE}" = "true" ]; then
        echo -e "\e[1;33m[信息]\e[0m 检查服务器更新..."
        /scripts/update.sh
    fi
fi

# 设置备份任务
if [ "${ENABLE_BACKUPS}" = "true" ]; then
    echo -e "\e[1;33m[信息]\e[0m 设置自动备份..."
    /scripts/setup_backup.sh
else
    echo -e "\e[1;33m[信息]\e[0m 自动备份功能已禁用"
fi

# 设置服务器配置
echo -e "\e[1;33m[信息]\e[0m 检查服务器配置..."
/scripts/setup_config.sh

# 如果配置设置脚本失败，则退出
if [ $? -ne 0 ]; then
    echo -e "\e[1;31m[错误]\e[0m 配置设置失败，服务器启动中止"
    exit 1
fi

# 判断ENABLE_IPV6_FORWARD是否为true
if [ "${ENABLE_IPV6_FORWARD}" = "true" ]; then
    echo -e "\e[1;33m[信息]\e[0m 启用 IPv6 端口转发..."
    /scripts/ipv6_forward.sh &  # 添加 & 使其在后台运行
    
    # 等待几秒确保端口转发启动
    sleep 2
    
    # 检查端口转发是否成功启动
    if pgrep -f "ipv6_forward.sh" > /dev/null; then
        echo -e "\e[1;32m[成功]\e[0m IPv6 端口转发已启动"
    else
        echo -e "\e[1;31m[警告]\e[0m IPv6 端口转发启动可能失败"
    fi
else
    echo -e "\e[1;33m[信息]\e[0m IPv6 端口转发已禁用"
fi

# 启动服务器
echo -e "\e[1;32m[信息]\e[0m 启动幻兽帕鲁服务器..."
exec /scripts/start.sh 