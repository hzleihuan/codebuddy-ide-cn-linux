[English](#english) | [简体中文](#简体中文) | [繁體中文](#繁體中文)

# 简体中文

# 移植笔记

## 参考项目模式

`codex-desktop-linux` 通过把上游软件作为本地输入，将 macOS-only Electron DMG 转换为 Linux 应用。它的关键步骤是：

1. 使用 `7z`/`7zz` 提取 DMG。
2. 从 `Electron Framework.framework/.../Info.plist` 检测 Electron 版本。
3. 复制或修补应用载荷。
4. 下载匹配的 Linux Electron runtime。
5. 为 Linux/Electron 重建原生 Node 模块。
6. 写入启动器和原生包。
7. 通过 `install-deps.sh`、`make build-app`、`make package`、`make install` 串起完整本地流程。

重要的法律和工程边界是：生成的载荷是本地产物，不是仓库内容。本项目只采用本地转换、依赖安装和包构建流程，不移植参考项目的自动更新程序。

## CodeBuddy 差异

已经检查过的 CodeBuddy IDE CN macOS bundle 使用：

- 应用显示名：`CodeBuddy CN`；
- bundle id：`com.tencent.codebuddycn`；
- Electron：`34.5.1`；
- 应用版本：`1.100.0`；
- 应用载荷：`Contents/Resources/app`；
- VS Code product application name：`buddycn`；
- URL scheme：`codebuddycn`。

这些值来自当前样本，只用于理解结构；构建脚本会从用户放入 `downloads/` 的官方 DMG 自动读取应用 bundle 和 Electron 版本，不绑定某一个具体 DMG 文件名或版本号。

不同于 Codex 参考项目，这个 bundle 以 `resources/app` 目录形式解包，而不是主要依赖 `app.asar`。因此转换器可以直接把应用载荷复制到 Linux Electron runtime 中。

macOS 载荷里发现的原生模块包括 `node-pty`、`native-keymap`、`native-watchdog`、`@vscode/sqlite3`、`@vscode/spdlog`、`@parcel/watcher`、`kerberos` 和相关可选模块。Linux 构建器会在复制后的应用上运行 `@electron/rebuild`，让这些模块被重建或替换为 Linux 版本。

## 首次 Linux 验证清单

把唯一一个官方 Intel/x64 DMG 放入 `downloads/`，然后运行：

```bash
bash scripts/install-deps.sh
make check
make build-app
make package
make install
codebuddy-ide-cn --verbose
```

也可以直接运行未安装的生成应用：

```bash
./codebuddycn-app/start.sh --verbose
```

如果 UI 能打开，但终端或文件监听失败，请检查：

```bash
find codebuddycn-app/resources/app/node_modules -name '*.node' -print
ldd codebuddycn-app/resources/app/node_modules/node-pty/build/Release/pty.node
ldd codebuddycn-app/resources/app/node_modules/native-keymap/build/Release/keymapping.node
```

如果原生模块重建失败，可以用下面的方式重试：

```bash
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist make build-app
```

---

# 繁體中文

# 移植筆記

## 參考專案模式

`codex-desktop-linux` 透過把上游軟體作為本地輸入，將 macOS-only Electron DMG 轉換為 Linux 應用程式。它的關鍵步驟是：

1. 使用 `7z`/`7zz` 提取 DMG。
2. 從 `Electron Framework.framework/.../Info.plist` 偵測 Electron 版本。
3. 複製或修補應用程式載荷。
4. 下載匹配的 Linux Electron 執行時。
5. 為 Linux/Electron 重建原生 Node 模組。
6. 寫入啟動器和原生套件。
7. 透過 `install-deps.sh`、`make build-app`、`make package`、`make install` 串起完整本地流程。

重要的法律和工程邊界是：生成的載荷是本地產物，不是儲存庫內容。本專案只採用本地轉換、相依性安裝和套件構建流程，不移植參考專案的自動更新程式。

## CodeBuddy 差異

已經檢查過的 CodeBuddy IDE CN macOS bundle 使用：

- 應用程式顯示名稱：`CodeBuddy CN`；
- bundle id：`com.tencent.codebuddycn`；
- Electron：`34.5.1`；
- 應用程式版本：`1.100.0`；
- 應用程式載荷：`Contents/Resources/app`；
- VS Code product application name：`buddycn`；
- URL scheme：`codebuddycn`。

這些值來自當前樣本，只用於理解結構；構建腳本會從使用者放入 `downloads/` 的官方 DMG 自動讀取應用程式 bundle 和 Electron 版本，不綁定某一個具體 DMG 檔案名稱或版本號。

不同於 Codex 參考專案，這個 bundle 以 `resources/app` 目錄形式解包，而不是主要依賴 `app.asar`。因此轉換器可以直接把應用程式載荷複製到 Linux Electron 執行時中。

macOS 載荷裡發現的原生模組包括 `node-pty`、`native-keymap`、`native-watchdog`、`@vscode/sqlite3`、`@vscode/spdlog`、`@parcel/watcher`、`kerberos` 和相關可選模組。Linux 構建器會在複製後的應用程式上執行 `@electron/rebuild`，讓這些模組被重建或替換為 Linux 版本。

## 首次 Linux 驗證清單

把唯一一個官方 Intel/x64 DMG 放入 `downloads/`，然後執行：

```bash
bash scripts/install-deps.sh
make check
make build-app
make package
make install
codebuddy-ide-cn --verbose
```

也可以直接執行未安裝的生成應用程式：

```bash
./codebuddycn-app/start.sh --verbose
```

如果 UI 能開啟，但終端機或檔案監聽失敗，請檢查：

```bash
find codebuddycn-app/resources/app/node_modules -name '*.node' -print
ldd codebuddycn-app/resources/app/node_modules/node-pty/build/Release/pty.node
ldd codebuddycn-app/resources/app/node_modules/native-keymap/build/Release/keymapping.node
```

如果原生模組重建失敗，可以用下面的方式重試：

```bash
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist make build-app
```

---

# English

# Porting Notes

## Reference Project Pattern

`codex-desktop-linux` converts a macOS-only Electron DMG into a Linux app by keeping upstream software as a local input. Its key steps are:

1. Extract the DMG with `7z`/`7zz`.
2. Detect Electron from `Electron Framework.framework/.../Info.plist`.
3. Copy or patch the app payload.
4. Download the matching Linux Electron runtime.
5. Rebuild native Node modules for Linux/Electron.
6. Write a launcher and native packages.
7. Connect the full local flow through `install-deps.sh`, `make build-app`, `make package`, and `make install`.

The important legal and engineering boundary is that generated payloads are local artifacts, not repository content. This project only adopts the local conversion, dependency installation, and package build flow; it does not port the reference project's auto-updater.

## CodeBuddy Differences

The inspected CodeBuddy IDE CN macOS bundle uses:

- app display name: `CodeBuddy CN`;
- bundle id: `com.tencent.codebuddycn`;
- Electron: `34.5.1`;
- app version: `1.100.0`;
- application payload: `Contents/Resources/app`;
- VS Code product application name: `buddycn`;
- URL scheme: `codebuddycn`.

These values come from the current sample and are only used to understand the structure. The build scripts read the app bundle and Electron version from the official DMG that the user places in `downloads/`; they are not bound to one specific DMG filename or version.

Unlike the Codex reference, this bundle is unpacked as a `resources/app` directory rather than primarily `app.asar`. That lets the converter copy the app payload directly into the Linux Electron runtime.

Native modules seen in the macOS payload include `node-pty`, `native-keymap`, `native-watchdog`, `@vscode/sqlite3`, `@vscode/spdlog`, `@parcel/watcher`, `kerberos`, and related optional modules. The Linux builder runs `@electron/rebuild` over the copied app so these modules are rebuilt or replaced for Linux.

## First Linux Validation Checklist

Place exactly one official Intel/x64 DMG in `downloads/`, then run:

```bash
bash scripts/install-deps.sh
make check
make build-app
make package
make install
codebuddy-ide-cn --verbose
```

You can also run the generated app before installing it:

```bash
./codebuddycn-app/start.sh --verbose
```

If the UI opens but terminal or file watching fails, inspect:

```bash
find codebuddycn-app/resources/app/node_modules -name '*.node' -print
ldd codebuddycn-app/resources/app/node_modules/node-pty/build/Release/pty.node
ldd codebuddycn-app/resources/app/node_modules/native-keymap/build/Release/keymapping.node
```

If native rebuild fails, retry with:

```bash
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist make build-app
```