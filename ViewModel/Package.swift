// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ViewModel",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15),
    ],
    products: [
        .library(name: "FunViewModel", targets: ["FunViewModel"]),
    ],
    dependencies: [
        .package(name: "Model", path: "../Model"),
        .package(name: "Core", path: "../Core"),
    ],
    targets: [
        .target(
            name: "FunViewModel",
            dependencies: [
                .product(name: "FunModel", package: "Model"),
                .product(name: "FunCore", package: "Core"),
            ],
            path: "Sources/ViewModel"
        ),
        .testTarget(
            name: "ViewModelTests",
            dependencies: [
                "FunViewModel",
                .product(name: "FunModel", package: "Model"),
                .product(name: "FunModelTestSupport", package: "Model"),
                .product(name: "FunCore", package: "Core"),
            ]
        ),
    ]
)
