# Changelog

## [Unreleased]

### Added

- Sentry adapter for CrashReporter and BugReporter protocols with user feedback form.
- OSLog adapter for Logger protocol using `os.Logger` and `OSLogStore`.
- `CrashReporter` protocol: `supportsLogs` and `supportsBreadcrumbs` capability flags.
- `CrashReporter` protocol: `recordBreadcrumb(message:category:level:)` for contextual breadcrumb trail.
- OSLog adapter forwards logs to crash reporter preferring structured logs over breadcrumbs.
- Sentry adapter attaches app logs to user feedback submissions.

### Fixed

- InfoViewController: fixed rendering corruption when company link has no image (nil image created zero-size `NSTextAttachment`).

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
