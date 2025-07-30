// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "onboardsync_swift",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "onboardsync_swift",
            targets: ["OnboardSync"]),
    ],
    targets: [
        .target(
            name: "OnboardSync",
            dependencies: [],
            path: "Sources/OnboardSync"),
        .testTarget(
            name: "OnboardSyncTests",
            dependencies: ["OnboardSync"],
            path: "Tests/OnboardSyncTests"),
    ]
)