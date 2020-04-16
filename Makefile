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
	rbenv exec bundle exec migrate-changelog Sources/$(NAME)/CHANGELOG.md `vrsn --read --file $(NAME).podspec`

prerelease-adapters:
	rbenv exec bundle exec prerelease-podspec PippinAdapters --podspec-name-in-tag --allow-warnings

release-adapters:
	rbenv exec bundle exec release-podspec PippinAdapters --skip-tests --podspec-name-in-tag --allow-warnings

prerelease-core:
	rbenv exec bundle exec prerelease-podspec PippinCore --podspec-name-in-tag

release-core:
	rbenv exec bundle exec release-podspec PippinCore --podspec-name-in-tag

prerelease-library:
	rbenv exec bundle exec prerelease-podspec PippinLibrary --podspec-name-in-tag

release-library:
	rbenv exec bundle exec release-podspec PippinLibrary --skip-tests --podspec-name-in-tag

prerelease-debugging:
	rbenv exec bundle exec prerelease-podspec PippinDebugging --podspec-name-in-tag

release-debugging:
	rbenv exec bundle exec release-podspec PippinDebugging --podspec-name-in-tag

prerelease-testing:
	rbenv exec bundle exec prerelease-podspec PippinTesting --podspec-name-in-tag

release-testing:
	rbenv exec bundle exec release-podspec PippinTesting --podspec-name-in-tag

clean-rc-tags:
	git tag --list | grep "-RC" | xargs -I @ git push --delete origin @
