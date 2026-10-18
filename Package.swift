// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "EPUBKit",
    
    platforms: [
        .macOS(.v10_10),
        .iOS(.v9),
        .tvOS(.v9)
    ],
    
    products: [
        .library(name: "EPUBKit", targets: ["EPUBKit"]),
    ],
    
    dependencies: [
        // AEXML 4.7.x 提高了最低系统版本；保持 EPUBKit 当前平台兼容范围。
        .package(
            url: "https://github.com/tadija/AEXML",
            .exact("4.6.0")
        ),
        .package(
            url: "https://github.com/marmelroy/Zip",
            from: "2.1.1"
        )
    ],
    
    targets: [
        .target(
            name: "EPUBKit",
            dependencies: ["AEXML", "Zip"]
        ),
        .testTarget(
            name: "EPUBKitTests",
            dependencies: ["EPUBKit"],
            resources: [.copy("Resources")]
        )
    ]
)
