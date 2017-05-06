//
//  LiveGiftShowModel.h
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//  包含用户信息和礼物信息

#import <Foundation/Foundation.h>
#import "LiveGiftListModel.h"
#import "LiveUserModel.h"


@interface LiveGiftShowModel : NSObject

@property (nonatomic ,strong) LiveGiftListModel * giftModel;

@property (nonatomic ,strong) LiveUserModel * user;

+ (instancetype)giftModel:(LiveGiftListModel *)giftModel userModel:(LiveUserModel *)userModel;

@end
