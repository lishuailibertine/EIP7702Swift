// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EIP7702Swift",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EIP7702Swift",
            targets: ["EIP7702Swift"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EIP7702Swift"),
        .testTarget(
            name: "EIP7702SwiftTests",
            dependencies: ["EIP7702Swift"]
        ),
    ]
)
