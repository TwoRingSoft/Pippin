# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

## [2.1.1] 2019-10-24

### Fixed

- Remove workaround to set `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES` to `YES` in podspec in attempt to work around a runpath bug in Xcode tooling.

## [2.1.0] 2019-10-14

### Added

- Added protocol `Robot` to describe a type that drives a UI test, to encourage usage of the robot testing pattern.

## [2.0.1] 2019-09-18

### Fixed

- Swift 5.1 support.

## [2.0.0] 2018-10-30

### Changed

- Removed function `popNavStackTop` that had no implementation.
- Renamed `enterNumericValue(value:)` to `enterWithOnscreenKeyboard(value:)` for better semantics, as it can handle any keyboard type, not just number pads.
