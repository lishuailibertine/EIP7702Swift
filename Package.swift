// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EIP7702Swift",
    platforms: [
        .macOS(.v10_15), .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EIP7702Swift",
            targets: ["EIP7702Swift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/lishuailibertine/web3swift", exact: "2.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EIP7702Swift",
            dependencies: [
                "web3swift"
            ]),
        .testTarget(
            name: "EIP7702SwiftTests",
            dependencies: ["EIP7702Swift"]
        ),
    ]
)
