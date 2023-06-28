Pod::Spec.new do |s|
  s.name         = 'PippinCore'
  s.version      = '2.2.0'
  s.summary      = "A Swift framework to scaffold and abstract the common major parts of an app, to make development faster and maintenance easier."
  s.description  = <<-DESC
    A collection of Swift and Objective-C utilities delivering reusable components of iOS applications and utilities to work with Apple and third-party frameworks.
  DESC
  s.homepage     = 'https://github.com/tworingsoft/Pippin'
  s.license      = 'MIT'
  s.author       = { 'Andrew McKnight' => 'andrew@tworingsoft.com' }
  s.source       = { :git => 'https://github.com/tworingsoft/Pippin.git', :tag => "#{s.name}-#{s.version}" }
  s.pod_target_xcconfig = { 'PRODUCT_BUNDLE_IDENTIFIER' => 'com.tworingsoft.pippin' }
  s.ios.deployment_target = '15.6'

  s.swift_version = '5.8'

  s.source_files = ['Sources/PippinCore/**/*.{h,m,swift}']

  s.dependency 'Result'
  s.dependency 'PippinLibrary'

  s.module_name = 'Pippin'
end
