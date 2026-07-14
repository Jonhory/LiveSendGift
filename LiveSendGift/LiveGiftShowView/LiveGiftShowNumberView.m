//
//  LiveGiftShowNumberView.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "LiveGiftShowNumberView.h"
#import "LiveGiftImageLoader.h"

@interface LiveGiftShowNumberView ()

@property (nonatomic ,strong) UIImageView * digitIV;
@property (nonatomic ,strong) UIImageView * ten_digitIV;
@property (nonatomic ,strong) UIImageView * hundredIV;
@property (nonatomic ,strong) UIImageView * thousandIV;

@property (nonatomic ,strong) UIImageView * xIV;

@property (nonatomic ,assign) NSInteger nextValue;/**< 下一次 increaseNumber 返回的数字 */
@property (nonatomic ,assign) NSInteger lastLength;/**< 上次显示的位数，位数不变时跳过约束调整 */
@property (nonatomic ,strong) NSArray<NSLayoutConstraint *> * rowConstraints;/**< 当前数字排的约束，位数变化时整组重建 */

@end

@implementation LiveGiftShowNumberView

- (void)resetNumber:(NSInteger)number{
    self.nextValue = number;
}

- (NSInteger)increaseNumber{
    NSInteger value = self.nextValue;
    self.nextValue += 1;
    return value;
}

- (NSInteger)currentNumber{
    return self.nextValue - 1;
}

/**
 改变数字显示
 
 @param numberStr 显示的数字
 */
- (void)changeNumber:(NSInteger)numberStr{
    if (numberStr <= 0) {
        return;
    }
    
    NSInteger num = numberStr;
    NSInteger qian = num / 1000;
    NSInteger qianYu = num % 1000;
    NSInteger bai = qianYu / 100;
    NSInteger baiYu = qianYu % 100;
    NSInteger shi = baiYu / 10;
    NSInteger shiYu = baiYu % 10;
    NSInteger ge = shiYu;
    
    if (numberStr > 9999) {
        qian = 9;
        bai = 9;
        shi = 9;
        ge = 9;
    }

    NSInteger length = qian > 0 ? 4 : (bai > 0 ? 3 : (shi > 0 ? 2 : 1));

    // 数字图片每次都要刷新（imageNamed 有缓存，开销极小）
    self.digitIV.image = LiveGiftImage([NSString stringWithFormat:@"w_%zi",ge]);
    if (length >= 2) {
        self.ten_digitIV.image = LiveGiftImage([NSString stringWithFormat:@"w_%zi",shi]);
    }
    if (length >= 3) {
        self.hundredIV.image = LiveGiftImage([NSString stringWithFormat:@"w_%zi",bai]);
    }
    if (length >= 4) {
        self.thousandIV.image = LiveGiftImage([NSString stringWithFormat:@"w_%zi",qian]);
    }

    // 位数没变时跳过视图层级与约束调整，连击场景下避免每次计数都强制同步布局（CPU 峰值主因之一）
    if (length == self.lastLength) {
        return;
    }
    self.lastLength = length;

    // 位数变化才走到这里（低频），整组重建约束（V2.0 起用系统 NSLayoutAnchor，移除 Masonry 依赖）
    [NSLayoutConstraint deactivateConstraints:self.rowConstraints ?: @[]];
    NSMutableArray<NSLayoutConstraint *> * constraints = [NSMutableArray array];

    [self addSubview:self.digitIV];
    [constraints addObject:[self.digitIV.rightAnchor constraintEqualToAnchor:self.rightAnchor]];
    [constraints addObject:[self.digitIV.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]];

    if (length >= 2) {
        [self addSubview:self.ten_digitIV];
        [constraints addObject:[self.ten_digitIV.rightAnchor constraintEqualToAnchor:self.digitIV.leftAnchor]];
        [constraints addObject:[self.ten_digitIV.centerYAnchor constraintEqualToAnchor:self.digitIV.centerYAnchor]];
    } else {
        [self.ten_digitIV removeFromSuperview];
    }
    if (length >= 3) {
        [self addSubview:self.hundredIV];
        [constraints addObject:[self.hundredIV.rightAnchor constraintEqualToAnchor:self.ten_digitIV.leftAnchor]];
        [constraints addObject:[self.hundredIV.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]];
    } else {
        [self.hundredIV removeFromSuperview];
    }
    if (length >= 4) {
        [self addSubview:self.thousandIV];
        [constraints addObject:[self.thousandIV.rightAnchor constraintEqualToAnchor:self.hundredIV.leftAnchor]];
        [constraints addObject:[self.thousandIV.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]];
    } else {
        [self.thousandIV removeFromSuperview];
    }

    [self addSubview:self.xIV];
    [constraints addObject:[self.xIV.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-15*length]];
    [constraints addObject:[self.xIV.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:2]];
    [constraints addObject:[self.xIV.widthAnchor constraintEqualToConstant:15]];

    [NSLayoutConstraint activateConstraints:constraints];
    self.rowConstraints = constraints;

    [self layoutIfNeeded];

}

- (UIImageView *)xIV{
    if (!_xIV) {
        _xIV = [self createIV];
        _xIV.image = LiveGiftImage(@"w_x");
    }
    return _xIV;
}

- (UIImageView *)digitIV{
    if (!_digitIV) {
        _digitIV = [self createIV];
    }
    return _digitIV;
}

- (UIImageView *)ten_digitIV{
    if (!_ten_digitIV) {
        _ten_digitIV = [self createIV];
    }
    return _ten_digitIV;
}

- (UIImageView *)hundredIV{
    if (!_hundredIV) {
        _hundredIV = [self createIV];
    }
    return _hundredIV;
}

- (UIImageView *)thousandIV{
    if (!_thousandIV) {
        _thousandIV = [self createIV];
    }
    return _thousandIV;
}

- (UIImageView *)createIV{
    UIImageView * iv = [[UIImageView alloc]init];
    iv.translatesAutoresizingMaskIntoConstraints = NO;
    return iv;
}

@end
