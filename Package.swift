// swift-tools-version:6.2

/**
*  CollectionConcurrencyKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

import PackageDescription

let package = Package(
    name: "CollectionConcurrencyKit",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .watchOS(.v26),
        .tvOS(.v26)
    ],
    products: [
        .library(
            name: "CollectionConcurrencyKit",
            targets: ["CollectionConcurrencyKit"]
        )
    ],
    targets: [
        .target(
            name: "CollectionConcurrencyKit",
            path: "Sources"
        ),
        .testTarget(
            name: "CollectionConcurrencyKitTests",
            dependencies: ["CollectionConcurrencyKit"],
            path: "Tests",
            swiftSettings: [
                .define("TIMING_TESTS")
            ]
        )
    ]
)
