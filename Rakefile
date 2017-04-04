task :test do
	require 'open3'
	Open3.pipeline(['xcrun xcodebuild -project Xcode/shared-utils-tests.xcodeproj -scheme shared-utilsTests -destination \'platform=iOS Simulator,name=iPhone SE,OS=10.3\' test'], ['xcpretty -t' ])
end
