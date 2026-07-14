//
//  LiveGiftShowCustom.h
//  LiveSendGift
//
//  Created by Jonhory on 2016/12/4.
//  Copyright © 2016年 com.wujh. All rights reserved.
//  Update on 2017/4/26

#import <UIKit/UIKit.h>

#import "LiveGiftShowModel.h"

// 项目打包上线都不会打印日志
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
 - LiveGiftAddModeQueue: 当有新弹幕时会进入队列
 */
typedef NS_ENUM(NSUInteger, LiveGiftAddMode) {
    LiveGiftAddModeReplace = 0,
    LiveGiftAddModeQueue   = 1,
};

NS_ASSUME_NONNULL_BEGIN

/**
 网络图片加载器（V2.0 新增，用于解耦 SDWebImage）

 @param imageView   目标视图（头像 / 礼物图）
 @param urlString   图片地址，可能为 nil
 @param placeholder 占位图，可能为 nil
 */
typedef void (^LiveGiftWebImageLoader)(UIImageView *imageView, NSString * _Nullable urlString, UIImage * _Nullable placeholder);

@protocol LiveGiftShowCustomDelegate <NSObject>

@optional
- (void)giftDidRemove:(LiveGiftShowModel *)showModel;

@end

@interface LiveGiftShowCustom : UIView

+ (instancetype)addToView:(UIView *)superView;
+ (instancetype)addToView:(UIView *)superView y:(CGFloat)y;

@property(nonatomic, assign) CGFloat kExchangeAnimationTime;/**< 交换动画时长 */
@property(nonatomic, assign) CGFloat kAppearAnimationTime;/**< 出现时动画时长 */
@property(nonatomic, assign) LiveGiftAddMode addMode;/** 弹幕添加模式,默认替换 */

@property(nonatomic, weak, nullable) id<LiveGiftShowCustomDelegate> delegate;

// V2.0：以下配置由全局 static 改为实例属性，多个实例互不影响。
// 公开方法（addLiveGiftShowModel: 等）线程安全，非主线程调用会自动转到主队列。

@property(nonatomic, assign) NSInteger maxRailwayCount;/**< 最大礼物轨道数量，默认 3 */
@property(nonatomic, assign) BOOL railwayCanExchange;/**< 轨道能否进行交换动画，默认 YES */
@property(nonatomic, assign) LiveGiftShowMode showMode;/**< 弹幕展现模式，默认自上而下 */
@property(nonatomic, assign) LiveGiftHiddenMode hiddenMode;/**< 弹幕消失模式，默认向右移出 */
@property(nonatomic, assign) LiveGiftAppearMode appearMode;/**< 弹幕出现模式，默认从左出现 */
@property(nonatomic, assign) BOOL interfaceDebugEnabled;/**< 是否打印调试信息，默认 NO */

/**
 网络图片加载器。默认 nil：集成了 SDWebImage 时自动使用 SDWebImage，
 否则仅显示占位图。使用 Kingfisher/自研加载器的宿主可注入此 block，
 即可完全不依赖 SDWebImage（CocoaPods 请用 `LiveSendGift/Core` subspec）。
 */
@property(nonatomic, copy, nullable) LiveGiftWebImageLoader webImageLoader;

/**
 *  设置是否打印信息
 *
 *  @param isDebug 开发的时候最好打开，默认是NO
 */
- (void)enableInterfaceDebug:(BOOL)isDebug __deprecated_msg("Use the interfaceDebugEnabled property");

/**
 设置弹幕消失模式

 @param model 弹幕消失模式
 */
- (void)setHiddenModel:(LiveGiftHiddenMode)model __deprecated_msg("Use the hiddenMode property");

/**
 设置弹幕出现模式

 @param model 弹幕出现模式
 */
- (void)setAppearModel:(LiveGiftAppearMode)model __deprecated_msg("Use the appearMode property");

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

NS_ASSUME_NONNULL_END
