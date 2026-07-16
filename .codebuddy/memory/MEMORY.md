# Long-term memory for codebuddy-ide-cn-linux project

## Project purpose (updated 2026-07-11)
This project now converts the **official CodeBuddy IDE CN Linux x64 .deb** package into a **loong64 (LoongArch)** compatible application. Previously it converted macOS DMG → Linux, but since the official Linux x64 .deb is now available, the project was repurposed.

## Key architecture notes
- Input: official Linux x64 .deb from `https://download.codebuddy.cn/aiide/linux-x64/`
- Extraction: `ar x` + `tar` (from upstream's deb.sh; no dpkg-deb needed)
- Electron: community loong64 mirror at `darkyzhou/electron-loong64`, downloaded by `scripts/lib/electron.sh`
- Native modules: **always rebuilt from source** via `@electron/rebuild` against loong64 Electron headers (x64 .node files from .deb are unusable on loong64)
- Target architecture: **loong64 only** (hardcoded, not auto-detected)
- Current version: 4.10.1 (build 33158423, hash 3ad58bcb)

## Rebase on upstream (2026-07-16)
- The codebase was **hard-reset to upstream/main** (`4f11594`), then loong64-specific changes were re-applied on top.
- Key loong64 changes on top of upstream: (1) `scripts/lib/electron.sh` — new file for loong64 Electron download/mirror; (2) `install.sh` — sources electron.sh, downloads loong64 Electron, launcher uses `electron` binary instead of `bin/buddycn`, copies only `resources/app` (not x64 electron); (3) `scripts/lib/native-modules.sh` — always rebuilds all native modules (removes upstream's "skip if .node exists" logic); (4) `scripts/lib/appimage.sh` — architecture-agnostic linuxdeploy (uses `uname -m`); (5) `scripts/build-{deb,rpm,pacman}.sh` — hardcoded loong64/loongarch64 ARCH; (6) `scripts/install-deps.sh` — NodeSource loong64 whitelist + `unzip` dep; (7) `Makefile` — loongarch64 AppImage config; (8) `.aur/PKGBUILD` — loongarch64 arch, our repo URL; (9) `README.md` — loong64-focused; (10) `CODEBUDDY.md` — preserved.
- Upstream improvements retained: `ar x`+`tar` .deb extraction, `remove_known_wrong_platform_modules()`, `purge_macho_native_modules()`, ImageMagick icon resize, desktop entry extraction from .deb, CI/CD workflows.

## Upstream remotes
- `origin` = `hzleihuan/codebuddy-ide-cn-loong64` (our fork/mainline we track & push)
- `upstream` = `JipZeonGit/codebuddy-ide-cn-linux` (reference upstream)
- Both ship CodeBuddy 4.10.1. `upstream/main` HEAD = `4f11594`.
