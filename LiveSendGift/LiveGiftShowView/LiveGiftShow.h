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

- (void)addGiftListModel:(LiveGiftShowModel *)model;

@end
