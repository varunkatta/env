// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ClaudeUsageMenu",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "ClaudeUsageMenu", targets: ["ClaudeUsageMenu"]),
    ],
    targets: [
        .executableTarget(name: "ClaudeUsageMenu"),
    ]
)
