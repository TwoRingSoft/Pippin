task :test do
	sh 'xcrun \
	xcodebuild \
	-project Xcode/shared-utils-tests.xcodeproj \
	-scheme shared-utilsTests \
	-destination \'platform=iOS Simulator,OS=10.2,name=iPhone SE\' \
	test'
end