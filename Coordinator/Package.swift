// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Coordinator",
    platforms: [
        .iOS(.v16),
        .macCatalyst(.v16),
    ],
    products: [
        .library(name: "FunCoordinator", targets: ["FunCoordinator"]),
    ],
    dependencies: [
        .package(name: "Model", path: "../Model"),
        .package(name: "ViewModel", path: "../ViewModel"),
        .package(name: "UI", path: "../UI"),
        .package(name: "Core", path: "../Core"),
    ],
    targets: [
        .target(
            name: "FunCoordinator",
            dependencies: [
                .product(name: "FunModel", package: "Model"),
                .product(name: "FunViewModel", package: "ViewModel"),
                .product(name: "FunUI", package: "UI"),
                .product(name: "FunCore", package: "Core"),
            ],
            path: "Sources/Coordinator"
        ),
    ]
)
