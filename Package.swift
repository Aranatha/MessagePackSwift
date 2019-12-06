// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "MessagePack",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v12),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "MessagePack",
            targets: ["MessagePack"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "MessagePack",
            dependencies: []),
        .testTarget(
            name: "MessagePackTests",
            dependencies: ["MessagePack"]),
    ]
)
