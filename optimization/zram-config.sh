#!/bin/bash
# ============================================================================
# NovaOS — ZRAM Configuration
# ============================================================================
# Sets up ZRAM compressed swap for efficient memory usage.
# ZRAM creates a compressed block device in RAM → acts as fast swap.
#
# Benefits:
#   - 500 MB RAM effectively becomes ~750 MB usable
#   - No disk I/O for swap (huge speed gain on HDDs)
#   - lz4 compression is nearly zero CPU overhead
# ============================================================================

set -e

echo "[NovaOS] Configuring ZRAM compressed swap..."

# --- Configure zram-tools ---
cat > /etc/default/zramswap << 'EOF'
# NovaOS ZRAM Configuration
# ZRAM creates compressed swap space in RAM

# Compression algorithm (lz4 = fastest, zstd = best ratio)
ALGO=lz4

# Percentage of total RAM to use for ZRAM
# 50% is a good balance — e.g., 500MB RAM → 250MB ZRAM device
# With ~2.5x compression, this gives ~625MB effective swap
PERCENT=50

# Priority (higher = preferred over disk swap)
PRIORITY=100
EOF

# --- Disable any disk-based swap ---
# We want to use ZRAM only for swap, not slow disk swap
if [ -f /etc/fstab ]; then
    # Comment out any swap lines in fstab
    sed -i '/\sswap\s/s/^/#/' /etc/fstab
fi

# --- Enable the ZRAM service ---
systemctl enable zramswap.service 2>/dev/null || true

echo "[NovaOS] ✅ ZRAM configured: lz4 compression, 50% of RAM"
echo "[NovaOS] Verify after boot with: cat /proc/swaps"
