use_frameworks!
install! 'cocoapods', :share_schemes_for_development_pods => true
platform :ios, '10.0'

target 'PippinTestHarness' do
  pod 'Pippin', path: '.', :testspecs => ['Tests']
  pod 'Crashlytics', '~> 3'
end
