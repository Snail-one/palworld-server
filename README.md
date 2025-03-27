# 幻兽帕鲁专用服务器 Docker 容器

这是一个用于运行幻兽帕鲁（Palworld）专用服务器的Docker容器。这个容器基于Ubuntu，并包含了多种功能，如自动备份、配置文件管理等。

## 特性

- 非root用户运行，避免权限问题
- 自动备份系统
- 支持RCON远程管理
- 容器启动时自动检查更新
- 自动复制官方配置文件
- 配置文件向导
- 简化的服务器管理命令：restart、stop、update

## 快速开始

### 使用Docker Compose

1. 克隆本仓库
2. 启动容器：

```bash
docker-compose up -d
```

3. 查看日志：

```bash
docker-compose logs -f
```

### 初始配置

首次启动时，容器会：

1. 安装服务器（如果未安装）
2. 自动寻找并复制官方配置文件（如果找不到则创建默认配置）
3. 等待用户确认配置（5分钟内，可通过SKIP_CONFIG_WAIT选项跳过）
4. 启动服务器

要确认配置：

1. 编辑游戏配置文件：`./server-data/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini`
2. 在配置确认文件中修改参数：`./server-data/Pal/Saved/Config/LinuxServer/ConfigConfirmed.ini`
3. 将文件中的 `CONFIG_CONFIRMED=false` 改为 `CONFIG_CONFIRMED=true`

**注意**：如果您在5分钟内未确认配置，容器将自动停止。这是为了确保服务器使用正确的配置运行。每次修改游戏配置后，需要重新确认配置（将 `CONFIG_CONFIRMED` 再次设置为 `true`）。

### 环境变量

在`docker-compose.yml`中，你可以修改以下环境变量：

#### 服务器参数
- `SERVER_PORT`: 服务器端口 (默认: 8211)
- `MAX_PLAYERS`: 最大玩家数量 (默认: 16)
- `PUBLIC_IP`: 公共IP地址，留空为自动检测
- `PUBLIC_PORT`: 公共端口，留空为使用SERVER_PORT
- `PUBLIC_LOBBY`: 是否为社区服务器 (默认: false)
- `WORKER_THREADS`: 工作线程数，留空为自动

#### 备份相关
- `ENABLE_BACKUPS`: 是否启用自动备份 (默认: true)
- `BACKUP_INTERVAL`: 备份间隔小时数 (默认: 6)
- `BACKUP_RETENTION`: 保留备份数量 (默认: 10)
- `BACKUP_ON_STOP`: 停止时是否备份 (默认: true)

#### 更新与配置相关
- `CHECK_UPDATE`: 启动时是否检查更新 (默认: true)
- `CHECK_UPDATE_ON_RESTART`: 重启时是否检查更新 (默认: true)
- `SKIP_CONFIG_WAIT`: 是否跳过配置等待 (默认: false)，设为true时将自动使用官方配置文件并跳过等待确认步骤

## 备份

备份文件保存在`./backups`目录中。备份包括：

- 自动备份（根据`BACKUP_INTERVAL`设置）
- 每日备份（每天0点）
- 每周备份（每周日0点）
- 手动备份（当你执行备份命令时）

## 停止服务器

```bash
docker-compose down
```

## 技术支持

如有问题，请提交Issue或查阅官方文档。

## 功能特点

- 🐳 **Docker容器化**：简化部署和管理
- 🔄 **自动更新**：保持服务器版本最新
- 💾 **自动备份**：定期备份游戏数据
- 🖥️ **美观的终端界面**：彩色文本和ASCII艺术
- 📊 **状态监控**：查看服务器运行状态和资源使用情况
- 📝 **详细日志**：提供服务器运行日志记录
- ✅ **官方兼容**：仅使用官方文档提供的启动参数
- 📄 **官方配置**：自动使用官方配置文件

## 系统要求

- Docker 和 Docker Compose
- 至少4GB RAM
- 至少10GB可用磁盘空间
- 良好的网络连接

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/your-username/palworld-docker.git
cd palworld-docker
```

### 2. 配置服务器

编辑`docker-compose.yml`文件，根据您的需求调整环境变量：

```yaml
environment:
  - MAX_PLAYERS=32
  - SERVER_PORT=8211
  - PUBLIC_LOBBY=true
  # 其他配置...
```

### 3. 启动服务器

```bash
docker-compose up -d
```
或使用提供的脚本：
```bash
./start-server.sh
```

### 4. 查看服务器状态

```bash
docker exec -it palworld-server /scripts/status.sh
```

### 5. 查看服务器日志

```bash
docker logs -f palworld-server
```

## 服务器管理

### 停止服务器

```bash
docker exec -it palworld-server /scripts/stop.sh
```
或使用提供的脚本：
```bash
./stop-server.sh
```

### 重启服务器

```bash
docker exec -it palworld-server /scripts/restart.sh
```

### 手动备份

```bash
docker exec -it palworld-server /scripts/backup.sh manual
```

### 更新服务器

```bash
docker exec -it palworld-server /scripts/update.sh
```

## 环境变量

| 变量 | 描述 | 默认值 |
|------|-------------|---------|
| MAX_PLAYERS | 最大玩家数 | 16 |
| SERVER_PORT | 服务器端口 | 8211 |
| PUBLIC_IP | 公共IP地址 | 自动检测 |
| PUBLIC_PORT | 公共端口 | 使用SERVER_PORT |
| PUBLIC_LOBBY | 是否为社区服务器 | false |
| WORKER_THREADS | 工作线程数 | 自动 |
| LOG_FORMAT | 日志格式 (text或json) | text |
| RCON_ENABLED | RCON是否启用 | true |
| RCON_PORT | RCON端口 | 25575 |
| CHECK_UPDATE | 启动时检查更新 | true |
| ENABLE_BACKUPS | 启用自动备份 | true |
| BACKUP_INTERVAL | 备份间隔（小时） | 6 |
| BACKUP_RETENTION | 备份保留数量 | 10 |
| BACKUP_ON_STOP | 停止时备份 | true |
| CHECK_UPDATE_ON_RESTART | 重启时检查更新 | true |
| SKIP_CONFIG_WAIT | 是否跳过配置等待 | false |
| SERVER_DIR | 服务器数据目录路径 | /palworld-server |
| BACKUP_DIR | 备份目录路径 | /backups |
| GAME_ID | 幻兽帕鲁服务器的Steam应用ID | 2394010 |
| STEAMCMD_DIR | SteamCMD安装目录 | /steamcmd |

## 官方启动参数

此容器**仅**支持幻兽帕鲁官方文档中的启动参数：

- `-port=8211`: 更改服务器监听端口
- `-players=32`: 更改服务器最大参与者数量
- `-useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS`: 改善多线程CPU环境下的性能
- `-NumberOfWorkerThreadsServer=X`: 设置处理线程数
- `-publiclobby`: 将服务器设置为社区服务器
- `-publicip=x.x.x.x`: 手动指定服务器运行的网络全局IP地址
- `-publicport=xxxx`: 手动指定服务器运行的网络端口号
- `-logformat=text`: 更改日志格式（text或json）

详细信息可以参考[官方文档](https://docs.palworldgame.com/settings-and-operation/arguments)。

## 数据卷

- `./server-data:/palworld-server`: 服务器数据目录
- `./backups:/backups`: 备份目录

## 端口

- `8211/udp`: 游戏端口
- `27015/udp`: 查询端口

## 故障排除

### 服务器无法启动

1. 检查服务器日志: `docker logs palworld-server`
2. 确保端口没有被其他应用占用
3. 检查系统资源是否充足

### 无法连接到服务器

1. 确保防火墙允许UDP端口8211和27015
2. 检查服务器是否真正在运行: `docker exec -it palworld-server /scripts/status.sh`
3. 确保您的网络配置正确

## 许可证

MIT

## 贡献

欢迎提交PR和问题！


## 容器内管理命令

容器内置了简化的服务器管理命令，可以直接使用：

1. `restart` - 重启幻兽帕鲁服务器
2. `stop` - 停止幻兽帕鲁服务器
3. `update` - 更新幻兽帕鲁服务器到最新版本

使用示例：

```bash
# 进入容器
docker exec -it palworld-server bash

# 使用命令
restart  # 重启服务器
stop     # 停止服务器
update   # 更新服务器
```

这些命令是对应脚本的快捷方式，提供了更简单的服务器管理体验。 