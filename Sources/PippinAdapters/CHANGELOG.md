# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Changed

- Removed Crashlytics in favor of KSCrash.
- Bump SwiftMessages dependency to 9.

## [7.0.0] 2022-04-25

### Changed

- Remove `CoreLocation` and `AVCaptureDevice` adapters from the default subspecs list so they don't cause build rejections from AppStoreConnect due to missing infoplist purpose strings even if the app doesn't use them.

### Added

- Added an adapter for KSCrash as an alternative for Crashlytics.

## [6.0.0] 2020-10-26

### Changed

- Obsoleted `CrudViewControllerUITableViewDelegate.crudViewController(crudViewController:otherEditActionsFor:)` and introduced `CrudViewControllerUITableViewDelegate.crudViewController(crudViewController:otherSwipeActionsFor:)` to provide the equivalent functionality with the new iOS function, as `UITableViewRowAction` was deprecated in iOS 12.

## [5.2.1] 2020-08-08

### Fixed

- Retain cycles in `CrudViewController`.

## [5.2.0] 2020-06-09

### Added

- Allow multiple selections in `CrudViewController`.

## [5.1.0] 2020-05-28

### Added

- Exposed the `managedObjectModel` that `CoreDataController` uses.

## [5.0.7] 2020-04-20

### Fixed

- Accessibility on `CrudViewController` add item cells that works in UI tests.

## [5.0.6] 2020-04-18

### Fixed

- Removed a duplicate insertion check in `CrudViewController` that prevented added entities from displaying in table views. This was likely added to prevent the crashes introduced by the retain cycles that have been fixed.
- Set `accessibilityLabel` on `CrudViewController`'s add item cell.

## [5.0.5] 2020-04-18

### Fixed

- Retain cycle in `NSNotificationCenter` observation block in `CrudViewController`.

## [5.0.4] 2020-04-15

### Fixed

- Retain cycles by making delegate properties on `CrudViewController` `weak`.

## [5.0.3] 2020-03-15

### Fixed

- Blur behind `Acknowledgements` displayed from `InfoViewController`.

## [5.0.2] 2020-03-14

### Fixed

- Layout issue with acknowledgements modal in `InfoViewController` after autorotating between landscape and portrait modes.

## [5.0.1] 2020-03-08

### Fixed

- Handle `nil` returned `AVCaptureDevice` in the already-authorized codepath.
- Make all subspecs default to avoid CocoaPods creating multiple framework targets that both have a `PRODUCT_NAME` and `MODULE_NAME` of `PippinAdapters` resulting in a build error of "multiple commands produce...".

## [5.0.0] 2020-03-08

### Changed

- Updated bundle identifier for `PippinAdapters.framework`.
- Bumped podspec's `deployment_target` to iOS 12.0 to workaround a CocoaPods bug: https://github.com/CocoaPods/CocoaPods/issues/7111#issuecomment-589048018.

### Added

- Support for Dark Mode in `CrashlyticsAdapter: Debuggable` and `InfoViewController`.

### Fixed

- Layout issues in `InfoViewController` with multiple modal presentations.

## [4.0.0] 2019-09-21

### Changed

- Split out debug subspec into its own podspec, `PippinDebugging`.

### Added

- Convenience function to set up a default `Environment` instance using the `PippinAdapters` default subspecs.
- Added `InfoViewController`, `CRUDViewController` and `FormController` from `PippinCore` spec.

## [3.1.0] 2019-09-18

### Added

- Implement `Debuggable` conformance to `PinpointKitAdapter`, `XCGLoggerAdapter` and `COSTouchVisualizerAdapter`, to add them to the debug console.

### Fixed

- Swift 5.1 support.

## [3.0.0] 2019-09-11

### Changed

- Moved `FLEX` dependency out of `DebugController` subspec to a separate, new subspec named `DebugTools`. This way it is not included in every debug build, but can be if desired, even on a per-configuration basis if setting up a config just for `FLEX` and other debug frameworks.

## [2.1.1] 2019-04-03

### Fixed

- Fixed a podspec issue that caused an error resolving dependency on Pippin.

## [2.1.0] 2019-03-20

### Added

- Debug `Alerter` function to show an alert for an unimplemented feature.

### Fixed

- Usages of Pippin's `Environment` with removed IUOs.

## [2.0.0] 2019-01-29

### Changed

- Pinned `DebugController` and `PinpointKitAdapter` dependencies on `Pippin` to `~> 13`, to ensure the correct version is pulled in for the `FileManager+URLs` changes.

### Fixed

- Updated `DebugController` and `PinpointKitAdapter` for `FileManager+URLs` API change.

## [1.0.0] 2018-10-25

### Added

- Sources moved from the `Adapters` subspec in `Pippin`.
