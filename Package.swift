// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "MessagePack",
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
