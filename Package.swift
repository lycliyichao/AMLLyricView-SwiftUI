// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AMLLView",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AMLLView",
            targets: ["AMLLView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AMLLView",
            dependencies: [
                .product(name: "SwiftSoup", package: "SwiftSoup")
            ]),
        .testTarget(
            name: "AMLLViewTests",
            dependencies: ["AMLLView"]),
    ]
)
