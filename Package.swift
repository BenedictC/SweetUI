// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
// import CompilerPluginSupport


let package = Package(
    name: "SweetUI",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SweetUI",
            targets: ["SweetUI"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
//        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
//        .macro(
//            name: "MacrosPlugin",
//            dependencies: [
//                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
//                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
//            ]
//        ),

        .target(
            name: "SweetUI",
            dependencies: [
//                "MacrosPlugin"
            ]
        ),

        .testTarget(
            name: "SweetUITests",
            dependencies: ["SweetUI"]
        ),
    ]
)
