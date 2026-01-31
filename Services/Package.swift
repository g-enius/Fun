// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Services",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15),
    ],
    products: [
        .library(name: "FunServices", targets: ["FunServices"]),
    ],
    dependencies: [
        .package(name: "Model", path: "../Model"),
        .package(name: "Toolbox", path: "../Toolbox"),
    ],
    targets: [
        .target(
            name: "FunServices",
            dependencies: [
                .product(name: "FunModel", package: "Model"),
                .product(name: "FunToolbox", package: "Toolbox"),
            ],
            path: "Sources/Services"
        ),
        .testTarget(
            name: "ServicesTests",
            dependencies: ["FunServices"]
        ),
    ]
)
