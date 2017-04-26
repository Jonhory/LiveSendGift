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
    fromTopToBottom = 0,
    fromBottomToTop = 1,
};

@interface LiveGiftShowCustom : UIView

+ (instancetype)addToView:(UIView *)superView;

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

@end
