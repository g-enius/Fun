// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Toolbox",
    platforms: [
        .iOS(.v15),
        .macOS(.v11),
        .macCatalyst(.v15),
    ],
    products: [
        .library(name: "FunToolbox", targets: ["FunToolbox"]),
    ],
    targets: [
        .target(
            name: "FunToolbox",
            path: "Sources/Toolbox"
        ),
        .testTarget(
            name: "ToolboxTests",
            dependencies: ["FunToolbox"]
        ),
    ]
)
