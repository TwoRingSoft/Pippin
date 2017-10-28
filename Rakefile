task :test do
	require 'open3'
	Open3.pipeline(['xcrun xcodebuild -project Pippin.xcodeproj -scheme PippinTests -destination \'platform=iOS Simulator,name=iPhone SE,OS=10.3.1\' test'], ['xcpretty -t' ])
end
