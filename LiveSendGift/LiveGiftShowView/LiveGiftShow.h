//
//  LiveGiftShow.h
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//  所有弹幕管理视图

#import <UIKit/UIKit.h>
#import "Masonry.h"

#import "LiveGiftShowModel.h"

@interface LiveGiftShow : UIView


/**
 唯一入口

 @param model 传入模型数据 显示的数字自动从1开始加1
 */
- (void)addGiftListModel:(LiveGiftShowModel *)model;

@end
