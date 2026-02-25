// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Core",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macCatalyst(.v16),
    ],
    products: [
        .library(name: "FunCore", targets: ["FunCore"]),
    ],
    targets: [
        .target(
            name: "FunCore",
            path: "Sources/Core",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["FunCore"]
        ),
    ]
)
