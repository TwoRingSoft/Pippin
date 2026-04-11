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
            name: "PippinAdapters-AVCaptureDevice",
            targets: ["PippinAdapters-AVCaptureDevice"]),
        .library(
            name: "PippinAdapters-CoreData",
            targets: ["PippinAdapters-CoreData"]),
        .library(
            name: "PippinAdapters-CoreLocation",
            targets: ["PippinAdapters-CoreLocation"]),
        .library(
            name: "PippinAdapters-CoreLocationSimulator",
            targets: ["PippinAdapters-CoreLocationSimulator"]),
        .library(
            name: "PippinAdapters-CrudViewController",
            targets: ["PippinAdapters-CrudViewController"]),
        .library(
            name: "PippinAdapters-FormController",
            targets: ["PippinAdapters-FormController"]),
        .library(
            name: "PippinAdapters-InfoViewController",
            targets: ["PippinAdapters-InfoViewController"]),
        .library(
            name: "PippinAdapters-JGProgressHUD",
            targets: ["PippinAdapters-JGProgressHUD"]),
        .library(
            name: "PippinAdapters-OSLog",
            targets: ["PippinAdapters-OSLog"]),
        .library(
            name: "PippinAdapters-StoreKit",
            targets: ["PippinAdapters-StoreKit"]),
        .library(
            name: "PippinAdapters-SwiftMessages",
            targets: ["PippinAdapters-SwiftMessages"]),
        .library(
            name: "PippinAdapters-XCGLogger",
            targets: ["PippinAdapters-XCGLogger"]),
        .library(
            name: "PippinAdapters-SwiftyBeaver",
            targets: ["PippinAdapters-SwiftyBeaver"]),
        .library(
            name: "PippinAdapters-CloudKitCoreData",
            targets: ["PippinAdapters-CloudKitCoreData"]),
        .library(
            name: "PippinDebugging",
            targets: ["PippinDebugging"]),
    ],
    dependencies: [
        .package(path: "swift-armcknight"),
        .package(url: "https://github.com/Rightpoint/Anchorage", from: "4.5.0"),
        .package(url: "https://github.com/SwiftKickMobile/SwiftMessages", from: "10.0.0"),
        .package(url: "https://github.com/DaveWoodCom/XCGLogger", from: "7.0.0"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver", from: "2.0.0"),
        .package(url: "https://github.com/JonasGessner/JGProgressHUD", from: "2.2.0"),
        .package(url: "https://github.com/FLEXTool/FLEX", from: "5.22.10"),
        .package(url: "https://github.com/antitypical/Result", from: "5.0.0"),
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

        // Individual adapter targets
        .target(
            name: "PippinAdapters-AVCaptureDevice",
            dependencies: ["Pippin"],
            path: "Sources/PippinAdapters/AVCaptureDevice"
        ),
        .target(
            name: "PippinAdapters-CoreData",
            dependencies: [
                "Pippin",
                .product(name: "SwiftArmcknight", package: "swift-armcknight"),
                .product(name: "SwiftArmcknightUIKit", package: "swift-armcknight"),
            ],
            path: "Sources/PippinAdapters/CoreData"
        ),
        .target(
            name: "PippinAdapters-CloudKitCoreData",
            dependencies: [
                "Pippin",
                "PippinAdapters-CoreData",
            ],
            path: "Sources/PippinAdapters/CloudKitCoreData"
        ),
        .target(
            name: "PippinAdapters-CoreLocation",
            dependencies: [
                "Pippin",
                "Result",
            ],
            path: "Sources/PippinAdapters/CoreLocation"
        ),
        .target(
            name: "PippinAdapters-CoreLocationSimulator",
            dependencies: [
                "Pippin",
                "Anchorage",
            ],
            path: "Sources/PippinAdapters/CoreLocationSimulator"
        ),
        .target(
            name: "PippinAdapters-CrudViewController",
            dependencies: [
                "Pippin",
                "Anchorage",
                .product(name: "SwiftArmcknight", package: "swift-armcknight"),
                .product(name: "SwiftArmcknightUIKit", package: "swift-armcknight"),
            ],
            path: "Sources/PippinAdapters/CrudViewController"
        ),
        .target(
            name: "PippinAdapters-FormController",
            dependencies: [
                "Pippin",
                "Anchorage",
                .product(name: "SwiftArmcknight", package: "swift-armcknight"),
                .product(name: "SwiftArmcknightUIKit", package: "swift-armcknight"),
            ],
            path: "Sources/PippinAdapters/FormController"
        ),
        .target(
            name: "PippinAdapters-InfoViewController",
            dependencies: [
                "Pippin",
                "Anchorage",
                .product(name: "SwiftArmcknight", package: "swift-armcknight"),
                .product(name: "SwiftArmcknightUIKit", package: "swift-armcknight"),
            ],
            path: "Sources/PippinAdapters/InfoViewController"
        ),
        .target(
            name: "PippinAdapters-JGProgressHUD",
            dependencies: [
                "Pippin",
                .product(name: "SwiftArmcknight", package: "swift-armcknight"),
                .product(name: "SwiftArmcknightUIKit", package: "swift-armcknight"),
                .product(name: "JGProgressHUD", package: "JGProgressHUD", condition: .when(platforms: [.iOS])),
            ],
            path: "Sources/PippinAdapters/JGProgressHUD"
        ),
        .target(
            name: "PippinAdapters-OSLog",
            dependencies: ["Pippin"],
            path: "Sources/PippinAdapters/OSLog"
        ),
        .target(
            name: "PippinAdapters-StoreKit",
            dependencies: [
                "Pippin",
                "Anchorage",
                .product(name: "SwiftArmcknight", package: "swift-armcknight"),
                .product(name: "SwiftArmcknightUIKit", package: "swift-armcknight"),
            ],
            path: "Sources/PippinAdapters/StoreKit"
        ),
        .target(
            name: "PippinAdapters-SwiftMessages",
            dependencies: [
                "Pippin",
                "Anchorage",
                .product(name: "SwiftArmcknight", package: "swift-armcknight"),
                .product(name: "SwiftArmcknightUIKit", package: "swift-armcknight"),
                .product(name: "SwiftMessages", package: "SwiftMessages", condition: .when(platforms: [.iOS])),
            ],
            path: "Sources/PippinAdapters/SwiftMessages"
        ),
        .target(
            name: "PippinAdapters-SwiftyBeaver",
            dependencies: [
                "Pippin",
                .product(name: "SwiftyBeaver", package: "SwiftyBeaver"),
            ],
            path: "Sources/PippinAdapters/SwiftyBeaver"
        ),
        .target(
            name: "PippinAdapters-XCGLogger",
            dependencies: [
                "Pippin",
                .product(name: "SwiftArmcknight", package: "swift-armcknight"),
                .product(name: "SwiftArmcknightUIKit", package: "swift-armcknight"),
                .product(name: "XCGLogger", package: "XCGLogger"),
                .product(name: "ObjcExceptionBridging", package: "XCGLogger"),
            ],
            path: "Sources/PippinAdapters/XCGLogger"
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
