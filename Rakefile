desc 'Initialize development environment.'
task :init do
    sh 'bundle'
end

desc 'Run Pippin unit tests.'
task :test do
	require 'open3'
	Open3.pipeline(['xcrun xcodebuild -project PippinTests.xcodeproj -scheme PippinTests -destination \'platform=iOS Simulator,name=iPhone SE,OS=10.3.1\' test'], ['xcpretty -t' ])
end
end
