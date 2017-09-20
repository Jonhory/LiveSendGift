//
//  LiveGiftShowView.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "LiveGiftShowView.h"
#import "LiveGiftListModel.h"

#import "UIImageView+WebCache.h"
#import "Masonry.h"

static CGFloat const kNameLabelFont = 12.0;//送礼者
#define kNameLabelTextColor [UIColor whiteColor]//送礼者颜色

static CGFloat const kGiftLabelFont = 10.0;//送出礼物寄语  字体大小
#define kGiftLabelTextColor [UIColor orangeColor]//礼物寄语 字体颜色

static CGFloat const kGiftNumberWidth = 15.0;

@interface LiveGiftShowView ()

@property (nonatomic ,weak) UIImageView * backIV;/**< 背景图 */
@property (nonatomic ,weak) UIImageView * iconIV;/**< 头像 */
@property (nonatomic ,weak) UILabel * nameLabel;/**< 名称 */
@property (nonatomic ,weak) UILabel * sendLabel;/**< 送出 */
@property (nonatomic ,weak) UIImageView * giftIV;/**< 礼物图片 */

@property (nonatomic ,strong) NSTimer * liveTimer;/**< 定时器控制自身移除 */
@property (nonatomic ,assign) NSInteger liveTimerForSecond;

@property (nonatomic ,assign) BOOL isSetNumber;

@end

@implementation LiveGiftShowView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, kViewWidth, kViewHeight)];
    if (self) {
        self.liveTimerForSecond = 0;
        [self setupContentContraints];
        self.creatDate = [NSDate date];
        self.kTimeOut = 3;
        self.kRemoveAnimationTime = 0.5;
        self.kNumberAnimationTime = 0.25;
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.liveTimerForSecond = 0;
        [self setupContentContraints];
    }
    return self;
}

- (void)setModel:(LiveGiftShowModel *)model{
    if (!model) {
        return;
    }
    _model = model;
    
    self.nameLabel.text = model.user.name;
    
    [self.iconIV sd_setImageWithURL:[NSURL URLWithString:model.user.iconUrl] placeholderImage:[UIImage imageNamed:@"LiveDefaultIcon"]];
    
    self.sendLabel.text = model.giftModel.rewardMsg;
    [self.giftIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",model.giftModel.picUrl]] placeholderImage:nil];
    
}

/**
 重置定时器和计数
 
 @param number 计数
 */
- (void)resetTimeAndNumberFrom:(NSInteger)number{
    self.numberView.number = number;
    [self addGiftNumberFrom:number];
}

/**
 获取用户名

 @return 获取用户名
 */
- (NSString *)getUserName{
    return self.nameLabel.text;
}

/**
 礼物数量自增1使用该方法

 @param number 从多少开始计数
 */
- (void)addGiftNumberFrom:(NSInteger)number{
    if (!self.isSetNumber) {
        self.numberView.number = number;
        self.isSetNumber = YES;
    }
    //每调用一次self.numberView.number get方法 自增1
    NSInteger num = self.numberView.number;
    [self.numberView changeNumber:num];
    [self handleNumber:num];
    self.model.currentNumber = num;
    self.creatDate = [NSDate date];
}


/**
 设置任意数字时使用该方法

 @param number 任意数字 >9999 则显示9999
 */
- (void)changeGiftNumber:(NSInteger)number{
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
- (void)handleNumber:(NSInteger )number{
    self.liveTimerForSecond = 0;
    //根据数字修改self.giftIV的约束 比如 1 占 10 的宽度，10 占 20的宽度
    NSString * numStr = [NSString stringWithFormat:@"%zi",number];
    CGFloat giftRight = numStr.length * kGiftNumberWidth + kGiftNumberWidth;
    
    [self.giftIV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-kGiftNumberWidth - giftRight);
    }];
    
    if (numStr.length >= 4) {
        [self.giftIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-kGiftNumberWidth * 6);
        }];
    }
    if (!CGAffineTransformIsIdentity(self.numberView.transform)) {
        [self.numberView.layer removeAllAnimations];
    }
    self.numberView.transform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:self.kNumberAnimationTime animations:^{
        self.numberView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    } completion:^(BOOL finished) {
        if (finished) {
            self.numberView.transform = CGAffineTransformIdentity;
        }
    }];
    
    [self.liveTimer setFireDate:[NSDate date]];
}

- (void)liveTimerRunning{
    self.liveTimerForSecond += 1;
    if (self.liveTimerForSecond > self.kTimeOut) {
        if (self.isAnimation == YES) {
            self.isAnimation = NO;
            return;
        }
        self.isAnimation = YES;
        self.isLeavingAnimation = YES;
        CGFloat xChanged = [UIScreen mainScreen].bounds.size.width;
        
        switch (self.hiddenModel) {
            case LiveGiftHiddenModeLeft:
                xChanged = -xChanged;
                break;
            default:
                break;
        }
        if (self.hiddenModel == LiveGiftHiddenModeNone) {
            self.isLeavingAnimation = NO;
            if (self.liveGiftShowViewTimeOut) {
                self.liveGiftShowViewTimeOut(self);
            }
            [self removeFromSuperview];
        } else {
            [UIView animateWithDuration:self.kRemoveAnimationTime delay:self.kNumberAnimationTime options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.transform = CGAffineTransformTranslate(self.transform, xChanged, 0);
            } completion:^(BOOL finished) {
                if (finished) {
                    self.isLeavingAnimation = NO;
                    if (self.liveGiftShowViewTimeOut) {
                        self.liveGiftShowViewTimeOut(self);
                    }
                    [self removeFromSuperview];
                }
            }];
        }
        
        [self stopTimer];
    }
    
}


- (void)setupContentContraints{
    [self.backIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    [self.iconIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@6);
        make.width.height.equalTo(@30);
        make.centerY.equalTo(self);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(9);
        make.left.equalTo(self.iconIV.mas_right).offset(6);
        make.width.equalTo(@86);
    }];
    
    [self.sendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(-9);
        make.left.equalTo(self.nameLabel);
    }];
    
    [self.giftIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right).offset(5).priority(750);
        make.width.equalTo(@32);
        make.height.equalTo(@24);
        make.centerY.equalTo(self);
    }];
    
    [self.numberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-kGiftNumberWidth);
        make.centerY.height.equalTo(self);
    }];
}

- (UIImageView *)backIV{
    if (!_backIV) {
        _backIV = [self creatIV];
        _backIV.image = [UIImage imageNamed:@"w_liveGiftBack"];
    }
    return _backIV;
}

- (UIImageView *)iconIV{
    if (!_iconIV) {
        _iconIV = [self creatIV];
        _iconIV.image = [UIImage imageNamed:@"LiveDefaultIcon"];
        _iconIV.layer.cornerRadius = 15;
        _iconIV.layer.masksToBounds = YES;
    }
    return _iconIV;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [self creatLabel];
        _nameLabel.textColor = kNameLabelTextColor;
        _nameLabel.font = [UIFont systemFontOfSize:kNameLabelFont];
    }
    return _nameLabel;
}

- (UILabel *)sendLabel{
    if (!_sendLabel) {
        _sendLabel = [self creatLabel];
        _sendLabel.font = [UIFont systemFontOfSize:kGiftLabelFont];
        _sendLabel.textColor = kGiftLabelTextColor;
    }
    return _sendLabel;
}


- (UIImageView *)giftIV{
    if (!_giftIV) {
        _giftIV = [self creatIV];
    }
    return _giftIV;
}

- (LiveGiftShowNumberView *)numberView{
    if (!_numberView) {
        LiveGiftShowNumberView * nv = [[LiveGiftShowNumberView alloc]init];
        [self addSubview:nv];
        _numberView = nv;
    }
    return _numberView;
}

- (UIImageView *)creatIV{
    UIImageView * iv = [[UIImageView alloc]init];
    [self addSubview:iv];
    return iv;
}

- (UILabel * )creatLabel{
    UILabel * label = [[UILabel alloc]init];
    [self addSubview:label];
    return label;
}


- (NSTimer *)liveTimer{
    if (!_liveTimer) {
        _liveTimer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(liveTimerRunning) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_liveTimer forMode:NSRunLoopCommonModes];
    }
    return _liveTimer;
}

- (void)stopTimer{
    if (_liveTimer) {
        [_liveTimer invalidate];
        _liveTimer = nil;
    }
}

@end
