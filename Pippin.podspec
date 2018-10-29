Pod::Spec.new do |s|
  s.name         = 'Pippin'
  s.version      = '12.0.0'
  s.summary      = "A Swift framework to scaffold an app and make development and maintenance easier."
  s.description  = <<-DESC
    A collection of Swift and Objective-C utilities delivering reusable components of iOS applications and utilities to work with Apple frameworks.
  DESC
  s.homepage     = 'http://github.com/tworingsoft/Pippin'
  s.license      = 'MIT'
  s.author       = { 'Andrew McKnight' => 'andrew@tworingsoft.com' }
  s.source       = { :git => 'https://github.com/tworingsoft/Pippin.git', :tag => "#{s.name}-#{s.version}" }
  s.platform     = :ios, '9.0'
  s.swift_version = '4.2'
  
  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/Pippin/**/*.swift'
  end
  
  s.default_subspecs = ['Core', 'Extensions']
  
  s.subspec 'Core' do |ss|
    ss.source_files = [
      'Sources/Pippin/Core/**/*.{h,m,swift}',
      'Sources/Pippin/Sensors/**/*.{h,m,swift}',
      'Sources/Pippin/Controls/**/*.{h,m,swift}',
      'Sources/Pippin/CanIHaz/Camera/**/*.{h,m,swift}',
      'Sources/Pippin/CanIHaz/Location/**/*.{h,m,swift}'
    ]
    ss.dependency 'Result'
    ss.dependency 'Anchorage', '~> 4'
    ss.dependency 'Pippin/Extensions'
  end
  s.subspec 'Extensions' do |ss|
    ss.source_files = [
      'Sources/Pippin/Extensions/**/*.{h,m,swift}'
    ]
  end
  
end
