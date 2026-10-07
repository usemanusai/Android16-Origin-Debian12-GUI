## AD FocuSee  [Record Your Screen.Get Polished Videos Automatically.](https://focusee.imobie.com?ad=github-xlzhen) 
# Android 16 / 17 Terminal Debian GUI Access Tool (2026 Optimized)

![Bash](https://img.shields.io/badge/Shell-Bash-green) ![Debian](https://img.shields.io/badge/OS-Debian%2012%2B-red) ![Android](https://img.shields.io/badge/Android-16%20%7C%2017-brightgreen) ![License](https://img.shields.io/badge/License-MIT-blue) ![2026 Optimized](https://img.shields.io/badge/2026%20Optimized-Autonomous-orange) ![Last Updated](https://img.shields.io/badge/Last%20Updated-2026--10--07-yellow)

**Chinese Documentation**: [README_CN.md](README_CN.md) | **[CHANGELOG](CHANGELOG.md)** | **[SECURITY](/.github/SECURITY.md)**

## 🚀 Quick Start (30 Seconds)

### Autonomous Mode (No User Input)
```bash
# Default: XFCE desktop, Chinese UI
AUTO_MODE=1 ./android16-terminal.sh

# With English UI and GNOME desktop
AUTO_MODE=1 DESKTOP=gnome LANG_CHOICE=en ./android16-terminal.sh

# Supported desktops: xfce, gnome, kde, mate, cinnamon, lxqt, lxde, gnome-flashback
```

### Interactive Mode
```bash
./android16-terminal.sh
# Follow the on-screen prompts to customize
```

## ✨ What It Does

This script automates GUI setup for Android 16/17 Linux Terminal and standard Debian systems:

1. **Auto-detects** Debian version (12 bookworm, 13 trixie, 14+ forky)
2. **Installs** desktop environment (your choice or default XFCE)
3. **Configures** SSH on port 10022 with secure drop-in config
4. **Sets up** VNC server for remote GUI access
5. **Auto-generates** VNC password (saved to ~/.vnc/password.txt)
6. **Remembers state** - safe to re-run without duplicate installations
7. **Works in 3-15 minutes** depending on your internet speed

## 📋 Compatibility Matrix

| Platform | Default Debian | Status | Notes |
|----------|---|---|---|
| Android 16 Terminal (Baklava) | Debian 12 (bookworm) | ✅ Tested | Stock image, auto-detected |
| Android 17 Terminal (Cinnamon) | Debian 13 (trixie) | ✅ Tested | Stock image, auto-detected |
| Desktop/Server Debian 12 | bookworm | ✅ Tested | Full feature support |
| Desktop/Server Debian 13+ | trixie+ | ✅ Tested | Full feature support |
| Generic Linux (non-Debian) | N/A | ❌ Unsupported | Debian only |

## 🎯 Features

- ✅ **Autonomous Mode**: Set and forget - no prompts
- ✅ **State Management**: Skips completed steps automatically
- ✅ **Auto-Password**: Generates & saves VNC password
- ✅ **Smart Locale**: Automatically configures UTF-8 locale
- ✅ **Modern SSH**: Uses `/etc/ssh/sshd_config.d/` drop-in (Debian 12/13+)
- ✅ **Bilingual UI**: Full Chinese & English support
- ✅ **Easy Re-runs**: Safe to run multiple times
- ✅ **2026 Optimized**: Works with current Debian releases & packages

## 🔧 Installation

### Step 1: Download
```bash
# On Android Terminal or Linux
wget https://raw.githubusercontent.com/usemanusai/Android16-Origin-Debian12-GUI/main/android16-terminal.sh
chmod +x android16-terminal.sh
```

### Step 2: Run (Pick One)

**Option A: Autonomous (Recommended for Android)**
```bash
AUTO_MODE=1 ./android16-terminal.sh
```

**Option B: Interactive (Customization)**
```bash
./android16-terminal.sh
# Select language, desktop, options interactively
```

### Step 3: Connect

**On Windows/Mac/Linux:**
```bash
# If running on Android
adb forward tcp:5901 tcp:5901

# Open VNC client and connect to
localhost:5901
```

Enter the auto-generated password (check `~/.vnc/password.txt` on the device)

## 🔌 Usage Examples

### Example 1: XFCE with Chinese UI (Default)
```bash
AUTO_MODE=1 ./android16-terminal.sh
```

### Example 2: GNOME with English UI
```bash
AUTO_MODE=1 DESKTOP=gnome LANG_CHOICE=en ./android16-terminal.sh
```

### Example 3: KDE Plasma
```bash
AUTO_MODE=1 DESKTOP=kde ./android16-terminal.sh
```

### Example 4: Custom User & Language
```bash
AUTO_MODE=1 TARGET_USER=myuser DESKTOP=mate LANG_CHOICE=en ./android16-terminal.sh
```

## 🔐 SSH Connection

After setup, connect via SSH:

```bash
# On your PC/Mac/Linux
ssh -p 10022 username@android-device-ip

# Example
ssh -p 10022 ubuntu@192.168.1.100
```

**Security Note**: Change the default password after first login:
```bash
passwd
```

## 🐛 Troubleshooting

### Script Fails to Run
```bash
chmod +x android16-terminal.sh
bash -x ./android16-terminal.sh  # Debug mode
```

### VNC Password Lost
```bash
# Password is stored here
cat ~/.vnc/password.txt

# Or generate new one
vncpasswd ~/.vnc/passwd
```

### Desktop Not Starting
```bash
# Reinstall desktop (safe to re-run)
AUTO_MODE=1 DESKTOP=xfce ./android16-terminal.sh
```

### Check Installation Status
```bash
# View what's been completed
cat ~/.android-terminal-installer/install.state
```

## 📦 What Gets Installed

- `openssh-server` (SSH server on port 10022)
- `tigervnc-standalone-server` & `tigervnc-common` (VNC)
- `tasksel` (desktop environment selector)
- `locales` (language support)
- Selected desktop environment (XFCE, GNOME, KDE, etc.)

**Estimated size**: 1-3 GB depending on desktop choice

## 🛠️ Advanced: Debian Upgrade

If you want to upgrade from Debian 12 → 13 → 14+:

```bash
# Autonomous upgrade (no prompts)
AUTO_MODE=1 ./update_debian14.sh

# Interactive upgrade
./update_debian14.sh
```

**⚠️ Android Terminal Warning**: In-place upgrades may corrupt the VM image. Consider:
- Staying on Debian 12 until Android 17 ships
- Using desktop Debian instead

## 📝 Other Scripts in This Repo

| Script | Purpose |
|--------|----------|
| `android16-terminal.sh` | Main installer (2026 optimized, autonomous) |
| `update_debian14.sh` | Auto upgrade Debian versions (new 2026) |
| `update_debian13.sh` | Manual upgrade Debian 12→13 (legacy) |
| `update_debian13_EN.sh` | English version of above |
| `install_software.sh` | Install Chrome, VS Code, etc. |
| `auto-start.ps1` | Windows helper (ADB + VNC launcher) |

## 📄 License & Contributing

This project is open-sourced under [MIT License](LICENSE).

**Issues & PRs Welcome!** Please provide:
- Error messages (run in debug mode: `bash -x script.sh`)
- Device/OS details (Android version, Debian release)
- Expected vs actual behavior

## 🔄 2026 Improvements

- ✨ **Autonomous Mode**: Works without any user interaction
- 🔄 **State Management**: Tracks progress, skips completed steps
- 🎯 **Auto-Password**: Generates secure VNC password automatically
- 🚀 **Faster Setup**: ~3-15 minutes depending on internet speed
- 🛡️ **Better Errors**: Clearer error messages with recovery steps
- 📱 **Debian 14+ Support**: Future-proof for upcoming releases
- 🏗️ **Modern SSH Config**: Uses systemd drop-in configuration

---

**Last Updated**: October 7, 2026 | **Version**: 2.1.0

**Get started now**: `AUTO_MODE=1 ./android16-terminal.sh`
