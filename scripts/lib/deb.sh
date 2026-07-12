#!/bin/bash
# Linux .deb discovery, extraction, and metadata reading. Sourced by install.sh.

resolve_input_path() {
    local explicit_path="$1"
    local -a candidates=()

    if [ -n "$explicit_path" ]; then
        [ -e "$explicit_path" ] || error "Input not found: $explicit_path"
        realpath "$explicit_path"
        return 0
    fi

    if [ -d "$SCRIPT_DIR/downloads" ]; then
        mapfile -d '' candidates < <(find "$SCRIPT_DIR/downloads" -maxdepth 1 -type f -name "*.deb" -print0 | sort -z)
        if [ "${#candidates[@]}" -eq 1 ]; then
            realpath "${candidates[0]}"
            return 0
        fi
        if [ "${#candidates[@]}" -gt 1 ]; then
            error "Multiple .deb files found in downloads/. Pass one explicitly."
        fi
    fi

    error "No input found. Pass a .deb path or place one official .deb in downloads/."
}

# Extract a .deb package into $WORK_DIR/deb-extract using dpkg-deb.
# Returns the path to the extracted root directory.
extract_deb() {
    local deb_path="$1"
    local extract_dir="$WORK_DIR/deb-extract"

    [ -f "$deb_path" ] || error "Input is not a file: $deb_path"
    require_cmd dpkg-deb

    rm -rf "$extract_dir"
    mkdir -p "$extract_dir"

    info "Extracting .deb with dpkg-deb"
    dpkg-deb -x "$deb_path" "$extract_dir" || error "Failed to extract .deb"

    echo "$extract_dir"
}

# Locate the CodeBuddy app payload directory inside the extracted .deb root.
# The official .deb installs to /opt/codebuddy-ide-cn/ (or similar).
locate_app_payload() {
    local extracted_root="$1"
    local app_dir

    # Try common installation prefixes
    for prefix in "opt/codebuddy-ide-cn" "opt/codebuddycn" "usr/lib/codebuddy-ide-cn" "usr/share/buddycn"; do
        if [ -d "$extracted_root/$prefix" ] && [ -f "$extracted_root/$prefix/resources/app/package.json" ]; then
            echo "$extracted_root/$prefix"
            return 0
        fi
    done

    # Fallback: search for a directory containing resources/app/package.json
    app_dir="$(find "$extracted_root" -maxdepth 5 -type f -path "*/resources/app/package.json" -print0 2>/dev/null | head -zn 1 | xargs -0 dirname | xargs dirname | xargs dirname || true)"
    if [ -n "$app_dir" ]; then
        echo "$app_dir"
        return 0
    fi

    error "Could not locate CodeBuddy app payload in extracted .deb"
}

# Detect the Electron version from the app's package.json.
detect_electron_version() {
    local app_dir="$1"
    local package_json="$app_dir/resources/app/package.json"
    local detected

    if [ -f "$package_json" ]; then
        detected="$(node -e 'const p=require(process.argv[1]); process.stdout.write(String(p.devDependencies?.electron || p.dependencies?.electron || ""));' "$package_json")"
        detected="${detected#^}"
        detected="${detected#~}"
        detected="${detected#v}"
        if [[ "$detected" =~ ^[0-9]+(\.[0-9]+){2}([.-][0-9A-Za-z]+)*$ ]]; then
            echo "$detected"
            return 0
        fi
    fi

    echo "$ELECTRON_VERSION"
}

# Read the upstream CodeBuddy version from the app's package.json.
read_app_version() {
    local app_dir="$1"
    local package_json="$app_dir/resources/app/package.json"

    if [ -f "$package_json" ]; then
        node -e 'const p=require(process.argv[1]); process.stdout.write(String(p.version || ""));' "$package_json"
        return 0
    fi

    echo ""
}

# Extract version string from .deb filename.
# Pattern: CodeBuddy-linux-x64-{version}.{build}-{hash}-cn.deb
# Returns: {version}.{build}--{hash}  (e.g. 4.10.0.32999201--c8bdde62)
extract_deb_version() {
    local deb_path="$1"
    local basename="${deb_path##*/}"

    if [[ "$basename" =~ CodeBuddy-linux-x64-([0-9]+\.[0-9]+\.[0-9]+)\.([0-9]+)-([0-9a-f]+)-cn\.deb ]]; then
        echo "${BASH_REMATCH[1]}.${BASH_REMATCH[2]}--${BASH_REMATCH[3]}"
        return 0
    fi

    return 1
}
