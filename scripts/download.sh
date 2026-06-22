#!/bin/bash
# Download the official CodeBuddy DMG into downloads/.
# Usage: download.sh <dmg-url>
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DOWNLOADS_DIR="$SCRIPT_DIR/downloads"
BACKUPS_DIR="$DOWNLOADS_DIR/backups"

. "$SCRIPT_DIR/scripts/lib/common.sh"

[ $# -ge 1 ] || error "Usage: $0 <dmg-url>"

DMG_URL="$1"
DMG_FILENAME="${DMG_URL##*/}"

# 1. Ensure downloads/ exists
mkdir -p "$DOWNLOADS_DIR"

# 2. If the exact file already exists, nothing to do
if [ -f "$DOWNLOADS_DIR/$DMG_FILENAME" ]; then
    info "$DMG_FILENAME already exists in downloads/, skipping download."
    exit 0
fi

# 3. Move any existing .dmg files to backups/
for f in "$DOWNLOADS_DIR"/*.dmg; do
    [ -f "$f" ] || continue
    mkdir -p "$BACKUPS_DIR"
    info "Moving old DMG to backups/: $(basename "$f")"
    mv "$f" "$BACKUPS_DIR/"
done

# 4. Download the new DMG
info "Downloading $DMG_FILENAME ..."
curl -fSL --progress-bar -o "$DOWNLOADS_DIR/$DMG_FILENAME" "$DMG_URL"

info "Download complete: downloads/$DMG_FILENAME"
