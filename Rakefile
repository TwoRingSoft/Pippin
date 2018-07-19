desc 'Initialize development environment.'
task :init do
    sh 'brew tap tworingsoft/formulae'
    sh 'brew install XcodeGen vrsn'
end

version_file = 'Pippin.podspec'

desc 'Bump version number and commit the changes with message as the output from vrsn. Can supply argument to bump one of: major, minor, patch or build. E.g., `rake bump[major]` or `rake bump[build]`.'
task :bump,[:component] do |t, args|
    require 'open3'

    modified_file_count, stderr, status = Open3.capture3("git status --porcelain | egrep '^(M| M)' | wc -l")
    if modified_file_count.to_i > 0 then
        sh "git stash --all"
    end
  
    component = args[:component]
    if component == 'major' then
        stdout, stderr, status = Open3.capture3("vrsn major --file #{version_file}")
    elsif component == 'minor' then
        stdout, stderr, status = Open3.capture3("vrsn minor --file #{version_file}")
    elsif component == 'patch' then
        stdout, stderr, status = Open3.capture3("vrsn patch --file #{version_file}")
    elsif component == 'build' then
        stdout, stderr, status = Open3.capture3("vrsn --numeric --file #{version_file}")
    else
        fail 'Unrecognized version component.'
    end

    sh "git add #{version_file}"
    sh "git commit --message \"#{stdout}\""
    sh 'git push'
    
    if modified_file_count.to_i > 0 then
        sh "git stash pop"
    end
end


desc 'Create git tags and push them to remote, push podspec to CocoaPods.'
task :release do
  version = `vrsn --read --file #{version_file}`
  sh "git tag #{version.strip}"
  sh 'git push --tags'
  
  sh 'pod trunk push --allow-warnings'
end

desc 'Run Pippin unit tests.'
task :test do
	require 'open3'
	Open3.pipeline(['xcrun xcodebuild -workspace PippinTests.xcworkspace -scheme Pippin-Unit-Tests -destination \'platform=iOS Simulator,name=iPhone SE,OS=10.3.1\' test'], ['tee Pippin-Unit-Tests.log'], ['xcpretty -t'])
end

desc 'Try to integrate and build the individual subspecs into test app targets.'
task :smoke_test do
    require 'fileutils'
  	require 'open3'

    scheme_suffixes = ['Core', 'Extensions', 'CanIHaz-Location', 'CanIHaz-Camera', 'Adapters-PinpointKit', 'Adapters-XCGLogger', 'Adapters-DebugController', 'Extensions-Foundation', 'Extensions-UIKit', 'Extensions-WebKit']
    languages = [ :swift, :objc ]

    # create dir to contain all tests
    root_test_path = 'Pippin/SmokeTests/generated_xcode_projects'
    if Dir.exists?(root_test_path) then
        FileUtils.rm_rf(root_test_path)
    end
    Dir.mkdir(root_test_path)

    # test integrating each subspec into a project in each language
    scheme_suffixes.product(languages).each do |subspec_language_combo|
        subspec = subspec_language_combo[0]
        language = subspec_language_combo[1]
        language_name = language == :swift ? 'Swift' : 'Objc'
        test_name = subspec + '-' + language_name

        # prepare for xcode generation
        xcodegen_spec_yml = make_xcodegen_spec_yml test_name, test_name
        test_path = File.join(root_test_path, test_name)
        FileUtils.mkdir_p(test_path)

        Dir.chdir(test_path) do
            # copy in the source files
            FileUtils.cp_r('../../' + language_name + 'App', test_name)

            # generate the xcode project
            spec_filename = 'xcodegen-spec.yml'
            File.open(spec_filename, 'w', File::CREAT) do |spec_file|
                spec_file << xcodegen_spec_yml
                File.chmod(0644, spec_file.path)
            end
            sh "xcodegen --spec #{spec_filename} >> #{test_name}.log"

            sdk_versions_per_platform = {
                # platform => [ sdk versionss ]
                'phone' => ['11.3'],
                #'mac' => ['10.13'],
                #'tv' => ['11.1'],
                #'watch' => ['4.1']
            }

            platform_to_device_prefix = {
                # platform => [ prefix ]
                'phone' => 'iphonesimulator',
                'mac' => 'macosx',
                'tv' => 'appletvsimulator',
                'watch' => 'watchsimulator'
            }

            platform_to_cocoapods_names = {
                # platform => cocoapods platform name
                'phone' => 'ios',
                'mac' => 'osx',
                'tv' => 'tvos',
                'watch' => 'watchos'
            }

            # build for each sdk on each platform
            sdk_versions_per_platform.each_key do |platform|
                sdk_versions_per_platform[platform].each do |sdk_version|
                    # create podfile and insert correct subspec name
                    File.open(File.join('../..', 'Podfile')) do |podfile|
                        replaced_podfile_contents = [
                            ['{{PLATFORM}}', platform_to_cocoapods_names[platform]],
                            ['{{SDK_VERSION}}', sdk_version],
                            ['{{TARGET_NAME}}', test_name],
                            ['{{SUBSPEC}}', subspec.gsub('-', '/')]
                        ].inject(podfile.read) do |acc, item|
                            acc.gsub(item[0], item[1])
                        end
                        File.open('Podfile', 'w', File::CREAT) do |new_podfile|
                            new_podfile << replaced_podfile_contents
                            File.chmod(0644, new_podfile.path)
                        end
                    end

                    sh "pod install >> #{test_name}.log"

                    sdk_value = platform_to_device_prefix[platform] + sdk_version
                    derived_data_path = 'derivedData'
                    FileUtils.remove_dir(derived_data_path, true) if Dir.exists?(derived_data_path)
                  	Open3.pipeline(["xcrun xcodebuild -workspace #{test_name}.xcworkspace -scheme #{test_name} -sdk #{sdk_value} -derivedDataPath #{derived_data_path}"], ["tee #{test_name}.log"], ['xcpretty -t'])
                end
            end
        end
    end
end

def make_xcodegen_spec_yml test_name, sources_path
<<-XCODEGEN_SPEC_YML
name: #{test_name}
targets:
  #{test_name}:
    scheme: {}
    platform: iOS
    type: application
    sources:
      - path: #{sources_path}
        type: group
    settings:
      ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
      CODE_SIGN_STYLE: Automatic
      INFOPLIST_FILE: #{sources_path}/Info.plist
      LD_RUNPATH_SEARCH_PATHS: $(inherited) @executable_path/Frameworks
      PRODUCT_BUNDLE_IDENTIFIER: com.two-ring-soft.test
      PRODUCT_NAME: #{test_name}
      SWIFT_VERSION: 4.0
      TARGETED_DEVICE_FAMILY: 1,2
XCODEGEN_SPEC_YML
end
