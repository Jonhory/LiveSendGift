//
//  LiveGiftNumberView.swift
//  LiveSendGiftSwift
//
//  弹幕效果数字变化的视图（x 1234）。
//

import UIKit

public final class LiveGiftNumberView: UIView {

    /// 下一次 increaseNumber 返回的数字
    private var nextValue: Int = 0
    /// 上次显示的位数，位数不变时跳过约束调整
    private var lastLength: Int = 0
    /// 当前数字排的约束，位数变化时整组重建
    private var rowConstraints: [NSLayoutConstraint] = []

    private lazy var digitIV = makeImageView()
    private lazy var tenDigitIV = makeImageView()
    private lazy var hundredIV = makeImageView()
    private lazy var thousandIV = makeImageView()
    private lazy var xIV: UIImageView = {
        let iv = makeImageView()
        iv.image = liveGiftImage("w_x")
        return iv
    }()

    /// 重置计数起点，下一次 increaseNumber 将返回该值
    public func resetNumber(_ number: Int) {
        nextValue = number
    }

    /// 计数自增，返回本次应显示的数字
    @discardableResult
    public func increaseNumber() -> Int {
        let value = nextValue
        nextValue += 1
        return value
    }

    /// 当前显示的数字
    public var currentNumber: Int {
        return nextValue - 1
    }

    /// 改变数字显示，>9999 则显示 9999
    public func changeNumber(_ number: Int) {
        guard number > 0 else { return }

        var thousands = number / 1000
        var hundreds = (number % 1000) / 100
        var tens = (number % 100) / 10
        var ones = number % 10
        if number > 9999 {
            thousands = 9; hundreds = 9; tens = 9; ones = 9
        }

        let length = thousands > 0 ? 4 : (hundreds > 0 ? 3 : (tens > 0 ? 2 : 1))

        // 数字图片每次都要刷新（imageNamed 有缓存，开销极小）
        digitIV.image = liveGiftImage("w_\(ones)")
        if length >= 2 { tenDigitIV.image = liveGiftImage("w_\(tens)") }
        if length >= 3 { hundredIV.image = liveGiftImage("w_\(hundreds)") }
        if length >= 4 { thousandIV.image = liveGiftImage("w_\(thousands)") }

        // 位数没变时跳过视图层级与约束调整，连击场景下避免每次计数都强制同步布局
        guard length != lastLength else { return }
        lastLength = length

        NSLayoutConstraint.deactivate(rowConstraints)
        var constraints: [NSLayoutConstraint] = []

        addSubview(digitIV)
        constraints.append(digitIV.rightAnchor.constraint(equalTo: rightAnchor))
        constraints.append(digitIV.centerYAnchor.constraint(equalTo: centerYAnchor))

        if length >= 2 {
            addSubview(tenDigitIV)
            constraints.append(tenDigitIV.rightAnchor.constraint(equalTo: digitIV.leftAnchor))
            constraints.append(tenDigitIV.centerYAnchor.constraint(equalTo: digitIV.centerYAnchor))
        } else {
            tenDigitIV.removeFromSuperview()
        }
        if length >= 3 {
            addSubview(hundredIV)
            constraints.append(hundredIV.rightAnchor.constraint(equalTo: tenDigitIV.leftAnchor))
            constraints.append(hundredIV.centerYAnchor.constraint(equalTo: centerYAnchor))
        } else {
            hundredIV.removeFromSuperview()
        }
        if length >= 4 {
            addSubview(thousandIV)
            constraints.append(thousandIV.rightAnchor.constraint(equalTo: hundredIV.leftAnchor))
            constraints.append(thousandIV.centerYAnchor.constraint(equalTo: centerYAnchor))
        } else {
            thousandIV.removeFromSuperview()
        }

        addSubview(xIV)
        constraints.append(xIV.rightAnchor.constraint(equalTo: rightAnchor, constant: CGFloat(-15 * length)))
        constraints.append(xIV.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 2))
        constraints.append(xIV.widthAnchor.constraint(equalToConstant: 15))

        NSLayoutConstraint.activate(constraints)
        rowConstraints = constraints

        layoutIfNeeded()
    }

    private func makeImageView() -> UIImageView {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }
}
