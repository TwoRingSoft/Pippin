target 'shared-utilsTests-harness-ios' do
  use_frameworks!
  
  target 'shared-utilsTests' do

      pod 'Anchorage'
      pod 'Crashlytics'
      pod 'XCGLogger'
  
  end

end

# xcode 9 beta era workaround, waiting for some dependencies to publish in swift 4
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
        end
    end
end
