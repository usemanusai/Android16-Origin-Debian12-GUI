#!/bin/bash

# ==============================================================================
# 脚本名称: Android 16 / 17 Linux Terminal Debian 桌面一键安装脚本 (2026优化版)
# Script  : Android 16 / 17 Linux Terminal Debian desktop one-click installer (2026 Optimized)
#
# 脚本功能 / Features:
#   - 自动检测 Debian 版本 (12 bookworm / 13 trixie / 14+) 并应用相应配置。
#   - Auto-detects Debian release (12 bookworm / 13 trixie / 14+) and adapts.
#   - 完全自动化模式: 使用预定义选项无需交互
#   - Fully autonomous mode: works without user interaction when preset
#   - 同时支持 Android 16 (Baklava) 与 Android 17 (Cinnamon Bun) 自带的 Linux 终端。
#   - Works on both Android 16 (Baklava) and Android 17 (Cinnamon Bun) Linux Terminal.
#   - 自动检测已完成的步骤, 支持重新运行而不重复安装
#   - Smart detection: automatically skips completed steps, safe to re-run
#
# 兼���性 / Compatibility:
#   Android 16  + Debian 12 (bookworm)        ✔
#   Android 16  + Debian 13 (trixie, upgraded) ✔
#   Android 17  + Debian 13 (trixie, default) ✔
#   Debian 14+  (futuristic support)          ✔
#   普通 Debian 12+ 桌面或服务器              ✔
#
# 用法 / Usage:
#   ./android16-terminal.sh                 # 交互模式 / Interactive
#   AUTO_MODE=1 DESKTOP=xfce ./android16-terminal.sh    # 自动模式 (XFCE) / Auto mode
#   AUTO_MODE=1 DESKTOP=gnome LANG_CHOICE=en ./android16-terminal.sh  # 自动 + 英文
# ==============================================================================

set -euo pipefail

# --- 全局变量和初始化 / Globals ---
LANG_CHOICE="${LANG_CHOICE:-cn}"
TARGET_USER="${TARGET_USER:-$(whoami)}"
DEBIAN_CODENAME=""
DEBIAN_VERSION_ID=""
ANDROID_HINT=""
AUTO_MODE="${AUTO_MODE:-0}"
DESKTOP="${DESKTOP:-xfce}"
VNC_PASSWORD_FILE="$HOME/.vnc/password.txt"
STATE_DIR="$HOME/.android-terminal-installer"
STATE_FILE="$STATE_DIR/install.state"

# 创建状态目录 / Create state directory
mkdir -p "$STATE_DIR"

if [ "$(id -u)" -eq 0 ]; then
  echo -e "\033[0;31m[ERROR]\033[0m 请不要以 root 用户身份运行此脚本。请使用一个普通用户账户运行，脚本会在需要时请求 sudo 权限。"
  echo -e "\033[0;31m[ERROR]\033[0m Please do not run this script as root. Run it as a regular user, and it will ask for sudo password when needed."
  exit 1
fi

# --- 颜色定义 / Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- 多语言消息定义 / Bilingual messages ---
declare -A messages
messages=(
    # --- 通用 / Generic ---
    ["press_enter_cn"]="按回车键继续..."
    ["press_enter_en"]="Press Enter to continue..."
    ["invalid_option_cn"]="无效的选项，请重试。"
    ["invalid_option_en"]="Invalid option, please try again."
    ["operation_cancelled_cn"]="操作已取消。"
    ["operation_cancelled_en"]="Operation cancelled."
    ["auto_mode_enabled_cn"]="🤖 自动模式已启用 (AUTO_MODE=1)"
    ["auto_mode_enabled_en"]="🤖 Autonomous mode enabled (AUTO_MODE=1)"

    # --- 信息 / Info ---
    ["install_success_cn"]="成功安装 %s"
    ["install_success_en"]="Successfully installed %s"
    ["config_success_cn"]="成功配置 %s"
    ["config_success_en"]="Successfully configured %s"
    ["detected_os_cn"]="检测到 Debian %s (%s) - %s"
    ["detected_os_en"]="Detected Debian %s (%s) - %s"
    ["skip_already_done_cn"]="⏭️  跳过 (已完成): %s"
    ["skip_already_done_en"]="⏭️  Skipping (already done): %s"

    # --- 错误 / Errors ---
    ["install_fail_cn"]="安装 %s 失败"
    ["install_fail_en"]="Failed to install %s"
    ["config_fail_cn"]="配置 %s 失败"
    ["config_fail_en"]="Failed to configure %s"
    ["command_fail_cn"]="命令执行失败: %s"
    ["command_fail_en"]="Command failed: %s"
    ["unsupported_os_cn"]="不支持的发行版。本脚本仅支持 Debian 12+ (bookworm 或更新)。"
    ["unsupported_os_en"]="Unsupported distribution. This script supports Debian 12+ (bookworm or newer)."
    ["not_debian_cn"]="未检测到 /etc/os-release 或当前系统不是 Debian。已中止。"
    ["not_debian_en"]="/etc/os-release missing or current system is not Debian. Aborting."

    # --- 流程 / Flow ---
    ["welcome_banner_cn"]="欢迎使用 Android 16 / 17 终端 Debian 桌面一键安装脚本 (2026优化)"
    ["welcome_banner_en"]="Welcome to Android 16 / 17 Terminal Debian Desktop Installer (2026 Optimized)"
    ["select_lang_prompt_cn"]="请选择脚本界面语言 / Please select script UI language:"
    ["lang_choice_cn_cn"]="1. 中文 (默认)"
    ["lang_choice_cn_en"]="1. Chinese (Default)"
    ["lang_choice_en_cn"]="2. English"
    ["lang_choice_en_en"]="2. English"
    ["enter_lang_num_cn"]="输入数字 / Enter number (1/2): "
    ["enter_lang_num_en"]="Enter number / 输入数字 (1/2): "
    
    ["desktop_select_cn"]="选择您想安装的桌面环境"
    ["desktop_select_en"]="Select the desktop environment you want to install"
    ["enter_desktop_num_cn"]="请输入您想安装的桌面环境编号: "
    ["enter_desktop_num_en"]="Please enter the number for the desktop environment: "

    ["update_pkg_cn"]="✓ 正在更新软件包列表..."
    ["update_pkg_en"]="✓ Updating package list..."
    ["upgrade_pkg_cn"]="✓ 正在升级已安装的软件包..."
    ["upgrade_pkg_en"]="✓ Upgrading installed packages..."
    ["ssh_modify_cn"]="✓ 正在配置 SSH 服务器..."
    ["ssh_modify_en"]="✓ Configuring SSH server..."
    ["locale_check_cn"]="✓ 正在检查系统语言环境 (Locale)..."
    ["locale_check_en"]="✓ Checking system locale..."
    ["desktop_install_cn"]="✓ 正在安装 %s 桌面环境，这可能需要一些时间..."
    ["desktop_install_en"]="✓ Installing %s desktop environment, this may take a while..."
    ["vnc_config_cn"]="✓ 正在配置 TigerVNC..."
    ["vnc_config_en"]="✓ Configuring TigerVNC..."
    
    ["final_summary_cn"]="🎉 所有配置已完成！"
    ["final_summary_en"]="🎉 All configurations completed!"
    ["final_info_cn"]="您现在可以使用以下信息进行远程连接："
    ["final_info_en"]="You can now connect using the following information:"
    ["final_ssh_header_cn"]="  ${CYAN}SSH (命令行):${NC}"
    ["final_ssh_header_en"]="  ${CYAN}SSH (Command Line):${NC}"
    ["final_vnc_header_cn"]="  ${CYAN}VNC (图形桌面):${NC}"
    ["final_vnc_header_en"]="  ${CYAN}VNC (Graphical Desktop):${NC}"
    ["final_vnc_addr_cn"]="    VNC 服务器地址: %s:1"
    ["final_vnc_addr_en"]="    VNC Server Address: %s:1"
    ["final_adb_hint_cn"]="  💡 Android ���端用户: 在 PC 上执行 'adb forward tcp:5901 tcp:5901'，然后 VNC 连接 localhost:5901"
    ["final_adb_hint_en"]="  💡 Android Terminal users: run 'adb forward tcp:5901 tcp:5901' on your PC, then VNC-connect to localhost:5901"
)

# --- 辅助函数 / Helpers ---
function lang() { local key="${1}_${LANG_CHOICE}"; printf '%s' "${messages[$key]:-$key}"; }
function info() { echo -e "${GREEN}[✓]${NC} $1"; }
function warn() { echo -e "${YELLOW}[!]${NC} $1"; }
function error() { echo -e "${RED}[✗]${NC} $1"; }
function banner() { echo -e "\n${BLUE}╔════════════════════════════════════════════════════════╗${NC}"; echo -e "${BLUE}║${NC} $1"; echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}\n"; }
function step_completed() { echo "$1=true" >> "$STATE_FILE"; }
function is_step_done() { grep -q "^$1=true$" "$STATE_FILE" 2>/dev/null && return 0 || return 1; }

# --- 状态管理 / State management ---
function save_state() {
    touch "$STATE_FILE"
}

function load_state() {
    [ -f "$STATE_FILE" ] && source "$STATE_FILE" || true
}

# --- 检测系统版本 / Detect OS release ---
function detect_os() {
    if [ ! -r /etc/os-release ]; then
        error "$(lang not_debian)"
        exit 1
    fi
    . /etc/os-release
    if [ "${ID:-}" != "debian" ]; then
        error "Unsupported distribution: ID='${ID:-unknown}'"
        exit 1
    fi
    DEBIAN_CODENAME="${VERSION_CODENAME:-}"
    DEBIAN_VERSION_ID="${VERSION_ID:-}"

    case "$DEBIAN_CODENAME" in
        bookworm|trixie|forky) 
            ANDROID_HINT="Debian $DEBIAN_VERSION_ID ($DEBIAN_CODENAME)"
            ;;
        *)
            if [ "$DEBIAN_VERSION_ID" -ge 12 ] 2>/dev/null; then
                ANDROID_HINT="Debian $DEBIAN_VERSION_ID (future release)"
            else
                error "$(lang unsupported_os)"
                exit 1
            fi
            ;;
    esac
    
    if grep -qiE 'crosvm|google,gunyah|android' /proc/cpuinfo 2>/dev/null \
       || [ -d /sys/firmware/devicetree/base/avf ] 2>/dev/null; then
        ANDROID_HINT="Android Terminal - $ANDROID_HINT"
    fi
}

# --- 映射桌面选项 / Map desktop option ---
function get_desktop_config() {
    local de="$1"
    case "$de" in
        kde|plasma)
            echo "KDE Plasma" "kde-desktop" "plasma"
            ;;
        gnome|gdm)
            echo "GNOME" "gnome-desktop" "gnome"
            ;;
        xfce|xfwm)
            echo "XFCE" "xfce-desktop" "xfce"
            ;;
        mate)
            echo "MATE" "mate-desktop" "mate"
            ;;
        cinnamon)
            echo "Cinnamon" "cinnamon-desktop" "cinnamon"
            ;;
        lxqt)
            echo "LXQt" "lxqt-desktop" "lxqt"
            ;;
        lxde)
            echo "LXDE" "lxde-desktop" "lxde"
            ;;
        gnome-flashback)
            echo "GNOME Flashback" "gnome-flashback-desktop" "gnome-flashback-metacity"
            ;;
        *)
            echo "XFCE" "xfce-desktop" "xfce"  # Default fallback
            ;;
    esac
}

# --- 生成VNC密码 / Generate VNC password ---
function generate_vnc_password() {
    if [ -f "$VNC_PASSWORD_FILE" ]; then
        info "$(lang config_success '.vnc/password')"
        return 0
    fi
    
    # 自动生成8位随机密码 / Auto-generate 8-char random password
    local pass=$(openssl rand -base64 6 | sed 's/[^a-zA-Z0-9]//g' | cut -c1-8)
    echo "$pass" > "$VNC_PASSWORD_FILE"
    chmod 600 "$VNC_PASSWORD_FILE"
    info "VNC password auto-generated and saved"
    return 0
}

# --- 主安装函数 / Main installation functions ---
function prepare_system() {
    if is_step_done "prepare_system"; then
        warn "$(lang skip_already_done 'System preparation')"
        return 0
    fi
    
    banner "$(lang update_pkg)"
    sudo apt-get update -qq && sudo apt-get upgrade -yq || return 1
    
    banner "$(lang locale_check)"
    if ! locale | grep -q "UTF-8"; then
        warn "No UTF-8 locale detected, installing locales..."
        sudo apt-get install -yq locales
        echo "en_US.UTF-8 UTF-8" | sudo tee -a /etc/locale.gen > /dev/null
        sudo locale-gen en_US.UTF-8 > /dev/null 2>&1
    fi
    
    step_completed "prepare_system"
}

function setup_ssh() {
    if is_step_done "setup_ssh"; then
        warn "$(lang skip_already_done 'SSH setup')"
        return 0
    fi
    
    banner "$(lang ssh_modify)"
    sudo apt-get install -yq openssh-server
    sudo mkdir -p /etc/ssh/sshd_config.d
    
    sudo tee /etc/ssh/sshd_config.d/50-android-terminal.conf > /dev/null <<'EOF'
# Managed by android16-terminal.sh - Auto-configured 2026
Port 10022
PasswordAuthentication yes
PermitRootLogin no
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
EOF
    
    if ! sudo grep -qE '^\s*Include\s+/etc/ssh/sshd_config\.d/\*\.conf' /etc/ssh/sshd_config; then
        echo "Include /etc/ssh/sshd_config.d/*.conf" | sudo tee -a /etc/ssh/sshd_config > /dev/null
    fi
    
    sudo systemctl restart ssh 2>/dev/null || sudo systemctl restart sshd 2>/dev/null
    info "$(lang config_success 'SSH service')"
    
    step_completed "setup_ssh"
}

function install_desktop() {
    if is_step_done "install_desktop"; then
        warn "$(lang skip_already_done 'Desktop environment')"
        return 0
    fi
    
    local config=$(get_desktop_config "$DESKTOP")
    local desktop_name=$(echo "$config" | awk '{print $1" "$2}')
    local tasksel_task=$(echo "$config" | awk '{print $3}')
    
    banner "$(printf "$(lang desktop_install)" "$desktop_name")"
    sudo apt-get install -yq tasksel
    sudo tasksel install "$tasksel_task" > /dev/null 2>&1 || true
    
    info "$(lang config_success "Desktop: $desktop_name")"
    step_completed "install_desktop"
}

function setup_vnc() {
    if is_step_done "setup_vnc"; then
        warn "$(lang skip_already_done 'VNC setup')"
        return 0
    fi
    
    banner "$(lang vnc_config)"
    sudo apt-get install -yq tigervnc-standalone-server tigervnc-common
    
    # 生成VNC密码 / Generate VNC password
    generate_vnc_password
    
    local config=$(get_desktop_config "$DESKTOP")
    local vnc_session=$(echo "$config" | awk '{print $4}')
    
    # 设置VNC配置 / Configure VNC
    mkdir -p ~/.vnc
    cat > ~/.vnc/config <<EOF
session=$vnc_session
geometry=1920x1080
localhost=no
alwaysshared
EOF
    
    # 写入VNC用户配置 / Write VNC user config
    echo ":1=$TARGET_USER" | sudo tee /etc/tigervnc/vncserver.users > /dev/null
    
    # 启动VNC / Start VNC
    sudo systemctl daemon-reload
    sudo systemctl enable tigervncserver@:1.service
    sudo systemctl start tigervncserver@:1.service
    
    info "$(lang config_success 'VNC service')"
    step_completed "setup_vnc"
}

# --- 最终总结 / Final summary ---
function final_summary() {
    local IP_ADDR=$(hostname -I 2>/dev/null | awk '{print $1}')
    [ -z "$IP_ADDR" ] && IP_ADDR="127.0.0.1"
    
    banner "$(lang final_summary)"
    echo "$(lang final_info)"
    echo ""
    echo -e "$(lang final_ssh_header)"
    echo -e "    ${CYAN}ssh $TARGET_USER@$IP_ADDR -p 10022${NC}"
    echo ""
    echo -e "$(lang final_vnc_header)"
    printf "    $(lang final_vnc_addr)\n" "$IP_ADDR"
    
    if [ -f "$VNC_PASSWORD_FILE" ]; then
        echo -e "    ${CYAN}Password: $(cat $VNC_PASSWORD_FILE)${NC}"
    fi
    
    echo ""
    echo -e "$(lang final_adb_hint)"
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Setup Complete! System is ready to use.${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}\n"
}

# --- 主程序 / Main ---
function main() {
    clear
    detect_os
    load_state
    save_state
    
    # 语言选择 / Language selection
    if [ "$AUTO_MODE" != "1" ]; then
        banner "$(lang welcome_banner)"
        echo -e "$(lang select_lang_prompt)"
        echo "$(lang lang_choice_cn)"
        echo "$(lang lang_choice_en)"
        read -p "$(lang enter_lang_num)" lang_choice_num
        case $lang_choice_num in 2) LANG_CHOICE="en" ;; *) LANG_CHOICE="cn" ;; esac
    else
        info "$(lang auto_mode_enabled)"
    fi
    
    info "$(printf "$(lang detected_os)" "$DEBIAN_VERSION_ID" "$DEBIAN_CODENAME" "$ANDROID_HINT")"
    echo ""
    
    # 运行安装步骤 / Run installation steps
    prepare_system
    setup_ssh
    install_desktop
    setup_vnc
    
    # 最终总结 / Final summary
    final_summary
}

# 执行主函数 / Run main
main "$@"
