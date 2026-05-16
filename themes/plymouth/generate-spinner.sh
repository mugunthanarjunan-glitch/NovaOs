#!/bin/bash
# ============================================================================
# NovaOS — Generate Plymouth Spinner Frames
# ============================================================================
# Generates 36 spinner animation frames using ImageMagick.
# Run this on the Linux build host if ImageMagick is available.
# If not, the build hook will generate simple fallback frames.
# ============================================================================

set -e

OUTPUT_DIR="${1:-$(dirname "$0")/images}"
mkdir -p "${OUTPUT_DIR}"

FRAMES=36
SIZE=48
COLOR="#4fc3f7"  # Electric blue

echo "[NovaOS] Generating ${FRAMES} spinner frames..."

if command -v convert &> /dev/null; then
    # Use ImageMagick to generate spinning arc
    for i in $(seq 1 ${FRAMES}); do
        ANGLE=$(( (i - 1) * 10 ))
        PADDED=$(printf "%02d" $i)
        
        convert -size ${SIZE}x${SIZE} xc:transparent \
            -stroke "${COLOR}" -strokewidth 3 -fill none \
            -draw "arc 4,4 $((SIZE-4)),$((SIZE-4)) ${ANGLE},$((ANGLE+270))" \
            "${OUTPUT_DIR}/spinner-${PADDED}.png"
    done
    echo "[NovaOS] ✅ Generated ${FRAMES} spinner frames in ${OUTPUT_DIR}"
else
    echo "[NovaOS] ⚠️  ImageMagick not found. Creating placeholder frames."
    echo "[NovaOS] Install with: sudo apt install imagemagick"
    
    # Create minimal placeholder (1x1 transparent pixel per frame)
    for i in $(seq 1 ${FRAMES}); do
        PADDED=$(printf "%02d" $i)
        # Create a minimal 1-pixel PNG (can't do proper graphics without tools)
        printf '\x89PNG\r\n\x1a\n' > "${OUTPUT_DIR}/spinner-${PADDED}.png"
    done
    echo "[NovaOS] Created placeholder frames. Replace with proper images later."
fi
