# PippinAdapters

[![Cocoapod](http://img.shields.io/cocoapods/v/PippinAdapters.svg?style=flat)](http://cocoapods.org/pods/PippinAdapters)

These may have concrete objects implementing the functionality directly, or if there is already a great 3rd party doing the job well, provide an adapter implementation to that dependency. Each adapter has a separate CocoaPods subspec. The following adapters for third-party frameworks are currently available:

- `Alerter`: [SwiftMessages](https://github.com/SwiftKickMobile/SwiftMessages)
- `BugReporter`: [PinpointKit](https://github.com/Lickability/PinpointKit)
- `Logger`: [XCGLogger](https://github.com/DaveWoodCom/XCGLogger)
- `ActivityIndicator`: [JGProgressHUD](https://github.com/JonasGessner/JGProgressHUD)
- `TouchVisualization`: [COSTouchVisualizer](https://github.com/conopsys/COSTouchVisualizer)
- `CrashReporter`: [KSCrash](https://github.com/kstenerud/kscrash)

The following hand rolled adapters are available:

- `Locator`: `CoreLocationAdapter` (and `CoreLocationSimulator`–wip)
- `Defaults` and `DefaultsKey`: `DefaultDefaults` and `DefaultDefaultsKey` (say _that_ fast five times)
- `Fonts`: `DefaultFonts`
- `CrudViewController`: Create, read, update and delete from a data model using `UITableView`, `UISearchController` and `FetchedResultsController`
- `InfoViewController`: app name and version info, links to Two Ring Software properties (need to parameterize and extract to private shared repo), and buttons for more detail for certain components that may be present, like acknowledgements, bug reporting or in app purchases
- `FormController`: manage traversal and keyboard avoidance for a collection of inputs
