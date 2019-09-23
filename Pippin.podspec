Pod::Spec.new do |s|
  s.name         = 'Pippin'
  s.version      = '16.0.0'
  s.summary      = "A Swift framework to scaffold an app and make development and maintenance easier."
  s.description  = <<-DESC
    An umbrella framework to easily add all the common components of the Pippin ecosystem: core, adapters, library and testing. Debugging is not automatically included; as you should only add that as a dependency specifically set to your non-production build configurations. 
  DESC
  s.homepage     = 'https://github.com/tworingsoft/Pippin'
  s.license      = 'MIT'
  s.author       = { 'Andrew McKnight' => 'andrew@tworingsoft.com' }
  s.source       = { :git => 'https://github.com/tworingsoft/Pippin.git', :tag => "#{s.name}-#{s.version}" }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.12'
  
  s.swift_version = '5.1'

  s.dependency 'PippinAdapters'
  s.dependency 'PippinCore'
  s.dependency 'PippinLibrary'
  s.dependency 'PippinTesting'

  s.module_name = 'PippinUmbrella'
end
