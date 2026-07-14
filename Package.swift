// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LiveSendGift",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // ObjC 版（V2.x 起维护模式）
        .library(name: "LiveSendGift", targets: ["LiveSendGift"]),
        // Swift 版（推荐新项目使用，零三方依赖）
        .library(name: "LiveSendGiftSwift", targets: ["LiveSendGiftSwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "LiveSendGift",
            dependencies: [
                .product(name: "SDWebImage", package: "SDWebImage")
            ],
            path: "LiveSendGift/LiveGiftShowView",
            resources: [
                .process("LiveSendGiftAssets.xcassets"),
                .copy("PrivacyInfo.xcprivacy")
            ],
            publicHeadersPath: "."
        ),
        .target(
            name: "LiveSendGiftSwift",
            path: "Sources/LiveSendGiftSwift",
            resources: [
                .process("LiveSendGiftAssets.xcassets"),
                .copy("PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "LiveSendGiftSwiftTests",
            dependencies: ["LiveSendGiftSwift"],
            path: "Tests/LiveSendGiftSwiftTests"
        )
    ]
)
