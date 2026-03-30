// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "Pippin",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "PippinCore",
            targets: ["Pippin"]),
        .library(
            name: "PippinAdapters",
            targets: ["PippinAdapters"]),
        .library(
            name: "PippinDebugging",
            targets: ["PippinDebugging"]),
    ],
    dependencies: [
        .package(path: "../swift-armcknight"),
        .package(url: "https://github.com/Rightpoint/Anchorage", from: "4.5.0"),
        .package(url: "https://github.com/SwiftKickMobile/SwiftMessages", from: "10.0.0"),
        .package(url: "https://github.com/DaveWoodCom/XCGLogger", from: "7.0.0"),
        .package(url: "https://github.com/JonasGessner/JGProgressHUD", from: "2.2.0"),
        // KSCrash excluded: 2.x API incompatible with adapter (written for 1.x)
        // .package(url: "https://github.com/kstenerud/KSCrash", from: "2.0.0"),
        // PinpointKit excluded: no SPM support (archived, no Package.swift)
        // .package(url: "https://github.com/Lickability/PinpointKit", from: "1.5.0"),
        .package(url: "https://github.com/FLEXTool/FLEX", from: "5.22.10"),
        .package(url: "https://github.com/antitypical/Result", from: "5.0.0"),
        .package(path: "../sentry-cocoa"),
    ],
    targets: [
        // PippinCore: app shell - Environment, component protocols, defaults, theming
        // Target named "Pippin" to match the original CocoaPods module name (import Pippin)
        .target(
            name: "Pippin",
            dependencies: [
                .product(name: "SwiftArmcknight", package: "swift-armcknight"),
                .product(name: "SwiftArmcknightUIKit", package: "swift-armcknight"),
            ],
            path: "Sources/PippinCore",
            exclude: [
                "README.md",
            ],
            resources: [
                .process("Resources"),
            ]
        ),

        // PippinAdapters: third-party adapter implementations
        .target(
            name: "PippinAdapters",
            dependencies: [
                "Pippin",
                .product(name: "SwiftArmcknight", package: "swift-armcknight"),
                .product(name: "SwiftArmcknightUIKit", package: "swift-armcknight"),
                "Anchorage",
                .product(name: "SwiftMessages", package: "SwiftMessages", condition: .when(platforms: [.iOS])),
                "XCGLogger",
                .product(name: "JGProgressHUD", package: "JGProgressHUD", condition: .when(platforms: [.iOS])),
                "Result",
                .product(name: "Sentry", package: "sentry-cocoa"),
            ],
            path: "Sources/PippinAdapters",
            exclude: [
                "README.md",
                "COSTouchVisualizer",
                "PinpointKit",
                "KSCrash",
            ]
        ),

        // PippinDebugging: debug UI infrastructure
        .target(
            name: "PippinDebugging",
            dependencies: [
                "Pippin",
                .product(name: "SwiftArmcknight", package: "swift-armcknight"),
                .product(name: "SwiftArmcknightUIKit", package: "swift-armcknight"),
                "Anchorage",
                .product(name: "FLEX", package: "FLEX", condition: .when(platforms: [.iOS])),
            ],
            path: "Sources/PippinDebugging",
            exclude: [
                "README.md",
            ]
        ),
    ]
)
