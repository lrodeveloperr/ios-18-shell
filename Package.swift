// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "iOS18Shell",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .watchOS(.v11),
        .tvOS(.v18),
        .visionOS(.v2)
    ],
    products: [
        .library(name: "iOS18Shell", targets: ["iOS18Shell"])
    ],
    targets: [
        .target(name: "iOS18Shell"),
        .testTarget(name: "iOS18ShellTests", dependencies: ["iOS18Shell"])
    ]
)
