//
//  UserModel.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

+ (instancetype)random{
    UserModel * model = [[UserModel alloc]init];
    NSMutableString * str = [[NSMutableString alloc]init];
    for (int i = 0; i<arc4random()%10+1; i++) {
        [str appendFormat:@"%d",i];
    }
    model.name = str;
    return model;
}

@end
