#!/bin/bash

# FART_15 补丁自动应用脚本
# 用法: ./apply_fart_patches.sh [ANDROID_SOURCE_PATH] [FART_15_PATH]
# 默认: Android 源码路径为 ../  FART_15 路径为当前目录

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认路径
ANDROID_ROOT=${1:-$PWD/../}
FART_PATH=${2:-$PWD}

echo -e "${BLUE}=== FART_15 补丁应用脚本 ===${NC}"
echo -e "Android 源码路径: ${YELLOW}$ANDROID_ROOT${NC}"
echo -e "FART_15 路径: ${YELLOW}$FART_PATH${NC}"
echo ""

# 检查路径是否存在
if [ ! -d "$ANDROID_ROOT" ]; then
    echo -e "${RED}错误: Android 源码路径不存在: $ANDROID_ROOT${NC}"
    exit 1
fi

if [ ! -d "$FART_PATH" ]; then
    echo -e "${RED}错误: FART_15 路径不存在: $FART_PATH${NC}"
    exit 1
fi

# 检查补丁文件是否存在
ART_PATCH="$FART_PATH/art/art.patch"
FRAMEWORK_PATCH="$FART_PATH/frameworks/base/frameworks.patch"
LIBCORE_PATCH="$FART_PATH/libcore/libcore.patch"

echo -e "${BLUE}检查补丁文件...${NC}"
for patch in "$ART_PATCH" "$FRAMEWORK_PATCH" "$LIBCORE_PATCH"; do
    if [ ! -f "$patch" ]; then
        echo -e "${RED}错误: 补丁文件不存在: $patch${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓${NC} $(basename "$patch")"
done
echo ""

# 应用 ART 补丁
echo -e "${BLUE}应用 ART Runtime 补丁...${NC}"
cd "$ANDROID_ROOT/art"
if [ ! -d ".git" ]; then
    echo -e "${RED}错误: art 目录不是 git 仓库${NC}"
    exit 1
fi

echo "当前目录: $(pwd)"
git apply --check "$ART_PATCH" 2>/dev/null && \
git apply "$ART_PATCH" && \
echo -e "${GREEN}✓ ART 补丁应用成功${NC}" || \
{
    echo -e "${RED}✗ ART 补丁应用失败${NC}"
    echo "尝试强制应用..."
    git apply --reject --whitespace=fix "$ART_PATCH" || exit 1
}
echo ""

# 应用 Framework Base 补丁
echo -e "${BLUE}应用 Framework Base 补丁...${NC}"
cd "$ANDROID_ROOT/frameworks/base"
if [ ! -d ".git" ]; then
    echo -e "${RED}错误: frameworks/base 目录不是 git 仓库${NC}"
    exit 1
fi

echo "当前目录: $(pwd)"
git apply --check "$FRAMEWORK_PATCH" 2>/dev/null && \
git apply "$FRAMEWORK_PATCH" && \
echo -e "${GREEN}✓ Framework 补丁应用成功${NC}" || \
{
    echo -e "${RED}✗ Framework 补丁应用失败${NC}"
    echo "尝试强制应用..."
    git apply --reject --whitespace=fix "$FRAMEWORK_PATCH" || exit 1
}
echo ""

# 应用 Libcore 补丁
echo -e "${BLUE}应用 Libcore 补丁...${NC}"
cd "$ANDROID_ROOT/libcore"
if [ ! -d ".git" ]; then
    echo -e "${RED}错误: libcore 目录不是 git 仓库${NC}"
    exit 1
fi

echo "当前目录: $(pwd)"
git apply --check "$LIBCORE_PATCH" 2>/dev/null && \
git apply "$LIBCORE_PATCH" && \
echo -e "${GREEN}✓ Libcore 补丁应用成功${NC}" || \
{
    echo -e "${RED}✗ Libcore 补丁应用失败${NC}"
    echo "尝试强制应用..."
    git apply --reject --whitespace=fix "$LIBCORE_PATCH" || exit 1
}
echo ""

# 验证应用结果
echo -e "${BLUE}验证补丁应用结果...${NC}"

echo -e "${YELLOW}ART 修改文件:${NC}"
cd "$ANDROID_ROOT/art"
git status --porcelain | head -10

echo -e "${YELLOW}Framework 修改文件:${NC}"
cd "$ANDROID_ROOT/frameworks/base"
git status --porcelain | head -10

echo -e "${YELLOW}Libcore 修改文件:${NC}"
cd "$ANDROID_ROOT/libcore"
git status --porcelain | head -10

echo ""
echo -e "${GREEN}=== 所有补丁应用完成! ===${NC}"
echo ""