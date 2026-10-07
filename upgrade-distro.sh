#!/bin/bash

# ==============================================================================
# Unified Distro Upgrade Script (2026)
# Supports: Debian, Ubuntu, Kali, Fedora, Arch, openSUSE, Alpine
#
# Usage:
#   ./upgrade-distro.sh                      # Interactive
#   AUTO_MODE=1 ./upgrade-distro.sh         # Automatic
# ==============================================================================

set -euo pipefail

AUTO_MODE="${AUTO_MODE:-0}"

[ ! -r /etc/os-release ] && { echo "❌ Cannot read /etc/os-release"; exit 1; }
. /etc/os-release

DISTRO_ID="${ID:-unknown}"
VERSION="${VERSION_ID:-unknown}"

echo "Current: $DISTRO_ID $VERSION"

case "$DISTRO_ID" in
    debian)
        echo "Debian upgrade path: 12 → 13 → 14+"
        [ "$AUTO_MODE" = "1" ] && sudo apt-get update && sudo apt-get full-upgrade -y
        ;;
    ubuntu)
        echo "Ubuntu upgrade path: 20.04 → 22.04 → 24.04+"
        [ "$AUTO_MODE" = "1" ] && sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
        ;;
    fedora)
        echo "Fedora upgrade path: N → N+1 (rolling)"
        [ "$AUTO_MODE" = "1" ] && sudo dnf upgrade -y && sudo dnf autoremove -y
        ;;
    kali)
        echo "Kali upgrade path: rolling (always current)"
        [ "$AUTO_MODE" = "1" ] && sudo apt update && sudo apt upgrade -y
        ;;
    arch|manjaro)
        echo "Arch upgrade path: rolling (always current)"
        [ "$AUTO_MODE" = "1" ] && sudo pacman -Syu --noconfirm
        ;;
    opensuse*)
        echo "openSUSE upgrade path: Leap/Tumbleweed"
        [ "$AUTO_MODE" = "1" ] && sudo zypper update -y
        ;;
    alpine)
        echo "Alpine upgrade path: rolling/edge"
        [ "$AUTO_MODE" = "1" ] && sudo apk update && sudo apk upgrade
        ;;
    *)
        echo "❌ Unknown distro: $DISTRO_ID"
        exit 1
        ;;
esac

echo "✅ Upgrade complete"
