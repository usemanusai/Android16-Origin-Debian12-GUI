# Changelog

All notable changes to this project will be documented in this file.

## [4.0.0] - 2026-10-07 - 🚀 Advanced Edition

### Major Features Added
- **Distro-Specific Defaults**: Ubuntu→GNOME, Fedora→KDE, Arch→XFCE (auto-detected)
- **GPU Acceleration**: Auto-detects & installs NVIDIA/AMD/Intel drivers
- **Audio Forwarding**: PulseAudio/PipeWire support over SSH/VNC
- **Container Support**: Docker & Podman with full GUI desktop
- **Display Server Detection**: Auto-detects Wayland/X11 with configuration
- **Flatpak/Snap Support**: Modern app installation methods
- **Cloud VM Detection**: AWS/Azure/GCP/DigitalOcean auto-optimization
- **Unified Upgrade Script**: Single script handles all distro version paths
- **Advanced Environment Variables**: GPU_ACCEL, AUDIO_FORWARD, CONTAINER_ENGINE, etc.

### Improved
- True autonomous mode - works without ANY user interaction
- Better GPU detection and driver selection
- Enhanced SSH configuration for X11 forwarding
- Cloud-optimized configurations for each provider
- Distro-specific package mappings for all features

### New Scripts
- `upgrade-distro.sh` - Unified upgrade for all distros (Debian/Ubuntu/Fedora/Arch/Kali/etc)

## [3.0.0] - 2026-10-07 - 🌍 Universal Distribution Support

### Added
- **Universal Linux Support**: Debian, Ubuntu, Kali, Fedora, Arch, openSUSE, Alpine
- **Automatic Package Manager Detection**: apt, dnf, pacman, zypper, apk
- **Distro-Agnostic Installation**: Single script works on all major Linux distros
- **Enhanced Desktop Detection**: Auto-maps desktop packages for each distro
- **Better Error Handling**: Graceful fallbacks when packages unavailable
- **Unified Configuration**: SSH, VNC, and locale setup works across all distros

### Improved
- Package installation abstraction layer
- Desktop environment mapping for 7+ distros
- Installation messaging shows detected distro & package manager
- Locale setup handles distros without explicit locale packages
- VNC configuration compatible with all systemd-based distros

### Fixed
- SSH configuration now works on Fedora, Arch, openSUSE
- Desktop installation respects distro-specific package names
- Improved compatibility with immutable distros (Alpine, Fedora CoreOS)

## [2.1.0] - 2026-10-07

### Added
- Support for Debian 14+ releases with auto-detection
- Enhanced error handling for modern package managers
- Additional security hardening in SSH configuration
- Updated compatibility matrix for 2026
- State management system for safe re-runs
- Auto-generated VNC password storage

### Improved
- Documentation updated for October 2026 compatibility
- Script robustness enhancements for newer Debian releases
- Better detection of VNC server status
- Improved locale handling for edge cases
- Reduced user prompts in autonomous mode

### Fixed
- Corrected package version references for 2026 Debian repositories
- Enhanced compatibility checks for newer Android Terminal versions
- Improved error messages for better troubleshooting

## [2.0.0] - 2026-06-10 - 🤖 Autonomous Mode

### Added
- Full bilingual (Chinese/English) support throughout UI
- Autonomous mode with `AUTO_MODE=1` environment variable
- State management to track completed installation steps
- Auto-generated VNC password feature
- sshd_config.d drop-in configuration system
- Display button awareness for Android 16 QPR2 / Android 17
- Automatic OS detection (bookworm vs trixie vs forky)
- Smart configuration step skipping

### Changed
- Moved SSH configuration to `/etc/ssh/sshd_config.d/` for cleaner management
- Improved system preparation with robust locale detection
- Enhanced VNC configuration handling

### Security
- Updated SSH hardening practices
- Better password authentication prompts
- Improved PermitRootLogin restrictions

## [1.0.0] - Initial Release

### Features
- Basic Debian 12 support
- One-click GUI setup via VNC
- SSH server configuration on port 10022
- Desktop environment installation via tasksel
- Windows PowerShell automation helper
- Bilingual UI support (Chinese/English)
- Compatible with Android 16/17 Terminal

---

## Version Format

This project follows [Semantic Versioning](https://semver.org/). Version numbers are formatted as `MAJOR.MINOR.PATCH`.

- **MAJOR**: Breaking changes or major feature additions
- **MINOR**: New features or improvements
- **PATCH**: Bug fixes and minor improvements
