Pod::Spec.new do |s|
  s.name         = 'PippinAdapters'
  s.version      = '1.0.0'
  s.summary      = "Plugins for Pippin Protocols."
  s.description  = <<-DESC
                   A collection of pluggable adapters to third-party dependencies, or entirely self-rolled implementations for Pippin protocols.
                   DESC
  s.homepage     = 'http://github.com/tworingsoft/Pippin'
  s.license      = 'MIT'
  s.author       = { 'Andrew McKnight' => 'andrew@tworingsoft.com' }
  s.source       = { :git => 'https://github.com/tworingsoft/Pippin.git', :tag => "#{s.name}-#{s.version}" }
  s.platform     = :ios, '9.0'
  s.swift_version = '4.2'
  
  s.default_subspecs = 'PinpointKit', 'COSTouchVisualizer', 'XCGLogger', 'SwiftMessages', 'DebugController', 'JGProgressHUD'

  s.subspec 'PinpointKit' do |ss|
    ss.source_files = 'Sources/PippinAdapters/PinpointKit/**/*.{h,m,swift}'
    ss.dependency 'PinpointKit', '~> 1'
    ss.dependency 'Pippin'
  end
  s.subspec 'COSTouchVisualizer' do |ss|
    ss.source_files = 'Sources/PippinAdapters/COSTouchVisualizer/**/*.{h,m,swift}'
    ss.dependency 'COSTouchVisualizer', '~> 1'
    ss.dependency 'Pippin'
  end
  s.subspec 'XCGLogger' do |ss|
    ss.source_files = 'Sources/PippinAdapters/XCGLogger/**/*.{h,m,swift}'
    ss.dependency 'XCGLogger', '~> 6'
    ss.dependency 'Pippin'
  end
  s.subspec 'SwiftMessages' do |ss|
    ss.source_files = 'Sources/PippinAdapters/SwiftMessages/**/*.{h,m,swift}'
    ss.dependency 'SwiftMessages', '~> 4'
    ss.dependency 'Pippin'
  end
  s.subspec 'DebugController' do |ss|
    ss.source_files = 'Sources/PippinAdapters/DebugController/**/*.{h,m,swift}'
    ss.dependency 'Pippin'
  end
  s.subspec 'JGProgressHUD' do |ss|
    ss.source_files = 'Sources/PippinAdapters/JGProgressHUD/**/*.{h,m,swift}'
    ss.dependency 'Pippin'
    ss.dependency 'JGProgressHUD'
  end
end
