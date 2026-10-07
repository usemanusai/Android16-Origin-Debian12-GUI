# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please **do not** open a public GitHub issue.

Instead, please email security concerns directly to the project maintainer via GitHub's security advisory feature:
- Visit: https://github.com/usemanusai/Android16-Origin-Debian12-GUI/security/advisories
- Click "Report a vulnerability"
- Provide detailed information about the security issue

## Security Practices

### SSH Configuration
- SSH server listens on a non-standard port (10022) by default
- Uses `/etc/ssh/sshd_config.d/` drop-in files for safer configuration management
- Enforces password authentication; consider using SSH keys for production environments

### VNC Security
- VNC password protection is required during setup
- Recommend using SSH tunneling or firewall rules to restrict VNC access
- On Android Terminal, use `adb forward` for secure port forwarding

### System Updates
- Scripts automatically run `apt-get update && apt-get upgrade` to patch security vulnerabilities
- Ensure your system is connected to a stable network during installation
- Review package changes before confirming prompts during execution

### Best Practices for Users

1. **Regular Updates**: Keep your Debian system patched by running `sudo apt update && sudo apt upgrade` regularly
2. **SSH Key Authentication**: Consider replacing password authentication with SSH keys:
   ```bash
   ssh-keygen -t ed25519
   ssh-copy-id -p 10022 user@host
   ```
3. **Firewall Rules**: Restrict SSH and VNC access to trusted networks
4. **Audit Logs**: Review `/var/log/auth.log` for unauthorized access attempts
5. **Desktop Security**: Use appropriate security settings within your chosen desktop environment

## Supported Versions

Security updates are provided for:
- **Current Major Version**: Full support and security patches
- **Previous Major Version**: Security patches only (limited window)
- **Older Versions**: No active support; users are encouraged to upgrade

As of October 2026:
- ✅ Debian 12 (bookworm) - Full support
- ✅ Debian 13 (trixie) - Full support
- ⏳ Debian 14+ - Tested for compatibility

## Dependencies Security

This project relies on maintained Debian packages:
- `openssh-server` - OpenSSH suite
- `tigervnc-standalone-server` - TigerVNC server
- `tasksel` - Task selection tool
- `locales` - Locale support
- Desktop environment packages (via tasksel)

All dependencies are pulled from official Debian repositories and should be regularly updated via `apt`.

## Additional Resources

- [Debian Security Information](https://www.debian.org/security/)
- [OpenSSH Secure Configuration](https://man.openbsd.org/sshd_config)
- [TigerVNC Documentation](https://tigervnc.org/)
- [Android Terminal Security](https://developer.android.com/guide/topics/security)

---

**Last Updated**: October 7, 2026
