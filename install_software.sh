#!/bin/bash

# ==============================================================================
# 软件一键安装脚本 / One-click software installer
#
# 功能 / Features:
#   - 自动安装 Chromium、wget、Clash Verge、VS Code 和 Bilibili 客户端
#   - Installs Chromium, wget, Clash Verge, VS Code and the Bilibili client
#   - 自动检测 Debian 12 (bookworm) / Debian 13 (trixie) 与 arm64/amd64 架构
#   - Auto-detects Debian 12 (bookworm) / Debian 13 (trixie) and arm64/amd64
#   - 同时兼容 Android 16 与 Android 17 终端 (Cinnamon Bun) 环境
#   - Compatible with the Linux Terminal on both Android 16 and Android 17
# ==============================================================================

set -u

# 颜色定义 / Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- 辅助函数 / Helpers ---
print_separator() {
    echo -e "${BLUE}=============================================${NC}"
}

# 检查上一条命令执行结果 / Check status of the last command
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ 成功 / OK${NC}"
    else
        echo -e "${RED}✗ 失败 / FAILED${NC}"
        exit 1
    fi
}

# --- 环境检测 / Environment detection ---
if [ ! -r /etc/os-release ]; then
    echo -e "${RED}[ERROR]${NC} /etc/os-release missing - cannot determine distribution. Aborting."
    exit 1
fi
# shellcheck disable=SC1091
. /etc/os-release
if [ "${ID:-}" != "debian" ]; then
    echo -e "${RED}[ERROR]${NC} Unsupported distribution: ID='${ID:-unknown}'. This script supports Debian 12/13 only."
    exit 1
fi
DEBIAN_CODENAME="${VERSION_CODENAME:-}"
case "$DEBIAN_CODENAME" in
    bookworm|trixie) ;;
    *)
        echo -e "${RED}[ERROR]${NC} Unsupported Debian codename: '${DEBIAN_CODENAME}'. Supported: bookworm (12), trixie (13)."
        exit 1
        ;;
esac

ARCH=$(dpkg --print-architecture)
case "$ARCH" in
    arm64|amd64) ;;
    *)
        echo -e "${RED}[ERROR]${NC} Unsupported architecture: '$ARCH'. Supported: arm64, amd64."
        exit 1
        ;;
esac

echo -e "${BLUE}检测到 / Detected:${NC} Debian ${VERSION_ID:-?} (${DEBIAN_CODENAME}) ${ARCH}"
print_separator

# 更新软件包列表 / Update package list
echo -e "\n${YELLOW}🔄 正在更新软件包列表 / Updating package list...${NC}"
print_separator
sudo apt-get update
check_status

# 安装基础工具 (curl/wget/jq/gpg) / Base tools
echo -e "\n${YELLOW}🧰 正在安装基础工具 (curl, wget, jq, gpg) / Installing base tools...${NC}"
print_separator
sudo apt-get install -y curl wget jq gpg ca-certificates
check_status

# 安装 Chromium 浏览器 / Chromium
echo -e "\n${YELLOW}🌐 正在安装 Chromium 浏览器 / Installing Chromium...${NC}"
print_separator
sudo apt-get install -y chromium
check_status

# --- Clash Verge ---
# 使用官方 API 获取最新版本 / Fetch latest release from GitHub API
echo -e "\n${YELLOW}🔍 查询 Clash Verge 最新版本 / Querying latest Clash Verge release...${NC}"
LATEST_CLASH_RELEASE=$(curl -fsSL https://api.github.com/repos/clash-verge-rev/clash-verge-rev/releases/latest | jq -r '.tag_name')
if [ -z "$LATEST_CLASH_RELEASE" ] || [ "$LATEST_CLASH_RELEASE" = "null" ]; then
    echo -e "${RED}✗ 无法获取 Clash Verge 最新版本号 / Failed to obtain Clash Verge release tag${NC}"
    exit 1
fi
VERSION_CLASH_WITHOUT_V="${LATEST_CLASH_RELEASE#v}"
echo "最新版本号 / Latest tag: $LATEST_CLASH_RELEASE"

CLASH_DEB="Clash.Verge_${VERSION_CLASH_WITHOUT_V}_${ARCH}.deb"
echo -e "\n${YELLOW}🛡️ 下载 Clash Verge (${LATEST_CLASH_RELEASE} ${ARCH}) / Downloading Clash Verge...${NC}"
print_separator
wget -q --show-progress \
    "https://github.com/clash-verge-rev/clash-verge-rev/releases/download/${LATEST_CLASH_RELEASE}/${CLASH_DEB}" \
    -O "${CLASH_DEB}"
check_status

echo -e "\n${YELLOW}🛠️ 安装 Clash Verge / Installing Clash Verge...${NC}"
print_separator
sudo apt-get install -y --fix-broken "./${CLASH_DEB}"
check_status

# --- VS Code ---
echo -e "\n${YELLOW}💻 配置 VS Code 仓库 / Setting up VS Code repository...${NC}"
print_separator
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg
sudo apt-get update
check_status

echo -e "\n${YELLOW}🛠️ 安装 VS Code / Installing VS Code...${NC}"
print_separator
sudo apt-get install -y code
check_status

# --- Bilibili 客户端 / Bilibili client ---
echo -e "\n${YELLOW}🔍 查询 Bilibili 客户端最新版本 / Querying latest Bilibili client release...${NC}"
LATEST_BILIBILI_RELEASE=$(curl -fsSL https://api.github.com/repos/msojocs/bilibili-linux/releases/latest | jq -r '.tag_name')
if [ -z "$LATEST_BILIBILI_RELEASE" ] || [ "$LATEST_BILIBILI_RELEASE" = "null" ]; then
    echo -e "${RED}✗ 无法获取 Bilibili 客户端最新版本号 / Failed to obtain Bilibili release tag${NC}"
    exit 1
fi
VERSION_BILIBILI_WITHOUT_V="${LATEST_BILIBILI_RELEASE#v}"
echo "最新版本号 / Latest tag: $LATEST_BILIBILI_RELEASE"

BILIBILI_DEB="io.github.msojocs.bilibili_${VERSION_BILIBILI_WITHOUT_V}_${ARCH}.deb"
echo -e "\n${YELLOW}📺 下载 Bilibili 客户端 (${LATEST_BILIBILI_RELEASE} ${ARCH}) / Downloading Bilibili client...${NC}"
print_separator
wget -q --show-progress \
    "https://github.com/msojocs/bilibili-linux/releases/download/${LATEST_BILIBILI_RELEASE}/${BILIBILI_DEB}" \
    -O "${BILIBILI_DEB}"
check_status

echo -e "\n${YELLOW}🛠️ 安装 Bilibili 客户端 / Installing Bilibili client...${NC}"
print_separator
sudo dpkg -i "${BILIBILI_DEB}" || sudo apt-get -f install -y
check_status

# --- 清理 / Cleanup ---
echo -e "\n${YELLOW}🧹 清理安装包 / Cleaning up installer files...${NC}"
print_separator
rm -f "${CLASH_DEB}" "${BILIBILI_DEB}"
check_status

# --- Pi-Apps (可选) / Pi-Apps (optional) ---
echo -e "\n${GREEN}🍰 安装 Pi-Apps / Installing Pi-Apps...${NC}"
print_separator
wget -qO- https://raw.githubusercontent.com/Botspot/pi-apps/master/install | bash || \
    echo -e "${YELLOW}Pi-Apps 安装失败或被跳过 / Pi-Apps install failed or skipped${NC}"

# --- 完成提示 / Done ---
echo -e "\n${GREEN}🎉 所有软件安装完成！/ All software installed!${NC}"
echo -e "${BLUE}已安装以下软件 / Installed:${NC}"
echo -e "${BLUE}• Chromium${NC}"
echo -e "${BLUE}• curl / wget / jq${NC}"
echo -e "${BLUE}• Clash Verge (${LATEST_CLASH_RELEASE})${NC}"
echo -e "${BLUE}• VS Code${NC}"
echo -e "${BLUE}• Bilibili 客户端 (${LATEST_BILIBILI_RELEASE})${NC}"
print_separator
