# travis has trouble finding a simulator, unless you specify the id to use
task :test_travis do
	sh 'xcrun \
	xcodebuild \
	-project Xcode/shared-utils-tests.xcodeproj \
	-scheme shared-utilsTests \
	-destination \'platform=iOS Simulator,id=EF14975A-06EA-4CD6-8003-0767995A2DC0\' \
	test'
end

task :test do
	sh 'xcrun \
	xcodebuild \
	-project Xcode/shared-utils-tests.xcodeproj \
	-scheme shared-utilsTests \
	-destination \'platform=iOS Simulator,name=iPhone 6\' \
	test'
end
