use_frameworks!
install! 'cocoapods', :share_schemes_for_development_pods => true
platform :ios, '11.0'
project 'Pippin.xcodeproj'
workspace 'Pippin.xcworkspace'

abstract_target 'PippinPods' do
  pod 'Pippin', path: '.', :testspecs => ['Tests']
  pod 'PippinTesting', path: '.', :testspecs => ['Tests']
  target 'PippinTestHarness' do
    pod 'Crashlytics', '~> 3'
  end
  target 'PippinUnitTests'
end
