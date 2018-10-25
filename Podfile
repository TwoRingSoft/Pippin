use_frameworks!
install! 'cocoapods', :share_schemes_for_development_pods => true
platform :ios, '11.0'
project 'Pippin.xcodeproj'
workspace 'Pippin.xcworkspace'

abstract_target 'PippinPods' do
  pod 'Pippin', path: '.', :testspecs => ['Tests']
  
  target 'PippinTestHarness' do
    pod 'Crashlytics', '~> 3'
  end
  
  abstract_target 'PippinTestPods' do
      pod 'PippinTesting', path: '.', :testspecs => ['Tests']
      
      target 'PippinUITests'
      target 'PippinUnitTests'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    next unless
    target.build_configurations.each do |config|
      if target.name == 'PinpointKit' or target.name == 'Anchorage' then
        config.build_settings['SWIFT_VERSION'] = '4.2'
      elsif target.name == 'SwiftMessages' then
        config.build_settings['SWIFT_VERSION'] = '4'
      end
    end
  end
end
