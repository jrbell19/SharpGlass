// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SharpGlass",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "SharpGlass", targets: ["SharpGlassApp"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SharpGlass",
            dependencies: [],
            path: "Sources/SharpGlass",
            exclude: ["Shaders.metal"]
        ),
        .executableTarget(
            name: "SharpGlassApp",
            dependencies: ["SharpGlass"],
            path: "Sources/Main"
        ),
        .testTarget(
            name: "SharpGlassTests",
            dependencies: ["SharpGlass"],
            path: "Tests/SharpGlassTests"
        )
    ]
)
