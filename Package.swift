// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "ac-library-swift",
    products: [
        .library(
            name: "ac-library-swift",
            targets: [
                "Atcoder",
            ])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Atcoder",
            dependencies: [

            ]),
        .target(name: "DSU"),
        .target(name: "FenwickTree"),
        .target(name: "LazySegmentTree"),
        .target(name: "Math"),
        .target(name: "MaxFlow"),
        .target(name: "SCC"),
        .target(name: "SegmentTree"),
        .target(name: "String"),
        .target(name: "TwoSAT"),
    ]
)
