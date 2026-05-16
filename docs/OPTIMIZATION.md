# ⚡ NovaOS Optimization Guide

This document explains every optimization applied to NovaOS and why.

---

## Memory (RAM) Optimization

### ZRAM — Compressed Swap in RAM

**What:** Creates a compressed block device in RAM as swap space.

**Config (`/etc/default/zramswap`):**
```ini
ALGO=lz4           # Fastest compression
PERCENT=50          # Use 50% of RAM as compressed swap
PRIORITY=100        # Higher priority than disk swap
```

**Verify:** `cat /proc/swaps` and `swapon --show`

### Kernel Tuning (`/etc/sysctl.d/99-novaos-performance.conf`)

```ini
vm.swappiness = 10              # Prefer RAM over swap (default: 60)
vm.vfs_cache_pressure = 50      # Keep filesystem caches longer
vm.dirty_ratio = 10             # Faster dirty page writebacks
vm.dirty_background_ratio = 5
net.ipv6.conf.all.disable_ipv6 = 1  # Save RAM, faster DNS
```

---

## Disabled Services

| Service | RAM Saved | Why |
|---------|-----------|-----|
| `cups.service` | ~15 MB | Printer support — re-enable if needed |
| `cups-browsed.service` | ~10 MB | Printer auto-discovery |
| `ModemManager.service` | ~10 MB | Mobile broadband modems |
| `avahi-daemon.service` | ~5 MB | mDNS network discovery |
| `bluetooth.service` | ~8 MB | Bluetooth — easy to re-enable |
| `accounts-daemon.service` | ~8 MB | Not needed with LightDM |
| `rsyslog.service` | ~5 MB | journald is sufficient |
| `cron.service` | ~2 MB | Desktop users rarely need cron |

**Total saved: ~65 MB**

Re-enable any service: `sudo systemctl enable --now bluetooth.service`

---

## Boot Time Optimization

- Systemd timeout: 10s (from 90s default)
- GRUB timeout: 2s
- Disabled `NetworkManager-wait-online.service` (saves 10-30s)
- Plymouth `quiet splash` for clean boot

**Analyze:** `systemd-analyze`, `systemd-analyze blame`

---

## RAM Usage Breakdown (Expected Idle)

| Component | RAM |
|-----------|-----|
| Linux kernel | ~30 MB |
| systemd + journald | ~15 MB |
| Xorg | ~25 MB |
| XFCE desktop | ~40 MB |
| Picom compositor | ~5 MB |
| NetworkManager | ~10 MB |
| PulseAudio | ~8 MB |
| LightDM | ~10 MB |
| Buffers/cache | ~50 MB |
| **Total** | **~193 MB** |

---

## Further Optimization Options

1. Replace XFCE with Openbox — saves ~20 MB
2. Replace PulseAudio with ALSA — saves ~8 MB
3. Custom stripped kernel — saves ~10-15 MB
4. Remove GNOME Software — saves ~30 MB when running
5. Switch to Wayland (Wayfire) — potentially lighter than X11
