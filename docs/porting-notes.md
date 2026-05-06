[English](#english) | [简体中文](#简体中文)

# 简体中文

# 移植笔记

## 参考项目模式

`codex-desktop-linux` 通过把上游软件作为本地输入，将 macOS-only Electron DMG 转换为 Linux 应用。它的关键步骤是：

1. 使用 `7z`/`7zz` 提取 DMG。
2. 从 `Electron Framework.framework/.../Info.plist` 检测 Electron 版本。
3. 复制或修补应用载荷。
4. 下载匹配的 Linux Electron runtime。
5. 为 Linux/Electron 重建原生 Node 模块。
6. 写入启动器和可选的原生包。

重要的法律和工程边界是：生成的载荷是本地产物，不是仓库内容。

## CodeBuddy 差异

已经检查过的 CodeBuddy IDE CN macOS bundle 使用：

- 应用显示名：`CodeBuddy CN`；
- bundle id：`com.tencent.codebuddycn`；
- Electron：`34.5.1`；
- 应用版本：`1.100.0`；
- 应用载荷：`Contents/Resources/app`；
- VS Code product application name：`buddycn`；
- URL scheme：`codebuddycn`。

不同于 Codex 参考项目，这个 bundle 以 `resources/app` 目录形式解包，而不是主要依赖 `app.asar`。因此转换器可以直接把应用载荷复制到 Linux Electron runtime 中。

macOS 载荷里发现的原生模块包括 `node-pty`、`native-keymap`、`native-watchdog`、`@vscode/sqlite3`、`@vscode/spdlog`、`@parcel/watcher`、`kerberos` 和相关可选模块。Linux 构建器会在复制后的应用上运行 `@electron/rebuild`，让这些模块被重建或替换为 Linux 版本。

## 首次 Linux 验证清单

```bash
make check
make build-app DMG=/path/to/CodeBuddy-darwin-x64-4.9.8.26735874-04507acd-cn.dmg
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
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist make build-app DMG=/path/to/CodeBuddy.dmg
```

# English

# Porting Notes

## Reference Project Pattern

`codex-desktop-linux` converts a macOS-only Electron DMG into a Linux app by keeping upstream software as a local input. Its key steps are:

1. Extract the DMG with `7z`/`7zz`.
2. Detect Electron from `Electron Framework.framework/.../Info.plist`.
3. Copy or patch the app payload.
4. Download the matching Linux Electron runtime.
5. Rebuild native Node modules for Linux/Electron.
6. Write a launcher and optional native packages.

The important legal and engineering boundary is that generated payloads are local artifacts, not repository content.

## CodeBuddy Differences

The inspected CodeBuddy IDE CN macOS bundle uses:

- app display name: `CodeBuddy CN`;
- bundle id: `com.tencent.codebuddycn`;
- Electron: `34.5.1`;
- app version: `1.100.0`;
- application payload: `Contents/Resources/app`;
- VS Code product application name: `buddycn`;
- URL scheme: `codebuddycn`.

Unlike the Codex reference, this bundle is unpacked as a `resources/app` directory rather than primarily `app.asar`. That lets the converter copy the app payload directly into the Linux Electron runtime.

Native modules seen in the macOS payload include `node-pty`, `native-keymap`, `native-watchdog`, `@vscode/sqlite3`, `@vscode/spdlog`, `@parcel/watcher`, `kerberos`, and related optional modules. The Linux builder runs `@electron/rebuild` over the copied app so these modules are rebuilt or replaced for Linux.

## First Linux Validation Checklist

```bash
make check
make build-app DMG=/path/to/CodeBuddy-darwin-x64-4.9.8.26735874-04507acd-cn.dmg
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
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist make build-app DMG=/path/to/CodeBuddy.dmg
```
