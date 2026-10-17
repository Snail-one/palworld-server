# 使用固定大版本的 Debian 精简镜像
FROM debian:13-slim

# 维护者信息
LABEL maintainer="palworld-server-admin@example.com"

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    SERVER_DIR=/palworld-server \
    STEAMCMD_DIR=/steamcmd \
    GAME_ID=2394010 \
    GAME_PORT=8211 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# 安装必要的软件包
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    ca-certificates \
    lib32gcc-s1 \
    libstdc++6 \
    tmux \
    unzip \
    locales \
    && printf 'en_US.UTF-8 UTF-8\n' > /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/*

# 创建目录
RUN mkdir -p ${SERVER_DIR} ${STEAMCMD_DIR}

# 安装SteamCMD
RUN cd ${STEAMCMD_DIR} && \
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# 创建配置目录
RUN mkdir -p ${SERVER_DIR}/Logs && \
    mkdir -p ${SERVER_DIR}/Pal/Saved/Config/LinuxServer

# 创建非root用户，UID/GID 由系统默认分配
RUN useradd --user-group -m -d /home/palworld -s /bin/bash palworld

# 设置目录权限
RUN chown -R palworld:palworld ${SERVER_DIR} ${STEAMCMD_DIR} && \
    chown -R palworld:palworld /home/palworld && \
    chown -R palworld:palworld ${SERVER_DIR}/Logs

# 设置工作目录
WORKDIR ${SERVER_DIR}

# 复制脚本到容器
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh && \
    chown -R palworld:palworld /scripts

# 创建方便用户使用的命令符号链接
RUN ln -sf /scripts/update.sh /usr/local/bin/update && \
    ln -sf /scripts/status.sh /usr/local/bin/status && \
    chmod +x /usr/local/bin/update && \
    chmod +x /usr/local/bin/status

# 暴露端口
EXPOSE ${GAME_PORT}/udp

# 创建卷
VOLUME ["${SERVER_DIR}"]

# 切换到非root用户
USER palworld

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 CMD ["/scripts/status.sh"]

# 设置容器入口点
ENTRYPOINT ["/scripts/entrypoint.sh"]
