// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "ac-library-swift",
    products: [
        .library(
            name: "ac-library-swift",
            targets: [

            ])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "atcoder",
            dependencies: []),
        .target(name: "DSU"),
    ]
)
