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
- 挂载到 `./palworld` 的目录必须允许容器写入

### 1. 克隆仓库

```bash
git clone git@github.com:Snail-one/palworld-server.git
cd palworld-server
```

### 2. 启动服务器

```bash
docker compose up -d
```

或使用便捷脚本：
```bash
./start-server.sh
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

1. 编辑游戏配置：`./palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini`
2. 修改确认文件：`./palworld/Pal/Saved/Config/LinuxServer/ConfigConfirmed.ini`
3. 将 `CONFIG_CONFIRMED=false` 改为 `CONFIG_CONFIRMED=true`

> 💡 **提示**：设置 `SKIP_CONFIG_WAIT=true` 可跳过配置等待，直接使用默认配置启动

## ⚙️ 配置参数

### 环境变量配置

在 `docker-compose.yml` 中可以调整以下环境变量：

| 变量名 | 描述 | 默认值 | 示例 |
|--------|------|--------|------|
| **服务器基础设置** |
| `MAX_PLAYERS` | 最大玩家数量 | `16` | `32` |
| `SERVER_PORT` | 游戏服务器端口 | `8211` | `8211` |
| `PUBLIC_IP` | 公网IP地址 | 自动检测 | `192.168.1.100` |
| `PUBLIC_PORT` | 公网端口 | 使用SERVER_PORT | `8211` |
| `PUBLIC_LOBBY` | 社区服务器模式 | `false` | `true` |
| `WORKER_THREADS` | 工作线程数 | 自动检测 | `4` |
| `LOG_FORMAT` | 日志格式 | `text` | `json` |
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

### 便捷脚本

```bash
# 启动服务器
./start-server.sh

# 停止服务器
./stop-server.sh
```

## 📋 官方启动参数

本容器**严格遵循**幻兽帕鲁官方文档的启动参数规范：

| 参数 | 描述 | 环境变量映射 |
|------|------|-------------|
| `-port=8211` | 服务器监听端口 | `SERVER_PORT` |
| `-players=32` | 最大玩家数量 | `MAX_PLAYERS` |
| `-publiclobby` | 社区服务器模式 | `PUBLIC_LOBBY` |
| `-publicip=x.x.x.x` | 指定公网IP地址 | `PUBLIC_IP` |
| `-publicport=xxxx` | 指定公网端口 | `PUBLIC_PORT` |
| `-logformat=text` | 日志格式 | `LOG_FORMAT` |
| `-NumberOfWorkerThreadsServer=X` | 工作线程数 | `WORKER_THREADS` |
| `-useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS` | 多线程性能优化 | 自动应用 |

> 📖 详细信息请参考 [官方文档](https://docs.palworldgame.com/settings-and-operation/arguments)

## 🗂️ 数据卷和端口

### 数据卷映射

| 容器路径 | 主机路径 | 描述 |
|----------|----------|------|
| `/palworld-server` | `./palworld` | 服务器数据目录 |

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
   cat ./palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
   
   # 查看配置确认状态
   cat ./palworld/Pal/Saved/Config/LinuxServer/ConfigConfirmed.ini
   ```

## 🤝 贡献指南

欢迎提交问题和改进建议。提交前建议先运行一次：

```bash
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
