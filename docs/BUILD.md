<![CDATA[# 🏗️ NovaOS Build Guide

This guide walks you through building a NovaOS ISO from scratch.
Every step is explained in plain English.

---

## Prerequisites

### You Need a Linux Host

Building a Linux ISO **requires** a Linux system. If you're on Windows:

| Option | Difficulty | Reliability |
|--------|-----------|-------------|
| **VirtualBox Debian VM** | Easy | ⭐⭐⭐ Best |
| **WSL2 (Debian)** | Easy | ⭐⭐ Good (some quirks) |
| **Cloud VM (AWS/GCP)** | Medium | ⭐⭐⭐ Best |

**Recommended:** Install Debian Bookworm in VirtualBox with:
- 4 GB RAM
- 30 GB disk (the build needs space)
- Network access (NAT mode)

### Required Build Tools

```bash
# Update package lists
sudo apt update

# Install the build system
sudo apt install -y \
    live-build \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-efi-amd64-bin \
    grub-pc-bin \
    mtools \
    dosfstools \
    wget \
    curl \
    git \
    ca-certificates
```

**What each tool does:**
- `live-build` — The main tool that assembles our ISO
- `debootstrap` — Downloads and installs Debian base packages
- `squashfs-tools` — Creates the compressed filesystem
- `xorriso` — Creates the ISO image file
- `grub-*` — Bootloader for BIOS and EFI systems
- `mtools`, `dosfstools` — Handle FAT filesystems (needed for EFI boot)

---

## Step-by-Step Build

### Step 1: Get the Source Code

```bash
# Clone the NovaOS repository
git clone <your-repo-url> ~/NovaOS
cd ~/NovaOS

# Or if you already have it, copy it to your Linux host
```

### Step 2: Make Scripts Executable

```bash
chmod +x build/*.sh
chmod +x optimization/*.sh
chmod +x config/hooks/normal/*.hook.chroot
```

### Step 3: Build the ISO

```bash
# Run the master build script (needs root for chroot operations)
sudo ./build/build.sh
```

**What happens during the build:**

1. **Configuration** (~5 seconds)
   - `lb config` sets up the build directory structure
   - Package lists, hooks, and includes are copied

2. **Bootstrap** (~2-5 minutes)
   - `debootstrap` downloads the minimal Debian base
   - Creates a minimal root filesystem

3. **Chroot** (~10-30 minutes, depends on internet)
   - Enters the root filesystem (chroot)
   - Installs all packages from our lists (XFCE, apps, etc.)
   - Runs our hook scripts (themes, optimization, etc.)
   - This is the longest step — it downloads ~500-800 MB

4. **Binary** (~2-5 minutes)
   - Creates the squashfs compressed filesystem
   - Sets up GRUB bootloader
   - Assembles the final ISO image

5. **Done!**
   - Output: `build-dir/live-image-amd64.hybrid.iso`
   - Size: approximately 1.0-1.5 GB

### Step 4: Verify the ISO

```bash
# Check the ISO exists and its size
ls -lh build-dir/live-image-amd64.hybrid.iso

# Verify it's a valid ISO
file build-dir/live-image-amd64.hybrid.iso
# Should say: "ISO 9660 CD-ROM filesystem data"
```

---

## Troubleshooting

### Build Fails During Bootstrap

```
Error: "debootstrap failed"
```

**Fix:** Check your internet connection and DNS:
```bash
ping -c 3 deb.debian.org
```

If DNS isn't working:
```bash
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

### Build Fails During Chroot (Package Install)

```
Error: "E: Unable to locate package ..."
```

**Fix:** Make sure you have the correct archive areas:
```bash
# Check that config.sh has:
ARCHIVE_AREAS="main contrib non-free non-free-firmware"
```

### Build Fails With "lb build already in progress"

```bash
# Clean everything and start over
sudo ./build/clean.sh
sudo ./build/build.sh
```

### Out of Disk Space

The build needs at least 10 GB free:
```bash
df -h .
```

### Permission Denied Errors

Always run the build with `sudo`:
```bash
sudo ./build/build.sh
```

---

## Rebuilding After Changes

If you modify any config files and want to rebuild:

```bash
# Quick rebuild (keeps cached downloads)
cd ~/NovaOS
sudo lb clean --chroot
sudo ./build/build.sh

# Full rebuild (from scratch)
sudo ./build/clean.sh
sudo ./build/build.sh
```

---

## Build Output

After a successful build, you'll find:

| File | Description |
|------|-------------|
| `build-dir/live-image-amd64.hybrid.iso` | The bootable ISO |
| `build-dir/build.log` | Complete build log |
| `build-dir/chroot/` | The extracted filesystem (can inspect) |

---

## Next Steps

1. **Test it:** Follow [VIRTUALBOX_TESTING.md](VIRTUALBOX_TESTING.md)
2. **Customize:** Edit package lists and rebuild
3. **Distribute:** Upload the ISO for others to download
]]>
