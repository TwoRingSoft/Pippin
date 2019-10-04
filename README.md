# Pippin

![Swift 5.1](https://img.shields.io/badge/Swift-5.1-orange.svg)
![platforms](https://img.shields.io/badge/platforms-iOS-lightgrey.svg)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://mit-license.org)

`Pippin` is a collection of tools to scaffold iOS app infrastructure and assist in development tasks like writing code, testing and debugging.

Getting started with a default setup is as easy as declaring a Podfile dependency:

```ruby
pod 'Pippin'
```

and, at some point during your app launch sequence:

```swift
import Pippin
import PippinAdapters

let environment = Environment.default(
    bugReportRecipients: ["andrew@tworingsoft.com"],
    touchVizRootVC: UIViewController(nibName: nil, bundle: nil) // optional
)

// Crashlytics is a special situation
environment.crashReporter = CrashlyticsAdapter(debug: true)

// other optional peripherals
environment.locator = CoreLocationAdapter(locatorDelegate: self)

environment.connectEnvironment()
```

You've just gotten the following, with minimal boilerplate: 

- logging
- crash reporting
- bug reporting
- progress indicators
- alert dialogs
- fonts
- app and launch information
- data model
- touch visualization
- launch arguments and environment variables
- an authorized `CLLocationManager` (an authorized `AVCaptureDevice` may be obtained similarly)

## Podspecs

There are five podspecs to deliver these tools, see each's README for more information:

- [`PippinCore`](Sources/PippinCore)
- [`PippinAdapters`](Sources/PippinAdapters)
- [`PippinDebugging`](Sources/PippinDebugging)
- [`PippinLibrary`](Sources/PippinLibrar)
- [`PippinTesting`](Sources/PippinTesting)

> **Note:** there are several reasons these are delivered via separate podspecs instead of one podspec with multiple podspecs. Those two spec levels are not equivalent for all functionalities.
>
> - Issues with installing `test_spec`s for just one subspec.
> - Not supported to install a subspec using `Pod:configurations`: [https://github.com/CocoaPods/CocoaPods/issues/3503](https://github.com/CocoaPods/CocoaPods/issues/3503).

The old `Pippin.podspec` is now an umbrella framework that pulls in `PippinCore`, `PippinAdapters`, `PippinLibrary` and `PippinTesting` for convenience.

## Example projects

These are used for testing and can be evaluated using `pod try`:

- [`OperationDemo`](Examples/OperationDemo)
- [`Pippin`](Examples/Pippin)

# Contribute

Issues and pull requests are welcome! 

## Testing

`rake test`

Runs a collection of Rake tasks which themselves may be run independently:

- `example_smoke_tests`
- `unit_tests`
- `test_smoke_test`
- `subspec_smoke_test`

### `example_smoke_tests`

For each project in `Examples/` try to `pod install` and build.

### `unit_tests`

Run the unit test suites created for any `test_specs` of any Pippin podspecs.

### `test_smoke_test`

`pod install` and try to build the `Example/Pippin.xcodeproject` unit and UI test targets, which both declare dependencies on `PippinLibrary` and `PippinTesting`.

### `subspec_smoke_test`

An integration smoke test, which generates an Xcode project for each subspec of each Pippin podspec, each in both Swift and Objective-C, to try building after `pod install`ing that subspec. Each project is deposited under `PippinTests/SmokeTests`. 

`PippinTests/` also contains the template project source code in `ObjcApp/` and `SwiftApp/`, plus the template Podfile.

### Podspec `test_specs`

Pippin podspecs currently with unit tests located under `Tests/`:

- `PippinLibrary`
- `PippinTesting`

# Thanks!

If this project helped you, please consider <a href="https://www.paypal.me/armcknight">leaving a tip</a> 🤗
