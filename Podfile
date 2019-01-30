use_frameworks!
install! 'cocoapods', :share_schemes_for_development_pods => true
project 'Pippin.xcodeproj'
workspace 'Pippin.xcworkspace'

abstract_target 'PippinPods-iOS' do
    pod 'Pippin', path: '.', :testspecs => ['Tests']
    pod 'PippinAdapters', path: '.'
    
    target 'PippinTestHarness' do
        platform :ios, '9.0'
        pod 'Crashlytics', '~> 3'
    end
end

abstract_target 'PippinPods-macOS' do
    pod 'Pippin', path: '.', :testspecs => ['Tests']
    
    target 'PippinTestHarness-macOS' do
        platform :osx, '10.14'
    end
end

abstract_target 'PippinTestPods' do
  platform :ios, '11.0'
  pod 'PippinTesting', path: '.', :testspecs => ['Tests']
  pod 'Pippin/Extensions', path: '.'
  
  target 'PippinUITests'
  target 'PippinUnitTests'
end

post_install do |installer|
   # set SWIFT_VERSION for pods that don't declare it in their podspec
   installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
         if target.name == 'PinpointKit' or target.name == 'Anchorage' then
            config.build_settings['SWIFT_VERSION'] = '4.2'
         end
      end
   end
end
