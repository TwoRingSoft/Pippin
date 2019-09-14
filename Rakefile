def travis?
    return `whoami`.strip == 'travis'
end

desc 'Initialize development environment.'
task :init do
    sh 'brew tap tworingsoft/formulae'
    sh 'brew bundle'
    sh 'rbenv install'
    sh 'rbenv exec gem install bundler'
    sh 'rbenv exec bundle update'
    sh 'rbenv exec bundle package'
end

desc 'Bump version number for the specified podspec and commit the changes with message as the output from vrsn.'
task :bump,[:component, :podspec] do |t, args|
    require 'open3'
    
    version_file = "#{args[:podspec]}.podspec"

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

desc 'Perform prerelease tests and checks to do to make sure release happens correctly.'
task :prerelease,[:podspec] do |r, args|
  podspec = args[:podspec]
  version_file = "#{podspec}.podspec"
  current_version = `vrsn --read --file #{version_file}`.strip
  branch = "#{current_version}-release"
  sh "git checkout -b #{branch}"
  tag_root = "#{podspec}-#{current_version}-RC"
  release_candidate_number = `git tag --list | grep #{tag_root} | wc -l`.strip.to_i + 1
  release_candidate_tag = "#{tag_root}#{release_candidate_number}"
  sh "sed -i '' \"s/\\(\\.version *= *'\\).*'/\\1\"#{current_version}-RC#{release_candidate_number}\"\\'/g\" #{version_file}"
  sh "git add #{version_file}"
  sh "git commit --message 'TEMP: set podspec version to release candidate version'"
  sh "git tag #{release_candidate_tag}"
  sh 'git push --tags'
  puts "About to lint the podspec. This takes a while... (it is now #{Time.now})"
  sh "rbenv exec bundle exec pod spec lint #{podspec}.podspec --allow-warnings"
  sh 'git checkout master'
  sh "git branch -D #{branch}"
  sh "git tag --delete #{release_candidate_tag}"
  sh "git push --delete origin #{release_candidate_tag}"
end

desc 'Create git tags and push them to remote, push podspec to CocoaPods.'
task :release,[:podspec] do |t, args|
  podspec = args[:podspec]
  version_file = "#{podspec}.podspec"
  version = `vrsn --read --file #{version_file}`
  sh "git tag #{podspec}-#{version.strip}"
  sh 'git push --tags'
  sh "rbenv exec bundle exec pod trunk push #{podspec}.podspec --allow-warnings"
end

desc 'Reverse the last git tag, for use when a release fails.'
task :reverse_last_tag,[:podspec] do |t, args|
    podspec = args[:podspec]
    version_file = "#{podspec}.podspec"
    version = `vrsn --read --file #{version_file}`.strip
    tag = "#{podspec}-#{version}"
    sh "git tag --delete #{tag}"
    sh "git push --delete origin #{tag}"
end

desc 'Run Pippin unit and smoke tests.'
task :test do
  unit_tests
  app_smoke_test
  test_smoke_test
  example_smoke_tests
end

desc 'Run unit tests against Pippin and PippinTesting.'
task :unit_test do
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
  require 'open3'
  ['OperationDemo'].each do |example_project|
    puts "travis_fold:start:#{example_project}" if travis?
    Dir.chdir("Examples/#{example_project}") do
      update_command = 'rbenv exec bundle exec pod update --no-repo-update'
      puts update_command
      Open3.pipeline([update_command])
      build_command = "xcrun xcodebuild -workspace #{example_project}.xcworkspace -scheme #{example_project}"
      tee_pipe = "tee #{example_project}_smoke_test.log"
      xcpretty_pipe = 'rbenv exec bundle exec xcpretty'
      puts "#{build_command} | #{tee_pipe} | #{xcpretty_pipe}"
      Open3.pipeline([build_command], [tee_pipe], [xcpretty_pipe])
    end
    puts "travis_fold:end:#{example_project}" if travis?
  end
end

def unit_tests
  require 'open3'
  ['12.4'].each do |ios_version|
    ['Pippin-Unit-Tests', 'PippinTesting-Unit-Tests'].each do |scheme|
      sh "echo travis_fold:start:#{scheme}" if travis?
      build_command = "xcrun xcodebuild -workspace Pippin.xcworkspace -scheme #{scheme} -destination \'platform=iOS Simulator,name=iPhone SE,OS=#{ios_version}\' test"
      tee_pipe = "tee #{scheme}_ios_#{ios_version}.log"
      xcpretty_pipe = "rbenv exec bundle exec xcpretty -t"
      puts "#{build_command} | #{tee_pipe} | #{xcpretty_pipe}"
      Open3.pipeline([build_command], [tee_pipe], [xcpretty_pipe])
      sh "echo travis_fold:end:#{scheme}" if travis?
    end
  end
end

def test_smoke_test
  require 'open3'
  ['12.4'].each do |ios_version|
    [ 'PippinUnitTests', 'PippinUITests' ].each do |scheme|
      sh "echo travis_fold:start:#{scheme}" if travis?
      build_command = "xcrun xcodebuild -workspace Pippin.xcworkspace -scheme #{scheme} -destination \'platform=iOS Simulator,name=iPhone SE,OS=#{ios_version}\' test"
      tee_pipe = "tee #{scheme}_smoke_test_ios_#{ios_version}.log"
      xcpretty_pipe = "rbenv exec bundle exec xcpretty -t"
      puts "#{build_command} | #{tee_pipe} | #{xcpretty_pipe}"
      Open3.pipeline([build_command], [tee_pipe], [xcpretty_pipe])
      sh "echo travis_fold:end:#{scheme}" if travis?
    end
  end
end

def subspec_smoke_test
  require 'fileutils'
  require 'open3'
  
  sdk_versions_per_platform = {
    # platform => [ sdk versions ]
    'phone' => ['12.1'],
    'mac' => ['10.14'],
#    'tv' => ['11.1'],
#    'watch' => ['4.1']
  }
  
  platform_to_device_prefix = {
    # platform => prefix
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
  
  platform_xcodegen_names = {
    'phone' => 'iOS',
    'mac' => 'macOS',
    'tv' => 'tvOS',
    'watch' => 'watchOS',
  }
  
  scheme_names = [
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

  extra_pod_dependencies = {
    'Pippin' => [ 'Crashlytics' ],
    'PippinAdapters-PinpointKit' => [],
    'PippinAdapters-XCGLogger' => [],
    'PippinAdapters-DebugController' => [],
    'PippinAdapters-COSTouchVisualizer' => [],
    'PippinAdapters-JGProgressHUD' => [],
    'PippinAdapters-SwiftMessages' => [],
    'Pippin-OperationTestHelpers' => [],
  }
  
  languages = [
    :swift,
    :objc,
  ]
  
  # create dir to contain all tests
  root_test_path = 'Pippin/SmokeTests/generated_xcode_projects'
  if Dir.exists?(root_test_path) then
    FileUtils.rm_rf(root_test_path)
  end
  Dir.mkdir(root_test_path)
  
  # test integrating each subspec into a project in each language
  scheme_names.product(languages).each do |subspec_language_combo|
    subspec = subspec_language_combo[0]
    language = subspec_language_combo[1]
    language_name = language == :swift ? 'Swift' : 'Objc'
    
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
        sh "xcodegen --spec #{spec_filename} >> #{test_name}.log"
        
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
          
          sh "rbenv exec bundle exec pod install | tee #{integration_test_name}.log"
          
          sdk_value = platform_to_device_prefix[platform] + sdk_version
          derived_data_path = 'derivedData'
          FileUtils.remove_dir(derived_data_path, true) if Dir.exists?(derived_data_path)
          build_command = "xcrun xcodebuild -workspace #{test_name}.xcworkspace -scheme #{test_name} -sdk #{sdk_value} -derivedDataPath #{derived_data_path}"
          tee_pipe = "tee #{test_name}-#{platform}-#{sdk_version}.log"
          xcpretty_pipe = "rbenv exec bundle exec xcpretty -t"
          puts "#{build_command} | #{tee_pipe} | #{xcpretty_pipe}"
          Open3.pipeline([build_command], [tee_pipe], [xcpretty_pipe])
          
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
