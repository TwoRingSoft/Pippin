Pod::Spec.new do |s|
  s.name         = 'PippinCore'
  s.version      = '1.0.0'
  s.summary      = "A Swift framework to scaffold and abstract the common major parts of an app, to make development faster and maintenance easier."
  s.description  = <<-DESC
    A collection of Swift and Objective-C utilities delivering reusable components of iOS applications and utilities to work with Apple and third-party frameworks.
  DESC
  s.homepage     = 'https://github.com/tworingsoft/Pippin'
  s.license      = 'MIT'
  s.author       = { 'Andrew McKnight' => 'andrew@tworingsoft.com' }
  s.source       = { :git => 'https://github.com/tworingsoft/Pippin.git', :tag => "#{s.name}-#{s.version}" }

  s.ios.deployment_target = '9.0'
  
  s.swift_version = '5.1'
  
  s.default_subspecs = ['Components', 'Environment', 'Peripherals']

  s.subspec 'Components' do |ss|
    ss.source_files = ['Sources/PippinCore/Components/**/*.{h,m,swift}']
  end

  s.subspec 'Environment' do |ss|
    ss.source_files = ['Sources/PippinCore/Environment/**/*.{h,m,swift}']
  end

  s.subspec 'Peripherals' do |ss|
    ss.source_files = ['Sources/PippinCore/Peripherals/**/*.{h,m,swift}']
    ss.dependency 'Result'
  end

  s.dependency 'PippinLibrary'

  s.module_name = 'Pippin'
end
