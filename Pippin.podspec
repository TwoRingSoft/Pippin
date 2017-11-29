#
#  Be sure to run `pod spec lint Pippin.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = 'Pippin'
  s.version      = '0.0.1'
  s.summary      = "A basic framework for an app's various components, like logging and crash reporting, and various Swift utilities for working with Apple frameworks."
  s.description  = <<-DESC
  A collection of Swift and Objective-C utilities delivering reusable components of iOS applications and utilities to work with Apple frameworks.
                   DESC
  s.homepage     = 'http://github.com/tworingsoft/Pippin'
  s.license      = 'MIT'
  s.author       = { 'Andrew McKnight' => 'andrew@tworingsoft.com' }
  s.source       = { :git => 'https://github.com/tworingsoft/Pippin.git', :tag => "#{s.version}" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # s.platform     = :ios
  # s.platform     = :ios, '5.0'

  #  When using multiple platforms
  s.ios.deployment_target = '10.0'
  # s.osx.deployment_target = '10.7'
  # s.watchos.deployment_target = '2.0'
  # s.tvos.deployment_target = '9.0'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }

  s.test_spec 'Tests' do |test_spec|
      test_spec.source_files = 'Tests/**/*.swift'
  end
  
  s.default_subspecs = 'Core', 'CanIHaz', 'Extensions', 'Adapters', 'Assets'
  
  s.subspec 'Assets' do |ss|
    ss.resource  = 'Resources/Assets.xcassets'
  end
  
  s.subspec 'Adapters' do |ss|
    ss.subspec 'PinpointKit' do |sss|
      sss.source_files = 'Sources/Pippin/Adapters/PinpointKit/**/*.{h,m,swift}'
      sss.dependency 'PinpointKit', '~> 1'
      sss.dependency 'Pippin/Core'
    end
    ss.subspec 'XCGLogger' do |sss|
      sss.source_files = 'Sources/Pippin/Adapters/XCGLogger/**/*.{h,m,swift}'
      sss.dependency 'XCGLogger', '~> 6'
      sss.dependency 'Pippin/Core'
    end
  end
  
  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/Pippin/Core/**/*.{h,m,swift}'
  end
  
  s.subspec 'CanIHaz' do |ss|
    ss.source_files = 'Sources/Pippin/CanIHaz/**/*.{h,m,swift}'
  end
  
  s.subspec 'Extensions' do |ss|
    ss.subspec 'CoreData' do |sss|
      sss.source_files = 'Sources/Pippin/Extensions/CoreData/**/*.{h,m,swift}'
    end
    ss.subspec 'Foundation' do |sss|
      sss.source_files = 'Sources/Pippin/Extensions/Foundation/**/*.{h,m,swift}'
    end
    ss.subspec 'UIKit' do |sss|
      sss.source_files = 'Sources/Pippin/Extensions/UIKit/**/*.{h,m,swift}'
      sss.dependency 'Anchorage', '~> 4'
    end
    ss.subspec 'WebKit' do |sss|
      sss.source_files = 'Sources/Pippin/Extensions/WebKit/**/*.{h,m,swift}'
    end
  end

end
