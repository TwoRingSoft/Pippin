# Pippin

[![Build Status](https://travis-ci.org/TwoRingSoft/Pippin.svg?branch=master)](https://travis-ci.org/TwoRingSoft/Pippin)
![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg)
![platforms](https://img.shields.io/badge/platforms-iOS-lightgrey.svg)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://mit-license.org)

`Pippin`'s main goal is to decouple dependencies from your app, allowing you to swap in different third party frameworks, hand rolled versions or test mocks/fakes of production counterparts, with no changes to your codebase. 

`Pippin` has two subspecs:

- [`Core`](#core)
- [`Extensions`](#Extensions)

## Core

The `Pippin/Core` subspec is split into some subcomponents:

- [Seeds](#seeds)
- [Sensors](#sensors)
- [CanIHaz](#canihaz)
- [Controls](#controls)

### Seeds

Seeds are the basic building blocks of Pippin: stable APIs that sit between app code and dependencies, delivered via [data structures](#data-structures) and [protocols](#protocols). They make up a[Facade](https://en.wikipedia.org/wiki/Facade_pattern) that sits in between your app code and dependencies, and [Adapter](https://en.wikipedia.org/wiki/Adapter_pattern) implementations to those protocols are supplied in `PippinAdapters`.

#### Data Structures

`Environment` contains a property for each seed protocol etc.

#### Protocols

`Pippin` abstracts some major aspects of an app into protocols describing how they should work:

- `CoreDataController`: data modelling, (WIP: extract this into a fully-decoupled protocol with a `CoreDataAdapter`)
- `CrashReporter`
- `BugReporter`
- `Logger`
- `Alerter`
- `InAppPurchaseVendor`
- `Fonts`
- `ActivityIndicator`
- `Defaults`: provide some app/launch information

There are a few protocols defining cross-cutting concerns among many components, like theming and debugging of components that deliver UI.

- `Themeable`: provide access to `UIAppearanceProxy` based theming of UI elements
- `Debuggable`: deliver UI controls to exercise and manipulate UI components, for use by developers and testers
- `EnvironmentallyConscious`: provides an optional reference back to the `Environment` instance holding a reference to a given seed instance, allowing components to use other components: everything may access the logger, the logger may access the crash reporter to leave breadcrumbs, and the bug reporter may access the data model to export the database with the bug report

### Sensors

- `Locator`: location/gps

### CanIHaz

Provides a UI flow to acquire a user's permission to access a hardware component on device. Each component type has its own subspec so you can take just what you need. So far, there are stock flows for the following: 

- `AuthorizedCLLocationManager`
- `AuthorizedAVCaptureDevice`

### Controls

- `CrudViewController`: table view with search controls wrapped around an FRC
- `InfoViewController`: app name and version info, links to Two Ring Software properties (need to parameterize), and buttons for more detail for certain components that may be present, like acknowledgements, bug reporting or in app purchases
- `FormController`: manage traversal and keyboard avoidance for a collection of inputs

### Things to add:

- Settings bundles
- Analytics
- Push notifications
- State restoration
- App walkthrough

## Extensions

These are currently split into extensions on `Foundation` and the Swift stdlib, `UIKit` and `Webkit`.