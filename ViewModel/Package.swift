// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ViewModel",
    platforms: [
        .iOS(.v15),
        .macOS(.v11),
        .macCatalyst(.v15),
    ],
    products: [
        .library(name: "FunViewModel", targets: ["FunViewModel"]),
    ],
    dependencies: [
        .package(name: "Model", path: "../Model"),
        .package(name: "Toolbox", path: "../Toolbox"),
    ],
    targets: [
        .target(
            name: "FunViewModel",
            dependencies: [
                .product(name: "FunModel", package: "Model"),
                .product(name: "FunToolbox", package: "Toolbox"),
            ],
            path: "Sources/ViewModel"
        ),
        .testTarget(
            name: "ViewModelTests",
            dependencies: ["FunViewModel"]
        ),
    ]
)
