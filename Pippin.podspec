Pod::Spec.new do |s|
  s.name         = 'Pippin'
  s.version      = '12.1.0'
  s.summary      = "A Swift framework to scaffold an app and make development and maintenance easier."
  s.description  = <<-DESC
    A collection of Swift and Objective-C utilities delivering reusable components of iOS applications and utilities to work with Apple frameworks.
  DESC
  s.homepage     = 'http://github.com/tworingsoft/Pippin'
  s.license      = 'MIT'
  s.author       = { 'Andrew McKnight' => 'andrew@tworingsoft.com' }
  s.source       = { :git => 'https://github.com/tworingsoft/Pippin.git', :tag => "#{s.name}-#{s.version}" }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  
  s.swift_version = '4.2'
  
  s.default_subspecs = ['Core', 'Extensions']
  
  s.subspec 'Core' do |ss|
    ss.ios.source_files = [
      'Sources/Pippin/Seeds/**/*.{h,m,swift}',
      'Sources/Pippin/Sensors/**/*.{h,m,swift}',
      'Sources/Pippin/Controls/**/*.{h,m,swift}',
      'Sources/Pippin/CanIHaz/Camera/**/*.{h,m,swift}',
      'Sources/Pippin/CanIHaz/Location/**/*.{h,m,swift}'
    ]
    ss.ios.dependency 'Result'
    ss.ios.dependency 'Anchorage', '~> 4'
    ss.dependency 'Pippin/Extensions' # just pass through the only thing compatible with macos currently, the extensions, to avoid the empty spec error
  end
  s.subspec 'Extensions' do |ss|
    ss.ios.source_files = [
      'Sources/Pippin/Extensions/**/*.{h,m,swift}'
    ]
    ss.osx.source_files = [
      'Sources/Pippin/Extensions/Foundation/**/*.{h,m,swift}'
    ]
    ss.test_spec 'Tests' do |test_spec|
        test_spec.source_files = 'Tests/Pippin/**/*.{h,m,swift}'
        test_spec.dependency 'Pippin/OperationTestHelpers'
    end
  end
  s.subspec 'OperationTestHelpers' do |ss|
      ss.source_files = 'Tests/Helpers/Operations/**/*.{swift}'
      ss.dependency 'Pippin/Extensions'
  end
  
end
