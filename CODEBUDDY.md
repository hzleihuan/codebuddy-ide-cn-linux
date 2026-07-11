# CODEBUDDY.md This file provides guidance to CodeBuddy when working with code in this repository.

## Common Commands

### Build the full pipeline

```bash
make deps          # Install system dependencies (auto-detects apt/dnf/pacman/zypper)
make download      # Download official CodeBuddy IDE CN DMG from Tencent CDN
make build-app     # Convert DMG to Linux Electron app in codebuddycn-app/
make package       # Auto-detect distro and build native package (.deb/.rpm/.pkg.tar.zst)
make install       # Install the built package
make appimage      # Build cross-distro AppImage (requires build-app first)
```

### Build with custom input

```bash
make build-app DMG=/path/to/CodeBuddy.dmg     # Custom DMG path
CODEBUDDY_INSTALL_DIR=/opt/custom make build-app  # Custom output dir
ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ make build-app  # Custom Electron mirror
ELECTRON_LOCAL_ZIP=/path/to/electron.zip make build-app  # Use local Electron zip (loong64 etc.)
FORCE_ELECTRON_VERSION=35.4.0 make build-app  # Force specific Electron version
```

### Run and verify

```bash
make run-app       # Run the generated app without installing
make check         # Shell syntax validation for all scripts
make clean         # Remove codebuddycn-app, dist/
./codebuddycn-app/start.sh --verbose  # Run directly with debug output
```

### Individual package builders

```bash
make deb           # Build .deb only
make rpm           # Build .rpm only
make pacman        # Build .pkg.tar.zst only
```

## Architecture

### Overview

This project is an unofficial community tool that converts the official CodeBuddy IDE CN macOS Intel/x64 DMG installer into a working Linux Electron application. It references the `codex-desktop-linux` conversion pattern but does **not** port its auto-update module. The tool **never redistributes** any Tencent binaries — all upstream content is downloaded locally by the user's machine via `make download` or provided as a local DMG file.

The generated application directory (`codebuddycn-app/`) and all packaging artifacts (`dist/`) are git-ignored. Only the conversion scripts, packaging templates, and documentation are tracked in this repository.

### Pipeline stages (in execution order)

1. **`install.sh`** — The central orchestrator. Sources the four library scripts below then executes the full pipeline: parse arguments → validate dependencies → resolve input (DMG or .app) → detect Electron version from the macOS bundle → download matching Linux Electron runtime → copy app payload to resources/app → rebuild all native Node modules → generate launcher, desktop entry, icon, and build metadata.

2. **`scripts/lib/common.sh`** — Shared logging (`info`/`warn`/`error`), `require_cmd`, and `find_7z` which requires 7-Zip >= 21.x (rejects legacy p7zip 16.x that cannot correctly extract DMG files).

3. **`scripts/lib/dmg.sh`** — Input resolution and DMG extraction. `resolve_input_path` either uses the explicit DMG path, discovers the sole `.dmg` in `downloads/`, or falls back to a previously extracted `.app` bundle in `build/app-extracted/`. `resolve_app_bundle` extracts DMGs via `7z x -y -snl` and locates the `.app` directory. `detect_electron_version` reads `Electron Framework.framework/.../Info.plist` (preferred) or `package.json` devDependencies. `read_app_version` extracts the upstream CodeBuddy version from `Contents/Info.plist`.

4. **`scripts/lib/electron.sh`** — Linux Electron runtime download and loong64 architecture support. `electron_arch()` maps `uname -m` values to Electron's naming: x86_64→x64, aarch64→arm64, armv7l→armv7l, loongarch64→loong64. `map_loong64_electron_version()` matches the detected DMG Electron version to the closest available community loong64 build (exact → same major → lower major → newest fallback) from `darkyzhou/electron-loong64`. `download_electron_runtime()` caches downloaded zips in `~/.cache/codebuddy-ide-cn-linux/electron/`, supports `ELECTRON_LOCAL_ZIP` for local zip files, `ELECTRON_MIRROR` for custom mirrors, and auto-configures the loong64 community mirror when on that architecture.

5. **`scripts/lib/native-modules.sh`** — The most complex component. macOS DMG ships pre-compiled native modules **without** C++ source code (no `binding.gyp`, no `src/`), so direct `@electron/rebuild` is a no-op. The solution: for each native module found in the app's `node_modules`, read its version from `package.json`, download the full source distribution from npm into an isolated build directory, install Electron headers (skip binary), then run `@electron/rebuild` against the target Linux Electron to produce ELF `.node` binaries. The freshly built module is copied back into the app. Modules are categorized as **critical** (failure aborts build): `node-pty`, `native-keymap`, `native-watchdog`; and **optional** (failure logs warning but continues): `@vscode/spdlog`, `@vscode/sqlite3`, `kerberos`, `native-is-elevated`, `@vscode/policy-watcher`. Before rebuilding, `remove_known_wrong_platform_modules` strips Windows/macOS-only modules, and `refresh_platform_packages` pulls fresh Linux-appropriate versions of `@vscode/ripgrep` and `@parcel/watcher` from npm. `purge_macho_native_modules` scans for any remaining Mach-O `.node` files and deletes them.

### Package building

- **`scripts/build-deb.sh`** — Builds `.deb` using `dpkg-deb`. Files go to `/opt/codebuddy-ide-cn/`, creates `/usr/bin/codebuddy-ide-cn` launcher wrapper. Architecture whitelist: amd64, arm64, armhf, loong64.

- **`scripts/build-rpm.sh`** — Builds `.rpm` using `rpmbuild`. Generates a `.spec` file with correct `BuildArch`, Requires, and Conflicts. Architecture whitelist: x86_64, aarch64, loongarch64.

- **`scripts/build-pacman.sh`** — Builds `.pkg.tar.zst` using `makepkg` with a self-contained PKGBUILD. Architecture whitelist: x86_64, aarch64, loongarch64.

- **`scripts/build-appimage.sh`** — Builds a universal AppImage using `linuxdeploy`. Copies the entire `codebuddycn-app/` into an AppDir structure under `usr/bin/`, supplies a custom AppRun wrapper, and invokes `linuxdeploy` with `--appimage-extract-and-run` (no FUSE required at build time). Uses dynamic `LINUXDEPLOY_ARCH` for multi-arch support.

- **`scripts/package.sh`** — Auto-detection dispatcher. Detects the native package builder by checking for `dpkg-deb`, `rpmbuild`, or `makepkg` and delegates to the appropriate build script.

- **`scripts/install-package.sh`** — Finds the latest built package in `dist/` by timestamp and installs it using the appropriate package manager (`dpkg -i`, `dnf install`, `pacman -U`).

### Other scripts and templates

- **`scripts/install-deps.sh`** — One-shot dependency installer supporting five package managers (`apt`, `dnf5`, `dnf`, `pacman`, `zypper`). Installs: 7zip (>=21), Node.js >=20 (from distro repos or NodeSource), C++ toolchain, X11/krb5/libsecret development headers, and packaging tools. Architecture-aware for NodeSource: whitelists amd64, arm64, armhf, loong64.

- **`scripts/download.sh`** — Downloads the official DMG from Tencent CDN URL (configured in Makefile via `CB_VERSION`, `CB_BUILD`, `CB_HASH`). Moves any existing `.dmg` files to `downloads/backups/` before downloading the new one. Skips if the exact filename already exists.

- **`packaging/linux/codebuddy-ide-cn.desktop`** — Desktop entry template with `__EXEC__` placeholder that gets substituted by each build script.

- **`packaging/linux/control`** — Debian control file template with `__PACKAGE_NAME__`, `__VERSION__`, `__ARCH__` placeholders.

### Key design decisions and invariants

- **No binary redistribution**: The repository must never contain DMG files, `.app` bundles, or built Linux packages. `downloads/`, `build/`, `codebuddycn-app/`, `dist/`, and `reference/` are all git-ignored.

- **Version configuration is centralized** in the `Makefile` top section: `CB_VERSION`, `CB_BUILD`, `CB_HASH`. Update only these three values when a new upstream CodeBuddy version is released. The DMG URL is derived from these.

- **Electron version detection is automatic** from the DMG content, not hardcoded. The `ELECTRON_VERSION` default (35.6.0) in `install.sh` is a fallback used only when detection fails.

- **Native module rebuild takes a "from-source" approach** rather than trying to patch the macOS payload's pre-built binaries. Each module is fetched fresh from npm at the exact version installed in the app, then compiled from source against the correct Electron headers.

- **loong64 architecture support** uses a community Electron mirror (`darkyzhou/electron-loong64`) with a version-matching algorithm that finds the closest available build to the DMG's Electron version, preferring same major or lower major over latest. Local zip files can be injected via `ELECTRON_LOCAL_ZIP`.

- **AppImage uses dynamic `uname -m`** for `LINUXDEPLOY_URL`, `LINUXDEPLOY_BIN`, and `ARCH` to support non-x86_64 architectures.

- **Shell scripts all use** `set -Eeuo pipefail` for strict error handling, trap EXIT for cleanup of `$WORK_DIR` temp directories, and source `common.sh` for consistent logging.

### Verification workflow for new upstream versions

When a new CodeBuddy IDE CN version is released, the typical verification flow is:

1. Update `CB_VERSION`, `CB_BUILD`, `CB_HASH` in `Makefile`
2. `make download` to fetch the new DMG
3. `make build-app` — the Electron version is auto-detected, no manual version update needed
4. `./codebuddycn-app/start.sh --verbose` — verify the app launches
5. If native module rebuild fails, check which module versions changed and update `critical_modules`/`optional_modules`/`refresh_platform_packages` lists as needed
6. `make package && make install` — verify packaging and installation
7. Check `build-info.json` in the installed app for correct version metadata

### Environment variables reference

| Variable | Purpose | Default |
|---|---|---|
| `CODEBUDDY_INSTALL_DIR` | Output directory for the built app | `./codebuddycn-app` |
| `CODEBUDDY_APP_ID` | Application ID for desktop entry | `codebuddy-ide-cn` |
| `ELECTRON_VERSION` | Electron runtime version (auto-detected from DMG) | `35.6.0` (fallback) |
| `ELECTRON_MIRROR` | Custom Electron download mirror | Official GitHub releases |
| `ELECTRON_HEADERS_URL` | Electron headers dist URL for native rebuilds | `https://artifacts.electronjs.org/headers/dist` |
| `ELECTRON_LOCAL_ZIP` | Path to local Electron zip (skips download, for loong64 etc.) | unset |
| `FORCE_ELECTRON_VERSION` | Force a specific Electron version, skip DMG detection | unset |
| `PACKAGE_FORMAT` | Override auto-detected package format (`deb`/`rpm`/`pacman`) | auto-detected |
| `NODEJS_MAJOR` | Node.js major version to install (install-deps.sh) | `22` |
