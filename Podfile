use_frameworks!
install! 'cocoapods', :share_schemes_for_development_pods => true
project 'Pippin.xcodeproj'
workspace 'Pippin.xcworkspace'

abstract_target 'PippinPods-iOS' do
    pod 'Pippin', :path => '.', :testspecs => ['Extensions/Tests']
    pod 'PippinAdapters', :path => '.'
    pod 'PippinDebugging', :path => '.', :configurations => ['Debug']
    
    target 'PippinTestHarness' do
        platform :ios, '9.0'
        pod 'Crashlytics', '~> 3'
    end
end

abstract_target 'PippinPods-macOS' do
    pod 'Pippin/Extensions', path: '.'
    
    target 'PippinTestHarness-macOS' do
        platform :osx, '10.14'
    end
end

abstract_target 'PippinTestPods' do
  platform :ios, '11.0'
  pod 'PippinTesting', path: '.', :testspecs => ['Tests']
  pod 'Pippin/Extensions', path: '.', :testspecs => ['Tests']

  target 'PippinUITests'
  target 'PippinUnitTests'
end
