# Docker 部署指南

本文档提供两种架构的 Docker 镜像构建和运行步骤。

---

## 一、本地环境（NVIDIA x86_64）

### 1.1 构建镜像

```bash
# 在项目根目录执行
docker build -t data-preprocessing:v1.0.0 .
```

**说明：**
- 默认构建 x86_64 架构镜像
- 构建时会自动配置 Prisma 为 `linux-musl-openssl-3.0.x` 目标
- 镜像大小约 500MB-800MB（取决于依赖）

### 1.2 运行容器

```bash
docker run -d \
  --name data-preprocessing \
  -p 1717:1717 \
  -v $(pwd)/data:/app/prisma \
  data-preprocessing:v1.0.0
```

**参数说明：**
- `-d`: 后台运行
- `--name`: 容器名称
- `-p 1717:1717`: 映射端口（宿主机:容器）
- `-v $(pwd)/data:/app/prisma`: 数据持久化到本地 `./data` 目录

### 1.3 访问应用

浏览器访问：`http://localhost:1717`

### 1.4 查看日志

```bash
docker logs -f data-preprocessing
```

### 1.5 停止和删除

```bash
# 停止容器
docker stop data-preprocessing

# 删除容器
docker rm data-preprocessing

# 删除镜像（可选）
docker rmi data-preprocessing:latest
```

---

## 二、离线麒麟环境（ARM CPU）

### 2.1 在 x86 机器上交叉编译 ARM 镜像

**前提：** Docker Desktop 已启用 BuildKit 和多架构支持

```bash
# 1. 创建并使用 buildx 构建器
docker buildx create --name multiarch --use
docker buildx inspect --bootstrap

# 2. 构建 ARM64 镜像并导出为 tar 文件
docker buildx build \
  --platform linux/arm64 \
  -t data-preprocessing:arm64 \
  --output type=docker,dest=data-preprocessing-arm64.tar \
  .
```

**说明：**
- `--platform linux/arm64`: 指定 ARM64 架构
- `--output type=docker,dest=...`: 导出为 tar 文件，方便离线传输
- 构建时会自动配置 Prisma 为 `linux-musl-arm64-openssl-3.0.x`

### 2.2 传输到麒麟服务器

```bash
# 使用 scp 或其他方式传输
scp data-preprocessing-arm64.tar user@kylin-server:/path/to/destination/
```

### 2.3 在麒麟服务器上加载和运行

```bash
# 1. 加载镜像
docker load -i data-preprocessing-arm64.tar

# 2. 查看镜像是否加载成功
docker images | grep data-preprocessing

# 3. 运行容器
docker run -d \
  --name data-preprocessing \
  -p 1717:1717 \
  -v /data/preprocessing:/app/prisma \
  data-preprocessing:arm64
```

**麒麟环境注意事项：**
- 确保 `/data/preprocessing` 目录有写权限
- 如果防火墙开启，需放行 1717 端口
- 首次启动会自动初始化数据库（约 10-30 秒）

### 2.4 验证运行状态

```bash
# 查看容器状态
docker ps | grep data-preprocessing

# 查看启动日志
docker logs data-preprocessing

# 检查数据库文件
ls -lh /data/preprocessing/
```

---

## 三、Docker Compose 方式（可选）

项目已包含 `docker-compose.yml`，可使用以下命令：

```bash
# 启动
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止
docker-compose down
```

---

## 四、环境变量配置

创建 `.env` 文件（可选，用于配置 LLM API 等）：

```bash
# OpenAI API（如果需要）
OPENAI_API_KEY=your_key_here
OPENAI_BASE_URL=https://api.openai.com/v1

# 其他配置...
```

---

## 五、故障排查

### 5.1 容器启动失败

```bash
# 查看详细错误信息
docker logs data-preprocessing

# 检查端口占用
netstat -tuln | grep 1717
```

### 5.2 数据库初始化失败

```bash
# 进入容器手动初始化
docker exec -it data-preprocessing sh
cd /app
pnpm prisma db push --accept-data-loss
```

### 5.3 ARM 镜像在麒麟上无法运行

检查 CPU 架构：
```bash
uname -m  # 应输出 aarch64 或 armv8
```

如果提示架构不匹配，重新构建对应架构的镜像。

---

## 六、性能优化建议

1. **生产环境**：设置 `NODE_ENV=production`（Dockerfile 已配置）
2. **数据持久化**：务必挂载 `/app/prisma` 卷，避免容器重启数据丢失
3. **资源限制**：
   ```bash
   docker run -d \
     --name data-preprocessing \
     --memory="2g" \
     --cpus="2" \
     -p 1717:1717 \
     -v $(pwd)/data:/app/prisma \
     data-preprocessing:v1.0.0
   ```

---

## 七、更新镜像

```bash
# 1. 拉取最新代码
git pull origin main

# 2. 重新构建
docker build -t data-preprocessing:v1.0.0 .

# 3. 停止旧容器
docker stop data-preprocessing
docker rm data-preprocessing

# 4. 启动新容器（保留数据卷）
docker run -d \
  --name data-preprocessing \
  -p 1717:1717 \
  -v $(pwd)/data:/app/prisma \
  data-preprocessing:v1.0.0
```

---

**完成！** 如有问题，请检查日志或联系技术支持。
