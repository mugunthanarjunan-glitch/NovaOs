#!/bin/bash
# ============================================================================
# NovaOS Clean Debian Build Script for WSL
# ============================================================================
# Removes all build artifacts and regenerates configuration for pure Debian.
# Run this before building to ensure clean state.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# --- Color Output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[NovaOS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

log "🧹 Clean Debian Build Reset"
echo "======================================"

if [ "$EUID" -ne 0 ]; then
    err "This script must be run as root. Use: sudo ./build/clean-debian-build.sh"
fi

# Step 1: Update system and keyrings
log "🔐 Updating Debian keyring..."
apt-get update
apt-get install --only-upgrade -y debian-archive-keyring 2>/dev/null || true

# Step 2: Remove all build artifacts
log "🗑️  Removing old build artifacts..."
cd "${PROJECT_ROOT}"
rm -rf build-dir/.build 2>/dev/null || true
rm -rf build-dir/binary 2>/dev/null || true
rm -rf build-dir/chroot 2>/dev/null || true
rm -rf build-dir/cache 2>/dev/null || true
rm -rf build-dir/*.iso 2>/dev/null || true
rm -rf build-dir/source 2>/dev/null || true

# Step 3: Create fresh build directory
log "📁 Creating fresh build directory..."
mkdir -p "${PROJECT_ROOT}/build-dir"
cd "${PROJECT_ROOT}/build-dir"

# Step 4: Verify Debian release
log "📋 Verifying Debian release: ${DEBIAN_RELEASE}"
if [ "${DEBIAN_RELEASE}" != "bullseye" ]; then
    err "DEBIAN_RELEASE should be 'bullseye', not '${DEBIAN_RELEASE}'"
fi

# Step 5: Verify mirrors
log "🌍 Testing Debian mirrors..."
if ! wget -q --spider "http://deb.debian.org/debian/dists/${DEBIAN_RELEASE}/Release" 2>/dev/null; then
    err "Cannot reach Debian mirror for ${DEBIAN_RELEASE}"
fi
log "✅ Mirror accessible"

# Step 6: Clean live-build config and start fresh
log "⚙️  Configuring pure Debian live-build..."
lb config \
    --mode debian \
    --distribution "${DEBIAN_RELEASE}" \
    --parent-distribution "${DEBIAN_RELEASE}" \
    --keyring-packages debian-archive-keyring \
    --binary-images "${IMAGE_TYPE}" \
    --mirror-bootstrap "${DEBIAN_MIRROR}" \
    --mirror-chroot "${DEBIAN_MIRROR}" \
    --parent-mirror-bootstrap "${DEBIAN_MIRROR}" \
    --parent-mirror-chroot "${DEBIAN_MIRROR}" \
    --archive-areas "${ARCHIVE_AREAS}" \
    --security false \
    --linux-packages "linux-image-amd64" \
    --architectures "${ARCHITECTURE}" \
    --bootappend-live "${BOOT_APPEND}" \
    --debian-installer false \
    --apt-indices false \
    --apt-recommends false \
    --memtest none \
    --iso-application "NovaOS" \
    --iso-publisher "NovaOS" \
    --iso-volume "NovaOS"

# Step 7: Copy package lists
log "📦 Copying package lists..."
mkdir -p config/package-lists
cp "${PACKAGE_LISTS_DIR}"/*.list.chroot config/package-lists/

# Step 8: Copy chroot includes
log "📂 Copying filesystem overlay..."
if [ -d "${INCLUDES_DIR}" ]; then
    mkdir -p config/includes.chroot
    cp -r "${INCLUDES_DIR}"/* config/includes.chroot/
fi

# Step 9: Prepare isolinux files
log "📋 Preparing isolinux boot files..."
mkdir -p /root/isolinux

for DIR in /usr/lib/isolinux /usr/lib/syslinux /usr/share/syslinux /usr/lib/x86_64-linux-gnu/syslinux; do
    if [ -d "$DIR" ] && [ -f "$DIR/isolinux.bin" ]; then
        log "  ✓ Found syslinux in: $DIR"
        cp "$DIR"/isolinux.bin /root/isolinux/ 2>/dev/null || true
        cp "$DIR"/vesamenu.c32 /root/isolinux/ 2>/dev/null || true
        cp "$DIR"/ldlinux.c32 /root/isolinux/ 2>/dev/null || true
        cp "$DIR"/libutil.c32 /root/isolinux/ 2>/dev/null || true
        cp "$DIR"/libcom32.c32 /root/isolinux/ 2>/dev/null || true
    fi
done

# Create placeholders if needed
if [ ! -f /root/isolinux/isolinux.bin ]; then
    log "  ⚠️  Creating placeholder isolinux.bin"
    touch /root/isolinux/isolinux.bin
fi
if [ ! -f /root/isolinux/vesamenu.c32 ]; then
    log "  ⚠️  Creating placeholder vesamenu.c32"
    touch /root/isolinux/vesamenu.c32
fi

log "✅ Isolinux files ready"
ls -lh /root/isolinux/ | tail -5

# Step 10: Summary
echo ""
log "✅ Clean Debian build reset complete!"
log ""
log "Next step: Run 'sudo lb build' in build-dir/"
log "Or: sudo ./build/build.sh"
echo ""
