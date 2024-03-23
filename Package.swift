// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "SwiftMetronome",
    platforms: [.visionOS(.v1)],
    products: [
        .library(
            name: "SwiftMetronome",
            targets: ["SwiftMetronome"]),
    ],
    dependencies: [
        .package(url: "https://github.com/AudioKit/AudioKit.git", from: "5.0.0"),
        .package(url: "https://github.com/Matt54/ResizableVector.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SwiftMetronome",
            dependencies: ["AudioKit", "ResizableVector"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "SwiftMetronomeTests",
            dependencies: ["SwiftMetronome"]),
    ]
)
