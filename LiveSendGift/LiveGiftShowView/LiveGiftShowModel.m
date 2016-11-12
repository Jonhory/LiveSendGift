//
//  LiveGiftShowModel.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "LiveGiftShowModel.h"

@implementation LiveGiftShowModel

+ (instancetype)giftModel:(ZYGiftListModel *)giftModel userModel:(UserModel *)userModel{
    LiveGiftShowModel * model = [[LiveGiftShowModel alloc]init];
    model.giftModel = giftModel;
    model.user = userModel;
    return model;
}


@end
