build: build-ios build-macos

build-ios:
	xcodebuild -workspace Pippin.xcworkspace -scheme Pippin.default-OperationTestHelpers-iOS -sdk iphoneos -quiet

build-macos:
	xcodebuild -workspace Pippin.xcworkspace -scheme Pippin.default-OperationTestHelpers-macOS -sdk macosx -quiet
