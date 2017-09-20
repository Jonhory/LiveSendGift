//
//  LiveGiftShowCustom.h
//  LiveSendGift
//
//  Created by Jonhory on 2016/12/4.
//  Copyright © 2016年 com.wujh. All rights reserved.
//  Update on 2017/4/26

#import <UIKit/UIKit.h>

#import "Masonry.h"
#import "LiveGiftShowModel.h"

// 项目打包上线都不会打印日志，因此可放心。
#ifdef DEBUG
#define WLog(s, ... ) NSLog( @"[%@ in line %d] %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define WLog(s, ... )
#endif

/**
 弹幕展现模式

 - fromTopToBottom: 自上而下
 - fromBottomToTop: 自下而上
 */
typedef NS_ENUM(NSUInteger, LiveGiftShowMode) {
    LiveGiftShowModeFromTopToBottom = 0,
    LiveGiftShowModeFromBottomToTop = 1,
};

/**
 弹幕消失模式

 - right: 向右移出
 - left: 向左移出
 */
typedef NS_ENUM(NSUInteger, LiveGiftHiddenMode) {
    LiveGiftHiddenModeRight = 0,
    LiveGiftHiddenModeLeft = 1,
    LiveGiftHiddenModeNone = 2,
};

/**
 弹幕出现模式

 - none: 无效果
 - left: 从左到右出现（左进）
 */
typedef NS_ENUM(NSUInteger, LiveGiftAppearMode) {
    LiveGiftAppearModeNone = 0,
    LiveGiftAppearModeLeft = 1,
};


/**
 弹幕添加模式（当弹幕达到最大数量后新增弹幕时）,默认替换

 - LiveGiftAddModeReplace: 当有新弹幕时会替换
 - LiveGiftAddModeAdd: 当有新弹幕时会进入队列
 */
typedef NS_ENUM(NSUInteger, LiveGiftAddMode) {
    LiveGiftAddModeReplace = 0,
    LiveGiftAddModeAdd     = 1,
};

@protocol LiveGiftShowCustomDelegate <NSObject>

@optional
- (void)giftDidRemove:(LiveGiftShowModel *)showModel;

@end

@interface LiveGiftShowCustom : UIView

+ (instancetype)addToView:(UIView *)superView;

@property(nonatomic, assign) CGFloat kExchangeAnimationTime;/**< 交换动画时长 */
@property(nonatomic, assign) CGFloat kAppearAnimationTime;/**< 出现时动画时长 */
@property(nonatomic, assign) LiveGiftAddMode addMode;/** 弹幕添加模式,默认替换 */

@property(nonatomic, weak) id<LiveGiftShowCustomDelegate> delegate;

/**
 *  设置是否打印信息
 *
 *  @param isDebug 开发的时候最好打开，默认是NO
 */
- (void)enableInterfaceDebug:(BOOL)isDebug;

/**
 设置最大礼物数量

 @param maxGiftCount 默认为3
 */
- (void)setMaxGiftCount:(NSInteger)maxGiftCount;

/**
 设置弹幕展现模式

 @param model 弹幕展现模式
 */
- (void)setShowMode:(LiveGiftShowMode)model;

/**
 设置弹幕消失模式

 @param model 弹幕消失模式
 */
- (void)setHiddenModel:(LiveGiftHiddenMode)model;

/**
 设置弹幕出现模式

 @param model 弹幕出现模式
 */
- (void)setAppearModel:(LiveGiftAppearMode)model;

/**
 增加或者更新一个礼物视图

 @param showModel 礼物模型
 */
- (void)addLiveGiftShowModel:(LiveGiftShowModel *)showModel;

/**
 增加或者更新一个礼物视图

 @param showModel 礼物模型
 @param showNumber 如果传值，则显示改值，否则从1开始自增1
 */
- (void)addLiveGiftShowModel:(LiveGiftShowModel *)showModel showNumber:(NSInteger)showNumber;

/**
 添加一个礼物视图，若该礼物不在视图上则从数字1显示到指定数字的效果，否则继续增加指定数字

 @param showModel 礼物模型
 */
- (void)animatedWithGiftModel:(LiveGiftShowModel *)showModel;

@end
