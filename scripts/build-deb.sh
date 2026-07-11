#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

. "$REPO_DIR/scripts/lib/common.sh"

APP_DIR="${APP_DIR:-$REPO_DIR/codebuddycn-app}"
DIST_DIR="${DIST_DIR:-$REPO_DIR/dist}"
PKG_ROOT="${PKG_ROOT:-$DIST_DIR/deb-root}"

# Extract version info from the downloaded DMG filename.
# DMG filename pattern: CodeBuddy-darwin-x64-{version}.{build}-{hash}-cn.dmg
# Returns: {version}.{build}--{hash}  (e.g. 4.9.15.31887257--cbd94294)
extract_dmg_version() {
    local dmg_file downloads_dir="$REPO_DIR/downloads"
    dmg_file="$(find "$downloads_dir" -maxdepth 1 -name "*.dmg" -print 2>/dev/null | head -n 1)"
    if [ -z "$dmg_file" ]; then
        return 1
    fi
    local basename="${dmg_file##*/}"
    if [[ "$basename" =~ CodeBuddy-darwin-x64-([0-9]+\.[0-9]+\.[0-9]+)\.([0-9]+)-([0-9a-f]+)-cn\.dmg ]]; then
        echo "${BASH_REMATCH[1]}.${BASH_REMATCH[2]}--${BASH_REMATCH[3]}"
        return 0
    fi
    return 1
}

PACKAGE_NAME="${PACKAGE_NAME:-codebuddy-ide-cn}"
PACKAGE_VERSION="${PACKAGE_VERSION:-$(extract_dmg_version || date -u +%Y.%m.%d.%H%M%S)}"
DESKTOP_TEMPLATE="$REPO_DIR/packaging/linux/codebuddy-ide-cn.desktop"
CONTROL_TEMPLATE="$REPO_DIR/packaging/linux/control"

map_arch() {
    case "$(dpkg --print-architecture)" in
        amd64|arm64|armhf|loong64) dpkg --print-architecture ;;
        *) error "Unsupported Debian architecture: $(dpkg --print-architecture)" ;;
    esac
}

main() {
    [ -x "$APP_DIR/start.sh" ] || error "Missing generated app. Run ./install.sh first."
    require_cmd dpkg
    require_cmd dpkg-deb

    local arch output_file
    arch="$(map_arch)"
    output_file="$DIST_DIR/${PACKAGE_NAME}_${PACKAGE_VERSION}_${arch}.deb"

    rm -rf "$PKG_ROOT"
    mkdir -p \
        "$PKG_ROOT/DEBIAN" \
        "$PKG_ROOT/opt/$PACKAGE_NAME" \
        "$PKG_ROOT/usr/bin" \
        "$PKG_ROOT/usr/share/applications" \
        "$PKG_ROOT/usr/share/icons/hicolor/256x256/apps"

    cp -a "$APP_DIR/." "$PKG_ROOT/opt/$PACKAGE_NAME/"

    cat > "$PKG_ROOT/usr/bin/$PACKAGE_NAME" <<EOF
#!/bin/bash
exec /opt/$PACKAGE_NAME/start.sh "\$@"
EOF
    chmod 0755 "$PKG_ROOT/usr/bin/$PACKAGE_NAME"

    sed -e "s|__EXEC__|/opt/$PACKAGE_NAME/start.sh %F|g" "$DESKTOP_TEMPLATE" \
        > "$PKG_ROOT/usr/share/applications/$PACKAGE_NAME.desktop"
    chmod 0644 "$PKG_ROOT/usr/share/applications/$PACKAGE_NAME.desktop"

    if [ -f "$APP_DIR/.codebuddycn-linux/codebuddycn.png" ]; then
        cp "$APP_DIR/.codebuddycn-linux/codebuddycn.png" \
            "$PKG_ROOT/usr/share/icons/hicolor/256x256/apps/codebuddycn.png"
        chmod 0644 "$PKG_ROOT/usr/share/icons/hicolor/256x256/apps/codebuddycn.png"
    fi

    sed \
        -e "s/__PACKAGE_NAME__/$PACKAGE_NAME/g" \
        -e "s/__VERSION__/$PACKAGE_VERSION/g" \
        -e "s/__ARCH__/$arch/g" \
        "$CONTROL_TEMPLATE" > "$PKG_ROOT/DEBIAN/control"
    chmod 0644 "$PKG_ROOT/DEBIAN/control"

    mkdir -p "$DIST_DIR"
    dpkg-deb --root-owner-group --build "$PKG_ROOT" "$output_file" >&2
    info "Built package: $output_file"
}

main "$@"
