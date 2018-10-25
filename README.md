# Pippin

[![Build Status](https://travis-ci.org/TwoRingSoft/Pippin.svg?branch=master)](https://travis-ci.org/TwoRingSoft/Pippin)
![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg)
![platforms](https://img.shields.io/badge/platforms-iOS-lightgrey.svg)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://mit-license.org)
[![Cocoapod](http://img.shields.io/cocoapods/v/Pippin.svg?style=flat)](http://cocoapods.org/pods/Pippin)

Pippin is a collection of utilities to quickly prototype iOS apps and simplify working with Cocoa/UIKit API in Swift, as well as XCTest.

## Code

Pippin is split up into some top-level components: Core, Extensions, Sensors and CanIHaz. PippinAdapters provides pluggable interfaces between Pippin protocols and 3rd party dependencies, or home-rolled implementations. PippinTesting delivers tools to work with XCTest.

### Core

#### Data Structures

`Environment` contains a property for each protocol type. They are currently implicitly unwrapped optionals, so that you can use only the components you need. Each Core protocol conforms to the `EnvironmentallyConscious` protocol, providing an optional back reference to the `Environment` instance referencing the protocol conforming instance. This allows components to use other components; e.g. all components may access the logger, the logger may access the crash reporter to leave breadcrumbs, and the bug reporter may access the datamodel conforming instance to send the database with the bug report (along with logs, obvi).

#### Protocols

Pippin is designed to immediately abstract and handle the major components that usually go into an app: 

- Crash Reporting
- Bug reporting via in-app ui
- Logging
- Debugging via in-app debug/test/qa utilities
- Alerting via popups displayed to users
- In app purchases and licensing
- Appearance: look and feel, style, theming, fonts, layout
- Activity indicators for long-running activities and progress
- Defaults: user configurable settings and storage

##### Sensors

- Locator: location/gps

#### Adapters

These may have concrete objects implementing the functionality directly, or if there is already a great 3rd party doing the job well, provide an Adapter implementation to that dependency. Each Adapter has a separate CocoaPods subspec (or should–some still are in Core; this will be straightened out more when multiple implementations may be chosen from). The following adapters for third-party frameworks are currently available:

- Alerter: [SwiftMessages](https://github.com/SwiftKickMobile/SwiftMessages)
- BugReporter: [PinpointKit](https://github.com/Lickability/PinpointKit)
- Logger: [XCGLogger](https://github.com/DaveWoodCom/XCGLogger)
- ActivityIndicator: [JGProgressHUD](https://github.com/JonasGessner/JGProgressHUD)
- TouchVisualization: [COSTouchVisualizer](https://github.com/conopsys/COSTouchVisualizer)
- CrashReporter: *[Crashlytics](https://fabric.io)

The following hand rolled adapters are available:

- Debugging: DebugViewController 
- CoreDataController (wip extracting Model protocol)
- Locator: CoreLocationAdapter (and CoreLocationSimulator–wip)
- Defaults and DefaultsKey: DefaultDefaults and DefaultDefaultsKey (say _that_ fast five times)
- Fonts: DefaultFonts 

**\*Note:** Crashlytics is a special case, because it delivers a static binary, which is disallowed in CocoaPods framework dependency chains. `CrashlyticsAdapter.swift` is delivered separately in the repo, as it's not able to be built in the Pippin pod target due to the simple required `import Crashlytics` in that file. Whereas Pippin declares podspec dependencies on the aforementioned pods, you must specify `pod 'Crashlytics'` in your own Podfile and manually add `CrashlyticsAdapter.swift` to your project for it to work correctly.

#### Aspects

There are a few protocols defining cross cutting concerns across components, like theming and debugging of components that deliver UI.

- Themeable: provide access to `UIAppearanceProxy` based theming of UI elements
- Debuggable: deliver UI controls to exercise and manipulate UI components, for use by developers and testers
- EnvironmentallyConscious: provide a back reference to the `Environment` to use other PIppin components, e.g. the `CrashReporter` and `Logger` working together

#### Components to add:

- Data model
- Settings bundles
- Analytics
- Push notifications
- State restoration
- App walkthrough

### CanIHaz

Provides a UI flow to acquire an object that is gated by user interaction to allow access to a hardware device component. Each component type has its own subspec so you can take just what you need. So far there are stock flows for the following: 

- Location: AuthorizedCLLocationManager
- Camera: AuthorizedAVCaptureDevice

### Extensions

These are currently split into extensions on Foundation, UIKit and Webkit.

#### UIKit

- CrudViewController: table view with search controls wrapped around an FRC
- InfoViewController: app name and version info, links to two ring properties (need to parameterize), and buttons for more detail for certain components that may be present, like acknowledgements, bug reporting or in app purchases
- FormController: manage traversal and keyboard avoidance for a collection of inputs

## Testing

`rake test`

Files under Pippin/Tests/ are declared in Pippin's `test_spec`, and likewise for PippinTesting. These are brought into the Pippin Xcode project to run as unit tests using the Podfile's `testspecs` declaration.

Also runs an integration smoke test, which generates an Xcode project for each subspec, in each of Swift and Objective-C, to try building after `pod install` with the appropriate subspec written into its Podfile. Each project is deposited under `PippinTests/SmokeTests`. `PippinTests/` also contains the template project source code in `ObjcApp/` and `SwiftApp/`, plus the template Podfile.

# Contribute

Issues and pull requests are welcome! 

If this project helped you, please consider <a href="https://www.paypal.me/armcknight">leaving a tip</a> 🤗

Do you need help with a project? [I'm currently available for hire or contract.](http://tworingsoft.com/contracts).
