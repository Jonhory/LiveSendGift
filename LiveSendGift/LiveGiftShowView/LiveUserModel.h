//
//  UserModel.h
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveUserModel : NSObject

@property (nonatomic ,copy) NSString * userId;/**< 用户唯一标识，用于区分弹幕归属；不传则退化为用 name 区分（同名用户会被合并） */
@property (nonatomic ,copy) NSString * name;
@property (nonatomic ,copy) NSString * iconUrl;

@end
