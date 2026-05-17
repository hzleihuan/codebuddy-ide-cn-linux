#!/bin/bash
# Shared shell helpers. Sourced by scripts; do not run directly.

info() {
    echo "[INFO] $*" >&2
}

warn() {
    echo "[WARN] $*" >&2
}

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || error "Missing required command: $1"
}

find_7z() {
    local cmd=""
    if command -v 7zz >/dev/null 2>&1; then
        cmd="7zz"
    elif command -v 7z >/dev/null 2>&1; then
        cmd="7z"
    else
        error "Missing 7z/7zz. Install the 7zip package: https://7-zip.org"
    fi

    # Reject legacy p7zip (16.x) which cannot extract DMG files properly.
    # Official 7-Zip starts at version 21+.
    local ver_line
    ver_line="$("$cmd" 2>&1 | head -1)"
    if [[ "$ver_line" =~ 7-Zip[[:space:]]+([0-9]+)\. ]]; then
        local major="${BASH_REMATCH[1]}"
        if [ "$major" -lt 21 ]; then
            warn "Detected $cmd version $major.x (p7zip) which cannot extract DMG files reliably."
            warn "Install the official 7zip package (version 21+) instead:"
            warn "  Debian/Ubuntu: sudo apt install 7zip"
            warn "  Fedora:        sudo dnf install 7zip"
            warn "  Arch:          sudo pacman -S 7zip"
            warn "  openSUSE:      sudo zypper install 7zip"
            error "Please upgrade to 7zip 21+ and re-run."
        fi
    fi

    command -v "$cmd"
}
