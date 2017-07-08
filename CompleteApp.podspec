#
#  Be sure to run `pod spec lint CompleteApp.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "CompleteApp"
  s.version      = "1.0.0"
  s.summary      = "A collection of classes and utilities to rapidly create iOS applications."

  s.description  = <<-DESC
                   Two Ring's CompleteApp iOS app SDK delivers reusable UI components, factories, utilities and tools to help speed up the development of apps.
                   DESC

  s.homepage     = "https://github.com/tworingsoft/shared-utils"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Andrew McKnight" => "andrew@tworingsoft.com" }
  s.source       = { :git => "https://github.com/tworingsoft/shared-utils", :tag => "#{s.version}" }

  s.source_files  = "Sources/**/*"

  s.preserve_paths = "Scripts"

  s.dependency "Anchorage"
  s.dependency "Crashlytics"
  s.dependency "PinpointKit"
  s.dependency "XCGLogger"

end
