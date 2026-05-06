#!/bin/bash
# Native Node module rebuilds for the copied VS Code/Electron payload.

native_module_report() {
    local app_dir="$1"
    find "$app_dir/node_modules" -name "*.node" -type f 2>/dev/null | sort || true
}

remove_known_wrong_platform_modules() {
    local app_dir="$1"

    rm -rf "$app_dir/node_modules/windows-foreground-love" 2>/dev/null || true
    rm -rf "$app_dir/node_modules/@vscode/windows-mutex" 2>/dev/null || true
    rm -rf "$app_dir/node_modules/@vscode/windows-process-tree" 2>/dev/null || true
    rm -rf "$app_dir/node_modules/@vscode/windows-registry" 2>/dev/null || true
    find "$app_dir/node_modules" -path "*/prebuilds/darwin-*" -type d -prune -exec rm -rf {} + 2>/dev/null || true
}

refresh_npm_package() {
    local app_dir="$1"
    local package_name="$2"
    local package_path="$app_dir/node_modules/$package_name"
    local version build_dir source_path

    [ -f "$package_path/package.json" ] || return 0
    version="$(node -e 'const p=require(process.argv[1]); process.stdout.write(String(p.version || ""));' "$package_path/package.json")"
    [ -n "$version" ] || return 0

    build_dir="$WORK_DIR/platform-packages/${package_name//@/_}"
    rm -rf "$build_dir"
    mkdir -p "$build_dir"

    info "Refreshing platform package $package_name@$version"
    (
        cd "$build_dir"
        npm init -y >/dev/null 2>&1
        npm install "$package_name@$version" --no-audit --no-fund
    )

    source_path="$build_dir/node_modules/$package_name"
    [ -d "$source_path" ] || error "Failed to install $package_name@$version"
    rm -rf "$package_path"
    mkdir -p "$(dirname "$package_path")"
    cp -a "$source_path" "$package_path"
}

refresh_platform_packages() {
    local app_dir="$1"

    refresh_npm_package "$app_dir" "@vscode/ripgrep"
}

purge_macho_native_modules() {
    local app_dir="$1"
    local native_file description

    command -v file >/dev/null 2>&1 || return 0
    while IFS= read -r native_file; do
        description="$(file "$native_file" 2>/dev/null || true)"
        case "$description" in
            *Mach-O*)
                warn "Removing non-Linux native module: $native_file"
                rm -f "$native_file"
                ;;
        esac
    done < <(find "$app_dir/node_modules" -name "*.node" -type f 2>/dev/null | sort || true)
}

rebuild_native_modules() {
    local app_dir="$1"

    [ -d "$app_dir/node_modules" ] || {
        warn "No node_modules directory found; skipping native rebuild"
        return 0
    }

    info "Native modules before cleanup:"
    native_module_report "$app_dir" >&2
    remove_known_wrong_platform_modules "$app_dir"
    refresh_platform_packages "$app_dir"

    info "Rebuilding native modules for Electron $ELECTRON_VERSION"
    (
        cd "$app_dir"
        npm_config_disturl="$ELECTRON_HEADERS_URL" \
        NPM_CONFIG_DISTURL="$ELECTRON_HEADERS_URL" \
        npx --yes @electron/rebuild -v "$ELECTRON_VERSION" --force --dist-url "$ELECTRON_HEADERS_URL"
    )
    purge_macho_native_modules "$app_dir"

    info "Native modules after rebuild:"
    native_module_report "$app_dir" >&2
}
