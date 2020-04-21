Pod::Spec.new do |s|
  s.name         = 'PippinLibrary'
  s.version      = '2.2.0'
  s.summary      = "Extensions on Cocoa Touch and Swift stdlib SDKs."
  s.description  = <<-DESC
  All manner of extensions, categories, subclasses, wrappers, helpful functions, macros, syntactic sugar, utilities, &c that make coding faster and more semantically accurate.
  DESC
  s.homepage     = 'https://github.com/tworingsoft/Pippin'
  s.license      = 'MIT'
  s.author       = { 'Andrew McKnight' => 'andrew@tworingsoft.com' }
  s.pod_target_xcconfig = { 'PRODUCT_BUNDLE_IDENTIFIER' => 'com.tworingsoft.pippin-library' }
  s.source       = { :git => 'https://github.com/tworingsoft/Pippin.git', :tag => "#{s.name}-#{s.version}" }
  s.swift_version = '5.1'

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.12'

  s.ios.source_files = 'Sources/PippinLibrary/**/*.{h,m,swift}'
  s.osx.source_files = 'Sources/PippinLibrary/Foundation/**/*.{h,m,swift}'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/PippinLibrary/**/*.swift'
  end

  s.dependency 'Anchorage'
  s.ios.dependency 'Closures'
  s.dependency 'Then'
end
