# Pippin

[![Build Status](https://travis-ci.org/TwoRingSoft/Pippin.svg?branch=xcode-9)](https://travis-ci.org/TwoRingSoft/Pippin)
![Swift 4](https://img.shields.io/badge/Swift-4-orange.svg)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20OS%20X%20%7C%20watchOS%20%7C%20tvOS%20-lightgrey.svg)

Pippin is a collection of utilities to quickly prototype iOS apps and simplify working with Cocoa/UIKit API in Swift.

## Organization

### App prototyping

Pippin is designed to immediately abstract and handle the major components that usually go into an app: 

- crash reporting
- bug reporting
- logging
- data persistence
- in-app debug utilities
- app information/acknowledgements

Each of these has a top-level protocol defined, which can either have concrete objects implementing the functionality directly, or if there is already a great 3rd party doing the job well, provide an Adapter implementation to that dependency. Currently, bug reporting is adapted from [PinpointKit](https://github.com/Lickability/PinpointKit), and logging to [XCGLogger](https://github.com/DaveWoodCom/XCGLogger). 

**Note:** Crashlytics is a special case, because it delivers a static framework, which is disallowed in CocoaPods framework dependency chains. `CrashlyticsAdapter.swift` is delivered separately in the repo, as it's not able to be built in the Pippin pod target due to the simple required `import Crashlytics` in that file. Where Pippin decalares podspec dependencies on the aforementioned pods, you must specify `pod 'Crashlytics'` in your own Podfile and manually add `CrashlyticsAdapter.swift` to your project for it to work correctly.


#### Components to add:

- error display/alerting
- settings bundles
- analyticss

