#!/bin/bash
# ============================================================================
# NovaOS — Boot Time Optimization
# ============================================================================
# Configures systemd, GRUB, and other boot parameters for fast startup.
# Target: < 15 seconds boot time on SSD.
# ============================================================================

set -e

echo "[NovaOS] Optimizing boot time..."

# --- Systemd Timeouts ---
# Reduce default service timeout from 90s to 10s
# Hung services will be killed faster instead of blocking boot
mkdir -p /etc/systemd/system.conf.d
cat > /etc/systemd/system.conf.d/novaos-timeouts.conf << 'EOF'
[Manager]
DefaultTimeoutStartSec=10s
DefaultTimeoutStopSec=10s
EOF

# --- GRUB Configuration ---
# Reduce boot menu wait time
if [ -f /etc/default/grub ]; then
    # Set GRUB timeout to 2 seconds
    sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/' /etc/default/grub
    
    # Enable quiet boot with Plymouth splash
    sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/' /etc/default/grub
    
    # Set distributor name
    sed -i 's/^GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR="NovaOS"/' /etc/default/grub
    
    # Update GRUB config
    update-grub 2>/dev/null || true
fi

# --- Journal Size Limit ---
# Limit systemd journal to 50MB (default can grow to hundreds of MB)
mkdir -p /etc/systemd/journald.conf.d
cat > /etc/systemd/journald.conf.d/novaos-size.conf << 'EOF'
[Journal]
SystemMaxUse=50M
RuntimeMaxUse=20M
EOF

echo "[NovaOS] ✅ Boot optimizations applied."
echo "[NovaOS] Analyze boot time with: systemd-analyze"
