# Changelog

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added

- `CompoundOperation` and test/demo code ported from [FABOperation](https://github.com/google-fabric/faboperation).
- JSON extensions for `Dictionary`, `String` and `Data`.
- Reusable `ColorGradientLayer` and `ColorSliderCell` subclasses of `CALayer` and `UITableViewCell`, respectively.

---

## [PippinTesting 2.0.0] 2018-10-30

### Changed

- Removed function `popNavStackTop` that had no implementation.
- Renamed `enterNumericValue(value:)` to `enterWithOnscreenKeyboard(value:)` for better semantics, as it can handle any keyboard type, not just number pads.

## [Pippin 12.0.1] 2018-10-29

### Fixed

- Remove all pod dependencies (so, just Anchorage) from `Pippin/Extensions` subspec.
- Rename Core subdirectory to Seeds, to disambiguate between the Core subspec and the subdirectory containing the Core protocols and data structures.

## [PippinAdapters 1.0.0] 2018-10-25

### Added

- Sources moved from the `Adapters` subspec in `Pippin`.

## [Pippin 12.0.0] 2018-10-25

### Changed

- Adapters to Pippin protocols now live in the separate `PippinAdapters.podspec`.

## [Pippin 11.0.0] 2018-09-23

### Changed

- Make `Defaults` `EnvironmentallyConscious`.
- Functions on `ActivityIndicator` to show and hide UI now have completion block parameters.
- In `Environment.logLevel`, always return `LogLevel.verbose` when running UI tests.

### Added

- Extension on `UserDefaults` to set and a key/value pair and immediately synchronize the backing store.
- Parameter to specify a title font on `UIButton` factory function, and use it in `InfoViewController` for the app detail stack buttons.
- `TouchVisualization` protocol and `COSTouchVisualizer` adapter.
- Parameterize `DismissableModalViewController`'s insets instead of hardcoding it to inset by 30 from the top to avoid a status bar, something not all apps may want to do.
- Extension on `UIView` to round corners and style borders.
- Keep a reference to the `Bundle` containing any shared assets catalog, which defaults to the main bundle if one isn't specified in `Environment`'s init.
- A `LaunchArgument` to wipe any stored user defaults the app uses at launch. 
- A static extension function on `ProcessInfo` to test if any launch argument was provided during app launch, to help test app-specific launch arguments.

### Fixed

- Fixed layout issues in `DismissableModalViewController` when there is no title to display or in less than full-screen layouts.
- `Date+TimeElapsed` now returns sub-minute scale results as a string describing seconds elapsed.
- `InfoViewController` now shows in-app acknowledgements using a styled `NSAttributedString`.

## [Pippin 10.0.0] 2018-09-05

### Changed

- Rewrite `NSDate+Components` and `NSDate+TimeSince` in Swift and rename to `Date+Components` and `Date+ElapsedTime`, respectively.

#### Locator

- Make `Locator`s conform to `Debuggable`, and provide debugging controls for `CoreLocationSimulator`.
- Instead of setting a property on `CoreLocationSimulation` with the location data, pass in the raw string from e.g. the environment variable value and parse it internally.
- Add new `LocationError` enum and change `Locator`'s callback to pass this type. Currently just wraps `NSError`s reported by `CoreLocation`.

#### Debugging

- `DebugFlowController` now delegates model deletion back to the consumer app, instead of directly deleting the sqlite database files. Prevents a forced restart of the app to reconstruct the database.
- `DatabaseFixsturePickerViewController` now requires a parameter of type `Environment` instead of `CoreDataController`, which it can get from the environment parameter, as well as logging/alerting/etc.
- 

#### Model

- Always require a `NSManagedObjectContext` for fetching, instead of falling back to acquiring a new vended context. Helps with context confinement of model entity instances.
- Instead of requiring an instantiated `NSManagedObjectModel` in init, just get the bundle identifer of the bundle that contains it, and use the model name it already has to construct the instance internally.

#### CrudViewController

- No longer sets the Add Item cell's accessibility label to the reuse identifier of the cell. Now just lets the accessibility subsystem automatically infer it.
- Remove `reloadTableView()` as it is already used in `reloadData()`.

### Added

- Add case to `LaunchArgument` to delete all core data models on launch.
- Add asynchronous `Operation` subclass, `AsyncOperation`.
- Add function on `CoreDataController` to directly vend a context, instead of through a closure parameter via `perform(with:)`.
- Added property on `Environment` to hold reference to a `Locator?`.

### Fixed

- Hide debugging menu button when the menu is visible.
- Prevent double insertions of the same row in `CrudViewController`, due to multiple callbacks from the `NSFetchedResultsController` (in testing, also observed multiple `Notification`s sent for the same insertion).

## [Pippin 9.0.3] 2018-08-24

### Fixed

- Improved keyboard avoidance in `FormController` when used in conjunction with a `UIScrollView`.
- Fixed issues in `AuthorizedCLLocationManager` and `CoreLocationAdapter` that prevented themt from calling back to consumers.

## [Pippin 9.0.2] 2018-08-24

### Changed

- Renamed a parameter in a `UIEdgeInset+Factory.swift` init to remove ambiguity with its stock `init(top:right:bottom:left)`

## [Pippin 9.0.1] 2018-08-23

### Fixed

- Prepopulated app name and version into subject and body of feedback emails sent from InfoViewController. Also dismiss the mail view, where it previously hung on the screen.

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
