//
//  LiveGiftModels.swift
//  LiveSendGiftSwift
//
//  按 LiveSendGift（ObjC V2.0）逻辑移植的 Swift 版本。
//

import UIKit

/// 弹幕展现模式
public enum LiveGiftShowMode {
    /// 自上而下
    case fromTopToBottom
    /// 自下而上
    case fromBottomToTop
}

/// 弹幕消失模式
public enum LiveGiftHiddenMode {
    /// 向右移出
    case right
    /// 向左移出
    case left
    /// 无动画直接消失
    case none
}

/// 弹幕出现模式
public enum LiveGiftAppearMode {
    /// 无效果
    case none
    /// 从左到右出现（左进）
    case left
}

/// 弹幕添加模式（当弹幕达到最大数量后新增弹幕时）
public enum LiveGiftAddMode {
    /// 当有新弹幕时会替换最早的弹幕
    case replace
    /// 当有新弹幕时会进入等待队列
    case queue
}

/// 送礼用户
public final class LiveGiftUser {
    /// 用户唯一标识，用于区分弹幕归属；不传则退化为用 name 区分（同名用户会被合并）
    public var userId: String?
    public var name: String?
    public var iconUrl: String?

    public init(userId: String? = nil, name: String? = nil, iconUrl: String? = nil) {
        self.userId = userId
        self.name = name
        self.iconUrl = iconUrl
    }
}

/// 礼物信息
public final class LiveGiftItem {
    /// 礼物类型
    public var type: String?
    /// 礼物的名称
    public var name: String?
    /// 右侧礼物图片 url
    public var picUrl: String?
    /// 礼物配置的语句
    public var rewardMsg: String?

    public init(type: String? = nil, name: String? = nil, picUrl: String? = nil, rewardMsg: String? = nil) {
        self.type = type
        self.name = name
        self.picUrl = picUrl
        self.rewardMsg = rewardMsg
    }
}

/// 一次送礼展示的数据模型（包含用户信息和礼物信息）
public final class LiveGiftShowModel {
    public var gift: LiveGiftItem
    public var user: LiveGiftUser

    /// 当前送礼数量
    public var currentNumber: Int = 0

    // 连续动画时使用
    /// 连续增加的数量
    public var toNumber: Int = 1
    /// 连续增加时动画间隔
    public var interval: TimeInterval = 0.35
    /// 连击定时器（运行中非 nil；结束后置 nil，供同 key 合并判断）
    public internal(set) var animatedTimer: DispatchSourceTimer?

    public init(gift: LiveGiftItem, user: LiveGiftUser) {
        self.gift = gift
        self.user = user
    }
}
