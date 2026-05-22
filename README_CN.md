# Android 16 / 17 终端 Debian GUI 访问工具

![Bash](https://img.shields.io/badge/Shell-Bash-green) ![Debian](https://img.shields.io/badge/OS-Debian%2012%20%2F%2013-red) ![Android](https://img.shields.io/badge/Android-16%20%7C%2017-brightgreen) ![VNC](https://img.shields.io/badge/Protocol-VNC-blue)

## 功能简介

本脚本面向 Android 16 (Baklava) 与 Android 17 (Cinnamon Bun) 自带的 **Linux 终端**，在 Debian 12 (bookworm) 与 Debian 13 (trixie) 两种底层镜像下自动选择正确的安装步骤，配置完整的图形桌面与远程 VNC 访问。

配置完成后, 您可以:

1. 在 Android 终端运行本脚本完成配置
2. 在 PC 端执行 `adb forward tcp:5901 tcp:5901` 端口转发
3. 使用任意 VNC 客户端连接 `localhost:5901`

(或者在 Android 16 QPR2 / Android 17 上, 点击终端右上角的 **显示器** 按钮, 直接通过 Wayland + virglrenderer 在 Android 上原生显示 GUI, 无需 VNC。)

## 兼容性矩阵

| 主机                  | 默认 Debian        | 状态 | 说明                                                                                          |
| --------------------- | ------------------ | ---- | --------------------------------------------------------------------------------------------- |
| Android 16 (Baklava)  | Debian 12 (bookworm) | ✅  | 原厂镜像; `android16-terminal.sh` 自动识别 bookworm。                                          |
| Android 16 + 手动升至 13 | Debian 13 (trixie) | ⚠️  | 升级后可用, 但 bookworm→trixie 大版本升级可能破坏 AVF 虚拟机镜像 — 详见 `update_debian13.sh`。 |
| Android 17 (Cinnamon Bun) | Debian 13 (trixie) | ✅  | 原厂镜像; `android16-terminal.sh` 自动识别 trixie。                                            |
| 通用 Debian 12 / 13 (服务器/桌面) | bookworm / trixie | ✅ | 脚本同样适用于普通 Debian 12/13 系统。                                                          |

## 主要特性

- **自动版本识别**: 一份脚本同时覆盖 Debian 12 与 13, 自动选择对应的安装路径
- **一键式配置**: 自动化完成所有必要组件的安装和配置
- **SSH 访问**: 通过 `/etc/ssh/sshd_config.d/` 独立配置文件设置端口为 10022, Debian 12 / 13 均干净支持
- **图形界面支持**: 安装您选择的桌面环境与 TigerVNC 服务器
- **Display 按钮提醒**: 提示 Android 16 QPR2 / Android 17 自带的 Wayland 直显示功能
- **智能检测**: 自动跳过已完成的配置步骤
- **UTF-8 语言环境检测**: 避免重复设置已配置的语言环境
- **详细日志输出**: 中英双语彩色输出

## 使用说明

### 前置条件

- 一台开启了 Linux 终端的 Android 16 或 Android 17 设备
- (或任意带有 sudo 权限的 Debian 12 / 13 系统)

### 安装步骤

1. 将脚本保存到您的 Android 终端设备, 例如保存为 `android16-terminal.sh`
2. 赋予脚本执行权限:
   ```bash
   chmod +x android16-terminal.sh
   ```
3. 运行脚本:
   ```bash
   ./android16-terminal.sh
   ```

### PC 端连接步骤 (VNC)

1. 确保 Android 设备已通过 USB 连接到 PC
2. 在 PC 端执行端口转发:
   ```bash
   adb forward tcp:5901 tcp:5901
   ```
3. 打开 VNC 客户端, 连接地址填写:
   ```
   localhost:5901
   ```
4. 输入您在脚本运行过程中设置的 VNC 密码

Windows 用户可运行 [`auto-start.ps1`](auto-start.ps1) 自动安装 ADB + TigerVNC 并完成连接。

### Android 端直接显示 GUI (无需 VNC, 仅 Android 16 QPR2+ / Android 17)

Android 16 QPR2 与 Android 17 的终端应用新增了 **显示器** 按钮 (右上角), 可通过 Wayland + virglrenderer 在 Android 上原生显示 Linux GUI。启用 GPU 加速:

```bash
# 在 Android 主机, Terminal 应用所属的 Linux 文件夹中:
touch virglrenderer
```

然后点击显示器按钮, 在终端运行 `weston` (或其他桌面) 即可。

## 脚本功能详解

`android16-terminal.sh` 将依次执行:

1. **系统版本检测** — 仅在 Debian 12 (bookworm) 或 Debian 13 (trixie) 上继续, 其余拒绝执行
2. **系统更新** — `apt-get update && apt-get upgrade`
3. **SSH 服务** — 安装 `openssh-server`; 在 `/etc/ssh/sshd_config.d/50-android-terminal.conf` 写入 `Port 10022` 与 `PasswordAuthentication yes`
4. **语言环境** — 安装 `locales`, 仅在未检测到 UTF-8 时才进入交互配置
5. **桌面环境** — 通过 `tasksel` 安装您选择的桌面 (KDE、GNOME、XFCE、MATE、Cinnamon、LXQt、LXDE 或 GNOME Flashback)
6. **VNC 服务器** — 安装 `tigervnc-standalone-server` / `tigervnc-common`, 提示设置 VNC 密码, 写入 `~/.vnc/config` 与 `/etc/tigervnc/vncserver.users`, 启用 `tigervncserver@:1.service`
7. **可选输入法** — 询问是否安装 `ibus` + `ibus-pinyin`
8. **结束摘要** — 输出 SSH + VNC 连接信息, 以及 Android 终端用户的 ADB 端口转发提示

## 仓库内其他脚本

| 脚本                    | 用途                                                                                          |
| ----------------------- | --------------------------------------------------------------------------------------------- |
| `android16-terminal.sh` | 主安装脚本 — 同时支持 Android 16 (Debian 12) 与 Android 17 (Debian 13)                        |
| `install_software.sh`   | 安装 Chromium、VS Code、Clash Verge、Bilibili 客户端; 自动识别架构和 Debian 版本              |
| `update_debian13.sh`    | 将 Debian 12 升级至 Debian 13 (中文); 检测到已经在 trixie 时直接退出                          |
| `update_debian13_EN.sh` | 同上, 英文版本                                                                                |
| `auto-start.ps1`        | Windows PowerShell 助手: 安装 ADB + TigerVNC, 执行 `adb forward`, 启动 VNC Viewer             |
| `android_chroot_debian12.md` | 通过 Magisk + BusyBox 部署 chroot 版 Debian 的参考文档 (与 AVF 终端方案无关)              |

## 注意事项

1. 首次运行 VNC 服务器时会提示设置密码, 请牢记您设置的密码
2. 脚本运行过程中可能需要多次确认操作, 请按照提示操作
3. 建议在稳定的网络环境下运行, 以确保软件包下载顺利
4. 配置完成后, 可通过以下命令管理 VNC 服务:
   - 启动服务: `sudo systemctl start tigervncserver@:1.service`
   - 停止服务: `sudo systemctl stop tigervncserver@:1.service`
   - 查看状态: `sudo systemctl status tigervncserver@:1.service`
5. **Android Linux Terminal 升级警告**: 多名用户报告, 在终端中执行 bookworm→trixie 大版本升级会导致 AVF VM 镜像损坏, 应用提示必须重置后才能再次启动。如您在 Android 16, 建议保持 Debian 12 不变, 等待升级到 Android 17 后通过 "重置 Linux 终端" 获得官方 Debian 13 镜像。

## 贡献与反馈

欢迎提交 Issue 或 Pull Request 来改进本项目。如果您在使用过程中遇到任何问题, 请提供详细的错误描述和重现步骤。

## 许可证

本项目采用 [MIT License](LICENSE) 开源。
