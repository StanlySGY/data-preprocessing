#!/bin/sh
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PRISMA_TEMPLATE_DIR="/app/prisma-template"
PRISMA_DIR="/app/prisma"

echo "${GREEN}=== 数据预处理 数据库初始化 ===${NC}"

# 复制 prisma schema 模板（每次启动都更新）
if [ -d "$PRISMA_TEMPLATE_DIR" ]; then
    mkdir -p "$PRISMA_DIR"
    cp -rn "$PRISMA_TEMPLATE_DIR"/* "$PRISMA_DIR/" 2>/dev/null || true
fi

# 确保 local-db 目录存在
mkdir -p /app/local-db

# 运行 prisma db push 创建/更新数据库 schema
echo "${GREEN}初始化数据库 schema...${NC}"
cd /app
pnpm prisma db push --skip-generate 2>&1 || true

echo "${GREEN}=== 数据库就绪，启动应用 ===${NC}"
echo ""

exec "$@"
