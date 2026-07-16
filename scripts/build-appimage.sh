#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

. "$REPO_DIR/scripts/lib/common.sh"
. "$REPO_DIR/scripts/lib/appimage.sh"

APP_DIR="${APP_DIR:-$REPO_DIR/codebuddycn-app}"
DIST_DIR="${DIST_DIR:-$REPO_DIR/dist}"
PACKAGE_NAME="${PACKAGE_NAME:-codebuddy-ide-cn}"
DESKTOP_TEMPLATE="$REPO_DIR/packaging/linux/codebuddy-ide-cn.desktop"
OUTPUT="${APPIMAGE_OUT:-$DIST_DIR/${PACKAGE_NAME}-loongarch64.AppImage}"
WORK_DIR="$(mktemp -d)"

main() {
    [ -x "$APP_DIR/start.sh" ] || error "Missing generated app. Run make build-app first."
    require_cmd curl
    require_cmd python3

    local appdir="$WORK_DIR/CodeBuddyCN.AppDir"

    download_linuxdeploy
    prepare_appdir "$appdir"
    build_appimage "$appdir" "$OUTPUT" "$WORK_DIR"
}

trap 'rm -rf "$WORK_DIR"' EXIT
main "$@"
