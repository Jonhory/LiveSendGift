//
//  LiveGiftShowCustom.swift
//  LiveSendGiftSwift
//
//  管理所有弹幕的容器视图。
//  行为与 ObjC 版 LiveGiftShowCustom（V2.0）保持一致：
//  实例级配置、线程安全、userId 区分用户、同 key 连击定时器合并。
//

import UIKit

@objc(SwiftLiveGiftShowCustom)
public final class LiveGiftShowCustom: UIView {

    /// 两个弹幕之间的高度差
    static let giftViewMargin: CGFloat = 50.0

    // MARK: - 配置（实例属性，多实例互不影响）

    /// 交换动画时长
    public var exchangeAnimationTime: TimeInterval = 0.25
    /// 出现时动画时长
    public var appearAnimationTime: TimeInterval = 0.5
    /// 弹幕添加模式，默认替换
    public var addMode: LiveGiftAddMode = .replace
    /// 最大礼物轨道数量，默认 3
    public var maxRailwayCount: Int = 3 {
        didSet {
            heightConstraint?.constant =
                (kLiveGiftViewHeight + Self.giftViewMargin) * CGFloat(maxRailwayCount - 1) + kLiveGiftViewHeight
        }
    }
    /// 轨道能否进行交换动画，默认 true
    public var railwayCanExchange = true
    /// 弹幕展现模式，默认自上而下
    public var showMode: LiveGiftShowMode = .fromTopToBottom
    /// 弹幕消失模式，默认向右移出
    public var hiddenMode: LiveGiftHiddenMode = .right
    /// 弹幕出现模式，默认从左出现
    public var appearMode: LiveGiftAppearMode = .left
    /// 是否打印调试信息，默认 false
    public var interfaceDebugEnabled = false

    /// 网络图片加载器。默认 nil：使用内置的 URLSession 加载器。
    /// 使用 Kingfisher/SDWebImage/自研加载器的宿主可注入此 block。
    public var webImageLoader: LiveGiftWebImageLoader?

    /// 弹幕被移除时的回调
    public var onGiftRemoved: ((LiveGiftShowModel) -> Void)?

    // MARK: - 内部状态

    /// 轨道槽位，nil 表示该轨道已空（原 ObjC 版的 kGiftViewRemoved 占位）
    private(set) var slots: [LiveGiftShowView?] = []
    /// key（userId/name + 礼物类型) -> 正在展示的弹幕
    private(set) var showViewDict: [String: LiveGiftShowView] = [:]
    /// 待展示礼物队列
    private(set) var waitQueue: [LiveGiftShowModel] = []

    private var heightConstraint: NSLayoutConstraint?

    // MARK: - 初始化

    /// 添加到宿主视图。y 的设定应注意最大礼物数量时不要超出屏幕边界，
    /// 建议按安全区计算（如 `view.safeAreaInsets.top + 10`）。
    @discardableResult
    public static func add(to superView: UIView, y: CGFloat = 100) -> LiveGiftShowCustom {
        let v = LiveGiftShowCustom()
        v.isUserInteractionEnabled = false
        v.backgroundColor = .clear
        superView.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        let height = v.heightAnchor.constraint(
            equalToConstant: (kLiveGiftViewHeight + giftViewMargin) * CGFloat(v.maxRailwayCount - 1)
                + kLiveGiftViewHeight)
        v.heightConstraint = height
        NSLayoutConstraint.activate([
            v.widthAnchor.constraint(equalToConstant: kLiveGiftViewWidth),
            height,
            v.leftAnchor.constraint(equalTo: superView.leftAnchor),
            v.topAnchor.constraint(equalTo: superView.topAnchor, constant: y),
        ])
        return v
    }

    // MARK: - 公开 API（线程安全：非主线程调用自动转主队列）

    /// 增加或者更新一个礼物弹幕。
    /// - Parameters:
    ///   - showModel: 礼物模型
    ///   - showNumber: 大于 0 时直接显示该数字，否则从 1 开始自增
    public func add(_ showModel: LiveGiftShowModel, showNumber: Int = 0) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.add(showModel, showNumber: showNumber) }
            return
        }

        let key = dictKey(showModel)
        let isResetNumber = showNumber > 0

        // 已有同 key 弹幕：更新计数
        if let oldView = showViewDict[key] {
            if isResetNumber {
                oldView.resetTimeAndNumber(from: showNumber)
            } else {
                oldView.addGiftNumber(from: 1)
            }
            if railwayCanExchange {
                compactAndSort()
                resetY()
            }
            return
        }

        // 轨道已满且无空位
        if slots.count >= maxRailwayCount, !slots.contains(where: { $0 == nil }) {
            switch addMode {
            case .replace:
                // 替换创建时间最早的弹幕
                if let oldest = slots.compactMap({ $0 }).min(by: { $0.createDate < $1.createDate }) {
                    reset(oldest, with: showModel, isChangeNumber: isResetNumber, number: showNumber)
                }
            case .queue:
                if showNumber > 0 {
                    showModel.currentNumber = showNumber
                }
                addToQueue(showModel)
            }
            return
        }

        // 计算轨道与 Y 值
        let slotIndex = slots.firstIndex(where: { $0 == nil }) ?? slots.count
        var showViewY = CGFloat(slotIndex) * (kLiveGiftViewHeight + Self.giftViewMargin)
        if showMode == .fromBottomToTop {
            showViewY = -showViewY
        }
        var frame = CGRect(x: 0, y: showViewY, width: 0, height: 0)
        if appearMode == .left {
            // 用宿主视图宽度计算离屏起点，iPad 分屏等非全屏容器下 mainScreen 宽度会偏大
            let containerWidth = superview?.bounds.width ?? UIScreen.main.bounds.width
            frame.origin.x = -containerWidth
        }

        let newView = LiveGiftShowView(frame: frame)
        // imageLoader 须在 model 之前，didSet 内会触发图片加载
        newView.imageLoader = webImageLoader
        newView.model = showModel
        newView.hiddenMode = hiddenMode
        if isResetNumber {
            newView.resetTimeAndNumber(from: showNumber)
        } else {
            newView.addGiftNumber(from: 1)
        }
        appear(newView)

        // 超时移除
        newView.onTimeOut = { [weak self] view in
            guard let self else { return }
            if let model = view.model {
                self.onGiftRemoved?(model)
            }
            // 释放槽位（index 由排序逻辑维护，做防护避免状态不同步）
            if view.index >= 0, view.index < self.slots.count, self.slots[view.index] === view {
                self.slots[view.index] = nil
            } else if let realIndex = self.slots.firstIndex(where: { $0 === view }) {
                self.slots[realIndex] = nil
            }
            if let model = view.model {
                self.showViewDict.removeValue(forKey: self.dictKey(model))
            }
            self.debugLog("移除了第 \(view.index) 个，剩余 \(self.showViewDict.count) 条")

            if self.railwayCanExchange {
                self.compactAndSort()
                self.resetY()
            }
            switch self.addMode {
            case .queue:
                self.showWaitView()
            case .replace:
                if let timer = view.model?.animatedTimer {
                    timer.cancel()
                    view.model?.animatedTimer = nil
                }
            }
        }

        addSubview(newView)

        // 占用槽位
        if slotIndex < slots.count {
            newView.index = slotIndex
            slots[slotIndex] = newView
        } else {
            newView.index = slots.count
            slots.append(newView)
        }
        showViewDict[key] = newView
    }

    /// 添加一个礼物弹幕：若该礼物不在视图上，则播放从 1 增加到 toNumber 的连击效果；否则继续累加。
    public func animate(with showModel: LiveGiftShowModel) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.animate(with: showModel) }
            return
        }

        // 同一弹幕已有连击定时器在跑时，合并次数而不是再开一个定时器。
        // 多个并发定时器同时驱动同一个视图自增，是数字异常膨胀（ObjC 版 issue #17）的根源。
        let key = dictKey(showModel)
        if let showing = showViewDict[key], let runningModel = showing.model,
            runningModel.animatedTimer != nil, runningModel !== showModel
        {
            runningModel.toNumber += showModel.toNumber
            return
        }

        if addMode == .queue, showViewDict[key] == nil {
            let showCount = slots.compactMap { $0 }.count
            if showCount >= maxRailwayCount {
                addToQueue(showModel)
                return
            }
        }

        let timer = DispatchSource.makeTimerSource(queue: .main)
        // 容差取间隔的 10%，允许系统合并定时器唤醒，降低多弹幕连击时的瞬时 CPU
        timer.schedule(
            deadline: .now(),
            repeating: showModel.interval,
            leeway: .milliseconds(Int(showModel.interval * 100)))
        // 创建即持有，保证合并判断（animatedTimer != nil）在首个 tick 之前就生效
        showModel.animatedTimer = timer

        var tick = 0
        timer.setEventHandler { [weak self] in
            guard let self, self.superview != nil else {
                timer.cancel()
                showModel.animatedTimer = nil
                return
            }
            if tick < showModel.toNumber {
                tick += 1
                self.add(showModel)
            } else {
                timer.cancel()
                // 置 nil 让后续同 key 的连击能重新开定时器 / 队列合并逻辑能正确判断
                showModel.animatedTimer = nil
            }
        }
        timer.resume()
    }

    // MARK: - Private

    /// 出现动画
    private func appear(_ view: LiveGiftShowView) {
        guard appearMode == .left else { return }
        view.isAppearAnimation = true
        UIView.animate(
            withDuration: appearAnimationTime,
            animations: {
                var f = view.frame
                f.origin.x = 0
                view.frame = f
            },
            completion: { _ in
                view.isAppearAnimation = false
            })
    }

    /// 空槽位补位 + 按当前计数降序排序
    private func compactAndSort() {
        // 空槽位由后续未在飞出的弹幕补位
        for p in 0..<slots.count where slots[p] == nil {
            for j in (p + 1)..<slots.count {
                if let view = slots[j], !view.isLeavingAnimation {
                    view.index = p
                    slots.swapAt(p, j)
                    break
                }
            }
        }
        // 计数大的弹幕排在上面
        for i in 0..<slots.count {
            for j in i..<slots.count {
                guard let viewI = slots[i], let viewJ = slots[j],
                    viewI.numberView.currentNumber < viewJ.numberView.currentNumber
                else { continue }
                viewI.index = j
                viewI.isAnimating = true
                viewJ.index = i
                viewJ.isAnimating = true
                slots.swapAt(i, j)
            }
        }
    }

    /// 排序后调整各弹幕的 Y 值
    private func resetY() {
        for (i, slot) in slots.enumerated() {
            guard let show = slot else { continue }
            var showY = CGFloat(i) * (kLiveGiftViewHeight + Self.giftViewMargin)
            if showMode == .fromBottomToTop {
                showY = -showY
            }
            guard show.frame.origin.y != showY, !show.isLeavingAnimation else { continue }
            // 避免出现动画和交换动画冲突
            if show.isAppearAnimation {
                show.layer.removeAllAnimations()
            }
            UIView.animate(withDuration: exchangeAnimationTime) {
                var f = show.frame
                f.origin.y = showY
                show.frame = f
            }
            show.isAnimating = true
            debugLog("\(show) 重置动画")
        }
    }

    /// 替换模式：复用最早的弹幕视图展示新模型
    private func reset(_ view: LiveGiftShowView, with model: LiveGiftShowModel, isChangeNumber: Bool, number: Int) {
        if let oldModel = view.model {
            showViewDict.removeValue(forKey: dictKey(oldModel))
            if let timer = oldModel.animatedTimer {
                timer.cancel()
                oldModel.animatedTimer = nil
            }
        }
        view.imageLoader = webImageLoader
        view.model = model
        view.resetTimeAndNumber(from: isChangeNumber ? number : 1)
        showViewDict[dictKey(model)] = view
    }

    /// 加入等待队列；同 key 且未在连击中的等待模型会被合并
    private func addToQueue(_ model: LiveGiftShowModel) {
        let key = dictKey(model)
        if let index = waitQueue.firstIndex(where: { dictKey($0) == key && $0.animatedTimer == nil }) {
            model.toNumber += waitQueue[index].toNumber
            waitQueue.remove(at: index)
        }
        waitQueue.append(model)
    }

    /// 展示等待队列中的下一条
    private func showWaitView() {
        let showCount = slots.compactMap { $0 }.count
        guard showCount < maxRailwayCount, let model = waitQueue.first else { return }
        waitQueue.removeFirst()
        if model.currentNumber > 0 {
            add(model, showNumber: model.currentNumber)
        } else {
            animate(with: model)
        }
    }

    /// 弹幕归属 key：优先 userId，避免同名用户被错误合并
    func dictKey(_ model: LiveGiftShowModel) -> String {
        let userKey: String
        if let userId = model.user.userId, !userId.isEmpty {
            userKey = userId
        } else {
            userKey = model.user.name ?? ""
        }
        return userKey + (model.gift.type ?? "")
    }

    private func debugLog(_ message: @autoclosure () -> String) {
        #if DEBUG
        if interfaceDebugEnabled {
            print("[LiveSendGiftSwift] \(message())")
        }
        #endif
    }
}
