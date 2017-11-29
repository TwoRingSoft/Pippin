desc 'Initialize development environment.'
task :init do
    sh 'brew tap yonaskolb/XcodeGen https://github.com/yonaskolb/XcodeGen.git'
    sh 'brew install XcodeGen'
end

desc 'Run Pippin unit tests.'
task :test do
	require 'open3'
	Open3.pipeline(['xcrun xcodebuild -project PippinTests.xcodeproj -scheme PippinTests -destination \'platform=iOS Simulator,name=iPhone SE,OS=10.3.1\' test'], ['xcpretty -t' ])
end

desc 'Try to integrate and build the individual subspecs into each of the corresponding app targets.'
task :smoke_test do

    scheme_suffixes = ['Core', 'Extensions', 'CanIHaz', 'Adapters', 'Extensions-CoreData', 'Extensions-Foundation', 'Extensions-UIKit', 'Extensions-WebKit']
    languages = [ :swift, :objc ]


    # platform => [ sdks ]
    sdks = {
        'phone' => ['iphonesimulator11.1'],
        #'mac' => ['macosx10.13'],
        #'tv' => ['appletvsimulator11.1'],
        #'watch' => ['watchsimulator4.1']
    }

    sdks.each_key do |platform|
        sdks_for_platform = sdks[platform]
        sdks_for_platform.product(scheme_suffixes).each do |scheme_sdk_combo|
            sdk = scheme_sdk_combo[0]
            scheme_suffix = scheme_sdk_combo[1]
            sh "xcrun xcodebuild -project PippinTests.xcodeproj -scheme Subspec-#{scheme_suffix} -sdk #{sdk}"
        end
    end
end
