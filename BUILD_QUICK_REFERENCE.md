# NovaOS WSL Build Quick Reference

## 🎯 TL;DR - Build in 3 Commands

```bash
cd ~/NovaOS
sudo ./build/wsl-build-debian.sh
# Wait 10-30 minutes
# ISO ready at: build-dir/live-image-amd64.iso
```

---

## 🔧 Quick Commands

### Full Clean Build
```bash
cd ~/NovaOS
sudo rm -rf build-dir/.build build-dir/binary build-dir/chroot
sudo ./build/clean-debian-build.sh
cd build-dir
sudo lb build
```

### Rebuild (if already configured)
```bash
cd ~/NovaOS/build-dir
sudo lb build
```

### Check Build Status
```bash
# While building in another terminal:
tail -f build-dir/build.log

# Or check progress:
ls -lh build-dir/chroot/
```

### View Build Errors
```bash
# If build failed:
tail -100 build-dir/build.log

# Or full log:
cat build-dir/build.log | grep -i error
```

---

## 📦 Configuration

All settings in: `build/config.sh`

```bash
DEBIAN_RELEASE="bullseye"              # Debian version
DEBIAN_MIRROR="http://deb.debian.org/debian"
ARCHIVE_AREAS="main contrib non-free"
ARCHITECTURE="amd64"
```

---

## 📂 Important Files

| File | Purpose |
|------|---------|
| `build/config.sh` | Build configuration |
| `build/wsl-build-debian.sh` | **Main build script** |
| `build/clean-debian-build.sh` | Clean rebuild from scratch |
| `config/package-lists/*.list.chroot` | Installed packages |
| `config/includes.chroot/` | Filesystem overlay |
| `DEBIAN_BUILD_GUIDE.md` | Full documentation |
| `KERNEL_FIX_GUIDE.md` | Kernel detection fix info |

---

## 📋 Build Stages (What Happens)

1. **bootstrap** (2-5 min) - Download Debian base system
2. **chroot** (5-10 min) - Install packages
3. **linux-image** (1-2 min) - Install kernel (fixed!)
4. **binary** (2-5 min) - Create ISO filesystem
5. **manifest** (1 min) - Finalize ISO

**Total: 10-30 minutes**

---

## ✨ What's Inside

| Component | What |
|-----------|------|
| Desktop | XFCE 4 |
| Login Manager | LightDM |
| Browser | Firefox ESR |
| Terminal | XFCE4 Terminal |
| Editor | Mousepad |
| File Manager | Thunar |
| System Tools | git, neofetch, htop |
| Base | Debian Bullseye |

---

## 🧪 Test ISO

### VirtualBox
```bash
# 1. Create VM (Linux, Debian 64-bit, 2GB RAM, 20GB disk)
# 2. Mount ISO as CD-ROM
# 3. Boot, select "Live"
# 4. Should see XFCE desktop
```

### Write to USB
```bash
# From WSL (or Linux):
sudo dd if=build-dir/live-image-amd64.iso of=/dev/sdX bs=4M status=progress && sync

# ⚠️ Replace /dev/sdX with your USB device!
# Find it: sudo lsblk
```

---

## 🐛 Common Issues

### Build fails with "404 Not Found Contents-amd64.gz"
**Status**: ✅ FIXED in wsl-build-debian.sh

The old `--linux-packages` parameter has been replaced with `--linux-flavours amd64`.

See: `KERNEL_FIX_GUIDE.md`

### WSL says "not enough disk space"
```bash
# Check available space:
df -h /mnt/c/

# Or use Windows disk cleanup
```

### Build hangs during "lb_bootstrap"
```bash
# WSL memory issue - restart WSL:
wsl --shutdown
wsl

# Then retry build
```

### "Permission denied" errors
```bash
# Make scripts executable:
chmod +x build/*.sh
sudo ./build/wsl-build-debian.sh
```

---

## 📊 File Structure

```
NovaOS/
├── build/
│   ├── config.sh                    # Configuration
│   ├── build.sh                     # Main build script
│   ├── wsl-build-debian.sh          # ✨ WSL recommended
│   ├── clean-debian-build.sh        # Clean rebuild
│   └── build-wsl2.sh                # Legacy
├── config/
│   ├── package-lists/               # Package installation
│   │   ├── base.list.chroot         # Core packages
│   │   ├── desktop.list.chroot      # XFCE, LightDM
│   │   └── apps.list.chroot         # Firefox, etc
│   ├── includes.chroot/             # Files to add to ISO
│   └── hooks/                       # Customization scripts
├── build-dir/                       # BUILD OUTPUT
│   ├── .build/                      # live-build config
│   ├── chroot/                      # Build environment
│   └── live-image-amd64.iso         # 📀 YOUR ISO!
├── DEBIAN_BUILD_GUIDE.md            # Full guide
├── KERNEL_FIX_GUIDE.md              # Kernel fix info
└── README.md                        # Project info
```

---

## 🎓 Learning Path

1. **First time?**
   - Read: `DEBIAN_BUILD_GUIDE.md`
   - Run: `sudo ./build/wsl-build-debian.sh`

2. **Build failed?**
   - Check: Last 50 lines of `build-dir/build.log`
   - See: `KERNEL_FIX_GUIDE.md` if kernel error
   - Run: `sudo ./build/clean-debian-build.sh`

3. **Want to customize?**
   - Edit: `config/package-lists/apps.list.chroot`
   - Add packages one per line
   - Run: `sudo ./build/wsl-build-debian.sh`

4. **Want to theme?**
   - Edit: `config/includes.chroot/` files
   - Add: Theme files to `themes/` directory
   - Run: `sudo ./build/wsl-build-debian.sh`

---

## ⚡ Performance Tips

### Speed up build:
- Increase WSL memory if possible
- Use SSD (faster than HDD)
- Close other apps to free RAM
- Run build in morning (less network congestion)

### Cache packages:
- First build downloads all packages (slow)
- Second build uses cache (fast)
- Cache in: `build-dir/cache/`

---

## 📞 Need Help?

1. **Build fails**: Check `build-dir/build.log`
2. **Kernel error**: Read `KERNEL_FIX_GUIDE.md`
3. **ISO won't boot**: Try VirtualBox test first
4. **Package missing**: Check Debian Bullseye repos

---

**Happy building! 🚀**

Last updated: 2026-05-16
Build system: Pure Debian Bullseye + live-build
