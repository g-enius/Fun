// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "UI",
    platforms: [
        .iOS(.v15),
        .macOS(.v11),
        .macCatalyst(.v15),
    ],
    products: [
        .library(name: "FunUI", targets: ["FunUI"]),
    ],
    dependencies: [
        .package(name: "ViewModel", path: "../ViewModel"),
        .package(name: "Model", path: "../Model"),
        .package(name: "Toolbox", path: "../Toolbox"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.0"),
    ],
    targets: [
        .target(
            name: "FunUI",
            dependencies: [
                .product(name: "FunViewModel", package: "ViewModel"),
                .product(name: "FunModel", package: "Model"),
                .product(name: "FunToolbox", package: "Toolbox"),
            ],
            path: "Sources/UI",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "UITests",
            dependencies: [
                "FunUI",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)
