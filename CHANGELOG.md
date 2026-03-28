# Changelog

## [Unreleased]

## [12.0.0]

### Breaking Changes

- Migrated from CocoaPods to Swift Package Manager
- Replaced PippinLibrary dependency with swift-armcknight (SwiftArmcknight + SwiftArmcknightUIKit)
- All UIKit-dependent code gated behind `#if canImport(UIKit)` for cross-platform compilation
- Protocols (`CrashReporter`, `Logger`, `Model`, `Locator`) conditionally inherit `Debuggable` only on iOS
- `Environment` properties (`alerter`, `activityIndicator`, `bugReporter`, `fonts`, `colors`, `debugging`, `touchVisualizer`) only available on iOS
- iOS-only dependencies (FLEX, JGProgressHUD, SwiftMessages) are platform-conditional

### Removed

- Removed adapters from build: COSTouchVisualizer, PinpointKit, KSCrash (API incompatible with 2.x)
- Removed podspecs
