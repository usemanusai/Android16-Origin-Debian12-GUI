#!/bin/bash

# ==============================================================================
# 脚本名称: Android 16 / 17 Linux Terminal Debian 桌面一键安装脚本
# Script  : Android 16 / 17 Linux Terminal Debian desktop one-click installer
#
# 脚本功能 / Features:
#   - 自动检测 Debian 版本 (12 bookworm / 13 trixie) 并应用相应配置。
#   - Auto-detects Debian release (12 bookworm / 13 trixie) and adapts.
#   - 同时支持 Android 16 (Baklava) 与 Android 17 (Cinnamon Bun) 自带的 Linux 终端。
#   - Works on both Android 16 (Baklava) and Android 17 (Cinnamon Bun) Linux
#     Terminal images, as well as any standard Debian 12/13 system.
#   - 修复了脚本交互 UI 部分中英文显示不一致的问题, 全面支持中英文双语界面切换。
#   - Unified bilingual UI (CN/EN) across every prompt.
#
# 兼容性 / Compatibility:
#   Android 16  + Debian 12 (bookworm)        ✔
#   Android 16  + Debian 13 (trixie, upgraded) ✔  (use update_debian13.sh first)
#   Android 17  + Debian 13 (trixie, default) ✔
#   普通 Debian 12 / 13 桌面或服务器          ✔
# ==============================================================================

# --- 全局变量和初始化 / Globals ---
LANG_CHOICE="cn"
TARGET_USER=$(whoami)
DEBIAN_CODENAME=""   # bookworm | trixie
DEBIAN_VERSION_ID="" # 12 | 13
ANDROID_HINT=""      # human-readable: "Android 16", "Android 17", "Debian"

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
NC='\033[0m' # No Color

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

    # --- 信息 / Info ---
    ["install_success_cn"]="成功安装 %s"
    ["install_success_en"]="Successfully installed %s"
    ["config_success_cn"]="成功配置 %s"
    ["config_success_en"]="Successfully configured %s"
    ["detected_os_cn"]="检测到 Debian %s (%s) - %s"
    ["detected_os_en"]="Detected Debian %s (%s) - %s"

    # --- 错误 / Errors ---
    ["install_fail_cn"]="安装 %s 失败"
    ["install_fail_en"]="Failed to install %s"
    ["config_fail_cn"]="配置 %s 失败"
    ["config_fail_en"]="Failed to configure %s"
    ["command_fail_cn"]="命令执行失败: %s"
    ["command_fail_en"]="Command failed: %s"
    ["unsupported_os_cn"]="不支持的发行版。本脚本仅支持 Debian 12 (bookworm) 或 Debian 13 (trixie)。"
    ["unsupported_os_en"]="Unsupported distribution. This script supports only Debian 12 (bookworm) or Debian 13 (trixie)."
    ["not_debian_cn"]="未检测到 /etc/os-release 或当前系统不是 Debian。已中止。"
    ["not_debian_en"]="/etc/os-release missing or current system is not Debian. Aborting."

    # --- 流程 / Flow ---
    ["welcome_banner_cn"]="欢迎使用 Android 16 / 17 终端 Debian 桌面一键安装脚本"
    ["welcome_banner_en"]="Welcome to the Android 16 / 17 Terminal Debian Desktop One-Click Installer"
    ["select_lang_prompt_cn"]="请选择脚本界面语言 / Please select script UI language:"
    ["select_lang_prompt_en"]="Please select script UI language / 请选择脚本界面语言:"
    ["lang_choice_cn_cn"]="1. 中文 (默认)"
    ["lang_choice_cn_en"]="1. Chinese (Default)"
    ["lang_choice_en_cn"]="2. English"
    ["lang_choice_en_en"]="2. English"
    ["enter_lang_num_cn"]="输入数字 / Enter number (1/2): "
    ["enter_lang_num_en"]="Enter number / 输入数字 (1/2): "
    ["set_password_prompt_cn"]="是否为用户 '$TARGET_USER' 设置或更改登录密码？(y/n): "
    ["set_password_prompt_en"]="Set or change the login password for user '$TARGET_USER'? (y/n): "
    ["desktop_select_cn"]="选择您想安装的桌面环境"
    ["desktop_select_en"]="Select the desktop environment you want to install"
    ["enter_desktop_num_cn"]="请输入您想安装的桌面环境编号: "
    ["enter_desktop_num_en"]="Please enter the number for the desktop environment: "
    ["confirm_banner_cn"]="安装确认"
    ["confirm_banner_en"]="Installation Confirmation"
    ["confirm_intro_cn"]="将在系统上执行以下操作:"
    ["confirm_intro_en"]="The following actions will be performed on your system:"
    ["confirm_user_cn"]="  - 用户: '$TARGET_USER'"
    ["confirm_user_en"]="  - User: '$TARGET_USER'"
    ["confirm_platform_cn"]="  - 平台: "
    ["confirm_platform_en"]="  - Platform: "
    ["confirm_desktop_cn"]="  - 安装桌面: "
    ["confirm_desktop_en"]="  - Install Desktop: "
    ["confirm_ssh_cn"]="  - 配置 SSH 服务 (端口 10022)"
    ["confirm_ssh_en"]="  - Configure SSH Service (Port 10022)"
    ["confirm_vnc_cn"]="  - 配置 VNC 服务 (端口 5901)"
    ["confirm_vnc_en"]="  - Configure VNC Service (Port 5901)"
    ["confirm_proceed_cn"]="是否继续? (y/n): "
    ["confirm_proceed_en"]="Do you want to continue? (y/n): "

    ["update_pkg_cn"]="正在更新软件包列表..."
    ["update_pkg_en"]="Updating package list..."
    ["upgrade_pkg_cn"]="正在升级已安装的软件包..."
    ["upgrade_pkg_en"]="Upgrading installed packages..."
    ["ssh_modify_cn"]="正在配置 SSH 服务器 (使用 sshd_config.d 写入独立配置)..."
    ["ssh_modify_en"]="Configuring SSH server (writing a drop-in under sshd_config.d)..."
    ["ssh_port_prompt_cn"]="SSH 端口已配置为 10022。如果需要，请在防火墙或云服务商安全组中放行此端口。"
    ["ssh_port_prompt_en"]="SSH port is configured to 10022. Please allow it in your firewall or cloud provider's security group if needed."
    ["vnc_port_prompt_cn"]="VNC 服务已配置在 5901 端口。如果需要，请在防火墙或云服务商安全组中放行此端口。"
    ["vnc_port_prompt_en"]="VNC service is configured on port 5901. Please allow it in your firewall or cloud provider's security group if needed."
    ["locale_check_cn"]="正在检查系统语言环境 (Locale)..."
    ["locale_check_en"]="Checking system locale..."
    ["locale_utf8_ok_cn"]="检测到有效的 UTF-8 语言环境，跳过设置。"
    ["locale_utf8_ok_en"]="Valid UTF-8 locale detected, skipping setup."
    ["locale_utf8_fail_cn"]="未检测到 UTF-8 语言环境。即将进入交互式配置界面。"
    ["locale_utf8_fail_en"]="No UTF-8 locale detected. Entering interactive setup."
    ["locale_prompt_cn"]="请在接下来的界面中选择并生成您需要的语言环境 (推荐选择一个 UTF-8 选项, 例如 en_US.UTF-8 或 zh_CN.UTF-8)。"
    ["locale_prompt_en"]="In the following screens, please select and generate the locale you need (a UTF-8 option like en_US.UTF-8 or zh_CN.UTF-8 is recommended)."
    ["desktop_install_cn"]="正在安装 %s 桌面环境，这可能需要一些时间..."
    ["desktop_install_en"]="Installing %s desktop environment, this may take a while..."
    ["vnc_passwd_prompt_cn"]="接下来，请为您 VNC 会话设置一个密码 (至少6位)。"
    ["vnc_passwd_prompt_en"]="Next, please set a password for your VNC session (at least 6 characters)."
    ["vnc_config_cn"]="正在配置 TigerVNC..."
    ["vnc_config_en"]="Configuring TigerVNC..."
    ["input_method_prompt_cn"]="是否安装中文拼音输入法 (IBus Pinyin)? (y/n): "
    ["input_method_prompt_en"]="Install Chinese Pinyin input method (IBus Pinyin)? (y/n): "
    ["ime_install_banner_cn"]="正在安装中文输入法..."
    ["ime_install_banner_en"]="Installing Chinese Input Method..."
    ["ime_config_done_cn"]="输入法配置完成，您可能需要在桌面环境中手动启用它。"
    ["ime_config_done_en"]="Input method configured. You may need to enable it manually in the desktop environment."

    ["display_btn_note_cn"]="提示：在 Android 16 QPR2 / Android 17 终端中，您也可以直接点击终端右上角的「显示器」按钮，在 Android 上原生显示 GUI (基于 Wayland + virglrenderer)，无需 VNC。需在 Linux 文件夹下创建空文件 'virglrenderer' 以启用 GPU 加速。"
    ["display_btn_note_en"]="Tip: On Android 16 QPR2 / Android 17, you can also tap the 'Display' button in the top-right of the Terminal app to render the GUI natively on Android (Wayland + virglrenderer) without VNC. Create an empty file named 'virglrenderer' in the Linux folder to enable GPU acceleration."

    ["final_summary_cn"]="🎉 所有配置已完成！"
    ["final_summary_en"]="🎉 All configurations completed!"
    ["final_info_cn"]="您现在可以使用以下信息进行远程连接："
    ["final_info_en"]="You can now connect using the following information:"
    ["final_ssh_header_cn"]="  ${YELLOW}SSH (命令行):${NC}"
    ["final_ssh_header_en"]="  ${YELLOW}SSH (Command Line):${NC}"
    ["final_vnc_header_cn"]="  ${YELLOW}VNC (图形桌面):${NC}"
    ["final_vnc_header_en"]="  ${YELLOW}VNC (Graphical Desktop):${NC}"
    ["final_vnc_addr_cn"]="    VNC 服务器地址: %s:1"
    ["final_vnc_addr_en"]="    VNC Server Address: %s:1"
    ["final_vnc_alt_cn"]="    (或者在客户端中输入 %s 和端口 5901)"
    ["final_vnc_alt_en"]="    (Or enter %s and port 5901 in your client)"
    ["final_adb_hint_cn"]="  Android 终端用户提示: 在 PC 上执行 'adb forward tcp:5901 tcp:5901'，然后 VNC 连接 localhost:5901。"
    ["final_adb_hint_en"]="  Android Terminal users: run 'adb forward tcp:5901 tcp:5901' on your PC, then VNC-connect to localhost:5901."
)

# --- 辅助函数 / Helpers ---
function lang() { local key="${1}_${LANG_CHOICE}"; printf '%s' "${messages[$key]}"; }
function info() { echo -e "${GREEN}[INFO]${NC} $1"; }
function warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
function error() { echo -e "${RED}[ERROR]${NC} $1"; }
function banner() { echo -e "${BLUE}============================================================${NC}\n${BLUE}$1${NC}\n${BLUE}============================================================${NC}"; }
function prompt_continue() { echo ""; read -r -p "$(lang press_enter)"; }
function run_cmd() { if ! "$@"; then error "$(printf "$(lang command_fail)" "$*")"; exit 1; fi; }
function install_package() { local pkg_name=$1; if ! sudo apt install -y "$pkg_name"; then error "$(printf "$(lang install_fail)" "$pkg_name")"; exit 1; fi; info "$(printf "$(lang install_success)" "$pkg_name")"; }

# 检测系统版本 / Detect OS release
function detect_os() {
    if [ ! -r /etc/os-release ]; then
        error "/etc/os-release missing or current system is not Debian. Aborting."
        exit 1
    fi
    # shellcheck disable=SC1091
    . /etc/os-release
    if [ "${ID:-}" != "debian" ]; then
        error "Unsupported distribution: ID='${ID:-unknown}'. This script supports only Debian 12/13."
        exit 1
    fi
    DEBIAN_CODENAME="${VERSION_CODENAME:-}"
    DEBIAN_VERSION_ID="${VERSION_ID:-}"
    case "$DEBIAN_CODENAME" in
        bookworm) ANDROID_HINT="Android 16 Linux Terminal / Debian 12" ;;
        trixie)   ANDROID_HINT="Android 17 Linux Terminal / Debian 13" ;;
        *)
            error "Unsupported Debian codename: '${DEBIAN_CODENAME}'. This script supports only bookworm (12) or trixie (13)."
            exit 1
            ;;
    esac
}

# --- 主要功能函数 / Main steps ---

# 步骤1: 用户交互和选择 / User selections
function user_selections() {
    clear
    banner "$(lang welcome_banner)"

    echo -e "$(lang select_lang_prompt)"
    echo "$(lang lang_choice_cn)"
    echo "$(lang lang_choice_en)"
    read -p "$(lang enter_lang_num)" lang_choice_num
    case $lang_choice_num in 2) LANG_CHOICE="en" ;; *) LANG_CHOICE="cn" ;; esac

    info "$(printf "$(lang detected_os)" "$DEBIAN_VERSION_ID" "$DEBIAN_CODENAME" "$ANDROID_HINT")"

    read -p "$(lang set_password_prompt)" set_pwd
    if [[ "$set_pwd" =~ ^[Yy]$ ]]; then sudo passwd "$TARGET_USER"; fi

    banner "$(lang desktop_select)"
    echo "1. KDE Plasma"; echo "2. GNOME"; echo "3. XFCE"; echo "4. MATE"; echo "5. Cinnamon"; echo "6. LXQt"; echo "7. LXDE"; echo "8. GNOME Flashback (经典模式 / classic mode)"

    while true; do
        read -p "$(lang enter_desktop_num)" desktop_choice
        case $desktop_choice in
            1) DESKTOP_NAME="KDE Plasma"; TASKSEL_TASK="kde-desktop"; VNC_SESSION="plasma"; break ;;
            2) DESKTOP_NAME="GNOME"; TASKSEL_TASK="gnome-desktop"; VNC_SESSION="gnome"; break ;;
            3) DESKTOP_NAME="XFCE"; TASKSEL_TASK="xfce-desktop"; VNC_SESSION="xfce"; break ;;
            4) DESKTOP_NAME="MATE"; TASKSEL_TASK="mate-desktop"; VNC_SESSION="mate"; break ;;
            5) DESKTOP_NAME="Cinnamon"; TASKSEL_TASK="cinnamon-desktop"; VNC_SESSION="cinnamon"; break ;;
            6) DESKTOP_NAME="LXQt"; TASKSEL_TASK="lxqt-desktop"; VNC_SESSION="lxqt"; break ;;
            7) DESKTOP_NAME="LXDE"; TASKSEL_TASK="lxde-desktop"; VNC_SESSION="lxde"; break ;;
            8) DESKTOP_NAME="GNOME Flashback"; TASKSEL_TASK="gnome-flashback-desktop"; VNC_SESSION="gnome-flashback-metacity"; break ;;
            *) error "$(lang invalid_option)" ;;
        esac
    done

    clear
    banner "$(lang confirm_banner)"
    echo "$(lang confirm_intro)"
    printf "$(lang confirm_user)\n"
    printf "$(lang confirm_platform)%s\n" "$ANDROID_HINT"
    printf "$(lang confirm_desktop) '$DESKTOP_NAME'\n"
    echo "$(lang confirm_ssh)"
    echo "$(lang confirm_vnc)"
    read -p "$(lang confirm_proceed)" confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then info "$(lang operation_cancelled)"; exit 0; fi
}

# 步骤2: 系统准备 / Prepare system
function prepare_system() {
    banner "$(lang update_pkg)"; run_cmd sudo apt-get update -y
    banner "$(lang upgrade_pkg)"; run_cmd sudo apt-get upgrade -y

    info "$(lang locale_check)"
    if ! locale | grep -q "UTF-8"; then
        warn "$(lang locale_utf8_fail)"
        info "$(lang locale_prompt)"
        prompt_continue
        install_package "locales"
        run_cmd sudo dpkg-reconfigure locales
    else
        info "$(lang locale_utf8_ok)"
    fi
}

# 步骤3: 安装和配置 SSH / SSH setup
# 使用 sshd_config.d 下的 drop-in 文件，比直接 sed 主配置文件更安全。
# Use a sshd_config.d drop-in instead of sed-editing the main config; supported
# on both Debian 12 (bookworm) and Debian 13 (trixie).
function setup_ssh() {
    banner "$(lang ssh_modify)"; install_package "openssh-server"
    sudo mkdir -p /etc/ssh/sshd_config.d
    sudo tee /etc/ssh/sshd_config.d/50-android-terminal.conf >/dev/null <<'EOF'
# Managed by android16-terminal.sh - Android 16/17 Linux Terminal helper
Port 10022
PasswordAuthentication yes
EOF
    # 确保主配置文件包含 Include 指令 (Debian 12/13 默认都已包含, 仅作防御性检查)
    # Ensure the main config includes sshd_config.d/*.conf (default on both 12 & 13, defensive check).
    if ! sudo grep -qE '^\s*Include\s+/etc/ssh/sshd_config\.d/\*\.conf' /etc/ssh/sshd_config; then
        echo "Include /etc/ssh/sshd_config.d/*.conf" | sudo tee -a /etc/ssh/sshd_config > /dev/null
    fi
    run_cmd sudo systemctl restart ssh 2>/dev/null || run_cmd sudo systemctl restart sshd
    info "$(printf "$(lang config_success)" "/etc/ssh/sshd_config.d/50-android-terminal.conf")"
    info "$(lang ssh_port_prompt)"
}

# 步骤4: 安装桌面环境 / Install desktop
function install_desktop() {
    banner "$(printf "$(lang desktop_install)" "$DESKTOP_NAME")"
    install_package "tasksel"
    run_cmd sudo tasksel install "$TASKSEL_TASK"
}

# 步骤5: 安装和配置 VNC / VNC setup
function setup_vnc() {
    banner "$(lang vnc_config)"; install_package "tigervnc-standalone-server"; install_package "tigervnc-common"
    info "$(lang vnc_passwd_prompt)"; run_cmd vncpasswd
    mkdir -p ~/.vnc
    cat > ~/.vnc/config <<- EOF
		session=$VNC_SESSION
		geometry=1920x1080
		localhost=no
		alwaysshared
	EOF
    info "$(printf "$(lang config_success)" "~/.vnc/config")"
    echo ":1=$TARGET_USER" | sudo tee /etc/tigervnc/vncserver.users >/dev/null
    info "$(printf "$(lang config_success)" "/etc/tigervnc/vncserver.users")"
    run_cmd sudo systemctl daemon-reload; run_cmd sudo systemctl enable tigervncserver@:1.service; run_cmd sudo systemctl start tigervncserver@:1.service
    info "$(lang vnc_port_prompt)"
    info "$(lang display_btn_note)"
}

# 步骤6: 可选组件 / Optional components
function optional_components() {
    read -p "$(lang input_method_prompt)" install_ime
    if [[ "$install_ime" =~ ^[Yy]$ ]]; then
        banner "$(lang ime_install_banner)"
        install_package "ibus"; install_package "ibus-pinyin"
        im-config -n ibus || true
        info "$(lang ime_config_done)"
    fi
}

# 步骤7: 显示最终信息 / Final summary
function final_summary() {
    IP_ADDR=$(hostname -I 2>/dev/null | awk '{print $1}')
    [ -z "$IP_ADDR" ] && IP_ADDR="127.0.0.1"
    clear; banner "$(lang final_summary)"; echo "$(lang final_info)"
    echo ""; echo -e "$(lang final_ssh_header)"
    echo -e "    ssh $TARGET_USER@$IP_ADDR -p 10022"
    echo ""; echo -e "$(lang final_vnc_header)"
    printf "    $(lang final_vnc_addr)\n" "$IP_ADDR"
    printf "    $(lang final_vnc_alt)\n" "$IP_ADDR"
    echo ""
    echo -e "$(lang final_adb_hint)"
    echo ""
}

# --- 主程序入口 / Main entry ---
function main() {
    detect_os
    user_selections
    prepare_system
    setup_ssh
    install_desktop
    setup_vnc
    optional_components
    final_summary
}

# 执行主函数 / Run
main
