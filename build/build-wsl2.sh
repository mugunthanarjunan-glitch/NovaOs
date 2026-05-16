#!/bin/bash
# ============================================================================
# NovaOS — WSL2 Build Script
# ============================================================================
# Simplified build script for running inside WSL2 on Windows.
# Handles WSL2-specific quirks (loop devices, permissions).
#
# Prerequisites (run in PowerShell first):
#   wsl --install -d Debian
#
# Then inside WSL Debian:
#   sudo ./build/build-wsl2.sh
# ============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[NovaOS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# --- Check root ---
if [ "$EUID" -ne 0 ]; then
    err "Run with sudo: sudo ./build/build-wsl2.sh"
fi

# --- Detect WSL ---
if grep -qi microsoft /proc/version 2>/dev/null; then
    log "✅ WSL2 detected"
else
    warn "Not running in WSL2. This script is designed for WSL2."
    warn "Continuing anyway..."
fi

# --- Step 1: Install dependencies ---
log "📦 Installing build dependencies..."
apt-get update
apt-get install -y \
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

# --- Step 2: Source config ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# --- Step 3: Create build directory ---
log "📁 Setting up build directory..."
mkdir -p "${PROJECT_ROOT}/${BUILD_DIR}"
cd "${PROJECT_ROOT}/${BUILD_DIR}"

# Clean previous build if exists
if [ -f .build/config ]; then
    warn "Previous build found. Cleaning..."
    lb clean --chroot 2>/dev/null || true
fi

# --- Step 4: Configure live-build ---
log "⚙️  Configuring live-build..."
lb config \
    --mode debian \
    --binary-images "${IMAGE_TYPE}" \
    --distribution "${DEBIAN_RELEASE}" \
    --parent-distribution "${DEBIAN_RELEASE}" \
    --parent-mirror-bootstrap "${DEBIAN_MIRROR}" \
    --parent-mirror-chroot "${DEBIAN_MIRROR}" \
    --archive-areas "${ARCHIVE_AREAS}" \
    --mirror-bootstrap "${DEBIAN_MIRROR}" \
    --mirror-chroot "${DEBIAN_MIRROR}" \
    --security false \
    --keyring-packages debian-archive-keyring \
    --architectures "${ARCHITECTURE}" \
    --bootappend-live "${BOOT_APPEND}" \
    --debian-installer false \
    --apt-indices false \
    --memtest none \
    --iso-application "NovaOS" \
    --iso-publisher "NovaOS" \
    --iso-volume "NovaOS"

# --- Step 5: Copy project files ---
log "📦 Copying package lists..."
mkdir -p config/package-lists
cp "${PACKAGE_LISTS_DIR}"/*.list.chroot config/package-lists/

log "📂 Copying filesystem overlay..."
if [ -d "${INCLUDES_DIR}" ]; then
    mkdir -p config/includes.chroot
    cp -r "${INCLUDES_DIR}"/* config/includes.chroot/
fi

# --- Copy Theme Assets ---
log "🎨 Copying theme assets..."
CHROOT="config/includes.chroot"
mkdir -p "${CHROOT}/usr/share/backgrounds/novaos"
mkdir -p "${CHROOT}/usr/share/plymouth/themes/novaos"
mkdir -p "${CHROOT}/usr/share/pixmaps"
cp "${THEMES_DIR}"/wallpapers/*.png "${CHROOT}/usr/share/backgrounds/novaos/" 2>/dev/null || true
cp "${THEMES_DIR}"/plymouth/novaos.plymouth "${CHROOT}/usr/share/plymouth/themes/novaos/" 2>/dev/null || true
cp "${THEMES_DIR}"/plymouth/novaos.script "${CHROOT}/usr/share/plymouth/themes/novaos/" 2>/dev/null || true
cp "${THEMES_DIR}"/plymouth/images/*.png "${CHROOT}/usr/share/plymouth/themes/novaos/" 2>/dev/null || true
cp "${THEMES_DIR}/plymouth/images/novaos-logo.png" "${CHROOT}/usr/share/pixmaps/novaos-logo.png" 2>/dev/null || true

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

# --- Step 6: Build ---
log "🔨 Building NovaOS ISO... (15-45 minutes)"
log "   Go grab a coffee ☕"
echo ""

lb build 2>&1 | tee build.log

# --- Step 7: Result ---
ISO_FILE=$(find . -maxdepth 1 -name "*.iso" -o -name "*.hybrid.iso" | head -1)

if [ -n "${ISO_FILE}" ]; then
    ISO_SIZE=$(du -h "${ISO_FILE}" | cut -f1)
    
    # Copy to Windows-accessible location
    WIN_PATH="${PROJECT_ROOT}/${ISO_FILE##*/}"
    cp "${ISO_FILE}" "${WIN_PATH}" 2>/dev/null || true
    
    echo ""
    log "✅ Build successful!"
    log "📀 ISO: $(pwd)/${ISO_FILE}"
    log "📊 Size: ${ISO_SIZE}"
    echo ""
    log "The ISO is in your NovaOS folder."
    log "Open VirtualBox on Windows → Create new VM → Load this ISO"
else
    err "Build failed! Check build.log for details."
fi
