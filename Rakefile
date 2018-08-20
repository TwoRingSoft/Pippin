def ruby_environment_prefixes
  user = `whoami`.strip
  if user == 'travis' then
    ''
  else
    'rbenv exec'
  end
end

desc 'Initialize development environment.'
task :init do
    sh 'brew update'
    sh 'brew tap tworingsoft/formulae'
    [ 'XcodeGen', 'tworingsoft/formulae/vrsn' ].each do |formula|
        sh "brew install #{formula} || brew upgrade #{formula}"
    end
    sh "#{ruby_environment_prefixes} gem install xcpretty"
    sh "#{ruby_environment_prefixes} pod install --repo-update --verbose"
end

desc 'Bump version number for the specified podspec and commit the changes with message as the output from vrsn.'
task :bump,[:component, :podspec] do |t, args|
    require 'open3'
    
    version_file = version_file_from_podspec args[:podspec]

    modified_file_count, stderr, status = Open3.capture3("git status --porcelain | egrep '^(M| M)' | wc -l")
    if modified_file_count.to_i > 0 then
        sh "git stash"
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
    
    if modified_file_count.to_i > 0 then
        sh "git stash pop"
    end
end

def version_file_from_podspec podspec
  if podspec == 'Pippin' then
    'Pippin.podspec'
  elsif podspec == 'PippinTesting' then
    'PippinTesting.podspec'
  else
    fail 'Unrecognized podspec name.'
  end
end

desc 'Create git tags and push them to remote, push podspec to CocoaPods.'
task :release,[:podspec, :retry] do |t, args|
  podspec = args[:podspec]
  version_file = version_file_from_podspec podspec
  version = `vrsn --read --file #{version_file}`
  unless args[:retry] then
      sh "git tag #{podspec}-#{version.strip}"
      sh 'git push --tags'
  end
  
  sh "pod trunk push #{podspec}.podspec --allow-warnings"
end

desc 'Create git tags and push them to remote, push podspec to CocoaPods.'
task :reverse_last_tag,[:podspec] do |t, args|
    podspec = args[:podspec]
    version_file = version_file_from_podspec podspec
    version = `vrsn --read --file #{version_file}`
    tag = "#{podspec}-#{version.strip}"
    sh "git tag --delete #{tag}"
    sh "git push --delete origin #{tag}"
end

desc 'Run Pippin unit and smoke tests.'
task :test do
  unit_tests
  app_smoke_test
  test_bundle_smoke_test
end

def unit_tests
  require 'open3'
  ['Pippin-Unit-Tests', 'PippinTesting-Unit-Tests'].each do |scheme|
    sh "echo travis_fold:start:#{scheme}"
    Open3.pipeline(
      ["xcrun xcodebuild -workspace Pippin.xcworkspace -scheme #{scheme} -destination \'platform=iOS Simulator,name=iPhone SE,OS=11.4\' test"],
      ["tee #{scheme}.log"],
      ["#{ruby_environment_prefixes} xcpretty -t"]
    )
    sh "echo travis_fold:end:#{scheme}"
  end
end

def test_bundle_smoke_test
  require 'open3'
  [ 'PippinUnitTests' ].each do |scheme|
    sh "echo travis_fold:start:#{scheme}"
    Open3.pipeline(
      ["xcrun xcodebuild -workspace Pippin.xcworkspace -scheme #{scheme} -destination \'platform=iOS Simulator,name=iPhone SE,OS=11.4\' test"],
      ['tee #{scheme}_smoke_test.log'],
      ["#{ruby_environment_prefixes} xcpretty -t"]
    )
    sh "echo travis_fold:end:#{scheme}"
  end
end

def app_smoke_test
  require 'fileutils'
  require 'open3'
  
  scheme_suffixes = [
      'Core',
      'Extensions',
      'CanIHaz-Location',
      'CanIHaz-Camera',
      'Adapters-PinpointKit',
      'Adapters-XCGLogger',
      'Adapters-DebugController',
      'Extensions-Foundation',
      'Extensions-UIKit',
      'Extensions-WebKit',
      'Sensors-Location'
  ]
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
    
    sh "echo travis_fold:start:#{test_name}"
    
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
        'phone' => ['11.4'],
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
          integration_test_name = [subspec, language_name, platform, sdk_version].join('-')
          sh "echo travis_fold:start:#{integration_test_name}"
          
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
          
          sh "pod install >> #{integration_test_name}.log"
          
          sdk_value = platform_to_device_prefix[platform] + sdk_version
          derived_data_path = 'derivedData'
          FileUtils.remove_dir(derived_data_path, true) if Dir.exists?(derived_data_path)
          Open3.pipeline(
            ["xcrun xcodebuild -workspace #{test_name}.xcworkspace -scheme #{test_name} -sdk #{sdk_value} -derivedDataPath #{derived_data_path}"], 
            ["tee #{test_name}.log"], 
            ["#{ruby_environment_prefixes} xcpretty -t"]
          )

          sh "echo travis_fold:end:#{test_name}"
        end
      end
    end
    
    sh "echo travis_fold:end:#{test_name}"
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
