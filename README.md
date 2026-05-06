[English](#english) | [简体中文](#简体中文)

# 简体中文

# CodeBuddy IDE CN for Linux

这是一个非官方社区工具，用于把用户自己拥有的 macOS `CodeBuddy CN.app` 或官方 CodeBuddy IDE CN DMG 转换成本地 Linux Electron 应用。

本仓库刻意只做转换器，不作为再分发渠道。请把你自己的官方 DMG 放在 `downloads/`，或在运行安装器时传入 DMG 路径；生成的应用目录和包产物只保留在本地，并已被 Git 忽略。

## 状态

当前项目提供 Linux 侧转换和打包骨架：

- 使用 `7z`/`7zz` 提取官方 DMG，或复用已经解包的 `.app`；
- 从 macOS bundle 元数据中检测上游 Electron 版本；
- 下载匹配的 Linux Electron runtime；
- 将 CodeBuddy 应用载荷复制到 `resources/app`；
- 使用 `@electron/rebuild` 为 Linux/Electron 重建原生 Node 模块；
- 写入 Linux 启动器和桌面入口；
- 可选生成本地 `.deb` 包。

这套脚本是在 Windows 上准备的，所以构建脚本需要在 Linux 机器上验证。

## 依赖

Debian/Ubuntu：

```bash
sudo apt update
sudo apt install -y bash curl unzip p7zip-full python3 nodejs npm build-essential libx11-dev libxkbfile-dev libsecret-1-dev
```

其他发行版请安装等价依赖：`bash`、`curl`、`unzip`、`7z` 或 `7zz`、`python3`、`node`、`npm`、`make`、`g++`、X11 头文件、`libxkbfile` 和 `libsecret`。

## 构建

使用本地官方 DMG：

```bash
make build-app DMG=/path/to/CodeBuddy-darwin-x64-4.9.8.26735874-04507acd-cn.dmg
```

或把唯一一个 `.dmg` 放在 `downloads/`：

```bash
make build-app
```

运行生成的应用：

```bash
make run-app
```

从生成的应用构建 Debian 包：

```bash
make deb
sudo dpkg -i dist/codebuddycn-ide_*.deb
```

## 工作原理

本项目借鉴了 `codex-desktop-linux` 的本地转换流程：

1. 将官方 macOS 应用视为用户提供的输入。
2. 提取 Electron 应用载荷，而不是分发该载荷。
3. 用匹配的 Linux Electron runtime 替换 macOS Electron runtime。
4. 基于 Linux Electron headers 重建原生 Node 模块。
5. 在本地生成 Linux 启动和包元数据。

CodeBuddy IDE CN 基于 VS Code/Electron。macOS 应用已经在 `Contents/Resources/app` 下包含跨平台 JavaScript 应用；Linux 转换主要负责替换平台二进制并重新编译原生模块。

## 常用覆盖项

```bash
CODEBUDDY_INSTALL_DIR=/opt/tmp/codebuddycn-app bash install.sh /path/to/app.dmg
ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ bash install.sh /path/to/app.dmg
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist bash install.sh /path/to/app.dmg
```

## 仓库卫生

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

Unofficial community tooling for converting a user-owned macOS `CodeBuddy CN.app` or official CodeBuddy IDE CN DMG into a local Linux Electron application.

This repository is intentionally a converter, not a redistribution channel. Put your own official DMG in `downloads/` or pass its path to the installer; generated app folders and package artifacts stay local and are ignored by Git.

## Status

This project currently provides the Linux-side conversion and packaging skeleton:

- extracts an official DMG with `7z`/`7zz`, or reuses an already extracted `.app`;
- detects the upstream Electron version from the macOS bundle metadata;
- downloads the matching Linux Electron runtime;
- copies the CodeBuddy application payload into `resources/app`;
- rebuilds native Node modules for Linux/Electron with `@electron/rebuild`;
- writes a Linux launcher and desktop entry;
- optionally builds a local `.deb` package.

I have prepared this from Windows, so the build scripts are meant to be validated on a Linux machine.

## Prerequisites

On Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y bash curl unzip p7zip-full python3 nodejs npm build-essential libx11-dev libxkbfile-dev libsecret-1-dev
```

For other distros, install equivalent packages for `bash`, `curl`, `unzip`, `7z` or `7zz`, `python3`, `node`, `npm`, `make`, `g++`, X11 headers, `libxkbfile`, and `libsecret`.

## Build

Use a local official DMG:

```bash
make build-app DMG=/path/to/CodeBuddy-darwin-x64-4.9.8.26735874-04507acd-cn.dmg
```

Or place exactly one `.dmg` in `downloads/`:

```bash
make build-app
```

Run the generated app:

```bash
make run-app
```

Build a Debian package from the generated app:

```bash
make deb
sudo dpkg -i dist/codebuddycn-ide_*.deb
```

## How It Works

The approach is modeled after the local conversion flow in `codex-desktop-linux`:

1. Treat the official macOS app as a user-provided input.
2. Extract the Electron app payload instead of distributing it.
3. Replace the macOS Electron runtime with the matching Linux Electron runtime.
4. Rebuild native Node modules against Linux Electron headers.
5. Generate Linux launch and package metadata locally.

CodeBuddy IDE CN is VS Code/Electron based. The macOS app already contains a cross-platform JavaScript application under `Contents/Resources/app`; the Linux conversion mainly replaces platform binaries and recompiles native modules.

## Useful Overrides

```bash
CODEBUDDY_INSTALL_DIR=/opt/tmp/codebuddycn-app bash install.sh /path/to/app.dmg
ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ bash install.sh /path/to/app.dmg
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist bash install.sh /path/to/app.dmg
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
