// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Services",
    platforms: [
        .iOS(.v16),
        .macCatalyst(.v16),
    ],
    products: [
        .library(name: "FunServices", targets: ["FunServices"]),
    ],
    dependencies: [
        .package(name: "Model", path: "../Model"),
        .package(name: "Core", path: "../Core"),
    ],
    targets: [
        .target(
            name: "FunServices",
            dependencies: [
                .product(name: "FunModel", package: "Model"),
                .product(name: "FunCore", package: "Core"),
            ],
            path: "Sources/Services"
        ),
        .testTarget(
            name: "ServicesTests",
            dependencies: ["FunServices"]
        ),
    ]
)
