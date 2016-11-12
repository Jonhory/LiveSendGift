//
//  UserModel.h
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic ,copy) NSString * name;
@property (nonatomic ,copy) NSString * iconUrl;

+ (instancetype)random;


@end
