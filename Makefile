build: build-phone build-mac

build-phone:
	xcodebuild -workspace Pippin.xcworkspace -scheme PippinTestHarness -sdk iphoneos -quiet

build-mac:
	xcodebuild -workspace Pippin.xcworkspace -scheme PippinTestHarness-macOS -sdk macosx -quiet
