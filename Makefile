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
	rbenv exec bundle exec bumpr $(COMPONENT) $(NAME).podspec
	rbenv exec bundle exec migrate-changelog Sources/$(NAME)/CHANGELOG.md $(NAME)-`vrsn --read --file $(NAME).podspec`

prerelease-adapters:
	rbenv exec bundle exec prerelease-podspec PippinAdapters --podspec-name-in-tag --allow-warnings

release-adapters:
	rbenv exec bundle exec release-podspec PippinAdapters --skip-tests --podspec-name-in-tag --allow-warnings --changelog-path Sources/PippinAdapters/CHANGELOG.md

prerelease-core:
	rbenv exec bundle exec prerelease-podspec PippinCore --podspec-name-in-tag

release-core:
	rbenv exec bundle exec release-podspec PippinCore --podspec-name-in-tag --changelog-path Sources/PippinCore/CHANGELOG.md

prerelease-library:
	rbenv exec bundle exec prerelease-podspec PippinLibrary --podspec-name-in-tag

release-library:
	rbenv exec bundle exec release-podspec PippinLibrary --skip-tests --podspec-name-in-tag --changelog-path Sources/PippinLibrary/CHANGELOG.md

prerelease-debugging:
	rbenv exec bundle exec prerelease-podspec PippinDebugging --podspec-name-in-tag

release-debugging:
	rbenv exec bundle exec release-podspec PippinDebugging --podspec-name-in-tag --changelog-path Sources/PippinDebugging/CHANGELOG.md

prerelease-testing:
	rbenv exec bundle exec prerelease-podspec PippinTesting --podspec-name-in-tag

release-testing:
	rbenv exec bundle exec release-podspec PippinTesting --podspec-name-in-tag --changelog-path Sources/PippinTesting/CHANGELOG.md

clean-rc-tags:
	git tag --list | grep "\-RC\d*" | xargs -tI @ bash -c "git tag --delete @ &&git push --delete origin @"
