# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

## [3.0.0] 2022-04-27

### Breaking

- Moved `Array.PowerSet` to FastMath.

### Added

- Different ways to count things in Collections: `count(where:)` and `counts`.
- Ability to print a 2D collection with `gridDescription`.
- Extract typed values from strings like `lines`, `ints`, `stringsAndInts`, `intGrid` and `characterGrid`.
- Provide sliding window views of collections (`windows(ofSize:)`) and strings (`substrings(ofLength:)`).
- Flattening collections of collections.

### Fixed

- An incorrect calculation previously returned the wrong result from `CGRect(centeredAround:with:)`.

## [2.6.0] 2020-10-24

### Added

- Exposed `UIDevice.isPhone` to the Objective C runtime.

## [2.5.0] 2020-08-08

### Added

- Convenience constructor for the nil UUID 00000000-0000-0000-0000-000000000000.
- Enum describing HTTP request Content-Type values.

## [2.4.0] 2020-06-29

### Added

- More HTML enclosures for H1, H2 and H3 headers.

## [2.3.1] 2020-06-28

### Fixed

- Correctly decide when a compound operation is finished according to the number of completed suboperations.
- Add missing tests for `AsyncOperation`s.

## [2.3.0] 2020-05-21

### Added

- Add `enum` describing HTTP response codes.
- Add closure `typealias`es for blocks with `Result` parameters, and `throws` variants of a few closure types.

## [2.2.0] 2020-04-20

### Added

- [`Closures`](https://github.com/vhesener/Closures) and [`Then`](https://github.com/devxoul/Then) library vending.
- `conversationalList` on `Array` and `Set` to create lists of the style `1, 2 and 3`.
- Power set computation from contents of an `Array` (in both tail-recursive and regular recursive variants), found at https://gist.github.com/JadenGeller/6174b3461a34465791c5#file-powerset_map-swift and modified.
- `NSErrorConvertible` now brings conformance to `Swift.Error` and a default implemntation of `var nsError: NSError`.

### Fixed

- Make everything in `TextAndAccessoryCell` an `accessibilityElement`.

## [2.1.1] 2020-04-16

### Fixed

- Use correct bundle ID in `AsyncOperation` and `CompoundOperation`.

## [2.1.0] 2020-03-15

## Added

- A shorthand `UIEdgeInsets` constructor: `all(_ value: Int)`: `let insets = .all(25)`.

## Fixed

- Always toggle `isUserInteractionEnabled` in `TransparentModalPresentingViewController`.
- Fix header layout ambiguity in `DismissableModalViewController` and rewrite remaining manual constraints with a `UIStackView`.

## [2.0.1] 2020-03-15

### Fixed

- Made `TransparentModalPresentingViewController` behave well whether being shown/dismissed in landscape or portrait mode.

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
