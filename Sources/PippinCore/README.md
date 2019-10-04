# Pippin

[![Build Status](https://travis-ci.org/TwoRingSoft/Pippin.svg?branch=master)](https://travis-ci.org/TwoRingSoft/Pippin)

`PippinCore`'s main goal is to decouple dependencies from your app, allowing you to swap in different third party frameworks, hand rolled versions or test mocks/fakes of production counterparts, with no changes to your codebase. 

`PippinCore` has three main areas:

- [Components](#components)
- [Environment](#environment)
- [Peripherals](#peripherals)

## Components

The basic building blocks of `Pippin`: stable APIs that sit between app code and dependencies, delivered via [data structures](#data-structures) and [protocols](#protocols). 

### Data Structures

`Environment` contains a property for each component, peripheral, and environment info.

### Protocols

`PippinCore` abstracts some major aspects of an app into protocols describing how they should work:

- `Model`: data modelling (WIP: for now just use `PippinAdapters/CoreDataAdapter`)
- `CrashReporter`
- `BugReporter`
- `Logger`
- `Alerter`
- `InAppPurchaseVendor`
- `ActivityIndicator`

These form a [Facade](https://en.wikipedia.org/wiki/Facade_pattern) that sits in between your app code and dependencies, and [Adapter](https://en.wikipedia.org/wiki/Adapter_pattern) implementations to those protocols are supplied in [`PippinAdapters`](../PippinAdapters).

## Environment

A few protocols define cross-cutting concerns among many components:

- `Themeable`: provide access to `UIAppearanceProxy` based theming of UI elements
- `Debuggable`: deliver UI controls to exercise and manipulate UI components, for use by developers and testers
- `EnvironmentallyConscious`: provides a reference back to the `Environment` instance to which an instance belongs, allowing it to use other components: everything may access the logger, the logger may access the crash reporter to leave breadcrumbs, and the bug reporter may access the data model to export the database with the bug report

## Peripherals

- `Locator`: location/GPS

# Things to add:

- Settings bundles
- Analytics
- Push notifications
- State restoration
- App walkthrough
