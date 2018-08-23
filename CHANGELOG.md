# Changelog

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [Pippin 9.0.0] 2018-08-23

### Changed

- `InfoViewController` is constructed differently, with changes to how acknowledgements are passed in.

### Added

- Automatically add buttons for bug reporting, acknowledgements, contact, and in app purchases in `InfoViewController`.
- `Debuggable` protocol specifying that conformers will return a `UIView` containing controls a tester may use to exercise the component. Add implementations for `SwiftMessagesAdapter` (`Alerter`), `JGProgressHUDAdapter` (`ActivityIndicator`), `CrashlyticsAdapter` (`CrashReporter`) and `CoreDataController`.
- Parameter on `Environment` for a `Fonts` conforming object, and a default `Fonts` implementation, `DefaultFonts`, provided as the default value if one is not provided. This helped to remove the fonts parameter from `InfoViewController`, and is used in several other places that already benefited from `EnvironmentallyConscious` conformance.

### Fixed

- Thread child view controller `title` value through `BlurViewController`. Helps when embedding a vc into `BlurViewController` and then in a `DismissableModalViewController`, which displays a `UILabel` with the child vc's `title`.
- Fixed `hitTest` override in `DebugWindow` that caused touches on anything other than `UIButton`s in the `DebugViewController`.

## [Pippin 8.0.0]

## [2.0.0] 2017-12-31

### Changed
- Update String rDNS constructors
- Require iOS 11
- Reorganize debugging sources under Core
- Remove default log level function

### Added
- Add Core protocols:
- Alerter + SwiftMessagesAdapter
- InAppPurchaseVendor
- Fonts
- Environment struct
- LaunchArgument/EnvironmentVariable enums
- Allow passing custom managed object model to CoreDataController
- FormController now manages UITextViews
- Theming/customizing CrudViewController:
- Custom cells
- Empty state
- Look/feel

### Fixed
- Fix warnings:
  - deprecated usage of `characters` property of a Swift string to determine its length
  - unreachable code around fatal error
- Improvements:
  - FlowController
  - Debugging

## [1.0.0] 2017-11-29

- The official version 1 release!
