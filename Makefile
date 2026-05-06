SHELL := /bin/bash

.PHONY: help build-app run-app deb package clean check

help:
	@echo "Targets:"
	@echo "  make build-app DMG=/path/to/CodeBuddy.dmg"
	@echo "  make run-app"
	@echo "  make deb"
	@echo "  make package"
	@echo "  make check"
	@echo "  make clean"

build-app:
	bash install.sh $(DMG)

run-app:
	bash codebuddycn-app/start.sh

deb:
	bash scripts/build-deb.sh

package: deb

check:
	bash -n install.sh scripts/*.sh scripts/lib/*.sh

clean:
	rm -rf codebuddycn-app codebuddycn-app-next dist dist-next
