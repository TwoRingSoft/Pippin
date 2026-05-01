VERSION_FILE = VERSION

init:
	git submodule update --init --recursive
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

# MARK: - Releasing

.PHONY: patch
patch:
	vrsn patch -f $(VERSION_FILE) --commit

.PHONY: minor
minor:
	vrsn minor -f $(VERSION_FILE) --commit

.PHONY: major
major:
	vrsn major -f $(VERSION_FILE) --commit

.PHONY: deploy-beta
deploy-beta:
	@{ \
	prepare-release rc --file $(VERSION_FILE) --push --github-release --prerelease ; \
	} 2>&1 | tee deploy.log

.PHONY: deploy
deploy:
	@{ \
	prepare-release --file $(VERSION_FILE) --push --github-release ; \
	} 2>&1 | tee deploy.log
