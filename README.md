# CodeBuddy IDE CN for Linux (Unofficial)

[English](#english) | [简体中文](#简体中文)

---

# 简体中文

## 项目简介

这是一款非官方社区工具，核心作用是将官方 CodeBuddy IDE CN macOS Intel/x64 版本 DMG 安装包，转换为可在本地 Linux 系统运行的 Electron 应用。

本仓库**仅作为转换工具**，绝不充当软件分发渠道。所有官方安装包由用户机器自行从腾讯官方 CDN 下载，所有生成的应用目录、安装包产物均仅保留在本地，已加入 Git 忽略规则，不会被提交至仓库。

遇到任何 Bug 请在此仓库提 Issue，严禁向腾讯官方客服反馈在 Linux 移植后使用的相关问题。请勿在腾讯 CodeBuddy 官方用户群、社交媒体讨论本项目，本项目应保持低调维护。

## 快速安装

### Arch Linux / CachyOS / Manjaro 等 Arch 系发行版

直接通过 AUR 安装，无需 clone 本仓库：

```bash
yay -S codebuddy-cn-ide
# 或者
paru -S codebuddy-cn-ide
```

也可以手动构建：

```bash
git clone https://aur.archlinux.org/codebuddy-cn-ide.git
cd codebuddy-cn-ide
makepkg -si
```

AUR 包页面：<https://aur.archlinux.org/packages/codebuddy-cn-ide>

> 构建过程会自动从腾讯官方 CDN 下载约 180 MB 的官方 DMG，请保持网络畅通。本仓库与 AUR 包均不重新分发任何腾讯软件二进制。

### 其他 Linux 发行版（Debian / Ubuntu / Linux Mint / Fedora / openSUSE 等）

1. 克隆本项目至本地 Linux 机器；
2. 在项目根目录创建 `downloads` 文件夹；
3. 自行从官方网站下载 Intel/x64 架构 DMG 安装包，放入 `downloads/` 目录；
4. 依次执行：

```bash
bash scripts/install-deps.sh
make build-app
make package
make install
```

`scripts/install-deps.sh` 会自动识别当前系统的包管理器（支持 `apt`、`dnf5`、`dnf`、`pacman`、`zypper`），一键安装 DMG 提取、Electron 运行时下载、原生模块重建、安装包生成所需的全部依赖。

## 项目状态

目前项目已完整实现 Linux 端的转换与打包核心流程，具体功能如下：

- 借助 `7z`/`7zz` 工具，自动提取 `downloads/` 目录下的官方 DMG 安装包；
- 从 macOS 应用包元数据中，自动识别上游 Electron 版本号；
- 下载与识别版本匹配的 Linux 版 Electron 运行时；
- 将 CodeBuddy 应用核心程序复制至 `resources/app` 目录；
- 通过 `@electron/rebuild` 针对 Linux 系统与 Electron 环境重建原生 Node 模块；
- 更新适配 Linux 平台的依赖包，例如 `@vscode/ripgrep`；
- 自动生成 Linux 系统启动器与桌面入口文件；
- 根据当前 Linux 发行版，一键生成适配的 `.deb`、`.rpm` 或 `.pkg.tar.zst` 格式安装包；
- 通过 AUR 上架 `codebuddy-cn-ide`，Arch 系用户可一键安装。

> 测试范围：已在 Debian 系（Linux Mint 22.3）和 Arch 系（CachyOS）完成完整打包部署实测，运行稳定。
> 项目**未集成自动更新功能**。如需更新软件，只需手动下载新版官方 DMG 后重新执行构建流程即可覆盖本地旧版本；AUR 用户等包升级 push 后正常 `yay -Syu` 即可。

## 构建与运行

### 推荐构建方式

将官方 DMG 文件放入 `downloads/` 目录后，直接执行：

```bash
make build-app
```

### 自定义 DMG 路径

也可手动指定官方 DMG 文件路径：

```bash
make build-app DMG=/path/to/CodeBuddy.dmg
```

### 运行生成的应用

```bash
make run-app
```

### 打包并安装

自动生成适配当前发行版的安装包，并完成本地安装：

```bash
make package
make install
```

## 实现原理

本项目参考了 `codex-desktop-linux` 的本地转换与打包逻辑，但**未移植其自动更新模块**，核心流程如下：

1. 以用户自行提供（或由 AUR 包自动从官方 CDN 下载）的官方 macOS DMG 安装包作为输入源；
2. 仅提取 Electron 应用核心程序，不对外分发任何官方软件内容；
3. 用对应版本的 Linux Electron 运行时，替换原 macOS 版运行时；
4. **原生模块从源码拉取与重新编译**：由于 macOS DMG 预打包的原生模块（如 `node-pty`）被剥离了 C++ 源码与构建配置（导致直接 `@electron/rebuild` 失败），本工具会自动从 npm 下载对应版本的完整源码，在隔离目录基于 Linux Electron 头文件重新编译为 ELF 二进制文件，再覆盖回应用目录；
5. 更新适配 Linux 平台的专属二进制依赖包；
6. 本地生成 Linux 系统启动配置与安装包元数据；
7. 编译生成对应发行版的原生安装包，通过 `make install` 或 AUR helper 完成安装。

CodeBuddy IDE CN 基于 VS Code/Electron 开发，其 macOS 应用的 `Contents/Resources/app` 目录下已包含跨平台 JavaScript 核心代码，Linux 转换只需完成平台二进制文件替换、原生模块重新编译即可实现兼容。

## 常用自定义配置

如需自定义安装路径、切换 Electron 镜像，可通过以下命令执行：

```bash
# 自定义安装目录
CODEBUDDY_INSTALL_DIR=/opt/tmp/codebuddycn-app bash install.sh
# 切换 Electron 镜像源
ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ bash install.sh
# 自定义 Electron 头文件下载地址
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist bash install.sh
```

## 版本适配说明

当前转换流程基于官方 CodeBuddy IDE CN **4.9.9**（构建号 `27861944-19255a94-cn`）验证通过。更高版本的 DMG 可能因为上游代码结构变化导致流程失败。如遇到构建失败或运行异常，请在本仓库提 Issue 并附上所使用的 DMG 版本号。

## 仓库维护规范

以下目录因会存放上游软件、生成类安装包文件，已被 Git 忽略，**切勿手动提交**：

- `downloads/`
- `build/`
- `codebuddycn-app/`
- `dist/`
- `reference/`

禁止提交 DMG 安装包、解压后的 `.app` 应用包、生成的 Linux 应用目录及各类原生安装包产物。

## 免责声明

本项目为**非官方社区开源工具**，与腾讯官方无任何关联。CodeBuddy IDE CN 是腾讯旗下产品，版权归腾讯所有，详细版权信息请参阅官方网站。本工具不分发任何 CodeBuddy IDE CN 官方软件，仅自动化实现用户对自有正版安装包的格式转换流程。

使用本工具产生的 CodeBuddy 应用受腾讯官方协议约束：

- CodeBuddy 服务条款：<https://cloud.tencent.com/document/product/301/106125>
- CodeBuddy 用户隐私协议：<https://privacy.qq.com/document/preview/284d799a07164d09bfc7cedd0ec3e089>

使用本工具即表示您已知悉并同意以下内容：

1. **用户责任**：您有责任确保自行获取的 DMG 安装包来源合法，并遵守 CodeBuddy 的最终用户许可协议（EULA）及相关服务条款。
2. **无担保**：本工具按"现状"提供，不提供任何形式的明示或暗示担保，包括但不限于对适销性、特定用途适用性和非侵权性的担保。
3. **无官方支持**：本项目是独立社区项目，腾讯官方不对本工具提供任何技术支持。在 Linux 移植环境下遇到的问题，请在本仓库提 Issue，**严禁向官方客服反馈**。
4. **风险自担**：使用本工具进行格式转换和运行所产生的一切后果，由用户自行承担。
5. **商标声明**：CodeBuddy 相关标识是腾讯公司的商标或注册商标。本项目使用这些名称仅用于描述性目的，不暗示任何官方认可或授权。
6. **下架预案**：如腾讯或任何相关权利方对本项目存在异议，请通过本仓库 Issue 或邮件联系维护者。维护者承诺在收到合理异议后立即停止维护、下架 AUR 包，并按权利方要求处理 GitHub 仓库。

## 开源许可证

本项目（PKGBUILD、转换脚本及相关 recipe）采用 MIT 开源许可证，详见 [LICENSE](LICENSE)。MIT 许可仅覆盖本仓库中的转换工具，**不延伸到通过本工具安装的腾讯 CodeBuddy IDE 二进制文件**——后者仍受腾讯官方私有协议约束。

---

# English

## Project Introduction

This is an unofficial community tool designed to convert the official CodeBuddy IDE CN macOS Intel/x64 DMG installer into a local Linux Electron application.

This repository **serves solely as a converter** and is never a software redistribution channel. The official installer is downloaded by the user's own machine directly from Tencent's official CDN. All generated application directories and package artifacts are stored locally only and are added to Git ignore rules.

If you encounter bugs, please submit an Issue here. Do not contact Tencent official customer service to report Linux porting issues. Please do not promote this project in CodeBuddy official user groups or social media; this project is intended to be maintained quietly.

## Quick Install

### Arch Linux / CachyOS / Manjaro and other Arch-based distros

Install directly from the AUR, no need to clone this repository:

```bash
yay -S codebuddy-cn-ide
# or
paru -S codebuddy-cn-ide
```

Or build manually:

```bash
git clone https://aur.archlinux.org/codebuddy-cn-ide.git
cd codebuddy-cn-ide
makepkg -si
```

AUR package page: <https://aur.archlinux.org/packages/codebuddy-cn-ide>

> The build process automatically downloads ~180 MB of the official DMG from Tencent's CDN. Neither this repository nor the AUR package re-distributes any Tencent binary.

### Other Linux distros (Debian / Ubuntu / Linux Mint / Fedora / openSUSE etc.)

1. Clone this repository to your local Linux machine;
2. Create a `downloads/` folder in the project root;
3. Download the official Intel/x64 DMG installer yourself and place it in `downloads/`;
4. Run:

```bash
bash scripts/install-deps.sh
make build-app
make package
make install
```

`scripts/install-deps.sh` automatically detects the package manager (`apt`, `dnf5`, `dnf`, `pacman`, `zypper`) and installs all dependencies needed for DMG extraction, Electron runtime download, native module rebuilding and package generation.

## Project Status

The project fully implements the core Linux-side conversion and packaging workflow:

- Auto-extract the official DMG installer in `downloads/` via `7z`/`7zz`;
- Detect the upstream Electron version from the macOS application bundle metadata;
- Download the matching Linux Electron runtime;
- Copy the core CodeBuddy application payload to the `resources/app` directory;
- Rebuild native Node modules for Linux + Electron via `@electron/rebuild`;
- Update Linux platform-adapted dependencies such as `@vscode/ripgrep`;
- Auto-generate Linux system launcher and desktop entry files;
- Generate distro-native `.deb`, `.rpm` or `.pkg.tar.zst` packages;
- Distributed through AUR as `codebuddy-cn-ide` for one-click installation on Arch-based distros.

> Testing scope: fully tested on Debian-based (Linux Mint 22.3) and Arch-based (CachyOS) systems.
> No auto-update feature is integrated. To update, manually download the latest official DMG and re-run the build flow; AUR users get updates via standard `yay -Syu` once the AUR package is bumped.

## Build & Run

### Recommended Build Method

Place the official DMG in `downloads/` and run:

```bash
make build-app
```

### Custom DMG Path

You can also manually specify the path of the official DMG file:

```bash
make build-app DMG=/path/to/CodeBuddy.dmg
```

### Run the Generated Application

```bash
make run-app
```

### Package & Install

Generate a distribution-compatible package and install it locally:

```bash
make package
make install
```

## How It Works

This project references the local conversion and packaging logic of `codex-desktop-linux`, but **does not port its auto-update module**. The core workflow:

1. Take the official macOS DMG installer (provided by the user or fetched by the AUR package from Tencent's CDN) as the input source;
2. Only extract the core Electron application payload without redistributing any official software content;
3. Replace the macOS Electron runtime with the matching Linux Electron runtime;
4. **Recompile native Node modules from source**: because the pre-packaged native modules in the macOS DMG (e.g., `node-pty`) are stripped of C++ source files and build configurations (which causes direct `@electron/rebuild` to fail), this tool downloads each module's full source from npm and rebuilds it as Linux ELF binaries against the Linux Electron headers in an isolated directory, then replaces the original modules;
5. Update platform-specific binary dependencies adapted for Linux;
6. Generate Linux system startup configuration and package metadata locally;
7. Compile a native package for the current distribution and install via `make install` or an AUR helper.

CodeBuddy IDE CN is built on VS Code/Electron. Cross-platform JavaScript core code already lives under `Contents/Resources/app` of the macOS bundle, so Linux compatibility is achieved by replacing platform binaries and recompiling native modules.

## Useful Custom Configurations

```bash
# Custom installation directory
CODEBUDDY_INSTALL_DIR=/opt/tmp/codebuddycn-app bash install.sh
# Switch Electron mirror source
ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ bash install.sh
# Custom Electron headers download URL
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist bash install.sh
```

## Version Compatibility

The current conversion workflow has been verified against official CodeBuddy IDE CN **4.9.9** (build `27861944-19255a94-cn`). Higher versions of the DMG may have upstream code structure changes that prevent the flow from completing. If you encounter build failures or runtime issues, please file an Issue with the DMG version number.

## Repository Maintenance Rules

The following directories are ignored by Git because they hold upstream software and generated package files. **Never commit them manually**:

- `downloads/`
- `build/`
- `codebuddycn-app/`
- `dist/`
- `reference/`

Committing DMG installers, extracted `.app` bundles, generated Linux application directories and native package artifacts is prohibited.

## Disclaimer

This project is an **unofficial community open-source tool** with no affiliation with Tencent. CodeBuddy IDE CN is a product of Tencent; copyright belongs to Tencent. See the official site for details. This tool does not redistribute any official CodeBuddy IDE CN software; it only automates the format conversion process for users' genuine installers.

The CodeBuddy application produced by this tool is governed by the official Tencent agreements:

- CodeBuddy Terms of Service: <https://cloud.tencent.com/document/product/301/106125>
- CodeBuddy Privacy Policy: <https://privacy.qq.com/document/preview/284d799a07164d09bfc7cedd0ec3e089>

By using this tool you acknowledge and agree to the following:

1. **User Responsibility**: You are responsible for ensuring that the DMG installer you obtained is from a legitimate source and that your usage complies with CodeBuddy's End User License Agreement (EULA) and related terms of service.
2. **No Warranty**: This tool is provided "AS IS" without any express or implied warranties, including but not limited to warranties of merchantability, fitness for a particular purpose, and non-infringement.
3. **No Official Support**: This project is an independent community project. Tencent does not provide any technical support. For issues encountered in the Linux porting environment, please file an Issue here. **Do not report to official customer service.**
4. **Use at Your Own Risk**: All consequences arising from using this tool for format conversion and running the application are borne solely by the user.
5. **Trademark Notice**: CodeBuddy and related logos are trademarks or registered trademarks of Tencent. Any use of these names in this project is for descriptive purposes only and does not imply any official endorsement or authorization.
6. **Takedown Policy**: If Tencent or any rights holder objects to this project, please contact the maintainer via a GitHub issue or email. The maintainer commits to immediately suspending maintenance, removing the AUR package, and processing the GitHub repository in accordance with the rights holder's reasonable request upon receipt of such objection.

## License

This project (PKGBUILD, conversion scripts and related recipes) is licensed under the MIT License; see [LICENSE](LICENSE). The MIT grant covers only the conversion tooling in this repository and **does NOT extend to the Tencent CodeBuddy IDE binaries installed via this tool**, which remain subject to Tencent's proprietary terms.
