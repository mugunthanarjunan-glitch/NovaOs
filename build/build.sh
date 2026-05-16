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

# --- Create Build Directory ---
log "📁 Setting up build directory: ${BUILD_DIR}"
mkdir -p "${PROJECT_ROOT}/${BUILD_DIR}"
cd "${PROJECT_ROOT}/${BUILD_DIR}"

# --- Clean Previous Build (if any) ---
if [ -f .build/config ]; then
    warn "Previous build detected. Cleaning..."
    lb clean --chroot
fi

# --- Configure live-build ---
log "⚙️  Configuring live-build..."

# Note: We use = sign for compound options to prevent shell argument splitting.
# The kernel is included via package-lists/base.list.chroot instead of --linux-packages.
lb config \
    --binary-images "${IMAGE_TYPE}" \
    --distribution "${DEBIAN_RELEASE}" \
    --archive-areas "${ARCHIVE_AREAS}" \
    --mirror-bootstrap "${DEBIAN_MIRROR}" \
    --mirror-chroot-security "http://security.debian.org/debian-security" \
    --architectures "${ARCHITECTURE}" \
    --bootappend-live "${BOOT_APPEND}" \
    --debian-installer false \
    --apt-indices false \
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
