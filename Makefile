SHELL := /bin/bash

# ── CodeBuddy Linux .deb download config ──────────────────────────
# Only update these three values when a new version is released.
CB_VERSION  := 4.10.0
CB_BUILD    := 32999201
CB_HASH     := c8bdde62
# ───────────────────────────────────────────────────────────────────
CB_BASE_URL     := https://download.codebuddy.cn/aiide/linux-x64/CodeBuddy-linux-x64-
CB_SUFFIX       := -cn.deb
DEB_URL         := $(CB_BASE_URL)$(CB_VERSION).$(CB_BUILD)-$(CB_HASH)$(CB_SUFFIX)

# ── AppImage config ───────────────────────────────────────────────
LINUXDEPLOY_ARCH := loongarch64
LINUXDEPLOY_URL  := https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-$(LINUXDEPLOY_ARCH).AppImage
APPIMAGE_OUT     := dist/codebuddy-ide-cn-loongarch64.AppImage
# ───────────────────────────────────────────────────────────────────

.PHONY: help deps download build-app appimage run-app deb rpm pacman package install clean check

help:
	@echo "Targets:"
	@echo "  make deps"
	@echo "  make download              Download latest Linux x64 .deb to downloads/"
	@echo "  make build-app"
	@echo "  make build-app DEB=/path/to/CodeBuddy.deb"
	@echo "  make appimage              Build AppImage (requires build-app first)"
	@echo "  make run-app"
	@echo "  make deb"
	@echo "  make rpm"
	@echo "  make pacman"
	@echo "  make package"
	@echo "  make install"
	@echo "  make check"
	@echo "  make clean"

deps:
	bash scripts/install-deps.sh

download:
	bash scripts/download.sh "$(DEB_URL)"

build-app:
	@if [ -n "$(DEB)" ]; then bash install.sh "$(DEB)"; else bash install.sh; fi

codebuddycn-app/start.sh:
	$(MAKE) build-app

appimage: codebuddycn-app/start.sh
	LINUXDEPLOY_URL="$(LINUXDEPLOY_URL)" APPIMAGE_OUT="$(APPIMAGE_OUT)" \
	  bash scripts/build-appimage.sh

run-app:
	bash codebuddycn-app/start.sh

deb:
	bash scripts/build-deb.sh

rpm:
	bash scripts/build-rpm.sh

pacman:
	bash scripts/build-pacman.sh

package:
	bash scripts/package.sh

install:
	bash scripts/install-package.sh

check:
	bash -n install.sh scripts/*.sh scripts/lib/*.sh

clean:
	rm -rf codebuddycn-app codebuddycn-app-next dist dist-next
