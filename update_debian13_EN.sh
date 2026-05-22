#!/bin/bash

# ====================================================================================
# Debian 12 (bookworm) → Debian 13 (trixie) upgrade script (English)
#
# Scope:
#   - For Debian 12 (bookworm) only, including the default Android 16 Terminal image.
#   - If you are already on Debian 13 (e.g. the Android 17 Terminal default), the
#     script will exit immediately as no upgrade is needed.
#
# ⚠️ IMPORTANT for Android Linux Terminal users:
#   Multiple users report the in-place bookworm→trixie upgrade can corrupt the
#   Android 16 Terminal's AVF disk image (the app then refuses to launch and only
#   offers a wipe-and-reinstall). The safer path on Android is to stay on Debian 12
#   until Android 17 ships an official Debian 13 image, then reset the Terminal.
#
# Notes:
#   1. Back up your data before upgrading.
#   2. During the upgrade, choose "keep the current configuration" and "restart services".
#   3. This script only handles the OS; applications may require manual follow-up.
# ====================================================================================

set -u

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

err()  { echo -e "${RED}[ERROR]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
info() { echo -e "${GREEN}[INFO]${NC} $*"; }
note() { echo -e "${BLUE}[NOTE]${NC} $*"; }

# --- Detect current Debian release ---
if [ ! -r /etc/os-release ]; then
    err "Cannot find /etc/os-release."
    exit 1
fi
# shellcheck disable=SC1091
. /etc/os-release

if [ "${ID:-}" != "debian" ]; then
    err "Not running Debian (ID='${ID:-unknown}')."
    exit 1
fi

CODENAME="${VERSION_CODENAME:-}"
case "$CODENAME" in
    trixie)
        info "Already running Debian 13 (trixie); nothing to upgrade."
        info "If you are on the Android 17 Linux Terminal, this is the expected state."
        exit 0
        ;;
    bookworm)
        info "Detected Debian 12 (bookworm); preparing to upgrade to Debian 13 (trixie)."
        ;;
    *)
        err "Unsupported Debian codename: '${CODENAME}'. This script handles only bookworm → trixie."
        exit 1
        ;;
esac

# --- Android Terminal heuristic warning ---
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
    warn "  This appears to be running inside an Android Linux Terminal VM."
    warn ""
    warn "  ⚠️ Multiple users report the AVF VM image can be corrupted by the"
    warn "     in-place dist-upgrade. BACK UP YOUR DATA before continuing."
    warn ""
    warn "  Recommended:"
    warn "    1) Wait for Android 17 to ship the official Debian 13 image"
    warn "       (Terminal → Reset)."
    warn "    2) Or run this script on a desktop/server Debian 12 instead."
    warn "========================================================================="
    echo
    read -p "I understand the risk and want to continue (yes/N): " ack
    if [[ "$ack" != "yes" ]]; then
        info "Cancelled."
        exit 0
    fi
fi

echo "🚀 Starting upgrade from Debian 12 (bookworm) to Debian 13 (trixie)..."

# Step 1: Check disk space
echo "--- 1. Check available disk space ---"
df -h
echo "At least 5GiB of free space is recommended. If space is insufficient, run 'sudo apt clean' and 'sudo apt autoremove'."
read -p "Press Enter to continue..."

# Step 2: Update current release
echo "--- 2. Update the current release ---"
sudo apt-get update && sudo apt-get full-upgrade -y

# Check for required reboot
if [ -f /var/run/reboot-required ]; then
    warn "A reboot is required (kernel updated). Rebooting in 10 seconds; re-run this script after reboot."
    sleep 10
    sudo reboot
    exit 0
fi

# Step 3: Modify /etc/apt/sources.list
echo "--- 3. Switch main repositories to trixie ---"
if [ -f /etc/apt/sources.list ]; then
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bookworm.bak
    sudo sed -i 's/\bbookworm\b/trixie/g' /etc/apt/sources.list
    info "sources.list updated (backup at /etc/apt/sources.list.bookworm.bak)"
fi

# Step 4: Update third-party repository files
if [ -d /etc/apt/sources.list.d ]; then
    echo "--- 4. Update third-party repository files ---"
    find /etc/apt/sources.list.d -type f \( -name '*.list' -o -name '*.sources' \) \
        -exec sudo sed -i.bookworm.bak 's/\bbookworm\b/trixie/g' {} \;
    info "Third-party sources updated (.bookworm.bak files preserved)"
fi

# Step 5: non-free / non-free-firmware check
if grep -RhE '^\s*(deb|Components:).*non-free' /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null \
   | grep -vq 'non-free-firmware'; then
    warn "'non-free' present but 'non-free-firmware' is missing - add it manually to keep firmware support."
fi

# Step 6: Reload repository lists
echo "--- 6. Reload repository lists ---"
sudo apt-get update

# Step 7: Optional screen install
echo "--- 7. Optional screen install ---"
read -p "Install screen for SSH safety? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo apt-get install -y screen
    note "Re-run inside screen: 'screen -S upgrade ./update_debian13_EN.sh'"
    exit 0
fi

# Step 8: Full dist-upgrade
echo "--- 8. Perform full distribution upgrade ---"
info "If prompted, choose 'keep the current configuration files'."
sudo apt-get full-upgrade -y

# Step 9: Cleanup
echo "--- 9. Clean up old packages ---"
sudo apt-get autoremove -y && sudo apt-get clean

# Step 10: Modernize sources (trixie+ feature)
echo "--- 10. Modernize sources.list (Debian 13 feature) ---"
if sudo apt-get --help 2>&1 | grep -q "modernize-sources"; then
    read -p "Convert sources.list to deb822 (.sources) format? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo apt modernize-sources || warn "modernize-sources failed, ignored"
    fi
else
    note "'apt modernize-sources' unavailable, skipping."
fi

# Step 11: Reboot
echo "--- 11. Upgrade complete; rebooting in 10 seconds. ---"
echo "    (Android Linux Terminal users: this stops the VM; relaunch the Terminal app to restart it)"
sleep 10
sudo reboot
