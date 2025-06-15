// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PerformanceMonitor",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "PerformanceMonitor",
            targets: ["PerformanceMonitor"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PerformanceMonitor",
            dependencies: [],
            path: "Sources/PerformanceMonitor"),
        .testTarget(
            name: "PerformanceMonitorTests",
            dependencies: ["PerformanceMonitor"],
            path: "Tests/PerformanceMonitorTests")
    ]
)
