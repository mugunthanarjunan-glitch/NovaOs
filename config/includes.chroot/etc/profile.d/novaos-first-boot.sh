#!/bin/bash
# ============================================================================
# NovaOS First-Boot Setup Script
# ============================================================================
# Runs on first boot to finalize setup (add Flathub, etc.)
# Placed in /etc/profile.d/ to run once for the first user.
# ============================================================================

MARKER="/var/lib/novaos/.first-boot-done"

if [ ! -f "${MARKER}" ]; then
    # Add Flathub if not already added
    if command -v flatpak &> /dev/null; then
        flatpak remote-add --if-not-exists flathub \
            https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
    fi
    
    # Create marker to prevent re-running
    sudo mkdir -p /var/lib/novaos
    sudo touch "${MARKER}"
fi
