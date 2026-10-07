#!/bin/bash

# ====================================================================================
# Debian 12/13/14+ 升级脚本 (2026 优化版)
# Debian 12/13/14+ Upgrade Script (2026 Optimized)
#
# 功能 / Features:
#   - 自动检测当前 Debian 版本并升级至下一个 LTS 版本
#   - Auto-detect Debian version and upgrade to next LTS
#   - 完全自动化模式支持，无需用户交互
#   - Fully autonomous mode, zero user interaction
#   - 支持 Debian 12 → 13 → 14+ 升级路径
#   - Support for 12→13→14+ upgrade paths
#   - 智能备份和恢复机制
#   - Smart backup and recovery mechanisms
#
# 用法 / Usage:
#   ./update_debian14.sh                 # 交互模式 / Interactive
#   AUTO_MODE=1 ./update_debian14.sh    # 自动模式 / Autonomous
# ====================================================================================

set -u

# 配置 / Config
AUTO_MODE="${AUTO_MODE:-0}"
STATE_DIR="$HOME/.debian-upgrade-state"
STATE_FILE="$STATE_DIR/upgrade.state"
BACKUP_DIR="/var/backups/apt-sources-backup"

mkdir -p "$STATE_DIR" "$BACKUP_DIR"

# --- 颜色定义 / Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

err()  { echo -e "${RED}[✗]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
info() { echo -e "${GREEN}[✓]${NC} $*"; }
note() { echo -e "${BLUE}[i]${NC} $*"; }

# --- 状态管理 / State management ---
function step_done() { echo "$1" >> "$STATE_FILE"; }
function is_step_done() { grep -q "^$1$" "$STATE_FILE" 2>/dev/null; }

# --- 检测当前 Debian 版本 / Detect current Debian release ---
if [ ! -r /etc/os-release ]; then
    err "Cannot find /etc/os-release"
    exit 1
fi

. /etc/os-release

if [ "${ID:-}" != "debian" ]; then
    err "Not running Debian (ID='${ID:-unknown}')"
    exit 1
fi

CODENAME="${VERSION_CODENAME:-}"
VERSION_NUM="${VERSION_ID:-0}"

# 确定目标版本 / Determine target version
case "$CODENAME" in
    bookworm)
        TARGET_CODENAME="trixie"
        TARGET_VERSION="13"
        ;;
    trixie)
        TARGET_CODENAME="forky"
        TARGET_VERSION="14"
        ;;
    forky)
        info "Already on Debian 14 (forky) or newer - no upgrade needed"
        exit 0
        ;;
    *)
        err "Unsupported Debian codename: '$CODENAME'"
        exit 1
        ;;
esac

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Debian Upgrade Tool - 2026 Optimized                 ║${NC}"
echo -e "${CYAN}║   Current: Debian $VERSION_NUM ($CODENAME)                    ║${NC}"
echo -e "${CYAN}║   Target:  Debian $TARGET_VERSION ($TARGET_CODENAME)                    ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# --- 检测 Android Terminal / Detect Android Terminal ---
if grep -qiE 'crosvm|google,gunyah|android' /proc/cpuinfo 2>/dev/null \
   || [ -d /sys/firmware/devicetree/base/avf ] 2>/dev/null; then
    warn "Detected Android Terminal environment"
    warn "⚠️  In-place upgrades may risk VM image corruption"
    warn "Consider waiting for official image or using desktop Debian instead"
    echo ""
    if [ "$AUTO_MODE" != "1" ]; then
        read -p "Proceed with upgrade? (yes/N): " ack
        if [ "$ack" != "yes" ]; then
            info "Cancelled by user"
            exit 0
        fi
    fi
fi

# --- 步骤 1: 检查磁盘空间 / Step 1: Check disk space ---
if ! is_step_done "check_disk"; then
    note "Checking available disk space..."
    AVAIL=$(df /var | awk 'NR==2 {print $4}')
    if [ "$AVAIL" -lt 5242880 ]; then  # 5GB in KB
        warn "Less than 5GB available - upgrade may fail"
    fi
    step_done "check_disk"
fi

# --- 步骤 2: 更新当前发行版 / Step 2: Update current release ---
if ! is_step_done "update_current"; then
    info "Updating current release..."
    sudo apt-get update -qq
    sudo apt-get full-upgrade -yq
    
    # 检查是否需要重启 / Check for required reboot
    if [ -f /var/run/reboot-required ]; then
        warn "Kernel update detected - reboot required before continuing"
        warn "After reboot, re-run this script"
        if [ "$AUTO_MODE" = "1" ]; then
            sudo reboot
        fi
        exit 0
    fi
    step_done "update_current"
fi

# --- 步骤 3-5: 切换仓库 / Steps 3-5: Switch repositories ---
if ! is_step_done "switch_repos"; then
    info "Backing up and switching repositories to $TARGET_CODENAME..."
    
    # 备份主仓库 / Backup main sources
    if [ -f /etc/apt/sources.list ]; then
        BACKUP_NAME="$BACKUP_DIR/sources.list.${CODENAME}.$(date +%s).bak"
        sudo cp /etc/apt/sources.list "$BACKUP_NAME"
        info "Backup saved to: $BACKUP_NAME"
        
        # 切换到新版本 / Switch to new release
        sudo sed -i "s/\\b${CODENAME}\\b/${TARGET_CODENAME}/g" /etc/apt/sources.list
    fi
    
    # 处理 sources.list.d / Handle sources.list.d
    if [ -d /etc/apt/sources.list.d ]; then
        find /etc/apt/sources.list.d -type f \( -name '*.list' -o -name '*.sources' \) \
            -exec sudo sed -i.bak "s/\\b${CODENAME}\\b/${TARGET_CODENAME}/g" {} \;
    fi
    
    info "Repository files updated"
    step_done "switch_repos"
fi

# --- 步骤 6: 重新加载仓库 / Step 6: Reload repository lists ---
if ! is_step_done "reload_repos"; then
    info "Reloading repository lists..."
    sudo apt-get update -qq
    step_done "reload_repos"
fi

# --- 步骤 7: 可选安装 screen / Step 7: Optional screen for SSH safety ---
if ! is_step_done "check_screen"; then
    if ! command -v screen &> /dev/null && [ "$AUTO_MODE" != "1" ]; then
        read -p "Install screen for SSH connection safety? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo apt-get install -yq screen
            note "Re-run this script inside screen: screen -S upgrade $0"
            exit 0
        fi
    fi
    step_done "check_screen"
fi

# --- 步骤 8: 执行完整发行版升级 / Step 8: Full dist-upgrade ---
if ! is_step_done "dist_upgrade"; then
    info "Performing full distribution upgrade to $TARGET_VERSION..."
    info "(This may take 15-30 minutes)"
    
    # 关键升级 / Key upgrade
    sudo DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -yq \
        -o Dpkg::Options::="--force-confnew" \
        -o Dpkg::Options::="--force-confmiss"
    
    step_done "dist_upgrade"
fi

# --- 步骤 9: 清理 / Step 9: Cleanup ---
if ! is_step_done "cleanup"; then
    info "Cleaning up old packages..."
    sudo apt-get autoremove -yq
    sudo apt-get clean
    step_done "cleanup"
fi

# --- 步骤 10: 现代化 sources / Step 10: Modernize sources (Debian 13+ feature) ---
if ! is_step_done "modernize"; then
    if command -v apt &> /dev/null && apt --help 2>&1 | grep -q "modernize-sources"; then
        if [ "$AUTO_MODE" = "1" ]; then
            info "Converting sources.list to deb822 format..."
            sudo apt modernize-sources -y 2>/dev/null || warn "modernize-sources skipped"
        fi
    fi
    step_done "modernize"
fi

# --- 完成 / Completion ---
echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Upgrade to Debian $TARGET_VERSION ($TARGET_CODENAME) complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo ""
note "System will reboot in 10 seconds to apply all changes"
note "You can cancel with Ctrl+C if needed"

if [ "$AUTO_MODE" != "1" ]; then
    read -t 10 || true
fi

sudo reboot
