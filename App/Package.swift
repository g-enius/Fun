// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "App",
    platforms: [
        .iOS(.v15),
        .macOS(.v11),
        .macCatalyst(.v15),
    ],
    products: [
        .library(name: "App", targets: ["AppCore"]),
    ],
    dependencies: [
        .package(name: "ViewModel", path: "../ViewModel"),
        .package(name: "UI", path: "../UI"),
        .package(name: "Model", path: "../Model"),
        .package(name: "Services", path: "../Services"),
        .package(name: "Toolbox", path: "../Toolbox"),
        .package(name: "Coordinator", path: "../Coordinator"),
    ],
    targets: [
        .target(
            name: "AppCore",
            dependencies: [
                .product(name: "FunViewModel", package: "ViewModel"),
                .product(name: "FunUI", package: "UI"),
                .product(name: "FunModel", package: "Model"),
                .product(name: "FunServices", package: "Services"),
                .product(name: "FunToolbox", package: "Toolbox"),
                .product(name: "FunCoordinator", package: "Coordinator"),
            ],
            path: "Sources/App"
        ),
        .testTarget(
            name: "FunAppTests",
            dependencies: ["AppCore"]
        ),
    ]
)
