## AD FocuSee  [Record Your Screen.Get Polished Videos Automatically.](https://focusee.imobie.com?ad=github-xlzhen) 
# Android 16 / 17 Terminal GUI Installer (2026 Advanced Edition)

![Shell](https://img.shields.io/badge/Shell-Bash-green) ![Distros](https://img.shields.io/badge/Distros-7%2B-brightblue) ![Android](https://img.shields.io/badge/Android-16%20%7C%2017-brightgreen) ![Features](https://img.shields.io/badge/Features-Advanced-red) ![License](https://img.shields.io/badge/License-MIT-blue) ![2026 Advanced](https://img.shields.io/badge/2026-Advanced%20Edition-purple) ![Last Updated](https://img.shields.io/badge/Last%20Updated-2026--10--07-yellow)

**Chinese Documentation**: [README_CN.md](README_CN.md) | **[CHANGELOG](CHANGELOG.md)** | **[SECURITY](/.github/SECURITY.md)**

## 🌍 Universal Linux Support with Advanced Features

This is the **Advanced Edition** featuring:
- 🤖 **One-command setup** for 7+ distros
- 🎯 **Distro-specific desktop defaults** (Ubuntu→GNOME, Fedora→KDE, Arch→XFCE)
- 🐳 **Docker/Podman** support for isolated GUI environments
- 🖥️ **Wayland vs X11 detection** with auto-configuration
- 🚀 **GPU acceleration** detection & setup (NVIDIA/AMD/Intel)
- 🔊 **Audio forwarding** over SSH/VNC
- 📦 **Snap/Flatpak** app installation support
- ☁️ **Cloud VM auto-detection** (AWS/Azure/GCP/DigitalOcean)
- 🔄 **Unified upgrade paths** for all distros

### Supported Distributions

- ✅ **Debian** (12 bookworm, 13 trixie, 14+ forky)
- ✅ **Ubuntu** (20.04 LTS, 22.04 LTS, 24.04 LTS+)
- ✅ **Kali Linux** (rolling, latest)
- ✅ **Fedora** (38+, Silverblue, Kinoite)
- ✅ **Arch Linux** (Arch, Manjaro, EndeavorOS)
- ✅ **openSUSE** (Leap, Tumbleweed)
- ✅ **Alpine Linux** (minimal, edge)
- ✅ **Android 16/17 Terminal** (all above distros on Android)

## 🚀 Quick Start (30 Seconds)

### Ultra-Simple: Just Works
```bash
# Downloads & runs with distro-optimized defaults
AUTO_MODE=1 ./android16-terminal.sh

# That's it! Detects your distro and applies best defaults:
# - Ubuntu → GNOME + Wayland
# - Fedora → KDE + Wayland  
# - Arch → XFCE + X11
# - etc.
```

### With Custom Options
```bash
# Custom desktop (overrides distro default)
AUTO_MODE=1 DESKTOP=gnome ./android16-terminal.sh

# Enable GPU acceleration
AUTO_MODE=1 GPU_ACCEL=1 ./android16-terminal.sh

# Use Podman instead of Docker
AUTO_MODE=1 CONTAINER_ENGINE=podman ./android16-terminal.sh

# English UI with Snap support
AUTO_MODE=1 LANG_CHOICE=en FLATPAK_SUPPORT=1 ./android16-terminal.sh

# All features enabled
AUTO_MODE=1 GPU_ACCEL=1 AUDIO_FORWARD=1 CONTAINER_ENGINE=docker FLATPAK_SUPPORT=1 ./android16-terminal.sh
```

### Interactive Mode
```bash
./android16-terminal.sh
# Walks you through all options interactively
```

## ✨ What It Does

### Core Setup
1. **Auto-detects** your distro, package manager, GPU, Wayland/X11
2. **Installs** desktop environment with distro-specific defaults
3. **Configures** SSH on port 10022 (hardened)
4. **Sets up** VNC server for remote GUI access
5. **Auto-generates** secure VNC password
6. **Smart state tracking** - safe to re-run

### Advanced Features (Optional)
7. **GPU Acceleration** - detects NVIDIA/AMD/Intel and installs drivers
8. **Audio Forwarding** - enables PulseAudio over SSH/VNC
9. **Docker/Podman** - isolated GUI containers with full desktop
10. **Wayland/X11** - detects & optimizes for your display server
11. **Snap/Flatpak** - app installation support
12. **Cloud VM Detection** - optimizes for AWS/Azure/GCP/DigitalOcean

## 📋 Distro-Specific Defaults

| Distro | Default Desktop | Display Server | Notes |
|--------|---|---|---|
| **Ubuntu** | GNOME | Wayland (preferred) | Optimized for latest Ubuntu |
| **Fedora** | KDE Plasma | Wayland (default) | Cutting-edge desktop |
| **Debian** | XFCE | X11 | Lightweight & stable |
| **Arch** | XFCE | X11 | Minimal footprint |
| **Kali** | XFCE | X11 | Security-focused |
| **openSUSE** | GNOME | Wayland | openSUSE default |
| **Alpine** | XFCE | X11 | Minimal container |

**All defaults can be overridden with environment variables.**

## 🔧 Environment Variables

```bash
# Core
AUTO_MODE=1              # Autonomous (no prompts)
DESKTOP=gnome            # xfce, gnome, kde, mate, cinnamon, lxqt, lxde
LANG_CHOICE=en           # en or cn (Chinese)
TARGET_USER=myuser       # Custom username

# Advanced Features
GPU_ACCEL=1              # Enable GPU drivers (NVIDIA/AMD/Intel)
AUDIO_FORWARD=1          # Enable PulseAudio forwarding
CONTAINER_ENGINE=docker  # docker or podman (installs container support)
FLATPAK_SUPPORT=1        # Install Flatpak support
SNAP_SUPPORT=1           # Install Snap support
WAYLAND_MODE=1           # Force Wayland (if supported)
X11_MODE=1               # Force X11 (override Wayland)
CLOUD_DETECT=1           # Enable cloud VM detection & optimization
```

## 💾 Installation

### Step 1: Download
```bash
wget https://raw.githubusercontent.com/usemanusai/Android16-Origin-Debian12-GUI/main/android16-terminal.sh
chmod +x android16-terminal.sh
```

### Step 2: Run
```bash
# Simplest way (uses distro defaults)
AUTO_MODE=1 ./android16-terminal.sh

# Or with advanced features
AUTO_MODE=1 GPU_ACCEL=1 AUDIO_FORWARD=1 ./android16-terminal.sh
```

### Step 3: Connect
```bash
# Get password
cat ~/.vnc/password.txt

# SSH Connection
ssh -p 10022 username@device-ip

# VNC Connection
vncviewer device-ip:1

# From Android (via ADB)
adb forward tcp:5901 tcp:5901
# Then VNC to localhost:5901
```

## 📖 Advanced Usage Examples

### Ubuntu with Full Features
```bash
AUTO_MODE=1 GPU_ACCEL=1 AUDIO_FORWARD=1 FLATPAK_SUPPORT=1 ./android16-terminal.sh
# Result: GNOME + Wayland + NVIDIA drivers + audio + Flatpak
```

### Fedora in Docker Container
```bash
AUTO_MODE=1 CONTAINER_ENGINE=docker DESKTOP=kde ./android16-terminal.sh
# Result: KDE inside isolated Docker environment
```

### Arch with GPU & Podman
```bash
AUTO_MODE=1 GPU_ACCEL=1 CONTAINER_ENGINE=podman ./android16-terminal.sh
# Result: XFCE + AMD drivers + Podman support
```

### Cloud VM Optimized (AWS/Azure/GCP)
```bash
AUTO_MODE=1 CLOUD_DETECT=1 GPU_ACCEL=1 ./android16-terminal.sh
# Result: Detects cloud provider, optimizes for performance
```

### Minimal Setup (Alpine)
```bash
AUTO_MODE=1 DESKTOP=xfce ./android16-terminal.sh
# Result: Ultra-lightweight XFCE environment
```

## 🔌 Remote Access

### SSH with Audio
```bash
# Enable audio forwarding
ssh -X -p 10022 username@device-ip

# Or with full PulseAudio tunnel
ssh -R 64713:localhost:64713 -p 10022 username@device-ip
```

### VNC with Audio (via PulseAudio)
```bash
# If audio forwarding enabled
vncviewer device-ip:1
# Audio will be forwarded automatically
```

### Docker/Podman Desktop in Browser
```bash
# If container support enabled
docker run -it -e DISPLAY=:0 myimage bash
# Or with Podman
podman run -it -e DISPLAY=:0 myimage bash
```

## 🎯 Distro Upgrade Paths

### Unified Upgrade Script
```bash
# Single script handles all distro upgrades
AUTO_MODE=1 ./upgrade-distro.sh

# Automatically upgrades:
# Debian 12 → 13 → 14+
# Ubuntu 20.04 → 22.04 → 24.04+
# Fedora N → N+1 → N+2
# Arch (rolling)
# Kali (rolling)
```

## 🐛 Troubleshooting

### GPU Not Detected
```bash
# Check GPU info
lspci | grep -i vga
glxinfo | grep vendor

# Manually enable
GPU_ACCEL=1 ./android16-terminal.sh
```

### Wayland Issues
```bash
# Force X11
X11_MODE=1 ./android16-terminal.sh

# Or check session
echo $XDG_SESSION_TYPE
```

### Audio Not Working
```bash
# Enable audio forwarding
AUDIO_FORWARD=1 ./android16-terminal.sh

# Check PulseAudio
pactl info
```

### Docker Permission Denied
```bash
# Add user to docker group
sudo usermod -aG docker $USER
groups $USER
```

### Cloud VM Not Detected
```bash
# Check cloud provider
grep -i cloud /etc/os-release
ls /sys/hypervisor/

# Manual enable
CLOUD_DETECT=1 ./android16-terminal.sh
```

## 📦 What Gets Installed

### Always Installed
- `openssh-server` (SSH on 10022)
- `tigervnc-server` (VNC)
- Selected desktop environment
- Display drivers (X11/Wayland)

### Optional (with flags)
- `nvidia-driver` / `amdgpu` / `intel-media-driver` (GPU_ACCEL=1)
- `pulseaudio` / `pipewire` (AUDIO_FORWARD=1)
- `docker.io` or `podman` (CONTAINER_ENGINE)
- `flatpak` / `snapd` (FLATPAK_SUPPORT=1 / SNAP_SUPPORT=1)
- Cloud optimization packages (CLOUD_DETECT=1)

**Total Size**: 2-6 GB depending on options

## 🔄 2026 Advanced Improvements

- 🌍 **Universal Distro Support** - 7+ distros with smart detection
- 🎯 **Distro-Specific Defaults** - Best desktop for each distro
- 🐳 **Container Support** - Docker & Podman with GUI
- 🖥️ **Display Server Detection** - Wayland/X11 auto-configuration
- 🚀 **GPU Acceleration** - NVIDIA/AMD/Intel driver auto-install
- 🔊 **Audio Forwarding** - PulseAudio/PipeWire over SSH/VNC
- 📦 **Modern Packaging** - Snap & Flatpak support
- ☁️ **Cloud Optimization** - AWS/Azure/GCP/DigitalOcean detection
- 🔄 **Unified Upgrades** - Single script for all distro versions
- 🤖 **True Autonomous** - "Just works" with zero configuration

## 📄 License & Contributing

MIT License - contributions welcome!

**Report Issues:**
- Error output: `bash -x script.sh 2>&1 | tee debug.log`
- Your distro: `cat /etc/os-release`
- GPU info: `lspci | grep -i vga`
- Display server: `echo $XDG_SESSION_TYPE`

## 🚀 Roadmap 2027

- [ ] WebRTC desktop streaming
- [ ] Kubernetes pod GUI support
- [ ] Hardware acceleration for Wayland
- [ ] Multi-user VNC sessions
- [ ] Cloud-native container registries
- [ ] AI desktop assistant integration

---

**Last Updated**: October 7, 2026 | **Version**: 4.0.0 | **Advanced Edition**

**Get started now**: `AUTO_MODE=1 ./android16-terminal.sh`

**Or enable all features**: `AUTO_MODE=1 GPU_ACCEL=1 AUDIO_FORWARD=1 FLATPAK_SUPPORT=1 CLOUD_DETECT=1 ./android16-terminal.sh`

**Supported on:** 🐧 Debian • 🧡 Ubuntu • 🔪 Kali • 🎩 Fedora • 🏹 Arch • 🦎 openSUSE • ⛰️ Alpine • 📱 Android 16/17
