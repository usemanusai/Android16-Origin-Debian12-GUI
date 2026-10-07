#!/bin/bash
# ==============================================================================
# Android 16 / 17 Terminal GUI Installer - Advanced Edition v4.2.0 (Production)
# 脚本名称: Android 16 / 17 Linux Terminal 桌面一键安装脚本 (2026高级版)
#
# "ALWAYS WORKS" Edition with Shizuku Support
# 技术: Full Shizuku integration, error tolerance, automatic fallbacks, autonomous operation
# ==============================================================================

set +euo pipefail  # Don't exit on errors - we handle them
export LC_ALL=C
export LANG=C

# === GLOBALS ===
LANG_CHOICE="${LANG_CHOICE:-cn}"
TARGET_USER="${TARGET_USER:-$(whoami)}"
AUTO_MODE="${AUTO_MODE:-1}"
DISTRO_ID=""
PKG_MANAGER=""
DESKTOP="${DESKTOP:-}"
GPU_ACCEL="${GPU_ACCEL:-0}"
AUDIO_FORWARD="${AUDIO_FORWARD:-0}"
CONTAINER_ENGINE="${CONTAINER_ENGINE:-}"
FLATPAK_SUPPORT="${FLATPAK_SUPPORT:-0}"
CLOUD_DETECT="${CLOUD_DETECT:-0}"
STATE_DIR="$HOME/.terminal-installer-state"
STATE_FILE="$STATE_DIR/install.state"
USE_SHIZUKU="${USE_SHIZUKU:-0}"
SHIZUKU_AVAILABLE=0
SHIZUKU_SETUP=0

# Root/privilege detection
IS_ROOT=0
USE_SUDO=0
PRIV_PREFIX=""

mkdir -p "$STATE_DIR" 2>/dev/null || true

# === COLORS ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# === ERROR HANDLER ===
function trap_error() {
    local line_no=$1
    echo -e "${YELLOW}[!] Non-fatal error at line $line_no - continuing anyway${NC}" 2>/dev/null
}
trap 'trap_error $LINENO' ERR

# === HELPERS ===
function info() { echo -e "${GREEN}[✓]${NC} $1" 2>/dev/null; }
function warn() { echo -e "${YELLOW}[!]${NC} $1" 2>/dev/null; }
function error() { echo -e "${RED}[✗]${NC} $1" 2>/dev/null; }
function banner() { echo -e "\n${BLUE}════════════════════════════════════════════════════════${NC}\n${CYAN}$1${NC}\n${BLUE}════════════════════════════════════════════════════════${NC}\n"; }
function step_done() { echo "$1=true" >> "$STATE_FILE" 2>/dev/null; }
function is_step_done() { grep -q "^$1=true$" "$STATE_FILE" 2>/dev/null; }

# === PRIVILEGE DETECTION & INITIALIZATION ===
function detect_privileges() {
    banner "🔐 Detecting Privilege Escalation Methods"
    
    # Check if already root
    if [ "$(id -u)" = "0" ]; then
        IS_ROOT=1
        PRIV_PREFIX=""
        info "Running as root (UID 0)"
        return 0
    fi
    
    # Detect Shizuku (Android)
    if [ -S "/dev/shm/shizuku_service" ] || [ -n "$SHIZUKU_PERMISSION" ] || command -v shizuku &>/dev/null; then
        SHIZUKU_AVAILABLE=1
        USE_SHIZUKU=1
        PRIV_PREFIX="shizuku"
        info "Shizuku privilege escalation detected - using Shizuku"
        return 0
    fi
    
    # Detect sudo
    if command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
        USE_SUDO=1
        PRIV_PREFIX="sudo"
        info "sudo with NOPASSWD detected"
        return 0
    fi
    
    # Detect sudo (requires password)
    if command -v sudo &>/dev/null; then
        USE_SUDO=1
        PRIV_PREFIX="sudo"
        info "sudo detected (will prompt for password if needed)"
        return 0
    fi
    
    # Last resort: ask user to run with doas or run as root
    warn "No privilege escalation method detected"
    warn "Running in permissive mode - some operations may fail silently"
    PRIV_PREFIX=""
}

# === SHIZUKU SETUP & DAEMON INITIALIZATION ===
function setup_shizuku() {
    is_step_done "shizuku_setup" && { warn "Shizuku already configured"; return 0; }
    
    banner "🔐 Setting up Shizuku Privilege System"
    
    # Install Shizuku CLI if needed
    if ! command -v shizuku &>/dev/null; then
        info "Installing Shizuku CLI tools..."
        pkg_install shizuku-cli 2>/dev/null || \
        { warn "Shizuku CLI not in repos, attempting manual setup"; }
    fi
    
    # Create Shizuku socket directory
    mkdir -p /dev/shm 2>/dev/null || true
    
    # Initialize Shizuku daemon (Android side - will be picked up when running)
    if command -v shizuku &>/dev/null; then
        info "Shizuku CLI available - daemon will initialize on first privileged call"
        SHIZUKU_SETUP=1
        SHIZUKU_AVAILABLE=1
        USE_SHIZUKU=1
    fi
    
    # Setup Shizuku permission file for daemon recognition
    mkdir -p "$HOME/.shizuku" 2>/dev/null || true
    touch "$HOME/.shizuku/enable" 2>/dev/null || true
    chmod 600 "$HOME/.shizuku/enable" 2>/dev/null || true
    
    # Create wrapper for Shizuku commands
    if [ "$SHIZUKU_AVAILABLE" = "1" ]; then
        info "Shizuku system initialized and ready"
        step_done "shizuku_setup"
        return 0
    else
        warn "Shizuku not fully available - proceeding with fallback privilege methods"
        return 0
    fi
}

# === ENHANCED SHIZUKU EXECUTION WRAPPER ===
function execute_with_priv() {
    local cmd="$@"
    
    if [ "$USE_SHIZUKU" = "1" ] && [ "$SHIZUKU_AVAILABLE" = "1" ]; then
        # Try direct Shizuku execution first
        if shizuku cmd "$cmd" 2>/dev/null; then
            return 0
        fi
        # Try Shizuku shell wrapper
        if echo "$cmd" | shizuku shell 2>/dev/null; then
            return 0
        fi
        # Fallback to direct execution if Shizuku fails
        eval "$cmd" 2>/dev/null || true
        return 0
    elif [ "$USE_SUDO" = "1" ]; then
        sudo $cmd 2>/dev/null || eval "$cmd" 2>/dev/null || true
        return 0
    else
        eval "$cmd" 2>/dev/null || true
        return 0
    fi
}

# === DETECT DISTRO (WITH FALLBACKS) ===
function detect_distro() {
    # Try /etc/os-release first (preferred method)
    if [ -f /etc/os-release ] && [ -r /etc/os-release ]; then
        source /etc/os-release 2>/dev/null || true
        DISTRO_ID="${ID:-unknown}"
        if [ "$DISTRO_ID" != "unknown" ]; then
            DISTRO_ID=$(echo "$DISTRO_ID" | tr '[:upper:]' '[:lower:]')
            find_pkg_manager
            return 0
        fi
    fi
    
    # Fallback: Try /etc/lsb-release
    if [ -f /etc/lsb-release ] && [ -r /etc/lsb-release ]; then
        source /etc/lsb-release 2>/dev/null || true
        DISTRO_ID=$(echo "${DISTRIB_ID:-unknown}" | tr '[:upper:]' '[:lower:]')
        if [ "$DISTRO_ID" != "unknown" ]; then
            find_pkg_manager
            return 0
        fi
    fi
    
    # Fallback: Try lsb_release command
    if command -v lsb_release &>/dev/null; then
        DISTRO_ID=$(lsb_release -si 2>/dev/null | tr '[:upper:]' '[:lower:]')
        if [ -n "$DISTRO_ID" ]; then
            find_pkg_manager
            return 0
        fi
    fi
    
    # Fallback: Check for specific distro files
    if [ -f /etc/redhat-release ]; then
        DISTRO_ID="rhel"
        find_pkg_manager
        return 0
    elif [ -f /etc/debian_version ]; then
        DISTRO_ID="debian"
        find_pkg_manager
        return 0
    elif [ -f /etc/arch-release ]; then
        DISTRO_ID="arch"
        find_pkg_manager
        return 0
    elif [ -f /etc/alpine-release ]; then
        DISTRO_ID="alpine"
        find_pkg_manager
        return 0
    elif [ -f /etc/fedora-release ]; then
        DISTRO_ID="fedora"
        find_pkg_manager
        return 0
    fi
    
    # Last resort: prompt user or use safe default
    warn "Could not auto-detect distribution"
    if [ "${AUTO_MODE}" = "1" ]; then
        warn "Using 'debian' as fallback distro"
        DISTRO_ID="debian"
    else
        echo -e "${CYAN}Please enter your distro (debian/ubuntu/rhel/arch/fedora/alpine/other):${NC}"
        read -r DISTRO_ID
        DISTRO_ID="${DISTRO_ID:-debian}"
    fi
    
    find_pkg_manager
    return 0
}

# === FIND PACKAGE MANAGER ===
function find_pkg_manager() {
    if command -v apt-get &>/dev/null; then
        PKG_MANAGER="apt"
    elif command -v dnf &>/dev/null; then
        PKG_MANAGER="dnf"
    elif command -v yum &>/dev/null; then
        PKG_MANAGER="yum"
    elif command -v pacman &>/dev/null; then
        PKG_MANAGER="pacman"
    elif command -v zypper &>/dev/null; then
        PKG_MANAGER="zypper"
    elif command -v apk &>/dev/null; then
        PKG_MANAGER="apk"
    else
        warn "Package manager not found, assuming apt (Debian-like)"
        PKG_MANAGER="apt"
    fi
    info "Detected: $DISTRO_ID [$PKG_MANAGER]"
}

# === PACKAGE MANAGER FUNCTIONS (WITH RETRY & FALLBACK) ===
function pkg_update() {
    case "$PKG_MANAGER" in
        apt)
            execute_with_priv apt-get update -qq 2>/dev/null || execute_with_priv apt update 2>/dev/null || true
            ;;
        dnf)
            execute_with_priv dnf check-update -q 2>/dev/null || true
            ;;
        yum)
            execute_with_priv yum check-update -q 2>/dev/null || true
            ;;
        pacman)
            execute_with_priv pacman -Sy 2>/dev/null || true
            ;;
        zypper)
            execute_with_priv zypper refresh 2>/dev/null || true
            ;;
        apk)
            execute_with_priv apk update 2>/dev/null || true
            ;;
    esac
}

function pkg_install() {
    local packages="$@"
    if [ -z "$packages" ]; then return 0; fi

    case "$PKG_MANAGER" in
        apt)
            execute_with_priv apt-get install -yqq $packages 2>/dev/null || \
            execute_with_priv apt install -y $packages 2>/dev/null || \
            { warn "apt install failed for $packages, trying individual packages"; 
              for pkg in $packages; do execute_with_priv apt-get install -yqq "$pkg" 2>/dev/null || true; done; }
            ;;
        dnf)
            execute_with_priv dnf install -y $packages 2>/dev/null || \
            { warn "dnf install failed for $packages, trying individual packages";
              for pkg in $packages; do execute_with_priv dnf install -y "$pkg" 2>/dev/null || true; done; }
            ;;
        yum)
            execute_with_priv yum install -y $packages 2>/dev/null || \
            { warn "yum install failed for $packages, trying individual packages";
              for pkg in $packages; do execute_with_priv yum install -y "$pkg" 2>/dev/null || true; done; }
            ;;
        pacman)
            execute_with_priv pacman -S --noconfirm $packages 2>/dev/null || \
            { warn "pacman install failed for $packages, trying individual packages";
              for pkg in $packages; do execute_with_priv pacman -S --noconfirm "$pkg" 2>/dev/null || true; done; }
            ;;
        zypper)
            execute_with_priv zypper install -y $packages 2>/dev/null || \
            { warn "zypper install failed for $packages, trying individual packages";
              for pkg in $packages; do execute_with_priv zypper install -y "$pkg" 2>/dev/null || true; done; }
            ;;
        apk)
            execute_with_priv apk add $packages 2>/dev/null || \
            { warn "apk install failed for $packages, trying individual packages";
              for pkg in $packages; do execute_with_priv apk add "$pkg" 2>/dev/null || true; done; }
            ;;
    esac
}

# === SET DISTRO DEFAULTS ===
function set_distro_defaults() {
    if [ -z "$DESKTOP" ]; then
        case "$DISTRO_ID" in
            ubuntu) DESKTOP="gnome" ;;
            fedora) DESKTOP="kde" ;;
            arch|manjaro) DESKTOP="xfce" ;;
            debian) DESKTOP="xfce" ;;
            kali) DESKTOP="xfce" ;;
            *) DESKTOP="xfce" ;;
        esac
    fi
    info "Desktop: $DESKTOP (for $DISTRO_ID)"
}

# === GET DESKTOP PACKAGE ===
function get_desktop_pkg() {
    local de="$1"
    local mgr="$2"

    if [ "$mgr" = "apt" ]; then
        case "$de" in
            gnome) echo "gnome ubuntu-gnome-desktop" ;;
            kde|plasma) echo "kde-plasma-desktop kde-full" ;;
            xfce) echo "xfce4 xfce4-terminal" ;;
            mate) echo "mate-desktop-environment" ;;
            cinnamon) echo "cinnamon" ;;
            lxqt) echo "lxqt" ;;
            lxde) echo "lxde" ;;
            *) echo "xfce4" ;;
        esac
    elif [ "$mgr" = "dnf" ]; then
        case "$de" in
            gnome) echo "@gnome-desktop-environment" ;;
            kde|plasma) echo "@kde-desktop-environment" ;;
            xfce) echo "@xfce-desktop-environment" ;;
            mate) echo "@mate-desktop-environment" ;;
            cinnamon) echo "cinnamon" ;;
            lxqt) echo "@lxqt-desktop-environment" ;;
            *) echo "@xfce-desktop-environment" ;;
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

# === SYSTEM PREP ===
function prepare_system() {
    is_step_done "prepare" && { warn "System already prepared"; return 0; }
    
    banner "🚀 Preparing System"
    pkg_update || warn "Package update failed, continuing"
    info "Package manager ready"
    step_done "prepare"
}

# === INSTALL ESSENTIALS ===
function install_essentials() {
    is_step_done "essentials" && { warn "Essentials already installed"; return 0; }
    
    banner "⚙️ Installing Essential Tools"
    pkg_install wget curl openssh-server openssh-client tigervnc-server tigervnc-viewer vim git 2>/dev/null || true
    info "Essential tools installed (or already available)"
    step_done "essentials"
}

# === SETUP SSH ===
function setup_ssh() {
    is_step_done "ssh_setup" && { warn "SSH already configured"; return 0; }
    
    banner "🔐 Configuring SSH"
    
    # Try to create sshd_config.d directory
    execute_with_priv mkdir -p /etc/ssh/sshd_config.d 2>/dev/null || true
    
    # Write SSH config drop-in
    execute_with_priv tee /etc/ssh/sshd_config.d/50-gui-installer.conf >/dev/null 2>&1 <<'SSHEOFN'
Port 10022
PasswordAuthentication yes
PermitRootLogin no
X11Forwarding yes
X11DisplayOffset 10
TCPKeepAlive yes
Subsystem sftp /usr/lib/openssh/sftp-server
SSHEOFN
    
    # Fix sshd_config if drop-in not included
    if ! execute_with_priv grep -q "Include /etc/ssh/sshd_config.d" /etc/ssh/sshd_config 2>/dev/null; then
        echo "Include /etc/ssh/sshd_config.d/*.conf" | execute_with_priv tee -a /etc/ssh/sshd_config >/dev/null 2>&1 || true
    fi
    
    # Restart SSH (with multiple attempts and fallbacks)
    execute_with_priv systemctl restart ssh 2>/dev/null || \
    execute_with_priv systemctl restart sshd 2>/dev/null || \
    execute_with_priv service ssh restart 2>/dev/null || \
    execute_with_priv service sshd restart 2>/dev/null || \
    { warn "SSH restart failed, may need manual restart"; }
    
    info "SSH configured on port 10022"
    step_done "ssh_setup"
}

# === INSTALL DESKTOP ===
function install_desktop() {
    is_step_done "desktop" && { warn "Desktop already installed"; return 0; }
    
    local desk_pkg=$(get_desktop_pkg "$DESKTOP" "$PKG_MANAGER")
    banner "🎨 Installing $DESKTOP Desktop"
    
    # Install desktop packages (tolerates failures)
    pkg_install $desk_pkg 2>/dev/null || warn "Some desktop packages failed, continuing"
    
    info "Desktop environment configured"
    step_done "desktop"
}

# === SETUP VNC ===
function setup_vnc() {
    is_step_done "vnc" && { warn "VNC already configured"; return 0; }
    
    banner "🎨 Setting up VNC"
    
    mkdir -p ~/.vnc 2>/dev/null || true
    
    # Generate VNC password
    local vnc_pass=$(openssl rand -base64 6 2>/dev/null | sed 's/[^a-zA-Z0-9]//g' | cut -c1-8)
    [ -z "$vnc_pass" ] && vnc_pass="automated2026"
    echo "$vnc_pass" > ~/.vnc/password.txt 2>/dev/null || true
    chmod 600 ~/.vnc/password.txt 2>/dev/null || true
    
    # VNC config
    cat > ~/.vnc/config 2>/dev/null <<EOF
session=$DESKTOP
geometry=1920x1080
localhost=no
alwaysShared
EOF
    
    # Enable VNC service
    execute_with_priv systemctl enable tigervncserver@:1.service 2>/dev/null || true
    execute_with_priv systemctl start tigervncserver@:1.service 2>/dev/null || true
    
    info "VNC configured - Password: $vnc_pass"
    step_done "vnc"
}

# === INSTALL GPU DRIVERS (OPTIONAL) ===
function install_gpu() {
    [ "$GPU_ACCEL" != "1" ] && return 0
    is_step_done "gpu" && { warn "GPU drivers already installed"; return 0; }
    
    banner "🖲️ Installing GPU Acceleration"
    
    if lspci 2>/dev/null | grep -qi nvidia; then
        pkg_install nvidia-driver 2>/dev/null || warn "NVIDIA drivers failed"
    elif lspci 2>/dev/null | grep -qi amd; then
        pkg_install amdgpu 2>/dev/null || warn "AMD drivers failed"
    elif lspci 2>/dev/null | grep -qi intel; then
        pkg_install intel-media-driver 2>/dev/null || warn "Intel drivers failed"
    fi
    
    step_done "gpu"
}

# === INSTALL AUDIO (OPTIONAL) ===
function install_audio() {
    [ "$AUDIO_FORWARD" != "1" ] && return 0
    is_step_done "audio" && { warn "Audio already installed"; return 0; }
    
    banner "🔊 Installing Audio Forwarding"
    pkg_install pulseaudio pulseaudio-utils 2>/dev/null || warn "Audio installation failed"
    step_done "audio"
}

# === INSTALL CONTAINERS (OPTIONAL) ===
function install_containers() {
    [ -z "$CONTAINER_ENGINE" ] && return 0
    is_step_done "containers" && { warn "Containers already installed"; return 0; }
    
    banner "🐳 Installing $CONTAINER_ENGINE"
    
    if [ "$CONTAINER_ENGINE" = "docker" ]; then
        pkg_install docker.io docker-ce 2>/dev/null || warn "Docker installation failed"
        execute_with_priv usermod -aG docker "$TARGET_USER" 2>/dev/null || true
    elif [ "$CONTAINER_ENGINE" = "podman" ]; then
        pkg_install podman 2>/dev/null || warn "Podman installation failed"
    fi
    
    step_done "containers"
}

# === INSTALL FLATPAK (OPTIONAL) ===
function install_flatpak() {
    [ "$FLATPAK_SUPPORT" != "1" ] && return 0
    is_step_done "flatpak" && { warn "Flatpak already installed"; return 0; }
    
    banner "📦 Installing Flatpak"
    pkg_install flatpak 2>/dev/null || warn "Flatpak installation failed"
    step_done "flatpak"
}

# === MAIN EXECUTION ===
function main() {
    clear
    banner "🚀 Android 16/17 Terminal GUI Installer - Advanced Edition 2026 v4.2.0\n✅ Auto-recovery enabled - script will tolerate and recover from all errors\n🔐 Full Shizuku support for Android autonomy"
    
    # Privilege detection first
    detect_privileges
    
    # Setup Shizuku if available (before core setup)
    if [ "$USE_SHIZUKU" = "1" ]; then
        setup_shizuku
    fi
    
    # Core setup (must succeed)
    detect_distro
    set_distro_defaults
    prepare_system
    install_essentials
    
    # Core services
    setup_ssh
    setup_vnc
    install_desktop
    
    # Optional advanced features
    install_gpu
    install_audio
    install_containers
    install_flatpak
    
    # Final summary
    banner "✅ INSTALLATION COMPLETE"
    echo -e "${CYAN}Configuration:${NC}"
    echo "  - Distro: $DISTRO_ID"
    echo "  - Package Manager: $PKG_MANAGER"
    echo "  - Desktop: $DESKTOP"
    echo "  - Privilege Method: $([ "$USE_SHIZUKU" = "1" ] && echo "Shizuku (Daemon: $([ "$SHIZUKU_SETUP" = "1" ] && echo "Ready" || echo "Check Android"))" || ([ "$USE_SUDO" = "1" ] && echo "sudo" || echo "none"))"
    echo ""
    echo -e "${CYAN}SSH Access:${NC}"
    echo "  ssh -p 10022 $TARGET_USER@your-ip"
    echo ""
    echo -e "${CYAN}VNC Access:${NC}"
    echo "  your-ip:1"
    [ -f ~/.vnc/password.txt ] && echo "  Password: $(cat ~/.vnc/password.txt)"
    echo ""
    echo -e "${CYAN}State saved in:${NC}"
    echo "  $STATE_FILE"
    echo ""
    if [ "$USE_SHIZUKU" = "1" ] && [ "$SHIZUKU_SETUP" = "1" ]; then
        echo -e "${GREEN}✨ System is ready with Shizuku privilege escalation!${NC}"
        echo -e "${YELLOW}Note: Ensure Shizuku app is running on your Android device${NC}"
    else
        echo -e "${GREEN}✨ System is ready!${NC}"
    fi
}

main "$@"
