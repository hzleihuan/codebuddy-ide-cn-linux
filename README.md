<div align="center">

# CodeBuddy IDE CN for Linux (Unofficial)

</div>

<div align="center">

Codebuddy IDE CN（国内版）的非官方 Linux 自动化移植与安装构建脚本工具

</div>
<p align="middle">
  <img src="https://img.shields.io/badge/deb-Ubuntu_%7C_Debian-A81D33?style=flat&logo=debian&logoColor=white" alt="Debian Ubuntu Support">
  <a href="https://aur.archlinux.org/packages/codebuddy-ide-cn" target="_blank">
  <img src="https://img.shields.io/badge/AUR-codebuddy--ide--cn-1793D1?style=flat&logo=arch-linux&logoColor=white" alt="AUR Package"></a>
  <img src="https://img.shields.io/badge/rpm-Fedora_%7C_RHEL-006699?style=flat&logo=fedora&logoColor=white" alt="Fedora RHEL Support">
  <br>
  <img src="https://img.shields.io/badge/版本适配-v4.9.13-0052D9?style=flat&logo=probot&logoColor=white" alt="Supported Version">
  <img src="https://img.shields.io/badge/Electron-v34.5.1-47307B?style=flat&logo=electron&logoColor=white" alt="Electron Version">
  <img src="https://img.shields.io/badge/状态-Unofficial-d73a49?style=flat" alt="Status Unofficial">
</p>

<div align="center">

[English](#english) | [简体中文](#简体中文) | [繁體中文](#繁體中文)

</div>

---

# 简体中文

## 项目简介

这是一款非官方社区工具，核心作用是将官方 CodeBuddy IDE CN macOS Intel/x64 版本 DMG 安装包，转换为可在本地 Linux 系统运行的 Electron 应用。

本仓库**仅作为转换工具**，绝不充当软件分发渠道。所有官方安装包由用户机器自行从腾讯官方 CDN 下载，所有生成的应用目录、安装包产物均仅保留在本地，已加入 Git 忽略规则，不会被提交至仓库。

遇到任何 Bug 请在此仓库提 Issue，严禁向腾讯官方客服反馈在 Linux 移植后使用的相关问题。请勿在腾讯 CodeBuddy 官方用户群、社交媒体讨论本项目，本项目应保持低调维护。

## 版本适配说明

当前转换流程基于官方 CodeBuddy IDE CN **4.9.13**（构建号 `30241433-0acccacc-cn`）验证通过。更高版本的 DMG 可能因为上游代码结构变化导致流程失败。如遇到构建失败或运行异常，请在本仓库提 Issue 并附上所使用的 DMG 版本号。

## 快速安装

### Arch Linux / CachyOS / Manjaro 等 Arch 系发行版

直接通过 AUR 安装，无需 clone 本仓库：

```bash
yay -S codebuddy-ide-cn
# 或者
paru -S codebuddy-ide-cn
```

也可以手动构建：

```bash
git clone https://aur.archlinux.org/codebuddy-ide-cn.git
cd codebuddy-ide-cn
makepkg -si
```

AUR 包页面：<https://aur.archlinux.org/packages/codebuddy-ide-cn>

> 构建过程会自动从腾讯官方 CDN 下载约 180 MB 的官方 DMG，请保持网络畅通。本仓库与 AUR 包均不重新分发任何腾讯软件二进制。

### 其他 Linux 发行版（Debian / Ubuntu / Linux Mint / Fedora / openSUSE 等）

1. 克隆本项目至本地 Linux 机器；
2. 在项目根目录创建 `downloads` 文件夹；
3. 自行从官方网站下载 Intel/x64 架构 DMG 安装包，放入 `downloads/` 目录；
4. 依次执行：

```bash
make deps
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
- 通过 AUR 上架 `codebuddy-ide-cn`，Arch 系用户可一键安装。

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

## 迁移说明

如果您之前安装过旧版 `codebuddycn-ide`，请参考 [迁移指南](docs/migration.md) 迁移到新版 `codebuddy-ide-cn`。

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
7. **项目定位**： 本项目（包括本 GitHub 仓库及相关的 AUR/PKGBUILD 自动化脚本）仅用于技术研究与概念验证。原作者从未、亦绝不分发任何官方二进制软件。
8. **AUR 机制说明**： 相关的 AUR 软件包仅提供文本形式的构建“配方”（Script/PKGBUILD）。用户通过该脚本进行的任何下载、解包、格式转换等行为，均在用户本地计算机上独立发生，下载源均指向官方或合法的公开地址，本项目不托管任何受版权保护的二进制文件。
9. **第三方责任**： 任何第三方因 Fork、修改本项目，或自行分发移植二进制安装包（Releases）而产生的版权争议与法律责任，均由该第三方独立承担，与本项目原作者无关。

## 开源许可证

本项目（PKGBUILD、转换脚本及相关 recipe）采用 MIT 开源许可证，详见 [LICENSE](LICENSE)。MIT 许可仅覆盖本仓库中的转换工具，**不延伸到通过本工具安装的腾讯 CodeBuddy IDE 二进制文件**——后者仍受腾讯官方私有协议约束。

---

# 繁體中文

## 專案簡介

這是一款非官方社群工具，核心作用是將官方 CodeBuddy IDE CN macOS Intel/x64 版本 DMG 安裝包，轉換為可在本地 Linux 系統運行的 Electron 應用程式。

本儲存庫**僅作為轉換工具**，絕不充當軟體分發管道。所有官方安裝包由使用者機器自行從騰訊官方 CDN 下載，所有生成的應用程式目錄、安裝包產物均僅保留在本地，已加入 Git 忽略規則，不會被提交至儲存庫。

遇到任何 Bug 請在此儲存庫提 Issue，嚴禁向騰訊官方客服回報在 Linux 移植後使用的相關問題。請勿在騰訊 CodeBuddy 官方使用者群組、社群媒體討論本專案，本專案應保持低調維護。

## 版本適配說明

當前轉換流程基於官方 CodeBuddy IDE CN **4.9.13**（構建號 `30241433-0acccacc-cn`）驗證通過。更高版本的 DMG 可能因為上游程式碼結構變化導致流程失敗。如遇到構建失敗或執行異常，請在本儲存庫提 Issue 並附上所使用的 DMG 版本號。

## 快速安裝

### Arch Linux / CachyOS / Manjaro 等 Arch 系發行版

直接透過 AUR 安裝，無需 clone 本儲存庫：

```bash
yay -S codebuddy-ide-cn
# 或者
paru -S codebuddy-ide-cn
```

也可以手動構建：

```bash
git clone https://aur.archlinux.org/codebuddy-ide-cn.git
cd codebuddy-ide-cn
makepkg -si
```

AUR 套件頁面：<https://aur.archlinux.org/packages/codebuddy-ide-cn>

> 構建過程會自動從騰訊官方 CDN 下載約 180 MB 的官方 DMG，請保持網路暢通。本儲存庫與 AUR 套件均不重新分發任何騰訊軟體二進位檔案。

### 其他 Linux 發行版（Debian / Ubuntu / Linux Mint / Fedora / openSUSE 等）

1. 複製本專案至本地 Linux 機器；
2. 在專案根目錄建立 `downloads` 資料夾；
3. 自行從官方網站下載 Intel/x64 架構 DMG 安裝包，放入 `downloads/` 目錄；
4. 依次執行：

```bash
make deps
make build-app
make package
make install
```

`scripts/install-deps.sh` 會自動辨識當前系統的套件管理器（支援 `apt`、`dnf5`、`dnf`、`pacman`、`zypper`），一鍵安裝 DMG 提取、Electron 執行時下載、原生模組重建、安裝包生成所需的全部相依性。

## 專案狀態

目前專案已完整實現 Linux 端的轉換與打包核心流程，具體功能如下：

- 借助 `7z`/`7zz` 工具，自動提取 `downloads/` 目錄下的官方 DMG 安裝包；
- 從 macOS 應用程式套件後設資料中，自動識別上游 Electron 版本號；
- 下載與識別版本匹配的 Linux 版 Electron 執行時；
- 將 CodeBuddy 應用程式核心程式複製至 `resources/app` 目錄；
- 透過 `@electron/rebuild` 針對 Linux 系統與 Electron 環境重建原生 Node 模組；
- 更新適配 Linux 平台的相依套件，例如 `@vscode/ripgrep`；
- 自動生成 Linux 系統啟動器與桌面入口檔案；
- 根據當前 Linux 發行版，一鍵生成適配的 `.deb`、`.rpm` 或 `.pkg.tar.zst` 格式安裝包；
- 透過 AUR 上架 `codebuddy-ide-cn`，Arch 系使用者可一鍵安裝。

> 測試範圍：已在 Debian 系（Linux Mint 22.3）和 Arch 系（CachyOS）完成完整打包部署實測，執行穩定。
> 專案**未整合自動更新功能**。如需更新軟體，只需手動下載新版官方 DMG 後重新執行構建流程即可覆蓋本地舊版本；AUR 使用者等套件升級 push 後正常 `yay -Syu` 即可。

## 構建與執行

### 推薦構建方式

將官方 DMG 檔案放入 `downloads/` 目錄後，直接執行：

```bash
make build-app
```

### 自訂 DMG 路徑

也可手動指定官方 DMG 檔案路徑：

```bash
make build-app DMG=/path/to/CodeBuddy.dmg
```

### 執行生成的應用程式

```bash
make run-app
```

### 打包並安裝

自動生成適配當前發行版的安裝包，並完成本地安裝：

```bash
make package
make install
```

## 實現原理

本專案參考了 `codex-desktop-linux` 的本地轉換與打包邏輯，但**未移植其自動更新模組**，核心流程如下：

1. 以使用者自行提供（或由 AUR 套件自動從官方 CDN 下載）的官方 macOS DMG 安裝包作為輸入來源；
2. 僅提取 Electron 應用程式核心程式，不對外分發任何官方軟體內容；
3. 用對應版本的 Linux Electron 執行時，替換原 macOS 版執行時；
4. **原生模組從原始碼拉取與重新編譯**：由於 macOS DMG 預打包的原生模組（如 `node-pty`）被剝離了 C++ 原始碼與構建設定（導致直接 `@electron/rebuild` 失敗），本工具會自動從 npm 下載對應版本的完整原始碼，在隔離目錄基於 Linux Electron 頭檔案重新編譯為 ELF 二進位檔案，再覆蓋回應用程式目錄；
5. 更新適配 Linux 平台的專屬二進位相依套件；
6. 本地生成 Linux 系統啟動設定與安裝包後設資料；
7. 編譯生成對應發行版的原生安裝包，透過 `make install` 或 AUR helper 完成安裝。

CodeBuddy IDE CN 基於 VS Code/Electron 開發，其 macOS 應用程式的 `Contents/Resources/app` 目錄下已包含跨平台 JavaScript 核心程式碼，Linux 轉換只需完成平台二進位檔案替換、原生模組重新編譯即可實現相容。

## 常用自訂設定

如需自訂安裝路徑、切換 Electron 鏡像，可透過以下命令執行：

```bash
# 自訂安裝目錄
CODEBUDDY_INSTALL_DIR=/opt/tmp/codebuddycn-app bash install.sh
# 切換 Electron 鏡像來源
ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ bash install.sh
# 自訂 Electron 頭檔案下載位址
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist bash install.sh
```

## 遷移說明

如果您之前安裝過舊版 `codebuddycn-ide`，請參考 [遷移指南](docs/migration.md) 遷移到新版 `codebuddy-ide-cn`。

## 儲存庫維護規範

以下目錄因會存放上游軟體、生成類安裝包檔案，已被 Git 忽略，**切勿手動提交**：

- `downloads/`
- `build/`
- `codebuddycn-app/`
- `dist/`
- `reference/`

禁止提交 DMG 安裝包、解壓縮後的 `.app` 應用程式套件、生成的 Linux 應用程式目錄及各類原生安裝包產物。

## 免責聲明

本專案為**非官方社群開源工具**，與騰訊官方無任何關聯。CodeBuddy IDE CN 是騰訊旗下產品，版權歸騰訊所有，詳細版權資訊請參閱官方網站。本工具不分發任何 CodeBuddy IDE CN 官方軟體，僅自動化實現使用者對自有正版安裝包的格式轉換流程。

使用本工具產生的 CodeBuddy 應用程式受騰訊官方協議約束：

- CodeBuddy 服務條款：<https://cloud.tencent.com/document/product/301/106125>
- CodeBuddy 使用者隱私協議：<https://privacy.qq.com/document/preview/284d799a07164d09bfc7cedd0ec3e089>

使用本工具即表示您已知悉並同意以下內容：

1. **使用者責任**：您有責任確保自行取得的 DMG 安裝包來源合法，並遵守 CodeBuddy 的最終使用者授權協議（EULA）及相關服務條款。
2. **無擔保**：本工具按「現狀」提供，不提供任何形式的明示或暗示擔保，包括但不限于對適銷性、特定用途適用性和非侵權性的擔保。
3. **無官方支援**：本專案是獨立社群專案，騰訊官方不對本工具提供任何技術支援。在 Linux 移植環境下遇到的問題，請在本儲存庫提 Issue，**嚴禁向官方客服回報**。
4. **風險自擔**：使用本工具進行格式轉換和執行所產生的一切後果，由使用者自行承擔。
5. **商標聲明**：CodeBuddy 相關標識是騰訊公司的商標或註冊商標。本專案使用這些名稱僅用於描述性目的，不暗示任何官方認可或授權。
6. **下架預案**：如騰訊或任何相關權利方對本專案存在異議，請透過本儲存庫 Issue 或電子郵件聯繫維護者。維護者承諾在收到合理異議後立即停止維護、下架 AUR 套件，並按權利方要求處理 GitHub 儲存庫。
7. **專案定位**：本專案（包括本 GitHub 儲存庫及相關的 AUR/PKGBUILD 自動化腳本）僅用於技術研究與概念驗證。原作者從未、亦絕不分發任何官方二進位軟體。
8. **AUR 機制說明**：相關的 AUR 軟體套件僅提供文本形式的構建「配方」（Script/PKGBUILD）。使用者透過該腳本進行的任何下載、解包、格式轉換等行為，均在使用者本地電腦上獨立發生，下載來源均指向官方或合法的公開位址，本專案不託管任何受版權保護的二進位檔案。
9. **第三方責任**：任何第三方因 Fork、修改本專案，或自行分發移植二進位安裝包（Releases）而產生的版權爭議與法律責任，均由該第三方獨立承擔，與本專案原作者無關。

## 開源授權條款

本專案（PKGBUILD、轉換腳本及相關 recipe）採用 MIT 開源授權條款，詳見 [LICENSE](LICENSE)。MIT 授權僅覆蓋本儲存庫中的轉換工具，**不延伸到透過本工具安裝的騰訊 CodeBuddy IDE 二進位檔案**——後者仍受騰訊官方私有協議約束。

---

# English

## Project Introduction

This is an unofficial community tool designed to convert the official CodeBuddy IDE CN macOS Intel/x64 DMG installer into a local Linux Electron application.

This repository **serves solely as a converter** and is never a software redistribution channel. The official installer is downloaded by the user's own machine directly from Tencent's official CDN. All generated application directories and package artifacts are stored locally only and are added to Git ignore rules.

If you encounter bugs, please submit an Issue here. Do not contact Tencent official customer service to report Linux porting issues. Please do not promote this project in CodeBuddy official user groups or social media; this project is intended to be maintained quietly.

## Version Compatibility

The current conversion workflow has been verified against official CodeBuddy IDE CN **4.9.13** (build `30241433-0acccacc-cn`). Higher versions of the DMG may have upstream code structure changes that prevent the flow from completing. If you encounter build failures or runtime issues, please file an Issue with the DMG version number.

## Quick Install

### Arch Linux / CachyOS / Manjaro and other Arch-based distros

Install directly from the AUR, no need to clone this repository:

```bash
yay -S codebuddy-ide-cn
# or
paru -S codebuddy-ide-cn
```

Or build manually:

```bash
git clone https://aur.archlinux.org/codebuddy-ide-cn.git
cd codebuddy-ide-cn
makepkg -si
```

AUR package page: <https://aur.archlinux.org/packages/codebuddy-ide-cn>

> The build process automatically downloads ~180 MB of the official DMG from Tencent's CDN. Neither this repository nor the AUR package re-distributes any Tencent binary.

### Other Linux distros (Debian / Ubuntu / Linux Mint / Fedora / openSUSE etc.)

1. Clone this repository to your local Linux machine;
2. Create a `downloads/` folder in the project root;
3. Download the official Intel/x64 DMG installer yourself and place it in `downloads/`;
4. Run:

```bash
make deps
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
- Distributed through AUR as `codebuddy-ide-cn` for one-click installation on Arch-based distros.

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

## Migration Notes

If you previously installed the old `codebuddycn-ide` package, please refer to the [Migration Guide](docs/migration.md) to migrate to the new `codebuddy-ide-cn` package.

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
7. **Project Purpose**: This project (including this GitHub repository and any related AUR/PKGBUILD automation scripts) is intended solely for technical research and proof-of-concept purposes. The original author has never distributed, and will never distribute, any official proprietary binary software.
8. **AUR Mechanism Clarification**: The related AUR package contains only text-based build scripts ("recipes"). All download, extraction, and format conversion processes are executed independently on the user's local machine. The build scripts fetch files directly from official or legally public URLs; this project does not host or store any copyrighted binary files.
9. **Third-Party Responsibility**: Any copyright disputes or legal liabilities arising from third-party forks, modifications, or the independent publication of pre-compiled binary installation packages (including GitHub Releases) shall be the sole responsibility of such third parties, and are entirely unrelated to the original author.

## License

This project (PKGBUILD, conversion scripts and related recipes) is licensed under the MIT License; see [LICENSE](LICENSE). The MIT grant covers only the conversion tooling in this repository and **does NOT extend to the Tencent CodeBuddy IDE binaries installed via this tool**, which remain subject to Tencent's proprietary terms.
