---
name: dmg-to-linux-deb-loong64
overview: 将项目从「macOS DMG → Linux Electron」改造为「官方 Linux x64 .deb → loong64 安装包」，下载官方 Linux .deb，提取应用内容，替换 loong64 Electron 运行时，重建原生模块，并重新打包为 loong64 原生安装包。
todos:
  - id: update-makefile-download
    content: 更新 Makefile 版本号（4.10.0/32999201/c8bdde62）、下载 URL 改为 linux-x64 .deb 地址、重写 help 文本；重写 download.sh 适配 .deb 下载和备份逻辑
    status: completed
  - id: create-deb-extraction
    content: 新建 scripts/lib/deb.sh：实现 dpkg-deb 提取 .deb、从 package.json 检测 Electron 版本、从 deb 文件名正则提取版本号；从 common.sh 移除 find_7z 函数；删除 scripts/lib/dmg.sh
    status: completed
  - id: rewrite-install-sh
    content: 重写 install.sh：source deb.sh 替换 dmg.sh，移除 ICNS 图标转换逻辑，重写 main() 为 deb 提取→版本检测→loong64 Electron 下载→复制 app→重建原生模块→生成启动器/桌面入口/元数据
    status: completed
    dependencies:
      - create-deb-extraction
  - id: simplify-native-modules
    content: 精简 native-modules.sh：移除 purge_macho_native_modules 函数、移除 remove_known_wrong_platform_modules 调用（或在函数内清空），保留核心 from-source 重建逻辑
    status: completed
  - id: update-package-builders
    content: 更新 build-deb.sh/build-rpm.sh/build-pacman.sh 的版本号提取正则适配 deb 文件名；精简 install-deps.sh 移除 7zip/icnsutils/imagemagick 依赖
    status: completed
  - id: update-documentation
    content: 重写 README.md（项目定位、安装步骤、工作原理）和 CODEBUDDY.md（架构概述、流水线阶段），反映 deb→loong64 新流程
    status: completed
    dependencies:
      - update-package-builders
---

## 项目概述

将 CodeBuddy IDE CN 的非官方 Linux 移植工具从“macOS DMG → Linux Electron 应用”改造为“官方 Linux x64 .deb → loong64 安装包”。核心变化是输入源从 macOS DMG 替换为官方 Linux x64 .deb 包，使用 dpkg-deb 提取内容，移除所有 macOS 特有处理逻辑（DMG 提取、Plist 版本检测、ICNS 图标转换、Mach-O 二进制清理），保留 loong64 Electron 下载、原生模块从源码重建和多格式打包能力。

## 核心功能

- **下载官方 Linux x64 .deb 包**：从腾讯 CDN 下载最新版本，自动备份旧版本
- **.deb 内容提取**：使用 dpkg-deb 提取 .deb 包内容，获取完整的 Linux 应用目录结构
- **版本信息自动检测**：从 .deb 文件名正则匹配版本号，从提取后的 app 中 package.json 检测 Electron 版本
- **loong64 Electron 运行时替换**：通过社区镜像 darkyzhou/electron-loong64 下载匹配版本的 loong64 Electron，替换 x64 版本
- **原生模块 loong64 重建**：从 npm 获取原生模块完整源码，针对 loong64 Electron 头文件重新编译
- **多格式 loong64 安装包生成**：支持生成 .deb、.rpm、.pkg.tar.zst 和 AppImage 四种格式的 loong64 安装包

## 技术栈

- Shell 脚本（Bash 4+，set -Eeuo pipefail 严格模式）
- dpkg-deb（.deb 提取）
- curl / unzip（下载和解压）
- Node.js 20+ / npm / npx（原生模块重建）
- @electron/rebuild（跨架构原生模块编译）
- dpkg-deb / rpmbuild / makepkg / linuxdeploy（各格式打包）

## 实现方案

### 整体策略

保持原有流水线架构（下载→提取→Electron 替换→原生模块重建→打包），仅替换输入源和提取方式。移除所有 macOS 特有逻辑，简化依赖列表。loong64 Electron 版本匹配和下载逻辑完全保留。

### 架构变化

**流水线对比（旧 → 新）**：

1. 下载 macOS DMG → 下载 Linux x64 .deb
2. 7z 提取 DMG → dpkg-deb 提取 .deb
3. Plist 检测 Electron 版本 → package.json 检测
4. 复制 Contents/Resources/app → 复制提取后的整个应用目录
5. ICNS 图标转换 → 跳过（.deb 中已有图标或无需转换）
6. purge_macho 清理 Mach-O → 跳过（无 Mach-O 文件）
7. remove_wrong_platform 清理 Windows/macOS 模块 → 跳过
8. 原生模块 from-source 重建 → 保留，面向 loong64 Electron
9. 多格式打包 → 保留，架构输出为 loongarch64

### 关键设计决策

**为什么用 dpkg-deb 而不是 7z**：官方 .deb 包是标准 Debian 包格式，dpkg-deb 是原生工具，更可靠且无需额外依赖 7-Zip。

**为什么保留 from-source 重建**：x64 .deb 中的预编译 .node 文件是 x86_64 ELF 格式，loong64 需要重新编译。即使某些模块包含源码，from-source 方式保证一致性。

**为什么移除 remove_known_wrong_platform_modules**：官方 Linux .deb 包已经是 Linux 版本，不包含 Windows/macOS 模块，无需清理。

## 目录结构

```
project-root/
├── Makefile                          # [MODIFY] 更新版本号、URL、help 文本
├── install.sh                        # [REWRITE] 核心流水线，source deb.sh 替代 dmg.sh
├── scripts/
│   ├── download.sh                   # [REWRITE] 下载 .deb 替代 .dmg
│   ├── lib/
│   │   ├── common.sh                 # [MODIFY] 移除 find_7z 函数
│   │   ├── dmg.sh                    # [DELETE] 不再需要 DMG 处理
│   │   ├── deb.sh                    # [NEW] .deb 提取、版本检测、内容复制
│   │   ├── electron.sh               # [MODIFY] 保留 loong64 逻辑，移除 DMG 相关注释
│   │   ├── native-modules.sh         # [SIMPLIFY] 移除 purge_macho、remove_known_wrong_platform
│   │   └── appimage.sh              # [UNCHANGED] 保留
│   ├── build-deb.sh                  # [MODIFY] 版本号提取正则适配 .deb 文件名
│   ├── build-rpm.sh                  # [MODIFY] 版本号逻辑调整
│   ├── build-pacman.sh              # [MODIFY] 版本号逻辑调整
│   ├── build-appimage.sh            # [UNCHANGED] 保留
│   ├── install-deps.sh              # [SIMPLIFY] 移除 7zip/icnsutils/imagemagick
│   ├── package.sh                   # [UNCHANGED] 保留
│   └── install-package.sh           # [UNCHANGED] 保留
├── packaging/
│   └── linux/
│       ├── codebuddy-ide-cn.desktop # [UNCHANGED] 保留
│       └── control                   # [UNCHANGED] 保留
├── README.md                         # [REWRITE] 完整文档更新
├── CODEBUDDY.md                      # [REWRITE] 架构文档更新
└── LICENSE                           # [UNCHANGED]
```

## 关键代码结构

### scripts/lib/deb.sh 接口定义

```
# 输入解析：优先用显式路径，否则在 downloads/ 找唯一 .deb
resolve_input_path()  # 参数: explicit_path; 输出: .deb 文件的绝对路径

# 提取 .deb 内容到工作目录
extract_deb()         # 参数: deb_path; 输出: 提取后的根目录路径

# 从提取内容中定位 app payload 目录（通常在 opt/codebuddy-ide-cn/）
locate_app_payload()  # 参数: extracted_root; 输出: app 目录路径

# 从 app/package.json 读取 Electron 版本
detect_electron_version()  # 参数: app_dir; 输出: 版本号字符串

# 从 .deb 文件名提取上游版本号
extract_deb_version()  # 参数: deb_path; 输出: 版本字符串（如 4.10.0.32999201--c8bdde62）
```

### 版本号正则适配

旧 DMG 模式：`CodeBuddy-darwin-x64-{version}.{build}-{hash}-cn.dmg`
新 deb 模式：`CodeBuddy-linux-x64-{version}.{build}-{hash}-cn.deb`