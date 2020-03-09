build: build-phone build-mac

build-phone:
	xcodebuild -workspace Pippin.xcworkspace -scheme PippinTestHarness -sdk iphoneos -quiet

build-mac:
	xcodebuild -workspace Pippin.xcworkspace -scheme PippinTestHarness-macOS -sdk macosx -quiet

bump:
	rbenv exec bundle exec bumpr $(COMPONENT) $(NAME).podspec

release-adapters:
	rbenv exec bundle exec release-podspec PippinAdapters --skip-tests --podspec-name-in-tag --allow-warnings

release-core:
	rbenv exec bundle exec release-podspec PippinCore

release-library:
	rbenv exec bundle exec release-podspec PippinLibrary --skip-tests
