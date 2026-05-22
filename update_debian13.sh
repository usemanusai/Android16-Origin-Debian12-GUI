#!/bin/bash

# ====================================================================================
# Debian 12 (bookworm) → Debian 13 (trixie) 升级脚本
# Debian 12 (bookworm) → Debian 13 (trixie) upgrade script
#
# 适用环境 / Scope:
#   - 仅限 Debian 12 (bookworm) 用户使用 (含 Android 16 自带终端的默认镜像)。
#   - For Debian 12 (bookworm) only, including the default Android 16 Terminal image.
#   - 如已运行 Debian 13 (例如 Android 17 自带终端), 脚本将直接退出。
#   - If you are already on Debian 13 (e.g. the Android 17 Terminal default), the
#     script will exit immediately as no upgrade is needed.
#
# ⚠️ Android 用户特别警告 / IMPORTANT for Android Linux Terminal users:
#   多名用户报告在 Android 16 终端中执行 bookworm→trixie 大版本升级会导致
#   AVF 虚拟机镜像损坏 (Terminal 报错"VM image damaged, must be wiped")。
#   如条件允许, 推荐 Android 16 用户保持 Debian 12 不变, 等待升级到 Android 17 后
#   通过 "重置 Linux 终端" 获得官方 Debian 13 镜像, 而不是手动 dist-upgrade。
#   Multiple users report the in-place bookworm→trixie upgrade can corrupt the
#   Android 16 Terminal's AVF disk image (the app then refuses to launch and only
#   offers a wipe-and-reinstall). The safer path on Android is to stay on Debian 12
#   until Android 17 ships an official Debian 13 image, then reset the Terminal.
#
# 注意 / Notes:
#   1. 升级前请务必备份重要数据。
#      Back up your data before upgrading.
#   2. 升级过程中可能提示选择配置，通常选择"保留现有配置"和"重启服务"。
#      During the upgrade, choose "keep the current configuration" and "restart services" if prompted.
#   3. 该脚本只处理 OS 本身, 应用层迁移可能需要额外手动步骤。
#      This script only handles the OS; applications may require manual follow-up.
# ====================================================================================

set -u

# 颜色 / Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

err()  { echo -e "${RED}[ERROR]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
info() { echo -e "${GREEN}[INFO]${NC} $*"; }
note() { echo -e "${BLUE}[NOTE]${NC} $*"; }

# --- 检测当前 Debian 版本 / Detect current Debian release ---
if [ ! -r /etc/os-release ]; then
    err "找不到 /etc/os-release。/ Cannot find /etc/os-release."
    exit 1
fi
# shellcheck disable=SC1091
. /etc/os-release

if [ "${ID:-}" != "debian" ]; then
    err "当前系统不是 Debian (ID='${ID:-unknown}')。/ Not running Debian (ID='${ID:-unknown}')."
    exit 1
fi

CODENAME="${VERSION_CODENAME:-}"
case "$CODENAME" in
    trixie)
        info "当前已经运行 Debian 13 (trixie), 无需升级。"
        info "Already running Debian 13 (trixie); nothing to upgrade."
        info "如果您是 Android 17 终端用户, 这是预期行为。 / If you are on the Android 17 Linux Terminal, this is the expected state."
        exit 0
        ;;
    bookworm)
        info "检测到 Debian 12 (bookworm), 准备升级到 Debian 13 (trixie)。"
        info "Detected Debian 12 (bookworm); preparing to upgrade to Debian 13 (trixie)."
        ;;
    *)
        err "不支持的 Debian 版本: '${CODENAME}'。本脚本仅处理 bookworm → trixie 升级。"
        err "Unsupported Debian codename: '${CODENAME}'. This script handles only bookworm → trixie."
        exit 1
        ;;
esac

# --- Android 终端环境警告 / Android Terminal environment warning ---
# 启发式检测 AVF VM (并非严格判断)。/ Heuristic AVF VM detection (not strict).
IN_ANDROID_VM=0
if grep -qiE 'crosvm|google,gunyah|android' /proc/cpuinfo 2>/dev/null \
   || [ -d /sys/firmware/devicetree/base/avf ] \
   || { command -v dmesg >/dev/null && dmesg 2>/dev/null | head -50 | grep -qiE 'crosvm|gunyah'; }
then
    IN_ANDROID_VM=1
fi

if [ "$IN_ANDROID_VM" = "1" ]; then
    echo
    warn "========================================================================="
    warn "  检测到该系统可能运行在 Android Linux Terminal 虚拟机中。"
    warn "  This appears to be running inside an Android Linux Terminal VM."
    warn ""
    warn "  ⚠️ 多个用户报告: 在 Android 16 终端中执行 bookworm→trixie 升级后,"
    warn "     Terminal 应用提示 VM 镜像损坏并要求重置。建议先备份您的数据。"
    warn "  ⚠️ Multiple users report the AVF VM image can be corrupted by the"
    warn "     in-place dist-upgrade. BACK UP YOUR DATA before continuing."
    warn ""
    warn "  推荐方案 / Recommended:"
    warn "    1) 在 Android 17 上等待官方 Debian 13 镜像 (终端→重置)。"
    warn "       Wait for Android 17 to ship the official Debian 13 image (Terminal → Reset)."
    warn "    2) 或在桌面/服务器版 Debian 12 上运行该脚本进行常规升级。"
    warn "       Or run this script on a desktop/server Debian 12 instead."
    warn "========================================================================="
    echo
    read -p "我已了解风险, 仍要继续? / I understand the risk and want to continue? (yes/N): " ack
    if [[ "$ack" != "yes" ]]; then
        info "已取消。/ Cancelled."
        exit 0
    fi
fi

echo "🚀 开始将 Debian 12 (bookworm) 升级到 Debian 13 (trixie)..."
echo "🚀 Starting upgrade from Debian 12 (bookworm) to Debian 13 (trixie)..."

# 步骤 1: 检查磁盘空间 / Step 1: Check disk space
echo "--- 1. 检查可用磁盘空间 / Check available disk space ---"
df -h
echo "建议至少有 5GiB 的可用空间。/ At least 5GiB of free space is recommended."
read -p "按 Enter 键继续 / Press Enter to continue..."

# 步骤 2: 更新当前发行版 / Step 2: Update current release
echo "--- 2. 更新当前发行版 / Update the current release ---"
sudo apt-get update && sudo apt-get full-upgrade -y

# 检查是否需要重启 / Check for required reboot
if [ -f /var/run/reboot-required ]; then
    warn "检测到需要重启 (内核更新), 系统将在 10 秒后重启, 请重启后重新运行本脚本。"
    warn "A reboot is required (kernel updated). Rebooting in 10 seconds; re-run this script after reboot."
    sleep 10
    sudo reboot
    exit 0
fi

# 步骤 3: 修改 /etc/apt/sources.list / Step 3: Switch main repositories
echo "--- 3. 切换主仓库至 trixie / Switch main repositories to trixie ---"
if [ -f /etc/apt/sources.list ]; then
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bookworm.bak
    sudo sed -i 's/\bbookworm\b/trixie/g' /etc/apt/sources.list
    info "sources.list updated (backup at /etc/apt/sources.list.bookworm.bak)"
fi

# 步骤 3.5: 处理 deb822 格式 / Step 3.5: Handle deb822 format (newer installations)
if [ -d /etc/apt/sources.list.d ]; then
    echo "--- 4. 同步第三方仓库 / Update third-party repository files ---"
    find /etc/apt/sources.list.d -type f \( -name '*.list' -o -name '*.sources' \) \
        -exec sudo sed -i.bookworm.bak 's/\bbookworm\b/trixie/g' {} \;
    info "Third-party sources updated (.bookworm.bak files preserved)"
fi

# 步骤 5: 处理 non-free / non-free-firmware
if grep -RhE '^\s*(deb|Components:).*non-free' /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null \
   | grep -vq 'non-free-firmware'; then
    warn "检测到 'non-free' 但未配置 'non-free-firmware'。建议手动添加以保留固件支持。"
    warn "'non-free' present but 'non-free-firmware' is missing - add it manually to keep firmware support."
fi

# 步骤 6: 重新加载仓库列表 / Step 6: Reload repository lists
echo "--- 6. 重新加载仓库列表 / Reload repository lists ---"
sudo apt-get update

# 步骤 7: screen (可选) / Optional screen install for SSH safety
echo "--- 7. screen (可选) / Optional screen install ---"
read -p "是否安装并提示使用 screen 防止 SSH 连接中断? / Install screen for SSH safety? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo apt-get install -y screen
    note "请在 screen 会话中重新运行本脚本: 'screen -S upgrade ./update_debian13.sh'"
    note "Re-run inside screen: 'screen -S upgrade ./update_debian13.sh'"
    exit 0
fi

# 步骤 8: 执行完整发行版升级 / Step 8: Full dist-upgrade
echo "--- 8. 执行完整的发行版升级 / Perform full distribution upgrade ---"
info "在升级提示中, 建议选择 '保留现有配置文件 / keep the current configuration files'."
sudo apt-get full-upgrade -y

# 步骤 9: 清理 / Step 9: Cleanup
echo "--- 9. 清理旧的包 / Clean up old packages ---"
sudo apt-get autoremove -y && sudo apt-get clean

# 步骤 10: 现代化 sources / Step 10: Modernize sources (trixie+ feature)
echo "--- 10. 现代化 sources.list (Debian 13 新特性) / Modernize sources.list (Debian 13 feature) ---"
if sudo apt-get --help 2>&1 | grep -q "modernize-sources"; then
    read -p "是否将 sources.list 转换为 deb822 (.sources) 格式? / Convert to deb822 (.sources) format? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo apt modernize-sources || warn "modernize-sources 失败, 已忽略 / modernize-sources failed, ignored"
    fi
else
    note "'apt modernize-sources' 不可用, 跳过。 / 'apt modernize-sources' unavailable, skipping."
fi

# 步骤 11: 重启 / Step 11: Reboot
echo "--- 11. 升级完成, 10 秒后重启以应用全部更改。 / Upgrade complete; rebooting in 10 seconds. ---"
echo "    (Android Linux Terminal 用户: 重启即关闭 VM, 下次启动 Terminal 自动重启 VM)"
echo "    (Android Linux Terminal users: this stops the VM; relaunch the Terminal app to restart it)"
sleep 10
sudo reboot
