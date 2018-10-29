use_frameworks!
install! 'cocoapods', :share_schemes_for_development_pods => true
platform :ios, '11.0'
project 'Pippin.xcodeproj'
workspace 'Pippin.xcworkspace'

abstract_target 'PippinPods' do
  pod 'PinpointKit', path: '../../../automated-forks/PinpointKit'
  pod 'Pippin', path: '.', :testspecs => ['Tests']
  pod 'PippinAdapters', path: '.'
  
  target 'PippinTestHarness' do
    pod 'Crashlytics', '~> 3'
  end
end

abstract_target 'PippinTestPods' do
  pod 'PippinTesting', path: '.', :testspecs => ['Tests']
  pod 'Pippin/Extensions', path: '.'
  
  target 'PippinUITests'
  target 'PippinUnitTests'
end
