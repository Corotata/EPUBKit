// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "EPUBKit",
    
    platforms: [
        .macOS("10.14"),
        .iOS("17.0"),
        .tvOS("17.0")
    ],
    
    products: [
        .library(name: "EPUBKit", targets: ["EPUBKit"]),
    ],
    
    dependencies: [
        // 固定已验证版本，避免 AEXML 后续更新意外提高最低系统要求。
        .package(
            url: "https://github.com/tadija/AEXML",
            .exact("4.7.3")
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
