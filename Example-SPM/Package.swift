// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Example-SPM",
    defaultLocalization: "en", // 设置一个默认的本地化标识符，比如 "en" 表示英语

    platforms: [
        .iOS(.v14),
        .macOS(.v10_15),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Example-SPM",
            targets: ["Example-SPM"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(path: "../"),  // Adjust the relative path to EiteiQR
    ],
    targets: [
        .target(
            name: "Example-SPM",
            dependencies: ["EiteiPLR"], path: "Example-SPM")
    ]
)
