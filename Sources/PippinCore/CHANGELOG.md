# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

## [2.2.0] 2022-04-27

### Added

- A secondary foreground color in `Colors` (and a default value in `DefaultColors`).

## [2.1.0] 2020-08-08

### Added

- Ability to pass a custom view for app-specific debug views when installing Pippin debugging views for the menu.

## [2.0.2] 2020-04-15

### Fixed

- Use correct bundle ID in `DefaultDefaults`, `LogLevel`, `LaunchArgument` and `EnvironmentVariable` descriptions, as well as errors and internal components.

## [2.0.1] 2020-04-05

### Fixed

- Set the `Environment` reference for `Defaults` in `connectEnvironment()`.

## [2.0.0] 2020-03-08

### Changed

- Added a parameter to `AppInfoPresenter.init` to specify the logical (not direct container) parent `UIViewController`, if any, to corrently stack modally presented view controllers. For example, if an `InfoViewController` is modally presented, and it modally presents another `UIViewController`, then treat the new modal's parent as the original `InfoViewController`'s parent. This helps with layouts that use margins, so the Nth modal doesn't get shifted down by N x margin.
- Updated bundle identifier for `Pippin.framework`.
- Bumped podspec's `deployment_target` to iOS 12.0 to workaround a CocoaPods bug: https://github.com/CocoaPods/CocoaPods/issues/7111#issuecomment-589048018.

### Fix

- rDNS raw values for `LaunchArgument` members to use `Pippin.framework`'s bundle ID instead of the app, to help avoid potential collisions.

### Added

- `Colors` protocol and `DefaultColors` struct to help with Dark Mode (or more generally, configurable color systems).

## [16.0.0] 2019-09-21

### Changed

- Guard usage of debug APIs within `#if DEBUG` conditional compilation directives.
- `AuthorizedCLLocationManager` now returns a token to retain while prompting user for permission instead of the old singleton pattern.
- Moved `InfoViewController`, `CRUDViewController` and `FormController` to `PippinAdapters` spec.

### Added

- Function on `LaunchArgument` to query whether a calling case was supplied in a launch.
- `AuthorizedCLLocationManager` now returns a token to retain while prompting user for permission instead of the old singleton pattern.

### Fixed

- Improved `AuthorizedCLLocationManager` handling of possible authorization states at the time it is used to request authorization from the user.

## [15.0.0] 2019-09-18

### Changed

- Removed iOS 11 minimum requirement for `DebugController`.
- `XCGLoggerAdapter.init` is now optional, as it will return `nil` if called with the new `XCGLogger.LogLevel` cases `notice`, `emergency` and `alert`.

### Added

- Declare `Debuggable` conformance to `BugReporter`, `Logger` and `TouchVisualization` seeds.
- Extension to construct a `CGRect` centered on a `CGPoint` with a given `CGSize`.

### Fixed

- Swift 5.1 support.
- `WindowLevel` now includes a level for `TouchVisualizer`.

## [14.1.0] 2019-09-04

### Added

- A way to tell `CrudViewController` all the edit actions to show for an item cell, instead of actions to add to default Edit and Delete actions. This helps if you want Delete without Edit, or totally different set of options.
- ObjC access to `UIAlertControllerFactory` functions.

### Fixed

- `CrudViewController` now transitions to nonempty states when calling `reloadData()` that causes a fetch of newly added entities.
- New compiler warning about redun

## [14.0.0] 2019-03-20

### Changed

- Converted remaining implicitly unwrapped optionals in `Environment` to optionals.
- Make `TouchVisualization` `EnvironmentallyConscious` so it can use logging etc.
- Consolidate `FileManager` errors in an extension to get standard user directories.

### Added

- `NSErrorConvertible` protocol for Swift errors to be able to produce an `NSError` version of themselves.
- `Environment` errors for when an expected piece of infrastructure necessary for a particular function is not present, like an `InAppPurchaseVendor`.

### Fixed

- `FormController` no longer shows disabled "Next" and "Previous" buttons when only one input is currently managed.

## [13.0.0] 2019-01-29

### Changed

- Fixed up the APIs in `FileManager+URLs` for better consistency in naming and error throwing.

### Added

- Extension on `CGFloat` describing the amount of alpha a disabled UI element should have.
- Teach `UIFont` instances how to grow a bit bigger or smaller.
- New parameter on `CoreDataController.save(context:)` to provide a custom failure message to display in an alert and in the logs.
- Expose more extensions to `public` and also explicitly declare a few `internal` and `private` ones that were missing any protection type.

## [12.1.0] 2019-01-09

### Added

- `CompoundOperation` and test/demo code ported from [FABOperation](https://github.com/google-fabric/faboperation).
- JSON extensions for `Dictionary`, `String` and `Data`.
- Reusable `ColorGradientLayer` and `ColorSliderCell` subclasses of `CALayer` and `UITableViewCell`, respectively.
- Function to split an `Array` into subarrays of a specified size.
- Function to test if an object instance is one of a set of types.
- `Model` seed protocol.
- Taught `UITableViewCell` how to draw a cell separator on its top edge.
- Let `Date.elapsedTime(since:)` default to time since now if called with no parameter.
- Taught `Dictionary` how to initialize from a Plist file, as well as how to return a list of its keys ordered by their associated values, or an array of `(key, value)` tuples ordered by key, in various ways.
- Definitions and a `String` extension function to parse CSV files.
- Add a way to insert a new key/value pair into a `Dictionary`, or if there's already a value mapped to the key, a way to update the value using a block.

### Fixed

- When `AsyncOperation`s are cancelled in-flight, their `completionBlock` inherited from `Operation` is not executed, in accordance with `Operation`'s behavior.

## [12.0.1] 2018-10-29

### Fixed

- Remove all pod dependencies (so, just Anchorage) from `Pippin/Extensions` subspec.
- Rename Core subdirectory to Seeds, to disambiguate between the Core subspec and the subdirectory containing the Core protocols and data structures.

## [12.0.0] 2018-10-25

### Changed

- Adapters to Pippin protocols now live in the separate `PippinAdapters.podspec`.

## [11.0.0] 2018-09-23

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

## [10.0.0] 2018-09-05

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

## [9.0.3] 2018-08-24

### Fixed

- Improved keyboard avoidance in `FormController` when used in conjunction with a `UIScrollView`.
- Fixed issues in `AuthorizedCLLocationManager` and `CoreLocationAdapter` that prevented themt from calling back to consumers.

## [9.0.2] 2018-08-24

### Changed

- Renamed a parameter in a `UIEdgeInset+Factory.swift` init to remove ambiguity with its stock `init(top:right:bottom:left)`

## [9.0.1] 2018-08-23

### Fixed

- Prepopulated app name and version into subject and body of feedback emails sent from InfoViewController. Also dismiss the mail view, where it previously hung on the screen.

## [9.0.0] 2018-08-23

### Changed

- `InfoViewController` is constructed differently, with changes to how acknowledgements are passed in.

### Added

- Automatically add buttons for bug reporting, acknowledgements, contact, and in app purchases in `InfoViewController`.
- `Debuggable` protocol specifying that conformers will return a `UIView` containing controls a tester may use to exercise the component. Add implementations for `SwiftMessagesAdapter` (`Alerter`), `JGProgressHUDAdapter` (`ActivityIndicator`), `CrashlyticsAdapter` (`CrashReporter`) and `CoreDataController`.
- Parameter on `Environment` for a `Fonts` conforming object, and a default `Fonts` implementation, `DefaultFonts`, provided as the default value if one is not provided. This helped to remove the fonts parameter from `InfoViewController`, and is used in several other places that already benefited from `EnvironmentallyConscious` conformance.

### Fixed

- Thread child view controller `title` value through `BlurViewController`. Helps when embedding a vc into `BlurViewController` and then in a `DismissableModalViewController`, which displays a `UILabel` with the child vc's `title`.
- Fixed `hitTest` override in `DebugWindow` that caused touches on anything other than `UIButton`s in the `DebugViewController`.

## [8.0.0]

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
