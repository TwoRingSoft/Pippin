Pod::Spec.new do |s|
  s.name         = 'PippinDebugging'
  s.version      = '2.1.0'
  s.summary      = "A Swift framework providing tools for in-app debugging."
  s.description  = <<-DESC
  A collection of Swift and Objective-C utilities delivering UI and low-level utilities to debug an app while it's running.
                   DESC
  s.homepage     = 'https://github.com/tworingsoft/Pippin'
  s.license      = 'MIT'
  s.author       = { 'Andrew McKnight' => 'andrew@tworingsoft.com' }
  s.pod_target_xcconfig = { 'PRODUCT_BUNDLE_IDENTIFIER' => 'com.tworingsoft.pippin-debugging' }
  s.source       = { :git => 'https://github.com/tworingsoft/Pippin.git', :tag => "#{s.name}-#{s.version}" }
  s.platform     = :ios, '15.6'
  s.swift_version = '5.8'

  s.source_files = 'Sources/PippinDebugging/**/*.{h,m,swift}'

  s.dependency 'FLEX', '~> 2'
  s.dependency 'PippinCore'
end
