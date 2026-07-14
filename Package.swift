// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LiveSendGift",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "LiveSendGift", targets: ["LiveSendGift"])
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
                .process("LiveSendGiftAssets.xcassets")
            ],
            publicHeadersPath: "."
        )
    ]
)
