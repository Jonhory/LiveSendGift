//
//  LiveGiftShowNumberView.h
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//  弹幕效果数字变化的视图

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveGiftShowNumberView : UIView

/**
 重置计数起点，下一次 increaseNumber 将返回该值

 @param number 计数起点
 */
- (void)resetNumber:(NSInteger)number;

/**
 计数自增，返回本次应显示的数字
 （V2.0：替代原先带自增副作用的 number getter）

 @return 本次应显示的数字
 */
- (NSInteger)increaseNumber;

/**
 获取当前显示的数字

 @return 当前显示的数字
 */
- (NSInteger)currentNumber;

/**
 改变数字显示

 @param numberStr 显示的数字
 */
- (void)changeNumber:(NSInteger )numberStr;

@end

NS_ASSUME_NONNULL_END
