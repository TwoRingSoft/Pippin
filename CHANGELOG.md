# Changelog

## [Unreleased]

### Changed

- Renamed the `CrashReporter` protocol to `AppMonitor`, `Environment.crashReporter`
  to `Environment.appMonitor`, and
  `CloudKitCoreDataController.reportiCloudUserToCrashReporter()` to
  `reportiCloudUserToAppMonitor()`. The old names remain as deprecated aliases.
- **Breaking:** `CloudKitCoreDataController.cloudKitContainer` is now
  `CKContainer?`, and `nil` for an in-memory store, which no longer creates a
  `CKContainer` at all. Creating one needs the iCloud entitlement, so an unsigned
  build (UI tests run in CI) crashed at launch even with `inMemory: true`.
  `reportiCloudUserToAppMonitor()` does nothing for an in-memory store.
  Callers unwrap the container, for example to show a share sheet only when
  there is one.
- Bump the `swift-armcknight` submodule to its split release: it now vends a
  platform-neutral `SwiftArmcknightCore` product (builds on Linux) alongside the
  Apple-only `SwiftArmcknight`, which re-exports Core. No Pippin API change.
- The GitHub release is now published by CI on a tag push, via the reusable
  `github-release` workflow in `armcknight/workflows`, instead of by
  `prepare-release --github-release` on whichever workstation ran `make deploy`.
  That local step is how 13.0.1 became a tag with no release at all.
- `make help` lists every target, and the existing targets carry descriptions.

## [13.0.1] 2026-05-02

Notes written after the fact: this version was tagged in May 2026 but its
release was never published, and its changelog section was left empty. Both are
reconstructed here from the single commit it contains (`afe777b`).

### Changed

- `Acknowledgements`: the disclaimer is now the first section of the rendered
  acknowledgements text rather than the last.

### Added

- `Acknowledgements`: debug logging through the whole acknowledgements plist
  path — the URL it loads, the bytes read, the `PreferenceSpecifiers` count, each
  entry skipped for a missing `Title`, `FooterText` or `License`, the parsed
  total, and the two cases that silently produced nothing before (no plist URL
  supplied, and a plist without the expected structure).

## [13.0.0] 2026-05-02

### Added

- `ChangelogParser` for parsing Keep a Changelog format markdown and filtering entries between versions.
- `ChangelogParser.entriesSince(build:upTo:from:)` — filter changelog entries by build number range, extracted from `+N` semver metadata in entry version strings; handles RC-to-RC upgrades where the marketing version doesn't change.
- `Environment.lastLaunchedVersion` exposed publicly for version upgrade detection.
- `Environment.currentBuild` — the current app build number read from `CFBundleVersion` at launch.
- `Environment.lastLaunchedBuild` — the build number of the previous run, persisted in `UserDefaults`; used by `ChangelogPresenter` for What's New detection.

### Changed

- `AppAcknowledgements`: replaced `customAcknowledgements: String?` with `specialThanks: String?` and `disclaimer: String?`, each rendered as its own labelled section.

### Fixed

- `ChangelogPresenter.whatsNewEntries()` now compares build numbers (`currentBuild` vs `lastLaunchedBuild`) instead of marketing version strings; RC builds with different build numbers correctly trigger the What's New display even when the marketing version hasn't changed.
- `WhatsNewView`: fixed macOS build error — replaced unavailable `ToolbarItem(placement: .topBarTrailing)` with `.automatic` and guarded `.navigationBarTitleDisplayMode` behind `#if !os(macOS)`.
- Sentry adapter for CrashReporter and BugReporter protocols with user feedback form.
- OSLog adapter for Logger protocol using `os.Logger` and `OSLogStore`.
- `CrashReporter` protocol: `supportsLogs` and `supportsBreadcrumbs` capability flags.
- `CrashReporter` protocol: `recordBreadcrumb(message:category:level:)` for contextual breadcrumb trail.
- OSLog adapter forwards logs to crash reporter preferring structured logs over breadcrumbs.
- Sentry adapter attaches app logs to user feedback submissions.
- Split PippinAdapters into individual SPM library targets for selective linking (e.g. `PippinAdapters-Sentry`, `PippinAdapters-OSLog`).
- A launch argument to help signal forcing dark mode.

### Removed

- Removed `DefaultEnvironment.swift` convenience initializer (referenced adapters across multiple targets).

### Fixed

- InfoViewController: fixed rendering corruption when company link has no image (nil image created zero-size `NSTextAttachment`).
- LaunchArguments that resolved to different string values due to bundle names when linked statically.

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
