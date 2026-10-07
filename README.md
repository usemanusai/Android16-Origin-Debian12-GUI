## AD FocuSee  [Record Your Screen.Get Polished Videos Automatically.](https://focusee.imobie.com?ad=github-xlzhen) 
# Android 16 / 17 Terminal GUI Installer (2026 Optimized - Universal Distro Support)

![Shell](https://img.shields.io/badge/Shell-Bash-green) ![Distros](https://img.shields.io/badge/Distros-7%2B-brightblue) ![Android](https://img.shields.io/badge/Android-16%20%7C%2017-brightgreen) ![License](https://img.shields.io/badge/License-MIT-blue) ![2026 Universal](https://img.shields.io/badge/2026%20Universal-All%20Distros-orange) ![Last Updated](https://img.shields.io/badge/Last%20Updated-2026--10--07-yellow)

**Chinese Documentation**: [README_CN.md](README_CN.md) | **[CHANGELOG](CHANGELOG.md)** | **[SECURITY](/.github/SECURITY.md)**

## 🌍 Universal Linux Support

This script now supports **any major Linux distribution** with automatic detection:

- ✅ **Debian** (12 bookworm, 13 trixie, 14+ forky)
- ✅ **Ubuntu** (20.04 LTS, 22.04 LTS, 24.04 LTS+)
- ✅ **Kali Linux** (rolling, latest)
- ✅ **Fedora** (38+, Silverblue, Kinoite)
- ✅ **Arch Linux** (Arch, Manjaro, EndeavorOS)
- ✅ **openSUSE** (Leap, Tumbleweed)
- ✅ **Alpine Linux** (minimal, edge)
- ✅ **Android 16/17 Terminal** (all above distros on Android)

## 🚀 Quick Start (30 Seconds)

### Autonomous Mode (No User Input)
```bash
# Default: XFCE desktop, Chinese UI (works on ANY distro)
AUTO_MODE=1 ./android16-terminal.sh

# With English UI and GNOME desktop
AUTO_MODE=1 DESKTOP=gnome LANG_CHOICE=en ./android16-terminal.sh

# Supported desktops: xfce, gnome, kde, mate, cinnamon, lxqt, lxde
```

### Interactive Mode
```bash
./android16-terminal.sh
# Follow the on-screen prompts to customize
```

## ✨ What It Does

Automates GUI setup for any Linux distribution:

1. **Auto-detects** your distro and package manager (apt, dnf, pacman, zypper, apk)
2. **Installs** desktop environment (XFCE, GNOME, KDE, MATE, etc.)
3. **Configures** SSH on port 10022
4. **Sets up** VNC server for remote GUI access
5. **Auto-generates** VNC password (saved to ~/.vnc/password.txt)
6. **Remembers state** - safe to re-run without duplicate installations
7. **Works in 3-15 minutes** depending on your internet speed

## 📋 Compatibility Matrix

| Distribution | Version | Status | Notes |
|--|--|--|--|
| **Debian** | 12 (bookworm) | ✅ Fully Tested | Original supported distro |
| **Debian** | 13+ (trixie+) | ✅ Fully Tested | Future versions supported |
| **Ubuntu** | 20.04 LTS+ | ✅ Fully Tested | Desktop & Server editions |
| **Kali Linux** | Rolling | ✅ Fully Tested | Security-focused variant |
| **Fedora** | 38+ | ✅ Fully Tested | DNF package manager |
| **Fedora** | Silverblue/Kinoite | ⚠️ Partial | Immutable FS, manual setup |
| **Arch Linux** | Latest | ✅ Fully Tested | Pacman package manager |
| **Manjaro** | Latest | ✅ Fully Tested | Arch-based variant |
| **openSUSE** | Leap/Tumbleweed | ✅ Fully Tested | Zypper package manager |
| **Alpine Linux** | Latest | ✅ Basic | Minimal, APK manager |
| **Android 16 Terminal** | Any distro above | ✅ Tested | All above work in Android |
| **Android 17 Terminal** | Any distro above | ✅ Tested | All above work in Android |

## 🔧 Supported Package Managers

| Package Manager | Distros | Auto-Detection |
|--|--|--|
| **apt** | Debian, Ubuntu, Kali | ✅ Automatic |
| **dnf** | Fedora, RHEL, CentOS | ✅ Automatic |
| **pacman** | Arch, Manjaro, EndeavorOS | ✅ Automatic |
| **zypper** | openSUSE Leap, Tumbleweed | ✅ Automatic |
| **apk** | Alpine Linux | ✅ Automatic |

## 💾 Installation

### Step 1: Download
```bash
# On any Linux system
wget https://raw.githubusercontent.com/usemanusai/Android16-Origin-Debian12-GUI/main/android16-terminal.sh
chmod +x android16-terminal.sh
```

### Step 2: Run (Pick One)

**Option A: Autonomous (Recommended)**
```bash
AUTO_MODE=1 ./android16-terminal.sh
```

**Option B: Interactive (Customization)**
```bash
./android16-terminal.sh
```

### Step 3: Connect

**From Windows/Mac/Linux:**
```bash
# If running on Android
adb forward tcp:5901 tcp:5901

# Open VNC client and connect to
localhost:5901
```

Enter the auto-generated password (stored in `~/.vnc/password.txt`)

## 📖 Usage Examples

### Ubuntu 24.04 LTS with GNOME
```bash
AUTO_MODE=1 DESKTOP=gnome LANG_CHOICE=en ./android16-terminal.sh
```

### Fedora with KDE Plasma
```bash
AUTO_MODE=1 DESKTOP=kde LANG_CHOICE=en ./android16-terminal.sh
```

### Kali Linux with Cinnamon
```bash
AUTO_MODE=1 DESKTOP=cinnamon ./android16-terminal.sh
```

### Arch Linux with LXQt (minimal)
```bash
AUTO_MODE=1 DESKTOP=lxqt ./android16-terminal.sh
```

### Alpine Linux with XFCE
```bash
AUTO_MODE=1 DESKTOP=xfce ./android16-terminal.sh
```

### Custom User, Desktop & Language
```bash
AUTO_MODE=1 TARGET_USER=myuser DESKTOP=mate LANG_CHOICE=en ./android16-terminal.sh
```

## 🔌 SSH Connection

After setup, connect via SSH from any computer:

```bash
# Replace YOUR_DEVICE_IP with actual IP
ssh -p 10022 username@YOUR_DEVICE_IP

# Example
ssh -p 10022 ubuntu@192.168.1.100
```

**Change password after first login:**
```bash
passwd
```

## 🐛 Troubleshooting

### Script Fails
```bash
# Enable debug mode
bash -x ./android16-terminal.sh

# Check which distro was detected
cat /etc/os-release
```

### VNC Password Lost
```bash
cat ~/.vnc/password.txt
```

### Reinstall Desktop (Safe to re-run)
```bash
AUTO_MODE=1 DESKTOP=xfce ./android16-terminal.sh
```

### Check What's Installed
```bash
cat ~/.terminal-installer-state/install.state
```

## 📦 What Gets Installed

**All Distros:**
- `openssh-server` (SSH on port 10022)
- `tigervnc-server` (VNC server)
- Selected desktop environment

**Size:** 1-3 GB depending on desktop choice

## 🎯 Why This is Better

- **One script for all distros** - no hunting for distro-specific docs
- **Automatic package manager detection** - no manual selection needed
- **Idempotent** - safe to run multiple times
- **State tracking** - skips completed steps automatically
- **Auto password generation** - VNC ready to use immediately
- **Bilingual UI** - Chinese & English support
- **Future-proof** - works with new distro versions

## 📄 License & Contributing

MIT License - contributions welcome!

**Report Issues:**
- Error output (run in debug mode: `bash -x script.sh`)
- Your distro & version (run: `cat /etc/os-release`)
- Expected vs actual behavior

## 🔄 2026 Improvements

- 🌍 **Universal Distro Support** - Debian, Ubuntu, Kali, Fedora, Arch, openSUSE, Alpine
- 🤖 **Autonomous Mode** - Zero user interaction
- 📊 **Smart State Management** - Tracks progress, skips completed steps
- 🔐 **Auto-Password** - Generates secure VNC password
- ⚡ **Fast Setup** - 3-15 minutes depending on internet
- 🛡️ **Better Errors** - Clear messages with recovery steps
- 🔄 **Package Manager Abstraction** - Unified installer for all package managers
- 🔌 **SSH Hardening** - Modern configuration standards

## 🚀 What's Next?

Future improvements planned:
- [ ] Docker/Podman support for isolated environments
- [ ] Wayland vs X11 detection & configuration
- [ ] GPU acceleration detection & setup
- [ ] Audio forwarding over SSH/VNC
- [ ] Snap/Flatpak support for app installation
- [ ] Cloud VM auto-detection & optimization

---

**Last Updated**: October 7, 2026 | **Version**: 3.0.0 | **Universal Release**

**Get started now on ANY distro**: `AUTO_MODE=1 ./android16-terminal.sh`

**Supported on:** 🐧 Debian • 🧡 Ubuntu • 🔪 Kali • 🎩 Fedora • 🏹 Arch • 🦎 openSUSE • ⛰️ Alpine • 📱 Android 16/17
