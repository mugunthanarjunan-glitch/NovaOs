#!/bin/bash
# ============================================================================
# NovaOS Build Cleanup Script
# ============================================================================
# Removes all build artifacts so you can start fresh.
#
# Usage:
#   sudo ./build/clean.sh
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[NovaOS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR]${NC} This script must be run as root. Use: sudo ./build/clean.sh"
    exit 1
fi

BUILD_PATH="${PROJECT_ROOT}/${BUILD_DIR}"

if [ -d "${BUILD_PATH}" ]; then
    log "🧹 Cleaning build directory: ${BUILD_PATH}"
    cd "${BUILD_PATH}"
    
    # Use live-build's clean command if available
    if [ -f .build/config ]; then
        lb clean --purge
    fi
    
    cd "${PROJECT_ROOT}"
    rm -rf "${BUILD_PATH}"
    log "✅ Build directory removed."
else
    warn "Build directory does not exist: ${BUILD_PATH}"
fi

log "🏁 Clean complete. Ready for a fresh build."
