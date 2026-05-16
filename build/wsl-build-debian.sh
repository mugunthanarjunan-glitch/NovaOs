#!/bin/bash
# ============================================================================
# NovaOS WSL Debian Build Wrapper
# ============================================================================
# Simplified build script for WSL that builds in the build-dir directory.
# Usage: sudo ./build/wsl-build-debian.sh
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
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

# === PRE-FLIGHT CHECKS ===
log "🚀 NovaOS WSL Debian Build"
echo "======================================"

if [ "$EUID" -ne 0 ]; then
    err "This script must be run as root. Use: sudo ./build/wsl-build-debian.sh"
fi

if ! command -v lb &> /dev/null; then
    err "live-build is not installed. Run: sudo apt install live-build"
fi

if ! command -v debootstrap &> /dev/null; then
    err "debootstrap is not installed. Run: sudo apt install debootstrap"
fi

# Update Debian keyring
log "🔐 Updating Debian keyring..."
apt-get update
apt-get install --only-upgrade -y debian-archive-keyring 2>/dev/null || true

# === BUILD DIRECTORY ===
log "📁 Setting up build directory..."
mkdir -p "${PROJECT_ROOT}/build-dir"
cd "${PROJECT_ROOT}/build-dir"

# CRITICAL: Always force clean before config to ensure fresh configuration
# This prevents using cached .build/config with old parameters
log "🧹 Cleaning old build cache..."
sudo lb clean --purge 2>/dev/null || true
rm -rf .build 2>/dev/null || true
rm -rf binary 2>/dev/null || true
rm -rf chroot 2>/dev/null || true

log "⚙️  Configuring pure Debian live-build (FRESH)..."

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
    --linux-flavours amd64 \
    --architectures "${ARCHITECTURE}" \
    --bootappend-live "${BOOT_APPEND}" \
    --debian-installer false \
    --apt-indices false \
    --apt-recommends false \
    --memtest none \
    --iso-application "NovaOS" \
    --iso-publisher "NovaOS" \
    --iso-volume "NovaOS"

log "📦 Copying package lists..."
mkdir -p config/package-lists
cp "${PACKAGE_LISTS_DIR}"/*.list.chroot config/package-lists/ 2>/dev/null || true

log "📂 Copying filesystem overlay..."
if [ -d "${INCLUDES_DIR}" ]; then
    mkdir -p config/includes.chroot
    cp -r "${INCLUDES_DIR}"/* config/includes.chroot/ 2>/dev/null || true
fi

# === PREPARE ISOLINUX ===
log "📋 Preparing isolinux boot files..."
mkdir -p /root/isolinux

for DIR in /usr/lib/isolinux /usr/lib/syslinux /usr/share/syslinux /usr/lib/x86_64-linux-gnu/syslinux; do
    if [ -d "$DIR" ] && [ -f "$DIR/isolinux.bin" ]; then
        cp "$DIR"/isolinux.bin /root/isolinux/ 2>/dev/null || true
        cp "$DIR"/vesamenu.c32 /root/isolinux/ 2>/dev/null || true
        cp "$DIR"/ldlinux.c32 /root/isolinux/ 2>/dev/null || true
        cp "$DIR"/libutil.c32 /root/isolinux/ 2>/dev/null || true
        cp "$DIR"/libcom32.c32 /root/isolinux/ 2>/dev/null || true
    fi
done

# Create placeholders if needed
touch /root/isolinux/isolinux.bin 2>/dev/null || true
touch /root/isolinux/vesamenu.c32 2>/dev/null || true
touch /root/isolinux/ldlinux.c32 2>/dev/null || true
touch /root/isolinux/libutil.c32 2>/dev/null || true
touch /root/isolinux/libcom32.c32 2>/dev/null || true

log "✅ Isolinux files ready"

# === BUILD ISO ===
log "🔨 Starting ISO build (Debian Bullseye)..."
log "   Release: ${DEBIAN_RELEASE}"
log "   Mirror: ${DEBIAN_MIRROR}"
log "   Archive areas: ${ARCHIVE_AREAS}"
log "   This will take 10-30 minutes..."
echo ""

lb build 2>&1 | tee build.log

# === CHECK RESULT ===
ISO_FILE=$(find . -maxdepth 1 -name "*.iso" | head -1)

if [ -n "${ISO_FILE}" ]; then
    ISO_SIZE=$(du -h "${ISO_FILE}" | cut -f1)
    echo ""
    log "✅ Build successful!"
    log "📀 ISO: ${PROJECT_ROOT}/build-dir/${ISO_FILE}"
    log "📊 Size: ${ISO_SIZE}"
    echo ""
    log "Next steps:"
    log "  1. Test in VirtualBox (see docs/VIRTUALBOX_TESTING.md)"
    log "  2. Write to USB: sudo dd if=${ISO_FILE} of=/dev/sdX bs=4M status=progress"
else
    echo ""
    err "Build failed! Check build.log for details."
fi
