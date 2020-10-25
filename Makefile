init:
	brew bundle
	rbenv install --skip-existing
	rbenv exec gem update bundler
	rbenv exec bundle update

build: build-phone build-mac

build-phone:
	xcodebuild -workspace Pippin.xcworkspace -scheme PippinTestHarness -sdk iphoneos -quiet

build-mac:
	xcodebuild -workspace Pippin.xcworkspace -scheme PippinTestHarness-macOS -sdk macosx -quiet

bump:
	rbenv exec bundle exec bumpr $(COMPONENT) $(NAME).podspec --no-commit
	rbenv exec bundle exec migrate-changelog Sources/$(NAME)/CHANGELOG.md `vrsn --read --file $(NAME).podspec` --no-commit
	git commit --all --message "chore: update version and changelog to `vrsn --read --file $(NAME).podspec`"

prerelease-adapters:
	rbenv exec bundle exec prerelease-podspec PippinAdapters.podspec --podspec-name-in-tag --allow-warnings

ADAPTERS_VERSION=$(shell vrsn --read --file PippinAdapters.podspec)
release-adapters:
	rbenv exec bundle exec release-podspec PippinAdapters.podspec --skip-tests --podspec-name-in-tag --allow-warnings --changelog-path Sources/PippinAdapters/CHANGELOG.md --changelog-entry $(ADAPTERS_VERSION)

prerelease-core:
	rbenv exec bundle exec prerelease-podspec PippinCore.podspec --podspec-name-in-tag

CORE_VERSION=$(shell vrsn --read --file PippinCore.podspec)
release-core:
	rbenv exec bundle exec release-podspec PippinCore.podspec --podspec-name-in-tag --changelog-path Sources/PippinCore/CHANGELOG.md --changelog-entry $(CORE_VERSION)

prerelease-library:
	rbenv exec bundle exec prerelease-podspec PippinLibrary.podspec --podspec-name-in-tag --skip-tests

LIBRARY_VERSION=$(shell vrsn --read --file PippinLibrary.podspec)
release-library:
	rbenv exec bundle exec release-podspec PippinLibrary.podspec --skip-tests --podspec-name-in-tag --changelog-path Sources/PippinLibrary/CHANGELOG.md --changelog-entry $(LIBRARY_VERSION)

prerelease-debugging:
	rbenv exec bundle exec prerelease-podspec PippinDebugging.podspec --podspec-name-in-tag

DEBUGGING_VERSION=$(shell vrsn --read --file PippinDebugging.podspec)
release-debugging:
	rbenv exec bundle exec release-podspec PippinDebugging.podspec --podspec-name-in-tag --changelog-path Sources/PippinDebugging/CHANGELOG.md --changelog-entry $(DEBUGGING_VERSION)

prerelease-testing:
	rbenv exec bundle exec prerelease-podspec PippinTesting.podspec --podspec-name-in-tag

TESTING_VERSION=$(shell vrsn --read --file PippinTesting.podspec)
release-testing:
	rbenv exec bundle exec release-podspec PippinTesting.podspec --podspec-name-in-tag --changelog-path Sources/PippinTesting/CHANGELOG.md --changelog-entry $(TESTING_VERSION)

clean-rc-tags:
	git tag --list | grep "\-RC\d*" | xargs -tI @ bash -c "git tag --delete @ &&git push --delete origin @"
