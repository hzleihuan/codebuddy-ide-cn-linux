#!/bin/bash
# Download the official CodeBuddy Linux .deb into downloads/.
# Usage: download.sh <deb-url>
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DOWNLOADS_DIR="$SCRIPT_DIR/downloads"
BACKUPS_DIR="$DOWNLOADS_DIR/backups"

. "$SCRIPT_DIR/scripts/lib/common.sh"

[ $# -ge 1 ] || error "Usage: $0 <deb-url>"

DEB_URL="$1"
DEB_FILENAME="${DEB_URL##*/}"

# 1. Ensure downloads/ exists
mkdir -p "$DOWNLOADS_DIR"

# 2. If the exact file already exists, nothing to do
if [ -f "$DOWNLOADS_DIR/$DEB_FILENAME" ]; then
    info "$DEB_FILENAME already exists in downloads/, skipping download."
    exit 0
fi

# 3. Move any existing .deb files to backups/
for f in "$DOWNLOADS_DIR"/*.deb; do
    [ -f "$f" ] || continue
    mkdir -p "$BACKUPS_DIR"
    info "Moving old .deb to backups/: $(basename "$f")"
    mv "$f" "$BACKUPS_DIR/"
done

# 4. Download the new .deb
info "Downloading $DEB_FILENAME ..."
curl -fSL --progress-bar -o "$DOWNLOADS_DIR/$DEB_FILENAME" "$DEB_URL"

info "Download complete: downloads/$DEB_FILENAME"
