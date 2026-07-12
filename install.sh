#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_ID="${CODEBUDDY_APP_ID:-codebuddy-ide-cn}"
APP_DISPLAY_NAME="${CODEBUDDY_APP_DISPLAY_NAME:-CodeBuddy CN}"
INSTALL_DIR="${CODEBUDDY_INSTALL_DIR:-$SCRIPT_DIR/codebuddycn-app}"
ELECTRON_VERSION="${ELECTRON_VERSION:-37.7.0}"
ELECTRON_HEADERS_URL="${ELECTRON_HEADERS_URL:-${npm_config_disturl:-${NPM_CONFIG_DISTURL:-https://artifacts.electronjs.org/headers/dist}}}"
ELECTRON_MIRROR="${ELECTRON_MIRROR:-}"
WORK_DIR="$(mktemp -d)"
ARCH="$(uname -m)"
PROVIDED_INPUT=""
FRESH=0

. "$SCRIPT_DIR/scripts/lib/common.sh"
. "$SCRIPT_DIR/scripts/lib/deb.sh"
. "$SCRIPT_DIR/scripts/lib/electron.sh"
. "$SCRIPT_DIR/scripts/lib/native-modules.sh"

usage() {
    cat <<'HELP'
Usage: ./install.sh [--fresh] [path/to/CodeBuddy.deb]

Builds a loong64 Linux Electron app from the official CodeBuddy IDE CN
Linux x64 .deb package.  With no path, the installer expects exactly one
official .deb in downloads/.

Environment:
  CODEBUDDY_INSTALL_DIR   Output app directory (default: ./codebuddycn-app)
  ELECTRON_MIRROR         Optional Electron runtime mirror
  ELECTRON_HEADERS_URL    Electron headers dist URL for native rebuilds
HELP
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --fresh)
                FRESH=1
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -*)
                usage >&2
                exit 2
                ;;
            *)
                [ -z "$PROVIDED_INPUT" ] || error "Only one input path can be provided"
                PROVIDED_INPUT="$1"
                ;;
        esac
        shift
    done
}

check_deps() {
    require_cmd python3
    require_cmd curl
    require_cmd unzip
    require_cmd dpkg-deb
    require_cmd node
    require_cmd npm
    require_cmd npx
}

prepare_install_dir() {
    if [ -e "$INSTALL_DIR" ]; then
        if [ "$FRESH" -eq 1 ]; then
            rm -rf "$INSTALL_DIR"
        else
            info "Replacing existing install dir: $INSTALL_DIR"
            rm -rf "$INSTALL_DIR"
        fi
    fi
    mkdir -p "$INSTALL_DIR"
}

copy_app_payload() {
    local app_dir="$1"

    [ -d "$app_dir" ] || error "Missing app payload directory"
    [ -f "$app_dir/resources/app/package.json" ] || error "No package.json found in app payload"

    info "Copying CodeBuddy app payload"
    rm -rf "$INSTALL_DIR/resources/app"
    mkdir -p "$INSTALL_DIR/resources"
    cp -a "$app_dir/resources/app" "$INSTALL_DIR/resources/app"
}

write_launcher() {
    cat > "$INSTALL_DIR/start.sh" <<EOF
#!/bin/bash
set -euo pipefail

APP_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
export CHROME_DESKTOP="${APP_ID}.desktop"
export ELECTRON_FORCE_IS_PACKAGED=1

exec "\$APP_DIR/electron" \\
  --no-sandbox \\
  --disable-dev-shm-usage \\
  --disable-gpu-sandbox \\
  --ozone-platform-hint=auto \\
  --enable-wayland-ime \\
  "\$@"
EOF
    chmod +x "$INSTALL_DIR/start.sh"
}

write_icon() {
    local app_dir="$1"
    local src="$app_dir/resources/app/out/media/mascot-new.png"
    local dst="$INSTALL_DIR/.codebuddycn-linux/codebuddycn.png"

    [ -f "$src" ] || { warn "No icon source found at $src"; return 0; }

    mkdir -p "$INSTALL_DIR/.codebuddycn-linux"

    info "Generating app icon (256x256) from mascot"
    python3 -c "
from PIL import Image
img = Image.open('$src')
img.thumbnail((256, 256), Image.LANCZOS)
img.save('$dst', 'PNG')
" || { warn "Failed to generate icon with PIL, trying ImageMagick"; \
    convert "$src" -resize 256x256 "$dst" 2>/dev/null || warn "Failed to generate app icon"; }
}

write_desktop_entry() {
    mkdir -p "$INSTALL_DIR/.codebuddycn-linux"
    cat > "$INSTALL_DIR/.codebuddycn-linux/$APP_ID.desktop" <<EOF
[Desktop Entry]
Name=$APP_DISPLAY_NAME
Comment=Run $APP_DISPLAY_NAME on Linux (loong64)
Exec=$INSTALL_DIR/start.sh %F
Icon=$APP_ID
Type=Application
Categories=Development;IDE;
StartupNotify=true
StartupWMClass=CodeBuddy CN
MimeType=x-scheme-handler/codebuddycn;
EOF
}

write_build_metadata() {
    local app_dir="$1"
    local version
    version="$(read_app_version "$app_dir")"
    mkdir -p "$INSTALL_DIR/.codebuddycn-linux"
    cat > "$INSTALL_DIR/.codebuddycn-linux/build-info.json" <<EOF
{
  "appId": "$APP_ID",
  "displayName": "$APP_DISPLAY_NAME",
  "upstreamVersion": "$version",
  "electronVersion": "$ELECTRON_VERSION",
  "arch": "loong64",
  "generatedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
}

main() {
    parse_args "$@"
    check_deps

    local deb_path deb_extracted app_dir
    deb_path="$(resolve_input_path "$PROVIDED_INPUT")"
    deb_extracted="$(extract_deb "$deb_path")"
    app_dir="$(locate_app_payload "$deb_extracted")"

    if [ -n "${FORCE_ELECTRON_VERSION:-}" ]; then
        ELECTRON_VERSION="$FORCE_ELECTRON_VERSION"
        info "Using forced Electron version: $ELECTRON_VERSION"
    else
        ELECTRON_VERSION="$(detect_electron_version "$app_dir")"
    fi

    info "Using .deb: $deb_path"
    info "Using app payload: $app_dir"
    info "Using Electron: $ELECTRON_VERSION"

    prepare_install_dir
    download_electron_runtime
    copy_app_payload "$app_dir"
    write_icon "$app_dir"
    rebuild_native_modules "$INSTALL_DIR/resources/app"
    write_launcher
    write_desktop_entry
    write_build_metadata "$app_dir"

    info "Build complete: $INSTALL_DIR"
    info "Run: $INSTALL_DIR/start.sh"
}

trap 'rm -rf "$WORK_DIR"' EXIT
main "$@"
