# CODEBUDDY.md This file provides guidance to CodeBuddy when working with code in this repository.

## Common Commands

### Build the full pipeline

```bash
make deps          # Install system dependencies (auto-detects apt/dnf/pacman/zypper)
make download      # Download official CodeBuddy IDE CN Linux x64 .deb from Tencent CDN
make build-app     # Convert .deb to loong64 Electron app in codebuddycn-app/
make package       # Auto-detect distro and build native loong64 package (.deb/.rpm/.pkg.tar.zst)
make install       # Install the built package
make appimage      # Build loong64 AppImage (requires build-app first)
```

### Build with custom input

```bash
make build-app DEB=/path/to/CodeBuddy.deb     # Custom .deb path
CODEBUDDY_INSTALL_DIR=/opt/custom make build-app  # Custom output dir
ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ make build-app  # Custom Electron mirror
ELECTRON_LOCAL_ZIP=/path/to/electron.zip make build-app  # Use local Electron zip
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

This project is an unofficial community tool that converts the official CodeBuddy IDE CN **Linux x64 .deb** package into a working **loong64 (LoongArch 64-bit)** Electron application. The tool **never redistributes** any Tencent binaries — all upstream content is downloaded locally by the user's machine via `make download` or provided as a local .deb file.

The generated application directory (`codebuddycn-app/`) and all packaging artifacts (`dist/`) are git-ignored. Only the conversion scripts, packaging templates, and documentation are tracked in this repository.

### Pipeline stages (in execution order)

1. **`install.sh`** — The central orchestrator. Sources the three library scripts below then executes the full pipeline: parse arguments → validate dependencies → resolve input (.deb) → extract .deb with `dpkg-deb -x` → locate app payload → detect Electron version from `package.json` → download loong64 Electron runtime → copy app payload to `resources/app` → rebuild all native Node modules for loong64 → generate launcher, desktop entry, and build metadata.

2. **`scripts/lib/common.sh`** — Shared logging (`info`/`warn`/`error`) and `require_cmd`.

3. **`scripts/lib/deb.sh`** — Input resolution and .deb extraction. `resolve_input_path` either uses the explicit .deb path or discovers the sole `.deb` in `downloads/`. `extract_deb` uses `dpkg-deb -x` to extract the .deb contents. `locate_app_payload` finds the CodeBuddy app directory inside the extracted tree (searches `/opt/codebuddy-ide-cn/` and similar paths). `detect_electron_version` reads `package.json` devDependencies. `read_app_version` extracts the upstream CodeBuddy version from `package.json`. `extract_deb_version` parses the deb filename to get the upstream version string.

4. **`scripts/lib/electron.sh`** — Loong64 Electron runtime download. `electron_arch()` maps `uname -m` values to Electron's naming. `map_loong64_electron_version()` matches the detected Electron version to the closest available community loong64 build (exact → same major → lower major → newest fallback) from `darkyzhou/electron-loong64`. `download_electron_runtime()` caches downloaded zips in `~/.cache/codebuddy-ide-cn-linux/electron/`, supports `ELECTRON_LOCAL_ZIP` for local zip files, `ELECTRON_MIRROR` for custom mirrors, and auto-configures the loong64 community mirror.

5. **`scripts/lib/native-modules.sh`** — Native Node module rebuild. The official x64 .deb ships pre-compiled native modules for x86_64. To run on loong64, each module is rebuilt from source: read version from in-tree `package.json`, download full source distribution from npm into an isolated build directory, install Electron headers, run `@electron/rebuild` against the target loong64 Electron to produce ELF `.node` binaries, then copy back into the app. Modules are categorized as **critical** (failure aborts build): `node-pty`, `native-keymap`, `native-watchdog`; and **optional** (failure logs warning but continues): `@vscode/spdlog`, `@vscode/sqlite3`, `kerberos`, `native-is-elevated`, `@vscode/policy-watcher`. `refresh_platform_packages` pulls fresh loong64-appropriate versions of `@vscode/ripgrep` and `@parcel/watcher` from npm.

### Package building

- **`scripts/build-deb.sh`** — Builds `.deb` using `dpkg-deb`. Files go to `/opt/codebuddy-ide-cn/`, creates `/usr/bin/codebuddy-ide-cn` launcher wrapper. Architecture is hardcoded as `loong64`. Version extracted from .deb filename pattern: `CodeBuddy-linux-x64-{version}.{build}-{hash}-cn.deb`.

- **`scripts/build-rpm.sh`** — Builds `.rpm` using `rpmbuild`. Architecture is hardcoded as `loongarch64`.

- **`scripts/build-pacman.sh`** — Builds `.pkg.tar.zst` using `makepkg`. Architecture is hardcoded as `loongarch64`.

- **`scripts/build-appimage.sh`** — Builds a loong64 AppImage using `linuxdeploy`. Copies the entire `codebuddycn-app/` into an AppDir structure under `usr/bin/`, supplies a custom AppRun wrapper, and invokes `linuxdeploy` with `--appimage-extract-and-run`. Uses `LINUXDEPLOY_ARCH=loongarch64`.

- **`scripts/package.sh`** — Auto-detection dispatcher. Detects the native package builder by checking for `dpkg-deb`, `rpmbuild`, or `makepkg` and delegates to the appropriate build script.

- **`scripts/install-package.sh`** — Finds the latest built package in `dist/` by timestamp and installs it using the appropriate package manager (`dpkg -i`, `dnf install`, `pacman -U`).

### Other scripts and templates

- **`scripts/install-deps.sh`** — One-shot dependency installer supporting five package managers (`apt`, `dnf5`, `dnf`, `pacman`, `zypper`). Installs: Node.js >=20 (from distro repos or NodeSource), C++ toolchain, X11/krb5/libsecret development headers, and packaging tools (`dpkg-dev`, `rpm-build`, `base-devel`). Architecture-aware for NodeSource: whitelists amd64, arm64, armhf, loong64.

- **`scripts/download.sh`** — Downloads the official .deb from Tencent CDN URL (configured in Makefile via `CB_VERSION`, `CB_BUILD`, `CB_HASH`). Moves any existing `.deb` files to `downloads/backups/` before downloading the new one. Skips if the exact filename already exists.

- **`packaging/linux/codebuddy-ide-cn.desktop`** — Desktop entry template with `__EXEC__` placeholder that gets substituted by each build script.

- **`packaging/linux/control`** — Debian control file template with `__PACKAGE_NAME__`, `__VERSION__`, `__ARCH__` placeholders.

### Key design decisions and invariants

- **No binary redistribution**: The repository must never contain .deb files, extracted bundles, or built packages. `downloads/`, `build/`, `codebuddycn-app/`, `dist/`, and `reference/` are all git-ignored.

- **Target architecture is loong64 only**: The tool is specifically designed to convert official x64 packages to loong64. Architecture is hardcoded, not auto-detected.

- **Version configuration is centralized** in the `Makefile` top section: `CB_VERSION`, `CB_BUILD`, `CB_HASH`. Update only these three values when a new upstream CodeBuddy version is released. The .deb URL is derived from these.

- **Electron version detection is automatic** from the app's `package.json`, not hardcoded. The `ELECTRON_VERSION` default (35.6.0) in `install.sh` is a fallback used only when detection fails.

- **Native module rebuild takes a "from-source" approach**: each module is fetched fresh from npm at the exact version installed in the app, then compiled from source against the correct loong64 Electron headers. This handles the case where the x64 .deb may ship modules without full source code.

- **loong64 Electron uses a community mirror** (`darkyzhou/electron-loong64`) with a version-matching algorithm that finds the closest available build, preferring same major or lower major over latest. Local zip files can be injected via `ELECTRON_LOCAL_ZIP` to bypass download.

- **Shell scripts all use** `set -Eeuo pipefail` for strict error handling, trap EXIT for cleanup of `$WORK_DIR` temp directories, and source `common.sh` for consistent logging.

### Verification workflow for new upstream versions

When a new CodeBuddy IDE CN version is released, the typical verification flow is:

1. Update `CB_VERSION`, `CB_BUILD`, `CB_HASH` in `Makefile` (extract from the new official download URL)
2. `make download` to fetch the new .deb
3. `make build-app` — the Electron version is auto-detected, no manual version update needed
4. `./codebuddycn-app/start.sh --verbose` — verify the app launches on loong64
5. If native module rebuild fails, check which module versions changed and update `critical_modules`/`optional_modules`/`refresh_platform_packages` lists as needed
6. `make package && make install` — verify packaging and installation
7. Check `build-info.json` in the installed app for correct version metadata

### Environment variables reference

| Variable | Purpose | Default |
|---|---|---|
| `CODEBUDDY_INSTALL_DIR` | Output directory for the built app | `./codebuddycn-app` |
| `CODEBUDDY_APP_ID` | Application ID for desktop entry | `codebuddy-ide-cn` |
| `ELECTRON_VERSION` | Electron runtime version (auto-detected from package.json) | `35.6.0` (fallback) |
| `ELECTRON_MIRROR` | Custom Electron download mirror | Community loong64 mirror |
| `ELECTRON_HEADERS_URL` | Electron headers dist URL for native rebuilds | `https://artifacts.electronjs.org/headers/dist` |
| `ELECTRON_LOCAL_ZIP` | Path to local Electron zip (skips download) | unset |
| `FORCE_ELECTRON_VERSION` | Force a specific Electron version, skip detection | unset |
| `PACKAGE_FORMAT` | Override auto-detected package format (`deb`/`rpm`/`pacman`) | auto-detected |
| `NODEJS_MAJOR` | Node.js major version to install (install-deps.sh) | `22` |
