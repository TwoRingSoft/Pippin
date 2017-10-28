use_frameworks!
install! 'cocoapods', :share_schemes_for_development_pods => true
platform :ios, '10.0'

abstract_target 'Testing' do

  pod 'Pippin', path: '.'
  pod 'Crashlytics', '~> 3'

  target 'PippinTestHarness'
  target 'PippinTests'
  
end
