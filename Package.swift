// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SalmaSDK",
    defaultLocalization: "ar",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "SalmaSDK",
            targets: ["SalmaSDK"]
        ),
    ],
    targets: [
        .target(
            name: "SalmaSDK",
            dependencies: [],
            path: "SalmaAI",
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
