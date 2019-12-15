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
        .executable(name: "pack",
                    targets: ["pack"]),
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
        .target(
            name: "pack",
            dependencies: ["MessagePack"]),
        .testTarget(
            name: "MessagePackTests",
            dependencies: ["MessagePack"]),
    ]
)
