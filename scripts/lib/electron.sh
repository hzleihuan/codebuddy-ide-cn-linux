#!/bin/bash
# Linux Electron runtime download. Sourced by install.sh.

# ── Community Electron mirror for LoongArch (loong64) ──────────────────
# Electron does not publish official loong64 binaries.
# This community project provides regularly updated LoongArch builds with
# the same download layout as the official GitHub releases.
LOONG64_ELECTRON_MIRROR="${LOONG64_ELECTRON_MIRROR:-https://github.com/darkyzhou/electron-loong64/releases/download}"

# Known LoongArch Electron versions, newest first.
# kept here so map_loong64_electron_version can pick the closest match.
LOONG64_KNOWN_VERSIONS=(
    "39.2.7" "39.2.3" "37.2.5"
    "35.4.0"
    "34.5.4" "34.4.1" "34.3.2" "34.2.0"
    "32.2.7" "32.2.6"
)
# ───────────────────────────────────────────────────────────────────────

electron_arch() {
    case "$ARCH" in
        x86_64) echo "x64" ;;
        aarch64) echo "arm64" ;;
        armv7l) echo "armv7l" ;;
        loongarch64) echo "loong64" ;;
        *) error "Unsupported architecture: $ARCH" ;;
    esac
}

# Map a detected Electron version to the closest available loong64 build.
# Strategy: prefer the same major, then the nearest lower major (stability
# over bleeding-edge).  Within a major, pick the highest available version.
map_loong64_electron_version() {
    local input="$1"
    local input_major="${input%%.*}"
    local best=""

    # Try exact match first (fast path)
    for v in "${LOONG64_KNOWN_VERSIONS[@]}"; do
        if [ "$v" = "$input" ]; then
            echo "$v"
            return 0
        fi
    done

    # Same major: highest version in that major
    for v in "${LOONG64_KNOWN_VERSIONS[@]}"; do
        local v_major="${v%%.*}"
        if [ "$v_major" = "$input_major" ]; then
            best="$v"
            break  # list is sorted newest-first, so first hit is highest
        fi
    done
    if [ -n "$best" ]; then
        warn "LoongArch Electron $input is not available → using closest $best"
        echo "$best"
        return 0
    fi

    # No same-major build – pick the closest lower major
    for v in "${LOONG64_KNOWN_VERSIONS[@]}"; do
        local v_major="${v%%.*}"
        if [ "$v_major" -lt "$input_major" ]; then
            best="$v"
            break
        fi
    done
    if [ -n "$best" ]; then
        warn "LoongArch Electron $input has no $input_major.x build → falling back to $best"
        echo "$best"
        return 0
    fi

    # Last resort: the newest build we know about
    best="${LOONG64_KNOWN_VERSIONS[0]}"
    warn "LoongArch Electron $input not found in known versions → using $best"
    echo "$best"
}

download_electron_runtime() {
    local arch zip_name url cache_dir cached_zip partial_zip

    arch="$(electron_arch)"

    # ── ELECTRON_LOCAL_ZIP: use a local zip directly, skip download ──
    if [ -n "${ELECTRON_LOCAL_ZIP:-}" ]; then
        [ -f "$ELECTRON_LOCAL_ZIP" ] || error "ELECTRON_LOCAL_ZIP not found: $ELECTRON_LOCAL_ZIP"
        info "Using local Electron zip: $ELECTRON_LOCAL_ZIP"
        unzip -qo "$ELECTRON_LOCAL_ZIP" -d "$INSTALL_DIR"
        [ -x "$INSTALL_DIR/electron" ] || error "Electron binary was not extracted from $ELECTRON_LOCAL_ZIP"
        return 0
    fi

    # ── LoongArch: set community mirror + match closest version ───────
    if [ "$arch" = "loong64" ]; then
        if [ -z "$ELECTRON_MIRROR" ]; then
            ELECTRON_MIRROR="$LOONG64_ELECTRON_MIRROR"
        fi
        local mapped_version
        mapped_version="$(map_loong64_electron_version "$ELECTRON_VERSION")"
        if [ "$mapped_version" != "$ELECTRON_VERSION" ]; then
            ELECTRON_VERSION="$mapped_version"
        fi
    fi

    zip_name="electron-v${ELECTRON_VERSION}-linux-${arch}.zip"
    if [ -n "$ELECTRON_MIRROR" ]; then
        url="${ELECTRON_MIRROR%/}/v${ELECTRON_VERSION}/${zip_name}"
    else
        url="https://github.com/electron/electron/releases/download/v${ELECTRON_VERSION}/${zip_name}"
    fi

    cache_dir="${CODEBUDDY_ELECTRON_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/codebuddy-ide-cn-linux/electron}"
    cached_zip="$cache_dir/$zip_name"
    partial_zip="$cached_zip.part"
    mkdir -p "$cache_dir"

    if [ ! -f "$cached_zip" ]; then
        info "Downloading $zip_name"
        curl -L --fail --continue-at - --progress-bar -o "$partial_zip" "$url"
        mv "$partial_zip" "$cached_zip"
    else
        info "Using cached Electron runtime: $cached_zip"
    fi

    unzip -qo "$cached_zip" -d "$INSTALL_DIR"
    [ -x "$INSTALL_DIR/electron" ] || error "Electron binary was not extracted"
}
