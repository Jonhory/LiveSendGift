//
//  LiveGiftShowView.h
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//  一个弹幕效果视图

#import <UIKit/UIKit.h>
#import "LiveGiftShowModel.h"
#import "LiveGiftShowNumberView.h"
#import "LiveGiftShowCustom.h"

static CGFloat const kViewWidth = 240.0;//背景宽
static CGFloat const kViewHeight = 44.0;//背景高

@interface LiveGiftShowView : UIView

@property (nonatomic, assign) NSInteger kTimeOut;/**< 超时移除时长 */
@property (nonatomic, assign) CGFloat kRemoveAnimationTime;/**< 移除动画时长 */
@property (nonatomic, assign) CGFloat kNumberAnimationTime;/**< 数字改变动画时长 */

@property (nonatomic ,copy) NSDate * creatDate;/**< 视图创建时间，用于LiveGiftShow替换旧的视图 V1.5在内部创建*/
@property (nonatomic ,assign) NSInteger index;/**< 用于LiveGiftShow判断是第几个视图 */

@property (nonatomic ,strong) LiveGiftShowModel * model;/**< 数据源*/

@property (nonatomic, assign) LiveGiftHiddenMode hiddenModel;/**< 消失模式*/

@property (nonatomic ,weak) LiveGiftShowNumberView * numberView;

@property (nonatomic ,assign) BOOL isAnimation;/**< 是否正处于动画，用于上下视图交换位置时使用 */
@property (nonatomic ,assign) BOOL isLeavingAnimation;/**< 是否正处于动画，用于视图正在向右飞出时不要交换位置 */
@property (nonatomic, assign) BOOL isAppearAnimation;/**< 是否正处于动画，用于出现动画时和交换位置的动画冲突*/

@property (nonatomic ,copy) void(^liveGiftShowViewTimeOut)(LiveGiftShowView *);


/**
 重置定时器和计数

 @param number 计数
 */
- (void)resetTimeAndNumberFrom:(NSInteger)number;

/**
 获取用户名
 
 @return 获取用户名
 */
- (NSString *)getUserName;

/**
 礼物数量自增1使用该方法
 
 @param number 从多少开始计数
 */
- (void)addGiftNumberFrom:(NSInteger)number;

/**
 设置任意数字时使用该方法
 
 @param number 任意数字 >9999 则显示9999
 */
- (void)changeGiftNumber:(NSInteger)number;



@end
