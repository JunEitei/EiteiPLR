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
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.7.1")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1")),
        .package(url: "https://github.com/ashleymills/Reachability.swift.git", .upToNextMajor(from: "5.2.1"))

    ],
    targets: [
        .target(
            name: "EiteiPLR",
            dependencies: [
                "SnapKit","Alamofire","ReachabilitySwift"
            ],
            path: "Sources/EiteiPLR",
            resources: [
                .copy("Resource")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
