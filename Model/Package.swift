// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Model",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15),
    ],
    products: [
        .library(name: "FunModel", targets: ["FunModel"]),
        .library(name: "FunModelTestSupport", targets: ["FunModelTestSupport"]),
    ],
    dependencies: [
        .package(name: "Core", path: "../Core"),
    ],
    targets: [
        .target(
            name: "FunModel",
            dependencies: [
                .product(name: "FunCore", package: "Core"),
            ],
            path: "Sources/Model"
        ),
        .target(
            name: "FunModelTestSupport",
            dependencies: ["FunModel"],
            path: "Sources/ModelTestSupport"
        ),
        .testTarget(
            name: "ModelTests",
            dependencies: ["FunModel", "FunModelTestSupport"]
        ),
    ]
)
