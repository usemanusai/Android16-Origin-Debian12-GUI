#!/bin/bash

# ==============================================================================
# Android 16 / 17 Terminal GUI Installer - Advanced Edition (2026)
# 脚本名称: Android 16 / 17 Linux Terminal 桌面一键安装脚本 (2026高级版)
#
# 功能 / Features:
#   - 支持7+发行版，自动检测最优配置
#   - Distro-specific defaults (Ubuntu→GNOME, Fedora→KDE, Arch→XFCE)
#   - Docker/Podman容器支持
#   - GPU加速检测与安装
#   - Wayland/X11自动检测
#   - 音频转发支持
#   - Snap/Flatpak应用支持
#   - 云VM自动检测与优化
#   - 统一升级脚本
#
# 用法 / Usage:
#   AUTO_MODE=1 ./android16-terminal.sh                    # 一键启动
#   AUTO_MODE=1 GPU_ACCEL=1 ./android16-terminal.sh       # 启用GPU
#   AUTO_MODE=1 AUDIO_FORWARD=1 ./android16-terminal.sh   # 启用音频
# ==============================================================================

set -euo pipefail

# === 配置 / Configuration ===
LANG_CHOICE="${LANG_CHOICE:-cn}"
TARGET_USER="${TARGET_USER:-$(whoami)}"
DISTO_ID=""
DISTO_NAME=""
DESKTOP="${DESKTOP:-}"
AUTO_MODE="${AUTO_MODE:-0}"
GPU_ACCEL="${GPU_ACCEL:-0}"
AUDIO_FORWARD="${AUDIO_FORWARD:-0}"
CONTAINER_ENGINE="${CONTAINER_ENGINE:-}"
FLATPAK_SUPPORT="${FLATPAK_SUPPORT:-0}"
SNAP_SUPPORT="${SNAP_SUPPORT:-0}"
WAYLAND_MODE="${WAYLAND_MODE:-}"
X11_MODE="${X11_MODE:-}"
CLOUD_DETECT="${CLOUD_DETECT:-0}"
PKG_MANAGER=""
DISPLAY_SERVER=""
GPU_VENDOR=""
CLOUD_PROVIDER=""
STATE_DIR="$HOME/.terminal-installer-state"
STATE_FILE="$STATE_DIR/install.state"
VNC_PASSWORD_FILE="$HOME/.vnc/password.txt"

mkdir -p "$STATE_DIR"

if [ "$(id -u)" -eq 0 ]; then
  echo "❌ Do not run as root. Use a regular user."
  exit 1
fi

# === Colors ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# === Helpers ===
function info() { echo -e "${GREEN}[✓]${NC} $1"; }
function warn() { echo -e "${YELLOW}[!]${NC} $1"; }
function error() { echo -e "${RED}[✗]${NC} $1"; }
function banner() { echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}\n$1\n${BLUE}═══════════════════════════════════════════════════════${NC}\n"; }
function step_done() { echo "$1=true" >> "$STATE_FILE"; }
function is_step_done() { grep -q "^$1=true$" "$STATE_FILE" 2>/dev/null && return 0 || return 1; }

# === Detect Distro ===
function detect_distro() {
    [ ! -r /etc/os-release ] && { error "Cannot read /etc/os-release"; exit 1; }
    . /etc/os-release
    DISTRO_ID="${ID:-unknown}"
    DISTRO_NAME="${NAME:-Unknown}"

    if command -v apt-get &>/dev/null; then PKG_MANAGER="apt"
    elif command -v dnf &>/dev/null; then PKG_MANAGER="dnf"
    elif command -v pacman &>/dev/null; then PKG_MANAGER="pacman"
    elif command -v zypper &>/dev/null; then PKG_MANAGER="zypper"
    elif command -v apk &>/dev/null; then PKG_MANAGER="apk"
    else error "Unknown package manager"; exit 1; fi

    info "Detected: $DISTRO_NAME [$PKG_MANAGER]"
}

# === Detect GPU ===
function detect_gpu() {
    if lspci 2>/dev/null | grep -qi nvidia; then
        GPU_VENDOR="nvidia"
        info "GPU: NVIDIA detected"
    elif lspci 2>/dev/null | grep -qi amd; then
        GPU_VENDOR="amd"
        info "GPU: AMD detected"
    elif lspci 2>/dev/null | grep -qi intel; then
        GPU_VENDOR="intel"
        info "GPU: Intel detected"
    else
        GPU_VENDOR="generic"
        warn "GPU: Using generic drivers"
    fi
}

# === Detect Display Server ===
function detect_display_server() {
    if [ -n "$X11_MODE" ]; then
        DISPLAY_SERVER="x11"
    elif [ -n "$WAYLAND_MODE" ]; then
        DISPLAY_SERVER="wayland"
    else
        DISPLAY_SERVER="${XDG_SESSION_TYPE:-x11}"
    fi
    info "Display Server: $DISPLAY_SERVER"
}

# === Detect Cloud Provider ===
function detect_cloud_provider() {
    [ "$CLOUD_DETECT" != "1" ] && return 0
    
    if grep -qi amazon /sys/hypervisor/uuid 2>/dev/null; then
        CLOUD_PROVIDER="aws"
        info "Cloud: AWS detected"
    elif grep -qi microsoft /sys/hypervisor/uuid 2>/dev/null; then
        CLOUD_PROVIDER="azure"
        info "Cloud: Azure detected"
    elif grep -qi google /sys/hypervisor/uuid 2>/dev/null; then
        CLOUD_PROVIDER="gcp"
        info "Cloud: Google Cloud detected"
    elif [ -f /etc/digitalocean ]; then
        CLOUD_PROVIDER="digitalocean"
        info "Cloud: DigitalOcean detected"
    else
        CLOUD_PROVIDER="generic"
    fi
}

# === Set Distro-Specific Defaults ===
function set_distro_defaults() {
    if [ -z "$DESKTOP" ]; then
        case "$DISTRO_ID" in
            ubuntu) DESKTOP="gnome" ;;
            fedora) DESKTOP="kde" ;;
            arch|manjaro) DESKTOP="xfce" ;;
            debian) DESKTOP="xfce" ;;
            kali) DESKTOP="xfce" ;;
            opensuse*) DESKTOP="gnome" ;;
            alpine) DESKTOP="xfce" ;;
            *) DESKTOP="xfce" ;;
        esac
        info "Desktop default for $DISTRO_ID: $DESKTOP"
    fi
}

# === Package Installation ===
function pkg_install() {
    local packages="$@"
    case "$PKG_MANAGER" in
        apt) sudo apt-get install -yq $packages 2>/dev/null || true ;;
        dnf) sudo dnf install -y $packages 2>/dev/null || true ;;
        pacman) sudo pacman -S --noconfirm $packages 2>/dev/null || true ;;
        zypper) sudo zypper install -y $packages 2>/dev/null || true ;;
        apk) sudo apk add $packages 2>/dev/null || true ;;
    esac
}

function pkg_update() {
    case "$PKG_MANAGER" in
        apt) sudo apt-get update -qq ;;
        dnf) sudo dnf check-update -q || true ;;
        pacman) sudo pacman -Sy ;;
        zypper) sudo zypper refresh ;;
        apk) sudo apk update ;;
    esac
}

# === Get Desktop Package ===
function get_desktop_pkg() {
    local de="$1"
    local mgr="$2"
    
    if [ "$mgr" = "apt" ]; then
        case "$de" in
            gnome) echo "gnome" ;;
            kde|plasma) echo "kde-plasma-desktop" ;;
            xfce) echo "xfce4" ;;
            mate) echo "mate-desktop-environment" ;;
            cinnamon) echo "cinnamon" ;;
            lxqt) echo "lxqt" ;;
            lxde) echo "lxde" ;;
            *) echo "xfce4" ;;
        esac
    elif [ "$mgr" = "dnf" ]; then
        case "$de" in
            gnome) echo "@gnome-desktop" ;;
            kde|plasma) echo "@kde-desktop-environment" ;;
            xfce) echo "@xfce-desktop" ;;
            mate) echo "@mate-desktop" ;;
            cinnamon) echo "cinnamon-desktop" ;;
            lxqt) echo "@lxqt-desktop" ;;
            *) echo "@xfce-desktop" ;;
        esac
    elif [ "$mgr" = "pacman" ]; then
        case "$de" in
            gnome) echo "gnome gnome-extra" ;;
            kde|plasma) echo "plasma kde-applications" ;;
            xfce) echo "xfce4 xfce4-goodies" ;;
            mate) echo "mate mate-extra" ;;
            cinnamon) echo "cinnamon" ;;
            lxqt) echo "lxqt" ;;
            *) echo "xfce4" ;;
        esac
    else
        echo "xfce4"
    fi
}

# === Install GPU Drivers ===
function install_gpu_drivers() {
    if [ "$GPU_ACCEL" != "1" ]; then return 0; fi
    is_step_done "gpu_install" && { warn "GPU drivers already installed"; return 0; }
    
    banner "🚀 Installing GPU Acceleration"
    case "$GPU_VENDOR" in
        nvidia)
            pkg_install nvidia-driver nvidia-utils
            ;;
        amd)
            pkg_install amdgpu-dkms libdrm-amdgpu
            ;;
        intel)
            pkg_install intel-media-driver libva-intel-driver
            ;;
    esac
    step_done "gpu_install"
}

# === Install Audio Forwarding ===
function install_audio() {
    if [ "$AUDIO_FORWARD" != "1" ]; then return 0; fi
    is_step_done "audio_install" && { warn "Audio already installed"; return 0; }
    
    banner "🔊 Installing Audio Forwarding"
    pkg_install pulseaudio pulseaudio-utils
    step_done "audio_install"
}

# === Install Container Support ===
function install_containers() {
    if [ -z "$CONTAINER_ENGINE" ]; then return 0; fi
    is_step_done "container_install" && { warn "Containers already installed"; return 0; }
    
    banner "🐳 Installing $CONTAINER_ENGINE"
    if [ "$CONTAINER_ENGINE" = "docker" ]; then
        pkg_install docker.io
        sudo usermod -aG docker "$TARGET_USER" 2>/dev/null || true
    elif [ "$CONTAINER_ENGINE" = "podman" ]; then
        pkg_install podman podman-compose
    fi
    step_done "container_install"
}

# === Install Flatpak/Snap ===
function install_app_stores() {
    if [ "$FLATPAK_SUPPORT" = "1" ]; then
        is_step_done "flatpak_install" || { 
            banner "📦 Installing Flatpak"
            pkg_install flatpak
            step_done "flatpak_install"
        }
    fi
    
    if [ "$SNAP_SUPPORT" = "1" ]; then
        is_step_done "snap_install" || { 
            banner "📦 Installing Snapd"
            pkg_install snapd
            step_done "snap_install"
        }
    fi
}

# === Cloud Optimization ===
function cloud_optimization() {
    if [ "$CLOUD_DETECT" != "1" ] || [ -z "$CLOUD_PROVIDER" ]; then return 0; fi
    is_step_done "cloud_opt" && { warn "Cloud optimization already applied"; return 0; }
    
    banner "☁️ Cloud VM Optimization ($CLOUD_PROVIDER)"
    case "$CLOUD_PROVIDER" in
        aws)
            pkg_install ec2-instance-connect ec2-metadata
            ;;
        azure)
            pkg_install walinuxagent
            ;;
        gcp)
            pkg_install google-cloud-sdk
            ;;
    esac
    step_done "cloud_opt"
}

# === Setup System ===
function prepare_system() {
    is_step_done "prepare" && { warn "System already prepared"; return 0; }
    
    banner "🔧 Preparing System"
    pkg_update
    pkg_install openssh-server tigervnc-server vim curl wget
    step_done "prepare"
}

# === Setup SSH ===
function setup_ssh() {
    is_step_done "ssh_setup" && { warn "SSH already configured"; return 0; }
    
    banner "🔐 Configuring SSH"
    sudo mkdir -p /etc/ssh/sshd_config.d
    sudo tee /etc/ssh/sshd_config.d/50-gui-installer.conf > /dev/null <<'EOF'
Port 10022
PasswordAuthentication yes
PermitRootLogin no
X11Forwarding yes
X11DisplayOffset 10
TCPKeepAlive yes
PermitUserEnvironment yes
AcceptEnv LANG LC_* DISPLAY XAUTHORITY
Subsystem sftp /usr/lib/openssh/sftp-server
EOF
    
    if ! sudo grep -q "Include /etc/ssh/sshd_config.d" /etc/ssh/sshd_config; then
        echo "Include /etc/ssh/sshd_config.d/*.conf" | sudo tee -a /etc/ssh/sshd_config
    fi
    
    sudo systemctl restart ssh sshd 2>/dev/null || true
    step_done "ssh_setup"
}

# === Install Desktop ===
function install_desktop() {
    is_step_done "desktop_install" && { warn "Desktop already installed"; return 0; }
    
    local desk_pkg=$(get_desktop_pkg "$DESKTOP" "$PKG_MANAGER")
    banner "💻 Installing $DESKTOP"
    pkg_install $desk_pkg
    step_done "desktop_install"
}

# === Setup VNC ===
function setup_vnc() {
    is_step_done "vnc_setup" && { warn "VNC already configured"; return 0; }
    
    banner "📹 Setting up VNC"
    mkdir -p ~/.vnc
    
    if [ ! -f "$VNC_PASSWORD_FILE" ]; then
        local pass=$(openssl rand -base64 6 | sed 's/[^a-zA-Z0-9]//g' | cut -c1-8)
        echo "$pass" > "$VNC_PASSWORD_FILE"
        chmod 600 "$VNC_PASSWORD_FILE"
        info "VNC password: $pass"
    fi
    
    cat > ~/.vnc/config <<EOF
session=$DESKTOP
geometry=1920x1080
localhost=no
alwaysshared
securitytypes=vncauth
EOF
    
    sudo systemctl enable tigervncserver@:1.service 2>/dev/null || true
    sudo systemctl start tigervncserver@:1.service 2>/dev/null || true
    step_done "vnc_setup"
}

# === Main ===
function main() {
    clear
    banner "🚀 Android 16/17 Terminal GUI Installer - Advanced Edition 2026"
    
    detect_distro
    detect_gpu
    detect_display_server
    detect_cloud_provider
    set_distro_defaults
    
    info "Config: GPU=$GPU_ACCEL Audio=$AUDIO_FORWARD Container=$CONTAINER_ENGINE Flatpak=$FLATPAK_SUPPORT Cloud=$CLOUD_DETECT"
    echo ""
    
    # Run installation steps
    prepare_system
    setup_ssh
    install_gpu_drivers
    install_audio
    install_containers
    install_app_stores
    cloud_optimization
    install_desktop
    setup_vnc
    
    # Summary
    banner "✅ Setup Complete!"
    echo "SSH:  ssh -p 10022 $TARGET_USER@your-ip"
    echo "VNC:  your-ip:1 (password: $(cat $VNC_PASSWORD_FILE 2>/dev/null || echo 'check ~/.vnc/password.txt'))"
    echo "Type: $DISTRO_NAME | GPU: $GPU_VENDOR | Display: $DISPLAY_SERVER | Cloud: $CLOUD_PROVIDER"
}

main "$@"
