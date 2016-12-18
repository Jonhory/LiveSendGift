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
    model.name = [self randomStrWithLength:arc4random()%10+1];
    model.iconUrl = @"http://ww3.sinaimg.cn/large/c6a1cfeagw1faewpod4p4j20ii0jw76i.jpg";
    return model;
}

+ (NSString *)randomStrWithLength:(int)length{
    NSString *string = [[NSString alloc]init];
    for (int i = 0; i < length; i++) {
        int number = arc4random() % 36;
        if (number < 10) {
            int figure = arc4random() % 10;
            NSString *tempString = [NSString stringWithFormat:@"%d", figure];
            string = [string stringByAppendingString:tempString];
        }else {
            int figure = (arc4random() % 26) + 97;
            char character = figure;
            NSString *tempString = [NSString stringWithFormat:@"%c", character];
            string = [string stringByAppendingString:tempString];
        }
    }
    return string;
}

@end
