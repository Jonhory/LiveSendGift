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

@end
