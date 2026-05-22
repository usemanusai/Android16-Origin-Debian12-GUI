## AD FocuSee  [Record Your Screen.Get Polished Videos Automatically.](https://focusee.imobie.com?ad=github-xlzhen) 
# Android 16 / 17 Terminal Debian GUI Access Tool

![Bash](https://img.shields.io/badge/Shell-Bash-green) ![Debian](https://img.shields.io/badge/OS-Debian%2012%20%2F%2013-red) ![Android](https://img.shields.io/badge/Android-16%20%7C%2017-brightgreen) ![VNC](https://img.shields.io/badge/Protocol-VNC-blue)

**Chinese Documentation**: [README_CN.md](README_CN.md)

## Feature Overview

This script is designed for the **Linux Terminal** that ships with Android 16 (Baklava) and Android 17 (Cinnamon Bun). It auto-detects whether the underlying Debian image is **Debian 12 (bookworm)** or **Debian 13 (trixie)** and configures a full graphical desktop with remote VNC access accordingly.

After running it you can:

1. Run this script inside the Android Terminal to complete configuration
2. Execute `adb forward tcp:5901 tcp:5901` on your PC for port forwarding
3. Connect any VNC client to `localhost:5901`

(Or, on Android 16 QPR2 / Android 17, tap the **Display** button in the top-right of the Terminal app to render the GUI directly on Android via Wayland + virglrenderer — no VNC needed.)

## Compatibility Matrix

| Host                  | Default Debian | Tested | Notes                                                                                          |
| --------------------- | -------------- | ------ | ---------------------------------------------------------------------------------------------- |
| Android 16 (Baklava)  | Debian 12 (bookworm) | ✅ | Stock image; `android16-terminal.sh` auto-detects bookworm.                                    |
| Android 16 + manual upgrade to 13 | Debian 13 (trixie) | ⚠️ | Works post-upgrade, but the bookworm→trixie dist-upgrade can corrupt the AVF VM image — see warnings in `update_debian13.sh`. |
| Android 17 (Cinnamon Bun) | Debian 13 (trixie) | ✅ | Stock image; `android16-terminal.sh` auto-detects trixie.                                      |
| Generic Debian 12 / 13 (server/desktop) | bookworm / trixie | ✅ | Scripts run on any standard Debian 12/13 system.                                               |

## Key Features

- **Auto OS Detection**: One script for both Debian 12 and Debian 13 — selects the right install steps automatically
- **One-click Configuration**: Automates installation and configuration of all necessary components
- **SSH Access**: Configures SSH service on port 10022 via a dedicated `/etc/ssh/sshd_config.d/` drop-in (clean on both Debian 12 and 13)
- **GUI Support**: Installs your chosen desktop environment and a TigerVNC server
- **Display-button aware**: Prints a note about the native Wayland Display feature added in Android 16 QPR2 / Android 17
- **Smart Detection**: Automatically skips completed configuration steps
- **UTF-8 Locale Check**: Prevents redundant locale configuration
- **Detailed Logging**: Color-coded bilingual (中/EN) output

## Usage Guide

### Prerequisites

- Android 16 or Android 17 device with the Linux Terminal feature enabled
- (Or any standard Debian 12 / 13 system with sudo)

### Installation Steps

1. Save the script to your Android terminal device (e.g., `android16-terminal.sh`)
2. Grant execution permissions:
   ```bash
   chmod +x android16-terminal.sh
   ```
3. Execute the script:
   ```bash
   ./android16-terminal.sh
   ```

### PC Connection Steps (VNC)

1. Ensure Android device is connected via USB
2. Perform port forwarding on PC:
   ```bash
   adb forward tcp:5901 tcp:5901
   ```
3. Open VNC client and connect to:
   ```
   localhost:5901
   ```
4. Enter the VNC password set during script execution

Windows users can run [`auto-start.ps1`](auto-start.ps1) to install ADB + TigerVNC and connect automatically.

### Android-Side GUI (no VNC, Android 16 QPR2+/Android 17)

On Android 16 QPR2 and Android 17, the Terminal app gained a **Display** button (top-right) that renders the Linux GUI natively on Android via Wayland and virglrenderer. To enable GPU acceleration:

```bash
# On the Android host, inside the Terminal app's Linux folder:
touch virglrenderer
```

Then tap the Display button and run `weston` (or your chosen DE) from the terminal.

## Script Function Details

`android16-terminal.sh` performs:

1. **OS detection** — refuses to run on anything other than Debian 12 (bookworm) or Debian 13 (trixie)
2. **System Updates** — `apt-get update && apt-get upgrade`
3. **SSH** — Installs `openssh-server`; writes `/etc/ssh/sshd_config.d/50-android-terminal.conf` with `Port 10022` and `PasswordAuthentication yes`
4. **Locale** — Installs `locales` and reconfigures only when no UTF-8 locale is active
5. **Desktop Environment** — Installs your selected DE via `tasksel` (KDE, GNOME, XFCE, MATE, Cinnamon, LXQt, LXDE, or GNOME Flashback)
6. **VNC** — Installs `tigervnc-standalone-server` / `tigervnc-common`, prompts for a VNC password, writes `~/.vnc/config` and `/etc/tigervnc/vncserver.users`, enables `tigervncserver@:1.service`
7. **Optional IME** — Offers to install `ibus` + `ibus-pinyin`
8. **Summary** — Prints SSH + VNC connection info, plus the ADB-forward tip for Android Terminal users

## Other Scripts in This Repo

| Script                  | Purpose                                                                                       |
| ----------------------- | --------------------------------------------------------------------------------------------- |
| `android16-terminal.sh` | Main installer — works on Android 16 (Debian 12) and Android 17 (Debian 13)                   |
| `install_software.sh`   | Installs Chromium, VS Code, Clash Verge, Bilibili client; arch- and version-aware             |
| `update_debian13.sh`    | Upgrades a Debian 12 system to Debian 13 (中文); exits cleanly if already on trixie           |
| `update_debian13_EN.sh` | Same upgrade script in English                                                                |
| `auto-start.ps1`        | Windows PowerShell helper: installs ADB + TigerVNC, runs `adb forward`, launches the viewer   |
| `android_chroot_debian12.md` | Reference docs for the chroot-based (non-AVF) Debian deployment via Magisk + BusyBox      |

## Important Notes

1. VNC password setup prompt appears during first execution — remember your credentials
2. Script may require multiple confirmations during execution — follow on-screen instructions
3. Recommended to run in stable network environment for reliable package downloads
4. After configuration, manage VNC service with:
   - Start: `sudo systemctl start tigervncserver@:1.service`
   - Stop: `sudo systemctl stop tigervncserver@:1.service`
   - Check status: `sudo systemctl status tigervncserver@:1.service`
5. **Android Linux Terminal upgrade warning**: Multiple users report the in-place bookworm→trixie upgrade can corrupt the AVF VM image, forcing a wipe-and-reinstall from the Terminal app. If you are on Android 16, prefer staying on Debian 12 until Android 17 ships the official Debian 13 image (Terminal → Reset).

## Contribution & Feedback

We welcome Issues and Pull Requests to improve this project. Please provide detailed error descriptions and reproduction steps when reporting issues.

## License

This project is open-sourced under [MIT License](LICENSE).
