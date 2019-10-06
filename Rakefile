def travis?
    return `whoami`.strip == 'travis'
end

desc 'Initialize development environment.'
task :init do
    sh 'brew tap tworingsoft/formulae'
    sh 'brew bundle'
    sh 'echo \'2.6.2\' > .ruby-version'
    sh 'rbenv install --skip-existing'
    sh 'rbenv exec gem install bundler'
    sh 'rbenv exec bundle'
    sh 'mkdir -p Logs'

    example_projects.each do |project|
      Dir.chdir "Examples/#{project[:project]}" do
        sh 'rbenv exec bundle exec pod install'
      end
    end
end

desc 'Run Pippin unit and smoke tests.'
task :test do
  unit_tests
  test_smoke_test
  example_smoke_tests
  # subspec_smoke_test
end

desc 'Run unit tests against Pippin and PippinTesting.'
task :unit_tests do
    unit_tests
end

desc 'Smoke test installing and building each subspec in isolation against both ObjC- and Swift- based targets across all applicable SDK targets and OSes.'
task :subspec_smoke_test do
    subspec_smoke_test
end

desc 'Smoke test installing and building PippinTesting against unit and UI test targets.'
task :test_smoke_test do
    test_smoke_test
end

desc 'Smoke test installing pods for and building all example projects deliverable via `pod try`.'
task :example_smoke_tests do
  example_smoke_tests
end

def example_smoke_tests
  require 'open3'
  example_projects.each do |example|
    example_project = example[:project]
    example[:schemes].each do |example_scheme|
      puts "travis_fold:start:#{example_scheme}" if travis?
      build_command = "xcrun xcodebuild -workspace Examples/#{example_project}/#{example_project}.xcworkspace -scheme #{example_scheme} 2>&1"
      tee_pipe = "tee Logs/#{example_scheme}_smoke_test.log"
      xcpretty_pipe = 'rbenv exec bundle exec xcpretty'
      puts "#{build_command} | #{tee_pipe} | #{xcpretty_pipe}"
      status_list = Open3.pipeline([build_command], [tee_pipe], [xcpretty_pipe])
      fail if status_list[0] != 0
      puts "travis_fold:end:#{example_scheme}" if travis?
    end
  end
end

def unit_tests
  require 'open3'
  test_destinations.each do |options|
    ios_version = options[:ios_version]
    device_name = options[:device_name]
    ['PippinLibrary-iOS-Unit-Tests', 'PippinTesting-Unit-Tests'].each do |scheme|
      sh "echo travis_fold:start:#{scheme}" if travis?
      build_command = "xcrun xcodebuild -workspace Examples/Pippin/Pippin.xcworkspace -scheme #{scheme} -destination \'platform=iOS Simulator,name=#{device_name},OS=#{ios_version}\' test 2>&1"
      tee_pipe = "tee Logs/#{scheme}_ios_#{ios_version}.log"
      xcpretty_pipe = "rbenv exec bundle exec xcpretty -t"
      puts "#{build_command} | #{tee_pipe} | #{xcpretty_pipe}"
      status_list = Open3.pipeline([build_command], [tee_pipe], [xcpretty_pipe])
      fail if status_list[0] != 0
      sh "echo travis_fold:end:#{scheme}" if travis?
    end
  end
end

def test_smoke_test
  require 'open3'
  test_destinations.each do |options|
    ios_version = options[:ios_version]
    device_name = options[:device_name]
    [ 'PippinUnitTests-iOS', 'PippinUITests-iOS' ].each do |scheme|
      sh "echo travis_fold:start:#{scheme}" if travis?
      build_command = "xcrun xcodebuild -workspace Examples/Pippin/Pippin.xcworkspace -scheme #{scheme} -destination \'platform=iOS Simulator,name=#{device_name},OS=#{ios_version}\' test 2>&1"
      tee_pipe = "tee Logs/#{scheme}_smoke_test_ios_#{ios_version}.log"
      xcpretty_pipe = "rbenv exec bundle exec xcpretty -t"
      puts "#{build_command} | #{tee_pipe} | #{xcpretty_pipe}"
      status_list = Open3.pipeline([build_command], [tee_pipe], [xcpretty_pipe])
      fail if status_list[0] != 0
      sh "echo travis_fold:end:#{scheme}" if travis?
    end
  end
end

def subspec_smoke_test
  require 'fileutils'
  require 'open3'
  
  # create dir to contain all tests
  root_test_path = 'SmokeTests/generated_xcode_projects'
  if Dir.exists?(root_test_path) then
    FileUtils.rm_rf(root_test_path)
  end
  Dir.mkdir(root_test_path)
  
  # test integrating each subspec into a project in each language
  scheme_names.product(languages).each do |subspec_language_combo|
    subspec = subspec_language_combo[0]
    language_name = subspec_language_combo[1]
    
    sdk_versions_per_platform.each_key do |platform|
      next if platform == 'mac' and subspec.include? 'Adapters'
      test_name = [subspec, platform, language_name].join('-')
      
      sh "echo travis_fold:start:#{test_name}" if travis?
      
      # prepare for xcode generation
      xcodegen_spec_yml = make_xcodegen_spec_yml test_name, test_name, platform_xcodegen_names[platform]
      test_path = File.join(root_test_path, test_name)
      FileUtils.mkdir_p(test_path)
      
      Dir.chdir(test_path) do
        # copy in the source files
        FileUtils.cp_r('../../' + platform + '/' + language_name + 'App', test_name)
        
        # generate the xcode project
        spec_filename = 'xcodegen-spec.yml'
        File.open(spec_filename, 'w', File::CREAT) do |spec_file|
          spec_file << xcodegen_spec_yml
          File.chmod(0644, spec_file.path)
        end
        sh "xcodegen --spec #{spec_filename} >> Logs/#{test_name}.log"
        
        # build for each sdk on each platform
        sdk_versions_per_platform[platform].each do |sdk_version|
          integration_test_name = [subspec, language_name, platform, sdk_version].join('-')
          sh "echo travis_fold:start:#{integration_test_name}" if travis?
          
          # create podfile and insert correct subspec name
          extra_dependencies = extra_pod_dependencies[subspec].map {|dependency| "pod '#{dependency}'" }
          File.open(File.join('../..', 'Podfile')) do |podfile|
            replaced_podfile_contents = [
            ['{{PLATFORM}}', platform_to_cocoapods_names[platform]],
            ['{{SDK_VERSION}}', sdk_version],
            ['{{TARGET_NAME}}', test_name],
            ['{{PODSPEC}}', subspec.gsub('-', '/')],
            ['{{EXTRA_POD_DEPENDENCIES}}', extra_dependencies.join("\n")],
            ].inject(podfile.read) do |acc, item|
              acc.gsub(item[0], item[1])
            end
            File.open('Podfile', 'w', File::CREAT) do |new_podfile|
              new_podfile << replaced_podfile_contents
              File.chmod(0644, new_podfile.path)
            end
          end
          
          sh "rbenv exec bundle exec pod install | tee Logs/#{integration_test_name}.log"
          
          sdk_value = platform_to_device_prefix[platform] + sdk_version
          derived_data_path = 'derivedData'
          FileUtils.remove_dir(derived_data_path, true) if Dir.exists?(derived_data_path)
          build_command = "xcrun xcodebuild -workspace #{test_name}.xcworkspace -scheme #{test_name} -sdk #{sdk_value} -derivedDataPath #{derived_data_path} 2>&1"
          tee_pipe = "tee Logs/#{test_name}-#{platform}-#{sdk_version}.log"
          xcpretty_pipe = "rbenv exec bundle exec xcpretty -t"
          puts "#{build_command} | #{tee_pipe} | #{xcpretty_pipe}"
          status_list = Open3.pipeline([build_command], [tee_pipe], [xcpretty_pipe])
          fail if status_list[0] != 0
          sh "echo travis_fold:end:#{test_name}" if travis?
        end
      end
      
      sh "echo travis_fold:end:#{test_name}" if travis?
    end
  end
end

def make_xcodegen_spec_yml test_name, sources_path, platform
<<-XCODEGEN_SPEC_YML
name: #{test_name}
targets:
  #{test_name}:
    scheme: {}
    platform: #{platform}
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
      SWIFT_VERSION: 4.2
      TARGETED_DEVICE_FAMILY: #{platform == 'iOS' ? '1,2' : '4'}
      ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES: $(inherited)
XCODEGEN_SPEC_YML
end

def example_projects
  [
    {:project => 'OperationDemo', :schemes => ['OperationDemo']}, 
    {:project => 'Pippin', :schemes => ['Pippin-iOS', 'Pippin-macOS']},
  ]
end

def test_destinations
  [
    # {:ios_version => '10.3.1', :device_name => 'iPhone 5'}, 
    {:ios_version => '13.1', :device_name => 'iPhone 8'},
  ]
end

def sdk_versions_per_platform 
  {    
    'phone' => ['10.3.1', '13.0'],
    'mac' => ['10.14'],
    # 'tv' => ['11.1'],
    # 'watch' => ['4.1']
  }
end

def platform_to_device_prefix 
  {
    'phone' => 'iphonesimulator',
    'mac' => 'macosx',
    'tv' => 'appletvsimulator',
    'watch' => 'watchsimulator'
  }
end

def platform_to_cocoapods_names
  {
    'phone' => 'ios',
    'mac' => 'osx',
    'tv' => 'tvos',
    'watch' => 'watchos'
  }
end

def platform_xcodegen_names
 {
    'phone' => 'iOS',
    'mac' => 'macOS',
    'tv' => 'tvOS',
    'watch' => 'watchOS',
  }
end

def scheme_names 
  [
    'Pippin',
    'Pippin-Extensions',
    'Pippin-OperationTestHelpers',
    'PippinAdapters-PinpointKit',
    'PippinAdapters-XCGLogger',
    'PippinAdapters-DebugController',
    'PippinAdapters-COSTouchVisualizer',
    'PippinAdapters-JGProgressHUD',
    'PippinAdapters-SwiftMessages',
  ]
end

def extra_pod_dependencies
  {
    'Pippin' => [ 'Crashlytics' ],
    'PippinAdapters-PinpointKit' => [],
    'PippinAdapters-XCGLogger' => [],
    'PippinAdapters-DebugController' => [],
    'PippinAdapters-COSTouchVisualizer' => [],
    'PippinAdapters-JGProgressHUD' => [],
    'PippinAdapters-SwiftMessages' => [],
  }
end

def languages
  ['Swift', 'Objc']
end

# run init task before all tasks for setup
# Rake::Task.tasks.each do |t|
#   next if t.name == 'init'
#   t.enhance [:init]
# end
