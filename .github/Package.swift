// swift-tools-version:5.9
// Package.swift for GitHub Actions build support

import PackageDescription

let package = Package(
    name: "Granulay",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "Granulay",
            targets: ["Granulay"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/sparkle-project/Sparkle",
            from: "2.7.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "Granulay",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "Granulay",
            sources: [
                "GranulayApp.swift",
                "ContentView.swift",
                "GrainOverlayWindow.swift",
                "SettingsView.swift",
                "GrainEffect.swift",
                "MenuBarManager.swift",
                "UpdateManager.swift",
                "PerformanceOptimizer.swift",
                "LocalizationHelper.swift"
            ],
            resources: [
                .process("Assets.xcassets"),
                .process("en.lproj"),
                .process("pt-BR.lproj"),
                .process("Info.plist"),
                .process("Granulay.entitlements")
            ]
        )
    ]
)