//
//  LiveGiftShowView.swift
//  LiveSendGiftSwift
//
//  一个弹幕效果视图。
//

import UIKit

public let kLiveGiftViewWidth: CGFloat = 240.0  // 背景宽
public let kLiveGiftViewHeight: CGFloat = 44.0  // 背景高

@objc(SwiftLiveGiftShowView)
public final class LiveGiftShowView: UIView {

    private static let nameLabelFont: CGFloat = 12.0
    private static let giftLabelFont: CGFloat = 10.0
    private static let giftNumberWidth: CGFloat = 15.0

    /// 超时移除时长（秒）
    public var timeOut: Int = 3
    /// 移除动画时长
    public var removeAnimationTime: TimeInterval = 0.5
    /// 数字改变动画时长
    public var numberAnimationTime: TimeInterval = 0.25

    /// 视图创建时间，用于替换旧的视图
    public internal(set) var createDate = Date()
    /// 用于容器判断是第几个轨道
    var index: Int = 0

    /// 消失模式
    var hiddenMode: LiveGiftHiddenMode = .right
    /// 网络图片加载器，nil 时使用默认 URLSession 加载器；须在 model 之前赋值
    var imageLoader: LiveGiftWebImageLoader?

    /// 是否正处于动画，用于上下视图交换位置时使用
    var isAnimating = false
    /// 是否正处于飞出动画，飞出中不参与轨道交换
    var isLeavingAnimation = false
    /// 是否正处于出现动画，用于和交换位置的动画冲突处理
    var isAppearAnimation = false

    /// 超时移除回调
    var onTimeOut: ((LiveGiftShowView) -> Void)?

    public let numberView = LiveGiftNumberView()

    /// 数据源
    public var model: LiveGiftShowModel? {
        didSet {
            guard let model else { return }
            nameLabel.text = model.user.name
            sendLabel.text = model.gift.rewardMsg

            let iconPlaceholder = liveGiftImage("LiveDefaultIcon")
            let loader = imageLoader ?? LiveGiftDefaultWebImageLoader.load
            loader(iconIV, model.user.iconUrl, iconPlaceholder)
            loader(giftIV, model.gift.picUrl, nil)
        }
    }

    private let backIV = UIImageView()
    private let iconIV = UIImageView()
    private let nameLabel = UILabel()
    private let sendLabel = UILabel()
    private let giftIV = UIImageView()

    private var liveTimer: Timer?
    private var liveTimerSeconds = 0
    private var isNumberSet = false
    /// 上次数字位数，位数不变时跳过约束更新
    private var lastNumberLength = 0
    /// 礼物图右边距，随数字位数调整
    private var giftIVRightConstraint: NSLayoutConstraint!

    // MARK: - 初始化

    public override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: kLiveGiftViewWidth, height: kLiveGiftViewHeight))
        setupContentConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContentConstraints()
    }

    deinit {
        stopTimer()
    }

    // MARK: - 计数

    /// 重置定时器和计数
    public func resetTimeAndNumber(from number: Int) {
        numberView.resetNumber(number)
        addGiftNumber(from: number)
    }

    /// 礼物数量自增 1
    public func addGiftNumber(from number: Int) {
        if !isNumberSet {
            numberView.resetNumber(number)
            isNumberSet = true
        }
        let num = numberView.increaseNumber()
        numberView.changeNumber(num)
        handleNumber(num)
        model?.currentNumber = num
        createDate = Date()
    }

    /// 设置任意数字
    public func changeGiftNumber(_ number: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.numberView.changeNumber(number)
            self?.handleNumber(number)
        }
    }

    /// 获取用户名
    public var userName: String? {
        return nameLabel.text
    }

    // MARK: - Private

    /// 处理显示数字，重置消失倒计时并播放缩放动画
    private func handleNumber(_ number: Int) {
        liveTimerSeconds = 0

        // 位数没变时无需更新约束，连击场景下减少布局开销
        let length = String(number).count
        if length != lastNumberLength {
            lastNumberLength = length
            let giftRight = length >= 4
                ? Self.giftNumberWidth * 5
                : CGFloat(length) * Self.giftNumberWidth + Self.giftNumberWidth
            giftIVRightConstraint.constant = -Self.giftNumberWidth - giftRight
        }

        if numberView.transform != .identity {
            numberView.layer.removeAllAnimations()
        }
        numberView.transform = .identity
        UIView.animate(withDuration: numberAnimationTime, animations: {
            self.numberView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: { _ in
            self.numberView.transform = .identity
        })

        startTimerIfNeeded()
    }

    private func startTimerIfNeeded() {
        guard liveTimer == nil else { return }
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.liveTimerRunning()
        }
        RunLoop.current.add(timer, forMode: .common)
        liveTimer = timer
    }

    private func liveTimerRunning() {
        guard superview != nil else {
            stopTimer()
            return
        }

        liveTimerSeconds += 1
        guard liveTimerSeconds > timeOut else { return }

        if isAnimating {
            isAnimating = false
            return
        }
        isAnimating = true
        isLeavingAnimation = true

        // 用 window 宽度计算飞出距离，iPad 分屏等非全屏场景下 mainScreen 宽度会偏大
        var xChanged = window.map { $0.bounds.width } ?? UIScreen.main.bounds.width
        if hiddenMode == .left {
            xChanged = -xChanged
        }

        if hiddenMode == .none {
            isLeavingAnimation = false
            onTimeOut?(self)
            removeFromSuperview()
        } else {
            UIView.animate(withDuration: removeAnimationTime, delay: 0, options: .curveEaseIn, animations: {
                self.transform = self.transform.translatedBy(x: xChanged, y: 0)
            }, completion: { _ in
                self.isLeavingAnimation = false
                self.onTimeOut?(self)
                self.removeFromSuperview()
            })
        }

        stopTimer()
    }

    private func stopTimer() {
        liveTimer?.invalidate()
        liveTimer = nil
    }

    private func setupContentConstraints() {
        backIV.image = liveGiftImage("w_liveGiftBack")
        iconIV.image = liveGiftImage("LiveDefaultIcon")
        iconIV.layer.cornerRadius = 15
        iconIV.layer.masksToBounds = true
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: Self.nameLabelFont)
        sendLabel.textColor = .orange
        sendLabel.font = .systemFont(ofSize: Self.giftLabelFont)

        for view in [backIV, iconIV, nameLabel, sendLabel, giftIV, numberView] as [UIView] {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }

        // 礼物图靠左约束低优先级，右边距（随数字位数变化）优先
        let giftLeft = giftIV.leftAnchor.constraint(equalTo: nameLabel.rightAnchor, constant: 5)
        giftLeft.priority = .defaultHigh
        giftIVRightConstraint = giftIV.rightAnchor.constraint(equalTo: rightAnchor, constant: -Self.giftNumberWidth * 2 - 1)

        NSLayoutConstraint.activate([
            backIV.topAnchor.constraint(equalTo: topAnchor),
            backIV.bottomAnchor.constraint(equalTo: bottomAnchor),
            backIV.leftAnchor.constraint(equalTo: leftAnchor),
            backIV.rightAnchor.constraint(equalTo: rightAnchor),

            iconIV.leftAnchor.constraint(equalTo: leftAnchor, constant: 6),
            iconIV.widthAnchor.constraint(equalToConstant: 30),
            iconIV.heightAnchor.constraint(equalToConstant: 30),
            iconIV.centerYAnchor.constraint(equalTo: centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 9),
            nameLabel.leftAnchor.constraint(equalTo: iconIV.rightAnchor, constant: 6),
            nameLabel.widthAnchor.constraint(equalToConstant: 86),

            sendLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -9),
            sendLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),

            giftLeft,
            giftIVRightConstraint,
            giftIV.widthAnchor.constraint(equalToConstant: 32),
            giftIV.heightAnchor.constraint(equalToConstant: 24),
            giftIV.centerYAnchor.constraint(equalTo: centerYAnchor),

            numberView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Self.giftNumberWidth),
            numberView.centerYAnchor.constraint(equalTo: centerYAnchor),
            numberView.heightAnchor.constraint(equalTo: heightAnchor),
        ])
    }
}
