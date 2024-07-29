// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Watchface",
    products: [
        .library(
            name: "Watchface",
            targets: ["Watchface"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/marmelroy/Zip", from: "2.1.2"),
        // for generating public memberwise init by `swift run -c release swift-mod`
//        .package(id: "https://github.com/ra1028/swift-mod.git", exact: "0.0.6"),
        .package(url: "https://github.com/ra1028/swift-mod", revision: "0.0.6"),
        // use revision instead of `from` to allow unstable dependency ref from swift-mod to swift-syntax
    ],
    targets: [
        .target(
            name: "Watchface",
            dependencies: ["Zip"],
            path: "Watchface"
        ),
        .testTarget(
            name: "WatchFaceTests",
            dependencies: ["Watchface"],
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
