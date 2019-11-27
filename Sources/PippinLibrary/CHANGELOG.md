# Changelog

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

---

# [Unreleased]

---

## [1.0.1] 2019-11-26

### Fixed

- Remove workaround to set `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES` to `YES` in podspec in attempt to work around a runpath bug in Xcode tooling, as this causes a failure during upload to App Store Connect. Will deploy to CocoaPods using `pod trunk push --skip-tests` until [the related issue](https://github.com/CocoaPods/CocoaPods/issues/9165) can be fixed or a valid workaround provided.

## [1.0.0] 2019-09-22

### Added

- Extracted sources from old `Pippin/Extensions` subspec.
