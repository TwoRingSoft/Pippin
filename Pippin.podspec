#
#  Be sure to run `pod spec lint Pippin.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = 'Pippin'
  s.version      = '11.0.0'
  s.summary      = "A Swift framework to scaffold an app and make development and maintenance easier."
  s.description  = <<-DESC
  A collection of Swift and Objective-C utilities delivering reusable components of iOS applications and utilities to work with Apple frameworks.
                   DESC
  s.homepage     = 'http://github.com/tworingsoft/Pippin'
  s.license      = 'MIT'
  s.author       = { 'Andrew McKnight' => 'andrew@tworingsoft.com' }
  s.source       = { :git => 'https://github.com/tworingsoft/Pippin.git', :tag => "#{s.name}-#{s.version}" }
  s.platform     = :ios, '9.0'
  s.swift_version = '4.0'

  s.test_spec 'Tests' do |test_spec|
      test_spec.source_files = 'Tests/Pippin/**/*.swift'
  end
  
  s.default_subspecs = 'Core', 'Adapters'
  
  s.subspec 'Core' do |ss|
      ss.source_files = [
        'Sources/Pippin/Core/**/*.{h,m,swift}',
        'Sources/Pippin/Extensions/**/*.{h,m,swift}',
        'Sources/Pippin/Sensors/**/*.{h,m,swift}',
        'Sources/Pippin/CanIHaz/Camera/**/*.{h,m,swift}',
        'Sources/Pippin/CanIHaz/Location/**/*.{h,m,swift}'
      ]
      ss.dependency 'Result'
      ss.dependency 'Anchorage', '~> 4'
  end
  
  s.subspec 'Adapters' do |ss|
    ss.subspec 'PinpointKit' do |sss|
      sss.source_files = 'Sources/Pippin/Adapters/PinpointKit/**/*.{h,m,swift}'
      sss.dependency 'PinpointKit', '~> 1'
      sss.dependency 'Pippin/Core'
    end
    ss.subspec 'COSTouchVisualizer' do |sss|
      sss.source_files = 'Sources/Pippin/Adapters/COSTouchVisualizer/**/*.{h,m,swift}'
      sss.dependency 'COSTouchVisualizer', '~> 1'
      sss.dependency 'Pippin/Core'
    end
    ss.subspec 'XCGLogger' do |sss|
      sss.source_files = 'Sources/Pippin/Adapters/XCGLogger/**/*.{h,m,swift}'
      sss.dependency 'XCGLogger', '~> 6'
      sss.dependency 'Pippin/Core'
    end
    ss.subspec 'SwiftMessages' do |sss|
      sss.source_files = 'Sources/Pippin/Adapters/SwiftMessages/**/*.{h,m,swift}'
      sss.dependency 'SwiftMessages', '~> 4'
      sss.dependency 'Pippin/Core'
    end
    ss.subspec 'DebugController' do |sss|
      sss.source_files = 'Sources/Pippin/Adapters/DebugController/**/*.{h,m,swift}'
      sss.dependency 'Pippin/Core'
    end
    ss.subspec 'JGProgressHUD' do |sss|
      sss.source_files = 'Sources/Pippin/Adapters/JGProgressHUD/**/*.{h,m,swift}'
      sss.dependency 'Pippin/Core'
      sss.dependency 'JGProgressHUD'
    end
  end

end
