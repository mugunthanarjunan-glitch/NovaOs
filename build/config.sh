#!/bin/bash
# ============================================================================
# NovaOS Build Configuration
# ============================================================================
# Central configuration variables for the NovaOS ISO build.
# All build scripts source this file.
# ============================================================================

# --- Distribution Identity ---
DISTRO_NAME="NovaOS"
DISTRO_VERSION="1.0"
DISTRO_CODENAME="nova"
DISTRO_FULLNAME="${DISTRO_NAME} ${DISTRO_VERSION}"

# --- Debian Base ---
DEBIAN_RELEASE="bookworm"
ARCHITECTURE="amd64"
ARCHIVE_AREAS="main contrib non-free non-free-firmware"
DEBIAN_MIRROR="http://deb.debian.org/debian"

# --- Kernel ---
KERNEL_PACKAGE="linux-image-amd64"
KERNEL_FLAVOUR="amd64"

# --- Build Options ---
IMAGE_TYPE="iso-hybrid"
BUILD_DIR="build-dir"

# --- Boot ---
BOOT_APPEND="boot=live components quiet splash timezone=UTC keyboard-layouts=us"

# --- Paths (relative to project root) ---
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_LISTS_DIR="${PROJECT_ROOT}/config/package-lists"
INCLUDES_DIR="${PROJECT_ROOT}/config/includes.chroot"
HOOKS_DIR="${PROJECT_ROOT}/config/hooks"
THEMES_DIR="${PROJECT_ROOT}/themes"
OPTIMIZATION_DIR="${PROJECT_ROOT}/optimization"
INSTALLER_DIR="${PROJECT_ROOT}/installer"
