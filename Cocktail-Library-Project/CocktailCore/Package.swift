// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CocktailCore",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CocktailCore",
            targets: ["CocktailCore"]
        )
    ],
    targets: [
        .target(
            name: "CocktailCore",
            path: "Sources/CocktailCore",
            resources: [
                .process("Data")
            ]
        ),
        .testTarget(
            name: "CocktailCoreTests",
            dependencies: ["CocktailCore"],
            path: "Tests"
        )
    ]
)
