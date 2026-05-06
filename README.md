[English](#english) | [简体中文](#简体中文)

# 简体中文

# CodeBuddy IDE CN for Linux

这是一个非官方社区工具，用于把用户自己拥有的官方 CodeBuddy IDE CN macOS Intel/x64 DMG 转换成本地 Linux Electron 应用。

本仓库刻意只做转换器，不作为再分发渠道。请从官方网站下载 Intel/x64 版本的官方 DMG，把它放在 `downloads/`；生成的应用目录和包产物只保留在本地，并已被 Git 忽略。

## 状态

当前项目提供 Linux 侧转换和打包骨架：

- 使用 `7z`/`7zz` 自动提取 `downloads/` 中唯一的官方 DMG；
- 从 macOS bundle 元数据中检测上游 Electron 版本；
- 下载匹配的 Linux Electron runtime；
- 将 CodeBuddy 应用载荷复制到 `resources/app`；
- 使用 `@electron/rebuild` 为 Linux/Electron 重建原生 Node 模块；
- 刷新 Linux 平台相关包，例如 `@vscode/ripgrep`；
- 写入 Linux 启动器和桌面入口；
- 根据当前发行版生成本地 `.deb`、`.rpm` 或 `.pkg.tar.zst` 包。

这套脚本是在 Windows 上准备的，所以构建脚本需要在 Linux 机器上验证。项目不包含自动更新程序；更新时请手动下载新版官方 DMG，放入 `downloads/` 后重新运行构建和安装流程覆盖本地安装。

## 快速流程

把唯一一个官方 Intel/x64 DMG 放入 `downloads/`，然后运行：

```bash
bash scripts/install-deps.sh
make build-app
make package
make install
```

`scripts/install-deps.sh` 会按发行版检测 `apt`、`dnf5`、`dnf`、`pacman` 或 `zypper`，并安装提取 DMG、下载 Electron runtime、重建原生 Node 模块和生成本地包所需的依赖。

## 构建

推荐方式：把唯一一个 `.dmg` 放在 `downloads/` 后直接构建：

```bash
make build-app
```

也可以传入某个官方 DMG 路径；这只是输入路径，不代表绑定某个版本：

```bash
make build-app DMG=/path/to/CodeBuddy.dmg
```

运行生成的应用：

```bash
make run-app
```

从生成的应用自动构建当前发行版对应的包并安装：

```bash
make package
make install
```

## 工作原理

本项目借鉴了 `codex-desktop-linux` 的本地转换和打包流程，但不移植它的自动更新程序：

1. 将官方 macOS DMG 视为用户提供的输入。
2. 提取 Electron 应用载荷，而不是分发该载荷。
3. 用匹配的 Linux Electron runtime 替换 macOS Electron runtime。
4. 基于 Linux Electron headers 重建原生 Node 模块。
5. 刷新平台相关二进制包。
6. 在本地生成 Linux 启动和包元数据。
7. 根据当前发行版生成本地包，并由 `make install` 安装最新生成的产物。

CodeBuddy IDE CN 基于 VS Code/Electron。macOS 应用已经在 `Contents/Resources/app` 下包含跨平台 JavaScript 应用；Linux 转换主要负责替换平台二进制并重新编译原生模块。

## 常用覆盖项

```bash
CODEBUDDY_INSTALL_DIR=/opt/tmp/codebuddycn-app bash install.sh
ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ bash install.sh
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist bash install.sh
```

## 仓库维护规范

以下路径会被 Git 忽略，因为它们可能包含上游软件或生成的包载荷：

- `downloads/`
- `build/`
- `codebuddycn-app/`
- `dist/`
- `reference/`

不要提交 DMG、解包后的 `.app` bundle、生成的 Linux 应用目录或原生包产物。

## 免责声明

这是一个非官方的社区项目。CodeBuddy IDE CN 是 腾讯 的产品（版权 © 2026 腾讯云计算（北京）有限责任公司丨腾讯科技（深圳）有限公司 版权所有）。本工具不重新分发任何 CodeBuddy IDE CN 的软件；它只是自动化了用户对自己拥有的副本进行转换的过程。

## 许可证

MIT。见 [LICENSE](LICENSE)。

# English

# CodeBuddy IDE CN for Linux

Unofficial community tooling for converting a user-owned official CodeBuddy IDE CN macOS Intel/x64 DMG into a local Linux Electron application.

This repository is intentionally a converter, not a redistribution channel. Download the official Intel/x64 DMG from the official website and place it in `downloads/`; generated app folders and package artifacts stay local and are ignored by Git.

## Status

This project currently provides the Linux-side conversion and packaging skeleton:

- automatically extracts the single official DMG placed in `downloads/` with `7z`/`7zz`;
- detects the upstream Electron version from the macOS bundle metadata;
- downloads the matching Linux Electron runtime;
- copies the CodeBuddy application payload into `resources/app`;
- rebuilds native Node modules for Linux/Electron with `@electron/rebuild`;
- refreshes Linux platform packages such as `@vscode/ripgrep`;
- writes a Linux launcher and desktop entry;
- builds a local `.deb`, `.rpm`, or `.pkg.tar.zst` package for the current distro.

I have prepared this from Windows, so the build scripts are meant to be validated on a Linux machine. This project does not include an auto-updater; to update, manually download a newer official DMG, place it in `downloads/`, then rerun the build and install flow to overwrite the local install.

## Quick Flow

Place exactly one official Intel/x64 DMG in `downloads/`, then run:

```bash
bash scripts/install-deps.sh
make build-app
make package
make install
```

`scripts/install-deps.sh` detects `apt`, `dnf5`, `dnf`, `pacman`, or `zypper` and installs the dependencies needed to extract DMGs, download the Electron runtime, rebuild native Node modules, and produce a local package.

## Build

Recommended: place exactly one `.dmg` in `downloads/`, then build:

```bash
make build-app
```

You can also pass an official DMG path. This is only an input path and does not bind the project to a specific version:

```bash
make build-app DMG=/path/to/CodeBuddy.dmg
```

Run the generated app:

```bash
make run-app
```

Build and install the native package for the current distro:

```bash
make package
make install
```

## How It Works

The approach is modeled after the local conversion and packaging flow in `codex-desktop-linux`, without porting its auto-updater:

1. Treat the official macOS DMG as a user-provided input.
2. Extract the Electron app payload instead of distributing it.
3. Replace the macOS Electron runtime with the matching Linux Electron runtime.
4. Rebuild native Node modules against Linux Electron headers.
5. Refresh platform-specific binary packages.
6. Generate Linux launch and package metadata locally.
7. Build a native package for the current distro, then install the newest generated artifact with `make install`.

CodeBuddy IDE CN is VS Code/Electron based. The macOS app already contains a cross-platform JavaScript application under `Contents/Resources/app`; the Linux conversion mainly replaces platform binaries and recompiles native modules.

## Useful Overrides

```bash
CODEBUDDY_INSTALL_DIR=/opt/tmp/codebuddycn-app bash install.sh
ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ bash install.sh
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist bash install.sh
```

## Repository Hygiene

The following paths are ignored by Git because they can contain upstream software or generated package payloads:

- `downloads/`
- `build/`
- `codebuddycn-app/`
- `dist/`
- `reference/`

Do not commit DMGs, extracted `.app` bundles, generated Linux app directories, or native package artifacts.

## Disclaimer

This is an unofficial community project. CodeBuddy IDE CN is a product of Tencent (copyright © 2026 Tencent Cloud Computing (Beijing) Co., Ltd. and Tencent Technology (Shenzhen) Co., Ltd. All rights reserved). This tool does not redistribute any CodeBuddy IDE CN software; it only automates the conversion process that users perform on copies they own.

## License

MIT. See [LICENSE](LICENSE).
