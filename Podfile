use_frameworks!
install! 'cocoapods', :share_schemes_for_development_pods => true
project 'Pippin.xcodeproj'
workspace 'Pippin.xcworkspace'
platform :ios, '11.0'

abstract_target 'PippinPods' do
  pod 'Pippin', path: '.', :testspecs => ['Tests']
  pod 'PippinAdapters', path: '.'

  target 'PippinTestHarness' do
    pod 'Crashlytics', '~> 3'
  end
end

abstract_target 'PippinTestPods' do
  platform :ios, '11.0'
  pod 'PippinTesting', path: '.', :testspecs => ['Tests']
  pod 'Pippin/Extensions', path: '.'

  target 'PippinUITests'
  target 'PippinUnitTests'
end
