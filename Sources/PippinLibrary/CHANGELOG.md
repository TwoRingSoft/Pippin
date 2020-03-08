# Changelog

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [2.0.0] 2020-03-08

Support for Dark Mode.

### Changed

- Deprecate `BlurViewController(viewController:blurStyle:)` in favor of new `BlurViewController(blurredViewController:material:vibrancy:)`.
- Updated bundle identifier for `PippinLibrary.framework`.
- Bumped podspec's `deployment_target` to iOS 12.0 to workaround a CocoaPods bug: https://github.com/CocoaPods/CocoaPods/issues/7111#issuecomment-589048018.

### Added

- Use Dark Mode compatible fill in `TextFieldTableViewCell`'s `UITextField`.
- Dark Mode support in `InfoViewController`.
- New `String(asRDNSWithSubpaths:)` that doesn't try to grab the main bundle ID, so it can be used from other places.

### Fixed

- Layout issues in `TextFieldTableViewCell` and `DismissableModalViewController`.
- Typo in `BundleKey` raw value that resulted in failing to extract bundle IDs from Info.plist files.

## [1.1.0] 2019-12-03

### Added

- Objc-compatible version of `UIView.roundCorners(radius:borderWidth:borderColor:)`, prefixed with `objc_`.

## [1.0.1] 2019-11-26

### Fixed

- Remove workaround to set `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES` to `YES` in podspec in attempt to work around a runpath bug in Xcode tooling, as this causes a failure during upload to App Store Connect. Will deploy to CocoaPods using `pod trunk push --skip-tests` until [the related issue](https://github.com/CocoaPods/CocoaPods/issues/9165) can be fixed or a valid workaround provided.

## [1.0.0] 2019-09-22

### Added

- Extracted sources from old `Pippin/Extensions` subspec.
