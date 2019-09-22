Pod::Spec.new do |s|
  s.name         = 'PippinDebugging'
  s.version      = '1.0.0'
  s.summary      = "A Swift framework providing tools for in-app debugging."
  s.description  = <<-DESC
  A collection of Swift and Objective-C utilities delivering UI and low-level utilities to debug an app while it's running.
                   DESC
  s.homepage     = 'https://github.com/tworingsoft/Pippin'
  s.license      = 'MIT'
  s.author       = { 'Andrew McKnight' => 'andrew@tworingsoft.com' }
  s.source       = { :git => 'https://github.com/tworingsoft/Pippin.git', :tag => "#{s.name}-#{s.version}" }
  s.platform     = :ios, '9.0'
  s.swift_version = '5.1'

  s.source_files = 'Sources/PippinDebugging/**/*.{h,m,swift}'
  
  s.dependency 'FLEX', '~> 2'
  s.dependency 'Pippin'
end