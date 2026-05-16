<![CDATA[# 🧪 VirtualBox Testing Guide

This guide explains how to test your NovaOS ISO in VirtualBox step by step.

---

## 1. Install VirtualBox

Download from: https://www.virtualbox.org/wiki/Downloads

- Windows: Run the `.exe` installer
- Linux: `sudo apt install virtualbox`
- macOS: Run the `.dmg` installer

---

## 2. Create a New Virtual Machine

### Step-by-Step VM Creation

1. Open VirtualBox → Click **"New"**

2. **Name and Operating System:**
   - Name: `NovaOS-Test`
   - Folder: (default is fine)
   - Type: `Linux`
   - Version: `Debian (64-bit)`

3. **Memory (RAM):**
   - Set to **512 MB** (to test minimum requirements)
   - For comfortable testing, use **1024 MB**
   - We want to verify NovaOS works at 512 MB

4. **Hard Disk:**
   - Select "Create a virtual hard disk now"
   - Disk type: **VDI** (VirtualBox Disk Image)
   - Storage: **Dynamically allocated**
   - Size: **15 GB** (minimum 8 GB)

5. Click **Create**

### Configure VM Settings

After creating the VM, select it and click **Settings**:

#### System Tab
- **Motherboard:**
  - Boot Order: Optical → Hard Disk (uncheck Floppy)
  - Enable **EFI** if testing EFI boot (optional, test both)
  - Chipset: PIIX3 (default)
  - Enable **PAE/NX** ✓
- **Processor:**
  - CPUs: 1 (to test minimum)
  - Enable **PAE/NX** ✓

#### Display Tab
- Video Memory: **64 MB**
- Graphics Controller: **VMSVGA**
- Enable 3D Acceleration: Optional (can test with/without)

#### Storage Tab
- Click the **Empty** disk under Controller: IDE
- Click the disk icon on the right → **Choose a disk file**
- Navigate to your `live-image-amd64.hybrid.iso`
- Click **OK**

#### Network Tab
- Adapter 1: **NAT** (allows internet access)
- Advanced → Adapter Type: Intel PRO/1000

---

## 3. Boot the ISO

1. Select your `NovaOS-Test` VM
2. Click **Start**
3. You should see:
   - GRUB boot menu → Select "NovaOS Live"
   - Plymouth boot splash (NovaOS logo animation)
   - LightDM login screen
   - Auto-login to XFCE desktop (in live mode)

### If Boot Fails

**Black screen after GRUB:**
- Try pressing `Esc` during boot to see text output
- At GRUB, press `e` to edit boot entry
- Add `nomodeset` to the linux line, then press `Ctrl+X`

**Kernel panic:**
- This usually means a build error — check the build log
- Verify `linux-image-amd64` is in your package list

**Drops to shell (initramfs prompt):**
- The live-boot package may be missing
- Rebuild with `live-boot` in your package list

---

## 4. Test the Live Session

Once you're on the desktop, test these things:

### Desktop Environment
- [ ] XFCE desktop loads with correct theme (Orchis Dark)
- [ ] Top panel visible with Whisker Menu, system tray, clock
- [ ] Wallpaper displays correctly
- [ ] Right-click desktop shows context menu

### Default Applications
- [ ] Click Whisker Menu → apps are listed
- [ ] Open Falkon browser → loads a webpage
- [ ] Open Thunar file manager → navigates correctly
- [ ] Open XFCE Terminal → type `echo hello`
- [ ] Open Mousepad text editor → type and save
- [ ] Open Settings Manager → themes/display settings visible

### System Checks
```bash
# Check RAM usage (target: ~200 MB or less idle)
free -h

# Detailed process memory usage
htop

# System info
neofetch

# Boot time
systemd-analyze

# ZRAM status
cat /proc/swaps
swapon --show

# Check running services
systemctl list-units --type=service --state=running
```

---

## 5. Test Installation (Calamares)

1. **Launch Installer:**
   - Double-click "Install NovaOS" on the desktop
   - Or: Whisker Menu → System → Install NovaOS

2. **Walk Through Steps:**
   - **Welcome:** Language selection
   - **Location:** Timezone selection
   - **Keyboard:** Layout selection
   - **Partitioning:** Select "Erase disk" (it's a VM, safe to do)
   - **Users:** Create username and password
   - **Summary:** Review and click "Install"

3. **Wait for Installation** (~5-10 minutes in VM)
   - Watch the slideshow
   - Installation copies files and configures the system

4. **Finish:**
   - Click "Restart Now"
   - When prompted, VirtualBox may ask to remove the ISO
   - Or: Go to VM Settings → Storage → Remove the ISO

---

## 6. Test the Installed System

After reboot from the installed disk:

1. **GRUB** should appear with "NovaOS" entry
2. **Plymouth** boot splash should show
3. **LightDM** login screen should appear
4. Log in with the credentials you created

### Post-Install Checks
```bash
# Verify we're running from disk (not live)
mount | grep "on / "
# Should show /dev/sda1 or similar, NOT tmpfs

# Check RAM (should be similar to live session)
free -h

# Verify Flatpak works
flatpak list
flatpak remote-list

# Test AppImage support
# Download any AppImage, make executable, and run:
# chmod +x SomeApp.AppImage && ./SomeApp.AppImage

# Check Wine
wine --version

# Verify ZRAM
cat /proc/swaps

# Check boot time
systemd-analyze
systemd-analyze blame  # Shows slowest services
```

---

## 7. Measure RAM Usage

### Quick Check
```bash
free -h
```

Expected output on 512 MB VM:
```
              total        used        free    shared  buff/cache   available
Mem:          476Mi       180Mi       120Mi      12Mi       176Mi       280Mi
Swap:         238Mi         0Mi       238Mi
```

**Key metric:** The `used` column under `Mem` should be ≤ 200 MB.

### Detailed Breakdown
```bash
# Top memory consumers
ps aux --sort=-%mem | head -20

# Memory by service
systemd-cgtop -m --depth=1

# /proc/meminfo for detailed kernel stats
cat /proc/meminfo
```

---

## 8. Debug Boot Problems

### Check Boot Logs
```bash
# Full boot log
journalctl -b

# Only errors
journalctl -b -p err

# Kernel messages
dmesg | tail -50

# GRUB config
cat /boot/grub/grub.cfg

# Systemd boot analysis
systemd-analyze blame
systemd-analyze critical-chain
```

### Common Issues and Fixes

| Problem | Cause | Fix |
|---------|-------|-----|
| Black screen | GPU driver issue | Add `nomodeset` to GRUB |
| No network | Missing firmware | Add `firmware-linux` package |
| Slow boot | Waiting for network | Disable `NetworkManager-wait-online` |
| No sound | PulseAudio not starting | Check `pulseaudio --check` |
| Screen resolution stuck | VBox additions missing | Install Guest Additions |

### Install VirtualBox Guest Additions (Optional)

For better performance in VirtualBox:
```bash
sudo apt install virtualbox-guest-x11 virtualbox-guest-utils
sudo reboot
```

This enables:
- Auto screen resize
- Shared clipboard
- Better graphics performance
- Shared folders

---

## Performance Benchmarks

After testing, record these metrics:

| Metric | Target | Your Result |
|--------|--------|-------------|
| Idle RAM | ≤ 200 MB | ___ MB |
| Boot time | ≤ 15 sec | ___ sec |
| ISO size | ≤ 1.5 GB | ___ GB |
| Disk usage (installed) | ≤ 4 GB | ___ GB |
| Running services (idle) | ≤ 20 | ___ |
]]>
