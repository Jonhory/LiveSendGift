//
//  LiveGiftShowModel.h
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//  包含用户信息和礼物信息

#import <Foundation/Foundation.h>
#import "ZYGiftListModel.h"
#import "UserModel.h"

@interface LiveGiftShowModel : NSObject

@property (nonatomic ,strong) ZYGiftListModel * giftModel;

@property (nonatomic ,strong) UserModel * user;

+ (instancetype)giftModel:(ZYGiftListModel *)giftModel userModel:(UserModel *)userModel;

@end
