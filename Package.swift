// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EiteiPLR",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "EiteiPLR",
            targets: ["EiteiPLR"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1"))
    ],
    targets: [
        .target(
            name: "EiteiPLR",
            dependencies: [
                "SnapKit"
            ],
            path: "Sources/EiteiPLR",
            resources: [
                .copy("Resource")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
