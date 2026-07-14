//
//  LiveSendGiftSwiftTests.swift
//  LiveSendGiftSwiftTests
//
//  与 ObjC 版单元测试一一对应，保证 Swift 移植后核心行为一致。
//

import XCTest
@testable import LiveSendGiftSwift

final class LiveSendGiftSwiftTests: XCTestCase {

    private var hostView: UIView!
    private var giftShow: LiveGiftShowCustom!

    override func setUp() {
        super.setUp()
        hostView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        giftShow = LiveGiftShowCustom.add(to: hostView, y: 0)
    }

    private func makeModel(userId: String, name: String, giftType: String) -> LiveGiftShowModel {
        let user = LiveGiftUser(userId: userId, name: name)
        let gift = LiveGiftItem(type: giftType, name: "测试礼物")
        return LiveGiftShowModel(gift: gift, user: user)
    }

    private var visibleBanners: [LiveGiftShowView] {
        giftShow.subviews.compactMap { $0 as? LiveGiftShowView }
    }

    /// 数字视图：显式自增语义必须稳定
    func testNumberViewIncrease() {
        let numberView = LiveGiftNumberView()
        numberView.resetNumber(5)
        XCTAssertEqual(numberView.increaseNumber(), 5, "重置后首次自增应返回起点值")
        XCTAssertEqual(numberView.increaseNumber(), 6)
        XCTAssertEqual(numberView.currentNumber, 6, "currentNumber 应为最后一次自增返回的值")
        numberView.resetNumber(1)
        XCTAssertEqual(numberView.increaseNumber(), 1, "重置后计数应重新开始")
    }

    /// 同名用户必须靠 userId 区分，不能被合并成一条弹幕
    func testSameNameDifferentUserIdCreatesTwoBanners() {
        giftShow.add(makeModel(userId: "1001", name: "小明", giftType: "0"))
        giftShow.add(makeModel(userId: "1002", name: "小明", giftType: "0"))
        XCTAssertEqual(visibleBanners.count, 2, "同名不同 userId 应产生两条弹幕")
    }

    /// 同一用户同一礼物应合并为一条弹幕并计数
    func testSameUserSameGiftMergesIntoOneBanner() {
        giftShow.add(makeModel(userId: "1001", name: "小明", giftType: "0"))
        giftShow.add(makeModel(userId: "1001", name: "小明", giftType: "0"))
        XCTAssertEqual(visibleBanners.count, 1)
        XCTAssertEqual(visibleBanners.first?.numberView.currentNumber, 2, "两次添加应计数到 2")
    }

    /// 轨道数量上限 + 队列模式下同 key 等待模型合并
    func testMaxRailwayCountCapAndQueueMerge() {
        giftShow.addMode = .queue
        giftShow.maxRailwayCount = 2

        giftShow.add(makeModel(userId: "1", name: "a", giftType: "0"))
        giftShow.add(makeModel(userId: "2", name: "b", giftType: "0"))
        XCTAssertEqual(visibleBanners.count, 2, "最多显示 maxRailwayCount 条")

        giftShow.add(makeModel(userId: "3", name: "c", giftType: "0"))
        XCTAssertEqual(visibleBanners.count, 2)
        XCTAssertEqual(giftShow.waitQueue.count, 1, "超出上限的弹幕应进入等待队列")

        giftShow.add(makeModel(userId: "3", name: "c", giftType: "0"))
        XCTAssertEqual(giftShow.waitQueue.count, 1, "同 key 等待模型应合并")
        XCTAssertEqual(giftShow.waitQueue.first?.toNumber, 2, "合并后 toNumber 应累加")
    }

    /// 注入自定义图片加载器后，头像与礼物图都应走注入的加载器
    func testInjectedImageLoaderIsUsed() {
        var loadedUrls: [String] = []
        giftShow.webImageLoader = { imageView, urlString, placeholder in
            loadedUrls.append(urlString ?? "<nil>")
            imageView.image = placeholder
        }

        let model = makeModel(userId: "1001", name: "小明", giftType: "0")
        model.user.iconUrl = "https://example.com/icon.png"
        model.gift.picUrl = "https://example.com/gift.png"
        giftShow.add(model)

        XCTAssertEqual(loadedUrls.count, 2, "头像和礼物图都应通过注入的加载器加载")
        XCTAssertTrue(loadedUrls.contains("https://example.com/icon.png"))
        XCTAssertTrue(loadedUrls.contains("https://example.com/gift.png"))
    }

    /// 公开 API 从后台线程调用不应崩溃，且弹幕最终正常上屏
    func testBackgroundThreadAddIsSafe() {
        let exp = expectation(description: "background add")
        let model = makeModel(userId: "1001", name: "小明", giftType: "0")
        DispatchQueue.global().async {
            self.giftShow.add(model)
            DispatchQueue.main.async {
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 2)
        XCTAssertEqual(visibleBanners.count, 1, "后台线程调用应自动转主队列并正常上屏")
    }

    /// 同 key 并发连击应合并进已有定时器，而不是叠加多个定时器导致数字失控（ObjC 版 issue #17）
    func testAnimatedTimerMergeForSameKey() {
        // toNumber 拉长到 20，保证第二发连击到来时首个定时器仍在存活期（20 ticks × 0.05s ≈ 1s）
        let first = makeModel(userId: "1001", name: "小明", giftType: "0")
        first.toNumber = 20
        first.interval = 0.05
        giftShow.animate(with: first)

        // 等首个 tick 上屏，弹幕视图建立
        let shown = expectation(description: "first tick")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { shown.fulfill() }
        wait(for: [shown], timeout: 2)
        XCTAssertEqual(visibleBanners.count, 1)
        XCTAssertNotNil(first.animatedTimer, "首个连击定时器应仍在运行")

        // 同 key 第二次连击：应合并进 first 的定时器
        let second = makeModel(userId: "1001", name: "小明", giftType: "0")
        second.toNumber = 5
        second.interval = 0.05
        giftShow.animate(with: second)

        XCTAssertEqual(first.toNumber, 25, "同 key 连击应合并 toNumber")
        XCTAssertNil(second.animatedTimer, "不应为第二个模型开新定时器")

        // 等定时器跑完：最终计数应恰好为 25，且定时器已释放（不会"停不下来"）
        let finished = expectation(description: "timer finished")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { finished.fulfill() }
        wait(for: [finished], timeout: 5)

        XCTAssertNil(first.animatedTimer, "连击结束后定时器应释放")
        XCTAssertEqual(visibleBanners.first?.numberView.currentNumber, 25, "最终计数应恰好等于合并后的 toNumber")
    }
}
