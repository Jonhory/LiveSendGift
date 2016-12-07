//
//  LiveGiftShowCustom.h
//  LiveSendGift
//
//  Created by Jonhory on 2016/12/4.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Masonry.h"
#import "LiveGiftShowModel.h"

@interface LiveGiftShowCustom : UIView

+ (instancetype)addToView:(UIView *)superView;


- (void)addLiveGiftShowModel:(LiveGiftShowModel *)showModel;

/**
 增加或者更新一个礼物视图

 @param showModel 礼物模型
 @param showNumber 如果传值，则显示改值，否则从1开始自增1
 */
- (void)addLiveGiftShowModel:(LiveGiftShowModel *)showModel showNumber:(NSInteger)showNumber;

@end
