<div align="center">

# CodeBuddy IDE CN for loong64 Linux (Unofficial)

</div>

<div align="center">

Codebuddy IDE CN（国内版）的非官方 **loong64 (LoongArch)** Linux 自动化移植与安装构建脚本工具

</div>

<p align="center">
  <img src="https://img.shields.io/badge/deb-Ubuntu_%7C_Debian-A81D33?style=flat&logo=debian&logoColor=white" alt="Debian Ubuntu Support">
  <img src="https://img.shields.io/badge/arch-ArchLinux_%7C_CachyOS-1793D1?style=flat&logo=arch-linux&logoColor=white" alt="AUR Package">
  <img src="https://img.shields.io/badge/rpm-Fedora_%7C_RHEL-006699?style=flat&logo=fedora&logoColor=white" alt="Fedora RHEL Support">
  <img src="https://img.shields.io/badge/AppImage-All_Distros-007ACC?style=flat&logo=appimage&logoColor=white" alt="AppImage Support">
  <br>
  <img src="https://img.shields.io/badge/架构-loong64-6C2DC7?style=flat" alt="Architecture loong64">
  <img src="https://img.shields.io/badge/版本适配-v4.10.0-0052D9?style=flat&logo=probot&logoColor=white" alt="Supported Version">
  <img src="https://img.shields.io/badge/Electron-v35.6.0-47307B?style=flat&logo=electron&logoColor=white" alt="Electron Version">
  <img src="https://img.shields.io/badge/状态-Unofficial-d73a49?style=flat" alt="Status Unofficial">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat" alt="License MIT">
</p>

---

# 简体中文

## 项目简介

这是一款非官方社区工具，核心作用是将**官方 CodeBuddy IDE CN Linux x64 .deb 安装包**，转换为可在 **loong64 (LoongArch)** 架构 Linux 系统运行的 Electron 应用。

本仓库**仅作为转换工具**，绝不充当软件分发渠道。所有官方安装包由用户机器自行从腾讯官方 CDN 下载，所有生成的应用目录、安装包产物均仅保留在本地，已加入 Git 忽略规则，不会被提交至仓库。

遇到任何 Bug 请在此仓库提 Issue，严禁向腾讯官方客服反馈在 loong64 Linux 移植后使用的相关问题。请勿在腾讯 CodeBuddy 官方用户群、社交媒体讨论本项目，本项目应保持低调维护。

## 版本适配说明

当前转换流程基于官方 CodeBuddy IDE CN **4.10.0**（构建号 `32999201-c8bdde62-cn`）验证通过。更高版本的 .deb 可能因为上游代码结构变化导致流程失败。如遇到构建失败或运行异常，请在本仓库提 Issue 并附上所使用的 .deb 版本号。

## 快速安装

### 前提条件

- 一台运行 Linux 的 **loong64 (LoongArch)** 架构机器
- 网络连接（用于下载官方 .deb 包和 npm 包）

### 所有 Linux 发行版通用安装

1. 克隆本项目至本地 loong64 Linux 机器；
2. 依次执行：

```bash
make deps
make download
make build-app
make package    # 或 make appimage
make install
```

`make download` 会自动从腾讯官方 CDN 下载 x64 架构的 .deb 安装包到 `downloads/` 目录。如已有旧版 .deb，会自动移至 `downloads/backups/` 备份。你也可以手动从官方网站下载 .deb 放入 `downloads/` 目录替代此步骤。

`make deps` 会自动识别当前系统的包管理器（支持 `apt`、`dnf5`、`dnf`、`pacman`、`zypper`），一键安装 .deb 提取、Electron 运行时下载、原生模块重建、安装包生成所需的全部依赖。

## 项目状态

目前项目已完整实现 loong64 端的转换与打包核心流程，具体功能如下：

- 自动从腾讯 CDN 下载官方 Linux x64 .deb 安装包；
- 使用 `dpkg-deb` 提取 .deb 包内容；
- 从应用 payload 中自动识别上游 Electron 版本号；
- 从社区镜像（darkyzhou/electron-loong64）下载匹配版本的 loong64 Electron 运行时；
- 将 CodeBuddy 应用核心程序复制至 `resources/app` 目录；
- 通过 `@electron/rebuild` 针对 loong64 架构和 loong64 Electron 头文件重建原生 Node 模块；
- 更新适配平台的依赖包，例如 `@vscode/ripgrep`；
- 自动生成 Linux 系统启动器与桌面入口文件；
- 根据当前 Linux 发行版，一键生成适配 loong64 的 `.deb`、`.rpm` 或 `.pkg.tar.zst` 格式安装包；
- 支持生成 loong64 AppImage 格式（`make appimage`），无需安装即可运行。

> 项目**未集成自动更新功能**。如需更新软件，只需执行 `make download` 下载新版官方 .deb 后重新执行构建流程即可覆盖本地旧版本。

## 构建与运行

### 下载官方 .deb

自动从腾讯官方 CDN 下载 x64 架构的 .deb 安装包到 `downloads/` 目录：

```bash
make download
```

如 `downloads/` 中已有旧版 .deb，会自动移至 `downloads/backups/` 备份后再下载新版。你也可以跳过此步骤，手动从官方网站下载 .deb 放入 `downloads/` 目录。

### 推荐构建方式

将官方 .deb 文件放入 `downloads/` 目录后，直接执行：

```bash
make build-app
```

### 自定义 .deb 路径

也可手动指定官方 .deb 文件路径：

```bash
make build-app DEB=/path/to/CodeBuddy.deb
```

### 运行生成的应用

```bash
make run-app
```

### 打包并安装

自动生成适配当前发行版的 loong64 安装包，并完成本地安装：

```bash
make package
make install
```

### 构建 AppImage

生成 loong64 AppImage 格式，无需安装即可运行（会自动触发 `build-app`）：

```bash
make appimage
```

生成的 AppImage 位于 `dist/codebuddy-ide-cn-loongarch64.AppImage`。首次构建会自动下载 `linuxdeploy` 工具到 `build/tools/` 缓存。

### 清理构建产物

清除所有构建生成的临时文件与应用目录：

```bash
make clean
```

## 实现原理

核心流程如下：

1. 以用户自行提供（或通过 `make download` 从腾讯官方 CDN 下载）的官方 Linux x64 .deb 安装包作为输入源；
2. 使用 `dpkg-deb -x` 提取 .deb 内容，定位 CodeBuddy 应用目录；
3. 从应用内 `package.json` 自动检测上游 Electron 版本号；
4. 通过社区 loong64 Electron 镜像（darkyzhou/electron-loong64）智能匹配并下载 loong64 Electron 运行时；
5. 用 loong64 Electron 替换 x64 版本；
6. **原生模块从源码拉取与重新编译**：由于官方 x64 .deb 预打包的原生模块（如 `node-pty`）是 x86_64 ELF 格式，无法在 loong64 上运行。本工具会自动从 npm 下载对应版本的完整源码，在隔离目录基于 loong64 Electron 头文件重新编译为 loong64 ELF 二进制文件，再覆盖回应用目录；
7. 更新适配平台的专属二进制依赖包（如 `@vscode/ripgrep`）；
8. 本地生成 Linux 系统启动配置与安装包元数据；
9. 编译生成 loong64 原生安装包。

CodeBuddy IDE CN 基于 VS Code/Electron 开发，其核心 JavaScript 代码是跨平台的，loong64 转换只需完成 Electron 运行时替换和原生模块重新编译即可实现兼容。

## 常用自定义配置

如需自定义安装路径、切换 Electron 镜像，可通过以下环境变量配合 `make build-app` 执行：

```bash
# 自定义安装目录
CODEBUDDY_INSTALL_DIR=/opt/tmp/codebuddycn-app make build-app
# 自定义 Electron 镜像源
ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ make build-app
# 自定义 Electron 头文件下载地址
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist make build-app
# 使用本地 Electron zip（跳过下载）
ELECTRON_LOCAL_ZIP=/path/to/electron-loong64.zip make build-app
# 强制指定 Electron 版本
FORCE_ELECTRON_VERSION=35.4.0 make build-app
```

## 仓库维护规范

以下目录因会存放上游软件、生成类安装包文件，已被 Git 忽略，**切勿手动提交**：

- `downloads/`
- `build/`
- `codebuddycn-app/`
- `dist/`
- `reference/`

禁止提交 .deb 安装包、生成的 Linux 应用目录及各类原生安装包产物。

## 免责声明

本项目为**非官方社区开源工具**，与腾讯官方无任何关联。CodeBuddy IDE CN 是腾讯旗下产品（版权 2026 腾讯云计算（北京）有限责任公司丨腾讯科技（深圳）有限公司 版权所有），详细版权信息请参阅官方网站。本工具不分发任何 CodeBuddy IDE CN 官方软件，仅自动化实现用户对自有正版安装包的架构转换流程。

使用本工具产生的 CodeBuddy 应用受腾讯官方协议约束：

- CodeBuddy 服务条款：https://cloud.tencent.com/document/product/301/106125
- CodeBuddy 用户隐私协议：https://privacy.qq.com/document/preview/284d799a07164d09bfc7cedd0ec3e089

使用本工具即表示您已知悉并同意以下内容：

1. **用户责任**：您有责任确保自行获取的 .deb 安装包来源合法，并遵守 CodeBuddy 的最终用户许可协议（EULA）及相关服务条款。
2. **无担保**：本工具按"现状"提供，不提供任何形式的明示或暗示担保。
3. **无官方支持**：本项目是独立社区项目，腾讯官方不对本工具提供任何技术支持。在 loong64 Linux 移植环境下遇到的问题，请在本仓库提 Issue，**严禁向官方客服反馈**。
4. **风险自担**：使用本工具进行架构转换和运行所产生的一切后果，由用户自行承担。
5. **商标声明**：CodeBuddy 相关标识是腾讯公司的商标或注册商标。本项目使用这些名称仅用于描述性目的。
6. **下架预案**：如腾讯或任何相关权利方对本项目存在异议，请通过本仓库 Issue 或邮件联系维护者。

## 开源许可证

本项目（PKGBUILD、转换脚本及相关 recipe）采用 MIT 开源许可证，详见 [LICENSE](LICENSE)。MIT 许可仅覆盖本仓库中的转换工具，**不延伸到通过本工具安装的腾讯 CodeBuddy IDE 二进制文件**——后者仍受腾讯官方私有协议约束。
