[English](#english) | [简体中文](#简体中文) | [繁體中文](#繁體中文)

# 简体中文

# 迁移指南：从 codebuddycn-ide 到 codebuddy-ide-cn

本指南帮助已安装旧版 `codebuddycn-ide` 的用户迁移到新版 `codebuddy-ide-cn` 包。

## 为什么迁移？

项目包名已从 `codebuddycn-ide` 统一为 `codebuddy-ide-cn`，与 AUR 包名一致。旧包不再维护。

## 迁移步骤

### 1. 卸载旧包

根据您的包管理器执行相应命令：

**Arch Linux (pacman):**
```bash
sudo pacman -R codebuddycn-ide
```

**Debian/Ubuntu (dpkg):**
```bash
sudo dpkg -r codebuddycn-ide
```

**Fedora/RHEL (rpm):**
```bash
sudo rpm -e codebuddycn-ide
```

### 2. 清理旧缓存（可选）

旧版 Electron 运行时缓存位于 `~/.cache/codebuddycn-ide-linux`。可选择删除：
```bash
rm -rf ~/.cache/codebuddycn-ide-linux
```

新版缓存目录为 `~/.cache/codebuddy-ide-cn-loong64`，不会冲突。

### 3. 安装新包

按照项目 README 中的说明安装新版 `codebuddy-ide-cn`。

**Arch Linux (AUR):**
```bash
yay -S codebuddy-ide-cn
# 或
paru -S codebuddy-ide-cn
```

**其他发行版：**
```bash
# 构建新包
make package
# 安装
make install
```

### 4. 更新桌面数据库（可选）

如果安装后桌面菜单没有更新，可手动更新：

```bash
# 系统级
sudo update-desktop-database /usr/share/applications
# 用户级（如果有本地桌面文件）
update-desktop-database ~/.local/share/applications
```

## 配置文件

应用配置文件通常位于：
- `~/.config/CodeBuddy CN/`（或类似目录）
- `~/.config/codebuddycn-ide/`（如果存在）

这些配置文件与包名无关，迁移后通常无需处理。如遇问题，可备份后删除配置目录。

## 验证迁移

安装完成后，运行以下命令验证：
```bash
codebuddy-ide-cn --verbose
```

## 回滚

如需回滚到旧版，卸载新包后重新安装旧包即可。旧包安装包可能仍保留在构建目录 `dist/` 中。

## 联系支持

迁移过程中遇到问题，请在项目仓库提 Issue。

---

# 繁體中文

# 遷移指南：從 codebuddycn-ide 到 codebuddy-ide-cn

本指南幫助已安裝舊版 `codebuddycn-ide` 的使用者遷移到新版 `codebuddy-ide-cn` 套件。

## 為什麼遷移？

專案套件名已從 `codebuddycn-ide` 統一為 `codebuddy-ide-cn`，與 AUR 套件名一致。舊套件不再維護。

## 遷移步驟

### 1. 解除安裝舊套件

根據您的套件管理器執行相應命令：

**Arch Linux (pacman):**
```bash
sudo pacman -R codebuddycn-ide
```

**Debian/Ubuntu (dpkg):**
```bash
sudo dpkg -r codebuddycn-ide
```

**Fedora/RHEL (rpm):**
```bash
sudo rpm -e codebuddycn-ide
```

### 2. 清理舊快取（可選）

舊版 Electron 執行時快取位於 `~/.cache/codebuddycn-ide-linux`。可選擇刪除：
```bash
rm -rf ~/.cache/codebuddycn-ide-linux
```

新版快取目錄為 `~/.cache/codebuddy-ide-cn-loong64`，不會衝突。

### 3. 安裝新套件

按照專案 README 中的說明安裝新版 `codebuddy-ide-cn`。

**Arch Linux (AUR):**
```bash
yay -S codebuddy-ide-cn
# 或
paru -S codebuddy-ide-cn
```

**其他發行版：**
```bash
# 構建新套件
make package
# 安裝
make install
```

### 4. 更新桌面資料庫（可選）

如果安裝後桌面選單沒有更新，可手動更新：

```bash
# 系統級
sudo update-desktop-database /usr/share/applications
# 使用者級（如果有本地桌面檔案）
update-desktop-database ~/.local/share/applications
```

## 設定檔案

應用程式設定檔案通常位於：
- `~/.config/CodeBuddy CN/`（或類似目錄）
- `~/.config/codebuddycn-ide/`（如果存在）

這些設定檔案與套件名無關，遷移後通常無需處理。如遇問題，可備份後刪除設定目錄。

## 驗證遷移

安裝完成後，執行以下命令驗證：
```bash
codebuddy-ide-cn --verbose
```

## 回滾

如需回滾到舊版，解除安裝新套件後重新安裝舊套件即可。舊套件安裝包可能仍保留在構建目錄 `dist/` 中。

## 聯繫支援

遷移過程中遇到問題，請在專案儲存庫提 Issue。

---

# English

# Migration Guide: From codebuddycn-ide to codebuddy-ide-cn

This guide helps users who have installed the old `codebuddycn-ide` package migrate to the new `codebuddy-ide-cn` package.

## Why Migrate?

The project package name has been unified from `codebuddycn-ide` to `codebuddy-ide-cn`, consistent with the AUR package name. The old package is no longer maintained.

## Migration Steps

### 1. Uninstall the Old Package

Run the appropriate command for your package manager:

**Arch Linux (pacman):**
```bash
sudo pacman -R codebuddycn-ide
```

**Debian/Ubuntu (dpkg):**
```bash
sudo dpkg -r codebuddycn-ide
```

**Fedora/RHEL (rpm):**
```bash
sudo rpm -e codebuddycn-ide
```

### 2. Clean Old Cache (Optional)

The old Electron runtime cache is located at `~/.cache/codebuddycn-ide-linux`. You can optionally delete it:
```bash
rm -rf ~/.cache/codebuddycn-ide-linux
```

The new cache directory is `~/.cache/codebuddy-ide-cn-loong64`, which will not conflict.

### 3. Install the New Package

Follow the instructions in the project README to install the new `codebuddy-ide-cn` package.

**Arch Linux (AUR):**
```bash
yay -S codebuddy-ide-cn
# or
paru -S codebuddy-ide-cn
```

**Other distributions:**
```bash
# Build new package
make package
# Install
make install
```

### 4. Update Desktop Database (Optional)

If the desktop menu is not updated after installation, you can manually update it:

```bash
# System-wide
sudo update-desktop-database /usr/share/applications
# User-level (if you have local desktop files)
update-desktop-database ~/.local/share/applications
```

## Configuration Files

Application configuration files are typically located at:
- `~/.config/CodeBuddy CN/` (or similar directories)
- `~/.config/codebuddycn-ide/` (if exists)

These configuration files are unrelated to the package name and typically do not require any action after migration. If you encounter issues, you can back up and delete the configuration directory.

## Verify Migration

After installation, run the following command to verify:
```bash
codebuddy-ide-cn --verbose
```

## Rollback

If you need to roll back to the old version, uninstall the new package and reinstall the old package. The old package installer may still be retained in the build directory `dist/`.

## Contact Support

If you encounter issues during migration, please file an Issue in the project repository.