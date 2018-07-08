Pod::Spec.new do |s|
  s.name         = 'PippinTesting'
  s.version      = '1.0.0'
  s.summary      = "A Swift framework to make Xcode testing easier.."
  s.description  = <<-DESC
  A collection of Swift and Objective-C utilities delivering helper functions to work with XCTest and XCUIApplication API in service of concise, readable and robust test code.
                   DESC
  s.homepage     = 'http://github.com/tworingsoft/Pippin'
  s.license      = 'MIT'
  s.author       = { 'Andrew McKnight' => 'andrew@tworingsoft.com' }
  s.source       = { :git => 'https://github.com/tworingsoft/Pippin.git', :tag => "#{s.version}" }
  s.platform     = :ios, '9.0'

  s.source_files = 'Sources/PippinTesting/Extensions/XCTest/**/*.{h,m,swift}'
  s.frameworks = 'XCTest'
  
  s.test_spec 'Tests' do |test_spec|
      test_spec.source_files = 'Tests/PippinTesting/**/*.swift'
  end
  
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }
end
