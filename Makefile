VERSION_FILE = VERSION

.PHONY: help init xcode build build-macos build-ios patch minor major deploy-beta deploy

.DEFAULT_GOAL := help

help: ## Show this help
	@echo "Pippin — available make targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "} {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

# MARK: - Dev tooling

init: ## Fetch submodules and install the toolchain
	git submodule update --init --recursive
	brew bundle
	rbenv install --skip-existing
	rbenv exec gem update bundler
	rbenv exec bundle update

xcode: ## Update the example app's pods and open its workspace
	pushd Examples/Pippin; rbenv exec bundle exec pod update; xed Examples/Pippin/Pippin.xcworkspace; popd

build-macos: ## Build for macOS
	swift build

build-ios: ## Build for the iOS simulator
	swift build --sdk "$$(xcrun --sdk iphonesimulator --show-sdk-path)" --triple arm64-apple-ios17.0-simulator

build: build-macos build-ios ## Build for macOS and the iOS simulator

# MARK: - Releasing
#
# `make {patch,minor,major}` bumps VERSION with vrsn. Then `make deploy` runs
# prepare-release, which migrates the CHANGELOG [Unreleased] section into a dated
# version section, commits, tags, and pushes. GitHub Actions picks up the tag and
# publishes the GitHub release from that changelog section.
#
# Publishing happens in CI rather than here, so it cannot half-succeed depending
# on the workstation that tagged — which is how 13.0.1 came to be a tag with no
# release.
#
# There is no artifact to ship: dependents resolve the package from the git tag,
# so tagging is the release.
#
# Requires `vrsn` + `prepare-release` on PATH (from the armcknight/tools cask).

patch: ## Bump the patch version (x.y.Z) and commit
	vrsn patch -f $(VERSION_FILE) --commit

minor: ## Bump the minor version (x.Y.0) and commit
	vrsn minor -f $(VERSION_FILE) --commit

major: ## Bump the major version (X.0.0) and commit
	vrsn major -f $(VERSION_FILE) --commit

deploy-beta: ## Migrate the changelog, tag an RC, and push
	prepare-release rc --file $(VERSION_FILE) --push

deploy: ## Migrate the changelog, tag, and push the release
	prepare-release --file $(VERSION_FILE) --push
