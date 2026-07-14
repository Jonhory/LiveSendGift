//
//  LiveGiftShowView.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "LiveGiftShowView.h"
#import "LiveGiftListModel.h"

// SDWebImage 为可选依赖：未集成且未注入 webImageLoader 时仅显示占位图
#if __has_include(<SDWebImage/SDWebImage.h>)
#import <SDWebImage/SDWebImage.h>
#define LIVE_HAS_SDWEBIMAGE 1
#elif __has_include("UIImageView+WebCache.h")
#import "UIImageView+WebCache.h"
#define LIVE_HAS_SDWEBIMAGE 1
#else
#define LIVE_HAS_SDWEBIMAGE 0
#endif
#import "LiveGiftImageLoader.h"

static CGFloat const kNameLabelFont = 12.0;      // 送礼者
#define kNameLabelTextColor [UIColor whiteColor] // 送礼者颜色

static CGFloat const kGiftLabelFont = 10.0;       // 送出礼物寄语  字体大小
#define kGiftLabelTextColor [UIColor orangeColor] // 礼物寄语 字体颜色

static CGFloat const kGiftNumberWidth = 15.0;

@interface LiveGiftShowView ()

@property (nonatomic, weak) UIImageView *backIV; /**< 背景图 */
@property (nonatomic, weak) UIImageView *iconIV; /**< 头像 */
@property (nonatomic, weak) UILabel *nameLabel;  /**< 名称 */
@property (nonatomic, weak) UILabel *sendLabel;  /**< 送出 */
@property (nonatomic, weak) UIImageView *giftIV; /**< 礼物图片 */

@property (nonatomic, strong) dispatch_block_t timeoutBlock; /**< 超时移除任务，计数变化时重置 */

@property (nonatomic, assign) BOOL isSetNumber;
@property (nonatomic, assign) NSUInteger lastNumberLength;               /**< 上次数字位数，位数不变时跳过约束更新 */
@property (nonatomic, strong) NSLayoutConstraint *giftIVRightConstraint; /**< 礼物图右边距，随数字位数调整 */

@end

@implementation LiveGiftShowView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, kViewWidth, kViewHeight)];
    if (self) {
        [self setupContentContraints];
        self.createDate = [NSDate date];
        self.kTimeOut = 3;
        self.kRemoveAnimationTime = 0.5;
        self.kNumberAnimationTime = 0.25;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupContentContraints];
    }
    return self;
}

- (void)setModel:(LiveGiftShowModel *)model {
    if (!model) {
        return;
    }
    _model = model;

    self.nameLabel.text = model.user.name;
    self.sendLabel.text = model.giftModel.rewardMsg;

    UIImage *iconPlaceholder = LiveGiftImage(@"LiveDefaultIcon");
    if (self.imageLoader) {
        // 宿主注入的加载器（Kingfisher / 自研等）
        self.imageLoader(self.iconIV, model.user.iconUrl, iconPlaceholder);
        self.imageLoader(self.giftIV, model.giftModel.picUrl, nil);
    } else {
#if LIVE_HAS_SDWEBIMAGE
        [self.iconIV sd_setImageWithURL:[NSURL URLWithString:model.user.iconUrl ?: @""]
                       placeholderImage:iconPlaceholder];
        [self.giftIV sd_setImageWithURL:[NSURL URLWithString:model.giftModel.picUrl ?: @""] placeholderImage:nil];
#else
        self.iconIV.image = iconPlaceholder;
#endif
    }
}

/**
 重置定时器和计数

 @param number 计数
 */
- (void)resetTimeAndNumberFrom:(NSInteger)number {
    [self.numberView resetNumber:number];
    [self addGiftNumberFrom:number];
}

/**
 获取用户名

 @return 获取用户名
 */
- (NSString *)getUserName {
    return self.nameLabel.text;
}

/**
 礼物数量自增1使用该方法

 @param number 从多少开始计数
 */
- (void)addGiftNumberFrom:(NSInteger)number {
    if (!self.isSetNumber) {
        [self.numberView resetNumber:number];
        self.isSetNumber = YES;
    }
    // 显式自增（V2.0：替代原先带副作用的 number getter）
    NSInteger num = [self.numberView increaseNumber];
    [self.numberView changeNumber:num];
    [self handleNumber:num];
    self.model.currentNumber = num;
    self.createDate = [NSDate date];
}


/**
 设置任意数字时使用该方法

 @param number 任意数字 >9999 则显示9999
 */
- (void)changeGiftNumber:(NSInteger)number {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.numberView changeNumber:number];
        [self handleNumber:number];
    });
}

#pragma mark - Private
/**
 处理显示数字 开启定时器

 @param number 显示数字的值
 */
- (void)handleNumber:(NSInteger)number {
    // 根据数字修改self.giftIV的约束 比如 1 占 10 的宽度，10 占 20的宽度
    // 位数没变时无需更新约束，连击场景下减少布局开销
    NSString *numStr = [NSString stringWithFormat:@"%zi", number];
    if (numStr.length != self.lastNumberLength) {
        self.lastNumberLength = numStr.length;
        CGFloat giftRight = numStr.length >= 4 ? kGiftNumberWidth * 5 : numStr.length * kGiftNumberWidth + kGiftNumberWidth;
        self.giftIVRightConstraint.constant = -kGiftNumberWidth - giftRight;
    }
    if (!CGAffineTransformIsIdentity(self.numberView.transform)) {
        [self.numberView.layer removeAllAnimations];
    }
    self.numberView.transform = CGAffineTransformIdentity;

    [UIView animateWithDuration:self.kNumberAnimationTime
        animations:^{
            self.numberView.transform = CGAffineTransformMakeScale(1.5, 1.5);
        }
        completion:^(BOOL finished) {
            self.numberView.transform = CGAffineTransformIdentity;
        }];

    // 计数变化即重置消失倒计时；相比每秒轮询的 NSTimer 更省电
    [self scheduleTimeoutAfter:self.kTimeOut + 1];
}

/// 重排超时任务，delay 秒后未再收到计数变化则触发移除
- (void)scheduleTimeoutAfter:(NSTimeInterval)delay {
    if (self.timeoutBlock) {
        dispatch_block_cancel(self.timeoutBlock);
    }
    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = dispatch_block_create(0, ^{
        [weakSelf timeoutFired];
    });
    self.timeoutBlock = block;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

- (void)timeoutFired {
    if (!self.superview) {
        return;
    }
    if (self.isAnimation == YES) {
        // 正在交换动画，宽限 1 秒后重试（对齐旧轮询行为）
        self.isAnimation = NO;
        [self scheduleTimeoutAfter:1];
        return;
    }
    {
        self.isAnimation = YES;
        self.isLeavingAnimation = YES;
        // 用 window 宽度计算飞出距离，iPad 分屏等非全屏场景下 mainScreen 宽度会偏大
        CGFloat xChanged = self.window ? CGRectGetWidth(self.window.bounds) : CGRectGetWidth([UIScreen mainScreen].bounds);

        switch (self.hiddenMode) {
        case LiveGiftHiddenModeLeft:
            xChanged = -xChanged;
            break;
        default:
            break;
        }

        if (self.hiddenMode == LiveGiftHiddenModeNone) {
            self.isLeavingAnimation = NO;
            if (self.liveGiftShowViewTimeOut) {
                self.liveGiftShowViewTimeOut(self);
            }
            [self removeFromSuperview];
        } else {
            [UIView animateWithDuration:self.kRemoveAnimationTime
                delay:0
                options:UIViewAnimationOptionCurveEaseIn
                animations:^{
                    self.transform = CGAffineTransformTranslate(self.transform, xChanged, 0);
                }
                completion:^(BOOL finished) {
                    self.isLeavingAnimation = NO;
                    if (self.liveGiftShowViewTimeOut) {
                        self.liveGiftShowViewTimeOut(self);
                    }
                    [self removeFromSuperview];
                }];
        }
    }
}


- (void)setupContentContraints {
    // V2.0 起用系统 NSLayoutAnchor，移除 Masonry 依赖
    self.backIV.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconIV.translatesAutoresizingMaskIntoConstraints = NO;
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.sendLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.giftIV.translatesAutoresizingMaskIntoConstraints = NO;
    self.numberView.translatesAutoresizingMaskIntoConstraints = NO;

    // 礼物图靠左约束低优先级，右边距（随数字位数变化）优先
    NSLayoutConstraint *giftLeft = [self.giftIV.leftAnchor constraintEqualToAnchor:self.nameLabel.rightAnchor constant:5];
    giftLeft.priority = UILayoutPriorityDefaultHigh;
    self.giftIVRightConstraint = [self.giftIV.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-kGiftNumberWidth * 2 - 1];

    [NSLayoutConstraint activateConstraints:@[
        [self.backIV.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.backIV.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.backIV.leftAnchor constraintEqualToAnchor:self.leftAnchor],
        [self.backIV.rightAnchor constraintEqualToAnchor:self.rightAnchor],

        [self.iconIV.leftAnchor constraintEqualToAnchor:self.leftAnchor
                                               constant:6],
        [self.iconIV.widthAnchor constraintEqualToConstant:30],
        [self.iconIV.heightAnchor constraintEqualToConstant:30],
        [self.iconIV.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],

        [self.nameLabel.topAnchor constraintEqualToAnchor:self.topAnchor
                                                 constant:9],
        [self.nameLabel.leftAnchor constraintEqualToAnchor:self.iconIV.rightAnchor
                                                  constant:6],
        [self.nameLabel.widthAnchor constraintEqualToConstant:86],

        [self.sendLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor
                                                    constant:-9],
        [self.sendLabel.leftAnchor constraintEqualToAnchor:self.nameLabel.leftAnchor],

        giftLeft,
        self.giftIVRightConstraint,
        [self.giftIV.widthAnchor constraintEqualToConstant:32],
        [self.giftIV.heightAnchor constraintEqualToConstant:24],
        [self.giftIV.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],

        [self.numberView.rightAnchor constraintEqualToAnchor:self.rightAnchor
                                                    constant:-kGiftNumberWidth],
        [self.numberView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.numberView.heightAnchor constraintEqualToAnchor:self.heightAnchor],
    ]];
}

- (UIImageView *)backIV {
    if (!_backIV) {
        _backIV = [self createIV];
        _backIV.image = LiveGiftImage(@"w_liveGiftBack");
    }
    return _backIV;
}

- (UIImageView *)iconIV {
    if (!_iconIV) {
        _iconIV = [self createIV];
        _iconIV.image = LiveGiftImage(@"LiveDefaultIcon");
        _iconIV.layer.cornerRadius = 15;
        _iconIV.layer.masksToBounds = YES;
    }
    return _iconIV;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [self createLabel];
        _nameLabel.textColor = kNameLabelTextColor;
        _nameLabel.font = [UIFont systemFontOfSize:kNameLabelFont];
    }
    return _nameLabel;
}

- (UILabel *)sendLabel {
    if (!_sendLabel) {
        _sendLabel = [self createLabel];
        _sendLabel.font = [UIFont systemFontOfSize:kGiftLabelFont];
        _sendLabel.textColor = kGiftLabelTextColor;
    }
    return _sendLabel;
}


- (UIImageView *)giftIV {
    if (!_giftIV) {
        _giftIV = [self createIV];
    }
    return _giftIV;
}

- (LiveGiftShowNumberView *)numberView {
    if (!_numberView) {
        LiveGiftShowNumberView *nv = [[LiveGiftShowNumberView alloc] init];
        [self addSubview:nv];
        _numberView = nv;
    }
    return _numberView;
}

- (UIImageView *)createIV {
    UIImageView *iv = [[UIImageView alloc] init];
    [self addSubview:iv];
    return iv;
}

- (UILabel *)createLabel {
    UILabel *label = [[UILabel alloc] init];
    [self addSubview:label];
    return label;
}


- (void)dealloc {
    if (_timeoutBlock) {
        dispatch_block_cancel(_timeoutBlock);
    }
}

@end
