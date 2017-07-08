Pod::Spec.new do |s|
  s.name = "CompleteApp"
  s.version = "1.0.0"
  s.summary = "A collection of classes and utilities to rapidly create iOS applications."
  s.description = <<-DESC
    Two Ring's CompleteApp iOS app SDK delivers reusable UI components, factories, utilities and tools to help speed up the development of apps.
  DESC
  s.homepage = "https://github.com/tworingsoft/shared-utils"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Andrew McKnight" => "andrew@tworingsoft.com" }
  s.platform = :ios, '9.0'
  s.source = { :git => "https://github.com/tworingsoft/shared-utils", :tag => "#{s.version}" }
  s.source_files  = "Sources/**/*.{h,m,swift}"
  s.preserve_paths = "Scripts"
  s.dependency "Anchorage"
  s.dependency "PinpointKit"
  s.dependency "XCGLogger"
end
