# 幻兽帕鲁专用服务器 Docker 容器

一个精简高效的幻兽帕鲁（Palworld）专用服务器Docker容器，基于Ubuntu构建，专注于稳定性和易用性。

## ✨ 功能特点

- 🐳 **容器化部署**：基于Docker的现代化部署方式
- 🔄 **智能更新**：自动检查游戏版本并更新到最新版本
- 🛡️ **安全运行**：非root用户运行，保障系统安全
- ⚙️ **配置管理**：自动处理官方配置文件
- 📊 **状态监控**：实时查看服务器运行状态
- ✅ **官方兼容**：严格遵循官方启动参数规范

## 快速开始

### 系统要求

- Docker 和 Docker Compose（支持 `docker compose` 或 `docker-compose`）
- 至少 4GB RAM
- 至少 10GB 可用磁盘空间
- 稳定的网络连接
- 挂载到 `./palworld` 和 `./config` 的目录必须允许容器用户 `palworld` 写入

### 1. 克隆仓库

```bash
git clone git@github.com:Snail-one/palworld-server.git
cd palworld-server
```

### 2. 启动服务器

启动前确保 `./palworld` 和 `./config` 已创建，并具有容器用户的写入权限；镜像中的目录权限不会覆盖宿主机挂载目录的权限。

```bash
mkdir -p palworld config
docker compose up -d
```

### 3. 查看服务器状态

```bash
docker logs -f palworld-server
```

### 4. 初始配置

首次启动时，容器会自动：

1. 下载并安装幻兽帕鲁服务器
2. 复制官方默认配置文件
3. 等待用户确认配置（最多5分钟）
4. 启动游戏服务器

如果安装完成后缺少官方默认配置文件，容器会直接报错退出，避免生成过时的本地模板配置。
如果挂载目录没有写入权限，容器也会在初始化阶段直接报错退出。

#### 配置确认步骤

项目根目录的 `config` 是独立的真实目录，通过 Docker 挂载到游戏配置目录。首次安装会直接将默认配置写入 `./config`，修改这里的文件就是修改游戏实际使用的配置。目录中的实际配置文件已被 Git 忽略。

1. 编辑游戏配置：`./config/PalWorldSettings.ini`
2. 修改确认文件：`./config/ConfigConfirmed.ini`
3. 将 `CONFIG_CONFIRMED=false` 改为 `CONFIG_CONFIRMED=true`

后续修改设置时，先执行 `docker compose stop`，编辑 `./config/PalWorldSettings.ini`，再执行 `docker compose up -d`。

#### 从旧配置目录迁移

独立配置挂载会遮住容器内原配置目录。已有服务器在首次切换前，先停服，再将旧配置复制到 `./config`；以下命令会保留新目录中已经存在的文件。

```bash
docker compose stop
# 如果 config 是旧版快捷链接，只移除链接本身
if [ -L config ]; then
  unlink config
fi
mkdir -p config
if [ -d ./palworld/Pal/Saved/Config/LinuxServer ]; then
  cp -an ./palworld/Pal/Saved/Config/LinuxServer/. ./config/
fi
# 确保 config 目录及其文件允许容器用户读写
docker compose up -d --force-recreate
```

> 💡 **提示**：设置 `SKIP_CONFIG_WAIT=true` 可跳过配置等待，直接使用默认配置启动

## 镜像发布与版本标签

发布工作流支持两种触发方式：

- **推送 Git tag**：构建镜像并发布到 GHCR，例如执行 `git tag v1.0.0` 后执行 `git push origin v1.0.0`。
- **手动触发（Run workflow）**：仅构建镜像并验证 SteamCMD 版本读取，不登录 GHCR、不推送镜像；即使手动选择 Git tag 运行也不会发布。

普通分支推送不会触发此发布工作流。Git tag 用于触发发布，镜像的版本标签仍使用 SteamCMD 工具自身的版本号。

GitHub Actions 发布到 `ghcr.io/snail-one/palworld-server` 时，会生成以下标签：

| 标签 | 含义 |
|------|------|
| `latest` | 最近发布的镜像 |
| `sha-<提交短哈希>` | 对应 Git 提交的镜像 |
| `<SteamCMD 版本号>` | 镜像中实际安装的 SteamCMD 工具版本号，自动获取 |

构建镜像时会运行 `steamcmd.sh +quit`，完成 SteamCMD 自身的初始化和更新，再从其安装清单 `/steamcmd/package/steam_cmd_linux.installed` 中读取 `version`，保存到 `/steamcmd/version.txt`。发布流程读取镜像内的该文件，直接以工具版本号作为标签；获取失败会终止构建或发布，无需手动填写版本号。

发布完成后即可按 SteamCMD 工具版本号拉取，例如：

```bash
docker pull ghcr.io/snail-one/palworld-server:1791918946
```

将示例编号替换为实际发布的 SteamCMD 版本号。使用 Docker Compose 时，将 `docker-compose.yml` 中的 `image` 设置为相同镜像地址，再执行 `docker compose pull` 和 `docker compose up -d`。

版本标签记录**镜像构建时的 SteamCMD 工具版本**。SteamCMD 在后续运行时仍可能自动更新。帕鲁服务端在容器启动时下载和更新，选择该标签不会锁定或回退游戏版本。同一 SteamCMD 版本再次发布时，对应标签会指向新镜像；需要区分容器代码时可使用 `sha-<提交短哈希>`。

SteamCMD 工具版本也会写入镜像标签元数据，可通过以下命令查看：

```bash
docker image inspect ghcr.io/snail-one/palworld-server:latest \
  --format '{{ index .Config.Labels "io.palworld.steamcmd.version" }}'
```

## ⚙️ 配置参数

### 环境变量配置

在 `docker-compose.yml` 中可以调整以下环境变量：

| 变量名 | 描述 | 默认值 | 示例 |
|--------|------|--------|------|
| **服务器基础设置** |
| `MAX_PLAYERS` | 最大玩家数量 | `16` | `32` |
| `SERVER_PORT` | 游戏服务器端口 | `8211` | `8211` |
| `PUBLIC_IP` | 社区服务器公网IP地址 | 游戏自动检测 | `203.0.113.10` |
| `PUBLIC_PORT` | 社区服务器公网端口，不改变监听端口 | 游戏自动检测 | `8211` |
| `PUBLIC_LOBBY` | 社区服务器模式 | `false` | `true` |
| `ENABLE_MULTITHREADING` | 启用可选多线程参数 | `false` | `true` |
| `WORKER_THREADS` | 工作线程数，需启用 `ENABLE_MULTITHREADING` | 留空，由游戏决定 | `4` |
| `LOG_FORMAT` | 日志格式 | `text` | `json` |
| `ENABLE_GAMEDATA_API` | 启用 GameData API | `false` | `true` |
| **更新管理** |
| `CHECK_UPDATE` | 启动时检查更新 | `true` | `false` |
| `FORCE_UPDATE_ON_START` | 每次启动强制更新 | `false` | `true` |
| **高级设置** |
| `SKIP_CONFIG_WAIT` | 跳过配置等待 | `false` | `true` |
| `SERVER_DIR` | 服务器目录 | `/palworld-server` | - |
| `GAME_ID` | Steam应用ID | `2394010` | - |
| `STEAMCMD_DIR` | SteamCMD目录 | `/steamcmd` | - |

### 配置示例

```yaml
# docker-compose.yml
environment:
  - MAX_PLAYERS=32
  - SERVER_PORT=8211
  - PUBLIC_LOBBY=true
  - FORCE_UPDATE_ON_START=false
  - SKIP_CONFIG_WAIT=true
```

根据[官方启动参数文档](https://docs.palworldgame.com/settings-and-operation/arguments/)，v1.0 及以后，不设置旧多线程参数可能获得更好的性能，因此本容器默认关闭这组参数。需要启用时，设置 `ENABLE_MULTITHREADING=true`，并按实际负载比较性能；`WORKER_THREADS` 可留空，指定时必须为正整数。

从旧版本升级时，如果已经设置 `WORKER_THREADS`，请同时设置 `ENABLE_MULTITHREADING=true`，或清空 `WORKER_THREADS` 使用游戏默认行为。两个新增开关 `ENABLE_MULTITHREADING` 和 `ENABLE_GAMEDATA_API` 仅接受 `true` 或 `false`。

### 游戏 INI 配置

游戏设置在 `./config/PalWorldSettings.ini` 中修改，包括 `CrossplayPlatforms`（允许连接的平台）、`RESTAPIEnabled` / `RESTAPIPort`（REST API）、`bIsUseBackupSaveData`（世界备份）、`bAllowClientMod`（客户端 Mod 接入）和 `MaxBuildingLimitNum`（玩家建筑数量限制）。`AllowConnectPlatform` 当前不可用，应使用 `CrossplayPlatforms`。

`ENABLE_GAMEDATA_API` 对应启动参数，不会自动修改上述 REST API 配置。首次安装会复制游戏附带的官方默认配置；已有配置不会自动覆盖或补齐新字段。升级后请对照新版本的 `./palworld/DefaultPalWorldSettings.ini` 和[官方配置参数文档](https://docs.palworldgame.com/settings-and-operation/configuration/)检查所需设置。

## 🎮 服务器管理

### Docker Compose 方式

```bash
# 启动服务器
docker compose up -d

# 停止服务器
docker compose down

# 查看日志
docker compose logs -f

# 重启服务器
docker compose restart
```

### 容器内管理命令

进入容器后可使用简化命令：

```bash
# 进入容器
docker exec -it palworld-server bash

# 管理命令
update  # 检查并更新服务器
status  # 查看状态
```

## 📋 官方启动参数

本容器**严格遵循**幻兽帕鲁官方文档的启动参数规范：

| 参数 | 描述 | 环境变量映射 |
|------|------|-------------|
| `-port=8211` | 服务器监听端口 | `SERVER_PORT` |
| `-players=32` | 最大玩家数量 | `MAX_PLAYERS` |
| `-publiclobby` | 社区服务器模式 | `PUBLIC_LOBBY` |
| `-publicip=x.x.x.x` | 社区服务器公网IP地址，省略时由游戏自动检测 | `PUBLIC_IP` |
| `-publicport=xxxx` | 社区服务器公网端口，省略时由游戏自动检测，不改变监听端口 | `PUBLIC_PORT` |
| `-logformat=text` | 日志格式 | `LOG_FORMAT` |
| `-NumberOfWorkerThreadsServer=X` | 工作线程数，需启用多线程参数 | `WORKER_THREADS` |
| `-useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS` | 可选多线程参数，默认不添加 | `ENABLE_MULTITHREADING=true` |
| `-enable-gamedata-api` | 启用 GameData API | `ENABLE_GAMEDATA_API=true` |

> 📖 详细信息请参考 [官方文档](https://docs.palworldgame.com/settings-and-operation/arguments)

## 🗂️ 数据卷和端口

### 数据卷映射

| 容器路径 | 主机路径 | 描述 |
|----------|----------|------|
| `/palworld-server` | `./palworld` | 服务器数据目录 |
| `/palworld-server/Pal/Saved/Config/LinuxServer` | `./config` | 独立配置目录，包含 `PalWorldSettings.ini` 和 `ConfigConfirmed.ini` |

配置挂载覆盖服务器数据目录中的同名子目录。修改使用 `./config`，备份时也需包含 `./config`；原 `./palworld/Pal/Saved/Config/LinuxServer` 中的旧配置会保留在宿主机，切换后游戏通过新挂载读取配置。

### 网络端口

| 端口 | 协议 | 描述 |
|------|------|------|
| `8211` | UDP | 游戏主端口 |

## 🔧 故障排除

### 常见问题

#### 🚫 服务器无法启动

```bash
# 1. 检查容器日志
docker logs palworld-server

# 2. 检查端口占用
netstat -tulpn | grep :8211

# 3. 检查系统资源
docker stats palworld-server
```

#### 🌐 无法连接服务器

```bash
# 1. 确认服务器状态
docker exec -it palworld-server status

# 2. 检查防火墙设置
sudo ufw allow 8211/udp

# 3. 验证网络配置
docker port palworld-server
```

#### 🔄 更新问题

```bash
# 手动强制更新
docker exec -it palworld-server update

# 或设置强制更新环境变量
# FORCE_UPDATE_ON_START=true
```

### 调试技巧

1. **查看详细日志**：
   ```bash
   docker logs --details palworld-server
   ```

2. **进入容器调试**：
   ```bash
   docker exec -it palworld-server bash
   ```

3. **检查配置文件**：
   ```bash
   # 查看游戏配置
   cat ./config/PalWorldSettings.ini
   
   # 查看配置确认状态
   cat ./config/ConfigConfirmed.ini
   ```

## 🤝 贡献指南

欢迎提交问题和改进建议。提交前建议先运行一次：

```bash
python3 -B -m unittest discover -s tests -v
docker compose config
docker build -t palworld-server .
```

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📞 技术支持

- 🐛 问题反馈：[GitHub Issues](https://github.com/Snail-one/palworld-server/issues)
- 📖 官方文档：[Palworld 官方文档](https://docs.palworldgame.com/)
- 💬 社区讨论：[GitHub Discussions](https://github.com/Snail-one/palworld-server/discussions)

---

⭐ 如果这个项目对你有帮助，请给个星标支持一下！ 
