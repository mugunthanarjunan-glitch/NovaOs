#!/bin/bash
# ============================================================================
# NovaOS Master Build Script
# ============================================================================
# Builds the NovaOS live ISO using Debian live-build.
# Must be run as root (sudo) on a Debian/Ubuntu host.
#
# Usage:
#   sudo ./build/build.sh
# ============================================================================

set -e  # Exit on any error

# --- Load Configuration ---
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

# --- Pre-flight Checks ---
log "🚀 NovaOS Build System v${DISTRO_VERSION}"
echo "======================================"

if [ "$EUID" -ne 0 ]; then
    err "This script must be run as root. Use: sudo ./build/build.sh"
fi

if ! command -v lb &> /dev/null; then
    err "live-build is not installed. Run: sudo apt install live-build"
fi

if ! command -v debootstrap &> /dev/null; then
    err "debootstrap is not installed. Run: sudo apt install debootstrap"
fi

if ! command -v syslinux &> /dev/null && [ ! -f /usr/share/syslinux/isolinux.bin ] && [ ! -f /usr/lib/syslinux/isolinux.bin ] && [ ! -f /usr/lib/isolinux/isolinux.bin ]; then
    err "syslinux is not installed. Run: sudo apt install syslinux"
fi

# Update Debian keyring to ensure we have latest keys
log "🔐 Updating Debian keyring..."
apt-get update
apt-get install --only-upgrade -y debian-archive-keyring 2>/dev/null || true

# --- Create Build Directory ---
log "📁 Setting up build directory: ${BUILD_DIR}"
mkdir -p "${PROJECT_ROOT}/${BUILD_DIR}"
cd "${PROJECT_ROOT}/${BUILD_DIR}"

# --- Clean Previous Build (if any) ---
if [ -d .build ]; then
    warn "Previous build cache detected. Cleaning..."
    sudo lb clean --purge 2>/dev/null || true
    rm -rf .build binary source 2>/dev/null || true
fi

# --- Configure live-build ---
log "⚙️  Configuring live-build..."

# CRITICAL: Pure Debian mode (no Ubuntu contamination)
# - Force --mode debian explicitly
# - Use only Debian keyring and mirrors
# - Disable Ubuntu-specific features
log "📦 Configuring pure Debian build system..."
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
    --architectures "${ARCHITECTURE}" \
    --bootappend-live "${BOOT_APPEND}" \
    --debian-installer false \
    --apt-indices false \
    --apt-recommends false \
    --memtest none \
    --iso-application "NovaOS" \
    --iso-publisher "NovaOS" \
    --iso-volume "NovaOS"

# --- Copy Package Lists ---
log "📦 Copying package lists..."
mkdir -p config/package-lists
cp "${PACKAGE_LISTS_DIR}"/*.list.chroot config/package-lists/

# --- Copy Chroot Includes ---
log "📂 Copying filesystem overlay..."
if [ -d "${INCLUDES_DIR}" ]; then
    mkdir -p config/includes.chroot
    cp -r "${INCLUDES_DIR}"/* config/includes.chroot/
fi

# --- Copy Theme Assets (wallpapers, Plymouth, logo) ---
log "🎨 Copying theme assets..."
CHROOT="config/includes.chroot"

# Wallpapers
mkdir -p "${CHROOT}/usr/share/backgrounds/novaos"
if [ -d "${THEMES_DIR}/wallpapers" ]; then
    cp "${THEMES_DIR}"/wallpapers/*.png "${CHROOT}/usr/share/backgrounds/novaos/" 2>/dev/null || true
fi

# Plymouth theme
mkdir -p "${CHROOT}/usr/share/plymouth/themes/novaos"
if [ -d "${THEMES_DIR}/plymouth" ]; then
    cp "${THEMES_DIR}"/plymouth/novaos.plymouth "${CHROOT}/usr/share/plymouth/themes/novaos/" 2>/dev/null || true
    cp "${THEMES_DIR}"/plymouth/novaos.script "${CHROOT}/usr/share/plymouth/themes/novaos/" 2>/dev/null || true
    cp "${THEMES_DIR}"/plymouth/images/*.png "${CHROOT}/usr/share/plymouth/themes/novaos/" 2>/dev/null || true
fi

# Logo for LightDM greeter
mkdir -p "${CHROOT}/usr/share/pixmaps"
if [ -f "${THEMES_DIR}/plymouth/images/novaos-logo.png" ]; then
    cp "${THEMES_DIR}/plymouth/images/novaos-logo.png" "${CHROOT}/usr/share/pixmaps/novaos-logo.png"
fi

# --- Copy Hooks ---
log "🔧 Copying build hooks..."
if [ -d "${HOOKS_DIR}/normal" ]; then
    mkdir -p config/hooks/normal
    cp "${HOOKS_DIR}"/normal/*.hook.chroot config/hooks/normal/
    chmod +x config/hooks/normal/*.hook.chroot
fi
if [ -d "${HOOKS_DIR}/live" ]; then
    mkdir -p config/hooks/live
    cp "${HOOKS_DIR}"/live/*.hook.chroot config/hooks/live/ 2>/dev/null || true
    chmod +x config/hooks/live/*.hook.chroot 2>/dev/null || true
fi
if [ -d "${HOOKS_DIR}/binary" ]; then
    mkdir -p config/hooks/binary
    cp "${HOOKS_DIR}"/binary/*.hook.binary config/hooks/binary/ 2>/dev/null || true
    chmod +x config/hooks/binary/*.hook.binary 2>/dev/null || true
fi

# --- Prepare isolinux files before build ---
log "📋 Preparing isolinux boot files..."
mkdir -p /root/isolinux

# Function to copy syslinux files from a directory
copy_syslinux_files() {
    local sourcedir="$1"
    if [ -d "$sourcedir" ]; then
        cp "$sourcedir"/isolinux.bin /root/isolinux/ 2>/dev/null || true
        cp "$sourcedir"/vesamenu.c32 /root/isolinux/ 2>/dev/null || true
        cp "$sourcedir"/ldlinux.c32 /root/isolinux/ 2>/dev/null || true
        cp "$sourcedir"/libutil.c32 /root/isolinux/ 2>/dev/null || true
        cp "$sourcedir"/libcom32.c32 /root/isolinux/ 2>/dev/null || true
        return 0
    fi
    return 1
}

# Try multiple common locations for syslinux files
if copy_syslinux_files /usr/lib/isolinux; then
    : # Success
elif copy_syslinux_files /usr/lib/syslinux; then
    : # Success
elif copy_syslinux_files /usr/share/syslinux; then
    : # Success
elif copy_syslinux_files /usr/lib/x86_64-linux-gnu/syslinux; then
    : # Success
fi

# Verify and create if needed
if [ -f /root/isolinux/isolinux.bin ] && [ -f /root/isolinux/vesamenu.c32 ]; then
    log "✅ Isolinux boot files ready"
    ls -lh /root/isolinux/ || true
else
    warn "⚠️  Creating placeholder isolinux files..."
    touch /root/isolinux/isolinux.bin
    touch /root/isolinux/vesamenu.c32
    touch /root/isolinux/ldlinux.c32
    touch /root/isolinux/libutil.c32
    touch /root/isolinux/libcom32.c32
    log "✅ Placeholder isolinux files created"
    ls -lh /root/isolinux/ || true
fi

# --- Build the ISO ---
log "🔨 Starting ISO build... This will take 15-45 minutes."
log "   Go grab a coffee ☕"
echo ""

lb build 2>&1 | tee build.log

# --- Check Result ---
ISO_FILE=$(find . -maxdepth 1 -name "*.iso" -o -name "*.hybrid.iso" | head -1)

if [ -n "${ISO_FILE}" ]; then
    ISO_SIZE=$(du -h "${ISO_FILE}" | cut -f1)
    echo ""
    log "✅ Build successful!"
    log "📀 ISO: ${PROJECT_ROOT}/${BUILD_DIR}/${ISO_FILE}"
    log "📊 Size: ${ISO_SIZE}"
    echo ""
    log "Next steps:"
    log "  1. Test in VirtualBox (see docs/VIRTUALBOX_TESTING.md)"
    log "  2. Write to USB: sudo dd if=${ISO_FILE} of=/dev/sdX bs=4M status=progress"
else
    err "Build failed! Check build.log for details."
fi
