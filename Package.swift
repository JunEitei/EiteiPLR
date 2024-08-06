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
        .package(url: "https://github.com/SnapKit/SnapKit", .upToNextMajor(from: "5.7.1")),
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.9.1")),
        .package(url: "https://github.com/ashleymills/Reachability.swift", .upToNextMajor(from: "5.2.3")),
        .package(url: "https://github.com/relatedcode/ProgressHUD", .upToNextMajor(from: "14.1.3"))
    ],
    targets: [
        .target(
            name: "EiteiPLR",
            dependencies: [
                "SnapKit","Alamofire","Reachability","ProgressHUD"
            ],
            path: "Sources/EiteiPLR",
            resources: [
                .copy("Resource")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
