// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Coordinator",
    platforms: [
        .iOS(.v15),
        .macOS(.v11),
        .macCatalyst(.v15),
    ],
    products: [
        .library(name: "FunCoordinator", targets: ["FunCoordinator"]),
    ],
    dependencies: [
        .package(name: "Model", path: "../Model"),
        .package(name: "ViewModel", path: "../ViewModel"),
        .package(name: "UI", path: "../UI"),
        .package(name: "Toolbox", path: "../Toolbox"),
    ],
    targets: [
        .target(
            name: "FunCoordinator",
            dependencies: [
                .product(name: "FunModel", package: "Model"),
                .product(name: "FunViewModel", package: "ViewModel"),
                .product(name: "FunUI", package: "UI"),
                .product(name: "FunToolbox", package: "Toolbox"),
            ],
            path: "Sources/Coordinator"
        ),
        .testTarget(
            name: "CoordinatorTests",
            dependencies: ["FunCoordinator"]
        ),
    ]
)
