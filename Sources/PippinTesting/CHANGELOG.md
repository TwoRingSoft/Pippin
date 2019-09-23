# Changelog

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

---

# [Unreleased]

---

## [2.0.1] 2019-09-18

### Fixed

- Swift 5.1 support.

## [2.0.0] 2018-10-30

### Changed

- Removed function `popNavStackTop` that had no implementation.
- Renamed `enterNumericValue(value:)` to `enterWithOnscreenKeyboard(value:)` for better semantics, as it can handle any keyboard type, not just number pads.
