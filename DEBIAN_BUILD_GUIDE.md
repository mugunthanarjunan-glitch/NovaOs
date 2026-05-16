# NovaOS Debian Build Instructions

## ✅ What Changed

NovaOS has been converted to a **pure Debian-based distribution**:

- **Base Distribution**: Debian Bullseye (Stable)
- **Mode**: Pure Debian (no Ubuntu dependencies)
- **Mirrors**: Only `http://deb.debian.org/debian/`
- **Archive Areas**: `main contrib non-free`
- **Desktop**: XFCE 4
- **Display Manager**: LightDM
- **Browser**: Firefox ESR
- **Included Tools**: git, neofetch, thunar, mousepad, xfce4-terminal

## 🚀 Building in WSL (Windows)

### Prerequisites
- WSL2 with Debian or Ubuntu installed
- At least 2GB RAM allocated to WSL
- 20GB free disk space
- `sudo` access (no password prompt)

### Step 1: Open WSL Terminal

```bash
# From Windows PowerShell or WSL terminal
wsl
```

### Step 2: Navigate to NovaOS

```bash
cd /mnt/d/NovaOS  # or wherever you cloned it
# Or if cloned to home:
cd ~/NovaOS
```

### Step 3: Clean Old Build Cache (First Time Only)

```bash
sudo rm -rf build-dir/.build
sudo rm -rf build-dir/binary
sudo rm -rf build-dir/chroot
sudo rm -rf build-dir/cache
sudo rm -rf build-dir/*.iso
```

### Step 4: Build the ISO

**Option A: Full clean build**
```bash
sudo ./build/clean-debian-build.sh
# Then in build-dir:
sudo lb build
```

**Option B: Quick rebuild (if already configured)**
```bash
cd build-dir
sudo lb build
```

**Option C: Automated WSL build (recommended)**
```bash
sudo ./build/wsl-build-debian.sh
```

## 📊 Build Output

When successful, you'll see:
```
[2026-05-16 23:00:00] lb_build
[2026-05-16 23:00:05] lb_bootstrap
[2026-05-16 23:05:00] lb_chroot_linux-image
  ✅ Installing linux-image-amd64...
...
P: Begin creating ISO file...
P: Done with ISO file.
...
[NovaOS] ✅ Build successful!
[NovaOS] 📀 ISO: /path/to/build-dir/live-image-amd64.iso
[NovaOS] 📊 Size: 1.2 GB
```

### Kernel Installation (Fixed)
- Uses `--linux-flavours amd64` (not deprecated `--linux-packages`)
- No more `404 Not Found` for `Contents-amd64.gz`
- Kernel installs cleanly: `linux-image-amd64`
- See **KERNEL_FIX_GUIDE.md** for technical details

## 🔧 Configuration Files

All settings are in `build/config.sh`:

```bash
DEBIAN_RELEASE="bullseye"              # Debian version
DEBIAN_MIRROR="http://deb.debian.org/debian"
ARCHIVE_AREAS="main contrib non-free"
ARCHITECTURE="amd64"
```

## 📦 Package Lists

Located in `config/package-lists/`:

- **base.list.chroot**: Core system packages (live-boot, systemd, grub, etc.)
- **desktop.list.chroot**: XFCE, LightDM, plugins, fonts, audio
- **apps.list.chroot**: Firefox ESR, Thunar, Mousepad, git, neofetch
- **support.list.chroot**: Additional support packages

## ✨ Key Features

✅ **Pure Debian Bullseye** - No Ubuntu libraries  
✅ **XFCE 4** - Lightweight desktop environment  
✅ **LightDM** - Fast login manager  
✅ **Firefox ESR** - Stable web browser  
✅ **Modern Tools** - Git, Neofetch included  
✅ **Lightweight** - Designed for minimal resource usage  
✅ **Beginner-Friendly** - Simple, clean interface  

## 🐛 Troubleshooting

### Build fails with "E: Release signed by unknown key"
→ Run: `sudo apt-get install --only-upgrade debian-archive-keyring`
→ Clean build: `sudo rm -rf build-dir/.build`

### "E: Package 'X' not found"
→ Package not available in Bullseye
→ Check: `apt-cache search X` on your system
→ Or use alternative from `config/package-lists/`

### Build hangs or times out
→ WSL may need more RAM
→ Check: `free -h` in WSL
→ Or skip this build and retry

## 🧪 Testing the ISO

### In VirtualBox:
1. Create new VM (Linux, Debian 64-bit)
2. Allocate 2GB RAM, 20GB disk
3. Mount ISO as CD-ROM
4. Boot and select "Live" option
5. Should boot to XFCE desktop

### Write to USB (from Linux/WSL):
```bash
# Warning: This will overwrite the USB device!
sudo dd if=build-dir/live-image-amd64.iso of=/dev/sdX bs=4M status=progress && sync
```

## 📚 Documentation

- **docs/BUILD.md** - Detailed build process
- **docs/VIRTUALBOX_TESTING.md** - VirtualBox setup guide
- **docs/OPTIMIZATION.md** - Performance tuning

## 🎨 Customization

### Add Packages
Edit `config/package-lists/apps.list.chroot` and add package names, one per line.

### Modify Themes
Customize in `themes/` directory and `config/hooks/`.

### Change Desktop Settings
Edit files in `config/includes.chroot/` to set default configs.

## 📞 Support

If build fails:
1. Check build log: `cat build-dir/build.log | tail -50`
2. Verify Debian mirrors: `wget -q --spider http://deb.debian.org/debian/dists/bullseye/Release`
3. Ensure keyring is updated: `sudo apt install --only-upgrade debian-archive-keyring`

---

**Happy building! 🎉**
