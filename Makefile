VERSION=$(shell cat VERSION)
TOOLS_BIN = tools/.build/release

init:
	git submodule update --init --recursive
	brew bundle
	rbenv install --skip-existing
	rbenv exec gem update bundler
	rbenv exec bundle update
	cd tools && swift build -c release

.PHONY: xcode
xcode:
	pushd Examples/Pippin; rbenv exec bundle exec pod update; xed Examples/Pippin/Pippin.xcworkspace; popd

.PHONY: build-macos
build-macos:
	swift build

.PHONY: build-ios
build-ios:
	swift build --sdk "$$(xcrun --sdk iphonesimulator --show-sdk-path)" --triple arm64-apple-ios17.0-simulator

.PHONY: build
build: build-macos build-ios

.PHONY: bump-major
bump-major:
	$(TOOLS_BIN)/vrsn major -f VERSION
	$(TOOLS_BIN)/migrate-changelog CHANGELOG.md $$(cat VERSION) --no-commit

.PHONY: bump-minor
bump-minor:
	$(TOOLS_BIN)/vrsn minor -f VERSION
	$(TOOLS_BIN)/migrate-changelog CHANGELOG.md $$(cat VERSION) --no-commit

.PHONY: bump-patch
bump-patch:
	$(TOOLS_BIN)/vrsn patch -f VERSION
	$(TOOLS_BIN)/migrate-changelog CHANGELOG.md $$(cat VERSION) --no-commit

.PHONY: release
release:
	@if [ -n "$$(git status --porcelain)" ]; then echo "Error: working directory not clean"; exit 1; fi
	$(TOOLS_BIN)/changetag CHANGELOG.md $(VERSION)
	git push origin $(VERSION)
