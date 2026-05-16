<![CDATA[# 🚀 NovaOS — Lightweight Modern Linux

<p align="center">
  <strong>A beginner-friendly, ultra-lightweight Linux distribution built on Debian</strong><br>
  Modern UI • 200MB Idle RAM • Fast Boot • Full App Support
</p>

---

## ✨ Features

| Feature | Details |
|---------|---------|
| **Ultra-Lightweight** | Idles at ~200 MB RAM, runs on 500 MB minimum |
| **Modern UI** | XFCE desktop with Orchis Dark theme, Papirus icons, smooth compositing |
| **Fast Boot** | Optimized systemd services, ZRAM, kernel tuning |
| **Beginner-Friendly** | Ubuntu-like usability, Calamares graphical installer |
| **App Support** | APT, Flatpak, AppImage, Wine (Windows apps) |
| **Stable Base** | Built on Debian Bookworm (Stable) |
| **Beautiful** | Custom boot splash, modern login screen, curated wallpapers |

## 🖥️ System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **RAM** | 500 MB | 1 GB+ |
| **CPU** | x86_64 (any) | Dual-core 1 GHz+ |
| **Disk** | 8 GB | 20 GB+ |
| **GPU** | Any (VESA fallback) | Intel/AMD with drivers |

## 📦 Default Applications

| Category | Application |
|----------|-------------|
| Browser | Falkon |
| File Manager | Thunar |
| Terminal | XFCE4 Terminal |
| Text Editor | Mousepad |
| Media Player | MPV / Parole |
| Image Viewer | Ristretto |
| App Store | GNOME Software (Flatpak) |
| Archive Manager | Engrampa |
| Task Manager | XFCE4 Task Manager |
| Network | NetworkManager |

## 🏗️ Project Structure

```
NovaOS/
├── build/              # ISO build scripts
├── config/             # live-build configuration
│   ├── package-lists/  # What packages to include
│   ├── includes.chroot/# Files to overlay on the filesystem
│   └── hooks/          # Build-time customization scripts
├── themes/             # Visual theming assets
├── optimization/       # Performance tuning scripts
├── installer/          # Calamares installer config
└── docs/               # Documentation
```

## 🚀 Quick Start

> **Note:** Building NovaOS requires a **Debian/Ubuntu Linux** host system.
> If you're on Windows, use WSL2 or a VirtualBox Debian VM.

### 1. Set Up Build Environment

```bash
# On a Debian/Ubuntu system:
sudo apt update
sudo apt install -y live-build debootstrap git
```

### 2. Clone and Build

```bash
git clone <your-repo-url> NovaOS
cd NovaOS
chmod +x build/*.sh
sudo ./build/build.sh
```

### 3. Test in VirtualBox

See [docs/VIRTUALBOX_TESTING.md](docs/VIRTUALBOX_TESTING.md) for the complete guide.

## 📖 Documentation

### Quick Start
- **[BUILD_QUICK_REFERENCE.md](BUILD_QUICK_REFERENCE.md)** — TL;DR build commands
- **[DEBIAN_BUILD_GUIDE.md](DEBIAN_BUILD_GUIDE.md)** — Complete Debian build instructions
- **[KERNEL_FIX_SUMMARY.md](KERNEL_FIX_SUMMARY.md)** — Kernel detection fix details

### Detailed Guides
- **[docs/BUILD.md](docs/BUILD.md)** — Detailed build process
- **[docs/VIRTUALBOX_TESTING.md](docs/VIRTUALBOX_TESTING.md)** — VirtualBox testing guide
- **[docs/OPTIMIZATION.md](docs/OPTIMIZATION.md)** — Performance optimization details
- **[docs/ROADMAP.md](docs/ROADMAP.md)** — Future development plans

### Technical
- **[KERNEL_FIX_GUIDE.md](KERNEL_FIX_GUIDE.md)** — Technical kernel details

## 🛠️ Technology Stack

- **Base:** Debian Bookworm (Stable) Minimal
- **Kernel:** Linux (Debian stock)
- **Desktop:** XFCE 4.18
- **Display Server:** X11
- **Compositor:** Picom
- **Installer:** Calamares
- **Package Manager:** APT
- **Build Tool:** live-build

## 📄 License

This project is open source. Individual components retain their original licenses
(Linux kernel: GPLv2, XFCE: GPLv2, Debian packages: various open-source licenses).

---

<p align="center">
  <em>Made with ❤️ for users who deserve a fast, beautiful, and simple Linux experience.</em>
</p>
]]>
