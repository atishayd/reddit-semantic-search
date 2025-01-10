// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RSS",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "RSS", targets: ["RSS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nalexn/ViewInspector", from: "0.9.0"),
    ],
    targets: [
        .target(name: "RSS"),
        .testTarget(
            name: "RSSTests",
            dependencies: [
                "RSS",
                "ViewInspector"
            ]
        ),
    ]
) 