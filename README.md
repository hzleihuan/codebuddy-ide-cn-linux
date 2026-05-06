# CodeBuddy IDE CN for Linux

[English](#english) | [简体中文](#简体中文)

---

# 简体中文

## 项目简介

这是一款非官方社区工具，核心作用是将你自行获取的官方 CodeBuddy IDE CN macOS Intel/x64 版本 DMG 安装包，转换为可在本地 Linux 系统运行的 Electron 应用。

本仓库**仅作为转换工具**，绝不充当软件分发渠道。请务必前往官方网站下载正版 Intel/x64 架构 DMG 安装包，放置于项目 `downloads/` 目录下；所有生成的应用目录、安装包产物均仅保留在本地，且已加入 Git 忽略规则，不会被提交至仓库。

## 项目状态

目前项目已完整实现 Linux 端的转换与打包核心流程，具体功能如下：

- 借助 `7z`/`7zz` 工具，自动提取 `downloads/` 目录下唯一的官方 DMG 安装包；
- 从 macOS 应用包元数据中，自动识别上游 Electron 版本号；
- 下载与识别版本匹配的 Linux 版 Electron 运行时；
- 将 CodeBuddy 应用核心程序复制至 `resources/app` 目录；
- 通过 `@electron/rebuild`，针对 Linux 系统与 Electron 环境重建原生 Node 模块；
- 更新适配 Linux 平台的依赖包，例如 `@vscode/ripgrep`；
- 自动生成 Linux 系统启动器与桌面入口文件；
- 根据当前 Linux 发行版，一键生成适配的 `.deb`、`.rpm` 或 `.pkg.tar.zst` 格式安装包。

> 说明：整套工程已在 **Linux Mint 22.3** 环境完成完整打包部署实测，部署完成后连续运行 **GLM 5.1** 执行一小时高强度复杂任务，程序运行稳定流畅，各项功能均可正常使用，兼容性与可靠性经过充分验证。
> 项目**未集成自动更新功能**，如需更新软件，只需手动下载新版官方 DMG，放入 `downloads/` 目录后，重新执行构建、安装流程即可覆盖本地旧版本。

## 快速上手

1. 克隆本项目至本地 Linux 机器；
2. 在项目根目录创建 `downloads` 文件夹；
3. 将**唯一一份**官方 Intel/x64 架构 DMG 安装包放入 `downloads/` 目录；
4. 依次执行以下命令：

```bash
bash scripts/install-deps.sh
make build-app
make package
make install
```

`scripts/install-deps.sh` 脚本会自动识别当前系统的包管理器（支持 `apt`、`dnf5`、`dnf`、`pacman`、`zypper`），并一键安装 DMG 提取、Electron 运行时下载、原生模块重建、安装包生成所需的全部依赖。

## 构建与运行

### 推荐构建方式

将唯一的 `.dmg` 文件放入 `downloads/` 目录后，直接执行构建命令：

```bash
make build-app
```

### 自定义 DMG 路径

也可手动指定官方 DMG 文件路径（仅为输入路径，不绑定软件版本）：

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

1. 以用户自行提供的官方 macOS DMG 安装包作为输入源；
2. 仅提取 Electron 应用核心程序，不对外分发任何官方软件内容；
3. 用对应版本的 Linux Electron 运行时，替换原 macOS 版运行时；
4. 基于 Linux Electron 头文件，重新编译原生 Node 模块；
5. 更新适配 Linux 平台的专属二进制依赖包；
6. 本地生成 Linux 系统启动配置与安装包元数据；
7. 编译生成对应发行版的原生安装包，通过 `make install` 完成最新版本安装。

CodeBuddy IDE CN 基于 VS Code/Electron 开发，其 macOS 应用的 `Contents/Resources/app` 目录下已包含跨平台 JavaScript 核心代码，Linux 转换只需完成平台二进制文件替换、原生模块重新编译即可实现兼容。

## 常用自定义配置

如需自定义安装路径、切换 Electron 镜像，可通过以下命令执行：

```bash
# 自定义安装目录
CODEBUDDY_INSTALL_DIR=/opt/tmp/codebuddycn-app bash install.sh
# 切换Electron镜像源
ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ bash install.sh
# 自定义Electron头文件下载地址
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist bash install.sh
```

## 仓库维护规范

以下目录因会存放上游软件、生成类安装包文件，已被 Git 忽略，**切勿手动提交**：

- `downloads/`
- `build/`
- `codebuddycn-app/`
- `dist/`
- `reference/`

禁止提交 DMG 安装包、解压后的 `.app` 应用包、生成的 Linux 应用目录及各类原生安装包产物。

## 免责声明

本项目为**非官方社区开源工具**，与腾讯官方无任何关联。CodeBuddy IDE CN 是腾讯旗下产品（版权 © 2026 腾讯云计算（北京）有限责任公司丨腾讯科技（深圳）有限公司 版权所有）。本工具不分发任何 CodeBuddy IDE CN 官方软件，仅自动化实现用户对自有正版安装包的格式转换流程。

## 开源许可证

本项目采用 MIT 开源许可证，详细内容请查看 [LICENSE](LICENSE) 文件。

---

# English

## Project Introduction

This is an unofficial community tool designed to convert your legally obtained official CodeBuddy IDE CN macOS Intel/x64 DMG installer into a local Linux Electron application.

This repository **serves solely as a converter** and will never act as a software redistribution channel. Please download the genuine Intel/x64 DMG installer from the official website and place it in the `downloads/` directory. All generated application directories and package artifacts are stored locally only and are added to Git ignore rules to avoid being committed to the repository.

## Project Status

The project currently fully implements the core Linux-side conversion and packaging workflow, with specific features as follows:

- Automatically extract the single official DMG installer in the `downloads/` directory via `7z`/`7zz`;
- Detect the upstream Electron version from the macOS application bundle metadata;
- Download the matching Linux Electron runtime corresponding to the detected version;
- Copy the core CodeBuddy application payload to the `resources/app` directory;
- Rebuild native Node modules for Linux system and Electron environment using `@electron/rebuild`;
- Update Linux platform-adapted dependencies such as `@vscode/ripgrep`;
- Automatically generate Linux system launcher and desktop entry files;
- Generate compatible `.deb`, `.rpm` or `.pkg.tar.zst` packages based on the current Linux distribution.

> Note: The entire project has been fully tested and packaged on **Linux Mint 22.3**. After installation, it ran complex heavy workloads on **GLM 5.1** continuously for one hour, running stably with full functionality verified.
> No auto-update feature is integrated in this project. To update the software, simply manually download the latest official DMG, place it in the `downloads/` directory, and re-run the build and installation process to overwrite the old version.

## Quick Start

1. Clone this repository to your local Linux machine;
2. Create a `downloads` folder in the project root directory;
3. Place **exactly one** official Intel/x64 DMG installer into the `downloads/` directory;
4. Execute the following commands in sequence:

```bash
bash scripts/install-deps.sh
make build-app
make package
make install
```

The `scripts/install-deps.sh` script automatically detects the package manager of the current system (supports `apt`, `dnf5`, `dnf`, `pacman`, `zypper`) and installs all dependencies required for DMG extraction, Electron runtime download, native module rebuilding and package generation.

## Build & Run

### Recommended Build Method

After placing the only `.dmg` file in the `downloads/` directory, run the build command directly:

```bash
make build-app
```

### Custom DMG Path

You can also manually specify the path of the official DMG file (only an input path, not binding to a specific software version):

```bash
make build-app DMG=/path/to/CodeBuddy.dmg
```

### Run the Generated Application

```bash
make run-app
```

### Package & Install

Automatically generate a distribution-compatible package and complete local installation:

```bash
make package
make install
```

## How It Works

This project references the local conversion and packaging logic of `codex-desktop-linux`, but **does not port its auto-update module**. The core workflow is as follows:

1. Take the official macOS DMG installer provided by the user as the input source;
2. Only extract the core Electron application payload without redistributing any official software content;
3. Replace the original macOS Electron runtime with the corresponding Linux Electron runtime;
4. Recompile native Node modules based on Linux Electron headers;
5. Update platform-specific binary dependencies adapted for Linux;
6. Generate Linux system startup configuration and package metadata locally;
7. Compile a native package for the current distribution and install the latest version via `make install`.

CodeBuddy IDE CN is developed based on VS Code/Electron. The cross-platform JavaScript core code is already included in the `Contents/Resources/app` directory of its macOS application, and Linux compatibility can be achieved only by replacing platform binaries and recompiling native modules.

## Useful Custom Configurations

To customize the installation path or switch Electron mirrors, execute the following commands:

```bash
# Custom installation directory
CODEBUDDY_INSTALL_DIR=/opt/tmp/codebuddycn-app bash install.sh
# Switch Electron mirror source
ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ bash install.sh
# Custom Electron headers download URL
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist bash install.sh
```

## Repository Maintenance Rules

The following directories are ignored by Git because they store upstream software and generated package files, **never commit them manually**:

- `downloads/`
- `build/`
- `codebuddycn-app/`
- `dist/`
- `reference/`

Committing DMG installers, extracted `.app` bundles, generated Linux application directories and various native package artifacts is prohibited.

## Disclaimer

This project is an **unofficial community open-source tool** and has no affiliation with Tencent. CodeBuddy IDE CN is a product of Tencent (copyright © 2026 Tencent Cloud Computing (Beijing) Co., Ltd. and Tencent Technology (Shenzhen) Co., Ltd. All rights reserved). This tool does not redistribute any official CodeBuddy IDE CN software, it only automates the format conversion process for users' genuine installers.

## License

This project is licensed under the MIT License. For details, please refer to the [LICENSE](LICENSE) file.