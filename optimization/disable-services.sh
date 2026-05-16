#!/bin/bash
# ============================================================================
# NovaOS — Disable Unnecessary Services
# ============================================================================
# Disables systemd services that are not needed for a lightweight desktop.
# Each service is documented with what it does and RAM saved.
#
# Users can re-enable any service with:
#   sudo systemctl enable --now <service-name>
# ============================================================================

set -e

echo "[NovaOS] Disabling unnecessary services for lightweight operation..."

# --- Printing (not needed by default) ---
# cups.service: CUPS print server (~15 MB)
# cups-browsed.service: Auto-discover network printers (~10 MB)
systemctl disable cups.service 2>/dev/null || true
systemctl disable cups-browsed.service 2>/dev/null || true

# --- Mobile Broadband ---
# ModemManager.service: Manages mobile broadband modems (~10 MB)
systemctl disable ModemManager.service 2>/dev/null || true

# --- Network Discovery ---
# avahi-daemon.service: mDNS/DNS-SD service discovery (~5 MB)
systemctl disable avahi-daemon.service 2>/dev/null || true

# --- Bluetooth (disabled by default, easy to re-enable) ---
# bluetooth.service: Bluetooth daemon (~8 MB)
systemctl disable bluetooth.service 2>/dev/null || true

# --- Account Management ---
# accounts-daemon.service: D-Bus account management (~8 MB)
systemctl disable accounts-daemon.service 2>/dev/null || true

# --- Legacy Logging (journald is sufficient) ---
# rsyslog.service: Traditional syslog daemon (~5 MB)
systemctl disable rsyslog.service 2>/dev/null || true

# --- Scheduled Tasks ---
# cron.service: Task scheduler (~2 MB)
# Desktop users rarely need cron
systemctl disable cron.service 2>/dev/null || true

# --- Network Wait (slows boot by 10-30 seconds) ---
systemctl disable NetworkManager-wait-online.service 2>/dev/null || true

# --- Mask services that should never start ---
# These are completely prevented from running:
systemctl mask lvm2-monitor.service 2>/dev/null || true
systemctl mask lvm2-lvmpolld.service 2>/dev/null || true

echo "[NovaOS] ✅ Services optimized. Estimated RAM saved: ~65 MB"
echo "[NovaOS] Re-enable any service with: sudo systemctl enable --now <service>"
