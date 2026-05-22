# ============================================================================
#  Android 16 / 17 Linux Terminal - PC 端 VNC 自动连接脚本
#  Android 16 / 17 Linux Terminal - PC-side VNC auto-connect helper
#
#  适用 / Works with:
#    - Windows 10/11 (PowerShell 5.1+ 或 PowerShell 7+)
#    - Android 16 (Baklava) Linux Terminal + Debian 12
#    - Android 17 (Cinnamon Bun) Linux Terminal + Debian 13
#  脚本与 Android 主版本无关, 它只负责 PC 上的 ADB 端口转发 + VNC 客户端启动。
#  This script is independent of the Android version - it only handles ADB
#  port-forwarding and the VNC client on the PC side.
# ============================================================================

# 1. 安装 ADB 和平台工具 / Install ADB & Android platform-tools
Write-Host "Installing Android platform-tools (ADB)..."
winget install --id Google.PlatformTools --source winget --accept-package-agreements --accept-source-agreements

# 2. ADB 端口转发 / ADB port forwarding (host:5901 -> guest:5901)
Write-Host "Forwarding TCP 5901 via ADB..."
# 执行 ADB 转发前, 请确保设备已通过 USB 连接并启用 USB 调试模式。
# Before forwarding, ensure your device is connected via USB and USB debugging is enabled.
# 该脚本假设 ADB 已经能正常工作; 如未授权, 请先手动运行 `adb devices`。
# This script assumes ADB is already working; if not, run `adb devices` first to authorize.
# 原生命令失败不会抛出异常, 必须显式检查 $LASTEXITCODE / Native commands don't throw - check $LASTEXITCODE explicitly.
adb forward tcp:5901 tcp:5901
if ($LASTEXITCODE -eq 0) {
    Write-Host "Port forward OK: localhost:5901 -> device:5901"
} else {
    Write-Error "ADB port-forwarding failed (exit code $LASTEXITCODE). Ensure ADB is on PATH, device is connected & authorized."
    # 端口转发失败时可选择退出 / Uncomment to exit on failure:
    # exit 1
}

# 3. 安装 TigerVNC Viewer / Install TigerVNC Viewer
Write-Host "Installing TigerVNC Viewer..."
winget install --id TigerVNC.TigerVNC --source winget --accept-package-agreements --accept-source-agreements

# 4. 将 TigerVNC 目录加入 PATH (仅当前会话生效) / Add TigerVNC to PATH (current session only)
$env:Path += ";C:\Program Files\TigerVNC\"

# 5. 启动 VNC Viewer / Launch VNC Viewer
Write-Host "Launching VNC Viewer..."
# 启动前请确认设备上的 VNC 服务器已运行 (端口 5901)。
# Confirm the VNC server is running on port 5901 on the device before continuing.
# 提示: Android 16 QPR2 / Android 17 自带「显示器」按钮, 可在 Android 上直接显示 GUI,
# 无需 VNC; 但 VNC 仍是更稳定的远程方案。
# Tip: Android 16 QPR2 / Android 17 expose a 'Display' button that renders the GUI
# natively on Android (no VNC), but VNC remains the more reliable remote option.
Read-Host "Make sure the VNC server is running on your device, then press Enter to launch VNC Viewer"
vncviewer.exe 127.0.0.1::5901

Write-Host "Done. / 脚本执行完毕。"
