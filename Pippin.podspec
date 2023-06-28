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

  s.ios.deployment_target = '15.6'
  s.osx.deployment_target = '12.4'

  s.swift_version = '5.8'

  s.ios.dependency 'PippinAdapters'
  s.ios.dependency 'PippinCore'
  s.dependency 'PippinLibrary'

  s.module_name = 'PippinUmbrella'
end
