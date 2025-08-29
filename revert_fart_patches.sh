#!/bin/bash

# FART_15 补丁撤销脚本
# 用法: ./revert_fart_patches.sh [ANDROID_SOURCE_PATH]
# 默认: Android 源码路径为 ../

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认路径
ANDROID_ROOT=${1:-$PWD/../}

echo -e "${BLUE}=== FART_15 补丁撤销脚本 ===${NC}"
echo -e "Android 源码路径: ${YELLOW}$ANDROID_ROOT${NC}"
echo ""

# 检查路径是否存在
if [ ! -d "$ANDROID_ROOT" ]; then
    echo -e "${RED}错误: Android 源码路径不存在: $ANDROID_ROOT${NC}"
    exit 1
fi

# 确认操作
echo -e "${YELLOW}警告: 此操作将撤销所有 FART_15 相关的修改${NC}"
printf "是否继续? (y/N): "
read REPLY
case "$REPLY" in
    [Yy]|[Yy][Ee][Ss])
        echo "继续执行撤销操作..."
        ;;
    *)
        echo "操作已取消"
        exit 0
        ;;
esac

# 撤销 ART 修改
echo -e "${BLUE}撤销 ART Runtime 修改...${NC}"
cd "$ANDROID_ROOT/art"
if [ ! -d ".git" ]; then
    echo -e "${RED}错误: art 目录不是 git 仓库${NC}"
    exit 1
fi

echo "当前目录: $(pwd)"
git checkout -- .
git clean -fd
echo -e "${GREEN}✓ ART 修改已撤销${NC}"
echo ""

# 撤销 Framework Base 修改
echo -e "${BLUE}撤销 Framework Base 修改...${NC}"
cd "$ANDROID_ROOT/frameworks/base"
if [ ! -d ".git" ]; then
    echo -e "${RED}错误: frameworks/base 目录不是 git 仓库${NC}"
    exit 1
fi

echo "当前目录: $(pwd)"
git checkout -- .
git clean -fd
echo -e "${GREEN}✓ Framework 修改已撤销${NC}"
echo ""

# 撤销 Libcore 修改
echo -e "${BLUE}撤销 Libcore 修改...${NC}"
cd "$ANDROID_ROOT/libcore"
if [ ! -d ".git" ]; then
    echo -e "${RED}错误: libcore 目录不是 git 仓库${NC}"
    exit 1
fi

echo "当前目录: $(pwd)"
git checkout -- .
git clean -fd
echo -e "${GREEN}✓ Libcore 修改已撤销${NC}"
echo ""

# 验证撤销结果
echo -e "${BLUE}验证撤销结果...${NC}"

echo -e "${YELLOW}检查 ART 状态:${NC}"
cd "$ANDROID_ROOT/art"
git status --porcelain

echo -e "${YELLOW}检查 Framework 状态:${NC}"
cd "$ANDROID_ROOT/frameworks/base"
git status --porcelain

echo -e "${YELLOW}检查 Libcore 状态:${NC}"
cd "$ANDROID_ROOT/libcore"
git status --porcelain

echo ""
echo -e "${GREEN}=== 所有 FART_15 修改已撤销! ===${NC}"
echo -e "${YELLOW}源码已恢复到原始状态${NC}"
