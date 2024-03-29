// swift-tools-version:5.0

import PackageDescription

#if os(Windows)

let package = Package(
    name: "Gzip",
    products: [
        .library(name: "Gzip", targets: ["Gzip"]),
    ],
    dependencies: [
        .package(url: "https://github.com/KittyMac/SWCompression.git", from: "4.8.5")
    ],
    targets: [
        .target(name: "Gzip", dependencies: ["SWCompression"]),
        .testTarget(name: "GzipTests", dependencies: ["Gzip"]),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)

#else

let package = Package(
    name: "Gzip",
    products: [
        .library(name: "Gzip", targets: ["Gzip"]),
    ],
    targets: [
        .target(name: "Gzip", dependencies: ["system-zlib"]),
        .target(name: "system-zlib"),
        .testTarget(name: "GzipTests", dependencies: ["Gzip"]),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)

#endif

