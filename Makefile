VERSION=$(shell cat VERSION)

init:
	brew bundle
	rbenv install --skip-existing
	rbenv exec gem update bundler
	rbenv exec bundle update

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
	@echo $$(echo $(VERSION) | awk -F. '{print $$1+1".0.0"}') > VERSION
	@$(MAKE) -s update-changelog
	@echo "Version bumped to $$(cat VERSION)"

.PHONY: bump-minor
bump-minor:
	@echo $$(echo $(VERSION) | awk -F. '{print $$1"."$$2+1".0"}') > VERSION
	@$(MAKE) -s update-changelog
	@echo "Version bumped to $$(cat VERSION)"

.PHONY: bump-patch
bump-patch:
	@echo $$(echo $(VERSION) | awk -F. '{print $$1"."$$2"."$$3+1}') > VERSION
	@$(MAKE) -s update-changelog
	@echo "Version bumped to $$(cat VERSION)"

.PHONY: update-changelog
update-changelog:
	@NEW_VERSION=$$(cat VERSION); \
	DATE=$$(date +%Y-%m-%d); \
	sed -i '' "s/## \[Unreleased\]/## [Unreleased]\n\n## [$$NEW_VERSION] - $$DATE/" CHANGELOG.md

.PHONY: release
release:
	@if [ -n "$$(git status --porcelain)" ]; then echo "Error: working directory not clean"; exit 1; fi
	git tag $(VERSION)
	git push origin $(VERSION)
	@echo "Released $(VERSION)"
