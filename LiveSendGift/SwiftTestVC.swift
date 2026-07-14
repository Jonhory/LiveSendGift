//
//  SwiftTestVC.swift
//  LiveSendGift
//
//  Swift 版（LiveSendGiftSwift）演示页，与 ObjC 版 TestVC 的队列模式对照。
//

import UIKit

@objc(SwiftTestVC)
public final class SwiftTestVC: UIViewController {

    private static let buttonTag = 300

    private lazy var giftShow: LiveGiftShowCustom = {
        // 全面屏适配：首条弹幕位于安全区（含导航栏）下方 10pt
        let show = LiveGiftShowCustom.add(to: view, y: view.safeAreaInsets.top + 10)
        show.addMode = .queue
        show.maxRailwayCount = 3
        show.showMode = .fromTopToBottom
        show.appearMode = .left
        show.hiddenMode = .left
        show.interfaceDebugEnabled = true
        show.onGiftRemoved = { model in
            print("[SwiftDemo] 用户：\(model.user.name ?? "") 送出了 \(model.currentNumber) 个 \(model.gift.name ?? "")")
        }
        return show
    }()

    private let users: [LiveGiftUser] = ["first", "second", "third", "fourth", "fifth"].enumerated().map {
        LiveGiftUser(
            userId: "\(2001 + $0.offset)", name: $0.element,
            iconUrl: "https://raw.githubusercontent.com/Jonhory/LiveSendGift/main/DemoAssets/avatar.jpg")
    }

    private let gifts: [LiveGiftItem] = [
        LiveGiftItem(
            type: "0", name: "松果", picUrl: "https://raw.githubusercontent.com/Jonhory/LiveSendGift/main/DemoAssets/gift_pinecone.jpg",
            rewardMsg: "扔出一颗松果"),
        LiveGiftItem(
            type: "1", name: "花束", picUrl: "https://raw.githubusercontent.com/Jonhory/LiveSendGift/main/DemoAssets/gift_flower.jpg",
            rewardMsg: "献上一束花"),
        LiveGiftItem(
            type: "2", name: "果汁", picUrl: "https://raw.githubusercontent.com/Jonhory/LiveSendGift/main/DemoAssets/gift_juice.jpg",
            rewardMsg: "递上果汁"),
        LiveGiftItem(
            type: "3", name: "棒棒糖", picUrl: "https://raw.githubusercontent.com/Jonhory/LiveSendGift/main/DemoAssets/gift_lollipop.jpg",
            rewardMsg: "递上棒棒糖"),
        LiveGiftItem(type: "4", name: "泡泡糖", picUrl: "", rewardMsg: "一起吃泡泡糖吧"),
    ]

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 237 / 255.0, green: 237 / 255.0, blue: 237 / 255.0, alpha: 1)

        let titles = ["first", "second", "third", "fourth", "fifth"]
        let buttonWidth = (view.bounds.width - 40) / CGFloat(titles.count)
        for (i, title) in titles.enumerated() {
            let button = makeButton(title: title, tag: Self.buttonTag + i)
            button.frame = CGRect(x: 20 + CGFloat(i) * buttonWidth, y: 400, width: buttonWidth, height: 40)
        }

        let batchButton = makeButton(title: "同时添加多条", tag: Self.buttonTag + 5)
        batchButton.frame = CGRect(x: 0, y: 0, width: (view.bounds.width - 40) / 3, height: 40)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 全面屏适配：底部按钮避开安全区
        if let batchButton = view.viewWithTag(Self.buttonTag + 5) {
            batchButton.center = CGPoint(
                x: view.bounds.width / 2,
                y: view.bounds.height - view.safeAreaInsets.bottom - 60)
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sendMultipleGifts()
    }

    @objc private func buttonTapped(_ button: UIButton) {
        let index = button.tag - Self.buttonTag
        switch index {
        case 0:
            // 连击动画到指定数字
            let model = LiveGiftShowModel(gift: gifts[0], user: users[0])
            model.toNumber = 8
            model.interval = 0.15
            giftShow.animate(with: model)
        case 1:
            // 普通 +1
            giftShow.add(LiveGiftShowModel(gift: gifts[1], user: users[1]))
        case 2:
            // 直接显示指定数字
            giftShow.add(LiveGiftShowModel(gift: gifts[2], user: users[2]), showNumber: 99)
        case 3, 4:
            let model = LiveGiftShowModel(gift: gifts[index], user: users[index])
            model.toNumber = index == 3 ? 3 : 2
            giftShow.animate(with: model)
        default:
            sendMultipleGifts()
        }
    }

    private func sendMultipleGifts() {
        for i in 0..<5 {
            let model = LiveGiftShowModel(gift: gifts[i], user: users[0])
            model.toNumber = 10
            model.interval = 0.15
            giftShow.animate(with: model)
        }
    }

    private func makeButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hue: .random(in: 0...1), saturation: 0.75, brightness: 0.75, alpha: 1)
        button.tag = tag
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        view.addSubview(button)
        return button
    }
}
