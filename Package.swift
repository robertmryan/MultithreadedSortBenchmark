// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyPackage",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "benchmark", targets: ["MultithreadedSortBenchmark"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections-benchmark", from: "0.0.3"),
        // ... other dependencies ...
    ],
    targets: [
        // ... other targets ...
        .executableTarget(
            name: "MultithreadedSortBenchmark",
            dependencies: [
                .product(name: "CollectionsBenchmark", package: "swift-collections-benchmark"),
            ]),
    ]
)
