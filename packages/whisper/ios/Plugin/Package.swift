// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorMlkitWhisper",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "CapacitorMlkitWhisper",
            targets: ["WhisperPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0"),
        .package(url: "https://github.com/ggml-org/whisper.spm.git", from: "1.5.4")
    ],
    targets: [
        .target(
            name: "WhisperPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                .product(name: "whisper", package: "whisper.spm")
            ],
            path: ".",
            sources: ["WhisperPlugin.swift", "Whisper.swift"],
            cSettings: [
                .define("WHISPER_USE_COREML", to: "1"),
                .define("WHISPER_COREML", to: "1")
            ],
            swiftSettings: [
                .define("WHISPER_USE_COREML"),
                .define("WHISPER_COREML")
            ]
        )
    ]
)