// swift-tools-version:5.0

import PackageDescription

#if os(Windows)
let productsTarget: [PackageDescription.Target] = [
    .target(name: "Gzip", dependencies: ["windows-zlib"]),
    .target(name: "windows-zlib"),
]
#else
let productsTarget: [PackageDescription.Target] = [
    .target(name: "Gzip", dependencies: ["system-zlib"]),
    .target(name: "system-zlib"),
]
#endif

let package = Package(
    name: "Gzip",
    products: [
        .library(name: "Gzip", targets: ["Gzip"]),
    ],
    targets: productsTarget + [
        .testTarget(name: "GzipTests", dependencies: ["Gzip"]),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)
