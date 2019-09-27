# Changelog

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

---

# [Unreleased]

---

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