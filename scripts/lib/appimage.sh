#!/bin/bash
# AppImage packaging helpers. Sourced by build-appimage.sh.

# Derive the linuxdeploy architecture suffix from uname -m.
# linuxdeploy releases use the raw kernel arch name (x86_64, aarch64, etc.).
detect_linuxdeploy_arch() {
    uname -m
}

LINUXDEPLOY_ARCH="${LINUXDEPLOY_ARCH:-$(detect_linuxdeploy_arch)}"
LINUXDEPLOY_URL="${LINUXDEPLOY_URL:-https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-${LINUXDEPLOY_ARCH}.AppImage}"
LINUXDEPLOY_BIN="${LINUXDEPLOY_BIN:-$REPO_DIR/build/tools/linuxdeploy-${LINUXDEPLOY_ARCH}.AppImage}"

download_linuxdeploy() {
    if [ -x "$LINUXDEPLOY_BIN" ]; then
        info "linuxdeploy already cached: $LINUXDEPLOY_BIN"
        return 0
    fi
    mkdir -p "$(dirname "$LINUXDEPLOY_BIN")"
    info "Downloading linuxdeploy ..."
    curl -fSL --progress-bar -o "$LINUXDEPLOY_BIN" "$LINUXDEPLOY_URL"
    chmod +x "$LINUXDEPLOY_BIN"
    info "linuxdeploy saved: $LINUXDEPLOY_BIN"
}

prepare_appdir() {
    local appdir="$1"

    rm -rf "$appdir"
    mkdir -p \
        "$appdir/usr/bin" \
        "$appdir/usr/share/applications" \
        "$appdir/usr/share/icons/hicolor/256x256/apps"

    # Copy the entire built app into usr/bin/
    # start.sh uses $(dirname "${BASH_SOURCE[0]}") to locate electron,
    # so the internal layout must stay intact.
    cp -a "$APP_DIR" "$appdir/usr/bin/codebuddycn-app"

    # Icon
    local icon_src="$APP_DIR/.codebuddycn-linux/codebuddycn.png"
    if [ -f "$icon_src" ]; then
        cp "$icon_src" "$appdir/usr/share/icons/hicolor/256x256/apps/codebuddycn.png"
    else
        warn "Icon not found; AppImage will use a fallback icon"
    fi
}

build_appimage() {
    local appdir="$1"
    local output="$2"
    local workdir="$3"
    local icon_path="$appdir/usr/share/icons/hicolor/256x256/apps/codebuddycn.png"

    # Custom AppRun - linuxdeploy won't accept shell scripts as Exec,
    # so we provide our own AppRun directly.
    # Must live outside the AppDir so linuxdeploy can copy it in.
    local apprun_src="$workdir/AppRun"
    cat > "$apprun_src" <<'APPRUN'
#!/bin/bash
SELF_DIR="$(dirname "$(readlink -f "$0")")"
exec "$SELF_DIR/usr/bin/codebuddycn-app/start.sh" "$@"
APPRUN
    chmod 0755 "$apprun_src"

    # Desktop entry - also outside AppDir to avoid copy-to-self errors.
    local desktop_src="$workdir/$PACKAGE_NAME.desktop"
    sed -e "s|__EXEC__|codebuddy-ide-cn %F|g" "$DESKTOP_TEMPLATE" \
        > "$desktop_src"
    chmod 0644 "$desktop_src"

    info "Building AppImage ..."
    mkdir -p "$DIST_DIR"

    local -a deploy_args=(
        --appimage-extract-and-run
        --appdir "$appdir"
        --custom-apprun "$apprun_src"
        --desktop-file "$desktop_src"
        --output appimage
    )
    if [ -f "$icon_path" ]; then
        deploy_args+=(--icon-file "$icon_path")
    fi

    # --appimage-extract-and-run avoids requiring FUSE at build time
    ARCH="$LINUXDEPLOY_ARCH" "$LINUXDEPLOY_BIN" "${deploy_args[@]}" >&2

    # linuxdeploy writes the AppImage into the current directory
    local generated
    generated="$(find "$REPO_DIR" -maxdepth 1 -name "*.AppImage" -print | head -n 1)"
    if [ -n "$generated" ] && [ -f "$generated" ]; then
        mv "$generated" "$output"
    else
        error "AppImage generation failed; no output file found"
    fi

    info "Built AppImage: $output"
}
