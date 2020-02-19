// swift-tools-version:5.1

import PackageDescription


import PackageDescription

let package = Package(
    name: "RCRealm",
    platforms: [.iOS(SupportedPlatform.IOSVersion.v9)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "RCRealm",
            targets: ["RCRealm"]),
    ],
    dependencies:[
        .package(url: "https://github.com/techpro-studio/RCKit", from: "0.0.3"),
        .package(url: "https://github.com/realm/realm-cocoa", from: "4.3.2"),

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "RCRealm",
            dependencies: ["RealmSwift", "RCKit"]),
    ]
)
